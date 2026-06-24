#include "crexx_rag/ragcore.h"

#include "chunker.h"

#include <sqlite3.h>

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <limits>
#include <memory>
#include <queue>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

#ifdef CPRAG_HAVE_FAISS
#include <faiss/IndexFlat.h>
#include <faiss/IndexIDMap.h>
#include <faiss/index_io.h>
#endif

struct cprag_handle {
    std::filesystem::path libraryPath;
    sqlite3* db {nullptr};
    bool readOnly {false};
    std::string lastError;
};

namespace {

struct Entity {
    std::string id;
    std::string nodeType;
    std::string label;
    std::string description;
    std::string metadataJson;
};

struct Edge {
    long long rowid {0};
    std::string sourceId;
    std::string targetId;
    std::string relationshipType;
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
    std::string sourceType;
    double confidence {1.0};
    std::string capturedAt;
    std::string eventStartAt;
    std::string eventEndAt;
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
    std::string sourceType;
    double confidence {1.0};
    std::string capturedAt;
    std::string eventStartAt;
    std::string eventEndAt;
    double rank {0.0};
    std::string retrieval;
    bool hasVectorDistance {false};
    double vectorDistance {0.0};
};

struct StoredChunk {
    long long id {0};
    long long documentId {0};
    std::string sourceUri;
    std::string title;
    int chunkIndex {0};
    std::string text;
    int length {0};
    long long startOffset {-1};
    long long endOffset {-1};
    std::string sourceType;
    double confidence {1.0};
    std::string capturedAt;
    std::string eventStartAt;
    std::string eventEndAt;
    std::string metadataJson;
};

struct ChunkEmbedding {
    long long chunkId {0};
    int dimension {0};
    std::string embeddingProfile;
    std::vector<float> vector;
};

struct VectorIndexState {
    bool present {false};
    std::string embeddingModel;
    std::string embeddingProfile;
    int dimension {0};
    std::string metric;
    long long embeddingCount {0};
    std::string indexPath;
    std::string backend;
    std::string updatedAt;
};

struct VectorHit {
    StoredChunk chunk;
    double distance {0.0};
    double score {0.0};
};

struct VocabularyItem {
    const char* id;
    const char* label;
    const char* description;
};

constexpr const char* kDefaultSourceType = "unknown";
constexpr const char* kRawEmbeddingProfile = "raw-text-v1";
constexpr const char* kSemanticEmbeddingProfile = "semantic-context-v1";
constexpr const char* kVocabularyProfile = "architecture-provenance-v1";

static constexpr VocabularyItem kArchitectureNodeTypes[] = {
    {"component", "Component", "Deployable or logical software component."},
    {"service", "Service", "Externally meaningful application, business, or platform service."},
    {"capability", "Capability", "Ability or outcome provided by people, process, or technology."},
    {"data-object", "Data object", "Structured information used or produced by the architecture."},
    {"technology-node", "Technology node", "Runtime, host, platform, or infrastructure node."},
    {"deployment-target", "Deployment target", "Environment or target where components run."},
    {"process", "Process", "Operational or business process."},
    {"material", "Material", "Domain material, resource, or physical thing."}
};

static constexpr VocabularyItem kArchitectureRelationshipTypes[] = {
    {"depends-on", "Depends on", "Source requires target to function."},
    {"realizes", "Realizes", "Source implements or fulfills target."},
    {"serves", "Serves", "Source provides behavior or value to target."},
    {"accesses", "Accesses", "Source reads, writes, or otherwise uses target data."},
    {"flows-to", "Flows to", "Information, control, or material flows from source to target."},
    {"composed-of", "Composed of", "Source is structurally composed of target."},
    {"deployed-on", "Deployed on", "Source runs on or is installed on target."},
    {"associated-with", "Associated with", "General intentionally weak relationship."}
};

static constexpr VocabularyItem kSourceTypes[] = {
    {"primary-source", "Primary source", "Original authoritative material, document, system export, or record."},
    {"client-stated", "Client stated", "Information stated directly by a client or stakeholder."},
    {"meeting-note", "Meeting note", "Information captured during or from a meeting."},
    {"decision-record", "Decision record", "A recorded decision, rationale, or accepted outcome."},
    {"derived", "Derived", "Information derived from analysis, transformation, or summarization."},
    {"inferred", "Inferred", "Information inferred by a person, agent, rule, or model."},
    {"external-reference", "External reference", "Information from an outside reference or third-party source."},
    {"unknown", "Unknown", "Source type was not supplied or has not been assessed."}
};

static constexpr VocabularyItem kTemporalRoles[] = {
    {"captured-at", "Captured at", "When this information was gathered or entered into the library."},
    {"event-start-at", "Event start at", "When the represented event, meeting, decision, or validity period starts."},
    {"event-end-at", "Event end at", "When the represented event, meeting, decision, or validity period ends."},
    {"created-at", "Created at", "When the library record was first created."},
    {"updated-at", "Updated at", "When the library record was last updated."}
};

static constexpr VocabularyItem kConfidenceScale[] = {
    {"1.0", "High confidence", "Use for authoritative, directly observed, or otherwise strongly trusted information."},
    {"0.7", "Medium confidence", "Use for plausible information with some uncertainty or indirect support."},
    {"0.4", "Low confidence", "Use for tentative, weakly supported, or partially conflicting information."},
    {"0.0", "Rejected confidence", "Use when information should remain traceable but should not influence retrieval."}
};

static constexpr VocabularyItem kEmbeddingProfiles[] = {
    {"raw-text-v1", "Raw text", "Embed the chunk text as supplied; kept for compatibility and manual vector loading."},
    {"semantic-context-v1", "Semantic context", "Embed a stable envelope containing source type, confidence, timeline fields, title, and chunk text."}
};

std::filesystem::path dbPathForLibrary(const std::filesystem::path& libraryPath)
{
    return libraryPath / "library.sqlite";
}

std::filesystem::path vectorIndexPathForLibrary(const std::filesystem::path& libraryPath)
{
    return libraryPath / "vectors.faiss";
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

int invalidateVectorIndexState(cprag_handle* handle);

bool columnExists(cprag_handle* handle, const std::string& table, const std::string& column)
{
    sqlite3_stmt* stmt = nullptr;
    const std::string sql = "PRAGMA table_info(" + table + ")";
    if (sqlite3_prepare_v2(handle->db, sql.c_str(), -1, &stmt, nullptr) != SQLITE_OK) {
        return false;
    }

    bool found = false;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        const unsigned char* text = sqlite3_column_text(stmt, 1);
        const std::string columnName = text == nullptr ? std::string() : reinterpret_cast<const char*>(text);
        if (columnName == column) {
            found = true;
            break;
        }
    }
    sqlite3_finalize(stmt);
    return found;
}

int ensureColumn(
    cprag_handle* handle,
    const std::string& table,
    const std::string& column,
    const std::string& definition,
    bool* added = nullptr)
{
    if (added != nullptr) {
        *added = false;
    }
    if (columnExists(handle, table, column)) {
        return CPRAG_OK;
    }

    const std::string sql = "ALTER TABLE " + table + " ADD COLUMN " + definition;
    const int rc = execSql(handle, sql.c_str());
    if (rc == CPRAG_OK && added != nullptr) {
        *added = true;
    }
    return rc;
}

int createSchema(cprag_handle* handle)
{
    static constexpr const char* kSchema = R"SQL(
PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS entities (
    id TEXT PRIMARY KEY,
    node_type TEXT NOT NULL DEFAULT 'entity',
    label TEXT NOT NULL,
    description TEXT NOT NULL,
    metadata_json TEXT NOT NULL DEFAULT '{}'
);
CREATE TABLE IF NOT EXISTS edges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_id TEXT NOT NULL,
    target_id TEXT NOT NULL,
    relationship_type TEXT NOT NULL DEFAULT 'relationship',
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
    source_type TEXT NOT NULL DEFAULT 'unknown',
    confidence REAL NOT NULL DEFAULT 1.0,
    captured_at TEXT NOT NULL DEFAULT '',
    event_start_at TEXT NOT NULL DEFAULT '',
    event_end_at TEXT NOT NULL DEFAULT '',
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
    source_type TEXT NOT NULL DEFAULT 'unknown',
    confidence REAL NOT NULL DEFAULT 1.0,
    captured_at TEXT NOT NULL DEFAULT '',
    event_start_at TEXT NOT NULL DEFAULT '',
    event_end_at TEXT NOT NULL DEFAULT '',
    metadata_json TEXT NOT NULL DEFAULT '{}',
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    UNIQUE(document_id, chunk_index)
);
CREATE INDEX IF NOT EXISTS idx_documents_source_uri ON documents(source_uri);
CREATE INDEX IF NOT EXISTS idx_chunks_document ON chunks(document_id, chunk_index);
CREATE TABLE IF NOT EXISTS chunk_embeddings (
    chunk_id INTEGER NOT NULL,
    embedding_model TEXT NOT NULL,
    embedding_profile TEXT NOT NULL DEFAULT 'raw-text-v1',
    dimension INTEGER NOT NULL,
    vector BLOB NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (chunk_id, embedding_model),
    FOREIGN KEY (chunk_id) REFERENCES chunks(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_chunk_embeddings_model ON chunk_embeddings(embedding_model, dimension);
CREATE TABLE IF NOT EXISTS vector_index_state (
    index_name TEXT PRIMARY KEY,
    embedding_model TEXT NOT NULL,
    embedding_profile TEXT NOT NULL DEFAULT 'raw-text-v1',
    dimension INTEGER NOT NULL,
    metric TEXT NOT NULL DEFAULT 'l2',
    embedding_count INTEGER NOT NULL DEFAULT 0,
    index_path TEXT NOT NULL DEFAULT 'vectors.faiss',
    backend TEXT NOT NULL DEFAULT 'faiss',
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
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
    int rc = execSql(handle, kSchema);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bool addedNodeType = false;
    bool addedRelationshipType = false;
    rc = ensureColumn(handle, "entities", "node_type", "node_type TEXT NOT NULL DEFAULT 'entity'", &addedNodeType);
    if (rc != CPRAG_OK) {
        return rc;
    }
    rc = ensureColumn(
        handle,
        "edges",
        "relationship_type",
        "relationship_type TEXT NOT NULL DEFAULT 'relationship'",
        &addedRelationshipType);
    if (rc != CPRAG_OK) {
        return rc;
    }
    const std::pair<const char*, const char*> documentColumns[] = {
        {"source_type", "source_type TEXT NOT NULL DEFAULT 'unknown'"},
        {"confidence", "confidence REAL NOT NULL DEFAULT 1.0"},
        {"captured_at", "captured_at TEXT NOT NULL DEFAULT ''"},
        {"event_start_at", "event_start_at TEXT NOT NULL DEFAULT ''"},
        {"event_end_at", "event_end_at TEXT NOT NULL DEFAULT ''"}
    };
    for (const auto& column : documentColumns) {
        rc = ensureColumn(handle, "documents", column.first, column.second);
        if (rc != CPRAG_OK) {
            return rc;
        }
    }
    const std::pair<const char*, const char*> chunkColumns[] = {
        {"source_type", "source_type TEXT NOT NULL DEFAULT 'unknown'"},
        {"confidence", "confidence REAL NOT NULL DEFAULT 1.0"},
        {"captured_at", "captured_at TEXT NOT NULL DEFAULT ''"},
        {"event_start_at", "event_start_at TEXT NOT NULL DEFAULT ''"},
        {"event_end_at", "event_end_at TEXT NOT NULL DEFAULT ''"}
    };
    for (const auto& column : chunkColumns) {
        rc = ensureColumn(handle, "chunks", column.first, column.second);
        if (rc != CPRAG_OK) {
            return rc;
        }
    }
    rc = ensureColumn(
        handle,
        "chunk_embeddings",
        "embedding_profile",
        "embedding_profile TEXT NOT NULL DEFAULT 'raw-text-v1'");
    if (rc != CPRAG_OK) {
        return rc;
    }
    rc = ensureColumn(
        handle,
        "vector_index_state",
        "embedding_profile",
        "embedding_profile TEXT NOT NULL DEFAULT 'raw-text-v1'");
    if (rc != CPRAG_OK) {
        return rc;
    }
    if (addedNodeType) {
        rc = execSql(handle, "UPDATE entities SET node_type = label WHERE label <> ''");
        if (rc != CPRAG_OK) {
            return rc;
        }
    }
    if (addedRelationshipType) {
        rc = execSql(handle, "UPDATE edges SET relationship_type = label WHERE label <> ''");
        if (rc != CPRAG_OK) {
            return rc;
        }
    }
    return CPRAG_OK;
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

std::string sourceTypeOrDefault(const char* sourceType)
{
    const std::string value = valueOrEmpty(sourceType);
    return value.empty() ? kDefaultSourceType : value;
}

std::string embeddingProfileOrDefault(const char* embeddingProfile)
{
    const std::string value = valueOrEmpty(embeddingProfile);
    return value.empty() ? kRawEmbeddingProfile : value;
}

int validateConfidence(cprag_handle* handle, double confidence)
{
    if (!std::isfinite(confidence) || confidence < 0.0 || confidence > 1.0) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "confidence must be a finite number between 0.0 and 1.0");
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

long long countStoredEmbeddings(cprag_handle* handle)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle, "SELECT COUNT(*) FROM chunk_embeddings", &stmt) != CPRAG_OK) {
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
    if (prepare(handle, "SELECT id, node_type, label, description, metadata_json FROM entities", &stmt) != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    std::vector<Entity> entities;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Entity entity;
        entity.id = columnText(stmt, 0);
        entity.nodeType = columnText(stmt, 1);
        entity.label = columnText(stmt, 2);
        entity.description = columnText(stmt, 3);
        entity.metadataJson = columnText(stmt, 4);
        entities.push_back(std::move(entity));
    }
    sqlite3_finalize(stmt);
    return entities;
}

std::vector<Edge> loadEdges(cprag_handle* handle)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle, "SELECT id, source_id, target_id, relationship_type, label, weight, metadata_json FROM edges", &stmt) != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    std::vector<Edge> edges;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Edge edge;
        edge.rowid = sqlite3_column_int64(stmt, 0);
        edge.sourceId = columnText(stmt, 1);
        edge.targetId = columnText(stmt, 2);
        edge.relationshipType = columnText(stmt, 3);
        edge.label = columnText(stmt, 4);
        edge.weight = sqlite3_column_double(stmt, 5);
        edge.metadataJson = columnText(stmt, 6);
        edges.push_back(std::move(edge));
    }
    sqlite3_finalize(stmt);
    return edges;
}

std::vector<DocumentSummary> loadDocumentSummaries(cprag_handle* handle)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle,
            "SELECT d.id, d.source_uri, d.title, d.content_hash, d.file_type, "
            "d.source_type, d.confidence, d.captured_at, d.event_start_at, d.event_end_at, d.metadata_json, "
            "COUNT(c.id) AS chunk_count, d.created_at, d.updated_at "
            "FROM documents d "
            "LEFT JOIN chunks c ON c.document_id = d.id "
            "GROUP BY d.id, d.source_uri, d.title, d.content_hash, d.file_type, "
            "d.source_type, d.confidence, d.captured_at, d.event_start_at, d.event_end_at, "
            "d.metadata_json, d.created_at, d.updated_at "
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
        document.sourceType = columnText(stmt, 5);
        document.confidence = sqlite3_column_double(stmt, 6);
        document.capturedAt = columnText(stmt, 7);
        document.eventStartAt = columnText(stmt, 8);
        document.eventEndAt = columnText(stmt, 9);
        document.metadataJson = columnText(stmt, 10);
        document.chunkCount = sqlite3_column_int64(stmt, 11);
        document.createdAt = columnText(stmt, 12);
        document.updatedAt = columnText(stmt, 13);
        documents.push_back(std::move(document));
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        throw std::runtime_error(sqliteError(handle->db));
    }
    return documents;
}

std::vector<StoredChunk> loadChunksForSource(cprag_handle* handle, const std::string& sourceUri)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle,
            "SELECT c.id, c.document_id, d.source_uri, d.title, c.chunk_index, c.text, c.length, "
            "c.start_offset, c.end_offset, c.source_type, c.confidence, "
            "c.captured_at, c.event_start_at, c.event_end_at, c.metadata_json "
            "FROM chunks c "
            "JOIN documents d ON d.id = c.document_id "
            "WHERE d.source_uri = ? "
            "ORDER BY c.chunk_index",
            &stmt)
        != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    bindText(stmt, 1, sourceUri);

    std::vector<StoredChunk> chunks;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        StoredChunk chunk;
        chunk.id = sqlite3_column_int64(stmt, 0);
        chunk.documentId = sqlite3_column_int64(stmt, 1);
        chunk.sourceUri = columnText(stmt, 2);
        chunk.title = columnText(stmt, 3);
        chunk.chunkIndex = sqlite3_column_int(stmt, 4);
        chunk.text = columnText(stmt, 5);
        chunk.length = sqlite3_column_int(stmt, 6);
        chunk.startOffset = sqlite3_column_int64(stmt, 7);
        chunk.endOffset = sqlite3_column_int64(stmt, 8);
        chunk.sourceType = columnText(stmt, 9);
        chunk.confidence = sqlite3_column_double(stmt, 10);
        chunk.capturedAt = columnText(stmt, 11);
        chunk.eventStartAt = columnText(stmt, 12);
        chunk.eventEndAt = columnText(stmt, 13);
        chunk.metadataJson = columnText(stmt, 14);
        chunks.push_back(std::move(chunk));
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        throw std::runtime_error(sqliteError(handle->db));
    }
    return chunks;
}

StoredChunk loadChunkById(cprag_handle* handle, long long chunkId)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle,
            "SELECT c.id, c.document_id, d.source_uri, d.title, c.chunk_index, c.text, c.length, "
            "c.start_offset, c.end_offset, c.source_type, c.confidence, "
            "c.captured_at, c.event_start_at, c.event_end_at, c.metadata_json "
            "FROM chunks c "
            "JOIN documents d ON d.id = c.document_id "
            "WHERE c.id = ?",
            &stmt)
        != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    sqlite3_bind_int64(stmt, 1, chunkId);
    StoredChunk chunk;
    const int stepRc = sqlite3_step(stmt);
    if (stepRc == SQLITE_ROW) {
        chunk.id = sqlite3_column_int64(stmt, 0);
        chunk.documentId = sqlite3_column_int64(stmt, 1);
        chunk.sourceUri = columnText(stmt, 2);
        chunk.title = columnText(stmt, 3);
        chunk.chunkIndex = sqlite3_column_int(stmt, 4);
        chunk.text = columnText(stmt, 5);
        chunk.length = sqlite3_column_int(stmt, 6);
        chunk.startOffset = sqlite3_column_int64(stmt, 7);
        chunk.endOffset = sqlite3_column_int64(stmt, 8);
        chunk.sourceType = columnText(stmt, 9);
        chunk.confidence = sqlite3_column_double(stmt, 10);
        chunk.capturedAt = columnText(stmt, 11);
        chunk.eventStartAt = columnText(stmt, 12);
        chunk.eventEndAt = columnText(stmt, 13);
        chunk.metadataJson = columnText(stmt, 14);
        sqlite3_finalize(stmt);
        return chunk;
    }

    sqlite3_finalize(stmt);
    if (stepRc == SQLITE_DONE) {
        throw std::runtime_error("chunk was not found");
    }
    throw std::runtime_error(sqliteError(handle->db));
}

bool chunkExists(cprag_handle* handle, long long chunkId)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle, "SELECT 1 FROM chunks WHERE id = ?", &stmt) != CPRAG_OK) {
        return false;
    }
    sqlite3_bind_int64(stmt, 1, chunkId);
    const bool exists = sqlite3_step(stmt) == SQLITE_ROW;
    sqlite3_finalize(stmt);
    return exists;
}

bool bindBlob(sqlite3_stmt* stmt, int index, const void* data, int size)
{
    return sqlite3_bind_blob(stmt, index, data, size, SQLITE_TRANSIENT) == SQLITE_OK;
}

int validateVector(
    cprag_handle* handle,
    const float* vector,
    size_t dimension,
    int* outDimension)
{
    if (vector == nullptr) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "vector is required");
    }
    if (dimension == 0 || dimension > static_cast<size_t>(std::numeric_limits<int>::max())) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "vector dimension must be positive");
    }
    if (dimension > 65536) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "vector dimension is too large");
    }
    for (size_t i = 0; i < dimension; ++i) {
        if (!std::isfinite(vector[i])) {
            return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "vector values must be finite");
        }
    }
    *outDimension = static_cast<int>(dimension);
    return CPRAG_OK;
}

std::vector<float> vectorFromBlob(const void* blob, int bytes)
{
    if (blob == nullptr || bytes <= 0 || bytes % static_cast<int>(sizeof(float)) != 0) {
        return {};
    }
    std::vector<float> values(static_cast<size_t>(bytes) / sizeof(float));
    std::memcpy(values.data(), blob, static_cast<size_t>(bytes));
    return values;
}

std::vector<ChunkEmbedding> loadChunkEmbeddings(
    cprag_handle* handle,
    const std::string& embeddingModel,
    const std::string& embeddingProfile)
{
    sqlite3_stmt* stmt = nullptr;
    const bool hasProfile = !embeddingProfile.empty();
    const char* sql = hasProfile
        ? "SELECT chunk_id, dimension, embedding_profile, vector "
          "FROM chunk_embeddings "
          "WHERE embedding_model = ? AND embedding_profile = ? "
          "ORDER BY chunk_id"
        : "SELECT chunk_id, dimension, embedding_profile, vector "
          "FROM chunk_embeddings "
          "WHERE embedding_model = ? "
          "ORDER BY chunk_id";
    if (prepare(handle, sql, &stmt) != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    bindText(stmt, 1, embeddingModel);
    if (hasProfile) {
        bindText(stmt, 2, embeddingProfile);
    }
    std::vector<ChunkEmbedding> embeddings;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        ChunkEmbedding embedding;
        embedding.chunkId = sqlite3_column_int64(stmt, 0);
        embedding.dimension = sqlite3_column_int(stmt, 1);
        embedding.embeddingProfile = columnText(stmt, 2);
        const void* blob = sqlite3_column_blob(stmt, 3);
        const int bytes = sqlite3_column_bytes(stmt, 3);
        embedding.vector = vectorFromBlob(blob, bytes);
        if (embedding.dimension <= 0
            || embedding.vector.size() != static_cast<size_t>(embedding.dimension)) {
            sqlite3_finalize(stmt);
            throw std::runtime_error("stored embedding dimension does not match vector bytes");
        }
        embeddings.push_back(std::move(embedding));
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        throw std::runtime_error(sqliteError(handle->db));
    }
    return embeddings;
}

VectorIndexState loadVectorIndexState(cprag_handle* handle)
{
    sqlite3_stmt* stmt = nullptr;
    if (prepare(handle,
            "SELECT embedding_model, embedding_profile, dimension, metric, embedding_count, index_path, backend, updated_at "
            "FROM vector_index_state "
            "WHERE index_name = 'chunks'",
            &stmt)
        != CPRAG_OK) {
        throw std::runtime_error(handle->lastError);
    }

    VectorIndexState state;
    const int stepRc = sqlite3_step(stmt);
    if (stepRc == SQLITE_ROW) {
        state.present = true;
        state.embeddingModel = columnText(stmt, 0);
        state.embeddingProfile = columnText(stmt, 1);
        state.dimension = sqlite3_column_int(stmt, 2);
        state.metric = columnText(stmt, 3);
        state.embeddingCount = sqlite3_column_int64(stmt, 4);
        state.indexPath = columnText(stmt, 5);
        state.backend = columnText(stmt, 6);
        state.updatedAt = columnText(stmt, 7);
        sqlite3_finalize(stmt);
        return state;
    }

    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        throw std::runtime_error(sqliteError(handle->db));
    }
    return state;
}

int upsertVectorIndexState(
    cprag_handle* handle,
    const std::string& embeddingModel,
    const std::string& embeddingProfile,
    int dimension,
    long long embeddingCount)
{
    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle,
        "INSERT INTO vector_index_state "
        "(index_name, embedding_model, embedding_profile, dimension, metric, embedding_count, index_path, backend, updated_at) "
        "VALUES ('chunks', ?, ?, ?, 'l2', ?, 'vectors.faiss', 'faiss', CURRENT_TIMESTAMP) "
        "ON CONFLICT(index_name) DO UPDATE SET "
        "embedding_model=excluded.embedding_model, embedding_profile=excluded.embedding_profile, "
        "dimension=excluded.dimension, metric=excluded.metric, "
        "embedding_count=excluded.embedding_count, index_path=excluded.index_path, backend=excluded.backend, "
        "updated_at=CURRENT_TIMESTAMP",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    bindText(stmt, 1, embeddingModel);
    bindText(stmt, 2, embeddingProfile);
    sqlite3_bind_int(stmt, 3, dimension);
    sqlite3_bind_int64(stmt, 4, embeddingCount);
    const int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return CPRAG_OK;
}

int invalidateVectorIndexState(cprag_handle* handle)
{
    return execSql(handle, "DELETE FROM vector_index_state WHERE index_name = 'chunks'");
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

void appendNullableString(std::ostringstream& out, const std::string& value)
{
    if (value.empty()) {
        out << "null";
    } else {
        out << jsonString(value);
    }
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

    std::string haystack = entity.id + " " + entity.nodeType + " " + entity.label + " " + entity.description;
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
            "SELECT c.id, c.document_id, d.source_uri, d.title, c.chunk_index, c.text, c.length, "
            "c.source_type, c.confidence, c.captured_at, c.event_start_at, c.event_end_at, "
            "(bm25(chunks_fts) * c.confidence) AS rank "
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
        chunk.sourceType = columnText(stmt, 7);
        chunk.confidence = sqlite3_column_double(stmt, 8);
        chunk.capturedAt = columnText(stmt, 9);
        chunk.eventStartAt = columnText(stmt, 10);
        chunk.eventEndAt = columnText(stmt, 11);
        chunk.rank = sqlite3_column_double(stmt, 12);
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

std::string lowerCopy(std::string value)
{
    std::transform(value.begin(), value.end(), value.begin(), [](unsigned char c) {
        return static_cast<char>(std::tolower(c));
    });
    return value;
}

std::string searchModeName(int mode)
{
    switch (mode) {
    case CPRAG_SEARCH_AUTO:
        return "auto";
    case CPRAG_SEARCH_LEXICAL:
        return "lexical";
    case CPRAG_SEARCH_VECTOR:
        return "vector";
    case CPRAG_SEARCH_HYBRID:
        return "hybrid";
    default:
        return "unknown";
    }
}

bool edgeAllowed(const Edge& edge, const std::unordered_set<std::string>& filters)
{
    if (filters.empty()) {
        return true;
    }
    return filters.find(lowerCopy(edge.relationshipType)) != filters.end()
        || filters.find(lowerCopy(edge.label)) != filters.end();
}

bool entityAllowed(const Entity& entity, const std::unordered_set<std::string>& filters)
{
    return filters.empty()
        || filters.find(lowerCopy(entity.nodeType)) != filters.end()
        || filters.find(lowerCopy(entity.label)) != filters.end();
}

void appendEntityJson(std::ostringstream& out, const Entity& entity)
{
    out << "{\"id\":" << jsonString(entity.id)
        << ",\"node_type\":" << jsonString(entity.nodeType)
        << ",\"label\":" << jsonString(entity.label)
        << ",\"description\":" << jsonString(entity.description)
        << ",\"metadata\":" << (entity.metadataJson.empty() ? "{}" : entity.metadataJson)
        << '}';
}

void appendEdgeJson(std::ostringstream& out, const Edge& edge)
{
    out << "{\"id\":" << edge.rowid
        << ",\"source\":" << jsonString(edge.sourceId)
        << ",\"target\":" << jsonString(edge.targetId)
        << ",\"relationship_type\":" << jsonString(edge.relationshipType)
        << ",\"label\":" << jsonString(edge.label)
        << ",\"weight\":" << edge.weight
        << ",\"metadata\":" << (edge.metadataJson.empty() ? "{}" : edge.metadataJson)
        << '}';
}

std::string buildSubgraphJson(
    const std::vector<Entity>& entities,
    const std::vector<Edge>& edges,
    const std::vector<Anchor>& anchors,
    int hops,
    const std::string& relationFilterCsv,
    const std::vector<ChunkHit>& chunkHits,
    const std::string& searchMetadataJson = "")
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
    out << "{\"success\":true";
    if (!searchMetadataJson.empty()) {
        out << ",\"search\":" << searchMetadataJson;
    }
    out << ",\"anchors\":[";
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
            << ",\"source_type\":" << jsonString(chunk.sourceType)
            << ",\"confidence\":" << chunk.confidence
            << ",\"captured_at\":";
        appendNullableString(out, chunk.capturedAt);
        out << ",\"event_start_at\":";
        appendNullableString(out, chunk.eventStartAt);
        out << ",\"event_end_at\":";
        appendNullableString(out, chunk.eventEndAt);
        out
            << ",\"rank\":" << chunk.rank;
        if (!chunk.retrieval.empty()) {
            out << ",\"retrieval\":" << jsonString(chunk.retrieval);
        }
        if (chunk.hasVectorDistance) {
            out << ",\"vector_distance\":" << chunk.vectorDistance;
        }
        out << '}';
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
        appendEntityJson(out, it->second);
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
        appendEdgeJson(out, edge);
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

int copyText(cprag_handle* handle, const std::string& text, char* outText, size_t outTextSize)
{
    if (outText == nullptr || outTextSize == 0) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "output buffer is required");
    }
    if (text.size() + 1 > outTextSize) {
        return setErrorCode(handle, CPRAG_BUFFER_TOO_SMALL, "output buffer is too small");
    }
    std::copy(text.begin(), text.end(), outText);
    outText[text.size()] = '\0';
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
                 << "  \"database\": \"library.sqlite\",\n"
                 << "  \"vector_index\": \"vectors.faiss\"\n"
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
    const std::string& sourceType,
    double confidence,
    const std::string& capturedAt,
    const std::string& eventStartAt,
    const std::string& eventEndAt,
    long long* outId)
{
    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle,
        "INSERT INTO documents "
        "(source_uri, title, content_hash, file_type, source_type, confidence, captured_at, event_start_at, event_end_at, metadata_json) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
        "ON CONFLICT(source_uri) DO UPDATE SET "
        "title=excluded.title, content_hash=excluded.content_hash, file_type=excluded.file_type, "
        "source_type=excluded.source_type, confidence=excluded.confidence, captured_at=excluded.captured_at, "
        "event_start_at=excluded.event_start_at, event_end_at=excluded.event_end_at, "
        "metadata_json=excluded.metadata_json, updated_at=CURRENT_TIMESTAMP",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    bindText(stmt, 1, sourceUri);
    bindText(stmt, 2, title);
    bindText(stmt, 3, contentHash);
    sqlite3_bind_int(stmt, 4, fileType);
    bindText(stmt, 5, sourceType);
    sqlite3_bind_double(stmt, 6, confidence);
    bindText(stmt, 7, capturedAt);
    bindText(stmt, 8, eventStartAt);
    bindText(stmt, 9, eventEndAt);
    bindText(stmt, 10, metadata);

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
    return invalidateVectorIndexState(handle);
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
    const std::string& sourceType,
    double confidence,
    const std::string& capturedAt,
    const std::string& eventStartAt,
    const std::string& eventEndAt,
    std::vector<long long>* chunkIds)
{
    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle,
        "INSERT INTO chunks "
        "(document_id, chunk_index, text, length, start_offset, end_offset, source_type, confidence, "
        "captured_at, event_start_at, event_end_at, metadata_json) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '{}')",
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
        bindText(stmt, 7, sourceType);
        sqlite3_bind_double(stmt, 8, confidence);
        bindText(stmt, 9, capturedAt);
        bindText(stmt, 10, eventStartAt);
        bindText(stmt, 11, eventEndAt);

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
    const std::string& sourceType,
    double confidence,
    const std::string& capturedAt,
    const std::string& eventStartAt,
    const std::string& eventEndAt,
    const std::vector<std::string>& chunks,
    const std::vector<long long>& chunkIds)
{
    std::ostringstream out;
    out << "{\"success\":true,\"document\":{\"id\":" << documentId
        << ",\"source_uri\":" << jsonString(sourceUri)
        << ",\"title\":" << jsonString(title)
        << ",\"content_hash\":" << jsonString(contentHash)
        << ",\"file_type\":" << fileType
        << ",\"source_type\":" << jsonString(sourceType)
        << ",\"confidence\":" << confidence
        << ",\"captured_at\":";
    appendNullableString(out, capturedAt);
    out << ",\"event_start_at\":";
    appendNullableString(out, eventStartAt);
    out << ",\"event_end_at\":";
    appendNullableString(out, eventEndAt);
    out
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
            << ",\"source_type\":" << jsonString(document.sourceType)
            << ",\"confidence\":" << document.confidence
            << ",\"captured_at\":";
        appendNullableString(out, document.capturedAt);
        out << ",\"event_start_at\":";
        appendNullableString(out, document.eventStartAt);
        out << ",\"event_end_at\":";
        appendNullableString(out, document.eventEndAt);
        out
            << ",\"created_at\":" << jsonString(document.createdAt)
            << ",\"updated_at\":" << jsonString(document.updatedAt)
            << ",\"metadata\":" << (document.metadataJson.empty() ? "{}" : document.metadataJson)
            << '}';
    }
    out << "]}";
    return out.str();
}

std::string timelineSortTime(const DocumentSummary& document)
{
    if (!document.eventStartAt.empty()) {
        return document.eventStartAt;
    }
    if (!document.capturedAt.empty()) {
        return document.capturedAt;
    }
    return document.createdAt;
}

std::string buildTimelineJson(std::vector<DocumentSummary> documents, int limit)
{
    std::sort(documents.begin(), documents.end(), [](const DocumentSummary& lhs, const DocumentSummary& rhs) {
        const std::string lhsTime = timelineSortTime(lhs);
        const std::string rhsTime = timelineSortTime(rhs);
        if (lhsTime == rhsTime) {
            return lhs.sourceUri < rhs.sourceUri;
        }
        return lhsTime < rhsTime;
    });

    const size_t effectiveLimit = limit <= 0
        ? documents.size()
        : std::min(documents.size(), static_cast<size_t>(limit));
    std::ostringstream out;
    out << "{\"success\":true,\"events\":[";
    for (size_t i = 0; i < effectiveLimit; ++i) {
        const DocumentSummary& document = documents[i];
        if (i != 0) {
            out << ',';
        }
        out << "{\"id\":" << document.id
            << ",\"source_uri\":" << jsonString(document.sourceUri)
            << ",\"title\":" << jsonString(document.title)
            << ",\"source_type\":" << jsonString(document.sourceType)
            << ",\"confidence\":" << document.confidence
            << ",\"sort_time\":";
        appendNullableString(out, timelineSortTime(document));
        out << ",\"captured_at\":";
        appendNullableString(out, document.capturedAt);
        out << ",\"event_start_at\":";
        appendNullableString(out, document.eventStartAt);
        out << ",\"event_end_at\":";
        appendNullableString(out, document.eventEndAt);
        out << ",\"created_at\":" << jsonString(document.createdAt)
            << ",\"updated_at\":" << jsonString(document.updatedAt)
            << ",\"chunk_count\":" << document.chunkCount
            << ",\"metadata\":" << (document.metadataJson.empty() ? "{}" : document.metadataJson)
            << '}';
    }
    out << "]}";
    return out.str();
}

std::string buildChunksJson(const std::vector<StoredChunk>& chunks, const std::string& sourceUri)
{
    std::ostringstream out;
    out << "{\"success\":true,\"source_uri\":" << jsonString(sourceUri) << ",\"chunks\":[";
    for (size_t i = 0; i < chunks.size(); ++i) {
        const StoredChunk& chunk = chunks[i];
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
            << ",\"start_offset\":" << chunk.startOffset
            << ",\"end_offset\":" << chunk.endOffset
            << ",\"source_type\":" << jsonString(chunk.sourceType)
            << ",\"confidence\":" << chunk.confidence
            << ",\"captured_at\":";
        appendNullableString(out, chunk.capturedAt);
        out << ",\"event_start_at\":";
        appendNullableString(out, chunk.eventStartAt);
        out << ",\"event_end_at\":";
        appendNullableString(out, chunk.eventEndAt);
        out
            << ",\"metadata\":" << (chunk.metadataJson.empty() ? "{}" : chunk.metadataJson)
            << '}';
    }
    out << "]}";
    return out.str();
}

void appendStoredChunkJson(std::ostringstream& out, const StoredChunk& chunk)
{
    out << "{\"id\":" << chunk.id
        << ",\"document_id\":" << chunk.documentId
        << ",\"source_uri\":" << jsonString(chunk.sourceUri)
        << ",\"title\":" << jsonString(chunk.title)
        << ",\"chunk_index\":" << chunk.chunkIndex
        << ",\"text\":" << jsonString(chunk.text)
        << ",\"length\":" << chunk.length
        << ",\"start_offset\":" << chunk.startOffset
        << ",\"end_offset\":" << chunk.endOffset
        << ",\"source_type\":" << jsonString(chunk.sourceType)
        << ",\"confidence\":" << chunk.confidence
        << ",\"captured_at\":";
    appendNullableString(out, chunk.capturedAt);
    out << ",\"event_start_at\":";
    appendNullableString(out, chunk.eventStartAt);
    out << ",\"event_end_at\":";
    appendNullableString(out, chunk.eventEndAt);
    out
        << ",\"metadata\":" << (chunk.metadataJson.empty() ? "{}" : chunk.metadataJson)
        << '}';
}

std::string buildVectorStatusJson(
    cprag_handle* handle,
    const VectorIndexState& state,
    long long storedEmbeddingCount)
{
    std::ostringstream out;
    out << "{\"success\":true,\"enabled\":";
#ifdef CPRAG_HAVE_FAISS
    out << "true";
#else
    out << "false";
#endif
    out << ",\"backend\":\"faiss\""
        << ",\"index_path\":" << jsonString(vectorIndexPathForLibrary(handle->libraryPath).string())
        << ",\"stored_embeddings\":" << storedEmbeddingCount
        << ",\"active_index\":";
    if (!state.present) {
        out << "null";
    } else {
        out << "{\"embedding_model\":" << jsonString(state.embeddingModel)
            << ",\"embedding_profile\":" << jsonString(state.embeddingProfile)
            << ",\"dimension\":" << state.dimension
            << ",\"metric\":" << jsonString(state.metric)
            << ",\"embedding_count\":" << state.embeddingCount
            << ",\"index_path\":" << jsonString(state.indexPath)
            << ",\"backend\":" << jsonString(state.backend)
            << ",\"updated_at\":" << jsonString(state.updatedAt)
            << '}';
    }
    out << '}';
    return out.str();
}

std::string buildVectorRebuildJson(
    cprag_handle* handle,
    const std::string& embeddingModel,
    const std::string& embeddingProfile,
    int dimension,
    long long embeddingCount)
{
    std::ostringstream out;
    out << "{\"success\":true,\"backend\":\"faiss\""
        << ",\"embedding_model\":" << jsonString(embeddingModel)
        << ",\"embedding_profile\":" << jsonString(embeddingProfile)
        << ",\"dimension\":" << dimension
        << ",\"metric\":\"l2\""
        << ",\"embedding_count\":" << embeddingCount
        << ",\"index_path\":" << jsonString(vectorIndexPathForLibrary(handle->libraryPath).string())
        << '}';
    return out.str();
}

std::string buildVectorSearchJson(
    const std::string& embeddingModel,
    const std::string& embeddingProfile,
    int dimension,
    const std::vector<VectorHit>& hits)
{
    std::ostringstream out;
    out << "{\"success\":true,\"backend\":\"faiss\""
        << ",\"embedding_model\":" << jsonString(embeddingModel)
        << ",\"embedding_profile\":" << jsonString(embeddingProfile)
        << ",\"dimension\":" << dimension
        << ",\"metric\":\"l2\""
        << ",\"results\":[";
    for (size_t i = 0; i < hits.size(); ++i) {
        if (i != 0) {
            out << ',';
        }
        out << "{\"chunk_id\":" << hits[i].chunk.id
            << ",\"distance\":" << hits[i].distance
            << ",\"score\":" << hits[i].score
            << ",\"chunk\":";
        appendStoredChunkJson(out, hits[i].chunk);
        out << '}';
    }
    out << "]}";
    return out.str();
}

std::string buildChunkEmbeddingText(const StoredChunk& chunk, const std::string& embeddingProfile)
{
    if (embeddingProfile == kRawEmbeddingProfile) {
        return chunk.text;
    }

    std::ostringstream out;
    out << "Embedding profile: " << embeddingProfile << '\n'
        << "Vocabulary profile: " << kVocabularyProfile << '\n'
        << "Source type: " << (chunk.sourceType.empty() ? kDefaultSourceType : chunk.sourceType) << '\n'
        << "Confidence: " << chunk.confidence << '\n';
    if (!chunk.capturedAt.empty()) {
        out << "Captured at: " << chunk.capturedAt << '\n';
    }
    if (!chunk.eventStartAt.empty()) {
        out << "Event start at: " << chunk.eventStartAt << '\n';
    }
    if (!chunk.eventEndAt.empty()) {
        out << "Event end at: " << chunk.eventEndAt << '\n';
    }
    out << "Source URI: " << chunk.sourceUri << '\n'
        << "Title: " << chunk.title << '\n'
        << "Chunk index: " << chunk.chunkIndex << '\n'
        << "Text:\n"
        << chunk.text;
    return out.str();
}

int loadVectorHits(
    cprag_handle* handle,
    const char* embeddingModel,
    const float* queryVector,
    size_t dimension,
    int topK,
    std::vector<VectorHit>* outHits,
    std::string* outEmbeddingModel,
    std::string* outEmbeddingProfile,
    int* outDimension)
{
    if (handle == nullptr || outHits == nullptr || outEmbeddingModel == nullptr || outEmbeddingProfile == nullptr || outDimension == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    int effectiveDimension = 0;
    const int vectorRc = validateVector(handle, queryVector, dimension, &effectiveDimension);
    if (vectorRc != CPRAG_OK) {
        return vectorRc;
    }

#ifndef CPRAG_HAVE_FAISS
    (void)embeddingModel;
    (void)topK;
    return setErrorCode(handle, CPRAG_UNSUPPORTED, "FAISS support is not enabled in this build");
#else
    try {
        const VectorIndexState state = loadVectorIndexState(handle);
        if (!state.present) {
            return setErrorCode(handle, CPRAG_NOT_FOUND, "vector index has not been rebuilt");
        }

        const std::string requestedModel = valueOrEmpty(embeddingModel).empty()
            ? state.embeddingModel
            : valueOrEmpty(embeddingModel);
        if (requestedModel != state.embeddingModel) {
            return setErrorCode(handle, CPRAG_NOT_FOUND, "active vector index was built for a different embedding_model");
        }
        if (state.metric != "l2" || state.backend != "faiss") {
            return setErrorCode(handle, CPRAG_UNSUPPORTED, "active vector index uses an unsupported backend or metric");
        }
        if (effectiveDimension != state.dimension) {
            return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "query vector dimension does not match active index");
        }

        const std::filesystem::path indexPath = vectorIndexPathForLibrary(handle->libraryPath);
        if (!std::filesystem::exists(indexPath)) {
            return setErrorCode(handle, CPRAG_NOT_FOUND, "vectors.faiss was not found");
        }

        std::unique_ptr<faiss::Index> index(faiss::read_index(indexPath.string().c_str()));
        if (!index || index->d != state.dimension) {
            return setErrorCode(handle, CPRAG_INTERNAL_ERROR, "vectors.faiss dimension does not match index metadata");
        }

        const int effectiveTopK = topK <= 0 ? 3 : topK;
        std::vector<float> distances(static_cast<size_t>(effectiveTopK), 0.0f);
        std::vector<faiss::idx_t> labels(static_cast<size_t>(effectiveTopK), -1);
        index->search(
            1,
            queryVector,
            effectiveTopK,
            distances.data(),
            labels.data());

        outHits->clear();
        for (int i = 0; i < effectiveTopK; ++i) {
            if (labels[static_cast<size_t>(i)] < 0) {
                continue;
            }
            try {
                VectorHit hit;
                hit.chunk = loadChunkById(handle, static_cast<long long>(labels[static_cast<size_t>(i)]));
                hit.distance = distances[static_cast<size_t>(i)];
                const double confidence = std::max(0.01, hit.chunk.confidence);
                hit.score = -(hit.distance / confidence);
                outHits->push_back(std::move(hit));
            } catch (const std::exception&) {
                continue;
            }
        }

        std::sort(outHits->begin(), outHits->end(), [](const VectorHit& lhs, const VectorHit& rhs) {
            return lhs.score > rhs.score;
        });
        *outEmbeddingModel = state.embeddingModel;
        *outEmbeddingProfile = state.embeddingProfile;
        *outDimension = state.dimension;
        return CPRAG_OK;
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
#endif
}

ChunkHit chunkHitFromVectorHit(const VectorHit& hit)
{
    ChunkHit chunk;
    chunk.id = hit.chunk.id;
    chunk.documentId = hit.chunk.documentId;
    chunk.sourceUri = hit.chunk.sourceUri;
    chunk.title = hit.chunk.title;
    chunk.chunkIndex = hit.chunk.chunkIndex;
    chunk.text = hit.chunk.text;
    chunk.length = hit.chunk.length;
    chunk.sourceType = hit.chunk.sourceType;
    chunk.confidence = hit.chunk.confidence;
    chunk.capturedAt = hit.chunk.capturedAt;
    chunk.eventStartAt = hit.chunk.eventStartAt;
    chunk.eventEndAt = hit.chunk.eventEndAt;
    chunk.rank = hit.score;
    chunk.retrieval = "vector";
    chunk.hasVectorDistance = true;
    chunk.vectorDistance = hit.distance;
    return chunk;
}

std::vector<ChunkHit> mergeChunkHits(
    std::vector<ChunkHit> lexicalHits,
    const std::vector<VectorHit>& vectorHits,
    int limit)
{
    const int effectiveLimit = limit <= 0 ? 3 : limit;
    std::vector<ChunkHit> merged;
    std::unordered_map<long long, size_t> positionById;

    auto appendLexical = [&](ChunkHit chunk) {
        chunk.retrieval = "lexical";
        const auto existing = positionById.find(chunk.id);
        if (existing != positionById.end()) {
            if (merged[existing->second].retrieval == "vector") {
                merged[existing->second].retrieval = "hybrid";
            }
            return;
        }
        if (static_cast<int>(merged.size()) < effectiveLimit) {
            positionById.emplace(chunk.id, merged.size());
            merged.push_back(std::move(chunk));
        }
    };

    auto appendVector = [&](const VectorHit& vectorHit) {
        const auto existing = positionById.find(vectorHit.chunk.id);
        if (existing != positionById.end()) {
            ChunkHit& chunk = merged[existing->second];
            chunk.retrieval = "hybrid";
            chunk.hasVectorDistance = true;
            chunk.vectorDistance = vectorHit.distance;
            return;
        }
        if (static_cast<int>(merged.size()) < effectiveLimit) {
            positionById.emplace(vectorHit.chunk.id, merged.size());
            merged.push_back(chunkHitFromVectorHit(vectorHit));
        }
    };

    const size_t maxCount = std::max(lexicalHits.size(), vectorHits.size());
    for (size_t i = 0; i < maxCount; ++i) {
        if (i < lexicalHits.size()) {
            appendLexical(std::move(lexicalHits[i]));
        }
        if (i < vectorHits.size()) {
            appendVector(vectorHits[i]);
        }
    }
    return merged;
}

std::string buildSearchMetadataJson(
    int requestedMode,
    int effectiveMode,
    bool vectorUsed,
    const std::string& embeddingModel,
    const std::string& embeddingProfile,
    int dimension,
    const std::string& fallbackReason)
{
    std::ostringstream out;
    out << "{\"requested_mode\":" << jsonString(searchModeName(requestedMode))
        << ",\"effective_mode\":" << jsonString(searchModeName(effectiveMode))
        << ",\"vector_used\":" << (vectorUsed ? "true" : "false")
        << ",\"embedding_model\":";
    if (embeddingModel.empty()) {
        out << "null";
    } else {
        out << jsonString(embeddingModel);
    }
    out << ",\"embedding_profile\":";
    if (embeddingProfile.empty()) {
        out << "null";
    } else {
        out << jsonString(embeddingProfile);
    }
    out << ",\"dimension\":";
    if (dimension > 0) {
        out << dimension;
    } else {
        out << "null";
    }
    if (!fallbackReason.empty()) {
        out << ",\"fallback_reason\":" << jsonString(fallbackReason);
    }
    out << '}';
    return out.str();
}

std::string buildDeleteSourceJson(const std::string& sourceUri, int deleted)
{
    std::ostringstream out;
    out << "{\"success\":true,\"source_uri\":" << jsonString(sourceUri)
        << ",\"deleted\":" << deleted
        << '}';
    return out.str();
}

void appendVocabularyArray(std::ostringstream& out, const VocabularyItem* items, size_t count)
{
    out << '[';
    for (size_t i = 0; i < count; ++i) {
        if (i != 0) {
            out << ',';
        }
        out << "{\"id\":" << jsonString(items[i].id)
            << ",\"label\":" << jsonString(items[i].label)
            << ",\"description\":" << jsonString(items[i].description)
            << '}';
    }
    out << ']';
}

std::string buildVocabularyJson()
{
    std::ostringstream out;
    out << "{\"success\":true,\"profile\":" << jsonString(kVocabularyProfile) << ",\"node_types\":";
    appendVocabularyArray(out, kArchitectureNodeTypes, sizeof(kArchitectureNodeTypes) / sizeof(kArchitectureNodeTypes[0]));
    out << ",\"relationship_types\":";
    appendVocabularyArray(
        out,
        kArchitectureRelationshipTypes,
        sizeof(kArchitectureRelationshipTypes) / sizeof(kArchitectureRelationshipTypes[0]));
    out << ",\"source_types\":";
    appendVocabularyArray(out, kSourceTypes, sizeof(kSourceTypes) / sizeof(kSourceTypes[0]));
    out << ",\"temporal_roles\":";
    appendVocabularyArray(out, kTemporalRoles, sizeof(kTemporalRoles) / sizeof(kTemporalRoles[0]));
    out << ",\"confidence_scale\":";
    appendVocabularyArray(out, kConfidenceScale, sizeof(kConfidenceScale) / sizeof(kConfidenceScale[0]));
    out << ",\"embedding_profiles\":";
    appendVocabularyArray(out, kEmbeddingProfiles, sizeof(kEmbeddingProfiles) / sizeof(kEmbeddingProfiles[0]));
    out << '}';
    return out.str();
}

std::string buildShortestPathJson(
    const std::vector<Entity>& entities,
    const std::vector<Edge>& edges,
    const std::vector<std::string>& nodeIds,
    const std::vector<long long>& edgeIds)
{
    std::unordered_map<std::string, Entity> entityById;
    for (const Entity& entity : entities) {
        entityById.emplace(entity.id, entity);
    }
    std::unordered_map<long long, Edge> edgeById;
    for (const Edge& edge : edges) {
        edgeById.emplace(edge.rowid, edge);
    }

    std::ostringstream out;
    out << "{\"success\":true,\"found\":" << (nodeIds.empty() ? "false" : "true") << ",\"path\":{\"nodes\":[";
    for (size_t i = 0; i < nodeIds.size(); ++i) {
        if (i != 0) {
            out << ',';
        }
        const auto it = entityById.find(nodeIds[i]);
        if (it != entityById.end()) {
            appendEntityJson(out, it->second);
        }
    }
    out << "],\"edges\":[";
    for (size_t i = 0; i < edgeIds.size(); ++i) {
        if (i != 0) {
            out << ',';
        }
        const auto it = edgeById.find(edgeIds[i]);
        if (it != edgeById.end()) {
            appendEdgeJson(out, it->second);
        }
    }
    out << "]}}";
    return out.str();
}

std::string buildTypedSubgraphJson(
    const std::vector<Entity>& entities,
    const std::vector<Edge>& edges,
    const std::string& nodeTypeFilterCsv,
    const std::string& relationshipTypeFilterCsv,
    int limit)
{
    const auto nodeFilters = relationFilterSet(nodeTypeFilterCsv);
    const auto relationFilters = relationFilterSet(relationshipTypeFilterCsv);
    const int effectiveLimit = limit <= 0 ? 100 : limit;

    std::unordered_map<std::string, Entity> entityById;
    for (const Entity& entity : entities) {
        entityById.emplace(entity.id, entity);
    }

    std::unordered_set<std::string> includedNodes;
    std::vector<std::string> orderedNodeIds;
    for (const Entity& entity : entities) {
        if (!entityAllowed(entity, nodeFilters)) {
            continue;
        }
        if (static_cast<int>(orderedNodeIds.size()) >= effectiveLimit) {
            break;
        }
        if (includedNodes.insert(entity.id).second) {
            orderedNodeIds.push_back(entity.id);
        }
    }

    if (nodeFilters.empty() && !relationFilters.empty()) {
        for (const Edge& edge : edges) {
            if (!edgeAllowed(edge, relationFilters)) {
                continue;
            }
            if (includedNodes.insert(edge.sourceId).second) {
                orderedNodeIds.push_back(edge.sourceId);
            }
            if (static_cast<int>(orderedNodeIds.size()) >= effectiveLimit) {
                break;
            }
            if (includedNodes.insert(edge.targetId).second) {
                orderedNodeIds.push_back(edge.targetId);
            }
            if (static_cast<int>(orderedNodeIds.size()) >= effectiveLimit) {
                break;
            }
        }
    }

    std::ostringstream out;
    out << "{\"success\":true,\"subgraph\":{\"nodes\":[";
    bool first = true;
    for (const std::string& nodeId : orderedNodeIds) {
        const auto it = entityById.find(nodeId);
        if (it == entityById.end()) {
            continue;
        }
        if (!first) {
            out << ',';
        }
        first = false;
        appendEntityJson(out, it->second);
    }

    out << "],\"edges\":[";
    first = true;
    for (const Edge& edge : edges) {
        if (includedNodes.find(edge.sourceId) == includedNodes.end()
            || includedNodes.find(edge.targetId) == includedNodes.end()
            || !edgeAllowed(edge, relationFilters)) {
            continue;
        }
        if (!first) {
            out << ',';
        }
        first = false;
        appendEdgeJson(out, edge);
    }
    out << "]}}";
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
    return cprag_add_entity_typed(handle, id, label, label, description, metadata_json);
}

int cprag_add_entity_typed(
    cprag_handle* handle,
    const char* id,
    const char* node_type,
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
        "INSERT INTO entities (id, node_type, label, description, metadata_json) VALUES (?, ?, ?, ?, ?) "
        "ON CONFLICT(id) DO UPDATE SET node_type=excluded.node_type, label=excluded.label, description=excluded.description, metadata_json=excluded.metadata_json",
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
    const std::string effectiveType = valueOrEmpty(node_type).empty() ? "entity" : valueOrEmpty(node_type);
    bindText(stmt, 1, id);
    bindText(stmt, 2, effectiveType);
    bindText(stmt, 3, label);
    bindText(stmt, 4, description);
    bindText(stmt, 5, metadata);

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
    return cprag_add_edge_typed(handle, source_id, target_id, label, label, weight, metadata_json);
}

int cprag_add_edge_typed(
    cprag_handle* handle,
    const char* source_id,
    const char* target_id,
    const char* relationship_type,
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
        "INSERT INTO edges (source_id, target_id, relationship_type, label, weight, metadata_json) VALUES (?, ?, ?, ?, ?, ?)",
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
    const std::string effectiveType = valueOrEmpty(relationship_type).empty() ? "relationship" : valueOrEmpty(relationship_type);
    bindText(stmt, 1, source_id);
    bindText(stmt, 2, target_id);
    bindText(stmt, 3, effectiveType);
    bindText(stmt, 4, label);
    sqlite3_bind_double(stmt, 5, weight);
    bindText(stmt, 6, metadata);

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
    return cprag_ingest_text_ex(
        handle,
        source_uri,
        title,
        text,
        file_type,
        chunk_size,
        chunk_overlap,
        metadata_json,
        kDefaultSourceType,
        1.0,
        "",
        "",
        "",
        out_json,
        out_json_size);
}

int cprag_ingest_text_ex(
    cprag_handle* handle,
    const char* source_uri,
    const char* title,
    const char* text,
    int file_type,
    int chunk_size,
    int chunk_overlap,
    const char* metadata_json,
    const char* source_type,
    double confidence,
    const char* captured_at,
    const char* event_start_at,
    const char* event_end_at,
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
    const int confidenceRc = validateConfidence(handle, confidence);
    if (confidenceRc != CPRAG_OK) {
        return confidenceRc;
    }
    const std::string effectiveSourceType = sourceTypeOrDefault(source_type);
    const std::string capturedAt = valueOrEmpty(captured_at);
    const std::string eventStartAt = valueOrEmpty(event_start_at);
    const std::string eventEndAt = valueOrEmpty(event_end_at);

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
    int rc = upsertDocument(
        handle,
        sourceUri,
        effectiveTitle,
        contentHash,
        file_type,
        metadata,
        effectiveSourceType,
        confidence,
        capturedAt,
        eventStartAt,
        eventEndAt,
        &documentId);
    if (rc == CPRAG_OK) {
        rc = deleteDocumentChunks(handle, documentId);
    }

    std::vector<long long> chunkIds;
    if (rc == CPRAG_OK) {
        rc = insertChunkRows(
            handle,
            documentId,
            content,
            chunks,
            effectiveOverlap,
            effectiveSourceType,
            confidence,
            capturedAt,
            eventStartAt,
            eventEndAt,
            &chunkIds);
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
        buildIngestJson(
            documentId,
            sourceUri,
            effectiveTitle,
            contentHash,
            file_type,
            metadata,
            effectiveSourceType,
            confidence,
            capturedAt,
            eventStartAt,
            eventEndAt,
            chunks,
            chunkIds),
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

int cprag_timeline(cprag_handle* handle, int limit, char* out_json, size_t out_json_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        return copyJson(handle, buildTimelineJson(loadDocumentSummaries(handle), limit), out_json, out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
}

int cprag_list_chunks(cprag_handle* handle, const char* source_uri, char* out_json, size_t out_json_size)
{
    if (handle == nullptr || source_uri == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        const std::string sourceUri(source_uri);
        return copyJson(handle, buildChunksJson(loadChunksForSource(handle, sourceUri), sourceUri), out_json, out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
}

int cprag_each_chunk(
    cprag_handle* handle,
    const char* source_uri,
    cprag_chunk_visitor visitor,
    void* user_data)
{
    if (handle == nullptr || visitor == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    const std::string sourceUri = valueOrEmpty(source_uri);
    const bool hasSourceFilter = !sourceUri.empty();
    sqlite3_stmt* stmt = nullptr;
    const char* sql = hasSourceFilter
        ? "SELECT c.id, d.source_uri, d.title, c.chunk_index, c.text "
          "FROM chunks c "
          "JOIN documents d ON d.id = c.document_id "
          "WHERE d.source_uri = ? "
          "ORDER BY d.source_uri, c.chunk_index"
        : "SELECT c.id, d.source_uri, d.title, c.chunk_index, c.text "
          "FROM chunks c "
          "JOIN documents d ON d.id = c.document_id "
          "ORDER BY d.source_uri, c.chunk_index";

    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    if (hasSourceFilter && !bindText(stmt, 1, sourceUri)) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        const long long chunkId = sqlite3_column_int64(stmt, 0);
        const std::string rowSourceUri = columnText(stmt, 1);
        const std::string title = columnText(stmt, 2);
        const int chunkIndex = sqlite3_column_int(stmt, 3);
        const std::string text = columnText(stmt, 4);
        const int visitorRc = visitor(
            chunkId,
            rowSourceUri.c_str(),
            title.c_str(),
            chunkIndex,
            text.c_str(),
            user_data);
        if (visitorRc != 0) {
            sqlite3_finalize(stmt);
            if (handle->lastError.empty()) {
                setError(handle, "chunk visitor failed");
            }
            return visitorRc;
        }
    }

    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return CPRAG_OK;
}

int cprag_delete_source(cprag_handle* handle, const char* source_uri, char* out_json, size_t out_json_size)
{
    if (handle == nullptr || source_uri == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }

    int rc = execSql(handle, "BEGIN IMMEDIATE");
    if (rc != CPRAG_OK) {
        return rc;
    }

    sqlite3_stmt* stmt = nullptr;
    rc = prepare(handle, "DELETE FROM chunks WHERE document_id IN (SELECT id FROM documents WHERE source_uri = ?)", &stmt);
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }
    bindText(stmt, 1, source_uri);
    int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        execSql(handle, "ROLLBACK");
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    rc = prepare(handle, "DELETE FROM documents WHERE source_uri = ?", &stmt);
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }
    bindText(stmt, 1, source_uri);
    stepRc = sqlite3_step(stmt);
    const int deleted = sqlite3_changes(handle->db);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        execSql(handle, "ROLLBACK");
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    if (deleted > 0) {
        rc = invalidateVectorIndexState(handle);
        if (rc != CPRAG_OK) {
            execSql(handle, "ROLLBACK");
            return rc;
        }
    }

    rc = execSql(handle, "COMMIT");
    if (rc != CPRAG_OK) {
        return rc;
    }

    return copyJson(handle, buildDeleteSourceJson(source_uri, deleted), out_json, out_json_size);
}

int cprag_vector_index_available(void)
{
#ifdef CPRAG_HAVE_FAISS
    return 1;
#else
    return 0;
#endif
}

int cprag_add_chunk_embedding(
    cprag_handle* handle,
    long long chunk_id,
    const char* embedding_model,
    const float* vector,
    size_t dimension)
{
    return cprag_add_chunk_embedding_profile(
        handle,
        chunk_id,
        embedding_model,
        kRawEmbeddingProfile,
        vector,
        dimension);
}

int cprag_add_chunk_embedding_profile(
    cprag_handle* handle,
    long long chunk_id,
    const char* embedding_model,
    const char* embedding_profile,
    const float* vector,
    size_t dimension)
{
    if (handle == nullptr || embedding_model == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }
    const std::string model(embedding_model);
    if (model.empty()) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "embedding_model is required");
    }
    const std::string profile = embeddingProfileOrDefault(embedding_profile);
    if (chunk_id <= 0) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "chunk_id must be positive");
    }

    int effectiveDimension = 0;
    const int vectorRc = validateVector(handle, vector, dimension, &effectiveDimension);
    if (vectorRc != CPRAG_OK) {
        return vectorRc;
    }
    if (!chunkExists(handle, chunk_id)) {
        return setErrorCode(handle, CPRAG_NOT_FOUND, "chunk was not found");
    }

    sqlite3_stmt* stmt = nullptr;
    const int prepRc = prepare(handle,
        "INSERT INTO chunk_embeddings (chunk_id, embedding_model, embedding_profile, dimension, vector) "
        "VALUES (?, ?, ?, ?, ?) "
        "ON CONFLICT(chunk_id, embedding_model) DO UPDATE SET "
        "embedding_profile=excluded.embedding_profile, dimension=excluded.dimension, "
        "vector=excluded.vector, updated_at=CURRENT_TIMESTAMP",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    sqlite3_bind_int64(stmt, 1, chunk_id);
    const bool bound = bindText(stmt, 2, model)
        && bindText(stmt, 3, profile)
        && sqlite3_bind_int(stmt, 4, effectiveDimension) == SQLITE_OK
        && bindBlob(
            stmt,
            5,
            vector,
            static_cast<int>(static_cast<size_t>(effectiveDimension) * sizeof(float)));
    if (!bound) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    const int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return invalidateVectorIndexState(handle);
}

int cprag_rebuild_vector_index(
    cprag_handle* handle,
    const char* embedding_model,
    char* out_json,
    size_t out_json_size)
{
    return cprag_rebuild_vector_index_profile(handle, embedding_model, "", out_json, out_json_size);
}

int cprag_rebuild_vector_index_profile(
    cprag_handle* handle,
    const char* embedding_model,
    const char* embedding_profile,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || embedding_model == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }
    const std::string model(embedding_model);
    if (model.empty()) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "embedding_model is required");
    }
    const std::string requestedProfile = valueOrEmpty(embedding_profile);

#ifndef CPRAG_HAVE_FAISS
    (void)out_json;
    (void)out_json_size;
    return setErrorCode(handle, CPRAG_UNSUPPORTED, "FAISS support is not enabled in this build");
#else
    try {
        const std::vector<ChunkEmbedding> embeddings = loadChunkEmbeddings(handle, model, requestedProfile);
        if (embeddings.empty()) {
            return setErrorCode(handle, CPRAG_NOT_FOUND, "no chunk embeddings were found for embedding_model");
        }

        const int dimension = embeddings.front().dimension;
        const std::string effectiveProfile = embeddings.front().embeddingProfile.empty()
            ? kRawEmbeddingProfile
            : embeddings.front().embeddingProfile;
        std::vector<float> matrix;
        matrix.reserve(embeddings.size() * static_cast<size_t>(dimension));
        std::vector<faiss::idx_t> ids;
        ids.reserve(embeddings.size());
        for (const ChunkEmbedding& embedding : embeddings) {
            if (embedding.dimension != dimension) {
                return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "all embeddings for a model must have the same dimension");
            }
            const std::string profile = embedding.embeddingProfile.empty()
                ? kRawEmbeddingProfile
                : embedding.embeddingProfile;
            if (profile != effectiveProfile) {
                return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "all embeddings for a model must have the same embedding_profile");
            }
            matrix.insert(matrix.end(), embedding.vector.begin(), embedding.vector.end());
            ids.push_back(static_cast<faiss::idx_t>(embedding.chunkId));
        }

        faiss::IndexIDMap index(new faiss::IndexFlatL2(dimension));
        index.add_with_ids(
            static_cast<faiss::idx_t>(embeddings.size()),
            matrix.data(),
            ids.data());
        const std::filesystem::path indexPath = vectorIndexPathForLibrary(handle->libraryPath);
        faiss::write_index(&index, indexPath.string().c_str());

        const int stateRc = upsertVectorIndexState(
            handle,
            model,
            effectiveProfile,
            dimension,
            static_cast<long long>(embeddings.size()));
        if (stateRc != CPRAG_OK) {
            return stateRc;
        }
        return copyJson(
            handle,
            buildVectorRebuildJson(handle, model, effectiveProfile, dimension, static_cast<long long>(embeddings.size())),
            out_json,
            out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
#endif
}

int cprag_vector_search(
    cprag_handle* handle,
    const char* embedding_model,
    const float* query_vector,
    size_t dimension,
    int top_k,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    std::vector<VectorHit> hits;
    std::string effectiveModel;
    std::string effectiveProfile;
    int effectiveDimension = 0;
    const int rc = loadVectorHits(
        handle,
        embedding_model,
        query_vector,
        dimension,
        top_k,
        &hits,
        &effectiveModel,
        &effectiveProfile,
        &effectiveDimension);
    if (rc != CPRAG_OK) {
        return rc;
    }
    return copyJson(
        handle,
        buildVectorSearchJson(effectiveModel, effectiveProfile, effectiveDimension, hits),
        out_json,
        out_json_size);
}

int cprag_build_chunk_embedding_text(
    cprag_handle* handle,
    long long chunk_id,
    const char* embedding_profile,
    char* out_text,
    size_t out_text_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (chunk_id <= 0) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "chunk_id must be positive");
    }

    const std::string profile = valueOrEmpty(embedding_profile).empty()
        ? kSemanticEmbeddingProfile
        : valueOrEmpty(embedding_profile);
    try {
        return copyText(handle, buildChunkEmbeddingText(loadChunkById(handle, chunk_id), profile), out_text, out_text_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_NOT_FOUND, ex.what());
    }
}

int cprag_vector_status(cprag_handle* handle, char* out_json, size_t out_json_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        const VectorIndexState state = loadVectorIndexState(handle);
        return copyJson(
            handle,
            buildVectorStatusJson(handle, state, countStoredEmbeddings(handle)),
            out_json,
            out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
}

int cprag_vocabulary(char* out_json, size_t out_json_size)
{
    cprag_handle tempHandle;
    return copyJson(&tempHandle, buildVocabularyJson(), out_json, out_json_size);
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

int cprag_search_with_vector(
    cprag_handle* handle,
    const char* query,
    int top_k,
    int hops,
    int mode,
    const char* embedding_model,
    const float* query_vector,
    size_t dimension,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || query == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (mode != CPRAG_SEARCH_AUTO
        && mode != CPRAG_SEARCH_LEXICAL
        && mode != CPRAG_SEARCH_VECTOR
        && mode != CPRAG_SEARCH_HYBRID) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "search mode must be auto, lexical, vector, or hybrid");
    }

    try {
        const int effectiveTopK = top_k <= 0 ? 3 : top_k;
        const int effectiveHops = hops < 0 ? 0 : hops;
        const std::string queryText(query);
        const std::vector<Anchor> anchors = findAnchors(handle, queryText, effectiveTopK);

        std::vector<ChunkHit> chunks;
        std::vector<VectorHit> vectorHits;
        std::string effectiveModel;
        std::string effectiveProfile;
        int effectiveDimension = 0;
        int effectiveMode = CPRAG_SEARCH_LEXICAL;
        bool vectorUsed = false;
        std::string fallbackReason;

        if (mode == CPRAG_SEARCH_LEXICAL || (mode == CPRAG_SEARCH_AUTO && query_vector == nullptr)) {
            chunks = searchChunks(handle, queryText, effectiveTopK);
            effectiveMode = CPRAG_SEARCH_LEXICAL;
            if (mode == CPRAG_SEARCH_AUTO && query_vector == nullptr) {
                fallbackReason = "query vector was not provided";
            }
        } else {
            const int vectorRc = loadVectorHits(
                handle,
                embedding_model,
                query_vector,
                dimension,
                effectiveTopK,
                &vectorHits,
                &effectiveModel,
                &effectiveProfile,
                &effectiveDimension);

            if (vectorRc == CPRAG_OK) {
                vectorUsed = true;
                if (mode == CPRAG_SEARCH_VECTOR) {
                    effectiveMode = CPRAG_SEARCH_VECTOR;
                    for (const VectorHit& hit : vectorHits) {
                        chunks.push_back(chunkHitFromVectorHit(hit));
                    }
                } else {
                    effectiveMode = CPRAG_SEARCH_HYBRID;
                    chunks = mergeChunkHits(searchChunks(handle, queryText, effectiveTopK), vectorHits, effectiveTopK);
                }
            } else if (mode == CPRAG_SEARCH_AUTO
                && (vectorRc == CPRAG_UNSUPPORTED || vectorRc == CPRAG_NOT_FOUND)) {
                chunks = searchChunks(handle, queryText, effectiveTopK);
                effectiveMode = CPRAG_SEARCH_LEXICAL;
                fallbackReason = cprag_last_error(handle);
            } else {
                return vectorRc;
            }
        }

        const std::string metadata = buildSearchMetadataJson(
            mode,
            effectiveMode,
            vectorUsed,
            effectiveModel,
            effectiveProfile,
            effectiveDimension,
            fallbackReason);
        const std::string json = buildSubgraphJson(
            loadEntities(handle),
            loadEdges(handle),
            anchors,
            effectiveHops,
            "",
            chunks,
            metadata);
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

int cprag_shortest_path(
    cprag_handle* handle,
    const char* source_id,
    const char* target_id,
    const char* relationship_filter_csv,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || source_id == nullptr || target_id == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        const std::string source(source_id);
        const std::string target(target_id);
        const std::vector<Entity> entities = loadEntities(handle);
        const std::vector<Edge> edges = loadEdges(handle);
        std::unordered_set<std::string> entityIds;
        for (const Entity& entity : entities) {
            entityIds.insert(entity.id);
        }
        if (entityIds.find(source) == entityIds.end() || entityIds.find(target) == entityIds.end()) {
            return copyJson(handle, buildShortestPathJson(entities, edges, {}, {}), out_json, out_json_size);
        }

        const auto filters = relationFilterSet(valueOrEmpty(relationship_filter_csv));
        std::queue<std::string> queue;
        std::unordered_set<std::string> visited;
        std::unordered_map<std::string, std::string> previousNode;
        std::unordered_map<std::string, long long> previousEdge;

        visited.insert(source);
        queue.push(source);
        while (!queue.empty() && visited.find(target) == visited.end()) {
            const std::string current = queue.front();
            queue.pop();
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
                if (visited.insert(next).second) {
                    previousNode[next] = current;
                    previousEdge[next] = edge.rowid;
                    queue.push(next);
                    if (next == target) {
                        break;
                    }
                }
            }
        }

        if (visited.find(target) == visited.end()) {
            return copyJson(handle, buildShortestPathJson(entities, edges, {}, {}), out_json, out_json_size);
        }

        std::vector<std::string> nodeIds;
        std::vector<long long> edgeIdsReversed;
        std::string current = target;
        nodeIds.push_back(current);
        while (current != source) {
            edgeIdsReversed.push_back(previousEdge[current]);
            current = previousNode[current];
            nodeIds.push_back(current);
        }
        std::reverse(nodeIds.begin(), nodeIds.end());
        std::reverse(edgeIdsReversed.begin(), edgeIdsReversed.end());
        return copyJson(handle, buildShortestPathJson(entities, edges, nodeIds, edgeIdsReversed), out_json, out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
}

int cprag_subgraph(
    cprag_handle* handle,
    const char* node_type_filter_csv,
    const char* relationship_type_filter_csv,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        const std::string json = buildTypedSubgraphJson(
            loadEntities(handle),
            loadEdges(handle),
            valueOrEmpty(node_type_filter_csv),
            valueOrEmpty(relationship_type_filter_csv),
            limit);
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
    long long embeddingCount = 0;

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

    try {
        embeddingCount = countStoredEmbeddings(handle);
    } catch (const std::exception&) {
        embeddingCount = 0;
    }

    VectorIndexState vectorState;
    try {
        vectorState = loadVectorIndexState(handle);
    } catch (const std::exception&) {
        vectorState = {};
    }

    std::ostringstream out;
    out << "{\"success\":true,\"entities\":" << entityCount
        << ",\"edges\":" << edgeCount
        << ",\"documents\":" << documentCount
        << ",\"chunks\":" << chunkCount
        << ",\"vectors\":{\"enabled\":";
#ifdef CPRAG_HAVE_FAISS
    out << "true";
#else
    out << "false";
#endif
    out << ",\"stored_embeddings\":" << embeddingCount
        << ",\"active_index\":";
    if (!vectorState.present) {
        out << "null";
    } else {
        out << "{\"embedding_model\":" << jsonString(vectorState.embeddingModel)
            << ",\"dimension\":" << vectorState.dimension
            << ",\"metric\":" << jsonString(vectorState.metric)
            << ",\"embedding_count\":" << vectorState.embeddingCount
            << ",\"index_path\":" << jsonString(vectorState.indexPath)
            << ",\"backend\":" << jsonString(vectorState.backend)
            << ",\"updated_at\":" << jsonString(vectorState.updatedAt)
            << '}';
    }
    out << '}'
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
    case CPRAG_UNSUPPORTED:
        return "unsupported";
    case CPRAG_INTERNAL_ERROR:
        return "internal error";
    default:
        return "unknown error";
    }
}

} // extern "C"
