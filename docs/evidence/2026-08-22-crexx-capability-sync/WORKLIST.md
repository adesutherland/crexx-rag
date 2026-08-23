# CREXX Capability Sync Worklist

Status date: 2026-08-23. This is a bounded parallel capability stream under
the Gate-1B rules. It does not activate or reorder a Phase-2 product item.
`[ ]` is pending, `[~]` is active, `[x]` is accepted, and `[!]` is deferred to
the named platform gate.

## Authority And Boundaries

- Source repositories: the current `crexx-rag` `main` checkout and current
  CREXX `develop` checkout.
- Installed replay: a fresh temporary prefix only; both source and installed
  fallbacks are disabled for the downstream configure.
- Allowed `crexx-rag` writes: compatibility repairs, generic capability proof,
  focused regression tests, and retained evidence for this stream.
- Allowed CREXX writes: an approved generic `rxvector` implementation and its
  tests, documentation, packaging, and performance evidence. The API and
  architecture require a separate approval stop before production edits.
- Excluded: normal-prefix installation, hosted provider calls, credentials,
  live-library writes, Phase-2 product activation, native-v1 removal or
  cutover, commit, push, and pull request.

## macOS Work

- [x] **MAC-01 Current installed replay.** Build and install current CREXX into
  a fresh scratch prefix; configure `crexx-rag` with installed CREXX only;
  build the full graph; and run the current downstream test inventory. Retained
  result: [MACOS-BASELINE.md](MACOS-BASELINE.md).
- [x] **MAC-02 HTTP and toolchain compatibility.** Migrate current downstream
  provider probes to the installed Level-G HTTP surface, remove generator-path
  assumptions from external-consumer tests, correct the reserved `queue`
  identifier, and keep correctness tests independent of timing thresholds.
  Retained result: [MACOS-COMPATIBILITY.md](MACOS-COMPATIBILITY.md).
- [x] **MAC-03 SHA-256 capability adoption.** Prove installed `rxhash.sha256`
  through a downstream-owned, deterministic content-identity capability test.
  Do not activate `P2-10`, change the product schema, or introduce incremental
  or file-hash API claims not present in installed CREXX. Retained result:
  [MACOS-SHA256.md](MACOS-SHA256.md).
- [x] **MAC-04 `rxvector` design decision.** Present the proposed public API,
  ownership/error semantics, package/loading route, application proof, and
  performance verdict protocol. The proposed decision is retained in
  [RXVECTOR-DESIGN.md](RXVECTOR-DESIGN.md). Stop for approval before CREXX
  production edits.
- [x] **MAC-05 Approved `rxvector` implementation.** The approved generic
  provider, dual-VM contract, accepted first Release verdict, dynamic/static
  installed package proof, bounded downstream cutover, and proportional
  end-of-item Debug qualification are complete. Retained result:
  [MACOS-RXVECTOR.md](MACOS-RXVECTOR.md).

## Linux Completion

- [x] **CURRENT-01 Pulled-head installed replay.** Review CREXX
  `e3d6b7b9015847d247ab2b90e83c843881db9b2f`, scratch-install it, and replay
  the full no-fallback downstream inventory. The fresh build passed 27/27 and
  CTest passed 62/62 on macOS. Retained result:
  [2026-08-23 current integration](../2026-08-23-crexx-current-integration/README.md).
- [!] **LINUX-01 CRI-15 downstream confirmation.** Repeat the exact
  installed-only downstream replay on supported Linux, including the retained
  socket-timeout reproducer and both VMs. The pulled upstream lineage now has a
  green 2,363-test Linux ASan/LSan gate and cREXX-RAG HTTP cells; CRI-15 closes
  only when the current downstream reproducer confirms the old
  invalid-UTF-8/two-byte result is gone.
- [!] **LINUX-02 CRI-16 downstream closure.** Replay provider pooling,
  concurrency, TLS, cancellation and sanitizer scope from the current installed
  package. Distinguish the now-qualified upstream substrate from the still
  unsupported provider-lifetime reuse, streaming and cancellation claims.
- [!] **LINUX-03 Publication evidence.** Refresh the dependency ledger and Gate
  evidence, then publish the final downstream cross-platform disposition only
  after `LINUX-01` and the approved portion of `LINUX-02` are closed.

## Deferred Follow-Up

Phase 2 product delivery now has priority. The Linux replay is a later QA step
after material progress on this host, not the next action or a Phase-2
precondition. A future provider-lifecycle decision may consider one persistent
origin pool per adapter, explicit close, timeout-policy ownership, and measured
keep-alive reuse. Streaming and cancellation adoption remain a separate scope
decision. None of this work is active.

## Current Ordering

This capability stream may advance independently of the sole Phase-2 successor
`P2-04`, but it must not mutate Phase-2 product state. Within this stream, the
available macOS work and current-head compatibility replay are complete. The
next product action is `P2-04`; provider-lifecycle work requires separate
approval, while Linux downstream confirmation is deferred to later QA.
