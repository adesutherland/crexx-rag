# ESC-OPS-02 advanced call accounting — 17 September 2026

## Approved outcome and acceptance

Adrian approved fixing the remaining-call mismatch and requires all advanced
calls to count against the budget, including configurations with more calls.
Preserve the existing ordinary/advanced allowances and total job budgets. No
special extra concluding call, global limit increase, task reset or corpus run.

1. Ordinary escalation is charged to total job usage. Advanced search, read and
   conclusion calls consume the configured advanced allowance individually;
   failed/correction calls remain counted by the existing receipt owner.
2. Selection, exhaustion, inspection, frozen remaining-call instructions and
   validation agree for the actual task, independent of other tasks' routes.
3. Reproduce escalation → advanced search → read → final decision with a
   three-call advanced limit, and a longer five-call sequence. Preserve the
   direct-conclusion positive control, source/graph state, receipts, token usage
   and released reservations. No extra evidence step after exhaustion.
4. Run affected acceptance, then the full local gate once the candidate is
   stable; record exact-input reuse and remaining installed/live boundaries.

## Baseline and coverage

Baseline main `6b706308220b43bcf163c79410f879f850169f2e`, plus the qualified
uncommitted reference/quotation candidate and dated soak records; preserved.
Five selected exact-input receipts passed the report audit before edits:
`durable_backlog`, `durable_backlog_escalation`,
`durable_backlog_provider_advanced`, `durable_backlog_provider_correction` and
`regression_prompt_inspection`. Selection took 0.09s with no repeated executions.

Existing coverage includes route selection, ordinary search/read followed by
advanced conclusion, retry reset baselines, final no-change, native correction,
retained outputs and job budget limits. It did not exercise an ordinary call
followed by several advanced calls at the advanced ceiling. The new isolated
component case `durable_backlog_budget` exercises that boundary on both VMs.

The first new fixture run reached the expected missing third advanced call
(1.92s) but also found that its direct-control policy had omitted automatic
no-change. That fixture policy is corrected before recording a clean
regression-first result. No product implementation has changed at that point.

## Owning components and diagnosis

`raglifecycle.taskretrycallcount` counts distinct actual provider runs, optionally
by the immutable item's capability and existing reset baseline. `ragbacklog`
composes that counter for eligibility, outcome reconciliation, public retry
facts, frozen prompt allowance and search/read validation. Total job budgets
remain in shared admission/usage owners. No transport or SQLite-provider change.

The route-selection subquery currently names `maintenance_tasks` without an
alias, shadowing an outer `maintenance_tasks.task_id` expression. Literal-ID
inspection/prompt paths remain correlated while set-based selection/exhaustion
can use the first unrelated task's capability. The narrow repair will qualify
the inner task with its own alias; no policy redesign is needed.

## Regression-first result and repair

The clean regression failed only at `advanced call remains dispatchable at
step 3 of 3`, after its direct-conclusion control passed. Execution
`20260917T182132-ee598bdd`, 1.96s, retains the isolated database and logs.
That task has three total calls but only two advanced calls. The old correlated
lookup reads the ordinary control's route; the corrected lookup reads its own
advanced route. This reproduces the mechanism observed in the soak.

The product repair is one SQL-expression change in `ragbacklog._routecallcount`:
name the inner table `route_task` and qualify its columns. All existing callers
use that same repaired expression. No new counter, prompt, allowance, model,
schema, API or transaction boundary. The existing primary-key lookup now stays
correlated with the outer task instead of turning into an unrelated table read.
Final qualification is recorded below.


The first repaired focused selection passed all worker-sequence, prompt-count
and call-ledger assertions, but the new token assertion referenced `job_id` on
`attempts` instead of joining its owning `job_items` row. The independently
queried ledger correctly contained four calls/80 tokens and six calls/120
tokens. That assertion query is corrected without changing its expectation.
Five existing focused cases passed in the same 7.94s selection. The final
three-call test also represents the old premature `failed` state before its
last dispatch, requiring reconsideration without a reset or lost call history.


## Targeted acceptance

`durable_backlog_budget` now passes on both rxvme and rxbvm in 2.93s. Both
three/five-call paths reach their final no-change; every advanced step decrements
the same remaining count, all four/six calls consume total job usage, token sums
are 80/120, and reservations drain. The three-call path accepts the existing
premature failed state without resetting history. The prior focused selection's
five existing cases passed. The full required local selection is recorded below.

Built native SHA-256:
`b2005232c334127351318e115fd6790eed5bd05b922d162526bd94dcb5fdd4a7`.
Linked SHA-256:
`ab3cac9c454496cd75f0fb652f9c344f96b3955536e4e39a10e0dd3a18e7bbaf`.
The Scottish installation and its closed soak remain unchanged by this repair.


## Final local qualification

All **126 required local cases pass**. The full regression selection took
**554.61 seconds (9m 15s)**: 121 executed cases plus five exact-input retained
passes (`regression_prompt_inspection`, `durable_backlog_budget`, `task_reset`,
`durable_backlog_provider_advanced`, `durable_backlog_provider_correction`).
The final documentation edits require only `documentation_contract` again;
the fresh `tests/qa/report.py --require-complete` audit reports 126 passed, with
no disabled, failed, interrupted or not-run required case. No unchanged product
case was rerun for that documentation refresh. `git diff --check` passes.

Coverage includes native admission and shared budgets, successful/failed/budget-
limited correction, receipt reuse and interruption, current/legacy retry and
reset, process/controller recovery, installed CLI/MCP, Gemini loopback smoke,
malformed output and secret redaction. Hosted live calls, platform and longer
endurance gates remain separate. No hosted call or master-corpus mutation was
part of this repair. No configuration ceiling, prompt, model or durable history
was changed. Installation into ScottishHistory, a live repeat, commit and
publication have not occurred.

The four local acceptance criteria are complete. The original failed Scottish
task remains intact; subsequent authorised maintenance on the repaired build
can reconsider a prematurely failed task when its recorded advanced allowance
still has room. This path is covered by the retained-failed-state regression;
it is not authority to restart the expired soak.

Full selection and receipt-audit logs are retained in
`cmake-build-debug/qa/esc-ops-02/`, alongside the report and targeted acceptance
log. The initial failing executions remain under the ordinary per-case QA paths.

## Subsequent authorised publication and live acceptance

The earlier pending-install statement above is the local qualification boundary.
Adrian subsequently authorised commit/publication, installation and a new bounded
run. Baseline `4a9a8c3` is published and installed; the [fresh soak](maintenance-budget-soak-20260917.md)
selected the original premature failed task naturally. It resolved on its third
advanced call, fourth total call, with the accurate one-call-left instruction.
A separate invalid final response exhausted exactly three advanced calls while
retaining five total calls. No reset or increased allowance. ESC-OPS-02 bounded
live acceptance is complete. ESC-OPS-03 recording failure and correction prompt
wording remain separate observed follow-ups; no broad quality sign-off follows.
