# P1-SQL-02 Typed And Large Values

Status date: 2026-08-03. Result: accepted.

## Result

All optimized/non-optimized `rxvme`/`rxbvm` cells preserve null, signed int64
extrema, real, Unicode and empty text, embedded-NUL and empty blob, and
1,100,005-byte text/blob values. Empty blob is explicitly bound with a non-null
zero-length SQLite pointer so it remains distinct from SQL null. Named parameter
lookup is implemented and a missing name returns the contract's invalid-
argument status.

Each cell streams 20,000 ordered rows through a prepared cursor and reports the
exact sum 200,010,000 without a whole-result buffer or text row encoding.

## Commands And Measurements

```text
cmake --build --preset debug --target p1_sql_02
ctest --test-dir cmake-build-debug -L '^P1-SQL-02$' --output-on-failure -V
```

- target rerun: passed in 2.82 seconds, peak RSS 126,644 KiB;
- exact-label CTest: 1/1 passed in 2.80 seconds, peak RSS 126,856 KiB;
- raw matrix: `raw/p1-sql-02-commands-and-output.txt`;
- hashes: `raw/p1-sql-02-hashes.txt`.

The first compile correctly rejected implicit `.binary` to text conversion in
the test's size assertions. The fixture now uses the explicit `binlength()`
operation; the failed compiler output is retained in `raw/p1-sql-02-target.txt`.
