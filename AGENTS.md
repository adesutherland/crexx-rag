# AGENTS.md

Repository guidance for `crexx-rag`.

## Intent

- Keep the native core usable without CREXX, MCP, or any UI.
- Keep CREXX as the tunable orchestration/profile layer.
- Keep MCP as a thin client-facing adapter over the same core.
- Prefer small, shareable local library bundles over server-only storage.
- Treat the typed relationship map as fundamental to the vision. The primary
  use case is an IT architecture view of the world, likely ArchiMate-inspired,
  but the same model should be useful for other structured domains.
- Keep the first storage format folder-based and shareable:
  `manifest.json`, `library.sqlite`, and optional `vectors.faiss`.

## Build

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

The debug preset intentionally uses Ninja and writes to `cmake-build-debug`.
CLion should use the same generator/directory pair. If CLion reports an
incompatible generator for that directory, delete/regenerate the build directory
with `cmake --preset debug`; do not keep a Unix Makefiles cache there.

The project has also been validated with CLion's bundled CMake/Ninja on Apple
Silicon. CLion may invoke a command shaped like:

```bash
/Applications/CLion.app/Contents/bin/cmake/mac/aarch64/bin/cmake \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_MAKE_PROGRAM=/Applications/CLion.app/Contents/bin/ninja/mac/aarch64/ninja \
  -G Ninja \
  -S /Users/adrian/CLionProjects/crexx-rag \
  -B /Users/adrian/CLionProjects/crexx-rag/cmake-build-debug
```

`FindSQLite3` behaves differently across CMake builds. Keep the defensive
SQLite link logic in `CMakeLists.txt`: prefer `SQLite3::SQLite3`, fall back to
`SQLite::SQLite3`, then fall back to `SQLite3_LIBRARIES` and
`SQLite3_INCLUDE_DIRS`.

Build artifacts, `.cprag` libraries, and CLion `.idea/` files are intentionally
ignored. Use `CMakePresets.json` for shareable build configuration instead of
committing IDE workspace state.

CREXX integration should target the installed CREXX toolchain first, not the
sibling source checkout. The sibling checkout may be changing underneath us and
is useful as a reference, but it is not the compatibility target.

The build discovers `crexx` from `PATH` and searches near the installed binary
for `crexxpa.h`. If the installed package does not include the rxpa development
header, CMake may use the temporary vendored copy in
`third_party/crexx-rxpa/crexxpa.h`. That vendored header and its generated
`crexx_version.h` companion were copied from the sibling CREXX tree only as a
short-term bridge.

Use `-DCREXX_RXPA_INCLUDE_DIR=/path/to/installed/rxpa/include` when an installed
development header is available. Use `-DCPRAG_ALLOW_VENDORED_CREXXPA=OFF` to
verify that the installed distribution is sufficient. Use
`-DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=ON` only for temporary local diagnosis
against a source checkout.

When CREXX integration fails because the installed toolchain lacks headers,
CMake config files, plugin helpers, or runtime discovery features, record the
gap in `docs/crexx-integration-issues.md`. One project goal is to surface CREXX
packaging defects and missing native-plugin ergonomics clearly enough that the
CREXX team can improve them.

For dynamic plugin execution, remember that `-i` is compile/import only. The VM
also needs the plugin as a runtime module, for example:

```bash
rxvme -l cmake-build-debug/bin <program> rx_rag
```

When using the CREXX wrapper surface, compile `crexx/cprag.crexx` as a module
and load both runtime modules:

```bash
rxvme -l cmake-build-debug/bin <program> cprag rx_rag
```

The repeatable pattern is documented in `docs/crexx-plugin-pattern.md`.

## Design Rules

- The C ABI in `include/crexx_rag/ragcore.h` is the stable boundary.
- Do not expose FAISS, SQLite, C++ STL types, or graph implementation details
  through the C ABI.
- Keep `cprag_core` usable on its own; CREXX, CLI, and MCP are adapters over
  the same core.
- Nodes have meaningful types and relationships have meaningful type/semantic
  labels. Do not treat these as presentation-only metadata; they affect
  traversal, filtering, ranking, and explanation.
- The initial shared vocabulary is in `docs/architecture-vocabulary.md`, but the
  storage remains domain-neutral and may accept workload-specific types.
- Keep graph features intentionally essential until a real workload proves the
  need for a graph database:
  - k-hop expansion
  - relation filters
  - shortest path
  - subgraph extraction
  - simple ranking hooks
- Keep user-tunable ranking and retrieval policy in CREXX Level G/profile
  scripts where practical. MCP should remain a thin client-facing adapter.
- LLM-facing MCP search should default to `mode=auto`: use lexical search unless
  a compatible active vector index and embedding command are configured. Manual
  `lexical`, `vector`, and `hybrid` modes are for diagnostics and profiles.
- Keep MCP read-only by default. Mutating MCP tools must require explicit
  `--allow-writes` process startup and need negative tests for write gating and
  argument validation.
- Dynamic CREXX plugins are preferred for this project.
- The CREXX plugin is an integration target and diagnostic surface. Do not hide
  installed CREXX defects by silently depending on the sibling source tree.
- TODO: remove `third_party/crexx-rxpa/crexxpa.h`, its companion
  `crexx_version.h`, and the vendored-header CMake fallback once CREXX installs
  version-matched rxpa development headers.

## Dependency Direction

- SQLite is acceptable as a baseline dependency.
- FAISS is optional and must stay behind the C ABI. SQLite remains the source of
  truth for vector metadata; `vectors.faiss` is a rebuildable sidecar.
- Avoid adding a graph database dependency until the native essential graph layer
  is clearly insufficient.
- CREXX development headers and plugin build metadata should come from the
  installed CREXX package once CREXX provides them.

## Current Milestone

- Native core supports SQLite-backed entities and edges.
- Native core supports persistent documents and chunks with SQLite FTS5 lexical
  retrieval.
- Native core can store caller-provided chunk embeddings in SQLite and, when
  built with `CPRAG_ENABLE_FAISS=ON`, rebuild/search a FAISS `vectors.faiss`
  sidecar for one active embedding model/dimension.
- Entity `node_type` and edge `relationship_type` are explicit schema/API
  fields.
- Search combines naive text overlap over entity ids, labels, and descriptions
  with FTS5 chunk hits. `cprag_search_with_vector` supports lexical, vector,
  hybrid, and auto chunk retrieval modes.
- Graph expansion is BFS over incoming and outgoing edges; shortest path and
  typed subgraph extraction are available in the native core.
- Chunking is a Qt-free port inspired by CognitivePipelines' RAG chunkers,
  currently covering plain text, Markdown, and Rexx-oriented source.
- MCP server is a hardened stdio adapter with status, search, vocabulary,
  vector status, shortest path, typed subgraph, ingest, source/chunk listing,
  source deletion, and graph edit tools. It validates JSON-RPC shape and typed
  arguments, and it is read-only by default. It can call an external embedding
  command for automatic hybrid search when configured.
- CREXX plugin publishes Level G RXPA signatures and currently builds through
  the temporary vendored rxpa headers. It includes vector status, chunk
  embedding storage, FAISS rebuild, and vector search functions using
  comma-separated float vectors at the CREXX boundary.
- `crexx/cprag.crexx` provides the first Level G class-shaped wrapper surface
  over the raw plugin functions.
- CREXX plugin runtime is covered by `crexx_profile_smoke` when installed
  `rxc`, `rxas`, and `rxvme` are available.

## Publication

This repository is intended to be public on GitHub as `adesutherland/crexx-rag`.
Do not commit local build directories or CLion workspace files. Before pushing,
run at least:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```
