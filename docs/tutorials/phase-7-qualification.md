# Phase 7 tutorial: qualify the application without hiding behind scripts

Phase 7 asks whether the whole application is ready, not whether another test
harness can call a model. Start with the installed `crexxrag` surface that a
person will actually use. The current Gate-7 decision remains
**reject/defer cutover**, so these checks do not rename or remove native-v1.

Use a working folder prepared by the [Phase-3 ingestion
tutorial](phase-3-ingestion.md) or the [Phase-5 query
tutorial](phase-5-retrieval.md). It should contain `crexx-rag.conf`,
`source-docs/`, and (after ingestion) `library/`. `crexxrag` discovers those
local defaults automatically.

## 1. Check the application and declared routes

These commands make no model request:

```console
$ crexxrag doctor
$ crexxrag provider status
```

`doctor` checks the installed capabilities, configuration and library when one
exists. `provider status` reports redacted route, model, charging basis and
available Codex account information; it never prints credential values.

## 2. Make one reviewed smoke call to every active provider

```console
$ crexxrag provider test
Provider smoke plan

  Data:              Public synthetic text only
  Provider calls:    2 (configured ceiling 2)
  ...
Continue? [y/N]
```

Read the plan, then type `y`. For an already reviewed, repeatable run:

```console
$ crexxrag provider test --yes
```

To test only one route:

```console
$ crexxrag provider test gemini-generate --yes
```

Generation providers must return the exact structured answer shape and only
the supplied synthetic citation. Embedding providers must return one valid
768-dimensional vector. The operation is governed by the configuration's
call, token, monetary-cost, Codex-turn, allowance, timeout and retry limits.
Hosted routes receive only the fixed public synthetic passage shown in the
plan; no library or source content is read. A successful result proves the
configured route can complete that bounded operation now. It does not prove
throughput, streaming, cancellation, connection lifetime reuse or production
cutover readiness.

Automation uses the same contract without a prompt:

```bash
crexxrag --format json --access diagnose \
  provider test --provider gemini-generate
```

An MCP client with explicitly granted `diagnose` access may call
`rag_provider_test` for one provider. The tool is read-only with respect to the
library, open-world because it contacts a provider, and non-idempotent because
it consumes compute, API budget or subscription allowance.

## 3. Exercise the real ingestion and query surfaces

The provider smoke is intentionally small. The production-shaped application
walkthrough remains:

```console
$ crexxrag init
$ crexxrag ingest
$ crexxrag query 'What does BillingService depend on?'
$ crexxrag improve
$ crexxrag query 'What does BillingService depend on?'
$ crexxrag --access diagnose library verify
```

Inspect the human plans before accepting them. An unchanged ingestion replay
must queue no items and make no provider call. A query result must retain typed
evidence and source citations even when an optional provider writes the prose.

## 4. Run the comprehensive regression wall

Maintainers then run the permanent application and historical qualification
tests. This is the only section that uses build tooling:

```bash
cmake --preset debug
cmake --build --preset debug --target phase7_provider_smoke
ctest --preset debug --output-on-failure
git diff --check
```

`p7r_01_provider_smoke` runs native human, JSON and MCP calls against a
deterministic Gemini loopback. It validates structured citations and embedding
dimensions, enforces a zero-call budget denial, and rejects secret disclosure.
The full wall replays every earlier phase as well as the historical P7-01
through P7-08 qualification record.

A real hosted smoke is always explicit and bounded. With the maintained Google
configuration and `env:GEMINI_API_KEY`, run `crexxrag provider test --yes` and
retain only redacted status/usage evidence—never the key, request headers, or
raw response. Codex uses managed ChatGPT login and subscription allowance;
llama.cpp uses the local OpenAI-compatible embeddings route.

## 5. Read the decision accurately

The [2026-08-24 cutover
decision](../evidence/2026-08-24-phase7/cutover-decision.md) is a dated record.
Later Phase-3 work closed its cREXX hosted-completion, public worker/provider
dispatch and embedding-item findings on macOS. This Phase-7 application
extension also makes provider reachability directly testable through
`crexxrag`.

The decision itself is unchanged. A production-shaped same-session
native/cREXX comparison, exact downstream installed-CREXX Linux replay, and a
new explicit cutover decision are still absent. Native-v1 therefore remains
the default oracle.
