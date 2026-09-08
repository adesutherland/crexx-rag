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
its descendants. The earlier single-item same-job retry remains a compatibility
operation for an operator who deliberately wants that behavior.

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
