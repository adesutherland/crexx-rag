# crexx-rag

`crexx-rag` turns a collection of documents into a durable evidence library for
people and large language models. Instead of copying every document into every
prompt, it finds the small set of passages, supported relationships, conflicts,
and gaps that matter to a question and returns them with stable citations.

The aim is scalable, open, efficient, and comprehensive information for LLMs:
scalable because unchanged material is not reprocessed and every large result
or job is bounded; open because SQLite, canonical data formats, provider-neutral
contracts, and several public interfaces avoid a closed data or model silo;
efficient because cheap deterministic work narrows the expensive work; and
comprehensive because exact wording, semantic similarity, typed relationships,
history, ambiguity, and missing evidence are considered together.

The approved implementation is a cREXX Level-G application backed by SQLite.
It is also a demanding reference application for the cREXX language, VMs,
libraries, plugin system, packaging, diagnostics, and performance.

## In Plain English

Think of `crexx-rag` as a careful research librarian for an LLM. It remembers
where every statement came from, notices when a document changes, keeps old
revisions so citations remain meaningful, and builds several different routes
to the same information. When a user asks a question, it prepares an evidence
pack rather than pretending that a generated answer is itself a fact.

The system is intended to make a large, changing corpus useful over time:

- **Comprehensive:** preserve exact passages, accepted relationships, aliases,
  ambiguity, disagreement, attribution, time, and known gaps. Comprehensive
  does not mean inventing an answer when the corpus is silent.
- **Efficient:** hash and compare before doing deeper work, reuse unchanged
  chunks and embeddings, rank the most informative material, and call an LLM
  only when rules and indexes cannot finish the job cheaply.
- **Scalable:** page corpus-sized data, stream and bound file work, publish
  immutable generations, run resumable jobs, and enforce item, call, token,
  cost, time, retry, and in-flight limits. These are architectural properties,
  not a claim of unlimited throughput.
- **Open and portable:** keep SQLite as the source of truth, use documented
  canonical records and sidecars, support local and hosted providers through
  one contract, and expose the same operations to humans, cREXX programs, and
  agents. “Open” here describes the integration and data architecture; no
  repository licence is implied where one has not been published.

The first proving domain is IT architecture, using ArchiMate-inspired concepts
and relationships. Domain rules live in replaceable cREXX profiles, so the same
store and algorithms can be used for other bodies of knowledge.

## The Tools It Provides

| Tool or layer | What it does in ordinary language |
| --- | --- |
| Library and folder ingestion | Scans selected files, preserves exact source revisions, plans additions/changes/removals without writing, then applies only the reviewed delta. |
| Knowledge builder | Splits sources on format-aware boundaries, inventories names and cues, proposes concepts and directed claims, and keeps uncertain or conflicting material for review. |
| Hybrid retrieval | Searches exact words with SQLite FTS5, related meaning with embeddings, and supported relationships with a typed graph, then fuses the ranked results deterministically. |
| Evidence builder | Produces bounded packets containing cited passages, supported claims, leads, conflicts, ambiguity, time, provenance, gaps, and optional answer guidance. |
| Improvement worker | Processes durable queues under leases and monotonic fences, recovers after interruption, and cannot exceed reviewed work, provider, time, or cost budgets. |
| Provider layer | Gives local OpenAI-compatible services and hosted providers one normalized generation/embedding contract while enforcing privacy routes and symbolic secret references. |
| Public interfaces | Exposes one operation vocabulary through the native `crexxrag` application, `ADDRESS RAG` for cREXX programs, `crexxrag serve mcp` with typed `structuredContent` for agents, and four narrowly permissioned skills. |
| Operator and QA tools | Verify, back up, restore, diagnose, trace, and replay the library; executable tutorials and CTest fixtures prove the same behavior across compiler modes and both available VMs. |

Under the application, installed CREXX facilities provide binary-safe SHA-256,
parse-once JSON, bounded HTTP/TLS, exact packed vectors, and the SQLite plugin.
Those are general mechanisms: all source, chunk, claim, graph, ranking, policy,
job, and evidence decisions remain in cREXX application code.

## How The Algorithm Works

1. **Observe the sources.** Read the permitted files as exact bytes, hash them,
   normalize supported text formats, and create stable source and revision
   identities.
2. **Plan before changing anything.** Compare the observation with the current
   published generation and produce a canonical, content-addressed plan. An
   identical corpus means zero database writes and zero provider calls.
3. **Apply the reviewed delta.** Revalidate the plan, split new or changed text
   into stable chunks, reuse unaffected content, retract dependencies of removed
   evidence, and publish the next coherent generation.
4. **Build cheap indexes first.** Update exact full-text search and run a
   corpus-wide census of names, known concepts, aliases, and relationship cues.
   Queue only missing or potentially valuable deeper work.
5. **Improve under policy.** Rank chunks by expected information value. Local
   rules or configured models may propose types and relationships, but
   deterministic validation either accepts them with independently addressable
   support, rejects them, or creates a review item.
6. **Plan the question.** Normalize the question into exact phrase/prefix,
   alias, bounded spelling, relationship, comparison, and time variants without
   contacting a model.
7. **Retrieve through independent channels.** Run bounded lexical, semantic,
   and directed-graph searches, resolve every accepted relationship back to
   source support, and combine ranks with inspectable reciprocal-rank fusion.
8. **Assemble evidence, then optionally answer.** Select a diverse packet within
   the context budget and label passages, accepted claims, non-factual leads,
   conflicts, and gaps. A calling LLM may write prose from that packet; its prose
   never silently becomes stored truth.

SQLite is authoritative throughout. Vector indexes are checksum-bound,
rebuildable sidecars, and neither similarity nor model confidence can create an
accepted fact.

## Implementation And Evidence

The retained native-v1 implementation first established the algorithm and is
still the executable comparison oracle. The cREXX path now implements the
schema-v3 store, incremental ingestion, claim/review/improvement policy, durable
multi-process work, focused hybrid retrieval, typed evidence, and staged public
surfaces. Phase 7 deliberately deferred production cutover until the remaining
provider/worker integration and portability gates close.

The representative Scotland workload is not a toy fixture. It produced 5,977
Stage-1 chunks, 6,358 distinct candidates, 20,697 mentions, more than 23,000
mention-evidence rows, 9,080 ranked chunks, and 11,684 embeddings at dimension
768. These are capacity anchors and migration fixtures, not throughput promises
for a different corpus, model, or implementation.

> **Programme status, 2026-08-24:** Phase 2 and the Phase-3 reconciler through
> Phase 6 are implemented and accepted for their recorded macOS component
> scopes. Product ingestion acceptance has been reopened as Gate 3R so one
> installed cREXX application must prove real Gemini ingestion end to end.
> Phase 4 includes a literal
> supervised eight-hour soak, and Phase 5 includes bounded hosted answer-quality
> evidence. Phase 7 qualifies the corpora and external hosted generation and
> embedding paths but rejects/defers cutover because cREXX hosted response
> completion, the public worker/provider and embedding-item path,
> production-shaped same-session evidence, and exact downstream Linux remain
> open. Native-v1 remains the default oracle. Phase 8 is an opportunity and
> readiness report, not a tutorial or authorization to donate, cut over, or
> remove the oracle.

## Current Status

| Stage | State | Result |
| --- | --- | --- |
| Phase 0 / Gate 0 | Complete | Native oracle, fixtures, judgements, defects, hashes, and measurement protocol frozen |
| Phase 1A / Gate 1A | Complete | cREXX application and generic-plugin boundaries selected; CRI-01 through CRI-14 closed downstream |
| Phase 1B / Gate 1B | Accepted 2026-08-04 | 28 bounded items accepted; Debug/Release build; 55 of 56 tests pass with sole known CRI-15 failure |
| Phase 2 / Gate 2 | Accepted on macOS 2026-08-23 | P2-01 through P2-10, installed-capability adoption, canonical zero-write planning, and hostile apply-time revalidation are accepted; exact downstream Linux replay remains open |
| Phase 3 / Gate 3R | Product acceptance reopened 2026-08-24; reconciler accepted on macOS 2026-08-23 | Reuse the Level-G incremental reconciler, then prove one installed cREXX application performs real Gemini generation, embedding work, validated claim promotion and public evidence retrieval; Linux remains open |
| Phase 4 / Gate 4 | Accepted on macOS; application extension 2026-08-25 | Claim/support/review, budgeted improvement, crash recovery, two-process fencing and literal soak remain accepted; enduring `crexxrag improve`, immutable configured-provider inputs, permanent Gemini and bounded real Codex/Google improvement now pass; Linux remains open |
| Phase 5 / Gate 5 | Accepted on macOS; application extension completed 2026-08-25 | Native `crexxrag query` performs compatible hybrid retrieval and optional citation-validated Codex/Gemini answers over the accepted planning/evidence algorithms; permanent negative QA, 9/9 judgements and both real provider routes pass. Linux, release and cutover remain open |
| Phase 6 / Gate 6 | Accepted on macOS 2026-08-24 | Fresh installed Level-G CLI, ADDRESS RAG, MCP structured content, exact plan/apply, zero-write planning, backup/restore and four capability-scoped skills pass in four compiler/VM cells; no cutover is implied |
| Phase 7 / Gate 7 | Qualification complete; cutover deferred 2026-08-24 | Corpus/lifecycle/surface gates and bounded external OpenAI generation/embedding pass; cREXX hosted completion, public worker/provider and embedding-item integration, full same-session production comparison, and Linux remain open, so native-v1 stays default |
| Phase 8 | Opportunity report complete; Gate 8 not satisfied 2026-08-24 | Candidates, adopted CREXX capabilities, compatibility, and retirement readiness are assessed without submitting donations, cutting over, or deleting the oracle |

The Gate-3R worktree now builds one linked cREXX application and a native
package of the same Level-G command main. Its maintained human configuration
example is `crexx/application/config/google-gemini.conf`; building or running
`doctor` makes no hosted call. Native-v1 remains the default command until a
later cutover decision.

The linked application also has the first enduring controller/worker slice:
`worker start` supervises a bounded number of OS-process workers; list/status,
drain, stale-heartbeat plus local-PID diagnostics, and explicit pruning
communicate through schema-v3 SQLite runtime rows. The focused dual-VM test is
zero-outbound. Workers currently report `processor=framework-idle`; extraction,
embedding, and provider-backed job completion remain the next Gate-3R slice.

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

- **CRI-15:** the upstream HTTP/TLS substrate repairs are qualified, but the
  incubated cREXX provider still loses hosted POST response completion and the
  exact installed-package downstream Linux reproducer still needs both-VM
  replay. macOS results are not substituted for either open result.
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
  supervised eight-hour soak passed. The generic SQLite RXPA provider now
  qualifies its per-VM session implementation under a concurrent lifecycle
  harness and uses serialized SQLite connections, but attached cREXX tasks
  still cannot discover that native provider (CRI-17), so the product retains
  controller-owned SQLite and process-based workers.
- Phase-5 evidence qualifies deterministic hybrid retrieval and a bounded
  hosted answer comparison. Phase 7 externally qualifies OpenAI structured
  generation plus batch embedding, but the incubated cREXX adapter still loses
  hosted response completion and therefore remains a cutover blocker.
- The local OpenAI-compatible protocol is qualified against deterministic
  fixtures, but a real `llama-server` deployment was unavailable.
- The installed Level-G CLI/ADDRESS/MCP surfaces and public process lifecycle
  exist, but `worker.run` is still `framework-idle`: it has no production
  `.ragworkprovider` dispatch and ingestion extraction/embedding items have no
  public processor. There is no dual-write, cutover, or native-core removal.

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
7. **Phase 8: opportunity report.** Assess donation candidates, already adopted
   CREXX capabilities, compatibility, and native retirement readiness. The
   report is complete; submission, cutover, compatibility release, and removal
   remain separately approval-gated.

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
