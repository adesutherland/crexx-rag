# Working Notes

These notes capture the current project context for future agents and
contributors.

## Purpose

`crexx-rag` is a lightweight local GraphRAG component for CREXX, Codex, and
plain command-line workflows. The core should stay native and reusable; CREXX
Level G should provide the tunable retrieval/profile surface; MCP should provide
thin agent access.

A central vision is the typed relationship map. The primary workload is an IT
architecture view of the world, likely with an ArchiMate-inspired vocabulary, but
the same mechanism should work for other domains. Node types and relationship
types are core model concepts because they shape traversal, retrieval, ranking,
and explanations; CREXX profiles can tune policy, but should not be the only
place where those semantics exist.

## Current Implementation

- `cprag_core` exposes a stable C ABI in `include/crexx_rag/ragcore.h`.
- SQLite stores entities, edges, documents, and chunks in a shareable `.cprag`
  folder bundle.
- Entities have explicit `node_type`; edges have explicit `relationship_type`.
- The initial architecture vocabulary lives in `docs/architecture-vocabulary.md`
  and is exposed as JSON through the adapters.
- Search currently combines placeholder text-overlap entity anchors with SQLite
  FTS5 lexical chunk retrieval. `cprag_search_with_vector` adds lexical,
  vector, hybrid, and auto chunk retrieval modes while keeping graph expansion
  over text anchors for now.
- Optional FAISS support stores caller-provided chunk embeddings in SQLite,
  rebuilds a `vectors.faiss` sidecar for one active embedding model/dimension,
  and searches that sidecar by vector.
- Graph context is expanded with simple BFS over both incoming and outgoing
  edges.
- Graph query APIs include shortest path and typed subgraph extraction.
- Chunking is Qt-free and adapted from the useful CognitivePipelines chunking
  behavior: smart overlap, Markdown header/table awareness, and Rexx-friendly
  separators.
- `crexx-rag-mcp` is a hardened stdio MCP adapter with structured JSON parsing,
  JSON-RPC validation, central tool declarations, typed argument checks, and a
  read-only default. Mutating tools require `--allow-writes`. `library_search`
  accepts `mode=auto|lexical|vector|hybrid`; `auto` is the LLM default and only
  uses vector search when an active vector index and embedding command are
  configured.
- `rx_rag.rxplugin` publishes Level G native signatures through RXPA.
- `crexx/cprag.crexx` is the first CREXX Level G wrapper surface. It exposes
  `cprag.raglibrary`, keeps JSON as the interchange format, and uses CREXX
  `rxjson` helpers for JSON-aware convenience methods. Vector status,
  add-chunk-embedding, rebuild, and vector-search calls are exposed through the
  wrapper with comma-separated float vectors. Wrapper method names avoid raw
  plugin-name collisions: `vectorStatusJson`, `attachChunkEmbedding`,
  `buildVectorIndex`, and `searchVector`.
- The CREXX smoke compiles `cprag.crexx`, compiles the profile against it,
  assembles both modules with installed `rxas`, and runs with installed
  `rxvme`.

## Build Context

Use CMake presets:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

CLion should use Ninja with `cmake-build-debug`. If CLion reports an
incompatible generator, remove `cmake-build-debug` and regenerate with the
debug preset.

SQLite discovery must remain defensive because CLion's bundled CMake found
SQLite but did not provide `SQLite3::SQLite3` on this machine.

## CREXX Context

Installed CREXX is the compatibility target. On this machine it is:

```text
/Users/adrian/.local/bin/crexx
```

The installed package currently lacks `crexxpa.h`,
`RXPluginFunction.cmake`, and a version-matched development header bundle. This
repo temporarily vendors `crexxpa.h` and generated `crexx_version.h` under
`third_party/crexx-rxpa/`. Remove that shim once CREXX distributes development
headers.

The sibling `../CREXX` checkout is reference material only. Runtime and compiler
smokes should use the installed CREXX tools. The important dynamic plugin shape
is documented in `docs/crexx-plugin-pattern.md`: compile with `-i` so `rxc` can
see the `.rxplugin` signatures, then run `rxvme` with `rx_rag` listed as a
runtime module and the plugin directory supplied through `-l`. `rxvme` already
embeds the CREXX library, so do not pass `library` as another runtime module.

Record CREXX packaging/API issues in `docs/crexx-integration-issues.md`.

## Next Steps

- Add richer embedding-provider adapters, starting local-first.
- Add hybrid lexical/vector ranking policy in CREXX/profile code. The current
  hybrid merge is intentionally simple and deterministic.
- Add larger generated or fixture-based retrieval corpora when recall,
  performance, or hybrid ranking needs tuning. The current FAISS smoke uses
  tiny deterministic vectors so CI stays fast and reliable.
- Add stricter optional validation against named vocabularies when a profile
  wants it.
- Expand the CREXX Level G wrapper and profile scripts for ranking and query
  policies.
- Keep adding MCP negative tests as tools are added so malformed requests,
  wrong argument types, and write-gating behavior remain covered.
