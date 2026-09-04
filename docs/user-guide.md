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

## Configuration lifecycle and throughput control

New configurations should declare `format = crexx-rag.config/2`. Format 1
remains readable for compatibility, with bounded defaults for the added
fields. The shipped format-2 examples state them explicitly:

```text
provider.gemini-generate.requests_per_minute = 60
provider.gemini-generate.tokens_per_minute = 1000000
provider.gemini-generate.concurrent_requests = 2
provider.gemini-generate.initial_backoff_ms = 1000
provider.gemini-generate.maximum_backoff_ms = 60000
provider.gemini-generate.jitter_ms = 250

worker.processes = 2
worker.max_in_flight = 1
worker.lease_seconds = 120
```

The provider limits are shared across OS workers for each provider/model, not
multiplied by `worker.processes`. Set them at or below the allowance for the
account and model. `concurrent_requests` limits calls to that provider/model;
`worker.max_in_flight` remains the per-job reservation ceiling. More worker
processes can improve local parsing and SQLite work, but they do not bypass the
provider admission limits.

Inspect the effective policy before changing a library:

```sh
crexxrag config check
crexxrag config explain
crexxrag --library ./library config diff
```

These commands do not resolve credential values or make provider calls.
`config diff` reports `identical`, `identity-upgrade`, `operational`, or
`semantic`. Operational changes include budgets, worker settings, provider
timeouts/pacing/retry policy, vector-build policy and schedules. Source,
profile, provider/model/privacy route, role or discovery changes are semantic.

Apply an operational or legacy-identity upgrade only from the exact reviewed
JSON and digest:

```sh
crexxrag --library ./library --format json --access plan \
  config plan --reason 'increase workers within Gemini quota' > config-plan.json
plan=$(jq -r '.records[0].fields.canonical_plan' config-plan.json)
digest=$(jq -r '.records[0].fields.digest' config-plan.json)
crexxrag --library ./library --access admin config apply \
  --plan-json "$plan" --expect-digest "$digest"
```

Apply fails if the plan is changed, expired, stale, or active jobs remain. A
semantic classification cannot be applied as operating policy; ingest a new
generation using the changed configuration. Existing generations retain their
original configuration provenance while new jobs use the current snapshot.

All runtime tuning needed here is plain configuration. RexxScript may later
offer a friendlier way to author the same contract, but it is not required and
an operator or agent does not need to edit cREXX source.

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

Provider admission is persisted in SQLite and shared by those processes. A
call that cannot obtain request, reserved-token or concurrency capacity waits
only within its configured timeout. If it times out before the adapter runs,
the reservation is settled but no provider call is recorded. Retryable HTTP
results use exponential backoff, bounded jitter and `Retry-After` when present.

## Dead letters and replay

Inspect a terminal job before deciding what to replay:

```sh
crexxrag job status JOB_ID
crexxrag job events JOB_ID
crexxrag --access control job replay JOB_ID \
  --reason 'retry after corrected provider pacing'
crexxrag --access control job replay JOB_ID --item ITEM_ID \
  --reason 'retry one corrected item'
```

`job replay` requires a source job in `completed_with_errors`. It copies the
selected dead letters into a new queued job under the current configuration
and current item/call/token/cost/allowance budgets. The source job and source
items remain terminal and unchanged; `job_replays` and `job_replay_items`
retain the lineage. The target must be semantically compatible, so a model,
profile, source or discovery change requires a new ingestion generation rather
than disguising it as a replay.

The command itself makes no provider call. Start workers for the returned
`replay_job_id` using the normal supervised worker command. The command
`job retry JOB_ID --item ITEM_ID` remains available for compatibility but
requeues the item inside the original job; prefer `job replay` when preserving
the failed baseline matters.

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
duplicate, or missing citations when the provider declares the answer
supported. When retrieved material does not answer the question, the provider
may declare insufficient grounding with no citations; the command succeeds
with a deterministic insufficient-evidence answer instead of treating the
absence of relevant evidence as an infrastructure failure.

## Library report

```sh
crexxrag library report
crexxrag --format json library report --top 10
crexxrag library report --top 10 --narrative cached
crexxrag library report --top 10 --narrative refresh --yes
```

The default report is deterministic, read-only and makes no provider call. It
binds corpus, catalogue, graph and source-support metrics to the published
semantic generation; overlays current vector, job, review and maintenance
state; lists bounded relationship types and top concepts; and gives each top
concept a stable source-span citation. Semantic and operational digests are
separate so a maintenance or vector-publication change does not masquerade as
a corpus-generation change.

Health is deliberately multidimensional. Storage, lexical, vector,
provenance, graph, maintenance and review each report their state, issue count
and deterministic detail. There is no opaque overall score. A reconciliation
warning means durable maintenance-run state and terminal job state disagree;
it does not mean lexical or vector retrieval is unavailable.

`--narrative cached` reads a matching prior advisory result without a provider
call. `--narrative refresh` makes exactly one call through the configured
`advisory` role after privacy and budget preflight. Human refresh requires
`--yes`; an explicit JSON or MCP `refresh` request is the authority. The model
receives the bounded report plus representative cited passages. Its exact
JSON is rejected for extra fields, missing/duplicate/unknown citations or
oversized content. Only validated output is cached, keyed by both report
digests and the provider, model and prompt version. It cannot mutate concepts,
claims or other canonical graph state.

## Historic snapshots and trends

```sh
crexxrag --access control library snapshot \
  --trigger ingestion --reason 'initial corpus publication'
crexxrag --access control library snapshot \
  --trigger maintenance --reason 'reviewed maintenance settled'
crexxrag library trend --limit 20
```

Snapshot evaluation is deterministic and makes no provider call. The supported
triggers are `manual`, `ingestion`, `maintenance`, `vector-publication`,
`replay`, `reconciliation`, `migration`, `backup`, and `scheduled`. They label
the lifecycle boundary; they do not override the churn decision.

`churn-matrix/1` always retains the first point. It then scores semantic,
vector, health, job-settlement, work-backlog, historical-dead-letter,
review/gap and maximum-age changes. The capture threshold is 50 and ordinary
changes have a 900-second cooldown. Semantic, vector, health and settlement
changes bypass that cooldown. Work and dead-letter deltas are material at the
larger of 25 items or five percent; review/gap deltas use 10 items or five
percent. A changed point is captured after 86,400 seconds even when individual
deltas stay small.

Exact duplicates are suppressed. Equivalent repeated suppression requests are
coalesced into one decision row with an increasing evaluation count, so a
frequent scheduler does not create a large snapshot or decision history. Every
response explains its score, threshold, elapsed time, previous point and full
machine-readable matrix. Guided `ingest` and `maintain` request a checkpoint at
their terminal boundary. Machine workflows should request one after meaningful
publication, maintenance, replay, reconciliation, migration and backup events.

Snapshots use a fixed top-10 semantic census so changing a display option
cannot manufacture churn. They retain the current maintenance work-state
backlog separately from the historical dead-letter count; neither is labelled
uniquely actionable until replay/reconciliation semantics establish that. A cached validated report narrative is
attached when available; a later narrative with identical report digests is
discoverable without modifying the immutable snapshot.

`library trend` is read-only and zero-provider. It reports the retained and
suppressed counts, the policy, chronological points and signed deltas. With one
point it reports `baseline-only` and zero deltas rather than inventing a trend.

## Backup and restore

Backups include the SQLite authority, manifest and every published vector
sidecar needed by that pinned publication:

```sh
crexxrag --library ./library --access admin library backup \
  --output ./library-backup
crexxrag --library ./library --access admin library restore \
  --input ./library-backup --output ./library-restored
crexxrag --library ./library-restored --access diagnose library verify
```

Treat the final verify as part of the backup operation. A copied SQLite file
without its referenced `.rxvec` sidecars is not a complete backup. Request a
`backup` lifecycle snapshot after a meaningful retained backup boundary; the
normal churn matrix decides whether a new historic point is warranted.

## Automation and MCP

Canonical commands separate planning, applying, and supervision:

```text
ingest plan / ingest apply
maintain plan / maintain apply / maintain status / maintain inspect
proposal plan / proposal apply
worker start / worker run
job list / job status / job events
job replay
query search / evidence / answer / trace / path / timeline
library status / report / snapshot / trend / verify / backup / restore
config check / config explain / config diff / config plan / config apply
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
