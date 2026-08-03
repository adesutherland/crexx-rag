# P1-SQL-06 Backup, Integrity, And Cleanup

Status date: 2026-08-03. Result: accepted.

The generic boundary now wraps SQLite's online-backup API with caller-owned
page and busy-retry bounds, and always finishes the native backup object. It
also exposes bounded `quick_check` and `integrity_check` results. No backup
scheduling, retention, schema, or repository policy is native.

Optimized and non-optimized programs passed on `rxvme` and `rxbvm`. Every cell
copied a live 12-page source containing 2,000 rows, retained the 2,000-row
snapshot after the source advanced to 2,001 rows, and returned `ok` from source
quick-check and backup integrity-check. A forced backup to a read-only
destination returned boundary status -6 and SQLite primary code 8 while leaving
the destination usable. Forced cleanup then closed one abandoned statement and
two open databases, a repeated cleanup closed zero resources, and the backup
reopened with 2,000 rows and `ok` integrity.

```text
cmake --build --preset debug --target p1_sql_06
ctest --test-dir cmake-build-debug -L '^P1-SQL-06$' --output-on-failure
```

- final target: 2.36 seconds, peak RSS 121,744 KiB;
- exact-label CTest: 1/1 in 2.45 seconds, peak RSS 121,680 KiB;
- raw four-cell matrix: `raw/p1-sql-06-commands-and-output.txt`;
- hashes: `raw/p1-sql-06-hashes.txt`.

The first passing development run printed a later sentinel as its page count
and included an unused-import warning. It is retained as development history,
not acceptance evidence; the clean rerun and exact-label CTest are accepted.
