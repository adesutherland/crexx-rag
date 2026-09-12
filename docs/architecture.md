# Architecture

## Shape

`crexxrag` is a Level-G cREXX application packaged as one native executable.
The CLI, JSON/NDJSON, `ADDRESS RAG`, and MCP adapters translate into the same
typed command request and result vocabulary.

```text
human CLI / JSON / MCP / ADDRESS RAG
                 |
          ragproduct dispatcher
                 |
 config + policy + plans + jobs + retrieval + evidence
                 |
       cREXX SQL repositories and orchestration
                 |
       installed CREXX rxsqlite provider
                 |
     library.sqlite + immutable .rxvec sidecars
```

There is no second product implementation or compatibility bridge.

The [maintenance and ownership review](maintenance-refactoring-review-20260912.md)
distinguishes current owners from proposed extractions, prioritising shared
claim rules and domain prompt/contracts. Each proposal requires regression
characterization before implementation; a directory or executable split is
not itself an acceptance criterion.

## Claim-policy ownership

`ragclaimrules.effectiveclaimpolicy(profile, policy_version)` is the single
factory for the effective profile vocabulary and versioned stance weights.
Workers in `ragprocess`, public proposal commands and review acceptance compose
it. The legacy `ragproposalio.profileclaimpolicy` entry point delegates without
adding rules. `ragproposalio` owns bounded proposal decoding; `ragclaims` owns
typed validation, support decisions and transactional graph publication.
Dependencies run from orchestration through the factory to profile and claim
types, never from the validator back to process or command code.

Changing claim policy starts with `regression_claim_policy` and the ingestion,
external-review and grounding controls. See the
[staged delivery record](maintenance-refactoring-delivery.md) for qualification
and subsequent owners. Operator settings still enter through `crexxrag.conf`.

## Prompt and response-contract ownership

| Owner | Authoritative responsibility and consumers |
| --- | --- |
| `ragpromptdefaults` | Compatibility role objectives for older config formats; consumed by `ragconfigfile`. Explicit operator objectives remain config data. |
| `ragextractioncontract` | Effective extraction messages, profile-shaped schema and optional assessment extension; consumed by `ragapplicationprovider` and prompt inspection. |
| `ragresolutioncontract` | Effective resolution messages, selected-span excerpts, schema and subject/workflow action vocabulary. Both `ragapplicationprovider` and `ragbacklog` validation consume this vocabulary. |
| `ragquotationcontract` | Shared literal-quotation instructions and bounded correction feedback; normal `raggrounding` validation remains independent and authoritative. |
| `raganswercontract` / `ragreportcontract` | Answer and advisory-report message/schema pairs; consumed by `ragqueryprovider`. |
| `ragpromptinspection` | Public projection of those same builders, including exact system/schema hashes; no provider or library access. |

`ragapplicationprovider` retains execution, input-envelope checks, receipt
recovery, secret redaction and extraction decoding/validation. `ragbacklog`
retains task evidence validation and transactional lifecycle application.
`ragassessment` and `ragenrich` retain their specialized provenance contracts.
Domain contract modules do not import the product dispatcher or provider
execution adapters. The optional extraction schema extension uses SQLite JSON
functions but changes no persistent data.

Use `config prompt` to find the effective prompt, not just its configurable
objective. Runtime source context and correction history remain request data.
Golden wire checks protect the original text and schemas during extraction;
they are not a quality score or authority to accept an altered prompt. Any
later behavior change must update its domain contract and review canonical
identity, validation and retained-work compatibility together. Existing durable
identities are preserved by this refactor.

## Effective defaults and policy-file ownership

| Owner | Responsibility and callers |
| --- | --- |
| `ragworkerdefaults` | Default, minimum and maximum for worker poll, guided deadline, replacement count, replacement backoff and rolling window. Typed `ragworkerpolicy`, file parsing and canonical default omission consume the same specification. |
| `ragconfigfile` | Bounded declarative parsing, relative paths and complete typed configuration construction. It owns no publication or command access. |
| `ragpolicyfile` | `config show/set/replace`, whole-candidate and referenced-profile validation, prompt-source pair edits, selected-file registry loading and `refreshpolicyrequest` for file-bound transports. CLI, dispatcher, MCP and ADDRESS compose it. |
| `ragpolicypublication` | Bounded file reads/hashes, serialized edit ownership, verified sibling staging and rename publication. It accepts already validated candidate bytes and opens only an adjacent coordination database. |
| `ragconfiguration` | Existing immutable library configuration history and reviewed prospective/operational transition; file publication never rewrites retained job snapshots. |

Worker defaults stay byte-compatible: poll 100 ms (10–60000), guided deadline
0 seconds (0–604800), two replacements (0–10), 5000 ms backoff (10–60000), and a
3600-second rolling window (1–86400). Explicit invalid typed values are rejected,
not converted to defaults. The wider budget/provider/retrieval default families
remain in their existing owners; this stage consolidates one bounded family.

The CLI routes file administration before eager policy loading, allowing invalid
policy repair without a library. File-bound MCP and ADDRESS retain the selected path
and use the same policy refresh helper after argument validation on every
ordinary product call. There is no stale-cache fallback. `ragcommand` owns the
shared request rebinding; the catalogue owns the new commands' schema and access.
Legacy typed MCP callers without a file retain their supplied registry behavior.
ADDRESS `LIBRARY OPEN` still validates its initial binding; its function interface
can inspect or repair an explicitly supplied policy without an open session.

Publication uses a stable adjacent SQLite file and `BEGIN EXCLUSIVE` with no
busy wait; a competing editor receives conflict status and must inspect again.
A process crash releases the native SQLite lock. The target hash is checked under
that lock and again after staged bytes are verified; rename is the publication
point. Success after rename remains success even if coordination cleanup fails,
with a diagnostic and the new hash. The file contains no second policy and is
never unlinked to recover a lock. Filesystem metadata, external-writer races and
power-loss guarantees have explicit [integration limits](integration-issues.md#policy-file-publication-metadata-and-durability).
Custom metadata preservation and policy-file power-loss durability are accepted
limitations by the 12 September decision; SQLite and receipt-recovery guarantees
remain unchanged.

## Public result and lexical boundaries

`ragresultpages` constructs repository result rows, explicit page metadata and
job-plan text pages. `ragrepository` owns the SQL projections and bounded plan
slice reads; `ragproduct` composes access checks and commands. `ragcommand`
validates at most 100 data records plus one bounded final cursor record, rather
than counting the cursor against the advertised data limit. Large plans no
longer enter a generic list value: summaries state completeness and link to
`job.plan`. SQLite supplies a bounded character slice on each detail read.

`ragquery` owns lexical query preparation. It preserves non-ASCII text,
including combining marks, for the installed Unicode tokenizer, and keeps
ASCII FTS syntax out of generated terms. Index normalization remains SQLite's
responsibility; evidence text and citation byte offsets are not rewritten.
See [public results and lexical repair](public-result-lexical-repair.md).

## Durable ingestion

1. The controller discovers configured source files and creates a canonical,
   digest-bound zero-write plan.
2. Apply revalidates the source set, configuration snapshot, profile, provider
   route, and budget before publishing source/chunk state and durable work.
3. `worker start` launches independent `crexxrag worker run` processes. Every
   process starts its own CREXX VM, loads CREXX's installed `rxsqlite` provider,
   and opens its own WAL connection.
4. A worker reserves provider usage, validates the provider result, promotes a
   supported claim or creates a review, and settles the reservation.
5. Embeddings are recorded with provider/model/dimension/envelope identity and
   published as a generation-specific `.rxvec` sidecar.

SQLite rows are the process communication mechanism. Leases, fencing,
idempotency keys, attempts, provider runs, events, heartbeats, and requested
worker state make recovery explicit.

The 12 September architecture decision retains processes for independent worker
replacement and native-failure containment. Attached threads are an optional
QE-04 comparison alongside the future model bridge, with measured model lifetime,
memory, throughput and cancellation. They do not remove durable recovery rules
or permit SQLite handles to cross VM owners. See the
[execution decision and focused evidence](integration-issues.md#worker-execution-architecture).

`ragadmission` classifies job allowance from measured usage, live reservations,
uncertain usage and the requested call. It examines all dimensions before
returning admitted, waiting, exhausted, uncertain or invalid. Consumed and
uncertain allowance take precedence over temporary pressure. `ragwork` reads
the ledger and creates the reservation in the same writer transaction, and
owns the fenced item transition. Ordinary ingestion and active maintenance
both queue an uncalled capacity waiter without consuming a failed attempt;
closed maintenance windows keep their existing backlog policy. Real exhaustion
and uncertain outcomes retain their existing stopping/reconciliation paths.
The module does not own settlement, worker replacement or provider rate limits.
`job status` reports the latest queued deferral in `waiting_reason`, separately
from `last_error`; it clears when that item is reclaimed or stops waiting.

`raglifecycle` owns shared terminal-state projection, retry eligibility and the
schema-14 retry-request ledger. A request targets one task or ordinary item,
is deduplicated across process restarts, and records a pending/completed state
and disposition. Its creation and the owner's reconsideration run in one
SQLite writer transaction. `ragwork` retains leases, fences and same-job
execution; `ragbacklog` retains policy, windows and task dispatch. Closing a
window no longer hides dead letters behind an unconditional completed job.
A request cannot reopen a closed window, reset attempts, renew an allowance,
resume a pause/cancellation or erase an uncertain provider intent. See
[lifecycle recovery](lifecycle-recovery.md) for the contract and qualification.

`ragreceipts` owns request intent, immutable responses, stored external identity
and exact-outcome reconciliation. `ragusage` owns incurred usage, settlement,
admission release, expired reservations and unknown-usage allowance. Both use
`ragworktypes` value contracts and the shared active-fence predicate in
`raglifecycle`, without importing the worker implementation. `ragwork` composes
these services with claims and fenced publication; its existing function entry
points remain delegates. A cREXX caller using worker value types imports
`ragworktypes` explicitly. No public command or stored schema changes.

Receipt persistence failure is an uncertainty hold, not a content rejection.
Known usage is retained on the original provider run, while independently saved
Codex output remains intact for `job reconcile`. Without a recoverable response,
restarting or requesting retry cannot submit that item again. Expired reservation
capacity is released, but unaccounted allowance remains conservative. Healthy
peers can run within the remaining reviewed limits. See
[receipt recovery](receipt-recovery.md) for the fault tests and boundaries.

`ragsupervision` owns rolling replacement eligibility, durable reservations and
pool status. `ragprocess` observes child completion, launches eligible replacements
and continues supervising healthy peers while missing slots wait. The default
allowance is two replacements per rolling hour, configurable independently of
task attempts. Old events age out of active capacity but remain in `job_events`;
controller restart and runtime pruning cannot erase them. The controller
reconsiders even a completely empty pool. Explicit poll limits also bound parked
slots; pause, cancellation and the original maintenance cutoff remain binding.

`ragenvironment` owns provider/model cooldowns, shared admission and the single
recovery probe. Both called retryable failures and safely uncalled unhealthy
preflights can establish backoff. Uncalled deferrals consume no failed-task or
provider-call allowance. When all eligible routes are cooling, replacement
waits; an empty pool admits one replacement to probe, then restores other slots
when provider health recovers. Generic process exits are not outage evidence.
Usage settlement composes the environment transition inside its original writer
transaction. These modules have no dependency on HTTP versus a future native
model bridge. See [supervision recovery](supervision-recovery.md) for policy,
coverage and qualification boundaries.

`ragapplicationprovider` distinguishes failed preflight from an uncertain
submitted turn and preserves successful output across admission-release failure.
A failed Codex stream gets one bounded exact-turn inspection through a fresh
transport. Completed output returns through normal validation; a confirmed
interruption without output permits ordinary bounded retry. Unknown outcomes
hold only their affected items. When only held work remains, the drained job
pauses for public reconciliation and reports vector publication as pending.

Codex intent is durable before turn submission. Public `job reconcile` binds
the original attempt, input hash, snapshot, provider run, thread and turn to a
fresh observation. Inspect reads App Server history without cancellation or
resumption. Apply checks the digest again and atomically records the response,
ordinary settlement receipt, observation and item disposition. The job remains
paused. A completed response is untrusted input for the existing validation and
publication path; confirmed interruption without a final answer allows a retry
only within the original limits. Missing or ambiguous history remains held.
Unknown usage is explicitly a lower bound; admission conservatively retains the
unobserved part of the original token, time, cost and call reservation. It never reports those
estimates as measured provider usage.

Account preflight, thread/turn submission and answer reads share the configured
operation timeout, capped by the remaining worker lease with cleanup time.
Unrelated notifications and partial lines cannot restart that deadline. Usage
notifications are persisted through the ordinary SQLite writer retry helper.
`job run` checks compatibility before claims, prunes only confirmed exited local
ownership or terminal records, and uses the existing controller. Controller
registration rejects overlapping controller groups atomically.

Extraction correction reports up to 16 citation problems from the bounded
response, including literal OCR labels and both relationship endpoints. There
is still only one paid correction. Uncalled capacity/preflight deferrals do not
consume it. Terminal content failures create ordinary chunk review tasks marked
`advanced-reasoning`; their question and immutable job events retain the source
job/item and rejected responses. Transport and storage failures do not create
reasoning tasks. No schema or native-provider changes support these controls.

CREXX owns the generic SQLite implementation, bundled SQLite build, dynamic
provider, native archive, session isolation, and typed API. This repository
imports `rxsqlite` and owns only the schema, repositories, orchestration, and
product policy. Linked execution discovers the provider from the installed
CREXX runtime; native packaging consumes CREXX's canonical provider archive
and metadata without a downstream SDK copy or system SQLite link.

Dead-letter replay does not reopen or rewrite its source job. It copies one or
all selected terminal dead letters into a new job, binds that job to the
current semantically compatible configuration snapshot and current budgets,
and retains job/item lineage. The new budget policy and all replay items are
committed atomically; historical reservations must fit the reviewed envelope. A recursive reconciliation view classifies each
immutable source root as actionable, replaying, or resolved from the state of
its descendants. Replay rejects active, completed or uncertain work in the
same replay family. `job retry` records a durable request; maintenance-linked
items delegate to the task owner and continue in a new reviewed window.
Ordinary items retain their original job policy. Read-only schema-13 task
inspection remains available; the ordinary write-open path upgrades additively.

Schema 13 adds provider/model cooldown state and an index for embedding attempt
history. Admission parks uncalled work without charging an attempt. Retry delays
use durable embedding calls; a shared cooldown admits one recovery probe before
restoring configured concurrency. An older in-flight success cannot clear a newer
cooldown. Embedding-only maintenance uses the existing plan/apply and fenced job
machinery, omitting cognitive census and dispatch. Busy batch checkpoints avoid
repeating the full census on each worker poll; chunk evidence skips the unused
catalogue projection.

Explicit vector reconciliation closes duplicate active membership intervals in a
new generation and audits covered queued embeddings as skipped. It preserves
paused jobs and unmatched provider intents. Public verification compares the FTS
projection using bidirectional set differences and cardinality, and diagnoses
duplicate active embedding membership.

## Evidence and claims

Sources, revisions, chunks, concepts, claims, and support use stable
content-derived identities. Claims are directional. Support binds a claim to a
specific active chunk and UTF-8 byte span. Contradiction and ambiguity remain
explicit records rather than being flattened into an answer.

Extraction providers return contiguous `evidence_quote` text, not byte counts.
Level-G cREXX finds the first exact occurrence within the chunk, then falls back
to full Unicode casefold matching. A boundary map converts the match back to
original UTF-8 bytes, including expanding folds such as `ß` to `ss`. A final deterministic pass collapses ASCII whitespace runs, allowing printed
line wraps to match spaces while mapping to the full original byte span.
Punctuation and Unicode normalization remain exact. Repeated quotations choose
the first occurrence; relationship endpoint labels are resolved inside that
relationship's supporting quotation. Missing quotations, missing endpoints,
invalid types and canonical identity conflicts remain validation failures.
Bounded, redacted product-rejected JSON is retained with failed provider runs
for diagnosis; oversized or malformed content is omitted with its digest.

Lexical, vector, and graph retrieval produce an evidence packet with stable
citations. Optional answer generation receives only the bounded evidence
context. A supported answer must return schema-valid citations already present
in that context. An explicitly insufficient answer returns no citations and is
rendered as a deterministic refusal, so irrelevant retrieval cannot become an
uncited generated claim or a false command failure.

The library report uses the same trust boundary. Its deterministic core reads
one published semantic generation and computes bounded corpus, catalogue,
graph, support-span and top-concept data in Level-G cREXX. Current vector,
maintenance, job and review state forms a separately digested operational
overlay. Optional advisory generation receives only that bounded packet and
representative source-span passages. Exact-schema and known-citation
validation occurs before a narrative is cached or displayed; advisory output
has no graph-mutation path.

## External maintenance agents

External maintenance agents use the same durable task evidence validator and
lifecycle engine as workers. Task resolver capability is separate from work
priority and status. Schema 12 records external action plans in an immutable
`maintenance_agent_actions` table; their self-reported actor/model attribution
does not masquerade as an internally measured provider run. Submission queues
a review, and acceptance revalidates the evidence and generation transactionally.
See [Agent integration](agent-integration.md#difficult-maintenance-tasks).

The external exploration surface distinguishes the current evidence inventory
from a task's frozen packet. Both are paged with generation checks; large source
citations are read in bounded Unicode-character pages while retaining their
original UTF-8 byte identities. A reviewed, complete refresh supersedes the old
task and freezes a larger per-task evidence envelope without changing global
policy, semantic generation or provider receipts. Ordinary workers skip tasks
flagged for advanced reasoning. Content-validation failures and explicit worker
assertions can flag a task; transport failure alone cannot.

Inline new-claim NDJSON and server-file proposals share one decoder and the
existing claim validator. Both produce canonical plans and mandatory reviews.
Task resolution does not itself add relationships absent from the graph; those
require separately grounded claim proposals. Neither exploration nor an LLM's
reasoning bypasses ownership, exact-plan, review or lifecycle retirement gates.

## Historic observability

The detailed history remains in the existing append-only publication, job,
item, attempt, provider-run, review and maintenance records. Provider runs
retain their purpose, provider/model, charging basis, token counts, duration,
and the cost estimate made when the call completed. Historic
observability adds bounded, immutable derived checkpoints; it does not replace
or compact those source facts.

A `library snapshot` request first generates the fixed-top-10 deterministic
report and evaluates `churn-matrix/2` against the newest retained point. The
matrix captures the first point, a semantic-generation change, a vector
publication/coverage change, a health-state transition, a job transition from
active to settled, a material work/review/dead-letter delta, or a changed
point that has reached maximum staleness. Critical semantic, vector, health and
settlement transitions bypass the 15-minute cooldown. Ordinary backlog churn
must reach the larger of 25 items or five percent; review/gap churn must reach
the larger of 10 items or five percent. The aggregate capture threshold is 50.

An exact semantic-and-operational duplicate is always suppressed. A
non-critical candidate inside the cooldown is suppressed, as is a candidate
below the threshold. Decisions are content-addressed and repeated equivalent
suppression checks update one decision's evaluation count instead of appending
unbounded rows. Snapshot rows themselves are immutable in use and unique by
the semantic/operational digest pair.

The snapshot stores the generation, active vector publication, configuration
and profile identities, deterministic report, current work backlog, historical
dead-letter total, review/gap counts, health-attention dimensions and any
matching validated narrative identity. A narrative created after an immutable
snapshot is associated by the same report and operational digests rather than
rewriting the point. `library trend` reads a bounded chronological window and
computes signed deltas without a provider call. One point is explicitly
`baseline-only`; direction becomes available only from the second point.

Guided ingestion and maintenance request a snapshot after their reported
terminal boundary. Their request may be captured or audited as suppressed by
the same matrix. Canonical machine workflows call `library snapshot` explicitly
after ingestion publication, maintenance, vector publication, replay,
reconciliation, migration or backup. Provider calls and individual work items
do not each create a snapshot.

## Providers

The provider factory selects by configured `kind`:

- `gemini`: hosted structured generation and embedding generation;
- `codex`: structured generation through a worker-owned Codex App Server child
  process and managed ChatGPT OAuth;
- `openai-compatible`: local llama.cpp generation or embedding endpoints;
- `openai`: hosted OpenAI-compatible API route when explicitly configured.

Every route declares local/hosted privacy and a charging basis. Codex is hosted
even though the client is a local process. Subscription allowance is not
reported as zero monetary API cost; it has its own turn/token/remaining-
allowance ceilings.

Codex extraction runs in an empty working directory with non-interactive,
restricted settings and an exact output schema. External thread/turn identity
is stored with `provider_runs` so a crash can distinguish completed work from a
real retry.

Before an HTTP provider call, workers acquire a SQLite-backed admission scoped
by provider and model. The admission transaction accounts for requests in the
last 60 seconds, reserved tokens in that window and currently leased calls, so
independent worker processes share one limit. Active leases expire after the
call timeout plus a recovery margin. A denial or timeout happens before the
adapter is invoked and therefore creates no `provider_runs` row.

Direct provider operations retry retryable connection, timeout, 408, 429 and
5xx outcomes up to the configured attempt ceiling. Delay is exponential from
the configured initial value, incorporates integer-second `Retry-After`, adds
deterministic bounded jitter and never exceeds the configured maximum. Durable
worker items use one network attempt per fenced attempt and carry the advised
delay into the durable queue, ensuring every actual call remains separately
accounted.

Direct query embedding and answer calls are also inserted into
`provider_runs`, including transport failures and product-rejected outputs.
Preflight failures that never invoke an adapter remain uncounted. Query rows
carry `query-embedding` or `query-answer` purpose and the command returns their
durable run identities; provider content and questions are represented only by
a request hash, never copied into provider history.

Report-narrative calls follow the same accounting rule. Invalid structured or
product-rejected output is retained as failed/rejected provider history even
though it is never cached as a narrative.

## Configuration identity and change control

An effective configuration has a full hash plus separate semantic and
operational hashes. Source selection, provider/model/privacy routes, role
bindings, discovery rules and the selected profile are semantic. Budgets,
worker ceilings, provider timeouts/pacing/retry policy, vector-build policy,
retrieval/ranking and serialized-evidence ceilings, maintenance thresholds,
observation thresholds and schedules are operational. Profiles may be compiled defaults or strict bounded
data files; the interpreted canonical profile, not executable configuration,
defines its semantic identity. The library retains the current configuration
snapshot independently of the configuration that originally published each
semantic generation, so provenance is not rewritten when operating policy
changes.

`config check` and `config explain` validate and project the effective policy
without reading credential values. `config diff` classifies it as identical,
legacy identity upgrade, operational or prospective. Plan
freezes the source and target identities, classification, active-job count,
reason and the configured plan expiry into canonical JSON. Apply verifies the exact digest
and current state, requires active work to be drained, and appends an immutable
change event. Identity upgrades, operational changes and prospective changes
can use this path. A prospective change affects only newly planned work; it
does not publish a corpus generation, rewrite provenance or queue existing
chunks. Source ingestion keeps a stable algorithm identity and compares source
observations, so an unchanged corpus remains an exact no-op after provider,
prompt, route or configuration-schema changes.

Profile edits also apply prospectively, including chunking, vocabulary,
ranking, and prompt identities. Historical chunks and claims retain their
original snapshots and source spans. An unchanged observed source does not
get rechunked merely because a profile changed. Applying new interpretation
to old content is a separate, explicitly reviewed maintenance or migration
operation; it is never inferred from a configuration hash.

Changing ANN tuning rebuilds only the derived index from SQLite vectors.
Changing embedding model, dimensions or input representation calls for a new
compatible embedding set for the requested work. Old vector BLOBs, links and
publications remain stored. Neither operation invalidates source, graph or
citation evidence. Query compatibility checks may decline an incompatible
vector route; they do not classify the whole database as invalid.

## Schema and publication

Because no earlier product was released, the active database begins with one
initial schema migration and bundle format 1. Schema migration 4 adds the
deterministic report snapshot and validated narrative caches. Migration 5 adds
churn decisions and immutable historic observation points. Migration 6 adds
split configuration identity/current state, immutable configuration change
events, cross-process provider admissions and immutable replay lineage.
Migration 7 adds indexed FTS vocabulary term statistics and the read-only
dead-letter reconciliation view; canonical source, concept and claim ownership
remains unchanged. The ordered
migration/checksum mechanism is part of the format so every schema evolution
remains ordered and checksum-verified. There is no old schema importer.

Semantic generations are immutable once published. Vector generations are
separate rebuildable publications. Backup pins SQLite and sidecar identities;
verification checks schema, manifest, repositories, and published sidecars.
A graph-only generation can advertise the newest ancestral index for each
embedding profile when SQLite proves identical source-chunk and embedding-link
membership. The file retains its actual build generation and checksum; readers
validate against that identity, then resolve evidence in their current SQLite
snapshot. Changed membership or a non-ancestor index cannot pass this check.
Manifest projection, hybrid preflight, retrieval, reports, maintenance census
and backup use the same eligibility predicate. No schema migration is needed.

## Durable maintenance windows

Schema 10 adds independent task/census cursors, windows with immutable shared
budget policy, workflow parents, task-attempt mappings, typed decisions, alias
questions, settled-response recovery and note-link history. `ragbacklog` owns
these Level-G operations; `ragwork` executes them through the existing provider
admission and fenced publication path. The native CLI and machine surfaces use
the same operations. See [durable maintenance](autonomous-maintenance.md).

A maintenance plan resolves its relative duration, exact offset timestamp or
local overnight window to one immutable UTC deadline before the census. Its
canonical window policy retains the timing envelope and optional aggregate
provider-time cap; the existing `deadline_epoch` column is authoritative during
execution. New policies use `provider_time_budget_ms = 0` for no aggregate cap.
Policies without that field retain the historic `window_seconds` aggregate
interpretation, preserving already reviewed work. No schema migration is needed.

Window closure stops admission, while already admitted calls may still settle.
Workers reconcile terminal task outcomes after settlement even on their last
item. A later checkpoint also repairs closed-window task status without
reopening the window, moving its deadline or dispatching further work.

Evidence validation and generation staging share an IMMEDIATE transaction.
Stale answers retain their provenance without publishing a generation. Cached
embedding relinking stages a new membership generation rather than rewriting
a historical snapshot. Conflict questions remain pending when their supported
claim moves. Source bytes, vector BLOBs and existing publication history remain
under the original SQLite authority.

## Claim time and source provenance

Schema 11 adds generation-versioned `source_descriptions`, `source_relations`
and `support_descriptions`, owned by Level-G `ragprovenance`. `ragperiod` owns
canonical historical meaning; `ragassessment` validates grounded field values
for the shared provider contract. `ragenrich` composes these with the existing
maintenance worklist, receipt, review and publication paths for explicitly
requested experimental assessment. Normal ingestion, improvement and maintenance
use ordinary extraction; they do not enrol each support into assessment.
Document dates are recorded once per source revision and resolved through chunk
and citation links. Source-only metadata queues no provider work and never
changes embedding inputs. Retrieval carries per-support
provenance and period compatibility through version 2 evidence and answer
context; graph traversal checks common period bounds across a filtered path.
See [time and provenance](time-and-provenance.md) for the public contracts.

### Report, observation, query and diagnostic services

`ragproduct.dispatchproduct` composes transport-neutral domain services. CLI,
ADDRESS and MCP all reach these same services; adapters do not issue domain SQL.

| Source owner | Public entry points | Authoritative responsibility and dependencies |
| --- | --- | --- |
| `ragreportservice` | `libraryreport`, `reportoperationaldigest` | Report census, health/context, citation-validated narrative cache and report SQL. Uses configuration, repository and direct-call/provider services. |
| `ragobservationservice` | `librarysnapshot`, `librarytrend` | Observation policy application, immutable snapshots and deltas. Calls the report service directly; owns observation SQL. |
| `ragqueryservice` | `querycommand`, `citationshow` | Query/citation argument semantics, retrieval composition, sidecar checks and answer validation. Uses retrieval/evidence, configuration and provider policy owners. |
| `ragdirectcalls` | `persistdirectproviderrun`, `recorddirectproviderrun`, `directproviderrecord` | Existing direct query/report call history and usage projection. Worker reservations/receipts remain in `ragusage`/`ragreceipts`. |
| `ragoperationsquery` | `readtaskpage`, `operatordiagnostics`, `jobstatuscommand`, `jobeventscommand`, `jobplancommand`, `taskinventorycommand` | Job status/events/plans, task evidence and bounded task/workflow/item/attempt reads. Consumes read interfaces of job/backlog/supervision owners; makes no provider calls or state transitions. |
| `ragcommandutil` | `commandhasaccess`, `commandoptions`, `commandworkeroptions`, `commandoption`, `commandid`, result/error helpers | Shared service argument/access/error conventions. Domain services retain semantic validation. |
| `ragsqlsupport` | `sqlreadtext`, `sqlreadint`, `sqlquote`, `sqliteerrordetail` | Small scalar/error helpers only. Transactions and SQL statements belong to their domains. |

Existing owners also hold the shared rules consumed by these services:
`ragconfig.rolebinding/roleproviderconfig`,
`ragconfiguration.querysnapshotmatches`, `ragquerypolicy.queryprivacy`, and
`ragevidencejson.encodecitationarray/containscitation/evidencehascitation`.
Follow those owners when changing the related rule and review all consumers;
do not add a replacement copy to the dispatcher or a provider adapter.

The new diagnostic pages filter in SQL before their keyset cursor and limit,
using stable row identities. Job/workflow reads use one SQLite read snapshot.
They expose state, lineage and provider-run IDs while leaving raw retained
request/response content to its existing controlled inspection surface.

### Public command contract ownership

`surfaces/ragcommandcatalog.crexx` owns the canonical operation inventory and
MCP tool definitions: argument schemas, required fields, capabilities, library
requirements, positional forwarding and fixed command variants. It depends only
on primitive functions and JSON, so `ragcommand`, the CLI, MCP and access helpers
can use it without importing product services. `ragmcp` only handles JSON-RPC,
server bindings and result rendering. `ragcommand` owns typed requests/results
and CLI parsing. Guided CLI interactions remain in `crexxrag_cli`; domain
services own state-dependent argument checks, authorization and execution.

When adding a public operation, update its catalogue entry, owning service,
focused public-surface regression and user/agent documentation. Review the
captured metadata contract when changing an advertised schema. Do not add
parallel tool-name, required-argument or capability maps to an adapter.
