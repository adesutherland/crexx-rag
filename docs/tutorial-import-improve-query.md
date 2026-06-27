# Tutorial: Import, Improve, And Query A Corpus

This tutorial is the shortest repeatable path from a plain text file to a local
GraphRAG library that can be searched by humans and queried by an LLM agent.

It starts with the generic offline path because that proves the framework
without requiring llama.cpp models. Optional sections add embeddings and online
LLM extraction once the local servers are running.

## What You Will Build

The tutorial creates a shareable folder library:

```text
.local/tutorial/tutorial.cprag/
  manifest.json
  library.sqlite
  vectors.faiss        # only if the optional FAISS embedding step is run
```

The generic profile uses the same staged pipeline as Scotland:

```text
source text
  -> chunks
  -> Stage 1 candidate census
  -> Stage 1b candidate adjudication
  -> Stage 2 mention/evidence graph
  -> Stage 2b ranked extraction queue
  -> Stage 3 extraction attempts
  -> review/fixup queues
  -> source-bound search and QA evidence
```

The source of truth is the native library. CREXX controllers decide policy and
order of work; shell wrappers are operator conveniences.

## 1. Build And Check The Repo

Run the normal validation first:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

If CREXX is not installed, CREXX-specific tests may be skipped at configure time.
The staged pipeline commands below need installed `rxc`, `rxas`, and `rxvme`.

## 2. Run A Complete Offline Initial Load

Create a tiny generic library without local models:

```bash
rm -rf .local/tutorial/tutorial.cprag

scripts/run_use_case.sh initial-load \
  --library ./.local/tutorial/tutorial.cprag \
  --profile generic \
  --mode offline \
  --source-file ./tests/fixtures/generic-it.txt \
  --source-uri tutorial/generic-it.txt \
  --title "Generic IT tutorial corpus" \
  --stage1-chunk-limit 2 \
  --stage1b-min-count 1 \
  --stage2b-limit 5 \
  --stage3-limit 2 \
  --stage3-mode dry-run \
  --no-require-models
```

Expected shape:

- the command prints the chosen `profile_id=generic.hybrid.v1`;
- Stage 1 stores candidate mentions;
- Stage 1b stores keep/junk/type decisions;
- Stage 2 creates concept and evidence links;
- Stage 2b creates `chunk-extraction` work items;
- Stage 3 dry-run records attempts without calling a model;
- status prints queue, vector, and library summaries.

The log is under `.local/history-pipeline/<run-id>/pipeline.log`.

## 3. Inspect The Library

Use public CLI surfaces rather than direct SQLite queries:

```bash
./cmake-build-debug/crexx-rag stats ./.local/tutorial/tutorial.cprag

./cmake-build-debug/crexx-rag queue-status \
  ./.local/tutorial/tutorial.cprag \
  generic.hybrid.v1 \
  stage3-generic-default

./cmake-build-debug/crexx-rag work-queue \
  ./.local/tutorial/tutorial.cprag \
  generic.hybrid.v1 \
  stage3-generic-default \
  chunk-extraction \
  dry-run \
  10
```

For a quick graph view:

```bash
./cmake-build-debug/crexx-rag subgraph \
  ./.local/tutorial/tutorial.cprag \
  service,data-object \
  associated-with \
  20
```

## 4. Query The Corpus

Human CLI search:

```bash
scripts/run_use_case.sh search \
  --library ./.local/tutorial/tutorial.cprag \
  --query "authentication database" \
  --top-k 8 \
  --hops 2
```

LLM-facing QA evidence bundle:

```bash
scripts/run_use_case.sh qa-evidence \
  --library ./.local/tutorial/tutorial.cprag \
  --question "What evidence connects authentication to PostgreSQL?" \
  --top-k 8 \
  --hops 2
```

The QA bundle is the preferred agent surface. It returns source-bound policy,
retrieval plan hints, narrative chunks, accepted typed graph claims, graph-only
leads, and answer guidance. A new agent should answer from that bundle rather
than from outside memory.

## 5. Run A Background Improvement Cycle

The background worker reruns Stage 2b and Stage 3 over a named queue. Keep the
first tutorial run offline and bounded:

```bash
scripts/run_use_case.sh background-improve \
  --library ./.local/tutorial/tutorial.cprag \
  --profile generic \
  --queue-id improve-generic-tutorial \
  --mode offline \
  --stage2b-limit 5 \
  --stage2b-preview 5 \
  --stage3-limit 2 \
  --stage3-mode dry-run \
  --max-cycles 1 \
  --no-require-models
```

The worker uses a single filesystem lock and writes logs under
`.local/background-improvement/`. Do not run multiple queue readers until native
claim/lease semantics exist.

## 6. Add Another Document

Incremental import should reuse the existing concept and alias registry. Create a
second small text file:

```bash
mkdir -p .local/tutorial
printf '%s\n' \
  'The Reporting Component reads User Profile Data from PostgreSQL.' \
  'The Authentication Service sends account changes to the Reporting Component.' \
  > .local/tutorial/reporting-note.txt
```

Add it to the same library:

```bash
scripts/run_use_case.sh add-documents \
  --library ./.local/tutorial/tutorial.cprag \
  --profile generic \
  --mode offline \
  --source-file ./.local/tutorial/reporting-note.txt \
  --source-uri tutorial/reporting-note.txt \
  --title "Reporting note" \
  --stage1-chunk-limit 2 \
  --stage1b-min-count 1 \
  --stage2b-limit 10 \
  --no-require-models
```

Then run another bounded improvement cycle if you want Stage 3 attempts for the
newly ranked queue.

## 7. Review Or Promote Fixup Work

Review queues use the same durable `work_queue` table as extraction. The current
native resolver supports:

```text
endpoint-resolution
ambiguity-review
type-review
external-extraction-review
```

A type review accepts a proposed type for an existing entity:

```bash
./cmake-build-debug/crexx-rag upsert-work-item \
  ./.local/tutorial/tutorial.cprag \
  generic.hybrid.v1 \
  review \
  type-review \
  type:postgres \
  0 \
  8 \
  pending \
  "Accept PostgreSQL as a data object" \
  '{"entity_id":"generic:data-object:postgresql","accepted_type":"data-object","evidence":"tutorial review"}'

./cmake-build-debug/crexx-rag resolve-work-queue \
  ./.local/tutorial/tutorial.cprag \
  generic.hybrid.v1 \
  review \
  type-review \
  10 \
  dry-run
```

Use `apply` instead of `dry-run` only after the preview is right.

An external extractor can push one normalized proposal for review:

```bash
./cmake-build-debug/crexx-rag upsert-work-item \
  ./.local/tutorial/tutorial.cprag \
  generic.hybrid.v1 \
  review \
  external-extraction-review \
  external:redis \
  0 \
  7 \
  pending \
  "Promote reviewed external Redis proposal" \
  '{"node_id":"generic:data-object:redis","node_type":"data-object","node_label":"Redis","description":"Reviewed cache concept","source_id":"generic:service:authentication-service","target_id":"generic:data-object:redis","relationship_type":"associated-with","edge_label":"Authentication Service associated with Redis","confidence":0.8,"evidence":"tutorial external review"}'

./cmake-build-debug/crexx-rag resolve-work-queue \
  ./.local/tutorial/tutorial.cprag \
  generic.hybrid.v1 \
  review \
  external-extraction-review \
  10 \
  dry-run
```

This is the safe pattern for outside LLM output: normalize first, queue for
review, preview, then apply.

## 8. Optional: Add Local Embeddings

Start only the embedding server:

```bash
scripts/start_local_llama_servers.sh --embedding-only
scripts/status_local_llama_servers.sh --smoke --require embedding
```

Build the FAISS-enabled binary if needed:

```bash
cmake -S . -B cmake-build-faiss -G Ninja -DCPRAG_ENABLE_FAISS=ON
cmake --build cmake-build-faiss
```

Embed chunks with llama.cpp/Nomic:

```bash
./cmake-build-faiss/crexx-rag embed-chunks \
  ./.local/tutorial/tutorial.cprag \
  nomic-embed-text-v1.5 \
  llama-server

./cmake-build-faiss/crexx-rag vector-status \
  ./.local/tutorial/tutorial.cprag
```

The default local embedding provider is `llama-server` at
`http://127.0.0.1:8081/v1`. Nomic inputs are role-prefixed by the adapter:
`search_document: ` for chunks and `search_query: ` for queries.

## 9. Optional: Run Online Extraction

Start the chat server:

```bash
scripts/start_local_llama_servers.sh --chat-only
scripts/status_local_llama_servers.sh --smoke --require chat
```

Start the advisor server too if you also plan to run online Stage 1 or Stage 1b.

Run a tiny online Stage 3 pass:

```bash
scripts/run_use_case.sh background-improve \
  --library ./.local/tutorial/tutorial.cprag \
  --profile generic \
  --queue-id online-generic-tutorial \
  --mode online \
  --stage2b-limit 5 \
  --stage3-limit 1 \
  --stage3-mode online \
  --max-cycles 1
```

Keep the first online pass tiny. Local extraction is free and private, but it is
still a background workload.

## 10. Optional: Hand The Corpus To An Agent

For a Codex or MCP-capable agent, the prompt should not expose SQLite, FAISS, or
pipeline internals. Give it the library path and require MCP evidence first:

```text
Use the MCP tool library_answer_evidence against:
  ./.local/tutorial/tutorial.cprag

Answer only from the returned corpus evidence. First ask focused searches through
the tool, then answer with chunk citations. Treat graph-only mentioned-in paths
as leads, not direct claims. If evidence is missing or ambiguous, say so.
```

For Scotland-style tests, add domain hints such as spelling variants, aliases,
chronology, and direct-claim versus graph-adjacent comparison.

## Troubleshooting

- `rxc`, `rxas`, or `rxvme` missing: install CREXX or use non-CREXX native/CLI
  tests until the toolchain is available.
- Online model smoke fails: use the offline tutorial first, then inspect
  `.local/llama-servers/*.log`.
- `vectors.faiss` missing: the library still works with lexical and graph search;
  build the FAISS binary and run the optional embedding step when needed.
- Queue does not shrink after dry-run: expected. Dry-runs record previews but do
  not mark work as processed.
- Database lock during long jobs: use `queue-status`, `stats`, and wrapper logs
  instead of ad hoc SQLite polling.

## Tutorial-Driven Roadmap

This walkthrough now has CTest coverage through `use_case_wrapper_smoke` for the
offline initial load, search, MCP QA evidence, incremental add-documents,
background-improve dry-run, and the tutorial review/fixup preview commands.

Remaining hardening items:

- add MCP QA golden tests that check direct claims are preferred over
  `mentioned-in` leads;
- add native queue claim/lease semantics before multiple background workers are
  supported;
- add a first-class wrapper for review/fixup queues so tutorial users do not
  need raw `upsert-work-item` commands for common reviews;
- add normalized external extraction proposal fixtures and tests.
