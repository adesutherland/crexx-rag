# Rule simplification review — 13 September 2026

The user's direction is to remove checks that do not justify their cost:
"A task completed or needs redoing." This review supersedes the earlier
proposal to expand configuration execution guards. The user subsequently
approved implementation and duplicate removal; see the
[repair record](rule-simplification-repair-20260913.md).

The operating rule should be: accepted work is complete; unfinished work is
eligible for an ordinary retry within the selected run. Keep old attempts and
usage as history. Their presence must not turn an unrelated source import or
configuration change into a recovery exercise. An unavailable old receipt can
remain unavailable. Cancellation means stop scheduling; it does not need to
reconstruct the result of an old request.

## Concrete removal and simplification candidates

| Existing check | Recommendation | Reason and surviving protection |
| --- | --- | --- |
| `ragconfiguration._configurationactivejobs`, line 164: all-job/worker/reservation veto on recording future configuration | **Remove the global execution veto**, rather than combine and enlarge its SQL. Remove volatile job-count changes from plan staleness too. | Apply writes a new immutable config snapshot, the current planning pointer and its audit event. It does not rewrite old jobs, their budgets or their inputs. The existing per-item provider check enforces work compatibility. Retain a transaction and the conditional current-pointer update so two policy edits cannot overwrite each other. |
| `raglifecycle.retrydisposition`, lines 81–83: unknown history checked before `resolved/processed/skipped` | **Let completion win.** | A resolved task must report complete even when an older attempt lacks a response. This is the observed resolved embedding task. Keep the old unknown record and measured usage; neither requires reclassifying the completed task. Existing active claims are settled through their own item/attempt identity. |
| `ragwork.requestcancel` plus `lifecyclejobstate`, lines 408 / 17 | **Stop scheduling and make repeat cancellation a no-op for already stopped work.** Remove the historical-uncertainty dependency from whether that parent has stopped. | The parent currently oscillates between two stored states. A stopped job can retain unfinished items for later explicit retry. The old receipt need not be repaired to stop a run or start another one. No new lifecycle framework or schema is needed. |
| `ragcontinuation.preparecontinuation`, lines 27–35: global runtime count, automatic pause and further active-job checks solely to register compatible policy | **Remove this global registration ceremony with the config veto.** | Continuation already has the normal selected-group cleanup/start path and a transaction for the selected job. Another job's historical registration is not a reason to block this job. Retain the selected job's actual ownership protection when changing its execution. |
| `ragconfiguration.applyreconfigureplan`, lines 196 / 205 / 213: individual identity comparisons plus whole canonical-plan equality; current-pointer SELECT plus conditional UPDATE | **Delete redundant comparisons.** | Exact canonical equality already covers the same plan fields. The conditional pointer UPDATE and affected-row result already detect a concurrent change under the writer transaction. Keep bounded input parsing, the reviewed change identity and rollback on a failed write. |
| `ragwork._completeproviderbatch` / `_ensureprovidermentions` / `_completebatchattempt`, lines 825 / 892 / 936 | **Check publication ownership once on entry to the writer transaction. Remove repeated inner checks and unused standalone-transaction branches.** | The callers already own the same SQLite write transaction and pass a generation. No competing writer can take the item between these checks. Rechecking the lease clock halfway through can reject an otherwise coherent atomic publication. Keep the entry check and atomic commit/rollback. |
| `ragwork.replaydeadletters`, lines 541–543 / 565 | **Use one replay-eligibility decision. Remove the hand-written descendant veto once covered by the shared family decision.** | Replay currently checks descendants, then invokes `retryfamilyhold` for each selected item in the same transaction. Keep one owner covering the source and relevant family; do not remove prevention of simultaneous duplicate execution. The source's own unknown attempt is distinct from the peer-only helper and must not accidentally disappear during consolidation. |
| `ragoperationsquery._itemrecovery`, line 407 | **Remove the unconditional “job reconcile” instruction for unknown outcomes.** | The command only recovers a retained Codex identity. A plain diagnostic that the old response is unavailable is enough for Gemini. Do not build a new recovery mechanism to make the instruction true. Ordinary explicit retry of unfinished work should be the operational route. |

The first, second and third rows directly address the blocked smoke journey.
The transaction duplicates and replay copy are additional examples of checks
whose location or repetition adds little value.

## The common rules are only partly common

Lifecycle outcome and retry precedence are owned by `raglifecycle`. Work,
receipt and usage modules delegate their main ownership check to its
`activeworkfence`. Admission arithmetic is already a small shared rule in
`ragadmission`; its five outcomes explain whether an existing budget admits a
call and need no replacement framework.

There are still copies: configuration uses raw parent state independently of
lifecycle; reservation has two bespoke uncertainty SQL expressions at
`ragwork` lines 169–170; replay has a separate recursive veto; and maintenance
owns inline claim-fence SQL at `ragbacklog` lines 1038 and 1070 despite the
shared helper. Consolidate at the existing owner when touching those paths.
Do not merely move every old restriction into a common function and preserve
its unnecessary veto.

## Further broad checks worth narrowing

`worksnapshotmatches` compares almost the entire policy, allowing only worker
count to differ. Changing source discovery, query ranking or a plan expiry can
therefore stop an old embedding job although its requested provider work is
unchanged. Narrow compatibility to what that operation actually consumes;
preserve its effective provider request, profile, route and charging identity.
Do not blindly treat all operational fields as irrelevant: timeout, retries
and live admission settings are also read from configuration.

`querysnapshotmatches` enforces whole-policy equality even for lexical
`query inspect`. An unrelated future source or worker edit should not prevent
reading existing evidence. Narrow that check for read-only lexical inspection;
paid/hybrid querying has additional route, dimension and accounting needs and
is not the same operation.

These are source-reviewed candidates, not claims of a completed refactor or
measured speedup. Keep them separate from the immediate smoke unblock if they
would expand the patch.

## Why a larger config guard is unnecessary

Tracing the complete worker path found an existing check in
`ragapplicationprovider._process`, line 118, before each provider operation.
It checks the claimed snapshot against the worker's config; lines 120–127 also
check input identity and the retained route. The earlier concern about workers
checking only at startup was incomplete.

An unfiltered old worker could still claim new incompatible work and record a
refusal; it does not silently make the wrong provider call. The smoke workflow
already uses the ordinary named `job run JOB` path. This operational wrinkle
does not justify a library-wide veto, more history reconciliation or a new
scheduler. Retain the per-item protection; avoid requiring historical jobs to
be drained or settled simply to record future policy.

## Proportionate implementation and checking

Use the existing modules and public commands. No new framework, general
recovery protocol, schema or operator checklist is proposed. Old missing
responses should not be a permanent veto on an explicitly requested redo;
keep the history and account for a new call within that run's allowance.

For the immediate patch, exercise the actual journey: record a new source
while old completed/unfinished jobs remain; run only the new document; stop
and repeat a stop; show completed work as completed. Retain existing tests for
atomic publication, per-item duplicate ownership, valid evidence and bounded
provider work. Update assertions that encode a deliberately removed policy;
do not preserve an unnecessary restriction merely because a test expects it.
Run the normal full suite after the code change, then the planned small
new-document smoke and its no-op repeat. This review does not add a new test
matrix or require another full run for documentation alone.
