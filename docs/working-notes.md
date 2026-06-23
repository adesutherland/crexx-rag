# Working Notes

These notes capture the current project context for future agents and
contributors.

## Purpose

`crexx-rag` is a lightweight local GraphRAG component for CREXX, Codex, and
plain command-line workflows. The core should stay native and reusable; CREXX
should provide tunable retrieval profiles; MCP should provide agent access.

## Current Implementation

- `cprag_core` exposes a stable C ABI in `include/crexx_rag/ragcore.h`.
- SQLite stores entities and edges in a shareable `.cprag` folder bundle.
- Search is currently a placeholder text-overlap scorer.
- Graph context is expanded with simple BFS over both incoming and outgoing
  edges.
- Chunking is Qt-free and adapted from the useful CognitivePipelines chunking
  behavior: smart overlap, Markdown header/table awareness, and Rexx-friendly
  separators.
- `crexx-rag-mcp` is a minimal stdio MCP server scaffold.
- `rx_rag.rxplugin` is the CREXX dynamic plugin target.

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

Record CREXX packaging/API issues in `docs/crexx-integration-issues.md`.

## Next Steps

- Add document/chunk tables and ingestion commands.
- Add FAISS behind the C ABI as an optional vector index dependency.
- Add embedding-provider adapters, starting local-first.
- Expand MCP tools around ingest, source listing, and graph expansion.
- Add CREXX profile scripts for ranking and query policies.
