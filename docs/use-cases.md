# Executable Use Cases

This page is the operator and agent handoff for the current framework. It shows
how the main workflows are executed without requiring a new user or agent to
know the storage layout, build directories, SQLite schema, or model internals.

The common wrapper is:

```bash
scripts/run_use_case.sh list
```

It is intentionally thin. The native core owns durable state and graph/search
behavior. CREXX staged controllers own orchestration. `pipeline_profile.crexx`
owns profile policy. The wrapper only names common use cases and dispatches to
the right existing surface.

## 1. Initial Load

Initial load builds the first useful library: source chunks, Stage 1 census,
Stage 1b adjudications, Stage 2 mention graph, Stage 2b extraction queue, a
bounded Stage 3 pass, and status.

Offline smoke:

```bash
scripts/run_use_case.sh initial-load \
  --library ./generic-demo.cprag \
  --profile generic \
  --mode offline \
  --source-file ./tests/fixtures/generic-it.txt \
  --stage1-chunk-limit 2 \
  --stage1b-min-count 1 \
  --stage2b-limit 5 \
  --stage3-limit 2 \
  --stage3-mode dry-run \
  --no-require-models
```

Online corpus run uses the same shape, but with local models running and
`--stage3-mode online`.

## 2. Background Improve

Background improve consumes explicit queued work in bounded cycles. It is safe as
a single foreground worker and writes logs under `.local/background-improvement`.

```bash
scripts/run_use_case.sh background-improve \
  --library ./scotland.cprag \
  --profile scotland \
  --queue-id improve-scotland-$(date +%Y%m%d) \
  --mode online \
  --stage2b-limit 100 \
  --stage3-limit 25 \
  --stage3-mode online \
  --max-cycles 1
```

Do not run multiple readers until native queue claim/lease semantics exist.

## 3. Add More Documents

Adding documents reuses the existing concept/alias registry. It ingests the new
source, runs the census/adjudication path for that source, seeds accepted
mentions, builds or refreshes the extraction queue, and reports status.

```bash
scripts/run_use_case.sh add-documents \
  --library ./generic-demo.cprag \
  --profile generic \
  --mode offline \
  --source-file ./tests/fixtures/generic-it.txt \
  --stage1-chunk-limit 2 \
  --stage1b-min-count 1 \
  --stage2b-limit 5 \
  --no-require-models
```

Use a new `--source-file` for a real incremental run. Stage 3 is intentionally
not part of the default add-documents wrapper; queue consumption can happen as a
background-improve cycle.

## 4. Search And QA

Human CLI search:

```bash
scripts/run_use_case.sh search \
  --library ./generic-demo.cprag \
  --query "authentication database" \
  --top-k 8 \
  --hops 2
```

LLM-facing QA should prefer MCP `library_answer_evidence`. It returns a compact
source-bound evidence bundle with:

- retrieval plan hints;
- retrieved source chunks;
- accepted typed graph claims;
- graph-only leads such as `mentioned-in`;
- answer guidance that reminds the agent to cite chunks and avoid outside
  knowledge.

Manual smoke through stdio MCP:

```bash
scripts/run_use_case.sh qa-evidence \
  --library ./generic-demo.cprag \
  --question "What evidence connects authentication to the database?" \
  --top-k 8 \
  --hops 2
```

An MCP client should call:

```json
{
  "name": "library_answer_evidence",
  "arguments": {
    "question": "What evidence connects authentication to the database?",
    "mode": "auto",
    "top_k": 8,
    "hops": 2
  }
}
```

`mode=auto` uses lexical search unless a compatible active vector index and
embedding command are configured.

## Fixup Queues

Endpoint and ambiguity fixups use the same durable queue tables as extraction:

```bash
./cmake-build-debug/crexx-rag work-queue \
  ./generic-demo.cprag \
  generic.hybrid.v1 \
  fixup \
  ambiguity-review \
  pending \
  20

./cmake-build-debug/crexx-rag resolve-work-queue \
  ./generic-demo.cprag \
  generic.hybrid.v1 \
  fixup \
  ambiguity-review \
  20 \
  apply
```

Use `endpoint-resolution` for accepted/proposed typed edges whose endpoint ids
should already exist. Use `ambiguity-review` for labels with multiple plausible
senses. The resolver is conservative: it skips missing endpoints, keeps
ambiguity explicit, records attempts, and attaches `directness` /
`evidence_class` metadata for ranking and answers.

## 5. External Extractor Push

External extractors are a supported design case, but the production push/review
workflow is not complete yet. Today, accepted external facts can be written only
through the explicit mutating CLI/MCP graph tools, with provenance metadata, or
through Stage 3 extraction attempts. The intended hardening path is an
`external-extraction-review` queue item type that passes proposals through the
same validation, de-duplication, ambiguity, and support accumulation rules as
internal extraction.

Until that worker exists, do not treat external LLM output as truth. Store it as
proposed evidence with extractor/model/profile metadata, or route it through the
Stage 3 validation path.

## Validation

The executable framework gates are:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

The MCP QA surface is covered by `mcp_smoke`, and the generic lifecycle wrapper
is covered by `crexx_generic_pipeline_smoke`.
