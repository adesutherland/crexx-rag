# Temporary provider capacity recovery

Step 1 of the recovery work, 11 September 2026, based on
`df9649d7ae18fcc74a40616f5ff9b515f86b382b`.

An ordinary ingestion worker could fail an uncalled task when another worker
reserved the available input, output, cost, time or in-flight capacity. The
maintenance-only deferral helper returned an error for ordinary jobs. The
worker treated that error as a failed attempt and exited unhealthy.

`ragadmission` now owns the allowance decision. It distinguishes measured
consumption, live reservations and conservatively retained uncertain usage.
It checks every dimension; an exhausted or uncertain limit cannot be hidden
by temporary pressure elsewhere. `ragwork` keeps the ledger reads, fence check
and reservation creation in the same writer transaction. A waiting claim is
queued with the existing one-second readiness delay and its uncalled attempt
retained as cancelled/provider-deferred. Failed-attempt allowance is preserved.
The normal worker loop waits and resumes without a replacement.

The additive `job status` field `waiting_reason` reports a queued deferral
separately from historical failure. It clears when the claim is reacquired or
the item stops waiting. Existing real-exhaustion, uncertain-outcome, cancellation
and maintenance-window stopping behavior remains in force. No schema, budget,
provider pricing, worker replacement policy or executable boundary changes.

Coverage was confirmed before product changes:

- `regression_ingest_capacity` reproduced all five pressure dimensions on both
  optimized VMs, with an unpressured provider-call positive control.
- `durable_backlog`, `publication` and `provider_durability` passed on the
  baseline, including window deadlines, settlement, subscription accounting
  and unknown-usage retention. The four-test baseline took 44.04 seconds.
- Invalid-cap, consumed-budget and cancellation controls were added and run.
  The first two passed; cancellation exposed the peer already being dead-lettered.
- `native_admission` reproduced the failure through public plan/apply, job run
  and status with a held loopback response: three of four items completed,
  one failed attempt, two failed runtime instances and exit 8. The scratch
  fixture reduces the stored reservation ceiling before execution to guarantee
  contention; the policy stays unchanged throughout the run.

The acceptance requires all four native items to complete, no failed or
replacement workers, exactly four provider responses/reservations/settlements,
no phantom provider calls, unchanged policy and cleared waiting status. The VM
test additionally checks classification precedence, cancellation and real
exhaustion. These use synthetic scratch libraries and no hosted calls.

Validation completed:

- Focused panel: **5/5 passed in 48.15 seconds**.
- Complete working-tree workflow: **38/42 passed in 493.45 seconds**. All 33
  original tests and both admission tests passed. The seven separate review
  acceptance tests include three passes and four previously recorded failures:
  `regression_page_max`, `regression_large_job`, `regression_closed_retry` and
  `regression_retrieval_unicode`. The complete review gate still exits 8; no
  test was disabled, inverted or weakened.
- The scoped admission commit contains the 33 original tests plus these two
  passing admission tests. The broader review tests/roadmap remain separate
  working-tree changes, including the four visible failures above.
- `git diff --check` passed, changed product import paths have no cycles, and
  relative documentation links were checked. No hosted call, user-library
  mutation, global installation or push was performed.

Installed CREXX: `crexx-1.0.0-beta.3+local.g5ccf057a1633`.
Native product SHA-256:
`6c802036f40b02fb6d6bb2635925ff0055e1272e459f2543acdef97303e5c251`.
The local evidence is retained in `/tmp/crexx-rag-step1-full.log`,
`/tmp/crexx-rag-step1-focused.log` and the generated test directories under
`cmake-build-debug`. Rerunning tests replaces generated artifacts.

This closes step 1's temporary-pressure acceptance, not the wider OPS-004
supervision/outage policy or a globally green review gate.
