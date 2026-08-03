# P1-JOB-03 Budget Admission And Settlement

Status date: 2026-08-03. Result: accepted.

The Level-B `job_budget` layers hard admission over the fenced queue. Item
creation and provider-call reservation each use a short SQLite transaction.
Call admission verifies the current item/worker/fence/attempt, reserves the
configured maximum token, cost, and time exposure before provider work, and
settles actual usage afterward while releasing the difference.

The four-cell proof established:

- hard item and call ceilings of two;
- one in-flight call in the single-process worker;
- distinct zero-write denials for item, call, token, cost, job time, per-call
  cap, and in-flight limits;
- two pre-call reservations followed by actual usage settlement;
- zero remaining reservations and actual totals of 130 tokens, 26 cost
  microunits, and 650 ms; and
- documented maximum unreported in-flight exposure of one call, 100 tokens,
  20 cost microunits, and 500 ms.

The maximum exposure is not permission to exceed a configured hard budget.
It is the bounded amount already admitted but not yet reconciled into actual
usage when a status read or process failure occurs.

```text
cmake --build --preset debug --target p1_job_03
ctest --test-dir cmake-build-debug -R '^p1_job_03$' --output-on-failure
ctest --test-dir cmake-build-debug -L '^P1-JOB-0[1-3]$' --output-on-failure
```

- exact item CTest: 1/1 in 6.34 seconds, peak RSS 133,668 KiB;
- worker closeout: 3/3 in 19.28 seconds, peak harness RSS 133,708 KiB;
- item output, timing, and hashes: `raw/p1-job-03-*`;
- closeout evidence: `raw/job-closeout-ctest.*`.

This accepts the bounded scratch-library worker slice. It does not authorize a
production queue schema, multi-process workers, scheduler, or provider call.
