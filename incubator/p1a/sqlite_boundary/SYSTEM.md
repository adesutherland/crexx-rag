# SQLite Boundary System Design

## Status And Boundary

This directory contains the native implementation of the generic SQLite
candidate. It exposes SQLite mechanisms to cREXX and must not contain source,
chunk, claim, graph, job, retrieval, or other product vocabulary.

The implementation predates the Phase-1B directory layout, so later tests and
the hashed normative contract remain in
[`../../phase1b/rxsqlite/`](../../phase1b/rxsqlite/). The source is not moved
because its location and the contract path participate in retained Gate
evidence. This document and the adjacent [usage guide](README.md) are the
canonical colocated package documentation.

## Components

| Component | Responsibility |
| --- | --- |
| [`sqlite_boundary.c`](sqlite_boundary.c) | RXPA plugin, handle ownership, SQLite calls, typed materialization, diagnostics, backup, integrity, and cleanup |
| [`sqlite_boundary_test.crexx`](sqlite_boundary_test.crexx) | Original Gate-1A ownership and boundary probe |
| [`../../phase1b/rxsqlite/CONTRACT.md`](../../phase1b/rxsqlite/CONTRACT.md) | Normative Phase-1B API, ownership, and status contract |
| [`../../phase1b/rxsqlite/p1_sql_01.crexx`](../../phase1b/rxsqlite/p1_sql_01.crexx) through `p1_sql_07.crexx` | Level-G progressive independent correctness and operational qualification |
| [`../../phase1b/rxsqlite/rxsqlite_address.crexx`](../../phase1b/rxsqlite/rxsqlite_address.crexx) | Optional Level-G cREXX line-command facade over the same native API |

The repository root CMake project builds `_sqlite_boundary` as a dynamic plugin
and links SQLite using the defensive imported-target ordering documented in
`AGENTS.md`.

## Ownership Model

Database and statement values carry opaque native payloads. Copies retain the
same underlying handle. Closing any database copy closes the resource and all
child statements; finalizing any statement copy closes that statement for all
copies. A statement retains its parent database until it is finalized.

The plugin tracks live resources for finalization and forced cleanup. Handles
are process-local, non-serializable, and kind-checked. Invalid, stale, closed,
and wrong-kind handles have distinct statuses.

## Data And Control Flow

1. `sqliteopenmode` creates a database handle with explicit access flags.
2. `sqliteprepare` creates a child statement and retains its database.
3. Typed bind calls copy values into SQLite-owned statement storage.
4. `sqlitestep` advances one row at a time without whole-result serialization.
5. Typed column calls materialize only the requested current-row value.
6. `sqlitefinalize` and `sqliteclose` release resources deterministically.

Transactions and savepoints use caller-issued SQL. WAL, timeout, checkpoint,
backup, and integrity operations are generic primitives; scheduling and policy
remain above the plugin.

## Error Model

The public return value is authoritative. The process-local diagnostic record
adds SQLite primary/extended codes, the failed operation, and a safe message.
Successful calls clear it. Diagnostics never include SQL result data or an
application record.

Allocation and materialization failures are boundary errors. SQLite failures
retain their SQLite classifications. Typed column mismatches do not silently
coerce values.

## Concurrency And Recovery

No thread-sharing claim is made for cREXX handle values. Qualification uses
separate OS processes against SQLite WAL and busy-timeout behavior. Online
backup owns and always finishes its temporary SQLite backup object. Integrity
checking is bounded by caller-selected mode and error count.

## Evidence

The Phase-1B matrix covers ownership, null/integer/real/text/blob values,
transactions, statement reuse, FTS5/JSON1, WAL, read-only opens, separate-process
reader/writer behavior, online backup, integrity, forced cleanup, and the
optional ADDRESS facade. Exact commands, hashes, and results are retained under
[`docs/evidence/2026-08-03-phase1b/`](../../../docs/evidence/2026-08-03-phase1b/).

## Donation Readiness

P2-09 prepares and hash-verifies a review bundle containing the implementation,
contract, ADDRESS facade, example/reproducer, tests and representative evidence.
The bundle metadata explicitly denies release and submission status.

Before donation this candidate still needs:

- a final package/module name and versioned compatibility contract;
- independent CMake packaging rather than only the application root target;
- a fresh installed-consumer test and example using the proposed package;
- an explicit public-header and SQLite dependency policy;
- representative benchmark packaging and regression thresholds; and
- a donation decision and upstream handoff.

Application repositories, schema v2, migrations, queue policy, and product
commands are intentionally excluded from this package.
