# Provider Contract Usage

Status: implemented generic cREXX incubation for a possible future `rxllm`
package. The normalized contract and protocol mappings are accepted on
Phase-1B evidence and now compile against installed HTTP/socket foundations.
The focused installed-only macOS provider matrix passes, and upstream has
supported Linux sanitizer/cross-platform HTTP evidence. The package is not
installed, donation-ready, or approved for provider-lifetime high-throughput
reuse until the downstream lifecycle and Linux/package gates are complete.
P2-09 adds a reproducible review recipe in [`BUNDLE.tsv`](BUNDLE.tsv),
explicitly non-released [`PACKAGE.toml`](PACKAGE.toml) metadata, and a zero-call
compiled [`candidate_probe.crexx`](candidate_probe.crexx).

See [SYSTEM.md](SYSTEM.md) for module ownership and known transport constraints.
The experimental ChatGPT-subscription route is documented separately in
[README-CODEX.md](README-CODEX.md).

## Supported Operations

The `.provider` interface exposes:

- `capabilities()`;
- `generate(request)`;
- `generate_structured(request)`;
- `embed(request)`;
- `embed_batch(request)`; and
- `cancel(request_id)`.

Every method returns `.providerresult`. Unsupported capabilities return a typed
failure rather than falling back silently.

## Minimal Local Example

This example targets a local OpenAI-compatible endpoint. It does not require or
authorize a hosted-provider call.

```rexx
options levelg

import provider_contract
import openai_compatible_provider

messages = .providermessage[]
messages[1] = .providermessage("system", "Answer concisely")
messages[2] = .providermessage("user", "Summarize the supplied evidence")
inputs = .string[]
inputs[1] = "unused"

backend = .openaicompatibleprovider("127.0.0.1", 8080, 0, "/v1", "", "local-model", "local")
request = .providerrequest("generate", "answer", "local-chat", messages, inputs, "", 30000, 2, "local", "answer-001", "request-001", 0, 0, 0, 0)

capabilities = backend.capabilities()
if capabilities.chat() = 0 then return 1

result = backend.generate(request)
if result.status() \= 0 then do
  failure = result.error()
  say failure.category() || ": " || failure.message()
  return 1
end

say result.content()
return 0
```

The complete compiled examples in `p1_llm_01.crexx`, `p1_llm_02.crexx`, and
`p1_llm_04.crexx` are authoritative if compiler syntax changes.

## Request Records

| Record | Purpose |
| --- | --- |
| `.providermessage` | Role plus text, image URL, document URL, or audio URL input |
| `.providerrequest` | Operation, application role, model, content, schema, timeout, attempts, privacy, identities, token/dimension limits, streaming request, and optional temperature millionths |
| `.providercapabilities` | Truthful supported operations, modalities, limits, formats, streaming, cancellation, and connection reuse |
| `.providerresult` | Normalized generation or embeddings plus provider/model/request identity, usage, latency, finish reason, and typed error |
| `.embeddingrecord` | `f32le-v1` binary payload and element count |

Valid operations are `generate`, `generate_structured`, `embed`, and
`embed_batch`. Privacy classes are `local`, `restricted`, and `public`.
Hosted routes currently accept only `public`; policy denial occurs before the
transport is called.

Each request needs positive `timeout_ms`, one through ten attempts, and nonempty
idempotency and request identifiers. Generation needs at least one message;
embedding needs at least one input. Structured generation also needs a JSON
schema.

`temperature_millionths` defaults to `-1`, meaning omitted/provider default.
Generation callers may request zero through 2,000,000 millionths; embedding
requests cannot set it. OpenAI-compatible, OpenAI, Anthropic and Gemini
generation adapters map an explicit value to their protocol's `temperature`
field. Phase-5 hosted qualification uses zero for fixed repeatability while
retaining the model and all other decoding controls in its evidence.

## Adapters

| Class | Protocol shape | Current operations |
| --- | --- | --- |
| `.openaicompatibleprovider` | OpenAI Chat Completions and embeddings at a configurable endpoint | Text generation, bounded structured generation, single/batch text embeddings |
| `.industrialprovider("openai", ...)` | OpenAI Responses and embeddings | Text/media generation, structured generation, single/batch embeddings |
| `.industrialprovider("anthropic", ...)` | Anthropic Messages | Text/image/document generation and structured generation; no embeddings |
| `.industrialprovider("gemini", ...)` | Gemini generateContent and embedContent/batchEmbedContents | Text/media generation, structured generation, single/batch embeddings |
| `.codexprovider` | Codex App Server JSONL over a caller-owned child process | Text generation and schema-constrained structured generation; no embeddings |

Call `capabilities()` instead of assuming an operation or modality exists.
Streaming, cancellation, and cross-request connection reuse currently report
unsupported at the provider contract. The current product-safe transport opens
one bounded synchronous HTTP/TLS connection per attempt and requests
`Connection: close`; adapter instances do not retain a connection across
attempts or provider method calls.

## Structured Output

`generate_structured` validates that the response is JSON and enforces the
schema root `type` plus direct `required` property names and their declared
types. It is not a complete JSON Schema implementation. Callers needing a
stronger domain schema must perform deterministic application validation after
the provider result.

## Model Catalogue And Cost

[`provider_catalog.crexx`](provider_catalog.crexx) is a dated capability and
cost snapshot, not a discovery service or permanent truth. Check
`observed_date()` and treat unknown prices as unavailable (`-1`). Application
configuration may select registered model identifiers but should not infer a
capability that the adapter reports as unsupported.

## Failures And Usage

Common normalized error codes are:

| Code | Category |
| ---: | --- |
| `-101` | invalid request |
| `-120` | unsupported capability |
| `-121` | privacy denied before transport |
| `-122` | provider/transport configuration |
| `-123` | structured-response validation |

Transport failures preserve a safe lower-level message and HTTP status while
normalizing timeout and connection failures to the stable provider codes `-5`
and `-3`. Results also record retryability and attempt number. Usage records
expose input and output tokens, input count, estimated cost microunits,
attempts, and retry delay.

## Credentials And Hosted Calls

Credentials are constructor inputs to hosted adapters; they are not fields in
normalized requests, results, catalog records, fixtures, or evidence. Callers
must obtain them from secret references and must not print or persist adapter
instances.

The `p1_llm_04_hosted.crexx` program is retained qualification evidence, not a
normal test or usage example. Do not run it without a separate authorization
for the exact providers, models, budget, and evidence handling.

## Tests

Run deterministic contract and loopback qualification with:

```bash
ctest --preset debug -R '^p1_llm_0[1-5]$' --output-on-failure
ctest --preset debug -R '^p3r_04_codex_protocol$' --output-on-failure
```

The regular CTest selection makes no hosted calls. The Codex protocol fixture
covers managed-account status, one schema-constrained turn, usage and cleanup
on both VMs. The tests compile, assemble, and link final images before both VM
runs. The focused installed-only macOS provider replay passes. CRI-15 remains an exact downstream Linux
confirmation; CRI-16 remains a provider-lifecycle and selected downstream
Linux/package qualification decision.

## Current Limits

- Installed `rxfnsg`, `rxsocket`, and `_rxhttpcore` provide typed policy,
  bounded socket/TLS I/O, and HTTP parsing/building primitives.
- Provider adapters currently open one synchronous connection per attempt, so
  connection reuse, provider streaming, and provider cancellation remain
  unimplemented.
- The synchronous path avoids attached-task provider discovery in a native
  application (CRI-17); OS-process workers are unaffected.
- Current upstream Linux sanitizer and cross-platform HTTP/TLS evidence is
  green. The exact downstream CRI-15 reproducer and provider package remain to
  be replayed on supported Linux.
- The capability catalogue must be reviewed and versioned as providers change.
- Local OpenAI-compatible embedding generation is now exercised against
  `llama.cpp` with `nomic-embed-text-v1.5`; this does not make the model or
  server part of the candidate package.
- Codex App Server is experimental. Each application worker owns one contained
  process, and subscription allowance is an application budget rather than a
  monetary cost estimate.
- Independent release packaging, installed-consumer qualification, and
  donation approval remain outstanding beyond the P2-09 review recipe.
