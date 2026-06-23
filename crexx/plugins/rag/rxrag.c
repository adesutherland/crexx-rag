#include "crexxpa.h"
#include "crexx_rag/ragcore.h"

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

PROCEDURE(ingest)
{
    if (NUM_ARGS < 4 || NUM_ARGS > 8) {
        RETURNSIGNAL(SIGNAL_INVALID_ARGUMENTS, "path, source_uri, title, text, optional file_type, chunk_size, overlap, metadata_json expected")
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
    rc = cprag_ingest_text(
        handle,
        GETSTRING(ARG(1)),
        GETSTRING(ARG(2)),
        GETSTRING(ARG(3)),
        file_type_from_string(file_type_text),
        chunk_size,
        overlap,
        metadata,
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
ADDPROC(init,      "rxrag.init",      "b", ".string", "path=.string");
ADDPROC(addentity, "rxrag.addentity", "b", ".string", "path=.string,id=.string,label=.string,description=.string,metadata_json=.string");
ADDPROC(addedge,   "rxrag.addedge",   "b", ".string", "path=.string,source_id=.string,target_id=.string,label=.string,weight=.float,metadata_json=.string");
ADDPROC(ingest,    "rxrag.ingest",    "b", ".string", "path=.string,source_uri=.string,title=.string,text=.string,file_type=.string,chunk_size=.int,overlap=.int,metadata_json=.string");
ADDPROC(listsources, "rxrag.listsources", "b", ".string", "path=.string");
ADDPROC(search,    "rxrag.search",    "b", ".string", "path=.string,query=.string,top_k=.int,hops=.int");
ADDPROC(expand,    "rxrag.expand",    "b", ".string", "path=.string,anchors_csv=.string,hops=.int,relation_filter_csv=.string");
ADDPROC(stats,     "rxrag.stats",     "b", ".string", "path=.string");
ADDPROC(chunk,     "rxrag.chunk",     "b", ".string", "text=.string,chunk_size=.int,overlap=.int,file_type=.string");
ENDLOADFUNCS
