# Receipt and usage recovery

13 September update: the approved [rule simplification](rule-simplification-repair-20260913.md)
lets completed work stay complete and an explicit retry redo unfinished work
without recovering an old missing receipt. Automatic restart still retains
unanswered attempts without repeating the call; old usage and attempt limits
remain effective. The earlier hold rules and qualification below are historical.

Stage 3 of the recovery plan, 11 September 2026. Receipt persistence, usage
accounting and permission to publish are separate outcomes. A failed receipt
write must preserve the original request and usage, hold missing output, and
reuse recoverable output without another model call.

## Coverage confirmed before implementation

Baseline: `10a91d247685df5105d7c0152ff50bf351e2877e`, branch
`temp/project-review`, installed CREXX
`crexx-1.0.0-beta.3+local.g5ccf057a1633`. Tests use scratch libraries and local
fixtures; no live library, hosted call or sibling CREXX change is authorized.

The five existing suites passed in 83.95 seconds:

| Boundary | Existing test and independent assertions |
| --- | --- |
| Receipt saved, settlement fails | `native_receipts`: extraction and embedding separately; two replacement workers, exactly two total calls, original expired attempt charged, publication and released reservations. |
| Provider-specific observation | `worker_recovery`: exact thread/turn, unavailable/ambiguous history, stale digest, reconciliation rollback, duplicate apply, local saved output and no extra generation. |
| Reservation and usage contracts | `provider_durability`: admission release duplicates, external usage, expired reservations, conservative unknown allowance and migration. |
| Settlement succeeds, publication fails | `publication` and existing native publication/interruption cases: usage remains, graph changes roll back, stale ownership cannot publish, cancellation and post-commit projection failures stay distinct. |
| Killed request has no response | `native_interruption`: actual worker/controller kill with an unanswered intent; healthy peer completes and missing output stays held. |

Added before product edits:

- `provider_durability` now explicitly submits an exact duplicate raw response
  and a conflicting duplicate, then checks the unchanged original response and
  identity. All four compiler/VM combinations passed (10.12 seconds).
- `native_receipt_failure` injects an abort on the `provider-response` INSERT
  itself after the Gemini fixture returns, for extraction and embedding.
  Before repair, original usage and no-repeat protection survived, but neither
  case recorded an uncertain outcome; status reported a generic persistence
  error. The embedding restart also attempted vector publication despite its
  missing output and failed. Both defects are reproduced, not inferred from
  the historical incident.
- `worker_recovery` adds `receipt-write` on a real Codex fixture completion.
  Before repair, the already durable completed output was overwritten by the
  ordinary failed-output settlement path. Its assertion of one retained
  `completed-unsettled` response failed with zero. This is a demonstrated data
  loss at the intermediate receipt-write boundary.

Logs: `/tmp/crexx-rag-stage3-baseline.log`,
`/tmp/crexx-rag-stage3-test-first.log`,
`/tmp/crexx-rag-stage3-receipt-test-first.log`, and
`/tmp/crexx-rag-stage3-codex-test-first.log`.

## Ownership and compatibility

`ragworktypes` owns shared worker value contracts without importing a worker or
provider implementation. cREXX consumers of those types import it explicitly;
the unqualified names and value layouts are unchanged. Rebuild source consumers
with the explicit `ragworktypes` import. Existing `ragwork` function entry
points delegate to the new owners.

`ragreceipts` owns intent, response persistence, stored external identity and
observation/reconciliation. The adapter still owns provider-specific transport,
redaction and validation. `ragusage` owns settlement, admission release,
reservation accounting and conservative unknown-usage accounting. The shared
active-fence predicate belongs to `raglifecycle`; graph publication stays in
its existing worker/claim/backlog transaction owners.

Public settlement opens its writer transaction. Reconciliation composes the
same settlement body inside its existing atomic transaction. Extracting code
must not add a check-then-write race or nested transaction. No schema migration,
provider protocol change, executable split or new runtime dependency is needed.

## Receipt-write failure contract

A persistence error after receiving a provider envelope returns an explicit
uncertain worker outcome. The hold transaction retains known usage on the
original provider run; it never overwrites independently durable external
output. The worker then expires its own ownership through ordinary lease
recovery. Original intent, attempts and reservation events remain intact.

For Gemini, a minimal `completed-unsettled` usage record explicitly has no
content and marks its receipt missing. That is accounting evidence, not a
recoverable answer. Codex retains its existing raw completed output and
thread/turn identity. Public reconciliation can turn that output into a receipt,
settle once and queue normal validated publication. If output cannot be
recovered, the item remains held with no blind repeat call. Missing/unobserved
usage still consumes the conservative original allowance; releasing an expired
reservation does not make that allowance free again.

The planned CREXX llama.cpp bridge can enter through the provider adapter. These
receipt/usage contracts make no transport or executable assumption. This change
does not implement or qualify that future provider.

## Qualification

Final native executable SHA-256:
`5c828909c1c230f16c2099e1392c82996dfdf75adf34e0c8a9b30b7dcd468c6b`.
The optimized build and independent ADDRESS module built successfully with the
installed CREXX package; the original checkout is unchanged. A mechanical
comparison confirmed unchanged worker value-contract bodies and 44 moved
function bodies; this is a refactor review check, not runtime qualification.

The repair iteration passed all six focused suites in 99.06 seconds. The final
build additionally preserves the pre-existing unpriced sentinel for an uncertain
subscription run, now asserted by `worker_recovery`.

The final full review suite completed **43/46 in 544.99 seconds**. All **39
scoped tests** pass, including the new native receipt-failure test, the extended
Codex recovery case, both-VM duplicate checks, cancellation/late/publication
controls, linked/ADDRESS consumers and scratch-installed product smoke. No
previously passing test regressed.

The three failures are the existing broader review acceptance cases:
`regression_page_max` and `regression_large_job` (UX-02), and
`regression_retrieval_unicode` (QE-06). They remain enabled and failed; the full
review gate exits 8. This stage is locally qualified, not a green release gate
or closure of the complete OPS-001 operator/platform/long-run requirements.

Final evidence: `/tmp/crexx-rag-stage3-final-configure.log`,
`/tmp/crexx-rag-stage3-final-build.log`,
`/tmp/crexx-rag-stage3-final-full.log` and
`cmake-build-debug/regression.log`. `git diff --check` passes. No hosted calls,
global installation, live-library mutation, push or sibling CREXX changes were
made. The commit contains this stage's implementation, tests and documentation;
earlier broad review changes remain outside it. After the full run, only
documentation and trailing blank-line formatting changed.
