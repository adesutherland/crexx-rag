# USearch standalone-search proof of concept — 18 September 2026

## Outcome

**The native-library approach is promising. At this corpus size, exact native
search is the strongest first integration candidate.** It searches all 36,328
existing vectors in a median 1.43 ms per question and agrees with the independent
CREXX exact oracle, allowing float32 rounding and equivalent cutoff ties.
USearch HNSW is faster still but retains approximate-search losses.
No production backend, embedding, schema, default or installation was changed.

Adrian approved this isolated POC without further permission requests after the
[group comparison](vector-group-comparison-20260918.md) found little additional
speed at a loss of known supporting passages.

## Acceptance and implementation boundary

1. **Complete:** export the existing active vectors and identities from the
   restored Scottish test copy at generation 29748 without changing SQLite.
   The scratch Level-G exporter uses the active membership projection from
   ragembedding._loadmatrix, including both link and parent visibility.
2. **Complete:** generate the same 20 frozen question embeddings once using
   the pinned local BGE profile/engine and query prefix. Use the existing
   rxvector.topkcosine as an independent exact top-64 reference.
3. **Complete:** exercise USearch's public C API on known-neighbour controls,
   exact comparison, save/load/view, stable repeated results, malformed matrix
   and zero-vector rejection. Check later-window winner and distinct-parent
   collapse independently of the library.
4. **Complete:** compare exact scanning with HNSW search, load versus memory
   mapping, fresh-process startup, repeated queries, index build time/size and
   process memory. Keep float32 precision and one search/build thread.
5. **Complete:** retain evidence, report losses/limits honestly and identify
   the integration boundary. No permanent native RAG implementation,
   CREXX checkout change, global installation or broad QA run.

The generic C++ probe consumes float matrices and numeric keys through the
published C interface. It knows nothing about SQLite, chunks, generation,
provenance or graph ranking. Corpus export, local inference and the independent
oracle are Level-G cREXX. Python only prepares fixtures and post-processes
retained results; it does not run inference or product orchestration.

## Frozen inputs and build

- Apple M5, 24 GiB RAM, macOS arm64; Apple Clang 21.0.0; optimized native build.
- Upstream [USearch](https://github.com/unum-cloud/USearch), version 2.26.2,
  commit f91fe5bc000222aa1af6e91daf78c2bb20b0c90e, Apache-2.0 license.
  The earlier suggested Nomic URL is a fork; this POC uses upstream.
- Public [C API](https://github.com/unum-cloud/USearch/blob/f91fe5bc000222aa1af6e91daf78c2bb20b0c90e/c/usearch.h).
  Flags: -O3 -DNDEBUG -std=c++17; NumKong and OpenMP disabled, no BLAS dependency.
  These are POC choices, not full platform/packaging qualification.
- 36,328 windows / 36,319 parents; 384 dimensions; existing BGE-small-en-v1.5
  embeddings, no document re-embedding. Matrix SHA-256:
  674556ba42ce568a1f56fccc3daae7368c93213ea530044c67189e72b5d5c34b.
- Little-endian float32 matrix: 55,799,808 bytes; 20 query vectors: 30,720 bytes.
  The diagnostic mapping TSV is 11,937,494 bytes, not a production format.
- cREXX export/query/oracle execution: 3.88 s including local model loading;
  runtime is the already qualified private installed-package copy.
- HNSW connectivity 32, construction expansion 128, float32, sequential adds.
  Build 6.402 s plus 0.043 s save; whole build command 6.47 s. Saved index
  65,839,536 bytes (62.79 MiB); build peak RSS 122.13 MiB.

## Native search results

These timings measure **native search**, excluding query embedding, SQL
hydration, lexical retrieval, graph expansion, ranking and evidence formatting.
They are not complete RAG query latencies. The repaired product's earlier
1.61-second median includes those stages and is not directly comparable.

Each query requests 64 window keys, allowing independent best-window-per-parent
comparison for the final twelve. Exact search has ten repeats; approximate
settings have twenty. The table gives the median of the 20 questions' per-query
medians. Serial measurements on an active desktop are a screen, not an SLA.

| Method | Search expansion | Median native search | Mean exact top-12 recall, tie-aware | Lowest query recall | Peak process RSS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Exact native scan | — | 1.431 ms | 100% | 100% | 55.52 MiB |
| HNSW, loaded | 64 | 0.052 ms | 95.42% | 66.67% | 68.95 MiB |
| HNSW, mapped | 64 | 0.056 ms | 95.42% | 66.67% | 66.16 MiB |
| HNSW, mapped | 128 | 0.092 ms | 96.67% | 66.67% | 66.91 MiB |
| HNSW, mapped | 256 | 0.171 ms | 97.92% | 66.67% | 67.20 MiB |
| HNSW, mapped | 512 | 0.354 ms | 97.92% | 66.67% | Retained in results.json |
| HNSW, mapped | 1024 | 0.696 ms | 97.92% | 66.67% | Retained in results.json |

Increasing expansion above 256 did not recover misses for questions 11 and 20.
One question still retrieves only eight of twelve exact neighbours. This does
not establish a library defect: construction quality, duplicates and graph
connectivity were not separately investigated. No broader backend comparison
or construction-parameter sweep is implied.

### Exactness, ties and source relevance

The largest shared-key score difference between USearch and CREXX is 1.373e-7.
Strict top-twelve key agreement for the exact scan is 99.17%: question 1 has
six equal-score vectors straddling rank twelve, and the libraries select
different members of that tie. Every exact result meets the independent cutoff
within the explicitly recorded 1e-6 tolerance. Raw and tie-aware metrics are
both retained; the latter must not conceal a missing higher-scoring neighbour.

Best-window-per-parent recall has the same results on these questions.
Exact and mapped HNSW return the correct parent with a self-similarity score
for **18/18** extra probes covering both windows of all nine multiwindow
parents. A synthetic fixture proves the later window wins while other parents
remain represented. Loaded and mapped searches return identical keys/distances
for all 20 questions at matching settings.

All native settings return 17/20 frozen references in vector-only top twelve.
The product's hybrid packet returns 12/20 under additional ranking/diversity
stages. These different outputs are not an end-to-end quality improvement claim.
Nearest-neighbour recall, passage retrieval and answer quality remain distinct.

### Loading and memory mapping

Three fresh processes per method use the first frozen question. Filesystem
caches are warm; no disk-cold claim is made:

- Exact matrix read/validation: 19.70–19.96 ms; first search 1.45–1.48 ms.
- HNSW load: 13.17–13.44 ms; first search 0.83–0.89 ms at expansion 256.
- HNSW view: 0.93–1.00 ms; first search 1.89–1.98 ms at expansion 256.

The first mapped search pays page-access costs; mapping is not the whole startup.
The whole-command timer is too coarse for that case (0.00 s), which does not
mean zero latency. RSS rises as mapped pages are touched. The API's 0.28-MiB
mapped allocation excludes those pages and is not the process footprint;
measured multi-question mapped RSS is approximately 67 MiB.

## Recommended next implementation

Keep the product on 16/4 until an integrated candidate passes its affected
journeys. The first candidate should give CREXX a generic native vector
store/search owner that retains the matrix and returns IDs/scores through a
bounded interface. **Start with exact cosine at this corpus size.** HNSW can
remain a later scale option; do not accept its remaining losses for kernel speed.

This supports native vector storage/access, not a claim that USearch is the only
implementation: the existing in-memory rxvector exact oracle also completes
in roughly 12–17 ms per question. Removing JSON traversal and individual SQLite
vector fetches may matter more than choosing between those exact kernels.
Measure the complete integrated command before choosing a permanent dependency.

CREXX owns generic native lifetime, bulk vectors, save/open/view, search and
platform packaging. RAG retains configuration, generation/model identity,
immutable publication, visibility, numeric-key mapping, best-window-per-parent
selection, deterministic ties, graph ranking and citations. SQLite remains
authoritative and the native file rebuildable. Fixed overfetch of 64 suffices
for this fixture, not arbitrary window counts or filtered/stale candidates.

RAG-VEC-02 remains a separate publication defect; a different vector library
would not fix it. Production integration, fault/restart/visibility and platform
qualification, and complete-query timing with USearch remain unperformed.

## Evidence

All sources, upstream checkout, binaries, runtime logs, raw timings, matrices,
mappings, hashes and post-processing are retained at
/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/usearch-poc-20260918/.
The structured report is results.json; analyse.py reproduces it from retained
files. rxvector-oracle.tsv holds the independent exact reference. The Level-G
export opens only the test database in read-only mode. All inference and
measured native calls run with network access denied.
