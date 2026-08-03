# P1-SQL-05 Separate-Process Concurrency

Status date: 2026-08-03. Result: accepted.

The generic boundary was exercised with independent writer and reader cREXX
processes against fresh scratch WAL databases. Optimized and non-optimized
programs passed on both `rxvme` and `rxbvm`. In every cell, the reader observed
one row before and during the writer's uncommitted transaction, retained that
snapshot after the writer committed, and observed two rows after ending its
read transaction. A third process confirmed the final two-row state.

```text
cmake --build --preset debug --target p1_sql_05
ctest --test-dir cmake-build-debug -L '^P1-SQL-05$' --output-on-failure
```

- target: 16.74 seconds including the four concurrency cells, peak RSS
  119,712 KiB;
- exact-label CTest: 1/1 in 17.19 seconds, peak RSS 119,652 KiB;
- raw four-cell matrix: `raw/p1-sql-05-commands-and-output.txt`;
- hashes: `raw/p1-sql-05-hashes.txt`.

Three development failures are retained. The first two exposed insufficient
coordination diagnostics; the third proved that the background writer inherited
CMake's captured output pipe and made the launcher wait for it. Redirecting the
entire background subshell restored actual overlap. These failures are not
accepted as evidence; the final target and exact-label CTest results above are.
