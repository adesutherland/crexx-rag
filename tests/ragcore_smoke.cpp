#include "crexx_rag/ragcore.h"

#include <cassert>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

namespace {

std::vector<long long> chunkIdsFromJson(const std::string& json)
{
    std::vector<long long> ids;
    size_t pos = 0;
    const std::string pattern = "\"id\":";
    while ((pos = json.find(pattern, pos)) != std::string::npos) {
        pos += pattern.size();
        size_t end = pos;
        while (end < json.size() && json[end] >= '0' && json[end] <= '9') {
            ++end;
        }
        if (end > pos) {
            ids.push_back(std::stoll(json.substr(pos, end - pos)));
        }
        pos = end;
    }
    return ids;
}

struct VisitedChunk {
    long long id {0};
    std::string sourceUri;
    std::string title;
    int chunkIndex {0};
    std::string text;
};

int visitChunk(
    long long chunkId,
    const char* sourceUri,
    const char* title,
    int chunkIndex,
    const char* text,
    void* userData)
{
    auto* visited = static_cast<std::vector<VisitedChunk>*>(userData);
    visited->push_back(VisitedChunk {
        chunkId,
        sourceUri == nullptr ? std::string() : std::string(sourceUri),
        title == nullptr ? std::string() : std::string(title),
        chunkIndex,
        text == nullptr ? std::string() : std::string(text)
    });
    return CPRAG_OK;
}

} // namespace

int main()
{
    const std::filesystem::path root = std::filesystem::temp_directory_path()
        / ("crexx-rag-smoke-" + std::to_string(std::rand()));
    std::filesystem::remove_all(root);

    cprag_handle* handle = nullptr;
    int rc = cprag_open(root.string().c_str(), CPRAG_OPEN_READWRITE, &handle);
    assert(rc == CPRAG_OK);
    assert(handle != nullptr);

    rc = cprag_add_entity_typed(handle, "entity:auth", "service", "Authentication", "Authentication service handling login", "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_entity_typed(handle, "entity:postgres", "data-object", "PostgreSQL", "PostgreSQL user profile database", "{\"aliases\":\"Postgres|PG\"}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_entity_typed(handle, "entity:k8s", "technology-node", "Kubernetes", "Kubernetes runtime platform", "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_edge_typed(handle, "entity:auth", "entity:postgres", "accesses", "Reads user profiles", 1.0, "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_edge_typed(handle, "entity:auth", "entity:k8s", "deployed-on", "Runs on Kubernetes", 1.0, "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_edge_typed(handle, "entity:auth", "entity:postgres", "accesses", "Reads user profiles", 0.9, "{\"updated\":true}");
    assert(rc == CPRAG_OK);

    std::vector<char> buffer(65536);

    rc = cprag_add_entity(handle, "entity:bad", "Component", "Bad metadata should be rejected", "{not-json");
    assert(rc == CPRAG_INVALID_ARGUMENT);

    rc = cprag_list_concepts(handle, "data-object", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string concepts(buffer.data());
    if (concepts.find("\"id\":\"entity:postgres\"") == std::string::npos
        || concepts.find("\"aliases\":[") == std::string::npos
        || concepts.find("\"Postgres\"") == std::string::npos
        || concepts.find("\"PG\"") == std::string::npos
        || concepts.find("\"id\":\"entity:auth\"") != std::string::npos) {
        std::cerr << concepts << '\n';
        return 1;
    }

    rc = cprag_match_concepts(handle, "Auth stores user profiles in Postgres.", "data-object", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string conceptMatches(buffer.data());
    if (conceptMatches.find("\"id\":\"entity:postgres\"") == std::string::npos
        || conceptMatches.find("\"node_type\":\"data-object\"") == std::string::npos
        || conceptMatches.find("\"matched_alias\":\"Postgres\"") == std::string::npos
        || conceptMatches.find("\"id\":\"entity:auth\"") != std::string::npos) {
        std::cerr << conceptMatches << '\n';
        return 1;
    }

    rc = cprag_ingest_text_ex(
        handle,
        "docs/auth.md",
        "Authentication architecture notes",
        "# Auth\n\nThe authentication service depends on PostgreSQL and is deployed on Kubernetes.\n\n"
        "The payment service calls auth for token validation.",
        CPRAG_CHUNK_MARKDOWN,
        80,
        16,
        "{\"domain\":\"architecture\"}",
        "meeting-note",
        0.8,
        "2026-06-24T09:30:00Z",
        "2026-06-20T10:00:00Z",
        "2026-06-20T11:00:00Z",
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string ingest(buffer.data());
    if (ingest.find("\"source_uri\":\"docs/auth.md\"") == std::string::npos
        || ingest.find("\"chunk_count\":") == std::string::npos
        || ingest.find("\"source_type\":\"meeting-note\"") == std::string::npos
        || ingest.find("\"confidence\":0.8") == std::string::npos
        || ingest.find("\"event_start_at\":\"2026-06-20T10:00:00Z\"") == std::string::npos) {
        std::cerr << ingest << '\n';
        return 1;
    }

    rc = cprag_list_sources(handle, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string sources(buffer.data());
    if (sources.find("Authentication architecture notes") == std::string::npos
        || sources.find("\"chunk_count\":") == std::string::npos
        || sources.find("\"source_type\":\"meeting-note\"") == std::string::npos) {
        std::cerr << sources << '\n';
        return 1;
    }

    rc = cprag_timeline(handle, 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string timeline(buffer.data());
    if (timeline.find("\"events\":[") == std::string::npos
        || timeline.find("\"sort_time\":\"2026-06-20T10:00:00Z\"") == std::string::npos
        || timeline.find("\"source_type\":\"meeting-note\"") == std::string::npos) {
        std::cerr << timeline << '\n';
        return 1;
    }

    rc = cprag_list_chunks(handle, "docs/auth.md", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string listedChunks(buffer.data());
    if (listedChunks.find("\"source_uri\":\"docs/auth.md\"") == std::string::npos
        || listedChunks.find("token validation") == std::string::npos
        || listedChunks.find("\"source_type\":\"meeting-note\"") == std::string::npos) {
        std::cerr << listedChunks << '\n';
        return 1;
    }
    const std::vector<long long> chunkIds = chunkIdsFromJson(listedChunks);
    assert(!chunkIds.empty());

    rc = cprag_chunk_ids(handle, "docs/auth.md", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string chunkIdCsv(buffer.data());
    if (chunkIdCsv.find(std::to_string(chunkIds.front())) == std::string::npos) {
        std::cerr << chunkIdCsv << '\n';
        return 1;
    }

    rc = cprag_chunk_text_by_id(handle, chunkIds.front(), buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string chunkText(buffer.data());
    if (chunkText.find("authentication service") == std::string::npos) {
        std::cerr << chunkText << '\n';
        return 1;
    }

    std::vector<VisitedChunk> visitedChunks;
    rc = cprag_each_chunk(handle, "docs/auth.md", visitChunk, &visitedChunks);
    assert(rc == CPRAG_OK);
    if (visitedChunks.size() != chunkIds.size()
        || visitedChunks.front().id != chunkIds.front()
        || visitedChunks.front().sourceUri != "docs/auth.md"
        || visitedChunks.front().text.find("authentication service") == std::string::npos) {
        std::cerr << "cprag_each_chunk did not visit expected chunks\n";
        return 1;
    }

    rc = cprag_clear_candidate_census(handle, "architecture.test.v1", "docs/auth.md", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    rc = cprag_add_candidate_mention(
        handle,
        "architecture.test.v1",
        "docs/auth.md",
        chunkIds.front(),
        "stage1",
        "deterministic",
        "PostgreSQL",
        "POSTGRESQL",
        11,
        2,
        1,
        1,
        "{\"source\":\"unit\"}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_candidate_mention(
        handle,
        "architecture.test.v1",
        "docs/auth.md",
        chunkIds.front(),
        "stage1",
        "deterministic",
        "Postgres",
        "POSTGRESQL",
        12,
        2,
        1,
        1,
        "{\"source\":\"unit-update\"}");
    assert(rc == CPRAG_OK);
    rc = cprag_candidate_census(handle, "architecture.test.v1", "docs/auth.md", 1, 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string candidateCensus(buffer.data());
    if (candidateCensus.find("\"normalized\":\"POSTGRESQL\"") == std::string::npos
        || candidateCensus.find("\"count\":1") == std::string::npos
        || candidateCensus.find("\"max_priority\":12") == std::string::npos) {
        std::cerr << candidateCensus << '\n';
        return 1;
    }
    rc = cprag_adjudicate_candidate(
        handle,
        "architecture.test.v1",
        "POSTGRESQL",
        "keep",
        "data-object",
        "PostgreSQL",
        "Postgres|PG",
        "",
        0.95,
        "unit-test",
        "{\"reason\":\"known database\"}");
    assert(rc == CPRAG_OK);
    rc = cprag_candidate_census(handle, "architecture.test.v1", "docs/auth.md", 1, 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string adjudicatedCensus(buffer.data());
    if (adjudicatedCensus.find("\"adjudication\"") == std::string::npos
        || adjudicatedCensus.find("\"status\":\"keep\"") == std::string::npos
        || adjudicatedCensus.find("\"candidate_type\":\"data-object\"") == std::string::npos) {
        std::cerr << adjudicatedCensus << '\n';
        return 1;
    }
    rc = cprag_pending_candidate_census(handle, "architecture.test.v1", "docs/auth.md", 1, 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string pendingCensus(buffer.data());
    if (pendingCensus.find("\"pending_only\":true") == std::string::npos
        || pendingCensus.find("\"normalized\":\"POSTGRESQL\"") != std::string::npos) {
        std::cerr << pendingCensus << '\n';
        return 1;
    }
    rc = cprag_list_candidate_adjudications(handle, "architecture.test.v1", "keep", 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string adjudications(buffer.data());
    if (adjudications.find("\"normalized\":\"POSTGRESQL\"") == std::string::npos
        || adjudications.find("\"adjudicator\":\"unit-test\"") == std::string::npos) {
        std::cerr << adjudications << '\n';
        return 1;
    }
    rc = cprag_list_candidate_mention_evidence(
        handle,
        "architecture.test.v1",
        "keep",
        "data-object",
        1,
        0,
        10,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string candidateEvidence(buffer.data());
    if (candidateEvidence.find("\"mentions\"") == std::string::npos
        || candidateEvidence.find("\"normalized\":\"POSTGRESQL\"") == std::string::npos
        || candidateEvidence.find("\"candidate_type\":\"data-object\"") == std::string::npos
        || candidateEvidence.find("\"mention_count\":1") == std::string::npos) {
        std::cerr << candidateEvidence << '\n';
        return 1;
    }

    rc = cprag_build_chunk_embedding_text(handle, chunkIds[0], "semantic-context-v1", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string embeddingText(buffer.data());
    if (embeddingText.find("Embedding profile: semantic-context-v1") == std::string::npos
        || embeddingText.find("Source type: meeting-note") == std::string::npos
        || embeddingText.find("Event start at: 2026-06-20T10:00:00Z") == std::string::npos
        || embeddingText.find("Text:\n") == std::string::npos) {
        std::cerr << embeddingText << '\n';
        return 1;
    }

    rc = cprag_vector_status(handle, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string emptyVectorStatus(buffer.data());
    if (emptyVectorStatus.find("\"backend\":\"faiss\"") == std::string::npos
        || emptyVectorStatus.find("\"stored_embeddings\":0") == std::string::npos) {
        std::cerr << emptyVectorStatus << '\n';
        return 1;
    }

    const float authVector[] = {1.0f, 0.0f, 0.0f};
    rc = cprag_add_chunk_embedding(handle, chunkIds[0], "unit-test", authVector, 3);
    assert(rc == CPRAG_OK);
    if (chunkIds.size() > 1) {
        const float secondaryVector[] = {0.0f, 1.0f, 0.0f};
        rc = cprag_add_chunk_embedding(handle, chunkIds[1], "unit-test", secondaryVector, 3);
        assert(rc == CPRAG_OK);
    }

    rc = cprag_vector_status(handle, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string storedVectorStatus(buffer.data());
    if (storedVectorStatus.find("\"stored_embeddings\":") == std::string::npos
        || storedVectorStatus.find("\"active_index\":null") == std::string::npos) {
        std::cerr << storedVectorStatus << '\n';
        return 1;
    }

    const float queryVector[] = {0.9f, 0.1f, 0.0f};
    if (cprag_vector_index_available() != 0) {
        rc = cprag_rebuild_vector_index(handle, "unit-test", buffer.data(), buffer.size());
        assert(rc == CPRAG_OK);
        const std::string rebuilt(buffer.data());
        if (rebuilt.find("\"backend\":\"faiss\"") == std::string::npos
            || rebuilt.find("\"embedding_model\":\"unit-test\"") == std::string::npos
            || rebuilt.find("\"embedding_profile\":\"raw-text-v1\"") == std::string::npos
            || rebuilt.find("\"dimension\":3") == std::string::npos) {
            std::cerr << rebuilt << '\n';
            return 1;
        }

        rc = cprag_vector_search(handle, "unit-test", queryVector, 3, 3, buffer.data(), buffer.size());
        if (rc != CPRAG_OK) {
            std::cerr << cprag_status_message(rc) << ": " << cprag_last_error(handle) << '\n';
            return 1;
        }
        const std::string vectorSearch(buffer.data());
        if (vectorSearch.find("\"results\":[") == std::string::npos
            || vectorSearch.find("\"chunk_id\":" + std::to_string(chunkIds[0])) == std::string::npos
            || vectorSearch.find("\"embedding_profile\":\"raw-text-v1\"") == std::string::npos
            || vectorSearch.find("\"metric\":\"l2\"") == std::string::npos) {
            std::cerr << vectorSearch << '\n';
            return 1;
        }

        rc = cprag_search_with_vector(
            handle,
            "what database does auth use",
            3,
            2,
            CPRAG_SEARCH_AUTO,
            "unit-test",
            queryVector,
            3,
            buffer.data(),
            buffer.size());
        assert(rc == CPRAG_OK);
        const std::string hybridSearch(buffer.data());
        if (hybridSearch.find("\"requested_mode\":\"auto\"") == std::string::npos
            || hybridSearch.find("\"effective_mode\":\"hybrid\"") == std::string::npos
            || hybridSearch.find("\"vector_used\":true") == std::string::npos
            || hybridSearch.find("\"embedding_profile\":\"raw-text-v1\"") == std::string::npos
            || hybridSearch.find("\"retrieval\":") == std::string::npos) {
            std::cerr << hybridSearch << '\n';
            return 1;
        }
    } else {
        rc = cprag_rebuild_vector_index(handle, "unit-test", buffer.data(), buffer.size());
        assert(rc == CPRAG_UNSUPPORTED);
        rc = cprag_vector_search(handle, "unit-test", queryVector, 3, 3, buffer.data(), buffer.size());
        assert(rc == CPRAG_UNSUPPORTED);

        rc = cprag_search_with_vector(
            handle,
            "what database does auth use",
            3,
            2,
            CPRAG_SEARCH_AUTO,
            "unit-test",
            queryVector,
            3,
            buffer.data(),
            buffer.size());
        assert(rc == CPRAG_OK);
        const std::string autoFallback(buffer.data());
        if (autoFallback.find("\"requested_mode\":\"auto\"") == std::string::npos
            || autoFallback.find("\"effective_mode\":\"lexical\"") == std::string::npos
            || autoFallback.find("\"vector_used\":false") == std::string::npos) {
            std::cerr << autoFallback << '\n';
            return 1;
        }
    }

    rc = cprag_search_with_vector(
        handle,
        "what database does auth use",
        3,
        2,
        CPRAG_SEARCH_VECTOR,
        "unit-test",
        nullptr,
        0,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_INVALID_ARGUMENT);

    rc = cprag_search_with_vector(
        handle,
        "what database does auth use",
        3,
        2,
        99,
        "unit-test",
        queryVector,
        3,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_INVALID_ARGUMENT);

    rc = cprag_vocabulary(buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string vocabulary(buffer.data());
    if (vocabulary.find("\"id\":\"service\"") == std::string::npos
        || vocabulary.find("\"id\":\"deployed-on\"") == std::string::npos
        || vocabulary.find("\"source_types\"") == std::string::npos
        || vocabulary.find("\"id\":\"meeting-note\"") == std::string::npos
        || vocabulary.find("\"embedding_profiles\"") == std::string::npos
        || vocabulary.find("\"id\":\"semantic-context-v1\"") == std::string::npos) {
        std::cerr << vocabulary << '\n';
        return 1;
    }

    rc = cprag_search(handle, "what database does auth use", 3, 2, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);

    const std::string result(buffer.data());
    if (result.find("entity:auth") == std::string::npos
        || result.find("entity:postgres") == std::string::npos
        || result.find("\"node_type\":\"service\"") == std::string::npos
        || result.find("\"relationship_type\":\"accesses\"") == std::string::npos
        || result.find("\"support_count\":2") == std::string::npos
        || result.find("\"support_evidence\"") == std::string::npos
        || result.find("\"updated\":true") == std::string::npos) {
        std::cerr << result << '\n';
        return 1;
    }

    rc = cprag_shortest_path(handle, "entity:postgres", "entity:k8s", "", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string path(buffer.data());
    if (path.find("\"found\":true") == std::string::npos
        || path.find("\"relationship_type\":\"accesses\"") == std::string::npos
        || path.find("\"relationship_type\":\"deployed-on\"") == std::string::npos) {
        std::cerr << path << '\n';
        return 1;
    }

    rc = cprag_subgraph(handle, "service,technology-node", "deployed-on", 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string typedSubgraph(buffer.data());
    if (typedSubgraph.find("entity:k8s") == std::string::npos
        || typedSubgraph.find("\"relationship_type\":\"deployed-on\"") == std::string::npos
        || typedSubgraph.find("entity:postgres") != std::string::npos) {
        std::cerr << typedSubgraph << '\n';
        return 1;
    }

    rc = cprag_export_dot(handle, "service,technology-node", "deployed-on", 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string dot(buffer.data());
    if (dot.find("digraph cprag") == std::string::npos
        || dot.find("\"entity:auth\" -> \"entity:k8s\"") == std::string::npos
        || dot.find("deployed-on") == std::string::npos
        || dot.find("entity:postgres") != std::string::npos) {
        std::cerr << dot << '\n';
        return 1;
    }
    rc = cprag_export_dot(handle, "no-such-node-type", "", 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_NOT_FOUND);

    rc = cprag_search(handle, "kubernetes payment token", 3, 1, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string chunkResult(buffer.data());
    if (chunkResult.find("\"chunks\":[") == std::string::npos
        || chunkResult.find("docs/auth.md") == std::string::npos
        || chunkResult.find("Kubernetes") == std::string::npos
        || chunkResult.find("\"source_type\":\"meeting-note\"") == std::string::npos) {
        std::cerr << chunkResult << '\n';
        return 1;
    }

    rc = cprag_stats(handle, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string stats(buffer.data());
    if (stats.find("\"entities\":3") == std::string::npos
        || stats.find("\"edges\":2") == std::string::npos
        || stats.find("\"documents\":1") == std::string::npos
        || stats.find("\"chunks\":") == std::string::npos) {
        std::cerr << stats << '\n';
        return 1;
    }

    rc = cprag_seed_candidate_mention_graph(
        handle,
        "architecture.test.v1",
        "test:architecture",
        "keep",
        "data-object",
        1,
        0,
        10,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string seededCandidates(buffer.data());
    if (seededCandidates.find("\"rows\":1") == std::string::npos
        || seededCandidates.find("\"edge_writes\":1") == std::string::npos
        || seededCandidates.find("\"skipped_replay\":0") == std::string::npos
        || seededCandidates.find("\"last_id\":") == std::string::npos) {
        std::cerr << seededCandidates << '\n';
        return 1;
    }
    rc = cprag_seed_candidate_mention_graph(
        handle,
        "architecture.test.v1",
        "test:architecture",
        "keep",
        "data-object",
        1,
        0,
        10,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string replayedCandidates(buffer.data());
    if (replayedCandidates.find("\"rows\":1") == std::string::npos
        || replayedCandidates.find("\"edge_writes\":0") == std::string::npos
        || replayedCandidates.find("\"skipped_replay\":1") == std::string::npos) {
        std::cerr << replayedCandidates << '\n';
        return 1;
    }
    rc = cprag_build_extraction_queue(
        handle,
        "architecture.test.v1",
        "unit",
        "test:architecture",
        "data-object",
        10,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string builtQueue(buffer.data());
    if (builtQueue.find("\"queued\":1") == std::string::npos
        || builtQueue.find("\"top_chunk_id\":") == std::string::npos
        || builtQueue.find("concepts=1") == std::string::npos) {
        std::cerr << builtQueue << '\n';
        return 1;
    }
    rc = cprag_list_extraction_queue(
        handle,
        "architecture.test.v1",
        "unit",
        "pending",
        10,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string listedQueue(buffer.data());
    if (listedQueue.find("\"items\"") == std::string::npos
        || listedQueue.find("\"status\":\"pending\"") == std::string::npos
        || listedQueue.find("\"queue_id\":\"unit\"") == std::string::npos) {
        std::cerr << listedQueue << '\n';
        return 1;
    }
    rc = cprag_record_extraction_attempt(
        handle,
        "architecture.test.v1",
        "unit",
        chunkIds.front(),
        "unit-extractor",
        "unit-model",
        "processed",
        1,
        1,
        "{\"nodes\":[],\"relationships\":[]}",
        "{\"source\":\"unit\"}",
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string recordedAttempt(buffer.data());
    if (recordedAttempt.find("\"status\":\"processed\"") == std::string::npos
        || recordedAttempt.find("\"queue_updated\":true") == std::string::npos) {
        std::cerr << recordedAttempt << '\n';
        return 1;
    }
    rc = cprag_list_extraction_queue(
        handle,
        "architecture.test.v1",
        "unit",
        "processed",
        10,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string processedQueue(buffer.data());
    if (processedQueue.find("\"status\":\"processed\"") == std::string::npos) {
        std::cerr << processedQueue << '\n';
        return 1;
    }
    rc = cprag_list_extraction_attempts(
        handle,
        "architecture.test.v1",
        "unit",
        chunkIds.front(),
        10,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string listedAttempts(buffer.data());
    if (listedAttempts.find("\"attempts\"") == std::string::npos
        || listedAttempts.find("\"extractor\":\"unit-extractor\"") == std::string::npos
        || listedAttempts.find("\"accepted_relationships\":1") == std::string::npos) {
        std::cerr << listedAttempts << '\n';
        return 1;
    }
    rc = cprag_queue_status(
        handle,
        "architecture.test.v1",
        "unit",
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string queueStatus(buffer.data());
    if (queueStatus.find("\"queue_items\"") == std::string::npos
        || queueStatus.find("\"status\":\"processed\"") == std::string::npos
        || queueStatus.find("\"attempts\":1") == std::string::npos
        || queueStatus.find("\"accepted_nodes\":1") == std::string::npos
        || queueStatus.find("\"accepted_relationships\":1") == std::string::npos) {
        std::cerr << queueStatus << '\n';
        return 1;
    }
    rc = cprag_build_extraction_queue(
        handle,
        "architecture.test.v1",
        "unit-after",
        "test:architecture",
        "data-object",
        10,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string rebuiltAfterAttempt(buffer.data());
    if (rebuiltAfterAttempt.find("\"queued\":0") == std::string::npos) {
        std::cerr << rebuiltAfterAttempt << '\n';
        return 1;
    }

    rc = cprag_chunk_text(
        "# Title\n\nThis paragraph should stay close to the heading.\n\n## Next\nMore text.",
        48,
        8,
        CPRAG_CHUNK_MARKDOWN,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string chunks(buffer.data());
    if (chunks.find("# Title") == std::string::npos || chunks.find("## Next") == std::string::npos) {
        std::cerr << chunks << '\n';
        return 1;
    }

    rc = cprag_delete_source(handle, "docs/auth.md", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string deleted(buffer.data());
    if (deleted.find("\"deleted\":1") == std::string::npos) {
        std::cerr << deleted << '\n';
        return 1;
    }

    rc = cprag_list_chunks(handle, "docs/auth.md", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string chunksAfterDelete(buffer.data());
    if (chunksAfterDelete.find("\"chunks\":[]") == std::string::npos) {
        std::cerr << chunksAfterDelete << '\n';
        return 1;
    }

    rc = cprag_vector_status(handle, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string vectorStatusAfterDelete(buffer.data());
    if (vectorStatusAfterDelete.find("\"stored_embeddings\":0") == std::string::npos
        || vectorStatusAfterDelete.find("\"active_index\":null") == std::string::npos) {
        std::cerr << vectorStatusAfterDelete << '\n';
        return 1;
    }

    cprag_close(handle);
    std::filesystem::remove_all(root);
    return 0;
}
