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

struct CandidateMentionEvidence {
    long long id {0};
    std::string sourceUri;
    long long chunkId {0};
    std::string candidate;
    std::string normalized;
    int priority {0};
    int properCount {0};
    int knownCount {0};
    int cueCount {0};
    int mentionCount {0};
    std::string status;
    std::string candidateType;
    std::string canonicalLabel;
    std::string aliases;
    std::string disambiguation;
    double confidence {0.0};
    std::string adjudicator;
};

struct ExtractionQueueItem {
    long long chunkId {0};
    std::string sourceUri;
    std::string title;
    int chunkIndex {0};
    int length {0};
    double score {0.0};
    std::string evidenceClass;
    int evidencePenalty {0};
    int conceptCount {0};
    int supportCount {0};
    int typeDiversity {0};
    int relationCueCount {0};
    int rareConceptCount {0};
    int ambiguityCount {0};
    int maxPriority {0};
    int qualityPenalty {0};
    std::string qualityNotes;
    std::unordered_map<std::string, int> typeCounts;
    std::unordered_set<std::string> conceptIds;
    std::vector<std::pair<std::string, std::string>> sampleConcepts;
    std::string reason;
    std::string metadataJson;
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
CREATE TABLE IF NOT EXISTS candidate_mentions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    profile_id TEXT NOT NULL,
    source_uri TEXT NOT NULL DEFAULT '',
    chunk_id INTEGER NOT NULL,
    stage TEXT NOT NULL DEFAULT 'stage1',
    extractor TEXT NOT NULL DEFAULT 'deterministic',
    candidate TEXT NOT NULL,
    normalized_candidate TEXT NOT NULL,
    priority INTEGER NOT NULL DEFAULT 0,
    proper_count INTEGER NOT NULL DEFAULT 0,
    known_count INTEGER NOT NULL DEFAULT 0,
    cue_count INTEGER NOT NULL DEFAULT 0,
    metadata_json TEXT NOT NULL DEFAULT '{}',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (chunk_id) REFERENCES chunks(id) ON DELETE CASCADE,
    UNIQUE(profile_id, source_uri, chunk_id, stage, extractor, normalized_candidate)
);
CREATE INDEX IF NOT EXISTS idx_candidate_mentions_profile_source
    ON candidate_mentions(profile_id, source_uri, normalized_candidate);
CREATE INDEX IF NOT EXISTS idx_candidate_mentions_chunk
    ON candidate_mentions(chunk_id);
CREATE TABLE IF NOT EXISTS candidate_adjudications (
    profile_id TEXT NOT NULL,
    normalized_candidate TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    candidate_type TEXT NOT NULL DEFAULT '',
    canonical_label TEXT NOT NULL DEFAULT '',
    aliases TEXT NOT NULL DEFAULT '',
    disambiguation TEXT NOT NULL DEFAULT '',
    confidence REAL NOT NULL DEFAULT 0.0,
    adjudicator TEXT NOT NULL DEFAULT '',
    metadata_json TEXT NOT NULL DEFAULT '{}',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (profile_id, normalized_candidate)
);
CREATE INDEX IF NOT EXISTS idx_candidate_adjudications_profile_status
    ON candidate_adjudications(profile_id, status);
CREATE TABLE IF NOT EXISTS work_queue (
    profile_id TEXT NOT NULL,
    queue_name TEXT NOT NULL DEFAULT 'default',
    item_type TEXT NOT NULL DEFAULT 'work-item',
    item_id TEXT NOT NULL,
    subject_id INTEGER NOT NULL DEFAULT 0,
    source_uri TEXT NOT NULL DEFAULT '',
    title TEXT NOT NULL DEFAULT '',
    item_index INTEGER NOT NULL DEFAULT 0,
    score REAL NOT NULL DEFAULT 0.0,
    status TEXT NOT NULL DEFAULT 'pending',
    reason TEXT NOT NULL DEFAULT '',
    metadata_json TEXT NOT NULL DEFAULT '{}',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (profile_id, queue_name, item_id)
);
CREATE INDEX IF NOT EXISTS idx_work_queue_profile_status
    ON work_queue(profile_id, queue_name, item_type, status, score DESC);
CREATE TABLE IF NOT EXISTS work_attempts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    profile_id TEXT NOT NULL,
    queue_name TEXT NOT NULL DEFAULT 'default',
    item_type TEXT NOT NULL DEFAULT 'work-item',
    item_id TEXT NOT NULL,
    subject_id INTEGER NOT NULL DEFAULT 0,
    worker TEXT NOT NULL DEFAULT '',
    model TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT '',
    accepted_nodes INTEGER NOT NULL DEFAULT 0,
    accepted_relationships INTEGER NOT NULL DEFAULT 0,
    raw_output TEXT NOT NULL DEFAULT '',
    metadata_json TEXT NOT NULL DEFAULT '{}',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_work_attempts_profile_queue
    ON work_attempts(profile_id, queue_name, item_type, item_id, created_at DESC);
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

std::string trimCopy(const std::string& value)
{
    const auto first = std::find_if_not(value.begin(), value.end(), [](unsigned char c) {
        return std::isspace(c) != 0;
    });
    const auto last = std::find_if_not(value.rbegin(), value.rend(), [](unsigned char c) {
        return std::isspace(c) != 0;
    }).base();
    if (first >= last) {
        return {};
    }
    return std::string(first, last);
}

std::string lowerAscii(const std::string& value)
{
    std::string out;
    out.reserve(value.size());
    for (const unsigned char ch : value) {
        out.push_back(static_cast<char>(std::tolower(ch)));
    }
    return out;
}

std::string slugForId(const std::string& value)
{
    std::string out;
    bool lastDash = false;
    for (const unsigned char ch : lowerAscii(value)) {
        if (std::isalnum(ch) != 0) {
            out.push_back(static_cast<char>(ch));
            lastDash = false;
        } else if (!lastDash && !out.empty()) {
            out.push_back('-');
            lastDash = true;
        }
    }
    while (!out.empty() && out.back() == '-') {
        out.pop_back();
    }
    return out.empty() ? "unknown" : out;
}

std::string sanitizeCsvField(const std::string& value)
{
    std::string out;
    for (const char ch : value) {
        if (ch == ',' || ch == '|' || ch == ';' || ch == '\t' || ch == '\n' || ch == '\r') {
            if (!out.empty() && out.back() != ' ') {
                out.push_back(' ');
            }
        } else {
            out.push_back(ch);
        }
    }
    return trimCopy(out);
}

bool appendAlias(std::string& out, const std::string& value)
{
    const std::string trimmed = trimCopy(value);
    if (trimmed.empty()) {
        return false;
    }
    const std::string upper = lowerAscii(trimmed);
    if (upper == "none" || upper == "n/a" || upper == "na" || upper == "null") {
        return false;
    }
    const std::string safe = sanitizeCsvField(trimmed);
    if (safe.empty()) {
        return false;
    }
    if (!out.empty()) {
        out.push_back(',');
    }
    out += safe;
    return true;
}

std::string candidateAliasCsv(const CandidateMentionEvidence& row)
{
    std::string out;
    appendAlias(out, row.canonicalLabel);
    appendAlias(out, row.candidate);
    appendAlias(out, row.aliases);
    appendAlias(out, row.normalized);
    return out;
}

std::string candidateConceptId(const std::string& graphNamespace, const CandidateMentionEvidence& row)
{
    const std::string type = row.candidateType.empty() ? "unknown" : row.candidateType;
    std::string basis = trimCopy(row.canonicalLabel);
    if (basis.empty()) {
        basis = trimCopy(row.candidate);
    }
    if (basis.empty()) {
        basis = row.normalized;
    }
    return graphNamespace + ":" + type + ":" + slugForId(basis);
}

std::string evidenceChunkId(long long chunkId)
{
    return "evidence:chunk:" + std::to_string(chunkId);
}

std::string conceptSuffixFromId(const std::string& conceptId)
{
    const size_t pos = conceptId.rfind(':');
    if (pos == std::string::npos || pos + 1 >= conceptId.size()) {
        return conceptId;
    }
    return conceptId.substr(pos + 1);
}

int countOccurrences(const std::string& text, const std::string& needle)
{
    if (needle.empty()) {
        return 0;
    }
    int count = 0;
    size_t pos = 0;
    while ((pos = text.find(needle, pos)) != std::string::npos) {
        ++count;
        pos += needle.size();
    }
    return count;
}

int countFootnoteMarkers(const std::string& text)
{
    int count = 0;
    for (size_t i = 0; i + 2 < text.size(); ++i) {
        if (text[i] == '[' && std::isdigit(static_cast<unsigned char>(text[i + 1])) != 0) {
            ++count;
        }
    }
    return count;
}

int chunkShapePenalty(const std::string& text, std::string* notes)
{
    int penalty = 0;
    std::vector<std::string> flags;
    const int dashRuns = countOccurrences(text, "--");
    if (dashRuns >= 4) {
        penalty += 22;
        flags.push_back("heading-list");
    }
    const int footnotes = countFootnoteMarkers(text);
    if (footnotes >= 2) {
        penalty += std::min(25, footnotes * 5);
        flags.push_back("footnote-heavy");
    }
    if (text.find("[Illustration") != std::string::npos) {
        penalty += 8;
        flags.push_back("illustration-caption");
    }
    if (text.size() < 400) {
        penalty += 5;
        flags.push_back("short");
    }
    if (notes != nullptr) {
        std::ostringstream out;
        for (size_t i = 0; i < flags.size(); ++i) {
            if (i != 0) {
                out << ",";
            }
            out << flags[i];
        }
        *notes = out.str();
    }
    return penalty;
}

bool containsFolded(const std::string& text, const std::string& needle)
{
    if (needle.empty()) {
        return false;
    }
    return lowerAscii(text).find(lowerAscii(needle)) != std::string::npos;
}

std::string evidenceClassForText(const std::string& title, const std::string& text)
{
    const std::string haystack = title + "\n" + text;
    if (containsFolded(haystack, "index") || containsFolded(haystack, "contents")) {
        return "index-or-toc";
    }
    if (containsFolded(haystack, "fig.") || containsFolded(haystack, "illustration")
        || containsFolded(haystack, "caption")) {
        return "caption-or-illustration";
    }
    if (containsFolded(haystack, "footnote") || containsFolded(haystack, "note.")) {
        return "footnote-or-note";
    }
    if (containsFolded(haystack, "quoted") || containsFolded(haystack, "says ")
        || containsFolded(haystack, "according to")) {
        return "quoted-or-attributed";
    }
    return "narrative";
}

int evidenceClassPenalty(const std::string& evidenceClass)
{
    if (evidenceClass == "index-or-toc") {
        return 24;
    }
    if (evidenceClass == "caption-or-illustration") {
        return 14;
    }
    if (evidenceClass == "footnote-or-note") {
        return 10;
    }
    return 0;
}

std::string directnessForRelationship(const std::string& relationshipType)
{
    if (relationshipType == "mentioned-in") {
        return "mention-only";
    }
    if (relationshipType == "candidate-for") {
        return "ambiguity-lead";
    }
    return "accepted-typed-edge";
}

double typeWeight(const std::string& nodeType)
{
    if (nodeType == "event") {
        return 4.0;
    }
    if (nodeType == "clan" || nodeType == "military-unit") {
        return 2.5;
    }
    if (nodeType == "person") {
        return 2.0;
    }
    if (nodeType == "office" || nodeType == "polity") {
        return 1.5;
    }
    if (nodeType == "place" || nodeType == "institution") {
        return 1.2;
    }
    if (nodeType == "source-work") {
        return 0.8;
    }
    if (nodeType == "generic" || nodeType == "unknown") {
        return -1.0;
    }
    return 1.0;
}

std::string joinTypeNames(const std::unordered_map<std::string, int>& typeCounts)
{
    std::vector<std::string> names;
    names.reserve(typeCounts.size());
    for (const auto& entry : typeCounts) {
        names.push_back(entry.first);
    }
    std::sort(names.begin(), names.end());
    std::ostringstream out;
    for (size_t i = 0; i < names.size(); ++i) {
        if (i != 0) {
            out << "/";
        }
        out << names[i];
    }
    return out.str();
}

std::string topTypeSummary(const std::unordered_map<std::string, int>& typeCounts)
{
    std::vector<std::pair<std::string, int>> types(typeCounts.begin(), typeCounts.end());
    std::sort(types.begin(), types.end(), [](const auto& lhs, const auto& rhs) {
        if (lhs.second != rhs.second) {
            return lhs.second > rhs.second;
        }
        return lhs.first < rhs.first;
    });
    std::ostringstream out;
    const size_t count = std::min<size_t>(types.size(), 5);
    for (size_t i = 0; i < count; ++i) {
        if (i != 0) {
            out << ",";
        }
        out << types[i].first << ":" << types[i].second;
    }
    return out.str();
}

std::string extractionQueueReason(const ExtractionQueueItem& item)
{
    std::ostringstream out;
    out << "concepts=" << item.conceptCount
        << "; types=" << joinTypeNames(item.typeCounts)
        << "; relation_cues=" << item.relationCueCount
        << "; rare=" << item.rareConceptCount
        << "; ambiguity=" << item.ambiguityCount
        << "; support=" << item.supportCount
        << "; evidence=" << item.evidenceClass;
    if (item.evidencePenalty > 0) {
        out << "; evidence_penalty=" << item.evidencePenalty;
    }
    if (item.qualityPenalty > 0) {
        out << "; text_penalty=" << item.qualityPenalty;
        if (!item.qualityNotes.empty()) {
            out << "(" << item.qualityNotes << ")";
        }
    }
    const std::string topTypes = topTypeSummary(item.typeCounts);
    if (!topTypes.empty()) {
        out << "; top_types=" << topTypes;
    }
    return out.str();
}

std::string extractionQueueMetadata(
    const ExtractionQueueItem& item,
    const std::string& profileId,
    const std::string& queueId,
    const std::string& graphNamespace,
    const std::string& nodeTypeFilterCsv)
{
    std::ostringstream out;
    out << "{\"stage\":\"stage2b-rank\""
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"graph_namespace\":" << jsonString(graphNamespace)
        << ",\"node_type_filter_csv\":" << jsonString(nodeTypeFilterCsv)
        << ",\"concept_count\":" << item.conceptCount
        << ",\"support_count\":" << item.supportCount
        << ",\"type_diversity\":" << item.typeDiversity
        << ",\"relation_cue_count\":" << item.relationCueCount
        << ",\"rare_concept_count\":" << item.rareConceptCount
        << ",\"ambiguity_count\":" << item.ambiguityCount
        << ",\"max_priority\":" << item.maxPriority
        << ",\"evidence_class\":" << jsonString(item.evidenceClass)
        << ",\"directness\":\"retrieved-source-passage\""
        << ",\"source_directness\":\"mention-only\""
        << ",\"evidence_penalty\":" << item.evidencePenalty
        << ",\"quality_penalty\":" << item.qualityPenalty
        << ",\"quality_notes\":" << jsonString(item.qualityNotes)
        << ",\"type_counts\":{";
    std::vector<std::pair<std::string, int>> types(item.typeCounts.begin(), item.typeCounts.end());
    std::sort(types.begin(), types.end(), [](const auto& lhs, const auto& rhs) {
        return lhs.first < rhs.first;
    });
    for (size_t i = 0; i < types.size(); ++i) {
        if (i != 0) {
            out << ",";
        }
        out << jsonString(types[i].first) << ":" << types[i].second;
    }
    out << "},\"sample_concepts\":[";
    const size_t conceptCount = std::min<size_t>(item.sampleConcepts.size(), 8);
    for (size_t i = 0; i < conceptCount; ++i) {
        if (i != 0) {
            out << ",";
        }
        out << "{\"label\":" << jsonString(item.sampleConcepts[i].first)
            << ",\"type\":" << jsonString(item.sampleConcepts[i].second)
            << "}";
    }
    out << "]}";
    return out.str();
}

std::string candidateConceptMetadata(
    const std::string& profileId,
    const CandidateMentionEvidence& row,
    const std::string& aliases)
{
    std::ostringstream out;
    out << "{\"profile_id\":" << jsonString(profileId)
        << ",\"stage\":\"stage2-candidate-seed\""
        << ",\"normalized_candidate\":" << jsonString(row.normalized)
        << ",\"aliases\":" << jsonString(aliases)
        << ",\"mention_count\":" << row.mentionCount
        << "}";
    return out.str();
}

std::string candidateEvidenceChunkMetadata(const std::string& profileId, const CandidateMentionEvidence& row)
{
    std::ostringstream out;
    out << "{\"profile_id\":" << jsonString(profileId)
        << ",\"stage\":\"stage2-candidate-seed\""
        << ",\"chunk_id\":" << row.chunkId
        << ",\"source_uri\":" << jsonString(row.sourceUri)
        << ",\"evidence_class\":\"candidate-evidence-chunk\""
        << ",\"directness\":\"retrieved-source-passage\""
        << "}";
    return out.str();
}

std::string candidateMentionMetadata(const std::string& profileId, const CandidateMentionEvidence& row)
{
    std::ostringstream out;
    out << "{\"profile_id\":" << jsonString(profileId)
        << ",\"stage\":\"stage2-candidate-seed\""
        << ",\"chunk_id\":" << row.chunkId
        << ",\"candidate_mention_id\":" << row.id
        << ",\"normalized_candidate\":" << jsonString(row.normalized)
        << ",\"priority\":" << row.priority
        << ",\"confidence\":" << row.confidence
        << ",\"evidence_class\":\"candidate-mention\""
        << ",\"directness\":\"mention-only\""
        << "}";
    return out.str();
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

std::string jsonObjectStringValue(const std::string& json, const std::string& key)
{
    const std::string quotedKey = "\"" + key + "\"";
    size_t pos = json.find(quotedKey);
    if (pos == std::string::npos) {
        return {};
    }
    pos = json.find(':', pos + quotedKey.size());
    if (pos == std::string::npos) {
        return {};
    }
    ++pos;
    while (pos < json.size() && std::isspace(static_cast<unsigned char>(json[pos])) != 0) {
        ++pos;
    }
    if (pos >= json.size() || json[pos] != '"') {
        return {};
    }
    ++pos;

    std::string value;
    bool escaped = false;
    for (; pos < json.size(); ++pos) {
        const char ch = json[pos];
        if (escaped) {
            switch (ch) {
            case '"':
            case '\\':
            case '/':
                value.push_back(ch);
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
            default:
                value.push_back(ch);
                break;
            }
            escaped = false;
            continue;
        }
        if (ch == '\\') {
            escaped = true;
            continue;
        }
        if (ch == '"') {
            break;
        }
        value.push_back(ch);
    }
    return value;
}

std::vector<std::string> conceptAliases(const Entity& entity)
{
    std::vector<std::string> aliases;
    if (!entity.label.empty()) {
        aliases.push_back(entity.label);
    }

    const std::string aliasCsv = jsonObjectStringValue(entity.metadataJson, "aliases");
    for (std::string alias : splitCsv(aliasCsv)) {
        if (alias.find('|') != std::string::npos) {
            std::string current;
            std::istringstream stream(alias);
            while (std::getline(stream, current, '|')) {
                if (!current.empty()) {
                    aliases.push_back(current);
                }
            }
        } else if (!alias.empty()) {
            aliases.push_back(alias);
        }
    }

    std::sort(aliases.begin(), aliases.end(), [](const std::string& lhs, const std::string& rhs) {
        if (lhs.size() != rhs.size()) {
            return lhs.size() > rhs.size();
        }
        return lhs < rhs;
    });
    aliases.erase(std::unique(aliases.begin(), aliases.end()), aliases.end());
    return aliases;
}

void appendAliasArray(std::ostringstream& out, const std::vector<std::string>& aliases)
{
    out << '[';
    for (size_t i = 0; i < aliases.size(); ++i) {
        if (i > 0) {
            out << ',';
        }
        out << jsonString(aliases[i]);
    }
    out << ']';
}

std::string buildConceptListJson(const std::vector<Entity>& entities, const std::string& nodeTypeFilterCsv)
{
    const std::unordered_set<std::string> filters = relationFilterSet(nodeTypeFilterCsv);
    std::ostringstream out;
    out << "{\"success\":true,\"concepts\":[";
    bool first = true;
    for (const Entity& entity : entities) {
        if (!entityAllowed(entity, filters)) {
            continue;
        }
        if (!first) {
            out << ',';
        }
        first = false;
        out << "{\"id\":" << jsonString(entity.id)
            << ",\"node_type\":" << jsonString(entity.nodeType)
            << ",\"label\":" << jsonString(entity.label)
            << ",\"aliases\":";
        appendAliasArray(out, conceptAliases(entity));
        out << '}';
    }
    out << "]}";
    return out.str();
}

std::string buildConceptMatchesJson(
    const std::vector<Entity>& entities,
    const std::string& text,
    const std::string& nodeTypeFilterCsv)
{
    const std::unordered_set<std::string> filters = relationFilterSet(nodeTypeFilterCsv);
    std::ostringstream out;
    out << "{\"success\":true,\"matches\":[";
    bool first = true;
    for (const Entity& entity : entities) {
        if (!entityAllowed(entity, filters)) {
            continue;
        }
        const std::vector<std::string> aliases = conceptAliases(entity);
        for (const std::string& alias : aliases) {
            if (!containsFolded(text, alias)) {
                continue;
            }
            if (!first) {
                out << ',';
            }
            first = false;
            out << "{\"id\":" << jsonString(entity.id)
                << ",\"node_type\":" << jsonString(entity.nodeType)
                << ",\"label\":" << jsonString(entity.label)
                << ",\"matched_alias\":" << jsonString(alias)
                << '}';
        }
    }
    out << "]}";
    return out.str();
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
        out << ",\"evidence_class\":" << jsonString(evidenceClassForText(chunk.title, chunk.text))
            << ",\"directness\":\"retrieved-source-passage\"";
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

struct TypedSubgraphSelection {
    std::unordered_set<std::string> includedNodes;
    std::vector<std::string> orderedNodeIds;
};

TypedSubgraphSelection selectTypedSubgraph(
    const std::vector<Entity>& entities,
    const std::vector<Edge>& edges,
    const std::string& nodeTypeFilterCsv,
    const std::string& relationshipTypeFilterCsv,
    int limit)
{
    const auto nodeFilters = relationFilterSet(nodeTypeFilterCsv);
    const auto relationFilters = relationFilterSet(relationshipTypeFilterCsv);
    const int effectiveLimit = limit <= 0 ? 100 : limit;

    TypedSubgraphSelection selection;
    for (const Entity& entity : entities) {
        if (!entityAllowed(entity, nodeFilters)) {
            continue;
        }
        if (static_cast<int>(selection.orderedNodeIds.size()) >= effectiveLimit) {
            break;
        }
        if (selection.includedNodes.insert(entity.id).second) {
            selection.orderedNodeIds.push_back(entity.id);
        }
    }

    if (nodeFilters.empty() && !relationFilters.empty()) {
        for (const Edge& edge : edges) {
            if (!edgeAllowed(edge, relationFilters)) {
                continue;
            }
            if (selection.includedNodes.insert(edge.sourceId).second) {
                selection.orderedNodeIds.push_back(edge.sourceId);
            }
            if (static_cast<int>(selection.orderedNodeIds.size()) >= effectiveLimit) {
                break;
            }
            if (selection.includedNodes.insert(edge.targetId).second) {
                selection.orderedNodeIds.push_back(edge.targetId);
            }
            if (static_cast<int>(selection.orderedNodeIds.size()) >= effectiveLimit) {
                break;
            }
        }
    }

    return selection;
}

std::string buildTypedSubgraphJson(
    const std::vector<Entity>& entities,
    const std::vector<Edge>& edges,
    const std::string& nodeTypeFilterCsv,
    const std::string& relationshipTypeFilterCsv,
    int limit)
{
    const auto relationFilters = relationFilterSet(relationshipTypeFilterCsv);
    const TypedSubgraphSelection selection = selectTypedSubgraph(
        entities,
        edges,
        nodeTypeFilterCsv,
        relationshipTypeFilterCsv,
        limit);
    if (selection.orderedNodeIds.empty()) {
        return "";
    }

    std::unordered_map<std::string, Entity> entityById;
    for (const Entity& entity : entities) {
        entityById.emplace(entity.id, entity);
    }

    std::ostringstream out;
    out << "{\"success\":true,\"subgraph\":{\"nodes\":[";
    bool first = true;
    for (const std::string& nodeId : selection.orderedNodeIds) {
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
        if (selection.includedNodes.find(edge.sourceId) == selection.includedNodes.end()
            || selection.includedNodes.find(edge.targetId) == selection.includedNodes.end()
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

std::string dotEscape(const std::string& value)
{
    std::ostringstream out;
    for (const char ch : value) {
        switch (ch) {
        case '\\':
            out << "\\\\";
            break;
        case '"':
            out << "\\\"";
            break;
        case '\n':
        case '\r':
            out << "\\n";
            break;
        case '\t':
            out << "\\t";
            break;
        default:
            out << ch;
            break;
        }
    }
    return out.str();
}

std::string dotQuoted(const std::string& value)
{
    return "\"" + dotEscape(value) + "\"";
}

std::string buildTypedSubgraphDot(
    const std::vector<Entity>& entities,
    const std::vector<Edge>& edges,
    const std::string& nodeTypeFilterCsv,
    const std::string& relationshipTypeFilterCsv,
    int limit)
{
    const auto relationFilters = relationFilterSet(relationshipTypeFilterCsv);
    const TypedSubgraphSelection selection = selectTypedSubgraph(
        entities,
        edges,
        nodeTypeFilterCsv,
        relationshipTypeFilterCsv,
        limit);
    if (selection.orderedNodeIds.empty()) {
        return "";
    }

    std::unordered_map<std::string, Entity> entityById;
    for (const Entity& entity : entities) {
        entityById.emplace(entity.id, entity);
    }

    std::ostringstream out;
    out << "digraph cprag {\n";
    out << "  graph [rankdir=LR, label=\"crexx-rag typed graph\", labelloc=t, fontsize=18];\n";
    out << "  node [shape=box, style=\"rounded,filled\", fillcolor=\"#f8fafc\", color=\"#64748b\", fontname=\"Helvetica\"];\n";
    out << "  edge [color=\"#475569\", fontname=\"Helvetica\", fontsize=10];\n\n";

    for (const std::string& nodeId : selection.orderedNodeIds) {
        const auto it = entityById.find(nodeId);
        if (it == entityById.end()) {
            continue;
        }
        const Entity& entity = it->second;
        const std::string label = entity.label.empty() ? entity.id : entity.label;
        out << "  " << dotQuoted(entity.id)
            << " [label=" << dotQuoted(label + "\n" + entity.nodeType)
            << ", tooltip=" << dotQuoted(entity.id)
            << "];\n";
    }

    out << '\n';
    for (const Edge& edge : edges) {
        if (selection.includedNodes.find(edge.sourceId) == selection.includedNodes.end()
            || selection.includedNodes.find(edge.targetId) == selection.includedNodes.end()
            || !edgeAllowed(edge, relationFilters)) {
            continue;
        }
        std::string label = edge.relationshipType;
        if (!edge.label.empty() && edge.label != edge.relationshipType) {
            label += "\n" + edge.label;
        }
        out << "  " << dotQuoted(edge.sourceId)
            << " -> " << dotQuoted(edge.targetId)
            << " [label=" << dotQuoted(label)
            << ", tooltip=" << dotQuoted("weight=" + std::to_string(edge.weight))
            << "];\n";
    }
    out << "}\n";
    return out.str();
}

int loadCandidateMentionEvidenceRows(
    cprag_handle* handle,
    const std::string& profileId,
    const std::string& statusFilter,
    const std::string& typeFilterCsv,
    int minCount,
    long long afterId,
    int limit,
    std::vector<CandidateMentionEvidence>& rows)
{
    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "WITH counts AS ("
        "  SELECT normalized_candidate, COUNT(*) AS mention_count "
        "  FROM candidate_mentions "
        "  WHERE profile_id = ? "
        "  GROUP BY normalized_candidate "
        "  HAVING COUNT(*) >= ?"
        ") "
        "SELECT cm.id, cm.source_uri, cm.chunk_id, cm.candidate, cm.normalized_candidate, "
        "cm.priority, cm.proper_count, cm.known_count, cm.cue_count, counts.mention_count, "
        "ca.status, ca.candidate_type, ca.canonical_label, ca.aliases, ca.disambiguation, "
        "ca.confidence, ca.adjudicator "
        "FROM candidate_mentions cm "
        "JOIN counts ON counts.normalized_candidate = cm.normalized_candidate "
        "JOIN candidate_adjudications ca "
        "  ON ca.profile_id = cm.profile_id AND ca.normalized_candidate = cm.normalized_candidate "
        "WHERE cm.profile_id = ? AND cm.id > ? "
        "AND (? = '' OR ca.status = ?) "
        "AND (? = '' OR instr(',' || ? || ',', ',' || ca.candidate_type || ',') > 0) "
        "ORDER BY cm.id ASC "
        "LIMIT ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    sqlite3_bind_int(stmt, 2, minCount);
    bindText(stmt, 3, profileId);
    sqlite3_bind_int64(stmt, 4, afterId);
    bindText(stmt, 5, statusFilter);
    bindText(stmt, 6, statusFilter);
    bindText(stmt, 7, typeFilterCsv);
    bindText(stmt, 8, typeFilterCsv);
    sqlite3_bind_int(stmt, 9, limit);

    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        CandidateMentionEvidence row;
        row.id = sqlite3_column_int64(stmt, 0);
        row.sourceUri = columnText(stmt, 1);
        row.chunkId = sqlite3_column_int64(stmt, 2);
        row.candidate = columnText(stmt, 3);
        row.normalized = columnText(stmt, 4);
        row.priority = sqlite3_column_int(stmt, 5);
        row.properCount = sqlite3_column_int(stmt, 6);
        row.knownCount = sqlite3_column_int(stmt, 7);
        row.cueCount = sqlite3_column_int(stmt, 8);
        row.mentionCount = sqlite3_column_int(stmt, 9);
        row.status = columnText(stmt, 10);
        row.candidateType = columnText(stmt, 11);
        row.canonicalLabel = columnText(stmt, 12);
        row.aliases = columnText(stmt, 13);
        row.disambiguation = columnText(stmt, 14);
        row.confidence = sqlite3_column_double(stmt, 15);
        row.adjudicator = columnText(stmt, 16);
        rows.push_back(std::move(row));
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return CPRAG_OK;
}

int loadConceptSlugTypes(
    cprag_handle* handle,
    const std::string& graphNamespace,
    std::unordered_map<std::string, std::unordered_set<std::string>>& slugTypes)
{
    sqlite3_stmt* stmt = nullptr;
    const char* sql = "SELECT id, node_type FROM entities WHERE (? = '' OR id LIKE ?)";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, graphNamespace);
    bindText(stmt, 2, graphNamespace.empty() ? "" : graphNamespace + ":%");
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        const std::string id = columnText(stmt, 0);
        const std::string nodeType = columnText(stmt, 1);
        slugTypes[conceptSuffixFromId(id)].insert(nodeType);
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return CPRAG_OK;
}

int edgeHasCandidateMentionSupport(
    cprag_handle* handle,
    const std::string& sourceId,
    const std::string& targetId,
    long long candidateMentionId,
    bool* found)
{
    if (found == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    *found = false;
    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "SELECT 1 "
        "FROM edges e, json_each(e.metadata_json, '$.support_evidence') support "
        "WHERE e.source_id = ? AND e.target_id = ? AND e.relationship_type = 'mentioned-in' "
        "AND json_extract(support.value, '$.candidate_mention_id') = ? "
        "LIMIT 1";
    const int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, sourceId);
    bindText(stmt, 2, targetId);
    sqlite3_bind_int64(stmt, 3, candidateMentionId);
    const int stepRc = sqlite3_step(stmt);
    if (stepRc == SQLITE_ROW) {
        *found = true;
    } else if (stepRc != SQLITE_DONE) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    sqlite3_finalize(stmt);
    return CPRAG_OK;
}

bool startsWith(const std::string& value, const std::string& prefix)
{
    return value.size() >= prefix.size() && value.compare(0, prefix.size(), prefix) == 0;
}

std::vector<std::string> splitIdList(const std::string& input)
{
    std::vector<std::string> ids;
    std::string current;
    for (const char ch : input) {
        if (ch == ',' || ch == '|' || ch == ';' || ch == '\n' || ch == '\r' || ch == '\t') {
            const std::string trimmed = trimCopy(current);
            if (!trimmed.empty()) {
                ids.push_back(trimmed);
            }
            current.clear();
        } else {
            current.push_back(ch);
        }
    }
    const std::string trimmed = trimCopy(current);
    if (!trimmed.empty()) {
        ids.push_back(trimmed);
    }
    std::sort(ids.begin(), ids.end());
    ids.erase(std::unique(ids.begin(), ids.end()), ids.end());
    return ids;
}

int entityExists(cprag_handle* handle, const std::string& id, bool* exists)
{
    if (exists == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    *exists = false;
    sqlite3_stmt* stmt = nullptr;
    const int rc = prepare(handle, "SELECT 1 FROM entities WHERE id = ? LIMIT 1", &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, id);
    const int stepRc = sqlite3_step(stmt);
    if (stepRc == SQLITE_ROW) {
        *exists = true;
    } else if (stepRc != SQLITE_DONE) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    sqlite3_finalize(stmt);
    return CPRAG_OK;
}

int recordWorkAttemptInternal(
    cprag_handle* handle,
    const std::string& profileId,
    const std::string& queueId,
    const std::string& itemType,
    const std::string& itemId,
    long long subjectId,
    const std::string& worker,
    const std::string& model,
    const std::string& status,
    int acceptedNodes,
    int acceptedRelationships,
    const std::string& rawOutput,
    const std::string& metadata,
    bool manageTransaction,
    std::string* resultJson)
{
    if (status.empty()) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "status is required");
    }
    const int metadataRc = validateMetadataJson(handle, metadata);
    if (metadataRc != CPRAG_OK) {
        return metadataRc;
    }

    int rc = CPRAG_OK;
    if (manageTransaction) {
        rc = execSql(handle, "BEGIN IMMEDIATE");
        if (rc != CPRAG_OK) {
            return rc;
        }
    }

    sqlite3_stmt* stmt = nullptr;
    rc = prepare(
        handle,
        "INSERT INTO work_attempts "
        "(profile_id, queue_name, item_type, item_id, subject_id, worker, model, status, accepted_nodes, accepted_relationships, raw_output, metadata_json) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        &stmt);
    if (rc != CPRAG_OK) {
        if (manageTransaction) {
            execSql(handle, "ROLLBACK");
        }
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, itemType);
    bindText(stmt, 4, itemId);
    sqlite3_bind_int64(stmt, 5, subjectId);
    bindText(stmt, 6, worker);
    bindText(stmt, 7, model);
    bindText(stmt, 8, status);
    sqlite3_bind_int(stmt, 9, std::max(0, acceptedNodes));
    sqlite3_bind_int(stmt, 10, std::max(0, acceptedRelationships));
    bindText(stmt, 11, rawOutput);
    bindText(stmt, 12, metadata);
    int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        if (manageTransaction) {
            execSql(handle, "ROLLBACK");
        }
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    const long long attemptId = sqlite3_last_insert_rowid(handle->db);

    sqlite3_stmt* updateStmt = nullptr;
    rc = prepare(
        handle,
        "UPDATE work_queue SET "
        "status = ?, "
        "metadata_json = json_set("
        "  CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, "
        "  '$.last_attempt_id', ?, "
        "  '$.last_attempt_status', ?, "
        "  '$.last_attempt_worker', ?, "
        "  '$.last_attempt_model', ?, "
        "  '$.last_accepted_nodes', ?, "
        "  '$.last_accepted_relationships', ?), "
        "updated_at = CURRENT_TIMESTAMP "
        "WHERE profile_id = ? AND queue_name = ? AND item_id = ?",
        &updateStmt);
    if (rc != CPRAG_OK) {
        if (manageTransaction) {
            execSql(handle, "ROLLBACK");
        }
        return rc;
    }
    bindText(updateStmt, 1, status);
    sqlite3_bind_int64(updateStmt, 2, attemptId);
    bindText(updateStmt, 3, status);
    bindText(updateStmt, 4, worker);
    bindText(updateStmt, 5, model);
    sqlite3_bind_int(updateStmt, 6, std::max(0, acceptedNodes));
    sqlite3_bind_int(updateStmt, 7, std::max(0, acceptedRelationships));
    bindText(updateStmt, 8, profileId);
    bindText(updateStmt, 9, queueId);
    bindText(updateStmt, 10, itemId);
    stepRc = sqlite3_step(updateStmt);
    const int changed = sqlite3_changes(handle->db);
    sqlite3_finalize(updateStmt);
    if (stepRc != SQLITE_DONE) {
        if (manageTransaction) {
            execSql(handle, "ROLLBACK");
        }
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    if (manageTransaction) {
        rc = execSql(handle, "COMMIT");
        if (rc != CPRAG_OK) {
            execSql(handle, "ROLLBACK");
            return rc;
        }
    }

    if (resultJson != nullptr) {
        std::ostringstream out;
        out << "{\"success\":true"
            << ",\"attempt_id\":" << attemptId
            << ",\"profile_id\":" << jsonString(profileId)
            << ",\"queue_id\":" << jsonString(queueId)
            << ",\"item_type\":" << jsonString(itemType)
            << ",\"item_id\":" << jsonString(itemId)
            << ",\"subject_id\":" << subjectId
            << ",\"status\":" << jsonString(status)
            << ",\"accepted_nodes\":" << std::max(0, acceptedNodes)
            << ",\"accepted_relationships\":" << std::max(0, acceptedRelationships)
            << ",\"queue_updated\":" << (changed > 0 ? "true" : "false")
            << "}";
        *resultJson = out.str();
    }
    return CPRAG_OK;
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

    const std::string metadata = metadataOrDefault(metadata_json);
    const int metadataRc = validateMetadataJson(handle, metadata);
    if (metadataRc != CPRAG_OK) {
        return metadataRc;
    }
    const std::string effectiveType = valueOrEmpty(relationship_type).empty() ? "relationship" : valueOrEmpty(relationship_type);

    sqlite3_stmt* findStmt = nullptr;
    int prepRc = prepare(handle,
        "SELECT id FROM edges WHERE source_id = ? AND target_id = ? AND relationship_type = ? AND label = ? LIMIT 1",
        &findStmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }
    bindText(findStmt, 1, source_id);
    bindText(findStmt, 2, target_id);
    bindText(findStmt, 3, effectiveType);
    bindText(findStmt, 4, label);

    const int findRc = sqlite3_step(findStmt);
    const bool existingEdge = findRc == SQLITE_ROW;
    const sqlite3_int64 edgeId = existingEdge ? sqlite3_column_int64(findStmt, 0) : 0;
    if (findRc != SQLITE_ROW && findRc != SQLITE_DONE) {
        sqlite3_finalize(findStmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    sqlite3_finalize(findStmt);

    if (existingEdge) {
        sqlite3_stmt* updateStmt = nullptr;
        prepRc = prepare(
            handle,
            "UPDATE edges SET "
            "weight = max(weight, ?), "
            "metadata_json = CASE "
            "WHEN json_type(metadata_json, '$.support_evidence') = 'array' THEN "
            "  json_insert("
            "    json_set(metadata_json, "
            "      '$.support_count', COALESCE(json_extract(metadata_json, '$.support_count'), json_array_length(json_extract(metadata_json, '$.support_evidence')), 1) + 1, "
            "      '$.last_support', json(?)), "
            "    '$.support_evidence[#]', json(?)) "
            "ELSE "
            "  json_set(metadata_json, "
            "    '$.support_count', COALESCE(json_extract(metadata_json, '$.support_count'), 1) + 1, "
            "    '$.support_evidence', json_array(json(metadata_json), json(?)), "
            "    '$.last_support', json(?)) "
            "END "
            "WHERE id = ?",
            &updateStmt);
        if (prepRc != CPRAG_OK) {
            return prepRc;
        }
        sqlite3_bind_double(updateStmt, 1, weight);
        bindText(updateStmt, 2, metadata);
        bindText(updateStmt, 3, metadata);
        bindText(updateStmt, 4, metadata);
        bindText(updateStmt, 5, metadata);
        sqlite3_bind_int64(updateStmt, 6, edgeId);

        const int updateRc = sqlite3_step(updateStmt);
        sqlite3_finalize(updateStmt);
        if (updateRc != SQLITE_DONE) {
            return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
        }
        return CPRAG_OK;
    }

    sqlite3_stmt* stmt = nullptr;
    prepRc = prepare(handle,
        "INSERT INTO edges (source_id, target_id, relationship_type, label, weight, metadata_json) "
        "VALUES (?, ?, ?, ?, ?, json_set(json(?), '$.support_count', 1, '$.support_evidence', json_array(json(?)), '$.last_support', json(?)))",
        &stmt);
    if (prepRc != CPRAG_OK) {
        return prepRc;
    }

    bindText(stmt, 1, source_id);
    bindText(stmt, 2, target_id);
    bindText(stmt, 3, effectiveType);
    bindText(stmt, 4, label);
    sqlite3_bind_double(stmt, 5, weight);
    bindText(stmt, 6, metadata);
    bindText(stmt, 7, metadata);
    bindText(stmt, 8, metadata);

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

int cprag_chunk_ids(cprag_handle* handle, const char* source_uri, char* out_csv, size_t out_csv_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    const std::string sourceUri = valueOrEmpty(source_uri);
    const bool hasSourceFilter = !sourceUri.empty();
    sqlite3_stmt* stmt = nullptr;
    const char* sql = hasSourceFilter
        ? "SELECT c.id "
          "FROM chunks c "
          "JOIN documents d ON d.id = c.document_id "
          "WHERE d.source_uri = ? "
          "ORDER BY d.source_uri, c.chunk_index"
        : "SELECT c.id "
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

    std::ostringstream out;
    bool first = true;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        out << sqlite3_column_int64(stmt, 0);
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    return copyText(handle, out.str(), out_csv, out_csv_size);
}

int cprag_chunk_text_by_id(cprag_handle* handle, long long chunk_id, char* out_text, size_t out_text_size)
{
    if (handle == nullptr || chunk_id <= 0) {
        return CPRAG_INVALID_ARGUMENT;
    }

    sqlite3_stmt* stmt = nullptr;
    int rc = prepare(handle, "SELECT text FROM chunks WHERE id = ?", &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    sqlite3_bind_int64(stmt, 1, chunk_id);
    const int stepRc = sqlite3_step(stmt);
    if (stepRc == SQLITE_ROW) {
        const std::string text = columnText(stmt, 0);
        sqlite3_finalize(stmt);
        return copyText(handle, text, out_text, out_text_size);
    }
    sqlite3_finalize(stmt);
    if (stepRc == SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_NOT_FOUND, "chunk not found");
    }
    return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
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

int cprag_list_concepts(
    cprag_handle* handle,
    const char* node_type_filter_csv,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        return copyJson(
            handle,
            buildConceptListJson(loadEntities(handle), valueOrEmpty(node_type_filter_csv)),
            out_json,
            out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
}

int cprag_match_concepts(
    cprag_handle* handle,
    const char* text,
    const char* node_type_filter_csv,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || text == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        return copyJson(
            handle,
            buildConceptMatchesJson(loadEntities(handle), valueOrEmpty(text), valueOrEmpty(node_type_filter_csv)),
            out_json,
            out_json_size);
    } catch (const std::exception& ex) {
        return setErrorCode(handle, CPRAG_INTERNAL_ERROR, ex.what());
    }
}

int cprag_clear_candidate_census(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }

    const std::string profileId = valueOrEmpty(profile_id);
    const std::string sourceUri = valueOrEmpty(source_uri);
    sqlite3_stmt* stmt = nullptr;
    const char* sql = sourceUri.empty()
        ? "DELETE FROM candidate_mentions WHERE profile_id = ?"
        : "DELETE FROM candidate_mentions WHERE profile_id = ? AND source_uri = ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    if (!sourceUri.empty()) {
        bindText(stmt, 2, sourceUri);
    }
    const int stepRc = sqlite3_step(stmt);
    if (stepRc != SQLITE_DONE) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    const int deleted = sqlite3_changes(handle->db);
    sqlite3_finalize(stmt);

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"source_uri\":" << jsonString(sourceUri)
        << ",\"deleted\":" << deleted
        << "}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_add_candidate_mention(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    long long chunk_id,
    const char* stage,
    const char* extractor,
    const char* candidate,
    const char* normalized_candidate,
    int priority,
    int proper_count,
    int known_count,
    int cue_count,
    const char* metadata_json)
{
    if (handle == nullptr || profile_id == nullptr || candidate == nullptr || normalized_candidate == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (profile_id[0] == '\0' || candidate[0] == '\0' || normalized_candidate[0] == '\0') {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "profile_id, candidate, and normalized_candidate are required");
    }
    if (chunk_id <= 0) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "chunk_id must be positive");
    }

    const std::string metadata = metadataOrDefault(metadata_json);
    const int metadataRc = validateMetadataJson(handle, metadata);
    if (metadataRc != CPRAG_OK) {
        return metadataRc;
    }

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "INSERT INTO candidate_mentions "
        "(profile_id, source_uri, chunk_id, stage, extractor, candidate, normalized_candidate, "
        "priority, proper_count, known_count, cue_count, metadata_json) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
        "ON CONFLICT(profile_id, source_uri, chunk_id, stage, extractor, normalized_candidate) "
        "DO UPDATE SET candidate=excluded.candidate, priority=excluded.priority, "
        "proper_count=excluded.proper_count, known_count=excluded.known_count, "
        "cue_count=excluded.cue_count, metadata_json=excluded.metadata_json, "
        "updated_at=CURRENT_TIMESTAMP";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, valueOrEmpty(profile_id));
    bindText(stmt, 2, valueOrEmpty(source_uri));
    sqlite3_bind_int64(stmt, 3, chunk_id);
    bindText(stmt, 4, valueOrEmpty(stage).empty() ? "stage1" : valueOrEmpty(stage));
    bindText(stmt, 5, valueOrEmpty(extractor).empty() ? "deterministic" : valueOrEmpty(extractor));
    bindText(stmt, 6, valueOrEmpty(candidate));
    bindText(stmt, 7, valueOrEmpty(normalized_candidate));
    sqlite3_bind_int(stmt, 8, priority);
    sqlite3_bind_int(stmt, 9, proper_count);
    sqlite3_bind_int(stmt, 10, known_count);
    sqlite3_bind_int(stmt, 11, cue_count);
    bindText(stmt, 12, metadata);
    const int stepRc = sqlite3_step(stmt);
    if (stepRc != SQLITE_DONE) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    sqlite3_finalize(stmt);
    return CPRAG_OK;
}

static int candidateCensus(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    int min_count,
    int limit,
    bool pendingOnly,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }

    const std::string profileId = valueOrEmpty(profile_id);
    const std::string sourceUri = valueOrEmpty(source_uri);
    const int effectiveMinCount = min_count <= 0 ? 1 : min_count;
    const int effectiveLimit = limit <= 0 ? 100 : limit;

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "SELECT cm.normalized_candidate, MIN(cm.candidate) AS display_candidate, COUNT(*) AS mention_count, "
        "MIN(cm.chunk_id) AS first_chunk, MAX(cm.chunk_id) AS last_chunk, "
        "MAX(cm.priority) AS max_priority, MAX(cm.proper_count) AS max_proper_count, "
        "MAX(cm.known_count) AS max_known_count, MAX(cm.cue_count) AS max_cue_count, "
        "COALESCE(ca.status, '') AS status, COALESCE(ca.candidate_type, '') AS candidate_type, "
        "COALESCE(ca.canonical_label, '') AS canonical_label, COALESCE(ca.aliases, '') AS aliases, "
        "COALESCE(ca.disambiguation, '') AS disambiguation, COALESCE(ca.confidence, 0.0) AS confidence "
        "FROM candidate_mentions cm "
        "LEFT JOIN candidate_adjudications ca "
        "  ON ca.profile_id = cm.profile_id AND ca.normalized_candidate = cm.normalized_candidate "
        "WHERE cm.profile_id = ? AND (? = '' OR cm.source_uri = ?) "
        "AND (? = 0 OR ca.normalized_candidate IS NULL) "
        "GROUP BY cm.normalized_candidate "
        "HAVING COUNT(*) >= ? "
        "ORDER BY mention_count DESC, max_priority DESC, cm.normalized_candidate ASC "
        "LIMIT ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, sourceUri);
    bindText(stmt, 3, sourceUri);
    sqlite3_bind_int(stmt, 4, pendingOnly ? 1 : 0);
    sqlite3_bind_int(stmt, 5, effectiveMinCount);
    sqlite3_bind_int(stmt, 6, effectiveLimit);

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"source_uri\":" << jsonString(sourceUri)
        << ",\"pending_only\":" << (pendingOnly ? "true" : "false")
        << ",\"min_count\":" << effectiveMinCount
        << ",\"limit\":" << effectiveLimit
        << ",\"candidates\":[";
    bool first = true;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        out << "{\"normalized\":" << jsonString(columnText(stmt, 0))
            << ",\"display\":" << jsonString(columnText(stmt, 1))
            << ",\"count\":" << sqlite3_column_int(stmt, 2)
            << ",\"first_chunk\":" << sqlite3_column_int64(stmt, 3)
            << ",\"last_chunk\":" << sqlite3_column_int64(stmt, 4)
            << ",\"max_priority\":" << sqlite3_column_int(stmt, 5)
            << ",\"max_proper_count\":" << sqlite3_column_int(stmt, 6)
            << ",\"max_known_count\":" << sqlite3_column_int(stmt, 7)
            << ",\"max_cue_count\":" << sqlite3_column_int(stmt, 8);
        const std::string status = columnText(stmt, 9);
        if (!status.empty()) {
            out << ",\"adjudication\":{"
                << "\"status\":" << jsonString(status)
                << ",\"candidate_type\":" << jsonString(columnText(stmt, 10))
                << ",\"canonical_label\":" << jsonString(columnText(stmt, 11))
                << ",\"aliases\":" << jsonString(columnText(stmt, 12))
                << ",\"disambiguation\":" << jsonString(columnText(stmt, 13))
                << ",\"confidence\":" << sqlite3_column_double(stmt, 14)
                << "}";
        }
        out << "}";
    }
    if (stepRc != SQLITE_DONE) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    sqlite3_finalize(stmt);
    out << "]}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_candidate_census(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    int min_count,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    return candidateCensus(handle, profile_id, source_uri, min_count, limit, false, out_json, out_json_size);
}

int cprag_pending_candidate_census(
    cprag_handle* handle,
    const char* profile_id,
    const char* source_uri,
    int min_count,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    return candidateCensus(handle, profile_id, source_uri, min_count, limit, true, out_json, out_json_size);
}

int cprag_adjudicate_candidate(
    cprag_handle* handle,
    const char* profile_id,
    const char* normalized_candidate,
    const char* status,
    const char* candidate_type,
    const char* canonical_label,
    const char* aliases,
    const char* disambiguation,
    double confidence,
    const char* adjudicator,
    const char* metadata_json)
{
    if (handle == nullptr || profile_id == nullptr || normalized_candidate == nullptr || status == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (profile_id[0] == '\0' || normalized_candidate[0] == '\0' || status[0] == '\0') {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "profile_id, normalized_candidate, and status are required");
    }
    const int confidenceRc = validateConfidence(handle, confidence);
    if (confidenceRc != CPRAG_OK) {
        return confidenceRc;
    }
    const std::string metadata = metadataOrDefault(metadata_json);
    const int metadataRc = validateMetadataJson(handle, metadata);
    if (metadataRc != CPRAG_OK) {
        return metadataRc;
    }

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "INSERT INTO candidate_adjudications "
        "(profile_id, normalized_candidate, status, candidate_type, canonical_label, aliases, "
        "disambiguation, confidence, adjudicator, metadata_json) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
        "ON CONFLICT(profile_id, normalized_candidate) DO UPDATE SET "
        "status=excluded.status, candidate_type=excluded.candidate_type, "
        "canonical_label=excluded.canonical_label, aliases=excluded.aliases, "
        "disambiguation=excluded.disambiguation, confidence=excluded.confidence, "
        "adjudicator=excluded.adjudicator, metadata_json=excluded.metadata_json, "
        "updated_at=CURRENT_TIMESTAMP";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, valueOrEmpty(profile_id));
    bindText(stmt, 2, valueOrEmpty(normalized_candidate));
    bindText(stmt, 3, valueOrEmpty(status));
    bindText(stmt, 4, valueOrEmpty(candidate_type));
    bindText(stmt, 5, valueOrEmpty(canonical_label));
    bindText(stmt, 6, valueOrEmpty(aliases));
    bindText(stmt, 7, valueOrEmpty(disambiguation));
    sqlite3_bind_double(stmt, 8, confidence);
    bindText(stmt, 9, valueOrEmpty(adjudicator));
    bindText(stmt, 10, metadata);
    const int stepRc = sqlite3_step(stmt);
    if (stepRc != SQLITE_DONE) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    sqlite3_finalize(stmt);
    return CPRAG_OK;
}

int cprag_list_candidate_adjudications(
    cprag_handle* handle,
    const char* profile_id,
    const char* status_filter,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    const std::string profileId = valueOrEmpty(profile_id);
    const std::string statusFilter = valueOrEmpty(status_filter);
    const int effectiveLimit = limit <= 0 ? 100 : limit;

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "SELECT profile_id, normalized_candidate, status, candidate_type, canonical_label, aliases, "
        "disambiguation, confidence, adjudicator, metadata_json, updated_at "
        "FROM candidate_adjudications "
        "WHERE profile_id = ? AND (? = '' OR status = ?) "
        "ORDER BY updated_at DESC, normalized_candidate ASC "
        "LIMIT ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, statusFilter);
    bindText(stmt, 3, statusFilter);
    sqlite3_bind_int(stmt, 4, effectiveLimit);

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"status_filter\":" << jsonString(statusFilter)
        << ",\"limit\":" << effectiveLimit
        << ",\"adjudications\":[";
    bool first = true;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        out << "{\"normalized\":" << jsonString(columnText(stmt, 1))
            << ",\"status\":" << jsonString(columnText(stmt, 2))
            << ",\"candidate_type\":" << jsonString(columnText(stmt, 3))
            << ",\"canonical_label\":" << jsonString(columnText(stmt, 4))
            << ",\"aliases\":" << jsonString(columnText(stmt, 5))
            << ",\"disambiguation\":" << jsonString(columnText(stmt, 6))
            << ",\"confidence\":" << sqlite3_column_double(stmt, 7)
            << ",\"adjudicator\":" << jsonString(columnText(stmt, 8))
            << ",\"metadata\":" << (columnText(stmt, 9).empty() ? "{}" : columnText(stmt, 9))
            << ",\"updated_at\":" << jsonString(columnText(stmt, 10))
            << "}";
    }
    if (stepRc != SQLITE_DONE) {
        sqlite3_finalize(stmt);
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    sqlite3_finalize(stmt);
    out << "]}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_list_candidate_mention_evidence(
    cprag_handle* handle,
    const char* profile_id,
    const char* status_filter,
    const char* type_filter_csv,
    int min_count,
    long long after_id,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    const std::string profileId = valueOrEmpty(profile_id);
    const std::string statusFilter = valueOrEmpty(status_filter);
    const std::string typeFilterCsv = valueOrEmpty(type_filter_csv);
    const int effectiveMinCount = min_count <= 0 ? 1 : min_count;
    const int effectiveLimit = limit <= 0 ? 100 : limit;
    const long long effectiveAfterId = after_id < 0 ? 0 : after_id;

    std::vector<CandidateMentionEvidence> rows;
    int rc = loadCandidateMentionEvidenceRows(
        handle,
        profileId,
        statusFilter,
        typeFilterCsv,
        effectiveMinCount,
        effectiveAfterId,
        effectiveLimit,
        rows);
    if (rc != CPRAG_OK) {
        return rc;
    }

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"status_filter\":" << jsonString(statusFilter)
        << ",\"type_filter_csv\":" << jsonString(typeFilterCsv)
        << ",\"min_count\":" << effectiveMinCount
        << ",\"after_id\":" << effectiveAfterId
        << ",\"limit\":" << effectiveLimit
        << ",\"mentions\":[";
    bool first = true;
    for (const CandidateMentionEvidence& row : rows) {
        if (!first) {
            out << ',';
        }
        first = false;
        out << "{\"id\":" << row.id
            << ",\"source_uri\":" << jsonString(row.sourceUri)
            << ",\"chunk_id\":" << row.chunkId
            << ",\"candidate\":" << jsonString(row.candidate)
            << ",\"normalized\":" << jsonString(row.normalized)
            << ",\"priority\":" << row.priority
            << ",\"proper_count\":" << row.properCount
            << ",\"known_count\":" << row.knownCount
            << ",\"cue_count\":" << row.cueCount
            << ",\"mention_count\":" << row.mentionCount
            << ",\"status\":" << jsonString(row.status)
            << ",\"candidate_type\":" << jsonString(row.candidateType)
            << ",\"canonical_label\":" << jsonString(row.canonicalLabel)
            << ",\"aliases\":" << jsonString(row.aliases)
            << ",\"disambiguation\":" << jsonString(row.disambiguation)
            << ",\"confidence\":" << row.confidence
            << ",\"adjudicator\":" << jsonString(row.adjudicator)
            << "}";
    }
    out << "]}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_seed_candidate_mention_graph(
    cprag_handle* handle,
    const char* profile_id,
    const char* graph_namespace,
    const char* status_filter,
    const char* type_filter_csv,
    int min_count,
    long long after_id,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }
    const std::string profileId = valueOrEmpty(profile_id);
    const std::string graphNamespace = valueOrEmpty(graph_namespace).empty()
        ? "candidate"
        : valueOrEmpty(graph_namespace);
    const std::string statusFilter = valueOrEmpty(status_filter);
    const std::string typeFilterCsv = valueOrEmpty(type_filter_csv);
    const int effectiveMinCount = min_count <= 0 ? 1 : min_count;
    const int effectiveLimit = limit <= 0 ? 100 : limit;
    const long long effectiveAfterId = after_id < 0 ? 0 : after_id;

    std::vector<CandidateMentionEvidence> rows;
    int rc = loadCandidateMentionEvidenceRows(
        handle,
        profileId,
        statusFilter,
        typeFilterCsv,
        effectiveMinCount,
        effectiveAfterId,
        effectiveLimit,
        rows);
    if (rc != CPRAG_OK) {
        return rc;
    }

    rc = execSql(handle, "BEGIN IMMEDIATE");
    if (rc != CPRAG_OK) {
        return rc;
    }

    int processed = 0;
    int skippedReplay = 0;
    int conceptUpserts = 0;
    int evidenceUpserts = 0;
    int edgeWrites = 0;
    long long lastId = effectiveAfterId;

    for (const CandidateMentionEvidence& row : rows) {
        lastId = row.id;
        const std::string conceptId = candidateConceptId(graphNamespace, row);
        const std::string evidenceId = evidenceChunkId(row.chunkId);
        std::string label = trimCopy(row.canonicalLabel);
        if (label.empty()) {
            label = trimCopy(row.candidate);
        }
        if (label.empty()) {
            label = row.normalized;
        }
        const std::string aliases = candidateAliasCsv(row);

        rc = cprag_add_entity_typed(
            handle,
            evidenceId.c_str(),
            "evidence-chunk",
            ("Chunk " + std::to_string(row.chunkId)).c_str(),
            "Source chunk used as candidate evidence.",
            candidateEvidenceChunkMetadata(profileId, row).c_str());
        if (rc != CPRAG_OK) {
            execSql(handle, "ROLLBACK");
            return rc;
        }
        ++evidenceUpserts;

        rc = cprag_add_entity_typed(
            handle,
            conceptId.c_str(),
            row.candidateType.empty() ? "unknown" : row.candidateType.c_str(),
            label.c_str(),
            "Seeded from adjudicated Stage 1 candidate mentions.",
            candidateConceptMetadata(profileId, row, aliases).c_str());
        if (rc != CPRAG_OK) {
            execSql(handle, "ROLLBACK");
            return rc;
        }
        ++conceptUpserts;

        bool replay = false;
        rc = edgeHasCandidateMentionSupport(handle, conceptId, evidenceId, row.id, &replay);
        if (rc != CPRAG_OK) {
            execSql(handle, "ROLLBACK");
            return rc;
        }
        if (replay) {
            ++skippedReplay;
            continue;
        }

        double weight = row.confidence;
        if (!std::isfinite(weight) || weight <= 0.0) {
            weight = 0.6;
        } else if (weight > 1.0) {
            weight = 1.0;
        }
        rc = cprag_add_edge_typed(
            handle,
            conceptId.c_str(),
            evidenceId.c_str(),
            "mentioned-in",
            "Adjudicated candidate mention in source chunk.",
            weight,
            candidateMentionMetadata(profileId, row).c_str());
        if (rc != CPRAG_OK) {
            execSql(handle, "ROLLBACK");
            return rc;
        }
        ++edgeWrites;
        ++processed;
    }

    rc = execSql(handle, "COMMIT");
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"graph_namespace\":" << jsonString(graphNamespace)
        << ",\"status_filter\":" << jsonString(statusFilter)
        << ",\"type_filter_csv\":" << jsonString(typeFilterCsv)
        << ",\"min_count\":" << effectiveMinCount
        << ",\"after_id\":" << effectiveAfterId
        << ",\"limit\":" << effectiveLimit
        << ",\"rows\":" << rows.size()
        << ",\"processed\":" << processed
        << ",\"skipped_replay\":" << skippedReplay
        << ",\"concept_upserts\":" << conceptUpserts
        << ",\"evidence_upserts\":" << evidenceUpserts
        << ",\"edge_writes\":" << edgeWrites
        << ",\"last_id\":" << lastId
        << "}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_build_extraction_queue(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* graph_namespace,
    const char* node_type_filter_csv,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }

    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const std::string graphNamespace = valueOrEmpty(graph_namespace);
    const std::string nodeTypeFilterCsv = valueOrEmpty(node_type_filter_csv);
    const int effectiveLimit = limit <= 0 ? 100 : limit;

    std::unordered_map<std::string, std::unordered_set<std::string>> slugTypes;
    int rc = loadConceptSlugTypes(handle, graphNamespace, slugTypes);
    if (rc != CPRAG_OK) {
        return rc;
    }

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "WITH cue_stats AS ("
        "  SELECT chunk_id, MAX(cue_count) AS max_cue_count, MAX(priority) AS max_priority "
        "  FROM candidate_mentions "
        "  WHERE profile_id = ? "
        "  GROUP BY chunk_id"
        ") "
        "SELECT c.id, d.source_uri, d.title, c.chunk_index, c.length, "
        "c.text, src.id, src.node_type, src.label, "
        "COALESCE(json_extract(src.metadata_json, '$.mention_count'), 0) AS mention_count, "
        "COALESCE(json_extract(e.metadata_json, '$.support_count'), 1) AS support_count, "
        "COALESCE(cs.max_cue_count, 0) AS relation_cue_count, "
        "COALESCE(cs.max_priority, 0) AS max_priority "
        "FROM edges e "
        "JOIN entities src ON src.id = e.source_id "
        "JOIN chunks c ON c.id = CAST(json_extract(e.metadata_json, '$.chunk_id') AS INTEGER) "
        "JOIN documents d ON d.id = c.document_id "
        "LEFT JOIN cue_stats cs ON cs.chunk_id = c.id "
        "WHERE e.relationship_type = 'mentioned-in' "
        "AND json_extract(e.metadata_json, '$.profile_id') = ? "
        "AND (? = '' OR src.id LIKE ?) "
        "AND (? = '' OR instr(',' || ? || ',', ',' || src.node_type || ',') > 0) "
        "AND NOT EXISTS ("
        "  SELECT 1 FROM work_attempts wa "
        "  WHERE wa.profile_id = ? "
        "  AND wa.item_type = 'chunk-extraction' "
        "  AND wa.subject_id = c.id "
        "  AND wa.status IN ('processed', 'skipped')"
        ")";
    rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, profileId);
    bindText(stmt, 3, graphNamespace);
    bindText(stmt, 4, graphNamespace.empty() ? "" : graphNamespace + ":%");
    bindText(stmt, 5, nodeTypeFilterCsv);
    bindText(stmt, 6, nodeTypeFilterCsv);
    bindText(stmt, 7, profileId);

    std::unordered_map<long long, ExtractionQueueItem> byChunk;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        const long long chunkId = sqlite3_column_int64(stmt, 0);
        ExtractionQueueItem& item = byChunk[chunkId];
        if (item.chunkId == 0) {
            item.chunkId = chunkId;
            item.sourceUri = columnText(stmt, 1);
            item.title = columnText(stmt, 2);
            item.chunkIndex = sqlite3_column_int(stmt, 3);
            item.length = sqlite3_column_int(stmt, 4);
            const std::string chunkText = columnText(stmt, 5);
            item.evidenceClass = evidenceClassForText(item.title, chunkText);
            item.evidencePenalty = evidenceClassPenalty(item.evidenceClass);
            item.qualityPenalty = chunkShapePenalty(chunkText, &item.qualityNotes);
        }

        const std::string conceptId = columnText(stmt, 6);
        const std::string nodeType = columnText(stmt, 7);
        const std::string label = columnText(stmt, 8);
        const int mentionCount = sqlite3_column_int(stmt, 9);
        const int supportCount = std::max(1, sqlite3_column_int(stmt, 10));
        item.supportCount += supportCount;
        item.relationCueCount = std::max(item.relationCueCount, sqlite3_column_int(stmt, 11));
        item.maxPriority = std::max(item.maxPriority, sqlite3_column_int(stmt, 12));

        const auto inserted = item.conceptIds.insert(conceptId);
        if (inserted.second) {
            ++item.conceptCount;
            ++item.typeCounts[nodeType];
            if (mentionCount > 0 && mentionCount <= 10) {
                ++item.rareConceptCount;
            }
            const std::string suffix = conceptSuffixFromId(conceptId);
            const auto slugIt = slugTypes.find(suffix);
            if (slugIt != slugTypes.end() && slugIt->second.size() > 1) {
                ++item.ambiguityCount;
            }
            if (item.sampleConcepts.size() < 8) {
                item.sampleConcepts.push_back({label, nodeType});
            }
        }
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    std::vector<ExtractionQueueItem> ranked;
    ranked.reserve(byChunk.size());
    for (auto& entry : byChunk) {
        ExtractionQueueItem& item = entry.second;
        item.typeDiversity = static_cast<int>(item.typeCounts.size());
        double typeBonus = 0.0;
        for (const auto& typeEntry : item.typeCounts) {
            typeBonus += static_cast<double>(typeEntry.second) * typeWeight(typeEntry.first);
        }
        const double bridgeBonus = (item.typeDiversity >= 3 ? 5.0 : 0.0) + (item.conceptCount >= 8 ? 4.0 : 0.0);
        item.score =
            static_cast<double>(item.conceptCount) * 2.0
            + static_cast<double>(std::min(item.supportCount, 25)) * 0.7
            + static_cast<double>(item.typeDiversity) * 4.0
            + static_cast<double>(item.relationCueCount) * 6.0
            + static_cast<double>(item.rareConceptCount) * 3.0
            + static_cast<double>(item.ambiguityCount) * 5.0
            + static_cast<double>(item.maxPriority) * 0.05
            + typeBonus
            + bridgeBonus
            - static_cast<double>(item.evidencePenalty)
            - static_cast<double>(item.qualityPenalty);
        item.reason = extractionQueueReason(item);
        item.metadataJson = extractionQueueMetadata(item, profileId, queueId, graphNamespace, nodeTypeFilterCsv);
        ranked.push_back(std::move(item));
    }

    std::sort(ranked.begin(), ranked.end(), [](const ExtractionQueueItem& lhs, const ExtractionQueueItem& rhs) {
        if (lhs.score != rhs.score) {
            return lhs.score > rhs.score;
        }
        return lhs.chunkId < rhs.chunkId;
    });
    const int queued = std::min<int>(effectiveLimit, static_cast<int>(ranked.size()));

    rc = execSql(handle, "BEGIN IMMEDIATE");
    if (rc != CPRAG_OK) {
        return rc;
    }
    sqlite3_stmt* deleteStmt = nullptr;
    rc = prepare(handle, "DELETE FROM work_queue WHERE profile_id = ? AND queue_name = ? AND item_type = 'chunk-extraction'", &deleteStmt);
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }
    bindText(deleteStmt, 1, profileId);
    bindText(deleteStmt, 2, queueId);
    stepRc = sqlite3_step(deleteStmt);
    sqlite3_finalize(deleteStmt);
    if (stepRc != SQLITE_DONE) {
        execSql(handle, "ROLLBACK");
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    sqlite3_stmt* insertStmt = nullptr;
    rc = prepare(
        handle,
        "INSERT INTO work_queue "
        "(profile_id, queue_name, item_type, item_id, subject_id, source_uri, title, item_index, score, status, reason, metadata_json) "
        "VALUES (?, ?, 'chunk-extraction', ?, ?, ?, ?, ?, ?, 'pending', ?, ?) "
        "ON CONFLICT(profile_id, queue_name, item_id) DO UPDATE SET "
        "item_type=excluded.item_type, subject_id=excluded.subject_id, "
        "source_uri=excluded.source_uri, title=excluded.title, item_index=excluded.item_index, "
        "score=excluded.score, status=excluded.status, reason=excluded.reason, "
        "metadata_json=excluded.metadata_json, updated_at=CURRENT_TIMESTAMP",
        &insertStmt);
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }
    for (int i = 0; i < queued; ++i) {
        const ExtractionQueueItem& item = ranked[static_cast<size_t>(i)];
        sqlite3_reset(insertStmt);
        sqlite3_clear_bindings(insertStmt);
        bindText(insertStmt, 1, profileId);
        bindText(insertStmt, 2, queueId);
        bindText(insertStmt, 3, "chunk:" + std::to_string(item.chunkId));
        sqlite3_bind_int64(insertStmt, 4, item.chunkId);
        bindText(insertStmt, 5, item.sourceUri);
        bindText(insertStmt, 6, item.title);
        sqlite3_bind_int(insertStmt, 7, item.chunkIndex);
        sqlite3_bind_double(insertStmt, 8, item.score);
        bindText(insertStmt, 9, item.reason);
        bindText(insertStmt, 10, item.metadataJson);
        stepRc = sqlite3_step(insertStmt);
        if (stepRc != SQLITE_DONE) {
            sqlite3_finalize(insertStmt);
            execSql(handle, "ROLLBACK");
            return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
        }
    }
    sqlite3_finalize(insertStmt);
    rc = execSql(handle, "COMMIT");
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"graph_namespace\":" << jsonString(graphNamespace)
        << ",\"node_type_filter_csv\":" << jsonString(nodeTypeFilterCsv)
        << ",\"ranked\":" << ranked.size()
        << ",\"queued\":" << queued;
    if (queued > 0) {
        const ExtractionQueueItem& item = ranked.front();
        out << ",\"top_chunk_id\":" << item.chunkId
            << ",\"top_score\":" << item.score
            << ",\"top_reason\":" << jsonString(item.reason);
    }
    out << "}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_list_extraction_queue(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* status_filter,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const std::string statusFilter = valueOrEmpty(status_filter);
    const int effectiveLimit = limit <= 0 ? 100 : limit;

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "SELECT subject_id, source_uri, title, item_index, score, status, reason, updated_at "
        "FROM work_queue "
        "WHERE profile_id = ? AND queue_name = ? AND item_type = 'chunk-extraction' "
        "AND (? = '' OR status = ?) "
        "ORDER BY score DESC, subject_id ASC "
        "LIMIT ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, statusFilter);
    bindText(stmt, 4, statusFilter);
    sqlite3_bind_int(stmt, 5, effectiveLimit);

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"status_filter\":" << jsonString(statusFilter)
        << ",\"limit\":" << effectiveLimit
        << ",\"items\":[";
    bool first = true;
    int rank = 0;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        ++rank;
        out << "{\"rank\":" << rank
            << ",\"chunk_id\":" << sqlite3_column_int64(stmt, 0)
            << ",\"source_uri\":" << jsonString(columnText(stmt, 1))
            << ",\"title\":" << jsonString(columnText(stmt, 2))
            << ",\"chunk_index\":" << sqlite3_column_int(stmt, 3)
            << ",\"score\":" << sqlite3_column_double(stmt, 4)
            << ",\"status\":" << jsonString(columnText(stmt, 5))
            << ",\"reason\":" << jsonString(columnText(stmt, 6))
            << ",\"updated_at\":" << jsonString(columnText(stmt, 7))
            << "}";
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    out << "]}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_upsert_work_item(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* item_type,
    const char* item_id,
    long long subject_id,
    const char* source_uri,
    const char* title,
    int item_index,
    double score,
    const char* status,
    const char* reason,
    const char* metadata_json,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0'
        || item_type == nullptr || item_type[0] == '\0'
        || item_id == nullptr || item_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }

    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const std::string itemType = valueOrEmpty(item_type);
    const std::string itemId = valueOrEmpty(item_id);
    const std::string sourceUri = valueOrEmpty(source_uri);
    const std::string titleValue = valueOrEmpty(title);
    const std::string statusValue = valueOrEmpty(status).empty() ? "pending" : valueOrEmpty(status);
    const std::string reasonValue = valueOrEmpty(reason);
    const std::string metadata = metadataOrDefault(metadata_json);
    int rc = validateMetadataJson(handle, metadata);
    if (rc != CPRAG_OK) {
        return rc;
    }

    sqlite3_stmt* stmt = nullptr;
    rc = prepare(
        handle,
        "INSERT INTO work_queue "
        "(profile_id, queue_name, item_type, item_id, subject_id, source_uri, title, item_index, score, status, reason, metadata_json) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
        "ON CONFLICT(profile_id, queue_name, item_id) DO UPDATE SET "
        "item_type=excluded.item_type, subject_id=excluded.subject_id, "
        "source_uri=excluded.source_uri, title=excluded.title, item_index=excluded.item_index, "
        "score=excluded.score, status=excluded.status, reason=excluded.reason, "
        "metadata_json=excluded.metadata_json, updated_at=CURRENT_TIMESTAMP",
        &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, itemType);
    bindText(stmt, 4, itemId);
    sqlite3_bind_int64(stmt, 5, std::max<long long>(0, subject_id));
    bindText(stmt, 6, sourceUri);
    bindText(stmt, 7, titleValue);
    sqlite3_bind_int(stmt, 8, item_index);
    sqlite3_bind_double(stmt, 9, score);
    bindText(stmt, 10, statusValue);
    bindText(stmt, 11, reasonValue);
    bindText(stmt, 12, metadata);
    const int stepRc = sqlite3_step(stmt);
    const int changed = sqlite3_changes(handle->db);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"item_type\":" << jsonString(itemType)
        << ",\"item_id\":" << jsonString(itemId)
        << ",\"subject_id\":" << std::max<long long>(0, subject_id)
        << ",\"status\":" << jsonString(statusValue)
        << ",\"changed\":" << changed
        << "}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_list_work_queue(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* item_type_filter,
    const char* status_filter,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const std::string itemTypeFilter = valueOrEmpty(item_type_filter);
    const std::string statusFilter = valueOrEmpty(status_filter);
    const int effectiveLimit = limit <= 0 ? 100 : limit;

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "SELECT item_type, item_id, subject_id, source_uri, title, item_index, score, status, reason, "
        "CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, created_at, updated_at "
        "FROM work_queue "
        "WHERE profile_id = ? AND queue_name = ? "
        "AND (? = '' OR item_type = ?) "
        "AND (? = '' OR status = ?) "
        "ORDER BY score DESC, updated_at ASC, item_id ASC "
        "LIMIT ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, itemTypeFilter);
    bindText(stmt, 4, itemTypeFilter);
    bindText(stmt, 5, statusFilter);
    bindText(stmt, 6, statusFilter);
    sqlite3_bind_int(stmt, 7, effectiveLimit);

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"item_type_filter\":" << jsonString(itemTypeFilter)
        << ",\"status_filter\":" << jsonString(statusFilter)
        << ",\"limit\":" << effectiveLimit
        << ",\"items\":[";
    bool first = true;
    int rank = 0;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        ++rank;
        const std::string metadata = columnText(stmt, 9);
        out << "{\"rank\":" << rank
            << ",\"item_type\":" << jsonString(columnText(stmt, 0))
            << ",\"item_id\":" << jsonString(columnText(stmt, 1))
            << ",\"subject_id\":" << sqlite3_column_int64(stmt, 2)
            << ",\"source_uri\":" << jsonString(columnText(stmt, 3))
            << ",\"title\":" << jsonString(columnText(stmt, 4))
            << ",\"item_index\":" << sqlite3_column_int(stmt, 5)
            << ",\"score\":" << sqlite3_column_double(stmt, 6)
            << ",\"status\":" << jsonString(columnText(stmt, 7))
            << ",\"reason\":" << jsonString(columnText(stmt, 8))
            << ",\"metadata\":" << (metadata.empty() ? "{}" : metadata)
            << ",\"created_at\":" << jsonString(columnText(stmt, 10))
            << ",\"updated_at\":" << jsonString(columnText(stmt, 11))
            << "}";
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    out << "]}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_record_work_attempt(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* item_type,
    const char* item_id,
    long long subject_id,
    const char* worker,
    const char* model,
    const char* status,
    int accepted_nodes,
    int accepted_relationships,
    const char* raw_output,
    const char* metadata_json,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0'
        || item_type == nullptr || item_type[0] == '\0'
        || item_id == nullptr || item_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }
    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const std::string metadata = metadataOrDefault(metadata_json);
    std::string result;
    const int rc = recordWorkAttemptInternal(
        handle,
        profileId,
        queueId,
        valueOrEmpty(item_type),
        valueOrEmpty(item_id),
        std::max<long long>(0, subject_id),
        valueOrEmpty(worker),
        valueOrEmpty(model),
        valueOrEmpty(status),
        accepted_nodes,
        accepted_relationships,
        valueOrEmpty(raw_output),
        metadata,
        true,
        &result);
    if (rc != CPRAG_OK) {
        return rc;
    }
    return copyJson(handle, result, out_json, out_json_size);
}

int cprag_list_work_attempts(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* item_type_filter,
    const char* item_id_filter,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const std::string itemTypeFilter = valueOrEmpty(item_type_filter);
    const std::string itemIdFilter = valueOrEmpty(item_id_filter);
    const int effectiveLimit = limit <= 0 ? 100 : limit;

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "SELECT id, item_type, item_id, subject_id, worker, model, status, accepted_nodes, accepted_relationships, "
        "length(raw_output), CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, created_at "
        "FROM work_attempts "
        "WHERE profile_id = ? AND queue_name = ? "
        "AND (? = '' OR item_type = ?) "
        "AND (? = '' OR item_id = ?) "
        "ORDER BY id DESC "
        "LIMIT ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, itemTypeFilter);
    bindText(stmt, 4, itemTypeFilter);
    bindText(stmt, 5, itemIdFilter);
    bindText(stmt, 6, itemIdFilter);
    sqlite3_bind_int(stmt, 7, effectiveLimit);

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"item_type_filter\":" << jsonString(itemTypeFilter)
        << ",\"item_id_filter\":" << jsonString(itemIdFilter)
        << ",\"limit\":" << effectiveLimit
        << ",\"attempts\":[";
    bool first = true;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        const std::string metadata = columnText(stmt, 10);
        out << "{\"id\":" << sqlite3_column_int64(stmt, 0)
            << ",\"item_type\":" << jsonString(columnText(stmt, 1))
            << ",\"item_id\":" << jsonString(columnText(stmt, 2))
            << ",\"subject_id\":" << sqlite3_column_int64(stmt, 3)
            << ",\"worker\":" << jsonString(columnText(stmt, 4))
            << ",\"model\":" << jsonString(columnText(stmt, 5))
            << ",\"status\":" << jsonString(columnText(stmt, 6))
            << ",\"accepted_nodes\":" << sqlite3_column_int(stmt, 7)
            << ",\"accepted_relationships\":" << sqlite3_column_int(stmt, 8)
            << ",\"raw_output_size\":" << sqlite3_column_int(stmt, 9)
            << ",\"metadata\":" << (metadata.empty() ? "{}" : metadata)
            << ",\"created_at\":" << jsonString(columnText(stmt, 11))
            << "}";
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    out << "]}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_resolve_work_queue(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    const char* item_type,
    int limit,
    int dry_run,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0'
        || item_type == nullptr || item_type[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }

    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const std::string itemType = valueOrEmpty(item_type);
    if (itemType != "endpoint-resolution"
        && itemType != "ambiguity-review"
        && itemType != "type-review"
        && itemType != "external-extraction-review") {
        return setErrorCode(
            handle,
            CPRAG_INVALID_ARGUMENT,
            "item_type must be endpoint-resolution, ambiguity-review, type-review, or external-extraction-review");
    }
    const int effectiveLimit = limit <= 0 ? 100 : limit;
    const bool dryRun = dry_run != 0;

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "SELECT item_id, subject_id, score, reason, "
        "CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.source_id'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.source'), '') AS source_id, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.target_id'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.target'), '') AS target_id, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.relationship_type'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.relationship'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.type'), '') AS relationship_type, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.label'), '') AS label, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.weight'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.confidence'), 0.55) AS weight, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.evidence'), '') AS evidence, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.evidence_class'), '') AS evidence_class, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.alias'), '') AS alias, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.candidate_ids'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.candidate_id_csv'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.candidates'), '') AS candidate_ids, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.entity_id'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.node_id'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.id'), '') AS entity_id, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.accepted_type'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.new_type'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.node_type'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.type'), '') AS accepted_type, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.node_id'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.entity_id'), '') AS node_id, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.node_type'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.accepted_type'), '') AS node_type, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.node_label'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.label'), '') AS node_label, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.description'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.node_description'), '') AS description, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.aliases'), '') AS aliases, "
        "COALESCE(json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.edge_label'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.relationship_label'), "
        "         json_extract(CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, '$.label'), '') AS edge_label "
        "FROM work_queue "
        "WHERE profile_id = ? AND queue_name = ? AND item_type = ? AND status = 'pending' "
        "ORDER BY score DESC, updated_at ASC, item_id ASC "
        "LIMIT ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, itemType);
    sqlite3_bind_int(stmt, 4, effectiveLimit);

    struct ResolveItem {
        std::string itemId;
        long long subjectId {0};
        double score {0.0};
        std::string reason;
        std::string metadata;
        std::string sourceId;
        std::string targetId;
        std::string relationshipType;
        std::string label;
        double weight {0.55};
        std::string evidence;
        std::string evidenceClass;
        std::string alias;
        std::string candidateIds;
        std::string entityId;
        std::string acceptedType;
        std::string nodeId;
        std::string nodeType;
        std::string nodeLabel;
        std::string description;
        std::string aliases;
        std::string edgeLabel;
    };
    std::vector<ResolveItem> rows;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        ResolveItem row;
        row.itemId = columnText(stmt, 0);
        row.subjectId = sqlite3_column_int64(stmt, 1);
        row.score = sqlite3_column_double(stmt, 2);
        row.reason = columnText(stmt, 3);
        row.metadata = columnText(stmt, 4);
        row.sourceId = trimCopy(columnText(stmt, 5));
        row.targetId = trimCopy(columnText(stmt, 6));
        row.relationshipType = trimCopy(columnText(stmt, 7));
        row.label = trimCopy(columnText(stmt, 8));
        row.weight = sqlite3_column_double(stmt, 9);
        row.evidence = columnText(stmt, 10);
        row.evidenceClass = trimCopy(columnText(stmt, 11));
        row.alias = trimCopy(columnText(stmt, 12));
        row.candidateIds = columnText(stmt, 13);
        row.entityId = trimCopy(columnText(stmt, 14));
        row.acceptedType = trimCopy(columnText(stmt, 15));
        row.nodeId = trimCopy(columnText(stmt, 16));
        row.nodeType = trimCopy(columnText(stmt, 17));
        row.nodeLabel = trimCopy(columnText(stmt, 18));
        row.description = trimCopy(columnText(stmt, 19));
        row.aliases = trimCopy(columnText(stmt, 20));
        row.edgeLabel = trimCopy(columnText(stmt, 21));
        rows.push_back(std::move(row));
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    if (!dryRun) {
        rc = execSql(handle, "BEGIN IMMEDIATE");
        if (rc != CPRAG_OK) {
            return rc;
        }
    }

    int processed = 0;
    int skipped = 0;
    int nodeWrites = 0;
    int relationshipWrites = 0;
    std::ostringstream items;
    items << '[';
    bool firstItem = true;

    for (const ResolveItem& row : rows) {
        std::string status = "processed";
        std::string detail;
        int acceptedNodes = 0;
        int acceptedRelationships = 0;

        if (itemType == "endpoint-resolution") {
            bool sourceExists = false;
            bool targetExists = false;
            rc = entityExists(handle, row.sourceId, &sourceExists);
            if (rc != CPRAG_OK) {
                if (!dryRun) {
                    execSql(handle, "ROLLBACK");
                }
                return rc;
            }
            rc = entityExists(handle, row.targetId, &targetExists);
            if (rc != CPRAG_OK) {
                if (!dryRun) {
                    execSql(handle, "ROLLBACK");
                }
                return rc;
            }
            if (row.sourceId.empty() || row.targetId.empty() || row.relationshipType.empty() || !sourceExists || !targetExists) {
                status = "skipped";
                detail = "missing endpoint or relationship type";
            } else {
                const std::string label = row.label.empty() ? row.relationshipType : row.label;
                double weight = row.weight;
                if (!std::isfinite(weight) || weight <= 0.0) {
                    weight = 0.55;
                } else if (weight > 1.0) {
                    weight = 1.0;
                }
                const std::string evidenceClass = row.evidenceClass.empty() ? "model-proposal" : row.evidenceClass;
                std::ostringstream metadata;
                metadata << "{\"profile_id\":" << jsonString(profileId)
                    << ",\"queue_id\":" << jsonString(queueId)
                    << ",\"item_id\":" << jsonString(row.itemId)
                    << ",\"item_type\":\"endpoint-resolution\""
                    << ",\"worker\":\"endpoint-resolution-consumer\""
                    << ",\"evidence\":" << jsonString(row.evidence)
                    << ",\"evidence_class\":" << jsonString(evidenceClass)
                    << ",\"directness\":\"accepted-typed-edge\""
                    << ",\"work_item\":" << (row.metadata.empty() ? "{}" : row.metadata)
                    << "}";
                if (!dryRun) {
                    rc = cprag_add_edge_typed(
                        handle,
                        row.sourceId.c_str(),
                        row.targetId.c_str(),
                        row.relationshipType.c_str(),
                        label.c_str(),
                        weight,
                        metadata.str().c_str());
                    if (rc != CPRAG_OK) {
                        execSql(handle, "ROLLBACK");
                        return rc;
                    }
                }
                acceptedRelationships = 1;
                detail = "typed edge accepted";
            }
        } else if (itemType == "ambiguity-review") {
            std::string alias = row.alias;
            if (alias.empty() && startsWith(row.itemId, "ambiguity:")) {
                alias = row.itemId.substr(std::string("ambiguity:").size());
            }
            if (alias.empty()) {
                status = "skipped";
                detail = "missing alias";
            } else {
                const std::string ambiguityId = startsWith(row.itemId, "ambiguity:")
                    ? row.itemId
                    : "ambiguity:" + slugForId(alias);
                std::ostringstream nodeMetadata;
                nodeMetadata << "{\"profile_id\":" << jsonString(profileId)
                    << ",\"queue_id\":" << jsonString(queueId)
                    << ",\"item_id\":" << jsonString(row.itemId)
                    << ",\"item_type\":\"ambiguity-review\""
                    << ",\"alias\":" << jsonString(alias)
                    << ",\"evidence_class\":\"ambiguity-review\""
                    << ",\"directness\":\"ambiguity-lead\""
                    << ",\"work_item\":" << (row.metadata.empty() ? "{}" : row.metadata)
                    << "}";
                if (!dryRun) {
                    rc = cprag_add_entity_typed(
                        handle,
                        ambiguityId.c_str(),
                        "ambiguity",
                        ("Ambiguous mention: " + alias).c_str(),
                        "Mention needs explicit resolution against possible concepts.",
                        nodeMetadata.str().c_str());
                    if (rc != CPRAG_OK) {
                        execSql(handle, "ROLLBACK");
                        return rc;
                    }
                }
                acceptedNodes = 1;
                ++nodeWrites;

                for (const std::string& candidateId : splitIdList(row.candidateIds)) {
                    bool candidateExists = false;
                    rc = entityExists(handle, candidateId, &candidateExists);
                    if (rc != CPRAG_OK) {
                        if (!dryRun) {
                            execSql(handle, "ROLLBACK");
                        }
                        return rc;
                    }
                    if (!candidateExists) {
                        continue;
                    }
                    std::ostringstream edgeMetadata;
                    edgeMetadata << "{\"profile_id\":" << jsonString(profileId)
                        << ",\"queue_id\":" << jsonString(queueId)
                        << ",\"item_id\":" << jsonString(row.itemId)
                        << ",\"item_type\":\"ambiguity-review\""
                        << ",\"alias\":" << jsonString(alias)
                        << ",\"candidate_id\":" << jsonString(candidateId)
                        << ",\"evidence_class\":\"ambiguity-review\""
                        << ",\"directness\":\"ambiguity-lead\""
                        << "}";
                    if (!dryRun) {
                        rc = cprag_add_edge_typed(
                            handle,
                            ambiguityId.c_str(),
                            candidateId.c_str(),
                            "candidate-for",
                            ("Possible interpretation for " + alias).c_str(),
                            0.4,
                            edgeMetadata.str().c_str());
                        if (rc != CPRAG_OK) {
                            execSql(handle, "ROLLBACK");
                            return rc;
                        }
                    }
                    ++acceptedRelationships;
                }
                detail = acceptedRelationships > 0 ? "ambiguity candidates linked" : "ambiguity node accepted without candidate links";
            }
        } else if (itemType == "type-review") {
            const std::string entityId = row.entityId.empty() ? row.sourceId : row.entityId;
            const std::string acceptedType = row.acceptedType;
            bool exists = false;
            rc = entityExists(handle, entityId, &exists);
            if (rc != CPRAG_OK) {
                if (!dryRun) {
                    execSql(handle, "ROLLBACK");
                }
                return rc;
            }
            if (entityId.empty() || acceptedType.empty() || !exists) {
                status = "skipped";
                detail = "missing entity or accepted type";
            } else {
                if (!dryRun) {
                    sqlite3_stmt* updateStmt = nullptr;
                    rc = prepare(
                        handle,
                        "UPDATE entities SET "
                        "node_type = ?, "
                        "metadata_json = json_set("
                        "  CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, "
                        "  '$.type_review.profile_id', ?, "
                        "  '$.type_review.queue_id', ?, "
                        "  '$.type_review.item_id', ?, "
                        "  '$.type_review.previous_type', node_type, "
                        "  '$.type_review.accepted_type', ?, "
                        "  '$.type_review.evidence', ?, "
                        "  '$.type_review.evidence_class', 'type-review', "
                        "  '$.type_review.directness', 'accepted-type-review', "
                        "  '$.type_review.work_item', json(?)) "
                        "WHERE id = ?",
                        &updateStmt);
                    if (rc != CPRAG_OK) {
                        execSql(handle, "ROLLBACK");
                        return rc;
                    }
                    bindText(updateStmt, 1, acceptedType);
                    bindText(updateStmt, 2, profileId);
                    bindText(updateStmt, 3, queueId);
                    bindText(updateStmt, 4, row.itemId);
                    bindText(updateStmt, 5, acceptedType);
                    bindText(updateStmt, 6, row.evidence);
                    bindText(updateStmt, 7, row.metadata.empty() ? "{}" : row.metadata);
                    bindText(updateStmt, 8, entityId);
                    const int updateRc = sqlite3_step(updateStmt);
                    sqlite3_finalize(updateStmt);
                    if (updateRc != SQLITE_DONE) {
                        execSql(handle, "ROLLBACK");
                        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
                    }
                }
                acceptedNodes = 1;
                ++nodeWrites;
                detail = "entity type accepted";
            }
        } else if (itemType == "external-extraction-review") {
            bool wroteNode = false;
            const std::string nodeId = row.nodeId;
            const std::string nodeType = row.nodeType.empty() ? "unknown" : row.nodeType;
            std::string nodeLabel = row.nodeLabel;
            if (nodeLabel.empty()) {
                nodeLabel = nodeId;
            }
            const std::string nodeDescription = row.description.empty()
                ? "Accepted from external extraction review."
                : row.description;
            if (!nodeId.empty() && !nodeLabel.empty()) {
                std::ostringstream nodeMetadata;
                nodeMetadata << "{\"profile_id\":" << jsonString(profileId)
                    << ",\"queue_id\":" << jsonString(queueId)
                    << ",\"item_id\":" << jsonString(row.itemId)
                    << ",\"item_type\":\"external-extraction-review\""
                    << ",\"extractor\":\"external-extraction-review-consumer\""
                    << ",\"evidence\":" << jsonString(row.evidence)
                    << ",\"evidence_class\":\"external-extraction-review\""
                    << ",\"directness\":\"accepted-external-node\"";
                if (!row.aliases.empty()) {
                    nodeMetadata << ",\"aliases\":" << jsonString(row.aliases);
                }
                nodeMetadata << ",\"work_item\":" << (row.metadata.empty() ? "{}" : row.metadata)
                    << "}";
                if (!dryRun) {
                    rc = cprag_add_entity_typed(
                        handle,
                        nodeId.c_str(),
                        nodeType.c_str(),
                        nodeLabel.c_str(),
                        nodeDescription.c_str(),
                        nodeMetadata.str().c_str());
                    if (rc != CPRAG_OK) {
                        execSql(handle, "ROLLBACK");
                        return rc;
                    }
                }
                wroteNode = true;
                acceptedNodes = 1;
                ++nodeWrites;
            }

            bool sourceExists = false;
            bool targetExists = false;
            rc = entityExists(handle, row.sourceId, &sourceExists);
            if (rc != CPRAG_OK) {
                if (!dryRun) {
                    execSql(handle, "ROLLBACK");
                }
                return rc;
            }
            if (!row.targetId.empty() && row.targetId == nodeId && wroteNode) {
                targetExists = true;
            } else {
                rc = entityExists(handle, row.targetId, &targetExists);
                if (rc != CPRAG_OK) {
                    if (!dryRun) {
                        execSql(handle, "ROLLBACK");
                    }
                    return rc;
                }
            }

            if (!row.sourceId.empty() && !row.targetId.empty() && !row.relationshipType.empty() && sourceExists && targetExists) {
                double weight = row.weight;
                if (!std::isfinite(weight) || weight <= 0.0) {
                    weight = 0.55;
                } else if (weight > 1.0) {
                    weight = 1.0;
                }
                const std::string label = row.edgeLabel.empty() ? row.relationshipType : row.edgeLabel;
                const std::string evidenceClass = row.evidenceClass.empty() ? "external-extraction-review" : row.evidenceClass;
                std::ostringstream edgeMetadata;
                edgeMetadata << "{\"profile_id\":" << jsonString(profileId)
                    << ",\"queue_id\":" << jsonString(queueId)
                    << ",\"item_id\":" << jsonString(row.itemId)
                    << ",\"item_type\":\"external-extraction-review\""
                    << ",\"worker\":\"external-extraction-review-consumer\""
                    << ",\"evidence\":" << jsonString(row.evidence)
                    << ",\"evidence_class\":" << jsonString(evidenceClass)
                    << ",\"directness\":\"accepted-typed-edge\""
                    << ",\"work_item\":" << (row.metadata.empty() ? "{}" : row.metadata)
                    << "}";
                if (!dryRun) {
                    rc = cprag_add_edge_typed(
                        handle,
                        row.sourceId.c_str(),
                        row.targetId.c_str(),
                        row.relationshipType.c_str(),
                        label.c_str(),
                        weight,
                        edgeMetadata.str().c_str());
                    if (rc != CPRAG_OK) {
                        execSql(handle, "ROLLBACK");
                        return rc;
                    }
                }
                acceptedRelationships = 1;
            }

            if (acceptedNodes == 0 && acceptedRelationships == 0) {
                status = "skipped";
                detail = "no accepted external node or edge";
            } else if (acceptedNodes > 0 && acceptedRelationships > 0) {
                detail = "external node and edge accepted";
            } else if (acceptedNodes > 0) {
                detail = "external node accepted";
            } else {
                detail = "external edge accepted";
            }
        }

        if (!dryRun) {
            std::ostringstream attemptMetadata;
            attemptMetadata << "{\"profile_id\":" << jsonString(profileId)
                << ",\"queue_id\":" << jsonString(queueId)
                << ",\"item_type\":" << jsonString(itemType)
                << ",\"resolver\":\"native-work-queue-consumer\""
                << ",\"detail\":" << jsonString(detail)
                << ",\"work_item\":" << (row.metadata.empty() ? "{}" : row.metadata)
                << "}";
            std::string ignoredResult;
            rc = recordWorkAttemptInternal(
                handle,
                profileId,
                queueId,
                itemType,
                row.itemId,
                row.subjectId,
                itemType + "-consumer",
                "native",
                status,
                acceptedNodes,
                acceptedRelationships,
                row.metadata,
                attemptMetadata.str(),
                false,
                &ignoredResult);
            if (rc != CPRAG_OK) {
                execSql(handle, "ROLLBACK");
                return rc;
            }
        }

        if (status == "processed") {
            ++processed;
            relationshipWrites += acceptedRelationships;
        } else {
            ++skipped;
        }

        if (!firstItem) {
            items << ',';
        }
        firstItem = false;
        items << "{\"item_id\":" << jsonString(row.itemId)
            << ",\"status\":" << jsonString(dryRun ? "dry-run" : status)
            << ",\"detail\":" << jsonString(detail)
            << ",\"accepted_nodes\":" << acceptedNodes
            << ",\"accepted_relationships\":" << acceptedRelationships
            << "}";
    }
    items << ']';

    if (!dryRun) {
        rc = execSql(handle, "COMMIT");
        if (rc != CPRAG_OK) {
            execSql(handle, "ROLLBACK");
            return rc;
        }
    }

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"item_type\":" << jsonString(itemType)
        << ",\"dry_run\":" << (dryRun ? "true" : "false")
        << ",\"selected\":" << rows.size()
        << ",\"processed\":" << processed
        << ",\"skipped\":" << skipped
        << ",\"accepted_nodes\":" << nodeWrites
        << ",\"accepted_relationships\":" << relationshipWrites
        << ",\"items\":" << items.str()
        << "}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_record_extraction_attempt(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    long long chunk_id,
    const char* extractor,
    const char* model,
    const char* status,
    int accepted_nodes,
    int accepted_relationships,
    const char* raw_output,
    const char* metadata_json,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0' || status == nullptr || status[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    if (handle->readOnly) {
        return setErrorCode(handle, CPRAG_IO_ERROR, "library is open read-only");
    }
    if (chunk_id <= 0) {
        return setErrorCode(handle, CPRAG_INVALID_ARGUMENT, "chunk_id must be positive");
    }

    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const std::string extractorValue = valueOrEmpty(extractor);
    const std::string modelValue = valueOrEmpty(model);
    const std::string statusValue = valueOrEmpty(status);
    const std::string rawOutput = valueOrEmpty(raw_output);
    const std::string itemId = "chunk:" + std::to_string(chunk_id);
    const std::string metadata = metadataOrDefault(metadata_json);
    int rc = validateMetadataJson(handle, metadata);
    if (rc != CPRAG_OK) {
        return rc;
    }

    rc = execSql(handle, "BEGIN IMMEDIATE");
    if (rc != CPRAG_OK) {
        return rc;
    }

    sqlite3_stmt* stmt = nullptr;
    rc = prepare(
        handle,
        "INSERT INTO work_attempts "
        "(profile_id, queue_name, item_type, item_id, subject_id, worker, model, status, accepted_nodes, accepted_relationships, raw_output, metadata_json) "
        "VALUES (?, ?, 'chunk-extraction', ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        &stmt);
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, itemId);
    sqlite3_bind_int64(stmt, 4, chunk_id);
    bindText(stmt, 5, extractorValue);
    bindText(stmt, 6, modelValue);
    bindText(stmt, 7, statusValue);
    sqlite3_bind_int(stmt, 8, std::max(0, accepted_nodes));
    sqlite3_bind_int(stmt, 9, std::max(0, accepted_relationships));
    bindText(stmt, 10, rawOutput);
    bindText(stmt, 11, metadata);
    int stepRc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        execSql(handle, "ROLLBACK");
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    const long long attemptId = sqlite3_last_insert_rowid(handle->db);

    sqlite3_stmt* updateStmt = nullptr;
    rc = prepare(
        handle,
        "UPDATE work_queue SET "
        "status = ?, "
        "metadata_json = json_set("
        "  CASE WHEN json_valid(metadata_json) THEN metadata_json ELSE '{}' END, "
        "  '$.last_attempt_id', ?, "
        "  '$.last_attempt_status', ?, "
        "  '$.last_attempt_extractor', ?, "
        "  '$.last_attempt_model', ?, "
        "  '$.last_accepted_nodes', ?, "
        "  '$.last_accepted_relationships', ?), "
        "updated_at = CURRENT_TIMESTAMP "
        "WHERE profile_id = ? AND queue_name = ? AND item_id = ?",
        &updateStmt);
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }
    bindText(updateStmt, 1, statusValue);
    sqlite3_bind_int64(updateStmt, 2, attemptId);
    bindText(updateStmt, 3, statusValue);
    bindText(updateStmt, 4, extractorValue);
    bindText(updateStmt, 5, modelValue);
    sqlite3_bind_int(updateStmt, 6, std::max(0, accepted_nodes));
    sqlite3_bind_int(updateStmt, 7, std::max(0, accepted_relationships));
    bindText(updateStmt, 8, profileId);
    bindText(updateStmt, 9, queueId);
    bindText(updateStmt, 10, itemId);
    stepRc = sqlite3_step(updateStmt);
    const int changed = sqlite3_changes(handle->db);
    sqlite3_finalize(updateStmt);
    if (stepRc != SQLITE_DONE) {
        execSql(handle, "ROLLBACK");
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }

    rc = execSql(handle, "COMMIT");
    if (rc != CPRAG_OK) {
        execSql(handle, "ROLLBACK");
        return rc;
    }

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"attempt_id\":" << attemptId
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"chunk_id\":" << chunk_id
        << ",\"status\":" << jsonString(statusValue)
        << ",\"accepted_nodes\":" << std::max(0, accepted_nodes)
        << ",\"accepted_relationships\":" << std::max(0, accepted_relationships)
        << ",\"queue_updated\":" << (changed > 0 ? "true" : "false")
        << "}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_list_extraction_attempts(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    long long chunk_id,
    int limit,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }
    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id).empty() ? "default" : valueOrEmpty(queue_id);
    const int effectiveLimit = limit <= 0 ? 100 : limit;
    const long long effectiveChunkId = chunk_id < 0 ? 0 : chunk_id;

    sqlite3_stmt* stmt = nullptr;
    const char* sql =
        "SELECT id, subject_id, worker, model, status, accepted_nodes, accepted_relationships, "
        "length(raw_output), metadata_json, created_at "
        "FROM work_attempts "
        "WHERE profile_id = ? AND queue_name = ? AND item_type = 'chunk-extraction' "
        "AND (? = 0 OR subject_id = ?) "
        "ORDER BY id DESC "
        "LIMIT ?";
    int rc = prepare(handle, sql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    sqlite3_bind_int64(stmt, 3, effectiveChunkId);
    sqlite3_bind_int64(stmt, 4, effectiveChunkId);
    sqlite3_bind_int(stmt, 5, effectiveLimit);

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId)
        << ",\"chunk_id\":" << effectiveChunkId
        << ",\"limit\":" << effectiveLimit
        << ",\"attempts\":[";
    bool first = true;
    int stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        const std::string metadata = columnText(stmt, 8);
        out << "{\"id\":" << sqlite3_column_int64(stmt, 0)
            << ",\"chunk_id\":" << sqlite3_column_int64(stmt, 1)
            << ",\"extractor\":" << jsonString(columnText(stmt, 2))
            << ",\"model\":" << jsonString(columnText(stmt, 3))
            << ",\"status\":" << jsonString(columnText(stmt, 4))
            << ",\"accepted_nodes\":" << sqlite3_column_int(stmt, 5)
            << ",\"accepted_relationships\":" << sqlite3_column_int(stmt, 6)
            << ",\"raw_output_size\":" << sqlite3_column_int(stmt, 7)
            << ",\"metadata\":" << (metadata.empty() ? "{}" : metadata)
            << ",\"created_at\":" << jsonString(columnText(stmt, 9))
            << "}";
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    out << "]}";
    return copyJson(handle, out.str(), out_json, out_json_size);
}

int cprag_queue_status(
    cprag_handle* handle,
    const char* profile_id,
    const char* queue_id,
    char* out_json,
    size_t out_json_size)
{
    if (handle == nullptr || profile_id == nullptr || profile_id[0] == '\0') {
        return CPRAG_INVALID_ARGUMENT;
    }

    const std::string profileId = valueOrEmpty(profile_id);
    const std::string queueId = valueOrEmpty(queue_id);

    std::ostringstream out;
    out << "{\"success\":true"
        << ",\"profile_id\":" << jsonString(profileId)
        << ",\"queue_id\":" << jsonString(queueId);

    sqlite3_stmt* stmt = nullptr;
    const char* queueSql =
        "SELECT queue_name, item_type, status, COUNT(*), "
        "MIN(score), MAX(score), MIN(created_at), MAX(updated_at) "
        "FROM work_queue "
        "WHERE profile_id = ? AND (? = '' OR queue_name = ?) "
        "GROUP BY queue_name, item_type, status "
        "ORDER BY queue_name, item_type, status";
    int rc = prepare(handle, queueSql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, queueId);

    out << ",\"queue_items\":[";
    bool first = true;
    int stepRc = SQLITE_OK;
    long long queueTotal = 0;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        const int count = sqlite3_column_int(stmt, 3);
        queueTotal += count;
        out << "{\"queue_id\":" << jsonString(columnText(stmt, 0))
            << ",\"item_type\":" << jsonString(columnText(stmt, 1))
            << ",\"status\":" << jsonString(columnText(stmt, 2))
            << ",\"count\":" << count
            << ",\"min_score\":" << sqlite3_column_double(stmt, 4)
            << ",\"max_score\":" << sqlite3_column_double(stmt, 5)
            << ",\"created_at_min\":" << jsonString(columnText(stmt, 6))
            << ",\"updated_at_max\":" << jsonString(columnText(stmt, 7))
            << "}";
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    out << "]";

    stmt = nullptr;
    const char* attemptSql =
        "SELECT queue_name, item_type, status, COUNT(*), "
        "COALESCE(SUM(accepted_nodes), 0), COALESCE(SUM(accepted_relationships), 0), "
        "MAX(id), MAX(created_at) "
        "FROM work_attempts "
        "WHERE profile_id = ? AND (? = '' OR queue_name = ?) "
        "GROUP BY queue_name, item_type, status "
        "ORDER BY queue_name, item_type, status";
    rc = prepare(handle, attemptSql, &stmt);
    if (rc != CPRAG_OK) {
        return rc;
    }
    bindText(stmt, 1, profileId);
    bindText(stmt, 2, queueId);
    bindText(stmt, 3, queueId);

    out << ",\"attempts\":[";
    first = true;
    long long attemptTotal = 0;
    long long acceptedNodesTotal = 0;
    long long acceptedRelationshipsTotal = 0;
    long long lastAttemptId = 0;
    std::string lastAttemptAt;
    stepRc = SQLITE_OK;
    while ((stepRc = sqlite3_step(stmt)) == SQLITE_ROW) {
        if (!first) {
            out << ',';
        }
        first = false;
        const int count = sqlite3_column_int(stmt, 3);
        const long long acceptedNodes = sqlite3_column_int64(stmt, 4);
        const long long acceptedRelationships = sqlite3_column_int64(stmt, 5);
        const long long maxAttemptId = sqlite3_column_int64(stmt, 6);
        const std::string maxCreatedAt = columnText(stmt, 7);
        attemptTotal += count;
        acceptedNodesTotal += acceptedNodes;
        acceptedRelationshipsTotal += acceptedRelationships;
        if (maxAttemptId > lastAttemptId) {
            lastAttemptId = maxAttemptId;
            lastAttemptAt = maxCreatedAt;
        }
        out << "{\"queue_id\":" << jsonString(columnText(stmt, 0))
            << ",\"item_type\":" << jsonString(columnText(stmt, 1))
            << ",\"status\":" << jsonString(columnText(stmt, 2))
            << ",\"count\":" << count
            << ",\"accepted_nodes\":" << acceptedNodes
            << ",\"accepted_relationships\":" << acceptedRelationships
            << ",\"last_attempt_id\":" << maxAttemptId
            << ",\"last_attempt_at\":" << jsonString(maxCreatedAt)
            << "}";
    }
    sqlite3_finalize(stmt);
    if (stepRc != SQLITE_DONE) {
        return setErrorCode(handle, CPRAG_DATABASE_ERROR, sqliteError(handle->db));
    }
    out << "]";

    out << ",\"totals\":{"
        << "\"queue_items\":" << queueTotal
        << ",\"attempts\":" << attemptTotal
        << ",\"accepted_nodes\":" << acceptedNodesTotal
        << ",\"accepted_relationships\":" << acceptedRelationshipsTotal
        << ",\"last_attempt_id\":" << lastAttemptId
        << ",\"last_attempt_at\":" << jsonString(lastAttemptAt)
        << "}}";
    return copyJson(handle, out.str(), out_json, out_json_size);
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

int cprag_export_dot(
    cprag_handle* handle,
    const char* node_type_filter_csv,
    const char* relationship_type_filter_csv,
    int limit,
    char* out_dot,
    size_t out_dot_size)
{
    if (handle == nullptr) {
        return CPRAG_INVALID_ARGUMENT;
    }

    try {
        const std::string dot = buildTypedSubgraphDot(
            loadEntities(handle),
            loadEdges(handle),
            valueOrEmpty(node_type_filter_csv),
            valueOrEmpty(relationship_type_filter_csv),
            limit);
        if (dot.empty()) {
            return setErrorCode(handle, CPRAG_NOT_FOUND, "no nodes matched DOT export filters");
        }
        return copyJson(handle, dot, out_dot, out_dot_size);
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
