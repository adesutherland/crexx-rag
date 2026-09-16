# First recovery refactors and fixes

**Status authority:** [the master register](ROADMAP.md) owns current status and
priority. This document retains dated evidence and detailed requirements; its
checkpoint labels and checklists are historical unless linked as current by the master.

Sequence proposed 11 September, status reviewed 12 September 2026. This turns the
[consolidated roadmap](ROADMAP.md) into small implementation slices. Robust
recovery and cohesive source modules take priority. Separate executables are
an optional, lower-priority surface choice and are outside these slices.

The principle is straightforward: the logic for an aspect belongs together,
different aspects have separate source owners, and callers compose those
owners. Each refactor should remove a demonstrated ownership problem while
preserving unrelated behavior. Do not build a general recovery framework or
move the entire application before repairing the known failures.

## Current status and next work

The previously uncommitted review baseline, fixtures and regression workflow
are now committed in `5d1481a`. Steps 1–4 remain committed as `4500e77`,
`10a91d2`, `d36db07` and `8e4f5a8`. Steps 5a/5b and 6 implement the remaining
three failures with the tests confirmed and extended before product edits.
See [public results and Unicode repair](public-result-lexical-repair.md) for
qualification, compatibility review and exact artifact evidence.

| Step | Current delivery |
| --- | --- |
| 1 | `ragadmission`: recover temporary reservation pressure |
| 2 | `raglifecycle`: durable retry requests and shared lifecycle decisions |
| 3 | `ragreceipts`, `ragusage`, `ragworktypes`: retain output and usage on receipt failure |
| 4 | `ragsupervision`, `ragenvironment`: rolling replacement and shared preflight recovery |
| 5a | `ragresultpages` / `ragcommand`: full data pages plus bounded cursor metadata |
| 5b | `ragrepository` / `ragresultpages`: bounded summaries and exact `job plan` reads |
| 6 | `ragquery`: preserve Unicode terms through lexical query planning |

The scheduling gap identified in the earlier review is addressed: the two
public-result repairs and Unicode correctness fix now have implementation and
named acceptance, rather than being loose later-work notes. The broader
operator and QE requirements below remain open; a scoped repair does not close
all related backlog items. The tests-first instruction remains in AGENTS.md.

The architecture has improved in specific places. `ragwork` has reduced from
1,956 to 1,156 physical lines as receipt, usage and shared contracts moved to
named owners; no cross-module product import cycle was found. `ragproduct`
has grown from 3,304 to 3,351 lines and still mixes dispatch, queries, reports,
jobs and other operations. These size counts help locate responsibility; they
do not measure reliability. The targeted modularisation is useful, but no
reduction in escaped-regression rate has yet been measured. The public
result fix establishes one coherent result-page owner; a general dispatcher
split and separate executables remain later choices.

The approved follow-up order is UX-03 connection previews, then UX-04 with
OPS-002 external lifecycle closure, followed by the combined public recovery
journey under OPS-001/003. UX-03 and UX-04 have now each passed the full 59/59
local gate; see [connection effect previews](connection-effect-previews.md) and
[external workflow recovery](external-workflow-recovery.md). The combined
operator journey is implemented for local qualification; see
[public recovery](public-recovery-journey.md). Its final full gate passed **59/59 in 1238.52 seconds**, alongside the frozen installed replay. Each follow-up
confirms coverage before code and requires the full green gate before commit.

Sections 1–6 below retain their original coverage checkpoints and completion
criteria as implementation records; they are not instructions to repeat those
completed stages.

## Coverage checkpoint for every slice

This is now an explicit requirement in [AGENTS.md](../AGENTS.md#build-and-qa).
Before touching product implementation:

1. Identify its public outcome, owning modules, stored state, transaction/fence
   boundaries and compatibility obligations.
2. Inspect and run the relevant existing tests on the chosen product baseline.
   List the assertions that cover the intended change and its failure paths.
3. Add missing tests first. Reproduce a defect with a passing positive control;
   establish passing characterization before a behavior-preserving extraction.
   Existing passing tests are sufficient when their assertions cover the slice;
   do not add duplicate tests merely to increase the count.
4. Record the baseline and gaps. After the change, require its acceptance to
   pass, preserve previously passing tests and run the complete regression gate.
   Report remaining known failures without suppressing or inverting them.

Historically, the pre-implementation run was 36/41 passing; step 1 reached
38/42, step 2 reached 42/45, step 3 reached 43/46 and step 4 reached 45/48.
The last three failures have remained since step 2. Those checkpoints are
useful evidence, not blanket coverage for every refactor. The [coverage matrix](regression-coverage.md)
identifies the current gaps. Reconfirm the relevant cases when implementation
starts, particularly if the checkout, installed CREXX or product build changes.

## 1. Make temporary admission pressure recoverable — OPS-004

Implementation authorized 11 September 2026. The focused baseline confirmed
the five ordinary-ingestion pressure failures, with `durable_backlog`,
`publication` and `provider_durability` passing (44.04 seconds overall).
Before product edits, additional cancellation/invalid-cap/consumed-budget
controls were run, and `native_admission` reproduced a healthy peer becoming
a dead letter: only three of four items completed. The implementation now
introduces `ragadmission` and a shared uncalled-claim deferral, with a public
`waiting_reason`. Final qualification is recorded in the
[coverage matrix](regression-coverage.md). OPS-004 as a whole remains open.

**Status:** implemented and qualified locally; both admission tests and all 33
original tests pass. See [the scoped repair record](admission-recovery.md).

**Outcome:** healthy workers wait when peers temporarily reserve capacity, then
continue when capacity is released. They do not consume a failed task attempt
or trigger worker replacement merely because a reservation cannot yet fit.

**Source ownership:** extract provider admission decisions from `ragwork` into
a focused `ragadmission.crexx` module. It owns classification of available
capacity, temporarily held capacity, consumed allowance and unaccounted
external outcomes. It should return a structured decision and reason; callers
must not infer policy from rendered error text. `ragwork` retains item claim,
lease and fence transitions. `ragbacklog` retains maintenance-window controls.

Keep eligibility checking and reservation creation within the existing atomic
transaction. Extracting a decision function must not create a check-then-reserve
race. Use existing usage/receipt records; do not change budgets or erase unknown
usage. A true exhausted allowance remains an explicit stopping/waiting reason,
not an endless rapid retry. This slice does not select renewal or outage policy.

**Coverage to confirm first:** `regression_ingest_capacity` already fails for
input, output, cost, time and in-flight capacity on both optimized VMs.
`durable_backlog` covers maintenance reservation pressure; `publication` and
`provider_durability` cover settlement and unknown-usage protections. Add or
confirm per-call-invalid and actually-exhausted controls, cancellation/deadline
while waiting, and a native worker/controller case with a held peer request.
That last test must show no replacement event, no phantom provider call, an
unchanged attempt allowance and eventual completion after release.

**Done:** the pressure test passes for ordinary ingestion and maintenance;
actual exhaustion/uncertainty remain correctly enforced; public status exposes
the waiting reason; the admitted peer's receipt and usage settle exactly once.
This is the recommended first implementation slice.

## 2. Give lifecycle decisions one owner — OPS-001/002

**Status:** implemented and qualified locally: all 38 scoped tests pass; the
full review suite is 42/45 with only the existing UX-02/QE-06 failures. `raglifecycle` owns shared
projection/eligibility and durable request identity; item claims and task/window
execution retain their existing owners. Five retained failures recover with
five new calls; exhausted/uncertain requests remain held in later windows.
See [lifecycle recovery](lifecycle-recovery.md) for final qualification.

**Outcome:** unfinished tasks remain recoverable regardless of the internal
parent job/window state. A retry request is durable and deduplicated; accepting
it is distinct from granting permission to execute it now.

**Source ownership:** introduce `raglifecycle.crexx` for shared terminal-state,
retry-eligibility and continuation decisions currently interpreted independently
by `ragwork._refreshjob`, `retrydeadletter`/`replaydeadletters` and
`ragbacklog._closewindow`. Keep item execution/leases in `ragwork` and durable
task/window records, task reconsideration and dispatch in `ragbacklog`. Job
status and commands use the shared decisions; they must not invent another
completion rule. Keep task, job and window states distinct.

**Coverage to confirm first:** `regression_retry` and
`regression_closed_retry` cover supported retry/history and the recorded
closed-parent failure. They do **not** prove safe resumed execution. Add a
table-driven task/job/window matrix, including pending, dispatched, failed,
resolved and uncertain work; active/paused/closed windows; terminal parents;
duplicate requests; already covered chunks; request-versus-claim races and a
restart between accepting and dispatching a retry. Prove preserved original
attempts/receipts, no second submission of uncertain work, and real completion
through the normal public runner. Retain pause/cancel/window-boundary tests.

Do not repair this by simply allowing more parent-state strings. The request,
task reconsideration, safe dispatch and public terminal status must agree.
Specify the minimal durable request representation and compatibility behavior
before any schema change. Close/waive must remain distinct from completed
coverage. This slice does not silently reset retry limits or renew budgets.

**Done:** the five-failure persisted case can be recovered through product
controls, repeated requests do not duplicate execution, and status explains
held versus runnable versus completed work without SQL knowledge.

## 3. Isolate receipt and usage recovery — OPS-001, REL-005/011/012

**Status:** implemented and qualified locally. All 39 scoped tests pass; the
full review suite is 43/46 with the same three UX-02/QE-06 failures. The new
receipt-write tests preserve Gemini usage/holds and recover saved Codex output
without another generation. See [receipt recovery](receipt-recovery.md) for the
baseline, ownership and precise hold-versus-reuse behavior.

**Outcome:** durable output is reused; incurred usage is accounted once; loss of
receipt persistence cannot cause a blind repeat of a possibly paid request.

**Source ownership:** group request intent, response persistence and recovery
in `ragreceipts.crexx`; group usage settlement, reservation release and
uncertainty accounting in `ragusage.crexx`. These are separate aspects from
admission and from permission to publish. Extract them from `ragwork` in small
behavior-preserving steps, with existing callers maintained until migrated.
Provider-specific observation stays in its adapter; generic recovery stays in
these modules. Fenced semantic publication retains its current owner.

**Coverage to confirm first:** `native_receipts`, `worker_recovery`,
`provider_durability`, `publication` and `native_interruption` already exercise
many after-receipt, late, duplicate, cancelled and post-commit cases. Add the
missing fault at the receipt write itself, after the fixture provider has
returned, followed by controller restart and supported recovery. Assert that
the original intent/history survives, healthy peers continue where safe, and
no blind duplicate request occurs. Test exact and conflicting duplicate
receipts, settlement failure after durable receipt, and publication failure
after successful settlement as distinct boundaries.

When output was never made durable and the provider cannot recover it, safe
holding with an explicit uncertain outcome is the correct boundary; do not
claim output can always be recovered. The incident record does not establish
which recovery is possible for every provider.

**Done:** receipt, usage and publication outcomes can be distinguished after
restart; retained output causes zero repeat calls; unavailable output remains
explicitly held; no reservation or original-attempt usage is lost.

## 4. Separate worker supervision and shared-outage policy — OPS-004

12 September step 4: rolling supervision and shared preflight backoff are
implemented in [supervision recovery](supervision-recovery.md). Defaults are two
replacements per rolling hour; qualified evidence and remaining scope are
recorded there. Task attempts, unknown outcomes and cumulative usage remain
separate from replacement capacity.


**Outcome:** isolated worker failures can recover during long runs; a shared
outage triggers bounded waiting/probing rather than replacement storms.

**Source ownership:** `ragsupervision.crexx` owns pool/replacement decisions and
their durable history; `ragprocess` keeps process launch, liveness, signalling
and registration. A separate `ragenvironment.crexx` owns shared outage scope,
backoff and probe eligibility. These modules consume classified outcomes and
admission/lifecycle decisions; they do not reset task attempts or infer failure
scope from a generic nonzero exit. New names describe proposed responsibilities,
not a requirement to introduce all modules in one patch.

**Coverage to confirm first:** preserve `controller_recovery` and
`worker_recovery` peer-isolation and controller-restart assertions. Before new
policy, add isolated versus burst failure cases, rolling-window expiry and
automatic replenishment, restart on either side of expiry, concurrent
replacement decisions, zero healthy workers, and whole-pool outage/recovery.
Use a controlled clock or durable event timestamps and deterministic rendezvous
rather than waiting for real multi-hour windows.

Specify rolling duration/count defaults, evidence for shared-outage
classification and probe/backoff policy in this slice. Existing user-authorized
budgets and cutoffs remain binding. Those decisions need not delay slice 1.

**Done:** the configured pool is restored when eligible, recent replacement
history survives restart, healthy peers continue, and neither expired events
nor controller restarts reset task or provider history.

## 5. Repair bounded public results — UX-02 / OPS-003 / HC-33/34

**Status:** implemented; see [repair qualification](public-result-lexical-repair.md).
The following scope and test checkpoints are retained as the acceptance record.

**5a — Maximum page plus cursor.** `ragrepository.pagerepository` and
`ragproduct._repository` accept 100 data rows, but the latter appends a cursor
as record 101 and `ragcommand.validcommandresult` permits only 100 total records.
All four native transports fail after their 99-row positive control.
Give shared page/result construction a focused `ragresultpages.crexx` owner,
composed by the dispatcher. Reconcile data-row and metadata bounds explicitly;
preserve the advertised maximum, complete traversal, stable cursor semantics
and bounded rendering. Do not merely suppress the validation failure.

**Coverage first:** run `regression_pages` and `regression_page_max`. Extend
complete traversal at limit 100, empty/final pages and invalid limits; cover
ADDRESS and a scratch installed copy before changing the shared contract.
Confirm callers of the same page builder keep their identities and ordering.
**Exit:** every maximum-page case passes without omission, duplication or
unbounded results; the only remaining original failures are large job detail
and Unicode retrieval.

**5b — Large retained plan.** The jobs projection in `ragrepository` puts
`canonical_plan` into the generic `value` field, which the command contract
limits to 65,535 characters. A 65,536-character plan breaks even a one-job page.
This is a result-projection failure, not the already repaired plan-input bound.
Keep job identity, state and useful summary discoverable independently of plan
size. Define a bounded detail operation that can reconstruct the complete
retained plan; keep its source identity/digest and exact content verifiable.
The result-page owner handles presentation; the repository owns reads, and
renderers must not acquire job/recovery policy. Review compatibility for callers
that currently read `value`; avoid silently dropping or truncating their data.

**Coverage first:** preserve `regression_large_job` at 65,535/65,536 and add
exact full-detail retrieval, a representative larger synthetic plan, mixed
small/large listings and multi-byte text. Extend ADDRESS/installed acceptance;
prove zero provider calls and no authoritative state changes.
**Exit:** both UX-02 failure tests and public controls pass, complete plan detail
remains accessible, and the full suite has only the original Unicode failure
outstanding. Broader OPS-003 operator diagnostics remain separate acceptance.

## 6. Repair Unicode lexical query loss — QE-06

**Status:** implemented after step 5; see [repair qualification](public-result-lexical-repair.md).
`ragquery._words` keeps only ASCII letters/digits; `_ftswords` uses it even for
quoted phrases. Direct SQLite FTS finds the indexed `Élodie` and `東京`, while
`query inspect` returns no passage through JSON/MCP. The query planner owns
the repair; the evidence and source-offset contracts remain authoritative.

**Coverage first:** rerun `regression_retrieval` and
`regression_retrieval_unicode`, `query_policy` and `evidence_methodology`.
Add focused planner assertions for quoted/unquoted accented and non-Latin
terms, mixed scripts, case/combining forms, punctuation and safely quoted FTS
operators. Determine normalization compatibility from the installed tokenizer
and runtime; do not invent different normalization rules in each caller.
Keep independent direct-index probes and exact source/citation oracles, absent
term controls, CLI/MCP agreement, zero provider calls and zero writes. Exercise
the changed planner on both optimized VMs and the installed public route.

**Exit:** the two named queries recover their independently specified passages;
existing phrase/ASCII/negative cases retain their guarantees; all **48 current
tests plus newly added acceptance pass** in the full required gate. Remove
resolved known-defect labels only after passing. This closes the reproduced
Unicode defect, not all QE-06 ranking, OCR/alias or QE-09 evaluation requirements.

## Later work, with remaining acceptance explicit

**Operator closure — OPS-001/002/003, UX-01/03/04:** after the three failures
are repaired, characterize the public diagnostic/recovery journey on a frozen
installed artifact. Cover subject/workflow discovery, count reconciliation,
truthful effect preview, complete external correction and retirement, and
reasoned close/waive without losing task or usage history. Existing step-1–4
tests do not close these complete operator outcomes.

**Renewal/continuation — OPS-005:** build on the lifecycle and usage owners.
Specify optional/omitted limits and a new authorization period without erasing
cumulative spend, attempts or completed work. Confirm coverage, then add an
end-to-end renewal/restart test. Do not make a new allowance counter an
accidental prerequisite for the earlier recoverability fixes.

**Other source organisation:** consolidate HC-16's duplicate claim-policy
constructors under one policy owner, with worker/external-proposal equivalence
tests. Extract query and reporting services from `ragproduct` in separate
characterized changes; leave `dispatchproduct` as composition. After step 6's
lexical defect repair, broader ranking changes still need QE-09 evidence.

If a new owner would need to import its caller for shared types, first move only
the necessary contracts to a lower-level module and update imports with build,
linked/native/ADDRESS and installed-consumer checks. Do not create circular
imports or duplicate contract types to make the extraction compile. Preserve
the Level-G product boundary and installed `rxsqlite` ownership throughout.

Separate executables and a general directory reorganisation are deferred.
Success is fewer duplicate decisions, clear source ownership, preserved
atomicity and passing recovery journeys, not a target file count.
