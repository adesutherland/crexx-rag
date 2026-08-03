# Phase 1B Resumable Worklist

Status date: 2026-08-03. Authority is limited to the ordered worklist in
`docs/gate1a-decision-ledger.md`. `[ ]` is pending, `[~]` is active, `[x]` is
accepted, and `[!]` is incomplete with retained blocker evidence. At most one
roadmap item may be active.

## Entry

- [x] Entry audit: record provenance, toolchains, fixture hashes, Debug oracle
  configure/build/CTest, Release configure/build, `git diff --check`, and the
  separately expected CRI-15 result.
- [x] Post-crash recovery checkpoint: verify the sole active item, correct
  accepted-provider housekeeping, reproduce the full baseline, and retain
  replacement hashes in `RECOVERY-CHECKPOINT.md`.

## 1. Installed SDK

- [x] `P1-RXPA-01` Repeatable installed-package external dynamic-plugin build
  with vendored and source fallbacks disabled.
- [x] `P1-RXPA-02` Development-package contents, module discovery, version
  compatibility, and actionable negative diagnostics on both VMs.

## 2. Generic SQLite

- [x] `P1-SQL-01` Generic connection/statement/cursor/error contract and
  ownership rules.
- [x] `P1-SQL-02` Typed null/int64/real/text/blob and large-value/result
  round-trips.
- [x] `P1-SQL-03` Transactions, savepoints, statement reuse, cursor paging,
  FTS5, JSON1, foreign keys, WAL, busy timeout, and checkpoint.
- [x] `P1-SQL-04` Read-only zero-write and no-migration proof.
- [x] `P1-SQL-05` Separate-process reader/writer concurrency proof.
- [x] `P1-SQL-06` Online backup, integrity, and forced-error cleanup.
- [x] `P1-SQL-07` Optional `ADDRESS SQLITE` facade and command-syntax
  regression.

## 3. Structured Data And Records

- [x] `P1-JSON-01` Parse-once typed JSON iteration, Unicode,
  missing/null/empty, and bounded encoding.
- [x] `P1-JSON-02` Same-session representative provider/evidence comparison.
- [x] `P1-REC-01` Level-B/Level-G/plugin typed record crossings without corpus
  reserialization.

## 4. Provider Contract

- [x] `P1-LLM-01` Provider-neutral capability/request/result/error contract.
- [x] `P1-LLM-02` Configurable local OpenAI-compatible generation and embedding.
- [x] `P1-LLM-03` Batch embedding, structured validation, bounded retry,
  usage, privacy routing, streaming, and cancellation capability results.
- [x] `P1-LLM-04` Deterministic local/OpenAI/Anthropic/Gemini protocol shapes
  plus explicitly authorized low-cost, secret-gated hosted qualification.
- [x] `P1-LLM-05` Zero denied outbound requests and secret-free evidence.

## 5. Vector Boundary

- [x] `P1-VEC-01` Versioned float32 codec with application-owned schema.
- [x] `P1-VEC-02` Exact ordering for the retained 11,684-by-768 workload.
- [x] `P1-VEC-03` Both-VM transfer/decode/arithmetic/selection/memory/total
  measurements.
- [x] `P1-VEC-04` Evidence-led backend recommendation at the retained triggers.

## 6. Algorithm Parity

- [x] `P1-ALG-01` Scratch schema, deterministic chunking, and lexical FTS.
- [x] `P1-ALG-02` Identical-ingest zero-write and edited-paragraph identity
  reuse.
- [x] `P1-ALG-03` Exact normalized support and source-revision retraction.
- [x] `P1-ALG-04` Passage/claim/support/ambiguity/vector-lead evidence packet.
- [x] `P1-ALG-05` Native-oracle semantic parity and profile evidence.

## 7. Fenced Worker

- [x] `P1-JOB-01` Atomic claim, database-clock lease, heartbeat, monotonic
  fence, attempts, idempotent promotion, cancellation, and status.
- [x] `P1-JOB-02` Forced termination at every authorized boundary and
  duplicate-free recovery.
- [x] `P1-JOB-03` Item/call ceilings, pre-call reservations, actual usage, and
  maximum in-flight overrun.

## Gate 1B

- [x] Assemble the required packet and capability ledger.
- [x] Run Debug configure/build/CTest, Release configure/build, and
  `git diff --check`.
- [x] Audit worktree and sister-checkout preservation.
- [x] Stop unconditionally for the production-capability decision.

## Exclusions

`P1-RXPA-03`, `P1-HASH-01`, hosted calls outside the authorized `P1-LLM-04`
qualification, normal-prefix or CREXX changes, product-specific CRI-15
workarounds, production schema or migrations, live-library dual-write,
donation preparation, Phase 2, cutover, native-core removal, push, and pull
request remain excluded. A recovery checkpoint commit was separately requested
for consideration on 2026-08-03.
