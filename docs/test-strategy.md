# Test strategy

The admission slice adds `native_admission`: a loopback response is held until
a peer reaches a deliberately narrower reservation ceiling in a scratch job.
It checks public waiting status, no failed/replacement worker, no phantom call,
unchanged policy and exactly four completed items/receipts/settlements after
release. `regression_ingest_capacity` checks each allowance dimension on both
optimized VMs, cancellation while waiting, invalid per-call caps, real
exhaustion and classification precedence. Existing maintenance deadline and
unknown-usage suites remain required controls.

The maintained suite tests the single shipping architecture rather than an old
implementation comparison.

The [REG-01 coverage baseline](regression-coverage.md) maps the prioritized
escape paths, new executable cases and remaining policy/qualification gaps.
Run the configure/build/full-test gate with one command:

```sh
cmake --workflow --preset regression
```

Known defect tests are included and remain red until repaired. The
`known-defect` label is descriptive; it does not invert or suppress failures.
The gate retains `cmake-build-debug/regression.log`. The individual commands
below remain available for focused development.

The [reliability coverage review](reliability-coverage-review.md) maps these
tests to operator outcomes and records the unproved crash, publication and
concurrency boundaries. A passing suite is necessary, but is not evidence that
unattended long-running maintenance is qualified. In particular, idle worker
launch is not concurrent work qualification, and provider success is not item
publication success. Dated trial records describe their own run status; they
are not instructions to resume a live library.

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
| `regression_prompt_contract` | Captured baseline system-prompt/schema hashes from actual extraction, resolution, answer and report calls; correction history and existing ingestion/query/maintenance assertions |
| `regression_prompt_inspection` | Native public inspection, both-VM contract builders, optional provenance schema, subject/workflow action rules, typed/MCP access and argument controls |
| `regression_claim_policy` | Both VMs: effective profile vocabulary, exact tokens, stance weights, version propagation, external overrides and compatibility/shared-factory equivalence |
| `linked_application` | installed `rxsqlite` provider mapping and both CREXX VMs |
| `configuration_contract` | format-1 compatibility, format-2/3 bounded settings, split identities, credential-free check/explain, identical/operational/prospective diff, tamper-resistant plan/apply, and a regression proving a provider-policy change leaves an existing corpus generation unchanged with zero new jobs or provider calls |
| `process_workers` | eight-worker registration before admission, failed-launch diagnostics, observation, drain, stale PID detection, explicit pruning |
| `worker_recovery` | native managed-process disconnects; bounded replacement and durable rolling restart history; no preflight phantom calls; public exact-turn inspection, stale digest and ambiguous-history holds, atomic reconciliation rollback, repeated settlement, completed-output reuse and bounded retry; OCR/multiple-citation feedback, uncalled correction deferral, advanced-reasoning handoff; admission-release diagnostics; a real receipt-write fault preserves completed Codex output and public reconciliation reuses it without another generation |
| `regression_supervision` | optimized two-VM rolling-window boundaries, burst expiry, restart before/after expiry, generic exit exclusion, temporary queue emptiness while peers own work, pause and competing process reservations |
| `native_supervision` | public aged-history recovery, zero-worker replenishment, parked status and cancellation, eight failed preflights followed by one recovery probe and restoration; exact calls and retained budgets; one bad task exhausts its own attempts while seven peers finish without replacement |
| `controller_recovery` | eight overlapping native Codex workers; one command recovers confirmed interruption and completed output, replaces optional-cleanup failure, isolates unavailable history, and keeps healthy peers running after three failures exhaust two replacements; exact call counts, unchanged budgets and released ownership |
| `gemini_ingestion` | Gemini request/response mapping, compact gap-free LF/CR/CRLF normalization maps, durable work, claims, embeddings, vector publication, replay and failure paths |
| `gemini_extraction_validation` | invalid UTF-8 spans, unknown concept/relationship types and malformed extraction output dead-letter without product mutation or secret disclosure |
| `provider_durability` | exact/conflicting raw response duplicates, reservation recovery, Codex turns, fencing, completed-turn reuse, durable cross-process admission, no false call record on preflight failure, immutable replay lineage, backlog reconciliation, and schema 1-to-14 migration with historic-cost backfill and prospective-transition auditing |
| `codex_protocol` | App Server initialize/account/turn/schema/usage/cleanup over JSONL; shared deadlines despite unrelated notifications and fragmented lines before and after submission; 17,000 account cycles exceed the old 65,535-ticket ceiling |
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
| `installed_product` | scratch-prefix installation, installed skills/tutorial, doctor/init/provider smoke/ingest/maintain/query using only installed product artifacts; maximum public pages, exact large-plan reads and Unicode retrieval |
| `temporal_provenance` | period precision/calendars, scoped metadata, stale conflicts and zero-call no-op, whole-packet assessment, selective claim qualification, receipt recovery, temporal paths and bounded answer context on both VMs with and without optimization |
| `quotation_grounding` | exact-first/Unicode casefold/whitespace grounding, original byte mapping, repeated spans and scoped endpoints on both VMs and optimization modes |
| `durable_backlog` | complete split/merge fan-out, claim conflict preservation and qualification, typed identities, retained-ID classification conflict repair and convergent follow-up extraction, manual census/resume, supervised review, stale-before/after-call rejection, settled-response crash/window recovery and zero-call SQLite embedding reuse, elapsed versus aggregate parallel time, fixed deadlines across worker restarts, explicit provider-time caps, midnight/late-start and daylight-saving resolution on both VMs |
| `durable_backlog_provider` | native guided maintenance through Gemini loopback: valid decisions, malformed responses, product-rejected quotations, redacted diagnostics, runtime configuration transitions; 40 resolutions with two workers and 20 forced overlapping request pairs, exact terminal accounting and unchanged source/vector state |
| `publication` | independent SQLite connections prove manifest ownership and reader/backup snapshots during uncommitted writes; batch/single-proposal rollback, cancellation, late/excess/duplicate usage, stale fences, final call and Codex-turn allowance; unchanged legacy folder URI identity, both VMs |
| `native_publication` | injected late SQL write failure; four chunks and two workers with forced overlapping requests, querying/backing up/restoring/verifying while each pair is held; exact semantic/usage reconciliation; missing-manifest recovery and provider-free restored queries |
| `embedding_recovery` | eight native workers, four embedding-only dispatch batches, durable 429 retries, paused extraction, exact call accounting, zero-call reconciliation, duplicate-link history and public verification |
| `embedding_exhaustion` | eight workers through 429/503 failures, six actual calls per embedding across controller restarts and new maintenance windows, retained incomplete coverage and settled reservations |
| `native_receipt_failure` | Abort the response INSERT after Gemini extraction/embedding returns; controller restart and public retry preserve original intent/usage, explicitly hold the lost response, finish the healthy peer and make no repeat call. |
| `native_receipts` | exit after durable extraction/embedding response but before settlement, then two-worker public restart: no repeated call, original-attempt usage, exact publication and no reservation leak |
| `native_interruption` | actual busy worker/controller kill with explicit uncertain intent, cancellation while provider response is held, post-commit manifest rejection and first-vector recovery without repeated extraction |
| `local_embedding_protocol` | llama.cpp-compatible `/v1/embeddings` and `/v1/chat/completions`, strict structured output, correction history, rejected malformed/schema-invalid/truncated generation with retained usage, restricted local privacy, local-compute charging, and 429 `Retry-After` plus 503 exponential retry on both VMs and compiler modes |
| `regression_pages`, `regression_page_max`, `regression_large_job` | complete ordered page traversal, exact 99/100 and 65,535/65,536 boundaries through human/JSON/NDJSON/MCP; the latter two retain the repaired UX-02 boundary cases |
| `regression_plan_detail` | 1.5-million-character summary, exact multibyte plan reconstruction, JSON/MCP paging, invalid/end cursors, mixed listings, zero calls and unchanged SQLite |
| `regression_result_contract` | Both optimized VMs: ADDRESS maximum review/event pages and full plan reads; extra-record validator negatives, existing task metadata, read access and Unicode planner terms |
| `regression_retry`, `regression_closed_retry` | Public five-item retry, CLI/MCP deduplication and retained history; completed-parent task requests keep closed windows intact; terminal replay and duplicate-lineage protection. |
| `regression_lifecycle` | Both optimized VMs: task-independent item/parent acceptance, original attempt ceilings, uncertain intent, live claim competition, explicit resume, pause during failed settlement, immutable requests and missing-policy holds. |
| `native_lifecycle`, `native_lifecycle_holds` | Five persisted closed-window failures recovered through public commands and fresh processes; retry beside a held loopback response; exact calls and history; exhausted/uncertain tasks remain held across another window. |
| `regression_retrieval`, `regression_retrieval_unicode` | independently specified passage/citation corpus, CLI/MCP agreement, UTF-8 offsets, zero calls/writes, absent terms and faithful OCR/uncertainty; indexed Unicode-name retention covers the QE-06 correctness repair |
| `regression_ingest_capacity` | deterministic owned reservation versus ordinary peer worker, five capacity dimensions, optimized code on both VMs; exposes OPS-004 without introducing timing races |

The Gemini tests always exercise the Gemini adapter and Google request/response
shapes through a deterministic local fixture. Report tests additionally prove
that refresh makes one advisory call, cache reads make zero calls, unknown
citations are rejected and the previous valid cache survives. Historic tests
prove that the guided lifecycle captures a first point, exact duplicates are
suppressed/coalesced, a cached narrative is associated by report digests, and a
one-point trend refuses to infer direction. The suite does
not silently substitute a different provider. This makes the default suite
repeatable and zero-cost.

The MCP read-only regression hashes SQLite around lexical inspection, overview,
task/job discovery, planning and missing-review preview. The durable backlog
scenario also exercises external escalation, stale/tampered plans, exact replay,
mandatory review, split fan-out without fabricated provider usage, worker-asserted
escalation, pending-review task ownership, and the distinction between repeated
content failures and transport/storage failures on both VMs. It also checks
complete evidence refresh beyond catalogue/byte ceilings, current and stored
inventory, stale/tampered plans, replay, preserved questions/history, ownership
exclusion, resolution acceptance and census retention. The Gemini maintenance
fixture compares file and inline proposal canonical plans and rejects malformed,
duplicate and competing inputs before normal apply/review. Real fresh-Codex trials are separate bounded acceptance
runs, using installed skills and actual MCP traffic on isolated synthetic
libraries; they are not replaced by a static tools-list or file-existence test.

The deadline regression closes a window while extraction is in flight and
requires its final worker to settle the durable task without another poll.
Repeated closed-window checkpoints preserve the deadline and make no calls.
The Codex application fixture reports 20,000 input tokens, verifies the
32,768-token default reservation, and preserves the full usage through its
existing interrupted-turn recovery test.

The publication gate also holds a separate SQLite writer until a heartbeat
reports its first busy retry, then releases it and requires the same heartbeat
to succeed with an empty error. Both VMs check bounded lock exhaustion, retained
constraint diagnostics, missing runtime rows and non-retryable stale snapshots.
The lock-release handshake does not depend on an assumed duration of work.

The CREXX repository owns the generic `rxsqlite` contract suite: typed values,
file databases, FTS, backup and integrity behavior, concurrent session
isolation, FULLMUTEX configuration, attached-task discovery, native packaging,
and installed external-consumer coverage. This suite does not duplicate those
driver tests. It proves that the linked, process-worker, backup, ingestion, and
installed native product paths consume the supported provider correctly.

## Live providers

Fresh external-agent trials complement deterministic regressions. The
[copied-soak trial](mcp-soak-trials.md) records real-corpus evidence quality,
task discovery, pagination and exact correction acceptance, including failed
or incomplete outcomes. Its Codex sessions consumed managed subscription
inference; the RAG server made no provider calls. Use frozen copies, fixed
prompts and before/after invariants when repeating those trials.

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
without any provider calls. The migration fixture retains the earlier schema-1/6/8 upgrades, checks
schema-13 task inspection, then opens that bundle through the ordinary write path and requires a schema-14 aligned manifest.

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
