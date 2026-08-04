# Gate 1B Decision Ledger

Status date: 2026-08-04. Gate 1B is accepted. Phase 2 is approved as the next
product phase and is expected to begin shortly alongside separately bounded
CREXX capability work.

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

## Phase 2 Authority

Phase 2 may implement only the product-foundation items already specified in
the roadmap:

- Level B application modules and Level G facades;
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

The intended parallel capability queue remains:

1. CRI-15 socket receive-timeout correctness;
2. CRI-16 industrial HTTP/TLS qualification;
3. matched generic vector-acceleration qualification; and
4. incremental binary SHA-256 and durable identity.

This ledger authorizes the parallel delivery model, not unbounded or implicit
changes to the installed CREXX prefix or a sibling CREXX checkout. Before any
of these streams edits code, its exact repository, allowed write boundary,
tests, packaging, measurements, and approval stop must be recorded.

## Start State

At this decision point no Phase-2 implementation item or parallel capability
item has started. The next documentation action is to establish the Phase-2
worklist and handoff; the next implementation action is its first explicitly
active item.
