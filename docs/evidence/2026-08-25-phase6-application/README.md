# Phase 6 Application Extension Closure

Date: 2026-08-25

Platform: macOS 64

Outcome: accepted for the recorded Phase 6 macOS application scope

## Scope

This evidence extends the maintained native Level-G `crexxrag` application
through the already accepted Phase 6 CLI, `ADDRESS RAG`, MCP and skill surface.
It closes the human/agent executable seam, configuration parity, truthful MCP
provider-call annotations, and runtime enforcement of advertised argument
schemas.

It does not change the Gate-7 reject/defer decision or authorize release, push,
cutover, Linux qualification, donation submission, native-v1 removal, or a
compatibility release.

## Implemented Surface

The same enduring executable now starts the agent transport:

```text
crexxrag serve mcp
```

It discovers `./crexx-rag.conf`, defaults to `./library`, selects a sole
profile, and uses read access unless the operator explicitly grants more.
The standalone `ragmcp` module remains available for installed automation.

`ADDRESS RAG LIBRARY OPEN` accepts `--config-file`, builds the same typed
registry, and commits the new session only after configuration, profile,
access, and format validation. A failed open leaves the old session intact.

MCP now rejects unknown, duplicate, and incorrectly typed arguments instead of
merely advertising `additionalProperties: false`. Provider-capable query tools
are annotated read-only, non-destructive, open-world and non-idempotent: they
do not write the evidence library, but can consume embedding/answer compute,
API budget, or subscription allowance. Explicit lexical mode remains the
zero-outbound route.

The Phase 6 tutorial is human-first. Its setup reuses the Phase 3 provider
bundle and the normal walkthrough uses only `crexxrag`; it includes small MCP
JSONL and ADDRESS examples without requiring users to construct VM load paths
or module lists.

## Permanent QA

The installed toolchain was used first:

```text
crexx-1.0.0-beta.3+local.ge3d6b7b90158.dirty
```

The final application artifacts are:

```text
linked Level-G application SHA-256:
ec793c2d3120985fbaef76fd4e7a9cafcc8dc0f865a465eb78cb21f1b7d344af

native application package SHA-256:
96b9529e69ba5dd5b9702b5e445850a9bff1ac48f35e595c5a3b458b5d94d9c2
```

| Test | Coverage |
| --- | --- |
| `p6r_01_native_surfaces` | Native init and two-worker Gemini ingestion; built-in MCP serve with discovered config; hybrid citation-validated answer; lexical zero-call evidence; truthful annotations; strict unknown arguments; secret absence; final integrity |
| `phase6_surfaces` | Noopt/opt on `rxvme`/`rxbvm`; exact plan/apply; zero-write planning; CLI/ADDRESS/MCP equality; config-file binding and failed-open atomicity; strict unknown/duplicate/type rejection; annotation checks; tutorial shell/JSONL/source compilation; capabilities, skills, deprecation and backup/restore |
| full downstream CTest wall | All 86 tests, including every prior phase, native-v1 oracle, provider, storage, vector, application, CLI, ADDRESS, MCP, qualification and report check |

The focused native proof passed in 1.18 seconds. The expanded four-cell Phase 6
matrix passed in 224.42 seconds.

The final sequential downstream wall passed:

```text
ctest --preset debug --output-on-failure -j1
100% tests passed, 0 tests failed out of 86
Total Test time (real) = 1003.70 sec
```

## Bounded Real Google Smoke

The already-qualified public synthetic Google library was queried through the
new `crexxrag serve mcp` entry point. Gemini Embedding 2 generated the compatible
query vector and Gemini 3.5 Flash Lite returned the citation-validated answer.
The MCP `structuredContent` reported `query.answer`, hybrid retrieval, two
provider calls, seven embedding input tokens, 729 answer input tokens and 188
answer output tokens. No credential value was printed or retained.

## Boundaries

MCP `readOnlyHint` describes library mutation, not whether a call is free or
offline. Privacy, model-call, token, cost, Codex-turn, retry and allowance gates
remain in the shared product/provider policies. The server cannot replace its
operator-selected config through a tool call.

SQLite remains authoritative; vectors remain immutable rebuildable sidecars;
model output remains untrusted until cREXX schema and citation validation; and
agents do not gain worker supervision or write authority merely by knowing an
operation exists.
