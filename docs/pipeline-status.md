# cREXX-Only Programme Status

Status date: 2026-08-03.

This is the only living implementation-status page. The previous native-v1
pipeline status is [archived oracle evidence](archive/native-v1/pipeline-status.md).

## Decision And Gate State

| Area | State | Meaning |
| --- | --- | --- |
| Product direction | Approved | Application and algorithms move to cREXX over generic facilities |
| Specification and architecture | Approved target | They define intended behavior, not already-shipped commands |
| Documentation retirement | Complete in this worktree | Competing native-v1 guidance is archived and indexed |
| Native-v1 implementation | Preserved oracle | Buildable for fixtures, goldens, defects, and comparison; not the target architecture |
| Phase 0 | Complete | P0-01 through P0-07 including P0-04A are accepted in the dated evidence bundle |
| Gate 0 | Passed | Full configure/build/CTest passed 17/17 with 19 frozen hashes and raw measurements |
| Phase 1A | Complete diagnostic unit | P1A-SDK-01 through P1A-SUR-01 all have focused retained correctness/failure/profile evidence |
| Gate 1A | Reached; Apple candidate replay passed; stopped for decision | CRI-01 through CRI-14 are closed downstream; Linux qualification opened CRI-15; no Phase-1B choice is approved by this evidence alone |
| Phase 1B and later | Not authorized | No hardening, donation implementation, schema v2, cutover, or retirement yet |

## Current Product Reality

The checked-in executable remains the native-v1 C++ core with CLI, MCP, RXPA
bridge, cREXX profiles/controllers, SQLite/FTS, optional FAISS, queues, and the
staged generic/Scotland proof. Those capabilities remain useful only as the
executable comparison oracle during the approved phases.

At Gate 0 on 2026-07-28, the debug preset passed 17/17 tests after a
user-authorized Level B compatibility recovery for an installed `rxc` Level G
`PARSE VAR` regression. The initial 7/11 failure, minimized reproducer, recovery,
fixtures, goldens, defects, judgements, hashes, raw measurements, and protocols
are retained under `docs/evidence/2026-07-28-phase0-gate1a/`.

On 2026-07-31 the user approved the exact CREXX `develop` candidate
`ea25d1720c8dc4044614fa6ac4789811289dc8ca` for a downstream-only replay. A
fresh source build was installed into a scratch prefix; the downstream project
configured with both SDK/source fallbacks off. The custom JSON/vector envelope
was retired in favour of production `rxjson.jsondocument` and explicit owning
headerless `node_f32_array`/`node_i64_array` projections. Element type, count
and dimensional meaning now belong to the application schema.

The provider adapter uses that production parse-once path and raw binary.
Deterministic generation, embedding, malformed response, timeout, connection
and provider-error coverage passed on both VMs without the retired `rx_socket`
module argument. No hosted call or credential was used. The historical failed
and successful Gemini canaries remain separate evidence and are not
reinterpreted as an `rxhttp` defect.

P1A-VEC-01 passed exact cosine/top-k ordering and tie behavior plus a 32 by 768
raw-f32 page with application-owned schema on both VMs. P1A-ALG-01 passed immutable source revisions,
zero-write identical reingest, paragraph reuse, exact claim support/retraction,
citation, lead, and gap. P1A-JOB-01 passed real before/after-promotion process
termination, DB-issued fences, stale-worker rejection, idempotent recovery, and
one support row. P1A-SUR-01 now returns the imported Level-B record directly
through Level G; CLI JSON, actual `ADDRESS RAG`, and MCP `structuredContent`
remain semantically equal. The installed `crexx-contract` helper emits the
external `crexx.operation-contract/1` status-evidence artifact.

Concrete CRI-01/04/05 reproducers, the CRI-02 binary probe and the CRI-06/07
SDK matrix pass optimized/non-optimized on both VMs where runtime-relevant. The
fresh deterministic/loopback closeout suite passed 28/28, 0 failed, 0 skipped
in 110.30 seconds. Exact evidence is under
`docs/evidence/2026-07-31-gate1a-crexx-candidate/`.

No cREXX-only production path, schema v2, selected provider contract,
production `rxsqlite`, safe multi-worker queue, or target command set is claimed
implemented yet.

Fresh Linux validation on 2026-08-03 repaired the native build's missing direct
`<algorithm>` dependency, PIC requirement for the RXPA plugin, and macOS-only
process-memory measurement commands. Debug and Release each build all 27 Ninja
targets. Three timing/benchmark tests now pass on GNU `time`; stable Debug
validation has one installed-CREXX failure. CRI-15 records that `rxvme` loses the
documented socket timeout status during string receive validation. Exact build
and minimized reproducer evidence is in the
[Linux build review](evidence/2026-08-03-linux-build/LINUX-BUILD-REVIEW.md).

## Gate-1A Decision Stop

Use the [implementation handoff](../prompts/phase0-phase1a-implementation-handoff.md)
and the [roadmap](crexx-only-implementation-roadmap.md). Update this page only
from retained evidence:

- use the refreshed Gate-1A decision packet and candidate-integration closeout;
- choose the SQLite, record/JSON, provider, vector, publication, fencing, and
  facade boundaries explicitly before Phase 1B;
- preserve the failed and successful canary evidence as separate facts;
- do not turn any incubation slice into a production library, CREXX donation,
  schema-v2 module, or native replacement without new approval.

Do not copy milestone claims from the archived status page into this page unless
Phase 0 re-verifies them.
