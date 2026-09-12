# UX-04 external workflow reconciliation

This is the second approved follow-up after [UX-03](connection-effect-previews.md).
It addresses the OPS-002 external-retirement portion: a correction can finish
through public controls without launching an unrelated maintenance batch.
Reasoned task close/waive and the combined installed recovery journey are
recorded in the [third follow-up](public-recovery-journey.md); neither local slice
closes broader OPS-002 operator/platform qualification.

## Public journey

1. Find the migration with `maintain workflows --concept 'Exact label'` and
   inspect its tasks using `maintain tasks --workflow WORKFLOW_ID`.
2. Resolve each connection through its existing evidence-bound plan, exact
   submission and review. UX-03 exposes the proposed effects before acceptance.
3. Run `maintain reconcile WORKFLOW_ID` to inspect the current generation,
   remaining impact and ownership/review/outcome holds.
4. Run `maintain reconcile WORKFLOW_ID --apply --expect-generation GENERATION`
   using the preview's generation. The command only reconciles that workflow.
5. When returned, inspect `retirement_task_id`, prepare a `retire` resolution,
   submit its exact plan and accept its review. The normal retirement gate must
   still pass. Inspect the workflow again to verify `complete` and the parent
   concept's retained retired state.

MCP uses `rag_workflow_reconcile_preview` with plan access and
`rag_workflow_reconcile` with curate access and `expect_generation`.
The CLI uses the same catalogue and service. Preview has no writes; apply is
transactional and generation-checked. Repeating reconciliation cannot duplicate
a task or publication. A completed workflow is an operational no-op. The third follow-up also recovers
an old unfinished marker when a published retirement record, empty impact and
all normal holds prove completion is safe; it publishes no new generation.

`reconcile-connections` means remaining objects still need their own decisions.
`queue-retirement` means the census permits a retirement question, not that the
parent has already retired. Waiting actions distinguish the configured impact
bound, queued/running ownership, pending review and uncertain provider outcome.
`retirement_task_id` identifies an existing question on a preview and the
idempotently retained question after apply.

## Source ownership and recovery

`ragbacklog._censusworkflow` is the shared per-workflow census and fan-out owner.
Both normal window expansion and the targeted `reconcileworkflow` entry point
call it. The public entry uses the workflow's retained compatible policy;
it creates no window, job or worker and does not renew allowances.
`ragmaintain` remains the graph lifecycle and retirement gate owner.
`raglifecycle.uncertainitem` remains the common uncertainty definition.
`ragmaintain.workflowholds` supplies census counts; its `retirementready`
procedure owns publication readiness for external proposals, workers and legacy
lifecycle reviews. Own-task ownership/review exclusions follow normal task/fence
validation. Historical uncertainty is never excluded. The actual graph publisher
rechecks all active workflows for the parent under its writer transaction and
closes them atomically with retirement. Preview reuses this rule.
`ragproduct` parses and presents the command; `ragcommandcatalog` is the sole
operation/MCP schema and capability owner. No schema migration is needed.

An empty graph alone is insufficient for retirement while task ownership,
pending review or an uncertain outcome remains. These are explicit holds, not
successful coverage. Existing tasks, reviews, attempts, provider receipts,
cumulative usage and source history remain available.

## Evidence

Baseline: `4159bd7`, full local gate **59/59 in 758.92 seconds**. The added
`durable_backlog` case first reproduced the missing public census. The stronger
fixture then performed a real reviewed connection retraction, proved empty
remaining impact and no retirement task, and reproduced only the missing
public preview in **11.35 seconds** before product edits.

After the initial implementation, a further regression reproduced the missing
uncertain-outcome hold in **12.04 seconds**, while preview, access denial,
generation fencing, pending review, queued ownership, retirement, repeat calls
and source/history controls passed. The implementation now uses the existing
uncertainty predicate. A typed boolean-fixture correction is recorded separately
and is not treated as a product defect.

The scenario exercises actual CLI parsing and MCP calls. It checks exact task
identity across repeated census/apply, a completed workflow no-op, unchanged
unrelated tasks/jobs/work items, one reviewed retirement generation, retained
history, zero provider calls, source counts and foreign keys on both VMs.
Metadata comparison found exactly two added tools, no removed/changed tools and
an unchanged read-only tool catalogue before updating the expected snapshot.

The first focused implementation passed **5/5 in 27.08 seconds**. Review then
added a late-hold race and legacy lifecycle review case during the full run.
That run passed **58/59 in 730.55 seconds**; only the newly extended backlog
case failed, with every original regression passing. A separate focused run
reproduced all three missing checks (census legacy review, late-hold review
preview and late-hold acceptance) in **12.14 seconds** before the shared
readiness repair. The original run is retained as `full-initial.log`.

An additional direct lifecycle test reproduced a legacy-review publication
bypass in **12.24 seconds**. Moving the final gate into `ragmaintain` closes
that route too. The stronger guard also correctly rejected two older worker
fixtures that selected retirement while obsolete conflict work remained queued.
Those positive cases now drain that work through normal worker stale checks and
assert zero additional provider calls; their retirement/history assertions remain.
A separate isolated positive control proves legacy retirement closes the parent
and workflow together and rolls back its fixture cleanly.

Focused QA passed **5/5 in 32.39 seconds**, followed by the additional legacy
positive control on both VMs (**1/1 in 13.79 seconds**).
Full final QA passed **59/59 in 805.49 seconds** after clean configure/build.
`git diff --check` passed, all 99 relative links in the changed documentation
resolved, and the production import graph (77 modules) had no cycles.
Native SHA-256: `9c3d1797d3b4dc5829bff7bffa4fa5261e50b09739286511f87423b34a748c4d`.
Linked SHA-256: `bf52fa49fa91f65c0982a7f533a1ce2c1d361705cf3688387bbb8440edd3ae05`.
The fixture-failure full run is retained separately (**56/59 in 1554.21 seconds**);
the three affected checks then passed **3/3 in 148.18 seconds** before the clean
full rerun. No failed assertion or test was removed.

The next full run exposed a separate test-harness defect under concurrent host
build load: native-surface, installed maintenance and local-protocol servers
exited with fixture status 3 before requests arrived; retained attempts show
connection refusal. The shared fixture started its ten-second idle timer before
library initialization or scenario compilation. An eleven-second preparation
delay reproduced the failure in **21.75 seconds** without product changes.
The test server now permits sixty seconds between fixture requests (the existing
embedding-exhaustion case remains at 120 seconds), and reports idle expiration
explicitly. The controlled delay remains in `native_surfaces`. Product call
limits, timeout/backoff negative cases, expected request counts, output validation
and coverage assertions are unchanged. The native executable SHA remained
`9c3d1797d3b4dc5829bff7bffa4fa5261e50b09739286511f87423b34a748c4d`.
 Logs:
`/private/tmp/crexx-ux04-history-red.log`,
`/private/tmp/crexx-ux04-holds-red.log`,
`/private/tmp/crexx-ux04-holds-focused.log` and
`/private/tmp/crexx-ux04-full.log`.

This is local synthetic qualification. It does not claim a fresh Turray trial,
non-macOS qualification or live hosted-provider recovery.
