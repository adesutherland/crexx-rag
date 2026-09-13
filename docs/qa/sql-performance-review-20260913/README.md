# SQL review evidence

Review baseline: `bfbbdfd95d95a080262d47711c759bc2a9df18a0`.
See [the review](../../sql-performance-review-20260913.md) for findings and scope.

- `statement-review.json`: full source-location ledger, per-location review
  assessment, owner/loop/transaction context, duplicate groups, schema and EQP.
- `inventory.py`: one-off source/compile-only inventory generator. Its output
  `inventory.json` precedes the manual review annotations in the retained ledger.
- `query-experiments.json`: exact representative SELECT statements/parameters,
  ordered-result digests, timings, plans and experimental indexes.
- `measure.py`: initial experiment utility, updated to use read-only SELECT
  projections for all cases and a read-only baseline connection. The retained
  JSON is authoritative for the final glossary positive/negative fixture,
  including its explicit setup statement and rollback scope.
- `checkpoint-profile.patch`: timer-only change to a disposable copy of
  `ragbacklog.crexx`, renamed `diagnosticbacklog`; no product edit.
- `profile-scan.crexx`, `profile-scan.cmake`, `profile-run.cmake`: standalone
  diagnostic driver and compiler/runtime commands, using current main's built
  application modules and the installed CREXX provider. These are diagnostic
  artifacts, not a new product workflow or installed script.
- `profile-equivalence-before.log`, `profile-equivalence-after.log`: compact
  installed-provider census timings and semantic identity comparison.

The scripts retain the exact local paths used on 13 September. They do not
discover or choose a user library. To reproduce, first make another SQLite
backup of the disposable Test 3 database into the named diagnostic directory;
do not point mutation experiments at an operational library. Preserve the
original schema-17 copy for baseline reads. `inventory.py` only issues EXPLAIN
against its read-only connection. The query experiment creates its named
indexes in the diagnostic copy, never in the source.

To reproduce the checkpoint pair, apply the retained patch to a separate
copy of the baseline backlog source at
`/private/tmp/crexxrag-sql-review-20260913/diagnosticbacklog.crexx`, and copy the
driver/build files to that directory. Run `cmake -P .../profile-scan.cmake`
to compile and run. The driver's optional second argument is `1` for the
unindexed comparison: inside the same transaction it temporarily drops the
ten named experimental indexes, calls the census, fingerprints tasks, then
rolls everything back. Omit the argument for the indexed run; the retained
`profile-run.cmake` skips recompilation. No worker launcher is called.

The task digest excludes wall-clock fields. It checks task identity and
disposition equivalence, not byte equality of the entire database or all
possible SQL parameter combinations. Both census calls returned status 1
(more census work remains), not a completed maintenance window. They created
no durable tasks after rollback and made no provider calls.

The first exploratory glossary case executed its original DELETE only on the
diagnostic copy at generation 24928, which contained zero candidates. Source
and copy remained at 347,393 candidate rows. The retained final measurement
replaces that case with SELECT of deletion candidates using one synthetic
undecided candidate and one absent key; the fixture and baseline index drop
were rolled back. No operational data repair was performed.

These are review artifacts. Product migration, a repaired whole-command timing,
write-throughput/concurrency acceptance and hosted smoke qualification remain
implementation work.
