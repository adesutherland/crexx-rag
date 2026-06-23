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
   graph/doc chunks     planned
```

## Native Core

The native core exposes only C types through `include/crexx_rag/ragcore.h`.
SQLite, C++ containers, FAISS, and graph internals stay hidden.

Current capabilities:

- initialize a shareable `.cprag` library bundle
- chunk plain text, Markdown, and Rexx-oriented text without Qt
- ingest text sources into persistent document and chunk tables
- list ingested sources
- add/update entities
- add edges
- perform naive text anchor search over entities
- perform SQLite FTS5 lexical search over chunks
- expand anchors through k-hop graph traversal
- return JSON suitable for CLI, CREXX, or MCP wrappers

## Graph Layer

The graph layer is a typed relationship map, not merely adjacency around search
hits. The first target domain is an IT architecture view of the world, probably
using an ArchiMate-inspired vocabulary. Nodes should carry explicit architectural
types such as component, service, capability, data object, technology node, or
deployment target. Edges should carry relationship semantics such as depends-on,
realizes, serves, accesses, flows-to, composed-of, or deployed-on.

Those type semantics belong in the native model because they affect retrieval,
expansion, filtering, ranking, and explanation. CREXX/profile scripts may choose
which vocabularies and policies to prefer for a workload, but the core should
preserve and expose node and relationship types consistently.

The first implementation remains deliberately small:

- entities are nodes
- edges are directed relationships
- current entity and edge labels are the first type surface
- expansion traverses both incoming and outgoing edges
- relation filters are optional
- BFS controls hop depth

This covers the useful part of the local GraphRAG pattern without committing to
a graph database too early.

The model should stay domain-neutral enough to describe non-IT maps, including
materials, processes, and other structured knowledge domains, while keeping the
architecture relationship map as the guiding use case.

## Next Dependency: FAISS

FAISS should be added behind the C ABI as an optional native dependency.
Expected files inside a library bundle:

```text
library.cprag/
  manifest.json
  library.sqlite
  vectors.faiss
```

SQLite should remain the source of truth for ids, metadata, document chunks, and
graph structure. FAISS should hold vector ids that map back through SQLite chunk
rows.
