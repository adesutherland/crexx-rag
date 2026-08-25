# SQLite provider system design

`sqlite_boundary.c` is a generic RXPA mechanism. The application owns schema,
migrations, repositories, transactions, paging, jobs, and policy.

Opaque values carry session and kind identity. Database copies refer to the
same native resource; closing a connection invalidates its child statements.
Statement copies likewise share one resource. Cross-session, stale, closed,
and wrong-kind handles are rejected.

The RXPA V2 lifecycle creates isolated state per VM session. On a mutex-enabled
SQLite build, procedures are session-affine and every connection requests
FULLMUTEX. The maintained C harness opens four concurrent sessions, writes 400
unique rows, validates isolated diagnostics, and proves cross-session handles
are rejected.

Separate `crexxrag` worker processes are supported: each loads the provider and
opens a connection. Attached cREXX child task VMs cannot currently discover the
provider; that is a CREXX infrastructure limitation, not a SQLite or provider
thread-safety limitation.
