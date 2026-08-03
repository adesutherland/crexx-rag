# P1-JOB-01 Fenced Worker Lifecycle

Status date: 2026-08-03. Result: accepted.

The Level-B `job_queue` implements a scratch-only durable queue. Claim and
promotion use separate short `BEGIN IMMEDIATE` transactions. SQLite's clock
sets leases, an autoincrement table issues monotonic fences, and each claim
creates a durable attempt identity. Provider work is a pure operation invoked
only after the claim transaction is demonstrably closed.

The four-cell proof established:

- atomic claim with database-clock lease and a committed attempt;
- atomic heartbeat renewal that verifies item, worker, fence, attempt, and
  unexpired lease and returns the exact database-stored lease value;
- fences `1` then `2`, issued by the database;
- current-fence verification and idempotent promotion with one support row;
- deterministic queued and running cancellation;
- rejection of heartbeat and promotion after cancellation; and
- typed job status with separate job state and item counters.

```text
cmake --build --preset debug --target p1_job_01
ctest --test-dir cmake-build-debug -R '^p1_job_01$' --output-on-failure
```

- exact CTest: 1/1 in 4.52 seconds, peak RSS 133,812 KiB;
- four-cell result: `raw/p1-job-01-commands-and-output.txt`;
- CTest timing and source hashes: `raw/p1-job-01-*`.

This accepts the bounded single-process lifecycle. Forced process termination
and recovery remain for `P1-JOB-02`.
