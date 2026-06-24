# crexx-rag

`crexx-rag` is a lightweight local GraphRAG experiment intended to be usable from
CREXX, Codex, and plain command-line workflows.

An essential aim is to model a typed relationship map, not just a bag of text
chunks. The primary use case is an IT architecture view of the world, likely
inspired by ArchiMate: nodes have meaningful types such as components, services,
capabilities, data objects, and technology nodes; relationships have architecture
semantics such as depends-on, realizes, serves, accesses, flows-to, composed-of,
and deployed-on. The same idea should remain useful outside IT architecture, for
example when modelling domains such as materials, processes, or knowledge maps.

CREXX profiles can tune ranking, traversal, and vocabulary choices, but typed
nodes, typed relationships, source provenance, timeline fields, and confidence
ratings are fundamental to the native core rather than presentation-layer
concerns.

The initial architecture keeps the hot path native and the tunable policy layer
scriptable:

- `cprag_core`: C/C++ library with a stable C ABI.
- `crexx-rag`: command-line tool for local use and smoke testing.
- `crexx-rag-mcp`: stdio MCP server starter for Codex and other MCP clients.
- `rx_rag.rxplugin`: CREXX `rxpa` dynamic plugin exposing native functions.
- `cprag.crexx`: Level G CREXX wrapper for profiles and policy scripts.

The first implementation uses SQLite for a shareable local library bundle and a
small built-in graph traversal layer. It stores both the typed relationship map
and persistent document chunks, with SQLite FTS5 providing the first local
lexical retrieval path. It also ports the useful chunking ideas from
CognitivePipelines into a Qt-free native chunker for plain text, Markdown, and
Rexx-oriented source. Optional FAISS support adds a rebuildable `vectors.faiss`
sidecar for chunk vector search when callers provide embeddings.

## Build

From this repository:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

The `debug` preset uses Ninja and generates into `cmake-build-debug`, matching
the intended CLion profile.

The core, CLI, MCP server, and tests do not require CREXX headers. The CREXX
plugin build targets the installed CREXX toolchain first:

```bash
which crexx
```

If the installed CREXX package includes the rxpa development header, point CMake
at it when auto-discovery cannot find it:

```bash
cmake --preset debug -DCREXX_RXPA_INCLUDE_DIR=/path/to/installed/rxpa/include
```

Until CREXX installs that header, this repo carries a temporary copy at
[`third_party/crexx-rxpa/crexxpa.h`](third_party/crexx-rxpa/crexxpa.h), plus
the generated companion `crexx_version.h` required by that header. TODO: remove
the vendored headers and fallback CMake path once the CREXX distribution
provides version-matched development headers.

The sibling CREXX source checkout is intentionally not used by default because
it may be changing. A source checkout fallback exists only for diagnosis:

```bash
cmake --preset debug -DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=ON
```

Known CREXX integration/package gaps are tracked in
[`docs/crexx-integration-issues.md`](docs/crexx-integration-issues.md).
The repeatable dynamic plugin compile/run pattern is documented in
[`docs/crexx-plugin-pattern.md`](docs/crexx-plugin-pattern.md).
The initial typed architecture vocabulary is documented in
[`docs/architecture-vocabulary.md`](docs/architecture-vocabulary.md).

FAISS is optional and off by default. To build the FAISS-backed vector path,
install FAISS and configure with:

```bash
cmake -S . -B cmake-build-faiss -G Ninja -DCPRAG_ENABLE_FAISS=ON
cmake --build cmake-build-faiss
ctest --test-dir cmake-build-faiss --output-on-failure
```

The vector milestone is bring-your-own embeddings at the core boundary: FAISS
does not create embeddings, it indexes and searches fixed-length numeric
vectors. The core stores chunk embedding vectors in SQLite, rebuilds
`vectors.faiss` from that metadata, and searches the sidecar. CLI and MCP
adapters can call an external embedding command for local-first vector
generation.

Source provenance and timeline context are first-class retrieval metadata. Text
sources can carry `source_type`, `confidence`, `captured_at`, `event_start_at`,
and `event_end_at`; chunks inherit those fields, search results return them, and
lexical ranking applies the confidence value as a trust weight. `timeline`
provides the first source-level chronological view.

## CLI Sketch

```bash
./cmake-build-debug/crexx-rag init ./example.cprag
./cmake-build-debug/crexx-rag add-entity-typed ./example.cprag entity:auth service Authentication "Authentication service"
./cmake-build-debug/crexx-rag add-entity-typed ./example.cprag entity:db data-object PostgreSQL "PostgreSQL user database"
./cmake-build-debug/crexx-rag add-edge-typed ./example.cprag entity:auth entity:db accesses "Reads user profiles" 1.0
./cmake-build-debug/crexx-rag ingest-text ./example.cprag docs/auth.md "Auth notes" markdown 800 120 $'# Auth\n\nAuth depends on PostgreSQL.'
./cmake-build-debug/crexx-rag ingest-text ./example.cprag docs/decision.md "Decision note" plain 800 120 "The client confirmed the API database decision." '{}' decision-record 0.9 2026-06-24T09:00:00Z 2026-06-23T14:00:00Z
./cmake-build-debug/crexx-rag list-sources ./example.cprag
./cmake-build-debug/crexx-rag timeline ./example.cprag 20
./cmake-build-debug/crexx-rag list-chunks ./example.cprag docs/auth.md
./cmake-build-debug/crexx-rag vector-status ./example.cprag
./cmake-build-debug/crexx-rag shortest-path ./example.cprag entity:auth entity:db
./cmake-build-debug/crexx-rag search ./example.cprag "what database does auth use" 3 2
```

With a FAISS-enabled build, callers can attach embeddings and rebuild/search the
sidecar:

```bash
./cmake-build-faiss/crexx-rag add-chunk-embedding ./example.cprag 1 test-model 1.0,0.0,0.0
./cmake-build-faiss/crexx-rag rebuild-vector-index ./example.cprag test-model
./cmake-build-faiss/crexx-rag vector-search ./example.cprag test-model 0.9,0.1,0.0 3
```

For ordinary local use, the CLI can embed all stored chunks by calling an
external command, then rebuild the FAISS sidecar. By default this uses the
`semantic-context-v1` embedding profile, which sends a stable envelope with
source type, confidence, timeline fields, title, and chunk text to the embedder:

```bash
./cmake-build-faiss/crexx-rag embed-chunks ./example.cprag test-model ./embed-text
./cmake-build-faiss/crexx-rag embed-chunks ./example.cprag test-model ./embed-text docs/auth.md
./cmake-build-faiss/crexx-rag embedding-text ./example.cprag 1 semantic-context-v1
```

The embedding command is invoked as:

```text
<embedding-command> <text> <embedding-model>
```

It must print either a JSON number array, such as `[0.1,0.2,0.3]`, or an object
with an `embedding` array. Ollama can be used behind a small wrapper when a
local embedding-capable model is installed, but a general Gemma chat model is
not a substitute for a stable embedding model unless it exposes consistent
embedding vectors.

## MCP Direction

`crexx-rag-mcp` is deliberately a thin stdio adapter over `cprag_core`. It is
read-only by default and only advertises read tools unless started with explicit
write access:

```bash
./cmake-build-debug/crexx-rag-mcp --library ./example.cprag
./cmake-build-debug/crexx-rag-mcp --allow-writes --library ./example.cprag
```

The MCP adapter validates JSON-RPC request shape, tool names, argument objects,
required arguments, and argument types before calling the native core.

`library_search` is the main LLM-facing read tool. It accepts `mode` as
`auto`, `lexical`, `vector`, or `hybrid`; default `auto` falls back to lexical
search unless a compatible active vector index and embedding command are
available. Manual modes are intended for diagnostics and profiles, not ordinary
LLM use.

To enable query-time embeddings for automatic MCP hybrid search, start the MCP
server with an embedding command that prints a JSON number array, or an object
with an `embedding` array:

```bash
./cmake-build-faiss/crexx-rag-mcp \
  --library ./example.cprag \
  --embedding-command ./embed-query \
  --embedding-model test-model
```

## CREXX Direction

The richer user-facing surface should live in CREXX. MCP remains a thin
client-facing adapter over the same native core, while CREXX Level G scripts and
classes own profiles, retrieval policy, and higher-level orchestration.

The raw plugin exposes stateless path-based Level G functions:

- `rxrag.init(path)`
- `rxrag.addentity(path, id, label, description, metadata_json)`
- `rxrag.addentitytyped(path, id, node_type, label, description, metadata_json)`
- `rxrag.addedge(path, source_id, target_id, label, weight, metadata_json)`
- `rxrag.addedgetyped(path, source_id, target_id, relationship_type, label, weight, metadata_json)`
- `rxrag.ingest(path, source_uri, title, text, file_type, chunk_size, overlap, metadata_json, source_type, confidence, captured_at, event_start_at, event_end_at)`
- `rxrag.listsources(path)`
- `rxrag.timeline(path, limit)`
- `rxrag.listchunks(path, source_uri)`
- `rxrag.deletesource(path, source_uri)`
- `rxrag.vectorstatus(path)`
- `rxrag.embeddingtext(path, chunk_id, embedding_profile)`
- `rxrag.addchunkembedding(path, chunk_id, embedding_model, vector_csv, embedding_profile)`
- `rxrag.rebuildvectorindex(path, embedding_model, embedding_profile)`
- `rxrag.vectorsearch(path, embedding_model, vector_csv, top_k)`
- `rxrag.vocabulary()`
- `rxrag.search(path, query, top_k, hops)`
- `rxrag.expand(path, anchors_csv, hops)`
- `rxrag.shortestpath(path, source_id, target_id, relationship_filter_csv)`
- `rxrag.subgraph(path, node_type_filter_csv, relationship_type_filter_csv, limit)`
- `rxrag.stats(path)`
- `rxrag.chunk(text, chunk_size, overlap, file_type)`

The first CREXX wrapper is `cprag.raglibrary` in
[`crexx/cprag.crexx`](crexx/cprag.crexx). It wraps the raw plugin calls as a
small class-shaped API and uses CREXX's `rxjson` helpers for JSON-aware
convenience methods such as `sourceCount()`. The native functions still return
JSON so the same ABI works for CLI, CREXX, and MCP. Vector methods use
comma-separated float strings at the CREXX boundary for now; embedding provider
adapters can replace that with a richer profile-level flow later. The wrapper
names are `vectorStatusJson()`, `attachChunkEmbedding()`, `buildVectorIndex()`,
`searchVector()`, and `chunkEmbeddingInput()` to avoid colliding with raw
imported plugin function names.

The CREXX dynamic plugin smoke is part of the debug test preset when the
installed `rxc`, `rxas`, and `rxvme` are available:

```bash
ctest --preset debug -R crexx_profile_smoke --output-on-failure
```

## Status

This is a scaffold, not a finished RAG engine. The current search is intentionally
simple: text-overlap anchors over entity ids, labels, and descriptions, plus
SQLite FTS5 over persisted chunks. The graph layer now has explicit node and
relationship types, shortest path, typed subgraph extraction, and source/chunk
maintenance APIs, plus provenance, confidence, and timeline fields for sources
and chunks. The vector layer stores caller-provided chunk embeddings with an
embedding profile and can use FAISS for local vector search when enabled. MCP
has a small external embedding-command hook for automatic hybrid search; the
next major piece is hybrid ranking policy in CREXX/profile code.
