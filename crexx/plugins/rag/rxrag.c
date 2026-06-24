#include "crexxpa.h"
#include "crexx_rag/ragcore.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#define RXRAG_JSON_BUFFER_SIZE (1024 * 1024)

static void copy_message(char* dest, size_t dest_size, const char* src)
{
    if (dest_size == 0) {
        return;
    }
    if (src == NULL) {
        src = "";
    }
    strncpy(dest, src, dest_size - 1);
    dest[dest_size - 1] = '\0';
}

static void set_result_or_signal(void* ret, int rc, cprag_handle* handle, char* buffer)
{
    if (rc != CPRAG_OK) {
        const char* detail = handle == NULL ? cprag_status_message(rc) : cprag_last_error(handle);
        char message[512];
        copy_message(message, sizeof(message), detail);
        SETSTRING(ret, message);
        return;
    }
    SETSTRING(ret, buffer == NULL ? "" : buffer);
}

static int file_type_from_string(const char* type)
{
    if (type != NULL && strcmp(type, "rexx") == 0) {
        return CPRAG_CHUNK_CODE_REXX;
    }
    if (type != NULL && (strcmp(type, "markdown") == 0 || strcmp(type, "md") == 0)) {
        return CPRAG_CHUNK_MARKDOWN;
    }
    return CPRAG_CHUNK_PLAIN_TEXT;
}

static int parse_float_csv(const char* text, float** out_values, size_t* out_count, char* error, size_t error_size)
{
    if (text == NULL || out_values == NULL || out_count == NULL) {
        copy_message(error, error_size, "vector_csv is required");
        return 0;
    }

    size_t capacity = 1;
    for (const char* p = text; *p != '\0'; ++p) {
        if (*p == ',') {
            ++capacity;
        }
    }

    float* values = (float*)malloc(capacity * sizeof(float));
    if (values == NULL) {
        copy_message(error, error_size, "failed to allocate vector buffer");
        return 0;
    }

    const char* p = text;
    size_t count = 0;
    while (*p != '\0') {
        while (isspace((unsigned char)*p) || *p == ',') {
            ++p;
        }
        if (*p == '\0') {
            break;
        }

        char* end = NULL;
        const float value = strtof(p, &end);
        if (end == p) {
            free(values);
            copy_message(error, error_size, "invalid vector_csv float");
            return 0;
        }
        values[count++] = value;
        p = end;

        while (isspace((unsigned char)*p)) {
            ++p;
        }
        if (*p != '\0' && *p != ',') {
            free(values);
            copy_message(error, error_size, "vector_csv must contain comma-separated floats");
            return 0;
        }
    }

    if (count == 0) {
        free(values);
        copy_message(error, error_size, "vector_csv must contain at least one float");
        return 0;
    }

    *out_values = values;
    *out_count = count;
    return 1;
}

PROCEDURE(init)
{
    if (NUM_ARGS != 1) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path argument expected")
    }

    int rc = cprag_init_library(GETSTRING(ARG(0)));
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    SETSTRING(RETURN, "1");
    RESETSIGNAL
}

PROCEDURE(addentity)
{
    if (NUM_ARGS < 4 || NUM_ARGS > 5) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, id, label, description, optional metadata_json expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    const char* metadata = NUM_ARGS >= 5 ? GETSTRING(ARG(4)) : "{}";
    rc = cprag_add_entity(handle, GETSTRING(ARG(1)), GETSTRING(ARG(2)), GETSTRING(ARG(3)), metadata);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    cprag_close(handle);
    SETSTRING(RETURN, "1");
    RESETSIGNAL
}

PROCEDURE(addentitytyped)
{
    if (NUM_ARGS < 5 || NUM_ARGS > 6) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, id, node_type, label, description, optional metadata_json expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    const char* metadata = NUM_ARGS >= 6 ? GETSTRING(ARG(5)) : "{}";
    rc = cprag_add_entity_typed(handle, GETSTRING(ARG(1)), GETSTRING(ARG(2)), GETSTRING(ARG(3)), GETSTRING(ARG(4)), metadata);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    cprag_close(handle);
    SETSTRING(RETURN, "1");
    RESETSIGNAL
}

PROCEDURE(addedge)
{
    if (NUM_ARGS < 4 || NUM_ARGS > 6) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, source_id, target_id, label, optional weight, optional metadata_json expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    const double weight = NUM_ARGS >= 5 ? GETFLOAT(ARG(4)) : 1.0;
    const char* metadata = NUM_ARGS >= 6 ? GETSTRING(ARG(5)) : "{}";
    rc = cprag_add_edge(handle, GETSTRING(ARG(1)), GETSTRING(ARG(2)), GETSTRING(ARG(3)), weight, metadata);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    cprag_close(handle);
    SETSTRING(RETURN, "1");
    RESETSIGNAL
}

PROCEDURE(addedgetyped)
{
    if (NUM_ARGS < 5 || NUM_ARGS > 7) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, source_id, target_id, relationship_type, label, optional weight, optional metadata_json expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    const double weight = NUM_ARGS >= 6 ? GETFLOAT(ARG(5)) : 1.0;
    const char* metadata = NUM_ARGS >= 7 ? GETSTRING(ARG(6)) : "{}";
    rc = cprag_add_edge_typed(handle, GETSTRING(ARG(1)), GETSTRING(ARG(2)), GETSTRING(ARG(3)), GETSTRING(ARG(4)), weight, metadata);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    cprag_close(handle);
    SETSTRING(RETURN, "1");
    RESETSIGNAL
}

PROCEDURE(ingest)
{
    if (NUM_ARGS < 4 || NUM_ARGS > 13) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, source_uri, title, text, optional file_type, chunk_size, overlap, metadata_json, source_type, confidence, captured_at, event_start_at, event_end_at expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* file_type_text = NUM_ARGS >= 5 ? GETSTRING(ARG(4)) : "plain";
    const int chunk_size = NUM_ARGS >= 6 ? GETINT(ARG(5)) : 1000;
    const int overlap = NUM_ARGS >= 7 ? GETINT(ARG(6)) : 200;
    const char* metadata = NUM_ARGS >= 8 ? GETSTRING(ARG(7)) : "{}";
    const char* source_type = NUM_ARGS >= 9 ? GETSTRING(ARG(8)) : "unknown";
    const double confidence = NUM_ARGS >= 10 ? GETFLOAT(ARG(9)) : 1.0;
    const char* captured_at = NUM_ARGS >= 11 ? GETSTRING(ARG(10)) : "";
    const char* event_start_at = NUM_ARGS >= 12 ? GETSTRING(ARG(11)) : "";
    const char* event_end_at = NUM_ARGS >= 13 ? GETSTRING(ARG(12)) : "";
    rc = cprag_ingest_text_ex(
        handle,
        GETSTRING(ARG(1)),
        GETSTRING(ARG(2)),
        GETSTRING(ARG(3)),
        file_type_from_string(file_type_text),
        chunk_size,
        overlap,
        metadata,
        source_type,
        confidence,
        captured_at,
        event_start_at,
        event_end_at,
        buffer,
        RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(listsources)
{
    if (NUM_ARGS != 1) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path argument expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    rc = cprag_list_sources(handle, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(timeline)
{
    if (NUM_ARGS < 1 || NUM_ARGS > 2) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, optional limit expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const int limit = NUM_ARGS >= 2 ? GETINT(ARG(1)) : 100;
    rc = cprag_timeline(handle, limit, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(listchunks)
{
    if (NUM_ARGS != 2) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, source_uri expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    rc = cprag_list_chunks(handle, GETSTRING(ARG(1)), buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(chunkids)
{
    if (NUM_ARGS < 1 || NUM_ARGS > 2) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, optional source_uri expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* source_uri = NUM_ARGS >= 2 ? GETSTRING(ARG(1)) : "";
    rc = cprag_chunk_ids(handle, source_uri, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(chunktextbyid)
{
    if (NUM_ARGS != 2) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, chunk_id expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    rc = cprag_chunk_text_by_id(handle, GETINT(ARG(1)), buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(listconcepts)
{
    if (NUM_ARGS < 1 || NUM_ARGS > 2) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, optional node_type_filter_csv expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* node_filter = NUM_ARGS >= 2 ? GETSTRING(ARG(1)) : "";
    rc = cprag_list_concepts(handle, node_filter, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(matchconcepts)
{
    if (NUM_ARGS < 2 || NUM_ARGS > 3) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, text, optional node_type_filter_csv expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* node_filter = NUM_ARGS >= 3 ? GETSTRING(ARG(2)) : "";
    rc = cprag_match_concepts(handle, GETSTRING(ARG(1)), node_filter, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(deletesource)
{
    if (NUM_ARGS != 2) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, source_uri expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    rc = cprag_delete_source(handle, GETSTRING(ARG(1)), buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(vectorstatus)
{
    if (NUM_ARGS != 1) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path argument expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    rc = cprag_vector_status(handle, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(embeddingtext)
{
    if (NUM_ARGS < 2 || NUM_ARGS > 3) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, chunk_id, optional embedding_profile expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* profile = NUM_ARGS >= 3 ? GETSTRING(ARG(2)) : "semantic-context-v1";
    rc = cprag_build_chunk_embedding_text(handle, GETINT(ARG(1)), profile, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(addchunkembedding)
{
    if (NUM_ARGS < 4 || NUM_ARGS > 5) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, chunk_id, embedding_model, vector_csv, optional embedding_profile expected")
    }

    char parse_error[256];
    float* values = NULL;
    size_t count = 0;
    if (!parse_float_csv(GETSTRING(ARG(3)), &values, &count, parse_error, sizeof(parse_error))) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, parse_error)
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        free(values);
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    const char* profile = NUM_ARGS >= 5 ? GETSTRING(ARG(4)) : "raw-text-v1";
    rc = cprag_add_chunk_embedding_profile(handle, GETINT(ARG(1)), GETSTRING(ARG(2)), profile, values, count);
    free(values);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    cprag_close(handle);
    SETSTRING(RETURN, "1");
    RESETSIGNAL
}

PROCEDURE(rebuildvectorindex)
{
    if (NUM_ARGS < 2 || NUM_ARGS > 3) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, embedding_model, optional embedding_profile expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* profile = NUM_ARGS >= 3 ? GETSTRING(ARG(2)) : "";
    rc = cprag_rebuild_vector_index_profile(handle, GETSTRING(ARG(1)), profile, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(vectorsearch)
{
    if (NUM_ARGS < 3 || NUM_ARGS > 4) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, embedding_model, vector_csv, optional top_k expected")
    }

    char parse_error[256];
    float* values = NULL;
    size_t count = 0;
    if (!parse_float_csv(GETSTRING(ARG(2)), &values, &count, parse_error, sizeof(parse_error))) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, parse_error)
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        free(values);
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        free(values);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const int top_k = NUM_ARGS >= 4 ? GETINT(ARG(3)) : 3;
    rc = cprag_vector_search(handle, GETSTRING(ARG(1)), values, count, top_k, buffer, RXRAG_JSON_BUFFER_SIZE);
    free(values);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(vocabulary)
{
    if (NUM_ARGS != 0) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "no arguments expected")
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    int rc = cprag_vocabulary(buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        free(buffer);
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    SETSTRING(RETURN, buffer);
    free(buffer);
    RESETSIGNAL
}

PROCEDURE(search)
{
    if (NUM_ARGS < 2 || NUM_ARGS > 4) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, query, optional top_k, optional hops expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const int top_k = NUM_ARGS >= 3 ? GETINT(ARG(2)) : 3;
    const int hops = NUM_ARGS >= 4 ? GETINT(ARG(3)) : 2;
    rc = cprag_search(handle, GETSTRING(ARG(1)), top_k, hops, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(expand)
{
    if (NUM_ARGS < 2 || NUM_ARGS > 4) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, anchors_csv, optional hops, optional relation_filter_csv expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const int hops = NUM_ARGS >= 3 ? GETINT(ARG(2)) : 2;
    const char* filter = NUM_ARGS >= 4 ? GETSTRING(ARG(3)) : "";
    rc = cprag_expand(handle, GETSTRING(ARG(1)), hops, filter, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(shortestpath)
{
    if (NUM_ARGS < 3 || NUM_ARGS > 4) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, source_id, target_id, optional relationship_filter_csv expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* filter = NUM_ARGS >= 4 ? GETSTRING(ARG(3)) : "";
    rc = cprag_shortest_path(handle, GETSTRING(ARG(1)), GETSTRING(ARG(2)), filter, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(subgraph)
{
    if (NUM_ARGS < 1 || NUM_ARGS > 4) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, optional node_type_filter_csv, relationship_type_filter_csv, limit expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* node_filter = NUM_ARGS >= 2 ? GETSTRING(ARG(1)) : "";
    const char* relation_filter = NUM_ARGS >= 3 ? GETSTRING(ARG(2)) : "";
    const int limit = NUM_ARGS >= 4 ? GETINT(ARG(3)) : 100;
    rc = cprag_subgraph(handle, node_filter, relation_filter, limit, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(exportdot)
{
    if (NUM_ARGS < 1 || NUM_ARGS > 4) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, optional node_type_filter_csv, relationship_type_filter_csv, limit expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const char* node_filter = NUM_ARGS >= 2 ? GETSTRING(ARG(1)) : "";
    const char* relation_filter = NUM_ARGS >= 3 ? GETSTRING(ARG(2)) : "";
    const int limit = NUM_ARGS >= 4 ? GETINT(ARG(3)) : 100;
    rc = cprag_export_dot(handle, node_filter, relation_filter, limit, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(stats)
{
    if (NUM_ARGS != 1) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path argument expected")
    }

    cprag_handle* handle = NULL;
    int rc = cprag_open(GETSTRING(ARG(0)), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    rc = cprag_stats(handle, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char err[512];
        copy_message(err, sizeof(err), cprag_last_error(handle));
        free(buffer);
        cprag_close(handle);
        RETURNSIGNAL(SIGNAL_FAILURE, err)
    }

    set_result_or_signal(RETURN, rc, handle, buffer);
    free(buffer);
    cprag_close(handle);
    RESETSIGNAL
}

PROCEDURE(chunk)
{
    if (NUM_ARGS < 1 || NUM_ARGS > 4) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "text, optional chunk_size, optional overlap, optional file_type expected")
    }

    char* buffer = (char*)malloc(RXRAG_JSON_BUFFER_SIZE);
    if (buffer == NULL) {
        RETURNSIGNAL(SIGNAL_FAILURE, "failed to allocate result buffer")
    }

    const int chunk_size = NUM_ARGS >= 2 ? GETINT(ARG(1)) : 1000;
    const int overlap = NUM_ARGS >= 3 ? GETINT(ARG(2)) : 200;
    int file_type = CPRAG_CHUNK_PLAIN_TEXT;
    if (NUM_ARGS >= 4) {
        file_type = file_type_from_string(GETSTRING(ARG(3)));
    }

    int rc = cprag_chunk_text(GETSTRING(ARG(0)), chunk_size, overlap, file_type, buffer, RXRAG_JSON_BUFFER_SIZE);
    if (rc != CPRAG_OK) {
        char message[128];
        copy_message(message, sizeof(message), cprag_status_message(rc));
        free(buffer);
        RETURNSIGNAL(SIGNAL_FAILURE, message)
    }

    SETSTRING(RETURN, buffer);
    free(buffer);
    RESETSIGNAL
}

LOADFUNCS
ADDPROC(init,      "rxrag.init",      "g", ".string", "path=.string");
ADDPROC(addentity, "rxrag.addentity", "g", ".string", "path=.string,id=.string,label=.string,description=.string,metadata_json=.string");
ADDPROC(addentitytyped, "rxrag.addentitytyped", "g", ".string", "path=.string,id=.string,node_type=.string,label=.string,description=.string,metadata_json=.string");
ADDPROC(addedge,   "rxrag.addedge",   "g", ".string", "path=.string,source_id=.string,target_id=.string,label=.string,weight=.float,metadata_json=.string");
ADDPROC(addedgetyped, "rxrag.addedgetyped", "g", ".string", "path=.string,source_id=.string,target_id=.string,relationship_type=.string,label=.string,weight=.float,metadata_json=.string");
ADDPROC(ingest,    "rxrag.ingest",    "g", ".string", "path=.string,source_uri=.string,title=.string,text=.string,file_type=.string,chunk_size=.int,overlap=.int,metadata_json=.string,source_type=.string,confidence=.float,captured_at=.string,event_start_at=.string,event_end_at=.string");
ADDPROC(listsources, "rxrag.listsources", "g", ".string", "path=.string");
ADDPROC(timeline, "rxrag.timeline", "g", ".string", "path=.string,limit=.int");
ADDPROC(listchunks, "rxrag.listchunks", "g", ".string", "path=.string,source_uri=.string");
ADDPROC(chunkids, "rxrag.chunkids", "g", ".string", "path=.string,source_uri=.string");
ADDPROC(chunktextbyid, "rxrag.chunktextbyid", "g", ".string", "path=.string,chunk_id=.int");
ADDPROC(listconcepts, "rxrag.listconcepts", "g", ".string", "path=.string,node_type_filter_csv=.string");
ADDPROC(matchconcepts, "rxrag.matchconcepts", "g", ".string", "path=.string,text=.string,node_type_filter_csv=.string");
ADDPROC(deletesource, "rxrag.deletesource", "g", ".string", "path=.string,source_uri=.string");
ADDPROC(vectorstatus, "rxrag.vectorstatus", "g", ".string", "path=.string");
ADDPROC(embeddingtext, "rxrag.embeddingtext", "g", ".string", "path=.string,chunk_id=.int,embedding_profile=.string");
ADDPROC(addchunkembedding, "rxrag.addchunkembedding", "g", ".string", "path=.string,chunk_id=.int,embedding_model=.string,vector_csv=.string,embedding_profile=.string");
ADDPROC(rebuildvectorindex, "rxrag.rebuildvectorindex", "g", ".string", "path=.string,embedding_model=.string,embedding_profile=.string");
ADDPROC(vectorsearch, "rxrag.vectorsearch", "g", ".string", "path=.string,embedding_model=.string,vector_csv=.string,top_k=.int");
ADDPROC(vocabulary, "rxrag.vocabulary", "g", ".string", "");
ADDPROC(search,    "rxrag.search",    "g", ".string", "path=.string,query=.string,top_k=.int,hops=.int");
ADDPROC(expand,    "rxrag.expand",    "g", ".string", "path=.string,anchors_csv=.string,hops=.int,relation_filter_csv=.string");
ADDPROC(shortestpath, "rxrag.shortestpath", "g", ".string", "path=.string,source_id=.string,target_id=.string,relationship_filter_csv=.string");
ADDPROC(subgraph, "rxrag.subgraph", "g", ".string", "path=.string,node_type_filter_csv=.string,relationship_type_filter_csv=.string,limit=.int");
ADDPROC(exportdot, "rxrag.exportdot", "g", ".string", "path=.string,node_type_filter_csv=.string,relationship_type_filter_csv=.string,limit=.int");
ADDPROC(stats,     "rxrag.stats",     "g", ".string", "path=.string");
ADDPROC(chunk,     "rxrag.chunk",     "g", ".string", "text=.string,chunk_size=.int,overlap=.int,file_type=.string");
ENDLOADFUNCS
