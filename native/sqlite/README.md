# SQLite RXPA provider

This generic native provider exposes SQLite handles, prepared statements,
typed binding/column operations, diagnostics, checkpoint, backup, integrity,
and capability inspection to cREXX. It contains no RAG vocabulary or product
SQL.

The public namespace is `sqlite_boundary`. The standard RXPA
`LOADFUNCS`/`ADDPROC` declarations advertise the complete typed REXX API. CMake
builds the same source as a dynamic VM plugin and a static archive used by
CREXX native packaging.

Connections use `SQLITE_OPEN_FULLMUTEX` when SQLite reports mutex support.
Every VM session has its own handle registry and diagnostic state. Handles are
session-local and non-transferable. Concurrent worker processes must each open
their own connection; WAL, busy timeout, and caller-owned transactions
coordinate access.

Main operation groups are:

- connections: `sqliteopenmode`, `sqliteclose`, `sqlitecleanup`;
- statements: `sqliteprepare`, `sqlitestep`, `sqlitereset`, `sqlitefinalize`;
- typed values: bind/get null, integer, real, text, and blob;
- operations: `sqliteexec`, `sqlitecheckpoint`, `sqlitebackup`,
  `sqliteintegrity`, `sqlitecapability`;
- diagnostics: `sqliteerror`, `sqliteerrorextended`, `sqliteerrorjson`.

Prepared statements and connections must be finalized/closed on every normal
exit. `sqlitecleanup` is a last-resort session cleanup, not an ownership model.
