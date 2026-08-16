# cREXX-Only Test Strategy

Status: living acceptance policy for the approved programme, 2026-08-06.

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
  documentation sections.
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
| SQLite | Typed null/integer/real/Unicode text/blob, values beyond old buffers, cursor paging, rollback, FTS5, stale handles, and forced cleanup |
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
- generic SQLite correctness, read-only, concurrency, backup, and forced-error
  cleanup matrices;
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
VMs cover all 32 schema-v2 logical tables, migration-record 1-to-2 upgrade,
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
through P2-10. Gate 2 remains an unconditional stop even when every approved
test passes.

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
them. The provider section does not accept the CRI-15-affected Linux timeout path or
claim connection reuse, streaming, cancellation, compression, or bounded
response buffering from installed `rxhttp`; CRI-16 tracks that ceiling.
`P1-VEC-01` accepts canonical headerless `f32le-v1` bytes, application-owned
codec/count/meaning, and an exact 768-dimensional typed SQLite round trip in
all four compiler/runtime cells. `P1-VEC-02` accepts exact bounded-page
ordering and ties for 11,684-by-768; `P1-VEC-03` retains separate SQLite,
decode/validation, arithmetic, selection, working-memory, process-RSS, and
total measurements on both VMs. `P1-VEC-04` retains exact cREXX as the bounded
fallback and recommends separately authorized generic `rxvector`
qualification; no accelerator is implemented or selected without a matched
benchmark.

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

Use small target-only loops between those broad gates. Record an explicit reason
for any unavailable CREXX VM or local-provider mode. Finish with a worktree audit
showing all pre-existing user changes and every sister-repository file were
preserved.
