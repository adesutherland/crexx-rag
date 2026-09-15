# SQL performance repair delivery — 13 September 2026

ISSUE-01 worker replenishment (15 September): exit eligibility still uses the
`runtime_instances` primary key; only its exit-code predicate changes. Process
finish adds the shared `BEGIN IMMEDIATE` acquisition around its single keyed
UPDATE, outside provider work and existing caller transactions. The partial-pool
status extends its existing conditional job-item count to queued/running states,
using `job_items_claim`; no per-item or new per-poll query, index or migration
is added. The [repair checklist](worker-pool-repair-20260915.md) owns evidence.

Job controls (15 September): the job-list projection no longer materializes
canonical plan bodies at any size. Deadline writes use the existing unique
maintenance job key. Retry reset snapshots counts in one set-based INSERT under
one writer transaction, and skips unchanged snapshots. Its reads reuse
`attempts_item`, `attempts_provider_run`, `maintenance_task_items_task`,
`job_items_embedding_subject` and `job_events_item_type`; no schema/index change.
The shared embedding expression retains the exact JSON-index predicates.
Paid counts remain DISTINCT provider identities, preserving receipt reuse.
History counts are separate from reset-adjusted eligibility counts. Baselines
are numbers rather than clock timestamps or unstable implicit rowids.
The [job controls record](job-controls-delivery-20260915.md) owns acceptance.

T7-10 reuses the controller's existing runtime row and drain queries. The one
new request write is bounded by the `runtime_instances` primary key and runs
once when entering signal-requested drain, outside the signal handler. Child
drain remains bounded by the existing parent-instance index; ordinary heartbeat
and terminal writes carry the reason. No new query per item or schema/index
is needed. Baseline and final evidence are in the
[T7-10 checklist](t7-10-controller-diagnosis-20260915.md).

Test 7 T7-06 adds an uncertainty selector to the existing job-items query.
The job key bounds candidates, `raglifecycle.uncertainitem` uses the existing
item/type and attempt/type event indexes, and held/active/state filters precede
the cursor limit. It reuses the same read snapshot and per-returned-item
recovery projection. No extra catalogue read, queue scan in the client, new
index or stored status is introduced. The operator regression includes indexed
event-plan assertions and selects late held IDs through CLI/MCP without writes.

Test 7 T7-05 adds source-filtered backlog inspection in `ragoperationsquery`.
Source primary-key selection and `revision_chunks_visibility` bound the chunk
set; `maintenance_tasks_subject` supplies its tasks. The summary materializes
that source's chunk/task sets and reuses aggregate counts, while the task page
filters before its cursor and limit. Both share a read transaction; there is
no JSON scan of corpus-wide job inputs, new index, schema or reporting state.
`regression_source_backlog` verifies source denominators, states, pagination,
CLI/MCP, empty/missing sources and unchanged database/provider data.

Test 7 T7-04 repairs the missed `source.show`/`review.show` path: the existing
projection in `ragrepository` uses bound primary-key equality for exact reads;
listing keeps indexed range pagination. The adapter no longer loads a page and
then filters it for the requested ID. No index/migration or per-row lookup loop
is added. `regression_operator_diagnostics` reproduces the late-ID failure with
125 unrelated/target source and review rows, first-ID positive controls, missing
IDs and complete database-dump parity. Final qualification is in [Test 7](test7-overnight-soak-20260914.md).

Current Test 2 follow-up: [action checklist](test2-recovery-delivery-20260914.md).
The existing provider, publication, store and retrieval owners now implement
independent item/search availability and ordinary completion retry. Qualification
is complete: focused 5/5, live Test 2 pass, and all 71 local checks pass after
the reviewed metadata-fixture correction. The checklist retains exact results.

Implements the [whole SQL review](sql-performance-review-20260913.md) on main
at baseline `bfbbdfd95d95a080262d47711c759bc2a9df18a0`. This record distinguishes
implementation from acceptance; a finding is checked only after its complete
repair and relevant checks pass. The original acceptance used no hosted calls
or user-library writes; the separately approved installed smoke follows below.

## Acceptance checklist

- [x] F01: chunk/content/support and pending-review access paths, fresh/upgrade migration.
- [x] F02: indexed extraction-review event lookup, retained malformed JSON.
- [x] F03: concept evidence indexes, separate indexed identity branches, ambiguity/lifecycle preservation.
- [x] F04: automatic preview uses durable owner, bounded census/workflow preparation, reviewed ranking hoists shared facts, relative duration starts at activation.
- [x] F05: indexed admission expiry, one capacity projection, independent active leases and cooldown.
- [x] F06: indexed generation selection/exclusions, reused glossary statements with cleanup.
- [x] F07: shared report/operational projection, combined aggregates, one FTS verification per snapshot, job-scoped usage and observation reads.
- [x] F08: indexed retained outputs and joined provider metadata, correct recovery identity.
- [x] F09: indexed anchors/aliases, bounded spelling sort, phrase census, positive graph fixtures.
- [x] F10: recovery driven by expired items, one counter aggregate per affected job, unrelated jobs untouched.
- [x] F11: native keyset predicates and supporting reverse/history access paths.
- [x] F12: claim publication composes the shared lifecycle decision.
- [x] Architecture, repository guidance, owner map and regression coverage updated.
- [x] Focused regressions, full suite, scratch native maintenance and ingestion smoke checks.

## Baseline and regressions

The original 69-test baseline passed **69/69 in 943.87 seconds** with the installed CREXX package.
Existing fixture journeys cover ingestion/reimport, malformed provider output,
worker recovery, maintenance windows, query policy, repository paging and job
state transitions. New provider-durability checks reproduce all 13 reviewed
missing index paths on the baseline, checking planner choice on fresh and
upgraded libraries. Legacy invalid JSON is retained through the new migration.

## Repairs and acceptance coverage

| Finding | Complete change in the existing owner | Acceptance |
| --- | --- | --- |
| F01 | Schema 18 adds content/generation, chunk/support visibility and guarded pending-review JSON paths. Existing query expressions match the index expressions. | Fresh and upgrade planner assertions; ingestion, maintenance, query and publication journeys. |
| F02 | Extraction-review task holds use a guarded JSON expression index over the relevant event type. | Positive/empty corpus equivalence and retained invalid legacy JSON through migration. |
| F03 | Concept evidence has reverse visibility paths. Label and alias identity candidates use separate indexed branches, deduplicated before checking ambiguity and lifecycle. | Corpus equivalence; ambiguous label/alias fixture; lifecycle and evidence journeys. |
| F04 | Automatic preview defers discovery to the durable backlog owner. Census batches use the remaining item allowance; workflow expansion prepares bounded connection pages using stable identity cursors. Reviewed ranking shares rank facts and query-gap context and hashes only retained candidates. Relative time starts at activation. | Stronger duplicate occurrence, held connection progress across publication, delayed activation and unchanged restart deadline; complete split/merge/retirement and maintenance tests. |
| F05 | Admission expiry is indexed. Capacity reads recent rate usage, all active leases and cooldown together without conflating their different lifetimes. | Active lease older than the rate interval, cooldown, budget and concurrent provider fixtures. |
| F06 | Generation candidate selection and exclusions are indexed. Glossary insertion/deletion statements are prepared once per operation and reset, rebound and finalized on every path. | Ingestion/reimport and glossary fixtures, plus generation query plans. |
| F07 | Report aggregates and operational projections share owners; observation reads fetch one row; job usage aggregates distinct provider runs once. Complete FTS parity is reused only within the same read snapshot. | Report/observation, numeric-row failure cleanup, duplicate FTS rows and provider receipt/accounting fixtures. |
| F08 | Retained outputs have task/latest and provider-run access paths. Provider metadata is fetched once outside support loops. Review joins also constrain the decision's task. | Positive retained-output lookup controls and recovery/review journeys. Recovered output can belong to an earlier item, so provider-run identity is retained. |
| F09 | Question phrases seek label/alias indexes; spelling branches bound their sorted candidate sets. Single-term statistics retain existing semantics without the ineffective multiword body scan. Notes, conflicts and ambiguities have measured reverse access paths. | Eight ordered anchor comparisons including Unicode and repeated spaces; positive graph fixtures; retrieval and Unicode regressions. |
| F10 | Expired items drive reservation/attempt recovery. Reservation totals are recomputed once per affected job. | A trigger rejects any counter update on an unrelated job; existing receipts, uncertainty and fencing tests remain required. |
| F11 | Generation and composite repository pages compare native keys while retaining public cursor encoding and legacy fallback. Task/history lookups gain measured leading-key indexes. | Three late-page ordered equivalence checks, positive history queries and public paging regression. |
| F12 | Claim publication delegates job completion to `raglifecycle`; status counting and single-job reads share the lifecycle projection. | Paused/cancelled/window state characterization and progress timestamp regression. |

Schema 18 adds 25 indexes. Migration bodies and ordered checksums 1–17 remain
unchanged. The diagnostic corpus measured 57,241,600 bytes (54.6 MiB) for the
new indexes and 8.33 seconds to create them. This is an explicit storage/write
tradeoff for the observed access paths, including positive growth controls.

The review's remaining full reads are deliberate: report still performs deep
verification, status still reports current missing-embedding coverage, and
workflow retirement still checks the complete impact set. Their duplicate
reads and unbounded packet preparation were removed where identified. These
repairs do not add a cache, move transaction ownership, or change receipt and
publication rules. Indexed explicit task-detail OFFSET pages remain compatible;
the corpus-wide generation/composite page predicates now seek native keys.

The original statement inventory is the review baseline. Acceptance combines
query-family equivalence, positive planner controls and public journeys; it
does not claim a separate runtime benchmark for every dynamic SQL construction.

## Measured corpus result

The native executable was exercised on a SQLite backup of the Test 3 scratch
corpus: generation 24928, nine sources and 34,907 chunks. The source copy was
opened read-only; migration and maintenance acted on the new disposable copy.

| Public operation | Measured time/result |
| --- | --- |
| `library migrate` | 12.40 seconds; schema 18, zero verification issues. |
| `maintain plan --minutes 15` | 0.204 seconds on the final executable. |
| Exact-plan `maintain apply` | 0.625 seconds; eight items; full 900-second activation allowance. |
| `job cancel` | 0.193 seconds; job and all eight items cancelled. |
| `library report --narrative off` | 28.32 seconds; zero storage/repository verification issues; no provider calls. |

The previously installed executable took 41.70 seconds for the same report on
the original scratch snapshot. The semantic report digest is identical at
generation 24928. Both versions report zero storage/repository issues. The
operational digest differs because the new scratch copy retains the smoke
plan/apply/cancel history. This is a single local timing comparison, not a
controlled cold-cache benchmark.

The final plan/apply measurement is a warm repeat on the scratch copy. An
earlier post-repair activation measured 1.24 seconds. The original Test 3
plan/apply took 6 minutes 18 seconds. Automatic preview now approves policy
and defers selection; it deliberately avoids the old discarded whole-corpus
worklist, rather than claiming identical preview work ran faster.

Provider-run count stayed **82,557 → 82,557**. No workers or hosted calls were
started in this corpus smoke. The full suite supplies the actual ingestion,
maintenance execution, malformed-output and recovery journeys through local
fixtures. The corpus still contains its historical backlog and content-quality
holds; zero structural verification issues does not claim those are resolved.

Diagnostic SQL equivalence passed 11 query families, eight anchor questions
and three late-page comparisons. For the retained parameter sets, extraction
task holds fell from 8.914 seconds to 0.000089 seconds and identity census from
7.961 seconds to 0.0106 seconds. These are isolated query measurements, not
whole-command speedup claims.

See [retained evidence](qa/sql-performance-fixes-20260913/README.md) for exact
build/source hashes, native results, baseline failures and final acceptance.

Final acceptance: **70/70 tests passed in 919.24 seconds**, exit 0, including
`regression_sql_performance`. The focused final panel passed **4/4 in 25.51
seconds**. Full QA includes fresh and repeated ingestion, scratch-prefix
installation, provider validation/redaction, complete maintenance execution,
publication, receipts, controller recovery and continuation. `git diff --check`
passes. Product/build/test inputs remained unchanged during final acceptance.

Evidence is retained under `docs/qa/sql-performance-fixes-20260913/`, with
source hashes and an evidence checksum manifest. The repair and evidence are
committed together as `7febbca54fefa33ec90cc775f1b9ab01045fcad9`.

## Approved installed follow-up

The normal installation now matches the qualified native hash above. The
separately approved [Test 3 repeat](test3-repeat-sql-20260913.md) ran on a fresh
disposable corpus copy: plan 0.207 seconds, apply 0.705 seconds, execution
55 seconds, exit 0. Four managed Codex turns produced three resolved tasks and
one retained unresolved decision; monetary API usage was zero. One App Server
timeout was recovered by automatic worker replacement. Verification found zero
issues at generation 24,931, with source revisions, chunks, claims and the
Test 2 citation unchanged. [Test 4](test4-extraction-holds-20260913.md) then
inspected the remaining extraction holds without calls or data changes.
No authoritative library migration or hosted cross-platform qualification is claimed.

## Unchanged index retry — 14 September

[A8](test2-recovery-delivery-20260914.md) moves the unchanged-index decision
ahead of corpus reads and training. Invalidation uses existing indexed
membership/embedding lookups; whole-command retry fell from 26.14 seconds to
2.080 seconds on the final 34,902-vector scratch corpus.

## Acceptance reporting queries — 14 September

The [acceptance repairs](acceptance-repairs-20260914.md) join maintenance run
outcomes through existing unique/primary keys, removing the separate window
read in public job status. Dispatch and its eligibility counts share one route
predicate over existing task fields. No schema, extra census, or per-item
database read is introduced by the route decision.

## T7-08 retained reconciliation policy

`ragreceipts.readexternalidentity` includes the original job's attempt ceiling
in its existing exact job/item projection. A scalar lookup uses
`job_events_type(job_id,event_type,event_id)` and descending event ID with
LIMIT 1; the scratch-library query plan confirms indexed lookup without a sort.
No extra query per inspection step, schema change or worker-loop read is added.
The whole-configuration lookup is removed from reconciliation only; ordinary
worker compatibility remains unchanged. The extended `worker_recovery` case
asserts original budget-policy use after a selected configuration change.

## T7-07 bounded source census

The selected source membership now constrains `ragbacklog` chunk discovery
before its keyset predicate and LIMIT, not after a whole-corpus page. The same
`ragrepository.currentsourcechunks` projection serves operator inspection and
scoped dispatch/coverage; existing source primary key, revision membership and
task subject indexes are reused. Census pages and dispatch waves retain the
configured bounds. No full census, new cursor protocol or schema change was
introduced. `regression_source_maintenance` seeds an old chunk prefix larger
than the page and higher-ranked unrelated tasks; it passes (8.17s), alongside
`regression_sql_performance` (3.41s). Representative query plans use the source
primary key, `revision_chunks_visibility` for current source membership, and
`maintenance_tasks_subject` for scoped task lookup. Only the selected task set
requires the existing priority sort. Summary reads reuse one window-policy
read; scoped waiver counts replace the global count, and unscoped retry checks
retain their scalar path without a new membership query.

## Task reset (15 September)

Reset selects its task inventory once and owns one writer transaction. Per-task
source/evidence reads use the existing complete packet builder. Retry baselines
reuse `raglifecycle.recordretryreset`, narrowed by linked item IDs; this avoids
scanning all job items for every reset task. Scratch `EXPLAIN QUERY PLAN` confirms
`maintenance_task_items_task (task_id=?)` plus the `job_items` primary key, with
no added index or schema. Old review/retry/work transitions are set-based within
each selected task; there is no worker-loop query or duplicate provider-history
implementation. Acceptance/QA: [task-reset checklist](task-reset-delivery-20260915.md).
