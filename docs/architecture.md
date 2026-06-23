# Architecture

`crexx-rag` is designed as a small native core with multiple frontends.

```text
Codex / MCP clients
        |
        v
crexx-rag-mcp
        |
        v
CREXX scripts / profiles ---> rx_rag.rxplugin
        |                         |
        +-------------------------+
                  |
                  v
              cprag_core
                  |
       +----------+----------+
       |                     |
   SQLite metadata      FAISS vectors
   entities/edges       planned
```

## Native Core

The native core exposes only C types through `include/crexx_rag/ragcore.h`.
SQLite, C++ containers, FAISS, and graph internals stay hidden.

Current capabilities:

- initialize a shareable `.cprag` library bundle
- chunk plain text, Markdown, and Rexx-oriented text without Qt
- add/update entities
- add edges
- perform naive text anchor search
- expand anchors through k-hop graph traversal
- return JSON suitable for CLI, CREXX, or MCP wrappers

## Graph Layer

The first graph layer is deliberately small:

- entities are nodes
- edges are directed relationships
- expansion traverses both incoming and outgoing edges
- relation filters are optional
- BFS controls hop depth

This covers the useful part of the local GraphRAG pattern without committing to
a graph database too early.

## Next Dependency: FAISS

FAISS should be added behind the C ABI as an optional native dependency.
Expected files inside a library bundle:

```text
library.cprag/
  manifest.json
  library.sqlite
  vectors.faiss
```

SQLite should remain the source of truth for ids, metadata, and graph structure.
FAISS should hold vector ids that map back through SQLite.
