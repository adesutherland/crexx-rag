# Durable autonomous maintenance

Status: the committed `e369449` baseline passed 24 tests, but its concurrent
Scottish run failed and was stopped before completing 5,000 items. That pass
did not establish unattended reliability. Publication and request-contract
repairs are under qualification; crash recovery across all work kinds remains
open. See the [use-case coverage review](reliability-coverage-review.md) for
evidence and release blockers. No nightly schedule or repaired installation has
been enabled.

## Operating cycle

A maintenance window resumes durable questions and discovers aliases, pending
claim conflicts, analysis leads, query gaps, sparse concepts, chunk improvement
opportunities and missing embedding links. Repairs and unresolved identity
questions rank ahead of enrichment; waiting questions gain priority with age.
The census keeps a cursor for each category, so a small batch or an already
processed prefix does not hide later work.

The same public `maintain plan`, `maintain apply`, `worker start`,
`maintain status` and `maintain inspect` operations serve CLI, JSON and MCP.
Guided `maintain --yes --workers N` composes them and continues the census even
when its first page contains no provider work. There is one active window per
library. The next window uses a new reviewed plan and the unfinished backlog;
reapplying the identical plan returns its original window rather than granting
another budget.

All child tasks share the window's durable job and call, token, cost, time,
item and subscription-turn limits. `maintenance.batch_items` bounds each census
page and dispatch wave. `budget.item_limit` bounds dispatched items across the
whole window. Calls are reserved across independent worker processes, and
admission checks the remaining deadline again immediately before transport.
The window stops accepting calls early enough for their configured timeout.
An interrupted process cannot publish through an expired lease or fence.

## Modes and runtime configuration

| Mode | Behavior |
| --- | --- |
| `automatic` | Ask the configured extractor route for typed decisions and apply allowed actions after normal validation. Policy exceptions become reviews. |
| `supervised` | Ask for typed decisions, then require `review decide ... --decision accept --apply` for proposed changes. |
| `manual` | Collect inspectable questions without provider calls. A later automatic or supervised window can resume those unattempted questions. Operators can also use the existing explicit proposal workflow. |
| `reviewed` | Compatibility default: the earlier ranked maintenance batch and mandatory structural-review route. |

Example policy for an externally scheduled five-hour window:

```ini
maintenance.mode = automatic
maintenance.window_seconds = 18000
maintenance.batch_items = 100
maintenance.maximum_impact = 10000
maintenance.maximum_attempts = 3
maintenance.retry_seconds = 300
maintenance.maximum_evidence_bytes = 65536
maintenance.automatic_actions = reuse distinct split merge synonym type-correction retire restore move retract qualify retain investigate
maintenance.resolution_prompt = Resolve the question from the supplied evidence. Distinguish identity, time, scope and viewpoint. Cite contiguous quotations and preserve uncertainty.
budget.minutes = 300
worker.guided_deadline_seconds = 0
```

Keep explicit call, item, token, monetary or subscription budgets in the same
configuration; five hours does not grant unlimited spending. The effective time
window is the smaller of `maintenance.window_seconds` and `budget.minutes`.
A zero guided deadline uses the configured budget duration. Provider timeouts
and role input/output limits must fit the intended window.

These settings require no compilation. Edit the file, inspect `config diff`,
and apply an exact `config plan` before planning new work against an existing
library. The reviewed window freezes the effective policy, provider routes,
privacy classification and charging basis. Configuration changes never imply
corpus reingestion. Extraction/profile and resolution-prompt identities govern
which interpretation a task requests; changing only a spending limit does not
reset previously resolved or unresolved questions.

## Evidence and decisions

Resolution packets contain a specific question, subject, source-scoped concept
catalogue, applicable successors, and independently addressable source spans.
The configured provider returns an exact structured response: an action,
selected identifiers, rationale, quotations, optional successors, time/scope
qualifications and an optional follow-up question. The product grounds quotations
in original chunk bytes and rejects identifiers outside the permitted packet.
Claim/conflict dispositions must cite all affected supports. A changed evidence
fingerprint supersedes a stale answer instead of applying it. A post-call stale
answer is retained without publishing a semantic generation.

Unambiguous typed catalogue aliases are reused deterministically. Ambiguous
identities become questions; shared spelling alone does not justify a merge.
A `reuse` answer selects an existing candidate. A `distinct` answer retains a
separate meaning and explicit shared-alias ambiguity. Identity resolution queues
a follow-up extraction task so skipped connections can be reconsidered.

Other decisions include split, merge, synonym, type correction, retirement,
restoration, connection movement, retraction, claim qualification, retention,
further investigation and explicit uncertainty. `unresolved` is a valid result.
It retains the evidence and explanation without forcing a choice. Follow-up
questions are durable and deduplicated; unchanged evidence and interpretation
do not create an endless paid reconsideration loop. New source evidence,
concept state or an edited resolution prompt can create fresh work.

Malformed adapter output and product-invalid quotations remain failures. The
latter retain bounded, redacted diagnostic content; malformed or oversized raw
content can be omitted with its digest. The model cannot bypass type, span,
identity, privacy, budget, lease, lifecycle or impact validation.

## Split and merge workflows

A split creates successors and keeps the original concept as a migration
parent. A merge selects an existing supplied survivor and also retains the
parent until migration is complete. Both publish their initial change and
individual follow-up tasks atomically.

The full impact census covers aliases, mentions, individual claim supports,
linked notes, ambiguity candidates and conflicts. Each connection has its own
question and durable state. Movement must preserve the supported meaning and
relationship direction. A moved claim support requires a successor mention
inside that support span. The product rejects a self-relationship; it requires
an explicit supported disposition instead. Outstanding conflicts follow a
moved claim's new identity for fresh resolution.

Uncertain connections can remain on the migration parent. Later windows
re-census late-arriving connections. Retirement is admitted only when the
impact gate is empty; creating successors alone never completes a workflow.
Old concept versions, mentions, claims, supports and lineage remain stored.
Moved note links retain their previous parent, publication interval and any
source chunk/span in `maintenance_link_history`, available through workflow
inspection.
The current note-link projection and the append-only history serve different
purposes; a historical note-link report must use the retained history as well.

## Recovery and database preservation

Tasks, window policy, attempts, decisions and usage are authoritative SQLite
records. A pause/deadline cancels unstarted job items while retaining their
questions for a subsequent window. Paid retries have a configured cap and
backoff. Recovered unstarted dispatches do not consume the paid-attempt cap.
A **resolution** response durably stored with settlement can be reused in
another lease or window, even when its last permitted paid attempt was used.
Usage remains owned by the original provider run. Codex extraction has a
separate completed-turn recovery path. Gemini extraction and embedding results
do not yet share resolution's durable result cache; a crash after usage
settlement can require another provider call. No path guarantees recovery of a
network response lost before durable receipt. These differences must be closed
or explicitly handled before unattended qualification.

Graph maintenance retains source records and embedding BLOBs. An eligible
existing vector index remains usable across graph-only generations. Missing
links can reuse matching SQLite vectors with zero provider calls, publishing
new membership without changing historical generations. A sidecar rebuild
reads SQLite vectors rather than requesting new embeddings. A genuinely
incompatible embedding profile needs new derived vectors while preserving the
old representation and the rest of the database.

## Operator inspection and qualification

```sh
crexxrag maintain status --limit 25
crexxrag maintain status --limit 25 --cursor TASK_ID
crexxrag maintain inspect TASK_ID
crexxrag maintain inspect WORKFLOW_ID
crexxrag maintain inspect DECISION_ID
crexxrag review list
crexxrag review decide REVIEW_ID --decision accept --apply
```

Status reports the selected window, calls and recorded cost, plus the global
durable backlog. Task pages use their returned cursor. Inspection exposes
questions, evidence, decision provenance and workflow membership. A window can
be complete while unresolved questions or operator exceptions remain; inspect
the backlog counts as well as the window state.

Offline fixtures cover full split/merge connection handling, conflicts and
qualification, typed alias reuse/distinction, stale evidence, crash recovery,
shared budget/deadline behavior, manual collection and supervised review. Native
Gemini loopback tests exercise valid, malformed and product-rejected responses.
The Scottish scratch test separately checks schema migration, exact source/vector
preservation, sidecar reconstruction and retrieval from an existing query vector.
These checks do not establish the semantic accuracy of hosted whole-corpus work.
Nightly recurrence remains the responsibility of an external scheduler and is
not enabled by configuring or running a window.
