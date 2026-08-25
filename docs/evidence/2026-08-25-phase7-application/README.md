# Phase 7 application qualification extension

Date: 2026-08-25

Status: implemented and locally qualified on macOS. This extension does not
change the 2026-08-24 reject/defer cutover decision.

## Closed application gap

The public vocabulary already contained `provider.test`, but the foundation
implementation was deliberately configuration-only: local providers were not
contacted and hosted providers were rejected. The current product dispatcher
now owns a real, bounded smoke operation over the same configured provider
factory used by ingestion, improvement and query.

For each selected role-bound provider it performs the applicable operation:

- structured generation with an exact answer/citations schema and one fixed
  public synthetic citation; and/or
- embedding generation with one fixed public synthetic question and exact
  768-dimensional result validation.

The request is denied before client construction when privacy or configured
model-call, token, monetary-cost, Codex-turn, minimum-allowance, timeout or
retry policy is insufficient. The result reports route, charging basis, usage,
attempts and allowance when available without exposing a secret value.

## Enduring surfaces

- Human: `crexxrag provider test [PROVIDER] [--yes]` shows a plan and normally
  asks for confirmation.
- Machine: `crexxrag --format json --access diagnose provider test --provider
  ID` preserves the canonical command contract.
- Agent: `rag_provider_test` is advertised only with `diagnose` access. Its MCP
  annotations are library-read-only, non-destructive, non-idempotent and
  open-world.

The diagnosis skill requires explicit operator authorization and a declared
budget before making the outbound call.

## Permanent focused evidence

CTest `p7r_01_provider_smoke` uses the native cREXX application and deterministic
Gemini loopback to prove:

- the human command tests generation plus embeddings in two calls;
- canonical JSON tests one selected embedding provider;
- MCP advertises truthful annotations, rejects a missing required provider,
  and validates one generation call;
- exact answer schema/citation and vector dimension validation;
- zero-call budget denial before any outbound request;
- aggregate guided-command denial when both individual calls fit but their
  combined input usage exceeds the reviewed ceiling; and
- zero synthetic credential disclosure.

The Phase-6 four-cell MCP scenario also checks that the new diagnose tool is
advertised with truthful annotations. Earlier phase tests remain in the full
regression wall.

## Bounded real Google result

The native human command used the maintained hosted Gemini configuration with
two calls, one attempt per route, public synthetic input and a $0.05 ceiling:

| Route | Validated result | Input | Output | Estimated cost |
| --- | --- | ---: | ---: | ---: |
| Gemini 3.5 Flash Lite | exact structured answer plus supplied citation | 131 tokens | 53 tokens | 171 microunits |
| Gemini Embedding 2 | one 768-dimensional vector | 7 tokens | 0 tokens | 1 microunit |

The aggregate human summary reported two calls, 138 input tokens, 53 output
tokens and $0.000172 estimated API cost. Provider latency was 885,641 us plus
405,631 us. No credential value, request header or raw response was printed or
retained.

## Qualification result

The deterministic focused test passed in 1.45 seconds. The neighbouring
Phase-6 four-cell surface matrix passed in 233.90 seconds. The final serial
Debug wall passed every test:

```text
ctest --preset debug --output-on-failure -j1
100% tests passed, 0 tests failed out of 87
Total Test time (real) = 963.41 sec
```

The final installed-toolchain application artifacts are:

```text
linked Level-G application SHA-256:
4980269e61e059cfa134fcb3e79fa622c20645d12e3bb1cc1855a37327036c2b

native application package SHA-256:
eddbe674f8b60420b6f012622a932a0819648692e556aeef49781d7468f25349
```

## Limits

A provider smoke proves one configured request/response path at that time. It
does not claim performance, long-lived connection reuse, streaming,
cancellation, Linux portability, release readiness or cutover. It reads and
writes no library content. Hosted routes still send the fixed public synthetic
text off-machine; Codex remains a hosted privacy route despite its local App
Server process.
