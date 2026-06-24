#include "crexx_rag/ragcore.h"

#include <chrono>
#include <cerrno>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cctype>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>
#include <utility>
#include <vector>

#ifdef CPRAG_HAVE_CURL
#include <curl/curl.h>
#endif

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
        << "  crexx-rag embed-llama-server [--role document|query|raw] [--base-url URL] [--prefix PREFIX] <text> [embedding-model]\n"
        << "  crexx-rag advise-llama-server [--task value|route|relation|alias|complexity|proper-nouns] [--profile generic|scotland|athens] [--context TEXT] [--base-url URL] [--model MODEL] [--temperature N] [--max-tokens N] [--dry-prompt] <text>\n"
        << "  crexx-rag extract-llama-server [--profile generic|scotland|athens] [--base-url URL] [--model MODEL] [--temperature N] [--max-tokens N] [--dry-prompt] <text>\n"
        << "  crexx-rag extract-chunks-llama-server <library> [--source-uri URI] [--offset N] [--limit N] [--profile generic|scotland|athens] [--base-url URL] [--model MODEL]\n"
        << "  crexx-rag rebuild-vector-index <library> <embedding-model> [embedding-profile]\n"
        << "  crexx-rag vector-search <library> <embedding-model> <comma-separated-floats> [top-k]\n"
        << "  crexx-rag vector-status <library>\n"
        << "  crexx-rag list-concepts <library> [node-type-csv]\n"
        << "  crexx-rag match-concepts <library> <text> [node-type-csv]\n"
        << "  crexx-rag search <library> <query> [top-k] [hops]\n"
        << "  crexx-rag expand <library> <anchor-csv> [hops] [relation-filter-csv]\n"
        << "  crexx-rag shortest-path <library> <source-id> <target-id> [relationship-filter-csv]\n"
        << "  crexx-rag subgraph <library> [node-type-csv] [relationship-type-csv] [limit]\n"
        << "  crexx-rag export-dot <library> [node-type-csv] [relationship-type-csv] [limit]\n"
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

template <typename Fn>
int withLibraryReadOnly(const std::string& path, const Fn& fn)
{
    const std::filesystem::path dbPath = std::filesystem::path(path) / "library.sqlite";
    if (!std::filesystem::exists(dbPath)) {
        std::cerr << "library not found or not initialized: " << path << '\n';
        return CPRAG_NOT_FOUND;
    }

    cprag_handle* handle = nullptr;
    const int rc = cprag_open(path.c_str(), CPRAG_OPEN_READONLY, &handle);
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

std::string envOrDefault(const char* name, const std::string& fallback)
{
    const char* value = std::getenv(name);
    if (value == nullptr || value[0] == '\0') {
        return fallback;
    }
    return value;
}

int envIntOrDefault(const char* name, int fallback)
{
    const char* value = std::getenv(name);
    if (value == nullptr || value[0] == '\0') {
        return fallback;
    }
    char* end = nullptr;
    const long parsed = std::strtol(value, &end, 10);
    if (end == value || parsed < 0 || parsed > 100000) {
        return fallback;
    }
    return static_cast<int>(parsed);
}

std::string trimCopy(const std::string& value)
{
    const size_t first = value.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) {
        return "";
    }
    const size_t last = value.find_last_not_of(" \t\r\n");
    return value.substr(first, last - first + 1);
}

#ifdef CPRAG_HAVE_CURL
size_t writeCurlResponse(char* data, size_t size, size_t nmemb, void* userData)
{
    auto* output = static_cast<std::string*>(userData);
    const size_t bytes = size * nmemb;
    if (output->size() + bytes > kJsonBufferSize) {
        return 0;
    }
    output->append(data, bytes);
    return bytes;
}
#endif

size_t skipWhitespace(const std::string& text, size_t position);

bool parseJsonStringAt(const std::string& text, size_t position, std::string* out, std::string* error)
{
    position = skipWhitespace(text, position);
    if (position >= text.size() || text[position] != '"') {
        *error = "expected JSON string";
        return false;
    }
    ++position;

    std::string value;
    while (position < text.size()) {
        const unsigned char ch = static_cast<unsigned char>(text[position++]);
        if (ch == '"') {
            *out = std::move(value);
            return true;
        }
        if (ch != '\\') {
            value.push_back(static_cast<char>(ch));
            continue;
        }
        if (position >= text.size()) {
            *error = "unterminated JSON string escape";
            return false;
        }
        const char escaped = text[position++];
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
            if (position + 4 > text.size()) {
                *error = "unterminated unicode escape";
                return false;
            }
            value.push_back('?');
            position += 4;
            break;
        default:
            *error = "invalid JSON string escape";
            return false;
        }
    }

    *error = "unterminated JSON string";
    return false;
}

bool extractJsonStringField(const std::string& text, const std::string& field, std::string* out, std::string* error)
{
    const std::string key = "\"" + field + "\"";
    const size_t keyPos = text.find(key);
    if (keyPos == std::string::npos) {
        *error = "response did not contain field: " + field;
        return false;
    }
    const size_t colon = text.find(':', keyPos + key.size());
    if (colon == std::string::npos) {
        *error = "response field is missing ':'";
        return false;
    }
    return parseJsonStringAt(text, colon + 1, out, error);
}

std::string stripJsonFence(const std::string& content)
{
    std::string value = trimCopy(content);
    if (value.rfind("```", 0) != 0) {
        return value;
    }

    const size_t firstNewline = value.find('\n');
    if (firstNewline == std::string::npos) {
        return value;
    }
    const size_t closingFence = value.rfind("```");
    if (closingFence == 0 || closingFence == std::string::npos) {
        return value;
    }
    return trimCopy(value.substr(firstNewline + 1, closingFence - firstNewline - 1));
}

bool jsonDelimitersBalanced(const std::string& text, std::string* error)
{
    std::vector<char> stack;
    bool inString = false;
    bool escaped = false;

    for (size_t i = 0; i < text.size(); ++i) {
        const char ch = text[i];
        if (inString) {
            if (escaped) {
                escaped = false;
            } else if (ch == '\\') {
                escaped = true;
            } else if (ch == '"') {
                inString = false;
            }
            continue;
        }

        if (ch == '"') {
            inString = true;
        } else if (ch == '{' || ch == '[') {
            stack.push_back(ch);
        } else if (ch == '}' || ch == ']') {
            if (stack.empty()) {
                *error = "llama-server chat content had an unmatched JSON closing delimiter";
                return false;
            }
            const char open = stack.back();
            if ((open == '{' && ch != '}') || (open == '[' && ch != ']')) {
                *error = "llama-server chat content had mismatched JSON delimiters";
                return false;
            }
            stack.pop_back();
            if (stack.empty()) {
                for (size_t j = i + 1; j < text.size(); ++j) {
                    if (std::isspace(static_cast<unsigned char>(text[j])) == 0) {
                        *error = "llama-server chat content had text after the top-level JSON value";
                        return false;
                    }
                }
                return true;
            }
        }
    }

    if (inString) {
        *error = "llama-server chat content had an unterminated JSON string";
        return false;
    }
    if (!stack.empty()) {
        *error = "llama-server chat content had incomplete JSON";
        return false;
    }
    return true;
}

std::string extractionSystemPrompt(const std::string& profile)
{
    std::ostringstream prompt;
    prompt
        << "You extract source-grounded knowledge graph candidates for crexx-rag.\n"
        << "Return only valid JSON. Do not wrap it in markdown.\n"
        << "Use this exact shape:\n"
        << "{\"nodes\":[{\"id\":\"\",\"node_type\":\"\",\"label\":\"\",\"aliases\":[],\"confidence\":0.0,\"evidence\":\"\"}],"
        << "\"relationships\":[{\"source_id\":\"\",\"target_id\":\"\",\"relationship_type\":\"\",\"label\":\"\",\"confidence\":0.0,\"evidence\":\"\"}]}\n"
        << "Rules:\n"
        << "- Only include candidates directly supported by the input text.\n"
        << "- Prefer stable lower-case ids with a domain prefix when obvious.\n"
        << "- Keep evidence as a short source phrase copied from the input.\n"
        << "- The 0.0 confidence values in the schema are placeholders; choose real values from 0.1 to 1.0.\n"
        << "- Use an empty array when nothing is supported.\n";

    if (profile == "scotland") {
        prompt
            << "Scotland profile node types: clan, person, place, source-work, evidence-chunk.\n"
            << "Scotland relationship types: mentioned-in, held-land-in, associated-with, conflicted-with, claimed-descent-from, served, source-claims.\n"
            << "Prefer ids like history:scotland:clan:mackay or history:scotland:place:assynt.\n";
    } else if (profile == "athens") {
        prompt
            << "Athens profile node types: person, polity, place, institution, source-work, evidence-chunk.\n"
            << "Athens relationship types: mentioned-in, served, led-by, built-or-improved, treasury-at, succeeded-by, opposed-by, source-claims.\n"
            << "Prefer ids like history:athens:person:themistocles or history:athens:place:piraeus.\n";
    } else {
        prompt
            << "Generic node types: person, organization, place, work, concept, event, evidence-chunk.\n"
            << "Generic relationship types: mentioned-in, associated-with, part-of, located-in, caused-by, succeeded-by, source-claims.\n";
    }

    return prompt.str();
}

std::string extractionUserPrompt(const std::string& text)
{
    return "Extract graph candidates from this chunk:\n\n" + text;
}

std::string adviceSystemPrompt(const std::string& task, const std::string& profile)
{
    std::ostringstream prompt;
    prompt
        << "You are a cheap local graph-ingestion advisory model for crexx-rag.\n"
        << "Return only the requested short answer. No explanation. No JSON.\n"
        << "Graph value means relationship information or retrieval novelty beyond plain keyword/vector search.\n"
        << "Bias toward review rather than skipping: if unsure, choose gemma-advice.\n"
        << "Skip only when the chunk has no useful named endpoints and no relationship cue.\n"
        << "Known endpoints plus a clear cue such as held, fought, killed, succeeded, led, served, treasury, or built should be deterministic unless the direction is complex.\n";

    if (profile == "scotland") {
        prompt
            << "Scotland relationship vocabulary: held-land-in, associated-with, conflicted-with, claimed-descent-from, served, source-claims, none.\n";
    } else if (profile == "athens") {
        prompt
            << "Athens relationship vocabulary: served, led-by, built-or-improved, treasury-at, succeeded-by, opposed-by, source-claims, none.\n";
    } else {
        prompt
            << "Generic relationship vocabulary: associated-with, part-of, located-in, caused-by, succeeded-by, source-claims, none.\n";
    }

    if (task == "value") {
        prompt << "Task: return one integer 0, 1, 2, 3, 4, or 5. 0 means no graph value; 5 means strong typed relationship or bridge value. Known endpoints with a fight, land-holding, succession, leadership, treasury, service, or building cue should be 4 or 5.\n";
    } else if (task == "route") {
        prompt << "Task: return exactly one route word: skip, deterministic, medium, gemma-advice, gemma-extract. Use deterministic for known endpoints plus a clear cue. Use gemma-advice for uncertain chunks. Use gemma-extract for high-value complex chunks.\n";
    } else if (task == "relation") {
        prompt << "Task: return exactly one relationship type from the vocabulary, or none. Examples: fought, defeated, killed, feud, or battle -> conflicted-with; held lands, estate, or barony -> held-land-in; descended, sons of, or sprung from -> claimed-descent-from; led or head -> led-by; treasury or tribute -> treasury-at; built, harbour, walls, or fortification -> built-or-improved; succeeds or replaces -> succeeded-by.\n";
    } else if (task == "alias") {
        prompt << "Task: return yes if the chunk likely states an alias, spelling variant, old name, translation, or descent/origin name; otherwise no.\n";
    } else if (task == "complexity") {
        prompt << "Task: return low, medium, or high. High means relationship direction, pronouns, many unknown names, or multiple events need a stronger model.\n";
    } else if (task == "proper-nouns") {
        prompt << "Task: return a comma-separated list of proper nouns and multi-word proper names from the chunk. Include people, clans, places, polities, institutions, and source works. Return none if there are no proper nouns. Do not include common nouns, verbs, explanations, or bullets.\n";
    }

    return prompt.str();
}

std::string adviceUserPrompt(
    const std::string& task,
    const std::string& profile,
    const std::string& context,
    const std::string& text)
{
    std::ostringstream prompt;
    prompt << "Profile: " << profile << "\n";
    prompt << "Task: " << task << "\n";
    if (!context.empty()) {
        prompt << "Known deterministic context:\n" << context << "\n";
    }
    prompt << "Chunk:\n" << text;
    return prompt.str();
}

std::string lowerCopy(std::string value)
{
    for (char& ch : value) {
        ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
    }
    return value;
}

bool containsInsensitive(const std::string& text, const std::string& needle)
{
    return lowerCopy(text).find(lowerCopy(needle)) != std::string::npos;
}

std::vector<std::string> relationshipVocabulary(const std::string& profile)
{
    if (profile == "scotland") {
        return {
            "held-land-in",
            "associated-with",
            "conflicted-with",
            "claimed-descent-from",
            "served",
            "source-claims",
            "none"
        };
    }
    if (profile == "athens") {
        return {
            "served",
            "led-by",
            "built-or-improved",
            "treasury-at",
            "succeeded-by",
            "opposed-by",
            "source-claims",
            "none"
        };
    }
    return {
        "associated-with",
        "part-of",
        "located-in",
        "caused-by",
        "succeeded-by",
        "source-claims",
        "none"
    };
}

std::string normalizeAdvice(const std::string& task, const std::string& profile, const std::string& raw)
{
    const std::string text = trimCopy(stripJsonFence(raw));
    const std::string lower = lowerCopy(text);

    if (task == "value") {
        for (const char ch : lower) {
            if (ch >= '0' && ch <= '5') {
                return std::string(1, ch);
            }
        }
        return "0";
    }

    if (task == "alias") {
        if (containsInsensitive(lower, "yes") || containsInsensitive(lower, "alias")
                || containsInsensitive(lower, "variant") || containsInsensitive(lower, "spelling")) {
            return "yes";
        }
        return "no";
    }

    if (task == "complexity") {
        if (containsInsensitive(lower, "high")) {
            return "high";
        }
        if (containsInsensitive(lower, "medium")) {
            return "medium";
        }
        return "low";
    }

    if (task == "route") {
        const std::vector<std::string> routes = {
            "gemma-extract",
            "gemma-advice",
            "deterministic",
            "medium",
            "skip"
        };
        for (const std::string& route : routes) {
            if (containsInsensitive(lower, route)) {
                return route;
            }
        }
        if (containsInsensitive(lower, "extract")) {
            return "gemma-extract";
        }
        if (containsInsensitive(lower, "advice")) {
            return "gemma-advice";
        }
        return "skip";
    }

    if (task == "relation") {
        for (const std::string& relation : relationshipVocabulary(profile)) {
            if (containsInsensitive(lower, relation)) {
                return relation;
            }
        }
        return "none";
    }

    if (task == "proper-nouns") {
        std::string cleaned;
        bool previousWasComma = false;
        for (const char ch : text) {
            if (ch == '\n' || ch == '\r' || ch == ';' || ch == '|') {
                if (!previousWasComma) {
                    cleaned += ", ";
                    previousWasComma = true;
                }
            } else if (ch == '-' && (cleaned.empty() || cleaned.back() == '\n')) {
                continue;
            } else {
                cleaned.push_back(ch);
                previousWasComma = ch == ',';
            }
        }
        cleaned = trimCopy(cleaned);
        if (cleaned.empty()) {
            return "none";
        }
        return cleaned;
    }

    return text;
}

bool runLlamaServerChat(
    const std::string& userText,
    const std::string& systemPrompt,
    const std::string& model,
    const std::string& baseUrl,
    double temperature,
    int maxTokens,
    bool requireJson,
    std::string* outContent,
    std::string* error)
{
    const std::string endpoint = baseUrl.empty() ? "http://127.0.0.1:8080/v1" : baseUrl;
    const std::string trimmedEndpoint = endpoint.back() == '/' ? endpoint.substr(0, endpoint.size() - 1) : endpoint;
    const std::string effectiveModel = model.empty() ? "ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M" : model;
    const std::string apiKey = envOrDefault("CPRAG_LLAMA_SERVER_API_KEY", "no-key");
    const std::string timeout = envOrDefault("CPRAG_LLAMA_SERVER_CHAT_TIMEOUT", "180");
    std::string output;

    std::ostringstream body;
    body << "{\"model\":" << jsonString(effectiveModel)
         << ",\"messages\":[{\"role\":\"system\",\"content\":" << jsonString(systemPrompt)
         << "},{\"role\":\"user\",\"content\":" << jsonString(userText)
         << "}],\"temperature\":" << temperature
         << ",\"max_tokens\":" << maxTokens;
    if (requireJson) {
        body << ",\"response_format\":{\"type\":\"json_object\"}";
    }
    body << "}";

#ifdef CPRAG_HAVE_CURL
    char curlError[CURL_ERROR_SIZE] = {0};
    curl_global_init(CURL_GLOBAL_DEFAULT);
    CURL* curl = curl_easy_init();
    if (curl == nullptr) {
        *error = "failed to initialize libcurl";
        return false;
    }

    struct curl_slist* headers = nullptr;
    headers = curl_slist_append(headers, "Content-Type: application/json");
    const std::string authorization = "Authorization: Bearer " + apiKey;
    headers = curl_slist_append(headers, authorization.c_str());

    const double timeoutSeconds = std::strtod(timeout.c_str(), nullptr);
    curl_easy_setopt(curl, CURLOPT_URL, (trimmedEndpoint + "/chat/completions").c_str());
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    const std::string bodyText = body.str();
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, bodyText.c_str());
    curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, static_cast<long>(bodyText.size()));
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeCurlResponse);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &output);
    curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1L);
    curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, curlError);
    if (timeoutSeconds > 0.0) {
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, timeoutSeconds);
    }

    const CURLcode curlRc = curl_easy_perform(curl);
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);
    if (curlRc != CURLE_OK) {
        *error = curlError[0] == '\0'
            ? std::string("llama-server chat request failed: ") + curl_easy_strerror(curlRc)
            : std::string("llama-server chat request failed: ") + curlError;
        return false;
    }
#else
    const std::string shellCommand = "curl -fsS --max-time " + shellQuote(timeout)
        + " " + shellQuote(trimmedEndpoint + "/chat/completions")
        + " -H " + shellQuote("Content-Type: application/json")
        + " -H " + shellQuote("Authorization: Bearer " + apiKey)
        + " -d " + shellQuote(body.str());

    FILE* pipe = popen(shellCommand.c_str(), "r");
    if (pipe == nullptr) {
        *error = "failed to start curl for llama-server chat request";
        return false;
    }

    char buffer[4096];
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        output += buffer;
        if (output.size() > kJsonBufferSize) {
            pclose(pipe);
            *error = "llama-server chat response is too large";
            return false;
        }
    }
    const int status = pclose(pipe);
    if (status != 0) {
        *error = "llama-server chat request failed";
        return false;
    }
#endif

    std::string content;
    if (!extractJsonStringField(output, "content", &content, error)) {
        return false;
    }
    std::string payload = stripJsonFence(content);
    const std::string trimmed = trimCopy(payload);
    if (trimmed.empty() && output.find("\"reasoning_content\"") != std::string::npos) {
        *error = requireJson
            ? "llama-server returned reasoning_content but no final JSON; increase --max-tokens or use a less reasoning-heavy model"
            : "llama-server returned reasoning_content but no final answer; increase --max-tokens or use a less reasoning-heavy model";
        return false;
    }
    if (!requireJson) {
        *outContent = trimmed;
        return true;
    }
    if (trimmed.empty() || (trimmed.front() != '{' && trimmed.front() != '[')) {
        *error = "llama-server chat content was not JSON";
        return false;
    }
    if (!jsonDelimitersBalanced(trimmed, error)) {
        return false;
    }
    *outContent = trimmed;
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

bool runEmbeddingCommandWithRetries(
    const std::string& command,
    const std::string& text,
    const std::string& embeddingModel,
    int maxRetries,
    int retryDelayMs,
    std::vector<float>* out,
    std::string* error)
{
    std::string lastError;
    for (int attempt = 0; attempt <= maxRetries; ++attempt) {
        lastError.clear();
        if (runEmbeddingCommand(command, text, embeddingModel, out, &lastError)) {
            if (attempt > 0) {
                std::cerr << "embedding command recovered after retry " << attempt << '\n';
            }
            return true;
        }
        if (attempt < maxRetries) {
            std::cerr << "embedding command failed, retrying " << (attempt + 1)
                      << "/" << maxRetries << ": " << lastError << '\n';
            if (retryDelayMs > 0) {
                std::this_thread::sleep_for(std::chrono::milliseconds(retryDelayMs));
            }
        }
    }
    *error = lastError;
    return false;
}

std::string llamaInputPrefix(const std::string& role, std::string* error)
{
    if (role == "document") {
        return "search_document: ";
    }
    if (role == "query") {
        return "search_query: ";
    }
    if (role == "raw") {
        return "";
    }
    *error = "llama-server role must be document, query, or raw";
    return "";
}

bool hasKnownNomicPrefix(const std::string& text)
{
    return text.rfind("search_document: ", 0) == 0 || text.rfind("search_query: ", 0) == 0;
}

bool runLlamaServerEmbedding(
    const std::string& text,
    const std::string& embeddingModel,
    const std::string& baseUrl,
    const std::string& role,
    const std::string& explicitPrefix,
    std::vector<float>* out,
    std::string* error)
{
    const std::string endpoint = baseUrl.empty() ? "http://127.0.0.1:8081/v1" : baseUrl;
    const std::string trimmedEndpoint = endpoint.back() == '/' ? endpoint.substr(0, endpoint.size() - 1) : endpoint;
    const std::string model = embeddingModel.empty() ? "nomic-embed-text-v1.5" : embeddingModel;
    std::string prefix = explicitPrefix;
    if (prefix.empty()) {
        prefix = llamaInputPrefix(role, error);
        if (!error->empty()) {
            return false;
        }
    }
    const std::string input = (!prefix.empty() && !hasKnownNomicPrefix(text)) ? prefix + text : text;
    const std::string body = "{\"model\":" + jsonString(model)
        + ",\"input\":[" + jsonString(input)
        + "],\"encoding_format\":\"float\"}";
    const std::string apiKey = envOrDefault("CPRAG_LLAMA_SERVER_API_KEY", "no-key");
    const std::string timeout = envOrDefault("CPRAG_LLAMA_SERVER_TIMEOUT", "60");

#ifdef CPRAG_HAVE_CURL
    std::string output;
    char curlError[CURL_ERROR_SIZE] = {0};
    curl_global_init(CURL_GLOBAL_DEFAULT);
    CURL* curl = curl_easy_init();
    if (curl == nullptr) {
        *error = "failed to initialize libcurl";
        return false;
    }

    struct curl_slist* headers = nullptr;
    headers = curl_slist_append(headers, "Content-Type: application/json");
    const std::string authorization = "Authorization: Bearer " + apiKey;
    headers = curl_slist_append(headers, authorization.c_str());

    const double timeoutSeconds = std::strtod(timeout.c_str(), nullptr);
    curl_easy_setopt(curl, CURLOPT_URL, (trimmedEndpoint + "/embeddings").c_str());
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, body.c_str());
    curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, static_cast<long>(body.size()));
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeCurlResponse);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &output);
    curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1L);
    curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, curlError);
    if (timeoutSeconds > 0.0) {
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, timeoutSeconds);
    }

    const CURLcode curlRc = curl_easy_perform(curl);
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);
    if (curlRc != CURLE_OK) {
        *error = curlError[0] == '\0'
            ? std::string("llama-server embedding request failed: ") + curl_easy_strerror(curlRc)
            : std::string("llama-server embedding request failed: ") + curlError;
        return false;
    }
    return parseEmbeddingOutput(output, out, error);
#else
    const std::string shellCommand = "curl -fsS --max-time " + shellQuote(timeout)
        + " " + shellQuote(trimmedEndpoint + "/embeddings")
        + " -H " + shellQuote("Content-Type: application/json")
        + " -H " + shellQuote("Authorization: Bearer " + apiKey)
        + " -d " + shellQuote(body);

    FILE* pipe = popen(shellCommand.c_str(), "r");
    if (pipe == nullptr) {
        *error = "failed to start curl for llama-server embedding request";
        return false;
    }

    std::string output;
    char buffer[4096];
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        output += buffer;
        if (output.size() > kJsonBufferSize) {
            pclose(pipe);
            *error = "llama-server embedding response is too large";
            return false;
        }
    }
    const int status = pclose(pipe);
    if (status != 0) {
        *error = "llama-server embedding request failed";
        return false;
    }
    return parseEmbeddingOutput(output, out, error);
#endif
}

bool runLlamaServerEmbeddingWithRetries(
    const std::string& text,
    const std::string& embeddingModel,
    const std::string& baseUrl,
    const std::string& role,
    const std::string& explicitPrefix,
    int maxRetries,
    int retryDelayMs,
    std::vector<float>* out,
    std::string* error)
{
    std::string lastError;
    for (int attempt = 0; attempt <= maxRetries; ++attempt) {
        lastError.clear();
        if (runLlamaServerEmbedding(text, embeddingModel, baseUrl, role, explicitPrefix, out, &lastError)) {
            if (attempt > 0) {
                std::cerr << "llama-server embedding recovered after retry " << attempt << '\n';
            }
            return true;
        }
        if (attempt < maxRetries) {
            std::cerr << "llama-server embedding failed, retrying " << (attempt + 1)
                      << "/" << maxRetries << ": " << lastError << '\n';
            if (retryDelayMs > 0) {
                std::this_thread::sleep_for(std::chrono::milliseconds(retryDelayMs));
            }
        }
    }
    *error = lastError;
    return false;
}

void printEmbeddingObject(const std::vector<float>& values)
{
    std::cout << "{\"embedding\":[";
    for (size_t i = 0; i < values.size(); ++i) {
        if (i != 0) {
            std::cout << ',';
        }
        std::cout << std::setprecision(9) << values[i];
    }
    std::cout << "]}\n";
}

struct ChunkForEmbedding {
    long long id {0};
    std::string sourceUri;
    std::string title;
    int chunkIndex {0};
};

struct ChunkForExtraction {
    long long id {0};
    std::string sourceUri;
    std::string title;
    int chunkIndex {0};
    std::string text;
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

int collectChunkForExtraction(
    long long chunkId,
    const char* sourceUri,
    const char* title,
    int chunkIndex,
    const char* text,
    void* userData)
{
    auto* chunks = static_cast<std::vector<ChunkForExtraction>*>(userData);
    chunks->push_back(ChunkForExtraction {
        chunkId,
        sourceUri == nullptr ? std::string() : std::string(sourceUri),
        title == nullptr ? std::string() : std::string(title),
        chunkIndex,
        text == nullptr ? std::string() : std::string(text)
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

    if (command == "embed-llama-server") {
        std::string role = envOrDefault("CPRAG_LLAMA_SERVER_INPUT_ROLE", "raw");
        std::string baseUrl = envOrDefault("CPRAG_LLAMA_SERVER_BASE_URL", "http://127.0.0.1:8081/v1");
        std::string prefix = envOrDefault("CPRAG_LLAMA_SERVER_INPUT_PREFIX", "");
        std::string text;
        std::string embeddingModel = envOrDefault("CPRAG_EMBEDDING_MODEL", "nomic-embed-text-v1.5");

        for (int i = 2; i < argc; ++i) {
            const std::string arg = argv[i];
            if (arg == "--role") {
                if (i + 1 >= argc) {
                    std::cerr << "embed-llama-server: --role requires document, query, or raw\n";
                    return 2;
                }
                role = argv[++i];
            } else if (arg == "--base-url") {
                if (i + 1 >= argc) {
                    std::cerr << "embed-llama-server: --base-url requires a URL\n";
                    return 2;
                }
                baseUrl = argv[++i];
            } else if (arg == "--prefix") {
                if (i + 1 >= argc) {
                    std::cerr << "embed-llama-server: --prefix requires a value\n";
                    return 2;
                }
                prefix = argv[++i];
            } else if (arg == "--help" || arg == "-h") {
                std::cout << "Usage: crexx-rag embed-llama-server [--role document|query|raw] [--base-url URL] [--prefix PREFIX] <text> [embedding-model]\n";
                return 0;
            } else if (text.empty()) {
                text = arg;
            } else {
                embeddingModel = arg;
            }
        }

        if (text.empty()) {
            usage();
            return 2;
        }

        std::vector<float> embedding;
        std::string error;
        if (!runLlamaServerEmbedding(text, embeddingModel, baseUrl, role, prefix, &embedding, &error)) {
            std::cerr << error << '\n';
            return CPRAG_IO_ERROR;
        }
        printEmbeddingObject(embedding);
        return 0;
    }

    if (command == "advise-llama-server") {
        std::string task = envOrDefault("CPRAG_LLM_ADVICE_TASK", "route");
        std::string profile = envOrDefault("CPRAG_LLM_EXTRACT_PROFILE", "generic");
        std::string context;
        std::string baseUrl = envOrDefault("CPRAG_LLAMA_SERVER_ADVICE_BASE_URL",
            envOrDefault("CPRAG_LLAMA_SERVER_CHAT_BASE_URL", "http://127.0.0.1:8084/v1"));
        std::string model = envOrDefault("CPRAG_LLM_ADVICE_MODEL",
            envOrDefault("CPRAG_LLM_MODEL", "Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M"));
        std::string systemPrompt;
        std::string text;
        double temperature = std::strtod(envOrDefault("CPRAG_LLM_ADVICE_TEMPERATURE", "0.0").c_str(), nullptr);
        int maxTokens = envIntOrDefault("CPRAG_LLM_ADVICE_MAX_TOKENS", 32);
        bool dryPrompt = false;

        for (int i = 2; i < argc; ++i) {
            const std::string arg = argv[i];
            if (arg == "--task") {
                if (i + 1 >= argc) {
                    std::cerr << "advise-llama-server: --task requires value, route, relation, alias, complexity, or proper-nouns\n";
                    return 2;
                }
                task = argv[++i];
            } else if (arg == "--profile") {
                if (i + 1 >= argc) {
                    std::cerr << "advise-llama-server: --profile requires generic, scotland, or athens\n";
                    return 2;
                }
                profile = argv[++i];
            } else if (arg == "--context") {
                if (i + 1 >= argc) {
                    std::cerr << "advise-llama-server: --context requires text\n";
                    return 2;
                }
                context = argv[++i];
            } else if (arg == "--base-url") {
                if (i + 1 >= argc) {
                    std::cerr << "advise-llama-server: --base-url requires a URL\n";
                    return 2;
                }
                baseUrl = argv[++i];
            } else if (arg == "--model") {
                if (i + 1 >= argc) {
                    std::cerr << "advise-llama-server: --model requires a model id\n";
                    return 2;
                }
                model = argv[++i];
            } else if (arg == "--temperature") {
                if (i + 1 >= argc) {
                    std::cerr << "advise-llama-server: --temperature requires a number\n";
                    return 2;
                }
                temperature = std::strtod(argv[++i], nullptr);
            } else if (arg == "--max-tokens") {
                if (i + 1 >= argc) {
                    std::cerr << "advise-llama-server: --max-tokens requires a number\n";
                    return 2;
                }
                char* end = nullptr;
                const long parsed = std::strtol(argv[++i], &end, 10);
                if (end == argv[i] || parsed <= 0 || parsed > 100000) {
                    std::cerr << "advise-llama-server: max-tokens must be a positive integer\n";
                    return 2;
                }
                maxTokens = static_cast<int>(parsed);
            } else if (arg == "--system") {
                if (i + 1 >= argc) {
                    std::cerr << "advise-llama-server: --system requires prompt text\n";
                    return 2;
                }
                systemPrompt = argv[++i];
            } else if (arg == "--dry-prompt") {
                dryPrompt = true;
            } else if (arg == "--help" || arg == "-h") {
                std::cout << "Usage: crexx-rag advise-llama-server [--task value|route|relation|alias|complexity|proper-nouns] [--profile generic|scotland|athens] [--context TEXT] [--base-url URL] [--model MODEL] [--temperature N] [--max-tokens N] [--system PROMPT] [--dry-prompt] <text>\n";
                return 0;
            } else if (text.empty()) {
                text = arg;
            } else {
                text += "\n";
                text += arg;
            }
        }

        if (text.empty()) {
            usage();
            return 2;
        }
        if (task != "value" && task != "route" && task != "relation" && task != "alias" && task != "complexity" && task != "proper-nouns") {
            std::cerr << "advise-llama-server: task must be value, route, relation, alias, complexity, or proper-nouns\n";
            return 2;
        }
        if (profile != "generic" && profile != "scotland" && profile != "athens") {
            std::cerr << "advise-llama-server: profile must be generic, scotland, or athens\n";
            return 2;
        }
        if (maxTokens <= 0) {
            std::cerr << "advise-llama-server: max-tokens must be greater than zero\n";
            return 2;
        }
        if (!std::isfinite(temperature) || temperature < 0.0) {
            std::cerr << "advise-llama-server: temperature must be a non-negative number\n";
            return 2;
        }

        if (systemPrompt.empty()) {
            systemPrompt = adviceSystemPrompt(task, profile);
        }
        const std::string userPrompt = adviceUserPrompt(task, profile, context, text);

        if (dryPrompt) {
            std::cout << "{\"task\":" << jsonString(task)
                      << ",\"profile\":" << jsonString(profile)
                      << ",\"model\":" << jsonString(model)
                      << ",\"base_url\":" << jsonString(baseUrl)
                      << ",\"temperature\":" << temperature
                      << ",\"max_tokens\":" << maxTokens
                      << ",\"system\":" << jsonString(systemPrompt)
                      << ",\"user\":" << jsonString(userPrompt)
                      << "}\n";
            return 0;
        }

        std::string answer;
        std::string error;
        if (!runLlamaServerChat(userPrompt, systemPrompt, model, baseUrl, temperature, maxTokens, false, &answer, &error)) {
            std::cerr << error << '\n';
            return CPRAG_IO_ERROR;
        }
        std::cout << normalizeAdvice(task, profile, answer) << '\n';
        return 0;
    }

    if (command == "extract-llama-server") {
        std::string profile = envOrDefault("CPRAG_LLM_EXTRACT_PROFILE", "generic");
        std::string baseUrl = envOrDefault("CPRAG_LLAMA_SERVER_CHAT_BASE_URL", "http://127.0.0.1:8080/v1");
        std::string model = envOrDefault("CPRAG_LLM_MODEL", "ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M");
        std::string systemPrompt;
        std::string text;
        double temperature = std::strtod(envOrDefault("CPRAG_LLM_TEMPERATURE", "0.1").c_str(), nullptr);
        int maxTokens = envIntOrDefault("CPRAG_LLM_MAX_TOKENS", 2048);
        bool dryPrompt = false;

        for (int i = 2; i < argc; ++i) {
            const std::string arg = argv[i];
            if (arg == "--profile") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-llama-server: --profile requires generic, scotland, or athens\n";
                    return 2;
                }
                profile = argv[++i];
            } else if (arg == "--base-url") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-llama-server: --base-url requires a URL\n";
                    return 2;
                }
                baseUrl = argv[++i];
            } else if (arg == "--model") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-llama-server: --model requires a model id\n";
                    return 2;
                }
                model = argv[++i];
            } else if (arg == "--temperature") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-llama-server: --temperature requires a number\n";
                    return 2;
                }
                temperature = std::strtod(argv[++i], nullptr);
            } else if (arg == "--max-tokens") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-llama-server: --max-tokens requires a number\n";
                    return 2;
                }
                char* end = nullptr;
                const long parsed = std::strtol(argv[++i], &end, 10);
                if (end == argv[i] || parsed <= 0 || parsed > 100000) {
                    std::cerr << "extract-llama-server: max-tokens must be a positive integer\n";
                    return 2;
                }
                maxTokens = static_cast<int>(parsed);
            } else if (arg == "--system") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-llama-server: --system requires prompt text\n";
                    return 2;
                }
                systemPrompt = argv[++i];
            } else if (arg == "--dry-prompt") {
                dryPrompt = true;
            } else if (arg == "--help" || arg == "-h") {
                std::cout << "Usage: crexx-rag extract-llama-server [--profile generic|scotland|athens] [--base-url URL] [--model MODEL] [--temperature N] [--max-tokens N] [--system PROMPT] [--dry-prompt] <text>\n";
                return 0;
            } else if (text.empty()) {
                text = arg;
            } else {
                text += "\n";
                text += arg;
            }
        }

        if (text.empty()) {
            usage();
            return 2;
        }
        if (profile != "generic" && profile != "scotland" && profile != "athens") {
            std::cerr << "extract-llama-server: profile must be generic, scotland, or athens\n";
            return 2;
        }
        if (maxTokens <= 0) {
            std::cerr << "extract-llama-server: max-tokens must be greater than zero\n";
            return 2;
        }
        if (!std::isfinite(temperature) || temperature < 0.0) {
            std::cerr << "extract-llama-server: temperature must be a non-negative number\n";
            return 2;
        }

        if (systemPrompt.empty()) {
            systemPrompt = extractionSystemPrompt(profile);
        }
        const std::string userPrompt = extractionUserPrompt(text);

        if (dryPrompt) {
            std::cout << "{\"profile\":" << jsonString(profile)
                      << ",\"model\":" << jsonString(model)
                      << ",\"base_url\":" << jsonString(baseUrl)
                      << ",\"temperature\":" << temperature
                      << ",\"max_tokens\":" << maxTokens
                      << ",\"system\":" << jsonString(systemPrompt)
                      << ",\"user\":" << jsonString(userPrompt)
                      << "}\n";
            return 0;
        }

        std::string candidates;
        std::string error;
        if (!runLlamaServerChat(userPrompt, systemPrompt, model, baseUrl, temperature, maxTokens, true, &candidates, &error)) {
            std::cerr << error << '\n';
            return CPRAG_IO_ERROR;
        }
        std::cout << candidates << '\n';
        return 0;
    }

    if (argc < 3) {
        usage();
        return 2;
    }

    const std::string library = argv[2];

    if (command == "extract-chunks-llama-server") {
        std::string sourceFilter;
        std::string profile = envOrDefault("CPRAG_LLM_EXTRACT_PROFILE", "generic");
        std::string baseUrl = envOrDefault("CPRAG_LLAMA_SERVER_CHAT_BASE_URL", "http://127.0.0.1:8080/v1");
        std::string model = envOrDefault("CPRAG_LLM_MODEL", "ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M");
        std::string systemPrompt;
        double temperature = std::strtod(envOrDefault("CPRAG_LLM_TEMPERATURE", "0.1").c_str(), nullptr);
        int maxTokens = envIntOrDefault("CPRAG_LLM_MAX_TOKENS", 2048);
        int limit = envIntOrDefault("CPRAG_LLM_EXTRACT_LIMIT", 20);
        int offset = envIntOrDefault("CPRAG_LLM_EXTRACT_OFFSET", 0);

        for (int i = 3; i < argc; ++i) {
            const std::string arg = argv[i];
            if (arg == "--source-uri") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --source-uri requires a value\n";
                    return 2;
                }
                sourceFilter = argv[++i];
            } else if (arg == "--limit") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --limit requires a number\n";
                    return 2;
                }
                char* end = nullptr;
                const long parsed = std::strtol(argv[++i], &end, 10);
                if (end == argv[i] || parsed < 0 || parsed > 100000) {
                    std::cerr << "extract-chunks-llama-server: limit must be a non-negative integer\n";
                    return 2;
                }
                limit = static_cast<int>(parsed);
            } else if (arg == "--offset") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --offset requires a number\n";
                    return 2;
                }
                char* end = nullptr;
                const long parsed = std::strtol(argv[++i], &end, 10);
                if (end == argv[i] || parsed < 0 || parsed > 100000) {
                    std::cerr << "extract-chunks-llama-server: offset must be a non-negative integer\n";
                    return 2;
                }
                offset = static_cast<int>(parsed);
            } else if (arg == "--profile") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --profile requires generic, scotland, or athens\n";
                    return 2;
                }
                profile = argv[++i];
            } else if (arg == "--base-url") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --base-url requires a URL\n";
                    return 2;
                }
                baseUrl = argv[++i];
            } else if (arg == "--model") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --model requires a model id\n";
                    return 2;
                }
                model = argv[++i];
            } else if (arg == "--temperature") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --temperature requires a number\n";
                    return 2;
                }
                temperature = std::strtod(argv[++i], nullptr);
            } else if (arg == "--max-tokens") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --max-tokens requires a number\n";
                    return 2;
                }
                char* end = nullptr;
                const long parsed = std::strtol(argv[++i], &end, 10);
                if (end == argv[i] || parsed <= 0 || parsed > 100000) {
                    std::cerr << "extract-chunks-llama-server: max-tokens must be a positive integer\n";
                    return 2;
                }
                maxTokens = static_cast<int>(parsed);
            } else if (arg == "--system") {
                if (i + 1 >= argc) {
                    std::cerr << "extract-chunks-llama-server: --system requires prompt text\n";
                    return 2;
                }
                systemPrompt = argv[++i];
            } else if (arg == "--help" || arg == "-h") {
                std::cout << "Usage: crexx-rag extract-chunks-llama-server <library> [--source-uri URI] [--offset N] [--limit N] [--profile generic|scotland|athens] [--base-url URL] [--model MODEL] [--temperature N] [--max-tokens N] [--system PROMPT]\n";
                return 0;
            } else {
                std::cerr << "extract-chunks-llama-server: unknown argument: " << arg << '\n';
                return 2;
            }
        }

        if (profile != "generic" && profile != "scotland" && profile != "athens") {
            std::cerr << "extract-chunks-llama-server: profile must be generic, scotland, or athens\n";
            return 2;
        }
        if (!std::isfinite(temperature) || temperature < 0.0) {
            std::cerr << "extract-chunks-llama-server: temperature must be a non-negative number\n";
            return 2;
        }
        if (systemPrompt.empty()) {
            systemPrompt = extractionSystemPrompt(profile);
        }

        return withLibraryReadOnly(library, [&](cprag_handle* handle) {
            std::vector<ChunkForExtraction> chunks;
            const int rc = cprag_each_chunk(
                handle,
                sourceFilter.empty() ? nullptr : sourceFilter.c_str(),
                collectChunkForExtraction,
                &chunks);
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }

            const size_t start = std::min(chunks.size(), static_cast<size_t>(offset));
            const size_t availableAfterOffset = chunks.size() - start;
            const size_t totalToProcess = limit == 0
                ? 0
                : std::min(availableAfterOffset, static_cast<size_t>(limit));
            std::cerr << "llm extraction: library=" << library
                      << " source_uri=" << (sourceFilter.empty() ? "<all>" : sourceFilter)
                      << " chunks_available=" << chunks.size()
                      << " offset=" << offset
                      << " limit=" << limit
                      << " processing=" << totalToProcess
                      << " profile=" << profile
                      << " model=" << model
                      << '\n';

            std::cout << "{\"success\":true"
                      << ",\"library\":" << jsonString(library)
                      << ",\"source_uri\":";
            if (sourceFilter.empty()) {
                std::cout << "null";
            } else {
                std::cout << jsonString(sourceFilter);
            }
            std::cout << ",\"profile\":" << jsonString(profile)
                      << ",\"model\":" << jsonString(model)
                      << ",\"limit\":" << limit
                      << ",\"offset\":" << offset
                      << ",\"chunks_available\":" << chunks.size()
                      << ",\"processed\":" << totalToProcess
                      << ",\"chunks\":[";

            size_t failures = 0;
            for (size_t i = 0; i < totalToProcess; ++i) {
                const ChunkForExtraction& chunk = chunks[start + i];
                const auto started = std::chrono::steady_clock::now();
                std::cerr << "[" << (i + 1) << "/" << totalToProcess << "]"
                          << " chunk_id=" << chunk.id
                          << " source=" << chunk.sourceUri
                          << " index=" << chunk.chunkIndex
                          << " chars=" << chunk.text.size()
                          << " ... " << std::flush;

                std::string candidates;
                std::string error;
                const bool ok = runLlamaServerChat(
                    extractionUserPrompt(chunk.text),
                    systemPrompt,
                    model,
                    baseUrl,
                    temperature,
                    maxTokens,
                    true,
                    &candidates,
                    &error);
                const auto ended = std::chrono::steady_clock::now();
                const auto elapsedMs = std::chrono::duration_cast<std::chrono::milliseconds>(ended - started).count();
                if (ok) {
                    std::cerr << "ok " << elapsedMs << "ms\n";
                } else {
                    ++failures;
                    std::cerr << "failed " << elapsedMs << "ms: " << error << '\n';
                }

                if (i != 0) {
                    std::cout << ',';
                }
                std::cout << "{\"chunk_id\":" << chunk.id
                          << ",\"source_uri\":" << jsonString(chunk.sourceUri)
                          << ",\"title\":" << jsonString(chunk.title)
                          << ",\"chunk_index\":" << chunk.chunkIndex
                          << ",\"chars\":" << chunk.text.size()
                          << ",\"elapsed_ms\":" << elapsedMs
                          << ",\"success\":" << (ok ? "true" : "false");
                if (ok) {
                    std::cout << ",\"candidates\":" << candidates;
                } else {
                    std::cout << ",\"error\":" << jsonString(error);
                }
                std::cout << "}";
            }

            std::cout << "],\"failures\":" << failures << "}\n";
            std::cerr << "llm extraction complete: processed=" << totalToProcess
                      << " failures=" << failures << '\n';
            return failures == 0 ? 0 : CPRAG_IO_ERROR;
        });
    }

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
        if (argc < 7) {
            usage();
            return 2;
        }
        return withLibrary(library, [&](cprag_handle* handle) {
            const double weight = argc >= 8 ? std::atof(argv[7]) : 1.0;
            const char* metadata = argc >= 9 ? argv[8] : "{}";
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

    if (command == "list-concepts") {
        return withLibraryReadOnly(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const char* nodeFilter = argc >= 4 ? argv[3] : "";
            const int rc = cprag_list_concepts(handle, nodeFilter, buffer.data(), buffer.size());
            return printJsonResult(handle, rc, buffer);
        });
    }

    if (command == "match-concepts") {
        if (argc < 4) {
            usage();
            return 2;
        }
        return withLibraryReadOnly(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const char* nodeFilter = argc >= 5 ? argv[4] : "";
            const int rc = cprag_match_concepts(handle, argv[3], nodeFilter, buffer.data(), buffer.size());
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
        const bool useLlamaServerProvider = embeddingCommand == "llama-server";
        const int maxRetries = envIntOrDefault("CPRAG_EMBEDDING_RETRIES", 3);
        const int retryDelayMs = envIntOrDefault("CPRAG_EMBEDDING_RETRY_DELAY_MS", 500);
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
                const bool embeddedOk = useLlamaServerProvider
                    ? runLlamaServerEmbeddingWithRetries(
                        textBuffer.data(),
                        embeddingModel,
                        envOrDefault("CPRAG_LLAMA_SERVER_BASE_URL", "http://127.0.0.1:8081/v1"),
                        "document",
                        envOrDefault("CPRAG_LLAMA_SERVER_INPUT_PREFIX", ""),
                        maxRetries,
                        retryDelayMs,
                        &vector,
                        &error)
                    : runEmbeddingCommandWithRetries(
                        embeddingCommand,
                        textBuffer.data(),
                        embeddingModel,
                        maxRetries,
                        retryDelayMs,
                        &vector,
                        &error);
                if (!embeddedOk) {
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

    if (command == "export-dot") {
        return withLibraryReadOnly(library, [&](cprag_handle* handle) {
            std::vector<char> buffer(kJsonBufferSize);
            const char* nodeFilter = argc >= 4 ? argv[3] : "";
            const char* relationFilter = argc >= 5 ? argv[4] : "";
            const int limit = argc >= 6 ? std::atoi(argv[5]) : 100;
            const int rc = cprag_export_dot(handle, nodeFilter, relationFilter, limit, buffer.data(), buffer.size());
            if (rc != CPRAG_OK) {
                return fail(rc, handle);
            }
            std::cout << buffer.data();
            return 0;
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
