# Generic SQLite Boundary Contract

Status: `P1-SQL-01` ownership and error base implemented. Later Phase-1B SQL
items extended that contract in their authorized order. The maintained
2026-08-24 threading amendment adds RXPA V2 session ownership and serialized
SQLite connections without changing the public procedure signatures.

## Scope

The plugin exposes SQLite mechanisms to cREXX. It contains no repository,
schema, migration, paging-policy, queue, graph, source, or retrieval behavior.
Callers own every SQL statement and transaction boundary.

## Handles And Ownership

- Database and statement values are opaque native-payload-backed handles.
- A copied value retains the same handle; destroying a copy releases one
  reference and does not close the resource while another reference remains.
- A statement retains its parent database. Explicit database close finalizes
  all child statements and makes every database and child-handle copy closed.
- Explicit statement finalize makes every copy of that statement closed.
- Finalizers release abandoned resources. `sqlitecleanup()` deterministically
  closes every live statement before every live database for forced-failure
  tests and process shutdown.
- Invalid, closed, stale, wrong-kind, and cross-session handles are distinct
  errors. Handles belong to one RXPA VM session and must never be serialized or
  transferred to another task or process.
- On a mutex-enabled SQLite build, current RXPA V2 hosts may enter independent
  sessions concurrently. Every connection uses `SQLITE_OPEN_FULLMUTEX`.
  Mutex-free SQLite and older hosts fail closed to CREXX's legacy serialized
  lane. Independent-process WAL qualification remains separate.

## Values And Cursor

Bindings and columns preserve `null`, signed 64-bit integer, IEEE double, UTF-8
text, and exact-length blob types. Prepared statements are cursor handles:
`sqlitestep()` returns `100` for a row and `101` for completion. Row paging and
repository records remain caller policy.

## Backup And Integrity

`sqlitebackup()` copies `main` between distinct open database handles using the
SQLite online-backup API. The caller supplies a positive page-step size and
bounded busy/locked retry and sleep values. The call always finishes its native
backup object before returning and exposes the final remaining and total page
counts on success. Destination creation, replacement, retention, and backup
scheduling remain caller policy.

`sqliteintegrity()` performs bounded `quick_check` or `integrity_check` work and
returns both a boolean `ok` result and diagnostic rows bounded to 4,095 bytes.
The error-row limit is caller supplied from 1 through 1,000. Foreign-key checks
remain explicit caller-owned SQL because they are separate SQLite semantics.

## Status And Errors

Boundary statuses are stable negative integers; SQLite row/done retain 100/101.
`sqliteerrorextended()` returns boundary code, primary SQLite code, extended
SQLite code, operation, and a safe message from the most recent call in the
current VM session. A successful operation clears that session's error state.
Error state is diagnostic, not a replacement for the returned status.

| Status | Meaning |
| ---: | --- |
| 0 | success |
| 100 | row available |
| 101 | statement complete |
| -1 | invalid argument |
| -2 | invalid or stale handle payload |
| -3 | closed handle |
| -4 | wrong handle kind |
| -5 | allocation/materialization failure |
| -6 | SQLite error; inspect primary and extended codes |
| -7 | requested typed value does not match |

## Progressive Surface

`P1-SQL-01` covers open/close, exec, prepare/finalize, cursor step/reset,
ownership, cleanup, and structured errors. Typed large values, transaction and
capability controls, read-only modes, process concurrency, and backup/integrity
are accepted through `P1-SQL-06`. The maintained `p1_sql_thread_sessions` test
adds four concurrent RXPA sessions, distinct diagnostics, and 400 WAL writes.

The optional `P1-SQL-07` `ADDRESS SQLITE` facade is Rexx code over this same
API, not a second native data path. It intentionally provides only session
`OPEN`, non-row `EXEC`, scalar `VALUE ... INTO`, and `CLOSE` commands. Typed
application code continues to use handles and cursor iteration directly.

## Execution Topology

- A separate worker process may load the provider and open its own SQLite
  connection. Multiple processes coordinate through WAL, busy-timeout, leases,
  fencing, and short caller-owned transactions. A worker may run once or loop.
- An attached cREXX task running on a child thread cannot currently call this
  native provider directly because the installed CREXX task VM does not
  discover/propagate the RXPA provider. This is CREXX infrastructure issue
  CRI-17, not a SQLite or `rxsqlite` thread-safety issue.
- An attached task remains usable when it exchanges transferable inputs/results
  and its controller owns the SQLite connection and database operations.

No database or statement handle may cross a process, VM, session, or task
boundary.
