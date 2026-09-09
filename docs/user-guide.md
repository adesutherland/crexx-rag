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

For a Codex provider, `provider.PROVIDER_ID.reasoning_effort = low` selects
lighter reasoning for routine extraction and background work. Supported names
are `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, and `max`; the chosen
model must support the value. Omit the setting to inherit the Codex default.
The override is sent on each generation turn, including citation corrections,
without changing global Codex settings. Changing it is a prospective
configuration change: review and apply `config plan` before new work.

Input-token limits cover the complete provider-reported input, including
managed context, instructions and structured-output schemas. They are not
source-text token counts. Codex extraction defaults to 32,768 input tokens in
format-1/2 configurations; format-3 uses its explicit
`role.extractor.max_input_tokens` value. The four-worker Luna test reported
16,987–23,948 tokens per call, so an explicit 8,192-token envelope was too small.
Use 32,768 as the measured starting envelope for that workload, then review
receipts when changing the model, prompts or evidence size. This is a reservation,
not a server-enforced limit or a guarantee of future usage. Keep the aggregate
`budget.input_tokens` large enough for the intended concurrent reservations.
Actual reported tokens remain authoritative; overruns are retained as
`settlement-exception` events rather than truncated or discarded.

For local embeddings, start llama.cpp and configure an `openai-compatible`
provider at `http://127.0.0.1:8081/v1`. The terms are:

- embedding generation: converting text into vectors;
- vector-index publication: publishing the resulting `.rxvec` generation.

An `openai-compatible` provider can also generate text through
`/chat/completions`, including JSON-schema output and citation-correction
history. Configure its local model, context/output limits and zero monetary
prices, and assign it to the desired generation roles. The `openai` provider
kind continues to use `/responses`. Both kinds use `/embeddings` for vectors;
different generation and embedding providers can be assigned independently.

The tutorial includes a ready-to-copy Codex plus local-embedding configuration:

```sh
work_dir=$(docs/tutorial/setup.sh --no-build --provider codex-local)
```

## Configuration lifecycle and throughput control

Operator configuration is read on every invocation. The installed example
`share/crexxrag/application/config/editable-gemini.conf` selects editable
`profiles/*.profile.tsv` files and `prompts/*.txt` files. Copy that config
folder together so its relative references remain valid. Provider URLs,
models, capabilities, prices, role limits, worker settings and prompts can all
be changed as data, without recompiling.

All relative source roots, profile files, glossary files and prompt files are
resolved from the configuration file's directory. The resulting paths enter
the effective configuration identity. A copied configuration in a new
directory therefore needs either its referenced files copied with it or
explicit absolute paths. Credential references stay symbolic.

Libraries created by older versions may retain `file:./...` source URIs.
Repeat ingestion from their original working directory so equivalent absolute
paths can be proved without replacing revisions or vector membership. The
comparison still checks the complete source envelope; changed bytes or policy
are never hidden by path equivalence.

For each generation role in config/3, choose exactly one prompt source:

```ini
role.answerer.system_prompt_file = prompts/answerer.txt
# Alternatively: role.answerer.system_prompt = one-line prompt text
profile.generic-profile.file = profiles/generic.profile.tsv
source.architecture-docs.maximum_file_bytes = 16777216
source.architecture-docs.maximum_depth = 32
plan.ttl_seconds = 3600
```

Prompt files support multiple lines, must be nonempty, and are bounded at
16,384 bytes with no NUL bytes. Their actual contents, rather than just their
names, enter configuration and work identity. Explicit profile files override
the compatibility profile of the same ID. `config explain` shows the effective
paths, profile origin, prompt hashes, and limits. Review `config diff` and
apply a fresh `config plan` before using changed settings with an existing
library. A prompt or model change applies to subsequent work and never
implicitly regenerates the unchanged corpus.

`maximum_file_bytes` accepts 1–2,147,483,647 (compatibility default
2,147,483,647), `maximum_depth` accepts 0–256 (default 64), and
`plan.ttl_seconds` accepts 1–604,800 (default 3,600). These are operational
bounds. Worker run/start defaults use `worker.poll_ms`, and worker leases
accept the same 1–86,400-second range as configuration validation.

New configurations should declare `format = crexx-rag.config/3`. Formats 1 and
2 remain readable for compatibility: the loader projects their historical
execution envelopes explicitly, and those projected values enter the same
canonical configuration identities as format 3. New files must state provider
capabilities and prices, typed role execution policies, guided-worker timing,
and vector scale guards. The shipped Google example includes:

```text
provider.gemini-generate.requests_per_minute = 60
provider.gemini-generate.tokens_per_minute = 1000000
provider.gemini-generate.concurrent_requests = 2
provider.gemini-generate.initial_backoff_ms = 1000
provider.gemini-generate.maximum_backoff_ms = 60000
provider.gemini-generate.jitter_ms = 250
provider.gemini-generate.context_tokens = 1048576
provider.gemini-generate.maximum_output_tokens = 65536
provider.gemini-generate.embedding_dimensions_minimum = 0
provider.gemini-generate.embedding_dimensions_maximum = 0
provider.gemini-generate.maximum_batch_size = 1
provider.gemini-generate.input_price_microunits_per_million = 300000
provider.gemini-generate.output_price_microunits_per_million = 2500000
provider.gemini-generate.catalog_observed_date = 2026-08-24

role.extractor.provider = gemini-generate
role.extractor.max_input_tokens = 8192
role.extractor.max_output_tokens = 4096
role.extractor.max_call_cost_microunits = 100000
role.extractor.temperature_millionths = 0
role.extractor.system_prompt = Discover only grounded concepts and relationships...

role.embedding.provider = gemini-embed
role.embedding.max_input_tokens = 8192
role.embedding.max_output_tokens = 0
role.embedding.max_call_cost_microunits = 1000
role.embedding.temperature_millionths = 0
role.embedding.dimensions = 768
role.embedding.batch_size = 100

worker.processes = 2
worker.max_in_flight = 1
worker.lease_seconds = 120
worker.poll_ms = 100
worker.guided_deadline_seconds = 0
worker.max_restarts = 2
worker.restart_backoff_ms = 5000

vector.maximum_rows = 1000000
vector.maximum_sidecar_bytes = 67108864
vector.embedding_maximum_items = 100000

retrieval.lexical_candidates = 48
retrieval.vector_candidates = 12
retrieval.vector_scan_limit = 100000
retrieval.graph_hops = 3
retrieval.passage_limit = 12
retrieval.claim_limit = 8
retrieval.lead_limit = 8
retrieval.rrf_k = 60
retrieval.graph_direction = both
retrieval.maximum_evidence_bytes = 262144

maintenance.sparse_max_degree = 1
maintenance.query_gap_min_occurrences = 1
maintenance.batch_items = 1000

observation.capture_threshold = 50
observation.narrative_output_tokens = 4096
observation.cooldown_seconds = 900
observation.maximum_staleness_seconds = 86400
```

The provider limits are shared across OS workers for each provider/model, not
multiplied by `worker.processes`. Set them at or below the allowance for the
account and model. `concurrent_requests` limits calls to that provider/model;
`worker.max_in_flight` remains the per-job reservation ceiling. More worker
processes can improve local parsing and SQLite work, but they do not bypass the
provider admission limits. `guided_deadline_seconds = 0` derives the guided
wait from the reviewed job time budget. The vector sidecar setting is an
explicit fail-safe, not an RSS target: the current ANN reader still loads the
bounded sidecar as a whole, pending the compact/streamed representation work.

Inspect the effective policy before changing a library:

```sh
crexxrag config check
crexxrag config explain
crexxrag --library ./library config diff
```

These commands do not resolve credential values or make provider calls.
`config diff` reports `identical`, `identity-upgrade`, `operational`,
or `prospective`. Operational changes include budgets, worker settings, provider
timeouts/pacing/retry policy, retrieval result ceilings, vector-build policy
and schedules. Provider/model/privacy route, role, source-selection or
discovery changes are prospective: they change newly planned work without
rewriting previously accepted evidence. Profile edits, including chunking,
vocabulary and ranking, also apply to subsequent work. Existing source spans
and their original profile provenance remain valid.

Apply an operational, prospective or legacy-identity upgrade only from the
exact reviewed JSON and digest:

```sh
crexxrag --library ./library --format json --access plan \
  config plan --reason 'increase workers within Gemini quota' > config-plan.json
plan=$(jq -r '.records[0].fields.canonical_plan' config-plan.json)
digest=$(jq -r '.records[0].fields.digest' config-plan.json)
crexxrag --library ./library --access admin config apply \
  --plan-json "$plan" --expect-digest "$digest"
```

Apply fails if the plan is changed, expired, stale, or active jobs remain.
Configuration application changes the current planning policy and appends an
immutable audit event; it does not publish a corpus generation or queue work.
Existing jobs, provider runs, claims, embeddings and generations retain their
original configuration provenance. A subsequent `ingest plan` observes the
configured source set under the stable ingestion algorithm identity and queues
only genuinely added or changed source content. If the sources are unchanged,
`ingest apply` returns `identical-no-op` with zero work and zero provider calls.

Reinterpreting existing content requires an explicitly reviewed operation.
Provider or prompt changes can be exercised selectively through bounded
maintenance. A configuration or profile edit never requests a corpus rebuild.

All runtime tuning needed here is plain configuration. RexxScript is callable
as a function and may later help author configuration or rules, but it adds no
present capability to this bounded declarative contract. It is therefore not
used here, and an operator or agent does not need to edit cREXX source.

Compiled profiles remain available, while domain profiles can also be supplied
as bounded tab-separated data. The configured id must match the identity in the
file:

```text
profiles = scottish-history-profile
profile.scottish-history-profile.file = ./scottish-history.profile.tsv
```

Profile data declares `format`, one `profile` identity, `concept`,
`relationship`, `alias`, one `chunk` policy, `weight` values in millionths,
`prompt`, and `validator` records. The loader has fixed file, line, type and
cardinality ceilings; it cannot name or execute a cREXX or RexxScript module.
Normal profile validation and content-derived profile hashing apply after it is
parsed. A changed profile requires a reviewed configuration transition.
Compatible interpretation changes apply prospectively; an unchanged source
corpus remains a no-op. A change classified `reingest-required` needs an
explicit, separately qualified transition and must preserve the prior source,
history and usable derived representation.

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

The controller reserves and registers the complete configured worker group
before admitting work. Startup failure or a registration timeout is reported
with the worker identity; child stderr is inherited so redirected controller
logs also retain worker and provider channel errors. On controller failure,
drain requests are recorded before waiting for child cleanup.

A heartbeat encountering ordinary SQLite writer contention makes up to three
attempts, retaining the existing five-second busy timeout per attempt and short
100/200 ms pauses. Retries log the process identity and SQLite diagnostic. No
new work is admitted by that worker while its heartbeat is waiting. Exhausted
contention, constraints, missing process rows and stale transaction snapshots
remain errors; heartbeat recovery does not restart workers or provider calls.

For `worker start --job JOB_ID`, an unhealthy provider transport stops its worker
after preserving the current item's outcome. After that process exits, the
controller can replace it in the same slot. `worker.max_restarts` permits 0..10
automatic replacements across the whole job, defaulting to two; zero disables
replacement. `worker.restart_backoff_ms` accepts 10..60000, defaulting to 5000.
The delay multiplies by six after each replacement, capped at 60000 milliseconds
(the defaults therefore wait five and thirty seconds). Both settings are optional
operational configuration. Default values preserve existing configuration hashes.

Replacement reservations are durable job events, so restarting a controller or
pruning process rows cannot reset that ceiling. Replacement preserves the slot's
remaining item/poll allowance and the original job budgets and deadline. A pause,
cancellation, drain or exhausted ceiling stops further work. Startup failures and
unclassified crashes require diagnosis; they do not automatically consume more
process launches. Unfiltered worker groups also require operator restart.
Successful controller results include `workers_restarted`; historical failed
process records remain available for diagnosis.

The selected provider's `max_attempts` independently limits retryable item
failures. Set it to three when three total attempts are wanted; a value of one
still means no ordinary item retry. Worker replacement never rewrites dead
letters or resets attempt history. A submitted request with an unknown outcome
pauses the job for reconciliation, retaining its external identities and any
reported usage. A saved successful response remains eligible for publication
even if releasing its provider admission fails. Such a failure stops the worker
and reports the admission identity and SQLite diagnostic. Exact duplicate
admission settlement succeeds; conflicting settlement remains an error.

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

`job events` reads the durable event ledger for that job, with numeric cursor
paging; it does not list work items. `job status` includes the last failure or
uncertainty reason. An interrupted request with no durable response produces
`provider-outcome-uncertain`, pauses the job and leaves an inspectable dead
letter. It is not automatically submitted again. Inspect and reconcile that
outcome before explicitly choosing new work.

Received extraction and embedding outputs are retained before validation and
settlement. Restarting the same item reuses its receipt without another call,
under normal input validation and fresh worker ownership. An explicitly created
replay job is new work and may make another call. Actual late or above-estimate
usage is recorded once even when the original worker may no longer publish.

`job replay` requires a source job in `completed_with_errors`. It copies the
selected dead letters into a new queued job under the current configuration
and current item/call/token/cost/allowance budgets. The source job and source
items remain terminal and unchanged; `job_replays` and `job_replay_items`
retain the lineage. The target must be semantically compatible. If a model,
profile, source or discovery change makes the failed input incompatible, review
fresh work under the new interpretation. A replay rejection does not authorize
reingesting the corpus or replacing its existing data.

The command itself makes no provider call. Start workers for the returned
`replay_job_id` using the normal supervised worker command. The command
`job retry JOB_ID --item ITEM_ID` remains available for compatibility but
requeues the item inside the original job; prefer `job replay` when preserving
the failed baseline matters.

`library report` reconciles those immutable source dead letters with all replay
descendants. It reports `actionable` roots when no replay is active or has
succeeded, `replaying` roots while a descendant is queued/running/paused, and
`resolved` roots after a replay descendant completes. Replay never deletes or
rewrites the historical source record.

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

Query gaps enter this cycle automatically when they meet
`maintenance.query_gap_min_occurrences`. Their evidence search uses the recorded
question, while the diagnostic warning explains the retrieval limitation to the
resolution provider. They are not automatically manual tasks or database errors.
Maintenance may settle them, retain an unresolved explanation, or request a
follow-up; policy exceptions require operator review. A later successful answer
does not by itself close the original observation.

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

Automation uses exact plan/apply digests, durable workers and deterministic
validation. Set `maintenance.mode = automatic` for the durable resolution
backlog, `supervised` to review model-proposed changes, or `manual` to collect
questions without calling providers. The compatibility default `reviewed`
keeps the earlier ranked batch and mandatory structural review behavior.

For automatic maintenance, `maintain --yes` returns success (exit code 0) when
its reviewed budget or window is exhausted and admitted calls have finished.
The window records `budget-exhausted` or `deadline`; unstarted tasks remain in
the durable backlog for the next invocation's fresh plan. Call limits are
shared by the configured workers. Reaching a limit creates no failed task and
does not consume an uncalled task's retry allowance. Execution failures still
return a nonzero exit code, and rejected provider answers retain their normal
validation and accounting outcomes.

Citation validation gives extraction and maintenance resolution responses one
immediate correction attempt when a quotation, literal mention label, relationship
endpoint or selected evidence span fails grounding. The correction receives the
original input, saved response and validation feedback. Extraction feedback
identifies the failing array entry, rejected quotation and required endpoint
labels when relevant. It must pass the same
strict validation; it may withdraw unsupported extraction content or return an
unresolved resolution. This does not enable fuzzy matching or partial publication.

The correction is a separate provider call within the existing shared call,
token, cost and time budgets, including when the ordinary attempt limit is one.
Its durable `citation-correction-requested` event prevents repeated corrections
after a restart. Both provider receipts and usage records are retained. If the
window budget has already been used, no extra call is made. Source-shape, identity,
lifecycle and publication errors do not receive this citation correction.

A bounded `worker start --job JOB_ID --max-items N` lets each configured worker
process up to N work attempts. Empty polls and uncalled budget deferrals do not
consume this allowance. A citation correction is a separate work attempt;
completed failures and work resolved without a provider call also count.
Active calls finish before a worker stops. Job completion, pause, drain and
shared budgets still apply, so a worker can legitimately finish below N.

`worker run --follow` accepts the same per-worker limit. Zero or omission means
no item limit. The existing `--max-polls N` separately limits all checks,
including empty ones; if both limits are set, the first one reached stops the
worker. Both accept 0..1000000. Use `--max-items` for work batches.

The bounded command returns success when its workers finish. If work remains, `vector_state` is
`pending-work`; starting the group again continues that same job. Vector
publication waits until the job completes or is explicitly paused. The nightly
wrapper plans once with `--minutes N`, an exact `--until` timestamp, or an
`--overnight HH:MM-HH:MM` local-time window, and shares each batch across the
configured workers. The main product checks its fixed deadline before each
call, allowing the call timeout plus five seconds for cleanup. Worker restarts
never extend that deadline. A late overnight launch skips successfully.

For durable maintenance, `maintenance.window_seconds` is the default elapsed
duration. Parallel provider-call durations do not consume it. The optional
`maintenance.provider_time_minutes` separately caps aggregate provider time;
zero disables that cap. `budget.minutes` continues to apply to ingestion,
replay and compatibility reviewed maintenance. Call/token/cost/allowance limits
still cover the entire run. See [finish-time rules](autonomous-maintenance.md#choosing-a-finish-time)
for midnight, timezone, daylight-saving and graceful-stop behavior.

The [durable maintenance guide](autonomous-maintenance.md) describes the full
runtime configuration, five-hour windows, shared budgets, split/merge follow-up
tasks, the work-specific limits of interruption recovery, and task/decision
inspection. No recompilation is needed, and changing configuration never
automatically reingests an unchanged corpus. Unattended concurrent maintenance
remains subject to the open [reliability gates](reliability-coverage-review.md).

In the compatibility `reviewed` mode, each maintenance plan is an incremental batch bounded by
`maintenance.batch_items` as well as the global item, provider-call, token,
time and cost budgets. Repair work is ranked ahead of enrichment: a missing
vector publication, missing active embeddings and pending claim conflicts take
capacity before the highest-ranked cognitive reviews. Rerun the same
plan/apply/worker/status cycle to select the next eligible batch; a maintenance
command does not imply that the entire backlog must be completed in one run.
Content already owned by an improvement job is excluded from later batches.
Queued and running work finishes in that job, while terminal failures remain
durable dead letters and use `job replay`; maintenance does not create a second
copy that would obscure the original attempt history.
The machine plan reports `work_provider_calls` as the expected one-call-per-item
count and `maximum_work_provider_calls` as the hard ceiling after reserving the
configured retry attempts. Critical embedding-repair retries reserve capacity
before cognitive enrichment and both remain inside the global provider budget.

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

## Claim time and provenance

Use [time and provenance](time-and-provenance.md) to attach document dates and
status once per source revision with `ingest plan --metadata-input FILE`.
Chunks and citations inherit these links without per-claim LLM assessment.
Ordinary ingestion and maintenance do not request that optional experimental
assessment. Source publication, historical validity, assertion time and system
capture are separate. Unknown dates remain explicit. The same reference covers
historical query filters and the version 2 evidence contract.

## Query

```sh
crexxrag query 'What does BillingService depend on?'
crexxrag --format json query evidence 'question' --mode lexical
crexxrag --format json query answer 'question' --mode hybrid
crexxrag --format json query trace 'question' --mode hybrid
crexxrag --format json query path 'question' --mode hybrid
crexxrag --format json query timeline 'question' --mode hybrid
crexxrag citation show 'crexx-rag:...'
```

Lexical mode makes no embedding call. Automatic mode reports provider fallback
truthfully if query embedding is unavailable. Explicit hybrid mode fails if its
required embedding route fails. Generated answers are rejected for unknown,
duplicate, or missing citations when the provider declares the answer
supported or partial. Partial evidence is returned as useful evidence with its
citations and explicit remaining gaps; the RAG layer does not suppress it
merely because it cannot fully answer the question. `insufficient` is reserved
for evidence that answers none of the question. Trace, path, and timeline are
distinct bounded projections; path results include follow-up leads, and
`citation show` resolves a public citation to its exact stored source span.

When recording JSON command output, do not pipe the command directly through
`jq` if the command's exit status matters: a successful `jq` can hide a failed
`crexxrag` status. Capture output and status first, then format it, for example:

```sh
crexxrag --format json query answer 'question' --mode hybrid >answer.json
status=$?
jq . answer.json
test "$status" -eq 0
```

Every invoked query provider is recorded in the library's provider history
with an explicit embedding/answer purpose, completion-time cost estimate,
tokens, duration, outcome, and the `provider_run_id` returned by the command.
Failed transport calls and schema/citation-rejected answers remain visible;
credential, privacy, and budget preflight failures that make no provider call
do not create a row.

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
state inside one SQLite read transaction; lists bounded relationship types and top concepts; and gives each top
concept a stable source-span citation. Semantic and operational digests are
separate so a maintenance or vector-publication change does not masquerade as
a corpus-generation change.

Health is deliberately multidimensional. Storage, lexical, vector,
provenance, graph, maintenance and review each report their state, issue count
and deterministic detail. There is no opaque overall score. A reconciliation
warning means durable maintenance-run state and terminal job state disagree;
it does not mean lexical or vector retrieval is unavailable.

The separate `durable-maintenance-backlog` record counts every task state,
unfinished/completed workflows and retained decisions. Open tasks are pending,
dispatched, unresolved, review or failed; they contribute to maintenance health
and the snapshot's work backlog alongside legacy maintenance items. Durable
review tasks also contribute to review health and the snapshot's review count.
These are work-object counts, not estimates of distinct future provider calls.
Old snapshots remain unchanged; their stored report identifies which counters
were available when they were captured.

`--narrative cached` reads a matching prior advisory result without a provider
call. `--narrative refresh` makes exactly one call through the configured
`advisory` role after privacy and budget preflight. Human refresh requires
`--yes`; an explicit JSON or MCP `refresh` request is the authority. The model
receives the bounded report plus representative cited passages. Its exact
JSON is rejected for extra fields, missing/duplicate/unknown citations or
oversized content. `observation.narrative_output_tokens` independently bounds
the structured response so multi-subject narratives are not constrained by
the shorter query-answer default. Only validated output is cached, keyed by both report
digests and the provider, model and prompt version. It cannot mutate concepts,
claims or other canonical graph state.
Failed or rejected narrative calls remain in provider history with their
tokens and completion-time cost estimate even though no narrative is cached.

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

`churn-matrix/2` always retains the first point. It then scores semantic,
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
backlog separately from the immutable historical dead-letter count. Current
actionable/replaying/resolved status is derived by the reconciliation view and
reported without rewriting old snapshots. A cached validated report narrative
is attached when available; a later narrative with identical report digests is
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
schedule list / schedule show
```

Schedules are data definitions, not an in-process clock. Each enabled schedule
names one allowlisted operation (`maintain.plan`, `library.snapshot`,
`library.backup`, or `library.report`) and a trigger label. Use `schedule list`
or `schedule show ID` to consume the definition from CLI/JSON/MCP. Cron, Codex
automation, systemd, launchd, or another external runner owns recurrence and
invokes the ordinary public command with its normal access and confirmation
rules; listing a schedule never runs it or calls a provider.

Start the same vocabulary over stdio MCP with:

```sh
crexxrag --access read serve mcp
```

Mutation tools are only advertised/accepted when the corresponding capability
is supplied. MCP is read-only by default.

The evidence and maintenance fields exposed to agents are described in
[Methodology and algorithms](algorithm.md), including the boundary between
accepted claims, passage-level leads, explicit gaps and catalogue maintenance.

## Recover a vector sidecar from SQLite

SQLite stores the embedding BLOBs and chunk memberships. A `.rxvec` sidecar is
an efficiency index derived from those records. With a matching configuration
and profile and no active job, recover a missing or corrupt file using:

```sh
crexxrag --access control vector rebuild
crexxrag --access diagnose library verify
```

The equivalent MCP control tool is `rag_vector_rebuild`. This operation makes
zero provider calls, retains generation and provenance, and returns
`rebuilt-from-sqlite` for a repaired file or `identical-no-op` for an intact
index. It uses the configured vector build and byte limits. It cannot invent
missing embedding coverage or restore membership removed by an earlier
operation; those require a separately reviewed corpus recovery.

Concept and claim maintenance can continue using an existing vector index when
its source chunks and embedding links are unchanged. Its manifest entry retains
the generation that built the index. The application proves compatibility from
SQLite; source or embedding changes require a matching index publication.
Pausing and draining work does not by itself invalidate compatible vectors.

Extraction uses source quotations. The application computes offsets, prefers
exact matches, then accepts case differences using Unicode casefolding and ASCII whitespace
run differences with a map back to the original bytes.
Repeated quotations within a chunk select the first match. Invalid quotations,
unsupported relationships and conflicting canonical identities remain rejected;
no provider output overrides existing evidence or identity validation.

A conflicting classification or ambiguous catalogue match creates a durable
identity-resolution question instead of failing the extraction batch. Its
dependent relationships remain deferred. Maintenance reviews the source and
competing identities, including recent classification changes, under the normal
evidence and impact rules. An accepted resolution is retained for that source
occurrence and used by follow-up extraction. Uncertain decisions remain open
or require review; a mismatch alone never authorises changing a classification.

Explicit `query ... --mode hybrid` fails if the published sidecar is missing
or corrupt, before calling a query provider. Automatic mode may use lexical
retrieval and reports its effective mode.

Maintenance worklists use complete cursor pagination. `maintain status` and
`maintain inspect` accept `--limit 1..98` and `--cursor ITEM_ID`. The final
`maintenance-page` record gives `returned`, `has_more`, and `next_cursor`;
pass that cursor unchanged to get the next page for the same run. MCP exposes
the same `limit` and `cursor` arguments. Successful items in a mixed-result
job are marked applied individually; failed items remain visibly failed.
