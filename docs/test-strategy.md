# cREXX-Only Test Strategy

Status: living acceptance policy for the approved programme, 2026-08-03.

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
- New maintained test, fixture, benchmark, and analysis logic should be cREXX
  Level B where practical. CMake/CTest may orchestrate it; shell remains thin.
- Generic native-plugin tests contain no RAG nouns or product schema.
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

`P1-RXPA-03`, `P1-HASH-01`, hosted calls outside the explicitly authorized
low-cost `P1-LLM-04` qualification, normal-prefix/CREXX changes, production
schema, dual-write, and later phases are outside the acceptance scope. Gate 1B
is an unconditional stop even when every approved test passes.

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

Use small target-only loops between those broad gates. Record an explicit reason
for any unavailable CREXX VM or local-provider mode. Finish with a worktree audit
showing all pre-existing user changes and every sister-repository file were
preserved.
