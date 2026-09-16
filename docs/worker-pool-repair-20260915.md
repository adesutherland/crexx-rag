# ISSUE-01 — replenish worker slots after unexpected exits

**Status authority:** [the master register](ROADMAP.md) owns current status and
priority. This document retains dated evidence and detailed requirements; its
checkpoint labels and checklists are historical unless linked as current by the master.

**16 September superseding evidence:** [the installed CREXX #701 retest](crexx-701-retest-20260916.md)
passes all three original fault cases using `17e844441ed8`. The downstream regression
is re-enabled; the temporary exclusion described in this historical record no
longer applies to that updated runtime.

## Vision and scope

A running controller should restore an unexpectedly lost worker slot using the
existing bounded replacement allowance, while healthy peers continue. Process
exit classification must not decide replacement: attempt it after every
unexpected exit, subject to the existing run and allowance bounds. Process
failure does not establish a shared provider outage or grant new item attempts,
provider calls, spend or time. Preserve committed results, receipts, usage and
unknown-outcome holds. Explain an unfilled slot through public status. Use the
existing process, work-recovery and supervision owners; no new daemon, policy
framework or master-corpus experiment.

Authority: Adrian's engineering request forwarded by the Scottish task after
its two-hour run closed. Core-only diagnosis, regression-first repair and local
QA. Do not change/restart the master or install/publish a repair under this task.
Starting checkout: clean `main`, `f60472aab6ae7c437667aa70169210e66c9fe6b6`;
installed/tested native `30879436fcd8ac113435296cd7d8f6d03cab9b9387fe9e43f4bcf0ee5f0bd083`.

## Acceptance checklist

- [x] AC-01: preserve passing supervision/process controls, reproduce the real
  pre-claim panic, and reproduce missing replacement after native abrupt
  disappearance with healthy peers and runnable scratch work.
- [x] AC-02: replace unexpected, fully exited registered workers within the
  existing count/window/backoff and remaining item/poll/deadline limits. Pause,
  cancellation, drain and exhausted allowance remain effective.
  Application eligibility is covered; timely native completion notification is
  the explicitly accepted upstream limitation in CREXX #701.
- [x] AC-03: retained attempts, successful receipts/results, usage, budgets and
  unknown provider outcomes survive; no duplicate submitted work or invented
  shared provider diagnosis follows a process exit.
- [x] AC-04: an observed exit is durably recorded or its persistence error is
  reported; missing/stale and deliberately unreplaced slots have a useful public
  explanation. Separate the observed incident from hypotheses about its timing.
- [x] AC-05: reproduce and repair the early maintenance-error claim panic if
  confirmed, retaining its original error and uncalled-work accounting.
- [x] AC-06: complete the approved qualification: retain the full 77/80 result,
  fix the two manual-recovery fixtures and pass their targeted rerun; explicitly
  disable the upstream-dependent test pending CREXX #701. Adrian approved only
  the affected-test rerun for this test-only follow-up. Update shared coverage
  and this record; leave the Scottish master unchanged. No clean 80/80 claim.

## Work steps

- [x] STEP-01: review the saved Scottish receipts, installed policy and owning
  code; establish the exact exit-classification branch (AC-01/04).
- [x] STEP-02: run baseline controls and add ordinary failing reproductions plus
  positive controls before product edits (AC-01/03/04/05).
- [x] STEP-03: make bounded changes in `ragsupervision`, `ragprocess` and the
  claim/error owner as required by those failures (AC-02/03/04/05).
- [x] STEP-04: pass focused tests, review SQL access/loop context and update the
  authoritative docs/consumers (AC-02/03/04/06).
- [x] STEP-05: complete full build/QA and record the result: 77/80 passed;
  resolve its follow-ups under STEP-06/07 without repeating unchanged tests.
- [x] STEP-06: file pipe inheritance as
  [CREXX #701](https://github.com/adesutherland/CREXX/issues/701) and close that
  investigation locally as transferred upstream, per Adrian's 15 September
  instruction. No local runtime repair or extra RAG monitoring is planned.
- [x] STEP-07: apply the approved test-only corrections and run only
  `native_receipts` and `native_interruption`; both pass. Preserve the native
  abrupt-exit test as disabled/known-upstream, not counted as passing.

## Initial findings

Baseline panel passed: `regression_supervision`, `native_supervision`,
`process_workers`, `controller_recovery` (4/4). Evidence:
`cmake-build-debug/worker-pool-repair-20260915/baseline.log`.

The saved 14:07 status shows six live workers, seven registered, zero recent
replacements, two remaining, no cooldown deadline and an empty waiting reason.
The final receipt records two exit-16 workers and zero replacements while the
original controller/peers continued useful work. Master verification passed.
Evidence owner:
`/Users/adrian/Documents/ScottishHistory/reports/bounded-soak-20260915/ISSUES.md`
and its adjacent `evidence/` files.

`ragsupervision.reserveworkerreplacement` selects only failed/75 or stopped/0
rows. Failed/16 therefore yields no job ID and returns permanent refusal; the
controller clears that slot's pending flag. This confirms the classification
boundary without inferring it from restart counts alone.

The second worker's stale row is a separate observation. Completion recording
currently ignores `finishprocess` errors, and only the first failed worker gets
a launcher detail line. Thus the saved log alone cannot distinguish delayed
child completion from an observed exit whose registry write failed. Exercise
both observation and persistence before attributing the incident.

There is also a concrete early-return hazard: `_runworkeronce` leaves its exposed
claim uninitialized if `tickbacklogwindow` fails before `claimnext`; the outer
wrapper then calls `claim.claimed()`. This matches the panic text but still needs
a failing reproduction before repair. Do not assume the nearby SQLite retry
messages establish the original trigger.

## Reproduction and repair

Before product edits, `regression_supervision` failed the exit-16/1/137
replacement and partial-pool explanation assertions on both VMs. Its separate
checkpoint case produced the exact uninitialized `.ragworkclaim` panic on both
VMs. It forces `BEGIN IMMEDIATE` to fail before the first claim; this proves the
error-path defect, not the original soak's precise SQLite failure. The same
checkpoint after releasing the conflict is the positive control.

The native fixture killed a real registered worker before submission and after
a persisted intent. Both failed their replacement assertion. A trigger rejecting
the observed exit UPDATE also failed the required error-report assertion: the
controller ignored that write error. Held providers were released during fixture
cleanup; subsequent fixture timeouts are not evidence about the original soak.
The final fixture releases healthy peers immediately after killing the selected
worker, avoiding a test-induced provider timeout while observing replacement.
Baseline logs are `reproduction.log` and `native-reproduction.log` under
`cmake-build-debug/worker-pool-repair-20260915`.

The repair removes the failed-worker exit-code restriction, initializes the
empty claim before checkpointing, uses the existing bounded writer-lock helper
for process finish and checks its return when observing child exit. The shared
status owner supplies a reason for a partial pool with no more specific policy
hold. No schema, public option, daemon or new recovery policy is introduced.

The rebuilt candidate passes `regression_supervision`, including both VMs,
independent competing reservations, the lock-release positive control, unchanged
history and the new partial-pool reason. Native packaging's initialization and
two-worker smoke also pass. Candidate native SHA256:
`9825666f67bfa649af2896f38509e1a6d7f0314c9bedb5a84b334253b5f4d486`;
linked application SHA256:
`e936a333bfbc41515c84d91f5cde72439896c172960f7947623489bc0c433063`.
The first repaired native run restored the slot both before and after provider
submission. Fixture assertions were corrected to signal the registered
controller (rather than its `cmake -E env` launcher) and to count the retained
unknown `provider_runs` row separately from successful receipts. Its exit-write
case exposed a further diagnostic loss: finalizing the failed SQLite statement
cleared the provider error before formatting it. Capture now precedes finalize.
All three `worker_unexpected_exit` native cases now pass. Each loss case
restores eight live workers, keeps seven original peers alive without drain,
retains exactly one replacement event and one provider intent for the affected
item, and preserves original budgets. The submitted case keeps its unknown
provider row and item hold while eight other extractions succeed; the uncalled
case completes all nine extractions. The persistence fault reports its original
SQLite trigger diagnostic and returns failure instead of silently abandoning
the slot. Those are focused results; the full run below did not pass all cases.

SQL query plans on the scratch library confirm `job_items_claim` is a covering
index for partial-pool work counts and `sqlite_autoindex_runtime_instances_1`
serves the replacement lookup. All `finishprocess` callers were reviewed:
the operation owns its transaction and runs outside task/provider transactions.

## Full-suite finding — upstream child pipe inheritance

**Closed locally as transferred upstream, 15 September 2026:**
[CREXX #701](https://github.com/adesutherland/CREXX/issues/701), filed under
`adesutherland`, owns the runtime repair. Adrian directed that this is a CREXX
issue and should be closed here. The earlier request to implement a runtime
patch is superseded; no upstream implementation approval remains pending in
this task. Delayed notification/replacement is an accepted known limitation
until the upstream repair is available, not an additional RAG implementation
blocker. This disposition does not turn a failing regression into a pass.

The first full run reproduces delayed completion in `worker_unexpected_exit`
despite the focused pass: the killed worker's exit is delivered only after
healthy peers start finishing. Its write-error case similarly reports the error
only during cleanup. Do not mark the whole repair green on the focused result.

A read-only descriptor snapshot proves cross-worker stdout inheritance: native
PID 87853's stdout pipe `0xf3d72cac815b90c9` is also open in PID 87854 (fd 11);
PID 87855's stdout pipe `0x66cc65df8c0d3126` is open in PIDs 87856/87857 (fd 14).
Evidence is `descriptor-reproduction/worker-kill/worker-descriptors.txt` and
`registered-workers.json` in this repair's build evidence directory. These are
isolated fixture PIDs, not Scottish master processes.

Installed CREXX source `037e7939bc29`, `interpreter/rxspawn.c`, marks only the
parent completion descriptor close-on-exec. The child ends remain inheritable;
the process wait path then joins output capture through EOF before publishing
completion. The existing launch mutex protects launch-status pipes but not the
redirect pipe setup. A proposed narrow patch marks both redirect ends
close-on-exec under that same mutex; `dup2` retains the intended standard streams.
Patch: `cmake-build-debug/worker-pool-repair-20260915/rxspawn-cloexec-proposed.patch`.
No CREXX file has been changed. The proposed patch is retained as investigation
evidence only; implementation and runtime regression coverage belong upstream.
The historical Scottish second stale row still cannot be attributed
conclusively from its old receipts alone.

## Full-suite result and completed test-only follow-up

The existing 80-test run completed with **77 passed and 3 failed**; evidence is
`cmake-build-debug/worker-pool-repair-20260915/full-suite.log`. No additional
full test run was started for the upstream handoff/documentation update.

- `worker_unexpected_exit`: delayed child completion; the pipe-inheritance
  investigation is now owned by CREXX #701. Keep this result visible as a known
  upstream limitation. Adrian subsequently approved disabling this test until
  a repaired runtime is available; its code/assertions remain intact.
- `native_receipts`: worker start reports that the job already has a controller.
  Diagnosis showed the injected settlement fault remained active while the
  newly eligible replacements retried. Three local attempts reused one stored
  response; there was one provider intent and no duplicate provider call.
  The test accepted its 60-second command timeout as an expected failure, then
  tried a second controller against retained ownership.
- `native_interruption`: the post-commit projection-failure assertion returns
  `1:2:2:0`. The replacement completed the separate embedding item after the
  extraction committed. Both items had one successful attempt/provider run;
  the claim and accounting were preserved. Its old intermediate count expected
  the controller to stop after the first worker failure.

The approved correction selects existing `worker.max_restarts = 0` only in
these manual fault/restart fixtures (`manifest_failure` only in the shared
interruption driver). All original state, receipt, accounting and recovery
assertions remain. The receipt helper now requires an actual nonzero process
exit rather than accepting timeout as its intended failure. No product change
or rollback was required.

The checked-in targeted rerun passes **2/2**, covering both receipt variants and
all three ordinary interruption cases. `worker_unexpected_exit` is **Disabled**
with `known-upstream`/`crexx-701` labels and a source comment linking the issue.
The passing deterministic `regression_supervision` and existing
`native_supervision` tests remain enabled. Log:
`cmake-build-debug/regression-options-20260915/test-fix-targeted.log`.

Only tests and qualification documentation changed in this follow-up. The
product source files and native candidate checksum are unchanged; configuration
was regenerated without rebuilding. No full suite was rerun, as Adrian directed.
Local ISSUE-01 work is complete with the explicit CREXX #701 exclusion; the
upstream limitation remains open. The Scottish corpus, installed package and
published baseline remain unchanged by this repair.
