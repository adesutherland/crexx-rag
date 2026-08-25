# cREXX-Only Test Strategy

Status: living acceptance policy for the approved programme, 2026-08-24.

The detailed item matrix and decision gates are in the
[implementation roadmap](crexx-only-implementation-roadmap.md). The former
native-v1 test strategy is [archived](archive/native-v1/test-strategy.md) and is
an oracle input, not the target acceptance model.

## Test Principles

- Test semantic records, citations, lifecycle effects, and failure behavior;
  do not bless volatile row ids or incidental JSON formatting.
- Keep the native-v1 path unchanged as a comparison oracle. Known defects are
  negative fixtures, not desired parity.
- Use redistributable generic IT and Scotland-shaped fixtures. Never commit
  copyrighted corpus material, credentials, or private content.
- Every benchmark result records the exact commit/dirty state, installed
  toolchain, VM, build type, hardware, fixture hash, provider/model, command,
  raw output, and measurement component.
- Run comparisons in the same session and separate SQLite, cREXX algorithm,
  provider wait, JSON/record/codec, vector transfer/decode/compute/selection,
  and memory costs.
- New maintained application, advanced-library, test, fixture, benchmark, and
  analysis logic must be cREXX Level G. Level B is allowed only for CREXX
  bootstrap/foundation code or a documented low-level capability that Level G
  cannot express. CMake/CTest may orchestrate it; shell remains thin.
- `crexx_language_level_audit` rejects Level B in maintained Phase-1B code and
  checks that the current policy is present in the authoritative documents.
- Generic native-plugin tests contain no RAG nouns or product schema.
- Every implemented donation candidate is classified in `incubator/README.md`
  and keeps use `README.md` plus system `SYSTEM.md` beside its source. The
  `donation_docs_audit` CTest enforces the current candidate set and required
  documentation sections plus explicitly non-released `PACKAGE.toml` and
  role-labelled `BUNDLE.tsv` manifests. `p2_09_donation_bundles` stages and
  hashes every review bundle outside the source tree and runs its minimized
  Level-G probes across optimized/non-optimized x both VMs.
- Local and hosted providers share one target contract. Phase 0 makes no hosted
  call and uses no hosted credential. For P1A-LLM-01 only, the user's later
  instruction explicitly authorizes a Google/Gemini generation and embedding
  canary using `GEMINI_API_KEY`; deterministic success/failure coverage remains
  loopback-only and the key is never logged or retained.

## Phase 0 Acceptance

Gate 0 requires all of the following to be reproducible:

1. Clean current-oracle configure, build, and CTest results with exact counts
   and skips.
2. Hashed generic IT and sanitized Scotland-shaped fixtures covering exact
   keywords/keyphrases, aliases, semantic paraphrase, ambiguity, chronology,
   multiple support, stance, deletion, and directed graph paths.
3. Golden chunking, census, adjudication, graph seeding, extraction ranking,
   queue, deletion, lexical/vector/graph retrieval, and evidence-packet outputs.
4. Explicit demonstrations of same-URI chunk-id churn, stale support after
   source change/deletion, unsafe queue crash boundaries, and fixed-buffer
   whole-result JSON materialization.
5. Scotland and held-out IT judgement sets for passage relevance, keyword/alias
   expansion, claim support/stance/time, graph leads, citation entailment,
   ambiguity/conflict, and expected gaps.
6. Raw same-session benchmark results and a fixed/blinded answer-evaluation
   protocol with predeclared quality, context-cost, latency, and memory metrics.

An incomplete or non-reproducible item fails Gate 0 and prevents Phase 1A.

## Phase 1A Acceptance

Each bounded slice needs target-only CTest coverage and retained raw evidence:

| Slice | Minimum proof |
| --- | --- |
| SDK | Scratch-installed package supplies headers, imported targets and helper; independent plugin builds with both fallbacks off; valid and structured-invalid signatures run in both modes/VMs |
| SQLite | Typed null/integer/real/Unicode text/blob, values beyond old buffers, cursor paging, rollback, FTS5, stale handles, forced cleanup, RXPA V2 session isolation, serialized connections, and concurrent diagnostics |
| Data | Production parse-once Unicode/missing/null/empty/array/object behavior and paged typed records; explicit owning headerless `f32le`/`i64le` projections; application-owned type/count; optimized/`-n` correctness and same-session benchmarks on both VMs |
| Provider | Credential-free deterministic loopback generation, structured validation, ordered batch embedding, retry/error/usage, route denial, capability reporting, and provider-specific shapes on both VMs; separately authorized hosted canaries remain non-repeatable evidence |
| Vector | Raw float32 round-trip with schema-owned count/meaning, deterministic cosine/top-k ordering/ties, and separate transfer/decode/compute/selection/memory results on both supported VMs |
| Algorithm | First ingest, exact no-op, one-paragraph edit/reuse, support promotion/retraction, FTS, citation, and evidence packet |
| Job | Atomic claim, DB-issued fence, forced termination before/after promotion, stale-worker rejection, and idempotent recovery |
| Surfaces | Imported typed record returned through Level G; semantic equality through CLI JSON, `ADDRESS RAG`, and MCP `structuredContent`; external contract generated as `crexx.operation-contract/1` with the installed helper |

Gate 1A also requires a boundary decision packet that states rejected
alternatives, surface weaknesses, donation candidates, unresolved risks, and
exact Phase-1B choices. Passing PoCs are not production acceptance.

All Phase-1A slice prerequisites and the approved Apple CREXX-candidate replay
have retained focused passes. The failed first Gemini attempt remains negative
diagnostic evidence; it is not an `rxhttp` defect and no hosted call belongs in
the repeatable replay. That refreshed Apple suite passed 28/28 with zero
failures and zero skips. Fresh Linux validation builds Debug and Release and
passes the portable process-metrics tests, but currently fails the deterministic
provider timeout case because of the separately reproduced installed-CREXX
CRI-15 socket status defect. On 2026-08-03 the user accepted D1-D8 and the
bounded D9 Phase-1B worklist. CRI-15 remains separate negative evidence and
prevents a Linux provider-timeout qualification claim until fixed or separately
dispositioned.

## Phase 1B Acceptance

Every approved Phase-1B roadmap item needs its own target and CTest label,
retained entry/exit evidence, and a target-only development loop. The complete
slice must retain:

- installed-SDK external-consumer and compatibility diagnostics;
- generic SQLite correctness, read-only, concurrency, backup, forced-error
  cleanup, and maintained four-session thread qualification;
- JSON/typed-record correctness and representative same-session comparisons;
- deterministic synthetic and available local-provider contract results with
  zero denied outbound requests and secret-free evidence;
- the 11,684-by-768 vector transfer/compute/memory breakdown and exact ordering;
- scratch-schema algorithm parity and zero-write/retraction evidence; and
- fenced-worker crash recovery, cancellation, ceilings, reservations, and
  bounded-overrun results.

The completed worker slice uses four optimized/non-optimized and `rxvme`/
`rxbvm` cells. It includes real process termination before a provider call,
after a provider call, during an open promotion transaction, and after commit;
the budget slice retains distinct zero-write denial statuses and actual usage.

The dated Gate-1B results preserve the language-level boundary they originally
qualified. After acceptance, all maintained Phase-1B cREXX sources were migrated
to Level G under G1B-D6; the same optimized/non-optimized and dual-VM tests now
guard the Level-G implementation without rewriting the retained evidence.

## Phase 2 Acceptance To Date

`P2-01` freezes the Level G application object boundary through a compiled
consumer rather than documentation alone. CTest `p2_01_application_contract`
compiles `ragmodel`, `ragevidence`, `ragjob`, `raglibrary`, and the consumer in
optimized and non-optimized modes, then runs on `rxvme` and `rxbvm`. The fixture
must exercise the complete method vocabulary, nominal pages and records,
interface-valued library/job handles, directional independently cited claims,
ambiguity, graph-lead limitations, gaps, trace, and truthful package limits.

The accepted 2026-08-04 run passed all four cells and the full suite passed
58/59 in 527.97 seconds with only the unchanged CRI-15 failure. This does not
accept persistence, plan validation, commands, or provider execution assigned
to later Phase-2 items.

`P2-02` freezes typed configuration/profile/registry consumption through
`p2_02_config_contract`. It compiles optimized/non-optimized and runs both VMs;
valid selection plus negative cases cover arbitrary paths, unknown ids,
duplicate registration, invalid provider/profile/inverse references, symbolic
secret handling, redacted diagnostics, worker scope, and bounds-safe snapshot
inspection. Static imports and runtime worktree checks prove loading performs
zero provider, source, or library activity. The final focused run passed in
18.85 seconds at 134,736 KiB maximum process RSS; the full suite passed 59/60
in 607.33 seconds with only CRI-15. This does not accept durable configuration
snapshots, persistence, command parsing, or provider execution.

`P2-03` accepts the Level-G storage foundation through
`p2_03_storage_foundation`. Before compilation, CMake recomputes the SHA-256 of
each ordered migration's exact DDL. Optimized/non-optimized consumers on both
VMs cover the 32 accepted schema-v2 semantic tables, the schema-v3 runtime
registry, schema-v4 work-input column and schema-v5 provider recovery/budget
columns; migration-record upgrade and
all current checksums,
idempotent reapply with no row changes, downgrade/checksum denial,
transactional failed DDL, generation immutability, old/new reader snapshots,
visibility, manifest lag/recovery, full verification, ancestor rollback,
complete stable-bundle zero-write read-only opens, and missing-path denial.

The optimized crash proof starts child VMs and sends real `SIGKILL` before
SQLite commit, after SQLite commit, and after temporary-manifest write. Each
case proves the SQLite generation and manifest state through a separate
read-only process before authorized recovery. Crash-left `-shm` coordination
is transient and excluded; database, WAL, final/temporary manifests, and every
other bundle artifact are hashed before and after inspection. The final
measured focused target passed in 31.92 seconds at 180,672 KiB maximum RSS;
the final full Debug suite passed 60/61 in 553.13 seconds with only CRI-15.

`P1-RXPA-03`, `P1-HASH-01`, hosted calls outside the explicitly authorized
low-cost `P1-LLM-04` qualification, normal-prefix/CREXX changes, dual-write,
and later phases are outside the acceptance scope. P2-03 does not imply P2-04
through P2-10. Gate 2 remained an unconditional stop until the user's
2026-08-23 macOS acceptance decision. The later sequential Phase-3-plus
authority supersedes that stop without rewriting its dated evidence.

`P2-04` adds `p2_04_v1_compatibility`: optimized/non-optimized builds on both
VMs inspect and import a representative version-1 bundle, fingerprint every
source file across dry-run/import/rejection, verify deterministic schema-v2
mapping and quarantine, and reject target overwrite and unsupported manifests.

`P2-05` adds `p2_05_backup_restore`: all four cells exercise opaque binary file
I/O, fixed-memory immutable incremental `rxhash` state, and direct public file
raw/hex equivalence, plus immutable sidecar publication and checksum
tamper detection, a generation-2 SQLite backup held stable while generation 3
commits, regenerated snapshot manifests, fresh restore, and source-snapshot
zero-write fingerprints. Optimized `rxvme` and `rxbvm` receive real `SIGKILL`
after sidecar preparation/install/SQLite commit/temporary manifest and after
backup or restore database/sidecar/manifest staging. No partial final folder is
visible at any pre-publication boundary.

`P2-06` adds `p2_06_repositories`: 16 fixed repository names are paged one row
at a time through bound opaque keyset cursors in all four compiler/runtime
cells. A generation-2 read transaction continues to see the exact old semantic
and operational rows while its already-open WAL writer publishes generation 3;
a fresh snapshot sees the replacement rows and later job/review activity.
Artifact and embedding BLOBs cross the typed record boundary byte-exactly.
Invalid repository names, page limits, oversized cursors, and closed snapshots
are denied. Repository verification covers visible parent/end-point/support/
embedding membership, generation publication, FTS equality, job/item/attempt
lifecycle, review decisions, and a deliberately injected cross-source current
revision plus invalid job state.

`P2-07` adds `p2_07_command_contract`: all four compiler/runtime cells parse the
closed 40-operation vocabulary and representative global/access/command option
forms without executing an operation. Negative cases cover unknown operations
and globals, invalid format/access/registered ids, duplicate globals, missing
explicit library targets, late globals, and the positional `--` boundary. The
11 exit identities and `crexx-rag.command-result/1` schema are exact. JSON and
NDJSON are parsed back and compared for typed semantic values; human lines
retain status/exit identity while removing embedded control-line breaks.
Invalid typed values, duplicate fields, status/exit disagreement, more than 100
records, and unknown formats are rejected. CMake fingerprints every source
input before and after the four cells.

`P2-08` adds `p2_08_foundation_facade`: four cells dispatch doctor, six library
operations, provider status/configuration-only test, and profile validation.
They prove access-before-mutation, read-only status/verification fingerprints,
idempotent current-schema migration, registered non-secret config snapshots,
pinned backup/fresh restore, and zero provider calls or credential resolution.

`P2-09` originally added three explicitly non-released review bundles with 52
role-labelled, hash-identical files. The maintained SQLite bundle now adds its
session/thread test, so current staging contains 53 files while the dated
P2-09 evidence remains an exact 52-file record. Twelve optimized/non-optimized
and dual-VM probe cells cover typed SQLite,
provider route denial without transport, and portable vector codec/search.

`P2-10` adds `p2_10_plan_revalidation`: all four compiler/runtime cells create
the ingest, improve, and proposal `crexx-rag.plan/1` forms, verify zero changes
to database/manifest/WAL/shared-memory fingerprints, and require the operation
capability before hostile input inspection. Digest, canonical encoding, exact
one-hour expiry, generation, config/profile, visible source-revision,
provider-route/privacy, and active-reservation bindings are independently
revalidated. Valid input reaches a typed `revalidated` record but remains
`enqueued=false` with unavailable exit 8 because later execution phases are not
authorized.

Current Phase-1B progress: the installed-SDK section is accepted under
`P1-RXPA-01` and `P1-RXPA-02`. `P1-SQL-01` through `P1-SQL-07` pass their
dedicated targets and exact CTest labels for optimized/non-optimized programs
on both VMs. The retained SQLite evidence covers ownership, typed and large
values, transactions/capabilities, read-only zero-write, separate-process WAL
concurrency, online backup/integrity/forced cleanup, and the optional
output-asserting address facade. `P1-JSON-01`, `P1-JSON-02`, and `P1-REC-01`
accept the installed parse-once JSON and nominal application-record boundary.
`P1-LLM-01`, the available deterministic local OpenAI-compatible case in
`P1-LLM-02`, bounded provider hardening in `P1-LLM-03`, multi-provider
qualification in `P1-LLM-04`, and privacy controls in `P1-LLM-05` are accepted.
P1-LLM-03 counts attempts and connections, validates the
documented JSON Schema subset, and proves route denial before client
construction. P1-LLM-04 keeps recurring CTest deterministic and places the
authorized five-call hosted canary behind a separate target. P1-LLM-05 observes
zero denied connections and scans real credential values without retaining
them. The historical provider acceptance did not accept the CRI-15-affected
Linux timeout path or the then-installed `rxhttp` ceiling. Current `main` now
uses installed Level-G HTTP/socket foundations with one bounded synchronous
connection per attempt; the focused macOS provider matrix passes.
Exact downstream Linux confirmation remains open, and the provider contract
truthfully continues to report cross-operation reuse, streaming and
cancellation as unsupported pending separate lifecycle/capability decisions.
`P1-VEC-01` accepts canonical headerless `f32le-v1` bytes, application-owned
codec/count/meaning, and an exact 768-dimensional typed SQLite round trip in
all four compiler/runtime cells. `P1-VEC-02` accepts exact bounded-page
ordering and ties for 11,684-by-768; `P1-VEC-03` retains separate SQLite,
decode/validation, arithmetic, selection, working-memory, process-RSS, and
total measurements on both VMs. `P1-VEC-04` retains exact cREXX as the bounded
fallback and recommends separately authorized generic `rxvector`
qualification; no accelerator is implemented or selected without a matched
benchmark.

## Phase 3 Reconciler Component Acceptance

CTest `phase3_ingestion` is the permanent Gate-3 proof. It compiles the schema,
Level-B bounded file boundary, Level-G store/repositories/reconciler/folder
connector, three scenarios, and executable tutorial with and without
optimization. Every compiled shape runs on `rxvme` and `rxbvm`.

The matrix covers raw/revision SHA-256, MIME/encoding, CRLF and Unicode byte
span maps, invalid UTF-8 rejection, three format-aware chunkers, occurrence and
content identity, immutable generation-bound plans, exact counters, append,
middle edit, reorder, mapped/unmapped rename, duplicates, deletion,
metadata-only revisioning, parser invalidation, candidate census/representative
decisions, term/source-diversity fingerprints, FTS, job idempotency, embedding
reuse, support re-anchor/retract, stale-plan zero writes, and final repository
verification.

The optimized `rxvme` and `rxbvm` cases are killed with real `SIGKILL` after a
partial staging write. A separate process verifies transaction rollback and
resumes the same desired source to exactly one source, revision, job and zero
duplicate rows. The generic Phase-0 oracle capture must remain green. At the
matched Scotland-shaped 512-character/no-overlap policy, native-v1 and cREXX
must both project two sources and five chunks; candidate row ids are not
compared. The exact tutorial NDJSON is checked independently.

All recurring Phase-3 QA is credential-free and zero-outbound. Component tests
assert zero provider calls; product tests use only deterministic local protocol
fixtures. Hosted extraction/generation and local-model qualifications remain
separate, bounded runs with explicit call/token/cost/privacy or subscription-
allowance budgets. Credential values must never enter CTest output or retained
evidence.

The 2026-08-24 product re-baseline keeps this complete matrix as permanent
component regression evidence but no longer treats it as the end-to-end product
gate.

`p3r_01a_config_file` is the permanent four-cell contract for the bounded
human text projection and linked application. `phase6_surfaces` proves that MCP
fixes the selected file at startup. Both are zero-outbound and reject literal
credentials.

`p3r_01b_process_framework` runs the linked application on both concrete VMs.
Each cell creates a fresh schema-v5 library, starts one controller plus two
actual worker processes through the public child-process channel, and observes
the live rows from a separate application process. It then proves durable
drain, clean terminal state, forced-process termination, database-clock stale
classification, same-host missing-PID diagnostics, and explicit terminal/stale
pruning. The test is bounded and zero-outbound; it remains the process-control
proof independent of provider/ingestion processor behavior.

## Gate 3R Product Ingestion Acceptance

The authoritative sequence and assertions are in the
[`Gate-3R acceptance contract`](evidence/2026-08-24-phase3-product-rebaseline/ACCEPTANCE-CONTRACT.md).
Gate 3R and its provider portability addendum are accepted for the recorded
macOS scope. Recurring CTest must
build the linked installed cREXX application without a source fallback and
exercise the product CLI through the configured Gemini path. The reusable
provider matrix separately covers deterministic local OpenAI-compatible,
OpenAI, Anthropic, and Gemini protocol shapes; repeating every generic adapter
as a product ingestion route is not a Phase 3 requirement. Together they must
cover exact work-input binding, both claim-extraction and embedding item
ownership, candidate-to-concept promotion, proposal validation, worker
dispatch, job/reservation reconciliation, query-visible support, no-op replay,
changed-source invalidation, restart idempotency, privacy denial, and secret
absence.

The final gate also requires a separate non-recurring, explicitly budgeted real
Google Gemini run over public synthetic material. A direct provider probe,
source-level scenario, phase tutorial, pre-seeded graph, deterministic fixture,
or native-v1 command cannot satisfy that gate. The live result records only
symbolic credential reference, hashes, provider/model/request identity, usage,
cost, latency, normalized result, final counts, and stable citation.

`p3r_02_gemini_ingestion` is the permanent native-product processor and human
surface slice. A deterministic Gemini loopback accepts two equivalent fresh
ingestions: four requests in total, one structured generation and one embedding
per library. The test proves schema-v5 work-input binding, public `worker.run`
dispatch, safe concurrent reservations, configured two-process supervision,
candidate promotion, proposal validation, stored 768-dimensional embeddings,
automatic exact vector publication, completed jobs, truthful zero-job replay,
meaningful pre- and post-registration child-process errors, sanitized stderr
progress, stable JSON stdout,
automatic local config/library/profile defaults, guided human plan/apply,
concise evidence and credential-value absence without hosted traffic. The
canonical library also requires clean verification.

P3R-07 completed the same public vertical path on a fresh tutorial library with
exactly two approved first-attempt real Gemini calls. It completed both items,
accepted the source-supported claim, stored the embedding, published the vector
generation, reconciled reservations, verified with zero issues, and repeated
unchanged without a job or calls. The earlier recovered run remains defect
history; the 2026-08-25 replay is the pristine gate evidence.

`p3r_03_provider_durability` runs optimized and non-optimized on both VMs. It
proves that a persisted completed Codex output is reused, exactly one
subscription turn is charged, stale reservations are released, and the worker
fence advances. `p3r_04_codex_protocol` drives initialize, managed-account and
rate-limit reads, schema-constrained turn events, token usage and thread cleanup
through a deterministic App Server JSONL fixture in the same four cells.

The addendum's bounded live qualification used public synthetic material only.
One clean `crexxrag` walkthrough completed one Codex structured extraction
through the user's managed ChatGPT account and one 768-dimensional local Nomic
embedding through llama.cpp. A separate clean walkthrough completed one real
Gemini structured extraction and one `gemini-embedding-2` request. Both
published one vector generation, returned the cited typed claim, verified
cleanly and repeated unchanged without further provider calls. The exact
[closure record](evidence/2026-08-25-phase3-provider-addendum/README.md) also
records the successful full 82-test wall. These hosted runs are evidence, never
ordinary CTest.

## Phase 4 Acceptance

CTest `phase4_improvement` is the permanent bounded Gate-4 regression. It compiles the
Level-G claim, improvement, and worker modules plus two scenarios and the
executable tutorial with and without optimization. Claim and tutorial shapes
run on both `rxvme` and `rxbvm`.

The claim matrix covers canonical concepts and aliases, explicit ambiguity,
direction, qualification and effective time, support/contradiction,
assertion/quotation/report/negation/speculation, attribution, independent
lineage, support strengthening/retraction, no-op replay, bounded traversal,
every extraction-rank component, provider-neutral proposals, confidence,
endpoint/type/evidence validation, canonical overwrite, conflict, unresolved,
ambiguity and external review routes, explicit improvement triggers, exact
resource ceilings, symbolic secrets, stale plans, and zero-write reapply.

The optimized worker cases use real forced process termination after a
database-clock claim, lease expiry, two simultaneous OS-process workers,
recovery, and a fabricated late heartbeat at the old fence. They also cover
pause/resume/drain, bounded status, cooperative cancellation, retry/backoff,
dead letter, immutable budget policy, per-call and aggregate reservation
accounting, exact settlement, and denial of a third call at a two-call
in-flight ceiling. The final assertion requires one active graph support
despite at-least-once provider attempts.

Both VMs also run a two-poll `runworkerfollow` soak smoke. The literal
overnight record uses the same compiled mode under a temporary operator-owned
macOS supervisor with 28,800 one-second idle polls; the short permanent cell
proves invocation and clean completion without making ordinary CTest take
eight hours.

The target also runs the unchanged native-v1 work-queue consumer oracle and
compares the seven tutorial NDJSON records exactly in all four compiler/VM
cells. Recurring QA uses a deterministic provider and no hosted connection.
Plans contain only symbolic references such as `env:OPENAI_API_KEY`. Hosted
Phase-7 qualifications are secret-gated and must declare provider, model,
calls, tokens, cost, privacy and retained evidence before resolving a value.
The separate roadmap requirement for a literal supervised overnight worker is
a time-based acceptance record and cannot be replaced by this bounded target;
that record was therefore required in addition to the permanent test.

The literal macOS worker run subsequently completed 28,800 one-second polls,
processed all four items in its supervised improvement job, left that job with
no queued/running work or reservation, and exited zero. A separate ingestion
job remained queued and outside this soak's scope. Together with the retained
focused, full Debug/Release and
Apple-ASan results, this accepts Gate 4 for the recorded macOS scope. Exact
downstream Linux remains open.

The Phase-4 application extension adds `p4r_01_gemini_improvement`. A native
human workflow first ingests through the deterministic Gemini protocol fixture,
then previews and runs `crexxrag improve` through the configured extractor
role. The fixture requires exactly one improvement request, a completed
one-item durable job, concise non-JSON human output, no irrelevant vector state,
clean library verification and a zero-write/zero-worker/zero-call replay.
`phase4_improvement` now also persists configured work envelopes in its
dual-compiler/dual-VM process cases. Bounded real Codex and Google checks remain
explicit qualification evidence rather than credential-dependent CTest.

## Phase 5 Acceptance

CTest `phase5_retrieval` is the permanent deterministic Gate-5 proof. It
compiles query planning, embedding/index publication, hybrid retrieval,
evidence encoding, the scenario and executable tutorial with and without
optimization, then runs them on `rxvme` and `rxbvm`.

The matrix covers exact phrase and prefix behavior, profile/database aliases,
bounded edit-distance spelling, comparison/time/relationship intent, versioned
term statistics, FTS5 and adjacent context, privacy denial before a provider
call, incremental/reused/resumed embeddings, immutable profile and dimension
identity, atomic `.rxvec` generations, installed packed `rxvector`, explicit
lexical fallback, directed graph-to-support traversal, inspectable reciprocal-
rank fusion/diversity, stable historical citations, accepted support and
contradiction, stance/attribution/time, ambiguity/conflict, graph leads, gaps,
byte ceilings and exact tutorial NDJSON.

Nine frozen IT/Scotland questions are judged after two independent scorer
resets. Acceptance requires 9/9 cases, 144/144 deterministic points, 17/17
required-recall checks and zero critical failures in all four cells. The same
run captures current native-v1 MCP output and controlled full-source byte
counts without treating a tiny untyped corpus as a universal baseline win.

Hosted answer quality is an explicit non-recurring qualification. The harness
requires confirmation that all fixtures may leave the host, accepts only an
environment credential, records the symbolic reference, uses fixed schemas,
temperature/model/attempt/token limits, blind ordering and the declared
two-scorer/adjudication rule. Credential values, headers and environment dumps
must never be retained. A hosted quality pass does not substitute for the
cREXX provider/application path. Phase 7 owns the broader hosted transport and
cutover comparison boundary; the application extension therefore keeps its
own bounded real-provider walkthroughs.

The Phase-5 application extension adds two recurring layers. CTest
`p5r_01_gemini_query` runs native `crexxrag` over a strict Gemini protocol
fixture and proves ingestion, compatible query embedding, hybrid retrieval, a
concise cited answer, clean human/JSON separation and library integrity. It
also proves a zero-request lexical query, visible auto fallback, no silent
fallback for required hybrid, and rejection of unknown, duplicate, omitted and
extra-schema citations. CTest `p5r_02_query_policy` runs optimized and
non-optimized on `rxvme` and `rxbvm`; it independently covers local/hosted
privacy, maximum calls, Codex turns, input tokens, output tokens, monetary
cost, unavailable monetary usage and aggregate post-call ceilings. Existing
`p3r_02_gemini_ingestion`, `p1_llm_04` and `phase5_retrieval` remain focused
regressions. Real Codex/local and Google checks are bounded qualification
evidence, never credential-dependent CTest.

## Phase 6 Acceptance

CTest `phase6_surfaces` is the permanent Gate-6 proof. It compiles the shared
Level-G `ragproduct` dispatcher, CLI, ADDRESS RAG environment, MCP server, and
surface scenarios with and without optimization, then runs the behavioral
matrix on both `rxvme` and `rxbvm`.

Each fresh product cell proves exact reviewed ingest, stable evidence queries,
zero-write ingest/improve/proposal planning, denied mutation without the named
capability, a machine-readable one-release deprecation alias, pinned backup and
fresh-target restore, and semantic equality across CLI, ADDRESS RAG, and MCP
`structuredContent`. The MCP server advertises only capability-authorized
tools, never raw SQL or graph mutation. It also rejects unknown, duplicate and
wrongly typed arguments, checks provider-call annotations, and proves failed
ADDRESS config opens are atomic. Four narrow skill manifests are parsed and
checked against the versioned skill-manifest schema.

CTest `p6r_01_native_surfaces` is the focused application proof. A native
`crexxrag` instance initializes and ingests with two Gemini loopback workers,
then its built-in `serve mcp` route returns a citation-validated structured
answer, an explicit lexical zero-call packet, truthful annotations, and a
strict unknown-argument error. It checks the synthetic credential is absent
from output and verifies the final library.

The install proof stages application/provider sources, the downstream SQLite
boundary, tutorial fixtures, skills, and compile helper under a scratch prefix.
That helper compiles optimized and non-optimized external consumers from the
installed package with no source-tree fallback. Native-v1 remains installed as
an oracle; Gate 6 does not authorize cutover. Public worker-provider lifetime
and embedding-item execution are explicit Gate-7 limits.

## Phase 7 Acceptance

The `phase7_qualification` target depends on the permanent Phase 3–6 targets
and `phase7_provider_smoke`,
then audits the versioned P7-01 through P7-08 evidence and exact cutover
decision. It is credential-free and therefore repeatable in ordinary CTest.

CTest `p7r_01_provider_smoke` exercises the native application rather than an
external provider harness. Deterministic Gemini loopbacks cover the guided
human command (generation plus embedding), canonical JSON (one selected
embedding provider), and MCP (advertisement, required argument, annotations
and generation). The test requires exact answer/citation and 768-dimensional
vector validation, proves configured zero-call denial occurs before outbound
work, rejects aggregate guided-command usage above the reviewed ceiling, and
rejects synthetic credential disclosure. Phase-6 four-cell MCP coverage also
checks the new diagnose tool and annotations.

The historical explicit non-CTest `phase7_hosted` target requires only
`env:OPENAI_API_KEY`. Its external harness performed one structured generation
and one two-input 128-dimensional batch embedding, for a two-call ceiling and
one attempt per call. It retains usage/status metadata but no request/response
bodies, headers, or credential values. The retained
`phase7_crexx_hosted_probe` records the decision-head response-completion
failure; subsequent installed-CREXX and product-path evidence closes that
macOS implementation finding. Current real hosted acceptance uses native
`crexxrag provider test` and the Phase-3 through Phase-5 end-to-end walks, with
Google always included when a hosted credential is available.

Gate 7 selects reject/defer cutover. Later application evidence closes hosted
completion, public provider dispatch, embedding drain and direct reachability
testing for the recorded macOS scope. Several production-shaped same-session
measurements, exact downstream Linux and a new explicit cutover decision remain
absent. Native-v1 therefore remains the default oracle.

## Phase 8 Opportunity-Report Acceptance

CTest `phase8_opportunity_report` is a permanent documentation and metadata
audit, not a product execution gate and not a tutorial. It requires the
maintained opportunity report, historical evidence and current reconciliation,
checks all three existing
candidate bundles retain `review-bundle-not-approved` plus
`donation_submission_authorized = false`, distinguishes locally owned
candidates from installed CREXX adoptions, and rejects any Phase-8 tutorial.

The current audit also rejects superseded hosted-completion and public-worker
blocker text, requires the macOS provider/worker closures and remaining
lifetime/consumer/Linux boundaries, and proves that no `report` noun was added
to the application command vocabulary. That negative runtime check is
intentional: repository ownership and release authority must not be compiled
into an evidence-library operation.

The test also requires the exact Gate-7/default-oracle and Gate-8-negative
boundaries. Passing it proves the opportunity ledger is coherent; it does not
submit a donation, coordinate upstream, approve cutover, start a compatibility
window, retire native code, publish a release, or close exact Linux QA.

## Required Commands

At Phase-1B entry and Gate 1B:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
cmake --preset release
cmake --build --preset release
git diff --check
```

The final 2026-08-03 Gate-1B run passed 55/56 tests in 490.18 seconds. The only
failure was the separately retained CRI-15 `rxvme` receive-timeout defect. All
28 Phase-1B-labelled tests passed, Release built, the diff check was empty, and
the three-value credential scan found zero publication-file matches.

The 2026-08-23 current-head integration replay is the current compatibility
result: a fresh installed CREXX package from
`e3d6b7b9015847d247ab2b90e83c843881db9b2f`, with both fallbacks disabled,
passed the 27-step downstream build and 62/62 CTests in 97.99 seconds on macOS.
It does not replace the required exact downstream Linux CRI-15 replay or
authorize provider-interface changes.

The Gate-2 closeout adds `P1-HASH-01` coverage of all eight public SHA-256
procedures in optimized/non-optimized Level G on both VMs, including empty
updates, immutable/interleaved states, repeat finalization, binary input, and
file hashing. The same installed consumer is packaged and run with
`crexx -native`; `P2-05` independently proves the Level-B bounded-reader use and
public file equivalence for embedded-NUL/invalid-UTF-8 bytes.

The final current-worktree macOS result is 69/69 in ordinary Debug (98.58
seconds) and 69/69 from a fresh Release build (103.26 seconds), both against a
scratch-installed package with source fallbacks disabled. A coherent
all-instrumented installed CREXX Apple-ASan product plus downstream ASan build
passes 10/10 Phase-2 tests in 147.31 seconds and the focused hash/native package
test in 6.71 seconds. Apple LeakSanitizer is unsupported and is not claimed.
Exact downstream Linux replay remains separate.

Use small target-only loops between those broad gates. Record an explicit reason
for any unavailable CREXX VM or local-provider mode. Finish with a worktree audit
showing all pre-existing user changes and every sister-repository file were
preserved.
