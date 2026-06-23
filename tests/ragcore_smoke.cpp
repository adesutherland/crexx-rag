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
    rc = cprag_add_entity_typed(handle, "entity:postgres", "data-object", "PostgreSQL", "PostgreSQL user profile database", "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_entity_typed(handle, "entity:k8s", "technology-node", "Kubernetes", "Kubernetes runtime platform", "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_edge_typed(handle, "entity:auth", "entity:postgres", "accesses", "Reads user profiles", 1.0, "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_edge_typed(handle, "entity:auth", "entity:k8s", "deployed-on", "Runs on Kubernetes", 1.0, "{}");
    assert(rc == CPRAG_OK);

    std::vector<char> buffer(65536);

    rc = cprag_add_entity(handle, "entity:bad", "Component", "Bad metadata should be rejected", "{not-json");
    assert(rc == CPRAG_INVALID_ARGUMENT);

    rc = cprag_ingest_text(
        handle,
        "docs/auth.md",
        "Authentication architecture notes",
        "# Auth\n\nThe authentication service depends on PostgreSQL and is deployed on Kubernetes.\n\n"
        "The payment service calls auth for token validation.",
        CPRAG_CHUNK_MARKDOWN,
        80,
        16,
        "{\"domain\":\"architecture\"}",
        buffer.data(),
        buffer.size());
    assert(rc == CPRAG_OK);
    const std::string ingest(buffer.data());
    if (ingest.find("\"source_uri\":\"docs/auth.md\"") == std::string::npos
        || ingest.find("\"chunk_count\":") == std::string::npos) {
        std::cerr << ingest << '\n';
        return 1;
    }

    rc = cprag_list_sources(handle, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string sources(buffer.data());
    if (sources.find("Authentication architecture notes") == std::string::npos
        || sources.find("\"chunk_count\":") == std::string::npos) {
        std::cerr << sources << '\n';
        return 1;
    }

    rc = cprag_list_chunks(handle, "docs/auth.md", buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string listedChunks(buffer.data());
    if (listedChunks.find("\"source_uri\":\"docs/auth.md\"") == std::string::npos
        || listedChunks.find("token validation") == std::string::npos) {
        std::cerr << listedChunks << '\n';
        return 1;
    }
    const std::vector<long long> chunkIds = chunkIdsFromJson(listedChunks);
    assert(!chunkIds.empty());

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
            || vectorSearch.find("\"metric\":\"l2\"") == std::string::npos) {
            std::cerr << vectorSearch << '\n';
            return 1;
        }
    } else {
        rc = cprag_rebuild_vector_index(handle, "unit-test", buffer.data(), buffer.size());
        assert(rc == CPRAG_UNSUPPORTED);
        rc = cprag_vector_search(handle, "unit-test", queryVector, 3, 3, buffer.data(), buffer.size());
        assert(rc == CPRAG_UNSUPPORTED);
    }

    rc = cprag_vocabulary(buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string vocabulary(buffer.data());
    if (vocabulary.find("\"id\":\"service\"") == std::string::npos
        || vocabulary.find("\"id\":\"deployed-on\"") == std::string::npos) {
        std::cerr << vocabulary << '\n';
        return 1;
    }

    rc = cprag_search(handle, "what database does auth use", 3, 2, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);

    const std::string result(buffer.data());
    if (result.find("entity:auth") == std::string::npos
        || result.find("entity:postgres") == std::string::npos
        || result.find("\"node_type\":\"service\"") == std::string::npos
        || result.find("\"relationship_type\":\"accesses\"") == std::string::npos) {
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

    rc = cprag_search(handle, "kubernetes payment token", 3, 1, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string chunkResult(buffer.data());
    if (chunkResult.find("\"chunks\":[") == std::string::npos
        || chunkResult.find("docs/auth.md") == std::string::npos
        || chunkResult.find("Kubernetes") == std::string::npos) {
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
