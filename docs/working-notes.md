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
- `crexx/profiles/history/deterministic_extract.crexx` is now a legacy
  deterministic demo/comparison smoke. It iterates stored chunks through native
  chunk id/text helpers, applies a generic mention/evidence pass, applies
  hand-tunable CREXX cue rules for Scotland and Athens, and writes typed
  node/relationship candidates back through the engine. Keep it for cheap
  coverage of graph writes, shortest paths, concept matching, and DOT export,
  but do not use it as the template for new production profiles. New staged work
  should use `pipeline_profile.crexx` plus the staged controllers.
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
- `docs/framework-closure-plan.md` records the generic end-to-end lifecycle
  needed to turn the Scotland experiment into a reusable framework: ingest,
  chunk, embed, candidate census/adjudication, mention graph seed, extraction
  queue, queued relationship extraction, fixup/review, source-bound QA,
  background improvement, and incremental reprocessing.
- `crexx-rag queue-status` and `rxrag.queuestatus(...)` are the first generic
  queue observability surface. Prefer them over direct SQLite polling during
  long runs. `scripts/run_history_pipeline.sh` composes the current history
  controllers into a repeatable staged run, and
  `scripts/status_local_llama_servers.sh` checks local model readiness before
  online stages.
- `crexx-rag extract-llama-server` is the first local LLM extraction adapter.
  It calls llama.cpp's OpenAI-compatible chat endpoint and returns candidate
  node/relationship JSON only. CREXX profiles decide whether to call it never,
  always, or only for ambiguous rule hits, then validate and write accepted
  candidates through the same graph API.
- `crexx-rag advise-llama-server` is the cheap local LLM advisory adapter. It
  uses the same llama.cpp chat endpoint but deliberately avoids JSON for dumb
  triage tasks. Supported tasks are `proper-nouns`, `candidate-adjudication`,
  `value`, `route`, `relation`, `alias`, and `complexity`; outputs are
  normalized to short values such as comma-separated names,
  `status|type|canonical_label|aliases|disambiguation|confidence`, `0..5`,
  `yes`, `no`, `low`, `medium`, `high`, `skip`, `deterministic`,
  `gemma-advice`, and `gemma-extract`. The default advisory endpoint is
  `http://127.0.0.1:8084/v1`, intended for Qwen2.5 3B, with
  `CPRAG_LLAMA_SERVER_ADVICE_BASE_URL` and `CPRAG_LLM_ADVICE_MODEL` overrides.
- The local LLM adapters accept `--stdin` so CREXX profiles can pass chunk text
  through `ADDRESS COMMAND ... input lines output out error err` instead of
  shell-quoting large or punctuation-heavy text. Stage 1a and Stage 1b use this
  path for online advice/extraction calls. The executable path is left unquoted,
  arguments are quoted, and stdout/stderr arrays are cleared with `arraydrop`
  before each command capture so stale rows cannot leak into later parsing.
- `crexx/profiles/history/hybrid_ingest_extract.crexx` strings together the
  first end-to-end ingestion/extraction pipeline, while
  `crexx/profiles/pipeline_profile.crexx` owns the shared profile policy for
  `generic`, `scotland`, and `athens`. The current staged shape is Stage 1
  candidate census, Stage 1b candidate adjudication, Stage 2 native mention graph
  seeding, Stage 2b native queue ranking, and Stage 3 gated extraction from the
  queue. Aggregate names, classify keep/junk/ambiguous and likely type, feed that
  registry back into chunk scoring, graph-rank the shortlist, then spend
  Gemma-class extraction only where relationship utility is likely. Ambiguous
  aliases such as `Sutherland` create explicit `ambiguity` nodes and
  `candidate-for` edges instead of forcing an early interpretation. The
  repeatable CTest proof runs in `--mode offline`; online mode uses the same
  CREXX gate and graph-write validators but calls local `llama-server` adapters.
- The Scottish full Stage 1 experiment processed 5,977 chunks with Qwen2.5 3B
  on port 8084 in about 96.6 minutes. It produced 6,358 distinct candidate
  strings from 20,697 mentions; 3,854 appeared once, 344 appeared at least ten
  times, 140 appeared at least twenty times, and 43 appeared at least fifty
  times. This supports the census/adjudication design: the raw candidate stream
  is useful but noisy, and should seed a registry plus ignore list before
  expensive extraction.
- Stage 1 handoff is now native. `candidate_mentions` stores profile id, source
  URI, chunk id, candidate/display name, normalized key, priority, proper-name
  count, known-concept count, cue count, extractor, and metadata. Stage 1b stores
  decisions in `candidate_adjudications`: status, likely type, canonical label,
  aliases, disambiguation, confidence, adjudicator, and metadata. These are
  exposed through C ABI calls, CLI commands, raw `rxrag.*` procedures, and
  `cprag.raglibrary` wrapper methods. The first Stage 1b controller is
  `crexx/profiles/history/stage1b_adjudicate_candidates.crexx`.
- Stage 1b should treat malformed advisory output as a normal local-model
  condition, not a fatal error. CREXX should validate the returned shape, clean
  simple punctuation/numeric mistakes deterministically, and optionally call a
  tiny "repair assist" prompt that reformats or reprocesses only the failed
  candidate before escalating to a stronger model.
- Stage 1b batching now works through the CREXX controller with a defensive
  parser and per-candidate repair fallback. On the Scotland volume 2 candidate
  census, lean Gemma E4B on port 8080 handled 16 high-frequency candidates with
  batch size 8 in about 19 seconds and with batch size 16 in about 31 seconds;
  batch size 4 was structurally clean but slower on that slice because it made
  more model calls. The observed quality is advisory rather than authoritative:
  Gemma tends to choose a single plausible type, so later ambiguity discovery and
  sense splitting remain required.
- Stage 1b must use pending/paged native census calls for corpus-scale runs.
  A full Scotland Vol 1+Vol 2 `min-count >= 5` census had 1,678 candidates; a
  single giant Rexx JSON payload made `rxvme` CPU-bound before the first LLM
  call. The countermeasure is `pending-candidate-census` /
  `rxrag.pendingcandidatecensus(...)` with small recoverable pages. On the
  combined Scotland pass, page size 64 and batch size 8 gave regular checkpoints
  and let the run resume naturally from `candidate_adjudications`.
- Stage 2 must also keep the hot write loop native. A first CREXX proof that
  fetched a page and called `addentitytyped` / `addedgetyped` per mention was
  correct but slow because each plugin call reopened and rewrote the library.
  The countermeasure is `seed-candidate-graph` /
  `rxrag.seedcandidategraph(...)`: Rexx chooses the profile, filters, cursor,
  and page size, while the core writes concept nodes, evidence-chunk nodes, and
  `mentioned-in` support edges in one transaction per page. Replaying a page
  detects already-recorded `candidate_mention_id` support and skips it instead
  of inflating counts.
- The combined Scotland Vol 1+Vol 2 Stage 2 run wrote to
  `cmake-build-debug/scotland-combined-stage2.cprag`, leaving the Stage 1
  library untouched. With `min-count >= 5`, status `keep`, and the accepted
  profile types, it processed 23,284 adjudicated mention rows in 46 pages. The
  resulting graph has 10,454 entities and 23,283 `mentioned-in` edges; the
  one-row difference is expected evidence accumulation where multiple mention
  rows support the same concept/chunk edge. A replay over the same cursor range
  saw all 23,284 rows and wrote zero new edges.
- Stage 2b now builds a durable extraction queue from the seeded graph. The
  native `build-extraction-queue` / `rxrag.buildextractionqueue(...)` helper
  ranks chunks by concept density, type diversity, relation cues, rare concepts,
  ambiguity risk, and support. It also subtracts a text-shape penalty for
  heading lists, footnote-heavy chunks, illustration captions, and very short
  chunks after the first Scotland queue showed table-of-contents and footnote
  chunks crowding the top ranks. On `scotland-combined-stage2.cprag`, queue
  `stage3-scotland-default` ranked 9,080 evidence chunks and wrote the top 100
  into generic `work_queue` rows with `item_type=chunk-extraction`. The native
  CLI build is sub-second on this host; the CREXX controller with a 20-row
  preview takes about 8 seconds because `rxjson` still has visible cost even on
  compact result JSON.
- Stage 3 now has a CREXX queue consumer,
  `crexx/profiles/history/stage3_extract_queue.crexx`. JSON extraction from
  Gemma E4B reproduced the expected local-LLM weakness: the OpenAI response JSON
  was valid, but the candidate content could be malformed or truncated. Tagged
  output is now the preferred Stage 3 mode (`NODE|...` / `EDGE|...`). On a fresh
  Scotland Stage 3 proof copy, one tagged Gemma run against chunk 1660 completed
  in about 33 seconds, accepted 14 nodes and 2 typed relationships, rejected a
  truncated edge safely, marked the queue item `processed`, and stored the raw
  output plus counts in `work_attempts`.
- The first real Stage 3 Scotland batch processed the top 100
  `stage3-scotland-default` `chunk-extraction` work items on
  `scotland-combined-stage2.cprag` with Gemma E4B tagged output. Runtime was
  about 4,960 seconds, or 82.7 minutes, with one llama-server reader. Final
  attempt status was 99 `processed`, 1 `skipped`, 0 `failed`; the controller
  counted 981 accepted node proposals and 316 accepted relationship proposals.
  Durable graph deltas were lower because upserts and repeated support merge
  existing facts: 782 Stage 3 tagged concept nodes, 99 evidence chunk nodes, 973
  Stage 3 mention edges, and 315 Stage 3 typed relationship edges. Accepted
  relationship types were mostly `associated-with` and `mentioned-in`, with
  smaller but useful `conflicted-with`, `claimed-descent-from`, `source-claims`,
  and `served` edges.
- The Scotland batch is a deliberately hard corpus. Rejected tagged output
  repeatedly proposed extra node classes such as `title`, `group`, `object`,
  `concept`, `topic`, `date`, `custom`, and `tune`, plus relationship labels
  such as `married-to`, `received-land`, and `led-force-against`. Treat these as
  background-improvement fuel, not as silent failures: they should become
  profile-vocabulary review, endpoint-resolution, and relationship-mapping work
  items.
- A first endpoint-resolution backlog was seeded from credible rejected Stage 3
  tagged `EDGE` records. Queue `stage4-endpoint-resolution-default` contains 199
  pending `endpoint-resolution` rows: 60 already have both endpoints in the
  graph, 117 are missing the target endpoint, 15 are missing the source
  endpoint, and 7 need both endpoints resolved. This is intentionally a
  follow-up queue, not an automatic graph write.
- The combined Scotland corpus was embedded with the FAISS build and
  llama.cpp/Nomic (`nomic-embed-text-v1.5`, `semantic-context-v1`). The first
  run exposed a practical llama.cpp limit: a 519-token bibliography chunk failed
  with HTTP 500 when the embedding server used its default physical batch size
  of 512. Restarting Nomic with `--ubatch-size 1024` embedded all 11,684 chunks
  and rebuilt `vectors.faiss` with a 768-dimensional L2 index. Direct SQLite
  progress probes during the writer-heavy embedding pass also produced one
  `database is locked`, which is now captured as an observability/status API
  requirement.
- Initial search smokes are green across the loaded Scotland corpus. CLI
  lexical search, direct FAISS vector search, graph expansion/shortest path,
  and MCP `library_search` with `mode=auto` were exercised against Sutherland
  ambiguity, Clan Mackay, Harlaw, Donald/Lord of the Isles, and source-grounded
  relationship questions. MCP auto correctly promoted to `effective_mode =
  hybrid` when configured with
  `./cmake-build-faiss/crexx-rag embed-llama-server --role query` and
  `nomic-embed-text-v1.5`. Useful examples: Sutherland clan and place are linked
  through shared evidence chunk 5648; Harlaw expansion links Hector and Sir
  Alexander Irving through event `battle_of_harlaw_1411`; Donald Balloch and
  Lord of the Isles share evidence chunk 1660. The smokes also exposed expected
  fixups: duplicate Donald Balloch ids, some weak Stage 3 types, and pending
  endpoint-resolution items such as Sutherland/Culloden and Lord-of-the-Isles
  variants.
- The observed llama-server/Gemma memory footprint was small enough that
  multiple queue readers look plausible later. Do not simply start several CREXX
  loops over `pending` rows, though. Add native claim/lease semantics first:
  atomically move work from `pending` to `running`, record `worker_id` and
  `lease_until`, and recover expired leases. Then tune llama-server parallelism
  (`-np`, context/cache settings) and worker count together.
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
- The preferred profile shape is similarly layered: staged controllers should
  call native helpers and import `pipeline_profile`; workload-specific behavior
  should be vocabulary, filters, cue words, gates, and validation data rather
  than a copied controller.
- Local model lifecycle should be profile-controlled but implementation-light.
  The first useful layer can be shell wrappers such as "start Qwen advisor",
  "start Gemma extractor", and "stop local models"; CREXX can call those wrappers
  through the same command/address surface while the native CLI performs health
  checks and records which profile owns a process.
- Do not leave chatty `llama-server` processes attached to a foreground PTY for
  long batch runs. In the Stage 1b experiment, undrained server logs made the
  pipeline look model-bound even though llama.cpp was answering quickly. The
  start wrappers redirect logs to `.local/llama-servers/*.log` and should be the
  normal way to launch local advisory/extraction models. On macOS from the Codex
  execution environment, plain `nohup ... &` was not durable enough; the wrapper
  now defaults to `launchctl submit` and keeps llama-server stdin open through a
  harmless `tail -f /dev/null` pipe. Without that, llama-server reached
  "listening" and then exited with no useful error after stdin closed.
- The first hardened post-queue run used
  `scripts/run_history_pipeline.sh --stages stage2b,stage3,status` on
  `scotland-combined-stage2.cprag` with queue
  `stage3-scotland-hardening-20260625`. Stage 2b excluded the 100 previously
  attempted chunks and queued the next 25. Stage 3 then drained the queue with
  Gemma E4B tagged output: 25 `processed`, 0 `failed`, 245 accepted node
  proposals, and 119 accepted relationships. `queue-status` reported all 25
  items processed, with graph totals increasing to 11,158 entities and 24,934
  edges. Validator rejects during the run were mostly useful type/endpoint
  signals: object-like nodes, vague places such as `castle`, and non-canonical
  person/title variants.
- Useful CREXX reference points for this command-capture pattern are the
  sibling CREXX docs/examples:
  `/Users/adrian/CLionProjects/crexx/docs/ai-context/CREXX_LEVELB_AUTHORING.md`,
  `/Users/adrian/CLionProjects/crexx/docs/books/crexx_language_reference/statements.md`,
  `/Users/adrian/CLionProjects/crexx/tests/demo/countlines.crexx`,
  `/Users/adrian/CLionProjects/crexx/lib/rxfnsb/tests_functional/ts_address.crexx`,
  `/Users/adrian/CLionProjects/crexx/demos/llm/llm_address_demo.crexx`, and
  `/Users/adrian/CLionProjects/crexx/compiler/tests/rexx_src/address_llm_host.crexx`.
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
- Observability should be first class for every long-running pipeline step.
  Controllers should create durable job/work status and expose it through CLI,
  CREXX, and MCP instead of relying on operators to query SQLite tables directly.
  The Scotland embedding run completed successfully, but a mid-run read-only
  progress probe collided with writer-heavy embedding and produced
  `database is locked`; status APIs and resumable/skip-existing workers are the
  countermeasure.
- The CREXX smoke compiles `cprag.crexx`, compiles the profile against it,
  assembles both modules with installed `rxas`, and runs with installed
  `rxvme`.
- CREXXSAA cache maintenance uses `crexxsaa --clear`. The CTest path still uses
  explicit `rxc`/`rxas`/`rxvme` so it proves the installed compiler and VM
  directly.
- Review/fixup now has native generic consumers. The public surface is
  `upsert-work-item`, `work-queue`, `record-work-attempt`, `work-attempts`, and
  `resolve-work-queue`, with matching RXPA and `cprag.crexx` wrappers. The
  endpoint consumer only writes typed edges when both endpoints exist. The
  ambiguity consumer writes an explicit `ambiguity` node and `candidate-for`
  links to existing concepts. The type-review consumer accepts a proposed type
  for an existing entity without replacing its label/description. The external
  extraction review consumer promotes one normalized node, edge, or
  node-plus-edge proposal from an outside analyzer. Dry previews do not mutate;
  pass `apply` for graph writes and durable attempts.
- Evidence strength is now durable metadata, not just answer-prompt advice.
  Stage 2b stores `evidence_class`, `directness`, and source directness in
  queue metadata and penalizes locator-shaped chunks. Deterministic/hybrid/Stage
  3 writes tag directness and evidence class, and MCP `library_answer_evidence`
  prefers those fields before falling back to heuristics.

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
- Extend the hybrid extractor beyond the first proof. Candidate collation,
  LLM-assisted/offline adjudication, graph seeding, ranked extraction queues,
  and first fixup consumers now have first-class storage and CREXX APIs. The
  next major step is claim/lease semantics for safe multi-worker processing and
  broader profile tuning.
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
