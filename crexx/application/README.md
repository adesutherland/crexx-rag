# cREXX Application Modules

Status: Phase 3 product implementation. These modules are application code,
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
```

`raglibrary` defines the library and factory interfaces. `ragjob` defines the
durable-job handle contract. `ragevidence` defines immutable evidence records.
`ragmodel` contains records shared by those contracts. `ragconfig` and
`ragprofile` define typed operational configuration and domain profiles;
`ragregistry` exposes only operator-registered ids.
`ragschema` owns the ordered schema-v2 DDL and canonical migration checksums.
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
rendering. Global options must precede the noun, the 40 approved operations are
closed, registered ids and access names are validated, and command positionals
remain argv values rather than shell text. The stable exit range is 0 through
10. Machine output uses `crexx-rag.command-result/1`; JSON is one result object,
NDJSON is one bounded header plus one line per record, and human output is a
sanitized rendering of the same typed result.

`ragcanonical` owns byte-stable non-secret configuration, profile, and provider
route/privacy projections plus installed SHA-256 use. `ragplanning` creates and
revalidates `crexx-rag.plan/1` envelopes over a pinned read snapshot.
`ragfoundation` is the shared command dispatcher. Its Phase-2 generic ingest,
improve, and proposal command plans remain read-only previews until Phase 6
wires the public surface. `ragingest` now owns the Phase-3 domain plan and
shared initial/incremental reconciler. `ragfolder` discovers bounded folder
observations with sorted relative-path stable keys. The public facade does not
yet expose apply, so the Phase-3 implementation is exercised through typed
Level-G callers and the executable development tutorial.

`ragingest` uses `crexx-rag.ingest-plan/1`. Apply recomputes its source,
generation, parser, policy, raw/text/metadata and revision-envelope bindings
before entering the generation transaction. It atomically publishes immutable
artifact/text/revision/chunk occurrence rows and FTS, re-anchors exact unchanged
support and embeddings, retracts removed dependencies, performs versioned
candidate census/decisions, and queues missing embedding/claim-extraction work.
An identical desired source set returns exact unchanged counters with zero
SQLite writes and zero provider calls.

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
by `p2_10_plan_revalidation.crexx`. Phase-3 ingestion, oracle delta, and real
resume coverage are `p3_01_ingest_scenario.crexx`,
`p3_02_oracle_delta.crexx`, and `p3_03_resume_scenario.crexx`; the executable
tutorial is `crexx/tutorials/phase3_ingestion_scenario.crexx`.

`ragstore` uses a directory bundle containing `library.sqlite` and the
recoverable `manifest.json` projection. SQLite is authoritative. A publication
commits its semantic generation before the manifest is atomically renamed;
read-only opens report stale state without migration or repair. Authorized
recovery rewrites the projection. Orderly read-write close checkpoints WAL and
returns the stable bundle to rollback-journal mode.

## Current Limits

Phase 2 and Gate 2 remain accepted. Phase 3 implements the Level-G ingestion
algorithm and queues missing downstream work; the Phase-2 public facade still
does not expose apply. The native executable remains the oracle. Provider
execution, graph promotion, improvement/proposal workers, retrieval, and
transport adapters remain later items. Sidecar verification retains the
2,147,483,647-byte application ceiling but hashes in fixed memory. Callers that
do not need an interposed ceiling or returned byte count can use the installed
synchronous bounded-memory `rxhash.sha256file` or `sha256filehex` directly.
