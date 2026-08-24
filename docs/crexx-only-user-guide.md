# cREXX-Only User Guide

Status: target user experience, 2026-07-26. The commands on this page define the
interface the migration should deliver; they are not all implemented today. For
the current native proof of concept, use
the [archived native-v1 tutorial](archive/native-v1/tutorial-import-improve-query.md).

## What The Tool Does

`crexx-rag` turns a folder of source material into a local, shareable knowledge
library for people and LLM agents. It keeps the original passages, builds
lexical and optional semantic indexes, identifies useful concepts, and records
typed relationships only when they have source evidence.

The result is designed for questions such as:

- Which services depend on this database, and what passages support that?
- What decisions changed between two dates?
- Are two names aliases, or is the name genuinely ambiguous?
- What does the corpus state directly, and what is merely a graph lead?
- What new documents or unresolved work should be processed overnight?

An LLM receives a compact evidence packet with citations and gaps instead of
having to ingest the entire corpus into one context window.

## The Four Workflows

1. **Initial load** inventories sources, creates revisions/chunks, builds FTS,
   optionally embeds, performs a candidate census, and queues useful deep work.
2. **Add or change documents** runs the same reconciler, but does work only for
   the source delta.
3. **Search and evidence** combines focused lexical, vector, and typed-graph
   retrieval and returns source-bound passages and claims.
4. **Background improve** consumes an explicit, budgeted queue of missing or
   weak work and leaves every decision inspectable.

## Mental Model

- A **source** is a logical document or record.
- A **revision** is one immutable observed state of a source.
- A **chunk** is a stable span within a revision and is the normal citation
  target.
- A **concept** is an accepted entity with a domain type.
- A **mention** says a passage refers to a concept; it is weak evidence, not a
  relationship claim.
- A **claim** is a typed, directed relationship with one or more source support
  records.
- A **lead** is a useful vector or graph connection that has not earned claim
  status.
- A **job** is a durable, resumable unit of ingestion or improvement.
- A **review** is a decision about ambiguity, conflict, type, endpoint, or a
  proposed external extraction.

## Target Installation Shape

The installed product should provide:

```text
crexx-rag                 cREXX command application
rag*.rxbin                cREXX application modules
rxsqlite.rxplugin         generic SQLite facility
CREXX provider libraries  local and hosted LLM/embedding support
```

Ordinary use must not require the CREXX or `crexx-rag` source checkout, CMake
build paths, Python, or a product-specific C++ library.

Until the target is delivered, the current project still builds with:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

## Configuration In cREXX

Each library uses two cREXX modules:

- a configuration module selects providers, role routing, privacy, budgets,
  source sets, and worker limits; and
- a profile module defines domain vocabulary, aliases, chunk policy, ranking,
  extraction/validation, and evidence policy.

The final source syntax will be shipped as compiled examples after the
configuration PoC. The contract is equivalent to this illustrative data:

```text
configuration id: architecture-local

source-sets:
  architecture-docs:
    connector: folder
    root: ./source-docs
    include: ["**/*.md", "**/*.txt", "**/*.rexx", "**/*.crexx"]
    stable-key: relative-path
    privacy: internal
    retain-raw-artifact: true

providers:
  local-chat:
    kind: openai-compatible
    base-url: http://127.0.0.1:8080/v1
    model: local-chat-model
    privacy: local
  local-embed:
    kind: openai-compatible
    base-url: http://127.0.0.1:8081/v1
    model: nomic-embed-text-v1.5
    privacy: local
  hosted-strong:
    kind: openai
    credential: env:OPENAI_API_KEY
    model: configured-hosted-model
    privacy: hosted

roles:
  advisory: local-chat
  extractor: local-chat
  embedding: local-embed
  answerer: none

policy:
  restricted-source-route: deny-hosted
  worker-processes: 1
  default-improvement-budget:
    minutes: 120
    model-calls: 200
```

The configuration module exports this as typed cREXX data. Loading it may not
start work, read source text, contact a provider, or mutate a library. `profile
validate` and `ingest plan` render the resolved non-secret values for review.
Credentials remain environment references and are never stored in the bundle.

The simple folder example uses relative paths as connector stable keys. A rename
therefore appears as remove-plus-add unless the plan is given an explicit
reviewed mapping. Content-digest equality may suggest that mapping but never
merges two same-content files automatically. Connectors with durable external
ids can preserve rename identity without that review.

Profiles should be independent modules such as:

```text
generic_profile
it_architecture_profile
scotland_profile
```

Do not fork the pipeline for a domain. A profile supplies types, relationships,
normalization, prompts, weights, and validators to the same algorithms.

## Create And Check A Library

Global options identify the library, configuration, profile, output format, and
access capability:

`--access` accepts a comma-separated/repeated capability set and defaults to
`read`. `plan`, `control`, `ingest`, `curate`, `diagnose`, and `admin` expand the
bounded roles described in the architecture; they are process safety gates, not
authentication or a substitute for filesystem permissions.

P2-07 freezes the target parser contract: global `--library`, `--config`,
`--profile`, `--format`, and repeated `--access` options precede the noun;
operation options and positionals follow the noun/verb; and `--` makes all
remaining argv values positional. This is an argv grammar, never a shell-text
grammar. The parser contract and the P2-08 shared lifecycle/diagnostic
dispatcher are implemented in cREXX. The examples below describe that shared
operation contract; the replacement CLI adapter itself remains a later product
surface.

Stable target exit meanings are:

| Code | Meaning |
| ---: | --- |
| 0 | success |
| 1 | operation failed |
| 2 | usage or command syntax |
| 3 | configuration invalid |
| 4 | requested access denied |
| 5 | requested object not found |
| 6 | stale state or conflict |
| 7 | storage/integrity failure |
| 8 | required capability/provider unavailable |
| 9 | cancelled |
| 10 | internal invariant failure |

Machine results use `crexx-rag.command-result/1`. `json` returns one bounded
result object; `ndjson` returns one result header followed by one line per typed
record. Human output is a rendering of that same result and is not a separate
semantic operation.

```bash
crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --profile it_architecture_profile \
  --access admin \
  library init
```

Check the installed runtime, generic plugins, provider configuration, schema,
and sidecars:

```bash
crexx-rag --config architecture_local_config doctor

crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --access diagnose \
  library verify
```

`doctor` must distinguish missing installation capabilities from a broken
library or an unavailable optional model.

The P2-08 provider test is deliberately configuration-only: local declarations
can be validated without a request, while hosted tests report that a separately
authorized canary is required. Neither path resolves a credential or claims
provider reachability.

## Plan And Run Initial Ingestion

Planning is read-only. It inventories the configured source set and reports:

- new, changed, unchanged, missing, and ignored sources;
- expected chunk and embedding deltas;
- proposed candidate/extraction work;
- local or hosted provider routes and privacy decisions;
- estimated calls, tokens, cost, and duration when known;
- whether a backup is required; and
- the library/config/profile generations the plan is bound to.

```bash
crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --profile it_architecture_profile \
  --access plan \
  --format json \
  ingest plan --source-set architecture-docs --output ./initial.plan.json
```

Planning performs no library or filesystem writes except the explicitly named
output file. It prints the canonical plan's SHA-256 digest. Review that content
and digest, then apply the exact file with ingestion capability:

```bash
crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --profile it_architecture_profile \
  --access ingest \
  ingest apply --plan ./initial.plan.json --expect-digest <sha256>
```

The accepted P2-10 shared facade implements the underlying canonical bytes,
digest, expiry, and hostile apply-time revalidation. Its transport-neutral
apply option is `--plan-json`; a later thin CLI adapter will read `--plan FILE`
and pass those exact bytes to the facade. The currently shipped native-v1 CLI
has not been replaced. The Phase-3 ingest and Phase-4 improvement development
APIs now create and execute durable jobs, but the shared public facade still
reports `enqueued=false` until Phase 6 wires the command vocabulary to those
accepted algorithms.

After the Phase-6 adapter is implemented, public apply will return a job id
immediately. It will continue to refuse a stale plan if the library, sources,
configuration, profile, provider route, or reservations changed.

Applying enqueues work; it does not hide a daemon inside the command. For a
manual run, process one job explicitly:

```bash
crexx-rag --library ./architecture.cprag --access ingest \
  worker run --once --job <job-id>
```

For unattended work, run `worker run --follow` under launchd, systemd, or
another operator-owned supervisor. A queued job outlives the terminal; progress
requires a live or later worker.

```bash
crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --profile it_architecture_profile \
  --access ingest,curate \
  worker run --follow --worker-id architecture-worker-1
```

The supervisor owns restart and scheduling. An LLM may monitor the job but does
not gain process-supervision authority through the knowledge tools.

The underlying Phase-4 worker implementation is already database-clock leased
and fenced, supports bounded once/follow loops, pause/resume/drain, heartbeat,
retry/dead-letter, cooperative cancellation, exact reservation settlement, and
multi-process recovery. The command spellings in this guide remain target
interface until Phase 6.

Monitor it without reading SQLite directly:

```bash
crexx-rag --library ./architecture.cprag job status <job-id>
crexx-rag --library ./architecture.cprag job events <job-id> --follow
```

Status reports the job state separately from failed attempts, then exact
`planned_total`, `queued`, `running`, `processed`, `skipped`, `dead_letter`, and
`cancelled` item counts plus current item, provider/model, reserved/actual
budget use, throughput, timestamps, last error, and artifact publication state.

## Add, Change, Or Remove Documents

Run `ingest plan` again. There is no separate algorithm for incremental load:

```bash
crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --profile it_architecture_profile \
  --access plan \
  ingest plan --source-set architecture-docs --output ./delta.plan.json
```

An unchanged source must appear as `unchanged` and cause no write, embedding, or
model request. A changed source produces a new revision and reuses unchanged
chunks and derived artifacts. A missing source is not deleted silently: the
plan shows the support and claims it would retract and requires the configured
missing-source policy or an explicit decision.

Apply and monitor the delta exactly like initial load.

## Search Interactively

Human-oriented search returns compact passages and why they ranked:

```bash
crexx-rag \
  --library ./architecture.cprag \
  --access read \
  query search "Which components access customer profile data?"
```

Useful options include source/time filters, maximum passages, maximum graph
hops, profile, and `--mode auto|lexical|hybrid`. `auto` uses vectors only when a
compatible active index and permitted embedding route are available.

For diagnostics, request the trace:

```bash
crexx-rag --library ./architecture.cprag \
  query trace "Which components access customer profile data?"
```

The trace shows focused query variants, channel ranks, aliases, directed graph
paths, fusion terms, exclusions, and context-budget selection. It must never be
necessary for an ordinary answer.

## Get Evidence For An LLM

Phase 5 implements the retrieval/evidence algorithms behind this target
experience. Before the Phase-6 CLI and MCP adapters exist, Level-G callers use
`planquery`, `embedmissing`, `buildexactvectorgeneration`, `retrieveevidence`,
`encodeevidence`, `encodeanswercontext`, and `resolvecitation` directly. The
[Phase-5 tutorial](tutorials/phase-5-retrieval.md) is the executable current
workflow; the commands below remain the approved Phase-6 surface.

The primary agent-facing command is:

```bash
crexx-rag \
  --library ./architecture.cprag \
  --format json \
  --access read \
  query evidence "Which components access customer profile data, and why?"
```

It returns:

- focused query plan;
- cited source passages with revision/span, provenance, confidence, and time;
- accepted directed claims with their support citations;
- ambiguity and conflicts;
- graph/vector leads labelled as leads;
- evidence gaps; and
- answer guidance.

The command does not need to generate prose. An external agent and an optional
configured answer model consume the same packet.

To use the configured optional answerer while retaining the identical packet:

```bash
crexx-rag --library ./architecture.cprag --access read --format json \
  query answer "Which components access customer profile data, and why?"
```

The result contains both the evidence and generated prose. The prose never
changes the library.

Phase-5 evidence generation is provider-independent and does not require an
answer model. When an answer model is used, pass `crexx-rag.answer-context/1`
rather than untyped graph/vector lists. Stable citations bind the library,
source, immutable revision and UTF-8 byte span; a later source update does not
retarget an old citation. Hosted credentials remain symbolic `env:` references
and are resolved only inside an explicitly authorized call boundary.

## Run Bounded Background Improvement

First inspect what the library can improve:

```bash
crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --profile it_architecture_profile \
  --access plan \
  improve plan --budget overnight-small --output ./improve.plan.json
```

The plan might include missing embeddings, candidate deltas, high-value
unprocessed passages, unresolved endpoints, ambiguous aliases, weak claims,
changed prompt/profile versions, or coverage gaps. It reports provider/privacy
routes and hard budgets.

Apply only after review:

```bash
crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --profile it_architecture_profile \
  --access curate \
  improve apply --plan ./improve.plan.json --expect-digest <sha256>
```

With a supervised `worker run --follow`, the job can continue after the client
terminal exits. Job control requires the separate control capability:

```bash
crexx-rag --library ./architecture.cprag --access control job pause <job-id>
crexx-rag --library ./architecture.cprag --access control job resume <job-id>
crexx-rag --library ./architecture.cprag --access control job cancel <job-id>
```

Cancellation is cooperative and preserves completed work and audit history.
Expired worker leases are recoverable.

## Review Ambiguity And Proposed Facts

List review work with cursor pagination:

```bash
crexx-rag --library ./architecture.cprag --access plan \
  review list --state pending --limit 20

crexx-rag --library ./architecture.cprag --access plan \
  review show <review-id>
```

The review view includes supporting passages, existing canonical concepts,
conflicts, the proposal, validator findings, model/profile provenance, and the
effect of each decision. Preview a decision before applying it:

```bash
crexx-rag --library ./architecture.cprag --access plan \
  review decide <review-id> --decision accept --dry-run

crexx-rag --library ./architecture.cprag --access curate \
  review decide <review-id> --decision accept
```

Unresolved ambiguity is a valid durable state. Never choose a canonical target
merely to clear a queue.

## Import External Extraction Proposals

An outside analyzer may propose concepts or relationships, but it may not write
the graph directly. Normalize its output into the public proposal schema with
stable evidence citations, provider/model provenance, and input hashes, then
plan validation:

```bash
crexx-rag --library ./architecture.cprag --access plan \
  proposal plan --input ./external-proposals.ndjson \
  --output ./proposals.plan.json
```

The plan reports accepted candidates, invalid evidence spans, unknown types or
endpoints, canonical conflicts, ambiguity, provider/privacy provenance, and the
review items it would create. Apply the immutable plan only with curation
authority:

```bash
crexx-rag --library ./architecture.cprag --access curate \
  proposal apply --plan ./proposals.plan.json --expect-digest <sha256>
```

Accepted proposals pass through the same idempotency, support, profile, and
claim-validation path as internal extraction. Rejected or uncertain proposals
remain review work; vector similarity or an external model's confidence is not
support by itself.

## Local And Hosted Provider Policy

Configure roles independently:

- use a stable embedding model for `embedding`;
- use deterministic rules or a cheap model for `advisory`;
- use a stronger model only for the ranked `extractor` queue;
- leave `answerer` disabled if the calling LLM will compose the answer.

Local and hosted models obey the same record contract. Switching provider does
not change validation or claim promotion. There is no implicit fallback across
the local/hosted boundary.

Before a hosted call, the plan must show the source privacy class, provider,
model, estimated volume, and cost when available. A denied route makes zero
outbound requests.

## Use From cREXX Line Commands

`ADDRESS RAG` exposes the same application facade for cREXX programs:

```text
LIBRARY OPEN / LIBRARY STATUS / LIBRARY VERIFY / LIBRARY CLOSE
QUERY SEARCH / QUERY EVIDENCE / QUERY ANSWER / QUERY TRACE
QUERY PATH / QUERY TIMELINE
INGEST PLAN / INGEST APPLY
IMPROVE PLAN / IMPROVE APPLY
PROPOSAL PLAN / PROPOSAL APPLY
JOB STATUS / JOB EVENTS / JOB PAUSE / JOB RESUME / JOB CANCEL
REVIEW LIST / REVIEW SHOW / REVIEW DECIDE
```

The final examples will use typed host-variable anchors and the CREXX-safe
argv/stem command form. Arbitrary source text and prompts must never be
interpolated into a shell command. `ADDRESS RAG` must return the same typed
records and errors as the Level G `raglibrary` API.

## Use From An LLM Agent

Start MCP read-only for question answering:

```bash
crexx-rag \
  --library ./architecture.cprag \
  --config architecture_local_config \
  --profile it_architecture_profile \
  --access read \
  serve mcp
```

Read-only mode exposes status, sources, search, evidence/optional answer,
trace/path/timeline, and job status/events. A separately enabled non-mutating plan
capability may expose ingestion, improvement, and proposal plans plus review
listing. It does not advertise apply/decision/job-control mutations, raw SQL, or
raw graph edits.

Use [`../prompts/crexx-rag-agent-AGENTS.md`](../prompts/crexx-rag-agent-AGENTS.md)
as the generic agent instruction file. Grant write capability only for an
explicit ingestion/curation task, and still require plan before apply.

## Backup, Share, And Restore

Create a consistent snapshot while the library is live:

```bash
crexx-rag --library ./architecture.cprag --access admin \
  library backup --output ./architecture-backup.cprag
```

Backup pins one database semantic/vector generation, copies the matching
immutable sidecars, builds a snapshot manifest from the backed-up database, and
validates the assembled folder. Vector sidecars are included only when
consistent; they can always be rebuilt.

Restore into a fresh target by default:

```bash
crexx-rag --access admin library restore \
  --input ./architecture-backup.cprag \
  --output ./architecture-restored.cprag

crexx-rag --library ./architecture-restored.cprag --access diagnose \
  library verify
```

Share the validated bundle folder. Never copy a database and sidecar from an
uncoordinated live write by hand.

## Interpreting Evidence

| Evidence kind | What it supports |
| --- | --- |
| Narrative passage | Direct source statement, subject to source confidence and stance |
| Quoted authority | What the source reports another authority said; not automatically project truth |
| Accepted typed claim | Relationship validated and linked to active support passages |
| Mention | A concept appears in a passage; no relationship implied |
| Graph lead | A path worth investigating; not a claim by itself |
| Vector lead | Semantic proximity worth investigating; never a fact |
| Ambiguity/conflict | Multiple meanings or incompatible support remain unresolved |
| Gap | The retrieval process did not find adequate support |

Citations use the stable library/source/revision identity and a normalized
UTF-8 byte span, for example
`cprag://<library-id>/<source-id>@<revision-id>#b<start>-<end>`, not a mutable
URI or volatile row id. If a passage is retracted, the citation resolver reports
its historical revision rather than silently pointing somewhere else.

## Troubleshooting Principles

- Run `doctor` for installation/provider problems and `library verify` for
  bundle problems.
- Use public status and trace commands; do not poll SQLite directly during
  active work.
- If a job stops, inspect its state and lease before starting another worker.
- A model parse failure should remain retryable. Do not reinterpret it as an
  ambiguity decision.
- A stale vector index should cause a visible lexical fallback, not an empty
  result or an automatic fact change.
- If evidence is weak, improve or add sources; do not promote graph leads to
  make the answer look complete.
- Never expose credentials in a diagnostic bundle.

## Current-To-Target Map

| Current proof-of-concept surface | Target surface |
| --- | --- |
| `scripts/run_use_case.sh initial-load` | `ingest plan/apply` |
| `add-documents` wrapper | same incremental `ingest plan/apply` |
| `run_background_improvement.sh` | durable `improve plan/apply` job |
| flat `queue-status` and work commands | `job status/events` and `review` |
| shell-held background process | supervised `worker run --once|--follow` with leases/fencing |
| `library_search` | `knowledge_search` / `query search` |
| `library_answer_evidence` | versioned `knowledge_evidence` / `query evidence` |
| `external-extraction-review` low-level queue | normalized `proposal plan/apply` then review |
| raw MCP write tools | capability-gated workflow plan/apply only |
| RAG-specific `rx_rag` plugin | cREXX application over generic `rxsqlite` and provider facilities |

The current commands remain authoritative until their replacement phase is
accepted. Migration documentation must always state which surface is shipped
and which is proposed.
