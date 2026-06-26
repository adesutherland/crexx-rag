# Pipeline Status

This page separates implemented behavior from planned behavior. It is intended
for new contributors and agents who need to know what can be trusted today.

## Status Summary

| Area | Status | Notes |
| --- | --- | --- |
| Native core graph, chunk, candidate, queue, and attempt storage | Implemented | Domain-neutral C ABI and CLI surfaces exist. |
| Local embedding provider abstraction | Implemented | `llama-server` and Ollama remain adapter-level; FAISS remains optional. |
| Shared profile policy module | Implemented | `crexx/profiles/pipeline_profile.crexx` centralizes profile ids, namespaces, vocabulary, filters, cue words, validation, and concept id shape. |
| Generic staged pipeline | Implemented baseline smoke path | `generic` now runs through Stage 1, 1b, 2, 2b, 3 dry-run, background improvement, and status. |
| Scotland staged pipeline | Implemented demonstrator | Scotland uses the same staged controllers with profile-specific vocabulary and validation. |
| Athens staged pipeline | Partial | Prompt/profile support exists, but it has not been hardened to the same level as generic and Scotland. |
| Background improvement worker | Implemented budgeted single-worker wrapper | `scripts/run_background_improvement.sh` reuses the staged runner and uses an atomic lock. It is not yet a daemon. |
| Multi-worker queue consumption | Planned | Needs native claim/lease semantics before multiple Stage 3 workers are safe. |
| Endpoint/ambiguity resolution | Implemented first native consumer | `resolve-work-queue` consumes `endpoint-resolution` and `ambiguity-review` items conservatively. |
| External LLM extract push | Partial | Explicit graph writes and Stage 3 attempts exist; review-queue workflow is still needed. |
| Agent-facing QA wrapper | Implemented first read surface | MCP `library_answer_evidence` returns an LLM-ready evidence bundle; Scotland prompt/helper remains as a demo wrapper. |
| Executable use-case wrapper | Implemented | `scripts/run_use_case.sh` dispatches initial-load, add-documents, background-improve, search, and MCP QA evidence workflows. |

## Generic Path

The generic path is deliberately small. It proves the reusable framework without
depending on Scotland-specific concepts:

```bash
scripts/run_history_pipeline.sh \
  --library ./generic-demo.cprag \
  --profile generic \
  --stages stage1,stage1b,stage2,stage2b,stage3,status \
  --mode offline \
  --source-file ./tests/fixtures/generic-it.txt \
  --stage1-chunk-limit 2 \
  --stage1b-min-count 1 \
  --stage2b-limit 5 \
  --stage3-limit 2 \
  --stage3-mode dry-run \
  --no-require-models
```

Generic defaults:

- profile id: `generic.hybrid.v1`
- graph namespace: `generic`
- node types: `service`, `data-object`, `component`, `person`, `place`,
  `institution`, `source-work`
- relationship types: `associated-with`, `part-of`, `located-in`,
  `caused-by`, `succeeded-by`, `source-claims`

The default generic sample seeds a small IT-style vocabulary:

- `Authentication Service`
- `Backup Service`
- `PostgreSQL`
- `User Profile Data`

That sample is intentionally mundane. It is a framework test, not domain tuning.

## Scotland Path

The Scotland path should remain profile-specific policy over the generic stages.
Its current policy lives in `crexx/profiles/pipeline_profile.crexx`: vocabulary,
type filters, cue words, validation rules, candidate typing, and ambiguity
decisions. Scotland should not own queue mechanics, status, candidate
persistence, or native graph writes directly.

Current Scotland status:

- Stage 1 candidate census has been run over the two-volume corpus.
- Stage 1b candidate adjudication has been run.
- Stage 2 mention/co-occurrence graph seeding has been run.
- Stage 2b ranked extraction queues are available.
- Stage 3 has processed 124 real chunks plus one skipped chunk.
- Endpoint-resolution and ambiguity-review backlogs can be consumed by the
  generic native `resolve-work-queue` helper after inspection.

## Fixup Queues

Use generic work queues for fixup and review workloads rather than
profile-specific shell scripts:

```bash
./cmake-build-debug/crexx-rag work-queue \
  ./scotland.cprag \
  history.scotland.hybrid.v1 \
  fixup \
  endpoint-resolution \
  pending \
  20

./cmake-build-debug/crexx-rag resolve-work-queue \
  ./scotland.cprag \
  history.scotland.hybrid.v1 \
  fixup \
  endpoint-resolution \
  20 \
  apply
```

Current consumers:

- `endpoint-resolution`: writes a typed edge only when the source id, target id,
  and relationship type are present and both endpoint entities already exist.
- `ambiguity-review`: creates or refreshes an explicit `ambiguity` node and
  `candidate-for` edges to existing candidate concepts.

Leaving off `apply` gives a dry preview. Applied runs record `work_attempts` and
update queue item status through the same durable tables as Stage 3.

## Background Improvement

Use the background improvement wrapper for budgeted local runs:

```bash
scripts/run_background_improvement.sh \
  --library ./scotland.cprag \
  --profile scotland \
  --queue-id improve-scotland-$(date +%Y%m%d) \
  --mode online \
  --stage2b-limit 100 \
  --stage3-limit 25 \
  --stage3-mode online \
  --max-cycles 1
```

The worker:

- reuses `scripts/run_history_pipeline.sh`;
- takes an atomic filesystem lock;
- runs a bounded number of cycles;
- records logs under `.local/background-improvement`;
- is safe as a single-worker foreground process.

It does not yet:

- claim individual queue items;
- coordinate multiple readers;
- restart failed model servers;
- install itself as a daemon.

## Agent-Facing QA

For LLM clients, prefer MCP `library_answer_evidence` over raw `library_search`.
It returns source-bound policy, a retrieval plan, retrieved chunks, accepted
typed graph claims, graph-only leads, and answer guidance in one bundle. Manual
stdio smoke:

```bash
scripts/run_use_case.sh qa-evidence \
  --library ./generic-demo.cprag \
  --question "What evidence connects authentication to the database?"
```

Use `library_search` only for diagnostics or custom retrieval experiments.

## Boundary Rules

- Native core operations own durable state: chunks, candidate tables, graph
  upserts, support accumulation, queues, attempts, traversal, and search.
- Staged CREXX controllers own orchestration: which stage to run, limits,
  cursors, queue names, and model routing.
- `pipeline_profile.crexx` owns profile policy: default ids, namespaces,
  vocabulary, filters, cue words, candidate typing, ambiguity handling,
  validation choices, and concept id shape.
- Scotland should remain a small policy layer over the generic framework, not a
  fork of the pipeline.
- Vector similarity may prioritize or find candidates for inspection, but must
  not create typed domain edges by itself.
- Dry-run Stage 3 attempts record `dry-run`, not `skipped`, so test probes do
  not poison future ranking. `resolve-work-queue` dry previews are non-mutating;
  pass `apply` to write graph facts and attempts.
- Evidence chunks and edges should carry `evidence_class` and `directness`.
  Answer wrappers and ranking should prefer narrative passages and accepted
  typed edges over locators, captions, and mention-only graph leads.
