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

`ragrepositoryrecord` is the shared typed page envelope. `identity`,
`parent_identity`, and `related_identity` retain graph/storage identity;
`name`, `category`, `state`, `value`, and `detail` project each table's scalar
and JSON metadata; `payload` retains exact artifact/vector bytes; `ordinal` and
`metric` carry repository-specific integer values; and the visibility bounds
are explicit. A page records its pinned semantic generation and an opaque next
cursor. The repository never returns an unbounded corpus array.

`ragfile` is the one narrow Level-B foundation exception. Level G has no binary
file-read API in the consumed CREXX package, so this module uses the VM's
`freadb`/`fwriteb` byte instructions and delegates SHA-256 to installed
`rxhash`. It contains no product policy; every application, lifecycle, fixture,
and test consumer remains Level G. The four-cell P2-05 proof covers embedded
NUL and invalid-UTF-8 bytes, the bounded reader, and exact SHA-256.

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
`p2_07_command_contract.crexx`.

`ragstore` uses a directory bundle containing `library.sqlite` and the
recoverable `manifest.json` projection. SQLite is authoritative. A publication
commits its semantic generation before the manifest is atomically renamed;
read-only opens report stale state without migration or repair. Authorized
recovery rewrites the projection. Orderly read-write close checkpoints WAL and
returns the stable bundle to rollback-journal mode.

## Current Limits

`P2-01` freezes the Level G object vocabulary and `P2-02` configuration loading
is side-effect free with symbolic `env:NAME` references only. `P2-03` implements
the storage foundation, `P2-04` adds version-1 conversion, and `P2-05` adds
sidecar publication plus backup/restore. `P2-06` adds the internal paged
repository API, and `P2-07` freezes command/result contracts. `P2-07` does not
dispatch lifecycle behavior or replace the native executable; the first
implemented cREXX commands arrive in P2-08. Provider execution, plan validation,
and job workers remain later items. Sidecar verification currently reads at
most 2,147,483,647 bytes into
memory because installed `rxhash.sha256` is one-shot; incremental/file hashing
remains a separately scoped CREXX capability backlog item.
