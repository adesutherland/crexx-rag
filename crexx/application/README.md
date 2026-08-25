# cREXX Application Modules

Status: Phase 7 qualified staged public product implementation; cutover deferred. These modules are application code,
not generic CREXX donation candidates.

## Use

Import the public contract modules from a Level G cREXX application:

```text
options levelg
import ragmodel
import ragevidence
import ragjob
import raglibrary
import ragconfig
import ragconfigfile
import ragprofile
import ragregistry
import ragschema
import ragfile
import ragstore
import ragcompat
import ragbackup
import ragrepository
import ragcommand
import ragcanonical
import ragplanning
import ragtrace
import ragfoundation
import ragingest
import ragfolder
import ragclaims
import ragimprove
import ragwork
import ragapplicationprovider
import ragproviderdiagnostics
import ragquery
import ragembedding
import ragretrieval
import ragevidencejson
```

`raglibrary` defines the library and factory interfaces. `ragjob` defines the
durable-job handle contract. `ragevidence` defines immutable evidence records.
`ragmodel` contains records shared by those contracts. `ragconfig` and
`ragprofile` define typed operational configuration and domain profiles;
`ragregistry` exposes only operator-registered ids.
`ragschema` owns the ordered schema-v5 DDL and canonical migration checksums.
Migrations 1 and 2 retain the accepted semantic store; migration 3 adds the
controller/worker runtime registry; migration 4 adds the canonical durable
work-input envelope to job items; migration 5 adds provider charging basis,
durable external thread/turn/output recovery and Codex turn reservations.
`ragstore` owns SQLite-backed library initialization/open/close, migrations,
published generations, read snapshots, manifest publication/recovery,
verification, and rollback ordering.
`ragcompat` owns read-only version-1 inspection and side-by-side import.
`ragbackup` owns immutable sidecar publication, generation-pinned online backup,
and fresh-folder restore.
`ragrepository` owns bounded keyset pages over pinned read snapshots. Its static
registry covers sources, source artifacts, source revisions, normalization
maps, chunk contents and occurrences, published generations, concepts, claims,
support and lineage, embedding occurrences, jobs and items, attempts, and
reviews. Repository names select fixed SQL; cursors are always bound values and
cannot select arbitrary tables or query text.
`ragcommand` owns the target argv grammar and transport-neutral result
rendering. Global options must precede the noun, the 44 approved operations are
closed, registered ids and access names are validated, and command positionals
remain argv values rather than shell text. The stable exit range is 0 through
10. Machine output uses `crexx-rag.command-result/1`; JSON is one result object,
NDJSON is one bounded header plus one line per record, and human output is a
sanitized rendering of the same typed result.

`ragcanonical` owns byte-stable non-secret configuration, profile, and provider
route/privacy projections plus installed SHA-256 use. `ragplanning` creates and
revalidates `crexx-rag.plan/1` envelopes over a pinned read snapshot.
`ragfoundation` supplies generic lifecycle and canonical planning operations;
`ragproduct` is the shared Phase-6 product dispatcher used by the CLI, ADDRESS
RAG and MCP adapters. `ragingest` owns the Phase-3 domain plan and
shared initial/incremental reconciler. `ragfolder` discovers bounded folder
observations with sorted relative-path stable keys. The public facade exposes
exact reviewed ingest/improve/proposal apply and capability-gated job/review
operations without exposing raw SQL or graph edits.

`ragingest` uses `crexx-rag.ingest-plan/1`. Apply recomputes its source,
generation, parser, policy, raw/text/metadata and revision-envelope bindings
before entering the generation transaction. It atomically publishes immutable
artifact/text/revision/chunk occurrence rows and FTS, re-anchors exact unchanged
support and embeddings, retracts removed dependencies, performs versioned
candidate census/decisions, and queues missing embedding/claim-extraction work.
An identical desired source set returns exact unchanged counters with zero
SQLite writes and zero provider calls.

`ragclaims` owns Phase-4 concept/alias/ambiguity promotion, directional and
time-scoped claims, independent support, retraction, bounded traversal,
provider-neutral proposals, deterministic validation/review routing, and the
versioned explainable extraction rank. Provider output is immutable input to
this policy; it never writes canonical graph rows directly.

`ragimprove` owns canonical `crexx-rag.improve-plan/1` and
`crexx-rag.external-proposal-plan/1` values. Improvement triggers select and
rank deduplicated content, bind exact item/call/token/cost/time/in-flight/retry
budgets, privacy, route, prompt/policy/config versions, and an empty or `env:`
secret reference. Configured apply resolves `role.extractor` and persists each
selected chunk as an immutable `crexx-rag.work-input/1` envelope before a
worker can claim it. The configured-input digest is also the durable work
identity, so an already queued or completed selection is a zero-write,
zero-provider-call replay. Apply re-plans before one transaction creates the
job, items, and immutable budget policy. External proposals always enter typed
review.

`ragwork` owns database-clock claims, leases, monotonic fences, attempts,
heartbeats, retry/backoff/dead-letter, cooperative cancellation, pause/resume/
drain/status, and admission reservations. `.ragworkprovider` is the
provider-neutral Level-G interface. A worker reserves the item's persisted
ceiling before calling it, settles actual usage, then applies the returned
proposal or embedding through the same deterministic fenced path. `job retry`
can requeue one exact closed dead letter after an operator correction; it
preserves prior attempts and requires a terminal job with zero reservations.

`ragprocess` owns the application process framework. One controller starts a
bounded number of `crexxrag` OS processes through the public cREXX child-
process channel. Every controller and worker opens its own SQLite connection,
registers host/PID/start-token identity, heartbeats through
`runtime_instances`, and records terminal state. Heartbeats determine
active/stale classification; a local PID probe is diagnostic only. Independent
application instances can list, inspect, drain, and explicitly prune runtime
rows. `worker.run` now builds `ragapplicationprovider` from the immutable job
snapshot and dispatches extraction/embedding claims through `ragwork`; its
processor identity is `application-ingestion-v1`.

`ragtrace` owns sanitized progress events. The native CLI defaults human output
to ANSI progress on a colour terminal and plain progress otherwise;
`--progress off|plain|ansi` remains explicit control. Progress writes only
stderr, while JSON/NDJSON stdout remains the stable command result. ANSI is
accepted only for human output.

`ragquery` owns deterministic `crexx-rag.query-plan/1` values: normalized
questions, exact phrase/prefix variants, profile/database aliases, bounded
spelling candidates, comparison/time/relationship intent, ambiguity, term
statistics and canonical SHA-256 identity. It does not call a provider.

`ragembedding` registers immutable provider/model/dimension/envelope profiles,
checks privacy and route before every call, attaches compatible reusable
embeddings, batches and resumes missing work, and publishes checksum-bound
`crexx-rag.rxvector-generation/1` `.rxvec` sidecars atomically. `ragretrieval`
combines bounded FTS/context, installed exact packed `rxvector`, directed graph
paths resolved to support, and inspectable reciprocal-rank fusion. Vector and
graph proximity remain leads rather than accepted claims.

`ragevidencejson` serializes the typed records as bounded
`crexx-rag.evidence/1`, `crexx-rag.retrieval-result/1` and
`crexx-rag.answer-context/1` JSON. Stable citations bind library, source,
immutable revision and UTF-8 byte span and can be resolved historically.

`ragrepositoryrecord` is the shared typed page envelope. `identity`,
`parent_identity`, and `related_identity` retain graph/storage identity;
`name`, `category`, `state`, `value`, and `detail` project each table's scalar
and JSON metadata; `payload` retains exact artifact/vector bytes; `ordinal` and
`metric` carry repository-specific integer values; and the visibility bounds
are explicit. A page records its pinned semantic generation and an opaque next
cursor. The repository never returns an unbounded corpus array.

`ragfile` is the one narrow Level-B foundation exception. Level G has no binary
file-read API with a caller-controlled byte ceiling/count and no binary write
surface, so this module uses the VM's `freadb`/`fwriteb` instructions.
`sha256filebounded` feeds fixed 64 KiB chunks into immutable `rxhash` state and
never accumulates the file. `readbinaryfilebounded` accumulates only a single
source artifact up to the explicit application ceiling so the Level-G folder
connector can normalize and chunk it. The module contains no source selection,
storage, or lifecycle policy.

The example operator registry is constructed in
`config/operator_registry.crexx`. It registers `architecture-local`,
`generic-profile`, and `it-architecture-profile` from independent modules.
Applications receive the constructed registry and select ids; there is no
runtime module-path argument.

## Human configuration

`ragconfigfile` reads bounded `crexx-rag.config/1` text into the existing typed
`ragconfig` contract. The maintained installed example is
`config/google-gemini.conf`; the Phase-3 tutorial additionally supplies Codex
plus local llama.cpp and Google qualification files. Configuration selects a
provider by kind and an explicit charging basis. Gemini uses only
`env:GEMINI_API_KEY`; Codex delegates managed authentication to App Server and
must not contain a credential reference. Unknown or duplicate keys, literal
secrets, executable module paths, unsafe routes, traversal, and out-of-range
values fail before any provider call.

The human CLI selects an explicit `--config-file` first, then
`CREXX_RAG_CONFIG`, then `./crexx-rag.conf`. Stateful commands default to
`./library`; a sole configured profile is selected automatically. The enduring
short flow is therefore `crexxrag init`, `crexxrag ingest`, `crexxrag improve`,
and `crexxrag query '<question>'`. Canonical nouns/verbs and JSON/NDJSON remain
available for scripts and agents. MCP loads one operator-selected file at
startup and tools cannot replace it.

The compiled consumers are
`crexx/application/tests/p2_01_contract_consumer.crexx` and
`crexx/application/tests/p2_02_config_consumer.crexx`. The storage lifecycle
matrix is `crexx/application/tests/p2_03_store_scenario.crexx`; version-1
conversion is covered by `p2_04_v1_compatibility.crexx`; backup/restore,
sidecars, binary hashing, and crash ordering are covered by
`p2_05_backup_scenario.crexx`; pinned pagination and repository invariants are
covered by `p2_06_repository_scenario.crexx`.
Command parsing and result rendering are covered by
`p2_07_command_contract.crexx`; lifecycle dispatch is covered by
`p2_08_foundation_facade.crexx`; canonical planning and revalidation are covered
by `p2_10_plan_revalidation.crexx`. Human text configuration is covered by
`p3r_01a_config_file`, including the linked CLI and fixed MCP startup.
`p3r_01b_process_framework` runs the linked application on both VMs and covers
two live child workers, separate-process observation, durable drain, forced
termination, stale/PID classification, and explicit pruning. Phase-3 product
ingestion is covered by `p3r_02_gemini_ingestion`: two fresh libraries use a
deterministic four-request Gemini loopback for extraction plus 768-dimensional
embeddings. The test validates/promotes each claim, publishes the exact vector
generation, reconciles each job, covers canonical machine commands plus the
human three-command flow, exercises concurrent two-process workers, and
returns concise human output and stable JSON without retaining its synthetic
credential. It also proves an identical replay starts no job or workers and
that a failed child produces an actionable controller error.
`p3r_03_provider_durability` proves completed Codex output reuse and
subscription reservations in four compiler/VM cells. `p3r_04_codex_protocol`
uses a deterministic App Server JSONL fixture in the same four cells to cover
managed-account status, schema-constrained turns, usage events and cleanup.
Phase-3 ingestion, oracle delta, and real
resume coverage are `p3_01_ingest_scenario.crexx`,
`p3_02_oracle_delta.crexx`, and `p3_03_resume_scenario.crexx`; the executable
tutorial is `crexx/tutorials/phase3_ingestion_scenario.crexx`. Phase-4 claim
and worker coverage is `p4_01_claims_scenario.crexx` and
`p4_02_worker_scenario.crexx`; the latter verifies the configured immutable
work-input envelope in both VM families. `p4r_01_gemini_improvement` exercises
the linked application and human `crexxrag improve` command against a
deterministic Gemini service, including a zero-call replay. The maintained
human tutorial is `docs/tutorials/phase-4-improvement.md`; the frozen scenario
fixture remains `crexx/tutorials/phase4_improvement_scenario.crexx`.
Phase-5 focused planning, embeddings, hybrid retrieval, evidence, baselines and
judgements are covered by `p5_01_retrieval_scenario.crexx`; its executable
tutorial is `crexx/tutorials/phase5_retrieval_scenario.crexx`.
Phase-6 public binding coverage is `p6_02_address_scenario.crexx` and
`p6_03_mcp_scenario.crexx`; the installed human/agent walkthrough is
`docs/tutorials/phase-6-surfaces.md`.

`ragstore` uses a directory bundle containing `library.sqlite` and the
recoverable `manifest.json` projection. SQLite is authoritative. A publication
commits its semantic generation before the manifest is atomically renamed;
read-only opens report stale state without migration or repair. Authorized
recovery rewrites the projection. Orderly read-write close checkpoints WAL and
returns the stable bundle to rollback-journal mode.

## Current Limits

Phase 2 through Gate 6 are accepted for their recorded macOS scope. Phase 3
implements ingestion, Phase 4 claim/review/improvement/workers, Phase 5
retrieval/evidence, and Phase 6 the staged public CLI, ADDRESS, MCP, packaging
and skills. Phase 7 selected reject/defer, so the native executable remains the
default oracle.
Recurring QA uses deterministic providers and symbolic hosted secret
references. The Gate-3R product path now binds Gemini generation/embedding,
contained Codex structured generation and OpenAI-compatible local embeddings,
owns both queued item types, publishes the exact embedding profile after a
successful filtered job, and treats an unchanged plan as a successful no-op
without manufacturing a job or starting workers. Worker/controller failures
retain actionable child-process diagnostics. A pristine bounded live replay
completed at first attempt with exactly one Gemini generation call and one
Gemini embedding call. The Phase-3 addendum separately completed one Codex
turn through managed ChatGPT authentication and one local 768-dimensional
Nomic embedding through llama.cpp; both unchanged replays made no provider
call.
The Phase-4 application extension carries the configured provider contract
into improvement: the human command plans, reviews, queues, runs the configured
OS workers, and reports the completed job. Both Gemini and Codex extraction
have completed the bounded macOS path. Local embeddings remain a separate
Phase-3 ingestion concern, and improvement-only work makes no vector-
publication claim.
Exact Linux, clean Release, sanitizer, and cutover qualification remain open.
Sidecar verification retains the
2,147,483,647-byte application ceiling but hashes in fixed memory. Callers that
do not need an interposed ceiling or returned byte count can use the installed
synchronous bounded-memory `rxhash.sha256file` or `sha256filehex` directly.
