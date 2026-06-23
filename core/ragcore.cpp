#include "crexx_rag/ragcore.h"

#include "chunker.h"

#include <sqlite3.h>

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iomanip>
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

struct DocumentSummary {
    long long id {0};
    std::string sourceUri;
    std::string title;
    std::string contentHash;
    int fileType {CPRAG_CHUNK_PLAIN_TEXT};
    std::string metadataJson;
    long long chunkCount {0};
    std::string createdAt;
    std::string updatedAt;
};

struct ChunkHit {
    long long id {0};
    long long documentId {0};
    std::string sourceUri;
    std::string title;
    int chunkIndex {0};
    std::string text;
    int length {0};
    double rank {0.0};
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
CREATE TABLE IF NOT EXISTS documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_uri TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    content_hash TEXT NOT NULL,
    file_type INTEGER NOT NULL DEFAULT 0,
    metadata_json TEXT NOT NULL DEFAULT '{}',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS chunks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_id INTEGER NOT NULL,
    chunk_index INTEGER NOT NULL,
    text TEXT NOT NULL,
    length INTEGER NOT NULL,
    start_offset INTEGER NOT NULL DEFAULT -1,
    end_offset INTEGER NOT NULL DEFAULT -1,
    metadata_json TEXT NOT NULL DEFAULT '{}',
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    UNIQUE(document_id, chunk_index)
);
CREATE INDEX IF NOT EXISTS idx_documents_source_uri ON documents(source_uri);
CREATE INDEX IF NOT EXISTS idx_chunks_document ON chunks(document_id, chunk_index);
CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(
    text,
    source_uri UNINDEXED,
    title UNINDEXED,
    content='chunks',
    content_rowid='id'
);
CREATE TRIGGER IF NOT EXISTS chunks_ai AFTER INSERT ON chunks BEGIN
    INSERT INTO chunks_fts(rowid, text, source_uri, title)
    SELECT new.id, new.text, documents.source_uri, documents.title
    FROM documents
    WHERE documents.id = new.document_id;
END;
CREATE TRIGGER IF NOT EXISTS chunks_ad AFTER DELETE ON chunks BEGIN
    INSERT INTO chunks_fts(chunks_fts, rowid, text, source_uri, title)
    SELECT 'delete', old.id, old.text, documents.source_uri, documents.title
    FROM documents
    WHERE documents.id = old.document_id;
END;
CREATE TRIGGER IF NOT EXISTS chunks_au AFTER UPDATE ON chunks BEGIN
    INSERT INTO chunks_fts(chunks_fts, rowid, text, source_uri, title)
    SELECT 'delete', old.id, old.text, documents.source_uri, documents.title
    FROM documents
    WHERE documents.id = old.document_id;
    INSERT INTO chunks_fts(rowid, text, source_uri, title)
    SELECT new.id, new.text, documents.source_uri, documents.title
    FROM documents
    WHERE documents.id = new.document_id;
END;
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

std::string metadataOrDefault(const char* metadataJson)
{
    const std::string metadata = valueOrEmpty(metadataJson);
    return metadata.empty() ? "{}" : metadata;
}

int validateMetadataJson(cprag_handle* handle, const std::string& metadata)
{
    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(
        handle,
        "SELECT CASE WHEN json_valid(?) THEN json_type(?) = 'object' ELSE 0 END",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    bindText(stmt, 1, metadata);
    bindText(stmt, 2, metadata);
    const int stepRc = sqlite3_step(stmt);
    const bool valid = stepRc == SQLITE_ROW && sqlite3_column_int(stmt, 0) != 0;
    sqlite3_finalize(stmt);
    if (!valid) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "metadata_json must be a valid JSON object");
    }
    return CPRAG_OK;
}

std::string fnv1a64Hex(const std::string& text)
{
    uint64_t value = 14695981039346656037ull;
    for (const unsigned char ch : text) {
        value ^= ch;
        value *= 1099511628211ull;
    }

    std::ostringstream out;
    out << std::hex << std::setw(16) << std::setfill('0') << value;
    return out.str();
}

long long countRows(cprag_handle* handle, const char* tableName)
{
    std::string sql = "SELECT COUNT(*) FROM ";
    sql += tableName;
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle, sql.c_str(), &stmt) != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    long long count = 0;
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        count = sqlite3_column_int64(stmt, 0);
    }
    sqlite3_finalize(stmt);
    return count;
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

std::vector<DocumentSummary> loadDocumentSummaries(cprag_handle* handle)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle,
            "SELECT d.id, d.source_uri, d.title, d.content_hash, d.file_type, d.metadata_json, "
            "COUNT(c.id) AS chunk_count, d.created_at, d.updated_at "
            "FROM documents d "
            "LEFT JOIN chunks c ON c.document_id = d.id "
            "GROUP BY d.id, d.source_uri, d.title, d.content_hash, d.file_type, d.metadata_json, d.created_at, d.updated_at "
            "ORDER BY d.source_uri",
            &stmt)
        != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    std::vector<DocumentSummary> documents;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        DocumentSummary document;
        document.id = sqlite3_column_int64(stmt, 0);
        document.sourceUri = columnText(stmt, 1);
        document.title = columnText(stmt, 2);
        document.contentHash = columnText(stmt, 3);
        document.fileType = sqlite3_column_int(stmt, 4);
        document.metadataJson = columnText(stmt, 5);
        document.chunkCount = sqlite3_column_int64(stmt, 6);
        document.createdAt = columnText(stmt, 7);
        document.updatedAt = columnText(stmt, 8);
        documents.push_back(std::move(document));
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        throw std::runtime_error(sqliteError(handle->db));
    }
    return documents;
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

std::string ftsQueryForText(const std::string& text)
{
    std::vector<std::string> tokens;
    std::string current;
    for (const char ch : text) {
        const unsigned char uch = static_cast<unsigned char>(ch);
        if (std::isalnum(uch) != 0 || ch == '_') {
            current.push_back(static_cast<char>(std::tolower(uch)));
        } else if (!current.empty()) {
            tokens.push_back(current);
            current.clear();
        }
    }
    if (!current.empty()) {
        tokens.push_back(current);
    }

    std::sort(tokens.begin(), tokens.end());
    tokens.erase(std::unique(tokens.begin(), tokens.end()), tokens.end());

    std::ostringstream out;
    for (const std::string& token : tokens) {
        if (token.empty()) {
            continue;
        }
        if (out.tellp() > 0) {
            out << " OR ";
        }
        out << token << '*';
    }
    return out.str();
}

std::vector<ChunkHit> searchChunks(cprag_handle* handle, const std::string& query, int limit)
{
    const std::string ftsQuery = ftsQueryForText(query);
    if (ftsQuery.empty() || limit <= 0) {
        return {};
    }

    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle,
            "SELECT c.id, c.document_id, d.source_uri, d.title, c.chunk_index, c.text, c.length, bm25(chunks_fts) AS rank "
            "FROM chunks_fts "
            "JOIN chunks c ON c.id = chunks_fts.rowid "
            "JOIN documents d ON d.id = c.document_id "
            "WHERE chunks_fts MATCH ? "
            "ORDER BY rank "
            "LIMIT ?",
            &stmt)
        != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    bindText(stmt, 1, ftsQuery);
    sqlite3_bind_int(stmt, 2, limit);

    std::vector<ChunkHit> chunks;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        ChunkHit chunk;
        chunk.id = sqlite3_column_int64(stmt, 0);
        chunk.documentId = sqlite3_column_int64(stmt, 1);
        chunk.sourceUri = columnText(stmt, 2);
        chunk.title = columnText(stmt, 3);
        chunk.chunkIndex = sqlite3_column_int(stmt, 4);
        chunk.text = columnText(stmt, 5);
        chunk.length = sqlite3_column_int(stmt, 6);
        chunk.rank = sqlite3_column_double(stmt, 7);
        chunks.push_back(std::move(chunk));
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        throw std::runtime_error(sqliteError(handle->db));
    }
    return chunks;
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
    const std::string& relationFilterCsv,
    const std::vector<ChunkHit>& chunkHits)
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

    out << "],\"chunks\":[";
    for (size_t i = 0; i < chunkHits.size(); ++i) {
        const ChunkHit& chunk = chunkHits[i];
        if (i != 0) {
            out << ',';
        }
        out << "{\"id\":" << chunk.id
            << ",\"document_id\":" << chunk.documentId
            << ",\"source_uri\":" << jsonString(chunk.sourceUri)
            << ",\"title\":" << jsonString(chunk.title)
            << ",\"chunk_index\":" << chunk.chunkIndex
            << ",\"text\":" << jsonString(chunk.text)
            << ",\"length\":" << chunk.length
            << ",\"rank\":" << chunk.rank
            << '}';
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

cprag::ChunkFileType chunkFileTypeFromInt(int fileType)
{
    if (fileType == CPRAG_CHUNK_CODE_REXX) {
        return cprag::ChunkFileType::CodeRexx;
    }
    if (fileType == CPRAG_CHUNK_MARKDOWN) {
        return cprag::ChunkFileType::Markdown;
    }
    return cprag::ChunkFileType::PlainText;
}

int selectDocumentId(cprag_handle* handle, const std::string& sourceUri, long long* outId)
{
    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle, "SELECT id FROM documents WHERE source_uri = ?", &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }
    bindText(stmt, 1, sourceUri);
    const int stepRc = sqlite3_step(stmt);
    if (stepRc == SQLITE_ROW) {
        *outId = sqlite3_column_int64(stmt, 0);
        sqlite3_finalize(stmt);
        return CPRAG_OK;
    }
    sqlite3_finalize(stmt);
    return setErrorCode(handle, CPRAG_NOT_FOUND, "document was not found after ingest");
}

int upsertDocument(
    cprag_handle* handle,
    const std::string& sourceUri,
    const std::string& title,
    const std::string& contentHash,
    int fileType,
    const std::string& metadata,
    long long* outId)
{
    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle,
        "INSERT INTO documents (source_uri, title, content_hash, file_type, metadata_json) "
        "VALUES (?, ?, ?, ?, ?) "
        "ON CONFLICT(source_uri) DO UPDATE SET "
        "title=excluded.title, content_hash=excluded.content_hash, file_type=excluded.file_type, "
        "metadata_json=excluded.metadata_json, updated_at=CURRENT_TIMESTAMP",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    bindText(stmt, 1, sourceUri);
    bindText(stmt, 2, title);
    bindText(stmt, 3, contentHash);
    sqlite3_bind_int(stmt, 4, fileType);
    bindText(stmt, 5, metadata);

    const int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return selectDocumentId(handle, sourceUri, outId);
}

int deleteDocumentChunks(cprag_handle* handle, long long documentId)
{
    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle, "DELETE FROM chunks WHERE document_id = ?", &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }
    sqlite3_bind_int64(stmt, 1, documentId);
    const int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return CPRAG_OK;
}

std::pair<long long, long long> locateChunkOffsets(
    const std::string& text,
    const std::string& chunk,
    int chunkOverlap,
    size_t* searchStart)
{
    if (chunk.empty()) {
        return {-1, -1};
    }

    size_t begin = text.find(chunk, std::min(*searchStart, text.size()));
    if (begin == std::string::npos) {
        begin = text.find(chunk);
    }
    if (begin == std::string::npos) {
        return {-1, -1};
    }

    const size_t end = begin + chunk.size();
    const size_t rewind = chunkOverlap <= 0 ? 0 : std::min(static_cast<size_t>(chunkOverlap + 128), chunk.size());
    *searchStart = end > rewind ? end - rewind : end;
    return {static_cast<long long>(begin), static_cast<long long>(end)};
}

int insertChunkRows(
    cprag_handle* handle,
    long long documentId,
    const std::string& text,
    const std::vector<std::string>& chunks,
    int chunkOverlap,
    std::vector<long long>* chunkIds)
{
    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle,
        "INSERT INTO chunks (document_id, chunk_index, text, length, start_offset, end_offset, metadata_json) "
        "VALUES (?, ?, ?, ?, ?, ?, '{}')",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    size_t searchStart = 0;
    for (size_t i = 0; i < chunks.size(); ++i) {
        const auto offsets = locateChunkOffsets(text, chunks[i], chunkOverlap, &searchStart);
        sqlite3_reset(stmt);
        sqlite3_clear_bindings(stmt);
        sqlite3_bind_int64(stmt, 1, documentId);
        sqlite3_bind_int(stmt, 2, static_cast<int>(i));
        bindText(stmt, 3, chunks[i]);
        sqlite3_bind_int(stmt, 4, static_cast<int>(chunks[i].size()));
        sqlite3_bind_int64(stmt, 5, offsets.first);
        sqlite3_bind_int64(stmt, 6, offsets.second);

        const int stepRc = sqlite3_step(stmt);
        if (stepRc != SQLITE_DONE) {
            sqlite3_finalize(stmt);
            return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
        }
        chunkIds->push_back(sqlite3_last_insert_rowid(handle->db));
    }

    sqlite3_finalize(stmt);
    return CPRAG_OK;
}

std::string buildIngestJson(
    long long documentId,
    const std::string& sourceUri,
    const std::string& title,
    const std::string& contentHash,
    int fileType,
    const std::string& metadata,
    const std::vector<std::string>& chunks,
    const std::vector<long long>& chunkIds)
{
    std::ostringstream out;
    out << "{\"success\":true,\"document\":{\"id\":" << documentId
        << ",\"source_uri\":" << jsonString(sourceUri)
        << ",\"title\":" << jsonString(title)
        << ",\"content_hash\":" << jsonString(contentHash)
        << ",\"file_type\":" << fileType
        << ",\"metadata\":" << metadata
        << "},\"chunk_count\":" << chunks.size()
        << ",\"chunks\":[";

    for (size_t i = 0; i < chunks.size(); ++i) {
        if (i != 0) {
            out << ',';
        }
        out << "{\"id\":" << chunkIds[i]
            << ",\"index\":" << i
            << ",\"length\":" << chunks[i].size()
            << '}';
    }
    out << "]}";
    return out.str();
}

std::string buildSourcesJson(const std::vector<DocumentSummary>& documents)
{
    std::ostringstream out;
    out << "{\"success\":true,\"sources\":[";
    for (size_t i = 0; i < documents.size(); ++i) {
        const DocumentSummary& document = documents[i];
        if (i != 0) {
            out << ',';
        }
        out << "{\"id\":" << document.id
            << ",\"source_uri\":" << jsonString(document.sourceUri)
            << ",\"title\":" << jsonString(document.title)
            << ",\"content_hash\":" << jsonString(document.contentHash)
            << ",\"file_type\":" << document.fileType
            << ",\"chunk_count\":" << document.chunkCount
            << ",\"created_at\":" << jsonString(document.createdAt)
            << ",\"updated_at\":" << jsonString(document.updatedAt)
            << ",\"metadata\":" << (document.metadataJson.empty() ? "{}" : document.metadataJson)
            << '}';
    }
    out << "]}";
    return out.str();
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

    const std::vector<std::string> chunks = cprag::chunkText(
        text,
        chunk_size,
        chunk_overlap,
        chunkFileTypeFromInt(file_type));
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

    const std::string metadata = metadataOrDefault(metadata_json);
    const int metadataRc = validateMetadataJson(handle, metadata);
    if (metadataRc != CPRAG_OK) {
        sqlite3_finalize(stmt);
        return metadataRc;
    }
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

    const std::string metadata = metadataOrDefault(metadata_json);
    const int metadataRc = validateMetadataJson(handle, metadata);
    if (metadataRc != CPRAG_OK) {
        sqlite3_finalize(stmt);
        return metadataRc;
    }
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

int cprag_ingest_text(
    cprag_handle* handle,
    const char* source_uri,
    const char* title,
    const char* text,
    int file_type,
    int chunk_size,
    int chunk_overlap,
    const char* metadata_json,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || source_uri == nullptr || text == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }

    const std::string sourceUri(source_uri);
    if (sourceUri.empty()) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "source_uri is required");
    }

    const std::string effectiveTitle = valueOrEmpty(title).empty() ? sourceUri : valueOrEmpty(title);
    const std::string metadata = metadataOrDefault(metadata_json);
    const int metadataRc = validateMetadataJson(handle, metadata);
    if (metadataRc != CPRAG_OK) {
        return metadataRc;
    }

    const std::string content(text);
    const std::string contentHash = fnv1a64Hex(content);
    const int effectiveChunkSize = chunk_size <= 0 ? 1000 : chunk_size;
    const int effectiveOverlap = chunk_overlap < 0 ? 0 : chunk_overlap;
    const std::vector<std::string> chunks = cprag::chunkText(
        content,
        effectiveChunkSize,
        effectiveOverlap,
        chunkFileTypeFromInt(file_type));

    const int beginRc = execSql(handle, "BEGIN IMMEDIATE TRANSACTION");
    if (beginRc != CPRAG_OK) {
        return beginRc;
    }

    long long documentId = 0;
    int rc = upsertDocument(handle, sourceUri, effectiveTitle, contentHash, file_type, metadata, &documentId);
    if (rc == CPRAG_OK) {
        rc = deleteDocumentChunks(handle, documentId);
    }

    std::vector<long long> chunkIds;
    if (rc == CPRAG_OK) {
        rc = insertChunkRows(handle, documentId, content, chunks, effectiveOverlap, &chunkIds);
    }

    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }

    rc = execSql(handle, "COMMIT");
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }

    return copyJson(
        handle,
        buildIngestJson(documentId, sourceUri, effectiveTitle, contentHash, file_type, metadata, chunks, chunkIds),
        out_json,
        out_json_size);
}

int cprag_list_sources(cprag_handle* handle, char* out_json, size_t out_json_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        return copyJson(handle, buildSourcesJson(loadDocumentSummaries(handle)), out_json, out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
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
        const std::vector<ChunkHit> chunks = searchChunks(handle, query, effectiveTopK);
        const std::string json = buildSubgraphJson(loadEntities(handle), loadEdges(handle), anchors, effectiveHops, "", chunks);
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
            valueOrEmpty(relation_filter_csv),
            {});
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
    long long documentCount = 0;
    long long chunkCount = 0;

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

    if (prepare(handle, "SELECT COUNT(*) FROM documents", &stmt) != CPRAG_OK) {
        return CPRAG_DATABASE_ERROR;
    }
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        documentCount = sqlite3_column_int64(stmt, 0);
    }
    sqlite3_finalize(stmt);

    if (prepare(handle, "SELECT COUNT(*) FROM chunks", &stmt) != CPRAG_OK) {
        return CPRAG_DATABASE_ERROR;
    }
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        chunkCount = sqlite3_column_int64(stmt, 0);
    }
    sqlite3_finalize(stmt);

    std::ostringstream out;
    out << "{\"success\":true,\"entities\":" << entityCount
        << ",\"edges\":" << edgeCount
        << ",\"documents\":" << documentCount
        << ",\"chunks\":" << chunkCount
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
