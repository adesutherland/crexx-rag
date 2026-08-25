# Provider system notes

`provider_contract` defines typed requests, results, errors, usage, embeddings,
and route policy. `provider_catalog` supplies model capabilities and monetary
cost estimates. `provider_http` owns bounded HTTP/TLS transport through the
installed CREXX networking facilities. `industrial_provider` maps Gemini,
OpenAI, and local OpenAI-compatible protocols. `codex_provider` implements the
managed App Server JSONL lifecycle.

The application owns role binding, privacy, budgets, durable reservations,
provider-run identity, recovery, output validation, and promotion. Adapters do
not write product tables.
