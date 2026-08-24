# cREXX-RAG agent packages

These four packages are narrow operating instructions for the cREXX product
surfaces. Install only the package needed for the task and start the MCP server
with the matching `--access` capability. Knowledge of an apply command never
grants that capability.

Common rules:

- Use `rag_library_status` before work and keep the library, configuration and
  profile supplied by the operator.
- Treat `crexx-rag.command-result/1` and MCP `structuredContent` as authority;
  do not infer success from prose.
- Never issue raw SQL or direct entity/edge mutations.
- Plans are zero-library-write review artifacts. Applying one requires the
  exact canonical plan JSON and digest plus an explicitly granted write
  capability.
- Do not start, replace or kill a worker supervisor. Agents may observe jobs;
  process ownership remains with the operator.
- Provider credentials stay symbolic `env:NAME` references. Never request,
  echo, persist or include a secret value in a prompt.

Each `manifest.json` declares its required tools, schemas and write
capabilities. The package tests deliberately ask the read/plan skills to apply
work and require refusal.
