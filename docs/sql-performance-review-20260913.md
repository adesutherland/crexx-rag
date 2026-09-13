# SQL performance review — 13 September 2026

Implementation and acceptance are tracked in the
[SQL repair delivery checklist](sql-performance-delivery-20260913.md).
The measurements and proposals below preserve the pre-repair review baseline.

The main delay is application SQL and repeated preparation. The wider review
found additional expensive paths beyond the three previously identified
planning indexes. On the same corpus copy, indexing reduced maintenance
census/evidence preparation from **76.14 seconds to 6.00 seconds**, with the
same task identities, evidence fingerprints and task dispositions.

This review used isolated experiments. **At that checkpoint, product source,
schema, installation and user libraries had not been changed.** No providers
were called. These experiments alone did not establish the time for a repaired
`maintain plan` → `maintain apply` → worker run.

## Baseline and coverage

- Primary checkout: `/Users/adrian/CLionProjects/crexx-rag`, `main`,
  `bfbbdfd95d95a080262d47711c759bc2a9df18a0`.
- The [version consolidation](version-consolidation-20260913.md) remains
  authoritative. The major refactors and earlier performance fixes are present.
- Source corpus: the disposable Test 3 library at
  `/private/tmp/crexxrag-smk006-V6YatF/smoke-library/library.sqlite`, opened
  read-only for inventory and source reads; generation 24928, schema 17.
- Experiments used another backup at
  `/private/tmp/crexxrag-sql-review-20260913/library.sqlite`.
- Scale: 34,907 chunks, 347,393 candidate mentions, 63,083 mentions,
  28,750 aliases, 27,561 concepts, 52,583 tasks, 647,388 job events,
  82,536 provider admissions and 4,222 retained maintenance outputs.
- Actual schema inspected: 73 tables including FTS internal tables, 144 indexes
  including automatic constraint indexes, ten triggers and one view.

The [statement ledger](qa/sql-performance-review-20260913/statement-review.json)
records **1,675 SQL construction locations across 34 production modules**,
plus **873 direct execution/shared-scalar helper call locations**. These are
source locations, not 1,675 distinct fully assembled runtime statements.
Every construction has its source expression, owner, indexing assessment,
loop/transaction context, duplicate group and applicable finding.

Of the construction locations, 1,306 are query/DML roots, 213 transaction
primitives and 156 DDL/PRAGMA roots. The query/DML inventory compiled 1,051
standalone diagnostic templates; 954 returned read-side query-plan rows.
**251 assembled constructions still need their complete runtime shape for an
individual plan**, and four refer to a temporary table, migration table or
unfinished CTE. Their source families were reviewed; they are not described as
runtime-qualified. There are 113 repeated normalized SQL-text groups. Equal
text alone does not mean two reads can safely be replaced by one cached value.

Query-plan triage used Python SQLite 3.53.4. The checkpoint experiment compiled
a timer-only copy of `ragbacklog` against the current build modules and ran it
through installed CREXX `rxvme` and **rxsqlite 3.53.2**. It called `_scan` inside
a transaction and rolled back all census changes. This measures the real
cREXX census implementation, not the complete native CLI command.

## Findings and repairs

### F01 — P1: complete the chunk access paths already demonstrated

Owners: `ragclaims:432,868`, `ragimprove:511,517`, `ragschema`.

Ranking repeatedly scans `claim_support`, `revision_chunks` by content and
pending reviews by JSON chunk ID. The same missing content index affects
`ragrepository:210` and ingestion's correlated reuse lookup at
`ragingest:1298`; the support index also benefits assessment packets and
revision retirement/reanchoring.

Add the three access paths through one additive schema migration:

```sql
CREATE INDEX revision_chunks_content_generation
ON revision_chunks(content_id,visible_from_generation);
CREATE INDEX claim_support_chunk_visibility
ON claim_support(revision_chunk_id,visible_from_generation,visible_to_generation);
CREATE INDEX reviews_pending_chunk_type
ON reviews(json_extract(proposal_json,'$.revision_chunk_id'),review_type)
WHERE state='pending';
```

Earlier whole-plan measurement was **190.18 → 20.63 seconds**, with identical
canonical plan/digest. See the [planning investigation](maintenance-planning-performance-20260913.md).
The review-hold index already present on `(subject_id,state)` serves a
different predicate and must remain. Historical malformed JSON must be handled
explicitly in the migration/query pair; adding `json_valid` only to a partial
index can make it unusable by the existing query.

### F02 — P1: stop scanning the complete event history for task holds

Owner: `ragbacklog.enqueuebacklogtask`, line 418; schema owner `ragschema`.

The advanced-review lookup finds candidate tasks through an existing index,
then asks whether each has an `extraction-review-required` event. There is no
index for that **global event-type/JSON-task predicate**. Current event indexes
start with job, item or attempt identity, none supplied by this query.

The instrumented census found eight expensive calls totalling **37.79
seconds**, approximately 4–5 seconds each. Earlier samples that did not match
an advanced task never exercised this inner scan. This explains why the first
small lookup timing appeared harmless.

The tested repair is:

```sql
CREATE INDEX job_events_extraction_review_task
ON job_events(json_extract(message,'$.task_id'))
WHERE event_type='extraction-review-required';
```

On this copy, the selected event type contains 333 records, all valid JSON.
The index occupies **32 KiB**; its initial construction still scans the event
history and took 4.68 seconds. Two representative lookups went from **7.532
seconds to 0.000354 seconds**, preserving their results. Retain the hold
decision; there is no need for a new approval rule or another state ledger.

### F03 — P1: index repeated concept evidence and identity discovery

Owners: `ragbacklog:479,493,507,619`, `ragmaintain:792–795,953–958`;
also `ragreportservice:321`.

An index beginning with normalized alias does not serve aliases by target
concept. The chunk-first mentions index does not serve mentions by concept.
Competing identity and open alias-issue checks also compare `lower(label)`
without matching expression indexes. All are called repeatedly during evidence
construction, including workflow expansion.

The four tested access paths are:

```sql
CREATE INDEX aliases_target_visibility
ON aliases(target_concept_id,visible_to_generation,normalized_alias);
CREATE INDEX mentions_concept_visibility
ON mentions(concept_id,visible_to_generation,revision_chunk_id);
CREATE INDEX concepts_active_label
ON concepts(lower(canonical_label),concept_id)
WHERE visible_to_generation IS NULL AND lifecycle_state='active';
CREATE INDEX maintenance_alias_issues_open_label
ON maintenance_alias_issues(lower(proposed_label),proposed_type)
WHERE state='open';
```

Twenty concept-subject reads improved **0.404 → 0.000357 seconds**; twenty
competing-identity reads **0.388 → 0.000126 seconds**; the 100-row identity
census **4.278 → 0.002044 seconds**. Ordered results were identical.

One query shape still needs improvement: `resolveknownconcept:327` and the
alias-issue packet at `:488` use `LEFT JOIN aliases` with an `OR` spanning
concept labels and aliases. Even with the target index the packet still scans
concepts: ten reads improved only **0.567 → 0.366 seconds**. Generate candidate
IDs from separate indexed label/alias branches, then join/deduplicate once.
Preserve ambiguous names, concept type, ordering and the different lifecycle
rules: alias-issue evidence includes migration parents, while new resolution
targets require active concepts. The active-only index above does not support
every one of those broader branches; consolidate its eventual design when
implementing that rewrite, rather than blindly adding another overlapping index.

### F04 — P1: reduce preparation volume and shorten the writer transaction

Owners: `ragproduct._preparemaintenance`, `ragimprove.createimproveplan`,
`ragmaintain.buildmaintenancecensus`, `ragbacklog._scan/_expandworkflows`.

The observed eight-item allowance does **not** bound census to eight candidates.
The retained policy has `batch_items=100`; `_scan` applies that separately to
each category. The measured checkpoint built packets for 100 aliases, 100
notes, 100 sparse concepts, 100 chunks and 100 identity candidates, plus 16 gaps
and all 44 open workflows. Its task count remained 52,583: this pass still
prepared substantial evidence for existing work.

There is also a separate whole-corpus cognitive preview. It ranks about
28,917 eligible chunk occurrences, repeatedly reads generation/body/counters,
and builds context before knowing whether a candidate will survive the top-N
selection. `_maintenancecontext` rereads the same eight global query gaps for
each candidate. Only the current retained top-N content array is checked for
duplicates; it is not a record of all content already considered. Automatic
maintenance then discards the cognitive selection in this run and starts the
durable backlog, which selects again. Plan and apply both repeat preparation.

Repair in the existing owners:

1. Make automatic maintenance preview/apply compose the durable selection
   owner. Keep reviewed-worklist mode's exact replay contract separate.
2. Hoist generation/global query-gap context once per snapshot. Read chunk
   facts together and build packets/hashes only for retained candidates.
   Content-level reuse counts can be shared; chunk-specific evidence and
   triggers must still distinguish occurrences.
3. Bound census preparation to useful work for the remaining window, using
   existing cursors and modest successive batches when candidates are held.
   Bound workflow expansion too. Do not change persisted global budgets to
   make a small smoke run fit.
4. Apply the proven indexes and bounded batches first, then measure writer
   lock duration. Move preparation out of the writer only if still necessary,
   using existing generation/fence revalidation rather than inventing a new
   cache or recovery protocol.

The indexed census still spends about three seconds building alias packets and
two seconds proving that no embeddings are missing. A zero-result coverage
scan is not free. Share that result only within the same valid snapshot.
Keep the separate relative-duration issue from the planning investigation in
the repair list: preparation currently consumes the requested execution time.

### F05 — P2: provider admission sweeps all admission history on every call

Owner: `ragenvironment.admitprovidercall:29`.

`UPDATE provider_admissions ... WHERE outcome='active' AND
lease_until_epoch<=...` cannot use the existing provider/model-first indexes.
The read-side predicate scanned 82,536 rows to find **zero** expired active
admissions: **0.159 seconds** versus **0.000012 seconds** with:

```sql
CREATE INDEX provider_admissions_expiry
ON provider_admissions(lease_until_epoch,admission_id) WHERE outcome='active';
```

This occurs in the shared writer transaction before each provider call. The
experimental index is one empty 4-KiB page at this checkpoint; normal active
rows will add entries. Test actual expiry transitions and concurrent admission
when implementing it. Combine the adjacent scoped request/token/concurrency
and cooldown reads where they refer to the same admission snapshot.

### F06 — P2: ingestion still has generation scans and prepare-per-row loops

Owner: `ragingest._insertglossarycandidates:611`, `_queuework:1298`,
revision closure/reanchoring at `:1149–1169`.

Each excluded glossary term can scan all 347,393 candidate mentions. The
existing index starts with chunk ID, whereas the DELETE predicate starts with
generation and normalized candidate. Test/add
`candidate_mentions(visible_from_generation,normalized_candidate)` and reuse
the prepared exclusion/insert statements across their loops. The separate
candidate-selection experiment includes one synthetic undecided candidate and
one absent key, with all fixture changes rolled back.

The reuse exclusion in `_queuework` has a correlated full chunk scan; F01's
content index addresses that shared access path. Generation-only new-chunk
reads are also unindexed. Measure an actual new revision and unchanged-content
reanchor before deciding whether they warrant a further generation-first
index. Preserve the existing `_finalizecandidates` one-pass occurrence/source
aggregates; those earlier fixes remain present and should not be replaced by
per-candidate counts.

### F07 — P2: consolidate repeated report, status and accounting scans

Owners: `ragreportservice`, `ragobservationservice`, `ragbacklog:713–728,1364`,
`ragwork.readjobstatus`, `ragusage`.

- Report reads the same chunk text join three times for sum/min/max, support
  spans separately, and task/workflow states in loops. Fetch related aggregates
  together. Snapshot reads nine fields from the same latest snapshot through
  separate statements; fetch one row.
- Report and `reportoperationaldigest` independently repeat much of the same
  census. Share one named projection for each snapshot; re-read after a provider
  call or transaction boundary when freshness is actually required.
- `backlogsummary` scans all provider runs twice through correlated `EXISTS`,
  despite the existing job-scoped run-set aggregation in `ragusage`. It also
  performs a whole missing-embedding census for an ordinary status result.
- Checkpoint separately sums input, output, cost and duration over the same
  job run set; status repeats call/cost aggregates. Consolidate these without
  double-counting a provider run attached to several attempts.
- Report invokes both `verifyragstore` and `verifyrepositories`; both compare
  the complete FTS projection. Share that expensive verification result within
  the same snapshot. Decide separately whether full deep verification belongs
  in routine report output or only the explicit verification command.

These are static duplication findings, not measured whole-report speedups.
An index cannot remove the cost of intentionally reading every body. Keep
the validation meaning and remove repeated work, rather than adding another
reporting/cache subsystem.

### F08 — P2: retained provider-output lookups need a task access path

Owners: `ragwork:671`, `ragenrich:102,189`; review join `ragbacklog:1133`.

The ordinary resolution worker checks for a reusable answer by task ID before
calling a provider, but `maintenance_provider_outputs` is indexed only by item.
Test/add `(task_id,created_epoch DESC,item_id)`. Twenty representative cached
answer lookups improved **0.132 → 0.001945 seconds**. Keep failed/dead-letter
attempt exclusion and receipt/usage reuse unchanged. The provider-run lookup
used by review is a distinct access direction: prefer the decision's item
identity where the contract permits, otherwise measure that join before adding
another index.

### F09 — P2: retrieval has non-indexable predicates and catalogue loops

Owners: `ragquery:234,265`, `ragingest.termstatistics:511`,
`ragretrieval:627,650,689,787–799`.

- `lower(a.normalized_alias)=?` cannot use the existing plain normalized-alias
  index. A matching expression index improved four lookups **0.0613 → 0.000070
  seconds**. Removing `lower` instead requires proving the persisted
  normalization contract, including historical data and Unicode.
- Analysis notes are fetched per retrieved chunk, but no index leads with
  `analysis_note_links.revision_chunk_id`. The tested `(revision_chunk_id,note_id)`
  index improved twenty calls **0.1568 → 0.001938 seconds**.
- `_anchors` reads all concepts and aliases into cREXX and tests labels against
  the question. `_spelling` unions/sorts the catalogue before `LIMIT 512`.
  Multiword term statistics still read every chunk body; the single-word FTS
  vocabulary optimization does not cover that fallback. Derive bounded
  question terms/phrases, retrieve candidates through the existing vocabulary
  and verify the original matching semantics on those candidates.
- Conflicts by claim and ambiguities by chunk lack their reverse access paths.
  They currently contain zero and 1,160 rows respectively. Keep these as
  measured-growth follow-ups, not immediate speculative indexes.

Retain the existing batched chunk fetch, directed graph indexes, bounded graph
traversal and FTS route. An FTS `SCAN ... VIRTUAL TABLE INDEX` is not evidence
that SQLite ignored full-text indexing.

### F10 — P2: exceptional recovery still scans unrelated history

Owners: `ragusage.closeexpiredreservations:377–379`, `ragwork.claimnext:55–66`.

The normal claim path already has an indexed expired-lease existence check.
Only when a lease expires does it scan reservation events, update attempts
through a correlated item lookup, and recompute four reservation counters for
**every job**. Drive recovery from the indexed expired items, derive their
affected jobs, and aggregate immutable reservation pairs once for those jobs.
Preserve uncertainty, fences and original accounting. This is a static
recovery-path finding; it does not justify reverting the existing fast normal
claim path or adding a generic retry mechanism.

### F11 — P2: some bounded pages still scan/sort their whole input

Owners: `ragrepository:218,234,238`, `ragbacklog.inspectbacklog:1181–1182`,
`ragbacklog._resolvealias:1300`, `ragmaintain:446`.

`printf(generation)` and concatenated composite keys in cursor predicates do
not seek through the underlying numeric/composite key in the same way that a
native-column comparison does. Preserve the external cursor encoding, decode
it once, then compare the native columns and retain the identical total order.
Add any required index only after verifying the resulting predicate/order.

Some task detail paths use OFFSET and repeat counts; others filter tasks by
`subject_id` or `parent_task_id` without an index leading with that column.
These occur on explicit inspection/action paths, rather than the main census
hot path. Measure representative late pages and task histories before extending
the schema. The newer operational query pages already filter before pagination;
preserve that refactoring.

### F12 — P2: complete shared SQL/state ownership where duplication remains

Owner: `ragclaims._refreshjob:767`, compared with `raglifecycle.refreshlifecyclejob`
and the delegating `ragwork._refreshjob`.

The claim proposal completion path still carries its own three job-item counts
and job-state decision. The worker path delegates to the shared lifecycle owner.
Review the reachable proposal completion callers and consolidate in that owner,
with paused/cancelled/window-complete characterization. Do not mechanically
extract every repeated PK read into another SQL framework. The high-value
shared work is the repeated aggregate/projection and state decision.

## Index and transaction conclusions

The immediate migration candidate is **eight access paths**: F01's three,
F02's one and F03's four. Five further measured index candidates address
admission expiry, glossary generation, lowercased aliases, note chunks and
retained task outputs. They belong with their focused P2 changes.

The ten indexes in this review's experiment occupy about **29 MiB** together;
the original three planning indexes were a separate experiment. Index-only
census measurements included all ten, so they are a cohort result, not ten
individually attributed whole-command speedups. No redundant existing index
was proven safe to remove. Different leading columns, uniqueness, partial
predicates and required ordering matter; similar names are not duplication.

The database has no planner statistics. Evaluate an occasional `PRAGMA optimize`
after substantial ingestion/index changes, not on every worker item. It cannot
create missing indexes or eliminate repeated work. SQLite requires expression
and partial-index predicates to match their query uses; query plans must be
interpreted with the actual loop/parameter context.
[SQLite query-plan reference](https://www.sqlite.org/eqp.html),
[expression-index reference](https://www.sqlite.org/expridx.html),
[statistics guidance](https://www.sqlite.org/lang_analyze.html).

## Evidence and acceptance

The [SQL comparisons](qa/sql-performance-review-20260913/query-experiments.json)
retain statements, parameters, before/after plans, result hashes, index build
costs and index sizes. Python timings are representative local measurements,
not a release benchmark or a cross-platform promise.

The [unindexed checkpoint](qa/sql-performance-review-20260913/profile-equivalence-before.log)
and [indexed checkpoint](qa/sql-performance-review-20260913/profile-equivalence-after.log)
both produced 52,583 tasks and the same digest:

`fbb873b6f435bc287c4a1741e265de7823a4a5356c41e10a7dce4b2a46dca608`

The digest covers ordered task IDs, evidence fingerprints, states,
capabilities, kinds, subjects, workflow/parent IDs, priority, question and error.
Wall-clock creation/update fields are deliberately excluded. The initial
unindexed census runs took 79.71 and 77.10 seconds; the explicit equivalence
pair took **76.14 and 6.00 seconds**. Both calls rolled back their task/cursor
changes, and neither dispatched workers nor contacted a provider.

Implementation should proceed in this order:

1. Add the eight P1 access paths through the shared schema owner. Test fresh
   and upgraded libraries, positive/negative hold queries, expression-index
   data compatibility and identical task/plan results.
2. Consolidate automatic preparation and bound census/workflow batches. Measure
   plan time, apply time, census time and writer-lock duration separately on
   the same corpus copy. Keep candidate/packet counts visible in the retained
   test evidence so a fast empty run cannot count as success.
3. Apply the P2 changes in their existing owners, starting with admission,
   ingestion and retrieval; then report/accounting and exceptional recovery.
   Reuse prepared statements within loops where this removes actual repeated
   compilation, rather than introducing a global statement-cache framework.
4. Run affected regression journeys and the required full suite after product
   implementation. Then run the bounded new-document and maintenance smokes
   on a scratch corpus: new source searchable and embedded, repeated import
   a no-op, maintenance reaches useful execution, expected task outcomes,
   accurate calls/usage and no stranded active work. Recheck the ordinary
   relative execution allowance as part of maintenance acceptance.

No product tests were rerun merely for this review. The work here validates
access paths and the census experiment; it does not mark the remaining smoke
or concurrency defects fixed. Diagnostic reproduction details and coverage
limits are in the [evidence README](qa/sql-performance-review-20260913/README.md).
