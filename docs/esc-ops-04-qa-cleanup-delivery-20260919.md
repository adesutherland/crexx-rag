# Correction allowance and QA cleanup — 19 September 2026

## Outcome and approved scope

Fix ESC-OPS-04 (stale remaining-call context on citation correction) and
RAG-QA-05 (cleanup PermissionError loses a test receipt). Preserve the qualified,
uncommitted ESC-OPS-03 work. No prompt tuning, database-contention redesign,
corpus operation, installation or publication. The user regards contention as
acceptable for now; eight fast workers may exceed the efficient concurrency.

## Checkable acceptance

1. Reproduce stale correction context through a private public-provider fixture.
   Initial and final correction requests show two and one remaining calls;
   ordinary and advanced routes retain their actual admission/accounting limits.
2. Frozen task input, source evidence, reference map and original prompt binding
   are preserved. Actual correction request/response and usage remain observable;
   existing receipt replay and correction-budget refusal still pass.
3. Reproduce cleanup failures independently of product assertions. Keep the child
   process identity reserved until group cleanup; do not signal a recycled group.
   Permission errors produce failed receipts, never missing or reusable passes.
4. Normal completion, failed child, timeout, interruption and descendant cleanup
   remain bounded and leave unrelated processes untouched. Run targeted checks
   first, then one complete stable local gate with exact-input pass reuse.

## Execution steps

1. **Complete:** inspect owners and baseline receipts; add fail-first cases.
2. **Complete:** repair in `ragbacklog`/`ragapplicationprovider` and the existing
   Python QA boundary, without changing product process orchestration.
3. **Complete:** targeted acceptance, complete local gate, roadmap and coverage.

Baseline exact-input receipts: `qa_execution` 1.55s, provider advanced 8.52s,
provider correction 6.55s and provider valid 10.75s all passed. These did not
assert current correction allowance or cleanup-error receipt/identity ownership.

## Fail-first evidence and repair

Both public-provider controls failed before the product change with
`correction repeats stale remaining-call instructions: 2,2`:

- Ordinary: `qa/runs/durable_backlog_provider_correction/20260919T174308-35ab8bd9`, 4.05s.
- Advanced: `qa/runs/durable_backlog_provider_correction-advanced/20260919T174308-3b485500`, 5.12s.

Their original-call, correction, source/vector preservation, receipt and mapping
controls passed before the new allowance assertion. `ragbacklog.resolutioncorrectioninput`
now projects a request-only view using the original ceiling and shared route/reset
ledger. `ragapplicationprovider` first verifies the original frozen prompt binding,
then uses that view for the system message and presented input of an admitted
correction. Original task bytes, evidence, references and input identity remain
unchanged. The existing ordinary one-correction exception still includes the
already-admitted call; this projection never grants admission or changes budgets.
Receipt replay does not refresh or reissue a paid request. Actual prompt hashes
and the sent body remain in normal observability.

The QA tests first failed with the original uncaught PermissionError (two errors;
other five controls passed). A separate native macOS reproduction retained an
owned unreaped child, observed its group as `Z`, and received `errno=1` from
`killpg(SIGTERM)`. This reproduces the original symptom without PID reuse; the old
run lacks enough identity/state evidence to prove its exact mechanism.

The runner now observes exit with POSIX `waitid(WNOWAIT)` and reaps only after
cleanup, so the owned group number cannot be recycled while it is signalled.
On macOS EPERM after leader exit, a bounded successful process inventory must
confirm that no live group member remains before treating cleanup as complete.
Actual denial, an uncertain inventory or other cleanup errors yield failed,
non-reusable receipts with the process exit code and cleanup diagnostics.
Timeout and cancellation remain bounded; this is QA infrastructure only.

Nine focused harness tests pass in 5.118s, including normal/failed cases,
isolation/reuse, reserved identity, denied/unknown cleanup, timeout, TERM-ignoring
child, cancelled descendants and an exited leader with a surviving child while
an unrelated process remains alive. Captured development evidence is in
`/tmp/rag-qa-05-baseline.txt`, `/tmp/rag-qa-05-zombie-reproduction.txt` and
`/tmp/rag-qa-05-targeted.txt`; final CTest receipts provide durable QA evidence.

## Qualification

The six-case targeted acceptance passed in **9.53s**: ordinary correction 4.57s,
advanced correction 5.70s, failed correction 4.30s, budget refusal 4.95s, receipt
recovery 6.10s and the nine-check `qa_execution` case 4.26s. Both actual system
and presented user input show 2 → 1; the same stored input hash/reference map and
separate actual prompt hashes are retained. Final qualification accounts for **132/132 passing required cases**.
Changing the shared runner invalidates old runner identities; the stable full
selection must execute those cases under the repaired cleanup boundary. Existing
passes with exactly matching new inputs will still be reused.

The first full selection stopped on the captured prompt-contract snapshot after
61 cases in 155.74s. The expanded two-call fixture adds one effective system
hash: comparison of retained HTTP captures proves its sole difference from the
existing resolution prompt is remaining calls 2 instead of 1. All four original
system/schema pairs remain byte-identical. The reviewed expected snapshot adds
this fifth pair; no template/schema was changed and no assertion removed. The
selection resumes with exact-input passes retained, rather than repeating
unchanged product execution. Diagnostic run:
`qa/runs/regression_prompt_contract/20260919T175034-b137fa25`.

## Final local result

The resumed complete selection passes **132/132**, with **68 fresh executions
and 64 exact-input retained passes**. All previously passing relevant checks
remain passing; no disabled case is counted as a pass. The original
`regression_operator_diagnostics` journey passes under the repaired runner.
Final documentation-only verification and the current-input receipt audit close
out this candidate without repeating unchanged product cases. All four acceptance
criteria are locally satisfied. Other-platform qualification remains separate.

Native artifact SHA-256:
`91ad7e7a23ef9bc80acba01b429a0d3a22facdea55233279be6f51372d0feddb`.
The current report is `cmake-build-debug/qa-report.json`; retained run receipts
and logs are under `cmake-build-debug/qa/runs/`. Expected injected failures are
asserted inside the harness test, not relabelled as passing product executions.

The combined ESC-OPS-03/04 and QA repair remains uncommitted and uninstalled.
No push, publication, hosted calls, corpus run or database-policy change occurred.
Contention remains monitored, with no database redesign required by this work.
