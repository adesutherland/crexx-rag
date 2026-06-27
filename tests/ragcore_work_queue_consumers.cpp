#include "crexx_rag/ragcore.h"

#include <cassert>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

namespace {

bool contains(const std::string& haystack, const std::string& needle)
{
    return haystack.find(needle) != std::string::npos;
}

bool requireContains(const std::string& text, const std::string& needle, const char* label)
{
    if (!contains(text, needle)) {
        std::cerr << "missing " << label << ": " << needle << "\n" << text << '\n';
        return false;
    }
    return true;
}

bool requireNotContains(const std::string& text, const std::string& needle, const char* label)
{
    if (contains(text, needle)) {
        std::cerr << "unexpected " << label << ": " << needle << "\n" << text << '\n';
        return false;
    }
    return true;
}

} // namespace

int main()
{
    const std::filesystem::path root = std::filesystem::temp_directory_path()
        / ("crexx-rag-work-consumers-" + std::to_string(std::rand()));
    std::filesystem::remove_all(root);

    cprag_handle* handle = nullptr;
    int rc = cprag_open(root.string().c_str(), CPRAG_OPEN_READWRITE, &handle);
    assert(rc == CPRAG_OK);
    assert(handle != nullptr);

    std::vector<char> buffer(65536);

    rc = cprag_add_entity_typed(handle, "entity:auth", "unknown", "Authentication", "Auth service", "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_entity_typed(handle, "entity:postgres", "data-object", "PostgreSQL", "Database", "{}");
    assert(rc == CPRAG_OK);

    rc = cprag_upsert_work_item(
        handle,
        "generic.hybrid.v1",
        "review",
        "type-review",
        "type:auth",
        0,
        "unit://review",
        "Type review",
        0,
        8.0,
        "pending",
        "accept service type",
        "{\"entity_id\":\"entity:auth\",\"accepted_type\":\"service\",\"evidence\":\"reviewed by test\"}",
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);

    rc = cprag_resolve_work_queue(
        handle,
        "generic.hybrid.v1",
        "review",
        "type-review",
        10,
        1,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string typeDryRun(buffer.data());
    if (!requireContains(typeDryRun, "\"dry_run\":true", "type dry run")
        || !requireContains(typeDryRun, "\"accepted_nodes\":1", "type dry run accepted node")) {
        return 1;
    }
    rc = cprag_list_concepts(handle, "service", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    if (!requireNotContains(buffer.data(), "\"id\":\"entity:auth\"", "dry-run type mutation")) {
        return 1;
    }

    rc = cprag_resolve_work_queue(
        handle,
        "generic.hybrid.v1",
        "review",
        "type-review",
        10,
        0,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string typeApplied(buffer.data());
    if (!requireContains(typeApplied, "\"processed\":1", "type processed")
        || !requireContains(typeApplied, "\"accepted_nodes\":1", "type accepted node")) {
        return 1;
    }
    rc = cprag_list_concepts(handle, "service", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string serviceConcepts(buffer.data());
    if (!requireContains(serviceConcepts, "\"id\":\"entity:auth\"", "accepted type")) {
        return 1;
    }
    rc = cprag_subgraph(handle, "service", "", 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string serviceSubgraph(buffer.data());
    if (!requireContains(serviceSubgraph, "\"accepted_type\":\"service\"", "type review metadata")) {
        return 1;
    }

    rc = cprag_upsert_work_item(
        handle,
        "generic.hybrid.v1",
        "review",
        "external-extraction-review",
        "external:redis",
        0,
        "unit://external",
        "External extraction review",
        0,
        7.5,
        "pending",
        "promote external node and edge",
        "{\"node_id\":\"entity:redis\",\"node_type\":\"data-object\",\"node_label\":\"Redis\",\"description\":\"Redis cache\",\"aliases\":\"Redis|cache\",\"source_id\":\"entity:auth\",\"target_id\":\"entity:redis\",\"relationship_type\":\"uses\",\"edge_label\":\"Authentication uses Redis\",\"confidence\":0.82,\"evidence\":\"external reviewer accepted this\"}",
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);

    rc = cprag_upsert_work_item(
        handle,
        "generic.hybrid.v1",
        "review",
        "external-extraction-review",
        "external:empty",
        0,
        "unit://external",
        "Empty external extraction review",
        0,
        1.0,
        "pending",
        "no usable proposal",
        "{\"evidence\":\"nothing to promote\"}",
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);

    rc = cprag_resolve_work_queue(
        handle,
        "generic.hybrid.v1",
        "review",
        "external-extraction-review",
        10,
        0,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string externalApplied(buffer.data());
    if (!requireContains(externalApplied, "\"processed\":1", "external processed")
        || !requireContains(externalApplied, "\"skipped\":1", "external skipped")
        || !requireContains(externalApplied, "\"accepted_nodes\":1", "external accepted node")
        || !requireContains(externalApplied, "\"accepted_relationships\":1", "external accepted relationship")) {
        return 1;
    }

    rc = cprag_subgraph(handle, "service,data-object", "uses", 10, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string externalSubgraph(buffer.data());
    if (!requireContains(externalSubgraph, "\"id\":\"entity:redis\"", "external node")
        || !requireContains(externalSubgraph, "\"relationship_type\":\"uses\"", "external edge")
        || !requireContains(externalSubgraph, "\"directness\":\"accepted-typed-edge\"", "external directness")
        || !requireContains(externalSubgraph, "\"evidence_class\":\"external-extraction-review\"", "external evidence class")) {
        return 1;
    }

    rc = cprag_list_work_attempts(
        handle,
        "generic.hybrid.v1",
        "review",
        "",
        "",
        20,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string attempts(buffer.data());
    if (!requireContains(attempts, "\"item_type\":\"type-review\"", "type attempt")
        || !requireContains(attempts, "\"item_type\":\"external-extraction-review\"", "external attempt")
        || !requireContains(attempts, "\"status\":\"skipped\"", "skipped attempt")) {
        return 1;
    }

    rc = cprag_resolve_work_queue(
        handle,
        "generic.hybrid.v1",
        "review",
        "unsupported-review",
        1,
        0,
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_INVALID_ARGUMENT);

    cprag_close(handle);
    std::filesystem::remove_all(root);
    return 0;
}
