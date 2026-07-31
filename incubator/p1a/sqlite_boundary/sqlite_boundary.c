/*
 * Phase-1A generic SQLite boundary experiment.
 *
 * This deliberately contains no application or RAG vocabulary.  It exists to
 * measure and validate the smallest typed cREXX/SQLite ownership boundary.
 */

#include "crexxpa.h"

#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sqlite3.h>

enum {
    SQL_BOUNDARY_OK = 0,
    SQL_BOUNDARY_ROW = 100,
    SQL_BOUNDARY_DONE = 101,
    SQL_BOUNDARY_INVALID_ARGUMENT = -1,
    SQL_BOUNDARY_INVALID_HANDLE = -2,
    SQL_BOUNDARY_CLOSED_HANDLE = -3,
    SQL_BOUNDARY_WRONG_HANDLE_KIND = -4,
    SQL_BOUNDARY_NO_MEMORY = -5,
    SQL_BOUNDARY_SQLITE_ERROR = -6,
    SQL_BOUNDARY_TYPE_MISMATCH = -7
};

enum handle_kind {
    HANDLE_DATABASE = 1,
    HANDLE_STATEMENT = 2
};

typedef struct boundary_handle boundary_handle;

struct boundary_handle {
    enum handle_kind kind;
    int closed;
    size_t references;
    union {
        sqlite3 *database;
        sqlite3_stmt *statement;
    } resource;
    boundary_handle *parent;
    boundary_handle *next;
};

typedef struct handle_payload {
    uint64_t magic;
    boundary_handle *handle;
} handle_payload;

typedef struct error_state {
    int code;
    int sqlite_code;
    char operation[64];
    char message[768];
} error_state;

#define HANDLE_MAGIC UINT64_C(0x53514c3141484e44)

static boundary_handle *live_handles;
static error_state last_error;

static void handle_payload_copy(void *destination, void *source);
static void handle_payload_finalize(void *value);

static const rxpa_native_payload_ops handle_payload_ops = {
    "crexx.sqlite_boundary.handle.v1",
    handle_payload_copy,
    handle_payload_finalize
};

static void clear_error(void) {
    memset(&last_error, 0, sizeof(last_error));
}

static int fail_with(int code, int sqlite_code, const char *operation,
                     const char *message) {
    last_error.code = code;
    last_error.sqlite_code = sqlite_code;
    snprintf(last_error.operation, sizeof(last_error.operation), "%s",
             operation ? operation : "unknown");
    snprintf(last_error.message, sizeof(last_error.message), "%s",
             message ? message : "unspecified error");
    return code;
}

static int fail_sqlite(sqlite3 *database, int sqlite_code,
                       const char *operation) {
    const char *message = database ? sqlite3_errmsg(database)
                                   : sqlite3_errstr(sqlite_code);
    return fail_with(SQL_BOUNDARY_SQLITE_ERROR, sqlite_code, operation, message);
}

static int handle_is_registered(const boundary_handle *candidate) {
    const boundary_handle *cursor;
    for (cursor = live_handles; cursor; cursor = cursor->next) {
        if (cursor == candidate) return 1;
    }
    return 0;
}

static void register_handle(boundary_handle *handle) {
    handle->next = live_handles;
    live_handles = handle;
}

static void unregister_handle(boundary_handle *handle) {
    boundary_handle **cursor = &live_handles;
    while (*cursor) {
        if (*cursor == handle) {
            *cursor = handle->next;
            return;
        }
        cursor = &(*cursor)->next;
    }
}

static void retain_handle(boundary_handle *handle) {
    if (handle) handle->references++;
}

static void close_statement_resource(boundary_handle *handle) {
    if (!handle || handle->kind != HANDLE_STATEMENT || handle->closed) return;
    if (handle->resource.statement) sqlite3_finalize(handle->resource.statement);
    handle->resource.statement = NULL;
    handle->closed = 1;
}

static void close_database_resource(boundary_handle *handle) {
    boundary_handle *cursor;
    if (!handle || handle->kind != HANDLE_DATABASE || handle->closed) return;

    for (cursor = live_handles; cursor; cursor = cursor->next) {
        if (cursor->kind == HANDLE_STATEMENT && cursor->parent == handle) {
            close_statement_resource(cursor);
        }
    }
    if (handle->resource.database) sqlite3_close_v2(handle->resource.database);
    handle->resource.database = NULL;
    handle->closed = 1;
}

static void release_handle(boundary_handle *handle) {
    boundary_handle *parent;
    if (!handle || !handle_is_registered(handle) || handle->references == 0) return;
    handle->references--;
    if (handle->references != 0) return;

    if (handle->kind == HANDLE_STATEMENT) close_statement_resource(handle);
    if (handle->kind == HANDLE_DATABASE) close_database_resource(handle);
    parent = handle->parent;
    unregister_handle(handle);
    free(handle);
    if (parent) release_handle(parent);
}

static void handle_payload_copy(void *destination, void *source) {
    const rxpa_native_payload_ops *ops = NULL;
    handle_payload *source_payload;
    handle_payload copied_payload;
    size_t length = 0;

    source_payload = (handle_payload *)GETNATIVEPAYLOAD(
        source, &length, &ops, NULL);
    if (!source_payload || length != sizeof(*source_payload) ||
        ops != &handle_payload_ops || source_payload->magic != HANDLE_MAGIC ||
        !handle_is_registered(source_payload->handle)) {
        return;
    }

    copied_payload = *source_payload;
    retain_handle(copied_payload.handle);
    if (SETNATIVEPAYLOAD(destination, &copied_payload, sizeof(copied_payload),
                         &handle_payload_ops, 0) != 0) {
        release_handle(copied_payload.handle);
    }
}

static void handle_payload_finalize(void *value) {
    const rxpa_native_payload_ops *ops = NULL;
    handle_payload *payload;
    size_t length = 0;

    payload = (handle_payload *)GETNATIVEPAYLOAD(value, &length, &ops, NULL);
    if (payload && length == sizeof(*payload) && ops == &handle_payload_ops &&
        payload->magic == HANDLE_MAGIC) {
        release_handle(payload->handle);
    }
}

static boundary_handle *new_handle(enum handle_kind kind) {
    boundary_handle *handle = (boundary_handle *)calloc(1, sizeof(*handle));
    if (!handle) return NULL;
    handle->kind = kind;
    handle->references = 1;
    register_handle(handle);
    return handle;
}

static int publish_handle(rxpa_attribute_value destination,
                          boundary_handle *handle) {
    handle_payload payload;
    payload.magic = HANDLE_MAGIC;
    payload.handle = handle;
    if (SETNATIVEPAYLOAD(destination, &payload, sizeof(payload),
                         &handle_payload_ops, 0) != 0) {
        release_handle(handle);
        return fail_with(SQL_BOUNDARY_NO_MEMORY, SQLITE_NOMEM, "publish_handle",
                         "could not publish native handle payload");
    }
    return SQL_BOUNDARY_OK;
}

static int get_handle(rxpa_attribute_value value, enum handle_kind expected,
                      const char *operation, boundary_handle **result) {
    const rxpa_native_payload_ops *ops = NULL;
    handle_payload *payload;
    size_t length = 0;

    payload = (handle_payload *)GETNATIVEPAYLOAD(value, &length, &ops, NULL);
    if (!payload || length != sizeof(*payload) || ops != &handle_payload_ops ||
        payload->magic != HANDLE_MAGIC ||
        !handle_is_registered(payload->handle)) {
        return fail_with(SQL_BOUNDARY_INVALID_HANDLE, 0, operation,
                         "invalid or stale opaque handle");
    }
    if (payload->handle->kind != expected) {
        return fail_with(SQL_BOUNDARY_WRONG_HANDLE_KIND, 0, operation,
                         "opaque handle has the wrong kind");
    }
    if (payload->handle->closed) {
        return fail_with(SQL_BOUNDARY_CLOSED_HANDLE, 0, operation,
                         "opaque handle is closed");
    }
    *result = payload->handle;
    return SQL_BOUNDARY_OK;
}

static int valid_column(boundary_handle *statement, int column,
                        const char *operation) {
    int count = sqlite3_column_count(statement->resource.statement);
    if (column < 0 || column >= count) {
        return fail_with(SQL_BOUNDARY_INVALID_ARGUMENT, 0, operation,
                         "column index is outside the current row");
    }
    return SQL_BOUNDARY_OK;
}

static const char *column_type_name(int type) {
    switch (type) {
        case SQLITE_NULL: return "null";
        case SQLITE_INTEGER: return "integer";
        case SQLITE_FLOAT: return "real";
        case SQLITE_TEXT: return "text";
        case SQLITE_BLOB: return "blob";
        default: return "unknown";
    }
}

PROCEDURE(sqlite_open_boundary) {
    sqlite3 *database = NULL;
    boundary_handle *handle;
    int result;

    if (NUM_ARGS != 2) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "2 arguments expected")
    clear_error();
    SETNATIVEPAYLOAD(ARG(1), NULL, 0, NULL, 0);
    result = sqlite3_open_v2(GETSTRING(ARG(0)), &database,
                             SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
    if (result != SQLITE_OK) {
        result = fail_sqlite(database, result, "open");
        if (database) sqlite3_close_v2(database);
        SETINT(RETURN, result);
        RESETSIGNAL
        return;
    }

    handle = new_handle(HANDLE_DATABASE);
    if (!handle) {
        sqlite3_close_v2(database);
        SETINT(RETURN, fail_with(SQL_BOUNDARY_NO_MEMORY, SQLITE_NOMEM, "open",
                                 "could not allocate database handle"));
        RESETSIGNAL
        return;
    }
    handle->resource.database = database;
    SETINT(RETURN, publish_handle(ARG(1), handle));
    RESETSIGNAL
}

PROCEDURE(sqlite_close_boundary) {
    boundary_handle *handle;
    int status;
    if (NUM_ARGS != 1) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "1 argument expected")
    clear_error();
    status = get_handle(ARG(0), HANDLE_DATABASE, "close", &handle);
    if (status == SQL_BOUNDARY_OK) close_database_resource(handle);
    SETINT(RETURN, status);
    RESETSIGNAL
}

PROCEDURE(sqlite_exec_boundary) {
    boundary_handle *handle;
    char *error_message = NULL;
    int result;
    if (NUM_ARGS != 2) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "2 arguments expected")
    clear_error();
    result = get_handle(ARG(0), HANDLE_DATABASE, "exec", &handle);
    if (result == SQL_BOUNDARY_OK) {
        result = sqlite3_exec(handle->resource.database, GETSTRING(ARG(1)),
                              NULL, NULL, &error_message);
        if (result != SQLITE_OK) {
            int status = fail_with(SQL_BOUNDARY_SQLITE_ERROR, result, "exec",
                                   error_message ? error_message :
                                   sqlite3_errmsg(handle->resource.database));
            sqlite3_free(error_message);
            result = status;
        } else {
            result = SQL_BOUNDARY_OK;
        }
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_prepare_boundary) {
    boundary_handle *database_handle;
    boundary_handle *statement_handle;
    sqlite3_stmt *statement = NULL;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    SETNATIVEPAYLOAD(ARG(2), NULL, 0, NULL, 0);
    result = get_handle(ARG(0), HANDLE_DATABASE, "prepare", &database_handle);
    if (result != SQL_BOUNDARY_OK) {
        SETINT(RETURN, result);
        RESETSIGNAL
        return;
    }
    result = sqlite3_prepare_v2(database_handle->resource.database,
                                GETSTRING(ARG(1)), -1, &statement, NULL);
    if (result != SQLITE_OK) {
        SETINT(RETURN, fail_sqlite(database_handle->resource.database, result,
                                   "prepare"));
        RESETSIGNAL
        return;
    }
    statement_handle = new_handle(HANDLE_STATEMENT);
    if (!statement_handle) {
        sqlite3_finalize(statement);
        SETINT(RETURN, fail_with(SQL_BOUNDARY_NO_MEMORY, SQLITE_NOMEM, "prepare",
                                 "could not allocate statement handle"));
        RESETSIGNAL
        return;
    }
    statement_handle->resource.statement = statement;
    statement_handle->parent = database_handle;
    retain_handle(database_handle);
    SETINT(RETURN, publish_handle(ARG(2), statement_handle));
    RESETSIGNAL
}

PROCEDURE(sqlite_finalize_boundary) {
    boundary_handle *handle;
    int status;
    if (NUM_ARGS != 1) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "1 argument expected")
    clear_error();
    status = get_handle(ARG(0), HANDLE_STATEMENT, "finalize", &handle);
    if (status == SQL_BOUNDARY_OK) close_statement_resource(handle);
    SETINT(RETURN, status);
    RESETSIGNAL
}

static int get_statement(rxpa_attribute_value value, const char *operation,
                         boundary_handle **result) {
    return get_handle(value, HANDLE_STATEMENT, operation, result);
}

PROCEDURE(sqlite_bind_null_boundary) {
    boundary_handle *handle;
    int result;
    if (NUM_ARGS != 2) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "2 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "bind_null", &handle);
    if (result == SQL_BOUNDARY_OK) {
        result = sqlite3_bind_null(handle->resource.statement, (int)GETINT(ARG(1)));
        if (result != SQLITE_OK) result = fail_sqlite(sqlite3_db_handle(handle->resource.statement), result, "bind_null");
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_bind_int_boundary) {
    boundary_handle *handle;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "bind_int", &handle);
    if (result == SQL_BOUNDARY_OK) {
        result = sqlite3_bind_int64(handle->resource.statement,
                                    (int)GETINT(ARG(1)),
                                    (sqlite3_int64)GETINT(ARG(2)));
        if (result != SQLITE_OK) result = fail_sqlite(sqlite3_db_handle(handle->resource.statement), result, "bind_int");
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_bind_real_boundary) {
    boundary_handle *handle;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "bind_real", &handle);
    if (result == SQL_BOUNDARY_OK) {
        result = sqlite3_bind_double(handle->resource.statement,
                                     (int)GETINT(ARG(1)), GETFLOAT(ARG(2)));
        if (result != SQLITE_OK) result = fail_sqlite(sqlite3_db_handle(handle->resource.statement), result, "bind_real");
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_bind_text_boundary) {
    boundary_handle *handle;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "bind_text", &handle);
    if (result == SQL_BOUNDARY_OK) {
        result = sqlite3_bind_text(handle->resource.statement,
                                   (int)GETINT(ARG(1)), GETSTRING(ARG(2)), -1,
                                   SQLITE_TRANSIENT);
        if (result != SQLITE_OK) result = fail_sqlite(sqlite3_db_handle(handle->resource.statement), result, "bind_text");
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_bind_blob_boundary) {
    boundary_handle *handle;
    const rxpa_native_payload_ops *ops = NULL;
    void *bytes;
    size_t length = 0;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "bind_blob", &handle);
    if (result == SQL_BOUNDARY_OK) {
        bytes = GETNATIVEPAYLOAD(ARG(2), &length, &ops, NULL);
        if (ops != NULL || length > (size_t)INT_MAX) {
            result = fail_with(SQL_BOUNDARY_TYPE_MISMATCH, 0, "bind_blob",
                               "value is not an ordinary bounded binary value");
        } else {
            result = sqlite3_bind_blob(handle->resource.statement,
                                       (int)GETINT(ARG(1)), bytes, (int)length,
                                       SQLITE_TRANSIENT);
            if (result != SQLITE_OK) result = fail_sqlite(sqlite3_db_handle(handle->resource.statement), result, "bind_blob");
        }
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_clear_bindings_boundary) {
    boundary_handle *handle;
    int result;
    if (NUM_ARGS != 1) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "1 argument expected")
    clear_error();
    result = get_statement(ARG(0), "clear_bindings", &handle);
    if (result == SQL_BOUNDARY_OK) {
        result = sqlite3_clear_bindings(handle->resource.statement);
        if (result != SQLITE_OK) result = fail_sqlite(sqlite3_db_handle(handle->resource.statement), result, "clear_bindings");
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_reset_boundary) {
    boundary_handle *handle;
    int result;
    if (NUM_ARGS != 1) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "1 argument expected")
    clear_error();
    result = get_statement(ARG(0), "reset", &handle);
    if (result == SQL_BOUNDARY_OK) {
        result = sqlite3_reset(handle->resource.statement);
        if (result != SQLITE_OK) result = fail_sqlite(sqlite3_db_handle(handle->resource.statement), result, "reset");
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_step_boundary) {
    boundary_handle *handle;
    int result;
    if (NUM_ARGS != 1) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "1 argument expected")
    clear_error();
    result = get_statement(ARG(0), "step", &handle);
    if (result == SQL_BOUNDARY_OK) {
        result = sqlite3_step(handle->resource.statement);
        if (result == SQLITE_ROW) result = SQL_BOUNDARY_ROW;
        else if (result == SQLITE_DONE) result = SQL_BOUNDARY_DONE;
        else result = fail_sqlite(sqlite3_db_handle(handle->resource.statement), result, "step");
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_column_type_boundary) {
    boundary_handle *handle;
    int column;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "column_type", &handle);
    column = (int)GETINT(ARG(1));
    if (result == SQL_BOUNDARY_OK) result = valid_column(handle, column, "column_type");
    if (result == SQL_BOUNDARY_OK) {
        SETSTRING(ARG(2), column_type_name(sqlite3_column_type(handle->resource.statement, column)));
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_column_is_null_boundary) {
    boundary_handle *handle;
    int column;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "column_is_null", &handle);
    column = (int)GETINT(ARG(1));
    if (result == SQL_BOUNDARY_OK) result = valid_column(handle, column, "column_is_null");
    if (result == SQL_BOUNDARY_OK) SETINT(ARG(2), sqlite3_column_type(handle->resource.statement, column) == SQLITE_NULL);
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_column_int_boundary) {
    boundary_handle *handle;
    int column;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "column_int", &handle);
    column = (int)GETINT(ARG(1));
    if (result == SQL_BOUNDARY_OK) result = valid_column(handle, column, "column_int");
    if (result == SQL_BOUNDARY_OK && sqlite3_column_type(handle->resource.statement, column) != SQLITE_INTEGER) {
        result = fail_with(SQL_BOUNDARY_TYPE_MISMATCH, 0, "column_int", "column is not integer");
    }
    if (result == SQL_BOUNDARY_OK) SETINT(ARG(2), (rxinteger)sqlite3_column_int64(handle->resource.statement, column));
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_column_real_boundary) {
    boundary_handle *handle;
    int column;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "column_real", &handle);
    column = (int)GETINT(ARG(1));
    if (result == SQL_BOUNDARY_OK) result = valid_column(handle, column, "column_real");
    if (result == SQL_BOUNDARY_OK && sqlite3_column_type(handle->resource.statement, column) != SQLITE_FLOAT) {
        result = fail_with(SQL_BOUNDARY_TYPE_MISMATCH, 0, "column_real", "column is not real");
    }
    if (result == SQL_BOUNDARY_OK) SETFLOAT(ARG(2), sqlite3_column_double(handle->resource.statement, column));
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_column_text_boundary) {
    boundary_handle *handle;
    const unsigned char *text;
    int column;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "column_text", &handle);
    column = (int)GETINT(ARG(1));
    if (result == SQL_BOUNDARY_OK) result = valid_column(handle, column, "column_text");
    if (result == SQL_BOUNDARY_OK && sqlite3_column_type(handle->resource.statement, column) != SQLITE_TEXT) {
        result = fail_with(SQL_BOUNDARY_TYPE_MISMATCH, 0, "column_text", "column is not text");
    }
    if (result == SQL_BOUNDARY_OK) {
        text = sqlite3_column_text(handle->resource.statement, column);
        SETSTRING(ARG(2), (const char *)(text ? text : (const unsigned char *)""));
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_column_blob_boundary) {
    boundary_handle *handle;
    const void *bytes;
    int length;
    int column;
    int result;
    if (NUM_ARGS != 3) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "3 arguments expected")
    clear_error();
    result = get_statement(ARG(0), "column_blob", &handle);
    column = (int)GETINT(ARG(1));
    if (result == SQL_BOUNDARY_OK) result = valid_column(handle, column, "column_blob");
    if (result == SQL_BOUNDARY_OK && sqlite3_column_type(handle->resource.statement, column) != SQLITE_BLOB) {
        result = fail_with(SQL_BOUNDARY_TYPE_MISMATCH, 0, "column_blob", "column is not blob");
    }
    if (result == SQL_BOUNDARY_OK) {
        bytes = sqlite3_column_blob(handle->resource.statement, column);
        length = sqlite3_column_bytes(handle->resource.statement, column);
        if (SETNATIVEPAYLOAD(ARG(2), bytes, (size_t)length, NULL, 0) != 0) {
            result = fail_with(SQL_BOUNDARY_NO_MEMORY, SQLITE_NOMEM, "column_blob",
                               "could not materialize binary column");
        }
    }
    SETINT(RETURN, result);
    RESETSIGNAL
}

PROCEDURE(sqlite_error_boundary) {
    if (NUM_ARGS != 4) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "4 arguments expected")
    SETINT(ARG(0), last_error.code);
    SETINT(ARG(1), last_error.sqlite_code);
    SETSTRING(ARG(2), last_error.operation);
    SETSTRING(ARG(3), last_error.message);
    SETINT(RETURN, last_error.code);
    RESETSIGNAL
}

static void append_json_char(char *output, size_t capacity, size_t *used, char ch) {
    if (*used + 1 < capacity) output[(*used)++] = ch;
}

static void append_json_string(char *output, size_t capacity, size_t *used,
                               const char *input) {
    const unsigned char *cursor = (const unsigned char *)(input ? input : "");
    append_json_char(output, capacity, used, '"');
    while (*cursor && *used + 8 < capacity) {
        if (*cursor == '"' || *cursor == '\\') {
            append_json_char(output, capacity, used, '\\');
            append_json_char(output, capacity, used, (char)*cursor);
        } else if (*cursor == '\n') {
            append_json_char(output, capacity, used, '\\');
            append_json_char(output, capacity, used, 'n');
        } else if (*cursor == '\r') {
            append_json_char(output, capacity, used, '\\');
            append_json_char(output, capacity, used, 'r');
        } else if (*cursor == '\t') {
            append_json_char(output, capacity, used, '\\');
            append_json_char(output, capacity, used, 't');
        } else if (*cursor >= 0x20) {
            append_json_char(output, capacity, used, (char)*cursor);
        }
        cursor++;
    }
    append_json_char(output, capacity, used, '"');
}

PROCEDURE(sqlite_error_json_boundary) {
    char json[1280];
    size_t used = 0;
    char number[64];
    if (NUM_ARGS != 0) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "no arguments expected")
    append_json_char(json, sizeof(json), &used, '{');
    snprintf(number, sizeof(number), "\"code\":%d,\"sqlite_code\":%d,\"operation\":",
             last_error.code, last_error.sqlite_code);
    if (used + strlen(number) < sizeof(json)) {
        memcpy(json + used, number, strlen(number));
        used += strlen(number);
    }
    append_json_string(json, sizeof(json), &used, last_error.operation);
    if (used + 11 < sizeof(json)) {
        memcpy(json + used, ",\"message\":", 11);
        used += 11;
    }
    append_json_string(json, sizeof(json), &used, last_error.message);
    append_json_char(json, sizeof(json), &used, '}');
    json[used] = '\0';
    SETSTRING(RETURN, json);
    RESETSIGNAL
}

PROCEDURE(sqlite_cleanup_boundary) {
    boundary_handle *cursor;
    int closed = 0;
    if (NUM_ARGS != 0) RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "no arguments expected")
    clear_error();
    for (cursor = live_handles; cursor; cursor = cursor->next) {
        if (cursor->kind == HANDLE_STATEMENT && !cursor->closed) {
            close_statement_resource(cursor);
            closed++;
        }
    }
    for (cursor = live_handles; cursor; cursor = cursor->next) {
        if (cursor->kind == HANDLE_DATABASE && !cursor->closed) {
            close_database_resource(cursor);
            closed++;
        }
    }
    SETINT(RETURN, closed);
    RESETSIGNAL
}

FINALIZER(sqlite_boundary_shutdown)
    boundary_handle *cursor;
    boundary_handle *next;
    for (cursor = live_handles; cursor; cursor = cursor->next) {
        if (cursor->kind == HANDLE_STATEMENT) close_statement_resource(cursor);
    }
    for (cursor = live_handles; cursor; cursor = cursor->next) {
        if (cursor->kind == HANDLE_DATABASE) close_database_resource(cursor);
    }
    cursor = live_handles;
    while (cursor) {
        next = cursor->next;
        free(cursor);
        cursor = next;
    }
    live_handles = NULL;
}

LOADFUNCS
    ADDPROC(sqlite_open_boundary, "sqlite_boundary.sqliteopen", "b", ".int",
            "path=.string, expose handle=.binary");
    ADDPROC(sqlite_close_boundary, "sqlite_boundary.sqliteclose", "b", ".int",
            "handle=.binary");
    ADDPROC(sqlite_exec_boundary, "sqlite_boundary.sqliteexec", "b", ".int",
            "handle=.binary, sql=.string");
    ADDPROC(sqlite_prepare_boundary, "sqlite_boundary.sqliteprepare", "b", ".int",
            "handle=.binary, sql=.string, expose statement=.binary");
    ADDPROC(sqlite_finalize_boundary, "sqlite_boundary.sqlitefinalize", "b", ".int",
            "statement=.binary");
    ADDPROC(sqlite_bind_null_boundary, "sqlite_boundary.sqlitebindnull", "b", ".int",
            "statement=.binary, index=.int");
    ADDPROC(sqlite_bind_int_boundary, "sqlite_boundary.sqlitebindint", "b", ".int",
            "statement=.binary, index=.int, value=.int");
    ADDPROC(sqlite_bind_real_boundary, "sqlite_boundary.sqlitebindreal", "b", ".int",
            "statement=.binary, index=.int, value=.float");
    ADDPROC(sqlite_bind_text_boundary, "sqlite_boundary.sqlitebindtext", "b", ".int",
            "statement=.binary, index=.int, value=.string");
    ADDPROC(sqlite_bind_blob_boundary, "sqlite_boundary.sqlitebindblob", "b", ".int",
            "statement=.binary, index=.int, value=.binary");
    ADDPROC(sqlite_clear_bindings_boundary, "sqlite_boundary.sqliteclearbindings", "b", ".int",
            "statement=.binary");
    ADDPROC(sqlite_reset_boundary, "sqlite_boundary.sqlitereset", "b", ".int",
            "statement=.binary");
    ADDPROC(sqlite_step_boundary, "sqlite_boundary.sqlitestep", "b", ".int",
            "statement=.binary");
    ADDPROC(sqlite_column_type_boundary, "sqlite_boundary.sqlitecolumntype", "b", ".int",
            "statement=.binary, column=.int, expose value=.string");
    ADDPROC(sqlite_column_is_null_boundary, "sqlite_boundary.sqlitecolumnisnull", "b", ".int",
            "statement=.binary, column=.int, expose value=.int");
    ADDPROC(sqlite_column_int_boundary, "sqlite_boundary.sqlitecolumnint", "b", ".int",
            "statement=.binary, column=.int, expose value=.int");
    ADDPROC(sqlite_column_real_boundary, "sqlite_boundary.sqlitecolumnreal", "b", ".int",
            "statement=.binary, column=.int, expose value=.float");
    ADDPROC(sqlite_column_text_boundary, "sqlite_boundary.sqlitecolumntext", "b", ".int",
            "statement=.binary, column=.int, expose value=.string");
    ADDPROC(sqlite_column_blob_boundary, "sqlite_boundary.sqlitecolumnblob", "b", ".int",
            "statement=.binary, column=.int, expose value=.binary");
    ADDPROC(sqlite_error_boundary, "sqlite_boundary.sqliteerror", "b", ".int",
            "expose code=.int, expose sqlite_code=.int, expose operation=.string, expose message=.string");
    ADDPROC(sqlite_error_json_boundary, "sqlite_boundary.sqliteerrorjson", "b", ".string", "");
    ADDPROC(sqlite_cleanup_boundary, "sqlite_boundary.sqlitecleanup", "b", ".int", "");
ENDLOADFUNCS
