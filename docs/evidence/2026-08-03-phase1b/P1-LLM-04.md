# P1-LLM-04 Multi-Provider Qualification

Status date: 2026-08-03. Result: accepted.

One provider-neutral Level-B implementation now translates normalized requests
to three distinct hosted protocols while retaining the configurable local
OpenAI-compatible adapter:

- OpenAI Responses structured generation with text/image/file URL parts and
  OpenAI batch embeddings;
- Anthropic Messages structured generation with text/image/document URL parts
  and explicit unsupported embeddings; and
- Gemini `generateContent` structured generation with text/image/document/audio
  URL parts plus `embedContent`/`batchEmbedContents` vector-indexing requests.

A dated cREXX catalog separates model facts from adapter facts. Its seven
records cover generation and embedding models, operations, modalities,
structured/streaming model support, known limits, dimensions, cost tier, and
known token prices. Unknown prices and limits remain `-1`/zero. The catalog is
based on official [OpenAI models](https://developers.openai.com/api/docs/models)
and [embeddings](https://developers.openai.com/api/docs/guides/embeddings),
[Anthropic models](https://platform.claude.com/docs/en/about-claude/models/overview)
and [structured output](https://platform.claude.com/docs/en/build-with-claude/structured-outputs),
and Google [Gemini models](https://ai.google.dev/gemini-api/docs/models),
[embeddings](https://ai.google.dev/gemini-api/docs/embeddings), and
[structured output](https://ai.google.dev/gemini-api/docs/structured-output?lang=rest).
Runtime qualification, not the catalog alone, proves account access and current
response shape.

The deterministic suite passed optimized/non-optimized on both VMs. It checked
exact authorization and payload shapes without retaining header values, parsed
normalized results, projected ordered three-dimensional OpenAI and Gemini
batches, and exercised image, PDF, and audio URL modalities. The loopback
counted exactly 24 requests/connections. OpenAI structured generation and batch
embedding crossed the public Level-G `normalizedproviderfacade`, proving that
the multi-provider backend remains hidden behind the application-facing
contract.

The separately invoked, non-CTest hosted canary made five bounded calls using
environment-only credentials, one attempt, maximum 32 output tokens, and two
short embedding inputs. All passed:

| Provider | Model | Operation | Result |
| --- | --- | --- | --- |
| OpenAI | `gpt-5.6-luna` | structured generation | 46 input, 15 output tokens; 27 estimated USD microunits |
| OpenAI | `text-embedding-3-small` | two-input batch embedding | 128 dimensions |
| Anthropic | `claude-haiku-4-5` | structured generation | 160 input, 8 output tokens; 200 estimated USD microunits |
| Gemini | `gemini-2.5-flash-lite` | structured generation | 13 input, 11 output tokens; price unknown |
| Gemini | `gemini-embedding-2` | two-input batch embedding | 128 dimensions |

```text
cmake --build --preset debug --target p1_llm_04
ctest --test-dir cmake-build-debug -L '^P1-LLM-04$' --output-on-failure
cmake --build --preset debug --target p1_llm_04_hosted
```

- deterministic target: 19.13 seconds, peak RSS 177,228 KiB;
- exact-label CTest: 1/1 in 19.26 seconds, peak RSS 177,216 KiB;
- four-cell output: `raw/p1-llm-04-commands-and-output.txt`;
- secret-free hosted result: `raw/p1-llm-04-hosted-output.txt`;
- command, timing, and source hashes: `raw/p1-llm-04-*`.

This accepts protocol and provider behavior, not the installed transport as an
industrial high-throughput implementation. CRI-15 still blocks Linux timeout
qualification, and CRI-16 records the lack of connection reuse, streaming,
cancellation, compression, response-size bounds, and multiplexing.
