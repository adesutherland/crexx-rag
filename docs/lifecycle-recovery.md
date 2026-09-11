# Durable retry requests and lifecycle ownership

Step 2, based on `4500e771036d115045178afc68df0c1991ea03cf`.

The baseline focused run passed four of five tests in 25.61 seconds. Only
`regression_closed_retry` failed. Existing tests cover same-job retry history,
maintenance deadlines, uncertain usage and admission, but do not establish
durable acceptance for all task states or execution after a closed window.

## Design before implementation

`raglifecycle` owns terminal-job projection and retry-request identity/state.
`ragwork` retains claims, fences and same-job execution; `ragbacklog` retains
task reconsideration, window policy and dispatch. A request never grants new
budget, changes an attempt ceiling, reopens a closed window, or clears an
uncertain outcome.

Schema 14 adds one `retry_requests` table. A row targets exactly one existing
maintenance task or job item, retains its original reason and progress version,
and records pending/completed state plus a public disposition. At most one
pending request exists per target. Repeated requests at the same progress
version reuse the durable identity; an in-progress request is reused even if
execution has advanced the version. Original attempts, receipts, task links,
provider usage and window deadlines are preserved. Existing schema migrations
remain unchanged; old libraries use the normal additive upgrade path.

`maintain retry TASK_ID --reason TEXT` accepts every durable task state.
`job retry JOB_ID --item ITEM_ID` accepts every item state and delegates linked
maintenance work to its task owner. Acceptance is separate from execution:

- Existing queued/running work keeps ownership; the request cannot duplicate it.
- Completed or already-covered work completes the request without another call.
- Uncertain provider intent remains held for reconciliation.
- Reviews, advanced-reasoning routing, retry delays and attempt ceilings remain
  binding. The pending request reports the hold and is reconsidered by the
  normal maintenance checkpoint under a compatible reviewed policy.
- A closed window requires a new reviewed maintenance plan. The request remains
  durable across process restart; the new window can dispatch eligible work.
- Ordinary job items can requeue under their original job policy when eligible;
  pause/cancel controls, unknown outcomes and explicit attempt limits remain
  binding. A request alone does not resume a paused or cancelled job.

The public retry response includes request identity, whether it was newly
accepted, and its current disposition. Job status and task inspection expose
pending requests and their waiting reasons. Replay keeps its explicit new-job
contract, uses shared terminal-state eligibility, and must not clone an uncertain
call or duplicate active/completed descendants.

Coverage must include task/item/window state combinations, idempotence across
restart, request-versus-claim ownership, a five-failure closed-window embedding
fixture completing through public commands, covered-work no-op, preserved
history/usage and pending requests at actual attempt limits. Existing pause,
cancellation, uncertainty, admission, publication and migration tests remain
required controls. Record final qualification here when complete.

## Focused evidence

- `native_lifecycle`: public planning produces the inputs and original policy;
  a persisted five-quota-failure fixture recovers in a newly reviewed window
  with exactly five additional embedding calls. Closed items, original attempts,
  receipts/usage and the source allowance remain intact. A held provider response
  supplies the rendezvous for a concurrent retry request.
- `native_lifecycle_holds`: three items recover while one exhausted identity and
  one intent without a receipt remain held, including after a further window.
  Their explicit three-call ceiling and uncertain outcome are not reset.
- `regression_lifecycle`: both optimized VMs cover parent/item states, claim
  competition, pause during failed settlement, explicit resume, missing policy,
  immutable request history, replay deduplication, progress timestamps and
  ancestor-request completion after replay settlement.
- `provider_durability`: the earlier migration chain remains checked; schema 13
  can inspect its old task before the normal write-open path upgrades to 14.
  The earlier task, malformed legacy input and costed provider history survive.
- The broader review's `regression_retry`/`regression_closed_retry` cover native
  CLI and MCP access, deduplication, closed-parent acceptance and replay guards.

The native five-failure test was red on the original parent refusal before
implementation. Additional tests reproduced pause, unchanged-state progress
and replay-ancestor completion errors during review, before their corrections.
All policy decisions remain in Level-G source. No hosted calls, live operator
libraries, sibling CREXX modifications, executable split or model bridge were
used for this repair. Close/waive commands, receipt-persistence recovery,
renewal/outage policy and full operator-journey qualification remain separate
roadmap work.

## Final qualification

Qualified locally on 11 September 2026, against installed CREXX
`crexx-1.0.0-beta.3+local.g5ccf057a1633`:

- Configure and build: passed, including native init/two-worker packaging smoke.
- Final focused lifecycle cases: **3/3 passing in 21.31 seconds**.
- Complete review working-tree suite: **42/45 passing in 554.81 seconds**.
  `regression_page_max`, `regression_large_job` (UX-02) and
  `regression_retrieval_unicode` (QE-06) remain ordinary failures. The former
  closed-parent acceptance failure now passes through CLI and MCP.
- All **38 tests registered in this scoped commit pass**, including every
  previously committed test. The other seven cases belong to the separate,
  uncommitted broader review; they were included in the full run above.
- Working-tree and staged `git diff --check`: passed. Schema 14 checksum verified;
  prior migrations are unchanged. The original checkout remains untouched.

Native artifact SHA-256:
`c8277bed463c05f28c777628842e06ae2fa8b498efc2ef1db44678827019c15d`.
Logs: `/tmp/crexx-rag-step2-final-focused.log`,
`/tmp/crexx-rag-step2-final-full.log`, and
`cmake-build-debug/regression.log`. The full run used
`ctest --preset regression --output-on-failure`; the scoped committed suite
uses the existing debug preset. This is local macOS qualification, not hosted,
Linux, long-duration or full-corpus operator qualification.
