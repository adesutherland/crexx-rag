# cREXX-Only Programme Status

Status date: 2026-08-23.

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
| Gate 1A | Accepted 2026-08-03 | D1-D8 boundaries and the bounded D9 worklist are recorded; its historical Linux replay retained the original CRI-15 failure |
| Phase 1B / Gate 1B | Accepted 2026-08-04 | Every bounded item is accepted; the historical Gate validation was 55/56 with sole expected CRI-15; current disposition is tracked separately |
| Language strategy | Level G first, accepted 2026-08-04 | Advanced libraries and application code use Level G; Level B is limited to justified CREXX bootstrap/foundation work |
| Phase 2 / Gate 2 | Active; `P2-05` pending | `P2-01` through `P2-04` are accepted, including the schema-v2 storage foundation and read-only version-1 dry-run/import boundary; pinned backup/restore and immutable sidecars are next |
| Parallel CREXX capability sync | Current-head macOS replay complete; follow-up deferred | Current installed-only macOS replay, public Level-G HTTP/toolchain adoption, `rxhash.sha256`, and exact `rxvector` integration pass 62/62 against CREXX `e3d6b7b90158`. Remaining provider-lifecycle work is separately approval-gated, and exact downstream Linux confirmation is deferred to later QA after material local progress; neither blocks Phase 2. |
| Phase 3 and later | Not authorized | No production ingestion, additional hosted qualification, cutover, or retirement |

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

No complete cREXX-only product path, production `rxsqlite` package, safe
multi-worker queue, repository/ingestion layer, or target command set is
claimed implemented yet. The Level-G schema-v2 storage foundation is accepted
over the local generic SQLite incubation. The provider contract remains
qualified in local incubation, subject to the Gate-1B transport limitations.

Fresh Linux validation on 2026-08-03 repaired the native build's missing direct
`<algorithm>` dependency, PIC requirement for the RXPA plugin, and macOS-only
process-memory measurement commands. Debug and Release each build all 27 Ninja
targets. Three timing/benchmark tests now pass on GNU `time`; stable Debug
validation has one installed-CREXX failure. CRI-15 records that `rxvme` loses the
documented socket timeout status during string receive validation. Exact build
and minimized reproducer evidence is in the
[Linux build review](evidence/2026-08-03-linux-build/LINUX-BUILD-REVIEW.md).

On 2026-08-03 the user approved D1 through D8 as recommended and the bounded D9
worklist proposed from the successor decision prompt. The exact scope and
exclusions are in the [Gate-1A decision ledger](gate1a-decision-ledger.md).
The Phase-1B entry audit reproduced 27/28 Debug tests with only CRI-15, built
Release, and verified all 19 frozen hashes. Exact evidence and the resumable
worklist are under
[`docs/evidence/2026-08-03-phase1b/`](evidence/2026-08-03-phase1b/WORKLIST.md).

`P1-RXPA-01` is accepted: the installed package builds an independent dynamic
plugin with both fallbacks off, and optimized/non-optimized consumers pass on
`rxvme` and `rxbvm` with an exact version match. `P1-RXPA-02` passed
compatible/missing/incompatible package and dual-VM module-discovery
qualification. The SDK section is complete. `P1-SQL-01` through `P1-SQL-07`
are accepted with four-cell ownership, typed-value, SQLite behavior,
read-only, separate-process concurrency, online-backup, integrity, forced
cleanup, and optional address-facade evidence. The generic SQLite section is
complete. `P1-JSON-01` and `P1-JSON-02` are accepted against installed
`rxjson`; `P1-REC-01` originally qualified nominal Level-B records crossing
Level G over generic plugin columns. That cross-level result remains retained
compatibility evidence, while the maintained record and consumer sources now
use Level G under the later language-policy decision. `P1-LLM-01` and the
available local OpenAI-compatible case in `P1-LLM-02` are accepted; a real
`llama-server` executable was unavailable and is not claimed. `P1-LLM-03`
accepts ordered batch embedding, bounded structured validation, retry/backoff,
usage, pre-transport privacy denial, and truthful unsupported capabilities.
CRI-15 historically blocked Linux timeout qualification; CRI-16 recorded that
the then-installed `rxhttp` path was a one-connection-per-request synchronous
transport. The current disposition is the public Level-G `rxfnsg` path described
below. `P1-LLM-04`
passes all local/OpenAI/Anthropic/Gemini shapes and five low-cost hosted calls,
including two 128-dimensional batch-embedding results. `P1-LLM-05` proves zero
outbound connections for denied routes and zero retained matches for all three
credential values. The provider section is complete. The accepted boundary,
validation, and remaining transport gap are summarized in the
[provider closeout](evidence/2026-08-03-phase1b/PROVIDER-CLOSEOUT.md).
`P1-VEC-01` accepts a headerless canonical `f32le-v1` payload with
application-owned type/count/meaning and an exact 768-dimensional scratch
SQLite round trip. `P1-VEC-02` accepts exact keyset-paged ordering for the
11,684-by-768 representative fixture, including deterministic tie behavior.
`P1-VEC-03` measures full-workload search at 750,316 to 857,843 us with
18,845,696 to 26,595,328 bytes peak RSS; arithmetic dominates while memory
remains below 64 MiB. `P1-VEC-04` retains pure cREXX exact search as the bounded
fallback and recommends separately authorized generic `rxvector`
qualification because the latency trigger crossed. The vector section is
complete; every bounded Phase-1B implementation item through `P1-JOB-03` is
accepted. Gate 1B was reached on 2026-08-03 and accepted by the user on
2026-08-04. Phase 2 is authorized and `P2-01` is accepted. Its pushed entry
baseline reproduced 57/58 tests, with all 28 Phase-1B tests passing and the
sole failure still CRI-15. The ordered worklist and entry record are under
[`docs/evidence/2026-08-04-phase2/`](evidence/2026-08-04-phase2/WORKLIST.md).
The new Level-G application contracts and the registered typed
configuration/profile boundary pass optimized/non-optimized on both VMs.
`P2-02` rejects arbitrary paths, duplicates, invalid references, literal
secrets, and unsupported worker scope while proving zero loading side effects.
Its acceptance suite passed 59/60 in 607.33 seconds with only CRI-15. `P2-03`
now supplies two checksum-verified schema-v2 migrations, 32 logical tables,
SQLite-authoritative immutable publications, generation-pinned snapshots,
recoverable non-secret manifests, strict stable-bundle read-only opens, full
verification, and ordered ancestor rollback. Its four-cell and real-`SIGKILL`
proof passed, and the final full suite passed 60/61 in 553.13 seconds with only
CRI-15. Version-1 compatibility, backup/restore, repositories, commands, and
provider execution remain unimplemented. `P2-04` is pending.

On 2026-08-22 the separately bounded CREXX capability sync completed its
macOS work against a fresh installed-only scratch prefix. Downstream content
identity now exercises installed `rxhash.sha256`; the accepted exact CPU
`rxvector` provider supplies explicit `f32le` conversion and deterministic
packed cosine/top-k without a wrapper or manual plugin list. Its bounded
11,684-by-768 replay totals 122,740-129,974 us across four cells, versus the
retained pure 750,316-857,843 us result, with exact identities and scores.
Installed dynamic and automatic native/static selection pass, and benchmark-
only providers are absent from the package. The current 62-test downstream
inventory has passing evidence for every test after the broad run exposed and
the focused replay corrected one frozen-artifact preservation mistake. Exact
status and evidence are in the
[capability-sync worklist](evidence/2026-08-22-crexx-capability-sync/WORKLIST.md).

On 2026-08-23 the pulled CREXX head
`e3d6b7b9015847d247ab2b90e83c843881db9b2f` added no replacement public API,
but records completed supported Linux sanitizer qualification in its pulled
lineage, retained all four CREXX-owned cREXX-RAG HTTP cells, qualified
`rxvector`, and repaired a process cancellation/replacement ownership race. A
fresh scratch install selected that
exact package with both fallbacks off; the downstream build passed 27/27 and
the complete CTest inventory passed 62/62 in 97.99 seconds. No downstream
compatibility code change was needed because current `main` already consumes
the public Level-G HTTP, `rxhash` and `rxvector` facilities. Evidence is retained
in the [current integration replay](evidence/2026-08-23-crexx-current-integration/README.md).

The algorithm profile crossed its retained 10,000-us trigger in all four cells while
remaining below 64 MiB. Full validation passed 55/56 tests; the sole failure is
unchanged CRI-15. See the
[Gate-1B decision packet](evidence/2026-08-03-phase1b/GATE-1B-DECISION-PACKET.md)
and [decision ledger](gate1b-decision-ledger.md).

After Gate acceptance, the user confirmed Level G as the essential strategy for
advanced user-facing libraries and application code. The installed toolchain
requalification found no remaining Level-G blocker: every Phase-1B cREXX source
compiled in both modes and representative provider, record, algorithm, job,
vector, and installed-SDK runs passed on both VMs. The maintained Phase-1B
sources were migrated to Level G; dated Gate evidence and low-level reproducers
remain unchanged. The `crexx_language_level_audit` test enforces this boundary.
Exact commands and results are in the
[Level-G migration evidence](evidence/2026-08-04-levelg-migration/LEVEL-G-MIGRATION.md).

## Phase 2 Execution

The [Phase-1B implementation handoff](../prompts/phase1b-implementation-handoff.md)
and dated worklist are completed execution records, not active instructions.
The full validation remains in the evidence packet, and the user's acceptance
and Phase-2 authority are recorded in the
[Gate-1B decision ledger](gate1b-decision-ledger.md).

The dated Phase-2 worklist, entry baseline, item ordering, evidence
requirements, exclusions, and Gate-2 stop are established. `P2-01` through
`P2-03` are accepted; `P2-04` is next and pending, with no item active.
Separately bounded CREXX
capability work may proceed in parallel only after each stream records an
equivalent boundary.

Native-v1 remains the executable oracle. The pulled upstream lineage's
supported Linux sanitizer and HTTP substrate qualification is now green.
CRI-15 remains open for the exact
downstream Linux reproducer/current-package replay; CRI-16 remains open for the
approved provider-lifecycle scope and downstream Linux/package evidence. These
are deferred parallel qualification items, not Phase-2 prerequisites.
Additional hosted calls, Phase 3, donation submission, dual-write, cutover and
native-core retirement remain unauthorized.
