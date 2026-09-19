# Scottish native-model evaluation — 17 September 2026

**BGE-small is promising for standalone retrieval. SmolLM2-360M is not reliable
enough for grounded answers in this screen.** These are exploratory results,
not full QE-09 acceptance or a decision to replace existing embeddings.

## Scope and controls

Read-only public commands collected 339 distinct cited passages from 10 Scottish
source files at generation 29385. Eighteen topic searches supplied prose, OCR,
poetry, index entries and footnotes. Twenty questions with preselected supporting
passages and four deliberately unsupported questions were frozen before
embedding inference. All 20 reference citations were resolved through the public
command. This is a topic-selected sample, not random or complete books.

Installed CREXX `d0feda283857` ran the supported BGE-small-en-v1.5 F16 and
SmolLM2-360M-Instruct Q8_0 artifacts through `import llama`. Small Level-G
experimental programs used installed `rxsqlite` to read scratch inputs and retain
vectors, requests, outputs and timings. Fixture preparation and post-run analysis
were separate from the native inference timing. No product implementation or
CREXX checkout was changed. No hosted calls or model downloads were made.

The master remained at generation **29385**, aligned, with zero reported issues.
All seven result databases passed SQLite integrity checks. CPU/Metal and
single/batch outputs have finite, normalized 384-dimensional vectors; the
evaluated retrieval ranks agree across all four combinations. Each run retained
one model and prepared session. GPU runs, the CPU batch run, and generation ran
with network access denied by the macOS sandbox.

## Embedding speed

Apple M5, 10 CPU cores, 24 GiB; installed optimized native programs, default two
embedding threads. Timed runs were serial on an active desktop on battery.
These are indicative measurements, not quiet-machine release benchmarks.

| Measurement | CPU | Metal GPU |
| --- | ---: | ---: |
| Warm question embedding, median | 3.85 ms | 2.40 ms |
| Warm question embedding, 95th percentile | 4.44 ms | 4.80 ms |
| 340 mixed windows, single requests | 5.10 s | 1.15 s |
| Same windows, batches of eight | 5.36 s | 0.70 s |
| 40 longer windows, 250–350 tokens, single requests | 2.08 s | 0.25 s |
| Same longer windows, batches of eight | 2.37 s | 0.35 s |
| 486-token contiguous passage prefix, median single request | 101.79 ms | 10.01 ms |

The mixed cohort contains 30,417 tokens; the longer cohort contains 11,661.
Batching helped the mixed GPU workload but did not help the longer cohort in
this run. Do not select eight as a universal optimum. The longer batch cohort
has five measured batches and was run later than the reused single-request
measurements; its relative result needs a paired comparison before tuning.

Question summaries use 96 requests after one initial pass over the 24 questions.
Length probes use ten recorded samples after two initial requests per length.
The 161–486-token probes are literal prefixes of one Gaelic passage: useful
token-length stress, not evidence of Gaelic retrieval quality. Document totals
include their first request. Timings cover request creation, preparation of its
input, inference and vector encoding; database writes and model loading are
excluded. Raw process and database-workload timings are retained separately.

Model/runtime opening took 0.24–0.27 seconds with filesystem caches already warm;
session preparation took 3–8 ms. The first admission scan took 0.76 seconds to
open the model. No cold-filesystem result is claimed. Embedding process peak RSS
was approximately 257–407 MiB across configurations; this is not a complete
account of Metal shared-memory allocations or the future application footprint.

## Retrieval effectiveness

Exact cosine search avoids approximate-index effects. Scores are hits on the
known primary supporting passage, not exhaustive relevance or precision scores.
The keyword control is scratch SQLite FTS5/BM25 with non-stopword OR terms;
it is not the complete product lexical/graph retrieval path. The combined
control uses reciprocal-rank fusion with constant 60.

| Search method | Support ranked first | Support in first three |
| --- | ---: | ---: |
| Keyword control | 15/20 | 19/20 |
| BGE embedding | 17/20 | 20/20 |
| Keyword plus BGE | 18/20 | 20/20 |

One useful paraphrase case moved its preselected support from keyword rank 11
to embedding rank 1. Unsupported questions still returned plausible-looking
neighbours: their best cosine similarities ranged from 0.527 to 0.738. Similarity
alone therefore cannot decide whether a question is answerable.

BGE rejected one original Gaelic passage above its 512-token limit. Two windows
with a 150-character overlap retained all its text in the scratch index, producing
340 windows for 339 passages. Parent citation and window offsets were retained;
the master chunks were unchanged. A separately labelled oversized control was
rejected in every embedding run. Larger contexts remain untested and require a
different suitable model, not merely a higher configuration limit for BGE.

## Optional generation screen

SmolLM2 used Metal, a 4096-token context, greedy decoding and a 128-token output
cap. Twenty short requests included both a known supporting passage and the top
three retrieved passages. A fixed prompt required evidence-only answers, source
labels and `INSUFFICIENT` when unsupported. All requests ended normally at EOS;
none failed because of the output cap. Manual review found:

- Correct answer content with known support: **5/8**.
- Correct answer content with three retrieved passages: **3/8**.
- Correct abstention on unsupported questions: **0/4**.
- Required source labels on answerable cases: **0/16**.

Median request time was 238 ms, with a maximum of 445 ms. Despite that speed,
the model invented a telephone number, medical prescription and coordinates,
and confused names and dates present in its evidence. This was a simple prompt
screen with one reviewer, not a tuned model comparison or the product's validated
answer contract. The evidence does not justify using it for trusted answers.

## Decision and retained evidence

Continue local embedding evaluation when the wider CREXX interface is available,
using the same passages and frozen questions. Compare a longer-context model
before choosing an embedding replacement. Keep local generation optional and
evaluate a stronger model separately. Graph comparison, full-corpus retrieval,
end-to-end reader timing, safe alternate-index migration and the broader 60–100
question acceptance remain open under QE-03/04/07/08/09.

Local evidence is retained in
[`cmake-build-debug/native-scottish-evaluation-20260917/`](../cmake-build-debug/native-scottish-evaluation-20260917/).
Its `README.md` indexes the frozen fixtures, source citations, seven scratch
databases, native programs and source, exact hashes, raw timings, ranking results
and every reviewed generation input/output. These local artifacts are not
published repository data. No commit, installation or corpus migration was made.
