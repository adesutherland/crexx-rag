# cREXX-Only Programme Review Findings

Review snapshot: 2026-07-26.

This is the evidence summary behind the cREXX-only specification and roadmap.
It reviews the live `crexx-rag` checkout and the sister CREXX checkout. It is a
point-in-time assessment, not a substitute for the Phase-0 reproducible evidence
bundle.

## Reviewed State

| Item | Reviewed state |
| --- | --- |
| `crexx-rag` | `main`, commit `97cd87e`; current debug validation 11/11 passed |
| sister CREXX | `develop`, commit `537d3b3d2`; performance programme active |
| installed CREXX | `crexx-1.0.0-beta.3+local.g86006fac18a8.dirty`, built 2026-07-14 |
| current native scale | approximately 6,865 lines core, 2,783 CLI, 1,754 MCP, 1,885 RXPA bridge, plus cREXX controllers/scripts/tests |

Local worktree modifications were treated as user-owned and were not changed by
the review.

## Overall Finding

The original cREXX application vision is credible, but the justification is not
"CREXX is now fast, therefore translate the files." The stronger conclusion is:

- the application has discovered a valuable algorithm and evidence contract;
- recent CREXX optimization makes a serious application implementation
  plausible;
- the hard unknowns are structured storage/data movement, provider surfaces,
  lifecycle correctness, and operational durability more than scalar arithmetic;
- the current native system is an unusually useful oracle and stress workload;
  and
- generic missing facilities can be incubated here, proven by the application,
  and donated back to CREXX.

The migration should therefore preserve semantics, correct known lifecycle
defects, and deliberately produce CREXX capability evidence.

## Current Algorithm: What Worked

### 1. Source-aware ingestion and chunking

The native core stores source type, confidence, captured time, event time, and
format-aware chunks. The chunker has distinct plain, Markdown, and Rexx-oriented
paths (`core/chunker.cpp`; `core/ragcore.cpp`). This is a stronger foundation
than treating every passage as an anonymous vector.

### 2. Corpus census before deep extraction

The hybrid controller counts proper-name-like candidates, known-concept
matches, and relation cues before choosing expensive work
(`crexx/profiles/history/hybrid_ingest_extract.crexx`). Stage 1b collates
normalized candidates and records keep/junk/ambiguous/type/alias decisions
(`crexx/profiles/history/stage1b_adjudicate_candidates.crexx`).

This is the central algorithmic success: a per-corpus registry provides context
that an isolated chunk does not. The expensive model sees a ranked, already
partly understood subset rather than every chunk equally.

### 3. Weak mentions and strong claims are conceptually separate

Stage 2 seeds accepted concepts, evidence-chunk nodes, and `mentioned-in` links.
It treats replayed `candidate_mention_id` support as a no-op. Ambiguous names can
remain ambiguity nodes linked to several candidates.

The target should strengthen this distinction by normalizing claim support and
retraction rather than collapsing support into edge metadata.

### 4. Ranked deep extraction

The current queue score combines concept count, support, type diversity,
relation cues, rare concepts, ambiguity, priority, evidence class, and shape
penalties (`core/ragcore.cpp`). This demonstrated that expensive extraction can
be allocated by expected information value.

The current numeric baseline is approximately:

```text
2.0 * concept_count
+ 0.7 * min(support_count, 25)
+ 4.0 * type_diversity
+ 6.0 * relation_cues
+ 3.0 * rare_concepts
+ 5.0 * ambiguity_risk
+ 0.05 * maximum_priority
+ type_bonus + bridge_bonus
- evidence_class_penalty - text_shape_penalty
```

The policy currently leaks some history-specific weights into native code. The
formula should become a versioned cREXX profile baseline, then evolve with
novelty, redundancy, bridge value, and source quality.

### 5. Proposals are gated before graph writes

The Stage 3 controller prefers simple tagged proposal records, checks profile
types and confidence, promotes accepted nodes/relationships, and records
attempts (`crexx/profiles/history/stage3_extract_queue.crexx`). Generic repair
queues exist for endpoint, ambiguity, type, and external extraction work.

Validation is not yet strong enough, but the architecture principle is correct:
a provider proposes; deterministic cREXX policy accepts, rejects, or reviews.

### 6. Source-bound agent QA

MCP `library_answer_evidence` distinguishes retrieved passages, accepted graph
claims, and graph leads. The archived Scotland QA instructions go further by
requiring two to five focused questions, chronology/ambiguity analysis, and an
explanation of what a path proves
(`prompts/archive/native-v1/scotland-qa-agent-test-AGENTS.md`).

The observations recorded in the archived
[Scotland QA test notes](archive/native-v1/scotland-qa-test-notes.md) report that this
agent-led multi-query method was more useful than one broad search. Phase 0 must
turn that qualitative finding into a blinded judgement set before it becomes an
accepted comparative claim; the behavior should meanwhile inform the generic
evidence contract and skill.

### 7. Representative workload evidence

The Scotland work is not a synthetic toy:

- 5,977 Stage-1 chunks produced 6,358 distinct candidates and 20,697 mentions;
- Stage 2 materialized more than 23,000 mention evidence rows;
- Stage 2b ranked 9,080 chunks;
- the first 100-item Stage-3 batch took about 82.7 minutes with 99 processed,
  one skipped, 981 node proposals, and 316 relationship proposals; and
- the two-volume corpus reached 11,684 Nomic embeddings at dimension 768.

These figures provide migration fixtures and capacity shapes. They are not
throughput promises for a different model or cREXX implementation.

## Current Architecture: What Must Change

### Source revisions and stable identity

Same-URI ingest currently upserts the document, deletes all old chunks, and
inserts new row-id-based chunks (`core/ragcore.cpp`). Embeddings and candidate
mentions cascade, but graph evidence, claims, and queue/attempt history do not
have a complete retraction lifecycle. Source deletion has the same risk.

Required correction: immutable source revisions, content/span-based stable
chunk identities, candidate-revision publication, and derived support
reconciliation.

### First-class claims and support

Edges currently combine relationship identity, presentation, accumulated
support, and metadata. Entity upsert can overwrite canonical fields. There is
no normalized support identity, claim history, supersession, conflict, or
retraction.

Required correction: claims identified by typed semantic endpoints/qualifiers;
independent idempotent support records; canonical conflict review; derived
confidence/state; and explicit ambiguity/conflict.

### Crash-safe jobs

Stage 3 selects pending work without an atomic claim, performs graph writes, and
records an attempt afterward. Work rows have no worker, lease, heartbeat, retry
schedule, or dead-letter state. The background script protects only a single
local worker with a filesystem lock.

Required correction: durable job plans, atomic claim/lease, semantic
idempotency keys, transactional promotion/finalization, bounded retry, forced
termination tests, and public status.

### Retrieval quality

Entity anchors are naive substring matches; graph expansion loads broad graph
state and often traverses directionally typed edges as undirected; hybrid search
interleaves lexical and vector lists rather than fusing calibrated/rank signals;
and returned graph paths are not consistently resolved back to ranked support
passages.

The current evidence tool advertises a retrieval plan but executes one search,
and its category heuristics are not yet a full truth model. The successful agent
method already compensates by issuing focused follow-ups.

Required correction: deterministic query variants, alias/entity resolution,
directed typed graph-to-support retrieval, rank fusion, diversity/context
budget, temporal/source quality, stable citations, and genuinely distinct
passage/claim/lead/gap categories.

### Internal data plane

The RAG C ABI and RXPA bridge reopen a library for most calls and serialize
whole results through fixed 1 MiB JSON buffers. Vectors cross as comma-separated
text. Several read-like CLI operations open read-write, and a read-write open
may rewrite the manifest or evolve the schema.

Required correction: retained typed SQLite connection/statement/cursor handles,
cREXX records and pages, strict read-only opens, JSON only at external
boundaries, and no corpus-sized result materialization.

### Policy separation

The current native ranking has Scotland/history-oriented type bonuses, and the
legacy generic controller contains domain-specific filtering/defaults. Profile
membership sometimes relies on substring tests.

Required correction: one typed profile contract, independent profile modules,
exact set membership, versioned weights/prompts/validators, and zero
profile-name branching in generic algorithms.

## Sister CREXX Review

Paths in this section refer to the sibling checkout
`/Users/adrian/CLionProjects/CREXX` at the review snapshot.

### Performance direction

The live worktree `performance/ROADMAP.md` records PERF2-01 through PERF2-04
complete and PERF2-05 at a P05-SA1 selection stop marked `decision required`.
P05-CF1 is complete; the new uncommitted P05-SA1 evidence recommends separate
descriptor-materialization and relink rungs for user selection. Accepted work
includes major improvements on selected dispatch, receiver-inlining, Level B
BIF, and constant-call workloads, with full Debug-suite gates at their
acceptance points.

For this architecture programme, the project owner has directed planning to
assume that the ongoing PERF2 programme completes successfully. The cREXX-rag
roadmap therefore does not wait on or interfere with that work. Its own vertical
slices still measure SQLite/data movement, provider, graph, vector transfer, and
end-to-end application costs because PERF2 success cannot select those product
boundaries by itself.

Examples include roughly 52.8% median improvement for the selected List receiver
workload and roughly 95% for a selected two-million constant user-function-call
workload. Those are meaningful enablers. They are not a post-programme,
same-session portfolio proving dynamic RAG, SQLite, JSON, graph, and provider
workloads.

A non-retained audit-only Release probe on this machine performed the arithmetic
shape of 11,684 by 768 typed-array multiply/add operations quickly enough to make
exact pure-cREXX cosine/top-k worth a formal PoC. It is not baseline evidence and
the roadmap requires a dated reproduction with generated instructions and raw
timings. It also did not answer vector blob transfer, decode, selection, or
memory cost.

### Useful language and library foundations

- Level B has arrays, binary-memory helpers, string/regex/file libraries, and a
  compiler increasingly able to inline and partially evaluate ordinary code.
- Level G `rxfnsg` already implements cREXX LLM clients for Ollama, OpenAI,
  Anthropic, and Gemini over `rxhttp`/`rxjson`.
- CREXX supports safer argv/stem command dispatch, so new orchestration should
  not quote arbitrary source text into shell strings.
- Dynamic plugins and address environments exist and are the right mechanism
  for a generic SQLite facility.

### Blocking or shaping gaps

#### SQLite

The only SQLite integration is `demos/native/sqlite`. It is an embedded native
host demonstration, not an installed dynamic plugin. It has one connection,
text bindings/conversions, SQL/value/result fixed buffers, and pipe/newline row
serialization. The reviewed build lacks the required production FTS5,
transaction/cursor/blob/concurrency surface.

The reviewed Release demo command currently printed `(no output)`, preserved the
literal `VALUE ... INTO ${total}` text, and reported `SCALAR(count) => 0`; its
CTest checks only process success. Inspection indicates that the command
expressions are affected by CREXX implicit-concatenation syntax. This is a
reproducible review observation, not yet a retained performance artifact, and is
both a plugin gap and a valuable language/tooling regression case: Phase 0 must
capture it and examples must assert meaningful output.

#### Installed plugin development

The source tree has RXPA headers/helpers, but the reviewed install does not
provide a complete version-matched external development kit. `crexx-rag`
currently carries a temporary vendored header bridge. A fresh installed-consumer
test must be the packaging gate.

#### Structured data

String/path `rxjson` reparses documents for repeated queries and has correctness
and empty/missing limitations. CREXX's own performance capability ledger lists
parse-once/indexed JSON (CAP-01) and richer owned containers (CAP-02) as future
work. The new application must not reproduce the existing JSON bridge inside
cREXX.

#### Provider completeness

The existing cREXX provider code is the right starting point but lacks the full
application contract: arbitrary OpenAI-compatible base URLs, embeddings and
batch embeddings, structured schema output, message roles, retry/rate-limit
classification, usage/cost, connection reuse/streaming, and cancellation.

#### Hashing, binary files, and concurrency

The reviewed public libraries do not yet expose the required incremental
SHA-256/binary file identity surface. User-level threads/futures and independent
thread-safe VM/plugin contexts are not established. Begin with one durable
worker and test multiple OS processes only after SQLite leases/concurrency work.

## Incubate Here, Donate To CREXX

The project should develop missing generic facilities locally when that is the
fastest route to evidence. The key is to make the separation real.

| Candidate | Why it is generic | First application proof |
| --- | --- | --- |
| `rxsqlite` | typed relational access, cursors, transactions, backup, FTS | schema v2, paged retrieval, leases, concurrent status |
| parse-once `rxjson` | provider/MCP structured data | repeated provider parsing and evidence encoding |
| `rxllm` extensions | normalized local/hosted generate/embed contract | advisory, extraction, embedding roles |
| SHA-256/binary I/O | durable content identity | source revisions and embedding input hashes |
| float32 blob codec | portable numeric storage | 11,684 x 768 vector transfer |
| optional cosine/top-k | general numeric retrieval if measured | exact cREXX/vector backend comparison |
| config/command helpers | reusable typed configuration and dispatch | CLI, `ADDRESS RAG`, profile validation |
| MCP transport helpers | generic JSON-RPC/tool schema handling | typed `structuredContent`, read/write capability advertisement |

Application libraries such as chunking, claim support, hybrid fusion, and
durable queues should first be clean cREXX modules here. Donate them only when a
credible broader contract is clear; do not weaken the application by
prematurely generalizing it.

Every donation candidate needs a generic API, ownership/error semantics,
independent dual-VM tests, installed-consumer test where relevant, docs/example,
representative benchmark, packaging metadata, and a minimized non-RAG
reproducer of the capability need.

For a locally implemented candidate, `README.md` usage documentation and
`SYSTEM.md` maintainer documentation must live beside the source and the
candidate must appear in the [incubation audit](../incubator/README.md).

## Decision

Proceed with Phase 0 and only the bounded Phase-1A vertical slices in
[`crexx-only-implementation-roadmap.md`](crexx-only-implementation-roadmap.md).
Stop at Gate 1A before capability hardening or broad translation. The first
selection gate must decide:

- the final typed SQLite/cREXX record boundary;
- whether parse-once JSON is sufficient at external boundaries;
- the provider interface and HTTP gaps;
- pure cREXX versus generic accelerated vector search;
- single- versus multi-process worker scope; and
- the exact correctness/performance thresholds for production migration.

That path uses the application in precisely the way intended: as a useful
knowledge product and as a rigorous, evidence-producing test of cREXX.
