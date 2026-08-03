# P1-SQL-07 Optional ADDRESS SQLITE Facade

Status date: 2026-08-03. Result: accepted.

A Rexx-hosted `ADDRESS SQLITE` environment now provides a deliberately narrow
line-command facade over the same opaque-handle plugin API: `OPEN`, non-row
`EXEC`, scalar `VALUE ... INTO`, and `CLOSE`. It does not add a native data path
or serialize typed cursor results.

The regression uses an explicit `address sqlite "..."` statement for every
command, avoiding the reviewed demonstration's ambiguous naked string
expressions. Optimized and non-optimized modules and tests passed on `rxvme` and
`rxbvm`. Every cell asserted integer output `2`, text output `runtime`, null
output `NULL`, SQL-failure `RC=8` with boundary status -6, environment identity,
and closed-session status -3. This is output-asserting evidence, not a
process-success-only demonstration.

```text
cmake --build --preset debug --target p1_sql_07
ctest --test-dir cmake-build-debug -L '^P1-SQL-07$' --output-on-failure
```

- final target: 6.75 seconds, peak RSS 145,572 KiB;
- exact-label CTest: 1/1 in 7.16 seconds, peak RSS 145,640 KiB;
- raw four-cell output: `raw/p1-sql-07-commands-and-output.txt`;
- source and evidence hashes: `raw/p1-sql-07-hashes.txt`.

The first build failed because the new module omitted the installed Level-B
built-in function declarations used by its parser. That diagnostic is retained
in `raw/p1-sql-07-target.txt`; the import-only correction is verified by the
clean target rerun and CTest result.
