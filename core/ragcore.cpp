#include "crexx_rag/ragcore.h"

#include "chunker.h"

#include <sqlite3.h>

#include <algorithm>
#include <cctype>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <limits>
#include <queue>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

struct cprag_handle {
    std::filesystem::path libraryPath;
    sqlite3* db {nullptr};
    bool readOnly {false};
    std::string lastError;
};

namespace {

struct Entity {
    std::string id;
    std::string label;
    std::string description;
    std::string metadataJson;
};

struct Edge {
    long long rowid {0};
    std::string sourceId;
    std::string targetId;
    std::string label;
    double weight {1.0};
    std::string metadataJson;
};

struct Anchor {
    std::string id;
    double score {0.0};
};

std::filesystem::path dbPathForLibrary(const std::filesystem::path& libraryPath)
{
    return libraryPath / "library.sqlite";
}

std::string valueOrEmpty(const char* value)
{
    return value == nullptr ? std::string() : std::string(value);
}

void setError(cprag_handle* handle, const std::string& message)
{
    if (handle != nullptr) {
        handle->lastError = message;
    }
}

int setErrorCode(cprag_handle* handle, int code, const std::string& message)
{
    setError(handle, message);
    return code;
}

std::string sqliteError(sqlite3* db)
{
    const char* message = db == nullptr ? nullptr : sqlite3_errmsg(db);
    return message == nullptr ? "unknown SQLite error" : message;
}

int execSql(cprag_handle* handle, const char* sql)
{
    char* err = nullptr;
    const int rc = sqlite3_exec(handle->db, sql, nullptr, nullptr, &err);
    if (rc != SQLITE_OK) {
        const std::string message = err == nullptr ? sqliteError(handle->db) : std::string(err);
        sqlite3_free(err);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, message);
    }
    return CPRAG_OK;
}

int createSchema(cprag_handle* handle)
{
    static constexpr const char* kSchema = R"SQL(
PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS entities (
    id TEXT PRIMARY KEY,
    label TEXT NOT NULL,
    description TEXT NOT NULL,
    metadata_json TEXT NOT NULL DEFAULT '{}'
);
CREATE TABLE IF NOT EXISTS edges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_id TEXT NOT NULL,
    target_id TEXT NOT NULL,
    label TEXT NOT NULL,
    weight REAL NOT NULL DEFAULT 1.0,
    metadata_json TEXT NOT NULL DEFAULT '{}',
    FOREIGN KEY (source_id) REFERENCES entities(id) ON DELETE CASCADE,
    FOREIGN KEY (target_id) REFERENCES entities(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_edges_source ON edges(source_id);
CREATE INDEX IF NOT EXISTS idx_edges_target ON edges(target_id);
)SQL";
    return execSql(handle, kSchema);
}

bool bindText(sqlite3_stmt* stmt, int index, const std::string& value)
{
    return sqlite3_bind_text(stmt, index, value.c_str(), static_cast<int>(value.size()), SQLITE_TRANSIENT) == SQLITE_OK;
}

std::string columnText(sqlite3_stmt* stmt, int index)
{
    const unsigned char* text = sqlite3_column_text(stmt, index);
    return text == nullptr ? std::string() : reinterpret_cast<const char*>(text);
}

int prepare(cprag_handle* handle, const char* sql, sqlite3_stmt** outStmt)
{
    const int rc = sqlite3_prepare_v2(handle->db, sql, -1, outStmt, nullptr);
    if (rc != SQLITE_OK) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return CPRAG_OK;
}

std::vector<Entity> loadEntities(cprag_handle* handle)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle, "SELECT id, label, description, metadata_json FROM entities", &stmt) != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    std::vector<Entity> entities;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Entity entity;
        entity.id = columnText(stmt, 0);
        entity.label = columnText(stmt, 1);
        entity.description = columnText(stmt, 2);
        entity.metadataJson = columnText(stmt, 3);
        entities.push_back(std::move(entity));
    }
    sqlite3_finalize(stmt);
    return entities;
}

std::vector<Edge> loadEdges(cprag_handle* handle)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle, "SELECT id, source_id, target_id, label, weight, metadata_json FROM edges", &stmt) != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    std::vector<Edge> edges;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Edge edge;
        edge.rowid = sqlite3_column_int64(stmt, 0);
        edge.sourceId = columnText(stmt, 1);
        edge.targetId = columnText(stmt, 2);
        edge.label = columnText(stmt, 3);
        edge.weight = sqlite3_column_double(stmt, 4);
        edge.metadataJson = columnText(stmt, 5);
        edges.push_back(std::move(edge));
    }
    sqlite3_finalize(stmt);
    return edges;
}

std::string jsonEscape(const std::string& input)
{
    std::ostringstream out;
    for (const unsigned char ch : input) {
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
                out << "\\u";
                static constexpr char kHex[] = "0123456789abcdef";
                out << "00" << kHex[(ch >> 4) & 0x0f] << kHex[ch & 0x0f];
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

std::vector<std::string> splitCsv(const std::string& input)
{
    std::vector<std::string> parts;
    std::string current;
    std::istringstream stream(input);
    while (std::getline(stream, current, ',')) {
        const auto first = std::find_if_not(current.begin(), current.end(), [](unsigned char c) {
            return std::isspace(c) != 0;
        });
        const auto last = std::find_if_not(current.rbegin(), current.rend(), [](unsigned char c) {
            return std::isspace(c) != 0;
        }).base();
        if (first < last) {
            parts.emplace_back(first, last);
        }
    }
    return parts;
}

std::vector<std::string> tokenize(std::string text)
{
    std::vector<std::string> tokens;
    std::string current;
    for (char& ch : text) {
        const unsigned char uch = static_cast<unsigned char>(ch);
        if (std::isalnum(uch) != 0 || ch == '_' || ch == '-') {
            current.push_back(static_cast<char>(std::tolower(uch)));
        } else if (!current.empty()) {
            tokens.push_back(current);
            current.clear();
        }
    }
    if (!current.empty()) {
        tokens.push_back(current);
    }
    return tokens;
}

double scoreEntity(const std::string& query, const Entity& entity)
{
    const std::vector<std::string> queryTokens = tokenize(query);
    if (queryTokens.empty()) {
        return 0.0;
    }

    std::string haystack = entity.id + " " + entity.label + " " + entity.description;
    std::transform(haystack.begin(), haystack.end(), haystack.begin(), [](unsigned char c) {
        return static_cast<char>(std::tolower(c));
    });

    double score = 0.0;
    for (const std::string& token : queryTokens) {
        if (haystack.find(token) != std::string::npos) {
            score += 1.0;
        }
    }

    return score / static_cast<double>(queryTokens.size());
}

std::vector<Anchor> findAnchors(cprag_handle* handle, const std::string& query, int topK)
{
    std::vector<Anchor> anchors;
    for (const Entity& entity : loadEntities(handle)) {
        const double score = scoreEntity(query, entity);
        if (score <= 0.0) {
            continue;
        }
        anchors.push_back({entity.id, score});
    }

    std::sort(anchors.begin(), anchors.end(), [](const Anchor& lhs, const Anchor& rhs) {
        if (std::abs(lhs.score - rhs.score) < std::numeric_limits<double>::epsilon()) {
            return lhs.id < rhs.id;
        }
        return lhs.score > rhs.score;
    });

    if (topK > 0 && static_cast<int>(anchors.size()) > topK) {
        anchors.resize(static_cast<size_t>(topK));
    }
    return anchors;
}

std::unordered_set<std::string> relationFilterSet(const std::string& filterCsv)
{
    std::unordered_set<std::string> filters;
    for (std::string value : splitCsv(filterCsv)) {
        std::transform(value.begin(), value.end(), value.begin(), [](unsigned char c) {
            return static_cast<char>(std::tolower(c));
        });
        filters.insert(std::move(value));
    }
    return filters;
}

bool edgeAllowed(const Edge& edge, const std::unordered_set<std::string>& filters)
{
    if (filters.empty()) {
        return true;
    }
    std::string label = edge.label;
    std::transform(label.begin(), label.end(), label.begin(), [](unsigned char c) {
        return static_cast<char>(std::tolower(c));
    });
    return filters.find(label) != filters.end();
}

std::string buildSubgraphJson(
    const std::vector<Entity>& entities,
    const std::vector<Edge>& edges,
    const std::vector<Anchor>& anchors,
    int hops,
    const std::string& relationFilterCsv)
{
    std::unordered_map<std::string, Entity> entityById;
    for (const Entity& entity : entities) {
        entityById.emplace(entity.id, entity);
    }

    const auto filters = relationFilterSet(relationFilterCsv);
    std::unordered_set<std::string> visitedNodes;
    std::unordered_set<long long> visitedEdges;
    std::queue<std::pair<std::string, int>> queue;

    for (const Anchor& anchor : anchors) {
        if (entityById.find(anchor.id) == entityById.end()) {
            continue;
        }
        visitedNodes.insert(anchor.id);
        queue.push({anchor.id, 0});
    }

    while (!queue.empty()) {
        const auto [current, depth] = queue.front();
        queue.pop();
        if (depth >= hops) {
            continue;
        }

        for (const Edge& edge : edges) {
            if (!edgeAllowed(edge, filters)) {
                continue;
            }

            std::string next;
            if (edge.sourceId == current) {
                next = edge.targetId;
            } else if (edge.targetId == current) {
                next = edge.sourceId;
            } else {
                continue;
            }

            visitedEdges.insert(edge.rowid);
            if (visitedNodes.insert(next).second) {
                queue.push({next, depth + 1});
            }
        }
    }

    std::ostringstream out;
    out << "{\"success\":true,\"anchors\":[";
    for (size_t i = 0; i < anchors.size(); ++i) {
        const Anchor& anchor = anchors[i];
        if (i != 0) {
            out << ',';
        }
        out << "{\"id\":" << jsonString(anchor.id) << ",\"score\":" << anchor.score << '}';
    }

    out << "],\"subgraph\":{\"nodes\":[";
    bool first = true;
    std::vector<std::string> sortedNodeIds(visitedNodes.begin(), visitedNodes.end());
    std::sort(sortedNodeIds.begin(), sortedNodeIds.end());
    for (const std::string& nodeId : sortedNodeIds) {
        const auto it = entityById.find(nodeId);
        if (it == entityById.end()) {
            continue;
        }
        if (!first) {
            out << ',';
        }
        first = false;
        const Entity& entity = it->second;
        out << "{\"id\":" << jsonString(entity.id)
            << ",\"label\":" << jsonString(entity.label)
            << ",\"description\":" << jsonString(entity.description)
            << ",\"metadata\":" << (entity.metadataJson.empty() ? "{}" : entity.metadataJson)
            << '}';
    }

    out << "],\"edges\":[";
    first = true;
    for (const Edge& edge : edges) {
        if (visitedEdges.find(edge.rowid) == visitedEdges.end()) {
            continue;
        }
        if (!first) {
            out << ',';
        }
        first = false;
        out << "{\"id\":" << edge.rowid
            << ",\"source\":" << jsonString(edge.sourceId)
            << ",\"target\":" << jsonString(edge.targetId)
            << ",\"label\":" << jsonString(edge.label)
            << ",\"weight\":" << edge.weight
            << ",\"metadata\":" << (edge.metadataJson.empty() ? "{}" : edge.metadataJson)
            << '}';
    }
    out << "]}}";
    return out.str();
}

int copyJson(cprag_handle* handle, const std::string& json, char* outJson, size_t outJsonSize)
{
    if (outJson == nullptr || outJsonSize == 0) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "output buffer is required");
    }
    if (json.size() + 1 > outJsonSize) {
        return setErrorCode(handle, CPRAG_BUFFER_TOO_SMALL, "output buffer is too small");
    }
    std::copy(json.begin(), json.end(), outJson);
    outJson[json.size()] = '\0';
    return CPRAG_OK;
}

int initLibraryPath(const std::filesystem::path& libraryPath, std::string* error)
{
    try {
        std::filesystem::create_directories(libraryPath);
        std::ofstream manifest(libraryPath / "manifest.json", std::ios::trunc);
        manifest << "{\n"
                 << "  \"format\": \"crexx-rag-library\",\n"
                 << "  \"version\": 1,\n"
                 << "  \"vector_index\": \"planned-faiss\",\n"
                 << "  \"database\": \"library.sqlite\"\n"
                 << "}\n";
        return CPRAG_OK;
    } catch (const std::exception& ex) {
        if (error != nullptr) {
            *error = ex.what();
        }
        return CPRAG_IO_ERROR;
    }
}

} // namespace

extern "C" {

int cprag_open(const char* library_path, unsigned flags, cprag_handle** out_handle)
{
    if (library_path == nullptr || out_handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    auto handle = new cprag_handle();
    handle->libraryPath = std::filesystem::path(library_path);
    handle->readOnly = flags == CPRAG_OPEN_READONLY;

    std::string initError;
    if (!handle->readOnly) {
        const int initRc = initLibraryPath(handle->libraryPath, &initError);
        if (initRc != CPRAG_OK) {
            delete handle;
            return initRc;
        }
    }

    const int openFlags = handle->readOnly
        ? SQLITE_OPEN_READONLY
        : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);

    const std::filesystem::path dbPath = dbPathForLibrary(handle->libraryPath);
    const int rc = sqlite3_open_v2(dbPath.string().c_str(), &handle->db, openFlags, nullptr);
    if (rc != SQLITE_OK) {
        delete handle;
        return CPRAG_DATABASE_ERROR;
    }

    if (!handle->readOnly) {
        const int schemaRc = createSchema(handle);
        if (schemaRc != CPRAG_OK) {
            sqlite3_close(handle->db);
            delete handle;
            return schemaRc;
        }
    }

    *out_handle = handle;
    return CPRAG_OK;
}

void cprag_close(cprag_handle* handle)
{
    if (handle == nullptr) {
        return;
    }
    if (handle->db != nullptr) {
        sqlite3_close(handle->db);
    }
    delete handle;
}

const char* cprag_last_error(cprag_handle* handle)
{
    if (handle == nullptr) {
        return "no handle";
    }
    return handle->lastError.c_str();
}

int cprag_init_library(const char* library_path)
{
    if (library_path == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    cprag_handle* handle = nullptr;
    const int rc = cprag_open(library_path, CPRAG_OPEN_READWRITE, &handle);
    cprag_close(handle);
    return rc;
}

int cprag_chunk_text(
    const char* text,
    int chunk_size,
    int chunk_overlap,
    int file_type,
    char* out_json,
    size_t out_json_size)
{
    cprag_handle tempHandle;
    if (text == nullptr) {
        return setErrorCode(&tempHandle, CPRAG_INVALID_ARGUMENT, "text is required");
    }

    cprag::ChunkFileType type = cprag::ChunkFileType::PlainText;
    if (file_type == CPRAG_CHUNK_CODE_REXX) {
        type = cprag::ChunkFileType::CodeRexx;
    } else if (file_type == CPRAG_CHUNK_MARKDOWN) {
        type = cprag::ChunkFileType::Markdown;
    }

    const std::vector<std::string> chunks = cprag::chunkText(text, chunk_size, chunk_overlap, type);
    std::ostringstream out;
    out << "{\"success\":true,\"chunks\":[";
    for (size_t i = 0; i < chunks.size(); ++i) {
        if (i != 0) {
            out << ',';
        }
        out << "{\"index\":" << i
            << ",\"text\":" << jsonString(chunks[i])
            << ",\"length\":" << chunks[i].size()
            << '}';
    }
    out << "]}";

    return copyJson(&tempHandle, out.str(), out_json, out_json_size);
}

int cprag_add_entity(
    cprag_handle* handle,
    const char* id,
    const char* label,
    const char* description,
    const char* metadata_json)
{
    if (handle == nullptr || id == nullptr || label == nullptr || description == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }

    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle,
        "INSERT INTO entities (id, label, description, metadata_json) VALUES (?, ?, ?, ?) "
        "ON CONFLICT(id) DO UPDATE SET label=excluded.label, description=excluded.description, metadata_json=excluded.metadata_json",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    const std::string metadata = valueOrEmpty(metadata_json).empty() ? "{}" : valueOrEmpty(metadata_json);
    bindText(stmt, 1, id);
    bindText(stmt, 2, label);
    bindText(stmt, 3, description);
    bindText(stmt, 4, metadata);

    const int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return CPRAG_OK;
}

int cprag_add_edge(
    cprag_handle* handle,
    const char* source_id,
    const char* target_id,
    const char* label,
    double weight,
    const char* metadata_json)
{
    if (handle == nullptr || source_id == nullptr || target_id == nullptr || label == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }

    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle,
        "INSERT INTO edges (source_id, target_id, label, weight, metadata_json) VALUES (?, ?, ?, ?, ?)",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    const std::string metadata = valueOrEmpty(metadata_json).empty() ? "{}" : valueOrEmpty(metadata_json);
    bindText(stmt, 1, source_id);
    bindText(stmt, 2, target_id);
    bindText(stmt, 3, label);
    sqlite3_bind_double(stmt, 4, weight);
    bindText(stmt, 5, metadata);

    const int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return CPRAG_OK;
}

int cprag_search(
    cprag_handle* handle,
    const char* query,
    int top_k,
    int hops,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || query == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        const int effectiveTopK = top_k <= 0 ? 3 : top_k;
        const int effectiveHops = hops < 0 ? 0 : hops;
        const std::vector<Anchor> anchors = findAnchors(handle, query, effectiveTopK);
        const std::string json = buildSubgraphJson(loadEntities(handle), loadEdges(handle), anchors, effectiveHops, "");
        return copyJson(handle, json, out_json, out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
}

int cprag_expand(
    cprag_handle* handle,
    const char* anchors_csv,
    int hops,
    const char* relation_filter_csv,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || anchors_csv == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        std::vector<Anchor> anchors;
        for (const std::string& id : splitCsv(anchors_csv)) {
            anchors.push_back({id, 1.0});
        }
        const int effectiveHops = hops < 0 ? 0 : hops;
        const std::string json = buildSubgraphJson(
            loadEntities(handle),
            loadEdges(handle),
            anchors,
            effectiveHops,
            valueOrEmpty(relation_filter_csv));
        return copyJson(handle, json, out_json, out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
}

int cprag_stats(cprag_handle* handle, char* out_json, size_t out_json_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    sqlite3_stmt* stmt = nullptr;
    long long entityCount = 0;
    long long edgeCount = 0;

    if (prepare(handle, "SELECT COUNT(*) FROM entities", &stmt) != CPRAG_OK) {
        return CPRAG_DATABASE_ERROR;
    }
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        entityCount = sqlite3_column_int64(stmt, 0);
    }
    sqlite3_finalize(stmt);

    if (prepare(handle, "SELECT COUNT(*) FROM edges", &stmt) != CPRAG_OK) {
        return CPRAG_DATABASE_ERROR;
    }
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        edgeCount = sqlite3_column_int64(stmt, 0);
    }
    sqlite3_finalize(stmt);

    std::ostringstream out;
    out << "{\"success\":true,\"entities\":" << entityCount
        << ",\"edges\":" << edgeCount
        << ",\"library\":" << jsonString(handle->libraryPath.string())
        << '}';
    return copyJson(handle, out.str(), out_json, out_json_size);
}

const char* cprag_status_message(int code)
{
    switch (code) {
    case CPRAG_OK:
        return "ok";
    case CPRAG_INVALID_ARGUMENT:
        return "invalid argument";
    case CPRAG_IO_ERROR:
        return "I/O error";
    case CPRAG_DATABASE_ERROR:
        return "database error";
    case CPRAG_NOT_FOUND:
        return "not found";
    case CPRAG_BUFFER_TOO_SMALL:
        return "buffer too small";
    case CPRAG_INTERNAL_ERROR:
        return "internal error";
    default:
        return "unknown error";
    }
}

} // extern "C"
