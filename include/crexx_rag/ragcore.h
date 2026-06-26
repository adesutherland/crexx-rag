#pragma once

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct cprag_handle cprag_handle;

typedef int (*cprag_chunk_visitor)(
    long long chunk_id,
    const char* source_uri,
    const char* title,
    int chunk_index,
    const char* text,
    void* user_data);

enum {
    CPRAG_OK = 0,
    CPRAG_INVALID_ARGUMENT = 1,
    CPRAG_IO_ERROR = 2,
    CPRAG_DATABASE_ERROR = 3,
    CPRAG_NOT_FOUND = 4,
    CPRAG_BUFFER_TOO_SMALL = 5,
    CPRAG_UNSUPPORTED = 6,
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

enum {
    CPRAG_SEARCH_AUTO = 0,
    CPRAG_SEARCH_LEXICAL = 1,
    CPRAG_SEARCH_VECTOR = 2,
    CPRAG_SEARCH_HYBRID = 3
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

int cprag_ingest_text_ex(
    cprag_handle* handle,
    const char* source_uri,
    const char* title,
    const char* text,
    int file_type,
    int chunk_size,
    int chunk_overlap,
    const char* metadata_json,
    const char* source_type,
    double confidence,
    const char* captured_at,
    const char* event_start_at,
    const char* event_end_at,
    char* out_json,
    size_t out_json_size);

int cprag_list_sources(
    cprag_handle* handle,
    char* out_json,
    size_t out_json_size);

int cprag_timeline(
    cprag_handle* handle,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_list_chunks(
    cprag_handle* handle,
    const char* source_uri,
    char* out_json,
    size_t out_json_size);

int cprag_each_chunk(
    cprag_handle* handle,
    const char* source_uri,
    cprag_chunk_visitor visitor,
    void* user_data);

int cprag_chunk_ids(
    cprag_handle* handle,
    const char* source_uri,
    char* out_csv,
    size_t out_csv_size);

int cprag_chunk_text_by_id(
    cprag_handle* handle,
    long long chunk_id,
    char* out_text,
    size_t out_text_size);

int cprag_delete_source(
    cprag_handle* handle,
    const char* source_uri,
    char* out_json,
    size_t out_json_size);

int cprag_vector_index_available(void);

int cprag_add_chunk_embedding(
    cprag_handle* handle,
    long long chunk_id,
    const char* embedding_model,
    const float* vector,
    size_t dimension);

int cprag_add_chunk_embedding_profile(
    cprag_handle* handle,
    long long chunk_id,
    const char* embedding_model,
    const char* embedding_profile,
    const float* vector,
    size_t dimension);

int cprag_rebuild_vector_index(
    cprag_handle* handle,
    const char* embedding_model,
    char* out_json,
    size_t out_json_size);

int cprag_rebuild_vector_index_profile(
    cprag_handle* handle,
    const char* embedding_model,
    const char* embedding_profile,
    char* out_json,
    size_t out_json_size);

int cprag_build_chunk_embedding_text(
    cprag_handle* handle,
    long long chunk_id,
    const char* embedding_profile,
    char* out_text,
    size_t out_text_size);

int cprag_vector_search(
    cprag_handle* handle,
    const char* embedding_model,
    const float* query_vector,
    size_t dimension,
    int top_k,
    char* out_json,
    size_t out_json_size);

int cprag_vector_status(
    cprag_handle* handle,
    char* out_json,
    size_t out_json_size);

int cprag_vocabulary(
    char* out_json,
    size_t out_json_size);

int cprag_list_concepts(
    cprag_handle* handle,
    const char* node_type_filter_csv,
    char* out_json,
    size_t out_json_size);

int cprag_match_concepts(
    cprag_handle* handle,
    const char* text,
    const char* node_type_filter_csv,
    char* out_json,
    size_t out_json_size);

int cprag_clear_candidate_census(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    char* out_json,
    size_t out_json_size);

int cprag_add_candidate_mention(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    long long chunk_id,
    const char* stage,
    const char* extractor,
    const char* candidate,
    const char* normalized_candidate,
    int priority,
    int proper_count,
    int known_count,
    int cue_count,
    const char* metadata_json);

int cprag_candidate_census(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    int min_count,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_pending_candidate_census(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    int min_count,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_adjudicate_candidate(
    cprag_handle* handle,
    const char* profile_id,
    const char* normalized_candidate,
    const char* status,
    const char* candidate_type,
    const char* canonical_label,
    const char* aliases,
    const char* disambiguation,
    double confidence,
    const char* adjudicator,
    const char* metadata_json);

int cprag_list_candidate_adjudications(
    cprag_handle* handle,
    const char* profile_id,
    const char* status_filter,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_list_candidate_mention_evidence(
    cprag_handle* handle,
    const char* profile_id,
    const char* status_filter,
    const char* type_filter_csv,
    int min_count,
    long long after_id,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_seed_candidate_mention_graph(
    cprag_handle* handle,
    const char* profile_id,
    const char* graph_namespace,
    const char* status_filter,
    const char* type_filter_csv,
    int min_count,
    long long after_id,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_build_extraction_queue(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* graph_namespace,
    const char* node_type_filter_csv,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_list_extraction_queue(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* status_filter,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_record_extraction_attempt(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    long long chunk_id,
    const char* extractor,
    const char* model,
    const char* status,
    int accepted_nodes,
    int accepted_relationships,
    const char* raw_output,
    const char* metadata_json,
    char* out_json,
    size_t out_json_size);

int cprag_list_extraction_attempts(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    long long chunk_id,
    int limit,
    char* out_json,
    size_t out_json_size);

int cprag_queue_status(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    char* out_json,
    size_t out_json_size);

int cprag_search(
    cprag_handle* handle,
    const char* query,
    int top_k,
    int hops,
    char* out_json,
    size_t out_json_size);

int cprag_search_with_vector(
    cprag_handle* handle,
    const char* query,
    int top_k,
    int hops,
    int mode,
    const char* embedding_model,
    const float* query_vector,
    size_t dimension,
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

int cprag_export_dot(
    cprag_handle* handle,
    const char* node_type_filter_csv,
    const char* relationship_type_filter_csv,
    int limit,
    char* out_dot,
    size_t out_dot_size);

int cprag_stats(
    cprag_handle* handle,
    char* out_json,
    size_t out_json_size);

const char* cprag_status_message(int code);

#ifdef __cplusplus
}
#endif
