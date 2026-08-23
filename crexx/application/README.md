# cREXX Application Modules

Status: Phase 2 product implementation. These modules are application code,
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
`ragfoundation` is the shared command dispatcher. Its ingest, improve, and
proposal planning operations are successful read-only previews; matching apply
operations validate hostile JSON and the reviewed digest, then truthfully stop
as unavailable with `enqueued=false` until later roadmap phases implement jobs.

`ragrepositoryrecord` is the shared typed page envelope. `identity`,
`parent_identity`, and `related_identity` retain graph/storage identity;
`name`, `category`, `state`, `value`, and `detail` project each table's scalar
and JSON metadata; `payload` retains exact artifact/vector bytes; `ordinal` and
`metric` carry repository-specific integer values; and the visibility bounds
are explicit. A page records its pinned semantic generation and an opaque next
cursor. The repository never returns an unbounded corpus array.

`ragfile` is the one narrow Level-B foundation exception. The public CREXX file
hash routines do not expose the application's byte count and pre-hash size
ceiling, and Level G has no equivalent binary write surface, so this module
uses the VM's `freadb`/`fwriteb` byte instructions. Its bounded reader feeds
fixed 64 KiB chunks into immutable `rxhash.sha256init`, `sha256update`, and
`sha256finalhex` state; it never accumulates the complete file. It contains no
storage or lifecycle policy; every application, lifecycle, fixture, and test
consumer remains Level G. The four-cell P2-05 proof covers embedded NUL and
invalid-UTF-8 bytes, the application ceiling, exact incremental SHA-256, and
direct `rxhash.sha256file`/`sha256filehex` equivalence.

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
by `p2_10_plan_revalidation.crexx`.

`ragstore` uses a directory bundle containing `library.sqlite` and the
recoverable `manifest.json` projection. SQLite is authoritative. A publication
commits its semantic generation before the manifest is atomically renamed;
read-only opens report stale state without migration or repair. Authorized
recovery rewrites the projection. Orderly read-write close checkpoints WAL and
returns the stable bundle to rollback-journal mode.

## Current Limits

`P2-01` through `P2-10` now implement the bounded Level-G Phase-2 foundation:
contracts, registered configuration, schema-v2 storage, version-1 conversion,
backup/restore, paged repositories, command/result contracts, lifecycle and
configuration-only diagnostic dispatch, and canonical plan/revalidation.
The native executable remains the oracle and no plan is enqueued. Provider
execution, ingestion algorithms, improvement/proposal execution, workers, and
transport adapters remain later items. Sidecar verification retains the
2,147,483,647-byte application ceiling but hashes in fixed memory. Callers that
do not need an interposed ceiling or returned byte count can use the installed
synchronous bounded-memory `rxhash.sha256file` or `sha256filehex` directly.
