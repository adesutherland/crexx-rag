# Phase 3 Ingestion Evidence

Status: Phase 3 and Gate 3 accepted for the recorded macOS scope on
2026-08-23. Exact downstream Linux qualification remains open.

## Scope And Authority

Adrian authorized sequential Phase 3-plus implementation with QA and one commit
after each phase on 2026-08-23. Phase 3 uses the accepted schema-v2 and Gate-2
storage foundation. The sibling CREXX checkout was read-only; its existing
Debug product was copied into a scratch install prefix for installed-package
consumption.

No hosted provider call was needed. Credential availability is assumed for
later provider phases through symbolic environment/secret references, never
literal or retained values.

## Item Result

| Item | Result |
| --- | --- |
| P3-01 | Stable connector keys; retained raw bytes or verified references; raw, metadata, text, and revision-envelope SHA-256; immutable revisions; MIME/encoding; compressed raw-to-normalized UTF-8 byte-span maps. |
| P3-02 | Deterministic Level-G plain, Markdown-heading/fence, and Rexx-procedure chunkers with golden coverage. |
| P3-03 | Immutable revision/span occurrence ids plus content/input fingerprints and duplicate-aware continuity keys. |
| P3-04 | Canonical immutable `crexx-rag.ingest-plan/1`, generation/apply revalidation, exact counters, atomic retry/resume, and zero-write convergence. |
| P3-05 | One generation closes and publishes source/revision/chunk/dependency visibility, FTS, exact support re-anchor/retract, embedding reuse, and missing work. |
| P3-06 | Append, edit, reorder, mapped/unmapped rename, duplicate, deletion, metadata-only, CRLF/Unicode, invalid UTF-8, parser change, stale plan, interruption, and resume covered. |
| P3-07 | Versioned deterministic candidate census, collation, representative evidence and adjudication; a failed generation rolls back and is retryable from the same reviewed inputs. |
| P3-08 | Generic oracle capture remains green; the Scotland-shaped native and cREXX scratch libraries both project two sources and five chunks at the matched 512/0 policy. Row ids are not compared. |
| P3-09 | Versioned term occurrence/chunk/source-diversity fingerprints, candidate policy, parser/policy work hashes, bounded invalidation, and repeated-plan convergence covered. |

## Gate 3 Headline Evidence

- identical input: zero SQLite changes, zero provider calls, same generation;
- one-paragraph edit: unaffected chunk, embedding and support reused;
- removed paragraph: dependent support closes and is absent from the active
  snapshot;
- publication: a pinned reader sees the old FTS while a fresh reader sees the
  complete new generation;
- interruption: real `SIGKILL` of a staging transaction rolls back, and both
  concrete VMs resume to one source, revision and job without duplicates; and
- initial and incremental ingestion call the same `applyingestplan` reconciler.

## Permanent Proof

- `crexx/application/ragingest.crexx`
- `crexx/application/ragfolder.crexx`
- `crexx/application/tests/p3_01_ingest_scenario.crexx`
- `crexx/application/tests/p3_02_oracle_delta.crexx`
- `crexx/application/tests/p3_03_resume_scenario.crexx`
- `crexx/tutorials/phase3_ingestion_scenario.crexx`
- `tests/fixtures/tutorial/architecture-mini/`
- `tests/expected/tutorial-phase3.jsonl`
- `cmake/Phase3Ingestion.cmake`
- CTest `phase3_ingestion`

## Focused Result

`cmake --build cmake-build-debug --target phase3_ingestion --parallel 10`
passes optimized/non-optimized compilation on `rxvme` and `rxbvm`, the exact
executable tutorial output, native generic/Scotland oracle checks, and real
dual-VM `SIGKILL` resume.

## Validation

Final current-worktree results before the phase commit:

- scratch installed-package Debug build: complete 27-step downstream build;
- full ordinary Debug CTest: 70/70 passed in 114.46 seconds, including the
  four-mode/VM Phase-3 matrix, native oracle, executable tutorial, installed
  CREXX dependency, and dual-process interruption/resume proof;
- fresh Release build: complete 27-step downstream build and 70/70 CTests in
  109.59 seconds; the Phase-3 test passed in 31.15 seconds;
- focused ordinary Debug documentation, language-level, and Phase-3 tests:
  3/3 passed in 20.98 seconds;
- Apple AddressSanitizer: a coherent installed CREXX Apple-ASan product plus
  ASan-built downstream core/plugins passed `phase3_ingestion` in 48.92
  seconds with no sanitizer diagnostic;
- Apple LeakSanitizer: unsupported and not claimed; `detect_leaks=0` was used
  only for the Apple-ASan build/test;
- static/native proof: the permanent target drives the native CLI against the
  Scotland fixtures while cREXX runs both concrete VMs; installed/public
  packaging of the Phase-3 application modules remains Phase 6 and is not
  claimed here;
- exact tutorial output: all four optimized/non-optimized `rxvme`/`rxbvm`
  cells matched `tests/expected/tutorial-phase3.jsonl`;
- `git diff --check`: passed; and
- publication: no hosted call, credential read, normal-prefix install,
  sibling-source edit, push, pull request, release, or native cutover occurred.

The Debug, Release, and sanitizer trees all consumed CREXX from a scratch
install prefix. The sibling checkout remained read-only; its pre-existing
modified documentation files were neither edited nor staged by this work.

## Residual Limits

- public CLI, ADDRESS, MCP, skill and installed tutorial surfaces are Phase 6;
- provider execution and graph promotion are Phase 4;
- retrieval/evidence packets are Phase 5;
- folder symlink/selection and application size policy remain caller policy;
- normalized text is UTF-8; unsupported/invalid encodings reject
  deterministically; and
- native-v1 remains the oracle. No cutover, deletion, release, push, hosted
  call, or Linux completion is claimed by this phase.
