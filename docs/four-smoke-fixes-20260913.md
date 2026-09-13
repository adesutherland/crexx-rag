# Four smoke and restart repairs — 13 September 2026

Status: all four repairs locally qualified. Full QA is **67/67 in 932.92
seconds**; the separate scratch-installed replay is **5/5**. Changes are
uncommitted on review HEAD
`9292c8d8d724b52fce34047c868f15531348faca`, branch `temp/project-review`.
The user explicitly requested all four repairs. Existing test/documentation
changes were preserved. No live provider call, processing-master change, policy
increase, commit or push belongs to this gate.

## Fixes and acceptance

| Defect | Repair and owner | Required evidence |
| --- | --- | --- |
| P2 RAG-SMK-004: stale registrations called live | `ragsupervision` shares local process observations with worker diagnostics. Status exposes separate registered, confirmed-live and unverified counts. | CLI/MCP parity; fresh and old-heartbeat live processes; confirmed exited process; empty group; remote/PID-zero observations; exact unchanged SQLite dump. |
| P2 RAG-SMK-005: public final states disagree | `raglifecycle` supplies read projection and aggregate counts. Bounded repository job pages, report generation and report cache validation use the existing lifecycle rule. | CLI/MCP status/list/report agree after deadline drain; running, intentional pause, uncertainty and complete controls remain intact; reads do not write. |
| P1 OPS-001/004: children keep claiming after controller loss | `ragprocess` checks the parent during startup and worker iterations. `ragwork` checks again under the claim writer lock through `ragsupervision.workerclaimallowed`, carrying the original controller identity. | Kill only the controller during a held response; no new claim and child exits. Startup orphan exits. Both VMs deny a real claim after `ON DELETE SET NULL` clears the stored parent link. |
| P1 OPS-001/004: ordinary restart rejects a live old group | `ragproduct` composes selected-group drain/cleanup in `ragprocess`, existing durable recovery, then fresh controller/children. | Ordinary `job run` drains surviving ownership; repeated `job continue` preserves completed work, attempts, receipts and usage. Unrelated live/terminal records survive; PID-zero reservations are cleaned; remote ownership is refused before mutation. |

Product behavior stays in existing Level-G modules. No schema, native provider,
new command or supervisor is added. Raw-VM test module lists now include the
shared supervision dependency. Existing receipt, lease, uncertainty, retry,
budget and publication owners remain authoritative.

Cleanup snapshots the selected group and includes children reserved by its
original controllers while startup ends. It refuses unfiltered overlapping or
remote ownership before writing. It requests drain, waits for actual process
exit, recovers abandoned claims and removes only the materialized selected
identities. The wait uses the configured lease allowance with at least the
existing 60-second startup grace; expiration retains ownership and reports an
incomplete drain. Final identity materialization prevents foreign-key link
clearing from leaving late startup reservations behind. The existing atomic
registration guard handles fresh controller admission.

## Regression-first evidence

The historical baseline passed 63/67, with exactly these four ordinary tests
failing. Fresh reproduction used native SHA-256
`02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5`.
Original interruption and documentation controls passed. Before product changes,
this turn extended the four fixtures with remote/PID-zero observations,
startup controller death, selected-group isolation and remote refusal without
mutation. **All four extended regressions fail in 14.64 seconds**, with their
original positive/read-only/receipt controls retained (`extended-baseline.log`).

| Candidate | Result | Evidence |
| --- | --- | --- |
| Status repair | 5/5 in 21.25s: status, diagnostics, lifecycle and query | `status-build.log`, `status-targeted.log` |
| First restart repair | 8/9 in 154.49s: all four original regressions and existing process/interruption journeys pass; added parent-removal assertion fails on both VMs | `restart-build.log`, `restart-targeted.log` |
| Parent-identity candidate | Build passes; focused 7/7 in 34.48s, including the repaired parent-identity check and original interruption/lifecycle controls | `final-build.log`, `final-targeted.log` |

The first restart candidate exposed foreign-key `ON DELETE SET NULL` losing
parent identity. The final repair passes the original launch parent through
`runworkeronce` and `claimnext`; the stronger regression verifies the actual
claim transaction creates no new attempt. The failed intermediate log is
retained. No assertion was disabled, inverted or converted to an expected
failure. Resolved `known-defect` labels were removed after the focused pass.

Intermediate native hashes:

- Status repair: `75f7eb63f89e5c1da03692aeefc27e4556df59db104fd9aa667c04c8f5e49967`.
- First restart: `2aa686782bb2e720d36681dffd41d74a4efcf2b2c6cc415595243d188f601cae`.

## Final artifact and qualification

Native SHA-256:
`62eaaa2292e210b0c468d2de58ed126ca92557a1a24760109d863c764b85fa81`.
Linked application SHA-256:
`01712c8c081097b4208d982208035502735f2fbd84c574428dcd8bc0047e340c`.
The native candidate uses the installed CREXX package `5ccf057a1633`.

Full suite: **67/67 pass in 932.92 seconds**, CTest exit 0. This includes
Gemini provider smoke, malformed-output/secret-redaction controls, both-VM
owner tests, durable recovery, publication, continuation and installed-product
qualification. No previously passing test regressed.

A separate install to `/private/tmp/crexxrag-four-fixes-rZcd4v/installed`
completed successfully. Its executable matches the tested native SHA-256 above.
All **five installed fixture invocations pass**: stale workers, terminal state,
controller-only death, live-group restart and the original three-case native
interruption fixture. These use bounded loopback providers and scratch libraries.

Retained logs, public command outputs and source/artifact hashes:
[QA evidence](qa/four-smoke-fixes-20260913/). Working evidence directory:
`/private/tmp/crexxrag-four-fixes-rZcd4v/`. Final documentation verification and
`git diff --check` are recorded at handback. No product source changed after
the passing full gate.

## Remaining boundaries

This qualifies the local macOS launcher's process visibility domain. The
installed CREXX probe still cannot distinguish hidden PIDs from absent PIDs;
remote/PID-zero observations stay unverified, and automatic cross-account or
non-macOS recovery is not claimed.

The five missing Scottish embeddings, selected operational retries, retained
content holds and census-duration follow-up are separate work. No old live
allowance is renewed. The earlier smoke report and test-only full gate remain
historical evidence; these local repairs do not claim a new corpus outcome.

## Full-gate correction — continuation preparation

The first full gate on native `4b0676e4...` passed **64/67 in 975.40 seconds**.
`native_continuation` and `native_continuation_holds` exposed an ordering
regression: `job continue --prepare` drained/removed live ownership before the
existing preparation guard. The first failed fixture left its port occupied,
so `native_legacy_retry_ceiling` then failed its readiness control; the later
embedding-policy case passed. No product failure is dismissed as a timing issue.
The full logs and public commands are retained as `full-before-prepare-*` and
`prepare-failure-commands.log`.

A direct runtime-request equality check was added before the correction. It
fails against this candidate in **37.62 seconds**: the active group disappears
after the preparation-only command (`prepare-ownership-baseline.log`).
`ragproduct` now runs cleanup only for actual launches; `--prepare` retains the
existing ownership refusal without draining or renewing the active group.
The corrected build passes. Focused qualification is **9/9 in 67.06 seconds**, including all four requested repairs, original interruption and the four continuation/retry cases. The full rerun is **67/67 in 932.92 seconds**; no product source changed afterward. Logs are `prepare-build.log` and `prepare-targeted.log`, followed by the final full and installed evidence above.
