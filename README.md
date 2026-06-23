# crexx-rag

`crexx-rag` is a lightweight local GraphRAG experiment intended to be usable from
CREXX, Codex, and plain command-line workflows.

The initial architecture keeps the hot path native and the tunable policy layer
scriptable:

- `cprag_core`: C/C++ library with a stable C ABI.
- `crexx-rag`: command-line tool for local use and smoke testing.
- `crexx-rag-mcp`: stdio MCP server starter for Codex and other MCP clients.
- `rx_rag.rxplugin`: CREXX `rxpa` dynamic plugin exposing native functions.

The first implementation uses SQLite for a shareable local library bundle and a
small built-in graph traversal layer. It also ports the useful chunking ideas
from CognitivePipelines into a Qt-free native chunker for plain text, Markdown,
and Rexx-oriented source. FAISS is planned as the next native dependency for
vector search.

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

## CLI Sketch

```bash
./cmake-build-debug/crexx-rag init ./example.cprag
./cmake-build-debug/crexx-rag add-entity ./example.cprag entity:auth Service "Authentication service"
./cmake-build-debug/crexx-rag add-entity ./example.cprag entity:db Database "PostgreSQL user database"
./cmake-build-debug/crexx-rag add-edge ./example.cprag entity:auth entity:db CONNECTS_TO 1.0
./cmake-build-debug/crexx-rag search ./example.cprag "what database does auth use" 3 2
```

## CREXX Direction

The plugin exposes stateless path-based functions first:

- `rxrag.init(path)`
- `rxrag.addentity(path, id, label, description, metadata_json)`
- `rxrag.addedge(path, source_id, target_id, label, weight, metadata_json)`
- `rxrag.search(path, query, top_k, hops)`
- `rxrag.expand(path, anchors_csv, hops)`
- `rxrag.stats(path)`
- `rxrag.chunk(text, chunk_size, overlap, file_type)`

That gives CREXX scripts a safe tuning/orchestration layer while the storage and
graph traversal stay native.

## Status

This is a scaffold, not a finished RAG engine. The current search is intentionally
simple text overlap over entity ids, labels, and descriptions. The next major
piece is a FAISS-backed vector index and embedding-provider adapter.
