# SQLite Boundary Usage

Status: implemented generic incubation and candidate for a future `rxsqlite`
package. It is used by the Phase-1B capability and application slices, but it
is not an installed standalone package and is not approved for donation. P2-09
adds a reproducible review recipe in [`BUNDLE.tsv`](BUNDLE.tsv), explicitly
non-released metadata in [`PACKAGE.toml`](PACKAGE.toml), and a compiled minimal
[`candidate_probe.crexx`](candidate_probe.crexx).

The native implementation is [`sqlite_boundary.c`](sqlite_boundary.c). Its
normative Phase-1B ownership and status contract is retained in
[`CONTRACT.md`](../../phase1b/rxsqlite/CONTRACT.md). Maintainer architecture is
in [`SYSTEM.md`](SYSTEM.md).

## Prerequisites

- an installed CREXX development package and runtime;
- SQLite development headers and library; and
- the `rx_sqlite_boundary` provider package built by this repository's CMake
  project. It publishes both the dynamic VM plugin and the canonical static
  archive used by CREXX native packaging.

cREXX code imports the namespace as `sqlite_boundary`.

## Minimal Typed Example

```rexx
options levelg

import sqlite_boundary

database = .binary
statement = .binary
value = 0

if sqliteopenmode(":memory:", "create", database) \= 0 then return 1
if sqliteexec(database, "CREATE TABLE sample(v INTEGER)") \= 0 then return 1
if sqliteprepare(database, "INSERT INTO sample VALUES(?1)", statement) \= 0 then return 1
if sqlitebindint(statement, 1, 42) \= 0 then return 1
if sqlitestep(statement) \= 101 then return 1
if sqlitefinalize(statement) \= 0 then return 1

if sqliteprepare(database, "SELECT v FROM sample", statement) \= 0 then return 1
if sqlitestep(statement) \= 100 then return 1
if sqlitecolumnint(statement, 0, value) \= 0 then return 1
say value
call sqlitefinalize statement
call sqliteclose database
return 0
```

Production callers must finalize statements and close databases on every exit
path. `sqlitecleanup()` is a deterministic last-resort cleanup operation, not a
substitute for normal ownership.

The plugin is a low-level native mechanism, but its advanced and application
consumers use Level G. Importing its Level-B-compatible signature does not
require the caller to use Level B.

## API Groups

| Area | Operations |
| --- | --- |
| Connections | `sqliteopen`, `sqliteopenmode`, `sqliteclose`, `sqlitecleanup` |
| Statements | `sqliteexec`, `sqliteprepare`, `sqlitestep`, `sqlitereset`, `sqliteclearbindings`, `sqlitefinalize` |
| Bindings | `sqlitebindindex`, `sqlitebindnull`, `sqlitebindint`, `sqlitebindreal`, `sqlitebindtext`, `sqlitebindblob` |
| Columns | `sqlitecolumntype`, `sqlitecolumnisnull`, `sqlitecolumnint`, `sqlitecolumnreal`, `sqlitecolumntext`, `sqlitecolumnblob` |
| Operation | `sqlitecapability`, `sqlitebusytimeout`, `sqlitecheckpoint`, `sqlitebackup`, `sqliteintegrity` |
| Diagnostics | `sqliteerror`, `sqliteerrorextended`, `sqliteerrorjson` |

`sqliteopenmode` accepts `readonly`, `readwrite`, and `create`. Transactions,
savepoints, foreign-key policy, schema, migrations, paging, and repository
records remain caller-owned SQL and cREXX policy.

Prepared statements are cursors. `sqlitestep()` returns `100` when a row is
available and `101` when execution is complete. Typed getters reject a value of
the wrong SQLite type instead of coercing it silently.

## Errors

Boundary failures are stable negative statuses. After a failure,
`sqliteerrorextended()` returns the boundary status, SQLite primary and extended
codes, operation name, and safe message. A successful operation clears the
current VM/session diagnostic state. See the [contract](../../phase1b/rxsqlite/CONTRACT.md)
for the complete status table and ownership rules.

## Concurrency

On a current RXPA V2 host the provider advertises every procedure as
`SESSION_AFFINE`. CREXX creates one plugin session per VM, and that session owns
its handle registry and diagnostic state. Database handles therefore never
cross VM or task boundaries. Every connection is opened with
`SQLITE_OPEN_FULLMUTEX`, so SQLite supplies serialized connection semantics on
a mutex-enabled build. If `sqlite3_threadsafe()` reports zero, the capability
query fails closed to CREXX's legacy serialized lane.

`sqlitecapability(handle, "threadsafe", available)` reports SQLite's compile-
time mutex support. `sqlitecapability(handle, "session_affinity", available)`
reports whether the current host entered an RXPA V2 session.

Concurrent workers must each open their own connection. SQLite WAL,
busy-timeout and caller-owned transactions coordinate those connections; an
opaque database or statement value remains VM-local and is not a transferable
task value.

### Worker topology

| Worker form | Direct SQLite use | Reason |
| --- | --- | --- |
| Separate `crexx-rag` OS process | Supported | The process starts a fresh CREXX VM, loads the provider normally, and opens its own connection. |
| Attached cREXX task running on a child thread | Not currently supported | The installed CREXX attached-task path does not propagate/discover the native RXPA provider in the task VM. This is CRI-17, a CREXX infrastructure limitation, not a SQLite limitation. |
| Attached cREXX task with controller-owned SQLite | Supported design | The task exchanges ordinary transferable inputs/results; the controller performs SQLite operations. |

SQLite is therefore suitable for coordinating separate worker processes now.
CRI-17 matters only if an attached in-process task must call the native provider
directly. It does not prevent one-shot or looping worker processes from opening
independent connections to the same WAL database.

## Optional ADDRESS Facade

[`rxsqlite_address.crexx`](../../phase1b/rxsqlite/rxsqlite_address.crexx)
provides a deliberately small `ADDRESS SQLITE` facade with `OPEN`, non-row
`EXEC`, scalar `VALUE ... INTO`, and `CLOSE`. Typed application code should use
the handle/cursor API directly.

## Tests

After configuring the Debug preset, run the focused qualification with:

```bash
ctest --preset debug -R '^(p1a_sqlite_boundary|p1_sql_thread_sessions|p1_sql_0[1-7])$' --output-on-failure
```

The tests cover both CREXX VMs and optimized/non-optimized compilation where
runtime-relevant. The Phase-1B tests and immutable contract live in
[`phase1b/rxsqlite/`](../../phase1b/rxsqlite/).
P2-09 additionally stages the review bundle and runs the candidate probe in all
four compiler/VM cells through `p2_09_donation_bundles`.

The root build emits `rx_sqlite_boundary.rxplugin` for VM use and
`rx_sqlite_boundary.a` (or the platform-equivalent archive suffix) for CREXX
native packages. This is application-local incubation packaging, not an
independently released `rxsqlite` SDK.

The plugin advertises its complete typed REXX API through the standard
`LOADFUNCS`/`ADDPROC` mechanism. The compiler records each used declaration and
its stable provider ID in the linked provider requirements. The same source is
built as the native static provider, so `crexx -native` can select and retain
the canonical archive. Its RXPA V2 manifest publishes the session lifecycle
and marks the procedures session-affine when SQLite has mutex support.

## Current Limits

- The CMake targets and module still use the incubation name
  `_sqlite_boundary`/`rx_sqlite_boundary`, not a released `rxsqlite` identity.
- Handles are VM/session-local and must not be transferred to another task or
  process; the focused RXPA lifecycle test verifies cross-session use is
  rejected.
  Concurrent independently hosted VM/process connections are supported by the
  provider. The currently installed CREXX task-generation path excludes
  already loaded native modules and does not propagate a late provider search
  path to attached task VMs; this CREXX infrastructure gap is CRI-17. Product
  task threads must keep SQLite access in their controller until it is closed.
- The plugin is not an ORM and does not own application SQL or migrations.
- The P2-09 review recipe is not independent release packaging or an installed
  consumer qualification; final naming, package/release metadata and donation
  approval remain outstanding.
