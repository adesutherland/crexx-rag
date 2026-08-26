# crexxrag agent skills

The four packages provide narrow MCP operating instructions:

- `crexxrag-ingest` plans and, with explicit ingest authority, applies source
  ingestion;
- `crexxrag-improve` plans improvement and supports explicit human review;
- `crexxrag-qa` performs cited read-only query work;
- `crexxrag-diagnose` inspects libraries, jobs, and explicitly authorized
  provider smoke tests.

Start the shared MCP surface with `crexxrag --access CAPABILITIES serve mcp`.
Knowledge of a mutation tool never grants its capability. Plans are zero-write
review artifacts and apply requires the exact canonical bytes and digest.

Credentials remain symbolic references. `rag_provider_test` sends fixed public
synthetic text and may consume local compute, API budget, or subscription
allowance; it requires explicit operator authorization.

These directories are the distributable skill sources. Codex discovers
repository skills from `.agents/skills` and personal skills from
`$HOME/.agents/skills`; it does not discover this `skills/` directory merely
because it exists. Link or copy only the skills required for a workspace, then
restart Codex. See [Agent and LLM integration](../docs/agent-integration.md) for
the MCP and skill configuration, including the separate read, plan, ingest,
curate, and diagnose capability surfaces.
