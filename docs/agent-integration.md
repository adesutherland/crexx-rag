# Agent and LLM integration

There are two independent integrations. Keeping them separate prevents a
provider credential or an agent permission from silently becoming the other.

| Integration | Purpose | Boundary |
| --- | --- | --- |
| `crexxrag` provider | Generate extraction proposals, embeddings, or optional answers | Chosen by `role.*` in `crexxrag.conf`; provider output remains untrusted |
| External agent | Query, plan, diagnose, or explicitly apply work through MCP | Chosen by the MCP server's `--access` capabilities and an operating skill |

Codex can occupy both positions: Codex App Server can be the configured
extractor, while a separate Codex task can operate the `crexxrag` MCP tools.
They are separate processes, sessions, permissions, and budgets.

## Codex as a `crexxrag` provider

The packaged `crexxrag-codex-local.conf` demonstrates the recommended
subscription-first pairing:

```text
role.extractor = codex-extract
role.embedding = local-embed
role.answerer = codex-extract
```

The Codex provider communicates with `codex app-server` over local stdio JSONL.
The App Server owns ChatGPT authentication and token refresh. Every worker owns
its own contained App Server child process and uses an empty temporary working
directory, non-interactive settings, and the exact extraction output schema.
Thread and turn identities are persisted with the provider run before a result
can affect the graph.

Run the human login and preflight from the library workspace:

```sh
crexxrag provider login codex
crexxrag provider status
crexxrag provider test --yes
```

Do not extract a bearer token or place one in `crexxrag.conf`. Codex is a hosted
privacy route even though the App Server is a local process. Its charging basis
is `subscription-allowance`; reviewed limits cover turns, tokens, minimum
remaining allowance, timeout, and attempts. It is not recorded as a zero-cost
API call.

Codex App Server does not provide embedding generation. Use Gemini, an
explicit OpenAI API route, or a local OpenAI-compatible llama.cpp `/embeddings`
endpoint for the embedding role. See [Standalone setup](standalone-setup.md)
for the local Nomic example.

## `crexxrag` as an MCP server

An agent should normally begin with a read-only stdio server:

```sh
crexxrag --access read serve mcp
```

The command uses the same `./crexxrag.conf` and `./library` defaults as the
human CLI. For a launcher, use absolute paths and set the working directory so
relative source roots in the config retain their intended meaning.

For current Codex clients, MCP servers can be configured in the desktop app's
MCP settings, by `codex mcp add`, or in `~/.codex/config.toml`. A project can
instead use `.codex/config.toml` when the project is trusted. The following is
a read-only project configuration:

```toml
[mcp_servers.crexxrag_qa]
command = "/opt/crexxrag/bin/crexxrag"
args = [
  "--library", "/Users/me/evidence-workspace/library",
  "--config-file", "/Users/me/evidence-workspace/crexxrag.conf",
  "--access", "read",
  "serve", "mcp"
]
cwd = "/Users/me/evidence-workspace"
required = true
startup_timeout_sec = 20
tool_timeout_sec = 120
default_tools_approval_mode = "writes"
```

Restart the Codex client after changing MCP configuration, then use `/mcp` or
`codex mcp list` to confirm that `crexxrag_qa` initialized and advertised its
tools. This follows the current official
[Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli).

Read access does not imply zero network use. Query `mode: auto` or `hybrid` may
call the configured embedding provider, and `rag_query_answer` may call the
answerer. Use `rag_query_evidence` with `mode: lexical` when the task must make
no outbound provider call.

Read access also advertises `rag_config_check`, `rag_config_explain`, and
`rag_config_diff`; all three make zero provider calls and never resolve a
credential value. Plan access adds `rag_config_plan`, admin access adds
`rag_config_apply`, and control access adds `rag_job_replay`. Configuration
apply accepts only the exact canonical JSON and digest returned by planning.
Replay creates new current-config work and preserves its terminal source job
and item lineage. These are ordinary MCP/CLI operations over the format-2 text
configuration; an agent does not need permission to edit cREXX or use
RexxScript.

## Configure the Codex skills

The installation provides four skill sources:

| Skill | Use | Expected MCP access |
| --- | --- | --- |
| `crexxrag-qa` | Cited evidence questions, traces, paths, and timelines | `read` |
| `crexxrag-ingest` | Zero-write ingestion plan, followed by separately authorized apply | `read,plan`; `ingest` for apply |
| `crexxrag-maintain` | Ranked maintenance census, exact apply, inspection and explicit review/curation | `read,plan`; `curate` for writes |
| `crexxrag-diagnose` | Library verification, redacted diagnostics, bounded provider smoke tests | `read,diagnose` |

`$crexxrag-maintain` defaults to inspection and zero-write planning. Apply
requires a separately enabled `curate` capability, the exact reviewed plan and
explicit operator authority. See [Methodology and
algorithms](algorithm.md#catalogue-and-graph-maintenance-methodology).

Codex discovers repository skills under `.agents/skills` between the current
directory and repository root. It discovers personal skills under
`$HOME/.agents/skills`. The installed `share/crexxrag/skills` directory is a
distribution source, not an automatic discovery location.

For one project, link only the required skills into the project:

```sh
mkdir -p .agents/skills
ln -s /opt/crexxrag/share/crexxrag/skills/crexxrag-qa \
  .agents/skills/crexxrag-qa
ln -s /opt/crexxrag/share/crexxrag/skills/crexxrag-diagnose \
  .agents/skills/crexxrag-diagnose
ln -s /opt/crexxrag/share/crexxrag/skills/crexxrag-maintain \
  .agents/skills/crexxrag-maintain
```

Add ingestion or maintenance only where the agent is expected to perform that
workflow. To make a skill available to all local projects, place the same link
under `$HOME/.agents/skills` instead. Restart Codex after adding or changing a
skill.

Each skill directory contains the required `SKILL.md`. Its `description`
supports implicit selection, and a user can explicitly select a skill as
`$crexxrag-qa`, `$crexxrag-ingest`, `$crexxrag-maintain`, or
`$crexxrag-diagnose`. Current skill discovery and invocation are documented in
the official [Codex skills guide](https://learn.chatgpt.com/docs/build-skills).
The adjacent `manifest.json` is `crexxrag` audit metadata describing expected
tools and adversarial tests; it is not a replacement for `SKILL.md`.

Verify the integration with a read-only request first:

```text
Use $crexxrag-qa to ask the crexxrag library which component BillingService
depends on. Use lexical evidence and include the returned citation.
```

The expected tool sequence is library status, `rag_query_evidence`, and only
the additional trace/path/timeline view required by the question.

## Separate capabilities for mutation

MCP advertises and accepts tools only for capabilities granted when the server
starts. Knowledge of an apply tool name never grants the capability.

A planning server can use:

```toml
[mcp_servers.crexxrag_plan]
command = "/opt/crexxrag/bin/crexxrag"
args = [
  "--library", "/Users/me/evidence-workspace/library",
  "--config-file", "/Users/me/evidence-workspace/crexxrag.conf",
  "--access", "read,plan",
  "serve", "mcp"
]
cwd = "/Users/me/evidence-workspace"
default_tools_approval_mode = "writes"
```

It can create a canonical zero-write plan but cannot apply it. If an agent is
explicitly authorized to apply ingestion, configure a separate server with
`--access read,ingest`. For maintenance and review decisions, use a separately
enabled `--access read,curate` server. Configuration transitions require a
separate `--access read,plan,admin` server, and immutable dead-letter replay
requires `--access read,control`. Leave mutation servers disabled or absent
unless the workflow genuinely needs them.

Apply always requires the exact `canonical_plan` bytes and digest returned by
planning. The agent must not reconstruct, reformat, or edit the plan. Worker
supervision is deliberately outside the ingest skill: the human
`crexxrag ingest` command owns that complete experience, while canonical MCP operations
preserve explicit authority boundaries.

## Other LLM and agent hosts

The integration is not Codex-specific at the product boundary. Any local agent
host that supports stdio MCP can launch the same command, discover the same
JSON schemas, and use the same capability split. Configure its working
directory, executable, arguments, timeouts, and approval policy using that
host's supported MCP mechanism.

If the host supports skill directories, adapt the four `SKILL.md` packages to
its documented discovery location without changing their authority rules. If
it does not support skills, keep the MCP server read-only by default and use the
relevant `SKILL.md` as reviewed operating instructions. Do not copy examples
that mention apply into a system prompt and treat their presence as approval.

Machine callers without MCP can use the same CLI vocabulary with
`--format json` or `--format ndjson`. They should still preserve the plan/apply split,
check `exit_code`, pass exact digests, retain stable citations, and keep provider
privacy and budgets visible.

## Evidence handoff to a high-capability agent

The preferred handoff is `rag_query_evidence`, not a provider-generated prose
answer. It includes ranked passages, accepted claims and support, ambiguities,
graph leads, gaps, a trace identity, and answer guidance. An agent can then:

1. state supported facts with the returned stable citations;
2. label graph leads and gaps as unresolved rather than facts;
3. use trace, path, or timeline tools for focused follow-up;
4. perform deeper analysis outside the library; and
5. return any proposed new claim through the external-proposal and mandatory
   human-review path.

The detailed data, ranking and maintenance methodology is in
[Methodology and algorithms](algorithm.md).
