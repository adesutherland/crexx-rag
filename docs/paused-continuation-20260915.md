# PC-01 — finish admitted work after a maintenance deadline

**Master job cancelled; engineering repair explicitly continues.** Adrian
clarified that cancelling the job does not cancel this defect work. The Scottish agent executed public
`job cancel`; receipts 004–005 under its
`reports/paused-continuation-20260915/execution` confirm 34 cancelled items,
zero queued/running and no active workers/controller. Existing 837 processed,
842 skipped, 287 dead letters and 1238 prior provider runs remain unchanged.
At cancellation, no new provider call, allowance renewal or product implementation
had occurred. The subsequent engineering repair is recorded below.
The temporary original-policy file was removed and selected policy is unchanged.
The quality/status report remains in that Scottish report directory.

Engineering repair is complete in the current candidate: focused acceptance and
all 79 local tests pass. The [job controls delivery record](job-controls-delivery-20260915.md)
retains the evidence; this repair checklist is retired.
The original master job remains cancelled. The obsolete caller-completion step
below is retired; completing those 34 cancelled items is not an outstanding
acceptance requirement for this repair.

Before cancellation, Adrian requested ordinary completion of the 34 paused items and a
corpus quality/status report after Test 7 closed. The Scottish agent owns the
master execution and report; engineering owns this continuation repair.
No new ingestion, broader backlog run or renewal of the old large allowance
is part of this request. The overnight monitor remains paused.

- [x] Confirm the public failure. Current configuration differs from the old
  job; selecting its exact original policy passes that compatibility check but
  `job continue --prepare` then exits 6 because the maintenance deadline expired.
  Evidence: Scottish `reports/paused-continuation-20260915/execution/001–003`.
- [x] Inspect existing owners/controls. Direct workers also checkpoint the
  maintenance window and enforce admission time. `--renew` adds the original
  allocation and allows more discovery. Neither is the requested completion.
- [x] Add a failing regression and pre-expiry continuation positive control.
- [x] For ordinary continuation after expiry, reuse the existing window time
  period and cap its item limit at the job's already-materialized item count.
  Keep the job's remaining call/token/cost/attempt allowance and immutable
  inputs/history unchanged. This permits its queued work and prevents further
  discovery/dispatch. Explicit renewal retains its existing wider meaning.
- [x] Prove repeated preparation preserves the new deadline/limit, no allowance
  period is added, queued identities survive, and completion adds no other work.
- [x] Run focused and full acceptance; document the ordinary command behaviour.
- [x] Retire the original 34-item caller step after explicit master cancellation.
  Installation and the next authorized soak remain separate qualification.

This repair is separate from T7-10, the still-unexplained controller lifetime
failure. It must not be described as fixing that failure.
