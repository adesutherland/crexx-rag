#include "crexx_rag/ragcore.h"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

namespace {

struct Chunk {
    long long id {0};
    std::string sourceUri;
    int index {0};
    std::string text;
};

bool contains(const std::string& text, const std::string& needle)
{
    return text.find(needle) != std::string::npos;
}

bool require(bool condition, const std::string& message, const std::string& detail = {})
{
    if (condition) {
        return true;
    }
    std::cerr << "phase0 semantic oracle failure: " << message;
    if (!detail.empty()) {
        std::cerr << "\n" << detail;
    }
    std::cerr << '\n';
    return false;
}

std::string readFile(const std::filesystem::path& path)
{
    std::ifstream input(path, std::ios::binary);
    std::ostringstream buffer;
    buffer << input.rdbuf();
    return buffer.str();
}

int visitChunk(
    long long chunkId,
    const char* sourceUri,
    const char*,
    int chunkIndex,
    const char* text,
    void* userData)
{
    auto* chunks = static_cast<std::vector<Chunk>*>(userData);
    chunks->push_back(Chunk {
        chunkId,
        sourceUri == nullptr ? std::string() : std::string(sourceUri),
        chunkIndex,
        text == nullptr ? std::string() : std::string(text)
    });
    return CPRAG_OK;
}

bool callOk(int rc, cprag_handle* handle, const std::string& operation)
{
    if (rc == CPRAG_OK) {
        return true;
    }
    std::cerr << "phase0 semantic oracle failure: " << operation << " returned " << rc;
    if (handle != nullptr) {
        std::cerr << ": " << cprag_last_error(handle);
    }
    std::cerr << '\n';
    return false;
}

} // namespace

int main()
{
#ifndef CPRAG_PHASE0_FIXTURE_DIR
    std::cerr << "CPRAG_PHASE0_FIXTURE_DIR is not defined\n";
    return 1;
#endif
    const std::filesystem::path fixtureDir(CPRAG_PHASE0_FIXTURE_DIR);
    const std::string decision = readFile(fixtureDir / "it-auth-decision-v2.md");
    const std::string operations = readFile(fixtureDir / "it-operations-note.md");
    if (!require(!decision.empty() && !operations.empty(), "fixture input is empty")) {
        return 1;
    }

    std::vector<char> buffer(1024 * 1024);
    const std::string chunkInput = "# One\n\nAlpha paragraph.\n\n# Two\n\nBeta paragraph.";
    int rc = cprag_chunk_text(
        chunkInput.c_str(), 30, 5, CPRAG_CHUNK_MARKDOWN, buffer.data(), buffer.size());
    if (!callOk(rc, nullptr, "cprag_chunk_text")) {
        return 1;
    }
    const std::string chunkJson(buffer.data());
    if (!require(contains(chunkJson, "\"index\":0,\"text\":\"# One\\n\\nAlpha paragraph.\\n\\n\",\"length\":25"),
            "first chunk semantic record changed", chunkJson)
        || !require(contains(chunkJson, "\"index\":1,\"text\":\"# Two\\n\\nBeta paragraph.\",\"length\":22"),
            "second chunk semantic record changed", chunkJson)) {
        return 1;
    }
    std::cout << "{\"record\":\"chunking\",\"file_type\":\"markdown\",\"chunk_size\":30,\"overlap\":5,\"chunks\":[{\"index\":0,\"length\":25,\"text\":\"# One\\n\\nAlpha paragraph.\\n\\n\"},{\"index\":1,\"length\":22,\"text\":\"# Two\\n\\nBeta paragraph.\"}]}\n";

    const std::filesystem::path root = std::filesystem::temp_directory_path()
        / ("crexx-rag-phase0-semantics-" + std::to_string(std::rand()));
    std::filesystem::remove_all(root);
    cprag_handle* handle = nullptr;
    rc = cprag_open(root.string().c_str(), CPRAG_OPEN_READWRITE, &handle);
    if (!callOk(rc, handle, "cprag_open")) {
        return 1;
    }

    auto failAndClose = [&](const std::string& operation) {
        std::cerr << "phase0 semantic oracle failure after " << operation << "\n";
        cprag_close(handle);
        std::filesystem::remove_all(root);
        return 1;
    };

    rc = cprag_ingest_text_ex(
        handle,
        "fixture://it/auth/current",
        "Identity Gateway decision revision 2",
        decision.c_str(),
        CPRAG_CHUNK_MARKDOWN,
        4096,
        0,
        "{\"fixture\":\"generic-it-v1\",\"revision\":2}",
        "decision-record",
        0.95,
        "2026-03-18T15:30:00Z",
        "2026-03-18T15:30:00Z",
        "",
        buffer.data(),
        buffer.size());
    if (!callOk(rc, handle, "ingest decision")) {
        return failAndClose("ingest decision");
    }
    rc = cprag_ingest_text_ex(
        handle,
        "fixture://it/operations/corroboration",
        "Operations assurance",
        operations.c_str(),
        CPRAG_CHUNK_MARKDOWN,
        4096,
        0,
        "{\"fixture\":\"generic-it-v1\",\"independent_support\":true}",
        "operations-note",
        0.85,
        "2026-03-20T09:00:00Z",
        "2026-03-20T09:00:00Z",
        "",
        buffer.data(),
        buffer.size());
    if (!callOk(rc, handle, "ingest operations")) {
        return failAndClose("ingest operations");
    }

    std::vector<Chunk> decisionChunks;
    std::vector<Chunk> operationsChunks;
    rc = cprag_each_chunk(handle, "fixture://it/auth/current", visitChunk, &decisionChunks);
    if (!callOk(rc, handle, "visit decision chunks")) {
        return failAndClose("visit decision chunks");
    }
    rc = cprag_each_chunk(handle, "fixture://it/operations/corroboration", visitChunk, &operationsChunks);
    if (!callOk(rc, handle, "visit operations chunks")) {
        return failAndClose("visit operations chunks");
    }
    if (!require(decisionChunks.size() == 1 && operationsChunks.size() == 1,
            "fixture ingest should produce one chunk per source")) {
        return failAndClose("fixture chunk census");
    }

    rc = cprag_add_candidate_mention(
        handle, "generic.phase0.v1", "fixture://it/auth/current", decisionChunks[0].id,
        "stage1", "phase0-oracle", "Cedar Store", "CEDAR STORE", 18, 1, 1, 3,
        "{\"case\":\"it-support-01\"}");
    if (!callOk(rc, handle, "add decision candidate")) {
        return failAndClose("add decision candidate");
    }
    rc = cprag_add_candidate_mention(
        handle, "generic.phase0.v1", "fixture://it/operations/corroboration", operationsChunks[0].id,
        "stage1", "phase0-oracle", "Cedar Store", "CEDAR STORE", 12, 1, 1, 1,
        "{\"case\":\"it-support-01\"}");
    if (!callOk(rc, handle, "add operations candidate")) {
        return failAndClose("add operations candidate");
    }
    rc = cprag_adjudicate_candidate(
        handle, "generic.phase0.v1", "CEDAR STORE", "keep", "data-object",
        "Cedar Store", "CSDB", "Mercury is a separate ambiguity", 0.96,
        "phase0-fixed", "{\"judgement\":\"known database\"}");
    if (!callOk(rc, handle, "adjudicate candidate")) {
        return failAndClose("adjudicate candidate");
    }
    rc = cprag_candidate_census(
        handle, "generic.phase0.v1", "", 1, 10, buffer.data(), buffer.size());
    if (!callOk(rc, handle, "candidate census")) {
        return failAndClose("candidate census");
    }
    const std::string census(buffer.data());
    if (!require(contains(census, "\"normalized\":\"CEDAR STORE\""), "census normalized value", census)
        || !require(contains(census, "\"count\":2"), "census support count", census)
        || !require(contains(census, "\"max_priority\":18"), "census priority", census)
        || !require(contains(census, "\"status\":\"keep\""), "adjudication status", census)) {
        return failAndClose("census semantics");
    }
    std::cout << "{\"record\":\"candidate-census-adjudication\",\"normalized\":\"CEDAR STORE\",\"mention_count\":2,\"max_priority\":18,\"status\":\"keep\",\"type\":\"data-object\",\"canonical_label\":\"Cedar Store\",\"aliases\":[\"CSDB\"]}\n";

    rc = cprag_seed_candidate_mention_graph(
        handle, "generic.phase0.v1", "phase0", "keep", "data-object", 1, 0, 10,
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "seed candidate graph")) {
        return failAndClose("seed candidate graph");
    }
    const std::string seeded(buffer.data());
    if (!require(contains(seeded, "\"processed\":2"), "seed processed count", seeded)
        || !require(contains(seeded, "\"edge_writes\":2"), "seed edge count", seeded)) {
        return failAndClose("seed semantics");
    }
    rc = cprag_subgraph(handle, "data-object,evidence-chunk", "mentioned-in", 20, buffer.data(), buffer.size());
    if (!callOk(rc, handle, "seed subgraph")) {
        return failAndClose("seed subgraph");
    }
    const std::string seededGraph(buffer.data());
    if (!require(contains(seededGraph, "\"id\":\"phase0:data-object:cedar-store\""), "seed concept id", seededGraph)
        || !require(contains(seededGraph, "\"relationship_type\":\"mentioned-in\""), "mention edge", seededGraph)) {
        return failAndClose("seed graph semantics");
    }
    std::cout << "{\"record\":\"mention-graph-seeding\",\"concept_id\":\"phase0:data-object:cedar-store\",\"concept_upserts\":2,\"evidence_upserts\":2,\"mentioned_in_edges\":2,\"replay_skips\":0}\n";

    rc = cprag_build_extraction_queue(
        handle, "generic.phase0.v1", "phase0-extract", "phase0", "data-object", 10,
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "build extraction queue")) {
        return failAndClose("build extraction queue");
    }
    const std::string builtQueue(buffer.data());
    if (!require(contains(builtQueue, "\"queued\":2"), "queue count", builtQueue)) {
        return failAndClose("queue count");
    }
    rc = cprag_list_extraction_queue(
        handle, "generic.phase0.v1", "phase0-extract", "pending", 10,
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "list extraction queue")) {
        return failAndClose("list extraction queue");
    }
    const std::string queue(buffer.data());
    const size_t decisionPos = queue.find("fixture://it/auth/current");
    const size_t operationsPos = queue.find("fixture://it/operations/corroboration");
    if (!require(decisionPos != std::string::npos && operationsPos != std::string::npos && decisionPos < operationsPos,
            "extraction ranking order", queue)) {
        return failAndClose("extraction ranking");
    }
    std::cout << "{\"record\":\"extraction-ranking\",\"queue\":\"phase0-extract\",\"order\":[\"fixture://it/auth/current#0\",\"fixture://it/operations/corroboration#0\"],\"status\":\"pending\"}\n";

    rc = cprag_queue_status(handle, "generic.phase0.v1", "phase0-extract", buffer.data(), buffer.size());
    if (!callOk(rc, handle, "queue status")) {
        return failAndClose("queue status");
    }
    const std::string queueStatus(buffer.data());
    if (!require(contains(queueStatus, "\"queue_items\":2"), "queue total", queueStatus)
        || !require(contains(queueStatus, "\"status\":\"pending\""), "queue pending status", queueStatus)
        || !require(contains(queueStatus, "\"count\":2"), "queue pending count", queueStatus)) {
        return failAndClose("queue status semantics");
    }
    std::cout << "{\"record\":\"queue-status\",\"queue\":\"phase0-extract\",\"pending\":2,\"attempts\":0,\"accepted_nodes\":0,\"accepted_relationships\":0}\n";

    rc = cprag_add_entity_typed(handle, "entity:identity-gateway", "service", "Identity Gateway", "Token validation service", "{}");
    if (!callOk(rc, handle, "add gateway")) {
        return failAndClose("add gateway");
    }
    rc = cprag_add_entity_typed(handle, "entity:cedar-store", "data-object", "Cedar Store", "Customer profile database", "{\"aliases\":\"CSDB\"}");
    if (!callOk(rc, handle, "add store")) {
        return failAndClose("add store");
    }
    rc = cprag_add_entity_typed(handle, "entity:vault-service", "service", "Vault Service", "Snapshot service", "{}");
    if (!callOk(rc, handle, "add vault")) {
        return failAndClose("add vault");
    }
    rc = cprag_add_edge_typed(handle, "entity:identity-gateway", "entity:cedar-store", "depends-on", "Reads customer profiles", 1.0,
        "{\"source_uri\":\"fixture://it/auth/current\",\"directness\":\"accepted-typed-edge\",\"evidence_class\":\"source-passage\"}");
    if (!callOk(rc, handle, "add dependency edge")) {
        return failAndClose("add dependency edge");
    }
    rc = cprag_add_edge_typed(handle, "entity:cedar-store", "entity:vault-service", "protected-by", "Protected by snapshots", 1.0,
        "{\"source_uri\":\"fixture://it/auth/current\",\"directness\":\"accepted-typed-edge\",\"evidence_class\":\"source-passage\"}");
    if (!callOk(rc, handle, "add protection edge")) {
        return failAndClose("add protection edge");
    }

    rc = cprag_search_with_vector(
        handle, "Cedar Store", 4, 1, CPRAG_SEARCH_AUTO, "", nullptr, 0,
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "lexical auto search")) {
        return failAndClose("lexical auto search");
    }
    const std::string lexical(buffer.data());
    if (!require(contains(lexical, "\"requested_mode\":\"auto\""), "requested search mode", lexical)
        || !require(contains(lexical, "\"effective_mode\":\"lexical\""), "effective search mode", lexical)
        || !require(contains(lexical, "fixture://it/auth/current"), "decision lexical hit", lexical)
        || !require(contains(lexical, "fixture://it/operations/corroboration"), "operations lexical hit", lexical)) {
        return failAndClose("lexical semantics");
    }
    std::cout << "{\"record\":\"lexical-retrieval\",\"query\":\"Cedar Store\",\"requested_mode\":\"auto\",\"effective_mode\":\"lexical\",\"source_uris\":[\"fixture://it/auth/current\",\"fixture://it/operations/corroboration\"],\"vector_used\":false}\n";

    const float vector[] = {1.0f, 0.0f, 0.0f};
    rc = cprag_search_with_vector(
        handle, "Cedar Store", 4, 1, CPRAG_SEARCH_VECTOR, "phase0-model", vector, 3,
        buffer.data(), buffer.size());
#ifdef CPRAG_HAVE_FAISS
    if (!require(rc == CPRAG_NOT_FOUND, "vector oracle without rebuilt index should report not found")) {
        return failAndClose("vector semantics");
    }
    std::cout << "{\"record\":\"vector-retrieval\",\"build\":\"faiss-enabled\",\"result\":\"not-found-before-index-rebuild\"}\n";
#else
    if (!require(rc == CPRAG_UNSUPPORTED, "non-FAISS vector oracle should report unsupported")) {
        return failAndClose("vector semantics");
    }
    std::cout << "{\"record\":\"vector-retrieval\",\"build\":\"faiss-disabled\",\"result\":\"unsupported\",\"fallback\":\"auto-uses-lexical\"}\n";
#endif

    rc = cprag_shortest_path(
        handle, "entity:identity-gateway", "entity:vault-service", "depends-on,protected-by",
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "shortest path")) {
        return failAndClose("shortest path");
    }
    const std::string path(buffer.data());
    if (!require(contains(path, "\"found\":true"), "directed path found", path)
        || !require(contains(path, "\"id\":\"entity:cedar-store\""), "directed path intermediate", path)
        || !require(contains(path, "\"relationship_type\":\"depends-on\""), "depends-on path edge", path)
        || !require(contains(path, "\"relationship_type\":\"protected-by\""), "protected-by path edge", path)) {
        return failAndClose("graph path semantics");
    }
    std::cout << "{\"record\":\"graph-retrieval\",\"direction\":\"forward\",\"path\":[\"entity:identity-gateway\",\"entity:cedar-store\",\"entity:vault-service\"],\"relationships\":[\"depends-on\",\"protected-by\"],\"found\":true}\n";

    rc = cprag_delete_source(
        handle, "fixture://it/operations/corroboration", buffer.data(), buffer.size());
    if (!callOk(rc, handle, "delete source")) {
        return failAndClose("delete source");
    }
    if (!require(contains(buffer.data(), "\"deleted\":1"), "source deletion result", buffer.data())) {
        return failAndClose("delete source semantics");
    }
    rc = cprag_list_chunks(
        handle, "fixture://it/operations/corroboration", buffer.data(), buffer.size());
    if (!callOk(rc, handle, "list deleted chunks")) {
        return failAndClose("list deleted chunks");
    }
    if (!require(contains(buffer.data(), "\"chunks\":[]"), "deleted chunks absent", buffer.data())) {
        return failAndClose("deleted chunks semantics");
    }
    std::cout << "{\"record\":\"source-deletion\",\"source_uri\":\"fixture://it/operations/corroboration\",\"document_present\":false,\"chunks_present\":false,\"fts_hits_present\":false}\n";

    cprag_close(handle);
    std::filesystem::remove_all(root);
    return 0;
}
