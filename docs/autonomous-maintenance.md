# Durable autonomous maintenance

Maintenance uses durable questions, bounded windows and reviewed policy. The
local reliability baseline includes publication, request-contract and
received-response recovery repairs. See the
[use-case coverage review](reliability-coverage-review.md) for dated candidate
evidence and qualification limits, and the [MCP trials](mcp-codex-trials.md) for
external-agent validation. Scheduling and the state of a particular live run
are operator concerns; this guide does not enable or resume a schedule.

## Operating cycle

A maintenance window resumes durable questions and discovers aliases, pending
claim conflicts, analysis leads, query gaps, sparse concepts, chunk improvement
opportunities and missing embedding links. Repairs and unresolved identity
questions rank ahead of enrichment; waiting questions gain priority with age.
The census keeps a cursor for each category, so a small batch or an already
processed prefix does not hide later work.

Query-gap observations preserve the originating normalized question separately
from the diagnostic warning. Maintenance searches using the question and passes
both fields to the resolution provider. A generic ambiguity or missing-claim
warning is never substituted as the search subject. Existing observations already
contain this question, so the corrected lookup needs no schema or corpus rewrite.
Changed evidence supersedes waiting stale interpretations under the normal
fingerprint rules; unchanged corrected tasks remain deduplicated.

Open gaps are maintenance inputs, not automatically operator assignments. The
configured occurrence threshold controls eligibility. Maintenance can settle a
supported investigation, preserve uncertainty, or create a focused follow-up;
policy exceptions become reviews. Missing corpus evidence need not imply a
repairable defect, and answering a later query does not itself close an earlier
gap. No maintenance work occurs while its workers remain stopped.

The same public `maintain plan`, `maintain apply`, `worker start`,
`maintain status` and `maintain inspect` operations serve CLI, JSON and MCP.
Guided `maintain --yes --workers N` composes them and continues the census even
when its first page contains no provider work. There is one active window per
library. The next window uses a new reviewed plan and the unfinished backlog;
reapplying the identical plan returns its original window rather than granting
another budget.

All child tasks share the window's durable job and call, token, cost,
item and subscription-turn limits. Elapsed window time is independent of the
sum of provider-call durations across workers. `maintenance.batch_items` bounds
each census page and dispatch wave. `budget.item_limit` bounds dispatched items across the
whole window. Calls are reserved across independent worker processes, and
admission checks the remaining deadline again immediately before transport.
The window stops accepting calls early enough for their configured timeout
and a five-second cleanup allowance. Admission rechecks this before transport,
including after waiting for provider capacity. A call which cannot fit is not
started; this can leave unused time at the end of the window.
An interrupted process cannot publish through an expired lease or fence.

## Handoff for difficult questions

See [work tasks, prompts, models and completion](work-tasks-and-escalation.md)
for the complete current vocabulary and diagrams. Escalation is a capability
flag, not the `review` state. The requested final-pass model/prompt selection
and terminal no-change/conditional-deferral rules are recorded there as design
intent; the current external handoff below remains the implemented route.

Resolver capability is separate from task priority and work state. A worker can
assert that a task needs `advanced-reasoning`; two resolution-content validation
failures also flag the task. Ordinary workers skip flagged tasks. Transport or
storage failures alone do not imply that a stronger model would help.

An external agent uses `crexxrag-resolve` to discover the task, inspect its
history, page original evidence and prepare an exact correction plan. Submission
requires curation authority and creates a mandatory review. Acceptance uses the
same evidence validation and lifecycle engine as ordinary maintenance. Splits
and merges still require connection work before the parent can be retired.

If the stored evidence is incomplete, a reviewed refresh can create a complete
successor packet within per-task bounds, preserving the old task and question.
Exploring current sources does not silently extend stored evidence. New graph
relationships need separate source-grounded claim proposals; missing sources
and uncertainty can remain unresolved. See the [agent contract](agent-integration.md#difficult-maintenance-tasks)
for exact tools, input shapes, ownership rules and evidence limits.

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
maintenance.provider_time_minutes = 0
worker.guided_deadline_seconds = 0
```

Keep explicit call, item, token, monetary or subscription budgets in the same
configuration; five hours does not grant unlimited spending.
`maintenance.window_seconds` is the default elapsed duration, used when no
per-run timing option is supplied. `budget.minutes` retains its existing meaning
for ingestion, replay and compatibility `reviewed` maintenance; it does not cap
automatic, supervised or manual maintenance windows. A separate optional
`maintenance.provider_time_minutes` caps accumulated provider-call durations
and reservations across all workers. Zero (the default) disables that aggregate
time cap; monetary, token, call, item and subscription limits still apply.
With the explicit `crexx-rag.config/4` format, zero in those aggregate budget
fields means unlimited; older formats retain their zero no-spend behavior.
Provider request caps, timeouts and the external Codex allowance floor still
apply. Set `maintenance.window_seconds = 0` for an open-ended default window.

For example, two workers may each spend 90 minutes on calls during a two-hour
window. That is 180 provider minutes, but only two hours of elapsed time. This
formerly caused premature budget exhaustion because the window duration was
also used as an aggregate allowance. New windows use the corrected policy;
existing persisted windows retain their reviewed budgets until they end.

Durable guided maintenance uses the persisted deadline, not a poll count derived
from `worker.guided_deadline_seconds`. Provider timeouts and role input/output
limits must fit the intended window.

These settings require no compilation. Edit the file, inspect `config diff`,
and apply an exact `config plan` before planning new work against an existing
library. The reviewed window freezes the effective policy, provider routes,
privacy classification and charging basis. Configuration changes never imply
corpus reingestion. Extraction/profile and resolution-prompt identities govern
which interpretation a task requests; changing only a spending limit does not
reset previously resolved or unresolved questions.

## Choosing a finish time

The same timing controls are accepted by `maintain` and `maintain plan`:

```sh
crexxrag maintain --minutes 120 --yes
crexxrag maintain --until 2026-09-10T06:00:00+01:00 --yes
crexxrag maintain --overnight 18:00-06:00 --yes
```

Choose one control. `--minutes` accepts 1..10080 and starts its elapsed window
when maintenance planning begins, including the census and approval time.
Format-4 policy also accepts `--minutes 0` for no deadline. Such a window ends
on operator stop, a blocking error or no eligible work, and still uses the
configured `maintenance.batch_items` for each discovery pass.
`--until` requires a complete date and time with `Z` or a numeric UTC offset;
it accepts a future deadline within seven days. This makes an exact one-off
instant unambiguous. An already passed deadline returns success with
`disposition: skipped`, without a census, new job or provider call.

`--overnight` uses the host's local timezone and must cross midnight. Its opening
boundary is inclusive and closing boundary exclusive. With `18:00-06:00`, a
Monday 22:00 launch and Tuesday 00:30 launch both resolve to Tuesday 06:00.
Launching at Tuesday 06:00 or 06:05 skips that run. Launching during the daytime
also skips; the application does not wait until evening or schedule itself.
The external scheduler remains responsible for launching the wrapper.

Civil dates are converted using the host's timezone rules, so 06:00 stays 06:00
when daylight-saving changes alter the overnight elapsed duration. Configure the
scheduler's process timezone consistently (for example `TZ=Europe/London` on
POSIX hosts). A nonexistent local closing time is rejected; use an explicit
UTC-offset deadline when a clock-change boundary could be ambiguous.

The plan displays the resolved local and UTC finish time and retains the epoch,
local UTC offset, requested mode and cleanup allowance. Apply and worker restarts
retain that deadline. Waiting for approval or restarting workers never grants
more time. If the deadline passes before apply, apply skips successfully. A
changed local timezone between plan and apply requires a new plan.

Stopping is graceful and deadline-aware: calls must fit before the cleanup
allowance, their normal configured timeouts bound transport, and unstarted work
remains in the durable backlog. Timing does not interrupt database commits or
kill worker processes. A stalled operating system, provider cleanup or final
vector publication can still extend final process exit beyond the target; this
is not a hard process-kill guarantee. Normal deadline/budget closure returns 0.

The small `scripts/nightly-maintenance.crexx` wrapper passes one timing option
when it plans, then continues the same job in 100-attempt batches using the
configured workers. Edit its `timing` constant and recompile with
`crexx --noexec scripts/nightly-maintenance.crexx`; it owns no date rollover or
worker deadline logic.

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
do not create an endless paid reconsideration loop. Unscoped maintenance pages
through previously settled concepts and closed aliases as well as current open
work. Material changes to direct evidence, subject meaning, eligible identities
or incident relationships can create one linked successor under existing holds.
A final no-change stays final for the same assessed context; its own accepted
change does not immediately reopen it. Prompt/model changes and corpus generation
alone do not reopen settled questions. Read-only search makes no maintenance
writes. See the [comparison contract and upgrade limits](architecture.md#reconsidering-settled-maintenance-questions).

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
General extraction and embedding now persist an immutable, bounded response
envelope before validation and settlement. Same-item restart revalidates and
reuses that receipt without a new external request; usage remains owned by its
original attempt. Codex retains its managed thread/turn recovery and preserves
completed output after settlement too. A newly requested replay job is new
work and can make a new call; it is not the generic same-item recovery path.

An expired outbound intent without a durable response is explicitly uncertain.
Recovery pauses its job, exposes the affected item as a dead letter and records
`provider-outcome-uncertain` in `job events`. Further calls on that unresolved
job are refused. Inspect and reconcile the outcome before explicitly choosing
new work. No mechanism can recover a network response that was never received
durably. Late or above-estimate actual usage is still accounted once, with an
exception event; it never authorizes a stale worker to publish knowledge.

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
