# Native model review and proposed investigations — 18 September 2026

Status: review complete. The initial embedding comparison now includes Nomic,
and common/direct embedding and generation overhead has been measured in the
[18 September scratch results](native-interface-comparison-20260918.md).
Gemma grounding, broader quality selection and product integration remain open.
The aim is a small offline reader using local embeddings, existing graph and
source evidence, with generation optional. Select a larger model only when its
measured benefit justifies its latency, memory and index size.

The subsequent agreed implementation direction is
[atomic embedding windows](architecture.md#atomic-embedding-windows--agreed-design):
one selected local model, larger original chunks for graph work, temporary smaller
windows for embeddings, and one complete embedding list stored per chunk in an
atomic transaction. A failed window fails the chunk attempt; retry starts that
chunk again. No persisted window locations or per-window recovery state are
needed. Search uses the best score per parent. Nomic remains comparative evidence,
not a requirement to ship or load a second embedding model.

## What changed

The CREXX checkout and installed package identify revision
`e457f5ec38806907ac94303dead240b92eac3381`. The implementation is in
`e5a0c7a5b`, with an interface-factory signal repair in `1d2feb35f` and final
documentation in `e457f5ec3`. RAG remains at `e949884794cc`; no product change
or corpus migration accompanies this review.

There were two different interfaces behind the apparent hosted-provider gap:

| Surface | Before this update | Current position |
| --- | --- | --- |
| CREXX `.llm` | Only `.ollama` implemented the interface; separate OpenAI, Anthropic and Gemini classes existed | `.llm.open(.llmconfig(driver, model))` selects Ollama, OpenAI, Anthropic, Gemini or native llama |
| Legacy `.llm(model, host, port, timeout)` | Ollama factory | Still selects Ollama |
| RAG hosted generation and embeddings | Its own `.industrialprovider` HTTP adapters, plus managed `.codexprovider` | Unchanged; RAG did not depend on the old `.llm` factory |
| CREXX common embeddings | Native typed API | Separate `.embedding.open(config)`, currently native llama only |

RAG's routing is visible in
[`ragqueryprovider`](../crexx/application/ragqueryprovider.crexx) and
[`ragapplicationprovider`](../crexx/application/ragapplicationprovider.crexx);
HTTP protocol handling belongs to
[`industrial_provider`](../crexx/providers/industrial_provider.crexx).
The Scottish configuration still selects hosted Gemini embeddings and managed
Codex extraction. The statement that the old common interface only supported
Ollama did not mean that hosted inference was unavailable.

General native profiles now admit compatible GGUF models with a verified supplied
SHA-256, rather than a compiled list of model names. Embedding pooling,
normalization and query/document prefixes must be explicit. The returned
embedding-space specification identifies the artifact and preparation; retain
it with each index. The original two reference presets remain available.

Do not replace RAG's hosted adapters simply to share a class name. Common HTTP
results currently report unknown usage (`-1`), lack actual provider finish
reasons and cannot accept a separate system prompt or interrupt a blocking call.
`generateJson` returns the server's JSON body; it is not schema-constrained
generation. Codex App Server is not one of these common drivers. RAG's structured
validation, accounting, receipts and admission controls must remain authoritative.
The useful first integration is native embeddings behind the existing provider
boundary, with one persistent model/context owner.

## Available candidates and limits

Sizes below are model-file sizes, not runtime memory. Dimensions and context were
checked in the installed GGUF metadata. The common native wrapper currently caps
context at 8192 tokens and also enforces each model's smaller training limit.

| Installed artifact | Size | Relevant property | Proposed use |
| --- | ---: | --- | --- |
| BGE-small v1.5 F16 | 64 MiB | 384 dimensions; 512 tokens | Retain as the speed and quality reference |
| BGE-base v1.5 Q4_K_M | 65 MiB | 768 dimensions; 512 tokens | First larger embedding comparison |
| BGE-base v1.5 F16 | 209 MiB | 768 dimensions; 512 tokens | Measure quantization's quality and speed trade-off |
| Nomic Embed v1.5 Q4_K_M | 80 MiB | 768 dimensions; this GGUF has 2048-token metadata | Included in the first embedding comparison; 8192 extension is not admitted by current CREXX |
| Gemma 4 E4B Q4_0 | 4.3 GiB | Dense generation model | First grounded-answer comparison |
| Gemma 4 12B Q4_0 | 6.7 GiB | Larger dense generation model | Conditional second comparison if E4B is inadequate |
| Gemma 4 26B-A4B Q4_0 | 13.6 GiB | 128 experts in metadata | Exclude from this native trial: the bridge rejects expert/MoE layouts |

BGE-base Q4 is almost the same download size as BGE-small, but its vectors require
twice the raw storage at the same vector precision. Similar file size does not
establish similar inference latency or memory. Neither BGE-base variant extends
the 512-token input window. The installed Gemma generators are not EmbeddingGemma.

Upstream qualification records BGE-base F16/Q4 CPU compatibility and numerical
comparison with its engine. Gemma E4B produced four greeting tokens on CPU with
explicit raw turn markers. Its newer chat template is not automatically supported
by the pinned engine. This proves a narrow generation path, not useful answers,
Metal operation or the other Gemma variants. Larger models also need explicit
memory admission budgets; model-file size alone does not prove they fit.

These findings come from the installed `share/crexx/llama/common.md` and
`models.md`, and the sibling CREXX
`docs/qa/llm-interface-review-20260917/qualification.md`, model manifests and
consumer example. Upstream checks were reviewed, not repeated. Hosted driver
fixtures are not evidence of new live hosted calls from RAG.

## Proposed sequence and acceptance

1. **Prove the updated embedding interface on the existing sample.** Compile a
   separate scratch consumer against the new install. Compare the reference BGE
   preset through `.embedding.open` with the previous typed path on fixed inputs;
   retain identity, finite normalized vectors, ranks and explicit failure for
   oversized input. Prove reuse over repeated requests and usable owned results
   after close. Keep the previous executables and evidence frozen. Acceptance:
   equivalent preparation has equivalent results within a recorded numeric
   tolerance, with no silent model/backend fallback or truncation. Also compare
   `.llm.generate` with direct native generation using identical model, prompts,
   output cap and processing settings. Separate startup from steady-state calls
   and alternate API order in one process if separate runs show timing noise.
   Initial same-backend parity and paired performance checks are now complete.

2. **Compare the three installed BGE artifacts and Nomic together.** Reuse the 339 passages,
   340 windows and 24 questions from the
   [first evaluation](native-scottish-evaluation-20260917.md). Keep separate
   indexes and full specifications. Measure first-use loading, warm queries,
   document throughput, CPU/Metal, paired single/batch requests, peak memory and
   index bytes. Run timing measurements serially on the same machine; independent
   preparation and analysis may run in parallel with private writable folders.
   Acceptance: report support rank, top-three support and regressions alongside
   median/tail latency and memory for every candidate. No replacement decision
   from this small sample: its 20/20 top-three baseline is already at the ceiling.
   Before choosing a default, expand to the existing QE-09 requirement of 60–100
   supported questions with OCR, names, dates, paraphrases and confusing neighbours.
   The initial four-model screen and Nomic length probes are now complete; larger
   question coverage and cross-backend Q4 qualification remain open.

3. **Screen Gemma E4B for grounded answers.** Verify its explicit turn formatting
   first, then reuse the frozen 20-request generation screen: known support,
   retrieved support and unsupported questions. Start with one request at a time
   and a bounded 1024/2048-token context where the complete prompt fits; reject
   oversize input explicitly. Record complete inputs/outputs, finish reason,
   first-token/total latency and memory. Acceptance: score factual correctness,
   valid source labels and abstention separately. Any invented answer on the four
   unsupported controls fails this initial grounding screen. Passing it is only
   permission to widen evaluation. Try 12B only if E4B leaves a useful quality gap
   and measured resource headroom supports the trial.

4. **Include longer passages in the first Nomic trial.** Its
   [model card](https://huggingface.co/nomic-ai/nomic-embed-text-v1.5)
   specifies an 8192-token context with task prefixes, but the official GGUF has
   2048-token metadata and needs context extension for 8192. The existing cached
   Q4 model was found behind a Hugging Face symlink. Native 2048 operation is now
   tested; the current interface rejects 8192 rather than silently extending it.
   Compare whole passages
   with bounded overlapping windows, preserving original citation offsets.
   Acceptance: explicit length admission, no lost source text, and useful support
   retrieval per latency/memory cost. Larger input support alone is not a quality
   improvement. The [BGE model card](https://huggingface.co/BAAI/bge-base-en-v1.5)
   confirms that BGE-small/base remain 512-token alternatives.

5. **Then prove the standalone reader journey.** Compose the selected embedding
   provider with RAG's retrieval, graph traversal and citation validation. Measure
   complete search time, including vector/index/database and graph work; the
   previous millisecond figures cover embedding only. Acceptance: an installed
   reader finds cited evidence with network denied and no extraction credentials,
   retains the graph and source identities, and performs no implicit corpus
   mutation. Generation remains optional. This step requires the still-open
   product native adapter; a scratch benchmark does not close QE-03/04/07/08/09.

Use isolated scratch libraries and no hosted calls for these investigations.
Changing an embedding model requires a separate compatible vector index even
when dimensions happen to match. Do not re-extract sources or replace the
Scottish master embeddings during selection. Formal product qualification and
migration follow only after an integration change is agreed and implemented.
