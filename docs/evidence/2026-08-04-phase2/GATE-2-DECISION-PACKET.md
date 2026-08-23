# Gate 2 Foundation Decision Packet

Status date: 2026-08-23. Result: Gate 2 reached; foundation-acceptance decision
required. Programme execution stops here unconditionally.

## Executive Result

All ten bounded Phase-2 items are accepted on their item-specific evidence.
The committed Gate baseline configures and builds against the scratch-installed
CREXX package, builds a fresh Release tree, and passes all 69 Debug CTests. All
ten Phase-2 tests pass. No new failure, hosted call, credential resolution,
source-tree artifact, normal-prefix write, product-native change, or sister
CREXX change was found.

The outcome is a recoverable Level-G product foundation, not a completed RAG
pipeline or cutover candidate. A fresh scratch library can be initialized,
inspected, verified, backed up, and restored through the shared cREXX facade.
A version-1 fixture can be inspected, dry-run, and imported side-by-side.
Canonical plans can be reviewed and hostile input can be revalidated, but no
plan is enqueued and no ingestion or improvement algorithm runs.

## Provenance

- Gate entry commit: `3f50c04e1083034c45b2d5bf0fcc573facca2e92`
- branch: local `main`, eight commits ahead of `origin/main`; no push was
  performed
- consumed CREXX revision:
  `e3d6b7b9015847d247ab2b90e83c843881db9b2f`
- scratch installed identity:
  `crexx-1.0.0-beta.3+local.ge3d6b7b90158.dirty`
- scratch install: `/tmp/crexx-current-install.6yzYQv`
- host: `Darwin 25.5.0 arm64`, installed build identity `macOS 64 20260823`
- VMs: scratch-installed `rxvme` and `rxbvm`

The exact downstream Linux replay is deliberately deferred until after further
material progress on this host, as directed. No Linux result is inferred from
this macOS Gate.

## Item Acceptance

| Item | Local commit | Accepted result | Evidence |
| --- | --- | --- | --- |
| P2-01 | `67b6e8d` | Level-G public application contracts and truthful unavailable later behavior | [P2-01.md](P2-01.md) |
| P2-02 | `d1d2f31` | Registered typed config/profile boundary, symbolic secrets, no dynamic module paths | [P2-02.md](P2-02.md) |
| P2-03 | `de38040` | Schema-v2 migrations, immutable generations, snapshots, manifests, recovery and rollback | [P2-03.md](P2-03.md) |
| P2-04 | `df536e5` | Read-only version-1 inspection/dry-run and deterministic side-by-side import | [P2-04.md](P2-04.md) |
| P2-05 | `bef9e31` | Generation-pinned backup, immutable sidecars, crash ordering and fresh restore | [P2-05.md](P2-05.md) |
| P2-06 | `a59363f` | Sixteen bounded keyset repositories and snapshot/lifecycle invariants | [P2-06.md](P2-06.md) |
| P2-07 | `a27697d` | Closed 40-operation grammar, 11 exits and typed human/JSON/NDJSON results | [P2-07.md](P2-07.md) |
| P2-08 | `3882098` | Shared lifecycle/diagnostic facade with access-first and zero-outbound behavior | [P2-08.md](P2-08.md) |
| P2-09 | `e3bc777` | Versioned workload report and three non-released, hash-verified review bundles | [P2-09.md](P2-09.md) |
| P2-10 | `3f50c04` | Canonical plan/digest and hostile apply-time revalidation with zero enqueue | [P2-10.md](P2-10.md) |

The user-requested P2-04 through P2-10 sequence has one local commit per item.
The additional local `90bba73` commit records the refreshed CREXX integration
baseline consumed by that sequence.

## Fresh Installed-Package Operation

The Gate replay uses only the configured scratch install for `rxc`, `rxas`,
`rxvme`, `rxbvm`, installed foundation libraries, and package metadata. The
Phase-2 facade cells compile with and without optimization and run on both VMs.

In each fresh P2-08 cell the shared facade:

1. denies initialization without `admin` before creating the bundle;
2. initializes a registered config/profile library;
3. reads status and verifies storage/repository integrity without changing the
   source bundle;
4. confirms current-schema migration is idempotent;
5. creates a generation-pinned backup without changing the source;
6. restores into a fresh folder and verifies the restored library; and
7. reports provider configuration with zero calls and credential resolutions.

In each fresh P2-04 cell, the compatibility layer fingerprints and reads the
version-1 fixture, produces a dry-run report with zero source writes, imports a
separate schema-v2 target, verifies it, and denies malformed input or target
overwrite. Neither test runtime module list includes the product-specific
`rx_rag` plugin; they use the generic SQLite boundary and installed CREXX
facilities. The sibling CREXX source checkout is not an import or runtime path.

## Gate Validation

```text
cmake -S . -B <debug> -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH=<scratch-crexx> -DCREXX_DIR=<scratch-crexx>/lib/cmake/CREXX
cmake --build <debug> --parallel 10
ctest --test-dir <debug> --parallel 10 --output-on-failure
cmake -S . -B <fresh-release> -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=<scratch-crexx> -DCREXX_DIR=<scratch-crexx>/lib/cmake/CREXX
cmake --build <fresh-release> --parallel 10
git diff --check
```

- committed-head Debug configure: passed; selected the exact scratch package
- Debug build: passed with no work required
- Debug CTest: 69/69 passed in 101.30 seconds; harness maximum RSS 249,584 KiB
- Phase-2 label: 10/10 passed; aggregate process time 297.20 seconds
- fresh Release configure/build: passed; all 27 targets built
- fresh lifecycle facade: passed in 70.88 seconds within the parallel Gate run
- version-1 compatibility: passed in 18.17 seconds within the parallel Gate run
- canonical plan/revalidation: passed in 71.32 seconds within the parallel Gate
  run; its isolated item gate was 39.70 seconds at 246,288 KiB maximum RSS
- donation-document and Level-G audits: passed
- `git diff --check`: passed

The frozen Phase-0 oracle hashes and all earlier Phase-1/Phase-2 regressions are
part of the same 69-test result.

## Preservation And Publication Audit

- `core/`, `cli/`, `mcp/`, `include/`, and `crexx/plugins/rag/` have no diff
  from the refreshed Phase-2 baseline `f46c001`; native-v1 remains intact.
- `docs/archive/` and `prompts/archive/` have no diff from that baseline.
- Sister CREXX remains on `develop` at
  `e3d6b7b9015847d247ab2b90e83c843881db9b2f` with exactly its three pre-existing
  roadmap/planning document modifications; no file there was changed by this
  sequence.
- The normal CREXX install prefix was not configured or installed into; every
  consumer command selected the scratch prefix above.
- Repeating tests write only below their build/scratch roots. The source tree
  was clean at the committed Gate entry.
- Deterministic provider tests made no hosted request. P2-08/P2-09/P2-10 retain
  explicit zero-call results and no credential value was resolved or retained.
- No donation was submitted, no pull request was opened, and no commit was
  pushed.

## Capability Limits Carried Forward

- The checked-in executable is still the native-v1 oracle. Phase-6 CLI,
  `ADDRESS RAG`, MCP, and skill adapters have not cut over to the Level-G
  facade.
- P2-10 fingerprints current published library revisions. External connector
  inventory/delta fingerprints and actual ingestion are Phase 3.
- A valid plan is revalidated but not persisted as a job. Ingestion,
  improvement/proposal execution, workers, review mutation, and provider calls
  remain later phases.
- Provider tests are configuration-only. Exact downstream Linux CRI-15
  confirmation and the separately approval-gated CRI-16 provider lifecycle
  remain open; neither is a Phase-2 defect or a reason to jump hosts now.
- The three P2-09 packages are review bundles, not installed/released CREXX
  packages or approved donations.
- `ragfile` remains the documented narrow Level-B binary-file exception.
  Installed `rxhash.sha256` is one-shot, so sidecar verification retains its
  2,147,483,647-byte in-memory bound.
- No multi-process worker, production ingestion path, dual-write, cutover, or
  native-core retirement is accepted.

## Decision Requested

Recommended decision: accept the Phase-2 foundation and retain native-v1 as the
oracle. If the user wants implementation to continue, separately authorize the
existing Phase-3 sequence beginning at `P3-01`; do not infer approval for later
P3 items, Linux QA, hosted calls, cutover, or capability-lifecycle expansion.

No further programme item is active. This packet is the mandatory Gate-2 stop.
