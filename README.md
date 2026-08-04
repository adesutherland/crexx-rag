# crexx-rag

`crexx-rag` is an LLM-first local RAG and typed-graph knowledge store. It turns
a source corpus into reusable, provenance-backed evidence so that people and
agents can ask focused questions without sending the whole corpus to a model on
every session.

The approved target is a cREXX application backed by SQLite. The project is
also a deliberately demanding cREXX reference workload: it exercises the
language, runtimes, libraries, plugin model, packaging, diagnostics, and
performance with retained correctness and workload evidence.

> **Programme status, 2026-08-04:** Gate 1B is accepted, including all 28
> bounded Phase-1B results and their recorded limitations. Phase 2 is approved
> as the next product phase and has started from a pushed entry baseline.
> `P2-01` and `P2-02` are accepted; `P2-03` is next and pending. The native-v1 C++ path remains the
> executable oracle. Level G is
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

These slices prove boundaries and behavior. They are not yet a production
schema, complete ingestion pipeline, public command set, or cutover candidate.

## Current Status

| Stage | State | Result |
| --- | --- | --- |
| Phase 0 / Gate 0 | Complete | Native oracle, fixtures, judgements, defects, hashes, and measurement protocol frozen |
| Phase 1A / Gate 1A | Complete | cREXX application and generic-plugin boundaries selected; CRI-01 through CRI-14 closed downstream |
| Phase 1B / Gate 1B | Accepted 2026-08-04 | 28 bounded items accepted; Debug/Release build; 55 of 56 tests pass with sole known CRI-15 failure |
| Phase 2 / Gate 2 | Active; P2-03 pending | Level-G public contracts and typed registered configuration/profiles are accepted; schema v2 is next |
| Phase 3 and later | Not authorized | No production ingestion, cutover, or native retirement has started |

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
- bounded source, claim, evidence, and single-process worker semantics with
  native-golden parity.

## Known Production Gaps

The Gate-1B result is a strong capability skeleton, not an industrial
production claim:

- **CRI-15:** Linux `rxvme` overwrites a socket receive timeout with invalid
  UTF-8 status; Linux provider timeout behavior is therefore not qualified.
- **CRI-16:** installed `rxhttp` opens one synchronous connection per request,
  forces connection close and identity encoding, has no configured response
  ceiling, and exposes no streaming or cancellation. It is not approved for
  high-throughput hosted traffic.
- Pure cREXX exact search takes about 0.75 to 0.86 seconds for the representative
  11,684 x 768 workload. It remains the correctness fallback while a generic
  accelerated vector backend is evaluated.
- The Phase-1B fixture fingerprint is deliberately weak. Durable incremental
  binary SHA-256 support remains a separate capability decision.
- Worker evidence is single-process. Supervision, multi-process claiming,
  cancellation races, overnight operation, and bounded in-flight overrun still
  require production qualification.
- The local OpenAI-compatible protocol is qualified against deterministic
  fixtures, but a real `llama-server` deployment was unavailable.
- There is no production schema v2, migration, public target CLI/MCP surface,
  dual-write, cutover, or native-core removal.

## Roadmap

The Gate-1B decision accepts the cREXX skeleton and authorizes Phase 2 as the
next product workstream. Its bounded worklist and pushed entry baseline are
recorded, and its Level-G contracts plus registered configuration/profile
items are accepted. It may
proceed in parallel with separately scoped work
on socket timeouts, HTTP/TLS, vector acceleration, and durable hashing; those
capability streams retain their own evidence and stop points.

Subject to those decisions, the remaining roadmap is:

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
