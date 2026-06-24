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
- FAISS is a vector index/search backend, not an embedding provider. Keep
  embedding generation in adapters, scripts, CREXX/profile orchestration, or
  provider wrappers, and pass fixed-length vectors into the native core.
- Keep local embedding providers optional and adapter-level. The first open
  local provider path is `llama-server` from llama.cpp, with setup notes in
  `docs/local-embeddings.md`; Ollama remains supported through the same
  external embedding-command contract.
- Nodes have meaningful types and relationships have meaningful type/semantic
  labels. Do not treat these as presentation-only metadata; they affect
  traversal, filtering, ranking, and explanation.
- Source provenance, confidence, and temporal fields are also retrieval
  semantics, not presentation-only metadata. Preserve `source_type`,
  `confidence`, `captured_at`, `event_start_at`, and `event_end_at` through
  sources, chunks, search results, timelines, and embedding envelopes.
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
- Prefer CREXX and C++ for project pipeline logic and hot paths. Python may be
  useful for optional experiments or user-provided tools, but do not make the
  repeatable ingestion/extraction pipeline shell through Python when a CREXX,
  C++, or direct CLI/address-environment route is practical.
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
- Embedding providers should remain optional and adapter-level; local Ollama or
  llama.cpp `llama-server` can be wrapped as commands that emit JSON vectors.
  Use provider id `llama-server`, default base URL
  `http://127.0.0.1:8081/v1`, and `CPRAG_LLAMA_SERVER_BASE_URL` for overrides.
  The default llama.cpp embedder is
  `nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M`; Nomic inputs should be prefixed
  with `search_document: ` for chunks and `search_query: ` for queries.
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
  sidecar for one active embedding model/profile/dimension.
- Entity `node_type` and edge `relationship_type` are explicit schema/API
  fields.
- Search combines naive text overlap over entity ids, labels, and descriptions
  with FTS5 chunk hits. `cprag_search_with_vector` supports lexical, vector,
  hybrid, and auto chunk retrieval modes. Lexical chunk rank is weighted by
  chunk confidence.
- Graph expansion is BFS over incoming and outgoing edges; shortest path, typed
  subgraph extraction, and Graphviz DOT export are available in the native core.
  Entity writes upsert by id, and repeated relationship writes update the
  existing source/target/type/label connection instead of duplicating it.
- Chunking is a Qt-free port inspired by CognitivePipelines' RAG chunkers,
  currently covering plain text, Markdown, and Rexx-oriented source.
- MCP server is a hardened stdio adapter with status, search, vocabulary,
  vector status, shortest path, typed subgraph, ingest, timeline, source/chunk
  listing, source deletion, and graph edit tools. It validates JSON-RPC shape
  and typed arguments, and it is read-only by default. It can call an external
  embedding command for automatic hybrid search when configured.
- CREXX plugin publishes Level G RXPA signatures and currently builds through
  the temporary vendored rxpa headers. It includes timeline, source/chunk
  listing, chunk id/text lookup for profile extractors, known-concept listing
  and text matching, vector status, chunk embedding input rendering, chunk
  embedding storage, FAISS rebuild, and vector search functions using
  comma-separated float vectors at the CREXX boundary.
- `crexx/cprag.crexx` provides the first Level G class-shaped wrapper surface
  over the raw plugin functions.
- `crexx/profiles/history/deterministic_extract.crexx` is the first executable
  deterministic domain extractor. It is CREXX policy code that decides candidate
  nodes and relationships from chunks; the native core links, de-duplicates,
  stores, searches, walks, exports the graph, and can match stored concept
  aliases back against later text blocks.
- `crexx/profiles/history/hybrid_ingest_extract.crexx` is the first
  CREXX-controlled hybrid ingestion/extraction pipeline. It ingests and chunks
  text, uses native concept matching as the cheap known-concept API, and now
  proves the front of a corpus-scale pipeline: cheap candidate census,
  candidate collation/adjudication into keep/junk/ambiguous/type/alias decisions,
  mention/co-occurrence graph seeding, graph/vector ranking, then gated
  extraction on a shortlist. It can optionally route through Qwen2.5 advisory,
  Gemma advisory, and final gated Gemma JSON extraction. Cheap advisory calls
  must stay simple scalar/word outputs such as `proper-nouns`, `value`, `route`,
  `relation`, `alias`, and `complexity`; only final extraction should use
  candidate JSON. If a fast advisory model returns no usable Stage 1 proper
  nouns, CREXX should fall back to deterministic extraction rather than losing
  the chunk's score.
- Stage 1 output is a census, not truth. Collate it by normalized candidate,
  preserve counts and supporting chunks, classify likely junk/good/ambiguous
  candidates and types, then feed that registry back into chunk scoring. Do not
  choose the expensive extraction queue from raw proper-noun counts alone.
- Vectors may influence extraction ranking, redundancy control, coverage, and
  bridge detection, but vector similarity must not directly create typed domain
  relationships. Typed edges need deterministic evidence or accepted extraction.
- Ambiguous aliases must remain explicit graph facts, not silent guesses. For
  example, `Sutherland` can create an `ambiguity` node with `candidate-for`
  edges to both clan and place concepts while clear aliases still create normal
  `mentioned-in` evidence links.
- Repeated typed edge writes should accumulate evidence in the native core
  (`support_count`, `support_evidence`, `last_support`) and keep the strongest
  weight, rather than overwriting earlier metadata.
- `crexx-rag extract-llama-server` is the first local LLM extraction adapter. It
  returns candidate node/relationship JSON from llama.cpp chat completions but
  does not write to the graph. CREXX/profile code decides when to call it and
  validates accepted candidates before using the native graph APIs.
- `crexx-rag advise-llama-server` is the local LLM triage adapter for
  `proper-nouns`, `value`, `route`, `relation`, `alias`, and `complexity`
  questions. It should remain adapter-level and must not become a native-core
  dependency.
- Prefer one operation vocabulary across native helpers, CLI commands, CREXX
  functions, CREXX address environments, and MCP adapters. The CLI is needed for
  humans and scripts; the CREXX address environment is a programmer-friendly
  orchestration surface over the same operations, not a separate shell-script
  implementation.
- Incremental ingestion and external extractor push are first-class design
  cases. New documents should reuse the existing concept/alias registry and only
  adjudicate deltas. External LLM workflows may push proposed concepts and
  relationships with provenance, but those proposals must pass through the same
  de-duplication, ambiguity handling, support accumulation, and profile
  validation as internal extraction.
- CREXX plugin runtime is covered by `crexx_profile_smoke` when installed
  `rxc`, `rxas`, and `rxvme` are available.
- CREXXSAA cache cleanup, when needed for manual late-bound runs, is
  `crexxsaa --clear`.

## Publication

This repository is intended to be public on GitHub as `adesutherland/crexx-rag`.
Do not commit local build directories or CLion workspace files. Before pushing,
run at least:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```
