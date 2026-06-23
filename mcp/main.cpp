#include "crexx_rag/ragcore.h"

#include <cctype>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

namespace {

constexpr size_t kJsonBufferSize = 1024 * 1024;

std::string envOrDefault(const char* name, const char* fallback)
{
    const char* value = std::getenv(name);
    return value == nullptr || *value == '\0' ? std::string(fallback) : std::string(value);
}

std::string jsonEscape(const std::string& value)
{
    std::ostringstream out;
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
                out << "\\u" << std::hex << std::setw(4) << std::setfill('0') << static_cast<int>(ch);
            } else {
                out << ch;
            }
        }
    }
    return out.str();
}

std::string requestId(const std::string& line)
{
    const std::string key = "\"id\"";
    const size_t keyPos = line.find(key);
    if (keyPos == std::string::npos) {
        return "null";
    }
    const size_t colon = line.find(':', keyPos + key.size());
    if (colon == std::string::npos) {
        return "null";
    }
    size_t begin = colon + 1;
    while (begin < line.size() && std::isspace(static_cast<unsigned char>(line[begin])) != 0) {
        ++begin;
    }
    if (begin >= line.size()) {
        return "null";
    }
    if (line[begin] == '"') {
        const size_t end = line.find('"', begin + 1);
        if (end == std::string::npos) {
            return "null";
        }
        return line.substr(begin, end - begin + 1);
    }
    size_t end = begin;
    while (end < line.size() && line[end] != ',' && line[end] != '}') {
        ++end;
    }
    return line.substr(begin, end - begin);
}

bool decodeJsonStringAt(const std::string& line, size_t quote, std::string* out)
{
    if (quote >= line.size() || line[quote] != '"') {
        return false;
    }

    std::string value;
    for (size_t i = quote + 1; i < line.size(); ++i) {
        const char ch = line[i];
        if (ch == '"') {
            *out = value;
            return true;
        }
        if (ch != '\\' || i + 1 >= line.size()) {
            value.push_back(ch);
            continue;
        }

        const char escaped = line[++i];
        switch (escaped) {
        case '"':
        case '\\':
        case '/':
            value.push_back(escaped);
            break;
        case 'b':
            value.push_back('\b');
            break;
        case 'f':
            value.push_back('\f');
            break;
        case 'n':
            value.push_back('\n');
            break;
        case 'r':
            value.push_back('\r');
            break;
        case 't':
            value.push_back('\t');
            break;
        case 'u':
            if (i + 4 < line.size()) {
                i += 4;
                value.push_back('?');
            }
            break;
        default:
            value.push_back(escaped);
            break;
        }
    }
    return false;
}

size_t jsonArgumentsOffset(const std::string& line)
{
    const size_t keyPos = line.find("\"arguments\"");
    if (keyPos == std::string::npos) {
        return 0;
    }
    const size_t objectStart = line.find('{', keyPos);
    return objectStart == std::string::npos ? keyPos : objectStart;
}

std::string jsonStringFieldFrom(
    const std::string& line,
    size_t offset,
    const std::string& field,
    const std::string& fallback = "")
{
    const std::string key = "\"" + field + "\"";
    const size_t keyPos = line.find(key, offset);
    if (keyPos == std::string::npos) {
        return fallback;
    }
    const size_t colon = line.find(':', keyPos + key.size());
    if (colon == std::string::npos) {
        return fallback;
    }
    const size_t quote = line.find('"', colon + 1);
    if (quote == std::string::npos) {
        return fallback;
    }
    std::string value;
    if (!decodeJsonStringAt(line, quote, &value)) {
        return fallback;
    }
    return value;
}

std::string jsonStringField(const std::string& line, const std::string& field, const std::string& fallback = "")
{
    return jsonStringFieldFrom(line, 0, field, fallback);
}

int jsonIntFieldFrom(const std::string& line, size_t offset, const std::string& field, int fallback)
{
    const std::string key = "\"" + field + "\"";
    const size_t keyPos = line.find(key, offset);
    if (keyPos == std::string::npos) {
        return fallback;
    }
    const size_t colon = line.find(':', keyPos + key.size());
    if (colon == std::string::npos) {
        return fallback;
    }
    return std::atoi(line.c_str() + colon + 1);
}

int jsonIntField(const std::string& line, const std::string& field, int fallback)
{
    return jsonIntFieldFrom(line, 0, field, fallback);
}

double jsonDoubleFieldFrom(const std::string& line, size_t offset, const std::string& field, double fallback)
{
    const std::string key = "\"" + field + "\"";
    const size_t keyPos = line.find(key, offset);
    if (keyPos == std::string::npos) {
        return fallback;
    }
    const size_t colon = line.find(':', keyPos + key.size());
    if (colon == std::string::npos) {
        return fallback;
    }
    return std::atof(line.c_str() + colon + 1);
}

double jsonDoubleField(const std::string& line, const std::string& field, double fallback)
{
    return jsonDoubleFieldFrom(line, 0, field, fallback);
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

void respond(const std::string& id, const std::string& resultJson)
{
    std::cout << "{\"jsonrpc\":\"2.0\",\"id\":" << id << ",\"result\":" << resultJson << "}" << std::endl;
}

void respondError(const std::string& id, int code, const std::string& message)
{
    std::cout << "{\"jsonrpc\":\"2.0\",\"id\":" << id << ",\"error\":{\"code\":" << code
              << ",\"message\":\"" << jsonEscape(message) << "\"}}" << std::endl;
}

std::string toolListJson()
{
    return R"JSON({"tools":[{"name":"library_status","description":"Return local GraphRAG library statistics.","inputSchema":{"type":"object","properties":{}}},{"name":"library_vocabulary","description":"Return the initial architecture node and relationship vocabulary.","inputSchema":{"type":"object","properties":{}}},{"name":"library_search","description":"Search the local GraphRAG library and expand graph context.","inputSchema":{"type":"object","properties":{"query":{"type":"string"},"top_k":{"type":"integer"},"hops":{"type":"integer"}},"required":["query"]}},{"name":"library_shortest_path","description":"Find the shortest typed relationship path between two entities.","inputSchema":{"type":"object","properties":{"source_id":{"type":"string"},"target_id":{"type":"string"},"relationship_filter_csv":{"type":"string"}},"required":["source_id","target_id"]}},{"name":"library_subgraph","description":"Extract a typed subgraph by node and relationship filters.","inputSchema":{"type":"object","properties":{"node_type_filter_csv":{"type":"string"},"relationship_type_filter_csv":{"type":"string"},"limit":{"type":"integer"}}}},{"name":"library_ingest","description":"Ingest or update one text source into persistent document chunks.","inputSchema":{"type":"object","properties":{"source_uri":{"type":"string"},"title":{"type":"string"},"text":{"type":"string"},"file_type":{"type":"string","enum":["plain","rexx","markdown"]},"chunk_size":{"type":"integer"},"overlap":{"type":"integer"},"metadata_json":{"type":"string"}},"required":["source_uri","text"]}},{"name":"library_list_sources","description":"List ingested document sources.","inputSchema":{"type":"object","properties":{}}},{"name":"library_list_chunks","description":"List stored chunks for one source URI.","inputSchema":{"type":"object","properties":{"source_uri":{"type":"string"}},"required":["source_uri"]}},{"name":"library_delete_source","description":"Delete one ingested source and its chunks.","inputSchema":{"type":"object","properties":{"source_uri":{"type":"string"}},"required":["source_uri"]}},{"name":"library_add_entity","description":"Add or update one graph entity.","inputSchema":{"type":"object","properties":{"id":{"type":"string"},"label":{"type":"string"},"description":{"type":"string"},"metadata_json":{"type":"string"}},"required":["id","label","description"]}},{"name":"library_add_entity_typed","description":"Add or update one typed graph entity.","inputSchema":{"type":"object","properties":{"id":{"type":"string"},"node_type":{"type":"string"},"label":{"type":"string"},"description":{"type":"string"},"metadata_json":{"type":"string"}},"required":["id","node_type","label","description"]}},{"name":"library_add_edge","description":"Add a relationship between two entities.","inputSchema":{"type":"object","properties":{"source_id":{"type":"string"},"target_id":{"type":"string"},"label":{"type":"string"},"weight":{"type":"number"},"metadata_json":{"type":"string"}},"required":["source_id","target_id","label"]}},{"name":"library_add_edge_typed","description":"Add a typed relationship between two entities.","inputSchema":{"type":"object","properties":{"source_id":{"type":"string"},"target_id":{"type":"string"},"relationship_type":{"type":"string"},"label":{"type":"string"},"weight":{"type":"number"},"metadata_json":{"type":"string"}},"required":["source_id","target_id","relationship_type","label"]}}]})JSON";
}

std::string textContentResult(const std::string& text)
{
    return "{\"content\":[{\"type\":\"text\",\"text\":\"" + jsonEscape(text) + "\"}]}";
}

} // namespace

int main(int argc, char** argv)
{
    std::string libraryPath = envOrDefault("CPRAG_LIBRARY", "./library.cprag");
    for (int i = 1; i + 1 < argc; ++i) {
        if (std::string(argv[i]) == "--library") {
            libraryPath = argv[i + 1];
        }
    }

    cprag_handle* handle = nullptr;
    int rc = cprag_open(libraryPath.c_str(), CPRAG_OPEN_READWRITE, &handle);
    if (rc != CPRAG_OK) {
        std::cerr << "crexx-rag-mcp: failed to open library: " << cprag_status_message(rc) << '\n';
        return rc;
    }

    std::string line;
    while (std::getline(std::cin, line)) {
        const std::string id = requestId(line);

        if (line.find("\"method\":\"initialize\"") != std::string::npos || line.find("\"method\": \"initialize\"") != std::string::npos) {
            respond(id, R"JSON({"protocolVersion":"2025-06-18","serverInfo":{"name":"crexx-rag-mcp","version":"0.1.0"},"capabilities":{"tools":{}}})JSON");
            continue;
        }

        if (line.find("\"method\":\"tools/list\"") != std::string::npos || line.find("\"method\": \"tools/list\"") != std::string::npos) {
            respond(id, toolListJson());
            continue;
        }

        if (line.find("\"method\":\"tools/call\"") != std::string::npos || line.find("\"method\": \"tools/call\"") != std::string::npos) {
            const std::string name = jsonStringField(line, "name");
            const size_t argumentsOffset = jsonArgumentsOffset(line);
            std::vector<char> buffer(kJsonBufferSize);

            if (name == "library_status") {
                rc = cprag_stats(handle, buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_vocabulary") {
                rc = cprag_vocabulary(buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_status_message(rc));
                }
                continue;
            }

            if (name == "library_search") {
                const std::string query = jsonStringFieldFrom(line, argumentsOffset, "query");
                const int topK = jsonIntFieldFrom(line, argumentsOffset, "top_k", 3);
                const int hops = jsonIntFieldFrom(line, argumentsOffset, "hops", 2);
                rc = cprag_search(handle, query.c_str(), topK, hops, buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_shortest_path") {
                const std::string source = jsonStringFieldFrom(line, argumentsOffset, "source_id");
                const std::string target = jsonStringFieldFrom(line, argumentsOffset, "target_id");
                const std::string filter = jsonStringFieldFrom(line, argumentsOffset, "relationship_filter_csv", "");
                rc = cprag_shortest_path(handle, source.c_str(), target.c_str(), filter.c_str(), buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_subgraph") {
                const std::string nodeFilter = jsonStringFieldFrom(line, argumentsOffset, "node_type_filter_csv", "");
                const std::string relationshipFilter =
                    jsonStringFieldFrom(line, argumentsOffset, "relationship_type_filter_csv", "");
                const int limit = jsonIntFieldFrom(line, argumentsOffset, "limit", 100);
                rc = cprag_subgraph(handle, nodeFilter.c_str(), relationshipFilter.c_str(), limit, buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_ingest") {
                const std::string sourceUri = jsonStringFieldFrom(line, argumentsOffset, "source_uri");
                const std::string title = jsonStringFieldFrom(line, argumentsOffset, "title", sourceUri);
                const std::string text = jsonStringFieldFrom(line, argumentsOffset, "text");
                const std::string fileType = jsonStringFieldFrom(line, argumentsOffset, "file_type", "plain");
                const int chunkSize = jsonIntFieldFrom(line, argumentsOffset, "chunk_size", 1000);
                const int overlap = jsonIntFieldFrom(line, argumentsOffset, "overlap", 200);
                const std::string metadata = jsonStringFieldFrom(line, argumentsOffset, "metadata_json", "{}");
                rc = cprag_ingest_text(
                    handle,
                    sourceUri.c_str(),
                    title.c_str(),
                    text.c_str(),
                    fileTypeFromString(fileType),
                    chunkSize,
                    overlap,
                    metadata.c_str(),
                    buffer.data(),
                    buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_list_sources") {
                rc = cprag_list_sources(handle, buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_list_chunks") {
                const std::string sourceUri = jsonStringFieldFrom(line, argumentsOffset, "source_uri");
                rc = cprag_list_chunks(handle, sourceUri.c_str(), buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_delete_source") {
                const std::string sourceUri = jsonStringFieldFrom(line, argumentsOffset, "source_uri");
                rc = cprag_delete_source(handle, sourceUri.c_str(), buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_add_entity") {
                const std::string entityId = jsonStringFieldFrom(line, argumentsOffset, "id");
                const std::string label = jsonStringFieldFrom(line, argumentsOffset, "label");
                const std::string description = jsonStringFieldFrom(line, argumentsOffset, "description");
                const std::string metadata = jsonStringFieldFrom(line, argumentsOffset, "metadata_json", "{}");
                rc = cprag_add_entity(handle, entityId.c_str(), label.c_str(), description.c_str(), metadata.c_str());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult("{\"success\":true}"));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_add_entity_typed") {
                const std::string entityId = jsonStringFieldFrom(line, argumentsOffset, "id");
                const std::string nodeType = jsonStringFieldFrom(line, argumentsOffset, "node_type");
                const std::string label = jsonStringFieldFrom(line, argumentsOffset, "label");
                const std::string description = jsonStringFieldFrom(line, argumentsOffset, "description");
                const std::string metadata = jsonStringFieldFrom(line, argumentsOffset, "metadata_json", "{}");
                rc = cprag_add_entity_typed(
                    handle,
                    entityId.c_str(),
                    nodeType.c_str(),
                    label.c_str(),
                    description.c_str(),
                    metadata.c_str());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult("{\"success\":true}"));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_add_edge") {
                const std::string source = jsonStringFieldFrom(line, argumentsOffset, "source_id");
                const std::string target = jsonStringFieldFrom(line, argumentsOffset, "target_id");
                const std::string label = jsonStringFieldFrom(line, argumentsOffset, "label");
                const std::string metadata = jsonStringFieldFrom(line, argumentsOffset, "metadata_json", "{}");
                const double weight = jsonDoubleFieldFrom(line, argumentsOffset, "weight", 1.0);
                rc = cprag_add_edge(handle, source.c_str(), target.c_str(), label.c_str(), weight, metadata.c_str());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult("{\"success\":true}"));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_add_edge_typed") {
                const std::string source = jsonStringFieldFrom(line, argumentsOffset, "source_id");
                const std::string target = jsonStringFieldFrom(line, argumentsOffset, "target_id");
                const std::string relationshipType =
                    jsonStringFieldFrom(line, argumentsOffset, "relationship_type");
                const std::string label = jsonStringFieldFrom(line, argumentsOffset, "label");
                const std::string metadata = jsonStringFieldFrom(line, argumentsOffset, "metadata_json", "{}");
                const double weight = jsonDoubleFieldFrom(line, argumentsOffset, "weight", 1.0);
                rc = cprag_add_edge_typed(
                    handle,
                    source.c_str(),
                    target.c_str(),
                    relationshipType.c_str(),
                    label.c_str(),
                    weight,
                    metadata.c_str());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult("{\"success\":true}"));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            respondError(id, -32602, "unknown tool");
            continue;
        }

        if (line.find("\"method\":\"notifications/initialized\"") != std::string::npos
            || line.find("\"method\": \"notifications/initialized\"") != std::string::npos) {
            continue;
        }

        respondError(id, -32601, "method not found");
    }

    cprag_close(handle);
    return 0;
}
