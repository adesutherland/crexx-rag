# Test strategy

Job controls acceptance (15 September) is tracked in
[the checked delivery record](job-controls-delivery-20260915.md): deadline-only
CLI/MCP mutation, expired admitted completion, compact lists at all plan sizes,
and one/all-job count reset. Native loopback tests exercise maintenance and
embedding identity across repair jobs; both VMs exercise ordinary failure and
lease recovery. Exact Codex reconciliation also consumes reset-adjusted paid
counts. Provider calls in these fixtures are local synthetic calls only.
The completed candidate passes **79/79** local tests, including preserved timing
start and idempotent named renewal after expiry. Installation and corpus soak
qualification remain separate.

The [Test 7 overnight soak](test7-overnight-soak-20260914.md) ran on the Scottish
master through 06:00 BST on 15 September: embeddings-first imports, sustained
LLM/maintenance blocks, delegated curation, concurrent queries and engineering
repairs. Its functional results are recorded; two controller losses prevent
clean endurance qualification. The later master continuation was cancelled.
The [T7-10 checklist](t7-10-controller-diagnosis-20260915.md) now owns real-parent,
pipe and signal probes, graceful-drain acceptance and agent recovery guidance.
At the earlier T7-10 checkpoint, QA was **75/76**: only the separate PC-01
expired-window continuation case failed. New pipe/signal tests, existing
provider/recovery/retrieval checks and scratch installation passed. The combined
79/79 candidate above includes the subsequent PC-01 repair.

The first Test 7 repairs cover source include matching, returned proposal/review
IDs, useful validator diagnostics, indexed exact source/review lookup and
per-source backlog inspection. Their regression-first focused acceptance passes;
the expanded 73-test full local suite passed with zero failures (1437.92 seconds
on the shared machine, session 95038). The repaired package was installed at
23:45 BST after the first block drained; fresh CLI status passed at generation
24640. T7-01/03/04/05 caller checks pass; T7-02 awaits a naturally valid new
external proposal and final repaired-build endurance remains pending.

Subsequent T7-06/07 fixes add held-outcome selection and source-scoped durable
maintenance. Their combined full suite passes **74/74** in 1045.12 seconds;
the tested native `eb74de625d11fbb2f5416385a0c3e7a43dbe48885734e5198d2486e202747fcc`
was installed at 00:54 BST after Boswell's embedding phase drained. Fresh CLI
status passes at generation 24641. Live source-window results and final soak
qualification remain pending.
Routine soak monitoring is light;
missing product observability is repaired instead of replaced by manual tracking.

The [Test 6 agent functional checklist](test6-agent-functional-20260914.md)
extends the completed smoke/acceptance journeys into capability coverage and
Scottish-instance prompt tuning before soak testing. It separates generic
fixture qualification, actual agent tool use and a bounded configured-model
pilot; a prepared prompt is not a measured improvement.

The [committed-baseline Tests 1–5 repeat](smoke-tests-1-5-20260914.md) ran on
`696858c` with the unchanged 71/71-qualified artifact. Publication, retry,
selected replay and 59 provider-free MCP requests pass; final verification
has zero issues and complete vector coverage. The report separates operational
acceptance from the rejected maintenance choice, unresolved decisions and
figurative-place content finding. Shared-computer CPU observations remain
measurements, not elapsed-time acceptance gates.

The [Test 5 MCP smoke](test5-mcp-qa.md) now owns ordinary agent access, search,
relationship follow-up, citation paging, assistant-composed answers and local
performance characterization. The 14 September run passed 56 actual JSON-RPC
requests with zero RAG provider calls; explicit path tests alone recorded one
normal gap. Test 4 remains extraction/replay. On a shared computer, collect
server CPU, work/result counts and response bytes; elapsed times are observations,
not acceptance thresholds. Its approved follow-up raises the optional passage
maximum to 200 while retaining default 12, removes vector preparation from
lexical routing and simplifies shared setup guidance. A fourth-ranked useful
passage is a coverage observation, not itself a demonstrated ranking defect.
Regression coverage includes actual 200-passage retrieval and exact citations,
public 200/201 boundaries and lexical independence with hybrid refusal controls.
Final follow-up qualification passes **71/71 local tests** and 59 actual MCP
requests with zero provider calls; all workplan items are complete.

Test 4 replay compatibility is qualified by **71/71 local tests** and a bounded
live Nairn replay under normal configuration. Source/role selection regressions
retain incompatible selected-work and immutable-lineage controls. Captured bad
and corrected responses exercise the complete validator. Live model proposals
still require source-meaning review: the correct claim was published and two
incorrect proposals were held and rejected through existing review controls.
See [the completed checklist](test4-repair-delivery-20260914.md).

Latest publication follow-up: `embedding_publication` reproduces RAG-SMK-006's
partial ancestral index failure and now passes with four existing controls
(**5/5 in 52.41s**). Full QA passes **68/68 in 944.08s**, with a passing
matching scratch-installed replay on CREXX `g037e7939bc29`. See the
[publication repair record](smk006-publication-repair-20260913.md).

Current checkpoint: the four smoke-status and simple-restart regressions now
pass after shared-owner repairs. They first failed against unchanged product
code; branch coverage was extended before implementation. The final focused
panel is 9/9; the full suite passes **67/67 in 932.92 seconds**, and the
separate scratch-installed replay passes **5/5**. See
[the repair record](four-smoke-fixes-20260913.md). All assertions remain ordinary
required passes. Known-defect tests must never be disabled or inverted to make
a gate green.

The five maintenance refactors each required coverage before implementation
and a complete green gate. That historical local workflow passed **59/59**; the
[delivery record](maintenance-refactoring-delivery.md) retains baseline failures,
per-stage evidence and the limits of that qualification.

The admission slice adds `native_admission`: a loopback response is held until
a peer reaches a deliberately narrower reservation ceiling in a scratch job.
It checks public waiting status, no failed/replacement worker, no phantom call,
unchanged policy and exactly four completed items/receipts/settlements after
release. `regression_ingest_capacity` checks each allowance dimension on both
optimized VMs, cancellation while waiting, invalid per-call caps, real
exhaustion and classification precedence. Existing maintenance deadline and
unknown-usage suites remain required controls.

The maintained suite tests the single shipping architecture rather than an old
implementation comparison. Corpus-scale recovery checks must also inspect
access paths: small correctness fixtures missed repeated full review scans
inside a maintenance writer transaction. `provider_durability` now seeds
30,000 questions/5,000 reviews and checks indexed access plus review-hold
semantics on fresh and upgraded stores, without a machine-speed timeout test.

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

The [Test 2 repair checklist](test2-recovery-delivery-20260914.md) adds native
`test2_completion` fault injection, ordinary terminal job completion retry and
ANN availability during unrelated changes. Its baseline failures and current
qualification are recorded there.

Its A8 follow-up covers index dirty-marker invalidation, transaction rollback,
changed training settings, unchanged and forced retries, failed builds and
same-count membership changes without new embedding timestamps. ANN methodology
retains corrupt/missing-sidecar, graph-only, branch rollback and replacement
controls on both VMs. Full-corpus timings use the disposable Test 2 copy without
provider calls.

## Default matrix

| Test | Main assurance |
| --- | --- |
| `regression_prompt_contract` | Captured baseline system-prompt/schema hashes from actual extraction, resolution, answer and report calls; correction history and existing ingestion/query/maintenance assertions |
| `regression_prompt_inspection` | Native public inspection, both-VM contract builders, optional provenance schema, subject/workflow action rules, typed/MCP access and argument controls |
| `regression_policy_file` | Native CLI/MCP: bounded validated set/replace, stale hashes, invalid-policy repair, prompt-source switching, destination-relative references, same-session reload, removed-profile refusal, lock conflict and retry after a killed owner, unchanged complete library dump |
| `regression_policy_file_vm` | Both VMs: config positive control, explicit `true` value parsing, direct file inspection/edit, competing SQLite connection, unchanged semantic identity for operational edits, exact no-op/stale hashes and access refusal |
| `regression_claim_policy` | Both VMs: effective profile vocabulary, exact tokens, stance weights, version propagation, external overrides and compatibility/shared-factory equivalence |
| `linked_application` | installed `rxsqlite` provider mapping and both CREXX VMs |
| `configuration_contract` | format-1 compatibility, format-2/3 bounded settings, omitted/explicit worker defaults and typed bounds, split identities, credential-free check/explain, identical/operational/prospective diff, tamper-resistant plan/apply, and a regression proving a provider-policy change leaves an existing corpus generation unchanged with zero new jobs or provider calls |
| `process_workers` | eight-worker registration before admission, failed-launch diagnostics, observation, drain, stale PID detection, explicit pruning |
| `worker_recovery` | native managed-process disconnects; bounded replacement and durable rolling restart history; no preflight phantom calls; public exact-turn inspection, stale digest and ambiguous-history holds, atomic reconciliation rollback, repeated settlement, completed-output reuse and bounded retry; OCR/multiple-citation feedback, uncalled correction deferral, advanced-reasoning handoff; admission-release diagnostics; a real receipt-write fault preserves completed Codex output and public reconciliation reuses it without another generation |
| `regression_supervision` | optimized two-VM rolling-window boundaries, burst expiry, restart before/after expiry, generic exit exclusion, temporary queue emptiness while peers own work, pause and competing process reservations |
| `native_supervision` | public aged-history recovery, zero-worker replenishment, parked status and cancellation, eight failed preflights followed by one recovery probe and restoration; exact calls and retained budgets; one bad task exhausts its own attempts while seven peers finish without replacement |
| `controller_recovery` | eight overlapping native Codex workers; one command recovers confirmed interruption and completed output, replaces optional-cleanup failure, isolates unavailable history, and keeps healthy peers running after three failures exhaust two replacements; exact call counts, unchanged budgets and released ownership |
| `gemini_ingestion` | Gemini request/response mapping, compact gap-free LF/CR/CRLF normalization maps, durable work, claims, embeddings, vector publication, replay and failure paths |
| `gemini_extraction_validation` | invalid UTF-8 spans, unknown concept/relationship types and malformed extraction output dead-letter without product mutation or secret disclosure |
| `provider_durability` | exact/conflicting raw response duplicates, reservation recovery, Codex turns, fencing, completed-turn reuse, durable cross-process admission, no false call record on preflight failure, immutable replay lineage, backlog reconciliation, and schema 1-to-16 migration with historic-cost backfill and prospective-transition auditing |
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
| `address_surface` | File-bound prompt freshness, invalid-policy holds/repair, changed config identity, removed profiles and the function interface on both VMs; linked `ADDRESS RAG` report/trend/session/config/access behavior and snapshot denial on both VMs |
| `gemini_provider_smoke` | generation and embedding smoke, human/JSON/MCP, cancellation, aggregate budget, malformed output, secret redaction |
| `documentation_contract` | all five skill instruction tool names are declared in their manifests; declared tools and required capabilities match the shipping command catalogue |
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
| `native_interruption` | actual busy worker AND controller kill with explicit uncertain intent, cancellation while provider response is held, post-commit manifest rejection and first-vector recovery without repeated extraction |
| `regression_controller_loss` | controller-only kill while the first provider response is held; child must not take further work and must exit; initial live group, queued peer and final integrity checks |
| `regression_restart_live` | ordinary job run with a surviving group must clean/start fresh; repeat continuation after drain preserves complete attempts/receipts/claims/embeddings and starts fresh children |
| `regression_smoke_stale_workers` | CLI/MCP exclude confirmed exited workers from live count; known-live, empty-group and public PID controls; complete SQLite dump unchanged |
| `regression_smoke_terminal_state` | CLI/MCP status/list/report agree on drained deadline outcome; running, intentional pause, uncertain outcome and complete controls; complete SQLite dump unchanged |
| `local_embedding_protocol` | llama.cpp-compatible `/v1/embeddings` and `/v1/chat/completions`, strict structured output, correction history, rejected malformed/schema-invalid/truncated generation with retained usage, restricted local privacy, local-compute charging, and 429 `Retry-After` plus 503 exponential retry on both VMs and compiler modes |
| `regression_pages`, `regression_page_max`, `regression_large_job` | complete ordered page traversal, exact 99/100 and 65,535/65,536 boundaries through human/JSON/NDJSON/MCP; the latter two retain the repaired UX-02 boundary cases |
| `regression_plan_detail` | 1.5-million-character summary, exact multibyte plan reconstruction, JSON/MCP paging, invalid/end cursors, mixed listings, zero calls and unchanged SQLite |
| `regression_result_contract` | Both optimized VMs: ADDRESS maximum review/event pages and full plan reads; extra-record validator negatives, existing task metadata, read access and Unicode planner terms |
| `regression_retry`, `regression_closed_retry` | Public five-item retry, CLI/MCP deduplication and retained history; completed-parent task requests keep closed windows intact; terminal replay and duplicate-lineage protection. |
| `regression_lifecycle` | Both optimized VMs: task-independent item/parent acceptance, original attempt ceilings, uncertain intent, live claim competition, explicit resume, pause during failed settlement, immutable requests and missing-policy holds. |
| `native_continuation`, `native_continuation_holds` | Same-job named allowance renewal, deadline/idempotence, compatible worker-count registration, CLI/MCP parity, immutable original history and usage, retained uncertain/exhausted tasks and public completion. |
| `native_legacy_retry_ceiling`, `native_embedding_retry_policy` | Actual old one-attempt quota failure under a later reviewed ceiling; explicit six-attempt embedding policy takes precedence over a one-attempt reasoning policy, while paid history still counts. |
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
schema-13 and schema-14 task inspection with retained retry history, then opens that bundle through the ordinary write path and requires a schema-16 aligned manifest.

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
index, verifies retrieval and backup, retains valid members across source/embedding changes,
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

`regression_operator_diagnostics` protects the domain-service refactor's public
operator reads: job/subject filters precede pagination, 100-row pages continue
without omissions, exact canonical labels preserve homonyms and Unicode,
unknown arguments fail, native CLI and MCP return the same rows, and the full
scratch-library dump remains unchanged. Existing query/report, snapshot,
recovery and installed-surface journeys remain required for service changes.

`regression_command_metadata` freezes the complete advertised read/all tool
contracts before catalogue changes. `regression_command_arguments` exercises
native MCP booleans, bounds, enums, lengths, required fields, oneOf, unknown and
duplicate arguments, with an identical scratch database dump before/after.
`regression_command_catalogue` checks both VMs, capability inheritance, operation
recognition and literal forwarding of option-like caller text. Existing native,
ADDRESS, installed-product and provider journeys validate service behavior.

### Loopback fixture lifetime

The shared `tests/provider_fixture.cpp` server permits a bounded sixty-second
idle interval between requests so local library preparation and scenario
compilation do not masquerade as provider failures under build load. Its
embedding-exhaustion case retains its explicit 120-second interval; zero-outbound
checks retain their one-second window. This harness lifetime is independent of
product request timeouts and retry/backoff policy. `native_surfaces` deliberately
delays preparation for eleven seconds to protect this boundary. Exact request
counts, malformed-output, timeout and coverage assertions remain required.

## Public recovery follow-up

`native_lifecycle` and `native_lifecycle_holds` exercise actual counts, bounded
intervals and provider totals in active/terminal observations, public report
reconciliation, CLI/MCP waiver and retry, active ownership/access/reason denial,
unknown outcomes, retained ceilings and missing coverage. `regression_lifecycle`
checks immutable waiver/reopen cycles; `provider_durability` checks read-only
13/14 compatibility and ordinary migration to 16 without rewriting history.
`durable_backlog` adds legacy retired-parent reconciliation on both VMs and the
native command path. `durable_backlog_provider` uses real correction outcomes
to check public requested/processed correction counts. Required baseline reds
and final exact-artifact results are in [the recovery record](public-recovery-journey.md).

The [Scottish acceptance repairs](acceptance-repairs-20260914.md) extend these
tests with empty incomplete embedding runs and run-ID inspection. Native
`embedding_exhaustion` also checks atomic item/call limits and an embeddings-first
positive control. `durable_backlog` and `regression_ingest_capacity` cover zero
monetary routes, independent subscription/local work, and positive paid controls.

For local wall-time qualification on a Mac that may enter idle sleep,
`caffeinate -i ctest --preset debug --output-on-failure` keeps the host awake
only for that test process. It changes no product or CTest timeout. A real
392-second idle sleep interrupted the recovery follow-up's first full run;
retain that failure and repeat the full gate on the unchanged artifact, rather
than interpreting a suspended host as an ordinary concurrency measurement.

## Complete operator continuation follow-up — 12 September

Run all 63 registered cases for this public-command/schema/recovery change.
The default matrix above names the four new continuation and legacy-ceiling
cases. The [coverage matrix](regression-coverage.md#complete-operator-continuation-follow-up--12-september)
records their required failing reproductions and independent assertions.
Qualify a scratch-installed exact binary through the same continuation/held
journey, then record the real Scottish run separately. Follow the
[persistent handoff](operator-continuation-handoff.md) for the current gate;
do not confuse a historical 59-test milestone with this candidate's result.

Qualification checkpoint 2026-09-12 21:54 UTC: build 7 passed the full **63/63** suite
in **848.41 seconds**, plus the scratch-installed continuation/held journey.
The isolated full-corpus copy rehearsal reconciled both interrupted turns
without generation calls; provider-run count stayed 20809 and uncertainty
became zero. Incomplete usage remains a lower bound. The exact hashes and
logs are in the [handoff](operator-continuation-handoff.md). At that historical
checkpoint, actual processing-master ingestion and maintenance were still
required; the completed live evidence is linked below.

Schema-17 repair qualification: full **63/63 in 847.44 seconds**. The new
scale/fresh/upgrade controls pass alongside worker, provider, publication and
installed-product regressions. The repaired bounded maintenance smoke subsequently passed: exit 0, all eight
workers drained, one recovered timeout and no held uncertainty. See the
[final report](operator-continuation-smoke-20260913.md) for its actual 56m55s
worker runtime, retained holds and remaining status defects.

The T7-07 source-control regression (`regression_source_maintenance`) verifies
public CLI and MCP plan/apply scope before census/dispatch bounds, late-sorting
new-document chunks, source-local embedding completion, held task preservation,
out-of-source retry exclusion, and resumption of ordinary backlog. Its baseline
passed the unscoped priority control and failed source planning before repair.
`durable_backlog` separately verifies existing continuation preserves source
scope, deadline and allowance. This is zero-outbound scheduling/state coverage;
source content quality and the overall overnight block remain separate live gates.

T7-08 extends `worker_recovery` reconciliation with source and budget changes
after the original turn, including a lower selected attempt limit. Inspection
must retain its original digest without database writes; wrong provider identity
must fail. Apply preserves the retained job policy, atomic settlement and usage,
and repeated apply remains a no-op. Normal execution still rejects a changed
request configuration before claiming work. Its baseline passes original-config
inspection and route rejection, then fails changed-config inspection with exit 6.
