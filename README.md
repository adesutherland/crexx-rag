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

## CLI Sketch

```bash
./cmake-build-debug/crexx-rag init ./example.cprag
./cmake-build-debug/crexx-rag add-entity ./example.cprag entity:auth Service "Authentication service"
./cmake-build-debug/crexx-rag add-entity ./example.cprag entity:db Database "PostgreSQL user database"
./cmake-build-debug/crexx-rag add-edge ./example.cprag entity:auth entity:db CONNECTS_TO 1.0
./cmake-build-debug/crexx-rag ingest-text ./example.cprag docs/auth.md "Auth notes" markdown 800 120 $'# Auth\n\nAuth depends on PostgreSQL.'
./cmake-build-debug/crexx-rag list-sources ./example.cprag
./cmake-build-debug/crexx-rag search ./example.cprag "what database does auth use" 3 2
```

## CREXX Direction

The plugin exposes stateless path-based functions first:

- `rxrag.init(path)`
- `rxrag.addentity(path, id, label, description, metadata_json)`
- `rxrag.addedge(path, source_id, target_id, label, weight, metadata_json)`
- `rxrag.ingest(path, source_uri, title, text, file_type, chunk_size, overlap, metadata_json)`
- `rxrag.listsources(path)`
- `rxrag.search(path, query, top_k, hops)`
- `rxrag.expand(path, anchors_csv, hops)`
- `rxrag.stats(path)`
- `rxrag.chunk(text, chunk_size, overlap, file_type)`

That gives CREXX scripts a safe tuning/orchestration layer while the storage and
graph traversal stay native.

The CREXX dynamic plugin smoke is part of the debug test preset when the
installed `rxc`, `rxas`, and `rxvme` are available:

```bash
ctest --preset debug -R crexx_profile_smoke --output-on-failure
```

## Status

This is a scaffold, not a finished RAG engine. The current search is intentionally
simple: text-overlap anchors over entity ids, labels, and descriptions, plus
SQLite FTS5 over persisted chunks. The next major piece is a FAISS-backed vector
index and embedding-provider adapter.
