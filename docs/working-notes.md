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
- Sources and chunks now carry `source_type`, `confidence`, `captured_at`,
  `event_start_at`, and `event_end_at`. `cprag_timeline`, CLI `timeline`, and
  MCP `library_timeline` expose the first source-level timeline. Lexical search
  applies confidence as a ranking weight.
- Search currently combines placeholder text-overlap entity anchors with SQLite
  FTS5 lexical chunk retrieval. `cprag_search_with_vector` adds lexical,
  vector, hybrid, and auto chunk retrieval modes while keeping graph expansion
  over text anchors for now.
- Optional FAISS support stores caller-provided chunk embeddings in SQLite,
  rebuilds a `vectors.faiss` sidecar for one active embedding model, profile,
  and dimension, and searches that sidecar by vector. FAISS is not an embedder;
  local/provider adapters must generate fixed-length vectors before the core
  can index them.
- Graph context is expanded with simple BFS over both incoming and outgoing
  edges.
- Graph query APIs include shortest path, typed subgraph extraction, and
  Graphviz DOT export from the native engine.
- Chunking is Qt-free and adapted from the useful CognitivePipelines chunking
  behavior: smart overlap, Markdown header/table awareness, and Rexx-friendly
  separators.
- `crexx-rag-mcp` is a hardened stdio MCP adapter with structured JSON parsing,
  JSON-RPC validation, central tool declarations, typed argument checks, and a
  read-only default. Mutating tools require `--allow-writes`. `library_search`
  accepts `mode=auto|lexical|vector|hybrid`; `auto` is the LLM default and only
  uses vector search when an active vector index and embedding command are
  configured.
- `crexx-rag embed-chunks` batch-generates chunk embeddings through an external
  command and rebuilds the FAISS sidecar. The command contract is provider
  neutral: print a JSON number array, or an object with an `embedding` array.
  The default `semantic-context-v1` profile renders an embedding envelope with
  source type, confidence, timeline fields, title, and chunk text.
- The first open local embedding provider path is llama.cpp `llama-server` with
  provider id `llama-server`. Its default base URL is
  `http://127.0.0.1:8081/v1`, overrideable via
  `CPRAG_LLAMA_SERVER_BASE_URL`. `scripts/setup_llama_cpp_embedder.sh` verifies
  or installs via Homebrew, and the C++ CLI helper
  `crexx-rag embed-llama-server` adapts the OpenAI-compatible response to the
  existing embedding-command contract without shelling through Python. Ollama
  remains supported through the same wrapper approach. `embed-chunks` retries
  provider failures by default. A deterministic llama-server HTTP 500 on long
  semantic envelopes is usually an input/context-size problem, not JSON
  escaping; start Nomic with an explicit context such as `-c 2048`, or use
  `raw-text-v1` for first-pass embedding of large plain-text corpora.
- `rx_rag.rxplugin` publishes Level G native signatures through RXPA.
- `crexx/cprag.crexx` is the first CREXX Level G wrapper surface. It exposes
  `cprag.raglibrary`, keeps JSON as the interchange format, and uses CREXX
  `rxjson` helpers for JSON-aware convenience methods. Timeline, vector status,
  embedding input rendering, add-chunk-embedding, rebuild, and vector-search
  calls are exposed through the wrapper with comma-separated float vectors.
  Wrapper method names avoid raw plugin-name collisions: `timelineJson`,
  `vectorStatusJson`, `chunkEmbeddingInput`, `attachChunkEmbedding`,
  `buildVectorIndex`, and `searchVector`.
- The first executable CREXX domain extractor is
  `crexx/profiles/history/deterministic_extract.crexx`. It iterates stored
  chunks through native chunk id/text helpers, applies a generic
  mention/evidence pass, applies hand-tunable CREXX cue rules for Scotland and
  Athens, and writes typed node/relationship candidates back through the engine.
  The engine owns node/edge de-duplication, traversal, and DOT export; the CREXX
  profile owns extraction policy. It now also demonstrates an in-run profile
  context: an accepted candidate can teach the deterministic pass a canonical
  concept id and spelling aliases for later chunk calls.
- `cprag_list_concepts` and `cprag_match_concepts` expose the stored graph as a
  cheap known-concept vocabulary. They return canonical ids, node types, labels,
  and matched aliases from labels plus metadata `aliases`, and are available
  through CLI commands `list-concepts` / `match-concepts` and CREXX functions
  `rxrag.listconcepts` / `rxrag.matchconcepts`.
- `docs/graph-retrieval-methodology.md` records the retrieval argument: graph
  search should add typed, evidence-backed jumps rather than duplicate keyword
  or vector search. CREXX triage should ask whether a chunk is likely to create
  useful graph structure, then choose skip, deterministic write, small/medium
  model, or Gemma.
- `crexx-rag extract-llama-server` is the first local LLM extraction adapter.
  It calls llama.cpp's OpenAI-compatible chat endpoint and returns candidate
  node/relationship JSON only. CREXX profiles decide whether to call it never,
  always, or only for ambiguous rule hits, then validate and write accepted
  candidates through the same graph API.
- `crexx-rag advise-llama-server` is the cheap local LLM advisory adapter. It
  uses the same llama.cpp chat endpoint but deliberately avoids JSON for dumb
  triage tasks. Supported tasks are `proper-nouns`, `value`, `route`,
  `relation`, `alias`, and `complexity`; outputs are normalized to short values
  such as comma-separated names, `0..5`, `yes`, `no`, `low`, `medium`, `high`,
  `skip`, `deterministic`, `gemma-advice`, and `gemma-extract`. The default
  advisory endpoint is
  `http://127.0.0.1:8084/v1`, intended for Qwen2.5 3B, with
  `CPRAG_LLAMA_SERVER_ADVICE_BASE_URL` and `CPRAG_LLM_ADVICE_MODEL` overrides.
- `crexx/profiles/history/hybrid_ingest_extract.crexx` strings together the
  first end-to-end ingestion/extraction pipeline. It now has a three-stage
  proof shape: Stage 1 runs a cheap candidate census/ranker, Stage 2 writes
  mention/evidence links plus deterministic or LLM-gated typed edges, and Stage
  3 lists ambiguity/fixup nodes for revisit with broader graph context. The
  intended corpus-scale shape now inserts a candidate collation/adjudication step
  between Stage 1 and extraction: aggregate names, classify keep/junk/ambiguous
  and likely type, feed that registry back into chunk scoring, graph-rank the
  shortlist, then spend Gemma-class extraction only where relationship utility is
  likely. Ambiguous aliases such as `Sutherland` create explicit `ambiguity`
  nodes and `candidate-for` edges instead of forcing an early interpretation. The
  repeatable CTest proof runs in `--mode offline`; online mode uses the same
  CREXX gate and graph-write validators but calls local `llama-server` adapters.
- The Scottish full Stage 1 experiment processed 5,977 chunks with Qwen2.5 3B
  on port 8084 in about 96.6 minutes. It produced 6,358 distinct candidate
  strings from 20,697 mentions; 3,854 appeared once, 344 appeared at least ten
  times, 140 appeared at least twenty times, and 43 appeared at least fifty
  times. This supports the census/adjudication design: the raw candidate stream
  is useful but noisy, and should seed a registry plus ignore list before
  expensive extraction.
- Repeated typed edges are no longer overwritten in the native core. Adding the
  same source, target, relationship type, and label accumulates
  `support_count`, appends to `support_evidence`, stores `last_support`, and
  keeps the strongest weight. This is the initial hardening needed before
  evidence scoring and disambiguation become more ambitious.
- Chunk-vector neighborhoods should be used as ranking and coverage evidence,
  not as typed truth. A vector-near chunk can help detect redundancy, related
  context, or a bridge between graph communities, but deterministic rules or
  accepted LLM extraction must create typed relationships.
- The preferred programmer surface is one operation vocabulary with multiple
  bindings: native C/C++ helpers, CLI commands for humans and scripts, CREXX
  functions, CREXX address-environment commands, and MCP adapters when useful.
  This avoids duplicating pipeline logic while still giving CREXX profile authors
  a pleasant command-style orchestration surface.
- Pipeline logic and hot paths should prefer CREXX and C++. Python can remain an
  optional user or research tool, but the repeatable ingestion/extraction path
  should not depend on shelling through Python when CREXX, C++, or direct
  CLI/address-environment calls are practical.
- Incremental ingestion is a first-class use case. New sources should first
  match the existing concept/alias registry, adjudicate only deltas, and extract
  only where the new material adds evidence, relationships, or graph bridges.
  External LLM workflows should be able to push proposed concepts/relationships
  with provenance into the same evidence/de-duplication path.
- Background enhancement should be a budgeted work queue over explicit reasons
  such as ambiguity, weak but valuable edges, sparse concept communities, new
  aliases, vector-near bridge candidates, or low-confidence external pushes.
- The CREXX smoke compiles `cprag.crexx`, compiles the profile against it,
  assembles both modules with installed `rxas`, and runs with installed
  `rxvme`.
- CREXXSAA cache maintenance uses `crexxsaa --clear`. The CTest path still uses
  explicit `rxc`/`rxas`/`rxvme` so it proves the installed compiler and VM
  directly.

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

- Continue enriching local-first embedding-provider adapters. llama.cpp
  `llama-server` is the first documented open local provider, and Ollama remains
  a valid provider when an embedding-capable model is installed. The core should
  stay provider-neutral.
- Extend the hybrid extractor beyond the first proof. The current profile has
  candidate validation/application helpers and proves the Qwen2.5-to-Gemma
  routing shape, but the next major step is to make candidate collation,
  LLM-assisted candidate adjudication, graph/vector ranking, and extraction queue
  persistence first-class operations.
- Add the CREXX address environment for RAG/model operations so profiles can call
  the same operations exposed by the CLI without hand-building shell pipelines.
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
