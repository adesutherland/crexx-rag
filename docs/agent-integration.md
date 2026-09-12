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
no outbound provider call. For **zero writes as well as zero provider calls**,
use `rag_query_inspect`. Its CLI equivalent is `query inspect QUESTION`.
The older query routes record durable gap observations even in lexical mode.
`rag_library_overview` similarly exposes deterministic reporting without the
optional narrative refresh, so Codex can approve it as a read-only tool.

Read access also advertises `rag_config_check`, `rag_config_explain`, and
`rag_config_diff`; all three make zero provider calls and never resolve a
credential value.
`rag_config_prompt` is also read-only: give it an extractor, resolution,
answerer or advisory `role` to inspect the actual system prompt and schema,
including instructions appended to the configurable objective. Prompt edits
use the selected policy and its reviewed configuration transition; source
evidence validation remains enforced.

Plan access adds `rag_config_plan`, admin access adds
`rag_config_apply`, and control access adds `rag_job_replay`. Configuration
apply accepts only the exact canonical JSON and digest returned by planning.
Replay creates new current-config work and preserves its terminal source job
and item lineage. These are ordinary MCP/CLI operations over the format-2 text
configuration; an agent does not need permission to edit cREXX or use
RexxScript.

## Configure the Codex skills

The installation provides five skill sources:

| Skill | Use | Expected MCP access |
| --- | --- | --- |
| `crexxrag-qa` | Cited evidence questions, traces, paths, and timelines | `read` |
| `crexxrag-ingest` | Zero-write ingestion plan, followed by separately authorized apply | `read,plan`; `ingest` for apply |
| `crexxrag-maintain` | Ranked maintenance census, exact apply, inspection and explicit review/curation | `read,plan`; `curate` for writes |
| `crexxrag-diagnose` | Library verification, redacted diagnostics, bounded provider smoke tests | `read,diagnose` |
| `crexxrag-resolve` | Investigate difficult tasks; plan and review grounded lifecycle resolutions | `read,plan`; `curate` for submission, escalation and acceptance |

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
ln -s /opt/crexxrag/share/crexxrag/skills/crexxrag-resolve \
  .agents/skills/crexxrag-resolve
```

Add ingestion, maintenance or resolution only where the agent is expected to perform that
workflow. To make a skill available to all local projects, place the same link
under `$HOME/.agents/skills` instead. Restart Codex after adding or changing a
skill.

Each skill directory contains the required `SKILL.md`. Its `description`
supports implicit selection, and a user can explicitly select a skill as
`$crexxrag-qa`, `$crexxrag-ingest`, `$crexxrag-maintain`,
`$crexxrag-resolve`, or `$crexxrag-diagnose`. Current skill discovery and invocation are documented in
the official [Codex skills guide](https://learn.chatgpt.com/docs/build-skills).
The adjacent `manifest.json` is `crexxrag` audit metadata describing expected
tools and adversarial tests; it is not a replacement for `SKILL.md`.

Verify the integration with a read-only request first:

```text
Use $crexxrag-qa to ask the crexxrag library which component BillingService
depends on. Use query inspection with no writes or provider calls, and resolve
the returned source citation.
```

The expected tool sequence is library status or overview, `rag_query_inspect`,
and `rag_citation_show`. Use additional trace/path/timeline views only when
required by the question.

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

The default provider-free handoff is `rag_query_inspect`. It includes ranked
lexical passages, accepted claims and support, ambiguities,
graph leads, gaps, a trace identity, and answer guidance. An agent can then:

1. state supported facts with the returned stable citations;
2. label graph leads and gaps as unresolved rather than facts;
3. use trace, path, or timeline tools for focused follow-up;
4. perform deeper analysis outside the library; and
5. return new claims through the external-proposal path, or resolve an existing
   maintenance task through the task proposal and mandatory review path.

## Difficult maintenance tasks

Schema 12 adds `required_capability` to existing maintenance tasks. It is
`standard` or `advanced-reasoning`, independently of priority and task state.
The task records a reason, origin and content-validation failure count. An
ordinary worker may return `action: "escalate"`; two content-validation failures
for the same evidence task also flag it. Provider transport/admission failures
and exhausted call budgets are not intelligence signals. An input envelope
that exceeds the worker limit can be handed off when its complete evidence
packet exists. Ordinary
workers do not dispatch flagged tasks. Source changes produce a fresh task
identity under the existing evidence-fingerprint rules.
The flag does not automatically launch Codex or select a more capable model;
an operator or external agent discovers the queue and chooses the resolver.

Terminal extraction-content failures also create an advanced-reasoning chunk
review task. Its question names the original job and item. Page
`rag_job_events` for that job to read the retained provider response, the one
correction request and the final validation failure; filter those events by
the named item. The `extraction-review-required` event links back to the task.
Read its source packet through the usual evidence tools, treating rejected
answers as untrusted data. A later ordinary maintenance census preserves this
handoff while the same evidence remains unresolved. No stronger provider is
started automatically.

`rag_task_list` discovers all durable tasks without needing a run ID. Filter
by capability, state or workflow and follow its `next_cursor`. Inspect a task
with `rag_maintain_inspect` to obtain the subject, catalogue, response schema
and history; `rag_task_evidence` returns paged original passages and source
citations. `rag_profile_show` supplies permitted vocabulary. Workflow inspection
pages its task and historical-note-link arrays using a numeric cursor;
`rag_task_list(workflow: ID)` provides the task selection independently.
`rag_job_list` supplies actual job IDs and timestamps, and `rag_job_events`
supports cursor/limit continuation. `rag_job_plan` accepts `id`, a string
`cursor` and `limit` (1–8192 Unicode characters). Concatenate its `text` pages
until `next_cursor` is empty, checking the retained `plan_digest`. Job IDs are
not ordered by creation time.

The external resolution sequence is:

1. Call `rag_task_resolve_plan` with task ID and inline `response_json` matching
   the returned task schema. Source quotations must pass the normal durable
   packet validator. The canonical plan freezes the task stamp, evidence,
   configuration, profile, generation, attribution and impact census.
2. With authorized `curate` access, submit exact `plan_json` and `expect_digest`
   to `rag_task_resolve_apply`. This records an immutable external-agent action
   and creates a pending review; it does not change the corpus.
3. Inspect that `agent-action:` ID with `rag_maintain_inspect`. Preview and
   accept the returned review only within the user's authority. Acceptance
   revalidates current evidence, generation, profile and configuration and
   composes the existing lifecycle engine in one transaction. A stale proposal
   must be rejected and replanned. Exact submission replay is a no-op.

Actor and model labels are self-reported external attribution. No worker item,
provider run, usage or zero-cost model call is invented for the external agent.
Split and merge start migration workflows; connection disposition and eventual
parent retirement remain separate tasks. Unresolved decisions do not close a
task, and rejecting or dismissing a proposal leaves its task unresolved.

`rag_task_escalate_plan` and `rag_task_escalate_apply` use the same exact-plan
contract for an operator/agent flag. Active worker ownership blocks handoff.
The corresponding CLI verbs are `maintain tasks`, `maintain evidence`,
`maintain resolve-plan`, `maintain resolve-apply`, `maintain escalate-plan`
and `maintain escalate-apply`.

Exploratory query results do not extend a task's immutable evidence catalogue.
`rag_task_evidence_inventory` pages current or stored passages, catalogue and
context, including an oversized task whose stored passages are empty. Each
passage entry has a stable evidence ID, required span and source/context
citations. Read source text with `rag_citation_show`; large citations return
text pages with `next_cursor` and optional `limit` 1–8192 characters. Follow the
same citation until its cursor is empty. Citation byte offsets and paging's
Unicode character offsets are explicitly distinguished. For inventory, follow `next_cursor`,
passing the first page's generation as `expect_generation`; restart pagination
if it changes. Current inventory is exploration, not accepted task evidence.

`rag_task_refresh_plan` assembles a complete current packet with per-task
ceilings, defaulting to 1 MiB/1000 concepts and allowing up to 8 MiB/1000 concepts.
It returns completeness/counts, immutable bindings and a successor task ID.
Authorized `rag_task_refresh_apply` uses the exact canonical plan and digest,
preserves the old task, marks it superseded and creates the successor with its
original question, workflow and priority. The expanded task requires advanced
reasoning. Configuration, semantic generation and provider usage stay unchanged.
Active worker ownership or a pending review blocks refresh. Repeated apply is
an exact no-op. Read the successor's stored inventory before resolving it.
Later census and resolution validate using its retained envelope. An incomplete
packet is never installed; evidence changes invalidate an unapplied plan.

CLI equivalents are `maintain evidence-index --id TASK --kind passages
--scope current`, `maintain refresh-plan --id TASK --reason REASON
--maximum-bytes 1048576 --maximum-concepts 1000`, and `maintain refresh-apply`
with exact `--plan-json` and `--expect-digest`. Claim/conflict resolution still
requires all affected supports; response limits are 131072 bytes/1000 entries.
Generic refresh excludes provenance-enrichment's separate complete-support
assessment contract. Missing evidence still requires sources. Review preview
checks pending existence, rather than simulating all lifecycle effects.

New claim additions accept inline NDJSON through
`rag_proposal_plan.proposals_ndjson` (at most 65535 bytes), or a server file
through `input`; supply exactly one. Both use the same external claim decoder,
validator, canonical plan and mandatory review. The installed `crexxrag-resolve`
skill supplies the complete versioned claim shape and grounding rules. Inline
task resolution does not create unextracted relationships; prepare separate
claim proposals after discovering any newly accepted successor concepts.
See [the fresh Codex trials](mcp-codex-trials.md) for measured coverage and the
next validation cases.

The detailed data, ranking and maintenance methodology is in
[Methodology and algorithms](algorithm.md).

## Current scale limits

Review, repository and event pages support 100 data rows plus one bounded final
cursor record. Follow `next_cursor` to finish discovery. Job lists expose
`value_complete`; small plans retain their original inline `value`, while a
larger plan has an empty `value`, an explicit character count and
`detail_operation: job.plan`. Use `rag_job_plan` to read its complete text;
reducing the listing size is no longer necessary to discover that job.
The [public-result repair record](public-result-lexical-repair.md) describes the
cross-surface and installed-copy qualification. Subject/workflow discovery
limitations below remain separate.

Tasks can be filtered by state, capability and known workflow ID. There is no
direct concept-label or subject-ID task search, or dedicated workflow listing.
An agent given only a name may struggle to find its migration in a large
backlog. When an operator already has a task or workflow ID, pass it with the
request. Discovery and complete real-corpus lifecycle qualification are tracked
in the [trial record](mcp-codex-trials.md).
