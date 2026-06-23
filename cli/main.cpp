#include "crexx_rag/ragcore.h"

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <sstream>
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
        << "  crexx-rag add-edge <library> <source-id> <target-id> <label> [weight] [metadata-json]\n"
        << "  crexx-rag ingest-text <library> <source-uri> <title> <plain|rexx|markdown> <chunk-size> <overlap> <text> [metadata-json]\n"
        << "  crexx-rag ingest-file <library> <path> <plain|rexx|markdown> <chunk-size> <overlap> [title] [metadata-json]\n"
        << "  crexx-rag list-sources <library>\n"
        << "  crexx-rag search <library> <query> [top-k] [hops]\n"
        << "  crexx-rag expand <library> <anchor-csv> [hops] [relation-filter-csv]\n"
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

} // namespace

int main(int argc, char** argv)
{
    if (argc < 3) {
        usage();
        return 2;
    }

    const std::string command = argv[1];
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
