# P1-JOB-02 Forced-Termination Recovery

Status date: 2026-08-03. Result: accepted.

The scenario uses separate cREXX VM processes against one scratch database per
cell. Exit codes `71` through `74` force termination at the four authorized
boundaries: before the synthetic provider call, after it, with a promotion
transaction open, and after promotion commit.

Each optimized/non-optimized `rxvme`/`rxbvm` cell established:

- expired claims were recovered under a higher database-issued fence;
- the three displaced attempts became durable `expired` history;
- the uncommitted staged support and completion rolled back on process exit;
- stale workers could not promote;
- a call completed before a crash may be repeated at most once in this
  single-worker scenario;
- replay after committed promotion returned the idempotent result; and
- seven attempts/fences produced exactly four succeeded items and four unique
  support rows.

```text
cmake --build --preset debug --target p1_job_02
ctest --test-dir cmake-build-debug -R '^p1_job_02$' --output-on-failure
```

- exact CTest: 1/1 in 9.02 seconds, peak RSS 133,724 KiB;
- all stage outputs and forced exit codes:
  `raw/p1-job-02-commands-and-output.txt`;
- CTest timing and source hashes: `raw/p1-job-02-*`.

This accepts duplicate-free fenced recovery for the bounded single-process
worker. Budget admission and usage settlement remain for `P1-JOB-03`.
