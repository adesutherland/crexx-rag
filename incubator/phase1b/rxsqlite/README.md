# Phase 1B SQLite Qualification

This directory contains the retained Phase-1B contract, progressive
qualification programs, and optional ADDRESS facade for the generic SQLite
candidate. The native implementation and canonical colocated package
documentation are in [`../../p1a/sqlite_boundary/`](../../p1a/sqlite_boundary/):

- [usage guide](../../p1a/sqlite_boundary/README.md);
- [system design](../../p1a/sqlite_boundary/SYSTEM.md); and
- [native implementation](../../p1a/sqlite_boundary/sqlite_boundary.c).

[`CONTRACT.md`](CONTRACT.md) is immutable Gate evidence and remains here so its
retained path and hash do not change. The `p1_sql_01.crexx` through
`p1_sql_07.crexx` files are Level-G qualification consumers, not application
repository code or separate package implementations. The optional
`rxsqlite_address.crexx` facade is also Level G.
