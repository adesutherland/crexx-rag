# Test strategy

The maintained suite tests the single shipping architecture rather than an old
implementation comparison.

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

## Default matrix

| Test | Main assurance |
| --- | --- |
| `sqlite_provider_thread_sessions` | RXPA session isolation, four concurrent SQLite sessions, FULLMUTEX behavior |
| `linked_application` | linked-image provider mapping and both CREXX VMs |
| `configuration_contract` | bounded text parsing, privacy, secret references, optimized/non-optimized and both VMs |
| `process_workers` | two-worker launch, observation, drain, stale PID detection, explicit pruning |
| `gemini_ingestion` | Gemini request/response mapping, durable work, claims, embeddings, vector publication, replay and failure paths |
| `provider_durability` | reservation recovery, Codex turns, fencing, completed-turn reuse |
| `codex_protocol` | App Server initialize/account/turn/schema/usage/cleanup over JSONL |
| `gemini_improvement` | hosted-style improvement plus provider/profile discovery and external proposal review/promotion |
| `gemini_query` | query embeddings, hybrid retrieval, cited answers, lexical zero-call and invalid citation rejection |
| `query_policy` | local/hosted privacy and every call/token/cost/allowance ceiling |
| `native_surfaces` | human defaults and MCP structured-content/strict-argument behavior |
| `address_surface` | linked `ADDRESS RAG` session/config/access behavior on both VMs |
| `gemini_provider_smoke` | generation and embedding smoke, human/JSON/MCP, cancellation, aggregate budget, malformed output, secret redaction |

The Gemini tests always exercise the Gemini adapter and Google request/response
shapes through a deterministic local fixture. They do not silently substitute a
different provider. This makes the default suite repeatable and zero-cost.

## Live providers

Live calls are separate because they consume an external quota and require
credentials. Before a release candidate, run the native `provider test` against
the intended configuration, including Gemini even when Codex or local llama.cpp
routes are also under test:

```sh
export GEMINI_API_KEY='<key>'
cd docs/tutorial-work
./crexxrag provider test --yes
```

The reviewed configuration must bound calls, input/output tokens, timeout,
attempts, and either cost or subscription allowance. Test output must contain no
credential value.

## Change expectations

- Schema changes: fresh native build and all tests.
- Provider changes: Gemini ingestion/query/smoke, Codex protocol/durability,
  policy tests, malformed output, and secret audit.
- Worker changes: process, ingestion, improvement, replay, stale/prune tests.
- Public command changes: native surfaces plus the public discovery/proposal
  path inside `gemini_improvement`.
- Documentation/config changes: tutorial setup and `crexxrag doctor` from the
  resulting folder.
