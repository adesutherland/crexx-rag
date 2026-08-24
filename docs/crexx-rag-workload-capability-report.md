# cREXX-RAG Workload And Capability Report

Report version: 3. Status date: 2026-08-24. Evidence cutoff: the Phase-5
closeout worktree plus the retained P2-09 and Phase-5 qualifications.

This is the consolidated workload report for the cREXX-only programme.
It distinguishes application capability, local generic incubation, consumed
CREXX capability, and an external or deferred dependency. It is not a release,
production-readiness statement, Linux qualification, or donation approval.

## Evidence Boundary

- Host: Darwin arm64 on the current development machine.
- Consumed CREXX revision:
  `1fbd89dc9afb7dbbf2e8e577624a87b1076ff11e`.
- Installed identity:
  scratch-installed existing builds whose configured display remains
  `crexx-1.0.0-beta.3+local.ge3d6b7b90158.dirty`; executable provider symbols
  and tests prove the `1fbd89d` SHA-256 surface without relabelling that display.
- Current product qualification: 69/69 Debug and 69/69 fresh Release CTests,
  both VMs, optimized/non-optimized cREXX, dynamic/static provider selection,
  installed external consumers, and 10/10 Phase-2 Apple-ASan tests.
- Current-host evidence is not substituted for the deferred exact downstream
  Linux replay. Historical Linux and upstream sanitizer evidence retains its
  own scope.
- The closeout makes no provider request, reads no credential, changes no
  sibling checkout or normal install prefix, and does not submit a donation.

## Workload Results

| Workload | Retained shape | Observed result | Capability conclusion |
| --- | --- | --- | --- |
| SQLite typed cursor | 20,000 ordered rows including large typed text/blob values | Four-cell correctness; focused harness 2.80 s and 126,856 KiB peak RSS in the retained 2026-08-03 run | Generic typed handle/cursor boundary is accepted locally; no ORM or application-schema ownership |
| SQLite concurrency/recovery | Separate reader/writer processes plus a four-thread RXPA V2 provider-session lifecycle harness, WAL snapshot; online backup of 2,000 rows while source advances to 2,001 | Reader isolation, checkpoint, backup, integrity and failure cleanup pass; four session-owned connections write 400 unique rows with isolated diagnostics, cross-session handle use is rejected, and the installed dynamic cREXX path reports session entry | Correct generic local candidate with session-affine wrapper state and `SQLITE_OPEN_FULLMUTEX`; handles remain non-transferable and the CREXX task/native-provider integration seam remains open |
| Parse-once JSON | 713-byte provider response and four pages of eight evidence rows | Indexed parse/traversal was 808-1,162 us for the provider response versus 14,761-17,168 us repeated paths; paged parse/traversal was 2,288-2,877 us versus 54,893-75,320 us | Installed `rxjson` is the selected consumed capability, not a local donation |
| Provider contract | Deterministic local loopback; OpenAI-compatible, OpenAI, Anthropic and Gemini shapes; batch embeddings, structured results, failure/retry/privacy cases | Phase-1 contract passes; five separately authorized historical hosted canaries passed; current Phase-2/P2-09 runs make zero provider calls | RAG-neutral cREXX contract is accepted incubation; provider-lifetime reuse, streaming/cancellation and exact downstream Linux/package replay remain open |
| Exact vector retrieval | 11,684 vectors x 768 dimensions, 128-row pages, top 10 | Current installed `rxvector` path totals 122,740-129,974 us; conversion 29,444-31,261 us; arithmetic/selection 54,161-54,472 us; process RSS 86,196,224-99,434,496 bytes | Installed packed exact provider is selected; local `f32le-v1` codec and pure exact implementation remain portable oracle/fallback |
| Bounded content identity | Standard vectors, binary/Unicode cases, immutable incremental state, binary files, then 2,000 small fingerprint/chunk operations | Complete installed SHA-256 family passes optimized/non-optimized on both VMs, dynamic autoload, and static/native packaging; the retained earlier small-content profile was 24,219-24,721 us | One-shot raw/hex, incremental, and bounded-memory file hashing are accepted consumed capabilities; application sidecars use fixed-memory incremental hashing with their own size policy |
| Algorithm slice | Immutable revisions, stable chunks, FTS, no-op/reuse, claim support/retraction and evidence assembly; 2,000 profile operations | Semantic oracle overlap passes; historical profile 63,241-104,666 us and below 64 MiB process RSS | Application behavior is accepted evidence, not a generic package or production ingestion implementation |
| Worker slice | One process, DB-clock lease, heartbeat/fence, four crash boundaries, hard admission and usage settlement | No duplicate promotion; seven budget denial paths are zero-write; maximum unreported exposure is one call/100 tokens/20 cost microunits/500 ms | Application queue semantics are accepted but multi-process scheduling remains later qualification |
| Phase-2 foundation | Schema v2, version-1 import, pinned backup/restore, 16 repositories, closed results, ten-command foundation facade | P2-01 through P2-08 pass current installed-only macOS QA | Product foundation is implemented behind cREXX contracts; Phase-6 public adapters remain open |
| Phase-3 ingestion | Three format-aware chunkers, immutable plans, generation reconciliation, candidate census, FTS, jobs, native generic/Scotland semantic comparisons | Four compile/runtime cells, two concrete-VM crash/resume cells, and exact executable tutorial pass on macOS | Product ingestion is implemented behind Level-G development contracts; public Phase-6 adapters and Linux qualification remain open |
| Phase-4 improvement | Canonical claims/support, deterministic proposal/review policy, exact budgets, independent OS-process workers and literal 28,800-poll soak | Four claim/tutorial cells, dual-VM forced termination, two-process fencing, full Debug/Release, Apple-ASan and eight-hour supervised exit 0 | Product improvement/work semantics are accepted on macOS; public Phase-6 adapter and exact Linux replay remain open |
| Phase-5 retrieval | Nine frozen IT/Scotland questions; FTS5, exact vectors, directed graph, typed evidence and stable historical citations | Four cells pass 144/144 and 17/17 recall; typed contexts 69,295 bytes versus native MCP 92,385; bounded Gemini run 143/144 versus control 130/144 | Product retrieval/evidence is accepted on macOS; tiny full-context fixture and cREXX hosted transport limitation are retained without overclaiming |

Timing values are observations of the named retained synthetic workloads. They
are not universal performance claims, service-level objectives, or estimates
for a different corpus, provider, host, VM, or concurrency level.

## Capability Ownership

| Capability | Current owner/class | Current status | P2-09 bundle |
| --- | --- | --- | --- |
| SQLite typed boundary | Local generic incubation | Correct on accepted matrix; independent naming/release/upstream review open | `rxsqlite-candidate` |
| Provider-neutral model contract/adapters | Local Level-G generic incubation over installed HTTP/JSON | Contract accepted; lifecycle and selected Linux/package gates open | `rxllm-candidate` |
| Portable f32 codec and exact oracle | Local Level-G generic incubation | Correct oracle/fallback; installed `rxvector` is selected acceleration | `rxvector-portable-candidate` |
| Parse-once JSON | Installed CREXX | Consumed directly | None; not locally owned |
| HTTP/TLS and packed exact vector provider | Installed CREXX | Consumed directly within recorded limits | None; not locally owned |
| Complete binary SHA-256 family | Installed CREXX | One-shot raw/hex, canonical immutable incremental state, and synchronous bounded-memory file hashing consumed directly | None; not locally owned |
| Schema, repositories, commands, algorithms and jobs | cREXX-RAG application | Product-owned | None; explicitly excluded |
| Provider-lifetime reuse and adapter streaming/cancellation | Deferred decision/qualification | Not implemented or not qualified | None |

## Prepared Review Bundles

P2-09 prepares three reproducible review bundles from canonical repository
files. `cmake/P209.cmake` validates each manifest, requires user and maintainer
documentation beside the implementation, checks every required bundle role,
copies into an isolated build-tree folder, and writes `SHA256SUMS.tsv`. It also
compiles and runs each minimized candidate probe with and without optimization
on both VMs.

| Bundle | Canonical implementation | Included material | Readiness boundary |
| --- | --- | --- | --- |
| `rxsqlite-candidate` | `incubator/p1a/sqlite_boundary/` | Native mechanism, immutable contract, Level-G ADDRESS facade, example/reproducer, P1-SQL-01 through 07 tests and representative evidence | License, name/version, independent release packaging, public dependency policy and upstream approval remain open |
| `rxllm-candidate` | `incubator/phase1b/provider/` | Normalized contract/facade/catalog, local and hosted protocol adapters, HTTP bridge, zero-call example/reproducer, deterministic tests and retained evidence | License, provider-owned pool lifecycle, streaming/cancellation decision, selected Linux/package replay, catalogue release process and upstream approval remain open |
| `rxvector-portable-candidate` | `incubator/phase1b/vector/` | `f32le-v1` codec, pure exact search, example/reproducer, ordering/workload tests and matched current evidence | License, final namespace/split, finite-value/cross-platform policy, independent release packaging and upstream approval remain open |

The generated folders are review artifacts, not released packages. Their
`PACKAGE.toml` files say `review-bundle-not-approved` and
`donation_submission_authorized=false`. The retained hosted provider program is
placed under `qualification-only/`; merely packaging it does not authorize it
to run.

## Decisions Supported

The evidence supports continued cREXX product work through Phase 6 using
installed SQLite, JSON, HTTP, SHA-256 and exact-vector boundaries, and it
supports review of the three local generic candidates as bounded bundles. It
does not support:

- calling the current native executable replaced;
- claiming Linux, high-throughput hosted, cREXX hosted POST completion, or
  provider streaming/cancellation qualification;
- submitting any bundle to CREXX or changing the CREXX checkout; or
- deleting or weakening the native-v1 oracle.

The current incubation audit is authoritative for candidate disposition. A
future donation decision must review the named gaps and may change package
names or split a bundle without changing this retained report.
