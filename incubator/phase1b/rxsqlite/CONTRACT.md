# Generic SQLite Boundary Contract

Status: `P1-SQL-01` ownership and error base implemented. Later Phase-1B SQL
items extend this contract only in their authorized order.

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
- Invalid, closed, stale, and wrong-kind handles are distinct errors. Handles
  are process-local and must never be serialized or shared across processes.
- No in-process cREXX thread-safety claim is made. Concurrency qualification
  uses independent processes.

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
current process. A successful operation clears that error state. Error state is
diagnostic, not a replacement for the returned status.

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
are accepted through `P1-SQL-06`.

The optional `P1-SQL-07` `ADDRESS SQLITE` facade is Rexx code over this same
API, not a second native data path. It intentionally provides only session
`OPEN`, non-row `EXEC`, scalar `VALUE ... INTO`, and `CLOSE` commands. Typed
application code continues to use handles and cursor iteration directly.
