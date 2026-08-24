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
import ragfoundation
import ragingest
import ragfolder
import ragclaims
import ragimprove
import ragwork
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
`ragschema` owns the ordered schema-v3 DDL and canonical migration checksums.
Migrations 1 and 2 retain the accepted semantic store; migration 3 adds only
the controller/worker runtime registry.
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
rendering. Global options must precede the noun, the 43 approved operations are
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
secret reference. Apply re-plans before one transaction creates the job, items,
and immutable budget policy. External proposals always enter typed review.

`ragwork` owns database-clock claims, leases, monotonic fences, attempts,
heartbeats, retry/backoff/dead-letter, cooperative cancellation, pause/resume/
drain/status, and admission reservations. `.ragworkprovider` is the
provider-neutral Level-G interface. A worker reserves worst-case usage before
calling it, settles actual usage, then applies the returned proposal through
the same deterministic fenced claim path.

`ragprocess` owns the application process framework. One controller starts a
bounded number of `crexx-rag` OS processes through the public cREXX child-
process channel. Every controller and worker opens its own SQLite connection,
registers host/PID/start-token identity, heartbeats through
`runtime_instances`, and records terminal state. Heartbeats determine
active/stale classification; a local PID probe is diagnostic only. Independent
application instances can list, inspect, drain, and explicitly prune runtime
rows. The current worker body is deliberately `framework-idle`; provider and
ingestion-item processing are attached in the next Gate-3R slice.

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
`config/google-gemini.conf`; it uses only `env:GEMINI_API_KEY` and deliberately
leaves current Google model selection to the operator. Unknown or duplicate
keys, literal secrets, executable module paths, unsafe routes, traversal, and
out-of-range values fail before any provider call.

```sh
<prefix>/libexec/crexx-rag/crexx-rag \
  --config-file <prefix>/share/crexx-rag/application/config/google-gemini.conf \
  --profile generic-profile --format json doctor
```

The human CLI may select a file explicitly. MCP loads one operator-selected
file at startup and tools cannot replace it.

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
termination, stale/PID classification, and explicit pruning. Phase-3
ingestion, oracle delta, and real
resume coverage are `p3_01_ingest_scenario.crexx`,
`p3_02_oracle_delta.crexx`, and `p3_03_resume_scenario.crexx`; the executable
tutorial is `crexx/tutorials/phase3_ingestion_scenario.crexx`. Phase-4 claim
and worker coverage is `p4_01_claims_scenario.crexx` and
`p4_02_worker_scenario.crexx`; its executable tutorial is
`crexx/tutorials/phase4_improvement_scenario.crexx`.
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
Recurring QA uses deterministic providers and symbolic hosted
secret references. The bounded Phase-5 hosted quality and Phase-7 external
generation/embedding harnesses pass, but cREXX hosted response completion
remains unreliable. `worker.start`, `worker.run`, list, status, drain, and prune
now dispatch through the installed application framework, but `worker.run` is
still `framework-idle`: it does not yet bind an installed production
`.ragworkprovider`, and queued extraction/embedding items lack their public
processors. Those processing gaps keep Gate 3R open. Sidecar
verification retains the
2,147,483,647-byte application ceiling but hashes in fixed memory. Callers that
do not need an interposed ceiling or returned byte count can use the installed
synchronous bounded-memory `rxhash.sha256file` or `sha256filehex` directly.
