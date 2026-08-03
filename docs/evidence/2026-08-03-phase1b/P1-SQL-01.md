# P1-SQL-01 Ownership And Error Contract

Status date: 2026-08-03. Result: accepted. The generic contract is in
`incubator/phase1b/rxsqlite/CONTRACT.md`; it contains no product vocabulary and
leaves SQL, repositories, transactions, and paging policy to cREXX callers.

## Result

Optimized and non-optimized tests pass on `rxvme` and `rxbvm`. Every cell proves
reference-counted handle copies, statement-parent retention, explicit close and
finalize, child invalidation, invalid/stale/wrong-kind rejection, structured
primary and extended SQLite errors, and forced statement-before-database
cleanup. Each cell reports cleanup count 2 and statuses `-2`, `-3`, `-4`, and
`-6` as specified.

## Commands And Measurements

```text
cmake --build --preset debug --target p1_sql_01
ctest --test-dir cmake-build-debug -L '^P1-SQL-01$' --output-on-failure -V
```

- target: passed in 5.78 seconds including plugin rebuild, peak RSS 120,744 KiB;
- exact-label CTest: 1/1 passed in 2.53 seconds, peak RSS 120,644 KiB;
- raw four-cell output: `raw/p1-sql-01-commands-and-output.txt`;
- source/output hashes: `raw/p1-sql-01-hashes.txt`.

No VM variant is unsupported. Thread sharing is explicitly not claimed;
separate-process concurrency remains ordered under `P1-SQL-05`.
