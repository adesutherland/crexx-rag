#include "crexx_rag/ragcore.h"

#include <cctype>
#include <cstdlib>
#include <iostream>
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
    std::string out;
    for (const char ch : value) {
        if (ch == '"' || ch == '\\') {
            out.push_back('\\');
        }
        if (ch == '\n') {
            out += "\\n";
        } else {
            out.push_back(ch);
        }
    }
    return out;
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

std::string jsonStringField(const std::string& line, const std::string& field, const std::string& fallback = "")
{
    const std::string key = "\"" + field + "\"";
    const size_t keyPos = line.find(key);
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
    const size_t end = line.find('"', quote + 1);
    if (end == std::string::npos) {
        return fallback;
    }
    return line.substr(quote + 1, end - quote - 1);
}

int jsonIntField(const std::string& line, const std::string& field, int fallback)
{
    const std::string key = "\"" + field + "\"";
    const size_t keyPos = line.find(key);
    if (keyPos == std::string::npos) {
        return fallback;
    }
    const size_t colon = line.find(':', keyPos + key.size());
    if (colon == std::string::npos) {
        return fallback;
    }
    return std::atoi(line.c_str() + colon + 1);
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
    return R"JSON({"tools":[{"name":"library_status","description":"Return local GraphRAG library statistics.","inputSchema":{"type":"object","properties":{}}},{"name":"library_search","description":"Search the local GraphRAG library and expand graph context.","inputSchema":{"type":"object","properties":{"query":{"type":"string"},"top_k":{"type":"integer"},"hops":{"type":"integer"}},"required":["query"]}},{"name":"library_add_entity","description":"Add or update one graph entity.","inputSchema":{"type":"object","properties":{"id":{"type":"string"},"label":{"type":"string"},"description":{"type":"string"},"metadata_json":{"type":"string"}},"required":["id","label","description"]}},{"name":"library_add_edge","description":"Add a relationship between two entities.","inputSchema":{"type":"object","properties":{"source_id":{"type":"string"},"target_id":{"type":"string"},"label":{"type":"string"},"weight":{"type":"number"},"metadata_json":{"type":"string"}},"required":["source_id","target_id","label"]}}]})JSON";
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

            if (name == "library_search") {
                const std::string query = jsonStringField(line, "query");
                const int topK = jsonIntField(line, "top_k", 3);
                const int hops = jsonIntField(line, "hops", 2);
                rc = cprag_search(handle, query.c_str(), topK, hops, buffer.data(), buffer.size());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult(buffer.data()));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_add_entity") {
                const std::string entityId = jsonStringField(line, "id");
                const std::string label = jsonStringField(line, "label");
                const std::string description = jsonStringField(line, "description");
                const std::string metadata = jsonStringField(line, "metadata_json", "{}");
                rc = cprag_add_entity(handle, entityId.c_str(), label.c_str(), description.c_str(), metadata.c_str());
                if (rc == CPRAG_OK) {
                    respond(id, textContentResult("{\"success\":true}"));
                } else {
                    respondError(id, -32000, cprag_last_error(handle));
                }
                continue;
            }

            if (name == "library_add_edge") {
                const std::string source = jsonStringField(line, "source_id");
                const std::string target = jsonStringField(line, "target_id");
                const std::string label = jsonStringField(line, "label");
                const std::string metadata = jsonStringField(line, "metadata_json", "{}");
                rc = cprag_add_edge(handle, source.c_str(), target.c_str(), label.c_str(), 1.0, metadata.c_str());
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
