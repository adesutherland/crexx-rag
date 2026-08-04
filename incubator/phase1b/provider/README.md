# Provider Contract Usage

Status: implemented generic cREXX incubation for a possible future `rxllm`
package. The normalized contract and protocol mappings are accepted on
Phase-1B evidence, but the package is not installed, donation-ready, or approved
for industrial high-throughput HTTP/TLS.

See [SYSTEM.md](SYSTEM.md) for module ownership and known transport constraints.

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
request = .providerrequest("generate", "answer", "local-chat", messages, inputs, "", 30000, 2, "local", "answer-001", "request-001")

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
| `.providerrequest` | Operation, application role, model, content, schema, timeout, attempts, privacy, identities, token/dimension limits, and streaming request |
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

## Adapters

| Class | Protocol shape | Current operations |
| --- | --- | --- |
| `.openaicompatibleprovider` | OpenAI Chat Completions and embeddings at a configurable endpoint | Text generation, bounded structured generation, single/batch text embeddings |
| `.industrialprovider("openai", ...)` | OpenAI Responses and embeddings | Text/media generation, structured generation, single/batch embeddings |
| `.industrialprovider("anthropic", ...)` | Anthropic Messages | Text/image/document generation and structured generation; no embeddings |
| `.industrialprovider("gemini", ...)` | Gemini generateContent and embedContent/batchEmbedContents | Text/media generation, structured generation, single/batch embeddings |

Call `capabilities()` instead of assuming an operation or modality exists.
Streaming, cancellation, and connection reuse currently report unsupported.

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

Transport failures preserve their lower-level status and add an HTTP status,
retryable flag, attempt number, and safe message. Usage records expose input and
output tokens, input count, estimated cost microunits, attempts, and retry delay.

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
```

The regular CTest selection makes no hosted calls. CRI-15 means the Linux
receive-timeout cell remains the one known baseline failure.

## Current Limits

- Installed `rxhttp` is synchronous, opens one connection per request, and has
  no configured response-size ceiling, streaming, or cancellation.
- Linux timeout behavior is not qualified while CRI-15 remains open.
- The capability catalogue must be reviewed and versioned as providers change.
- A real local `llama-server` deployment was unavailable during Phase 1B.
- Independent package metadata, installed-consumer qualification, and donation
  approval remain outstanding.
