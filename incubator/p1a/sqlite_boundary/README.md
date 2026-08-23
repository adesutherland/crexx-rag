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
- the `rx_sqlite_boundary` module built by this repository's CMake project.

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
process-local diagnostic state. See the [contract](../../phase1b/rxsqlite/CONTRACT.md)
for the complete status table and ownership rules.

## Optional ADDRESS Facade

[`rxsqlite_address.crexx`](../../phase1b/rxsqlite/rxsqlite_address.crexx)
provides a deliberately small `ADDRESS SQLITE` facade with `OPEN`, non-row
`EXEC`, scalar `VALUE ... INTO`, and `CLOSE`. Typed application code should use
the handle/cursor API directly.

## Tests

After configuring the Debug preset, run the focused qualification with:

```bash
ctest --preset debug -R '^(p1a_sqlite_boundary|p1_sql_0[1-7])$' --output-on-failure
```

The tests cover both CREXX VMs and optimized/non-optimized compilation where
runtime-relevant. The Phase-1B tests and immutable contract live in
[`phase1b/rxsqlite/`](../../phase1b/rxsqlite/).
P2-09 additionally stages the review bundle and runs the candidate probe in all
four compiler/VM cells through `p2_09_donation_bundles`.

## Current Limits

- The CMake target and module still use the incubation name
  `_sqlite_boundary`/`rx_sqlite_boundary`, not a released `rxsqlite` identity.
- Handles are process-local and no in-process thread-safety claim is made.
- The plugin is not an ORM and does not own application SQL or migrations.
- The P2-09 review recipe is not independent release packaging or an installed
  consumer qualification; final naming, package/release metadata and donation
  approval remain outstanding.
