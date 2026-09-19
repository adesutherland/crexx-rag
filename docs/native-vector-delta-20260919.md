# Native integration versus POC — 19 September 2026

This diagnostic checkpoint is followed by the implemented and locally qualified
[retrieval tightening and dependency comparison](retrieval-tightening-20260919.md).
The prototype/pending language below describes this earlier checkpoint.

The integrated native search still matches the POC: **1.451 ms** versus the
POC's **1.431 ms**. The roughly 1.5-second public command includes substantial
work outside that search. A disposable diagnostic isolates the largest
avoidable cost in `ragfile.readbinaryfilebounded`: repeatedly concatenating the
growing binary buffer. Appending instead reduces its measured 61 MB read from
532 ms to 11 ms and the complete example query from 1.54 s to 1.01 s.

This is investigation and a scratch prototype, **not a product repair or new
qualification claim**. The qualified RAG executable, plugin, configuration and
Scottish master remain unchanged. No broad test suite or corpus migration runs.

## Comparable scopes

The [POC](usearch-poc-20260918.md) timed native cosine search over an already
loaded matrix and already generated question vectors. It excluded embedding,
file loading, checksum verification, SQL visibility, graph retrieval, ranking
and evidence formatting. Its separate fresh-process matrix read/validation
took about 20 ms.

The [integrated comparison](native-vector-delivery-20260918.md) measured a fresh
CLI process performing a public hybrid query. It opens configuration/database,
verifies the index before calling a provider, opens the local BGE model and
embeds the question, reads/verifies/decodes the index, retrieves and ranks
evidence, records provider usage and serializes the result. Comparing 1.431 ms
directly with 1.565 s therefore mixes different operations. The kernel itself
has not acquired a comparable slowdown.

## Measured phase breakdown

Four serial fresh-process queries use the first frozen Scottish question,
generation 29748, 36,328 vectors, the same native sidecar and BGE model, three
graph hops and twelve passages. Timestamps were added only to copied cREXX
sources and packaged with the same private installed CREXX cohort and native
plugin. All calls deny network access and generate no answer. Complete evidence
objects are identical to the retained qualified query, including passage order,
scores, claims and trace. Filesystem caches were not forcibly cleared.

| Phase | Median elapsed time |
| --- | ---: |
| Preflight file read and checksum | 184.3 ms |
| Local model lifecycle and question embedding | 235.1 ms |
| Second file read, accumulating the binary buffer | 532.2 ms |
| Second checksum of the loaded bytes | 140.9 ms |
| Native decode, ownership and validation | 21.2 ms |
| Native exact search through the cREXX interface | **1.451 ms** |
| SQL visibility and distinct-parent selection | 0.516 ms |
| Graph traversal, ranking and evidence assembly | 7.1 ms |
| Other command work, including startup, planning, output and shutdown | about 417 ms |
| **Complete command** | **1.54 s** |

The last category is the residual against the rounded whole-command timer,
not a separately instrumented single stage; sums of medians are approximate.
Lexical and query-planning work is included there. This is a bounded diagnosis
of one representative query, not a new 20-question benchmark or an SLA.
The tiny SQL visibility interval does not support attributing this serial
query's delay to database history or transaction contention. The migration's
concurrent write contention remains a separate finding.

## Buffer-copy control

`ragfile.readbinaryfilebounded` currently reads in 65,536-byte blocks and runs
`data = data || chunk` for each. There are 938 blocks for the 61,430,712-byte
native index. Repeatedly copying the prior accumulated bytes creates quadratic
work; the straightforward sum is approximately 28.8 GB of prior-buffer data.
This was less visible for the former 6.9 MB JSON sidecar.

A scratch variant replaces only that accumulation with the existing binary
append primitive, `call binappend data, chunk`. It retains byte ceilings, read
errors, close handling and both checksum stages. Three serial interleaved
qualified-control/diagnostic-variant pairs give:

| Measure | Qualified control | Scratch append variant |
| --- | ---: | ---: |
| Complete command samples | 1.90 / 1.54 / 1.53 s | 1.23 / 1.01 / 1.01 s |
| Complete command median | 1.54 s | **1.01 s** |
| Instrumented reader median | 532.2 ms, four original runs | **10.7 ms**, three variant runs |
| Median maximum RSS | 447,037,440 bytes | 376,242,176 bytes |
| Complete evidence versus retained original | Identical | Identical |

The measured complete-query reduction is about 34%. The first slower pair is
retained. The diagnostic variant still includes phase-timestamp overhead;
current uninstrumented controls and instrumented original runs share the same
1.54-second median. This is strong evidence for the bounded reader repair, not
complete file-I/O regression coverage.

## Recommended repair order and ownership

1. **Fix buffer accumulation in `ragfile`.** First add focused characterization
   of exact bytes across block boundaries, empty files, ceilings and failures.
   Retain the existing native/IVF corruption, missing-file, backup/restore and
   public hybrid checks. This removes the measured copying cost without adding
   a cache, changing retrieval results or weakening integrity checks.
2. **Reuse verified bytes within a query.** `ragqueryservice._querysidecaravailable`
   currently reads/hashes the file before provider work;
   `ragretrieval._vector` reads/hashes it again. Preserve that early rejection
   and pin the selected publication, but pass/reuse the verified immutable
   payload in that request. Do not simply delete a check or trust a pathname
   that can change between stages. Design and test this separately from step 1.
3. **Measure repeated-query model reuse if still needed.** The embedding phase
   includes model startup/close, unlike the POC's reused model. Persistent
   sessions could amortize that cost, but they are a later lifecycle decision.
   Native decode is only about 21 ms and search about 1.45 ms here; another
   search algorithm or HNSW is not the first response to this measured gap.

After the agreed code changes, use focused tests while iterating, compare
uninstrumented complete queries, then account for one final required local gate.
The generic plugin's existing qualification and donation source are unaffected
by this RAG reader prototype. The prototype has not been promoted into the product.

## Retained evidence and exclusions

Directory:
`/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/native-delta-20260919/`.
It contains copied instrumented sources, build arguments/logs, original and
append diagnostic binaries, `phase-results.json`, `reader-results.json`, every
query's JSON and timing log, plus artifact hashes and an analysis script.

The qualified executable remains SHA-256
`95e816a8656523e089d61003c57c2e547a0a43c3da030d84f7a847e6d64fac2b`.

Three initial setup calls overlapped inadvertently and are excluded from all
serial performance conclusions; their logs retain a WAL-lock retry and slower
model calls. No attempt is made to interpret them as the normal query latency
or to hide them. An incorrectly formed control invocation and unsuccessful
standalone reader-probe builds are likewise retained as setup failures. The
successful diagnostic uses the complete copied product and compares its actual
public-query output. Only successful serial calls populate the reported tables.
