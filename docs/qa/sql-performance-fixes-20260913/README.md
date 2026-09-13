# SQL repair evidence — 13 September 2026

Scope and checklist: [delivery record](../../sql-performance-delivery-20260913.md).
Historical inventory: [original review](../../sql-performance-review-20260913.md).

The baseline is local main `bfbbdfd95d95a080262d47711c759bc2a9df18a0`.
The repair and evidence are committed together. `source-sha256.json` identifies the 179 product,
configuration, build and test inputs; `build-metadata.json` identifies the
installed CREXX package. No sibling CREXX implementation was changed.

Final native SHA-256:
`e3967d87a24df035fa43373719bc5ed611592c7cf49433326dca85115cc762ab`.
Final linked application SHA-256:
`860ba8b1c10357c6aa6252714d4e3f88684ef3d1d06d65e24d888156c3e5edec`.
This executable is in the build package; the user's installed crexxrag has not
been replaced during this repair.

## Evidence map

| Files | Meaning |
| --- | --- |
| `baseline-ctest.log` | Original 69/69 baseline, 943.87 seconds. |
| `missing-index-baseline.log` | Fresh/upgrade access-path assertions fail before the indexes exist. |
| `ranking-baseline.log`, `workflow-cursor-baseline.log` | New behavior assertions reproduce the retained-occurrence and publication-cursor defects before their repairs. |
| `build.log`, `focused-ctest.log` | Final build and four focused tests, including both-VM SQL/lifecycle tests and the complete durable backlog journey. |
| `final-ctest.log`, `acceptance.json`, `SHA256SUMS` | Final 70/70 acceptance in 919.24 seconds, unchanged source/artifact verification and evidence checksums. |
| `native-migrate.json`, `native-migrate.time` | Public native migration of the disposable corpus copy, zero issues. |
| `native-plan.json`, `native-apply.json`, `native-cancel.json`, `native-measurement.json` | Final public plan/apply/cancel: eight items, full 900 seconds, unchanged provider-run count, cancelled job/items. |
| `native-report.json`, `native-report-measurement.json` | Full deterministic report with narrative off, storage and repository issues both zero. |
| `baseline-native-report.json`, `baseline-native-report-measurement.json`, `report-equivalence.json` | Previously installed report: 41.70 seconds versus 28.32; identical semantic digest; operational history differs after the scratch smoke. |
| `query-equivalence.json`, `measure.py` | Reproducible old/new SQL result digests, query plans, timings, anchor ordering and late-page comparisons. |
| `positive-index-controls.json` | Positive graph fixtures at 10,000 rows per table and retained task/output history lookups. Synthetic writes were rolled back. |

Final acceptance passed **70/70 in 919.24 seconds**, exit 0. Focused acceptance
passed **4/4 in 25.51 seconds**. `git diff --check` passed and no product,
build or test inputs changed during the final suite. Full QA includes a
separate scratch-prefix install and its provider/maintenance smoke tests.

## Diagnostic reproduction and limits

Run `measure.py` with three explicit arguments: a read-only source SQLite file,
a **new** diagnostic target path, and an output JSON path. It uses SQLite backup
to isolate the source, applies the actual schema-18 index DDL on the target,
then compares ordered result digests and plans. It is a diagnostic, not an
application workflow. The target retains schema-17 metadata and must not be
used as a native product library or migrated again.

The retained diagnostic uses Python SQLite 3.53.4. Native commands and the
both-VM fixtures use the installed CREXX/rxsqlite route (SQLite 3.53.2).
Diagnostic timings are local and affected by cache state; equivalent rows and
plans are the primary evidence. The final native timing is a warm repeat.
The 25 additional indexes occupy 57,241,600 bytes on this corpus.

The source was `/private/tmp/crexxrag-smk006-V6YatF/smoke-library/library.sqlite`.
Native operations used only the new
`/private/tmp/crexxrag-sql-fixes-20260913/native-library` copy. The original
corpus, permanent query copy, provider credentials and installed product were
not modified. Corpus smoke launched no workers and incurred no provider calls.
The original review contains the full statement inventory; these artifacts
qualify query families and public journeys, not every dynamic SQL shape in
isolation.
