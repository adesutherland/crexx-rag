#include "crexx_rag/ragcore.h"

#include <cassert>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

int main()
{
    const std::filesystem::path root = std::filesystem::temp_directory_path()
        / ("crexx-rag-smoke-" + std::to_string(std::rand()));
    std::filesystem::remove_all(root);

    cprag_handle* handle = nullptr;
    int rc = cprag_open(root.string().c_str(), CPRAG_OPEN_READWRITE, &handle);
    assert(rc == CPRAG_OK);
    assert(handle != nullptr);

    rc = cprag_add_entity(handle, "entity:auth", "Service", "Authentication service handling login", "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_entity(handle, "entity:postgres", "Database", "PostgreSQL user profile database", "{}");
    assert(rc == CPRAG_OK);
    rc = cprag_add_edge(handle, "entity:auth", "entity:postgres", "CONNECTS_TO", 1.0, "{}");
    assert(rc == CPRAG_OK);

    std::vector<char> buffer(65536);
    rc = cprag_search(handle, "what database does auth use", 3, 2, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);

    const std::string result(buffer.data());
    if (result.find("entity:auth") == std::string::npos || result.find("entity:postgres") == std::string::npos) {
        std::cerr << result << '\n';
        return 1;
    }

    rc = cprag_stats(handle, buffer.data(), buffer.size());
    assert(rc == CPRAG_OK);
    const std::string stats(buffer.data());
    if (stats.find("\"entities\":2") == std::string::npos || stats.find("\"edges\":1") == std::string::npos) {
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

    cprag_close(handle);
    std::filesystem::remove_all(root);
    return 0;
}
