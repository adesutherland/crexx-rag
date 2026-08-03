# P1-SQL-04 Read-Only Zero-Write

Status date: 2026-08-03. Result: accepted.

The boundary now exposes explicit `readonly`, `readwrite`, and `create` modes.
One seeded scratch database was opened read-only by optimized/non-optimized
programs on `rxvme` and `rxbvm`. Every cell read `user_version=7` and the seeded
row, rejected DDL and user-version mutation with SQLite primary code 8, and
closed normally.

Before and after every cell the database retained SHA-256
`e02d0b48e0c75c6a10df67d9d37584f68313b09c826ebcdc6f5cacb73fbb130f`,
size 8,192 bytes, the same mtime, and exactly one `readonly.sqlite*` file. Both
VMs also rejected a missing read-only path without creating it.

```text
cmake --build --preset debug --target p1_sql_04
ctest --test-dir cmake-build-debug -L '^P1-SQL-04$' --output-on-failure -V
```

- target: 7.07 seconds including plugin rebuild, peak RSS 119,108 KiB;
- exact-label CTest: 1/1 in 3.06 seconds, peak RSS 119,232 KiB;
- raw hash/size/mtime/file-set matrix: `raw/p1-sql-04-commands-and-output.txt`;
- hashes: `raw/p1-sql-04-hashes.txt`.
