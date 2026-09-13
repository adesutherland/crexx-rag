# Shared-rule simplification — 13 September 2026

Implemented and locally qualified: **69/69 tests pass in 901.87 seconds**, exit 0. This follows the
user-approved [review](rule-simplification-review-20260913.md), including the
search for duplicate rules. Work is in `crexx-rag-review` on `temp/project-review`,
base `9292c8d8d724b52fce34047c868f15531348faca`, preserving previous dirty repairs.
Installed CREXX is `crexx-1.0.0-beta.3+local.g037e7939bc29`.

## Changes

- Future configuration no longer scans or vetoes all old jobs, reservations or
  workers. Old job snapshots remain immutable; per-item provider compatibility
  still applies. Canonical identity validation and a conditional pointer update
  replace duplicate field comparisons and the extra pointer read.
- Completion precedes old missing-response history. A stopped terminal job stays
  stopped; repeat cancellation makes no writes. Drained failures finish with
  errors and available vectors can publish.
- Explicit retry uses normal attempt and run limits to redo unfinished work.
  Old intent, missing response and known/conservative usage remain unchanged.
  Automatic recovery does not silently repeat an unanswered call.
- `raglifecycle` shares explicit-retry predicates and replay-family ownership.
  Maintenance and the legacy claimed-proposal path share `activeworkfence`.
  Publication checks ownership at the writer transaction entry; inner mention
  and completion helpers take its generation and no longer reopen transactions
  or repeat the same check.
- Item diagnostics describe completed work as complete and use ordinary retry
  guidance for unfinished work. They no longer prescribe Codex reconciliation
  for every missing response. Actual retained Codex recovery remains available.
- Reconciliation accepts a drained terminal parent without first demanding an
  impossible pause transition. Actual worker/claim checks remain; the shared
  lifecycle refresh makes newly queued work runnable and preserves real pauses.

## Validation

Existing controls passed 6/6 before changes. The added standalone public journey
and both-VM lifecycle assertions reproduced the target failures before product
edits. Initial fixture errors (a noncanonical source path, incomplete synthetic
intent and attempt-budget setup) were corrected separately from product code.
The first complete focused pass covered the new source/stop/repeat journey,
both-VM explicit redo, public state projection and native maintenance redo:
4/4 in 25.79 seconds. Final candidate and full-suite results follow below.

Existing receipt/interruption assertions now distinguish automatic restart from
explicit redo; the native maintenance fixture completes four items, including
old unanswered work, while its exhausted item remains held. Original history,
active-owner exclusion, budget limits, no-call repeats and waiver coverage remain
asserted. Tests that encoded the removed permanent veto were updated deliberately.

## Duplicate search

Search covered product sources, callers, tests and current guides. Removed copies
include continuation's global config checks; reservation's two bespoke unknown
queries; replay's separate descendant veto; two inline maintenance fences; the
legacy claim fence; and inner publication fence/transaction branches. Existing
history queries for accounting and diagnostics are retained: observing an old
unknown response is different from prohibiting a new task. Schema migration/view
SQL and unrelated generation/provenance recursion are not duplicate execution
rules and were not refactored. Broad work/query snapshot compatibility remains a
separate candidate, as agreed in the review.

No hosted calls, master-library changes, regular installation, commits or pushes
are included in this repair.

## Disposable-corpus smoke preparation

The scratch-installed candidate applied both prospective source configuration
and the later two-worker adjustment beside the real historical jobs. The first
import rolled back because the prepared eight-worker policy divided a five-minute
time allowance below the full provider timeout. Public `config set` reduced
only the disposable policy's worker count to two; spend and time stayed unchanged.
No product guard or master policy was changed for that adjustment.

Public ingestion then added one 952-byte public-history document as two chunks,
queueing exactly two extraction and two embedding items at generation 24,923.
Repeating plan/apply returned `identical-no-op`, zero queued work and zero calls.
Lexical inspection found the new source; citation resolution matched source bytes
502–951 exactly. All original job snapshots stayed unchanged. Provider runs stayed
82,549 and attempts 116,184; only four items and one budget event were added.
The old resolved Gemini task reports `already-complete` while still displaying
its historical missing response.

Prepared library: `/private/tmp/crexxrag-smk006-V6YatF/smoke-library`.
Policy: `/private/tmp/crexxrag-smk006-V6YatF/test2.conf`, SHA-256
`0541ed3efa5cfc78f07e39ea3e9fed50fb5547d1e5b82e8214fc92956be15dcb`.
Snapshot: `config-a211c0fede4237fe77bbc797`.
Queued job: `job-sha256:0916c52c55fea9da892cd37de730e5abc2af5c17e882fb5cd0bf8444e2f38095`.

Hosted processing is pending. Its existing prepared limits are five minutes,
eight provider calls, at most four managed Codex turns, and $0.005 monetary
provider cost, using two workers and only this new job. Test 1's expired window
has not been reused. The original corpus and permanent query copy are untouched.

## Final integration follow-up

The first complete run passed 66/69 in 781.17 seconds. Three historical fixtures
encoded the removed pause/hold policy. Corrected worker and receipt fixtures pass
2/2 in 145.32 seconds. The controller rerun exposed a real follow-on restriction:
reconciliation required a pause that a terminal parent could not enter. Removing
that parent gate and calling the shared lifecycle refresh fixes the integration;
the controller fixture also checks that prepared continuation can use the result.
The final build passes the complete **69/69** suite in **901.87 seconds**, exit 0.
The focused terminal-controller case also passes, including prepared continuation.
The temporary installation matches the final native executable:
`751e3ca283c036f524feee93d5eb6b7565ec424bd4cd18fce038bc419fae0da3`.
Linked application:
`35f07ce135a7f0adb15fd7b119f805b694bf9ef4a840ca3a8b919d4608043a42`.
The final installed executable prepared the new corpus job with zero calls.

Retained evidence is in [docs/qa/rule-simplification-20260913](qa/rule-simplification-20260913/).
The completed full-run log is [full-reconciliation.log](qa/rule-simplification-20260913/full-reconciliation.log).
Earlier red logs remain historical evidence, not the current result.
