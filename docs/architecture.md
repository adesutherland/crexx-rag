# Architecture

`crexx-rag` is designed as a small native core with multiple frontends.

```text
Codex / MCP clients
        |
        v
crexx-rag-mcp
        |
        v
CREXX Level G surface ---> rx_rag.rxplugin
        |                         |
        +-------------------------+
                  |
                  v
              cprag_core
                  |
       +----------+----------+
       |                     |
   SQLite metadata      FAISS vectors
   graph/doc chunks     optional sidecar
```

## Native Core

The native core exposes only C types through `include/crexx_rag/ragcore.h`.
SQLite, C++ containers, FAISS, and graph internals stay hidden.

Current capabilities:

- initialize a shareable `.cprag` library bundle
- chunk plain text, Markdown, and Rexx-oriented text without Qt
- ingest text sources into persistent document and chunk tables
- list ingested sources
- build source-level timelines from captured and event times
- add/update entities
- add edges
- perform naive text anchor search over entities
- perform SQLite FTS5 lexical search over chunks
- preserve source provenance, confidence, and timeline fields on sources and
  chunks, and include them in retrieval output
- store caller-provided chunk embeddings in SQLite
- rebuild and search an optional FAISS `vectors.faiss` chunk index
- perform lexical, vector, or hybrid chunk retrieval when a query vector is
  supplied by an adapter
- iterate stored chunks so adapters can batch-generate embeddings without
  parsing JSON result payloads
- expand anchors through k-hop graph traversal
- return JSON suitable for CLI, CREXX, or MCP wrappers

## Adapter Roles

MCP should stay a thin client-facing adapter for agents and tools. It should not
become the place where retrieval policy, ranking profiles, or domain-specific
relationship behavior live.

The MCP server is read-only by default. Mutating tools are not advertised and
are rejected unless the process is started with `--allow-writes`. Requests are
validated as JSON-RPC before dispatching to the native core.

For ordinary LLM use, MCP should route read requests through `library_search`
with `mode=auto`. Auto mode uses lexical search unless a compatible active
vector index and configured embedding command are available, in which case MCP
passes a query vector to the native hybrid search path. Manual `lexical`,
`vector`, and `hybrid` modes are diagnostic/profile controls.

The richer orchestration surface belongs in CREXX Level G. The raw `rxrag`
plugin exposes native functions, and `crexx/cprag.crexx` starts the higher-level
`cprag.raglibrary` class wrapper. That wrapper currently preserves JSON as the
interchange format and can use CREXX's `rxjson` helpers for profile logic and
small convenience methods.

## Graph Layer

The graph layer is a typed relationship map, not merely adjacency around search
hits. The first target domain is an IT architecture view of the world, probably
using an ArchiMate-inspired vocabulary. Nodes should carry explicit architectural
types such as component, service, capability, data object, technology node, or
deployment target. Edges should carry relationship semantics such as depends-on,
realizes, serves, accesses, flows-to, composed-of, or deployed-on.

The first shared vocabulary is documented in
[`architecture-vocabulary.md`](architecture-vocabulary.md) and exposed through
the native, CLI, MCP, and CREXX adapters.

Those type semantics belong in the native model because they affect retrieval,
expansion, filtering, ranking, and explanation. CREXX/profile scripts may choose
which vocabularies and policies to prefer for a workload, but the core should
preserve and expose node and relationship types consistently.

The first implementation remains deliberately small:

- entities are nodes
- edges are directed relationships
- entities have explicit `node_type`
- edges have explicit `relationship_type`
- expansion traverses both incoming and outgoing edges
- relation filters are optional
- BFS controls hop depth
- shortest path and typed subgraph extraction are provided by the native core

This covers the useful part of the local GraphRAG pattern without committing to
a graph database too early.

The model should stay domain-neutral enough to describe non-IT maps, including
materials, processes, and other structured knowledge domains, while keeping the
architecture relationship map as the guiding use case.

## Provenance, Confidence, and Time

Documents and chunks carry source provenance and temporal context as first-class
fields:

- `source_type`: where the information came from, using shared terms such as
  primary-source, client-stated, meeting-note, decision-record, derived,
  inferred, external-reference, or unknown
- `confidence`: a numeric trust weight from `0.0` to `1.0`
- `captured_at`: when the information was gathered or entered
- `event_start_at` and `event_end_at`: when the represented event, meeting,
  decision, or validity period happened

These fields are not just metadata for display. Search results expose them,
lexical retrieval applies confidence as a ranking weight, `library_timeline`
and the CLI `timeline` command expose the first chronological view, and
CREXX/profile code can use the same fields for richer ranking and explanation.

The vocabulary API exposes provenance, temporal role, confidence scale, and
embedding profile terms alongside architecture node and relationship terms.

## Optional FAISS Index

FAISS is behind the C ABI as an optional native dependency. Expected files
inside a library bundle:

```text
library.cprag/
  manifest.json
  library.sqlite
  vectors.faiss
```

SQLite should remain the source of truth for ids, metadata, document chunks, and
graph structure. FAISS should hold vector ids that map back through SQLite chunk
rows.

The first vector surface intentionally accepts caller-provided chunk embeddings.
FAISS does not generate embeddings; it indexes and searches vectors generated by
an adapter or local provider. Embedding generation belongs in an adapter layer,
then ranking and retrieval policy can be tuned from CREXX/profile code. The
current FAISS sidecar is a single active chunk index for one embedding
model/profile/dimension at a time and can be rebuilt from SQLite metadata. The
CLI can batch-embed stored chunks through an external command, using an
embedding profile to render either raw text or a semantic-context envelope.
MCP has the same external-command hook for query-time vectors. Richer provider
integration and ranking policy still belong above the core.
