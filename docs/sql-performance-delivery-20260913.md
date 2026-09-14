# SQL performance repair delivery — 13 September 2026

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
