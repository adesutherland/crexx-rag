#include "crexx_rag/ragcore.h"

#include <sqlite3.h>

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

namespace {

struct ChunkId {
    long long value {0};
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
    std::cerr << "phase0 defect demonstration failure: " << message;
    if (!detail.empty()) {
        std::cerr << "\n" << detail;
    }
    std::cerr << '\n';
    return false;
}

bool callOk(int rc, cprag_handle* handle, const std::string& operation)
{
    if (rc == CPRAG_OK) {
        return true;
    }
    std::cerr << "phase0 defect demonstration failure: " << operation << " returned " << rc;
    if (handle != nullptr) {
        std::cerr << ": " << cprag_last_error(handle);
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

int firstChunk(
    long long chunkId,
    const char*,
    const char*,
    int,
    const char*,
    void* userData)
{
    auto* output = static_cast<ChunkId*>(userData);
    if (output->value == 0) {
        output->value = chunkId;
    }
    return CPRAG_OK;
}

bool sqliteColumnExists(sqlite3* db, const std::string& table, const std::string& wanted)
{
    sqlite3_stmt* stmt = nullptr;
    const std::string sql = "PRAGMA table_info(" + table + ")";
    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) != SQLITE_OK) {
        return false;
    }
    bool found = false;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        const unsigned char* name = sqlite3_column_text(stmt, 1);
        if (name != nullptr && wanted == reinterpret_cast<const char*>(name)) {
            found = true;
            break;
        }
    }
    sqlite3_finalize(stmt);
    return found;
}

} // namespace

int main()
{
#ifndef CPRAG_PHASE0_FIXTURE_DIR
    std::cerr << "CPRAG_PHASE0_FIXTURE_DIR is not defined\n";
    return 1;
#endif
    const std::filesystem::path fixtureDir(CPRAG_PHASE0_FIXTURE_DIR);
    const std::string revision1 = readFile(fixtureDir / "it-auth-decision-v1.md");
    const std::string revision2 = readFile(fixtureDir / "it-auth-decision-v2.md");
    if (!require(!revision1.empty() && !revision2.empty(), "source fixture is empty")) {
        return 1;
    }

    const std::filesystem::path root = std::filesystem::temp_directory_path()
        / ("crexx-rag-phase0-defects-" + std::to_string(std::rand()));
    std::filesystem::remove_all(root);
    cprag_handle* handle = nullptr;
    int rc = cprag_open(root.string().c_str(), CPRAG_OPEN_READWRITE, &handle);
    if (!callOk(rc, handle, "open defect library")) {
        return 1;
    }
    std::vector<char> buffer(1024 * 1024);

    auto ingest = [&](const std::string& text, int revision) {
        const std::string metadata = "{\"fixture\":\"generic-it-v1\",\"revision\":"
            + std::to_string(revision) + "}";
        return cprag_ingest_text_ex(
            handle, "fixture://it/auth/same-uri", "Identity Gateway decision", text.c_str(),
            CPRAG_CHUNK_MARKDOWN, 4096, 0, metadata.c_str(), "decision-record", 0.95,
            revision == 1 ? "2026-01-12T10:00:00Z" : "2026-03-18T15:30:00Z",
            "", "", buffer.data(), buffer.size());
    };

    rc = ingest(revision1, 1);
    if (!callOk(rc, handle, "ingest revision 1")) {
        return 1;
    }
    ChunkId oldChunk;
    rc = cprag_each_chunk(handle, "fixture://it/auth/same-uri", firstChunk, &oldChunk);
    if (!callOk(rc, handle, "read revision 1 chunk") || !require(oldChunk.value > 0, "revision 1 chunk id missing")) {
        return 1;
    }

    rc = cprag_add_candidate_mention(
        handle, "defect.phase0.v1", "fixture://it/auth/same-uri", oldChunk.value,
        "stage1", "phase0-defect", "Cedar Store", "CEDAR STORE", 10, 1, 1, 1, "{}");
    if (!callOk(rc, handle, "add defect candidate")) {
        return 1;
    }
    rc = cprag_adjudicate_candidate(
        handle, "defect.phase0.v1", "CEDAR STORE", "keep", "data-object",
        "Cedar Store", "CSDB", "", 0.9, "phase0-fixed", "{}");
    if (!callOk(rc, handle, "adjudicate defect candidate")) {
        return 1;
    }
    rc = cprag_seed_candidate_mention_graph(
        handle, "defect.phase0.v1", "defect", "keep", "data-object", 1, 0, 10,
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "seed defect graph")) {
        return 1;
    }

    rc = ingest(revision2, 2);
    if (!callOk(rc, handle, "ingest revision 2")) {
        return 1;
    }
    ChunkId newChunk;
    rc = cprag_each_chunk(handle, "fixture://it/auth/same-uri", firstChunk, &newChunk);
    if (!callOk(rc, handle, "read revision 2 chunk")
        || !require(newChunk.value > 0 && newChunk.value != oldChunk.value,
            "same-URI reingest did not demonstrate chunk-id churn")) {
        return 1;
    }
    rc = cprag_chunk_text_by_id(handle, oldChunk.value, buffer.data(), buffer.size());
    if (!require(rc == CPRAG_NOT_FOUND, "old chunk id unexpectedly remains addressable")) {
        return 1;
    }
    std::cout << "{\"defect\":\"same-uri-chunk-id-churn\",\"desired_parity\":false,\"same_uri\":true,\"content_changed\":true,\"old_chunk_addressable\":false,\"new_chunk_id_differs\":true}\n";

    rc = cprag_subgraph(
        handle, "data-object,evidence-chunk", "mentioned-in", 20,
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "read graph after revision change")) {
        return 1;
    }
    const std::string afterChange(buffer.data());
    const std::string staleEvidenceId = "evidence:chunk:" + std::to_string(oldChunk.value);
    if (!require(contains(afterChange, staleEvidenceId), "stale evidence node absent after source change", afterChange)
        || !require(contains(afterChange, "\"relationship_type\":\"mentioned-in\""), "stale mention edge absent after source change", afterChange)) {
        return 1;
    }
    rc = cprag_delete_source(handle, "fixture://it/auth/same-uri", buffer.data(), buffer.size());
    if (!callOk(rc, handle, "delete changed source")) {
        return 1;
    }
    rc = cprag_subgraph(
        handle, "data-object,evidence-chunk", "mentioned-in", 20,
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "read graph after deletion")) {
        return 1;
    }
    const std::string afterDelete(buffer.data());
    if (!require(contains(afterDelete, staleEvidenceId), "stale evidence node absent after source deletion", afterDelete)
        || !require(contains(afterDelete, "\"relationship_type\":\"mentioned-in\""), "stale mention edge absent after source deletion", afterDelete)) {
        return 1;
    }
    std::cout << "{\"defect\":\"stale-graph-support\",\"desired_parity\":false,\"stale_after_revision_change\":true,\"stale_after_source_deletion\":true,\"deleted_chunk_addressable\":false,\"mention_edge_survives\":true}\n";

    rc = cprag_upsert_work_item(
        handle, "defect.phase0.v1", "unsafe", "external-extraction-review", "item:one", 0,
        "fixture://queue", "Unsafe queue item", 0, 10.0, "pending", "provider work required", "{}",
        buffer.data(), buffer.size());
    if (!callOk(rc, handle, "upsert unsafe queue item")) {
        return 1;
    }
    cprag_handle* secondHandle = nullptr;
    rc = cprag_open(root.string().c_str(), CPRAG_OPEN_READWRITE, &secondHandle);
    if (!callOk(rc, secondHandle, "open second queue consumer")) {
        return 1;
    }
    rc = cprag_list_work_queue(
        handle, "defect.phase0.v1", "unsafe", "external-extraction-review", "pending", 1,
        buffer.data(), buffer.size());
    const std::string firstView(buffer.data());
    if (!callOk(rc, handle, "first consumer reads pending")) {
        return 1;
    }
    std::vector<char> secondBuffer(4096);
    rc = cprag_list_work_queue(
        secondHandle, "defect.phase0.v1", "unsafe", "external-extraction-review", "pending", 1,
        secondBuffer.data(), secondBuffer.size());
    const std::string secondView(secondBuffer.data());
    if (!callOk(rc, secondHandle, "second consumer reads pending")
        || !require(contains(firstView, "\"item_id\":\"item:one\"")
                && contains(secondView, "\"item_id\":\"item:one\""),
            "two consumers did not observe the same unclaimed item")) {
        return 1;
    }

    sqlite3* db = nullptr;
    if (sqlite3_open_v2((root / "library.sqlite").string().c_str(), &db, SQLITE_OPEN_READONLY, nullptr) != SQLITE_OK) {
        std::cerr << "failed to inspect work_queue schema\n";
        return 1;
    }
    const bool hasLease = sqliteColumnExists(db, "work_queue", "lease_owner")
        || sqliteColumnExists(db, "work_queue", "lease_expires_at");
    const bool hasFence = sqliteColumnExists(db, "work_queue", "fence_token");
    sqlite3_close(db);
    cprag_close(secondHandle);
    if (!require(!hasLease && !hasFence, "oracle unexpectedly has lease/fence columns")) {
        return 1;
    }
    std::cout << "{\"defect\":\"unsafe-queue-crash-boundary\",\"desired_parity\":false,\"two_consumers_observe_same_pending_item\":true,\"atomic_claim\":false,\"lease\":false,\"fence_token\":false,\"provider_work_replay_possible\":true}\n";

    const std::string longDescription(960, 'x');
    for (int i = 0; i < 1200; ++i) {
        const std::string id = "bulk:" + std::to_string(i);
        const std::string label = "Bulk node " + std::to_string(i);
        rc = cprag_add_entity_typed(
            handle, id.c_str(), "component", label.c_str(), longDescription.c_str(), "{}");
        if (!callOk(rc, handle, "add bulk entity")) {
            return 1;
        }
    }
    rc = cprag_subgraph(handle, "component", "", 2000, buffer.data(), buffer.size());
    if (!require(rc == CPRAG_BUFFER_TOO_SMALL, "1 MiB whole-result buffer did not fail as expected", cprag_last_error(handle))) {
        return 1;
    }
    std::cout << "{\"defect\":\"whole-result-fixed-buffer-json\",\"desired_parity\":false,\"buffer_bytes\":1048576,\"rows\":1200,\"description_bytes_per_row\":960,\"result\":\"buffer-too-small\",\"paged_or_streamed\":false}\n";

    cprag_close(handle);
    std::filesystem::remove_all(root);
    return 0;
}
