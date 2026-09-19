# Local embedding and common-interface comparison — 18 September 2026

**Nomic belongs in the first comparison. The common interfaces showed no
measurable steady-state penalty in the paired tests. BGE-small remains a strong
standalone candidate; the larger models did not consistently improve retrieval.**
This is an exploratory scratch evaluation, not full QE-09 qualification or an
embedding migration. The [review and remaining plan](native-model-follow-up-20260918.md)
retain the wider scope.

## Scope and reproducibility

Installed CREXX `e457f5ec3880`, Apple M5, 24 GiB. Native optimized Level-G
consumers used installed CREXX and its SQLite provider. RAG product code,
configuration and the Scottish master were unchanged. Every inference process
ran with network denied, using an independent writable scratch database. Timed
runs were serial; the desktop was not otherwise isolated, so these are indicative
measurements, not a quiet-machine release benchmark.

The 339 passages, 340 windows, 20 supported questions and four unsupported controls
come unchanged from the [17 September evaluation](native-scottish-evaluation-20260917.md).
Known-support ranking uses exact cosine search, avoiding approximate-index effects.
Question timings exclude the first pass over all 24 questions, leaving 96 samples
per lane. Document totals include the first document request and exclude SQLite
writes and model startup. Timings include result handling and request cleanup.

All four embedding artifacts used explicit pooling, L2 normalization and their
documented query/document prefixes. Each index retained its complete embedding
specification. All successful vectors were finite, normalized and the expected
dimension; every scratch database passed integrity checks.

Nomic Q4_K_M was already present as a Hugging Face snapshot symlink. The initial
filename search missed it; a duplicate download completed before discovery.
Both files match official artifact SHA-256
`d4e388894e09cf3816e8b0896d81d265b55e7a9fff9ab03fe8bf4ef5e11295ac`, revision
`0188c9bf409793f810680a5a431e7b899c46104c`. No model download occurred during
inference. The original cache remains untouched.

## Retrieval and speed

Common-interface measurements below use single requests. BGE-small's table row
uses its first common full-cohort run; a separate paired trial is below.

| Model | File size | Dimensions | GPU query median | CPU query median | GPU: 340 windows | Known support first / top three |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| BGE-small F16 | 64 MiB | 384 | 2.34 ms | 3.72 ms | 1.11 s | 17/20 · 20/20 |
| BGE-base Q4_K_M | 65 MiB | 768 | 4.42 ms | 13.60 ms | 2.79 s | 17/20 · 19/20 |
| BGE-base F16 | 209 MiB | 768 | 4.63 ms | 13.56 ms | 2.54 s | 16/20 · 20/20 |
| Nomic v1.5 Q4_K_M | 80 MiB | 768 | 4.91 ms | 14.84 ms | 2.89 s | 18/20 · 19/20 |

Quality columns are Metal results. Combining keyword and embedding ranks found
the known support in the top three for all 20 questions with every candidate.
This is a small, topic-selected sample with a top-three ceiling; it does not
establish general superiority or exhaustively judge relevant passages.

Nomic improved the cattle-recovery reward and supposed ancient-poem questions,
but moved the peat-fire/Erse travel passage from BGE-small's rank 2 to rank 9.
BGE-base Q4 moved the old-songs question from rank 2 to rank 4. Retained rankings
include source text and citations for reviewing those changes. Unsupported
questions still obtain plausible neighbours; similarity is not answerability.

Backend qualification matters. BGE-base Q4's CPU top-three score was 20/20,
versus 19/20 on Metal. Maximum coordinate differences between CPU and Metal were
about 0.0174 for BGE-base Q4 and 0.0183 for Nomic Q4; BGE-base F16 was about 0.00075.
Their cause was not diagnosed here. These are distinct from wrapper comparisons:
common and direct calls on the same backend agreed exactly. Do not assume
cross-backend numerical identity from common API parity.

Eight-row Metal batches reduced the 340-window totals to 0.69 s for BGE-small,
1.66 s for BGE-base Q4 and 1.70 s for BGE-base F16. Nomic's two-row batch took
2.18 s; four and eight rows were refused by the default 4 GiB admission budgets.
Those refusals are recorded limitations, not successful timings or hardware
allocation measurements. Single-request peak process RSS was approximately
258–278 MiB for the compact models and 409 MiB for BGE-base F16 on Metal;
RSS does not include a complete accounting of GPU/shared-memory allocation.

## Longer Nomic inputs

The official GGUF metadata says **2048 tokens**, and CREXX rejects a requested
8192-token context with `requested context exceeds model training context`.
The [official GGUF guide](https://huggingface.co/nomic-ai/nomic-embed-text-v1.5-GGUF)
explains that its 8192-token use requires context extension. CREXX currently
exposes neither those scaling controls nor admission beyond this metadata limit.
Qualifying that extension is an upstream interface question; it was not bypassed.

Literal contiguous prefixes of the retained Boswell source, including its actual
prose and punctuation, produced these direct-interface measurements. Token counts
include the document prefix and special tokens. Five timed samples followed two
initial requests at each length; these are length/timing tests, not new relevance
questions.

| Input tokens | Metal median | CPU median |
| ---: | ---: | ---: |
| 380 | 25 ms | 280 ms |
| 739 | 51 ms | 630 ms |
| 1204 | 96 ms | 1159 ms |
| 1543 | 136 ms | 1655 ms |
| 1940 | 189 ms | 2264 ms |

The longer negative input was explicitly refused, without truncation. Nomic also
embedded the original whole Gaelic passage that BGE needed split into two
windows, retaining its original citation. Using 339 whole passages instead of
340 windows left its question scores unchanged in this sample. The longer window
is useful, but its cost grows substantially with input length.

## Common interface versus direct llama

Separate-process trials contained a noisy common GPU run (5.23 ms query median,
versus 2.34 ms in its other run). Rather than hiding it or interpreting it as
wrapper cost, an additional focused probe opened both clients in one process and
alternated their call order for each identical input. It reused prepared sessions
and included result consumption and request cleanup on both paths.

| Paired warm workload | Direct median | Common median | Matched output pairs, including initial pass |
| --- | ---: | ---: | ---: |
| BGE-small query, Metal | 2.502 ms | 2.332 ms | 120/120 identical vectors |
| BGE-small query, CPU | 3.767 ms | 3.699 ms | 120/120 identical vectors |
| SmolLM2 generation, Metal | 210.61 ms | 209.61 ms | 30/30 identical text, token counts and finish reason |

Embedding medians use 96 warm pairs; generation uses 24 warm pairs from six varied
frozen Scottish prompts repeated five times. Generation held a 2048-token context,
32-token output cap, identical model and greedy decoding constant. It tests
`.llm.generate` overhead, not whether SmolLM2 is a good answerer; the earlier
grounding failures remain. `.embedding.open` is the separate common embedding API.

The common path showed no measurable steady-state penalty in these workloads.
Small apparent speed advantages are not a universal performance guarantee;
direct callers perform more individual API/diagnostic calls and desktop timing
varies. GPU paired tail differences remained noisy. The native common client
retains its model and context rather than reloading per request.

Startup has a visible one-time cost: later direct BGE open/prepare totals were
approximately 237–242 ms, versus 291–325 ms for the common path. The first direct
run took 780 ms. These are warm-filesystem observations with different factory
and packaging paths, not an isolated estimate of interface dispatch overhead.
The common scratch programs needed an explicit trusted installed plugin path;
the initial absent-plugin failure is retained. Generation result snapshots also
remained usable after closing the common client.

## Decision and evidence

Keep BGE-small as the lightweight reference and Nomic as the longer-input
alternative. BGE-base has not earned a default change on this sample. Continue
with harder held-out questions under QE-09, then Gemma grounded-generation
quality. Nomic's 8192 context extension and the Q4 backend differences need their
own bounded qualification. No RAG native adapter, index migration, Gemma quality
screen or hosted call was performed in this experiment.

The local evidence bundle is
[`cmake-build-debug/native-comparison-20260918/`](../cmake-build-debug/native-comparison-20260918/).
It retains source, compiled consumers, independent databases, exact arguments,
model identities, prompts/results, admission failures, raw timings, paired
comparisons and rankings. No commit or publication was made.
