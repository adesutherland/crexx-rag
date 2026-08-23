# Provider Contract System Design

## Boundary

This directory is a RAG-neutral provider incubation. It owns normalized model
requests/results, capability discovery, provider protocol mapping, privacy
enforcement at the transport boundary, bounded retry, and usage/latency
projection. It does not own prompts, domain schemas, model-role selection,
budgets, job scheduling, evidence policy, or application persistence.

The intended donation boundary is a generic cREXX `rxllm`-class library. The
current module and class names remain incubation API and are not a compatibility
promise.

## Modules

| Module | Level | Responsibility |
| --- | --- | --- |
| [`provider_contract.crexx`](provider_contract.crexx) | G | Normalized records, `.provider` interface, request/operation/route validation, bounded structured validation |
| [`provider_facade.crexx`](provider_facade.crexx) | G | Stable normalized public object contract over an injected provider |
| [`provider_catalog.crexx`](provider_catalog.crexx) | G | Dated model capabilities, defaults, and optional price estimates |
| [`provider_http.crexx`](provider_http.crexx) | G | Shared hosted HTTP request, authentication headers, policy gate, retry classification, and timing |
| [`openai_compatible_provider.crexx`](openai_compatible_provider.crexx) | G | Configurable Chat Completions/embedding adapter, primarily for local endpoints |
| [`industrial_provider.crexx`](industrial_provider.crexx) | G | OpenAI Responses, Anthropic Messages, and Gemini generation/embedding payloads and response projections |
| `p1_llm_*.crexx` | G | Independent contract, loopback, hosted, privacy, and failure qualification programs |

## Dependencies

- installed `rxjson` for parse-once response traversal and JSON encoding;
- installed Level-G `rxfnsg` for typed, bounded, pooled HTTP/TLS;
- `rxfnsb` for binary arrays and runtime functions; and
- no RAG application module.

These Level-G modules deliberately consume installed Level-B foundation
libraries. The dependency does not justify a Level-B advanced-library layer,
and `provider_facade` is retained for its stable normalized object contract,
not as a language-level wrapper.

Embedding payloads use the generic `f32le-v1` representation. The provider
contract owns codec/count/payload transport records but not embedding semantics,
index identity, or vector storage policy.

## Request Flow

1. The caller selects a registered adapter and asks for its capabilities.
2. `validateprovideroperation` checks the normalized request and method match.
3. Modality and adapter-specific limits are checked without network access.
4. `validateproviderroute` rejects non-public data on hosted routes before
   constructing an HTTP client.
5. The adapter renders one provider-specific payload.
6. `providerhttptransport` creates one bounded pool for the operation and sends
   typed HTTP requests with bounded attempts and backoff.
7. The adapter parses the response once and returns one `.providerresult`.
8. Structured output and embedding shape are validated before success returns.

There is no silent provider fallback. A failure remains attached to the
provider/model/request identity selected by the caller.

## Privacy And Secrets

The current route rule is intentionally conservative: local adapters may handle
all three privacy classes, while hosted adapters accept only `public`. A denied
route returns `privacy_denied` before any socket connection. Phase-1B observer
tests prove zero outbound connections for denied requests.

Credentials live in adapter/transport instance memory and are used only to
construct provider authentication headers. They do not belong in normalized
records, logs, test fixtures, retained raw output, or serialized configuration.

## Retry And Error Semantics

The request bounds attempts from one through ten. Connection failures, timeout
statuses, HTTP 408/429, and 5xx responses are retryable; backoff doubles from one
millisecond and is capped at one second. There is no jitter in the deterministic
incubation implementation.

Errors distinguish invalid request, unsupported operation, privacy denial,
configuration, structured validation, connection, timeout, and HTTP response.
Usage records preserve attempt count and accumulated retry delay even on
failure.

## Capability Truth

Adapter capability records are authoritative for implemented behavior. The
catalog adds model-specific, date-stamped information but cannot upgrade an
adapter capability. Unknown model facts and prices remain unknown.

Streaming, cancellation, and cross-request connection reuse remain zero at the
provider contract. Installed `rxfnsg` supplies the underlying primitives, and
retry attempts within one operation share a client pool, but adapter instances
do not yet retain that pool across separate method calls. The structured
validator implements a small deterministic subset, not full JSON Schema.

## Evidence

Phase-1B qualification covers normalized fake-provider behavior, configurable
local OpenAI-compatible loopback, ordered batch embeddings, malformed and
provider failures, bounded retry, structured validation, local/OpenAI/Anthropic/
Gemini protocol shapes, media modalities, five explicitly authorized low-cost
hosted calls, zero-outbound privacy denial, and credential-value scans. Evidence
is retained under
[`docs/evidence/2026-08-03-phase1b/`](../../../docs/evidence/2026-08-03-phase1b/).

The hosted program is not registered as an ordinary CTest and must remain
secret- and budget-gated.

## Known System Limits

- CRI-15: the historical installed Linux `rxvme` socket path lost the intended
  receive-timeout status. Current upstream Linux sanitizer and cREXX-RAG HTTP
  evidence is green, but the retained downstream reproducer must pass against
  the current installed package on both VMs before closure.
- CRI-16: generic `rxfnsg` pooling, keep-alive, bounded response buffering,
  compression, streaming and cancellation primitives now have upstream Linux
  sanitizer/cross-platform evidence. The downstream adapter still needs an
  approved provider-owned pool lifecycle and selected Linux/package replay;
  streaming and cancellation remain separate adapter-scope decisions.
- Adapter instances retain credentials in process memory for their lifetime.
- The adapters expose no concurrent request scheduler, persistent
  cross-operation pool, circuit breaker, jittered retry, or external capability
  discovery.
- Provider payloads and catalog data will evolve and need compatibility and
  review dates.

## Donation Readiness

Before a donation proposal, this incubation still needs:

- a stable package/module namespace and compatibility policy;
- an explicit separation or dependency contract with the hardened HTTP/TLS
  facility;
- bounded response and concurrent TLS performance evidence;
- a decision on streaming and cancellation requirements;
- a versioned, replaceable catalogue format rather than only compiled entries;
- independent package builds, installed-consumer tests, examples, and release
  metadata; and
- the retained non-RAG CRI-15 reproducer plus focused provider-lifecycle and
  capability proofs alongside the package proposal.
