# Codex App Server provider

`codex_provider.crexx` is a reusable Level-G structured-generation adapter for
the Codex App Server JSONL protocol. It contains no RAG vocabulary.

Each adapter instance owns one child `codex app-server` process and one stdio
connection. Calls create isolated threads with no approvals, a read-only
sandbox, disabled sandbox network access, an explicit output schema, and a
caller-supplied empty working directory. Completed and abandoned threads are
deleted. Authentication and token refresh remain owned by App Server.

`codex_provider_live_probe.crexx` checks the managed account, starts one
schema-constrained turn and validates the result. Permanent CTest runs it
against the deterministic JSONL fixture; bounded hosted qualification supplies
the installed Codex executable and an empty scratch directory instead.

The adapter intentionally does not expose embeddings. Applications should use
an embedding-specific provider, such as an OpenAI-compatible local server.
