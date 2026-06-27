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
- `crexx/profiles/pipeline_profile.crexx`: the shared CREXX profile contract
  for vocabulary, filters, cue words, validation, and default profile ids.

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
  --batch-size 2048 \
  --ubatch-size 1024 \
  --host 127.0.0.1 \
  --port 8081

./cmake-build-faiss/crexx-rag embed-chunks \
  ./example.cprag \
  nomic-embed-text-v1.5 \
  llama-server
```

The explicit context size is useful with `semantic-context-v1`, which embeds a
small provenance envelope around each chunk. If a large corpus trips a
deterministic llama-server 500 on long inputs, first check the llama.cpp server
log for `input ... is too large to process`. The Nomic Scotland run needed
`--ubatch-size 1024`; the default start wrapper now uses that value.
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
LLM-assisted graph extraction. It does not write to the graph. It can return
candidate JSON (`--format json`) or a simpler tagged line format
(`--format tagged`), so CREXX/profile code can decide whether to call it
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
printf '%s\n' \
  "The Macnicols held lands in Assynt and were connected with Sutherland." |
./cmake-build-debug/crexx-rag extract-llama-server --stdin \
  --profile scotland \
  --format tagged \
  --model ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M
```

Tagged output is preferred for bulk local extraction because small local LLMs
often accept JSON instructions better than they emit JSON. The tagged shape is:

```text
NODE|id|node_type|label|confidence|evidence|aliases
EDGE|source_id|relationship_type|target_id|confidence|label|evidence
```

Use `--format json` when a workflow specifically wants candidate JSON shaped as
`{"nodes":[],"relationships":[]}`. CREXX controllers should treat both formats
as proposals: validate node types, relationship types, endpoints, confidence,
and evidence before writing through the native graph APIs.

Use `--dry-prompt` to inspect the exact prompt without touching a server.
For CREXX/profile controllers, prefer `--stdin` for chunk text so punctuation,
quotes, and long passages do not have to survive shell-style command quoting.
Defaults are `CPRAG_LLAMA_SERVER_CHAT_BASE_URL=http://127.0.0.1:8080/v1`,
`CPRAG_LLM_MODEL=ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M`,
`CPRAG_LLM_EXTRACT_FORMAT=json`, `CPRAG_LLM_TEMPERATURE=0.1`, and
`CPRAG_LLM_MAX_TOKENS=2048`. Gemma E4B can spend a noticeable number of tokens
internally before returning final output, so very small `--max-tokens` values may
fail with no final content.

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
printf '%s\n' "The Mackays fought the Sutherlands at Dingwall." |
./cmake-build-debug/crexx-rag advise-llama-server --stdin \
  --task route \
  --profile scotland \
  --context "known=Clan Sutherland score=18"
```

Supported advisory tasks are `proper-nouns`, `candidate-adjudication`, `value`,
`route`, `relation`, `alias`, and `complexity`. `proper-nouns` returns a
comma-separated name list for Stage 1 prioritisation. `candidate-adjudication`
returns one pipe-separated classification line for Stage 1b:
`status|type|canonical_label|aliases|disambiguation|confidence`. The others
normalize to small strings such as `0..5`, `yes`, `no`, `low`, `medium`, `high`,
`skip`, `deterministic`, `gemma-advice`, or `gemma-extract`. This keeps the cheap
Qwen2.5-style step simple enough for CREXX policy code. Defaults are
`CPRAG_LLAMA_SERVER_ADVICE_BASE_URL=http://127.0.0.1:8084/v1` and
`CPRAG_LLM_ADVICE_MODEL=Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M`; both can be
overridden with environment variables or CLI flags.

When called from CREXX, the profile uses direct `ADDRESS COMMAND` with stdin
and captured stdout/stderr arrays. Clear captured arrays with `arraydrop` before
reuse; Stage 1/1b data should be read back from `candidate_mentions` and
`candidate_adjudications`, not scraped from progress logs.

The first end-to-end profile is
[`crexx/profiles/history/hybrid_ingest_extract.crexx`](crexx/profiles/history/hybrid_ingest_extract.crexx).
It ingests text, chunks it through the native engine, seeds a small profile
vocabulary, matches known concepts with `matchconcepts`, writes deterministic
mention and relationship edges, and points toward this staged policy. The
profile-specific knobs used by the staged controllers live in
[`crexx/profiles/pipeline_profile.crexx`](crexx/profiles/pipeline_profile.crexx):
default profile ids, graph namespaces, seed vocabulary, node/relationship
filters, cue words, candidate typing, ambiguity decisions, and concept id shape.
The native core remains the durable engine for chunks, candidate tables, graph
writes, support accumulation, queues, and search.

```text
Stage 0  -> ingest/chunk/store sources with provenance
Stage 1  -> run a cheap candidate census over chunks
Stage 1b -> collate/adjudicate candidate names into keep/junk/ambiguous/types
Stage 2  -> seed mention/co-occurrence graph
Stage 2b -> rank chunks/concepts into a durable extraction queue
Stage 3  -> extract typed edges from the ranked queue
Stage 4  -> revisit ambiguity nodes and other fixup candidates
```

The current executable proof implements this shape for the generic baseline and
the Scotland demonstrator. Stage 1 can run deterministically or ask the fast
Qwen2.5-style advisory model for proper nouns. The raw output is a census, not
truth: collate it by normalized candidate, count support, classify likely
junk/good/ambiguous names and types, then feed that registry back into chunk
scoring. Stage 2/3 extraction should spend Gemma-class calls only on chunks
whose adjudicated concepts, graph position, relation cues, or vector
neighborhoods suggest useful typed relationships.

The handoff is now durable. Stage 1 writes candidate mentions into the native
`candidate_mentions` table. Stage 1b reads the collated census, writes
`candidate_adjudications`, and is available as
[`crexx/profiles/history/stage1b_adjudicate_candidates.crexx`](crexx/profiles/history/stage1b_adjudicate_candidates.crexx).
It can run offline with simple heuristics or online through the
`candidate-adjudication` llama-server advice task.

Stage 2 is also a CREXX-controlled stage, but it uses a native page helper for
the hot graph writes. The controller
[`crexx/profiles/history/stage2_seed_graph.crexx`](crexx/profiles/history/stage2_seed_graph.crexx)
chooses status/type filters, minimum support, namespace, cursor, and page size,
then calls `seed-candidate-graph` / `rxrag.seedcandidategraph(...)` to write
concept nodes, `evidence-chunk` nodes, and `mentioned-in` support edges in one
transaction per page. Replays are safe: existing `candidate_mention_id` support
is counted as `skipped_replay`, not added again.

Stage 2b turns the seeded graph into a Stage 3 work queue. The controller
[`crexx/profiles/history/stage2b_rank_queue.crexx`](crexx/profiles/history/stage2b_rank_queue.crexx)
calls `build-extraction-queue` / `rxrag.buildextractionqueue(...)`, which scores
chunks by concept count, type diversity, relation cues, rare concepts,
ambiguity risk, and support count. It also applies a small text-shape penalty
for heading lists, footnote-heavy chunks, illustration captions, and very short
chunks, plus an evidence-class penalty for index/table-of-contents, caption,
and footnote-shaped passages, so dense locators do not crowd out narrative
evidence. The queue is stored in the generic `work_queue` table with
`item_type=chunk-extraction`, reasons, scores, pending status, and metadata such
as `evidence_class`, `directness`, and source directness. Queue builds skip
chunks that already have
`processed` or `skipped` extraction attempts for the same profile, so a
background improvement run naturally advances to unprocessed chunks unless the
operator explicitly clears or changes the history.

Stage 3 is a CREXX controller:
[`crexx/profiles/history/stage3_extract_queue.crexx`](crexx/profiles/history/stage3_extract_queue.crexx).
It consumes pending queue rows, calls the local LLM adapter, validates proposals,
writes accepted graph facts, and records every attempt in `work_attempts`. Its
default extraction format is tagged lines; JSON remains selectable with
`--format json` for comparison or repair experiments.

For operators and future agents, the repeatable surface is the staged runner:

```bash
scripts/run_history_pipeline.sh \
  --library ./history-stage2.cprag \
  --profile scotland \
  --stages stage2b,stage3,status \
  --mode online \
  --queue-id stage3-scotland-default \
  --stage2b-limit 100 \
  --stage3-limit 25
```

The runner compiles the shared `pipeline_profile` module plus the requested
CREXX controllers with the installed `rxc`/`rxas`, runs them through `rxvme`,
captures logs under `.local/history-pipeline/`, and calls the same native/CLI
operations documented below. It is orchestration glue, not a second
implementation. Use `--stages status` for a read-only summary and
`--stages stage1,embed,stage1b,stage2,stage2b,stage3,status` for a full
source-to-queue run. Stage 1 requires `--source-file`; preloaded libraries can
start at Stage 1b or later.

`generic` is now the baseline profile path and is covered by CTest. It uses the
same controllers as Scotland with neutral service/data-object/component
vocabulary:

```bash
scripts/run_history_pipeline.sh \
  --library ./generic-demo.cprag \
  --profile generic \
  --stages stage1,stage1b,stage2,stage2b,stage3,status \
  --mode offline \
  --source-file tests/fixtures/generic-it.txt \
  --stage1-chunk-limit 2 \
  --stage1b-min-count 1 \
  --stage2b-limit 5 \
  --stage3-limit 2 \
  --stage3-mode dry-run \
  --no-require-models
```

For budgeted improvement runs, use the single-worker wrapper:

```bash
scripts/run_background_improvement.sh \
  --library ./generic-demo.cprag \
  --profile generic \
  --queue-id improve-generic \
  --stage2b-limit 20 \
  --stage3-limit 5 \
  --stage3-mode dry-run \
  --max-cycles 1 \
  --no-require-models
```

The background worker intentionally reuses `run_history_pipeline.sh` and takes
an atomic filesystem lock. It is safe as one foreground worker. Do not run
multiple queue readers until native claim/lease semantics are added.

Queue observability is first-class:

```bash
./cmake-build-debug/crexx-rag queue-status \
  ./history-stage2.cprag \
  history.scotland.hybrid.v1 \
  stage3-scotland-default
```

`queue-status` is read-only and summarizes `work_queue` item counts plus
`work_attempts` counts, accepted node/relationship totals, and the latest
attempt id/time. The same operation is available to CREXX as
`rxrag.queuestatus(...)` and `cprag.raglibrary.queueStatusJson(...)`.

Generic work queues can also be inspected and consumed directly:

```bash
./cmake-build-debug/crexx-rag work-queue \
  ./history-stage2.cprag \
  history.scotland.hybrid.v1 \
  fixup \
  endpoint-resolution \
  pending \
  20

./cmake-build-debug/crexx-rag resolve-work-queue \
  ./history-stage2.cprag \
  history.scotland.hybrid.v1 \
  fixup \
  endpoint-resolution \
  20 \
  apply
```

`resolve-work-queue` currently consumes `endpoint-resolution`,
`ambiguity-review`, `type-review`, and `external-extraction-review` items.
Endpoint resolution only writes a typed edge when both endpoint ids already
exist and the item supplies a relationship type. Ambiguity review creates or
refreshes an explicit `ambiguity` node and `candidate-for` links to known
candidate concepts. Type review updates an existing entity's `node_type` while
preserving its label and description. External extraction review promotes one
pre-normalized external node proposal, edge proposal, or node-plus-edge
proposal through the same native graph upsert/support path. Omitting `apply`
performs a non-mutating preview.

Before online stages, use the local model lifecycle wrappers:

```bash
scripts/start_local_llama_servers.sh
scripts/status_local_llama_servers.sh --smoke --require embedding --require chat
scripts/stop_local_llama_servers.sh
```

`status_local_llama_servers.sh` checks PID files, listening ports, `/v1/models`,
and optional embedding/chat smoke calls. Long-running ingestion should rely on
these detached wrappers, which write logs to `.local/llama-servers/`, rather
than leaving chatty `llama-server` processes attached to a foreground terminal.

The first real Scotland Stage 3 batch processed 100 queued chunks with one local
Gemma E4B worker in about 83 minutes. It recorded 99 `processed`, 1 `skipped`,
and 0 `failed` attempts, accepting 981 node proposals and 316 relationship
proposals before native upsert/support merging. This is useful but clearly a
background workload: future workers should use generic queue claim/lease
semantics before multiple readers are allowed.

The same run seeded the first endpoint-resolution follow-up queue from rejected
but plausible tagged edge proposals. Those items can now be consumed through the
generic `resolve-work-queue` endpoint-resolution consumer after inspection. The
combined two-volume Scotland corpus has also been embedded with llama.cpp/Nomic
through the FAISS build:
11,684 chunks, 768-dimensional vectors, and an active `vectors.faiss` L2 index.

The operational shape is now:

```text
initial load        -> build the first graph and extraction queue
background improve  -> review ambiguity, weak edges, rejected proposal classes,
                       and sparse graph areas
add more documents  -> reuse the concept/alias registry and queue only deltas
search              -> combine lexical, vector, graph, support, and provenance
```

Ambiguous aliases such as `Sutherland` are represented explicitly by creating an
`ambiguity` node and `candidate-for` edges to possible concepts. Clear aliases
such as `Sutherlands` still produce ordinary `mentioned-in` links. Repeated
assertions of the same typed edge are merged by the native core with
`support_count`, `support_evidence`, and `last_support` metadata.
Edges and evidence chunks carry `directness` and `evidence_class` metadata so
ranking and answer wrappers can prefer narrative claims and accepted typed edges
over index rows, captions, and mention-only leads.

Vectors influence the extraction queue but do not create typed facts directly. A
vector-near chunk can indicate redundancy, related context, or a bridge between
graph communities; deterministic rules or accepted LLM extraction still need to
earn relationship edges.

Run the repeatable offline proof with CTest:

```bash
ctest --preset debug -R crexx_hybrid_extractor_smoke --output-on-failure
ctest --preset debug -R crexx_generic_pipeline_smoke --output-on-failure
```

See [`docs/pipeline-status.md`](docs/pipeline-status.md) for implemented versus
planned pipeline status, and [`docs/test-strategy.md`](docs/test-strategy.md)
for acceptance criteria. Executable operator/agent workflows are in
[`docs/use-cases.md`](docs/use-cases.md).

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

`library_answer_evidence` is the preferred LLM-facing QA tool. It accepts a
natural-language `question`, runs source-bound search, and returns a compact
evidence bundle with retrieval-plan hints, retrieved chunks, accepted typed graph
claims, graph-only leads, and answer guidance. An agent should answer from that
bundle and cite chunk ids; `mentioned-in` paths are leads, not claims. The
bundle prefers stored `directness` and `evidence_class` metadata and falls back
to conservative heuristics when older graph data lacks those fields.

`library_search` remains the lower-level diagnostic read tool. It accepts `mode`
as `auto`, `lexical`, `vector`, or `hybrid`; default `auto` falls back to lexical
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
- `rxrag.clearcandidatecensus(path, profile_id, source_uri)`
- `rxrag.addcandidatemention(path, profile_id, source_uri, chunk_id, candidate, normalized_candidate, priority, proper_count, known_count, cue_count, stage, extractor, metadata_json)`
- `rxrag.candidatecensus(path, profile_id, source_uri, min_count, limit)`
- `rxrag.pendingcandidatecensus(path, profile_id, source_uri, min_count, limit)`
- `rxrag.adjudicatecandidate(path, profile_id, normalized_candidate, status, candidate_type, canonical_label, aliases, disambiguation, confidence, adjudicator, metadata_json)`
- `rxrag.candidateadjudications(path, profile_id, status_filter, limit)`
- `rxrag.candidatementionevidence(path, profile_id, status_filter, type_filter_csv, min_count, after_id, limit)`
- `rxrag.seedcandidategraph(path, profile_id, graph_namespace, status_filter, type_filter_csv, min_count, after_id, limit)`
- `rxrag.buildextractionqueue(path, profile_id, queue_id, graph_namespace, node_type_filter_csv, limit)`
- `rxrag.extractionqueue(path, profile_id, queue_id, status_filter, limit)`
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
`searchVector()`, `graphDot()`, `chunkEmbeddingInput()`,
`clearStage1Census()`, `recordCandidateMention()`,
`candidateCensusJson()`, `pendingCandidateCensusJson()`,
`saveCandidateAdjudication()`, `candidateAdjudicationsJson()`,
`candidateMentionEvidenceJson()`, `seedCandidateGraphJson()`,
`buildExtractionQueueJson()`, and `extractionQueueJson()` to avoid colliding
with raw imported plugin function names.

Executable CREXX domain profiles can iterate stored chunks with `chunkIdCsv()`
and `storedChunkText()`, extract candidate concepts and relationships, and call
the native engine to add or update nodes and edges. The engine owns
de-duplication, traversal, search, and DOT export. The legacy deterministic demo
is
[`crexx/profiles/history/deterministic_extract.crexx`](crexx/profiles/history/deterministic_extract.crexx),
covered by `crexx_deterministic_extractor_smoke`; keep it for comparison and
cheap graph/DOT/path coverage, but use `pipeline_profile.crexx` plus the staged
controllers for new profile work.

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
