# crexx-rag

`crexx-rag` is an LLM-first local RAG and typed-graph knowledge store. It turns
a source corpus into reusable, provenance-backed evidence so that people and
agents can ask focused questions without sending the whole corpus to a model on
every session.

The approved target is a cREXX application backed by SQLite. The project is
also a deliberately demanding cREXX reference workload: it exercises the
language, runtimes, libraries, plugin model, packaging, diagnostics, and
performance with retained correctness and workload evidence.

> **Programme status, 2026-08-24:** Gate 1B is accepted, including all 28
> bounded Phase-1B results and their recorded limitations. `P2-01` through
> `P2-10` and Gate 2 are accepted for the current macOS scope. Exact downstream
> Linux replay remains open and is not represented by the macOS result. Phases
> 3 through 6 are implemented and accepted for the recorded macOS scope:
> incremental ingestion; claims, improvement and durable workers; and focused
> hybrid retrieval with typed evidence. Phase 4 includes its literal eight-hour
> supervised soak. Phase 5 includes bounded hosted answer-quality evidence but
> leaves the cREXX hosted POST-completion finding to Phase 7. The native-v1
> C++ path remains the executable oracle. Phase 6 adds the staged Level-G CLI,
> `ADDRESS RAG`, MCP `structuredContent`, installed package and four narrowly
> permissioned skills; Gate 6 acceptance does not authorize cutover. Level G is
> now the required default for advanced libraries and application code; Level B
> is reserved for CREXX bootstrap and justified low-level foundations.

## What The Product Is For

Large language models are useful reasoners but poor durable knowledge stores.
Reading a corpus serially can lose remote connections, blur source statements
with model knowledge, and repeat expensive analysis in every conversation.

`crexx-rag` instead builds a reusable evidence map:

- source passages remain authoritative and independently citable;
- lexical search provides exact, explainable precision;
- embeddings provide semantic recall and candidate bridges;
- a directional typed graph records only evidence-backed relationships;
- ambiguity, contradiction, attribution, and time remain explicit;
- model effort is allocated to the most informative work; and
- queries return compact evidence packets, with prose answers as an optional
  consumer rather than the source of truth.

SQLite is the authoritative store. Vector indexes are rebuildable sidecars, and
neither vector similarity nor an LLM response can create an accepted fact by
itself.

The primary proving domain is IT architecture with ArchiMate-inspired concepts
and relationships. The store and algorithms are domain-neutral so that other
typed knowledge domains can supply their own cREXX profiles.

## Algorithm Developed So Far

The existing native-v1 system established a useful algorithm rather than only
a technology demonstration:

1. preserve source provenance and split plain text, Markdown, and Rexx on
   format-aware boundaries;
2. run a cheap corpus-wide census of names, known concepts, and relationship
   cues before deep extraction;
3. collate and adjudicate candidates as accepted, junk, ambiguous, typed, or
   aliases instead of treating every mention as truth;
4. distinguish weak mentions from strong typed claims and keep ambiguity as a
   first-class result;
5. rank chunks by expected information value, including concept density, type
   diversity, relation cues, rarity, ambiguity, support, and evidence quality;
6. use stronger models only on that ranked queue, treating their output as
   proposals which deterministic policy must accept, reject, or send to review;
7. retrieve through focused lexical, semantic, and directed graph channels that
   resolve back to source support; and
8. assemble evidence that distinguishes passages, accepted claims, ambiguity,
   conflicts, graph leads, and gaps.

The representative Scotland workload is not a toy fixture. It produced 5,977
Stage-1 chunks, 6,358 distinct candidates, 20,697 mentions, more than 23,000
mention-evidence rows, 9,080 ranked chunks, and 11,684 embeddings at dimension 768. These are capacity anchors and migration fixtures, not throughput promises
for a different model or implementation.

Phase 1B then implemented bounded cREXX vertical slices that strengthen the
target semantics:

- immutable source revisions and zero-write identical re-ingest;
- stable reuse of unaffected chunks after a local edit;
- normalized directional claims with independently addressable support and
  explicit retraction;
- typed evidence packets combining lexical passages, accepted claim support,
  ambiguity, and non-factual vector leads;
- deterministic exact vector ordering over the representative workload;
- provider-neutral generation, structured output, multimodal input, and batch
  embedding contracts; and
- durable leased jobs with fencing, crash recovery, idempotent promotion,
  cancellation, and hard token/call/cost/time budgets.

These slices prove boundaries and behavior. Phase 2 also has an accepted
schema-v2 storage foundation with ordered migrations, published generations,
pinned snapshots, recoverable manifests, strict read-only opens, verification,
and rollback. Phase 3 now adds the production Level-G folder connector,
canonical ingest plan, shared initial/incremental reconciler, deterministic
chunking/candidate census, FTS/dependency invalidation, reuse, and resumable
jobs. Phase 4 adds claim/review/improvement and durable multi-process workers;
Phase 5 adds the production Level-G query planner, incremental embedding and
exact-vector publication, hybrid retrieval and bounded typed evidence. It is
now available through the Phase-6 CLI, `ADDRESS RAG`, MCP and narrow skills.
Corpus-wide selection, a provider-backed long-running public worker adapter,
and cutover remain Phase-7 decisions.

## Current Status

| Stage | State | Result |
| --- | --- | --- |
| Phase 0 / Gate 0 | Complete | Native oracle, fixtures, judgements, defects, hashes, and measurement protocol frozen |
| Phase 1A / Gate 1A | Complete | cREXX application and generic-plugin boundaries selected; CRI-01 through CRI-14 closed downstream |
| Phase 1B / Gate 1B | Accepted 2026-08-04 | 28 bounded items accepted; Debug/Release build; 55 of 56 tests pass with sole known CRI-15 failure |
| Phase 2 / Gate 2 | Accepted on macOS 2026-08-23 | P2-01 through P2-10, installed-capability adoption, canonical zero-write planning, and hostile apply-time revalidation are accepted; exact downstream Linux replay remains open |
| Phase 3 / Gate 3 | Accepted on macOS 2026-08-23 | Level-G initial/incremental ingestion, exact reuse/invalidation, executable tutorial, native semantic delta, and crash resume pass; Linux remains open |
| Phase 4 / Gate 4 | Accepted on macOS 2026-08-24 | Claim/support/review, budgeted improvement, crash recovery, two-process fencing, exact reservations, tutorial, literal eight-hour soak, Debug/Release and Apple-ASan pass; Linux remains open |
| Phase 5 / Gate 5 | Accepted on macOS 2026-08-24 | Focused planning, FTS/exact-vector/directed-graph retrieval, stable evidence/citations, 9/9 deterministic judgements and bounded hosted quality qualification pass; Linux and hosted cREXX transport closure remain open |
| Phase 6 / Gate 6 | Accepted on macOS 2026-08-24 | Fresh installed Level-G CLI, ADDRESS RAG, MCP structured content, exact plan/apply, zero-write planning, backup/restore and four capability-scoped skills pass in four compiler/VM cells; no cutover is implied |
| Phase 7 and later | Authorized sequentially | Corpus qualification and a separate cutover decision follow; native retirement is not authorized |

Gate 1B established:

- installed, no-fallback plugin development across both CREXX VMs and compiler
  modes;
- a generic `rxsqlite` incubation with typed values, transactions, WAL,
  concurrency, read-only access, backup, integrity, and cleanup evidence;
- parse-once `rxjson` use and nominal typed records crossing plugin and public
  API boundaries without JSON reserialization;
- one provider contract for configurable local OpenAI-compatible endpoints,
  OpenAI, Anthropic, and Gemini, including five low-cost hosted qualification
  calls and zero-outbound privacy-denial tests;
- a versioned `f32le-v1` vector representation and exact-search oracle; and
- bounded source, claim, evidence, and durable-worker semantics with
  native-golden parity.

## Known Production Gaps

The accepted Phase-3 ingestion path is substantial, but it is not an industrial
production claim:

- **CRI-15:** the upstream HTTP/timeout path is repaired and qualified, but the
  exact installed-package downstream Linux reproducer still needs both-VM
  replay. macOS results are not substituted for it.
- **CRI-16:** installed Level-G HTTP/TLS supplies typed bounded responses,
  pooling, compression, streaming, and cancellation primitives. The current
  adapters deliberately own one pool per operation, so cross-operation reuse,
  streaming, and cancellation remain unsupported until a separate lifecycle
  decision.
- Pure cREXX exact search remains the correctness fallback. Installed packed
  `rxvector` is the selected deterministic acceleration for the representative
  11,684 x 768 workload.
- Installed `rxhash` now owns durable one-shot, hexadecimal, immutable
  incremental, and bounded-memory file SHA-256. Application sidecars preserve
  their own byte ceiling while hashing fixed chunks.
- Phase-4 worker evidence includes database-clock leases, monotonic fences,
  forced termination, cancellation, retry/dead-letter, exact reservations,
  bounded in-flight denial, and two competing OS processes. The literal
  supervised eight-hour soak passed; in-process cREXX thread safety is neither
  assumed nor claimed.
- Phase-5 evidence qualifies deterministic hybrid retrieval and a bounded
  hosted answer comparison. The incubated cREXX hosted adapter's observed POST
  completion timeout remains explicit Phase-7 work; the external hosted
  quality harness does not qualify that transport path.
- The local OpenAI-compatible protocol is qualified against deterministic
  fixtures, but a real `llama-server` deployment was unavailable.
- There is no installed target CLI/MCP adapter,
  dual-write, cutover, or native-core removal. Phase 2 provides version-1
  import, paged repositories, and the shared command/foundation contracts only.

## Roadmap

Phase 2 and Gate 2 are accepted for the current macOS scope. Their bounded
worklist, entry baseline, item evidence, and closeout are recorded. Exact
downstream Linux replay remains open; provider-lifecycle expansion remains a
separate capability decision. Neither authorizes Phase 3.

The ordered roadmap is:

1. **Phase 2: product foundations.** Level-G application modules and public
   contracts, declarative configuration, schema v2 and migrations, published
   generations, backup/restore, repositories, stable command results, and
   plan/apply.
2. **Phase 3: incremental ingestion.** Durable identities, format-aware
   chunking, source reconciliation, reuse and retraction, interruption recovery,
   invalidation, and semantic comparison with the oracle.
3. **Phase 4: claims and improvement.** Typed claim/support policy,
   provider-neutral extraction, review, production job consumers, supervised
   multi-process workers, and bounded improvement.
4. **Phase 5: retrieval and evidence.** Keyword, vector, and directed graph
   retrieval; rank fusion; stable citations; evidence packets; traces; and
   blinded quality comparisons.
5. **Phase 6: product surfaces.** One operation vocabulary exposed through the
   CLI, `ADDRESS RAG`, MCP, and separately permissioned agent skills.
6. **Phase 7: qualification and cutover decision.** Corpus, provider, recovery,
   concurrency, portability, security, quality, and performance evidence.
7. **Phase 8: donation and retirement.** Package mature generic facilities for
   CREXX and remove native product code only after an explicit later approval.

See the [implementation roadmap](docs/crexx-only-implementation-roadmap.md) for
the itemized worklist and acceptance gates.

## Architecture Boundary

Product algorithms, SQL repositories and migrations, orchestration, policy,
configuration, commands, jobs, retrieval, and evidence assembly belong in
cREXX Level G. Reusable advanced libraries also use Level G even when they
consume Level-B foundation libraries. Level B is reserved for CREXX bootstrap
or an explicitly justified low-level capability. Native code is limited to
small reusable mechanisms that reasonably require host APIs, initially SQLite
and only measurement-justified hashing, HTTP/TLS, binary, or vector primitives.

Any generic facility incubated here must have a RAG-neutral API, independent
tests, examples, packaging, and workload benchmarks before it becomes a CREXX
donation candidate. The native-v1 C++ core, C ABI, `rx_rag` bridge, CLI, MCP,
and version-1 bundles remain the executable oracle until a later cutover gate.
Live libraries are never dual-written during comparison.

The [generic capability incubation audit](incubator/README.md) identifies every
current or future candidate, its implementation boundary, its donation status,
and the usage/system documentation kept beside implemented package code.

## Build And Test

Prerequisites are CMake 3.21 or newer, Ninja, a C/C++ toolchain, the installed
CREXX CMake package, and SQLite 3 development headers and library. On Debian or
Ubuntu:

```bash
sudo apt-get install build-essential cmake ninja-build libsqlite3-dev time
```

The `sqlite3` command-line program is not required. A runtime-only SQLite
package is insufficient because the build needs headers and the link library.

Configure, build, and run the retained oracle and cREXX capability tests with:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

The retained Gate-1B Linux baseline builds successfully and reports 55 of 56
tests passing. Test `p1a_provider_boundary` remains failing while CRI-15 is
open; the exact failure and minimized reproducer are retained rather than
hidden by a product workaround. Later housekeeping tests do not rewrite that
dated Gate result.

Use the installed CREXX toolchain as the compatibility target. Any sibling
CREXX source checkout is read-only reference material for this programme.

## Documentation

- [Vision and product specification](docs/crexx-only-vision-and-specification.md)
- [Target architecture](docs/crexx-only-architecture.md)
- [Implementation roadmap](docs/crexx-only-implementation-roadmap.md)
- [Current programme status](docs/pipeline-status.md)
- [Gate-1B decision packet](docs/evidence/2026-08-03-phase1b/GATE-1B-DECISION-PACKET.md)
- [Gate-1B decision ledger](docs/gate1b-decision-ledger.md)
- [CREXX capability ledger](docs/evidence/2026-08-03-phase1b/CAPABILITY-LEDGER.md)
- [CREXX integration issues](docs/crexx-integration-issues.md)
- [Generic capability incubation audit](incubator/README.md)
- [Test strategy](docs/test-strategy.md)
- [Complete documentation map](docs/README.md)

The material under `docs/archive/` and `prompts/archive/` is frozen native-v1
oracle evidence. It documents historical behavior, not the selected target
architecture or current programme authority.
