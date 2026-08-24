# Gate 7 cutover decision

Decision date: 2026-08-24

Decision: **reject/defer cutover**. Keep native-v1 as the default executable
oracle while the failed production-selection criteria are addressed.

## What passed

- optimized/non-optimized Level G on `rxvme` and `rxbvm`;
- generic IT and Scotland-shaped frozen judgements;
- incremental source lifecycle, crash recovery, worker fencing, backup/restore,
  generation visibility, stale-plan and capability denial;
- installed-package, no-source-fallback CLI/ADDRESS/MCP surfaces;
- deterministic local and synthetic provider matrices;
- explicit external hosted OpenAI structured generation and 128-dimensional
  batch embedding; and
- symbolic-key handling with credential values logged: zero.

## Resolved after the decision

- [x] cREXX hosted response completion is repaired in CREXX commit
  `cd9fadc4ba99675aca58c8387d3927dfdd1794fc` and qualified from a scratch
  installation in optimized/non-optimized execution on `rxvme` and `rxbvm`.
  All four hosted provider cells completed structured generation and batch
  embedding within the declared eight-call ceiling. This blocker is resolved.

The repair is committed locally but is not yet published or installed into the
normal prefix. That publication boundary does not reopen the repaired defect.

## Why cutover remains rejected

1. `worker.run` is in the public vocabulary but `ragproduct` does not dispatch
   it to `runworkeronce`/`runworkerfollow`. The only `.ragworkprovider`
   implementation is a deterministic test fixture; no installed adapter maps a
   configured local/hosted provider result into the validated claim proposal.
2. Initial ingestion queues both `embedding` and `claim-extraction` items, but
   the Phase-4 worker claims only `claim-extraction` and `improve-extraction`.
   The public application therefore cannot drain a complete ingestion job.
3. The available native/cREXX comparisons do not yet form one exact
   production-shaped same-session measurement of graph promotion, evidence
   latency/RSS, model-bound overhead, and final library counts.
4. Exact downstream Linux: open. The macOS result must not be relabelled as
   cross-platform completion.

The remaining findings are application integration, evidence, and platform
gaps, not permission to bypass capability, schema, or worker ownership rules.

## Required evidence before a new cutover request

- [x] Repair and qualify cREXX hosted response completion in optimized and
  non-optimized execution on both concrete VMs for the recorded macOS scope.
- [ ] Install a production `.ragworkprovider` adapter selected only through the
  registered config/role route, with typed schema validation, symbolic secrets,
  reservation settlement, cancellation boundaries, and local plus hosted
  qualification;
- [ ] Add bounded embedding-item execution or change publication so every queued
  item has one owned processor, then prove a public supervised worker drains a
  job after restart;
- [ ] Add one production-shaped same-session native/cREXX comparison covering all
  missing P7-05 measures with exact final-count invariants; and
- [ ] Run the exact installed downstream Linux matrix and relevant sanitizer gate.

## Approval boundary

This decision asks only that the deferral and closure evidence be accepted as
the Phase-7 outcome. It does not request cREXX-default cutover, dual-write,
native retirement, live-library migration, release publication, or donation
submission. Any later cutover requires a new explicit approval after the four
remaining open items above pass.
