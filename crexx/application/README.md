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
import ragstore
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

The example operator registry is constructed in
`config/operator_registry.crexx`. It registers `architecture-local`,
`generic-profile`, and `it-architecture-profile` from independent modules.
Applications receive the constructed registry and select ids; there is no
runtime module-path argument.

The compiled consumers are
`crexx/application/tests/p2_01_contract_consumer.crexx` and
`crexx/application/tests/p2_02_config_consumer.crexx`. The storage lifecycle
matrix is `crexx/application/tests/p2_03_store_scenario.crexx`.

`ragstore` uses a directory bundle containing `library.sqlite` and the
recoverable `manifest.json` projection. SQLite is authoritative. A publication
commits its semantic generation before the manifest is atomically renamed;
read-only opens report stale state without migration or repair. Authorized
recovery rewrites the projection. Orderly read-write close checkpoints WAL and
returns the stable bundle to rollback-journal mode.

## Current Limits

`P2-01` freezes the Level G object vocabulary and `P2-02` configuration loading
is side-effect free with symbolic `env:NAME` references only. `P2-03` implements
the storage foundation but not version-1 import, backup/restore, repository
APIs, command adapters, provider execution, plan validation, or job workers.
Sidecars are represented as an empty manifest set until `P2-05`.
