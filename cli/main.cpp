#include "crexx_rag/ragcore.h"

#include <cerrno>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cctype>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
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
        << "  crexx-rag ingest-text <library> <source-uri> <title> <plain|rexx|markdown> <chunk-size> <overlap> <text> [metadata-json [source-type confidence [captured-at] [event-start-at] [event-end-at]]]\n"
        << "  crexx-rag ingest-file <library> <path> <plain|rexx|markdown> <chunk-size> <overlap> [title] [metadata-json [source-type confidence [captured-at] [event-start-at] [event-end-at]]]\n"
        << "  crexx-rag list-sources <library>\n"
        << "  crexx-rag timeline <library> [limit]\n"
        << "  crexx-rag list-chunks <library> <source-uri>\n"
        << "  crexx-rag delete-source <library> <source-uri>\n"
        << "  crexx-rag embedding-text <library> <chunk-id> [embedding-profile]\n"
        << "  crexx-rag add-chunk-embedding <library> <chunk-id> <embedding-model> <comma-separated-floats> [embedding-profile]\n"
        << "  crexx-rag embed-chunks <library> <embedding-model> <embedding-command> [source-uri] [embedding-profile]\n"
        << "  crexx-rag rebuild-vector-index <library> <embedding-model> [embedding-profile]\n"
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

std::string jsonString(const std::string& value)
{
    std::ostringstream out;
    out << '"';
    for (const unsigned char ch : value) {
        switch (ch) {
        case '"':
            out << "\\\"";
            break;
        case '\\':
            out << "\\\\";
            break;
        case '\b':
            out << "\\b";
            break;
        case '\f':
            out << "\\f";
            break;
        case '\n':
            out << "\\n";
            break;
        case '\r':
            out << "\\r";
            break;
        case '\t':
            out << "\\t";
            break;
        default:
            if (ch < 0x20) {
                out << "\\u" << std::hex << std::setw(4) << std::setfill('0') << static_cast<int>(ch)
                    << std::dec << std::setfill(' ');
            } else {
                out << static_cast<char>(ch);
            }
        }
    }
    out << '"';
    return out.str();
}

std::string shellQuote(const std::string& value)
{
    std::string quoted = "'";
    for (const char ch : value) {
        if (ch == '\'') {
            quoted += "'\\''";
        } else {
            quoted.push_back(ch);
        }
    }
    quoted.push_back('\'');
    return quoted;
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

size_t skipWhitespace(const std::string& text, size_t position)
{
    while (position < text.size() && std::isspace(static_cast<unsigned char>(text[position])) != 0) {
        ++position;
    }
    return position;
}

bool parseJsonNumberArrayAt(
    const std::string& text,
    size_t position,
    std::vector<float>* out,
    std::string* error)
{
    position = skipWhitespace(text, position);
    if (position >= text.size() || text[position] != '[') {
        *error = "embedding command output must contain a JSON number array";
        return false;
    }
    ++position;

    std::vector<float> values;
    while (true) {
        position = skipWhitespace(text, position);
        if (position >= text.size()) {
            *error = "unterminated embedding array";
            return false;
        }
        if (text[position] == ']') {
            ++position;
            break;
        }

        errno = 0;
        const char* begin = text.c_str() + position;
        char* end = nullptr;
        const float value = std::strtof(begin, &end);
        if (end == begin || errno == ERANGE || !std::isfinite(value)) {
            *error = "embedding values must be finite numbers";
            return false;
        }
        values.push_back(value);
        position = static_cast<size_t>(end - text.c_str());
        position = skipWhitespace(text, position);
        if (position >= text.size()) {
            *error = "unterminated embedding array";
            return false;
        }
        if (text[position] == ',') {
            ++position;
            continue;
        }
        if (text[position] == ']') {
            ++position;
            break;
        }
        *error = "embedding array values must be separated by commas";
        return false;
    }

    if (values.empty()) {
        *error = "embedding command returned an empty vector";
        return false;
    }
    *out = std::move(values);
    return true;
}

bool parseEmbeddingOutput(const std::string& output, std::vector<float>* out, std::string* error)
{
    const size_t first = skipWhitespace(output, 0);
    if (first < output.size() && output[first] == '[') {
        return parseJsonNumberArrayAt(output, first, out, error);
    }

    const size_t key = output.find("\"embedding\"");
    if (key == std::string::npos) {
        *error = "embedding command output must be a JSON array or an object with an embedding array";
        return false;
    }
    const size_t colon = output.find(':', key + 11);
    if (colon == std::string::npos) {
        *error = "embedding object is missing ':' after embedding key";
        return false;
    }
    return parseJsonNumberArrayAt(output, colon + 1, out, error);
}

bool runEmbeddingCommand(
    const std::string& command,
    const std::string& text,
    const std::string& embeddingModel,
    std::vector<float>* out,
    std::string* error)
{
    if (command.empty()) {
        *error = "embedding command is required";
        return false;
    }

    std::string shellCommand = command + " " + shellQuote(text);
    if (!embeddingModel.empty()) {
        shellCommand += " " + shellQuote(embeddingModel);
    }

    FILE* pipe = popen(shellCommand.c_str(), "r");
    if (pipe == nullptr) {
        *error = "failed to start embedding command";
        return false;
    }

    std::string output;
    char buffer[4096];
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        output += buffer;
        if (output.size() > kJsonBufferSize) {
            pclose(pipe);
            *error = "embedding command output is too large";
            return false;
        }
    }
    const int status = pclose(pipe);
    if (status != 0) {
        *error = "embedding command failed";
        return false;
    }
    return parseEmbeddingOutput(output, out, error);
}

struct ChunkForEmbedding {
    long long id {0};
    std::string sourceUri;
    std::string title;
    int chunkIndex {0};
};

int collectChunkForEmbedding(
    long long chunkId,
    const char* sourceUri,
    const char* title,
    int chunkIndex,
    const char* text,
    void* userData)
{
    (void)text;
    auto* chunks = static_cast<std::vector<ChunkForEmbedding>*>(userData);
    chunks->push_back(ChunkForEmbedding {
        chunkId,
        sourceUri == nullptr ? std::string() : std::string(sourceUri),
        title == nullptr ? std::string() : std::string(title),
        chunkIndex
    });
    return CPRAG_OK;
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
            const char* sourceType = argc >= 12 ? argv[10] : "unknown";
            const double confidence = argc >= 12 ? std::atof(argv[11]) : 1.0;
            const char* capturedAt = argc >= 13 ? argv[12] : "";
            const char* eventStartAt = argc >= 14 ? argv[13] : "";
            const char* eventEndAt = argc >= 15 ? argv[14] : "";
            const int rc = cprag_ingest_text_ex(
                handle,
                argv[3],
                argv[4],
                argv[8],
                fileTypeFromString(argv[5]),
                std::atoi(argv[6]),
                std::atoi(argv[7]),
                metadata,
                sourceType,
                confidence,
                capturedAt,
                eventStartAt,
                eventEndAt,
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
            const char* sourceType = argc >= 11 ? argv[9] : "unknown";
            const double confidence = argc >= 11 ? std::atof(argv[10]) : 1.0;
            const char* capturedAt = argc >= 12 ? argv[11] : "";
            const char* eventStartAt = argc >= 13 ? argv[12] : "";
            const char* eventEndAt = argc >= 14 ? argv[13] : "";
            const int rc = cprag_ingest_text_ex(
                handle,
                argv[3],
                title,
                text.c_str(),
                fileTypeFromString(argv[4]),
                std::atoi(argv[5]),
                std::atoi(argv[6]),
                metadata,
                sourceType,
                confidence,
                capturedAt,
                eventStartAt,
                eventEndAt,
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

    if (command == "timeline") {
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const int limit = argc >= 4 ? std::atoi(argv[3]) : 100;
            const int rc = cprag_timeline(handle, limit, buffer.data(), buffer.size());
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

    if (command == "embedding-text") {
        if (argc < 4) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const char* profile = argc >= 5 ? argv[4] : "semantic-context-v1";
            const int rc = cprag_build_chunk_embedding_text(
                handle,
                std::atoll(argv[3]),
                profile,
                buffer.data(),
                buffer.size());
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            std::cout << buffer.data() << '\n';
            return 0;
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
            const char* profile = argc >= 7 ? argv[6] : "raw-text-v1";
            const int rc = cprag_add_chunk_embedding_profile(
                handle,
                chunkId,
                argv[4],
                profile,
                vector.data(),
                vector.size());
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            std::cout << "chunk embedding added: " << chunkId << '\n';
            return 0;
        });
    }

    if (command == "embed-chunks") {
        if (argc < 5) {
            usage();
            return 2;
        }
        if (cprag_vector_index_available() == 0) {
            std::cerr << cprag_status_message(CPRAG_UNSUPPORTED)
                      << ": FAISS support is not enabled in this build\n";
            return CPRAG_UNSUPPORTED;
        }

        const std::string embeddingModel = argv[3];
        const std::string embeddingCommand = argv[4];
        const std::string sourceFilter = argc >= 6 ? argv[5] : "";
        const std::string embeddingProfile = argc >= 7 ? argv[6] : "semantic-context-v1";
        if (embeddingModel.empty()) {
            std::cerr << "embedding model is required\n";
            return CPRAG_INVALID_ARGUMENT;
        }

        return withLibrary(library, [&](cprag_handle* handle) -> int {
            std::vector<ChunkForEmbedding> chunks;
            int rc = cprag_each_chunk(
                handle,
                sourceFilter.empty() ? nullptr : sourceFilter.c_str(),
                collectChunkForEmbedding,
                &chunks);
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            if (chunks.empty()) {
                std::cerr << "no chunks matched";
                if (!sourceFilter.empty()) {
                    std::cerr << " source_uri: " << sourceFilter;
                }
                std::cerr << '\n';
                return CPRAG_NOT_FOUND;
            }

            size_t dimension = 0;
            size_t embedded = 0;
            for (const ChunkForEmbedding& chunk : chunks) {
                std::vector<char> textBuffer(kJsonBufferSize);
                rc = cprag_build_chunk_embedding_text(
                    handle,
                    chunk.id,
                    embeddingProfile.c_str(),
                    textBuffer.data(),
                    textBuffer.size());
                if (rc != CPRAG_OK) {
                    return fail(rc, handle);
                }

                std::vector<float> vector;
                std::string error;
                if (!runEmbeddingCommand(embeddingCommand, textBuffer.data(), embeddingModel, &vector, &error)) {
                    std::cerr << "failed to embed chunk " << chunk.id << " (" << chunk.sourceUri
                              << "#" << chunk.chunkIndex << "): " << error << '\n';
                    return CPRAG_IO_ERROR;
                }
                if (dimension == 0) {
                    dimension = vector.size();
                } else if (vector.size() != dimension) {
                    std::cerr << "embedding dimension changed at chunk " << chunk.id
                              << ": expected " << dimension << ", got " << vector.size() << '\n';
                    return CPRAG_INVALID_ARGUMENT;
                }

                rc = cprag_add_chunk_embedding_profile(
                    handle,
                    chunk.id,
                    embeddingModel.c_str(),
                    embeddingProfile.c_str(),
                    vector.data(),
                    vector.size());
                if (rc != CPRAG_OK) {
                    return fail(rc, handle);
                }
                ++embedded;
            }

            std::vector<char> buffer(kJsonBufferSize);
            rc = cprag_rebuild_vector_index_profile(
                handle,
                embeddingModel.c_str(),
                embeddingProfile.c_str(),
                buffer.data(),
                buffer.size());
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }

            std::cout << "{\"success\":true"
                      << ",\"embedding_model\":" << jsonString(embeddingModel)
                      << ",\"embedding_profile\":" << jsonString(embeddingProfile)
                      << ",\"source_uri\":";
            if (sourceFilter.empty()) {
                std::cout << "null";
            } else {
                std::cout << jsonString(sourceFilter);
            }
            std::cout << ",\"embedded\":" << embedded
                      << ",\"dimension\":" << dimension
                      << ",\"index\":" << buffer.data()
                      << "}\n";
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
            const char* profile = argc >= 5 ? argv[4] : "";
            const int rc = cprag_rebuild_vector_index_profile(handle, argv[3], profile, buffer.data(), buffer.size());
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
