# Phase 2 Resumable Worklist

Status date: 2026-08-23. Authority is limited to `P2-01` through `P2-10` in
the [Gate-1B decision ledger](../../gate1b-decision-ledger.md) and
[implementation roadmap](../../crexx-only-implementation-roadmap.md). `[ ]` is
pending, `[~]` is active, `[x]` is accepted, and `[!]` is incomplete with
retained blocker evidence. At most one roadmap item may be active.

## Entry

- [x] Record the pushed repository baseline, installed toolchain, Debug
  configure/build/full CTest result, Release configure/build result, clean
  worktree, and the separately expected CRI-15 failure in
  [ENTRY-BASELINE.md](ENTRY-BASELINE.md).

## Product Skeleton

- [x] **P2-01** Create the Level G application module layout and the Level G
  `raglibrary`, `ragjob`, and `ragevidence` public contracts. Freeze concrete
  cREXX usage through an optimized/non-optimized, dual-VM compiled consumer.
  Keep every operation truthful about unavailable later-phase behavior. Do not
  add a facade solely to cross language levels; retain a reproducer and
  explicit exception evidence if Level B proves necessary. Accepted evidence:
  [P2-01.md](P2-01.md).
- [x] **P2-02** Implement operator-registered declarative cREXX configuration
  with `env:` secret references and independent typed profiles. Freeze typed
  config/profile/registry use through an optimized/non-optimized, dual-VM
  consumer; reject arbitrary module paths, duplicates, invalid references, and
  unsupported worker scope; prove loading has zero provider, source, or library
  side effects and retains no secret value. Accepted evidence:
  [P2-02.md](P2-02.md).

## Storage Foundation

- [x] **P2-03** Implement schema-v2 migrations, SQLite-authoritative published
  generations, visibility and snapshot rules, manifest recovery, strict
  read-only opens, crash ordering, library lifecycle operations, and rollback.
  Accepted evidence: [P2-03.md](P2-03.md).
- [x] **P2-04** Implement version-1 read/import compatibility and a dry-run
  conversion report without dual-writing either format. Accepted evidence:
  [P2-04.md](P2-04.md).
- [x] **P2-05** Implement generation-pinned online backup, immutable matching
  sidecars, snapshot manifests, fresh-folder restore, and crash-order tests.
  Accepted evidence: [P2-05.md](P2-05.md).
- [x] **P2-06** Implement paged repositories for sources, revisions, chunks,
  generations, concepts, claims, support, lineage, embeddings, jobs, attempts,
  and reviews. Accepted evidence: [P2-06.md](P2-06.md).

## Product Surfaces

- [x] **P2-07** Establish command parsing, stable exit codes, and semantic
  `human`, `json`, and `ndjson` result contracts. Accepted evidence:
  [P2-07.md](P2-07.md).
- [x] **P2-08** Add `doctor`, library lifecycle, provider status/test, and
  profile validation commands. Accepted evidence: [P2-08.md](P2-08.md).
- [x] **P2-09** Publish the first cREXX-rag workload/capability report and
  prepare complete bundles for already accepted generic components. Donation
  submission remains outside Phase 2 authority. Accepted evidence:
  [P2-09.md](P2-09.md).
- [ ] **P2-10** Implement zero-library-write canonical plan encoding and digest
  plus untrusted apply-time revalidation through the shared facade.

## Item Evidence

An item is accepted only when its dated evidence records:

- exact source and installed-toolchain provenance;
- optimized and non-optimized cREXX compilation where applicable;
- `rxvme` and `rxbvm` behavior where runtime behavior is applicable;
- focused correctness, negative, zero-write, crash, time, and memory evidence
  appropriate to the item;
- current documentation and implemented-versus-specified status;
- focused CTest plus the full Debug configure/build/CTest baseline; and
- `git diff --check` and an audit confirming no unauthorized writes, hosted
  calls, secrets, or generated source-tree artifacts.

An item with a genuine external blocker is marked `[!]`, retains the smallest
reproducer and exact failure, and does not activate its successor without a
separate decision.

## Gate 2 Stop

- [ ] Assemble a Gate-2 packet covering every item, capability limitations,
  installed-package operation, fresh init/status/verify/backup/restore, and
  version-1 fixture read/import.
- [ ] Run Debug configure/build/full CTest, Release configure/build, and
  `git diff --check`.
- [ ] Audit native-v1 and sibling-CREXX preservation.
- [ ] Stop unconditionally for the user's Gate-2 decision.

## Exclusions

Phase 3 ingestion, additional hosted-provider calls or qualification, edits or
installation in the normal CREXX prefix, writes to a sibling CREXX checkout,
donation submission, live-library dual-write, production cutover, native-core
removal, and implicit parallel capability work remain excluded. Scratch
libraries, copies, and deterministic protocol fixtures are required.
