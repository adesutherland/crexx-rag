# crexxrag agent skills

The five packages provide narrow MCP operating instructions:

- `crexxrag-ingest` plans and, with explicit ingest authority, applies source
  ingestion;
- `crexxrag-maintain` inventories and ranks maintenance, applies only an exact
  authorized worklist, supports explicit human review, and documents
  separately authorized retry/waiver with `control` access;
- `crexxrag-qa` performs cited read-only query work;
- `crexxrag-resolve` investigates difficult tasks, pages and refreshes their
  evidence, and prepares grounded lifecycle resolutions, inline new claims or
  advanced-reasoning flags for explicit review;
- `crexxrag-diagnose` inspects libraries, jobs, and explicitly authorized
  provider smoke tests.

Ordinary Q&A uses the current assistant to compose the cited answer from
retrieved evidence. The QA skill defines the default route and the explicit
request needed to use the separate cREXX-RAG answerer, including its performance
cost. Use the [corpus workspace template](../docs/templates/corpus-AGENTS.md)
for standing corpus-only, graph-exploration and quotation instructions.

The maintenance skill owns the shared long-job workflow: light monitoring,
independent worker model selection, embedding progress and engineering handoff
for missing public controls. Ingest and diagnosis link to it. Workspace READMEs
record chosen models and installation status; run records own temporary budgets
and deadlines. Existing user authorization persists across skill use.

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
