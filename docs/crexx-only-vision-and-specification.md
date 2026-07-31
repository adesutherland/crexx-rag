# cREXX-Only Vision And Product Specification

Status: approved target, 2026-07-26. This document describes the intended
replacement architecture. It does not describe commands that are all available
in the current native implementation.

## Executive Decision

`crexx-rag` should become a cREXX application built on small, general-purpose
cREXX facilities. All knowledge-store algorithms, policy, orchestration,
configuration, command handling, jobs, retrieval, and agent-facing evidence
assembly belong in cREXX. Native code is permitted only for reusable facilities
that reasonably require a host API, initially SQLite and, if measurement proves
it necessary, hashing or vector indexing.

Those facilities may be incubated and proven in this repository. They must be
designed without RAG concepts, accompanied by independent tests and examples,
and packaged so they can be donated to the sister CREXX project. Upstream-first
development is not required.

This gives the project two equally important outcomes:

1. a practical, LLM-first local knowledge store; and
2. a non-trivial reference application that proves, profiles, and improves the
   cREXX language, runtime, libraries, plugin model, packaging, and tooling.

The current C++ implementation is valuable evidence and an executable oracle.
It should remain intact during migration and be retired only after the cREXX
path passes explicit parity, lifecycle, quality, and performance gates.

## Product Purpose

Large language models are poor substitutes for a durable knowledge system. A
model that receives a large corpus serially can miss remote connections, forget
earlier passages, blur source statements with its own knowledge, and repeat the
same expensive analysis in every session.

`crexx-rag` addresses that problem by building a reusable evidence map:

- source passages remain the authority;
- keyword/lexical retrieval supplies exact, explainable precision;
- semantic embeddings supply recall and bridge candidates;
- a typed graph records accepted, evidence-backed relationships;
- ambiguity and conflicting evidence remain visible;
- inexpensive corpus-wide analysis selects where expensive model work is most
  useful;
- background work improves the same library incrementally; and
- an LLM receives a compact evidence packet rather than an undifferentiated
  dump of the corpus.

The primary domain is IT architecture, with ArchiMate-inspired concepts and
relationships. The store and algorithms remain domain-neutral so other typed
knowledge domains can supply their own cREXX profiles.

These are complementary channels, not competing product modes: keywords find
what the corpus says, embeddings help find differently worded passages, and the
typed graph jumps between supported relationships. All three must resolve back
to source evidence before an LLM treats a result as a fact.

## What "cREXX-Only" Means

The phrase applies to the product implementation, not to every machine
instruction in the process.

| Concern | Target owner |
| --- | --- |
| Chunking, normalization, ranking, graph algorithms, policy, validation | cREXX Level B modules |
| Domain vocabulary, weights, prompts, routing, budgets | cREXX profile/configuration |
| Public classes and application facade | cREXX Level G |
| CLI and line-command dispatch | cREXX |
| Ingestion, improvement, review, and query orchestration | cREXX |
| MCP/agent tool behavior and evidence assembly | cREXX, with transport kept thin |
| SQLite engine access | Generic cREXX plugin, initially incubated here |
| Local and hosted model access | Generic CREXX `rxllm` library/plugin surface over HTTP/TLS; native only where the runtime requires it |
| Optional ANN/vector acceleration | Generic measured backend, not a RAG-specific core |
| Shell scripts | Bootstrap/developer convenience only; never algorithm owners |
| Python | Optional user experiment only; never a required repeatable pipeline dependency |

A contribution is not generic merely because its name is generic. A candidate
for donation must have no concepts such as chunk, source, claim, graph, RAG,
profile, or embedding in its API. For example, a prepared-statement cursor is a
CREXX facility; a `seedCandidateGraph` native call is application logic.

## Programme Objectives

### O1. Useful local knowledge store

The product must support initial ingestion, incremental ingestion, source
replacement and deletion, evidence-centred search, bounded improvement, review,
backup, and sharing through a small folder bundle.

### O2. LLM-first retrieval

The primary query result is an evidence packet intended for an LLM. It must
make claims, sources, graph leads, ambiguity, provenance, confidence, time, and
gaps explicit. A prose answer is an optional consumer of that packet.

### O3. Local and hosted models

The same pipeline must work with local OpenAI-compatible endpoints, Ollama, and
hosted providers. Provider choice must be configuration, not pipeline code.
Embedding, cheap advisory, strong extraction, and answer generation are
separate roles and may use different providers.

### O4. Incremental by construction

An unchanged source must cause no derived writes and no model calls. A changed
source must create a revision, reconcile only the affected chunks and derived
artifacts, and preserve an audit trail. Deletion or supersession must retract or
weaken every dependent support record.

### O5. Safe background improvement

"Overnight" work means explicit, durable, budgeted queues. It does not mean an
agent wandering through the database. Jobs must be resumable, observable, and
safe after crashes or expired workers.

### O6. cREXX proving workload

Each phase must record what the application demonstrates about cREXX. Missing
capabilities become small reproducible tests and design proposals. Reusable
solutions are developed here behind generic APIs, benchmarked on the real
workload, and prepared for donation to CREXX.

## Evidence From The Current System

The current system has established a useful algorithm, not merely a technology
prototype:

1. preserve source provenance and split text on format-aware boundaries;
2. run a cheap candidate census across the corpus;
3. collate and adjudicate candidates before treating them as concepts;
4. seed accepted concepts and weak mention evidence;
5. rank chunks by concept density, type diversity, relation cues, rarity,
   ambiguity, support, and evidence quality;
6. spend a stronger model only on the ranked queue;
7. validate proposals before promoting typed claims;
8. route unresolved work to review/fixup queues; and
9. answer through repeated focused retrieval, distinguishing passages, accepted
   claims, ambiguity, and graph-only leads.

The Scotland work showed that this shape scales beyond a smoke test: the first
100-chunk Stage 3 batch completed 99 items and skipped one, producing 981 node
proposals and 316 relationship proposals before de-duplication; the two-volume
corpus reached 11,684 768-dimensional embeddings. These are workload anchors,
not claims that every current implementation choice is production-ready.

The following lessons are specification requirements:

- candidate census is evidence gathering, not truth;
- corpus-wide collation is more useful than blind per-chunk extraction;
- vectors may rank, group, and retrieve, but may not create typed facts;
- ambiguous aliases must remain explicit;
- repeated support strengthens a claim without duplicating it;
- narrative evidence outranks indexes, captions, and mention-only adjacency;
- model output is a proposal that must pass deterministic validation; and
- multi-query agent oversight produces better answers than a single broad
  search.

## Functional Requirements

### Library lifecycle

- **LIB-01** A library is a shareable folder containing `manifest.json`,
  `library.sqlite`, and optional rebuildable index sidecars.
- **LIB-02** The manifest is a recoverable projection of the SQLite-published
  semantic/index generation. It declares format version, library identity,
  active schema, required capabilities, and immutable sidecars. It is never the
  authority for a checksum of the mutating live database. Secrets are forbidden.
- **LIB-03** Ordered, transactional schema migrations are recorded in the
  database. Opening a library read-only must never rewrite its manifest or run
  migrations.
- **LIB-04** Backup pins one published SQLite semantic/index generation, copies
  its matching immutable sidecars, builds a snapshot manifest, and validates the
  assembled bundle before publication.
- **LIB-05** The current version-1 bundle remains readable during migration and
  has a dry-run, reversible conversion path.

### Sources and incremental ingestion

- **ING-01** Sources have internal identities independent of database row
  numbers and raw URIs. Connectors supply stable keys; a filename/URI change
  preserves identity only when the connector or an explicit reviewed mapping
  proves continuity. Identical content alone never merges sources.
- **ING-02** Every observed source state creates or reuses an immutable source
  revision identified by a collision-resistant envelope digest over content and
  semantic metadata. Captured raw bytes or a verified artifact reference,
  MIME/encoding, normalized text, extractor version, and raw-to-normal span map
  make rechunking and citation audit reproducible.
- **ING-03** Chunk identity has two layers: an immutable revision/span occurrence
  for citations and a content/input fingerprint for reusing derived work across
  revisions. Chunks also preserve type, confidence, capture time, event time,
  and parser/profile versions.
- **ING-04** Identical ingestion is a true no-op, including model and embedding
  work.
- **ING-05** Changed, appended, renamed, and deleted sources atomically retract
  or re-anchor affected active support, reuse identical derived artifacts, and
  enqueue missing mentions, embeddings, and extraction without leaving stale
  facts.
- **ING-06** Initial and incremental ingestion use the same operation. A plan
  mode reports adds, changes, removals, estimated work, and provider use before
  applying it.
- **ING-07** Connectors produce normalized source records; they do not own
  chunking, extraction, graph writes, or policy.
- **ING-08** Corpus statistics, candidate decisions, and extraction ranks carry
  complete input/dependency fingerprints. A source delta invalidates the
  bounded transitive set, and repeated planning on unchanged inputs converges to
  no new work.

### Candidate and concept lifecycle

- **CON-01** Cheap deterministic rules and optional advisory models produce
  candidate mentions with evidence spans and extractor provenance.
- **CON-02** Candidate collation is corpus- or delta-wide and preserves counts,
  source diversity, supporting passages, and prior decisions.
- **CON-03** Adjudication records keep, junk, ambiguous, alias, canonical label,
  proposed type, confidence, evidence, provider/model, prompt/policy version,
  input hash, and validation result.
- **CON-04** Failed or empty model responses remain retryable; they must not be
  silently persisted as semantic decisions.
- **CON-05** Canonical entities cannot be overwritten by an extraction
  proposal. Conflicts become review work.

### Claims, graph, and evidence

- **GRF-01** Nodes and relationships have explicit domain types.
- **GRF-02** A typed relationship is a claim with a stable semantic identity
  independent of its display label.
- **GRF-03** Every accepted claim has at least one independently addressable
  support record linked to a source revision, chunk, and optional character
  span.
- **GRF-04** Replaying the same support is idempotent. Independent support may
  increase confidence without duplicating the claim.
- **GRF-05** Removing or superseding support recalculates claim state; it never
  leaves an unsupported accepted claim silently active.
- **GRF-06** Direction and inverse semantics are preserved during traversal and
  explanation.
- **GRF-07** Ambiguities, conflicts, and candidate resolutions are visible
  graph facts, not hidden guesses.
- **GRF-08** Graph-only adjacency is a discovery lead until supported by a
  passage or an accepted claim with evidence.
- **GRF-09** Claim/support records preserve polarity, direct assertion versus
  quotation/report/speculation/negation, attribution, provenance lineage and
  independence, captured/system time, and asserted/effective validity intervals.
  Confidence/state derivation is versioned and explainable.

### Model providers

- **LLM-01** Providers implement a common cREXX interface with capability
  discovery for chat, structured output, embeddings, streaming, context size,
  and cancellation.
- **LLM-02** Model roles are configured separately: `advisory`, `extractor`,
  `embedding`, and optional `answerer`.
- **LLM-03** Local-to-hosted or hosted-to-local fallback never happens
  implicitly. Privacy and cost boundaries are explicit policy.
- **LLM-04** Requests have timeouts, bounded retries, retry classification,
  rate limits, concurrency limits, and stable input hashes.
- **LLM-05** Credentials are read from named environment variables and never
  written to logs, manifests, prompts, or the library.
- **LLM-06** Local and hosted providers emit the same normalized proposal
  records, so controllers and validators do not branch on vendor.
- **LLM-07** Application code calls the provider surface directly from cREXX.
  It does not shell through the current C++ CLI, `curl`, or a RAG-specific model
  adapter.

### Work and background improvement

- **JOB-01** All expensive or resumable work uses durable jobs and work items.
- **JOB-02** Workers atomically claim items with `worker_id`, `lease_until`, and
  attempt identity plus a database-issued monotonic fencing token. Heartbeat,
  cancellation, expiry, and promotion all verify that token so a late worker
  cannot publish.
- **JOB-03** Promotion of accepted output and completion of its attempt are
  transactional or protected by an idempotency key.
- **JOB-04** Jobs have item, time, token, request, and optional cost budgets.
  Provider work reserves a bounded maximum before admission; status separates
  reserved from actual use and documents the maximum in-flight overrun.
- **JOB-05** Status distinguishes job state from item counters and includes
  `planned_total`, `queued`, `running`, `processed`, `skipped`, `dead_letter`,
  `cancelled`, current item, failed-attempt count, provider/model, throughput,
  timestamps, last error, and artifact state.
- **JOB-06** Background improvement consumes explicit triggers: missing
  embeddings, changed source deltas, ambiguity, weak support, unresolved
  endpoints, stale policy versions, coverage gaps, or review requests.
- **JOB-07** Queue rebuilds never erase live leases or historical attempts.
- **JOB-08** Applying a plan only enqueues durable work. Explicit supervised
  `worker run --once|--follow` processes claim it, stop gracefully, and recover
  forced termination through leases/fencing.

### Retrieval and LLM evidence

- **RET-01** Query planning produces focused variants for exact phrases,
  spelling/aliases, entities, relationships, time, and comparison when relevant.
- **RET-01A** The keyword layer is explicit: FTS phrase/prefix retrieval,
  profile aliases/keyphrases, and versioned corpus term statistics contribute
  inspectable query expansions and ranking features.
- **RET-02** Lexical FTS, optional vector search, and typed graph traversal
  return separate ranked evidence lists with provenance.
- **RET-03** Fusion uses a documented rank-based or calibrated method. Raw
  incomparable scores and simple list interleaving are not sufficient.
- **RET-04** Retrieved chunks anchor their mention/claim graph; graph traversal
  must lead back to ranked source evidence.
- **RET-05** Evidence selection enforces diversity, source quality, directness,
  temporal relevance, and a configurable context budget.
- **RET-06** The primary response is a versioned evidence packet containing the
  original question, query plan, passages, accepted claims with support,
  support stance/polarity/attribution, claim effective time, ambiguities, graph
  leads, source metadata, gaps, and stable library/source/revision/span citations.
- **RET-07** Exact-phrase absence, weak evidence, contradiction, and unresolved
  ambiguity are reported rather than smoothed over.
- **RET-08** Answer generation, if requested, is a separate step that consumes
  and returns the same evidence packet exposed to an external agent plus prose;
  it never changes retrieval or library state.

### Human, line-command, and agent surfaces

- **SUR-01** One operation vocabulary is shared by cREXX APIs, CLI, line
  commands, and agent tools. Transports do not reimplement algorithms.
- **SUR-02** Human commands have stable exit codes and `--format json` output
  with versioned schemas.
- **SUR-03** Every mutation supports plan/dry-run where practical and requires
  an explicit library target.
- **SUR-03A** Planning performs zero library or managed-state writes. It emits
  canonical, content-addressed plan data and a digest that the caller may save;
  apply requires the reviewed digest,
  treats the plan as untrusted input, and revalidates every bound generation,
  fingerprint, provider/privacy route, reservation, and capability before the
  job stores the plan.
- **SUR-04** Agent-facing processes are read-only by default. Write tools are
  absent or rejected unless explicitly enabled at process startup.
- **SUR-05** Raw entity/edge mutation is an expert maintenance surface, not the
  default agent ingestion API.
- **SUR-06** Skills teach agents to plan ingestion, inspect jobs, retrieve with
  multiple focused questions, cite evidence, and distinguish claims from leads.
- **SUR-07** `--access` and MCP capabilities are safety gates, not
  authentication. Filesystem/OS permissions are the local security boundary;
  config/profile modules are trusted operator-registered cREXX code and agents
  cannot select arbitrary module paths.

### External proposal push

- **EXT-01** External analyzers submit normalized concept/claim proposals with
  stable evidence citations and full provider/input provenance through
  proposal plan/apply, never raw graph writes.
- **EXT-02** The same profile, evidence-span, canonical-conflict, ambiguity,
  support-idempotency, and review gates used for internal extraction apply to
  external proposals.

## Target Operation Vocabulary

The exact parser syntax will be frozen after the cREXX command-surface PoC, but
the semantic vocabulary is fixed now:

```text
crexx-rag doctor
crexx-rag library init|status|verify|backup|restore|migrate
crexx-rag provider list|status|test
crexx-rag profile list|show|validate
crexx-rag source list|show
crexx-rag ingest plan|apply
crexx-rag job list|status|events|pause|resume|cancel
crexx-rag worker run|status|drain
crexx-rag query search|evidence|answer|trace|timeline|path
crexx-rag improve plan|apply
crexx-rag proposal plan|apply
crexx-rag review list|show|decide
crexx-rag serve mcp
```

An interactive or embedded `ADDRESS RAG` environment should use the same nouns,
verbs, validation, result records, and exit semantics. It is an ergonomic
dispatcher over cREXX application modules, not a second implementation.

The corresponding minimal agent tools are:

```text
knowledge_status
knowledge_verify
knowledge_provider_status
knowledge_sources
knowledge_search
knowledge_evidence
knowledge_answer
knowledge_trace
knowledge_path
knowledge_timeline
knowledge_job_status
knowledge_job_events
knowledge_ingest_plan          # plan capability
knowledge_ingest_apply         # write-gated
knowledge_improve_plan         # plan capability
knowledge_improve_apply        # write-gated
knowledge_proposal_plan        # plan capability
knowledge_proposal_apply       # write-gated
knowledge_review_list          # plan capability
knowledge_review_preview       # plan capability
knowledge_review_decide        # write-gated
knowledge_job_control          # write-gated
```

## Configuration Contract

Configuration has two layers:

1. a declarative cREXX configuration module selects paths, providers, limits,
   privacy, schedules, and named profiles; and
2. a cREXX profile module defines domain vocabulary, normalization, scoring,
   validation, prompts, and routing policy.

Loading operational configuration may only construct typed configuration data;
it may not start work, read source content, contact providers, or mutate a
library. Secret values are represented only as environment-variable names.
Every job snapshots the effective non-secret configuration and profile version
needed to reproduce its decision.

## Quality Requirements

- **Correctness:** all lifecycle and evidence invariants above are covered by
  deterministic tests.
- **Durability:** interruption at every transaction boundary is resumable
  without duplicate support or lost work.
- **Observability:** normal status operations do not require direct SQLite
  access and do not block active writers.
- **Portability:** the baseline path uses installed CREXX plus packaged generic
  plugins; source-tree fallbacks are diagnostic only.
- **Privacy:** source text goes only to explicitly configured providers.
- **Auditability:** every model-derived decision is attributable and
  reproducible enough to review.
- **Performance:** gates use the same fixtures, build, configuration, and
  machine session. Model-bound and database/algorithm-bound time are reported
  separately.
- **Maintainability:** domain policy is not embedded in generic storage or
  algorithms, and transport adapters contain no business rules.

Initial performance thresholds are deliberately provisional. Phase 0 records
the native oracle and Phase 1 records cREXX capability PoCs before the project
sets final service-level targets. Early engineering targets are:

- unchanged ingestion performs no model or embedding requests;
- cREXX orchestration adds no more than 10% wall time to provider-bound stages;
- database-only corpus operations remain within 1.5 times the native oracle
  until a reviewed exception identifies a missing cREXX/runtime capability;
- a warm local lexical/graph evidence query targets p95 below one second, and a
  local hybrid query below two seconds, excluding answer-model time; and
- memory and result materialization remain paged and bounded by configuration.

These values become binding only after Phase 0 approves the exact corpus,
hardware, build, and measurement protocol.

## CREXX Contribution Contract

Reusable work developed here follows an incubation ladder:

1. **Workload case:** record the real cREXX-rag operation, scale, failure, and
   current workaround.
2. **Capability test:** reduce it to a deterministic standalone cREXX example
   or benchmark.
3. **Generic design:** remove all RAG vocabulary and define ownership,
   lifecycle, errors, and compatibility.
4. **Local implementation:** build it in a clearly separated incubation area
   with independent tests and documentation.
5. **Application proof:** use it in the cREXX pipeline and record correctness
   and performance evidence.
6. **Donation bundle:** prepare source, tests, docs, benchmark, packaging
   changes, and a paste-ready CREXX handoff.
7. **Upstream adoption:** switch to the installed CREXX facility only after its
   version and compatibility are detectable.

Likely candidates are a production SQLite plugin, parse-once JSON documents,
typed row/cursor records, provider-neutral embeddings and structured LLM
responses, content hashing and file fingerprints, configuration/command
helpers, MCP transport helpers, and—only if measured—a vector backend.

## Non-Goals

- Replacing SQLite with a graph database before the essential typed graph is
  proven insufficient.
- Allowing embeddings or an LLM to assert accepted facts without evidence and
  validation.
- Hiding provider choice behind silent fallback.
- Making a hosted server the source of truth for a local library.
- Big-bang removal of the current native oracle.
- Preserving current C ABI or JSON payload shapes when they obstruct a clean
  cREXX implementation.
- Generalizing every project module into a CREXX library before the application
  has proved a second credible consumer.

## Acceptance And Cutover Rule

The cREXX path becomes the default only when it passes all roadmap gates for:

- versioned storage and reversible migration;
- true incremental source lifecycle and support retraction;
- claim/evidence and ambiguity correctness;
- crash-safe leased work queues;
- qualified local and hosted provider behavior, or an explicitly scoped
  local-only release when no real hosted qualification is authorized;
- lexical/vector/graph evidence quality;
- agent, CLI, and line-command usability;
- generic and Scotland corpus acceptance;
- workload-specific correctness, throughput, latency, and memory evidence; and
- installed-package operation without an undeclared sister-source dependency.

Deletion of the RAG-specific C++ core, C ABI, plugin bridge, or legacy bundle
format requires a separate, explicit approval after that evidence is reviewed.
