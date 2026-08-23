# Gate 1B Decision Ledger

Status date: 2026-08-23. Gate 1B remains accepted. Phase 2 is the active product
phase alongside separately bounded CREXX capability work.

This ledger records the user's decision on the completed
[Gate-1B evidence packet](evidence/2026-08-03-phase1b/GATE-1B-DECISION-PACKET.md).
It changes programme authority; it does not change the retained measurements or
turn withheld production claims into accepted capabilities.

## Decisions

| ID | Decision |
| --- | --- |
| G1B-D1 | Accept the Phase-1B cREXX capability skeleton and all 28 bounded item results, including the explicitly recorded limitations. |
| G1B-D2 | Authorize Phase 2, `P2-01` through `P2-10`, as the next product workstream. Establish its dated worklist, entry baseline, ordering, and Gate-2 stop before the first implementation edit. |
| G1B-D3 | Permit Phase 2 to proceed in parallel with separately scoped CREXX capability work. Each parallel workstream must have its own ownership boundary, worklist, evidence, and stop point. |
| G1B-D4 | Preserve native-v1 as the executable oracle. Gate-1B acceptance does not authorize dual-write, cutover, compatibility removal, or native-core retirement. |
| G1B-D5 | Keep CRI-15, CRI-16, vector acceleration, durable hashing, multi-process workers, and all other withheld production claims explicit until their own evidence closes them. |
| G1B-D6 | Use Level G for advanced user-facing libraries and all application code. Reserve Level B for CREXX bootstrap/foundation facilities or explicitly justified low-level mechanisms; never add a facade solely to cross language levels. |

## Language-Level Amendment

On 2026-08-04 the user accepted the Level-G-first recommendation after the
installed compiler was requalified. All 46 Phase-1B cREXX sources compiled as
Level G in optimized and non-optimized modes; provider, typed-record, algorithm,
job, vector, and installed-RXPA representative runtime proofs passed on both
VMs. The historical CRI-01 and CRI-05 constraints are closed.

This amendment supersedes only Gate-1A D7's Level-B-core/Level-G-facade split
and the corresponding language-level wording below. It does not change any
Gate-1B measurement or authorize a withheld production capability. Level G may
consume installed Level-B foundation libraries normally. A retained facade
must define a stable user or transport contract rather than act as a
compatibility wrapper.

## Phase 2 Authority

Phase 2 may implement only the product-foundation items already specified in
the roadmap:

- Level G application modules, advanced libraries, and public contracts;
- declarative typed configuration and secret references;
- schema v2, migrations, generations, recovery, compatibility, backup, and
  restore;
- paged application repositories;
- stable human/JSON/NDJSON command contracts and foundation commands;
- the first workload/capability report and bundles for already accepted generic
  components; and
- canonical zero-write plan encoding and apply-time revalidation.

Phase 2 stops at Gate 2. This decision does not authorize Phase 3 ingestion,
additional hosted-provider qualification, donation submission, live-library
dual-write, production cutover, or native removal.

## Parallel Capability Work

The deferred parallel capability queue is:

1. exact downstream Linux confirmation of CRI-15 against the current installed
   package;
2. an approval-gated CRI-16 provider-owned pool lifecycle plus the selected
   downstream Linux/package qualification scope;
3. a separate decision on provider streaming and cancellation; and
4. incremental binary SHA-256 only when ingestion/stream ownership requires it.

Matched generic vector acceleration is complete through installed `rxvector`
and is no longer an open queue item. None of the remaining entries is a
prerequisite for `P2-04` through `P2-10`; the downstream Linux replay is a later
QA step after material progress on this host.

This ledger authorizes the parallel delivery model, not unbounded or implicit
changes to the installed CREXX prefix or a sibling CREXX checkout. Before any
of these streams edits code, its exact repository, allowed write boundary,
tests, packaging, measurements, and approval stop must be recorded.

### 2026-08-22 capability disposition

The separately bounded capability-sync worklist completed the available macOS
items: current installed-only replay, HTTP/toolchain compatibility, installed
one-shot `rxhash.sha256` content identity, and the accepted stateless exact
packed `rxvector` provider. This closes the macOS vector-acceleration proof but
does not claim an incremental/file-hash surface. CRI-15, CRI-16, supported
Linux sanitizer and final cross-platform publication remain explicit open
gates. No Phase-2 item was activated or reordered by this work.

### 2026-08-23 current-head disposition

CREXX was pulled through
`e3d6b7b9015847d247ab2b90e83c843881db9b2f`. The reviewed upstream lineage has
green 2,363-test Linux ASan/LSan evidence at `e3de72939`, all four CREXX-owned
cREXX-RAG HTTP cells, qualified `rxvector`, and focused Linux sanitizer plus
full ordinary Debug evidence for the later process cancellation/replacement
repair. A fresh installed-only macOS downstream replay
then passed its 27-step build and 62/62 CTests. Current `crexx-rag` already
consumes the public Level-G HTTP, `rxhash` and `rxvector` facilities, so no
compatibility code edit was required.

CRI-15 remains open for its exact downstream Linux reproducer/current-package
confirmation. CRI-16 now distinguishes a qualified upstream substrate from
downstream adapter features: provider-lifetime reuse, streaming and
cancellation still report unsupported. Changing that lifecycle or interface
requires explicit approval. No Phase-2 item was activated or reordered.

## Start State

`P2-01` through `P2-03` are accepted. `P2-04` is the next product item and is
pending with no item active. The capability-sync compatibility replay is
complete. Provider-lifecycle work remains separately approval-gated, and the
exact downstream Linux replay is deferred to later QA after material progress
on this host; neither reorders or blocks Phase 2.
