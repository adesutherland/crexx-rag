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
nodes and typed relationships are fundamental to the native core rather than a
presentation-layer concern.

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
Rexx-oriented source. FAISS is planned as the next native dependency for vector
search.

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

## CLI Sketch

```bash
./cmake-build-debug/crexx-rag init ./example.cprag
./cmake-build-debug/crexx-rag add-entity-typed ./example.cprag entity:auth service Authentication "Authentication service"
./cmake-build-debug/crexx-rag add-entity-typed ./example.cprag entity:db data-object PostgreSQL "PostgreSQL user database"
./cmake-build-debug/crexx-rag add-edge-typed ./example.cprag entity:auth entity:db accesses "Reads user profiles" 1.0
./cmake-build-debug/crexx-rag ingest-text ./example.cprag docs/auth.md "Auth notes" markdown 800 120 $'# Auth\n\nAuth depends on PostgreSQL.'
./cmake-build-debug/crexx-rag list-sources ./example.cprag
./cmake-build-debug/crexx-rag list-chunks ./example.cprag docs/auth.md
./cmake-build-debug/crexx-rag shortest-path ./example.cprag entity:auth entity:db
./cmake-build-debug/crexx-rag search ./example.cprag "what database does auth use" 3 2
```

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
- `rxrag.ingest(path, source_uri, title, text, file_type, chunk_size, overlap, metadata_json)`
- `rxrag.listsources(path)`
- `rxrag.listchunks(path, source_uri)`
- `rxrag.deletesource(path, source_uri)`
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
JSON so the same ABI works for CLI, CREXX, and MCP.

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
maintenance APIs. The next major piece is a FAISS-backed vector index and
embedding-provider adapter.
