# cREXX-Only Implementation Roadmap

Status: Gate 1B reached on 2026-08-03 and accepted on 2026-08-04. All bounded
Phase-1B items are complete. Phase 2 started on 2026-08-04 from the pushed
entry baseline in `docs/evidence/2026-08-04-phase2/`; `P2-01` through `P2-10`
and Gate 2 are accepted for the current macOS scope. Phase 3 and Gate 3 are
accepted for the recorded macOS scope; exact downstream Linux replay remains
open and Phase 4 is next. The authority is recorded in
the [Gate-1B ledger](gate1b-decision-ledger.md) and
[Gate-2 closeout](evidence/2026-08-23-phase2-gate2-closeout/README.md).

This is the execution plan for the target in
[`crexx-only-vision-and-specification.md`](crexx-only-vision-and-specification.md)
and [`crexx-only-architecture.md`](crexx-only-architecture.md). It deliberately
uses proof points and approval gates rather than authorizing a big-bang rewrite.

## How To Use This Worklist

- `[ ]` means not started, `[~]` means active, and `[x]` means accepted.
- Update evidence links and exact test/benchmark results before changing an item
  to accepted.
- Complete work as small, independently reviewable changes. Commit only when
  separately requested.
- Preserve the native implementation as the oracle until Gate 7.
- Generic capability work may incubate here and later be donated to CREXX.
- Sequential Phase-3-plus implementation with QA and one commit per phase was
  authorized on 2026-08-23. This does not authorize removal of the existing
  path, push, release, or donation submission.

## Reviewed Baseline

### Current `crexx-rag`

- The native core, CLI, MCP adapter, cREXX plugin/profile smokes, staged generic
  flow, and current use-case wrappers pass the debug preset: 11/11 tests on the
  2026-07-26 review checkout.
- The successful semantic sequence is candidate census, corpus/delta
  adjudication, evidence/mention seeding, ranked extraction, validated claim
  promotion, repair/review, and source-bound multi-query QA.
- The native implementation is not a safe incremental target: same-URI ingest
  replaces every chunk; claims/support are not normalized; queue workers lack
  leases; graph traversal is directionally lossy; hybrid search interleaves
  ranks; and the bridge moves corpus-sized JSON through fixed buffers.
- Existing user changes in `docs/crexx-integration-issues.md` and
  `docs/crexx-team-briefing.md` are outside this programme edit and must remain
  preserved.

### Sister CREXX

The 2026-07-26 live performance roadmap makes the direction credible but does
not prove this workload automatically:

- PERF2-01 through PERF2-04 are complete. The live uncommitted roadmap now marks
  PERF2-05 `decision required` at the P05-SA1 selection stop after P05-CF1.
- Planning assumption from the project owner: treat the ongoing PERF2 programme
  as completing successfully. This programme must not edit, sequence, or block
  that sister-repository work; cREXX-rag measurements select only this
  application's storage/data/provider/vector boundaries.
- Accepted receiver inlining and constant-call evaluation results are large on
  their selected workloads and remain correctness-gated.
- A small audit probe over 11,684 by 768 float multiply/add iterations made
  pure-cREXX exact vector arithmetic plausible; vector transfer and
  representation remain the real question.
- There is no current same-session portfolio showing that all ingestion,
  SQLite, JSON, graph, and provider workloads are fast enough.
- PERF2-08 still records parse-once JSON and richer owned containers as open
  capability work.
- Level G already has useful cREXX LLM clients for Ollama, OpenAI, Anthropic,
  and Gemini, but not the complete provider/embedding contract.
- SQLite is a non-installed demo with text/fixed-buffer constraints, not a
  production plugin. Its current demonstration also needs an output-asserting
  regression for CREXX implicit-concatenation command syntax.
- Installed external RXPA development headers and CMake helpers remain missing
  on the reviewed toolchain.

Performance improvements are an enabler and an invitation to measure this
application, not a waiver of workload-specific evidence.

## Programme Tracks

| Track | Outcome |
| --- | --- |
| A. CREXX capability | Generic SQLite, structured data, provider, hashing, binary/vector, packaging and diagnostic surfaces |
| B. Storage and lifecycle | Versioned schema, source revisions, stable chunks, normalized support, migrations and recovery |
| C. Algorithms | cREXX chunking, census, adjudication, graph, ranking, extraction, fusion and evidence packets |
| D. Operations | CLI, line commands, jobs, leases, budgets, backup, status and review |
| E. LLM product | Local/hosted provider parity, MCP, skills, privacy and agent workflows |
| F. Qualification | Oracle parity, generic/Scotland/IT corpora, failure injection, usability and performance |
| G. Donation | Minimized CREXX cases, generic packages, tests, docs, benchmarks and upstream handoffs |

## Phase 0 — Freeze The Oracle And Measurement Protocol

Goal: make the successful semantics and current defects reproducible before new
production code changes them.

- [x] **P0-01** Record exact `crexx-rag` and CREXX commits, installed toolchain
  version, compiler/VM variants, machine, build type, provider versions, and
  corpus fingerprints in a dated evidence directory.
- [x] **P0-02** Export a small generic IT-architecture version-1 fixture and a
  sanitized Scotland-shaped fixture containing ambiguity, multiple support,
  chronology, deletion, graph paths, exact keyword/keyphrase cases, aliases,
  and differently worded semantic matches.
- [x] **P0-03** Capture golden semantic outputs for chunking, candidate census,
  adjudication, graph seeding, extraction ranking, queue status, source
  deletion, lexical/vector/graph retrieval, and evidence bundles.
- [x] **P0-04** Convert the five Scotland QA lessons into judgement cases for
  exact phrase, alias/ambiguity, chronology, comparison, source stance, and
  direct-claim-versus-adjacency behavior. Judge evidence/citations, not exact
  generated prose.
- [x] **P0-04A** Create a separate IT-architecture judgement set with held-out
  questions and labels for passage relevance, keyword/alias expansions, claim
  support/stance/time, graph leads, citation entailment, and expected gaps.
- [x] **P0-05** Add explicit regression demonstrations for current lifecycle
  failures: same-URI ID churn, stale graph support after source change, unsafe
  queue crash boundaries, and corpus-sized JSON materialization.
- [x] **P0-06** Define a same-session benchmark harness that separates SQLite,
  cREXX algorithm, provider wait, JSON/codec, and vector transfer/compute time.
- [x] **P0-07** Freeze provisional thresholds and corpus sizes only after the
  first complete measurement run. Predeclare evidence recall/precision at the
  context budget, citation resolution and entailment, unsupported-claim rate,
  ambiguity/conflict classification, context tokens, p50/p95 latency, and the
  fixed/blinded answer-model protocol.

### Gate 0 — Baseline approval

Required evidence:

- clean reproducible builds and exact fixture hashes;
- current test counts and golden outputs;
- explicit known-defect cases;
- benchmark protocol and raw results; and
- written confirmation that the oracle is frozen but still maintained for
  blocking correctness defects.

If any required evidence is incomplete or non-reproducible, stop for review. If
Gate 0 passes, the approved execution unit may continue into bounded Phase 1A
without another user turn. Gate 0 never authorizes retirement or dual-write.

## Phase 1 — CREXX Capability Vertical Slices

Goal: answer the feasibility questions without turning the selection phase into
a full library programme. Phase 1 has a bounded boundary-selection pass followed
by separately approved hardening.

### Phase 1A — Bounded boundary selection

- [x] **P1A-SDK-01** Consume the approved CREXX candidate from a scratch
  install through its version-matched headers, CMake package, imported targets
  and plugin helper. The independent external consumer and structured-invalid
  signature matrix pass optimized/non-optimized on both VMs with both
  downstream fallbacks off; vendored/source SDK fallbacks are retired.
- [x] **P1A-SQL-01** Implement only the minimal generic SQLite slice needed to
  choose the boundary: connection, prepared statement, typed null/integer/real/
  text/blob bind/read, cursor iteration, transaction rollback, FTS5 query, and
  explicit error cleanup.
- [x] **P1A-DATA-01** Pass one representative provider JSON payload and one paged
  SQLite row set through parse-once/typed cREXX records without a whole-corpus
  JSON string. The approved candidate replay migrates this slice to production
  `rxjson.jsondocument` and explicit owning headerless `node_f32_array`/
  `node_i64_array` little-endian projections at 3,072 elements on both VM
  variants. Type, count and dimensional meaning are application schema.
- [x] **P1A-LLM-01** Complete one Google/Gemini generation call and one Google
  embedding call through the normalized cREXX provider contract, including
  timeout and structured error output. Deterministic protocol tests remain
  loopback-only; the real hosted canary and `GEMINI_API_KEY` use are explicitly
  user-authorized and the key must never enter evidence. The preserved first
  attempt timed out while repeatedly reparsing a full embedding. The accepted
  parse-once/packed repair passed deterministic failures and one canary with
  matching generation plus exactly 8 embedding dimensions.
- [x] **P1A-VEC-01** Round-trip a page of float32 vectors through SQLite and run
  exact cREXX cosine/top-k while measuring transfer, decode, compute, and memory
  separately.
- [x] **P1A-ALG-01** In one small cREXX vertical slice, capture a source
  artifact/revision, chunk and FTS it, reingest unchanged with zero library
  writes, edit one paragraph, promote/retract one normalized supported claim,
  and emit an evidence packet.
- [x] **P1A-JOB-01** Claim and fence one durable item, force termination before
  and after promotion, and prove idempotent recovery.
- [x] **P1A-SUR-01** Carry the same typed status/evidence record through a minimal
  Level G facade, CLI JSON, `ADDRESS RAG`, and MCP `structuredContent` adapter so
  transport feasibility is not deferred to Phase 6.

### Gate 1A — Boundary selection

Select or revise the SQLite ownership/record boundary, JSON/value model,
provider contract, vector baseline, generation model, job fencing, and facade
shape from retained correctness/profile evidence. Stop for approval before
turning any PoC into a production/common library.

Gate-1A evidence is complete in the dated decision packet. The 2026-07-31
approved-candidate replay closes CRI-01 through CRI-14 downstream and passes
28/28 deterministic/loopback tests. On 2026-08-03 the user approved D1 through
D8 and the bounded D9 worklist in the
[decision ledger](gate1a-decision-ledger.md).

The later 2026-08-04 Level-G-first decision supersedes Gate-1A D7 for current
and future implementation. The completed cross-level evidence remains valid as
CREXX compatibility proof, but it is not the target application structure. The
maintained-source migration and verification are retained in the
[Level-G migration evidence](evidence/2026-08-04-levelg-migration/LEVEL-G-MIGRATION.md).

Fresh Linux build qualification on 2026-08-03 builds all Debug and Release
targets and makes process-memory evidence portable, but opens CRI-15: installed
`rxvme` loses the documented socket timeout status during string receive. The
[retained reproducer](evidence/2026-08-03-linux-build/LINUX-BUILD-REVIEW.md)
must be closed or explicitly dispositioned before Phase-1B provider hardening
can claim Linux timeout qualification. It does not authorize a CREXX edit or a
downstream product-specific workaround.

### Phase 1B — Capability hardening and donation readiness

Only the Gate-1A-selected subset in the decision ledger is authorized. Local
generic incubation may be hardened, but donation preparation remains excluded.
Use the [Phase-1B handoff](../prompts/phase1b-implementation-handoff.md) and stop
unconditionally at Gate 1B.

### A1. Installed plugin development

- [x] **P1-RXPA-01** Harden the Gate-1A scratch SDK/install result into a
  repeatable external dynamic-plugin build with the vendored `crexxpa.h`
  fallback disabled. The installed-only four-cell result is retained in
  [the Phase-1B evidence](evidence/2026-08-03-phase1b/P1-RXPA-01.md).
- [x] **P1-RXPA-02** Specify and locally validate the development package:
  version-matched headers, `RXPluginFunction.cmake`, imported target or package
  config, runtime module discovery, examples, and compatibility diagnostics.
  Exact-compatible, missing, incompatible, and dual-VM discovery results are
  retained in [the Phase-1B evidence](evidence/2026-08-03-phase1b/P1-RXPA-02.md).
- [ ] **P1-RXPA-03** **Not authorized.** Produce a donation-ready
  installed-consumer test.

### A2. Production `rxsqlite`

- [x] **P1-SQL-01** Write the generic connection/statement/cursor/error contract
  and ownership rules without RAG vocabulary. The four-cell ownership/error
  result is [retained here](evidence/2026-08-03-phase1b/P1-SQL-01.md).
- [x] **P1-SQL-02** Implement typed null/integer/real/text/blob bind and column
  round-trips, including values and result sets larger than current fixed
  buffers. Four-cell typed/large results are
  [retained here](evidence/2026-08-03-phase1b/P1-SQL-02.md).
- [x] **P1-SQL-03** Implement transactions, savepoints, rollback, prepared
  statement reuse, cursor paging, FTS5, JSON1 capability reporting, foreign
  keys, WAL, busy timeout, and checkpoint. The four-cell result is
  [retained here](evidence/2026-08-03-phase1b/P1-SQL-03.md).
- [x] **P1-SQL-04** Prove read-only opens perform zero writes and cannot migrate.
  The four-cell byte-identical result is
  [retained here](evidence/2026-08-03-phase1b/P1-SQL-04.md).
- [x] **P1-SQL-05** Prove concurrent reader plus writer behavior using separate
  processes; do not assume cREXX VM thread safety. The four-cell WAL snapshot
  result is [retained here](evidence/2026-08-03-phase1b/P1-SQL-05.md).
- [x] **P1-SQL-06** Add online backup/integrity support and forced-error cleanup
  tests. The four-cell snapshot/failure result is
  [retained here](evidence/2026-08-03-phase1b/P1-SQL-06.md).
- [x] **P1-SQL-07** Add `ADDRESS SQLITE` as an optional facade over the same API
  and assert command output, including a minimized regression for the broken
  demonstration syntax. The four-cell output-asserting result is
  [retained here](evidence/2026-08-03-phase1b/P1-SQL-07.md).

### A3. Structured data and records

- [x] **P1-JSON-01** Prove a parse-once JSON document/value handle with typed
  iteration, Unicode correctness, missing/null/empty distinction, and bounded
  encoding. The installed-parser four-cell result is
  [retained here](evidence/2026-08-03-phase1b/P1-JSON-01.md).
- [x] **P1-JSON-02** Compare it with repeated `rxjson` paths on representative
  provider payloads and a paged evidence result. The same-session four-cell
  comparison is [retained here](evidence/2026-08-03-phase1b/P1-JSON-02.md).
- [x] **P1-REC-01** Establish how Level B typed records/arrays cross Level G and
  plugin boundaries without reserializing the corpus. The four-cell nominal
  record result is [retained here](evidence/2026-08-03-phase1b/P1-REC-01.md).

### A4. Provider contract

- [x] **P1-LLM-01** Refactor or wrap the existing Level G clients behind a
  provider-neutral capability/result/error contract. The four-cell contract
  result is [retained here](evidence/2026-08-03-phase1b/P1-LLM-01.md).
- [x] **P1-LLM-02** Complete one local llama-server generation call and one local
  embedding call through a configurable OpenAI-compatible base URL. The
  available deterministic loopback case is [retained here](evidence/2026-08-03-phase1b/P1-LLM-02.md);
  the `llama-server` executable was unavailable and is not claimed.
- [x] **P1-LLM-03** Add batch embedding, structured response validation,
  timeout, bounded retry/backoff, usage records, privacy route enforcement, and
  truthful streaming/cancellation capability reporting. Test both supported and
  explicit unsupported results; the RAG pipeline does not require every provider
  to stream. The non-timeout result is [retained here](evidence/2026-08-03-phase1b/P1-LLM-03.md);
  CRI-15 still blocks Linux timeout qualification and CRI-16 records the
  installed HTTP industrialization gap.
- [x] **P1-LLM-04** Pass synthetic contract tests for local, OpenAI, Anthropic,
  and Gemini shapes, then run the explicitly authorized low-cost, secret-gated
  hosted qualification for OpenAI, Anthropic/Claude, and Google Gemini. The
  deterministic and five-call hosted result is [retained here](evidence/2026-08-03-phase1b/P1-LLM-04.md).
- [x] **P1-LLM-05** Prove that denied/restricted routes make zero outbound
  requests and that credentials do not enter logs or fixtures. The four-cell
  observer and credential-value audit are [retained here](evidence/2026-08-03-phase1b/P1-LLM-05.md).

### A5. Hash, binary, and vector transfer

- [ ] **P1-HASH-01** **Not authorized.** Add incremental binary file input and
  SHA-256 through a generic cREXX library/plugin surface.
- [x] **P1-VEC-01** Define a versioned float32 embedding blob codec and store the
  existing 768-dimensional shape through `rxsqlite`. The four-cell codec and
  scratch-SQLite result is [retained here](evidence/2026-08-03-phase1b/P1-VEC-01.md).
- [x] **P1-VEC-02** Page 11,684 representative vectors into cREXX and compare
  exact cosine/top-k ordering with the oracle. The four-cell closed-form oracle
  result is [retained here](evidence/2026-08-03-phase1b/P1-VEC-02.md).
- [x] **P1-VEC-03** Report SQLite transfer, decode, similarity arithmetic,
  selection, memory, and total time separately on both VM variants. The
  four-cell component result is [retained here](evidence/2026-08-03-phase1b/P1-VEC-03.md).
- [x] **P1-VEC-04** Choose pure cREXX exact search, SQLite extension, or generic
  `rxvector` only from measured evidence. Do not assume FAISS is required. The
  [decision](evidence/2026-08-03-phase1b/P1-VEC-04.md) retains exact cREXX as
  the bounded correctness fallback and recommends separately authorized
  generic `rxvector` qualification because the latency trigger crossed.

### A6. Algorithm parity slice

- [x] **P1-ALG-01** In cREXX, initialize a small scratch schema through
  `rxsqlite`, chunk a deterministic corpus, and run lexical FTS search.
- [x] **P1-ALG-02** Prove identical ingest is a no-op and a one-paragraph edit
  reuses unaffected chunk identities.
- [x] **P1-ALG-03** Materialize one accepted typed claim with normalized support,
  retract its source revision, and prove the claim state updates.
- [x] **P1-ALG-04** Build an evidence packet combining lexical passage, graph
  claim/support, ambiguity, and one vector lead.
- [x] **P1-ALG-05** Record semantic parity and performance against the native
  oracle.

### A7. Resumable worker slice

- [x] **P1-JOB-01** Implement a single-process durable queue with atomic claim,
  database-clock lease, heartbeat, monotonic fencing token, attempt, idempotent
  promotion, cancellation request, and status.
- [x] **P1-JOB-02** Force termination before provider call, after provider call,
  during promotion, and after promotion; prove recovery without duplicate
  support.
- [x] **P1-JOB-03** Enforce item and call ceilings plus pre-call token/cost/time
  reservations; report actual use and the documented maximum in-flight overrun.

### Gate 1B — Hardened capability acceptance

Required evidence:

- `rxsqlite` correctness and concurrency matrix;
- structured data/record boundary result;
- local and hosted provider contract result;
- vector transfer/compute breakdown and backend recommendation;
- incremental/claim-support/evidence vertical slice;
- crash-recovery result;
- cREXX versus oracle profile; and
- a capability ledger classifying each issue as application code, local
  incubation, proposed CREXX donation, or blocked external dependency.

Stop for a production-capability decision. Revise the target design if hardening
disproves a selected boundary. Gate 1B acceptance authorizes the cREXX skeleton,
not native core removal. It also does not authorize Phase 2 without a separate
user decision.

Gate 1B was reached on 2026-08-03. All bounded implementation items are
accepted; full validation passed 55/56 with the sole unchanged CRI-15 failure.
The user accepted Gate 1B on 2026-08-04 and separately authorized Phase 2 as
the next product workstream. The dated worklist and pushed entry baseline are
now established under `docs/evidence/2026-08-04-phase2/`.

## Phase 2 — cREXX Product Skeleton And Schema V2

Goal: establish installed, recoverable product foundations without model-driven
mutation.

- [x] **P2-01** Create the Level G application module layout and Level G
  `raglibrary`, `ragjob`, and `ragevidence` public contracts. Do not introduce
  pass-through language-level wrappers; record any necessary Level-B
  foundation exception with a minimized reproducer and evidence. Accepted with
  four-cell compiled-consumer and full-suite evidence in
  [`P2-01.md`](evidence/2026-08-04-phase2/P2-01.md); no exception was needed.
- [x] **P2-02** Implement operator-registered declarative cREXX config modules
  with `env:` secret references and independent typed profiles; agents may
  select registered ids but never arbitrary executable paths. Accepted with
  four-cell validation, security, privacy, side-effect, resource, and
  full-suite evidence in
  [`P2-02.md`](evidence/2026-08-04-phase2/P2-02.md).
- [x] **P2-03** Implement schema v2 migrations, SQLite-authoritative published
  generations, reader snapshot/visibility rules, recoverable manifest
  projection, strict read-only opens, crash-order tests, library
  init/status/verify, and ordered rollback policy. Accepted with ordered-DDL,
  four-cell lifecycle, real `SIGKILL`, zero-write read-only, recovery,
  verification, rollback, and full-suite evidence in
  [`P2-03.md`](evidence/2026-08-04-phase2/P2-03.md).
- [x] **P2-04** Implement version-1 read/import compatibility and a dry-run
  conversion report. Do not write version 1 in both implementations. Accepted
  with four-cell read-only source fingerprinting, deterministic schema-v2
  import, quarantine policy, invalid-input denial, and full-suite evidence in
  [`P2-04.md`](evidence/2026-08-04-phase2/P2-04.md).
- [x] **P2-05** Implement generation-pinned online backup with matching immutable
  sidecars/snapshot manifest and fresh-folder restore; crash-test each ordering
  boundary. Accepted with four-cell binary SHA-256, online writer/snapshot,
  fresh restore, negative integrity, and dual-VM real-`SIGKILL` evidence in
  [`P2-05.md`](evidence/2026-08-04-phase2/P2-05.md).
- [x] **P2-06** Implement paged repositories for source artifacts, revisions,
  normalization maps, chunk content/occurrences, generation visibility,
  concepts, claims/support/lineage, embeddings, jobs, attempts, and reviews.
  Accepted with 16 bounded keyset repositories, typed binary payloads, pinned
  old/new snapshot isolation, cursor denial, lifecycle/orphan verification,
  and four-cell evidence in
  [`P2-06.md`](evidence/2026-08-04-phase2/P2-06.md).
- [x] **P2-07** Establish command parsing, stable exit codes, `human`, `json`,
  and `ndjson` result contracts. Accepted with the 40-operation closed argv
  grammar, 11 stable exits, bounded typed records, versioned JSON/reconstructable
  NDJSON/human renderings, parser/result denial cases, and four-cell evidence in
  [`P2-07.md`](evidence/2026-08-04-phase2/P2-07.md).
- [x] **P2-08** Add `doctor`,
  `library init/status/verify/backup/restore/migrate`, provider status/test, and
  profile validate commands. Accepted with shared typed dispatch, registered
  non-secret config/profile snapshots, capability-gated lifecycle operations,
  read-only verification, configuration-only provider diagnostics, zero
  outbound/credential resolution, and four-cell evidence in
  [`P2-08.md`](evidence/2026-08-04-phase2/P2-08.md).
- [x] **P2-09** Publish the first cREXX-rag workload/capability report and prepare
  donation bundles for accepted Phase-1 generic components. Require adjacent
  user `README.md` and maintainer `SYSTEM.md` documentation and a current
  incubation-audit entry for every included package. Accepted with a versioned
  ownership/maturity-safe workload report, three explicitly non-released
  manifest-driven review bundles, 52 hash-verified files, all required bundle
  roles, and 12 minimized dual-VM probe cells in
  [`P2-09.md`](evidence/2026-08-04-phase2/P2-09.md).
- [x] **P2-10** Implement zero-library-write canonical plan encoding/digest and
  untrusted apply-time revalidation through the shared facade. Accepted with
  a fixed `crexx-rag.plan/1` encoding, installed SHA-256, one-hour expiry,
  read-snapshot bindings, capability-first denial, hostile-input reconstruction,
  zero-write plan/validation paths, and four-cell evidence in
  [`P2-10.md`](evidence/2026-08-04-phase2/P2-10.md). Valid plans are revalidated
  but not enqueued because domain execution remains assigned to later phases.

### Gate 2 — Foundation acceptance

Fresh installed CREXX users must be able to initialize, inspect, verify, back
up, restore, and read/import a fixture without a sister source checkout or any
product-specific native runtime.

Gate 2 was reached on 2026-08-23 with 69/69 committed-head Debug tests, a fresh
27-target Release build, all ten Phase-2 items accepted, and the preservation
and limitation audit in the
[`Gate-2 decision packet`](evidence/2026-08-04-phase2/GATE-2-DECISION-PACKET.md).
The user accepted Gate 2 for the current macOS scope on 2026-08-23 after the
application adopted the complete installed SHA-256 surface and repeated the
current-package QA. Exact downstream Linux replay remains open. Sequential
Phase-3-plus implementation was subsequently authorized.

## Phase 3 — True Initial And Incremental Ingestion

Goal: replace native ingestion while making lifecycle behavior strictly better.

- [x] **P3-01** Implement connector stable keys, captured raw artifact or verified
  reference, raw and revision-envelope SHA-256 identities, MIME/encoding,
  semantic metadata fingerprints, immutable observations/revisions, and
  raw-to-normalized span maps.
- [x] **P3-02** Port deterministic plain/Markdown/Rexx chunking to Level G and
  preserve format-aware golden behavior where useful.
- [x] **P3-03** Define two-layer chunk identity: immutable revision/span
  occurrences for citations and content/input fingerprints for safe reuse across
  unchanged and changed revisions.
- [x] **P3-04** Implement immutable `ingest plan`, generation checks, apply,
  resume, and exact counters.
- [x] **P3-05** Implement the generation/invalidation kernel: atomically publish
  chunks/FTS, re-anchor or retract existing imported/simple support, and queue
  missing embeddings/mentions/work. Full claim creation/confidence remains
  Phase 4.
- [x] **P3-06** Handle append, middle edit, reorder, rename with and without a
  connector mapping, duplicate identical files, deletion, metadata-only change,
  CRLF/Unicode normalization, parser-version change, interruption, and resume.
- [x] **P3-07** Port candidate census/collation/adjudication using representative
  evidence and versioned decisions; failures stay retryable.
- [x] **P3-08** Dual-run generic fixtures and a bounded Scotland delta against
  the oracle, comparing semantic records rather than row ids.
- [x] **P3-09** Version corpus term/rarity, source-diversity, candidate-decision,
  and extraction-ranking inputs; prove bounded transitive invalidation and that
  repeated planning converges without infinite requeue.

### Gate 3 — Ingestion acceptance

Required headline tests:

- unchanged source produces zero writes/provider calls and preserves citations;
- a one-paragraph edit reuses unaffected chunks, embeddings, and support;
- removed text retracts every dependent active support;
- readers at forced publication crashes see wholly the old or wholly the new
  source/FTS/support generation;
- interrupted work resumes without duplicate mentions or decisions; and
- initial and incremental paths are the same reconciler.

Gate 3 was accepted for the current macOS scope on 2026-08-23. The permanent
four-cell and real-process evidence, executable tutorial, native semantic delta,
and exact limitations are retained in the
[`Phase-3 evidence`](evidence/2026-08-23-phase3/README.md). Exact downstream
Linux qualification remains open and native-v1 remains the oracle.

## Phase 4 — Claims, Extraction, Review, And Improvement

Goal: replace native graph/work business logic with cREXX algorithms over typed
repositories.

- [ ] **P4-01** Implement canonical concepts, aliases, explicit ambiguity,
  directed/qualified/time-scoped claims, support polarity and
  assertion/quotation/report/negation/speculation stance, attribution,
  provenance lineage/independence, conflict state, and directed traversal.
- [ ] **P4-02** Implement idempotent mention promotion and support
  strengthening/retraction in transactions.
- [ ] **P4-03** Port extraction ranking into versioned profile policy; add
  novelty, redundancy, bridge, source-quality, and unresolved-risk terms.
- [ ] **P4-04** Implement provider-neutral extraction proposal records and
  deterministic endpoint/type/evidence-span/confidence validation.
- [ ] **P4-05** Prevent canonical overwrite and route conflicts, unresolved
  endpoints, type issues, ambiguity, and external proposals to typed reviews.
- [ ] **P4-06** Complete database-clock leased/fenced job consumers, heartbeat,
  retry/backoff, cancellation request, dead-letter item state, job-versus-item
  counters, admission reservations, pause/resume/cancel, and non-blocking status.
- [ ] **P4-07** Implement budgeted `improve plan/apply` from explicit triggers.
- [ ] **P4-08** Implement `worker run --once|--follow`, status/drain, graceful
  supervisor shutdown, and forced-termination recovery. Prove one supervised
  worker overnight; then test two OS-process workers, expiry, late-worker
  fencing, cancel races, and bounded in-flight budget overrun.
- [ ] **P4-09** Implement external normalized proposal plan/apply through the
  same evidence/profile/idempotency/conflict/review gates as internal extraction.

### Gate 4 — Improvement acceptance

Every accepted claim must resolve to active support with explicit stance,
lineage and effective time. Crash injection, late workers, cancellation races,
and two workers must not duplicate or stale-promote. Review and background
operations must be bounded, observable, supervised, and resumable.

## Phase 5 — Retrieval And Evidence Product

Goal: make the knowledge store measurably more useful to an LLM than corpus
dumping or the current single-search wrapper.

- [ ] **P5-01** Implement deterministic focused query planning, exact phrases,
  spelling/alias resolution, time, comparison, and relationship intent.
- [ ] **P5-01A** Implement the explicit keyword layer: FTS phrase/prefix search,
  profile keyphrases/aliases, versioned corpus term statistics, inspectable query
  expansion, and the Phase-0 keyword goldens.
- [ ] **P5-02** Implement lexical passage retrieval and directed typed graph
  expansion that resolves paths back to support passages.
- [ ] **P5-03** Add the selected vector backend with profile/dimension/input
  fingerprints, incremental embedding, atomic index generations, and lexical
  fallback.
- [ ] **P5-04** Implement reciprocal-rank fusion with inspectable profile terms,
  directness/source quality, hop decay, temporal relevance, and diversity.
- [ ] **P5-05** Implement versioned evidence packets and stable
  library/source-id/revision-id/UTF-8-span citations with historical resolution.
- [ ] **P5-06** Separate accepted claims, support/contradiction polarity,
  quoted/reported/source stance and attribution, effective time, ambiguities,
  conflicts, graph leads, and gaps.
- [ ] **P5-07** Add query traces and judgement tests for all golden QA cases.
- [ ] **P5-08** Compare answer evidence against current MCP and controlled
  full-context baselines for recall, citation correctness, unsupported claims,
  latency, and context size.

### Gate 5 — Retrieval acceptance

Using the frozen held-out IT and Scotland cases plus a fixed/blinded answer-model
protocol, the cREXX evidence packet must meet Gate-0 thresholds for evidence
recall/precision, keyword/alias behavior, citation resolution/entailment,
unsupported-claim rate, ambiguity/conflict classification, context cost, and
latency. It must beat the declared single-query/list-interleaving and controlled
full-context baselines on the preselected measures, retain all provenance/stance/
time fields, and link every accepted claim to support.

## Phase 6 — Human, Line-Command, MCP, And Skill Experience

Goal: make one coherent application usable without internal implementation
knowledge.

- [ ] **P6-01** Finish the noun/verb CLI and cursor-paged machine formats.
- [ ] **P6-02** Implement `ADDRESS RAG` over the same facade and typed results.
- [ ] **P6-03** Implement typed MCP `structuredContent` by capability: `read`
  exposes status, sources, search, evidence/optional answer,
  trace/path/timeline, and job status/events; `diagnose` adds verify/provider
  diagnostics.
- [ ] **P6-04** Add zero-library-write ingest/improve/proposal plan, review list,
  and review-decision preview under `plan`; gate job control, ingest apply,
  improve/proposal apply, and review decisions under their explicit `control`,
  `ingest`, or `curate` capabilities. Do not expose raw SQL/entity/edge mutation.
- [ ] **P6-05** Ship the generic agent instructions and separately permissioned
  `crexx-rag-qa`, `crexx-rag-ingest`, `crexx-rag-improve`, and
  `crexx-rag-diagnose` skills as installable `SKILL.md` packages with manifests,
  tool/schema prerequisites, write-capability declarations, examples, and
  adversarial tests proving that knowledge of apply does not grant authority.
- [ ] **P6-06** Replace the target-interface examples in the user guide with
  executable tested commands and publish a fresh-install tutorial.
- [ ] **P6-07** Keep deprecated aliases for selected current commands for one
  compatibility release, with machine-readable deprecation output.

### Gate 6 — Usability and safety acceptance

A fresh human completes init, supervised worker start/status, ingest plan/apply,
evidence/optional answer query, improvement dry run, proposal validation,
backup, and restore from shipped documentation. A fresh agent independently
plans authorized work, queries evidence, and monitors the operator-owned worker/
job without acquiring process-supervision authority. Read and plan sessions
cause zero library writes. Privacy/cost plans are visible before authorization,
and every skill passes capability-denial tests.

## Phase 7 — Corpus Qualification And Cutover Decision

Goal: demonstrate production fitness on generic IT architecture and the
historical stress corpus.

- [ ] **P7-01** Run full generic IT-architecture acceptance with local providers.
- [ ] **P7-02** Run the Scotland corpus acceptance and five QA judgement groups.
- [ ] **P7-03** Run the provider matrix with local, deterministic synthetic
  hosted, and at least one real secret-gated hosted generation plus embedding
  qualification. If policy/budget prevents a real hosted run, scope the release
  claim to local providers and label hosted support experimental rather than
  claiming parity.
- [ ] **P7-04** Run source lifecycle, failure injection, worker concurrency,
  generation visibility, backup-during-work with matching sidecars/manifest,
  restore, migration, and rollback suites.
- [ ] **P7-05** Run exact same-session cREXX/native comparisons for ingestion,
  census, graph promotion, queue, vector, evidence latency, memory, model-bound
  overhead, and final library counts.
- [ ] **P7-06** Audit installation, bundle portability, secrets, outbound route
  denials, trusted module registry, file permissions, and read/plan zero-library-
  write behavior.
- [ ] **P7-07** Reconcile all documentation and publish known limitations.
- [ ] **P7-08** Produce a cutover evidence bundle and separate approval request.

### Gate 7 — Production selection

Choose one:

- accept cREXX as default and retain native read-only compatibility for one
  release;
- accept with explicit bounded exceptions and a dated closure plan; or
- reject/defer cutover and keep the oracle default while addressing evidence.

No code deletion is authorized merely by completing Phase 7.

## Phase 8 — Donation, Compatibility Release, And Native Retirement

Goal: finish the language contribution loop and remove obsolete product-native
code only after explicit approval.

- [ ] **P8-01** Prepare each mature generic facility as a donation bundle:
  contract, source, dual-VM tests, installed-consumer test, docs/example,
  benchmark, packaging metadata, and minimized capability reproducer. Keep the
  use `README.md` and system `SYSTEM.md` beside the donated implementation.
- [ ] **P8-02** Coordinate upstream review without depending on immediate
  adoption; retain a namespaced local package while needed.
- [ ] **P8-03** Detect and prefer compatible installed CREXX facilities, with
  explicit version checks and no silent source-tree fallback.
- [ ] **P8-04** Release the cREXX default plus native read-only migration/
  diagnostic compatibility.
- [ ] **P8-05** After the compatibility window and separate approval, remove the
  RAG-specific C++ core, C ABI, `rx_rag` plugin, C++ CLI/MCP business logic, and
  shell-owned orchestration.
- [ ] **P8-06** Preserve historical oracle evidence and migration tooling.

### Gate 8 — Programme closeout

The product contains no RAG-specific native algorithm, installed operation does
not depend on either source checkout, all accepted donations have an ownership
status, current docs describe the shipped cREXX product, and future capability
opportunities remain in an explicit ledger.

## Acceptance Matrix

| Area | Required cases |
| --- | --- |
| Source lifecycle | captured artifact/MIME/encoding, first ingest, identical no-op, append, middle edit/reorder, mapped/unmapped rename, duplicate content, metadata-only change, CRLF/Unicode span map, deletion, parser/profile change, interruption/resume |
| Generations | old-or-new reader visibility at every crash boundary, staging invisibility, manifest-behind recovery, pinned backup/sidecar parity |
| Claims | duplicate replay, independent/duplicated lineage, support/contradiction polarity, quotation/report/negation/attribution, effective time, support retraction, canonical conflict, alias collision, ambiguity, directed inverse/path, evidence-span validation |
| Jobs | two workers, fencing/late worker, heartbeat/expiry, cancel race, crash at every boundary, retry/backoff, dead letter, admission reservation/overrun, pause/resume/cancel, job-versus-item counters |
| Plans | zero library write, canonical encoding/digest, tamper/expiry/generation/config/source/provider rejection, exact reviewed apply |
| Providers | fake, local generation, local embedding, each hosted protocol shape, at least one real hosted qualification or scoped claim, timeout, cancellation capability, rate limit, malformed structured output, privacy denial |
| Vectors | model/profile/input identity, delta-only embedding, dimension mismatch, partial failure/resume, atomic generation activation, stale rejection, lexical fallback |
| Retrieval | keyword phrase/prefix/statistics/expansion, spelling/alias, chronology/effective time, comparison, source stance/attribution, conflict, ambiguity, direct claim, adjacency-only lead, absent evidence, frozen quality/context metrics |
| Safety | read/plan zero library write, capability denial, trusted module registry, secrets redacted, no unauthorized outbound request, backup/restore integrity |
| Portability | fresh installed CREXX, both VM variants where supported, no sibling source dependency, shared bundle reopen |
| UX | human and agent fresh-start walkthrough, supervised worker, installable skill permission tests, exact counters, stable JSON schemas, pagination, actionable errors |
| Performance | same-session raw evidence, component attribution, memory, throughput, query p50/p95, provider-bound overhead, regression threshold |

## Risk Register

| Risk | Mitigation and decision point |
| --- | --- |
| SQLite plugin scope grows into a second ORM | Keep typed primitives/cursors generic; SQL and repositories stay in cREXX; Gate 1A boundary review |
| cREXX structured data causes reparsing/copies | Parse-once and typed-record PoCs before skeleton; measure allocation/transfer separately |
| Vector storage dominates despite fast arithmetic | Run 11,684 x 768 transfer slice; select backend only from evidence |
| Model latency hides poor orchestration | Separate provider wait from cREXX/DB/codec timing in every benchmark |
| Source revisions multiply storage | Content-address chunks/embeddings, explicit retention/vacuum policy, never sacrifice audit silently |
| Multi-worker assumptions exceed VM safety | Start one worker; use OS processes only after SQLite/lease proof; no implied thread support |
| Hosted fallback leaks restricted content | Explicit role route and privacy class; zero-outbound denial test |
| Oracle defects become golden behavior | Golden semantic intent plus defect tests; do not demand parity for known-wrong lifecycle behavior |
| Application code is generalized too early | Incubation ladder and credible second-consumer rule |
| Upstream CREXX timing blocks product | Namespaced generic incubation here; donation-ready boundary; installed feature detection later |
| Dual implementation corrupts libraries | Dual-run on copies, never dual-write; generation/manifest checks |
| Command surface freezes before cREXX ergonomics are known | Freeze vocabulary now; freeze concrete syntax after compiled Phase-1/2 usage tests |

## Post-Gate-1B Direction

Gate 1B is accepted and the bounded Phase-2 item sequence is complete. The
dated Phase-2 worklist records `P2-01` through `P2-10` as accepted. Gate 2 is
accepted for the current macOS scope; do not activate Phase 3 without separate
authorization.

Phase 2 proceeded in parallel with separately bounded CREXX capability work.
The remaining exact downstream CRI-15 Linux replay and any approved provider
lifecycle expansion retain their own repository/write boundary, worklist,
evidence protocol, and stop point.

The 2026-08-22 capability-sync worklist completed the then-available macOS
HTTP/toolchain, one-shot binary SHA-256, and exact packed `rxvector` work. The
2026-08-23 continuation then pulled CREXX through
`e3d6b7b9015847d247ab2b90e83c843881db9b2f`, reviewed its Linux sanitizer,
HTTP and process-ownership closeout, and passed a fresh installed-only
downstream build plus 62/62 CTests. This confirms that current `crexx-rag`
already consumes the public Level-G HTTP, `rxhash` and `rxvector` facilities.
The later installed package supplies and the application now consumes complete
one-shot/hex, immutable incremental, and bounded-memory file SHA-256. It does
not claim provider-lifetime reuse, provider streaming/cancellation, or exact
downstream Linux closure.

## Parallel Capability Backlog — Not Phase 2 Preconditions

No item in this section was a prerequisite for `P2-04` through `P2-10`, and
Phase 2 is complete for the current macOS scope. The exact
downstream Linux replay is deferred to a later platform QA point, while
provider-owned pool lifecycle, streaming/cancellation, and independent `rxllm`
packaging remain separately scoped future decisions. Their retained detail belongs in the
[capability-sync worklist](evidence/2026-08-22-crexx-capability-sync/WORKLIST.md),
not in the Phase-2 execution sequence.

Additional hosted calls, Phase 3, donation submission, dual-write, cutover, and
native-core removal remain unauthorized. Native-v1 remains the executable
oracle throughout Phase 2.
