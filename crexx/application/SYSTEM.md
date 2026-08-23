# cREXX Application System Notes

## Boundary

The directory owns product-facing Level G contracts and, as Phase 2 proceeds,
the cREXX implementations behind them. It may consume installed CREXX
foundation modules and separately qualified generic plugins. It must not call
the native-v1 RAG bridge, shell through the CLI, or import product behavior from
the incubation tree.

The current dependency direction is:

```text
ragmodel <- ragevidence
ragmodel <- ragjob
ragmodel + ragevidence + ragjob <- raglibrary
ragmodel <- ragconfig + ragprofile <- ragregistry
ragconfig + ragprofile + ragregistry <- operator registry
ragconfig + ragprofile <- ragcanonical -> installed rxhash
ragschema <- ragstore -> installed SQLite boundary + rxjson + system
ragstore + ragregistry + ragcanonical <- ragplanning
ragcommand + lifecycle modules + ragplanning <- ragfoundation
```

`raglibrary` coordinates public operations. `ragjob` is a returned durable-work
handle. `ragevidence` is the stable evidence packet object; passages, accepted
claims, support, ambiguity, leads, and gaps remain distinct.

`ragconfig` validates source sets, provider routes, symbolic secret references,
budgets, and the currently qualified single-worker scope. `ragprofile` validates
domain types, relationships, aliases, chunk policy, ranking weights, prompt
identities, and validator identities. `ragregistry` receives already
constructed operator modules and exposes typed id lookup only. Dynamic module
loading is intentionally absent from the agent-facing boundary.

`ragschema` owns two ordered migrations. Migration 1 establishes library,
configuration, immutable published-generation, and publication-event state.
Migration 2 establishes the complete schema-v2 source, evidence, graph,
embedding, job, attempt, event, and review table set. Checksums are SHA-256 over
the exact ordered SQL statements with an LF after each statement; the CMake
proof recomputes them from the source before compiling consumers.

`ragstore` consumes only the generic SQLite mechanism. It keeps one monotonic
generation allocator, stages semantic rows inside the same transaction as a
generation record, commits the SQLite generation pointer, and only then
publishes the manifest using `manifest.json.new` plus atomic rename. Readers
start a SQLite transaction and pin `library_meta.published_generation` before
applying visibility bounds. A read-only open never migrates or repairs.

`ragplanning` opens a generation-pinned read transaction, recomputes the exact
registered effective-config/profile hashes, and fingerprints visible current
source revisions plus active reservations. It separately hashes provider
route/privacy declarations. The fixed canonical plan encodes those bindings,
the registered action, required capability, creation epoch, and exact one-hour
expiry. Validation first verifies the caller's reviewed digest, then parses and
strictly reconstructs the canonical object before comparing a fresh context.
The plan/apply foundation path never inserts a job; later phases own enqueue and
execution after Gate approval.

Rollback targets a published ancestor. While holding the SQLite writer lock it
first publishes a projection of that already-committed older generation, then
rebuilds FTS for the target visibility snapshot, moves the authoritative
pointer, and appends an audit event. A crash between those steps can therefore
leave the manifest behind SQLite, never ahead. The next-generation allocator
remains monotonic.

Orderly writer close checkpoints WAL and attempts to return the stable bundle
to rollback-journal mode. This makes a closed-bundle read-only open byte-for-
byte zero-write. Abrupt termination intentionally retains WAL; read-only crash
inspection may update SQLite's transient `-shm` lock page but cannot change the
database, WAL, manifest, temporary manifest, or migration state.

## Contract Discipline

- All modules and their consumers use Level G.
- Public methods return nominal records or interfaces, not JSON strings.
- Canonical plan JSON is the reviewed content-addressed authority; other JSON
  belongs at CLI/MCP transport adapters.
- Evidence claims remain directional and independently supported.
- Vector or graph proximity remains a lead, never accepted support.
- Later implementations must preserve truthful unsupported/error states.
- A facade is added only for a real public or transport contract, never for a
  language-level crossing.

## Verification

CTest `p2_01_application_contract` compiles every module and the consumer in
optimized and non-optimized modes, then runs the contract on `rxvme` and
`rxbvm`. CTest `p2_02_config_contract` applies the same four-cell matrix to
config/profile validation, registry security, symbolic secrets, zero retained
secret values, and structural zero-side-effect checks. The language-level
housekeeping audit also covers this directory.

CTest `p2_03_storage_foundation` recomputes migration checksums, compiles the
schema, store, and scenario in both modes, and runs both VMs. It covers all 32
logical tables, migration-record 1-to-2 upgrade, idempotence,
downgrade/checksum denial,
transactional DDL failure, snapshot isolation, generation immutability,
manifest recovery, read-only zero-write/missing paths, full verification,
ordered rollback, and real `SIGKILL` before commit, after SQLite commit, and
after temporary-manifest write.

CTest `p2_10_plan_revalidation` compiles all facade dependencies and the Level-G
scenario with and without optimization, then runs both VMs. It proves three
canonical plan forms, access-first denial, zero-write planning/revalidation,
digest and encoding rejection, expiry, generation, config/profile, current
source, provider-route/privacy, reservation, and capability revalidation, and
the explicit no-enqueue later-phase boundary.
