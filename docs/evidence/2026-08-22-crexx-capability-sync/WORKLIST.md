# CREXX Capability Sync Worklist

Status date: 2026-08-22. This is a bounded parallel capability stream under
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

- [!] **LINUX-01 CRI-15 and CRI-16.** Repeat installed-only downstream replay
  on supported Linux, close the invalid-UTF-8/timeout transport defect, and
  qualify the HTTP transport, pooling, TLS, cancellation, and sanitizer scope.
- [!] **LINUX-02 Publication evidence.** Run the supported Linux sanitizer and
  release gates, refresh the dependency ledger and Gate evidence, and publish
  the final cross-platform disposition only after `LINUX-01` is closed.

## Current Ordering

This capability stream may advance independently of the sole Phase-2 successor
`P2-04`, but it must not mutate Phase-2 product state. Within this stream,
the macOS work is complete. Linux items remain explicitly open and own the
supported sanitizer and transport completion.
