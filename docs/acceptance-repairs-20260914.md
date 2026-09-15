# Scottish master acceptance: operator workflow repairs

Baseline: published `dd96144bb3689ad4da4a9a43c8df914555402877`. The separate
ScottishHistory acceptance task reported AC-04 through AC-08 from the installed
build. Its evidence remains under
`/Users/adrian/Documents/ScottishHistory/reports/codex-acceptance-20260914/`.
Product work here used scratch libraries and local provider fixtures. Adrian
subsequently authorized staging the tested repairs in the master and resuming
the existing acceptance task; the completed results are recorded below.

## Agreed behavior

Failed embedding: leave that item pending or failed. Successfully stored
embeddings: include them in search independently. Existing documents: retain
usable search coverage while new work proceeds. Restart/retry: finish
outstanding work and index activation within the approved policy.

Completing a controller or admitting zero items does not mean missing embedding
coverage was repaired. An explicit retry preserves history and existing attempt
limits; a blocked retry must remain visible as blocked, not successful work.

Keep the operator workflow simple: execute within the configured limits, report
what completed, and retry outstanding work. Do not add preview-count approval
gates or make one unavailable provider block independently eligible work.

## Action checklist

- [x] Read the acceptance evidence and identify owners/callers.
- [x] Run current regression controls before changing implementation:
  `durable_backlog`, `embedding_recovery`, `embedding_exhaustion` and
  `regression_lifecycle` all pass (4/4, 82.21 seconds observed).
- [x] Add regressions and reproduce both failures on the unchanged baseline.
  `embedding_exhaustion` reproduces all three public symptoms: completed empty
  job, complete repair with one missing vector, and run inspection exit 5.
  `regression_lifecycle` reproduces the shared, public and durable state loss on
  both VMs; covered, active, cancelled and ordinary catalogue controls pass.
- [x] **AC-05:** preserve incomplete embedding outcomes in the shared job
  lifecycle and report incomplete repair through public maintenance status.
- [x] **AC-06:** make the returned durable maintenance run inspectable using the
  same owning summary as status, without writes or duplicated state rules.
- [x] **AC-07:** remove the unnecessary preview-count prerequisite from the
  acceptance guidance; confirm that apply enforces the configured item/call
  limits atomically before any provider work.
- [x] **AC-08:** trace and test zero monetary budget with a paid embedding route;
  distinguish an actual admission defect from a misleading unused route preview.
- [x] Verify failed and successful controls, zero extra provider calls,
  preserved attempt limits and source/receipt history, then run the full suite.
- [x] Document the public behavior and regression coverage.
- [x] Stage the tested candidate in ScottishHistory, preserving its previous
  installation, configuration and existing library.
- [x] Resume the existing acceptance task at Adrian's request; retest the
  repairs and continue the approved ingestion and maintenance sample.
- [x] Reconcile the acceptance results and explain the retained grounding
  rejections from their packets and the owning validator.
- [x] Delegate the five pending review decisions at Adrian's request and
  reconcile their applied outcomes: four accepted, one rejected.

## Diagnosis and scope

AC-04 is an inherited one-attempt configuration block, not a newly failed
provider call. Its ceiling is explicitly outside the acceptance approval.
This repair does not raise it or rerun master work.

AC-05 crosses the shared lifecycle owner (`raglifecycle`) and backlog owner
(`ragbacklog`). Backlog closure records an incomplete run when embeddings are
missing, but later job projection/refresh considers only the newly admitted
items; an empty repair job can therefore become completed. The public backlog
summary also presents the window's closure reason `complete` without that
incomplete outcome. Fix the shared owners and their callers together; do not
add status-only overrides or another completion policy in an adapter.

AC-06 is a supported run-ID journey: `maintain inspect` explicitly accepts run
IDs. Its durable lookup (`inspectbacklog`) currently handles tasks, workflows,
decisions and external actions, then falls back to the older maintenance-item
table. Durable window IDs returned by apply therefore produce not-found.

Existing `embedding_exhaustion` covers retained provider ceilings and a second
repair window, but does not assert that empty second job's public outcome.
`embedding_recovery` provides the successful full-coverage control. Existing
durable-backlog tests exercise task inspection, not the apply-returned run ID.

AC-01 (historic Rawlinson identity) and AC-02 (retrieval refinement) remain
separate content/quality observations; no current-build cause has been proven.

AC-05/06 focused regression is green: 4/4 tests, 126.71 seconds observed under
shared-machine load. AC-08 is a real admission defect: the added cost-route
cases in `durable_backlog` and `regression_ingest_capacity` reproduce paid work
queued/reserved at zero cost, including starvation of the subscription task in
a one-item batch. Positive paid, local and subscription controls pass. The
fix uses the shared admission owner and backlog selection, with no new stored
flags, timeout, approval or retry protocol.

AC-07 is an acceptance-guidance blocker, not a missing ingestion safety feature.
The new native controls prove that either configured item/call limit rolls back
source, chunk, job and generation changes with zero provider calls. A two-chunk
embeddings-first apply succeeds at the limit with no extraction queued. The
acceptance prompt now relies on those existing controls and explicitly removes
the separate preview-count prerequisite. No ingestion implementation change.

AC-08 targeted acceptance now passes: `durable_backlog` on both VMs and its
native continuation (14.90 seconds observed), `regression_ingest_capacity` on
both VMs (2.24 seconds), and native `embedding_exhaustion` including AC-05/06/07
(45.15 seconds). Its empty-window control uses a suitable discovery batch for
the earlier scale fixture; no wall-clock performance assertion was added.

Full suite passed **71/71**, including provider validation/redaction, CLI/MCP,
recovery, installation, retrieval and SQL regressions. Observed runtime was
947.06 seconds on the shared machine; this is not a performance threshold.
`git diff --check` also passes. Test log:
`cmake-build-debug/acceptance-repairs-20260914-ctest.log`.

Final tested native artifact:
`2828fc4a3a251aab3731afd2c9f378c8f670c7e171aa3a8397fa129de6f8abb6`.
The source repair checklist is complete. Changes are uncommitted and, at
Adrian's subsequent request, the tested candidate is staged in the Scottish
master's `tools/`. Installed CLI and fresh MCP status checks pass at schema 19,
generation 23208. The previous installation is retained in
`backups/tools-before-acceptance-repairs-20260914/`; the workspace staging record
is `reports/acceptance-repair-stage-20260914/README.md`. The existing acceptance
task completed the retest and approved continuation after its earlier stopped
attempt. The earlier zero-call closeout is historical, not the final result.

## Completed master acceptance

AC-05 and AC-06 close on the staged candidate: the retained empty repair job
reports `completed_with_errors` with five missing embeddings, and inspection
accepts its original returned run ID. AC-07's separate preview-count gate is
retired. Normal ingestion admitted eight chunks within the configured limits;
all eight embeddings were stored and the index activated despite the five old
gaps. New and existing passages remain retrievable with resolved citations.
Repeating the unchanged import returned `identical-no-op`, with no job or calls.

AC-08's bounded master journey passes: eight managed `gpt-5.6-luna` turns at low
reasoning ran under zero monetary allowance, with no Gemini calls in maintenance.
The negative unfunded-paid-route case is covered by developer fixtures; the
master's old embedding tasks were independently held by their attempt ceiling.
Ingestion used eight Gemini calls, USD0.000209, and no reasoning calls.

Final `library verify` passed at schema 19, generation 23209, with aligned
manifest and zero repository issues. Configuration was restored byte-identically
to the pre-resumption file, including the approved source registration. All
acceptance workers/controllers stopped; no active acceptance job remains.
No interruption occurred, so interruption recovery was not exercised on the
master. Shared-machine elapsed times are observations, not speed thresholds.

The engineering checklist is complete. After the delegated review follow-up
below, remaining corpus work is retained in the acceptance checklist: five old
embedding gaps held at the unchanged one-attempt limit (AC-04); the unresolved
Lochgary and Hamiltons tasks; and two uncalled tasks returned to pending when
the eight-turn allowance expired. No review remains pending among the five
delegated proposals. AC-01/02 remain the historical content/retrieval
observations. None of the unfinished tasks was marked done.

The grounding trace explains all three rejected outputs. The first orders
quotation matches bytes 201–312 but the selected mention is at 51–57; its
correction covers that mention and succeeds. One Hamiltons support contains
literal backslash-n characters. The final response reuses a quotation matching
bytes 420–433 for a different mention at 148–157. The validator requires the
resolved quotation to overlap the selected connection. Its exact-match priority
also matters when the earlier occurrence is separated by a newline. No new
product defect or need for another validation gate is established by this trace.
The supplied packets already provide the selected spans; a fuller quotation
can disambiguate repeated labels. No provider replay or corpus write was needed.

Evidence: the master's `reports/codex-acceptance-20260914/README.md`,
`ISSUES.md`, `maintenance-outcomes.md` and final verification JSON;
`reports/acceptance-repair-stage-20260914/grounding-analysis.md` records the
source-level diagnosis. Source repairs remain uncommitted and unpublished.

## Delegated review follow-up

At Adrian's request, the existing acceptance agent independently examined and
decided all five pending proposals through supported review commands. It
accepted retain for orders, Duke of York, Ancien Project de Memoire and
de Romilly, resolving those four tasks. It rejected the blanket Lochgary
place-to-person correction because the evidence did not justify applying one
meaning to every affected occurrence. That rejection leaves the classification
question unresolved; it does not certify the existing place classification.

All five review decisions completed successfully. The four retain acceptances
recorded generations 23210–23213 without changing the concepts' labels, types,
lifecycle or versions. No structural classification or relationship change was
applied. One final public verification passed at schema 19, generation 23213,
with aligned manifest and zero repository issues. The configuration and staged
native artifact are unchanged. No provider calls, new workers or maintenance
jobs were launched, and no new product defect was observed.

The acceptance report now contains `five-review-decisions.md` with the evidence
and rationale, `execution/five-review-outcomes.json` with exact identities and
states, and decision/verification logs 72–77. The separate Hamiltons task,
tenant/Union tasks and five old embedding gaps were outside this follow-up.
