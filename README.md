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
nodes, typed relationships, source provenance, timeline fields, and confidence
ratings are fundamental to the native core rather than presentation-layer
concerns.

The initial architecture keeps the hot path native and the tunable policy layer
scriptable:

- `cprag_core`: C/C++ library with a stable C ABI.
- `crexx-rag`: command-line tool for local use and smoke testing.
- `crexx-rag-mcp`: stdio MCP server starter for Codex and other MCP clients.
- `rx_rag.rxplugin`: CREXX `rxpa` dynamic plugin exposing native functions.
- `cprag.crexx`: Level G CREXX wrapper for profiles and policy scripts.

A plain-English explanation of the major pieces and why they fit together is in
[`docs/how-it-fits-together.md`](docs/how-it-fits-together.md). It covers
chunks, lexical search, embeddings, FAISS, typed relationships, provenance,
CREXX, and MCP without assuming GraphRAG expertise.
Concrete domain-profile examples for Scotland and Athens are in
[`docs/domain-profiles.md`](docs/domain-profiles.md).

The first implementation uses SQLite for a shareable local library bundle and a
small built-in graph traversal layer. It stores both the typed relationship map
and persistent document chunks, with SQLite FTS5 providing the first local
lexical retrieval path. It also ports the useful chunking ideas from
CognitivePipelines into a Qt-free native chunker for plain text, Markdown, and
Rexx-oriented source. Optional FAISS support adds a rebuildable `vectors.faiss`
sidecar for chunk vector search when callers provide embeddings.

Local embedding providers are adapter-level configuration, not native-core
dependencies. The first open local setup path is llama.cpp `llama-server`,
documented in [`docs/local-embeddings.md`](docs/local-embeddings.md), using the
provider id `llama-server` and the default base URL
`http://127.0.0.1:8081/v1`. Set `CPRAG_LLAMA_SERVER_BASE_URL` to point wrappers
at a different local endpoint. Ollama remains supported through the same
external embedding-command contract.

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
The initial typed architecture vocabulary is documented in
[`docs/architecture-vocabulary.md`](docs/architecture-vocabulary.md).

FAISS is optional and off by default. To build the FAISS-backed vector path,
install FAISS and configure with:

```bash
cmake -S . -B cmake-build-faiss -G Ninja -DCPRAG_ENABLE_FAISS=ON
cmake --build cmake-build-faiss
ctest --test-dir cmake-build-faiss --output-on-failure
```

The vector milestone is bring-your-own embeddings at the core boundary: FAISS
does not create embeddings, it indexes and searches fixed-length numeric
vectors. The core stores chunk embedding vectors in SQLite, rebuilds
`vectors.faiss` from that metadata, and searches the sidecar. CLI and MCP
adapters can call an external embedding command for local-first vector
generation.

Source provenance and timeline context are first-class retrieval metadata. Text
sources can carry `source_type`, `confidence`, `captured_at`, `event_start_at`,
and `event_end_at`; chunks inherit those fields, search results return them, and
lexical ranking applies the confidence value as a trust weight. `timeline`
provides the first source-level chronological view.

## CLI Sketch

```bash
./cmake-build-debug/crexx-rag init ./example.cprag
./cmake-build-debug/crexx-rag add-entity-typed ./example.cprag entity:auth service Authentication "Authentication service"
./cmake-build-debug/crexx-rag add-entity-typed ./example.cprag entity:db data-object PostgreSQL "PostgreSQL user database"
./cmake-build-debug/crexx-rag add-edge-typed ./example.cprag entity:auth entity:db accesses "Reads user profiles" 1.0
./cmake-build-debug/crexx-rag ingest-text ./example.cprag docs/auth.md "Auth notes" markdown 800 120 $'# Auth\n\nAuth depends on PostgreSQL.'
./cmake-build-debug/crexx-rag ingest-text ./example.cprag docs/decision.md "Decision note" plain 800 120 "The client confirmed the API database decision." '{}' decision-record 0.9 2026-06-24T09:00:00Z 2026-06-23T14:00:00Z
./cmake-build-debug/crexx-rag list-sources ./example.cprag
./cmake-build-debug/crexx-rag timeline ./example.cprag 20
./cmake-build-debug/crexx-rag list-chunks ./example.cprag docs/auth.md
./cmake-build-debug/crexx-rag vector-status ./example.cprag
./cmake-build-debug/crexx-rag shortest-path ./example.cprag entity:auth entity:db
./cmake-build-debug/crexx-rag export-dot ./example.cprag service,data-object accesses 20 > graph.dot
./cmake-build-debug/crexx-rag search ./example.cprag "what database does auth use" 3 2
```

With a FAISS-enabled build, callers can attach embeddings and rebuild/search the
sidecar:

```bash
./cmake-build-faiss/crexx-rag add-chunk-embedding ./example.cprag 1 test-model 1.0,0.0,0.0
./cmake-build-faiss/crexx-rag rebuild-vector-index ./example.cprag test-model
./cmake-build-faiss/crexx-rag vector-search ./example.cprag test-model 0.9,0.1,0.0 3
```

For ordinary local use, the CLI can embed all stored chunks by calling an
external command, then rebuild the FAISS sidecar. By default this uses the
`semantic-context-v1` embedding profile, which sends a stable envelope with
source type, confidence, timeline fields, title, and chunk text to the embedder:

```bash
./cmake-build-faiss/crexx-rag embed-chunks ./example.cprag test-model ./embed-text
./cmake-build-faiss/crexx-rag embed-chunks ./example.cprag test-model ./embed-text docs/auth.md
./cmake-build-faiss/crexx-rag embedding-text ./example.cprag 1 semantic-context-v1
```

The embedding command is invoked as:

```text
<embedding-command> <text> <embedding-model>
```

It must print either a JSON number array, such as `[0.1,0.2,0.3]`, or an object
with an `embedding` array. The CLI helper `crexx-rag embed-llama-server` adapts
llama.cpp `llama-server`'s OpenAI-compatible embeddings response to this shape
without shelling through Python:

```bash
llama-server \
  -hf nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M \
  --embedding \
  --pooling mean \
  -c 2048 \
  --host 127.0.0.1 \
  --port 8081

./cmake-build-faiss/crexx-rag embed-chunks \
  ./example.cprag \
  nomic-embed-text-v1.5 \
  llama-server
```

The explicit context size is useful with `semantic-context-v1`, which embeds a
small provenance envelope around each chunk. If a large corpus trips a
deterministic llama-server 500 on long inputs, either restart the server with a
larger `-c` value or run that source with `raw-text-v1` for the first pass.
Chunk embedding retries default to `CPRAG_EMBEDDING_RETRIES=3` and
`CPRAG_EMBEDDING_RETRY_DELAY_MS=500`.

For MCP query-time embeddings, use the query role so Nomic receives the
`search_query:` prefix:

```bash
./cmake-build-faiss/crexx-rag-mcp \
  --library ./example.cprag \
  --embedding-command "./cmake-build-faiss/crexx-rag embed-llama-server --role query" \
  --embedding-model nomic-embed-text-v1.5
```

Nomic expects `search_document: ...` for documents/chunks and
`search_query: ...` for queries; the wrapper applies those prefixes when
`--role document` or `--role query` is used. Ollama can still be used behind a
small wrapper when a local embedding-capable model is installed, but a general
chat model is not a substitute for a stable embedding model unless it exposes
consistent embedding vectors.

## Local LLM Extraction

`crexx-rag extract-llama-server` is the local llama.cpp chat adapter for
LLM-assisted graph extraction. It does not write to the graph. It returns
candidate JSON only, so CREXX/profile code can decide whether to call it
`never`, `always`, or only when deterministic cues need support.

Start a chat-capable `llama-server` separately, commonly on a different port
from the embedding server:

```bash
llama-server \
  -hf <chat-model-or-local-gguf> \
  -c 4096 \
  --host 127.0.0.1 \
  --port 8080
```

Then ask for extraction candidates:

```bash
./cmake-build-debug/crexx-rag extract-llama-server \
  --profile scotland \
  --model ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M \
  "The Macnicols held lands in Assynt and were connected with Sutherland."
```

The command returns a JSON object shaped as:

```json
{
  "nodes": [],
  "relationships": []
}
```

Use `--dry-prompt` to inspect the exact prompt without touching a server.
Defaults are `CPRAG_LLAMA_SERVER_CHAT_BASE_URL=http://127.0.0.1:8080/v1`,
`CPRAG_LLM_MODEL=ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M`,
`CPRAG_LLM_TEMPERATURE=0.1`, and `CPRAG_LLM_MAX_TOKENS=2048`. Gemma E4B can
spend a noticeable number of tokens internally before returning final JSON, so
very small `--max-tokens` values may fail with no final content.

For stored corpora, `extract-chunks-llama-server` runs the same adapter over a
bounded chunk range. It prints progress and elapsed milliseconds to stderr and
writes candidate JSON to stdout:

```bash
./cmake-build-debug/crexx-rag extract-chunks-llama-server ./athens.cprag \
  --source-uri examples/corpora/history/gutenberg-6156-athens-its-rise-and-fall.txt \
  --offset 1149 \
  --limit 2 \
  --profile athens \
  --model ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M
```

The intended hybrid profile keeps a CREXX context object between chunk calls.
If an LLM candidate teaches the profile that `Sutherland` is a clan, later
deterministic passes can reuse that learned alias and canonical id without
calling the LLM again. The C++ engine still owns graph writes and de-duplicates
nodes and relationships.

Profiles can also use the stored graph itself as a known-concept vocabulary:

```bash
./cmake-build-debug/crexx-rag list-concepts ./history.cprag clan,place
./cmake-build-debug/crexx-rag match-concepts ./history.cprag \
  "The Sutherlands held lands near Assynt." \
  clan,place
```

`match-concepts` returns canonical ids, node types, labels, and the matched
alias. CREXX can use that cheap result for triage before calling a local LLM.

`crexx-rag advise-llama-server` is the cheaper companion adapter for pipeline
triage. It asks a local chat model for one short answer rather than JSON:

```bash
./cmake-build-debug/crexx-rag advise-llama-server \
  --task route \
  --profile scotland \
  --context "known=Clan Sutherland score=18" \
  "The Mackays fought the Sutherlands at Dingwall."
```

Supported advisory tasks are `proper-nouns`, `value`, `route`, `relation`,
`alias`, and `complexity`. `proper-nouns` returns a comma-separated name list
for Stage 1 prioritisation; the others normalize to small strings such as
`0..5`, `yes`, `no`, `low`, `medium`, `high`, `skip`, `deterministic`,
`gemma-advice`, or `gemma-extract`. This keeps the cheap Qwen2.5-style step
simple enough for CREXX policy code. Defaults are
`CPRAG_LLAMA_SERVER_ADVICE_BASE_URL=http://127.0.0.1:8084/v1` and
`CPRAG_LLM_ADVICE_MODEL=Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M`; both can be
overridden with environment variables or CLI flags.

The first end-to-end profile is
[`crexx/profiles/history/hybrid_ingest_extract.crexx`](crexx/profiles/history/hybrid_ingest_extract.crexx).
It ingests text, chunks it through the native engine, seeds a small profile
vocabulary, matches known concepts with `matchconcepts`, writes deterministic
mention and relationship edges, and points toward this staged policy:

```text
Stage 0  -> ingest/chunk/store sources with provenance
Stage 1  -> run a cheap candidate census over chunks
Stage 1b -> collate/adjudicate candidate names into keep/junk/ambiguous/types
Stage 2  -> seed mention/co-occurrence graph and rank chunks/concepts
Stage 3  -> extract typed edges from the ranked shortlist
Stage 4  -> revisit ambiguity nodes and other fixup candidates
```

The current executable proof implements the front of this shape. Stage 1 can run
deterministically or ask the fast Qwen2.5-style advisory model for proper nouns.
The raw output is a census, not truth: collate it by normalized candidate, count
support, classify likely junk/good/ambiguous names and types, then feed that
registry back into chunk scoring. Stage 2/3 extraction should spend Gemma-class
calls only on chunks whose adjudicated concepts, graph position, relation cues,
or vector neighborhoods suggest useful typed relationships.

Ambiguous aliases such as `Sutherland` are represented explicitly by creating an
`ambiguity` node and `candidate-for` edges to possible concepts. Clear aliases
such as `Sutherlands` still produce ordinary `mentioned-in` links. Repeated
assertions of the same typed edge are merged by the native core with
`support_count`, `support_evidence`, and `last_support` metadata.

Vectors influence the extraction queue but do not create typed facts directly. A
vector-near chunk can indicate redundancy, related context, or a bridge between
graph communities; deterministic rules or accepted LLM extraction still need to
earn relationship edges.

Run the repeatable offline proof with CTest:

```bash
ctest --preset debug -R crexx_hybrid_extractor_smoke --output-on-failure
```

For a live local model experiment, run the compiled profile with `--mode online`
and pass `--cli ./cmake-build-debug/crexx-rag` plus any model/base-url overrides
needed for your running `llama-server` ports. Use `--offset` and `--limit` for
bounded corpus windows before attempting a full run.

If you use CREXXSAA for late-bound profile runs and suspect a stale compiled
profile, clear its cache with:

```bash
crexxsaa --clear
```

## MCP Direction

`crexx-rag-mcp` is deliberately a thin stdio adapter over `cprag_core`. It is
read-only by default and only advertises read tools unless started with explicit
write access:

```bash
./cmake-build-debug/crexx-rag-mcp --library ./example.cprag
./cmake-build-debug/crexx-rag-mcp --allow-writes --library ./example.cprag
```

The MCP adapter validates JSON-RPC request shape, tool names, argument objects,
required arguments, and argument types before calling the native core.

`library_search` is the main LLM-facing read tool. It accepts `mode` as
`auto`, `lexical`, `vector`, or `hybrid`; default `auto` falls back to lexical
search unless a compatible active vector index and embedding command are
available. Manual modes are intended for diagnostics and profiles, not ordinary
LLM use.

To enable query-time embeddings for automatic MCP hybrid search, start the MCP
server with an embedding command that prints a JSON number array, or an object
with an `embedding` array:

```bash
./cmake-build-faiss/crexx-rag-mcp \
  --library ./example.cprag \
  --embedding-command ./embed-query \
  --embedding-model test-model
```

## CREXX Direction

The richer user-facing surface should live in CREXX. MCP remains a thin
client-facing adapter over the same native core, while CREXX Level G scripts and
classes own profiles, retrieval policy, and higher-level orchestration.

The raw plugin exposes stateless path-based Level G functions:

- `rxrag.init(path)`
- `rxrag.addentity(path, id, label, description, metadata_json)`
- `rxrag.addentitytyped(path, id, node_type, label, description, metadata_json)`
- `rxrag.addedge(path, source_id, target_id, label, weight, metadata_json)`
- `rxrag.addedgetyped(path, source_id, target_id, relationship_type, label, weight, metadata_json)`
- `rxrag.ingest(path, source_uri, title, text, file_type, chunk_size, overlap, metadata_json, source_type, confidence, captured_at, event_start_at, event_end_at)`
- `rxrag.listsources(path)`
- `rxrag.timeline(path, limit)`
- `rxrag.listchunks(path, source_uri)`
- `rxrag.chunkids(path, source_uri)`
- `rxrag.chunktextbyid(path, chunk_id)`
- `rxrag.deletesource(path, source_uri)`
- `rxrag.vectorstatus(path)`
- `rxrag.embeddingtext(path, chunk_id, embedding_profile)`
- `rxrag.addchunkembedding(path, chunk_id, embedding_model, vector_csv, embedding_profile)`
- `rxrag.rebuildvectorindex(path, embedding_model, embedding_profile)`
- `rxrag.vectorsearch(path, embedding_model, vector_csv, top_k)`
- `rxrag.vocabulary()`
- `rxrag.search(path, query, top_k, hops)`
- `rxrag.expand(path, anchors_csv, hops)`
- `rxrag.shortestpath(path, source_id, target_id, relationship_filter_csv)`
- `rxrag.subgraph(path, node_type_filter_csv, relationship_type_filter_csv, limit)`
- `rxrag.exportdot(path, node_type_filter_csv, relationship_type_filter_csv, limit)`
- `rxrag.stats(path)`
- `rxrag.chunk(text, chunk_size, overlap, file_type)`

The first CREXX wrapper is `cprag.raglibrary` in
[`crexx/cprag.crexx`](crexx/cprag.crexx). It wraps the raw plugin calls as a
small class-shaped API and uses CREXX's `rxjson` helpers for JSON-aware
convenience methods such as `sourceCount()`. The native functions still return
JSON so the same ABI works for CLI, CREXX, and MCP. Vector methods use
comma-separated float strings at the CREXX boundary for now; embedding provider
adapters can replace that with a richer profile-level flow later. The wrapper
names are `vectorStatusJson()`, `attachChunkEmbedding()`, `buildVectorIndex()`,
`searchVector()`, `graphDot()`, and `chunkEmbeddingInput()` to avoid colliding
with raw imported plugin function names.

Executable CREXX domain profiles can iterate stored chunks with `chunkIdCsv()`
and `storedChunkText()`, extract candidate concepts and relationships, and call
the native engine to add or update nodes and edges. The engine owns
de-duplication, traversal, search, and DOT export. The first proof is
[`crexx/profiles/history/deterministic_extract.crexx`](crexx/profiles/history/deterministic_extract.crexx),
covered by `crexx_deterministic_extractor_smoke`.

The project should expose one operation vocabulary through several thin
surfaces. A command such as candidate collation, chunk ranking, embedding,
extraction push, or DOT export should have one implementation, then be available
through the CLI for humans/scripts, CREXX functions for direct profile code, a
CREXX address environment for command-style orchestration, and MCP only where a
client adapter is needed. The address environment is a programmer-experience
surface over the same operations, not a separate shell-script pipeline.

The CREXX dynamic plugin smoke is part of the debug test preset when the
installed `rxc`, `rxas`, and `rxvme` are available:

```bash
ctest --preset debug -R crexx_profile_smoke --output-on-failure
ctest --preset debug -R crexx_deterministic_extractor_smoke --output-on-failure
```

## Status

This is a scaffold, not a finished RAG engine. The current search is intentionally
simple: text-overlap anchors over entity ids, labels, and descriptions, plus
SQLite FTS5 over persisted chunks. The graph layer now has explicit node and
relationship types, shortest path, typed subgraph extraction, and source/chunk
maintenance APIs, plus provenance, confidence, and timeline fields for sources
and chunks. The vector layer stores caller-provided chunk embeddings with an
embedding profile and can use FAISS for local vector search when enabled. MCP
has a small external embedding-command hook for automatic hybrid search; the
next major piece is hybrid ranking policy in CREXX/profile code.
