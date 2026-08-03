# P1-SQL-03 Transactions And SQLite Controls

Status date: 2026-08-03. Result: accepted.

All optimized/non-optimized `rxvme`/`rxbvm` cells pass:

- transaction commit, full rollback, nested savepoint rollback/release;
- one prepared insert reused five times with reset and clear-bindings;
- cREXX-owned paging of five cursor rows into pages 2, 2, 1;
- FTS5 capability and match, JSON1 capability and extraction;
- enforced foreign keys with primary code 19 and extended code 787;
- WAL activation, a 25-ms two-connection busy result with primary code 5; and
- truncate checkpoint plus invalid-mode rejection.

The plugin additions are only capability probing, busy timeout, and checkpoint
mechanisms. SQL text, transaction boundaries, and page size remain cREXX test
policy.

```text
cmake --build --preset debug --target p1_sql_03
ctest --test-dir cmake-build-debug -L '^P1-SQL-03$' --output-on-failure -V
```

- target rerun: 2.85 seconds, peak RSS 126,592 KiB;
- exact-label CTest: 1/1 in 2.84 seconds, peak RSS 126,456 KiB;
- raw matrix: `raw/p1-sql-03-commands-and-output.txt`;
- hashes: `raw/p1-sql-03-hashes.txt`.

The initial target reached JSON1 then panicked on a test string using C-style
escaping. Replacing that fixture string with a quote-independent SQL expression
fixed the test; the failed output is retained in `raw/p1-sql-03-target.txt`.
