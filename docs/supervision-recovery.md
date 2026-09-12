# Rolling worker recovery and shared provider outages

Step 4 of the recovery plan replaces a job-lifetime restart ceiling with a
rolling allowance. A long run can recover from isolated failures hours apart.
A burst temporarily exhausts its allowance; the controller keeps observing
healthy peers and reconsiders missing slots, including a completely empty pool.

## Policy and ownership

`worker.max_restarts` remains 2 by default, with the existing range 0..10;
zero disables automatic replacement. `worker.restart_window_seconds` is an
optional operational setting, default 3600, range 1..86400. An event expires
at its timestamp plus the window duration. Expiry releases capacity, without
deleting the event. The existing replacement backoff starts at
`worker.restart_backoff_ms` (default 5000), multiplies by six for each recent
replacement, and caps at 60000 ms. Old events no longer increase that delay.
Omitted defaults preserve existing configuration hashes. A non-default window
participates in full and operational configuration identity.

`ragsupervision.crexx` owns eligibility, rolling history, atomic replacement
reservation and its status projection. Its reservation transaction binds the
original exited worker to a single replacement and records both the runtime
reservation and audit event. Concurrent callers cannot spend the same capacity.
`ragprocess.crexx` owns child launch, liveness, registration, signalling and
completion observation. It retains the previous public reservation entry point
as a delegate. The controller records its configured count and recovery policy
when it starts. No schema migration or new executable is needed.

A queue temporarily emptied by healthy workers does not discard a missing
slot: it waits for their disposition without spending replacement capacity.
A stopped slot waits independently; backoff no longer blocks observation of
other child exits. Replacement preserves its remaining item and poll limits.
While a slot is parked waiting for policy eligibility, elapsed idle polls count
toward an explicitly supplied `--max-polls` limit. This prevents a deliberately
bounded batch from becoming an hour-long wait. Zero remains unbounded follow.
Normal claims and provider admission still enforce the original job allowance
and maintenance cutoff. Pause, cancellation and drain remain effective while
waiting; replacing a worker grants no new task attempts, receipts or usage.

`ragenvironment.crexx` owns the existing provider/model admission gate,
cooldowns, exponential retry backoff and single recovery probe. Admission is
still atomic with its capacity recheck. Usage settlement invokes the environment
transition inside its existing writer transaction. Exact duplicate settlement
cannot grow a cooldown, and an older in-flight success cannot clear a newer one.

The added classification is narrow: a retryable, explicitly unhealthy transport
that failed before provider submission now establishes a shared cooldown too.
It consumes no provider call or failed-task allowance. Existing retryable called
provider failures retain their previous cooldown policy. Unknown submitted work
retains its reconciliation hold. Generic nonzero process exits do not establish
an environment diagnosis or become automatically replaceable.

When every remaining eligible route is cooling, replacement waits. Surviving
workers can perform the admission-gated recovery probe. With no live workers,
one replacement is reserved to probe; other missing slots wait until that probe
settles successfully. The same gate serves HTTP and managed Codex providers and
does not depend on a future llama.cpp bridge. An unavailable authoritative
SQLite store remains a coordination error; this slice does not infer a wider
infrastructure cause from a missing database connection.

`job status` reports configured/live worker counts, the window and maximum,
recent replacement count, the next eligibility epoch and worker waiting reason.
Process counts reflect retained runtime registrations; local PID ownership and
pruning retain their existing separately documented scope. A controller restart
or pruning runtime rows does not erase replacement events, provider cooldowns,
task history, original usage or unknown outcomes.

## Regression evidence

Baseline: `d36db0773f51bba3e9b991a73ba349b8661d9a97`, installed CREXX
`5ccf057a1633`, native SHA256
`5c828909c1c230f16c2099e1392c82996dfdf75adf34e0c8a9b30b7dcd468c6b`.
Before product edits, `configuration_contract`, `process_workers`,
`provider_durability`, `worker_recovery` and `controller_recovery` all passed
(148.77 seconds). Their assertions cover existing classification, peer isolation,
restart history, provider cooldown/probe atomicity and original accounting.

New native tests first reproduced both missing behaviors: two historical
replacements permanently blocked an isolated failure, and a zero-worker
controller exited before the recent allowance could recover. The same fixture
without historical replacements passed. The expiry fixture sets durable event
timestamps at the observed worker-failure boundary; it needs no multi-hour wait
or production clock override.

- `regression_supervision`: optimized code on both VMs; exact window boundary,
  burst backoff, expiry, reopen before/after expiry, retained history, a queue
  temporarily emptied by healthy owners, generic
  exit exclusion, pause and competing independent-process reservations.
- `native_supervision`: public `job run` positive control, aged history,
  zero-worker automatic replenishment, public waiting status, cancellation
  while parked, and an eight-worker outage followed by recovery. The outage
  requires eight actual failed preflights, one recovery probe, eight successful
  generation calls, restored slots, unchanged task allowances, retained history
  and zero outstanding reservations. A separate marked bad task must exhaust
  exactly two attempts among eight healthy workers while seven peers finish,
  with no worker replacement.
- `worker_recovery`: preserves peer/task/receipt/reconciliation assertions;
  the permanent-preflight-failure case now specifies a finite poll budget.
  A controlled retained cooldown across restart must defer without another
  preflight, preserve its failure count and leave the replacement burst intact.
- `controller_recovery`: retains the eight-worker isolation cases, exact call
  and replacement counts, healthy-peer progress and unchanged budgets.

The environment write-failure characterization also passed before the final
transaction-boundary adjustment: an injected cooldown INSERT failure rolls back
admission settlement, and a subsequent normal release succeeds.

The first full run caught a startup-diagnostic ordering regression in the new
controller loop. The existing `gemini_ingestion` assertion remained unchanged;
startup classification is now applied before the controller leaves its loop.

Final native SHA256: `60ad3f965c2704e069019fcf9680704adc733b38a258b6fe1f8418fd973fee0c`.
The full review suite passed **45/48 in 620.61 seconds**, including all
**41 tests in the scoped commit**. The only failures are the same three existing
review acceptances: `regression_page_max` and `regression_large_job` (UX-02),
and `regression_retrieval_unicode` (QE-06). No previously passing check regressed.
The complete review gate remains red; these tests were neither excluded nor
inverted. Local deterministic fixtures qualify this slice; hosted endurance and
additional platform qualification remain separate.

Commands: `cmake --preset debug`, `cmake --build --preset debug`,
`ctest --preset debug --output-on-failure --parallel 1` and `git diff --check`.
Full output: `cmake-build-debug/regression.log`. Native fixtures retain command
logs, public waiting status, independent SQLite assertions and probe audit data
under `cmake-build-debug/test-native-supervision`; optimized VM and competing
reservation logs are under `cmake-build-debug/test-supervision-regression`.
