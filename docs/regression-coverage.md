# Regression coverage baseline — REG-01

Current Test 2 follow-up: [action checklist](test2-recovery-delivery-20260914.md).
The existing provider, publication, store and retrieval owners now implement
independent item/search availability and ordinary completion retry. Qualification
is complete: focused 5/5, live Test 2 pass, and all 71 local checks pass after
the reviewed metadata-fixture correction. The checklist retains exact results.

SQL review implementation is tracked in the [delivery checklist](sql-performance-delivery-20260913.md).
Its clean product baseline passed 69/69 in 943.87 seconds. New acceptance covers
fresh/upgraded SQL access paths, legacy JSON, unrelated-job recovery isolation,
active admissions older than the rate interval, numeric-row error cleanup,
FTS duplicate parity, native page boundaries, strongest-occurrence ranking and
workflow connection progress across publications. Final focused QA passes
**4/4 in 25.51 seconds**; full acceptance passes **70/70 in 919.24 seconds**.
The final native corpus smoke and complete report also pass with no hosted calls.


Latest simplification: the [repair](rule-simplification-repair-20260913.md) adds
`regression_rule_simplification` for prospective policy beside historical/queued
jobs, stable repeated cancel, completed-task diagnostics and one-source ingest.
Both-VM lifecycle and native maintenance tests cover explicit redo with retained
history. The final complete suite passes **69/69 in 901.87 seconds**. The terminal
controller case also covers reconciliation followed by prepared continuation. Interrupted
request controls now distinguish automatic restart from an explicit redo.

Latest publication follow-up: `embedding_publication` reproduces RAG-SMK-006's
partial ancestral index failure and now passes with four existing controls
(**5/5 in 52.41s**). Full QA passes **68/68 in 944.08s**, with a passing
matching scratch-installed replay on CREXX `g037e7939bc29`. See the
[publication repair record](smk006-publication-repair-20260913.md).

The [maintenance refactoring delivery](maintenance-refactoring-delivery.md)
extends this gate at each new owner. Stage 1 adds `regression_claim_policy`,
characterized against the pre-refactor implementation on both VMs before
sharing the factory. All earlier regression cases remain required.

Stage 2 adds `regression_prompt_contract` for captured effective provider
messages/schemas and `regression_prompt_inspection` for public and direct
contract boundaries. Its baseline and final gate are recorded in the same
delivery record; golden data was captured before product changes.

## Current status — 13 September 2026

The user subsequently authorized all four repairs. The shared status readers and
simple controller cleanup/start behavior are implemented in this checkout.
The extended baseline failed all four cases before product changes. The final
focused panel passes **9/9 in 67.06 seconds**, including original
interruption and continuation/retry controls. Earlier both-VM supervision and
lifecycle controls also pass in the final full suite. The full suite passes **67/67 in
932.92 seconds**; the separate scratch-installed replay passes **5/5**.
[The repair record](four-smoke-fixes-20260913.md) owns exact artifact hashes,
retained logs and qualification boundaries. No known-defect assertion was disabled or
inverted; the four resolved labels were removed.

Additional branch controls cover selected-group isolation (including unrelated
live and terminal rows), PID-zero reservations, refusal of remote ownership
without mutation, startup controller death and loss of the parent foreign-key
link before a real claim. Direct and managed caller controls remain required.
Remote and PID-zero status observations stay unverified. The installed CREXX
probe cannot distinguish absent from inaccessible PIDs; cross-account and
non-macOS behavior remain outside this local qualification.

## Historical test-only baseline — 13 September 2026

This is the test-only checkpoint requested before a new implementation session.
Checkout: `crexx-rag-review`, branch `temp/project-review`, product/evidence HEAD
`9292c8d8d724b52fce34047c868f15531348faca` (product implementation `1edb325`).
Native SHA-256:
`02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5`.
The configure step passed and the build reported `ninja: no work to do`.
Only instructions, documentation and test registration/fixtures have changed.

Before adding tests, the affected existing panel passed **6/6 in 129.55 seconds**:
`regression_operator_diagnostics`, `regression_supervision`, `native_interruption`,
`controller_recovery`, `provider_durability` and `codex_protocol`. Names alone
had hidden gaps: the old kill case killed controller AND workers, and the old
status cases did not compare the final drained state across readers.

| Requirement | Executable regression and independent controls | Baseline result / next acceptance |
| --- | --- | --- |
| RAG-SMK-004: stale workers called live | `regression_smoke_stale_workers`: CLI/MCP job status, public PID inspection, known live runner (fresh and old heartbeat) and synchronously exited process, empty group, SQLite integrity and exact read-only dump | Fails: confirmed exited worker counted as 1 live worker instead of 0. Healthy, stale-but-alive and empty groups pass. Repair shared supervision facts; do not equate inaccessible with absent. |
| RAG-SMK-005: disagreeing final states | `regression_smoke_terminal_state`: CLI/MCP status/list/report for a drained deadline job; running, intentional pause, unknown-outcome hold and complete controls; exact read-only dump | Fails: list says paused instead of completed_with_errors; report counts 4 active jobs instead of 3, including the drained job. Status and controls pass. Share lifecycle projection without losing real pauses/holds. |
| OPS-001/004: child outlives controller and keeps taking work | `regression_controller_loss`: real registered controller/child, one provider response held on a FIFO, one queued peer; kill ONLY controller, release response, inspect attempts and actual child exit | Fails: attempts rise from 1 to 3 after controller loss. Child eventually exits, but has taken more work. Require no new claim once the controller is gone; no perfect recovery of the interrupted response is imposed. |
| OPS-001/004: routine restart rejects surviving ownership | `regression_restart_live`: invoke ordinary job run while the first response is held; inspect new controller, old child exit and reservations; repeat ordinary continuation after drain and compare complete attempts/receipts/claims/embedding rows | Fails: job run returns 6 and no fresh controller is created. Repeated continuation after the old group drains is a control; it must create fresh children without repeating completed work. |

All four use ordinary assertions and remain in the full gate. `known-defect`
is a descriptive label, never `WILL_FAIL`, a skip, or a substitute for passing
setup controls. Process tests use only their freshly created scratch library's
registered PIDs. Providers are bounded localhost fixtures with synthetic keys;
there are no hosted calls or changes to the Scottish master or selected policy.
Scratch SQL constructs/observes test state; operators still use public commands.

**Full suite: 63/67 pass in 879.91 seconds; exactly the four new regressions
fail. All 63 pre-existing tests pass.** A final focused repeat, including the
strengthened stale-but-alive/listing controls, passes the original interruption
and documentation gates and reproduces all four defects again (2/6, 15.28s).
The full gate is red, with no unexplained failures. Retained logs and final
fixture hashes are in [the test evidence directory](qa/restart-coverage-20260913/).
Product code is unchanged; no repair or new live qualification is claimed.

### Coverage retained and remaining limits

- RAG-SMK-001 already has active-submission versus unknown-hold assertions in
  `regression_operator_diagnostics`. RAG-SMK-002 has fragmented UTF-8 and malformed
  framing controls in `codex_protocol`. Do not replace these with success-only
  provider checks.
- RAG-SMK-003 already has 30,000-question/5,000-review fresh/upgrade query-plan and
  semantic checks in `provider_durability`. This guards the reproduced scan
  escape. It does not prove a maximum census writer duration; profile the
  remaining contention before selecting a change or a timing expectation.
- `native_legacy_retry_ceiling` and `native_embedding_retry_policy` cover the old
  one-attempt failure and explicit embedding-six/reasoning-one policy boundary.
  Higher-policy execution on the actual five Scottish items remains unperformed;
  that is live acceptance, not a missing synthetic retry test.
- Existing cancellation, lost/durable receipts, unknown outcomes, exhausted
  allowance and fresh/upgrade recovery cases remain required. The simple
  restart must compose these existing rules rather than replace them.
- The new process tests cover the launcher's local permission domain. Selected
  group isolation, permission errors and the exact PID representation need
  branch-specific controls before implementation changes those areas. These
  are declared extension points, not claims of cross-platform qualification.
- Retained content failures need independently adjudicated valid/invalid source
  fixtures before prompt or validator changes. Existing quotation and workflow
  negatives remain passing controls; a rejected model response is not evidence
  that validation is wrong. No correctness oracle for all 521/100 content holds
  has been invented here.

The requested first coverage increment is complete. The product defects and
remaining roadmap acceptance are still open. Start the next
session with the [handoff](operator-continuation-handoff.md) and make the
specific failing acceptances pass without weakening the controls.

## Historical status — 12 September 2026

The third follow-up extends native recovery with actual denominators, interval
usage, CLI/MCP waiver/reopen, active-work/access/reason denial, unchanged missing
coverage and retained uncertainty. Both-VM owner tests cover immutable history
and schema-14 compatibility; workflow recovery also uses native discovery and
reconciliation. Real correction provider fixtures assert public outcome counts.
See [the public recovery evidence](public-recovery-journey.md) for the test-first
baseline and final qualification. Its full gate passed **59/59 in 1238.52 seconds**,
following host-sleep/load timeouts and unchanged complete reruns.

UX-04 adds public workflow census and external retirement cases to
`durable_backlog`, including CLI/MCP parity, explicit generation, access,
review/ownership/uncertainty holds and idempotence, including legacy publication.
Its clean final gate passed **59/59 in 805.49 seconds**;
see [the workflow evidence](external-workflow-recovery.md).

UX-03 extends `durable_backlog` with support/claim/conflict effect assertions,
public human/JSON review previews, legacy immutable actions, stale acceptance
and bounded complete effect lists. Baseline positive controls and the intended
red assertions preceded implementation; see [the evidence](connection-effect-previews.md).
The post-change full gate passed **59/59 in 758.92 seconds**. The figures below
retain earlier results; this records the UX-03 checkpoint; the later UX-04 checkpoint is above. The
frozen installed replay is now recorded in the third follow-up above; independent fresh-operator acceptance remains open.

All five maintenance refactors are complete. The final full workflow passes
**59/59 in 737.26 seconds**, including every original defect test and the new
policy/transport boundaries; see the [stage evidence](maintenance-refactoring-delivery.md).
An earlier stage-5 run had three timing failures under concurrent machine load;
those failures and their unchanged-limit replays are retained in that record.
The following 50-test result records the earlier public-result repair.

The complete review baseline and regression workflow are committed in `5d1481a`.
Steps 5a/5b and 6 implement the three original failing acceptances. The
[repair record](public-result-lexical-repair.md) records their test-first
baseline, additional public/ADDRESS/installed checks and final qualification.
The complete workflow passed **50/50 tests in 654.74 seconds**, including the
two new result/detail cases and all three former failures. The matched native
SHA-256 is `a571e3d7c90fc115c43e236094101a527b8f5128282d865eab5479c08473b6a8`.
Full log: `/tmp/crexx-rag-results-full.log`. Resolved known-defect labels were removed; all tests still use ordinary
pass/fail assertions.

## Status before steps 5–6 — 12 September 2026

Product HEAD: `8e4f5a8413e289374408491dfc01dbb904ff0153`,
`temp/project-review`. The last full step-4 run passed **45/48 in 620.61
seconds**. All 41 tests registered in the committed tree passed. Seven further
review tests, their fixture support and the regression workflow still have
uncommitted changes; those seven add four passes and the three failures below.
The complete working-tree gate is **red**, regardless of the narrower result.

Fresh verification on the same native artifact ran:

```sh
ctest --preset debug --output-on-failure \
  -R '^regression_(pages|page_max|large_job|retrieval|retrieval_unicode)$' \
  --output-log /tmp/crexx-rag-status-review-targeted.log
```

Result: **2/5 passing in 32.11 seconds**, exit 8. `regression_pages` and
`regression_retrieval` passed. Each failing test also passed its own positive
controls before reproducing the intended defect:

| Failure | Confirmed behavior | Next acceptance |
| --- | --- | --- |
| `regression_page_max` | 99 reviews plus cursor succeed; 100 plus cursor exceed the 100-record bound in human/JSON/NDJSON/MCP | Step 5a: complete bounded traversal at the advertised maximum, including ADDRESS and installed copy |
| `regression_large_job` | A 65,535-character plan renders; 65,536 fails even at page size one in all four transports | Step 5b: stable bounded summaries and exact separately retrievable complete plan detail |
| `regression_retrieval_unicode` | Direct FTS finds `Élodie` and `東京`, but the quoted JSON/MCP queries return no passage; source/citation, zero-call and zero-write controls pass | Step 6: Unicode-safe query planning and existing lexical/evidence invariants |

Native SHA-256, freshly matched to the full-run artifact:
`60ad3f965c2704e069019fcf9680704adc733b38a258b6fe1f8418fd973fee0c`.
The previous complete log is retained at
`/tmp/crexx-rag-stage4-final-full.log`; the focused run does not substitute for
another full-suite execution. No product or test implementation changed during
this status review. See the [numbered plan](recovery-implementation-plan.md)
for the explicit next stages and the requirement to retain the complete gate
in version control. Later qualification sections below preserve dated results.

## Running the gate

This is the executable starting point for the repair work. It combines the
existing recovery and publication tests with new public-boundary tests and a
small independently specified retrieval corpus. The original baseline below
precedes product repairs; subsequent step-1–4 qualification is recorded below.

Run from the repository root, with the installed CREXX package available:

```sh
cmake --workflow --preset regression
```

The workflow configures Debug, builds the product and fixtures, and runs **all
tests, including known defects**, with serial CTest execution because existing
loopback fixtures reuse fixed ports. Individual concurrency cases still run
their intended overlapping workers. It needs CMake 3.25 or later, as does the
existing version-6 preset file. `ctest --preset debug` also includes the defect
tests. No expected-failure inversion, disabled tests or automatic exclusions
are used. A nonzero result remains a failed gate and must not be presented as
release readiness.

The retained test log is `cmake-build-debug/regression.log`; detailed CTest
output is in `cmake-build-debug/Testing/Temporary/LastTest.log`. Each new native
case retains its executable hash and command output under
`cmake-build-debug/test-regression-*`. The admission case retains compilation
and both VM logs. These are disposable generated artifacts, overwritten on a
rerun. Copy them before another run when retaining evidence for a repair.

For iteration, `ctest --preset debug -R '^regression_' --output-on-failure`
runs the twelve currently registered cases with that prefix, including lifecycle
and supervision added after REG-01. It excludes the native recovery cases and
other required controls, so this narrower panel is not the complete gate.
The workflow makes no hosted calls. The provider suites use local fixtures;
the new public cases remove their credential environment variable and never
start workers or a provider service.

## Original recorded run — 11 September 2026

`cmake --workflow --preset regression` completed configure and build, then
ran **41 tests in 495.38 seconds: 36 passed, five failed**. All 33 pre-existing
tests passed. The failures are exactly `regression_page_max`,
`regression_large_job`, `regression_closed_retry`,
`regression_retrieval_unicode` and `regression_ingest_capacity`, with the
positive controls and intended diagnoses described below. The workflow exits
8; it is not a passing release gate.

Product baseline: `df9649d7ae18fcc74a40616f5ff9b515f86b382b`, with these
uncommitted test/documentation changes in `temp/project-review`.
Installed CREXX: `crexx-1.0.0-beta.3+local.g5ccf057a1633`. The native executable
is unchanged from the review baseline, SHA-256
`6ab6af6e5709eb21ff81dd5f31d7407883d6a9de5c7417af6d1168cca3f3d47c`.
The initial focused run also reproduced all five failures. The final run
includes the additional successful replay control before the terminal-parent
failure. No product implementation was changed, and no commit, push, hosted
call, user-library mutation or global installation was performed.

## Admission repair — step 1

The [admission repair](admission-recovery.md) passed its focused panel:
**5/5 in 48.15 seconds** (`provider_durability`, `durable_backlog`, `publication`,
`regression_ingest_capacity`, `native_admission`). Both optimized VMs pass the
capacity positive control, five pressure dimensions, invalid-cap, consumed-budget
and cancellation controls. The new module checks classification precedence.
The native held-response case completes all four items with no failed/replacement
workers, no phantom call, unchanged policy and exact response/reservation/settlement
counts. Public `waiting_reason` appears during pressure and clears on completion.

The native executable SHA-256 is
`6c802036f40b02fb6d6bb2635925ff0055e1272e459f2543acdef97303e5c251`;
the installed CREXX identity remains `crexx-1.0.0-beta.3+local.g5ccf057a1633`.
The complete workflow then passed **38/42 in 493.45 seconds**: all 33 original
checks, both admission checks and three other review controls passed. The four
remaining failures are `regression_page_max`, `regression_large_job`,
`regression_closed_retry` and `regression_retrieval_unicode`. They are outside
this admission slice and remain required, ordinary failing tests; the complete
review gate exits 8. Step 1 is qualified, but the full review gate is not green.

## New executable coverage

| Test | Independent assertions and baseline expectation | Register/owner |
| --- | --- | --- |
| `regression_pages` | Traverse all 101 ordered reviews with limits 1, 20 and 99; no omitted, repeated or reordered identities; cursor terminates. Positive 99-row boundary in human/JSON/NDJSON/MCP, invalid limits rejected, integrity and zero provider calls. | OPS-003, UX-02, HC-33/34; `ragproduct`, `ragrepository`, `ragcommand`, MCP |
| `regression_page_max` | After each transport's successful 99-row control, request the advertised maximum of 100 from 101 reviews. Requires success with all 100 rows and a cursor. The original failure was cursor record 101; step 5a now permits the bounded cursor in addition to all data rows. | UX-02; same owners |
| `regression_large_job` | A valid retained JSON plan of 65,535 characters renders on a one-job page. One extra character must not make the job undiscoverable. Step 5b keeps both sizes discoverable through human/JSON/NDJSON/MCP and provides exact paged detail. The earlier test of a `canonical_plan` field did not exercise this repository `value` field. | UX-02, HC-34; `ragrepository`, `ragcommand` |
| `regression_retry` | Public retry of five dead letters, including after the first retry changes the parent to queued; read-only access cannot mutate; repeated submission cannot duplicate work/events; original attempts, fences, input hashes and diagnostics survive; no calls or reservation leakage. | OPS-001/002, MNT-002/003; `ragwork`, `ragproduct` |
| `regression_closed_retry` | The same positive retry control plus five failed tasks linked to a closed window under a completed parent. Step 2 now accepts the task request without reopening the window, preserves original history, supports terminal-parent replay, and rejects active/completed replay descendants through CLI/MCP. | OPS-002; job/task/window boundary |
| `regression_retrieval` | Six frozen questions, including an absent term, against six small synthetic documents; exact expected passage text, CLI/MCP citation agreement and citation resolution, original UTF-8 offsets, no fabricated graph claims, zero provider calls, unchanged complete SQLite dump. OCR spelling and uncertainty must survive intact. | QE-03/06/09; query, evidence, citation surfaces |
| `regression_retrieval_unicode` | Runs the same positive controls plus quoted `Élodie` and `東京`. Direct FTS probes independently prove each name is indexed. Both names failed through CLI/MCP at baseline. Step 6 retains them, with quoted/unquoted, uppercase/decomposed and Unicode-punctuation controls; this is not a general retrieval-quality score. | QE-06; `ragquery._words` / FTS planning |
| `regression_ingest_capacity` | An ordinary ingestion worker competes with a durably held reservation. Separate input, output, cost, time and in-flight cells; unpressured positive control; the peer must defer without a failed attempt, then finish when unused capacity is released. Actual call counts and settlement checked on both VMs with optimized code. All five pressure cells failed at the original baseline; the admission repair now passes them. | OPS-004; `ragwork` reservation/worker boundary |

The closed-parent fixture deliberately reproduces a recorded persisted state
combination. It does not prove that every current creation route still produces
that combination, nor establishes every operator journey. Step 2 retains that fixture and adds
`native_lifecycle` and `native_lifecycle_holds`: public plans and execution,
fresh-process request deduplication, a live provider barrier, exact five-call
recovery and exhausted/uncertain holds across a later window. The optimized VM
`regression_lifecycle` adds item/parent states, real claim competition, explicit
resume, pause during failed settlement, missing policy and immutable requests.

The admission test takes the owner claim and reservation before invoking the
peer, then settles the owner with lower actual usage. There is no sleep or
probabilistic race trigger. It exercises the real worker/reservation code with
an in-process provider fixture; it is not a new multi-process stress test.

## Risk and remaining acceptance matrix

Every entry below is covered by named executable tests or has an explicit
remaining acceptance owner. Passing a related case does not close the whole
roadmap item. The existing detailed test descriptions remain in
[test strategy](test-strategy.md#default-matrix); all 20 historical REL cases
remain in the [consolidated register](ROADMAP.md#recovery-and-reliability-history).

| Risk / trigger | Required gate coverage | Remaining acceptance before claiming closure |
| --- | --- | --- |
| Unchanged import or operational config causes re-extraction | `configuration_contract`, `publication` legacy-URI case, `gemini_ingestion`, `temporal_provenance` | REC-001's complete staged full-corpus replacement; frozen installed operator journey under OPS-001 |
| Partial publication or stale manifest loses/repeats work | `publication`, `native_publication`, `native_interruption`; independent connections, injected SQL failure, post-commit projection failure | QA-03 disk-full/filesystem/platform fault qualification |
| Incomplete embedding replacement hides complete baseline | `ann_methodology`, `embedding_recovery`, `embedding_exhaustion` | QE-07/08 complete profile identity, migration/resume/rollback workflow |
| Provider response retained but paid request repeats | `native_receipt_failure`, `native_receipts`, `codex_application`, `worker_recovery`, `provider_durability` | Stage 3 adds real receipt-INSERT aborts: Gemini missing output remains held with known usage; Codex saved output survives and reconciles without another generation. Full-corpus installed operator/platform qualification remains open |
| Unknown, duplicate, late or excessive usage | `publication`, `provider_durability`, `worker_recovery`, `native_interruption` | External account reconciliation and hosted qualification under QA-02; reservations are not actual usage |
| Pause/drain/cancel/terminal parent loses remaining work | `process_workers`, `provider_durability`, `durable_backlog`, `native_interruption`, new retry cases | Step 2 covers request acceptance/deduplication, closed-window reconsideration, safe execution and pause/claim races. The third follow-up tests reasoned waiver/reopen, preserved missing coverage and uncertainty; UX-04 adds scoped external-retirement acceptance with queue-to-publication hold revalidation; OPS-005 renewal policy is not implemented |
| Bad task, failed worker and shared outage treated alike | `worker_recovery`, `controller_recovery`, new capacity test; exact calls and healthy-peer outcomes | OPS-004 rolling replacement, shared-outage probes/backoff, concurrent replenishment and zero-worker policy require agreed behavior before executable acceptance |
| Public status/page hides outstanding failures or work | `native_surfaces`, `durable_backlog_provider`, new page/large-job tests | OPS-003 complete public-only diagnostic journey; UX-01 workflow/subject lookup and UX-04 external retirement completion; UX-03 local effect assertions are recorded separately |
| Retrieval changes meaning or drops evidence | `evidence_methodology`, `quotation_grounding`, `temporal_provenance`, `gemini_query`, new frozen corpus cases | QE-01/02 selected graph roots/traversal; QE-09 60–100-question independently judged comparative benchmark. Eight synthetic questions are a contract seed, not a quality score |
| Packaging/runtime divergence | `linked_application`, `address_surface`, `installed_product`; installed-package provider ownership | New 99/100 and large-row cases currently exercise native human/JSON/NDJSON/MCP, not ADDRESS or an installed copy; extend them before a transport/package refactor. Installed Linux remains QA-03 |
| Workload/ledger grows beyond small fixtures | Existing 40-resolution overlapping native backlog case, 32-chunk/eight-worker embedding case, 17,000 protocol cycles and methodology fixtures | QA-01/PERF-01 multi-hour mixed load, long-ledger admission/census latency, concurrent readers/backup and memory/latency measurements remain open |

No line- or branch-coverage percentage is claimed: there is no measured
instrumentation baseline here. This matrix measures specified behavior and
known escape paths. It makes the limits visible without treating test count as
a reliability metric.

## Repair discipline

Confirm coverage before every implementation or refactor, as required by
[AGENTS.md](../AGENTS.md#build-and-qa). The
[first recovery implementation slices](recovery-implementation-plan.md)
identify the existing tests and missing acceptance to address before each fix.

Keep the failing acceptance test for the defect being repaired. After the
smallest owning-component change, prove the positive controls and the repaired
case, then run the full workflow. Remove its `known-defect` label only after
the acceptance passes; the label never affects execution or success. Keep
attempt/usage/source-state assertions when changing implementation structure.

The first coverage increment is useful before the entire product is qualified.
Open policy work, larger retrieval evaluation and platform/hosted qualification
remain separately tracked. A module or executable split should preserve these
observable contracts and add tests at the new boundary.

## Step 2 lifecycle qualification

The baseline passed four of five focused controls and reproduced closed-parent
retry refusal. The new native five-failure fixture reproduced the same refusal
before product edits. Schema 14 adds only durable retry requests. The focused
acceptance now passes on both optimized VMs and the native CLI/MCP; the final
full-suite result is recorded in [lifecycle recovery](lifecycle-recovery.md).

Final step-2 run: **42/45 passing in 554.81 seconds**, with all 38 tests in the
scoped commit passing. Only `regression_page_max`, `regression_large_job` and
`regression_retrieval_unicode` remain red. The closed-parent acceptance case
is repaired. See the linked qualification record for the exact artifact.

## Step 3 receipt and usage qualification

The [receipt recovery record](receipt-recovery.md) documents the test-first
baseline and two reproduced failures: a receipt-write error erased separately
saved Codex output, and Gemini receipt loss lacked the explicit uncertain
outcome needed by status/controller completion. `ragreceipts`, `ragusage` and
shared `ragworktypes` now separate those responsibilities from worker execution.
Original usage survives, missing output stays held, and Codex public
reconciliation reuses its saved answer with exactly one generation call.

The final native SHA-256 is
`5c828909c1c230f16c2099e1392c82996dfdf75adf34e0c8a9b30b7dcd468c6b`.
The final suite passes **43/46 in 544.99 seconds**, including all **39 scoped
checks**. The only failures remain `regression_page_max`,
`regression_large_job` and `regression_retrieval_unicode`. No previous passing
case regressed. The full review gate still exits 8; operator/platform/soak
qualification remains separate.

## Step 4 supervision and environment qualification

The [supervision record](supervision-recovery.md) records the passing baseline,
reproduced lifetime/empty-pool failures, and subsequent boundary checks before
implementation. `ragsupervision` owns rolling replacement policy/history;
`ragenvironment` owns shared admission, cooldowns and probe eligibility.

The default is two replacements per rolling hour. New tests cover window
expiry, restart, competing reservations, a temporarily empty queue with healthy
owners, zero-worker replenishment, public parked status and cancellation,
eight failed preflights followed by exactly one recovery probe, and one bad task
among eight healthy workers. Original task attempts, usage, unknown outcomes,
source evidence, budgets and cutoffs retain their independent owners.

Final native SHA256: `60ad3f965c2704e069019fcf9680704adc733b38a258b6fe1f8418fd973fee0c`. The complete suite is **45/48 in 620.61 seconds**;
all **41 scoped tests pass**. The three remaining review failures are unchanged:
`regression_page_max`, `regression_large_job` and `regression_retrieval_unicode`.
The full gate still exits nonzero. General infrastructure diagnosis, hosted
endurance and additional platform qualification are not inferred from these
local tests.

The prompt-contract stage passed the complete **53/53** regression workflow in
733.58 seconds. Exact artifact and baseline evidence are recorded in the
[delivery record](maintenance-refactoring-delivery.md#stage-2--prompts-and-response-contracts).

The stage 3 service extraction is preceded by the complete stage 2 baseline and
a failing `regression_operator_diagnostics` interface test with a passing
job-status control. Its fixtures place unrelated rows before matching job and
concept rows to catch post-pagination filtering. Full stage 3 qualification is
recorded in the [delivery record](maintenance-refactoring-delivery.md).

Command-catalogue coverage begins with captured metadata and a failing advertised
boolean test on stage 3. Native MCP argument regressions and a two-VM scenario
cover transport validation, access filtering, literal forwarding and zero-write
planning. Qualification is recorded in the [delivery record](maintenance-refactoring-delivery.md).


Stage 5 starts with passing worker-default characterization and failing public
file-operation controls before implementation. `regression_policy_file` and
`regression_policy_file_vm` cover policy validation/publication, optimistic edit
conflicts, invalid-policy repair, prompt-source switching, exact no-op identity,
MCP refresh and killed-owner lock recovery. `configuration_contract` covers the
shared default/bounds family; `installed_product` adds the installed policy edit
round trip. Extended `address_surface` coverage reproduced its cached-registry
gap before a shared refresh fix; execution and function calls cover same-session
prompt/config/profile changes, invalid-file holds and repair. A complete library
dump remains identical across file edits. Platform
metadata and policy-file power-loss limits remain explicit in the integration
register, accepted outside active defect work by the 12 September decision.
Library, receipt and usage recovery obligations are unchanged.

## Complete operator continuation follow-up — 12 September

The [operator journey](operator-continuation.md) is one delivery, with complete
QA/live status in the [handoff](operator-continuation-handoff.md). Relevant
baseline tests passed 6/6 in 127.87 seconds before product changes.

| Acceptance | Reproduction and current coverage |
| --- | --- |
| Same-job continuation/renewal | `native_continuation` first failed on unknown `job continue`. Now covers CLI/MCP repeat, conflicting period minutes, immutable original policy/history, renewed maintenance execution and compatible worker-count registration. |
| Retained holds and ownership | `native_continuation_holds` retains exhausted/uncertain tasks and denies renewal during a live provider response. Prior paid calls, missing coverage and retry requests remain visible. |
| True historic one-attempt failure | `native_legacy_retry_ceiling` produced zero queued retries, expected five, under a later reviewed three-attempt policy. Equal-ceiling fixtures had missed it. |
| Explicit embedding ceiling | `native_embedding_retry_policy` reproduced zero queued retries under explicit embedding six versus reasoning one. Both the reviewed policy and dispatcher now use the shared effective ceiling; original paid attempts still count. |
| Public source/operation progress | `regression_operator_diagnostics` first rejected the missing command. Continuation tests page five sources, reconcile original/new item counts, filter by source/operation and compare CLI/MCP. Malformed historic item input remains inspectable. |
| Corpus-scale diagnostics | EXPLAIN reproduced one full event scan per item; migration 16 adds the item/event index. On the generation-23208 Scottish copy, status took 0.777 s, progress 0.378 s and five held items 0.187 s. Six public pages later accounted for all 515 holds with no duplicate IDs. |
| Concurrent journal startup | The second full gate exposed a silent child exit. Isolated repeat 95 captured `enable WAL` / `SQLITE_BUSY`. A controlled exclusive-lock rendezvous then failed on both VMs before repair; `regression_supervision` now requires the actual first BUSY retry followed by successful open. It preserves normal timeouts and strict one-winner reservation checks. |
| Configured/live worker distinction | A new fixture first expected three configured workers but received zero without a controller event. Status now reads canonical configuration/defaults; the Scottish copy reports eight configured, zero live and an explicit continuation action. |

The pre-WAL focused gate passed **6/6 in 113.35 seconds**. Build 7 then passed
the WAL/supervision/publication/held gate **4/4 in 115.50 seconds**, the complete
**63/63 in 848.41 seconds**, and the scratch-installed recovery journey.
The real remaining-ingestion/60-minute maintenance run is subsequent required
evidence. The two earlier full failures are retained with their reproductions
and repairs; no case was disabled.
[Retained logs](qa/operator-continuation-20260912/) include baseline reds, focused
results, metadata review and public corpus observations. No outcome is closed
by a test count alone.

The live smoke added RAG-SMK-001: active submitted work was shown as a
reconciliation hold. `regression_operator_diagnostics` reproduced the wrong
next action before repair, with one active intent, one terminal unknown and one
matched receipt. It now checks the disjoint public active/held counters and
unchanged database state. Candidate 8 passed its three focused cases in 26.98
seconds and the separate installed CLI/MCP scenario. Full QA then passed
**63/63 in 933.50 seconds**.

RAG-SMK-002 adds `codex_protocol` cases for valid 2/3/4-byte UTF-8 characters
split across stdout writes and for a complete invalid-byte frame. All eight
VM/optimization combinations reproduced panics before the adapter fix. The
repair retains exact Unicode text and returns a bounded malformed-frame error;
protocol and 17,000-cycle request-reclamation checks passed in 41.61 seconds.
Full provider/native qualification then passed **63/63 in 938.12 seconds**,
alongside the installed receipt-interruption journey.

RAG-SMK-003 adds corpus-scale review lookup coverage to `provider_durability`:
30,000 pending questions and 5,000 reviews in both fresh and upgraded stores.
The query plan must use a subject lookup; pending, accepted and unrelated
reviews have separate selection controls, and all reviews survive inspection.
The unmodified product failed exactly the two new access-path assertions in
3.02 seconds. A prior test-only reserved identifier error is recorded separately.
The additive schema-17 repair and fresh/schema-16 upgrade preservation checks
passed the final gate below; the live acceptance is recorded separately.

Schema-17 repair qualification: full **63/63 in 847.44 seconds**. The new
scale/fresh/upgrade controls pass alongside worker, provider, publication and
installed-product regressions. The repaired bounded maintenance smoke subsequently passed: exit 0, all eight
workers drained, one recovered timeout and no held uncertainty. See the
[final report](operator-continuation-smoke-20260913.md) for its actual 56m55s
worker runtime, retained holds and remaining status defects.

## Unchanged index retry — 14 September

`ann_methodology` now covers dirty-marker invalidation, settings, transaction
rollback and generation jumps, forced rebuild, failure/retry and reuse without a new embedding
timestamp on both VMs. See [A8 and its results](test2-recovery-delivery-20260914.md).
