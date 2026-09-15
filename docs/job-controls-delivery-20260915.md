# Job controls repair — 15 September 2026

Scope: deadline-only updates and ordinary continuation, compact job lists,
and explicit retry-count reset for one job or all jobs. Editable job files and
corpus prompt/extraction work are outside this repair. No master processing,
installation, paid calls, commit or publication is part of this acceptance.

**Complete — final candidate passes 79/79 local tests.** This repair checklist
is retired. Installation and corpus soak qualification remain separate work.

## Agreed behaviour

- Changing a deadline preserves every other limit, scope, input and usage value.
  Repeating the same absolute deadline does not extend it again.
- Ordinary continuation finishes admitted unfinished work after expiry without
  adding budget or discovering a further work wave. Explicit allowance renewal
  retains its separate meaning. Cancelled jobs remain cancelled.
- Job lists return compact metadata at every plan size; `job plan` owns detail.
- Resetting retry counts starts a fresh attempt allowance for the selected job
  or all jobs in this library. It preserves actual attempts, provider receipts,
  usage, budgets, completed results, reviews and unresolved outcomes. Reset is
  not a launch or budget renewal. Existing retry/continue commands perform work.
- Replace RAG-OPS-006's rolling-time retry proposal with this explicit control.

## Checklist

- [x] Inspect checkout, existing changes, owners, callers and reported failures.
- [x] Confirm relevant baseline controls; add failing acceptance before product edits.
- [x] Implement and test deadline-only update and expired continuation.
- [x] Implement and test compact job-list projection, retaining paged plan detail.
- [x] Implement and test one-job/all-jobs retry reset across ordinary work,
  maintenance and embedding retry eligibility, preserving accounting/history.
- [x] Update common command catalogue, CLI/MCP coverage and public/agent guidance.
- [x] Close the superseded rolling retry proposal; correct stale PC-01 checklist.
- [x] Pass final edge acceptance: retain start time and named-renewal idempotence after expiry.
- [x] Run configure/build, targeted tests, full suite and whitespace checks.
- [x] Report exact QA status and remaining installation/soak/upstream work.

## Evidence

Starting checkout: `main`, HEAD `dd96144bb3689ad4da4a9a43c8df914555402877`,
with earlier authorized repairs preserved. Prior full QA: 75/76; only PC-01
`regression_source_maintenance` fails. New evidence is retained under
`cmake-build-debug/job-controls-20260915/`.

Baseline rerun: 6/7 selected controls pass in 38.50s; only expired continuation
fails. Extended job-list acceptance reproduces a 66,275-byte response containing
plan text. Deadline and native reset acceptance fail on missing public commands.
The ordinary reset fixture first exposed a duplicate synthetic plan digest;
correcting the fixture gives the expected missing-command failure. Logs:
`baseline.log`, `new-baseline.log`, `reset-baseline.log` in the evidence directory.
The reset event is per item (five events for five native fixture items), with
idempotent repetition; the test asserts that explicit contract.

First acceptance found two interface defects: cancelled deadline conflicts were
misclassified as not-found, and the catalogue emitted an absent positional ID
for the all-jobs MCP call. Both are corrected without changing common parsing.
The next targeted run passes deadline, reset and metadata (3/3, 9.10s).
The first native reset test passes all five embeddings; ordinary count cycles
and lease recovery pass both VMs. Caller audit then found reconciliation's
separate lifetime paid-call count. An isolated nine-old-plus-one-uncertain-call
fixture fails after reset with `dead_letter` instead of `queued`, preserving
that defect in `reconcile-reset-baseline.log` before the owner repair.

SQL access-path review (`sql-access-paths.json`) confirms indexed item, task and
embedding-identity lookups. The newest per-item reset lookup sorts only that
item's reset records; no corpus-sized scan/sort or additional index is needed.
The 65,535-character list fixture now returns 736 bytes instead of the baseline
66,275 bytes, with complete plan text retained through `job plan`.

Combined targeted acceptance before the edge review: **9/9 pass**, 197.89s on
the shared machine.
This includes exact Codex reconciliation after reset, five native embedding
repairs, ordinary attempt/lease cycles, CLI/MCP single/all reset, deadline-only
mutation and continuation, compact lists/detail and advertised command metadata.
`targeted-final.log` retains the complete result. Configure/build and both
changed shared-skill validators also pass. The first full 79-test run passes (1024.41s); final review below adds two edge assertions before closure.

Final edge review: add preservation of the original timing start to the
explicit deadline test, and a native regression for repeating a named renewal
after its expiry. Named renewal must not fall through to ordinary admitted-work
completion and move its deadline. These assertions extend the final gate.

Both edge assertions reproduce their intended failures (`edge-baseline.log`):
the explicit edit replaced `started_epoch`, and an expired named renewal returned
success after moving the deadline. The repair preserves the existing start and
allows admitted completion only for an ordinary continuation, keeping named
renewals idempotent. The rebuild and expanded six-test panel pass (100.73s).
The final full-suite rerun passes **79/79**, zero failures, in 1562.73s on native
`30879436fcd8ac113435296cd7d8f6d03cab9b9387fe9e43f4bcf0ee5f0bd083`.
The linked artifact is
`9fc3ba5e7aa6fd88e80bd9eec5d18f0b9b0968b70025e4bcbf7399920e42c129`.
The final artifacts and 14 owning source/test hashes match the retained identity.
Configure/build, both changed skill validators and whitespace checks pass.
Elapsed times reflect a shared machine and are not performance qualification.
The [durable evidence directory](qa/job-controls-20260915/README.md) retains
the baseline failures, targeted acceptance, final full log and identity.

## Remaining work

- Install the qualified candidate and run the next authorized soak, including
  T7-10 controller/restart endurance. The exact mechanism of the two historical
  host-associated losses remains unconfirmed; this local suite does not claim
  to establish it. The Scottish executable and cancelled master job are unchanged.
- Exercise T7-02's returned review IDs with a naturally valid corpus proposal;
  its synthetic regression passes, but that real caller case remains open.
- Improve Scottish extraction prompts and resolve corpus content/review work
  during maintenance soaks, as agreed. This is separate from these job controls.
- Retain the bounded installed-CREXX source-form compiler finding in
  [integration issues](integration-issues.md); the existing documented close
  operation lets this product build normally without a sibling CREXX change.
- A commented job-file interface is now an agreed standing requirement under
  [RAG-OPS-007](ROADMAP.md#commented-job-files--rag-ops-007), with core and Scottish
  guidance updated. Its implementation remains separate from this closed repair.

No implementation or QA item remains in this repair. Changes are uncommitted;
the rolling retry proposal is closed as superseded by explicit reset.
