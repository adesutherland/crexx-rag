# Working Notes

These notes capture the current project context for future agents and
contributors.

## Purpose

`crexx-rag` is a lightweight local GraphRAG component for CREXX, Codex, and
plain command-line workflows. The core should stay native and reusable; CREXX
should provide tunable retrieval profiles; MCP should provide agent access.

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
  FTS5 lexical chunk retrieval.
- Graph context is expanded with simple BFS over both incoming and outgoing
  edges.
- Graph query APIs include shortest path and typed subgraph extraction.
- Chunking is Qt-free and adapted from the useful CognitivePipelines chunking
  behavior: smart overlap, Markdown header/table awareness, and Rexx-friendly
  separators.
- `crexx-rag-mcp` is a minimal stdio MCP server scaffold with status, search,
  vocabulary, shortest path, typed subgraph, ingest, source/chunk listing,
  source deletion, and graph edit tools.
- `rx_rag.rxplugin` is the CREXX dynamic plugin target and has a CTest smoke
  that compiles with installed `rxc`, assembles with installed `rxas`, and runs
  with installed `rxvme`.

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

- Add FAISS behind the C ABI as an optional vector index dependency.
- Add embedding-provider adapters, starting local-first.
- Add stricter optional validation against named vocabularies when a profile
  wants it.
- Add CREXX profile scripts for ranking and query policies.
