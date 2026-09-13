# Test 2 configuration and held-job investigation

**Repair recommendation superseded:** the user rejected the proposed added
guards. Follow the [simplification review](rule-simplification-review-20260913.md):
remove unnecessary global vetoes and keep completed/remaining work separate
from historical diagnostics. The observations below remain evidence; the
expanded guard and test-matrix proposal is not the current direction.

Status: investigated, **three open findings; no product repair in this slice**.
The user selected investigation after the rebuilt publication candidate passed
68/68. The three existing relevant tests still pass **3/3 in 35.36 seconds**.
Ten new synthetic diagnostic cases reproduce the missing boundaries. They are
retained probes, not registered passing repair acceptance. The corpus copy
still verifies at generation **24,922**, schema 17, with zero repository issues.

## Conclusion and repair direction

The new-document smoke is blocked before ingestion or provider execution.
A finished maintenance job is counted as active from its stale stored state.
A second historical embedding job retains a missing Gemini response. Its
cancellation changes the stored state used by the guard, and its suggested
recovery command supports only Codex.

The recommended repair is to permit reviewed future source configuration when
execution is drained, while retaining the old job's pause, immutable snapshot,
unknown attempt and accounting. This extends the current operational-change
rule to prospective changes; it is an explicit change to the documented
restriction, not a claim that today's restriction permits this workflow.
Correct the state-dependent guard, cancellation stability and misleading
recovery guidance together. A fabricated receipt, waiver, blind retry or SQL
data repair is unnecessary for the new-document run.

## Exact target and observations

Checkout: `/Users/adrian/CLionProjects/crexx-rag-review`, `temp/project-review`,
HEAD `9292c8d8d724b52fce34047c868f15531348faca` plus existing uncommitted repairs.
Installed CREXX used by the rebuilt candidate is `g037e7939bc29`.
The tested scratch-installed executable is
`/private/tmp/crexxrag-smk006-V6YatF/installed/bin/crexxrag`, SHA-256
`1572df54e58261d6300bbdf44903edfb3b36a07f6cd164ad3357b7d95377a7a5`.

Diagnosis used the prepared `smoke-library` and `test2.conf` beneath
`/private/tmp/crexxrag-smk006-V6YatF`. The current prospective plan reports
**two active jobs**. No queued/running items, active runtime registrations or
reserved calls/tokens/cost/turns exist for those blockers.

| Job suffix | Stored state | Public lifecycle | Work remaining in that job |
| --- | --- | --- | --- |
| `6487899…` | paused | paused | One embedding dead letter with an unmatched intent; 4,972 processed, one skipped |
| `d40ed9c…` | paused | completed_with_errors | Closed deadline window; 879 processed, 128 skipped, 101 dead letters, 92 cancelled; zero uncertainty |

Full job IDs and records are in [the evidence](qa/configuration-holds-20260913/).
The maintained copy retains 82,549 provider runs, 116,184 attempts, 647,251 events
and 95,147 items, unchanged throughout this investigation. The master was
queried read-only for the two historical parent states; it was not operated on.
No product rebuild, hosted call or master write ran in this slice. Tiny synthetic
fixtures alone used test SQL and public configuration/cancellation mutations.

## RAG-SMK-007 — configuration guard disagrees with execution and lifecycle

Owner: `ragconfiguration._configurationactivejobs` (line 164), consumed by
inspection, canonical plan creation, apply validation and its writer-transaction
recheck. For every non-operational classification it simply counts stored
`queued/running/paused/cancel_requested` jobs. It does not use the shared lifecycle
projection and does not independently check reservations, items or runtime
registrations. Operational changes use a different, stronger execution query
and allow drained paused jobs.

The `d40ed9c…` job is finished according to `raglifecycle` and every repaired
status surface. Its stored `paused` value alone blocks adding the source.
Changing only the parent storage value of an otherwise equivalent uncertainty
fixture also changes whether prospective apply is permitted.

The independent fixture results are:

| Fixture | Public state | Prospective active count / apply | Operational active count |
| --- | --- | --- | --- |
| Ordinary completed job | completed_with_errors | 0 / success | 0 |
| Drained deadline, stored paused | completed_with_errors | 1 / exit 6 | 0 |
| Unknown outcome, stored terminal | paused | 0 / success | 0 |
| Same hold, stored paused | paused | 1 / exit 6 | 0 |
| Queued work | running | 1 / exit 6 | 1 |
| Paused job with reservation | paused | 1 / exit 6 | 1 |
| Paused job with recent runtime registration | paused | 1 / exit 6 | 1 |
| Terminal parent with reservation | completed_with_errors | 0 / success | 1 |
| Terminal parent with recent runtime registration | completed_with_errors | 0 / success | 1 |
| Intentional drained pause | paused | 1 / exit 6 | 0 |

The terminal reservation/registration cases are injected fault states, not
observed live workers or reservations in the Scottish copy. They show why
merely changing the list of parent state strings is inadequate. Successful
fixture transitions retain the old job snapshot, generation, item count and
zero provider calls.

Proposed fix: one consistent configuration execution guard in the existing
owner. Reuse lifecycle observations for terminal projection and independently
retain queued/running work, reservation, item-fence and runtime protections.
A drained pause or historical unknown outcome remains attached to its old
snapshot and must not block unrelated newly planned work. Apply must recheck
inside its existing transaction. Keep `worksnapshotmatches` and
`checkworkerconfiguration`: new-policy workers must reject old incompatible
jobs, and old jobs retain their original provider requests. No schema or new
configuration framework is required. Reflect the revised policy in the user
and architecture guides.

## RAG-SMK-008 — cancellation toggles a held parent's stored state

Owners: `ragwork.requestcancel` (line 408) and the shared
`raglifecycle.lifecyclejobstate` / `refreshlifecyclejob` rules.

The original master has `6487899…` stored as `completed_with_errors` despite
its historical unknown attempt. The earlier copy-only cancel command therefore
matched no row in the initial `UPDATE ... WHERE state IN(...)`, but still
appended an event and refreshed the job. The refresh turned it into `paused`.
This explains the previous plan's active-job count increasing **one to two**;
the other job did not change.

The tiny fixture reproduces three successive public cancellations:
`completed_with_errors -> paused -> completed_with_errors -> paused` in storage,
while public status remains paused throughout. Starting paused produces the
opposite sequence. Attempts, unanswered intent and zero response/provider-call
counts remain unchanged. This is not an uncertainty settlement.

Proposed fix: make repeated cancellation and lifecycle refresh stable. Cancelling
already held or terminal scheduling must preserve the unresolved item and
uncertainty, and return a state whose read projection agrees. Reuse the shared
lifecycle owner; do not paper over it with command-level SQL. The regression
must exercise repeated public cancel plus a subsequent refresh and verify
unchanged attempts, receipts, usage, old snapshots and held-item state. No need
to cancel this historical job to make the new source eligible after SMK-007.

## RAG-SMK-009 — Gemini hold points to a Codex-only recovery command

Owner: `ragoperationsquery._itemrecovery` (line 400), composing receipt facts
from `ragreceipts` and the existing provider reconciliation service.

Held item:
`item-maintenance:d43ceb2521c2a043f6094565678f28b3c7e6feda7a4e7c6b73f354cea7c4159c`,
attempt `#attempt-8`, on 10 September. Its diagnostic is
`cannot begin provider receipt`. It has an intent and accounting settlement,
with recorded input **12 tokens**, output 0, cost **2 microunits**, but no durable
`provider-response`, no external thread/turn and no saved recovery content.
The associated task is resolved, which does not reconstruct this old response.
The exact cause of the historical receipt transaction failure was not recreated
in this investigation; do not infer a Gemini transport failure from it.

`job items` suggests `job reconcile`, but that public command returns exit 6:
`no durable Codex run for this job and item`. Its implementation explicitly
selects external thread identity and then requires a Codex route. The generic
recommendation is therefore unusable for this Gemini hold.

Proposed fix: choose guidance from the retained attempt's actual recovery
capability. Suggest exact Codex inspection when available; for a missing Gemini
receipt, report that no recoverable output is retained and keep the historical
hold. Do not promise reconciliation or suggest blind retry. The failed receipt
and known accounting stay visible; future unrelated work proceeds through the
corrected configuration guard. Implementing a new Gemini recovery protocol is
outside this bounded repair and is unnecessary for Test 2.

## Coverage gap and acceptance before the live smoke

Existing `configuration_contract`, `regression_smoke_terminal_state` and
`regression_lifecycle` passed **3/3 in 35.36 seconds** on the rebuilt product.
The configuration fixture settles its old jobs through test SQL before changing
provider/profile configuration. The status fixture checks read surfaces, not
configuration apply. The lifecycle fixture checks ordinary cancellation and
uncertainty separately, not repeated cancellation of this held parent. Those
passing tests did not cover the composed failure.

Before implementation, register ordinary failing regressions for the above
journeys and retain passing queued-work, active-owner and reservation controls.
After implementation require:

1. Reviewed new-source configuration succeeds on a drained corpus with a
   retained unknown attempt; every old snapshot, response and usage row remains.
2. Fresh/racing workers, queued work and reservations still refuse configuration
   apply, including the transaction recheck. New-policy workers cannot claim
   old incompatible work.
3. Repeated cancellation is stable, read/write lifecycle views agree, and the
   unanswered attempt remains held without a call or waiver.
4. Gemini diagnostics state the actual recovery limit; recoverable Codex
   inspection and digest-checked settlement retain their existing controls.
5. Full QA and the matching scratch-installed regressions pass. Repeat the
   source-configuration transition on the disposable full corpus and produce
   a new-document ingest plan showing only the staged document changes.

Then run the bounded new-document smoke: ingestion, embedding/extraction,
automatic publication, exact citation retrieval and identical re-ingest no-op.
The no-op must add no provider call or job. Follow with a small maintenance
window and selected extraction-hold recovery; do not launch the entire backlog.
Concrete hosted selections and call/time/spend bounds must be set before those
runs. Test 1's expired paid window is not reused.

The [19 retained evidence files](qa/configuration-holds-20260913/SHA256SUMS)
include the standalone CMake probe and its exact public command outputs. The
probe exits successfully when its mechanics complete; its logged failures and
unsafe fault-case acceptance remain open findings, not product qualification.
Documentation QA passed 1/1; diff whitespace, document links and all 19 evidence
hashes were checked. No product source, selected policy, master corpus or normal
installation changed.
