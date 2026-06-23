#include "crexx_rag/ragcore.h"

#include <cstdlib>
#include <cctype>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

constexpr size_t kJsonBufferSize = 1024 * 1024;

void usage()
{
    std::cerr
        << "usage:\n"
        << "  crexx-rag init <library>\n"
        << "  crexx-rag add-entity <library> <id> <label> <description> [metadata-json]\n"
        << "  crexx-rag add-entity-typed <library> <id> <node-type> <label> <description> [metadata-json]\n"
        << "  crexx-rag add-edge <library> <source-id> <target-id> <label> [weight] [metadata-json]\n"
        << "  crexx-rag add-edge-typed <library> <source-id> <target-id> <relationship-type> <label> [weight] [metadata-json]\n"
        << "  crexx-rag ingest-text <library> <source-uri> <title> <plain|rexx|markdown> <chunk-size> <overlap> <text> [metadata-json]\n"
        << "  crexx-rag ingest-file <library> <path> <plain|rexx|markdown> <chunk-size> <overlap> [title] [metadata-json]\n"
        << "  crexx-rag list-sources <library>\n"
        << "  crexx-rag list-chunks <library> <source-uri>\n"
        << "  crexx-rag delete-source <library> <source-uri>\n"
        << "  crexx-rag add-chunk-embedding <library> <chunk-id> <embedding-model> <comma-separated-floats>\n"
        << "  crexx-rag rebuild-vector-index <library> <embedding-model>\n"
        << "  crexx-rag vector-search <library> <embedding-model> <comma-separated-floats> [top-k]\n"
        << "  crexx-rag vector-status <library>\n"
        << "  crexx-rag search <library> <query> [top-k] [hops]\n"
        << "  crexx-rag expand <library> <anchor-csv> [hops] [relation-filter-csv]\n"
        << "  crexx-rag shortest-path <library> <source-id> <target-id> [relationship-filter-csv]\n"
        << "  crexx-rag subgraph <library> [node-type-csv] [relationship-type-csv] [limit]\n"
        << "  crexx-rag vocabulary\n"
        << "  crexx-rag chunk <plain|rexx|markdown> <chunk-size> <overlap> <text>\n"
        << "  crexx-rag stats <library>\n";
}

int fail(int code, cprag_handle* handle = nullptr)
{
    std::cerr << cprag_status_message(code);
    if (handle != nullptr) {
        std::cerr << ": " << cprag_last_error(handle);
    }
    std::cerr << '\n';
    return code == CPRAG_OK ? 0 : code;
}

template <typename Fn>
int withLibrary(const std::string& path, const Fn& fn)
{
    cprag_handle* handle = nullptr;
    const int rc = cprag_open(path.c_str(), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        return fail(rc, handle);
    }
    const int result = fn(handle);
    cprag_close(handle);
    return result;
}

int printJsonResult(cprag_handle* handle, int rc, std::vector<char>& buffer)
{
    if (rc != CPRAG_OK) {
        return fail(rc, handle);
    }
    std::cout << buffer.data() << '\n';
    return 0;
}

int fileTypeFromString(const std::string& type)
{
    if (type == "rexx") {
        return CPRAG_CHUNK_CODE_REXX;
    }
    if (type == "markdown" || type == "md") {
        return CPRAG_CHUNK_MARKDOWN;
    }
    return CPRAG_CHUNK_PLAIN_TEXT;
}

bool readFile(const std::string& path, std::string* out)
{
    std::ifstream input(path, std::ios::binary);
    if (!input) {
        return false;
    }
    std::ostringstream buffer;
    buffer << input.rdbuf();
    *out = buffer.str();
    return true;
}

std::vector<float> parseFloatCsv(const std::string& text)
{
    std::vector<float> values;
    std::string current;
    std::istringstream stream(text);
    while (std::getline(stream, current, ',')) {
        const auto first = current.find_first_not_of(" \t\r\n");
        if (first == std::string::npos) {
            continue;
        }
        const auto last = current.find_last_not_of(" \t\r\n");
        std::string item = current.substr(first, last - first + 1);
        size_t consumed = 0;
        const float value = std::stof(item, &consumed);
        while (consumed < item.size() && std::isspace(static_cast<unsigned char>(item[consumed])) != 0) {
            ++consumed;
        }
        if (consumed != item.size()) {
            throw std::invalid_argument("invalid float value: " + item);
        }
        values.push_back(value);
    }
    if (values.empty()) {
        throw std::invalid_argument("vector must contain at least one float");
    }
    return values;
}

} // namespace

int main(int argc, char** argv)
{
    if (argc < 2) {
        usage();
        return 2;
    }

    const std::string command = argv[1];
    if (command == "vocabulary") {
        std::vector<char> buffer(kJsonBufferSize);
        const int rc = cprag_vocabulary(buffer.data(), buffer.size());
        if (rc != CPRAG_OK) {
            return fail(rc);
        }
        std::cout << buffer.data() << '\n';
        return 0;
    }

    if (argc < 3) {
        usage();
        return 2;
    }

    const std::string library = argv[2];

    if (command == "init") {
        const int rc = cprag_init_library(library.c_str());
        if (rc != CPRAG_OK) {
            return fail(rc);
        }
        std::cout << "initialized " << library << '\n';
        return 0;
    }

    if (command == "add-entity") {
        if (argc < 6) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            const char* metadata = argc >= 7 ? argv[6] : "{}";
            const int rc = cprag_add_entity(handle, argv[3], argv[4], argv[5], metadata);
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            std::cout << "entity added: " << argv[3] << '\n';
            return 0;
        });
    }

    if (command == "add-entity-typed") {
        if (argc < 7) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            const char* metadata = argc >= 8 ? argv[7] : "{}";
            const int rc = cprag_add_entity_typed(handle, argv[3], argv[4], argv[5], argv[6], metadata);
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            std::cout << "entity added: " << argv[3] << '\n';
            return 0;
        });
    }

    if (command == "add-edge") {
        if (argc < 6) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            const double weight = argc >= 7 ? std::atof(argv[6]) : 1.0;
            const char* metadata = argc >= 8 ? argv[7] : "{}";
            const int rc = cprag_add_edge(handle, argv[3], argv[4], argv[5], weight, metadata);
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            std::cout << "edge added: " << argv[3] << " -" << argv[5] << "-> " << argv[4] << '\n';
            return 0;
        });
    }

    if (command == "add-edge-typed") {
        if (argc < 8) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            const double weight = argc >= 9 ? std::atof(argv[8]) : 1.0;
            const char* metadata = argc >= 10 ? argv[9] : "{}";
            const int rc = cprag_add_edge_typed(handle, argv[3], argv[4], argv[5], argv[6], weight, metadata);
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            std::cout << "edge added: " << argv[3] << " -" << argv[5] << "-> " << argv[4] << '\n';
            return 0;
        });
    }

    if (command == "ingest-text") {
        if (argc < 9) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const char* metadata = argc >= 10 ? argv[9] : "{}";
            const int rc = cprag_ingest_text(
                handle,
                argv[3],
                argv[4],
                argv[8],
                fileTypeFromString(argv[5]),
                std::atoi(argv[6]),
                std::atoi(argv[7]),
                metadata,
                buffer.data(),
                buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "ingest-file") {
        if (argc < 7) {
            usage();
            return 2;
        }
        std::string text;
        if (!readFile(argv[3], &text)) {
            std::cerr << "failed to read file: " << argv[3] << '\n';
            return CPRAG_IO_ERROR;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const char* title = argc >= 8 ? argv[7] : argv[3];
            const char* metadata = argc >= 9 ? argv[8] : "{}";
            const int rc = cprag_ingest_text(
                handle,
                argv[3],
                title,
                text.c_str(),
                fileTypeFromString(argv[4]),
                std::atoi(argv[5]),
                std::atoi(argv[6]),
                metadata,
                buffer.data(),
                buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "list-sources") {
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int rc = cprag_list_sources(handle, buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "list-chunks") {
        if (argc < 4) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int rc = cprag_list_chunks(handle, argv[3], buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "delete-source") {
        if (argc < 4) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int rc = cprag_delete_source(handle, argv[3], buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "add-chunk-embedding") {
        if (argc < 6) {
            usage();
            return 2;
        }
        std::vector<float> vector;
        try {
            vector = parseFloatCsv(argv[5]);
        } catch (const std::exception& ex) {
            std::cerr << ex.what() << '\n';
            return CPRAG_INVALID_ARGUMENT;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            const long long chunkId = std::atoll(argv[3]);
            const int rc = cprag_add_chunk_embedding(handle, chunkId, argv[4], vector.data(), vector.size());
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            std::cout << "chunk embedding added: " << chunkId << '\n';
            return 0;
        });
    }

    if (command == "rebuild-vector-index") {
        if (argc < 4) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int rc = cprag_rebuild_vector_index(handle, argv[3], buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "vector-search") {
        if (argc < 5) {
            usage();
            return 2;
        }
        std::vector<float> vector;
        try {
            vector = parseFloatCsv(argv[4]);
        } catch (const std::exception& ex) {
            std::cerr << ex.what() << '\n';
            return CPRAG_INVALID_ARGUMENT;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int topK = argc >= 6 ? std::atoi(argv[5]) : 3;
            const int rc = cprag_vector_search(
                handle,
                argv[3],
                vector.data(),
                vector.size(),
                topK,
                buffer.data(),
                buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "vector-status") {
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int rc = cprag_vector_status(handle, buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "search") {
        if (argc < 4) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int topK = argc >= 5 ? std::atoi(argv[4]) : 3;
            const int hops = argc >= 6 ? std::atoi(argv[5]) : 2;
            const int rc = cprag_search(handle, argv[3], topK, hops, buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "expand") {
        if (argc < 4) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int hops = argc >= 5 ? std::atoi(argv[4]) : 2;
            const char* filter = argc >= 6 ? argv[5] : "";
            const int rc = cprag_expand(handle, argv[3], hops, filter, buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "shortest-path") {
        if (argc < 5) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const char* filter = argc >= 6 ? argv[5] : "";
            const int rc = cprag_shortest_path(handle, argv[3], argv[4], filter, buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "subgraph") {
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const char* nodeFilter = argc >= 4 ? argv[3] : "";
            const char* relationFilter = argc >= 5 ? argv[4] : "";
            const int limit = argc >= 6 ? std::atoi(argv[5]) : 100;
            const int rc = cprag_subgraph(handle, nodeFilter, relationFilter, limit, buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "stats") {
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int rc = cprag_stats(handle, buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "chunk") {
        if (argc < 6) {
            usage();
            return 2;
        }

        int fileType = CPRAG_CHUNK_PLAIN_TEXT;
        fileType = fileTypeFromString(library);

        std::vector<char> buffer(kJsonBufferSize);
        const int rc = cprag_chunk_text(
            argv[5],
            std::atoi(argv[3]),
            std::atoi(argv[4]),
            fileType,
            buffer.data(),
            buffer.size());
        if (rc != CPRAG_OK) {
            return fail(rc);
        }
        std::cout << buffer.data() << '\n';
        return 0;
    }

    usage();
    return 2;
}
