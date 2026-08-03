# Phase 1B Provider Closeout

Status date: 2026-08-03. Provider section result: accepted. `P1-VEC-01` is
pending and has not started.

## Accepted Capability

The Phase-1B incubation now provides one typed cREXX provider contract, one
thin Level-G facade, and Level-B backends for configurable local
OpenAI-compatible services, OpenAI Responses and embeddings, Anthropic
Messages, and Gemini generation and embeddings. The boundary carries:

- operation, role, model, request identity, privacy class, time and attempt
  limits, output-token and embedding-dimension limits;
- text, image URL, document URL, and audio URL generation inputs where the
  provider protocol supports them;
- normalized generation, ordered `f32le-v1` embedding batches, usage, latency,
  cost estimate, finish reason, request identity, and typed failure results;
- bounded retry/backoff and explicit unsupported streaming/cancellation; and
- pre-transport route denial and environment-only hosted credentials.

The dated seven-record model catalog distinguishes generation and embedding
operations, modalities, known limits/dimensions, structured and streaming
model support, cost tier, and known prices. Unknown facts remain explicit
rather than receiving inferred defaults. Runtime qualification remains the
authority for account access and current wire shape.

## Qualification

`P1-LLM-01` through `P1-LLM-05` pass together. The deterministic tests compile
optimized and non-optimized cREXX modules and run them on `rxvme` and `rxbvm`.
They cover the public Level-G facade, provider-specific payload/auth shapes,
structured validation, ordered batch embeddings, retries, non-retryable
errors, privacy denial, zero denied connections, and secret-retention scans.

The separately invoked hosted canary used one attempt, a 32-token output
ceiling, and short two-input embedding batches. Five calls passed: structured
generation on OpenAI, Anthropic, and Gemini, plus 128-dimensional OpenAI and
Gemini embedding batches. Only provider/model/status/usage/latency summaries
were retained.

The final repository baseline produced:

- Debug configure and build: passed;
- Debug CTest: 44/45 passed in 341.30 seconds;
- sole failure: unchanged CRI-15 `p1a_provider_boundary` Linux receive-timeout
  defect;
- Release configure and build: passed; and
- `git diff --check`: passed.

Raw provider results are retained in `p1-llm-03-*`, `p1-llm-04-*`, and
`p1-llm-05-*`. Repository-wide validation is retained in
`raw/provider-closeout-*`.

## Withheld Claim

This accepts an industrialized provider contract and protocol boundary. It
does not accept the installed HTTP implementation as an industrial
high-throughput transport. CRI-16 records one synchronous connection per
request, `Connection: close`, identity encoding, unbounded response assembly,
and no streaming or cancellation. CRI-15 separately withholds Linux provider
timeout qualification. Both gaps remain generic CREXX capability work; no
product-specific native workaround has been introduced.

The recovery baseline immediately before provider hardening is commit
`f96b94b` (`feat: checkpoint Phase 1B through P1-LLM-02`). This provider
closeout is the next requested baseline checkpoint.
