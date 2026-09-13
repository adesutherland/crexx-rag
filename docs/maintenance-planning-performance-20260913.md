# Maintenance planning and apply performance review — 13 September 2026

This diagnostic is historical. The complete repair and passing acceptance are
recorded in the [SQL delivery checklist](sql-performance-delivery-20260913.md).

The six minutes eighteen seconds of Test 3 preparation has a substantial SQL
indexing cause. Three experimental indexes reduced a fresh full planning run
from **190.18 seconds to 20.63 seconds**, with the same maintenance worklist and
digest. Apply also repeats planning and has a separate slow backlog checkpoint.
The three indexes alone do not finish the performance repair.

This is a diagnostic review. Product source, schema migrations and the user
library were not changed. No provider calls were made. Experimental indexes and
one unexecuted apply were confined to an additional disposable database copy;
the diagnostic job was subsequently cancelled through the public command.

## Evidence and scope

- Checkout: `/Users/adrian/CLionProjects/crexx-rag-review`,
  `ab620e5f303696ba477d6b91845f075789b779c9`.
- Same frozen native used for Test 3:
  `/private/tmp/crexxrag-simplify-20260913/installed/bin/crexxrag`.
- Source for measurements: the disposable Test 3 corpus at
  `/private/tmp/crexxrag-smk006-V6YatF/smoke-library`, generation 24928.
- Indexed diagnostic copy, created with SQLite backup:
  `/private/tmp/crexxrag-plan-profile-20260913/indexed-library`.
- Original Test 3 timings were 160 seconds planning plus 218 seconds apply.
  The new measurements use the post-Test-3 corpus and normal machine load;
  they are not an exact replay of that earlier run.

The public `maintain plan --minutes 15` command ran successfully against both
copies with the same configuration and native executable. The complete
maintenance canonical payload and digest matched exactly. Both selected eight
items and zero cognitive chunks; the only differing preview field was timing.
The three indexes were the only schema/content differences before the indexed
plan. No `ANALYZE`, data cleanup or new build was required for this experiment.

Raw timings, query plans, samples and comparisons are in
[`qa/maintenance-planning-performance-20260913/`](qa/maintenance-planning-performance-20260913/).

## Confirmed missing access paths

`ragimprove.createimproveplan` enumerates 28,917 eligible chunk occurrences to
retain a maximum of eight candidates. `ragclaims.rankchunk` performs several
SQL queries per candidate. Three query patterns repeatedly scan whole tables:

| Lookup and source | Missing leading key | 200 executions before | After experimental index |
| --- | --- | ---: | ---: |
| Content reuse, `ragclaims.crexx:868` | `revision_chunks.content_id` | 1.028892 s | 0.001080 s |
| Visible support count, `ragclaims.crexx:432` | `claim_support.revision_chunk_id` | 0.225262 s | 0.000339 s |
| Pending chunk review, `ragimprove.crexx:517` | JSON `revision_chunk_id` in pending reviews | 1.173816 s | 0.000336 s |

The experiment used these indexes, one at a time on the diagnostic copy:

```sql
CREATE INDEX profile_revision_chunks_content_generation
ON revision_chunks(content_id, visible_from_generation);

CREATE INDEX profile_claim_support_chunk_visibility
ON claim_support(revision_chunk_id, visible_from_generation, visible_to_generation);

CREATE INDEX profile_reviews_pending_chunk_type
ON reviews(json_extract(proposal_json,'$.revision_chunk_id'), review_type)
WHERE state='pending';
```

Every sampled result matched before and after. `EXPLAIN QUERY PLAN` changed
from scans to indexed searches; the first two became covering-index searches.
The existing schema-17 `reviews(subject_id,state)` index supports task review
holds. It cannot serve this different JSON chunk lookup.

A ten-second sample of the original native planning process found roughly 96%
of main-thread samples inside `rxsqlite_step`. With the indexes, the full native
command improved by about 89%, or 9.2 times. This confirms that the expensive
SQL is material to the application, beyond the isolated Python SQL timings.
Conditional trigger queries do not run for every candidate; extrapolated
per-query timings in the raw diagnostic file must not be summed as a measured
breakdown of the command.

The apparently expensive sparse-node degree query already uses the two claims
endpoint indexes: its complete 27,560-row result took 0.153 seconds in the
standalone SQL check. Active analysis-note selection took 0.105 seconds for
10,381 rows. Those queries are not the main planning bottleneck identified here.

## Repeated planning and remaining apply cost

`ragproduct._maintainplan` calls `_preparemaintenance` at line 1405.
`_maintainapply` calls it again at line 1299, rebuilding and ranking the same
kind of full-corpus preview to compare its digest. `_preparemaintenance` also
repeats the maintenance census until the selected cognitive subset converges.

In automatic mode, `startbacklogwindow` then calls `tickbacklogwindow`, which
does its own `_scan`, workflow expansion and `_dispatch`. The preview selected
eight advisory notes and discarded all cognitive candidates; automatic
dispatch selects durable tasks independently. This is overlapping work and
also makes the preview less useful as a description of the tasks that run.

On the indexed copy, public apply succeeded in **96.34 seconds**, queued eight
items and made zero provider calls. Timestamps show:

- Process started at approximately 17:01:50 UTC.
- Maintenance job/window created at 17:02:07.310 UTC.
- Eight items inserted at 17:03:22.161–17:03:22.168 UTC.

Thus about 17 seconds preceded window creation and about 75 seconds elapsed
inside the subsequent checkpoint before dispatch completed. This checkpoint
holds `BEGIN IMMEDIATE`. A ten-second sample during it had 1,762 of 1,768
main-thread samples inside SQLite stepping.

The remaining delay is therefore also materially SQL work. This review does
not identify one statement responsible for all 75 seconds. The checkpoint
includes evidence assembly and expansion of 44 open workflows, as well as
selection. Small task identity lookups and the bounded identity census were
fast in isolated checks. A standalone cREXX probe using installed `rxsqlite`
(SQLite 3.53.2) confirmed the bounded identity query at 0.653 seconds and the
first alias subject query at 0.170 seconds. Those measurements do not justify
claiming that adding the three planning indexes fixes the whole apply path.

## History audit: were previous fixes lost?

The checked history provides no evidence that these performance repairs were
lost. All four relevant commits remain ancestors of the tested review HEAD:

| Commit | Previous repair | Current evidence |
| --- | --- | --- |
| `02589ec`, 4 September | Ingestion/retrieval scale repair, FTS vocabulary statistics | Schema-7 migration remains; this did not add the three chunk-ranking indexes above. |
| `87fdfd8`, 6 September | Aggregate ingestion candidate occurrence/source evidence once | The aggregate query remains in `ragingest._finalizecandidates`. |
| `17d7acb`, 10 September | Shared reservation aggregation, embedding-only route and less repeated busy-batch census work | The shared usage calculation, embedding-only path and empty-batch scan condition remain. |
| `1edb325`, 13 September | Index task review holds | `reviews_subject_state` remains in schema 17 and the measured database. `ragschema.crexx` is unchanged between that commit and the current HEAD. |

`git blame` dates all three slow query expressions identified in this review
to `446f50c`, 24 August. Searching available branches and reflog history found
no addition/removal of matching indexes on chunk content, chunk support or the
JSON chunk-review expression. The latest baseline simplification did not change
those queries. This supports an old coverage gap rather than a recent revert.

The previous review-index repair explicitly retained an unfinished component:
the handoff's 00:05 UTC checkpoint measured census preparation at 27.62 seconds
after indexing, while selection improved from 28.18 to 0.048 seconds and the
eligible count from 27.40 to 0.040 seconds. It explicitly said the repair did
not remove every source of a long census. Today's remaining checkpoint is
therefore follow-up to known unfinished work; its different duration alone
does not prove a regression because corpus, batch and workflow state differ.

The existing scale coverage is also narrower than complete maintenance startup:
the configured full-volume probe exercises retrieval; the maintenance
methodology fixture checks census/ranking/digest/replay semantics; the recent
30,000-task fixture targets review-hold queries. Passing these does not establish
that planning plus apply is fast on the operational corpus.

At audit time there was a separate checkout/install consistency issue. The
original `/Users/adrian/CLionProjects/crexx-rag` was at `e1a616a` on
`temp/maintenance-deadlines`, **31 commits behind** the review checkout. The
normally installed `/Users/adrian/.local/bin/crexxrag` also differed byte-for-byte
from the tested artifact; its exact source revision was not established by
this audit. However, Test 3 and this profiling used the explicitly named frozen
executable, whose SHA-256 matches the current review build exactly:
`751e3ca283c036f524feee93d5eb6b7565ec424bd4cd18fce038bc419fae0da3`.
Thus the measured delay is not explained by accidentally running that separate
installed binary or building the older original checkout.

The subsequent [version consolidation](version-consolidation-20260913.md)
merged the complete review history into `main`, returned the primary checkout
to that branch and updated the normal installation. That resolves the version
consistency issue; the performance findings in this report remain open.

The practical gap is completing and timing the whole maintenance startup on
one agreed build. Prior successful component repairs should remain credited;
unfinished preparation should remain explicitly unfinished until that flow
works within its intended time allowance.

## Recommended repair

1. Add the three demonstrated access paths through the existing `ragschema`
   migration owner, with focused result-equivalence and query-plan coverage.
   Keep normal review/grounding semantics; account for malformed historical
   JSON when implementing the expression index. This is the smallest proven
   performance improvement and needs no CREXX provider change.
2. Have automatic maintenance planning and apply use the existing durable
   backlog selection owner. Avoid building a separate whole-corpus cognitive
   ranking only to discard it and select different tasks. Retain a cheap
   current-state/configuration check rather than blindly replaying stale work.
   Reviewed mode still needs its exact reviewed-worklist semantics.
3. Time the remaining backlog checkpoint by phase before selecting additional
   indexes or moving evidence preparation. Remove repeated preparation of
   unchanged work and keep the writer transaction short. The present evidence
   supports this follow-up, not an unmeasured list of speculative indexes.
4. For relative `--minutes`, start the execution allowance when the window is
   activated, and retain that deadline across retries. Currently
   `resolvemaintenancetime` fixes the deadline before planning, so preparation
   consumes the requested worker time. Absolute `--until` and overnight end
   times should retain their existing fixed meaning. This is a separate timing
   contract change, not an indexing fix or a reason to increase smoke budgets.

Acceptance should compare the same worklist/results, remeasure planning and
apply separately on a corpus copy, and demonstrate that an ordinary five-minute
run reaches execution with its intended allowance. Run the focused migration
and maintenance tests, then the repository suite for the actual product change.
No full suite was rerun for this review because product code was unchanged.
