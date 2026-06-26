# Framework Closure Plan

This plan turns the Scotland experiment into a repeatable, generic GraphRAG
framework. Scotland remains the hard demo corpus; the framework must still work
for easier business, IT, architecture, and operational corpora without baking in
Scottish-history assumptions.

## Closure Goal

The framework is complete when a corpus can move through this lifecycle:

```text
source documents
  -> ingest and chunk
  -> embed chunks
  -> Stage 1 candidate census
  -> Stage 1b candidate adjudication
  -> Stage 2 mention/evidence graph seed
  -> Stage 2b extraction queue ranking
  -> Stage 3 relationship extraction
  -> fixup / ambiguity / evidence-quality review
  -> source-bound QA/search
  -> background improvement
  -> incremental re-ingest and reprocess
```

The lifecycle must be resumable, observable, and profile-tunable. Expensive LLM
work should be queued and restartable. The native core owns durable state,
deduplication, evidence accumulation, search, and graph writes. CREXX owns
policy and orchestration. MCP or wrapper scripts expose a narrow agent-facing
surface.

Current implementation status is tracked in
[`pipeline-status.md`](pipeline-status.md). Acceptance criteria and test layers
are tracked in [`test-strategy.md`](test-strategy.md). Keep those documents
updated when this plan moves from intent to implemented behavior.

## Generic First, Profile Second

Generic framework responsibilities:

- library bundle creation and status;
- source ingestion and chunking;
- chunk embedding and vector index rebuild;
- candidate mention storage;
- candidate adjudication storage;
- mention/evidence graph seeding;
- typed relationship writes with support accumulation;
- generic work queues and attempts;
- graph/vector/lexical/hybrid search;
- background worker status and retry policy;
- source-bound QA evidence bundles;
- evidence quality/directness metadata.

Profile responsibilities:

- allowed node and relationship vocabulary;
- candidate ignore lists and keep/junk hints;
- alias and spelling rules;
- relation cue words;
- extraction queue scoring weights;
- LLM prompts and output format;
- review thresholds;
- domain-specific answer guidance.

Scotland tuning belongs in a history/Scotland profile. Athens tuning belongs in
a history/Athens profile. The IT architecture use case should get its own
profile with ArchiMate-inspired node and relationship types.

## Framework Completion Checklist

### 1. Stable Pipeline Commands

Each stage needs a repeatable command/controller with clear defaults:

- ingest sources and chunk them;
- embed chunks with provider id and model;
- run Stage 1 candidate census;
- run Stage 1b adjudication;
- run Stage 2 graph seed;
- run Stage 2b extraction queue build;
- run Stage 3 extraction consumer;
- run fixup/ambiguity review;
- run search/QA smokes.

The current CREXX controllers prove Stage 1b, Stage 2, Stage 2b, and Stage 3.
The next closure step is a thin "pipeline runner" that calls the same
operations in order and records checkpoints. The runner can be CREXX first, with
CLI parity for humans.

Initial operator wrapper:

```bash
scripts/run_history_pipeline.sh --stages stage2b,stage3,status ...
```

This shell wrapper is intentionally thin: it compiles/runs the CREXX
controllers and calls existing native/CLI operations. It should remain an
operator convenience until the same orchestration is promoted into a CREXX
controller or address environment.

Current status: `run_history_pipeline.sh` supports `generic`, `scotland`, and
`athens`. The `generic` path is the baseline smoke path and is covered by
`crexx_generic_pipeline_smoke`.

### 2. Generic Work Queue

Use a queue model for all long-running or background work:

```text
queue_id
item_type
item_key
status
priority / rank
attempt count
last error
metadata
created_at / updated_at
```

Known item types:

- `chunk-extraction`
- `endpoint-resolution`
- `ambiguity-review`
- `type-review`
- `evidence-quality-review`
- `reembed-chunk`
- `reprocess-chunk`
- `external-extraction-review`

This lets an overnight run process work safely and lets a later background
worker continue improvement without a separate architecture.

Current status: `scripts/run_background_improvement.sh` provides a budgeted
single-worker loop over Stage 2b/Stage 3/status with an atomic filesystem lock.
It is not a multi-worker daemon; claim/lease semantics remain required before
multiple readers are allowed.

### 3. Observability

Every long-running stage needs status before it needs cleverness:

- library status;
- vector status;
- candidate census/adjudication counts;
- graph seed progress;
- queue status by queue id and item type;
- attempt counts by status;
- last processed id/rank;
- current model/provider endpoints;
- estimated remaining work when cheap to compute.

Direct database polling caused lock pressure during embedding, so status should
be a first-class API/CLI/CREXX operation rather than ad hoc SQLite inspection.

Initial implemented status surface:

```bash
crexx-rag queue-status <library> <profile-id> [queue-id]
scripts/status_local_llama_servers.sh --smoke --require chat
```

`queue-status` summarizes durable `work_queue` and `work_attempts` state.
`status_local_llama_servers.sh` checks local model readiness before online
stages.

### 4. Evidence Classes And Directness

QA showed that result quality depends on evidence classification. Store or
derive:

```text
evidence_class:
  narrative
  index
  toc
  caption
  footnote
  genealogy
  quoted-source
  inscription
  model-extracted

directness:
  direct-source-claim
  accepted-typed-edge
  deterministic-rule
  model-proposal
  mention-only
  co-mention-only
  locator-only
```

Narrative source claims and accepted typed edges should outrank index and
mention-only evidence for explanatory answers. Mention paths are leads, not
claims.

### 5. Ambiguity And Type Review

Ambiguity is normal, not an error. The framework should preserve uncertain
senses and queue reviews:

- one surface label can map to multiple concept senses;
- one concept can have many aliases and spellings;
- type conflicts should create `type-review` work items;
- high-frequency ambiguous labels should create `ambiguity-review` work items;
- answers should expose unresolved ambiguity rather than silently choosing.

Examples from Scotland:

- `Sutherland`: place, clan, estate, title, family, regiment context;
- `Macpherson`: James Macpherson versus Clan Macpherson;
- `Black Watch`: military unit, not clan;
- titles such as Earl, Lord, Duke, Marquis can refer to people, offices, or
  houses depending on context.

### 6. Source Layering

The framework should preserve whether a claim is:

- the corpus author's narrative;
- a quoted authority;
- a summary of another named source;
- an index entry;
- an inscription;
- a model extraction.

This matters for answers like "according to Keltie" or "according to Skene."
The answer layer should not flatten all text in a source bundle into the same
kind of authority.

### 7. Agent-Facing Search Wrapper

The agent-facing surface should return a compact evidence bundle, not internal
implementation detail. A new agent should be able to:

```text
read a narrow instruction file
ask focused corpus questions
receive grouped lexical/vector/graph evidence
answer with citations and uncertainty
```

The wrapper should hint multiple search paths:

- exact phrase;
- spelling variants;
- aliases/translations;
- actor/agency;
- chronology;
- legal/source status;
- comparison;
- direct claim versus graph-adjacent lead.

The wrapper should not require the agent to know about SQLite, FAISS, MCP
startup, build directories, or model process details.

Current status: MCP `library_answer_evidence` is the first implemented
agent-facing read surface. It wraps the lower-level search result into a
source-bound evidence bundle with retrieval-plan hints, retrieved chunks,
accepted graph claims, graph-only leads, and answer guidance. The Scotland shell
wrapper remains a demo/fallback, but LLM clients should prefer the MCP tool.

### 8. Regression Smokes

Keep behavior tests rather than exact-wording tests:

- Does the agent query the corpus before answering?
- Does it show a retrieval plan?
- Does it distinguish direct claim from adjacency?
- Does it avoid outside knowledge?
- Does it cite narrative chunks when available?
- Does it flag weak, missing, or inferred evidence?
- Does it handle ambiguous names?

The first Scotland QA smoke set:

- Sutherlands and the Clearances;
- MacGregors and "Children of the Mist";
- Black Watch / `Am Freiceadan Dubh`;
- Mackay/Sutherland/Strathnaver/Caithness direct versus adjacent claims;
- Ossian/Macpherson nuance.

## Applying The Lessons

Order of work:

1. Make the generic lifecycle scriptable and observable.
2. Add evidence class/directness fields or derived metadata.
3. Update Stage 2b ranking to use evidence quality and chunk shape.
4. Update Stage 3 writes to record extraction provenance and directness.
5. Add ambiguity/type-review queues.
6. Update the QA wrapper to return grouped evidence. Implemented first through
   MCP `library_answer_evidence`; keep hardening evidence classes and regression
   questions.
7. Promote the Scotland QA tests into a repeatable regression smoke.
8. Tune the Scotland profile with ignore lists, alias rules, type fixes, and
   cue weights.
9. Add a generic/default profile and an IT architecture profile.

This order keeps the framework honest: Scotland tuning should not hide generic
pipeline gaps.

## Overnight Ingest Readiness

Before an overnight full ingest, confirm:

- `ctest --preset debug` is green;
- the target library is a copy or intentionally mutable;
- embedding server and LLM server are running and smoke-tested;
- model ports and queue ids are recorded;
- status commands work without direct SQLite polling;
- Stage 3 writes attempts and marks queue items processed/skipped/failed;
- retry behavior is understood;
- logs are captured to files;
- the run has a limit or an expected queue size;
- disk and memory headroom are acceptable.

For the current Scotland flow, the safe overnight shape is:

```text
1. build/rebuild vector index if needed
2. run or resume Stage 1b adjudication for pending candidates
3. run Stage 2 graph seed from adjudicated candidates
4. build Stage 2b extraction queue
5. run Stage 3 queued extraction with a named queue id
6. summarize queue status, attempts, graph deltas, and search smokes
```

Long-running extraction should be treated as background improvement, not as a
single all-or-nothing import. The first useful library exists as soon as chunks,
embeddings, candidates, mentions, and some accepted relationships are present;
background workers can then keep improving it.

## Definition Of Done

Framework closure means:

- a fresh corpus can be processed end to end with documented commands;
- every expensive stage is resumable;
- every queue has status and attempt history;
- search works with lexical, vector, graph, and hybrid paths;
- the QA wrapper can be handed to a new agent without project internals;
- evidence directness and quality are visible to ranking and answers;
- profile-specific tuning is optional and does not change the generic pipeline;
- the Scotland smoke questions continue to produce source-bound, cautious,
  cited answers.
