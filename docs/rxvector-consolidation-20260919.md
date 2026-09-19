# rxvector consolidation — 19 September 2026

The subsequent authorized [CREXX/RAG publication phase](baseline-publication-20260919.md)
records the published and installed baseline. This document retains the initial
private-cohort implementation and QA evidence.

The approved generic binary float32 owner now lives in CREXX `rxvector` as C.
RAG consumes the installed provider and removes its incubating `rxvectorindex`,
vendored USearch and private SDK/C++ link staging. This is a local implementation
and qualification record; global installation and Git publication are separate.

## Ownership and compatibility

CREXX owns `.vectorindex`, `openindex`/`decodeindex`, exact cosine search,
immutable copy/close lifetime and the RXVIDX/1 binary codec. The original packed
double procedures remain available and process-reentrant. The new native
object calls are session-affine and retain no borrowed VM values or host pointers.
The complete API and format are documented in CREXX
`docs/books/crexx_library_reference/rxvector.md`; its bounded delivery plan is
`docs/planning/rxvector-binary-owner-20260919.md` (RXVECTOR-02).

The owner stores canonical float32 bytes and label offsets, avoiding full-matrix
double expansion. Exact ties use original row order. Import rejects truncated,
overflowed or trailing data, non-finite values and zero/extreme float32 norms.
Opaque labels and metadata preserve UTF-8 and embedded NUL bytes. Search uses
double accumulation, so comparison with the former float32 USearch kernel uses
an explicit absolute score tolerance of 1e-7.

RAG's `ragembedding`, `ragbackup` and `ragretrieval` retain input projection,
checksums/publication, SQLite visibility, result widening and best-window-per-parent
ownership. There is no new schema, configuration, recovery path or product rule.
`exact-native-v1` remains opt-in; existing IVF settings remain unchanged. Query
traces now name `rxvector-exact`. Existing RXVIDX/1 sidecars read directly without
rebuilding or re-embedding. Missing/corrupt files retain ordinary recovery.

The RAG build needs installed `rxvector` metadata and static archives exposing
the new interface. Its installed-provider consumer proves both VM and native
packaging, without a private provider overlay or extra vector C++ runtime.
Other components, including native inference, retain their own dependencies.

## Regression first and focused qualification

The new provider-interface test failed against the original installed provider
with missing class/procedure diagnostics before implementation. Existing packed
controls passed. The implemented C codec is checked independently for all
truncated prefixes, malformed lengths, overflow, trailing bytes, numeric bounds,
257-way ties and 100 synthetic comparisons with the existing double kernel.

Existing and new contracts pass on `rxvme` and `rxbvm`, with optimization on and
off. The standalone native owner passes copy/close and checked failed-import
controls. Production CREXX Release provider targets also build successfully.
Focused AddressSanitizer/UndefinedBehaviorSanitizer codec and statically linked
owner checks pass in 0.54 s. These instrument the new provider, not the whole VM
or inference engine. LeakSanitizer is unavailable on this macOS host; other
platform and Linux leak qualification remain separate.

An initial native consumer build found a stale root `bin/rxvector.rxplugin` in
the private cohort while `bin/providers` had been updated. Updating both copies
resolved the mismatch; the failed build and passing replay remain in evidence.

RAG `vector_provider`, `ann_methodology`, `native_vector`, `native_vector_public`,
`gemini_query` and `linked_application` pass in 17.34 s. These cover the installed
interface, sidecar reactivation, multiple windows/distinct parents, visibility,
backup/recovery, public query preflight and provider receipts. Generic core
coverage moves to CREXX; replacing the incubation's two local cases with one
installed-provider case changes the required RAG count from 131 to **130**.

The complete required selection took **541.25 s** (9 min 1 s), with 124 fresh
executions and six retained focused passes. It exposed two issues, both retained
in `regression.log`:

- `process_workers` used the selected runtimes for its worker matrix but let the
  final staged launcher find the older `~/.local` runtime on PATH. The new API
  correctly rejected that mixed cohort. A selected-cohort launcher control
  passed; the fixture now prepends `CPRAG_CREXX_BIN_DIR` consistently.
- `native_embedding_windows` hit its unchanged 10-second model-load limit while
  scheduled for only two slots alongside other cases. The failed settlement and
  dead-letter reason are retained in `model-load-failure.json`. The entire
  unchanged case passed in isolation in **10.91 s**. Its declared demand is now
  eight slots, accounting for two native inference workers and model-loader
  threads. At the supported local `-j8` selection it runs alone. This is a QA
  scheduling repair, not a larger timeout or a claim to have proved the precise
  cause of the load delay.

No product or provider code changed after the Release comparison. Only the
repaired launcher case and closing documentation need new execution; the
isolated real-model pass and all other exact-input passes remain reusable.
The repaired `process_workers` case passes in **32.12 s**. Final qualification
accounts for **130/130 required passing cases**, with changed documentation
receiving its own closing contract check and `qa-final.json` retaining the
`--require-complete` exact-input audit. No disabled or unexecuted case is counted
as a pass, and the full selection is not repeated. The separate scale lane,
hosted calls and other-platform gates are outside this local selection.

## Integrated Release comparison

Forty offline public hybrid queries alternate the retained USearch executable
and final C/rxvector candidate over the same twenty questions and existing
Scottish scratch corpus. Generation 29748 contains 36,328 windows for 36,319
parents, 384 dimensions. Network is denied; each command performs one local BGE
query embedding, three graph hops and returns up to twelve passages.

| Complete CLI query | Median | Range | Median peak RSS | Known reference hits |
| --- | ---: | ---: | ---: | ---: |
| Retained USearch control | 0.965 s | 0.91–1.43 s | 458.26 MiB | 12/20 |
| Integrated C/rxvector | 0.965 s | 0.91–15.78 s | 457.80 MiB | 12/20 |

All twenty passage orders match. The only evidence differences are the expected
backend label and 61 cosine scores, with maximum absolute difference 9.38e-8.
Command envelopes also have distinct provider receipt IDs, as expected for
separate calls. The first candidate launch is the retained 15.78 s outlier;
its cause is unproven. No sample is removed, caches are not cleared, and the
median is not a cold-start guarantee. Median CPU times are 0.910 s candidate and
0.915 s control. There is no material steady-state speed or result loss from
removing USearch on this workload; exact scanning remains linear in corpus size.

## Artifact and evidence boundary

RAG source starts from `e949884794cce8e3d3b9e46bb9225c214de7eda4` plus the existing
local work and this consolidation. CREXX source starts from
`47168a1f16365d6c2aaa54de770889c0e8dce6a4` plus the bounded vector changes;
unrelated working changes are preserved. No clean-SHA publication is claimed.

The private installed cohort retains the previously qualified 15c8a3ba4200
runtime/compiler and JSON repair, with only rxvector replaced for this work.
Its original BUILDINFO does not describe that replacement; component hashes do:

| Artifact | SHA-256 |
| --- | --- |
| RAG native executable | `048845f024305402296b31b4312f7cfd860895bf5b11162fd2adbbb9892a8ef0` |
| rxvector metadata/dynamic provider | `918a38ee15d965bfcd70c797248bc29bbbaedfb6f703a7c66324f84af57d6c2f` |
| rxvector static archive | `0953ef24ef852126fcc6e7679f09792d5d4d44b32277b27a988efc10cf0ec020` |

Evidence root:
`/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/rxvector-consolidation-20260919/`.
It retains baseline failure, old/new contract logs, native packaging, sanitizer
logs, all forty raw query outputs/timings, `paired-comparison.json`, artifact
hashes, focused results and final gate/audit. RAG builds in
`cmake-build-rxvector`; tests use private execution directories. The original
Scottish library, configuration and global `~/.local` installation are unchanged.
