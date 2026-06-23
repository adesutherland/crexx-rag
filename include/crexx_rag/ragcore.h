#pragma once

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct cprag_handle cprag_handle;

enum {
    CPRAG_OK = 0,
    CPRAG_INVALID_ARGUMENT = 1,
    CPRAG_IO_ERROR = 2,
    CPRAG_DATABASE_ERROR = 3,
    CPRAG_NOT_FOUND = 4,
    CPRAG_BUFFER_TOO_SMALL = 5,
    CPRAG_INTERNAL_ERROR = 100
};

enum {
    CPRAG_OPEN_READWRITE = 0,
    CPRAG_OPEN_READONLY = 1
};

enum {
    CPRAG_CHUNK_PLAIN_TEXT = 0,
    CPRAG_CHUNK_CODE_REXX = 3,
    CPRAG_CHUNK_MARKDOWN = 7
};

int cprag_open(const char* library_path, unsigned flags, cprag_handle** out_handle);
void cprag_close(cprag_handle* handle);
const char* cprag_last_error(cprag_handle* handle);

int cprag_init_library(const char* library_path);

int cprag_chunk_text(
    const char* text,
    int chunk_size,
    int chunk_overlap,
    int file_type,
    char* out_json,
    size_t out_json_size);

int cprag_add_entity(
    cprag_handle* handle,
    const char* id,
    const char* label,
    const char* description,
    const char* metadata_json);

int cprag_add_entity_typed(
    cprag_handle* handle,
    const char* id,
    const char* node_type,
    const char* label,
    const char* description,
    const char* metadata_json);

int cprag_add_edge(
    cprag_handle* handle,
    const char* source_id,
    const char* target_id,
    const char* label,
    double weight,
    const char* metadata_json);

int cprag_add_edge_typed(
    cprag_handle* handle,
    const char* source_id,
    const char* target_id,
    const char* relationship_type,
    const char* label,
    double weight,
    const char* metadata_json);

int cprag_ingest_text(
    cprag_handle* handle,
    const char* source_uri,
    const char* title,
    const char* text,
    int file_type,
    int chunk_size,
    int chunk_overlap,
    const char* metadata_json,
    char* out_json,
    size_t out_json_size);

int cprag_list_sources(
    cprag_handle* handle,
    char* out_json,
    size_t out_json_size);

int cprag_list_chunks(
    cprag_handle* handle,
    const char* source_uri,
    char* out_json,
    size_t out_json_size);

int cprag_delete_source(
    cprag_handle* handle,
    const char* source_uri,
    char* out_json,
    size_t out_json_size);

int cprag_vocabulary(
    char* out_json,
    size_t out_json_size);

int cprag_search(
    cprag_handle* handle,
    const char* query,
    int top_k,
    int hops,
    char* out_json,
    size_t out_json_size);

int cprag_expand(
    cprag_handle* handle,
    const char* anchors_csv,
    int hops,
    const char* relation_filter_csv,
    char* out_json,
    size_t out_json_size);

int cprag_shortest_path(
    cprag_handle* handle,
    const char* source_id,
    const char* target_id,
    const char* relationship_filter_csv,
    char* out_json,
    size_t out_json_size);

int cprag_subgraph(
    cprag_handle* handle,
    const char* node_type_filter_csv,
    const char* relationship_type_filter_csv,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_stats(
    cprag_handle* handle,
    char* out_json,
    size_t out_json_size);

const char* cprag_status_message(int code);

#ifdef __cplusplus
}
#endif
