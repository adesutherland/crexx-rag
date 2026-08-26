# User guide

For a first installation that does not depend on a source checkout or project
scripts, follow [Standalone setup](standalone-setup.md). For Codex, MCP, and
skill configuration, follow [Agent and LLM integration](agent-integration.md).

## Local defaults

Run `crexxrag` in a folder containing:

- `crexxrag.conf` — simple text configuration;
- `source-docs/` — or another configured source root;
- `library/` — created automatically by `crexxrag init`.

`CREXXRAG_CONFIG` or global `--config-file PATH` overrides the local config.
Global `--library PATH` overrides `./library`.

Human output and terminal progress are the default. Use `--format json` or
`--format ndjson` for automation. `NO_COLOR=1` selects plain progress; explicit
`--progress off|plain|ansi` takes precedence.

## Human workflow

```sh
crexxrag doctor
crexxrag provider status
crexxrag init
crexxrag ingest
crexxrag query 'What does BillingService depend on?'
```

`ingest` shows source, privacy, provider, budget, worker count, and plan digest
before asking for confirmation. After approval it applies the reviewed plan,
starts the configured number of worker processes, and reports the final job and
vector state. `--yes` is intended for an already reviewed non-interactive run.

Re-running unchanged ingestion is an `identical-no-op`: no work and no provider
calls are made.

## Providers

```sh
crexxrag provider list
crexxrag provider status
crexxrag provider test --yes
crexxrag provider test gemini-embed --yes
crexxrag provider login codex
```

The smoke test uses fixed public synthetic text. It validates structured
generation and embedding shape while enforcing the configuration's combined
budget. It never sends library content.

Gemini credentials are normally configured as `env:GEMINI_API_KEY`. Codex login
is owned by Codex App Server. Never place credential values in a config file.

For local embeddings, start llama.cpp and configure an `openai-compatible`
provider at `http://127.0.0.1:8081/v1`. The terms are:

- embedding generation: converting text into vectors;
- vector-index publication: publishing the resulting `.rxvec` generation.

The tutorial includes a ready-to-copy Codex plus local-embedding configuration:

```sh
work_dir=$(docs/tutorial/setup.sh --no-build --provider codex-local)
```

## Workers

```sh
crexxrag worker list
crexxrag worker status WORKER_ID
crexxrag worker drain WORKER_ID
crexxrag worker prune --stale-seconds 30
```

Controllers and workers register PID, host identity, process-start token,
heartbeat, state, and current item in SQLite. Lists can therefore distinguish
local/remote, live/stale, idle/running, and stopped records. Pruning is explicit;
stale rows are not silently deleted.

Workers are operating-system processes, not attached cREXX threads. Each owns a
VM, provider process/session, and SQLite connection.

## Maintenance and external proposals

```sh
crexxrag maintain
crexxrag maintain status
crexxrag maintain inspect ITEM_OR_NOTE_ID
crexxrag review list
crexxrag review show REVIEW_ID
crexxrag review decide REVIEW_ID --decision accept --apply
```

Normalized external claims use NDJSON and must declare `external: 1`:

```sh
crexxrag --access plan --format json \
  proposal plan --input proposals.ndjson
```

Automation then submits the exact returned `canonical_plan` and `digest` to
`proposal apply`. Apply only creates mandatory pending reviews. Accepting an
external review internalizes the proposal and runs the normal deterministic
claim validator before publication.

## Catalogue and graph maintenance cycle

Maintenance is the workflow for both **finding** useful work and executing an
authorized worklist. It inspects chunks, concept nodes, claim edges, pending
reviews, query gaps, failed work and embedding/vector coverage; ranks what is
worth further analysis; and optionally uses the configured LLM to diagnose and
propose actions.

An optional UTF-8 glossary supplies canonical labels, types, aliases and
excluded terms. The reviewed plan identifies its content digest and the
configured discovery mode: LLM review of all changed chunks, ranked chunks, or
maintenance-selected chunks. Disabling LLM discovery is reported as a degraded
deterministic fallback.

Configure it with `discovery.glossary_file`. The file is tab-separated and
bounded; aliases on a concept row are separated by `|`:

```text
format	crexx-rag.glossary/1
concept	BillingService	application-component	Billing Service|Billing
concept	CustomerDatabase	data-store	Customer DB
exclude	DeprecatedSystem
```

The exact file bytes and interpreted glossary are frozen into every ingestion
and maintenance plan. Editing the file after planning makes apply fail before
any library mutation or provider call; plan again to review the new glossary.

The human command is:

```sh
crexxrag maintain
```

It guides one bounded cycle:

1. inspect library readiness and the current semantic generation;
2. census and rank candidate work across chunks, nodes, edges, reviews, leads
   and derived indexes;
3. show why each selected item matters and the score/trigger that selected it;
4. run bounded LLM diagnosis for the selected items when authorized;
5. create a typed worklist containing proposed concept discovery, reanalysis,
   synonym/ambiguity review, split/merge work, retirement inspection, edge
   review, lead investigation or vector repair;
6. deterministically enumerate every alias, mention and graph edge affected by
   a structural proposal;
7. present the canonical plan, unresolved reviews, provider usage, migration
   impact and execution mode;
8. apply and run durable workers only with the required authority; and
9. re-census and verify graph integrity, lifecycle state, manifest and vector
   readiness.

The cycle stops when its worklist is complete, its configured budget or item
ceiling is reached, or no eligible work remains. It does not run indefinitely
because a provider can continue suggesting changes.

### Gradual concept migration

An LLM may suggest new concepts, synonyms, ambiguities, merges, splits, type
changes, retirement, restoration and dispositions for affected claims. It only
creates proposals. cREXX owns the impact census, canonical plan, validation and
apply.

The old concept is always retained as the active migration parent when a split
introduces successors. Supported aliases, mentions and claims can migrate
gradually. Uncertain connections stay on the old concept or enter explicit
ambiguity/review; they are not copied to every successor as accepted facts.

A merge follows the same gradual principle: select a survivor, introduce the
migration, and move only validated connections. Retirement is a later command
cycle with a separate plan and confirmation. It closes the active lifecycle
state only after every current alias, mention and incident edge has an explicit
disposition. It does not delete historical concepts, claims, citations or
maintenance provenance.

Concept nodes and claim edges are maintained in the same atomic graph plan.
Administrative lineage such as `split-from` or `merged-into` is retained as
maintenance provenance, not presented as a source-supported domain claim.

### Human and automatic operation

The operating patterns are:

- plan-only discovery with no provider calls or writes;
- supervised analysis followed by human approval of canonical changes; and
- automation that invokes the same explicit plan/apply/worker/status sequence
  within reviewed action, impact, privacy and provider-budget limits.

Automation still uses exact plan/apply digests, durable workers, deterministic
validation and final verification. Structural split, merge, type change,
retirement, restoration and claim retraction actions enter mandatory review;
analysis, embedding repair and vector publication can complete through the
reviewed maintenance worklist without a second graph-mutation path.

The canonical automation/MCP vocabulary is:

```text
maintenance plan
maintenance apply
maintenance status
maintenance inspect
```

The `$crexxrag-maintain` skill defaults to inspection and planning. Apply
requires `curate` capability and explicit authority. See
[Methodology and algorithms](algorithm.md#catalogue-and-graph-maintenance-methodology)
for ranking, the worklist, automation modes, split connection review and the
retirement gate.

## Query

```sh
crexxrag query 'What does BillingService depend on?'
crexxrag --format json query evidence 'question' --mode lexical
crexxrag --format json query answer 'question'
```

Lexical mode makes no embedding call. Automatic mode reports provider fallback
truthfully if query embedding is unavailable. Explicit hybrid mode fails if its
required embedding route fails. Generated answers are rejected for unknown,
duplicate, or missing citations.

## Automation and MCP

Canonical commands separate planning, applying, and supervision:

```text
ingest plan / ingest apply
maintain plan / maintain apply / maintain status / maintain inspect
proposal plan / proposal apply
worker start / worker run
job list / job status / job events
query search / evidence / answer / trace / path / timeline
library status / verify / backup / restore
```

Start the same vocabulary over stdio MCP with:

```sh
crexxrag --access read serve mcp
```

Mutation tools are only advertised/accepted when the corresponding capability
is supplied. MCP is read-only by default.

The evidence and maintenance fields exposed to agents are described in
[Methodology and algorithms](algorithm.md), including the boundary between
accepted claims, passage-level leads, explicit gaps and catalogue maintenance.
