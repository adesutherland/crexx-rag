# Native vector integration — 18 September 2026

Subsequent delivery: the [19 September consolidation](rxvector-consolidation-20260919.md)
moves the generic owner into CREXX rxvector and removes this incubation package.
The following retains the original implementation and qualification evidence.

Adrian approved local implementation, tests and RAG integration. Donation to CREXX is a later action. No master-corpus modification, commit, publication or global installation is included.

## Outcome and acceptance

1. Generic RXPA provider owns immutable float32 vectors, opaque labels and metadata, exact cosine search, deterministic row-order ties, bounded binary import/export and safe copy/close lifetime. No SQLite or RAG policy enters native code.
2. RAG selects the exact backend through its existing vector policy, publishes rebuildable files and retains visibility, best-window-per-parent, ranking and citation ownership. Existing IVF indexes remain readable.
3. Invalid input/sidecars, zero norms, missing and corrupt files, duplicate windows, partial coverage, graph-only generations, removal, backup/restore and A/B/A reactivation have regression evidence.
4. Targeted gates precede one complete stable local gate. Corpus-copy timings and frozen-question results distinguish kernel speed from complete query latency.
5. Source, upstream version/license, API documentation and evidence form a donation-ready package. Platform qualification outside this host remains explicit.

## Baseline

The existing 127-case qualification is retained. On this turn, ann_methodology, publication and configuration_contract reused passing exact-input receipts (CTest skipped execution, not disabled tests). Inspection confirms existing corruption/missing-sidecar, graph generation, visibility and duplicate-window coverage. A/B/A regression is added before implementation; results follow below.

## Status

Implemented and locally qualified. The generic provider and opt-in
`vector.algorithm = exact-native-v1` backend are integrated. The default remains
`ivf-flat-v1`; existing indexes remain readable. SQLite remains authoritative,
and schema 20 records both index formats. Final required coverage is 131 cases,
with exact-input evidence audited by `tests/qa/report.py --require-complete`.
Donation to CREXX, other-platform qualification, commit/publication and global
installation are separate actions. The Scottish master is unchanged.


## Failure-first integration evidence

- A/B/A: `ann_methodology` failed in 5.01 s at the new assertion, with both initial publications passing. The immutable target already exists error is retained under `cmake-build-retrieval-profile/qa/runs/ann_methodology/20260918T221717-51ac48cd`.
- After shared binary replay/reactivation, the existing and new retrieval fixtures passed on both VMs. Initial focused integration found one missing dynamic-provider search path; the corrected linked application and configuration checks pass.
- Additional public/maintenance acceptance deliberately exposed the remaining IVF-only conditions. `native_vector_public` failed in 1.51 s at hybrid preflight; `native_vector` failed in 4.60 s because a clean native index still scheduled another publication. These failing receipts are retained under the 20260918T224127 run directories. Both pass after corrections in `ragqueryservice` and `ragmaintain`.
- A fresh public restore of the immutable Scottish backup took 171.67 s. Schema 19 → 20 migration of that copy passed with generation 29748 and aligned manifest. The master and earlier experiment copies remain untouched.

## Native packaging boundary

The generic directory is `plugins/vectorindex`, with unchanged pinned USearch C API/headers and its Apache-2.0 license, local MIT wrapper/core/tests and an API/lifetime README. A private package view handles the installed driver's fixed provider-archive lookup and explicit C++ runtime link requirement. The native interface test passes rxvme, rxbvm and the packaged executable, including independent owner copies and embedded-NUL UTF-8 labels. Other-platform qualification and CREXX donation are not claimed.

## Qualification record

The candidate is based on `e949884794cce8e3d3b9e46bb9225c214de7eda4` plus the
preserved working changes. Build directory: `cmake-build-retrieval-profile`.
It uses the private installed CREXX cohort from the earlier retrieval repair;
neither the global installation nor a sibling checkout was modified.

- Final native executable SHA-256:
  `95e816a8656523e089d61003c57c2e547a0a43c3da030d84f7a847e6d64fac2b`.
- Linked application SHA-256:
  `32c9fca83ea4aa1d93b4a99b7feb57149b55c141e25403de327fc7a6c62f59f7`.
- The full code selection accounted for 130 cases in **529.49 s** with eight
  process slots. Three current focused passes were retained without duplicate
  execution. Its sole failure was an unnecessary module added to the transport
  test's module list without the corresponding search directory. Removing that
  unnecessary test dependency restored `local_embedding_protocol` in 6.91 s.
- `ann_methodology` additionally checks reactivation rejection for a changed
  semantic generation, changed vector revision and unknown immutable identity,
  with the prior publication preserved. These added assertions passed in 6.00 s;
  their parallel selection with the transport correction took **6.92 s**.
- `native_vector_public` exercises automatic publication during ingestion,
  hybrid preflight and answer generation, grounded citations and durable provider
  records. `native_vector` verifies that a clean native index does not schedule
  maintenance publication repeatedly. Gemini and malformed-output/privacy
  regressions remain in the full selection, using fixtures without hosted calls.
- The documentation contract runs after final documentation edits. The final
  auditor accounts for **131/131 required cases**, with no disabled, failed or
  missing cases. The separate scale lane is not part of this functional gate.
  Original failed receipts are retained; only affected cases were rerun.
- The generic directory also builds independently against the installed SDK,
  and its standalone core test passes. A separate AddressSanitizer and
  UndefinedBehaviorSanitizer build of the generic core and upstream C API
  passes the same numeric, binary and cutoff-tie controls without diagnostics.
  This instrumentation covers the core, not the VM wrapper. `qa-final.json`, standalone build/test
  logs, artifact hashes and `candidate-tracked.diff` are retained with the corpus
  evidence. The source-only `rxvectorindex-donation.tar.gz` includes wrapper,
  tests, pinned upstream headers/C wrapper and both licenses.

The full QA result qualifies this host and candidate. Migration contention and
the earlier native-model timeout remain separate tracked findings; this work
does not claim to resolve them. The native index is an exact linear scan, with
the memory and size limits reported below; approximate HNSW remains a POC only.

## Scottish corpus comparison — completed

Evidence is under `/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/native-vector-integration-20260918/`.
All measured product calls deny network access. They use the same BGE model,
36,328 windows, 36,319 parents, generation 29748 and 20 frozen questions.
Only this fresh restored copy is migrated and reconfigured.

| Route | Median full query | Known reference passages | Passage order against exhaustive IVF |
| --- | ---: | ---: | --- |
| Existing IVF 16/4 | 1.610 s | 12/20 | Approximate baseline |
| Exhaustive IVF 16/16 | 2.250 s | 12/20 | Reference |
| Native exact | 1.565 s | 12/20 | Identical for all 20 questions |

There are no lost or gained known reference passages versus the 16/4 baseline.
The native route achieves exhaustive output at roughly approximate-route latency;
the 2.8% difference from 16/4 is too small to claim a reliable speed improvement.
The larger reduction against exhaustive IVF is about 30%. Native kernel timing
alone must not be presented as whole-query latency. These serial measurements
ran before the full QA workload; filesystem caches were not forcibly cleared.
First native query: 2.48 s; remaining range/complete-run range: 1.50–2.48 s.

Public native rebuilding took 5.33 s, made zero model calls and produced a
61,430,712-byte file. Peak rebuild footprint was 958,121,136 bytes; largest query
RSS was 450,199,552 bytes, including the BGE model and product pipeline. This is
not a claim of minimal memory use. The initial implementation loads owned vectors
and retains the existing Level-G matrix-building path; no mapping/cache service
or broad memory redesign is included.

An independent binary parser verifies every window label against the earlier
export, and the complete 55,799,808-byte matrix is byte-identical, SHA-256
674556ba42ce568a1f56fccc3daae7368c93213ea530044c67189e72b5d5c34b.
`native-format-audit.json`, `results.json`, `analyse.py`, all 20 command outputs,
per-command timings and artifact hashes are retained. Full library/repository
verification reports zero issues (70.29 s while the QA workload was also running).
The first attempted `query inspect --mode hybrid` was rejected correctly because
inspect is lexical-only; its failed receipt is retained separately. Measurements
use `query search --mode hybrid`, matching the earlier comparison.
