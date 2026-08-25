# cREXX-Only Programme Status

Status date: 2026-08-25.

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
| Phase 2 / Gate 2 | Accepted on macOS 2026-08-23 | `P2-01` through `P2-10`, public installed-capability adoption, canonical zero-write plans, and hostile apply-time revalidation are accepted. Exact downstream Linux replay remains open. |
| Parallel CREXX capability sync | Current installed package adopted on macOS | Public Level-G HTTP/JSON, complete `rxhash` SHA-256, and exact packed `rxvector` are consumed directly with source fallback disabled. Provider-lifecycle expansion remains separately approval-gated, and exact downstream Linux confirmation is the only deferred Phase-2 platform replay. |
| Phase 3 / Gate 3R | Accepted on macOS, including provider addendum, 2026-08-25 | The native Level-G `crexxrag` application owns schema-v5 extraction/embedding work, provider-kind dispatch, validated claim promotion, exact vector publication, durable OS-process workers and human-default progress. Permanent Gemini, Codex JSONL/durability and process QA is green. [Clean bounded walkthroughs](evidence/2026-08-25-phase3-provider-addendum/README.md) passed with Codex plus local llama.cpp and with Google Gemini; each unchanged replay made no new job, worker or provider call. Codex App Server remains an experimental local-personal hosted route. The known CREXX prompt double-Enter remains accepted; Linux, release and cutover are separate. |
| Phase 4 / Gate 4 | Accepted on macOS; application extension accepted 2026-08-25 | Claims/extraction/review/improvement, durable multi-process workers and the literal eight-hour supervised soak pass. `crexxrag improve` now reviews and executes immutable configured-provider work; permanent Gemini plus bounded real Codex/Google paths and zero-call replay pass. Exact downstream Linux remains open. |
| Phase 5 / Gate 5 | Accepted on macOS; human application extension completed 2026-08-25 | Native `crexxrag query` now uses the accepted planning/evidence algorithms with compatible query embeddings and optional citation-validated Codex/Gemini answers. Permanent negative QA and clean real Codex/local plus Google walkthroughs pass. Exact Linux, release and cutover remain open. |
| Phase 6 / Gate 6 | Accepted on macOS 2026-08-24 | Installed Level-G CLI, ADDRESS RAG, MCP, exact reviewed ingest, zero-write plans, backup/restore and capability-scoped skills pass in four compiler/VM cells. Public worker-provider lifetime remains a cutover limit. |
| Phase 7 / Gate 7 | Qualification complete; application extension 2026-08-25; reject/defer cutover unchanged | Native human, canonical JSON and MCP provider smoke now make real budgeted calls using fixed public synthetic text and validate exact citations or embedding dimensions. The recorded decision preceded the now-accepted Phase-3 worker/provider integration and hosted replay. Production-shaped same-session comparison, exact Linux and a new explicit cutover decision remain open, so native-v1 stays default. |
| Phase 8 | Opportunity report complete; Gate 8 not satisfied 2026-08-24 | Candidate, installed-adoption, compatibility, and retirement states are recorded. No submission, cutover, deletion, release, or push occurred or is implied. |

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

One staged cREXX-only public product path now exists through the Phase-6 CLI,
`ADDRESS RAG`, MCP and skills, but it is not yet the selected production
default. The Phase-4 multi-process improvement queue and literal
eight-hour soak are accepted on macOS. The Level-G semantic schema-v2 storage,
schema-v3 runtime-process registry, and schema-v4 durable work envelopes,
schema-v5 external-provider recovery/subscription budgets, Phase-3
reconciler/repository components and Phase-5 retrieval/evidence paths
are accepted over the selected generic facilities. End-to-end product
ingestion is accepted at Gate 3R on macOS for Gemini and for the Phase-3
subscription/local addendum. The provider factory routes Gemini and
OpenAI-compatible generation/embedding plus contained Codex structured
generation. One App Server child and isolated empty directory belong to each
worker; thread/turn ids and completed output are durable before settlement.
Local Nomic embedding generation uses llama.cpp's OpenAI-compatible endpoint.
These results close the Phase-3 provider blockers locally but do not change the
original cutover decision or remaining comparison, platform/release criteria.

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
complete for its retained phase scope. Maintained 2026-08-24 hardening now uses
RXPA V2 per-VM sessions, session-local handles/diagnostics and
`SQLITE_OPEN_FULLMUTEX`; `p1_sql_thread_sessions` passes four concurrent
sessions, 400 WAL writes, isolated diagnostics, and cross-session handle
rejection on macOS. Direct SQLite calls from a cREXX task
remain blocked by the separate native-module/provider-discovery seam recorded
as CRI-17. `P1-JSON-01` and `P1-JSON-02` are accepted against installed
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
secrets, unsupported per-process in-flight scope, and unbounded process counts
while proving zero loading side effects; 1–32 processes with one item each are
now accepted configuration.
Its acceptance suite passed 59/60 in 607.33 seconds with only CRI-15. `P2-03`
retains two checksum-verified schema-v2 migrations and 32 semantic tables; the
maintained schema now adds checksum-verified migration 3 and one runtime table,
SQLite-authoritative immutable publications, generation-pinned snapshots,
recoverable non-secret manifests, strict stable-bundle read-only opens, full
verification, and ordered ancestor rollback. `P2-04` adds read-only version-1
inspection, dry-run reporting, deterministic side-by-side schema-v2 import,
and quarantine without dual-write. `P2-05` adds immutable active sidecars,
manifest/SQLite checksum identity, byte-for-byte SHA-256 verification,
generation-pinned online backup during a concurrent writer generation, atomic
snapshot-folder publication, and fresh-folder restore. `P2-06` adds 16 bounded
keyset repositories over pinned old/new semantic and operational snapshots,
typed artifact/vector payloads, and lifecycle/orphan verification. Command
contracts and the foundation facade are described below. At the Phase-2 head,
live provider execution was unimplemented; the current Phase-3 through Phase-7
application path now owns it.

`P2-07` freezes the closed 40-operation argv grammar, 11 stable exit identities,
bounded typed result records, and `crexx-rag.command-result/1` human, JSON, and
NDJSON rendering. It executes no operation and does not replace the native CLI;
the P2-08 facade consumes this contract.

`P2-08` adds the shared typed dispatcher for doctor, library
init/status/verify/backup/restore/migrate, provider status/configuration-only
test, and profile validation. Its access gates precede mutation, read paths
retain identical database/manifest hashes, backup/restore reuse the pinned
P2-05 path, and all provider diagnostics retain zero outbound calls and zero
credential resolution. That remains the exact Phase-2 evidence boundary. The
current application overrides `provider.test` with an explicitly authorized,
budgeted public-synthetic call and has installed Phase-6 adapters, while
native-v1 remains the default oracle pending a new cutover decision.

`P2-09` publishes workload/capability report version 1 and prepares the
`rxsqlite-candidate`, `rxllm-candidate`, and
`rxvector-portable-candidate` review bundles. The dated evidence retains its 52
files; the maintained SQLite manifest adds the session/thread qualification,
so a current rerun stages 53 role-labelled files outside the source tree with
exact SHA-256 identity. Twelve minimized compiler/VM probe cells remain. Each bundle
retains adjacent use/system docs and metadata that explicitly denies release or
donation-submission status. No hosted call, installed-capability copy, upstream
submission, or CREXX edit occurred.

`P2-10` adds `crexx-rag.plan/1` canonical envelopes and SHA-256 digests to the
shared Level-G facade for ingest, improve, and proposal planning. Planning pins
the published generation and binds the registered config/profile snapshot,
current source-revision fingerprint set, provider route/privacy declarations,
active reservations, required capability, and one-hour expiry without changing
the database, manifest, WAL, or shared-memory fingerprints. Apply checks access
before inspecting the hostile payload, verifies its reviewed digest, strictly
reconstructs the canonical JSON, and re-reads every binding. A valid plan ends
at stable unavailable exit 8 with `enqueued=false`; Phase-3/4 execution has not
been smuggled into the foundation.

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

The later CREXX commit
`1fbd89dc9afb7dbbf2e8e577624a87b1076ff11e` publishes the complete SHA-256
family. The Gate-2 closeout removed the downstream whole-file accumulation,
qualified the complete family in Level G and the bounded incremental
application reader in Level B, and preserved direct installed JSON, HTTP,
vector, and RXPA consumption. Full Debug and fresh Release each pass 69/69;
the coherent Apple-ASan product passes all ten Phase-2 tests and the focused
hash/native package proof. The user accepted Phase 2 and Gate 2 for this macOS
scope. Exact downstream Linux replay remains open; details are in the
[Gate-2 closeout](evidence/2026-08-23-phase2-gate2-closeout/README.md).

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
`P2-10` and Gate 2 are accepted for the current macOS scope; exact downstream
Linux replay remains open. The later sequential authority supersedes the old
Gate-2 stop without changing its historical evidence.

Native-v1 remains the executable oracle. The pulled upstream lineage's
supported Linux sanitizer and HTTP substrate qualification is now green.
CRI-15 remains open for the exact downstream Linux
reproducer/current-package replay. CRI-16 remains a separately approval-gated
provider-lifecycle decision, not a Phase-2 prerequisite.
Donation submission, dual-write, cutover, native-core retirement, push, and
release remain unauthorized.

## Phase 3 Execution

`P3-01` through `P3-09`, Gate 3's reconciler/component scope, and Gate 3R's
end-to-end product scope are accepted for the recorded macOS/Gemini boundary.
The Level-G `ragingest` reconciler and `ragfolder` connector use installed
SHA-256 and the accepted SQLite boundary; no RAG-specific native mechanism was
added. Four optimized/non-optimized dual-VM cells cover initial and incremental
lifecycle semantics. Two additional optimized cells use real `SIGKILL` during
a staging transaction and resume without duplicate sources, revisions or jobs.

The native oracle and cREXX scratch libraries agree on the Scotland-shaped
two-source/five-chunk projection at the matched 512-character/no-overlap policy.
The executable tutorial is checked against exact NDJSON and repeats unchanged
input with zero writes/provider calls. Provider-dependent queued work is
consumed by the Phase-4 worker path; the Phase-3 path itself makes no outbound
call and resolves no credential.
Exact evidence and limitations are in
[`docs/evidence/2026-08-23-phase3/`](evidence/2026-08-23-phase3/README.md).

The user-approved
[`Phase-3 product re-baseline`](evidence/2026-08-24-phase3-product-rebaseline/WORKLIST.md)
retains the reconciler evidence and is now complete. No cutover or native-v1
rename is implied. The enduring linked/native application and its bounded
`crexx-rag.config/1` projection use symbolic `env:GEMINI_API_KEY` with
`gemini-3.5-flash-lite` generation and `gemini-embedding-2` embeddings.

`ragprocess` and migration 3 provide the accepted process framework.
`worker start` uses the public cREXX child-process channel to supervise 1–32
instances of the same linked application. Each process opens its own SQLite
connection and records controller/worker parentage, host, PID, start token,
state, request, and database-clock heartbeat. A separate application process
can list/status the registry, request drain, classify stale heartbeats with a
same-host PID diagnostic, and explicitly prune terminal/stale rows. The
permanent `p3r_01b_process_framework` test passes on `rxvme` and `rxbvm` with
two simultaneous workers, forced termination, and zero provider calls.

Migration 4 adds exact work-input envelopes,
`ragapplicationprovider`, extraction and embedding ownership, public
`worker.run` dispatch as `application-ingestion-v1`, and sanitized stderr
progress. The human native surface now discovers `./crexx-rag.conf`, defaults
to `./library` and the sole configured profile, provides `init`, guided
`ingest`, and short `query` commands, emits concise results, and selects
ANSI/plain progress from its terminal. Machine JSON/NDJSON retains the canonical
operation vocabulary. `p3r_02_gemini_ingestion` proves both surfaces through
two fresh libraries against an exact four-request Gemini loopback, including
safe two-worker reservation allocation, truthful zero-work replay, non-empty
child-failure errors and automatic immutable vector publication. On 2026-08-25
the separately authorized fresh native tutorial made exactly two successful
first-attempt Google calls, completed both items, accepted one supported claim,
stored one 768-dimensional embedding, published one aligned vector generation,
verified with zero issues and repeated unchanged with no job, workers or calls.
That pristine replay plus the complete Phase-3/3R and provider dependency tests
satisfies Gate 3R. The known upstream CREXX `LINEIN()` double-Enter limitation
is accepted for now. Exact Linux, release and cutover remain separate.

## Phase 4 Execution

`P4-01` through `P4-09` are implemented in Level G. `ragclaims` owns canonical
concepts, aliases, explicit ambiguity, directional/time-scoped claims,
independent support, retraction, bounded traversal, immutable provider-neutral
proposals, deterministic validation/review routing, and explainable extraction
ranking. `ragimprove` creates content-addressed trigger plans with exact
item/call/token/cost/time/in-flight/retry ceilings and symbolic secret
references. `ragwork` uses database-clock leases, monotonic fences, attempts,
heartbeats, retry/backoff/dead-letter, cooperative cancellation, pause/resume/
drain, and exact reservation settlement across independent OS processes.

The permanent target passes optimized/non-optimized `rxvme`/`rxbvm` claim and
tutorial cells, real forced termination and lease recovery on both VMs, two
competing worker processes, stale-fence denial, the native-v1 queue oracle, and
exact tutorial NDJSON. Full Debug and fresh Release are 71/71; focused Apple
ASan is clean with unsupported LeakSanitizer explicitly off. Recurring QA uses
a deterministic provider and resolves no credential. The literal supervised
eight-hour run completed 28,800 one-second polls and all four items in its
supervised improvement job, with balanced reservations and exit 0, accepting
Gate 4 for the recorded macOS scope. A separate ingestion job remained queued
and was intentionally outside the soak.

The 2026-08-25 application extension carries that engine onto the enduring
human surface. `crexxrag improve` now shows selected work, provider/privacy and
budget bindings, confirms, queues immutable `crexx-rag.work-input/1` rows,
supervises the configured process count and returns final job status. Routing
uses `role.extractor`, not provider declaration order. Semantic configured-work
identity makes a repeated selected input a pre-job `identical-no-op`. Permanent
Gemini QA and bounded real Codex/Google improvement turns pass; the setup path
uses the installed toolchain and persistent macOS launchd ownership for the
local embedding server. Exact details are in the
[application-extension record](evidence/2026-08-25-phase4-application/README.md).

## Phase 5 Execution

`P5-01` through `P5-08` are implemented in Level G. `ragquery` creates
canonical `crexx-rag.query-plan/1` values with exact phrase/prefix, registered
alias and bounded spelling expansion, time/comparison/relationship intent,
ambiguity and versioned term statistics. `ragembedding` stores only compatible
missing embeddings, resumes partial batches and atomically publishes
checksum-bound exact `.rxvec` generations. `ragretrieval` combines bounded
FTS5, installed packed `rxvector`, directed graph-to-support expansion,
reciprocal-rank fusion and deterministic diversity. `ragevidencejson` emits
bounded `crexx-rag.evidence/1` and `crexx-rag.answer-context/1` projections with
historically resolvable library/source/revision/UTF-8-span citations.

All four optimized/non-optimized `rxvme`/`rxbvm` cells pass the nine frozen
IT/Scotland judgements at 144/144, required recall 17/17 and zero critical
failures. The tutorial output is byte-stable. The typed answer contexts total
69,295 bytes versus 92,385 for current native-v1 MCP responses; the tiny
full-source control is 45,891 bytes and is explicitly not represented as a
context-size win. A separately authorized public-fixture Gemini 3.5 Flash run
used 36 calls and scored typed evidence 143/144 versus control 130/144, with
9/9 passing and zero critical failures. Exact algorithmic evidence is in
[`docs/evidence/2026-08-23-phase5/`](evidence/2026-08-23-phase5/README.md).

The 2026-08-25 application extension connects those algorithms to the
maintained native human surface. `ragqueryprovider` performs configured query
embeddings and Gemini or contained Codex structured answers;
`ragquerypolicy` owns separately tested privacy and budget checks. The active
index must match provider, model, dimension and exact input envelope. Answer
output must match the exact two-field schema and every citation must already
exist in the supplied typed context. Permanent native/dual-VM evidence plus
bounded clean Codex/local and Google runs are recorded in
[`docs/evidence/2026-08-25-phase5-application/`](evidence/2026-08-25-phase5-application/README.md).

The Phase-6 application extension carries the same durable `crexxrag` name and
local defaults into `crexxrag serve mcp`, adds atomic text-config binding to
`ADDRESS RAG`, enforces MCP argument schemas at runtime, and corrects
provider-capable query annotations. A native deterministic Gemini vertical
slice and the optimized/non-optimized dual-VM surface matrix cover the change;
the retained evidence is
[`docs/evidence/2026-08-25-phase6-application/`](evidence/2026-08-25-phase6-application/README.md).
