# Scottish maintenance acceptance: engineering triage, 16 September 2026

This is dated investigation evidence, not a second defect register. Current
status belongs in [ROADMAP.md](ROADMAP.md). No product implementation, runtime
configuration or installed artifact was changed by this investigation.

## Run and authority

Published baseline `6b706308220b43bcf163c79410f879f850169f2e`, native SHA-256
`d9bd6040b99f83bc9bac6ca4f8ff0240445853e5e27c1b1838aab3bc158d54d9`, installed in
`/Users/adrian/Documents/ScottishHistory`. One automatic window activated at
17:03:35 BST with deadline 19:03:35 BST, eight configured workers, Luna Low for
ordinary work and Sol Medium for advanced work. Monetary budget is zero.

Job: `job-maintenance:49b91eecc4e0aa99752120fb6108016e8a07c28ddf8a611c47f98528f2eb3eca`.
Receipts and run record are in
`/Users/adrian/Documents/ScottishHistory/reports/maintenance-acceptance-20260916/`.
The monitor reported a continuity gap after 17:27 BST. This is distinct from
product processing time and is not evidence that the controller stopped.
Adrian subsequently identified an authentication timeout as the reason for the
app/session restart. Do not conflate that interruption with database contention.

At Adrian's separate explicit request, the operator then restarted the same
product job through supported `job run --count 8` controls. The operator reports
that the old group drained without a kill and a fresh controller
`controller-ab857a0c035787c25d374e4f57968d09` had eight live workers at 18:34 BST.
`user-restart-*` receipts retain the same job/window, limits and original deadline
1789581815, with 280 processed, eight running and no held uncertainty at
17:34:03 UTC. This is an operator-intervened run. Compare subsequent throughput
separately; a successful restart is not a repair of the contention mechanism.

The operator's 18:42:43 BST checkpoint (`check-1742-*`) reports 432 processed,
up 152 in 8 minutes 40 seconds from the restart checkpoint (about 17.5/min).
The last five-minute interval recorded 86 processed (17.2/min), compared with
two (0.4/min) at 18:31:59 BST. All eight workers were live. There were 800
planned items, 69 skipped and 297 dead letter; 820 recorded provider runs
comprised 441 successful and 379 failed. Held uncertainty, monetary cost and
reservations were zero; allowance remained 24%. A bounded queued page was
empty moments after status showed two queued items, so no parked-item diagnosis
can be drawn from that changing snapshot. The operator reports substantial
post-restart recovery, without proof of the contention root cause or endurance.

## Runtime contention: observed failure, exact holder not established

`continue-status.json`, observed at 17:31:59 UTC (18:31:59 BST), records 600 items:
253 processed, 238 dead letter, 38 skipped, 71 queued and zero running. Six
workers were live, the controller heartbeat was four seconds old, and two
processed items were recorded over the preceding 300 seconds. The rolling
replacement allowance was exhausted. There were no held uncertain outcomes or
outstanding reservations. This demonstrates severe degradation, not a complete
stall or a missing controller.

`continue-workers.json` retains several failed workers from this job with
`cannot checkpoint maintenance backlog` and one with
`cannot validate claimed maintenance context`. `run-launch.stderr` also retains
repeated SQLite BUSY errors for heartbeat writes, replacement transactions and
provider admission/release. Later `continue-provider.json` reports ready Luna
and Sol routes and 24% remaining allowance, resolving the stale allowance read.

Source trace:

- `ragbacklog.tickbacklogwindow` emits the first error when its raw
  `BEGIN IMMEDIATE` fails, before the checkpoint body.
- `ragbacklog.checkbacklogclaim` emits the second error at the same transaction
  entry operation, before fresh evidence validation.
- `ragwork.runworkeronce` propagates these failures. These are operational
  database failures, not evidence that an advanced model could not reason.
- `ragstore.beginwritetransaction` already provides bounded BUSY acquisition
  retries and extended error reporting. These two entry points bypass it.
- The architecture records remaining expensive census/evidence preparation
  inside the checkpoint writer transaction. That is a plausible contributor;
  the particular lock holder and query duration in this run are not established.

Do not attribute this to CREXX #701, increase replacement ceilings, weaken
validation or restart a live controller to manufacture an acceptance pass.
Retain the existing RAG-SMK-003 index/heartbeat repair evidence while reopening
its broader contention qualification. Preserve original deadline and history.

Next bounded engineering work: characterize independent-connection BUSY behavior
at both owner entry points, including a lock that clears and one that persists,
plus a non-BUSY failure control. Assert no duplicate claims, provider calls or
lost usage/fences. Inspect checkpoint transaction duration on an isolated corpus
copy before deciding whether shared acquisition retries suffice or the writer
critical section must be shortened. The existing supervision checkpoint test
uses a nested BEGIN on the same connection; it verifies error propagation and
no provider calls, but does not reproduce cross-connection contention.
Keep all fixture databases, logs and outputs private. No live-corpus load test
or full-suite repetition was performed during this baseline run.

## Inspection gap and escalation interpretation

The sampled task
`task:3708e704a4f830584574f364b8ef99b4a5f51e5a47ac9bdbcf349ce379a376b0`
was initially dispatched with advanced capability after two ordinary grounding
failures. At the next check it had progressed to failed with a bounded-attempt
diagnostic. This retracts the initial suggestion of a demonstrated stuck handoff.
An earlier ordinary dead-letter item's route count cannot establish what a new
advanced item did; due-advanced counts omit already dispatched work.

The public catalogue provides no direct per-task job-item filter and no bounded
failed-response lookup from a task ID. Task inspection lacks linked item IDs;
item summaries omit raw responses. A failed item can leave the queue preview
before the next five-minute observation. This prevents reliable attribution of
its exact frozen route and failure response without broader scanning. Record
this under RAG-OPS-003; do not work around it with private IDs or corpus SQL.

Successful decisions do have a public detail path: inspect the task, take a
returned `decisions[].decision_id`, then `maintain inspect DECISION_ID`. The
shared backlog owner returns response, grounding, item and provider-run IDs,
disposition and applied generation. Failed validation can have no decision.

## Grounding failures

Early bounded failed samples consistently reported
`resolution quotation does not ground the selected connection`. At the later
runtime checkpoint, 313 of 572 recorded provider runs were failed. These
counters do not establish that every failure had that message or cause.
The source validator checks literal quotation matching and overlap with the
selected evidence span. Without the exact rejected response and selected packet
pair, model, prompt, packet and matcher causes remain unseparated. Preserve
grounding requirements and track this under representative acceptance RAG-QA-02.

## Qualification

Investigation and documentation only; `git diff --check` is the relevant check.
Existing published functional passes remain valid for their exact tested inputs.
This runtime evidence prevents claiming clean eight-worker endurance or complete
semantic acceptance. The final operator report records partial acceptance, as detailed below.


## Final closeout

The operator's `FINAL.md`, `TECHNICAL.md` and `QUALITY-SAMPLE.md` in the run
receipt directory report **partial acceptance**, with all processing stopped.
The restarted launcher receipt was written at 19:01:36 BST, before the original
19:03:35 deadline; stopped workers were confirmed at 19:07. No overrun was
observed. Receipt time is not an exhaustive audit of individual admission times.

The terminal job is `completed_with_errors`: 1300 materialised items comprise
708 processed, 149 skipped, 438 dead letter and five cancelled. The 708 decisions
include 123 applied-change and 127 final no-change decisions. Whole-backlog
resolved tasks increased by 404, while pending tasks increased by 24 as discovery
and follow-up created work. These are different denominators; processed items
are not unique completed tasks or graph improvements.

There were 1273 provider runs, 722 successful and 551 failed, using 25676796 input
and 561032 output tokens. Monetary cost, held uncertainty and reservations were
zero at closeout. Remaining account-wide allowance changed from 28% to 23%; that
coarse shared measure cannot be attributed entirely to this job. Of 150 items
requesting quotation correction, 38 recorded a correction completion; this does
not by itself isolate model, prompt, packet or validator causes.

Published generation increased from 27957 to 28234. One final library verify
returned zero issues. The temporary monetary budget was restored through public
configuration controls; policy bytes match the pre-run baseline and effective
configuration is identical. Existing embedding coverage remained 36319 with no
missing embeddings. There was no ingestion.

Two deliberately selected advanced-capability decisions (one no-change and one
reuse) had literal quotation support in resolved immutable spans. The sample is
illustrative, not a random accuracy estimate, and retains identity qualifications.
Frozen policy selected Sol Medium, but the sampled records do not independently
expose executed model/effort; no model comparison or model-separated success rate
is established. Prior ordinary escalation decisions were retained with the sample.

Closeout passed. Reliability, grounding and inspectability remain partial. The
next bounded work is targeted failure inspection and contention reproduction,
followed by response/evidence analysis and a focused acceptance retest. The run
provides no authority for additional corpus processing.

## Causality clarification and observation requirements

Adrian challenged whether expired OpenAI authentication caused slow provider
sessions and subsequent database contention. That remains a valid hypothesis.
Recording authentication and database failures separately does not establish
causal independence. Available receipts cannot establish whether contention
initiated degradation or followed authentication trouble. Restart recovery
changes process/provider state as well as database activity and isolates neither.
Launcher stderr contains the cited lock errors but no explicit authentication
expiry diagnostic; absence there does not exclude errors retained elsewhere.

The inspected normal work path commits claims, context validation, reservations
and provider admission before waiting on the provider. It opens separate
transactions to retain results and settle usage. A slow provider call does not
normally hold the SQLite writer lock through this path. Authentication errors
could still alter retry, checkpoint, failure-recording and worker-replacement
traffic indirectly; that interaction needs controlled reproduction.

The Codex coordinating agent and native product controller have separate
lifecycles. The coordinator can lose authentication while the controller remains
live, as observed here. Provider health failures can stop product workers;
supervision can park replacement slots even when no child remains. Multiple
provider failures do not imply immediate controller shutdown. Desired behavior
for authentication-required should explicitly stop new affected provider calls,
retain receipts and task eligibility, and expose a resumable operator wait.
Authentication is not a semantic failure and must not trigger advanced reasoning.

Extend existing receipt/event inspection for successes and failures, with direct
task/item/attempt/provider linkage, frozen evidence/request, effective prompt,
model/effort, returned response or explicit missing-response state, validation,
correction, disposition, usage and timestamps. Separate provider wait,
authentication/backoff, lock acquisition and transaction-body durations,
correlated to the same worker/item. Preserve secret redaction; reuse retained
receipts rather than duplicating large bodies or logging every SQL statement.
Compare healthy slow-provider, authentication-failure and writer-contention
cases before selecting the repair. These are investigation/design requirements;
no runtime implementation or further corpus run was performed.
