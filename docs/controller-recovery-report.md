# Controller recovery qualification, 10 September 2026

The repair keeps admitted healthy workers running after one worker fails. It
isolates uncertain provider outcomes to their own items and leaves the existing
configured task-attempt and worker-replacement limits intact. It does not
implement the new task/worker/environment classification policy; that decision
is recorded separately as [RAG-OPS-004](recovery-defects.md#rag-ops-004--p1-distinguish-task-failure-worker-failure-and-environment-outage).

## Reproduced cause

The published baseline is `e17d52d58b17615695216336b8b729fcbdec7f20`.
An eight-worker fixture holds all first requests at a rendezvous, disconnects
one submitted Codex turn, and then releases the healthy responses. The baseline
stops at 7 of 16 extraction items: eight remain queued and one is held, with no
replacement. Its job-wide uncertainty guards pause peer admission, and the
controller treats the failed slot as a reason to stop the group.

The live run also demonstrated a second path: after two actual replacements,
`reserveworkerreplacement` reports the exhausted durable ceiling as a controller
error. The controller then requests drainage from healthy workers. Repeated
public restarts retain that ceiling, so a later eligible worker failure can
trigger the same drain immediately. The existing executable was restarted
through `job run`; the live database, configuration and executable were not
patched to apply this repair.

Earlier tests covered single-worker preflight replacement and explicitly
expected an unanswered turn to pause the entire job. They did not require
healthy peers to continue through a lost response or an exhausted replacement
ceiling. The new regression makes that concurrency requirement explicit.

## Repair

- Recover an exited worker's leases through the existing fenced claim owner.
  Replace eligible unhealthy workers using the existing durable ceiling,
  backoff, remaining slot allowance, job budgets and deadline.
- Treat an exhausted replacement ceiling as a decision about further process
  launches. Healthy workers continue; unreplaced failures are reported after
  those workers finish. Existing startup and controller/storage errors retain
  their failure handling.
- After a Codex stream failure, inspect the exact thread and turn once through
  a fresh bounded transport. Validate and reuse a completed answer, or permit
  the configured retry for confirmed interruption/failure without output.
  Unknown, ambiguous or nonterminal history holds only that item.
- Persist the observation with its receipt. Incomplete usage retains the
  unobserved part of its original input, output, cost, time and call allowance;
  it is not presented as measured usage. Read these allowances together,
  using the existing event-type index range for reservation-open events.
- When only held work remains, leave the drained job paused and vector
  publication pending so public reconciliation remains available. Repeating
  `job run` must preserve that hold, and cancellation takes precedence.

## Validation

The focused run passed all three panels: `provider_durability` (10.28 s),
`controller_recovery` (49.00 s) and `native_interruption` (8.57 s). The full suite
then passed all 33 tests in 651 seconds, including the Gemini, Codex, embedding,
publication, installed-product, documentation and process-recovery panels.

A final query-plan check added an explicit reservation-open prefix alongside
the existing exact reservation-event predicate. SQLite then selects
`job_events_type (job_id=? AND event_type>? AND event_type<?)` instead of reading
every event for the job. Scratch results are unchanged. The final executable
was rebuilt for the live handoff; its recovery panel results are recorded below.
The final executable passed `provider_durability` (10.05 s),
`controller_recovery` (52.26 s) and `native_interruption` (8.54 s): all three
panels passed in 70.86 seconds. `git diff --check` and the documentation contract
also passed.

The new `controller_recovery` panel uses one public eight-worker launch per
scenario, without operator restart. It covers confirmed interruption, recovered
completion, optional-cleanup failure, unavailable history, three failures against
a two-replacement ceiling, and a final held item with replacement disabled.
Assertions check exact call counts, task outcomes, unchanged budgets, released
ownership, continuing peers and public reconciliation after the other work ends.

| Injected failure | Finished extraction items | Generation calls | Automatic replacements |
| --- | ---: | ---: | ---: |
| Interrupted turn, confirmed through fresh history | 16/16 | 17 | 1 |
| Completed turn recovered from fresh history | 16/16 | 16 | 1 |
| Optional cleanup timeout after a saved answer | 16/16 | 16 | 1 |
| Unavailable history with remaining independent work | 15/16; one held | 16 | 1 |
| Three interrupted turns, replacement ceiling two | 16/16 | 19 | 2 |
| Only a held item remains, replacement disabled | 15/16; one held | 16 | 0 |

The final case also repeats public `job run` without another generation, then
uses public `job reconcile` to return the held item to the queue. The failed-slot
cases can report an error after peers finish; they must not request peer drainage.

The provider durability panel additionally checks all five uncertainty budget
dimensions and cancellation of a held job. The interruption panel kills actual
native processes and requires the independent embedding task to finish while
the killed extraction remains unrepeated. The existing cancellation and
post-commit publication scenarios remain part of that panel.

The full-suite executable above has SHA-256
`a61cb997e76d905153a9ba00a637cd21fcaa915017b0c045ebc6a2cfae6f7dc6`.
The final native executable, including the explicit index-range predicate, has
SHA-256 `caf17c66db6237c07a0de22f5a27d25178a3fdba0fc64b7ecf61035003e2cf3a`.
The pre-handoff live executable has SHA-256
`fe154f4b0ef7d74044a1b328c92299b7b08ee7d6905d55072ad71ecf72ef4c39`.

Evidence logs are under `/tmp/crexx-rag-controller-*`; scratch libraries and
per-scenario command logs are in this worktree's
`cmake-build-debug/test-controller-recovery` and
`cmake-build-debug/test-native-interruption`. These are deterministic local
fixtures, not a claim that every real provider or environment failure is solved.

## Authorized live handoff

The user authorized publication and an eight-worker launch of the same live job
with the repaired executable. At the handoff baseline the old controller and
all workers had exited after another timeout; public status reported 7,375
processed, 13,082 skipped, 230 dead-letter and 10,891 queued items (31,578 total).
Use public `job run` with the existing configuration and budgets, freeze the
new executable while it runs, and begin public pause/drain at 16:28 BST for the
16:30 cutoff. Runtime observations belong in the run log, separate from the
deterministic fixture results above.
