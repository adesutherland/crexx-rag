# Test strategy

The maintained suite tests the single shipping architecture rather than an old
implementation comparison.

The [reliability coverage review](reliability-coverage-review.md) maps these
tests to operator outcomes and records the unproved crash, publication and
concurrency boundaries. A passing suite is necessary, but is not evidence that
unattended long-running maintenance is qualified. In particular, idle worker
launch is not concurrent work qualification, and provider success is not item
publication success. The live 5,000-item run is held pending those gates.

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

The build declares the Level-G executable source cohort to CMake and invokes the
CREXX wrapper's incremental program mode once. CREXX supplies the sibling source
roots, bounded parallel compile wave, link barrier, content key, and atomic
publication. The independent `ADDRESS RAG` environment uses incremental library
mode. A repeated unchanged CMake build must report no work. Native packaging
uses the installed CREXX package's `rxsqlite` archive and native dependency
metadata directly.

## Default matrix

| Test | Main assurance |
| --- | --- |
| `linked_application` | installed `rxsqlite` provider mapping and both CREXX VMs |
| `configuration_contract` | format-1 compatibility, format-2/3 bounded settings, split identities, credential-free check/explain, identical/operational/prospective diff, tamper-resistant plan/apply, and a regression proving a provider-policy change leaves an existing corpus generation unchanged with zero new jobs or provider calls |
| `process_workers` | two-worker launch, observation, drain, stale PID detection, explicit pruning |
| `gemini_ingestion` | Gemini request/response mapping, compact gap-free LF/CR/CRLF normalization maps, durable work, claims, embeddings, vector publication, replay and failure paths |
| `gemini_extraction_validation` | invalid UTF-8 spans, unknown concept/relationship types and malformed extraction output dead-letter without product mutation or secret disclosure |
| `provider_durability` | reservation recovery, Codex turns, fencing, completed-turn reuse, durable cross-process admission, no false call record on preflight failure, immutable replay lineage, backlog reconciliation, and schema 1-to-10 migration with historic-cost backfill and prospective-transition auditing |
| `codex_protocol` | App Server initialize/account/turn/schema/usage/cleanup over JSONL |
| `codex_application` | public Codex extraction, worker-crash recovery from a persisted completed turn, duplicate-turn prevention, validation, allowance settlement and library verification |
| `gemini_maintenance` | hosted-style maintenance, glossary-drift rejection, durable cognitive notes, ANN publication/reuse, provider/profile discovery and external proposal review/promotion |
| `gemini_query` | query embeddings, hybrid retrieval, cited answers, deterministic library reporting, one-call cached advisory reporting with rejected-call history, churn-governed historic snapshots, duplicate coalescing, one-point trends, lexical zero-call and invalid citation rejection |
| `query_policy` | local/hosted privacy and every call/token/cost/allowance ceiling |
| `ann_methodology` | IVF-flat ANN publication/search, deterministic replay, bounded candidate work, recall against a frozen exact oracle and tamper fallback on both VMs |
| `lifecycle_methodology` | synonym, split, merge, type correction, retire/restore, exact impact census, migration-parent and atomic support/conflict handling on both VMs |
| `evidence_methodology` | outbound/inbound/both graph traversal without invented inverse claims, durable notes, leads and repeated query gaps on both VMs |
| `maintenance_methodology` | complete typed census, bounded deterministic ranking, stable worklist digest, generation binding and replay on both VMs |
| `native_surfaces` | human defaults, deterministic MCP reporting/snapshot/trend, configuration lifecycle, replay and external-schedule definition tools, MCP structured-content/strict-argument behavior, and exact integer boundaries including oversized-input rejection without a VM panic |
| `address_surface` | linked `ADDRESS RAG` report/trend/session/config/access behavior and snapshot denial on both VMs |
| `gemini_provider_smoke` | generation and embedding smoke, human/JSON/MCP, cancellation, aggregate budget, malformed output, secret redaction |
| `installed_product` | scratch-prefix installation, installed skills/tutorial, doctor/init/provider smoke/ingest/maintain/query using only installed product artifacts |
| `quotation_grounding` | exact-first/Unicode casefold/whitespace grounding, original byte mapping, repeated spans and scoped endpoints on both VMs and optimization modes |
| `durable_backlog` | complete split/merge fan-out, claim conflict preservation and qualification, typed identities, manual census/resume, supervised review, stale-before/after-call rejection, settled-response crash/window recovery and zero-call SQLite embedding reuse on both VMs |
| `durable_backlog_provider` | native guided maintenance through Gemini loopback: valid decisions, malformed responses, product-rejected quotations, redacted diagnostics, runtime configuration transitions; 40 resolutions with two workers and 20 forced overlapping request pairs, exact terminal accounting and unchanged source/vector state |
| `publication` | independent SQLite connections prove manifest ownership and reader/backup snapshots during uncommitted writes; batch/single-proposal rollback, cancellation, late/excess/duplicate usage, stale fences, final call and Codex-turn allowance; unchanged legacy folder URI identity, both VMs |
| `native_publication` | injected late SQL write failure; four chunks and two workers with forced overlapping requests, querying/backing up/restoring/verifying while each pair is held; exact semantic/usage reconciliation; missing-manifest recovery and provider-free restored queries |
| `native_receipts` | exit after durable extraction/embedding response but before settlement, then two-worker public restart: no repeated call, original-attempt usage, exact publication and no reservation leak |
| `native_interruption` | actual busy worker/controller kill with explicit uncertain intent, cancellation while provider response is held, post-commit manifest rejection and first-vector recovery without repeated extraction |
| `local_embedding_protocol` | llama.cpp-compatible `/v1/embeddings`, restricted local privacy, local-compute charging, and 429 `Retry-After` plus 503 exponential retry on both VMs and compiler modes |

The Gemini tests always exercise the Gemini adapter and Google request/response
shapes through a deterministic local fixture. Report tests additionally prove
that refresh makes one advisory call, cache reads make zero calls, unknown
citations are rejected and the previous valid cache survives. Historic tests
prove that the guided lifecycle captures a first point, exact duplicates are
suppressed/coalesced, a cached narrative is associated by report digests, and a
one-point trend refuses to infer direction. The suite does
not silently substitute a different provider. This makes the default suite
repeatable and zero-cost.

The CREXX repository owns the generic `rxsqlite` contract suite: typed values,
file databases, FTS, backup and integrity behavior, concurrent session
isolation, FULLMUTEX configuration, attached-task discovery, native packaging,
and installed external-consumer coverage. This suite does not duplicate those
driver tests. It proves that the linked, process-worker, backup, ingestion, and
installed native product paths consume the supported provider correctly.

## Live providers

Live calls are separate because they consume an external quota and require
credentials. Before a release candidate, run the native `provider test` against
the intended configuration, including Gemini even when Codex or local llama.cpp
routes are also under test:

```sh
export GEMINI_API_KEY='<key>'
cd docs/tutorial-work
./crexxrag provider test --yes
```

The reviewed configuration must bound calls, input/output tokens, timeout,
attempts, and either cost or subscription allowance. Test output must contain no
credential value.

## Change expectations

- Schema changes: fresh native build and all tests.
- Provider changes: Gemini ingestion/extraction-validation/query/smoke, Codex
  protocol/application/durability, local embedding protocol, policy tests,
  malformed output, and secret audit.
- Worker changes: process, ingestion, maintenance, replay, stale/prune tests.
- Public command changes: native surfaces plus the public discovery/proposal
  path inside `gemini_maintenance`.
- Documentation/config changes: tutorial setup and `crexxrag doctor` from the
  resulting folder.

## Configuration and derived-index preservation

The operator repair adds offline regressions for configuration-relative paths,
external prompt content identity, explicit standard-profile overrides, and
model/profile changes followed by unchanged ingestion. The query fixture
compares every existing SQLite table except the three configuration-history
tables before and after a reviewed model/profile change, including exact BLOB
encodings. It then checks old citations and database verification.

ANN methodology removes and corrupts sidecars and leaves an interrupted
recovery temporary; reconstruction and vector retrieval succeed with zero
provider runs. The public query fixture also exercises `vector rebuild`,
read-capability rejection, idempotent replay, and invalid-hybrid preflight
without any provider calls. The migration fixture opens a schema-8 bundle
through the ordinary write path and requires a schema-10 aligned manifest.

Maintenance methodology distinguishes successful and failed items within a
mixed-result job and recognizes embeddings repaired in a later generation.
The public maintenance fixture pages through more than 100 worklist items
with no duplicates or omissions, in both status and inspection operations.

Quotation grounding runs in both interpreters, with and without optimization.
It covers exact-first and first-repeat matching, Unicode byte mapping and
expanding casefolds, scoped relationship endpoints, non-matches, and the retained
Scottish hosted offset failure. Provider negatives check redacted rejected-output
durability as well as malformed output and strict product validation. Replay
qualification exercises claim, reservation, settlement and completion against
an atomically persisted budget policy. Cancellation covers queued, drained,
in-flight, expired-lease and already failed jobs.

ANN methodology also advances a graph-only generation without rebuilding its
index, verifies retrieval and backup, rejects changed embedding/source membership,
and tests rollback with an index from a non-ancestor branch. These tests make no
provider calls and retain the existing dimension, checksum and corruption checks.

The ANN gate also rejects incomplete alternate-profile replacement, queries the
retained original index, then completes replacement without removing old BLOBs.
The mixed backlog gate supplies a stale extraction identity during a real merge
workflow and requires publication against the active survivor.

The same gate uses different recorded questions with an identical generic
query-gap warning. It requires the original question and warning in separate
evidence fields, the relevant source passage for the matching question, empty
evidence for absent or stopword-only questions, and idempotent replacement of
an old unresolved interpretation. Ordinary maintenance must discover the gaps,
settle a grounded investigation, preserve missing evidence as unresolved, and
retain source text and vector bytes. Both VMs run these assertions.

## Bounded scale gates

`cmake/DurableBacklogProvider.cmake` accepts `CPRAG_CASES=concurrent`, an even
`CPRAG_CONCURRENT_ITEMS` from 2 to 10000 and an explicit
`CPRAG_COMMAND_TIMEOUT`. The default maintained case uses 40 decisions and
20 forced request pairs; the larger lane uses the same product commands,
10-item dispatch waves, two native workers and loopback-only credentials.
Every requested decision must reconcile with semantic output, exact calls and
zero unfinished items/reservations. A timeout is a failed gate, not completion.
`CPRAG_CONCURRENT_PORT` can isolate the larger fixture from the maintained
suite's default port. The 7 September candidate completed 5000 decisions and
2500 forced request pairs; exact evidence is in the reliability record.

`cmake/FullVolume.cmake` takes an explicit `CPRAG_SCALE_LIBRARY` copy and
`CPRAG_SCALE_PROFILE`, compiles `full_volume_scenario.crexx`, and runs both VMs.
It retrieves a frozen stored source vector through the full Scottish ANN index,
requires the original passage, reports candidate/row counts and checks the
incident's active catalogue lookup with zero provider calls. The external
full-size protocol also runs public verification, reviewed unchanged ingestion
and exact bidirectional source/vector/job/usage table comparison. Evidence and
the candidate hash belong in the reliability closure record.

These are bounded scale and fault gates. They do not substitute for the
separate multi-hour nightly soak, hosted-provider or non-macOS release gates.
