#include "crexx_rag/ragcore.h"

#include <algorithm>
#include <cctype>
#include <cerrno>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <limits>
#include <map>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace {

constexpr size_t kJsonBufferSize = 1024 * 1024;
constexpr int kParseError = -32700;
constexpr int kInvalidRequest = -32600;
constexpr int kMethodNotFound = -32601;
constexpr int kInvalidParams = -32602;
constexpr int kCoreError = -32000;
constexpr int kWritesDisabled = -32001;

struct Json {
    enum class Type {
        Null,
        Bool,
        Number,
        String,
        Array,
        Object
    };

    Type type {Type::Null};
    bool boolean {false};
    double number {0.0};
    std::string text;
    std::vector<Json> array;
    std::map<std::string, Json> object;
};

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
                static constexpr char kHex[] = "0123456789abcdef";
                out << "\\u00" << kHex[(ch >> 4) & 0x0f] << kHex[ch & 0x0f];
            } else {
                out << ch;
            }
        }
    }
    return out.str();
}

std::string jsonString(const std::string& value)
{
    return "\"" + jsonEscape(value) + "\"";
}

void appendUtf8(std::string* out, unsigned codepoint)
{
    if (codepoint <= 0x7f) {
        out->push_back(static_cast<char>(codepoint));
    } else if (codepoint <= 0x7ff) {
        out->push_back(static_cast<char>(0xc0u | (codepoint >> 6u)));
        out->push_back(static_cast<char>(0x80u | (codepoint & 0x3fu)));
    } else if (codepoint <= 0xffff) {
        out->push_back(static_cast<char>(0xe0u | (codepoint >> 12u)));
        out->push_back(static_cast<char>(0x80u | ((codepoint >> 6u) & 0x3fu)));
        out->push_back(static_cast<char>(0x80u | (codepoint & 0x3fu)));
    } else if (codepoint <= 0x10ffff) {
        out->push_back(static_cast<char>(0xf0u | (codepoint >> 18u)));
        out->push_back(static_cast<char>(0x80u | ((codepoint >> 12u) & 0x3fu)));
        out->push_back(static_cast<char>(0x80u | ((codepoint >> 6u) & 0x3fu)));
        out->push_back(static_cast<char>(0x80u | (codepoint & 0x3fu)));
    } else {
        throw std::runtime_error("invalid unicode escape");
    }
}

class JsonParser {
public:
    explicit JsonParser(const std::string& input)
        : input_(input)
    {
    }

    Json parse()
    {
        skipWhitespace();
        Json value = parseValue();
        skipWhitespace();
        if (pos_ != input_.size()) {
            fail("unexpected trailing content");
        }
        return value;
    }

private:
    const std::string& input_;
    size_t pos_ {0};

    [[noreturn]] void fail(const std::string& message) const
    {
        throw std::runtime_error(message);
    }

    char peek() const
    {
        return pos_ < input_.size() ? input_[pos_] : '\0';
    }

    char get()
    {
        if (pos_ >= input_.size()) {
            fail("unexpected end of JSON");
        }
        return input_[pos_++];
    }

    void skipWhitespace()
    {
        while (pos_ < input_.size() && std::isspace(static_cast<unsigned char>(input_[pos_])) != 0) {
            ++pos_;
        }
    }

    bool consume(char expected)
    {
        if (peek() != expected) {
            return false;
        }
        ++pos_;
        return true;
    }

    void expect(char expected)
    {
        if (!consume(expected)) {
            std::string message = "expected '";
            message.push_back(expected);
            message.push_back('\'');
            fail(message);
        }
    }

    bool consumeLiteral(const char* literal)
    {
        const size_t length = std::strlen(literal);
        if (input_.compare(pos_, length, literal) != 0) {
            return false;
        }
        pos_ += length;
        return true;
    }

    Json parseValue()
    {
        skipWhitespace();
        const char ch = peek();
        if (ch == '{') {
            return parseObject();
        }
        if (ch == '[') {
            return parseArray();
        }
        if (ch == '"') {
            Json value;
            value.type = Json::Type::String;
            value.text = parseString();
            return value;
        }
        if (ch == '-' || std::isdigit(static_cast<unsigned char>(ch)) != 0) {
            return parseNumber();
        }
        if (consumeLiteral("true")) {
            Json value;
            value.type = Json::Type::Bool;
            value.boolean = true;
            return value;
        }
        if (consumeLiteral("false")) {
            Json value;
            value.type = Json::Type::Bool;
            value.boolean = false;
            return value;
        }
        if (consumeLiteral("null")) {
            return Json {};
        }
        fail("expected JSON value");
    }

    Json parseObject()
    {
        Json value;
        value.type = Json::Type::Object;
        expect('{');
        skipWhitespace();
        if (consume('}')) {
            return value;
        }

        while (true) {
            skipWhitespace();
            if (peek() != '"') {
                fail("expected object key");
            }
            std::string key = parseString();
            skipWhitespace();
            expect(':');
            skipWhitespace();
            Json child = parseValue();
            if (value.object.find(key) != value.object.end()) {
                fail("duplicate object key: " + key);
            }
            value.object.emplace(std::move(key), std::move(child));
            skipWhitespace();
            if (consume('}')) {
                return value;
            }
            expect(',');
        }
    }

    Json parseArray()
    {
        Json value;
        value.type = Json::Type::Array;
        expect('[');
        skipWhitespace();
        if (consume(']')) {
            return value;
        }

        while (true) {
            value.array.push_back(parseValue());
            skipWhitespace();
            if (consume(']')) {
                return value;
            }
            expect(',');
        }
    }

    unsigned parseHex4()
    {
        if (pos_ + 4 > input_.size()) {
            fail("truncated unicode escape");
        }
        unsigned value = 0;
        for (int i = 0; i < 4; ++i) {
            const char ch = input_[pos_++];
            value <<= 4u;
            if (ch >= '0' && ch <= '9') {
                value |= static_cast<unsigned>(ch - '0');
            } else if (ch >= 'a' && ch <= 'f') {
                value |= static_cast<unsigned>(ch - 'a' + 10);
            } else if (ch >= 'A' && ch <= 'F') {
                value |= static_cast<unsigned>(ch - 'A' + 10);
            } else {
                fail("invalid unicode escape");
            }
        }
        return value;
    }

    std::string parseString()
    {
        expect('"');
        std::string out;
        while (true) {
            const char ch = get();
            if (ch == '"') {
                return out;
            }
            if (static_cast<unsigned char>(ch) < 0x20) {
                fail("control character in string");
            }
            if (ch != '\\') {
                out.push_back(ch);
                continue;
            }

            const char escaped = get();
            switch (escaped) {
            case '"':
            case '\\':
            case '/':
                out.push_back(escaped);
                break;
            case 'b':
                out.push_back('\b');
                break;
            case 'f':
                out.push_back('\f');
                break;
            case 'n':
                out.push_back('\n');
                break;
            case 'r':
                out.push_back('\r');
                break;
            case 't':
                out.push_back('\t');
                break;
            case 'u': {
                unsigned codepoint = parseHex4();
                if (codepoint >= 0xd800 && codepoint <= 0xdbff) {
                    if (get() != '\\' || get() != 'u') {
                        fail("missing low surrogate");
                    }
                    const unsigned low = parseHex4();
                    if (low < 0xdc00 || low > 0xdfff) {
                        fail("invalid low surrogate");
                    }
                    codepoint = 0x10000 + (((codepoint - 0xd800) << 10u) | (low - 0xdc00));
                } else if (codepoint >= 0xdc00 && codepoint <= 0xdfff) {
                    fail("unexpected low surrogate");
                }
                appendUtf8(&out, codepoint);
                break;
            }
            default:
                fail("invalid string escape");
            }
        }
    }

    Json parseNumber()
    {
        const size_t begin = pos_;
        if (consume('-') && !std::isdigit(static_cast<unsigned char>(peek()))) {
            fail("invalid number");
        }

        if (consume('0')) {
            if (std::isdigit(static_cast<unsigned char>(peek())) != 0) {
                fail("leading zero in number");
            }
        } else {
            if (peek() < '1' || peek() > '9') {
                fail("invalid number");
            }
            while (std::isdigit(static_cast<unsigned char>(peek())) != 0) {
                ++pos_;
            }
        }

        if (consume('.')) {
            if (std::isdigit(static_cast<unsigned char>(peek())) == 0) {
                fail("invalid fractional number");
            }
            while (std::isdigit(static_cast<unsigned char>(peek())) != 0) {
                ++pos_;
            }
        }

        if (peek() == 'e' || peek() == 'E') {
            ++pos_;
            if (peek() == '+' || peek() == '-') {
                ++pos_;
            }
            if (std::isdigit(static_cast<unsigned char>(peek())) == 0) {
                fail("invalid exponent");
            }
            while (std::isdigit(static_cast<unsigned char>(peek())) != 0) {
                ++pos_;
            }
        }

        Json value;
        value.type = Json::Type::Number;
        value.text = input_.substr(begin, pos_ - begin);
        char* end = nullptr;
        errno = 0;
        value.number = std::strtod(value.text.c_str(), &end);
        if (errno == ERANGE || end == value.text.c_str() || *end != '\0') {
            fail("invalid number");
        }
        return value;
    }
};

std::string renderJson(const Json& value)
{
    switch (value.type) {
    case Json::Type::Null:
        return "null";
    case Json::Type::Bool:
        return value.boolean ? "true" : "false";
    case Json::Type::Number:
        return value.text;
    case Json::Type::String:
        return jsonString(value.text);
    case Json::Type::Array: {
        std::ostringstream out;
        out << '[';
        for (size_t i = 0; i < value.array.size(); ++i) {
            if (i > 0) {
                out << ',';
            }
            out << renderJson(value.array[i]);
        }
        out << ']';
        return out.str();
    }
    case Json::Type::Object: {
        std::ostringstream out;
        out << '{';
        bool first = true;
        for (const auto& entry : value.object) {
            if (!first) {
                out << ',';
            }
            first = false;
            out << jsonString(entry.first) << ':' << renderJson(entry.second);
        }
        out << '}';
        return out.str();
    }
    }
    return "null";
}

const Json* member(const Json& object, const std::string& name)
{
    if (object.type != Json::Type::Object) {
        return nullptr;
    }
    const auto it = object.object.find(name);
    return it == object.object.end() ? nullptr : &it->second;
}

bool isValidId(const Json& id)
{
    return id.type == Json::Type::Null || id.type == Json::Type::String || id.type == Json::Type::Number;
}

bool requireString(const Json& args, const std::string& name, std::string* out, std::string* error)
{
    const Json* value = member(args, name);
    if (value == nullptr) {
        *error = "missing required string argument: " + name;
        return false;
    }
    if (value->type != Json::Type::String) {
        *error = "argument must be a string: " + name;
        return false;
    }
    *out = value->text;
    return true;
}

bool optionalString(
    const Json& args,
    const std::string& name,
    const std::string& fallback,
    std::string* out,
    std::string* error)
{
    const Json* value = member(args, name);
    if (value == nullptr) {
        *out = fallback;
        return true;
    }
    if (value->type != Json::Type::String) {
        *error = "argument must be a string: " + name;
        return false;
    }
    *out = value->text;
    return true;
}

bool jsonIntegerToInt(const Json& value, int* out)
{
    if (value.type != Json::Type::Number) {
        return false;
    }
    if (value.text.find_first_of(".eE") != std::string::npos) {
        return false;
    }
    char* end = nullptr;
    errno = 0;
    const long parsed = std::strtol(value.text.c_str(), &end, 10);
    if (errno == ERANGE || end == value.text.c_str() || *end != '\0') {
        return false;
    }
    if (parsed < std::numeric_limits<int>::min() || parsed > std::numeric_limits<int>::max()) {
        return false;
    }
    *out = static_cast<int>(parsed);
    return true;
}

bool optionalInt(
    const Json& args,
    const std::string& name,
    int fallback,
    int minValue,
    int* out,
    std::string* error)
{
    const Json* value = member(args, name);
    if (value == nullptr) {
        *out = fallback;
        return true;
    }
    if (!jsonIntegerToInt(*value, out)) {
        *error = "argument must be an integer: " + name;
        return false;
    }
    if (*out < minValue) {
        *error = "argument is below minimum: " + name;
        return false;
    }
    return true;
}

bool optionalDouble(
    const Json& args,
    const std::string& name,
    double fallback,
    double minValue,
    double* out,
    std::string* error)
{
    const Json* value = member(args, name);
    if (value == nullptr) {
        *out = fallback;
        return true;
    }
    if (value->type != Json::Type::Number) {
        *error = "argument must be a number: " + name;
        return false;
    }
    *out = value->number;
    if (*out < minValue) {
        *error = "argument is below minimum: " + name;
        return false;
    }
    return true;
}

int fileTypeFromString(const std::string& type, std::string* error)
{
    if (type == "plain") {
        return CPRAG_CHUNK_PLAIN_TEXT;
    }
    if (type == "rexx") {
        return CPRAG_CHUNK_CODE_REXX;
    }
    if (type == "markdown" || type == "md") {
        return CPRAG_CHUNK_MARKDOWN;
    }
    *error = "file_type must be one of plain, rexx, markdown, or md";
    return CPRAG_CHUNK_PLAIN_TEXT;
}

int searchModeFromString(const std::string& mode, std::string* error)
{
    if (mode == "auto") {
        return CPRAG_SEARCH_AUTO;
    }
    if (mode == "lexical") {
        return CPRAG_SEARCH_LEXICAL;
    }
    if (mode == "vector") {
        return CPRAG_SEARCH_VECTOR;
    }
    if (mode == "hybrid") {
        return CPRAG_SEARCH_HYBRID;
    }
    *error = "mode must be one of auto, lexical, vector, or hybrid";
    return CPRAG_SEARCH_AUTO;
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

bool parseFloatArray(const Json& value, std::vector<float>* out, std::string* error)
{
    if (value.type != Json::Type::Array) {
        *error = "embedding command output must be a JSON number array";
        return false;
    }
    std::vector<float> parsed;
    parsed.reserve(value.array.size());
    for (const Json& item : value.array) {
        if (item.type != Json::Type::Number || !std::isfinite(item.number)) {
            *error = "embedding values must be finite numbers";
            return false;
        }
        parsed.push_back(static_cast<float>(item.number));
    }
    if (parsed.empty()) {
        *error = "embedding command returned an empty vector";
        return false;
    }
    *out = std::move(parsed);
    return true;
}

bool parseEmbeddingOutput(const std::string& output, std::vector<float>* out, std::string* error)
{
    Json root;
    try {
        root = JsonParser(output).parse();
    } catch (const std::exception& ex) {
        *error = std::string("embedding command did not return valid JSON: ") + ex.what();
        return false;
    }

    if (root.type == Json::Type::Array) {
        return parseFloatArray(root, out, error);
    }
    const Json* embedding = member(root, "embedding");
    if (embedding != nullptr) {
        return parseFloatArray(*embedding, out, error);
    }
    *error = "embedding command output must be a JSON array or an object with an embedding array";
    return false;
}

bool runEmbeddingCommand(
    const std::string& command,
    const std::string& query,
    const std::string& embeddingModel,
    std::vector<float>* out,
    std::string* error)
{
    if (command.empty()) {
        *error = "embedding command is not configured";
        return false;
    }

    std::string shellCommand = command + " " + shellQuote(query);
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

void respond(const std::string& idJson, const std::string& resultJson)
{
    std::cout << "{\"jsonrpc\":\"2.0\",\"id\":" << idJson << ",\"result\":" << resultJson << "}" << std::endl;
}

void respondError(const std::string& idJson, int code, const std::string& message)
{
    std::cout << "{\"jsonrpc\":\"2.0\",\"id\":" << idJson << ",\"error\":{\"code\":" << code
              << ",\"message\":" << jsonString(message) << "}}" << std::endl;
}

std::string textContentResult(const std::string& text)
{
    return "{\"content\":[{\"type\":\"text\",\"text\":" + jsonString(text) + "}]}";
}

struct ToolSpec {
    const char* name;
    const char* description;
    const char* inputSchema;
    bool mutating;
};

const std::vector<ToolSpec>& toolSpecs()
{
    static const std::vector<ToolSpec> specs {
        {"library_status",
            "Return local GraphRAG library statistics.",
            R"JSON({"type":"object","properties":{}})JSON",
            false},
        {"library_vocabulary",
            "Return the initial architecture node and relationship vocabulary.",
            R"JSON({"type":"object","properties":{}})JSON",
            false},
        {"library_vector_status",
            "Return FAISS/vector index readiness and active embedding metadata.",
            R"JSON({"type":"object","properties":{}})JSON",
            false},
        {"library_search",
            "Search the local GraphRAG library and expand graph context. mode defaults to auto.",
            R"JSON({"type":"object","properties":{"query":{"type":"string"},"top_k":{"type":"integer","minimum":0},"hops":{"type":"integer","minimum":0},"mode":{"type":"string","enum":["auto","lexical","vector","hybrid"]},"embedding_model":{"type":"string"}},"required":["query"]})JSON",
            false},
        {"library_shortest_path",
            "Find the shortest typed relationship path between two entities.",
            R"JSON({"type":"object","properties":{"source_id":{"type":"string"},"target_id":{"type":"string"},"relationship_filter_csv":{"type":"string"}},"required":["source_id","target_id"]})JSON",
            false},
        {"library_subgraph",
            "Extract a typed subgraph by node and relationship filters.",
            R"JSON({"type":"object","properties":{"node_type_filter_csv":{"type":"string"},"relationship_type_filter_csv":{"type":"string"},"limit":{"type":"integer","minimum":0}}})JSON",
            false},
        {"library_list_sources",
            "List ingested document sources.",
            R"JSON({"type":"object","properties":{}})JSON",
            false},
        {"library_list_chunks",
            "List stored chunks for one source URI.",
            R"JSON({"type":"object","properties":{"source_uri":{"type":"string"}},"required":["source_uri"]})JSON",
            false},
        {"library_ingest",
            "Ingest or update one text source into persistent document chunks.",
            R"JSON({"type":"object","properties":{"source_uri":{"type":"string"},"title":{"type":"string"},"text":{"type":"string"},"file_type":{"type":"string","enum":["plain","rexx","markdown","md"]},"chunk_size":{"type":"integer","minimum":1},"overlap":{"type":"integer","minimum":0},"metadata_json":{"type":"string"}},"required":["source_uri","text"]})JSON",
            true},
        {"library_delete_source",
            "Delete one ingested source and its chunks.",
            R"JSON({"type":"object","properties":{"source_uri":{"type":"string"}},"required":["source_uri"]})JSON",
            true},
        {"library_add_entity",
            "Add or update one graph entity.",
            R"JSON({"type":"object","properties":{"id":{"type":"string"},"label":{"type":"string"},"description":{"type":"string"},"metadata_json":{"type":"string"}},"required":["id","label","description"]})JSON",
            true},
        {"library_add_entity_typed",
            "Add or update one typed graph entity.",
            R"JSON({"type":"object","properties":{"id":{"type":"string"},"node_type":{"type":"string"},"label":{"type":"string"},"description":{"type":"string"},"metadata_json":{"type":"string"}},"required":["id","node_type","label","description"]})JSON",
            true},
        {"library_add_edge",
            "Add a relationship between two entities.",
            R"JSON({"type":"object","properties":{"source_id":{"type":"string"},"target_id":{"type":"string"},"label":{"type":"string"},"weight":{"type":"number","minimum":0},"metadata_json":{"type":"string"}},"required":["source_id","target_id","label"]})JSON",
            true},
        {"library_add_edge_typed",
            "Add a typed relationship between two entities.",
            R"JSON({"type":"object","properties":{"source_id":{"type":"string"},"target_id":{"type":"string"},"relationship_type":{"type":"string"},"label":{"type":"string"},"weight":{"type":"number","minimum":0},"metadata_json":{"type":"string"}},"required":["source_id","target_id","relationship_type","label"]})JSON",
            true},
    };
    return specs;
}

const ToolSpec* findTool(const std::string& name)
{
    for (const ToolSpec& spec : toolSpecs()) {
        if (name == spec.name) {
            return &spec;
        }
    }
    return nullptr;
}

std::string toolListJson(bool allowWrites)
{
    std::ostringstream out;
    out << "{\"tools\":[";
    bool first = true;
    for (const ToolSpec& spec : toolSpecs()) {
        if (spec.mutating && !allowWrites) {
            continue;
        }
        if (!first) {
            out << ',';
        }
        first = false;
        out << "{\"name\":" << jsonString(spec.name)
            << ",\"description\":" << jsonString(spec.description)
            << ",\"inputSchema\":" << spec.inputSchema << '}';
    }
    out << "]}";
    return out.str();
}

std::string envOrDefault(const char* name, const char* fallback)
{
    const char* value = std::getenv(name);
    return value == nullptr || *value == '\0' ? std::string(fallback) : std::string(value);
}

bool envFlag(const char* name)
{
    const char* value = std::getenv(name);
    if (value == nullptr) {
        return false;
    }
    std::string flag(value);
    std::transform(flag.begin(), flag.end(), flag.begin(), [](unsigned char ch) {
        return static_cast<char>(std::tolower(ch));
    });
    return flag == "1" || flag == "true" || flag == "yes" || flag == "on";
}

bool ensureHandle(
    cprag_handle** handle,
    const std::string& libraryPath,
    bool allowWrites,
    std::string* error)
{
    if (*handle != nullptr) {
        return true;
    }
    const unsigned flags = allowWrites ? CPRAG_OPEN_READWRITE : CPRAG_OPEN_READONLY;
    const int rc = cprag_open(libraryPath.c_str(), flags, handle);
    if (rc != CPRAG_OK) {
        *error = cprag_status_message(rc);
        return false;
    }
    return true;
}

bool coreJsonResult(
    const std::string& idJson,
    cprag_handle* handle,
    int rc,
    const std::vector<char>& buffer)
{
    if (rc == CPRAG_OK) {
        respond(idJson, textContentResult(buffer.data()));
        return true;
    }
    respondError(idJson, kCoreError, cprag_last_error(handle));
    return false;
}

Json emptyObject()
{
    Json value;
    value.type = Json::Type::Object;
    return value;
}

const Json* toolArguments(const Json& params, std::string* error)
{
    const Json* arguments = member(params, "arguments");
    if (arguments == nullptr) {
        static const Json empty = emptyObject();
        return &empty;
    }
    if (arguments->type != Json::Type::Object) {
        *error = "params.arguments must be an object";
        return nullptr;
    }
    return arguments;
}

bool requireHandleForTool(
    const std::string& idJson,
    cprag_handle** handle,
    const std::string& libraryPath,
    bool allowWrites)
{
    std::string error;
    if (ensureHandle(handle, libraryPath, allowWrites, &error)) {
        return true;
    }
    respondError(idJson, kCoreError, "failed to open library: " + error);
    return false;
}

struct Config {
    std::string libraryPath {envOrDefault("CPRAG_LIBRARY", "./library.cprag")};
    bool allowWrites {envFlag("CPRAG_MCP_ALLOW_WRITES")};
    std::string embeddingCommand {envOrDefault("CPRAG_EMBEDDING_COMMAND", "")};
    std::string embeddingModel {envOrDefault("CPRAG_EMBEDDING_MODEL", "")};
};

bool vectorIndexReady(cprag_handle* handle, std::string* activeModel, int* activeDimension)
{
    std::vector<char> buffer(kJsonBufferSize);
    if (cprag_vector_status(handle, buffer.data(), buffer.size()) != CPRAG_OK) {
        return false;
    }

    Json root;
    try {
        root = JsonParser(buffer.data()).parse();
    } catch (const std::exception&) {
        return false;
    }

    const Json* enabled = member(root, "enabled");
    const Json* active = member(root, "active_index");
    if (enabled == nullptr || enabled->type != Json::Type::Bool || !enabled->boolean
        || active == nullptr || active->type != Json::Type::Object) {
        return false;
    }

    const Json* model = member(*active, "embedding_model");
    const Json* dimension = member(*active, "dimension");
    int parsedDimension = 0;
    if (model == nullptr || model->type != Json::Type::String
        || dimension == nullptr || !jsonIntegerToInt(*dimension, &parsedDimension)) {
        return false;
    }
    *activeModel = model->text;
    *activeDimension = parsedDimension;
    return true;
}

void handleToolCall(
    const std::string& idJson,
    const Json& params,
    cprag_handle** handle,
    const Config& config)
{
    std::string error;
    std::string name;
    if (!requireString(params, "name", &name, &error)) {
        respondError(idJson, kInvalidParams, error);
        return;
    }

    const ToolSpec* spec = findTool(name);
    if (spec == nullptr) {
        respondError(idJson, kInvalidParams, "unknown tool: " + name);
        return;
    }
    if (spec->mutating && !config.allowWrites) {
        respondError(idJson, kWritesDisabled, "write tools are disabled; restart with --allow-writes to enable mutations");
        return;
    }

    const Json* args = toolArguments(params, &error);
    if (args == nullptr) {
        respondError(idJson, kInvalidParams, error);
        return;
    }

    std::vector<char> buffer(kJsonBufferSize);
    int rc = CPRAG_OK;

    if (name == "library_vocabulary") {
        rc = cprag_vocabulary(buffer.data(), buffer.size());
        if (rc == CPRAG_OK) {
            respond(idJson, textContentResult(buffer.data()));
        } else {
            respondError(idJson, kCoreError, cprag_status_message(rc));
        }
        return;
    }

    if (!requireHandleForTool(idJson, handle, config.libraryPath, config.allowWrites)) {
        return;
    }

    if (name == "library_status") {
        rc = cprag_stats(*handle, buffer.data(), buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_vector_status") {
        rc = cprag_vector_status(*handle, buffer.data(), buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_search") {
        std::string query;
        std::string modeText;
        std::string requestedModel;
        int topK = 3;
        int hops = 2;
        if (!requireString(*args, "query", &query, &error)
            || !optionalInt(*args, "top_k", 3, 0, &topK, &error)
            || !optionalInt(*args, "hops", 2, 0, &hops, &error)
            || !optionalString(*args, "mode", "auto", &modeText, &error)
            || !optionalString(*args, "embedding_model", config.embeddingModel, &requestedModel, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        const int mode = searchModeFromString(modeText, &error);
        if (!error.empty()) {
            respondError(idJson, kInvalidParams, error);
            return;
        }

        std::vector<float> queryVector;
        const float* queryVectorData = nullptr;
        size_t queryVectorDimension = 0;
        std::string activeModel;
        int activeDimension = 0;
        const bool vectorReady = vectorIndexReady(*handle, &activeModel, &activeDimension);
        const std::string effectiveModel = requestedModel.empty() ? activeModel : requestedModel;
        const bool vectorRequested = mode == CPRAG_SEARCH_VECTOR || mode == CPRAG_SEARCH_HYBRID;
        const bool shouldEmbed = vectorRequested || (mode == CPRAG_SEARCH_AUTO && vectorReady && !config.embeddingCommand.empty());

        if (vectorRequested && config.embeddingCommand.empty()) {
            respondError(idJson, kInvalidParams, "embedding command is not configured; use mode=lexical or configure --embedding-command");
            return;
        }
        if (vectorRequested && !vectorReady) {
            respondError(idJson, kCoreError, "active vector index is not available");
            return;
        }
        if (shouldEmbed) {
            if (!runEmbeddingCommand(config.embeddingCommand, query, effectiveModel, &queryVector, &error)) {
                respondError(idJson, kCoreError, error);
                return;
            }
            queryVectorData = queryVector.data();
            queryVectorDimension = queryVector.size();
        }

        rc = cprag_search_with_vector(
            *handle,
            query.c_str(),
            topK,
            hops,
            mode,
            effectiveModel.c_str(),
            queryVectorData,
            queryVectorDimension,
            buffer.data(),
            buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_shortest_path") {
        std::string source;
        std::string target;
        std::string filter;
        if (!requireString(*args, "source_id", &source, &error)
            || !requireString(*args, "target_id", &target, &error)
            || !optionalString(*args, "relationship_filter_csv", "", &filter, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_shortest_path(*handle, source.c_str(), target.c_str(), filter.c_str(), buffer.data(), buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_subgraph") {
        std::string nodeFilter;
        std::string relationshipFilter;
        int limit = 100;
        if (!optionalString(*args, "node_type_filter_csv", "", &nodeFilter, &error)
            || !optionalString(*args, "relationship_type_filter_csv", "", &relationshipFilter, &error)
            || !optionalInt(*args, "limit", 100, 0, &limit, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_subgraph(*handle, nodeFilter.c_str(), relationshipFilter.c_str(), limit, buffer.data(), buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_list_sources") {
        rc = cprag_list_sources(*handle, buffer.data(), buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_list_chunks") {
        std::string sourceUri;
        if (!requireString(*args, "source_uri", &sourceUri, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_list_chunks(*handle, sourceUri.c_str(), buffer.data(), buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_ingest") {
        std::string sourceUri;
        std::string title;
        std::string text;
        std::string fileType;
        std::string metadata;
        int chunkSize = 1000;
        int overlap = 200;
        if (!requireString(*args, "source_uri", &sourceUri, &error)
            || !optionalString(*args, "title", sourceUri, &title, &error)
            || !requireString(*args, "text", &text, &error)
            || !optionalString(*args, "file_type", "plain", &fileType, &error)
            || !optionalInt(*args, "chunk_size", 1000, 1, &chunkSize, &error)
            || !optionalInt(*args, "overlap", 200, 0, &overlap, &error)
            || !optionalString(*args, "metadata_json", "{}", &metadata, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        const int chunkType = fileTypeFromString(fileType, &error);
        if (!error.empty()) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_ingest_text(
            *handle,
            sourceUri.c_str(),
            title.c_str(),
            text.c_str(),
            chunkType,
            chunkSize,
            overlap,
            metadata.c_str(),
            buffer.data(),
            buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_delete_source") {
        std::string sourceUri;
        if (!requireString(*args, "source_uri", &sourceUri, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_delete_source(*handle, sourceUri.c_str(), buffer.data(), buffer.size());
        coreJsonResult(idJson, *handle, rc, buffer);
        return;
    }

    if (name == "library_add_entity") {
        std::string entityId;
        std::string label;
        std::string description;
        std::string metadata;
        if (!requireString(*args, "id", &entityId, &error)
            || !requireString(*args, "label", &label, &error)
            || !requireString(*args, "description", &description, &error)
            || !optionalString(*args, "metadata_json", "{}", &metadata, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_add_entity(*handle, entityId.c_str(), label.c_str(), description.c_str(), metadata.c_str());
        if (rc == CPRAG_OK) {
            respond(idJson, textContentResult("{\"success\":true}"));
        } else {
            respondError(idJson, kCoreError, cprag_last_error(*handle));
        }
        return;
    }

    if (name == "library_add_entity_typed") {
        std::string entityId;
        std::string nodeType;
        std::string label;
        std::string description;
        std::string metadata;
        if (!requireString(*args, "id", &entityId, &error)
            || !requireString(*args, "node_type", &nodeType, &error)
            || !requireString(*args, "label", &label, &error)
            || !requireString(*args, "description", &description, &error)
            || !optionalString(*args, "metadata_json", "{}", &metadata, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_add_entity_typed(
            *handle,
            entityId.c_str(),
            nodeType.c_str(),
            label.c_str(),
            description.c_str(),
            metadata.c_str());
        if (rc == CPRAG_OK) {
            respond(idJson, textContentResult("{\"success\":true}"));
        } else {
            respondError(idJson, kCoreError, cprag_last_error(*handle));
        }
        return;
    }

    if (name == "library_add_edge") {
        std::string source;
        std::string target;
        std::string label;
        std::string metadata;
        double weight = 1.0;
        if (!requireString(*args, "source_id", &source, &error)
            || !requireString(*args, "target_id", &target, &error)
            || !requireString(*args, "label", &label, &error)
            || !optionalDouble(*args, "weight", 1.0, 0.0, &weight, &error)
            || !optionalString(*args, "metadata_json", "{}", &metadata, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_add_edge(*handle, source.c_str(), target.c_str(), label.c_str(), weight, metadata.c_str());
        if (rc == CPRAG_OK) {
            respond(idJson, textContentResult("{\"success\":true}"));
        } else {
            respondError(idJson, kCoreError, cprag_last_error(*handle));
        }
        return;
    }

    if (name == "library_add_edge_typed") {
        std::string source;
        std::string target;
        std::string relationshipType;
        std::string label;
        std::string metadata;
        double weight = 1.0;
        if (!requireString(*args, "source_id", &source, &error)
            || !requireString(*args, "target_id", &target, &error)
            || !requireString(*args, "relationship_type", &relationshipType, &error)
            || !requireString(*args, "label", &label, &error)
            || !optionalDouble(*args, "weight", 1.0, 0.0, &weight, &error)
            || !optionalString(*args, "metadata_json", "{}", &metadata, &error)) {
            respondError(idJson, kInvalidParams, error);
            return;
        }
        rc = cprag_add_edge_typed(
            *handle,
            source.c_str(),
            target.c_str(),
            relationshipType.c_str(),
            label.c_str(),
            weight,
            metadata.c_str());
        if (rc == CPRAG_OK) {
            respond(idJson, textContentResult("{\"success\":true}"));
        } else {
            respondError(idJson, kCoreError, cprag_last_error(*handle));
        }
    }
}

bool parseArgs(int argc, char** argv, Config* config)
{
    for (int i = 1; i < argc; ++i) {
        const std::string arg(argv[i]);
        if (arg == "--library") {
            if (i + 1 >= argc) {
                std::cerr << "crexx-rag-mcp: --library requires a path\n";
                return false;
            }
            config->libraryPath = argv[++i];
        } else if (arg == "--embedding-command") {
            if (i + 1 >= argc) {
                std::cerr << "crexx-rag-mcp: --embedding-command requires a command\n";
                return false;
            }
            config->embeddingCommand = argv[++i];
        } else if (arg == "--embedding-model") {
            if (i + 1 >= argc) {
                std::cerr << "crexx-rag-mcp: --embedding-model requires a model name\n";
                return false;
            }
            config->embeddingModel = argv[++i];
        } else if (arg == "--allow-writes") {
            config->allowWrites = true;
        } else if (arg == "--read-only") {
            config->allowWrites = false;
        } else if (arg == "--help" || arg == "-h") {
            std::cout << "Usage: crexx-rag-mcp [--library PATH] [--allow-writes|--read-only] [--embedding-command COMMAND] [--embedding-model MODEL]\n";
            return false;
        } else {
            std::cerr << "crexx-rag-mcp: unknown argument: " << arg << '\n';
            return false;
        }
    }
    return true;
}

} // namespace

int main(int argc, char** argv)
{
    Config config;
    if (!parseArgs(argc, argv, &config)) {
        return CPRAG_INVALID_ARGUMENT;
    }

    cprag_handle* handle = nullptr;
    std::string line;
    while (std::getline(std::cin, line)) {
        Json request;
        try {
            request = JsonParser(line).parse();
        } catch (const std::exception& ex) {
            respondError("null", kParseError, ex.what());
            continue;
        }

        if (request.type != Json::Type::Object) {
            respondError("null", kInvalidRequest, "request must be a JSON object");
            continue;
        }

        const Json* id = member(request, "id");
        const bool hasId = id != nullptr;
        const std::string idJson = hasId && isValidId(*id) ? renderJson(*id) : "null";
        if (hasId && !isValidId(*id)) {
            respondError("null", kInvalidRequest, "id must be a string, number, or null");
            continue;
        }

        const Json* version = member(request, "jsonrpc");
        if (version == nullptr || version->type != Json::Type::String || version->text != "2.0") {
            if (hasId) {
                respondError(idJson, kInvalidRequest, "jsonrpc must be \"2.0\"");
            } else {
                respondError("null", kInvalidRequest, "jsonrpc must be \"2.0\"");
            }
            continue;
        }

        const Json* method = member(request, "method");
        if (method == nullptr || method->type != Json::Type::String) {
            if (hasId) {
                respondError(idJson, kInvalidRequest, "method must be a string");
            }
            continue;
        }

        if (method->text == "notifications/initialized") {
            continue;
        }

        if (method->text == "initialize") {
            if (hasId) {
                respond(
                    idJson,
                    R"JSON({"protocolVersion":"2025-06-18","serverInfo":{"name":"crexx-rag-mcp","version":"0.1.0"},"capabilities":{"tools":{}}})JSON");
            }
            continue;
        }

        if (method->text == "tools/list") {
            if (hasId) {
                respond(idJson, toolListJson(config.allowWrites));
            }
            continue;
        }

        if (method->text == "tools/call") {
            const Json* params = member(request, "params");
            if (params == nullptr || params->type != Json::Type::Object) {
                if (hasId) {
                    respondError(idJson, kInvalidParams, "params must be an object");
                }
                continue;
            }
            if (hasId) {
                handleToolCall(idJson, *params, &handle, config);
            }
            continue;
        }

        if (hasId) {
            respondError(idJson, kMethodNotFound, "method not found");
        }
    }

    cprag_close(handle);
    return 0;
}
