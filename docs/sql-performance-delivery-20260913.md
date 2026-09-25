# SQL performance repair delivery — 13 September 2026

## Actionable corrections and waiting states — 25 September 2026, local candidate

`ragbacklog` keeps correction validation and note/gap writes in the existing
review transaction. Note supersession uses the note primary key; the answer
updates one open gap by its gap primary key. Waiting-task discovery compares
the existing bounded question packet and uses the current kind/subject lookup;
unchanged waits are excluded by the dispatch predicate before worker claim.
`backlogsummary` and `ragreportservice` add read-only counts over task state,
decision history and pending reviews. Their review effect lookup follows the
stored decision or external action ID; accepted external corrections are
counted through that same keyed action/review join. This adds no per-task application
loop. No schema, index, new transaction owner or corpus-scale claim is added.
The focused `durable_backlog_actionability` case exercises those paths; the
full performance and regression gates remain separate.

## Sparse-node review closure and exact support — 25 September 2026, coordinator-reviewed local checkpoint

The R1 review repair removes the current-evidence validation query from reject
and dismiss. Acceptance retains that validation after its existing fresh-packet
check inside the pending-review transaction. Review and decision rows remain
keyed by their existing primary keys; the pending-state update and task/decision
history use the existing transaction. R2's duplicate-support check uses the
`claim_support(support_id)` primary key and settles without staging or publishing
a generation. The endpoint-mention lookup uses the existing
`mentions_concept_visibility` index and one cited chunk. No schema, index,
per-item scan or new transaction owner was added. `durable_backlog_sparse_edge`
checks one accepted publication, stale review closure and a second exact-support
review; broader SQL scale and full regression remain in the programme gate.

## Logical debt and finish status — 25 September 2026, coordinator-reviewed local checkpoint

`ragreportservice` reads terminal decision existence through the existing
`maintenance_decisions(task_id)` path while grouping task versions by logical
question. It uses no per-question application loop and writes nothing.
`ragbacklog` checks selected workflow IDs, pending reviews and task ownership
only at window closure, then projects status with bounded cohort JSON and
existing job/event indexes. The nonempty identity/graph closure guard reads two
rows by the existing unique `maintenance_scan_cursors(kind)` key and compares
their current scan token; status performs no discovery writes. Accepted defer
uses the same indexed decision-existence lookup as terminal review decisions.
The source-state and repeated-read controls in
`native_surfaces`, plus `regression_source_maintenance`, are the focused SQL
evidence; corpus-scale timing and full regression remain in the final gate.

## rxvector consolidation — 19 September 2026

The provider replacement preserves all projections, indexes, transaction owners
and visibility loops. The same binary sidecar avoids per-window SQL reads;
returned hits still use the existing indexed visibility projection. No SQL or
schema change is needed. Both implementations return the same twenty ordered
passage lists at 0.965 s median. [Qualification](rxvector-consolidation-20260919.md).

## Native vector projection — 18 September 2026

Exact-native retrieval reads the complete binary vector matrix and uses the existing indexed chunk/profile/digest membership projection for returned hits only. It never fetches vector blobs inside its candidate loop. Publication reuses the bulk active-embedding projection; SQL visibility remains authoritative. [Regression and performance evidence](native-vector-delivery-20260918.md). The [19 September phase profile](native-vector-delta-20260919.md) distinguishes this retrieval read from the separate preflight read/hash: both happen in a complete public query. SQL visibility takes about 0.5 ms in the serial example; the dominant avoidable cost is binary-buffer accumulation, with duplicated file verification a separate follow-up. A scratch append variant proves the speed effect without changing the qualified product.


## Vector reporting — 18 September 2026, locally verified

The existing `ragreportservice` projection selects one compatible publication
instead of independent maxima across profiles. Its shared read query restricts
embedding membership to that profile and visible parents/links before counting
links and distinct parents; the existing profile dirty revision is read with
the same publication. Report and narrative recheck share the helper. This is
one report snapshot, with no writes, per-parent query loop, schema or index
change. The report's model uses the same deterministic selection as its counts
and observation snapshots. Existing pending-link behavior is retained before
the first publication. The scratch query plan exposed two membership scans in
the first draft; link and distinct-parent counts now use one aggregate over the
joined membership. Existing primary-key lookups resolve embeddings and parents;
no per-parent prepared-statement loop is added. Final targeted checks passed
on both VMs in 8.66 seconds. Full-corpus acceptance verifies 36,319 covered
parents, 36,328 windows, a current index and zero integrity issues. See the
[acceptance and qualification boundaries](scottish-bge-migration-20260918.md#completed-corpus-acceptance).
The separate full-corpus transaction-contention evidence remains RAG-PERF-01.

## Windowed embeddings — 18 September 2026, locally qualified

The existing `(input_digest,embedding_profile_id)` uniqueness and parent/embedding
link key support multiple vectors per chunk. No new table or index is required.
Native token admission and inference finish before the existing worker write
transaction. That transaction publishes the whole validated list and task
completion; the generation is read once. Retrieval keeps the existing bounded
128-row pages/prepared member query, now retaining parent-plus-input identities
until scoring. Every page scores all its windows, then retains only its best distinct parents
up to the existing vector limit; the cross-page ranking pool stays bounded as
before. The fail-first candidate-count assertion is recorded with the change.
The [delivery record](windowed-embedding-delivery-20260918.md) retains atomic
second-link failure and later-window/distinct-parent regression evidence.

## Essential observability follow-up — 16 September 2026, locally qualified

Job/item example filters are composed before keyset paging. Correlated lookups
use existing item/attempt, task-item and event-type indexes; full bodies are returned
only by explicit section inspection. JSON metadata is extracted within SQLite. Job-list projection stays shared with the
repository. Request capture joins the existing intent transaction and failure
diagnostics join settlement/uncertainty transactions. Slow checkpoint timing and
claim-context timing join their existing transactions; no per-statement trace or
idle-poll event is added. Failed BEGIN emits through the existing safe operator
sink. On the 4.04 GB isolated copy, existing reads showed no material regression;
new summary/item search medians were 269–314 ms and filtered job search 584 ms
(with a 5.59 s first sample). Synthetic recording median increased by about 7 ms;
runtime differences prevent attributing that delta solely to capture. Raw samples
and limitations are in the [observability record](observability-delivery-20260916.md).

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

## Maintenance route selection follow-up — 16 September 2026

The approved [escalation delivery](maintenance-escalation-delivery-20260916.md)
reuses task/item/provider indexes and transaction ownership. Eligibility and
ordering have one SQL producer shared by dispatch and bounded queue pages;
status aggregate counts are separate from the bounded item projection. Selected
source reads use canonical source/revision/span equality and visible-generation
checks. Supplemental catalogue reads are bounded to selected chunks and the
existing 1000-concept/packet-byte envelopes. Relevant-evidence refresh happens
once before freezing a dispatched item, with provider receipts left immutable.
The existing scale, publication, source-scope and durable backlog fixtures form
the final regression gate; no performance result is claimed before that gate.

## Checkpoint follow-up — 17 September 2026

The approved repair moves the active-funded-batch decision before the checkpoint
writer transaction. It reuses `jobusagevalues` and the existing route budget
policy; individual claim/admission transactions remain authoritative. Global
outcome reconciliation and discovery run when needed at drain/closure, rather
than on every worker poll with queued work. No indexes or schema changed.
Failed BEGIN preserves its original SQLite boundary and emits UTC diagnostics;
only that unstarted checkpoint can be deferred to an existing worker poll.

Eight opened connections and a deliberately held writer reproduce 160 failed
checkpoint acquisitions in the installed baseline owner. The repaired guard
avoids all 160 acquisitions without changing state or provider/accounting rows.
See [measured results and limits](maintenance-follow-up-delivery-20260917.md).
The actual competing writer in the Scottish soak remains unidentified, and
local polling throughput is not live provider/task throughput. Full qualification
and future live validation retain their separate status in the master register.

## ESC-OPS-02 route-count correlation (17 September 2026)

The inner capability lookup in `ragbacklog._routecallcount` now aliases its
`maintenance_tasks` table, preserving the caller's outer task key in set-based
selection and exhaustion. It remains one primary-key lookup per existing task
projection; capability-specific DISTINCT provider counting and reset indexes
are unchanged. No extra query, loop, transaction, schema or index. The
[isolated regression](advanced-call-budget-delivery-20260917.md) reproduces an
ordinary first row incorrectly classifying another advanced task, and checks
three/five-call worker sequences with independent usage/source assertions.

## Retrieval CPU repair (18 September 2026)

The measured ANN repair changes in-memory JSON traversal and duplicate lookup,
not the owning member SQL, visibility predicates, indexed identity lookup,
128-row scoring page or transaction scope. Same-generation queries scan the
same 11,006 vectors and return identical passages, scores and claims while
whole-command time drops from 10.47 seconds to 3.41/1.64/1.63 seconds. This is
evidence for avoidable CPU/copying cost, not a resolution of the separately
observed migration write contention. See the
[repair record](retrieval-profiling-20260918.md) for exact artifacts and limits.

## Verified retrieval payload (19 September 2026)

The preflight SELECT moves from `ragqueryservice` into `ragretrieval` alongside
its payload owner. The existing compatibility predicate, indexed publication
selection, final current-state lookup and visibility queries remain unchanged.
Statements are finalized before provider work; no transaction is held over a
model call. Reusing verified bytes removes the second file read/hash, not the
SQLite publication check. IVF's per-member indexed SQL and 128-row page remain;
its redundant in-memory norm scan is removed. Profiles attribute most remaining
IVF cost to JSON parsing (591 ms) versus member SQL (69 ms) on the example;
this is separate from concurrent migration-write contention. See
[phase evidence, corpus equivalence and qualification](retrieval-tightening-20260919.md).

## ESC-OPS-03 lifecycle preflight — 19 September 2026

Backlog validation adds one task-ID lookup and one concept-ID lookup for a type
correction only, using existing primary keys. Note-selected subjects reuse the
existing bounded catalogue membership projection; selection is shared with
application. There is no scan of corpus history, per-passage query, schema/index
change or new transaction. Lifecycle SQL and transaction ownership remain in
their existing modules; SQLite detail is captured immediately on INSERT failure.
The isolated positive/repeated-correction regression checks rollback, history,
source, receipt/usage and generation. [Results](esc-ops-03-delivery-20260919.md).

## ESC-OPS-04 current correction context — 19 September 2026

One read-only task-ID lookup projects the original bounded input with a refreshed
remaining-call value, using existing route/capability/reset counting. No new
transaction, schema/index, corpus scan or per-passage query. Durable job input
remains immutable. The ordinary and advanced correction fixtures assert sent
context, frozen input/reference identity, source/vector state and usage.
[Acceptance](esc-ops-04-qa-cleanup-delivery-20260919.md).

## 20 September settled-question comparison

The new cursor uses `maintenance_tasks` state/identity and existing parent/subject
indexes under the existing maintenance writer transaction. It pages leaf questions
and builds only their local packets, never all corpus evidence. Incident claims
and their supports use endpoint/claim indexes; the new reader stops at the packet
byte ceiling and finalizes on every exit. Assessment lookup uses the existing
`job_events_item_type` prefix `(item_id,event_type)` with a task-specific event
name, or the accepted review record. No schema/index or transaction owner changes.
The new bounded-page/packet and unchanged-context controls are recorded in
[beta delivery](beta-delivery-20260920.md). All 133 required local cases pass;
the 200-call copied-corpus run closes cleanly with zero integrity issues.
This is bounded functional/operational acceptance, not a new scale benchmark.
