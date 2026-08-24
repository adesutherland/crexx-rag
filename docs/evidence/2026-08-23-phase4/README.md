# Phase 4 Implementation And Gate 4 Evidence

Status: Phase 4 and Gate 4 accepted for the recorded macOS scope on 2026-08-24,
including the literal supervised overnight worker soak. This record does not
claim Linux, cutover, release, or native retirement.

## Authority And Boundary

The authorized unit is Phase 4, `P4-01` through `P4-09`, with one commit only
after its gate is honestly satisfied. The sibling CREXX checkout remained
read-only at `1fbd89dc9afb7dbbf2e8e577624a87b1076ff11e`; its pre-existing
`docs/ROADMAP.md`, runtime capability roadmap, and release-plan changes were not
modified, staged, or included here. Downstream builds use the scratch-installed
CREXX package at `/tmp/crexx-phase3-install.xqEdYn` with source fallback off.

Recurring tests use a deterministic provider. Plans contain the symbolic
reference `env:OPENAI_API_KEY`, but no secret value is resolved, logged, or
retained. Real local and hosted provider qualification belongs to the explicit
Phase-7 budget and privacy gate.

## Implemented Worklist

| Item | Result |
| --- | --- |
| P4-01 | Canonical concepts/aliases, explicit ambiguity, directed qualified/time-scoped claims, five stances, polarity, attribution, lineage, conflict, and bounded directed traversal |
| P4-02 | Transactional mention promotion, independent support strengthening/retraction, and pre-generation identical replay |
| P4-03 | Versioned rank with density/cues/novelty/redundancy/bridge/source-quality/unresolved-risk components and canonical fingerprint |
| P4-04 | Immutable provider-neutral proposals with deterministic schema, endpoint, type, evidence-span, confidence, direction, provenance, and bound validation |
| P4-05 | Typed review routes for canonical overwrite, conflict, unresolved endpoints, type issues, ambiguity, low confidence, and external proposals |
| P4-06 | Database-clock leases, monotonic fences, attempts, heartbeat, retry/backoff/dead-letter, cancellation, counters, reservations, pause/resume/drain/status |
| P4-07 | Canonical `crexx-rag.improve-plan/1` plan/apply from explicit triggers with exact resource ceilings and zero-write replay |
| P4-08 | Once/follow worker engine, forced-termination recovery, two OS-process workers, expiry, stale-fence denial, cancellation, in-flight overrun denial, and one clean 28,800-poll supervised macOS run |
| P4-09 | Canonical external proposal plan/apply through the same evidence/profile/idempotency/conflict/review gates |

## Public Level-G Development Surface

- `ragclaims`: `promotemention`, `rankchunk`, `validateproposal`,
  `applyproposal`, `applyclaimedproposal`, `retractsupport`, and
  `traverseclaims`.
- `ragimprove`: canonical internal and external proposal planning/apply.
- `ragwork`: claim, heartbeat, reservation, settlement, success/failure/skip,
  cancellation, pause/resume/drain/status, and once/follow worker execution.

The Phase-2 public command facade remains intentionally unwired until Phase 6.
Provider output is immutable input to deterministic policy and never writes
canonical graph rows directly. Repeated final proposal promotion returns
`identical-no-op` without allocating a semantic generation.

## Permanent Evidence

- `crexx/application/tests/p4_01_claims_scenario.crexx` covers the claim,
  support, review, rank, traversal, internal-plan, external-plan, and replay
  matrix.
- `crexx/application/tests/p4_02_worker_scenario.crexx` covers real crash/
  expiry/recovery, two worker processes, stale fencing, controls, reservations,
  retry/dead-letter, exact graph effect, and the short form of the same
  `runworkerfollow` mode used by the time-based supervised soak.
- `crexx/tutorials/phase4_improvement_scenario.crexx` is compared byte-for-byte
  with `tests/expected/tutorial-phase4.jsonl` in all four compiler/VM cells.
- `ragcore_work_queue_consumers` remains the unchanged native-v1 queue oracle.
- CTest `phase4_improvement` carries P4-01 through P4-09 labels and runs the
  complete bounded proof.

## Local QA

| Gate | Result |
| --- | --- |
| Focused Phase-4 target | Passed after final confidence and in-flight ceiling additions |
| Focused ordinary CTest | 1/1 passed in 51.49 seconds |
| Compiler modes | Optimized and non-optimized claims/tutorial passed |
| Concrete VMs | `rxvme` and `rxbvm` claims/tutorial/crash/control passed |
| OS-process recovery | Real `SIGKILL`, database-clock expiry, two competing workers, and stale-fence rejection passed on both VMs |
| Native/static proof | Existing `ragcore_work_queue_consumers` oracle passed inside the target |
| Full ordinary Debug | Corrected final source: 71/71 passed in 108.31 seconds with `--parallel 10` |
| Fresh Release | Corrected final source: build passed; 71/71 CTests passed in 113.67 seconds |
| Focused docs/language/Phase 4 | 3/3 passed in 51.80 seconds after documentation reconciliation |
| Apple ASan build phase | Focused target passed through `CREXX/tools/asan-run.sh`, `ASAN_OPTIONS=detect_leaks=0` |
| Apple ASan CTest phase | Corrected final source: 1/1 passed in 125.15 seconds, no sanitizer diagnostic |
| LeakSanitizer | Unsupported on Apple and explicitly disabled; no Linux LSan claim |
| Scratch installed consumer | CREXX package `/tmp/crexx-phase3-install.xqEdYn`, `CPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF` |
| Hosted traffic | Zero; symbolic reference only, no credential value resolved or retained |
| Literal supervised soak | One launchd run; 28,800 one-second polls; 31,579 observed elapsed seconds; four processed improvement items; exact success output; empty stderr; exit 0 |

Apple-ASan retained logs are under
`cmake-build-debugasan/asan-logs/20260823-221640-build/` and
`cmake-build-debugasan/asan-logs/20260823-221850-ctest/`. The fresh Release
tree was `/tmp/crexx-rag-p4-release.ZF70FH`.

## Literal Soak Acceptance

Roadmap P4-08 requires one supervised worker overnight. The optimized `rxvme`
worker ran under the macOS user launchd domain from
`2026-08-23T21:12:11Z`; completion was observed at
`2026-08-24T05:58:30Z`. It performed 28,800 one-second idle polls after
processing all four items in its improvement job. Launchd recorded exactly one
run and exit code 0; stdout was exactly:

```text
P4_SOAK_OK worker=supervised-soak-rxvme idle_polls=28800 processed=4 job_state=completed
```

Stderr was empty. The completed improvement job had four succeeded attempts,
four matched reservation-open/close events, zero reserved calls/tokens/cost,
four deterministic fixture provider runs, and one active support. A separate
ingestion job retained four queued claim-extraction and four queued embedding
items; it was intentionally outside this soak and is not represented as leaked
improvement work. Runtime inspection found zero network file descriptors and
zero secret-bearing launchd environment entries. The plan retained only the
symbolic reference `env:OPENAI_API_KEY`; no credential value was resolved.

The exact supervisor configuration, stdout, manifest, integrity-checked SQLite
database and checksums are retained beside this record as `soak-*` artifacts.
Gate 4 is therefore accepted for the recorded macOS scope. Exact downstream
Linux replay remains open and is not substituted by this result.

The first supervised timing probe correctly completed but exposed that
`rxplatform.sleep` takes milliseconds while `runworkerfollow` declares seconds.
That probe is not counted as the soak. The worker now converts its public
seconds bound to milliseconds. The same audit found that the crash fixture's
intended 30-second hold used 30 milliseconds and that its host harness did not
require `kill` to succeed. Both defects are repaired: the fixture holds for
30,000 milliseconds and a missing live child now fails the test. The permanent
two-poll cell verifies corrected polling before the full 28,800-second run is
relaunched.

## Tutorial

The executable walkthrough is
[`docs/tutorials/phase-4-improvement.md`](../../tutorials/phase-4-improvement.md).
It covers ingestion-to-claim flow, proposal validation, exact budget planning,
worker execution, review behavior, and zero-write replay without requiring a
hosted call.
