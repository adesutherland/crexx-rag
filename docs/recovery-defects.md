# Operational hardening and recovery defects

Start with the [consolidated roadmap](ROADMAP.md) for cross-project priorities,
current status and related query, configuration and agent findings. This file
retains the complete operational requirements and dated incident evidence.

## Current local implementation — 12 September 2026

The [public recovery follow-up](public-recovery-journey.md) adds reasoned
waiver/reopen controls, consistent status/usage/interval observations and old
workflow-marker recovery. Tests reproduce each gap first; the final local gate passed
**59/59 in 1238.52 seconds**, with frozen installed recovery replay also passing. The original requirements and incident accounts below remain evidence,
not claims that their dated live runs are still underway. Broader fresh-operator,
hosted, platform and long-run closure remains open; OPS-005 renewal is separate.

## RAG-OPS-001 — P1: routine launch and recovery must be product operations

Status: open, high-priority backlog requirement raised by the user on
2026-09-10. Address after the current embedding run; this entry does not claim
that the operational workflow is hardened.

The approved LLM repair now supplies an isolated implementation of `job run`,
pre-claim configuration checks, conservative process pruning and digest-checked
Codex `job reconcile` inspection/apply. Local recovery fixtures exercise these
paths. The user subsequently authorized the live LLM backlog until 16:30 BST;
that run is underway with eight workers on a fixed artifact. It does not yet
close the whole requirement, and the earlier paid embedding response without
a durable receipt still needs evidence-led closeout. See the current
[qualification record](llm-processing-repair-plan.md#qualification-at-publication).

Starting or resuming an approved workload must be a repeatable command using
the already built, tested executable and ordinary configuration. It must not
depend on agent-written Python, SQL edits, generated per-run repair programs,
or rebuilding the application to repair a routine data/configuration state.
Validation must either lead to a supported recovery path or explain the
specific decision that requires operator input. Another blocking check alone
does not close this requirement.

The embedding launch on 10 September exposed an operational configuration
guard that classified a drained, paused extraction job as active. Correcting
that guard required another build after earlier tests. The exact launch path
had not been qualified in advance, delaying the requested processing. The
live launch subsequently used public configuration plan/apply, maintenance
plan/apply and worker commands; that success does not qualify the entire
operator recovery workflow. Broader regression risk remains open because the
user directed immediate live execution before the full suite completed.

The live run also retained one failed item with `cannot begin provider receipt`
after a metered embedding response, while other embeddings continued. Include
this observed receipt-persistence failure in the recovery review; its underlying
cause is not yet established. Inspect durable response/usage evidence before
replay, and require recovery through the public product surface.

Four successive live worker groups also stopped on generic transaction-start
failures. The confirmed replacement gap was classification: those exits were
recorded as generic failure, while the supervisor accepted explicitly recoverable
exits. The generic messages discarded the SQLite result code. The reservation
path also scanned the growing event ledger four times under its writer lock,
and quota deferrals repeatedly reclaimed work before capacity returned.
Candidate 13 adds bounded retries of transaction start only, retains diagnostics,
marks safely settled busy exits for the existing replacement policy, combines
the four ledger scans, and waits for quota capacity. The same real job is being
used for the user's requested eight-versus-sixteen-worker comparison. This is
ongoing live validation; the wider P1 requirement remains open.

The eight-worker interval then added 581 covered chunks and 450 successful
provider calls in 926 seconds, with no new dead letters or worker replacements.
Changing only `worker.processes` to sixteen exposed another mismatch: the
public operational configuration transition succeeded, but each worker still
required the original full configuration hash. The group was drained after
288 uncalled configuration rejections. Candidate 14 permits a difference only
in the worker-count field; provider, profile and all remaining configuration
fields remain exact. The original snapshots and job limits are preserved.
Recovery uses public `job retry` for those uncalled rejections before a fresh
sixteen-worker interval. A configuration error must also be diagnosed once at
the group boundary rather than propagated into hundreds of item dead letters;
include that case in the P1 operator-flow qualification.

Required closure:

1. Review the existing configuration, job, maintenance-window, worker and
   publication state transitions together. Assign each decision and repair to
   its owning cREXX component and reuse its public controls. Consolidate
   conflicting guards and remove superseded workarounds; do not introduce a
   parallel orchestration framework or a second source of job truth.
2. Provide one documented entry point for starting and resuming the requested
   backlog with configured workers and explicit time/spend limits. Repeating
   it must not duplicate a job, provider call or reservation, or reset the
   original deadline and budget. Normal operation must require no build step.
3. Make recoverable configuration, migration, stale-owner, settled-job,
   cached-embedding and sidecar problems diagnosable and repairable through
   the tool itself. Repairs must be bounded, idempotent and auditable, preserve
   corpus history, and leave unrelated paused work alone. Return an actionable
   public command when a separate repair step is necessary.
4. Make the controller continue eligible work after transient provider errors
   or recoverable worker exits, using shared backoff and durable attempt
   limits. If the controller itself stops, provide a supported resume path
   with the same limits. Keep genuinely uncertain paid requests inspectable
   and held; do not silently resubmit them. Show why progress is waiting or
   stopped and distinguish that from an exhausted backlog.
5. Qualify the exact installed executable through the complete operator flow:
   launch, stop, resume, controller/worker interruption, throttling, ordinary
   reader/writer contention, drained paused jobs, configuration transitions,
   cache reuse and final index publication on a representative corpus copy.
   Verify coverage and paid-call accounting, not merely process startup.
6. Have a fresh agent or operator execute the documented commands without
   source edits, bespoke scripts or private database knowledge. Any required
   workaround fails this acceptance case. Run the relevant regression suite
   on the final artifact before claiming closure; retain live-run results
   separately from deterministic test evidence.

Current priority: let the authorized embedding backlog run and address actual
processing failures. Do not turn this requirement into another prelaunch
redesign or delay. Subsequent repairs should be small, justified against the
owning state transition, and remove the need for operational intervention.

## RAG-OPS-002 — P1: operators must be able to mark any task for retry

User requirement, confirmed 10 September: any task can be marked for retry;
the framework must not disable that operator action because of a task state,
parent-job state or closed maintenance window. The five failed embeddings below
are the reproduced case, not the boundary of this requirement.

The public operation must retain a durable retry request, reason and original
history, deduplicate repeated requests, and arrange eligible work through the
existing maintenance/job owner. Execution still accounts for existing calls,
budgets, ownership and uncertain external outcomes; any waiting condition must
be explicit and must not erase or reject the retry request. Cover every task
state and both open and closed parent jobs in the operator-flow acceptance.
Review the overly aggressive one-attempt transient-error default as part of
this defect. The user considers three attempts reasonable; preserve an
explicitly authorized ceiling such as the current six-call embedding limit.
Quota waits and failures before a provider call must not be confused with
permanent content failure or consume a reasoning correction.

Status: open; confirmed by the 10 September final coverage check. The eight-worker
window completed its admitted work with 34,900 of 34,905 active chunks covered.
The five missing chunks belong to maintenance job
`job-maintenance:cf5808df5d3703bf71ff2ec0881f5660e65b14741f6dcbbade1f34d6e5815fbf`.
Each made one recorded provider call, failed with a quota/resource-exhausted
response, and became a failed maintenance task under that window's one-attempt
limit. These are separate from the later run's two held item records.

`ragbacklog` retains the same task identity on a later census with unchanged
evidence and knowledge policy. `INSERT OR IGNORE` leaves its failed state in
place; dispatch selects pending tasks. Raising the later embedding allowance
to six does not reconsider these earlier failures. Another ordinary maintenance
window therefore does not automatically repair these five gaps.

Provide a supported, reviewed reconsideration/requeue transition in the existing
maintenance owner. It must distinguish confirmed transient failures from
uncertain paid outcomes, preserve original attempts and usage, apply the
current authorized cumulative ceiling and window budget, and expose ineligible
tasks explicitly. Validate by carrying a one-attempt quota failure into a later
authorized window, with repeated requeue as a no-op and no repeat call for an
already covered chunk. No live data patch or extra generation was made while
diagnosing this gap; it is separate from the approved LLM items 1–3.

The user's requested command-surface test then tried `job retry` for all five
items. Every call returned `job is not eligible for dead-letter retry`. A
single-item `job replay` also returned `source job must be terminal with explicit
dead letters`. Public `job status` reports the source as `completed` with five
dead letters, whereas both recovery controls require `completed_with_errors`
(retry also permits `queued`). Public task inspection still shows failed state,
one attempt and no semantic failures. No retries, new jobs or provider calls
were created. Correct the owning terminal-state projection and maintenance
reconsideration together; merely bypassing the job-state guard would leave the
closed window and failed task unresolved. Include explicit listing, bounded
retry and reasoned close/waive semantics in the operator-flow review; waiving a
missing embedding must not count it as covered.

## RAG-OPS-003 — P1: routine status must be available through product commands

Status: open; requested by the user on 10 September after live monitoring
repeatedly required manually written SQL. Operators and Codex must be able to
understand progress, diagnose failures and select recovery commands without
knowing the database schema or writing SQL or per-run status scripts.

Audit the monitoring queries against the existing `job status`, `job events`,
`worker status`, `maintain tasks`/`maintain inspect` and `library report`
surfaces first. Use existing commands wherever they already answer the
question; extend their owning Level-G cREXX repositories and command results
only for missing information. Expose equivalent structured results through
JSON/NDJSON and MCP, without a separate reporting framework or source of truth.

Required closure:

1. Report consistent completed/total counts by operation and source, including
   accepted, skipped, queued, running, deferred, review and terminal failures.
   Distinguish unique corpus coverage, task completion and provider attempts;
   every percentage must state its denominator and reconcile with its parts.
2. Provide bounded, filterable failure and retry inspection with the affected
   item, attempt, reason, attempt allowance, next retry time, uncertain outcome
   and supported recovery action. Show why a job is waiting or stopped.
3. Report configured versus live workers, controller ownership, heartbeat
   freshness, failed/replaced workers and remaining restart allowance.
4. Support a run or time interval for accepted-item throughput, provider-call
   outcomes, correction success, known usage and explicitly incomplete usage.
   Include observation time and enough context for a meaningful finish estimate.
5. Have a fresh operator or agent reproduce the live-run status and recovery
   diagnosis using documented commands alone. Keep reads bounded and efficient
   while workers are active; routine monitoring must not require raw SQL.

This is a backlog requirement, not a claim that these command extensions have
been implemented. It complements RAG-OPS-001 recovery and RAG-OPS-002 retry.

## RAG-OPS-004 — P1: distinguish task failure, worker failure and environment outage

12 September step 4: rolling supervision and shared preflight backoff are
implemented in [supervision recovery](supervision-recovery.md). Defaults are two
replacements per rolling hour; qualified evidence and remaining scope are
recorded there. Task attempts, unknown outcomes and cumulative usage remain
separate from replacement capacity.


11 September admission slice: [temporary capacity recovery](admission-recovery.md)
now shares the allowance decision between ordinary ingestion and maintenance.
This repairs the tested capacity-pressure case; the wider supervision/outage
requirement below remains open.

The following records the original requirement. The step-4 slice above now
implements worker replacement and shared preflight recovery. User clarification
on 10 September 2026: the intended
three-attempt retry limit applies to an individual task, not to a worker or the
whole job. This entry does not change current task, worker or job limits.

Design an explicit recovery decision in the existing task, worker and provider
owners. A counter alone is insufficient evidence for its scope:

- A task that repeatedly fails on otherwise healthy workers needs a bounded
  task retry, then an inspectable hold or review with its evidence and history.
- A broken worker needs replacement while its task retains the same identity,
  attempts, receipts and budget. Replacing a process must not reset task history.
- Correlated failures across healthy workers may indicate a provider, database,
  network or wider environment outage. Use shared backoff and bounded recovery
  probes, then resume eligible work when the affected service recovers. Quota
  waits and unavailable infrastructure must not condemn otherwise valid tasks
  as permanently failed.

Decide which failures count toward the task's three attempts, which evidence
permits a classification, and how ambiguous cases are held and reassessed.
Unknown submitted provider work still requires outcome reconciliation before
another call. Preserve budgets and deadlines and expose the decision, evidence,
waiting reason and next action through product commands (RAG-OPS-003).
Operator retry requests remain available for every task state (RAG-OPS-002).

### Worker replacement within a rolling time window

User roadmap clarification on 10 September: worker replacement limits must be
time-based. A lifetime count for a long-running job must not permanently prevent
replacement after a few isolated failures. In the evening run, one worker exited
after a Codex response timeout while seven peers continued; the job had already
used its two replacements during the afternoon.

Specify a configurable maximum number of worker replacements within a rolling
time window, with backoff for bursts. Old replacement events age out of the
active allowance while remaining in the audit history. Window duration and
count defaults require policy agreement; this entry does not select new values
or change the running job.

When the recent replacement allowance is exhausted, preserve healthy peers and
defer further replacement until the next eligible time. The controller must
automatically reassess and restore the configured worker count when the window,
provider/environment state and remaining job budgets permit it. An operator
restart must not be necessary merely because the rolling allowance recovered.
Persist replacement timestamps and decisions across controller restarts so a
restart neither clears a recent failure burst nor retains permanent exhaustion.

Keep this worker recovery policy separate from the task's three-attempt limit.
Time passing or replacing a worker must not reset task attempts, receipts,
uncertain provider outcomes, spend or the run deadline. Correlated environment
failures still require shared backoff and recovery probes rather than repeated
worker launches. Product status must show the window, recent replacement count,
next eligible replacement time, configured/live worker counts and waiting reason.

Acceptance must exercise isolated worker failures spread across a long run,
a burst that exhausts the rolling allowance, and automatic replacement after
the oldest event ages out, including when no healthy worker remains. Repeat
across a controller restart and at the window boundary; concurrent decisions
must not double-reserve a replacement. Verify uninterrupted healthy peers,
restoration of the configured pool, preserved task retry history, no duplicate
provider submission and respect for the original budgets and cutoff. Validate
through the normal public job command, without manual database/config repair.

Acceptance must include one repeatedly failing task among eight healthy workers,
a failing worker processing otherwise valid tasks, and an outage affecting the
whole pool followed by recovery. Check exact task attempts, uninterrupted peer
progress, replacement without history reset, shared outage backoff and automatic
resumption through public commands. The later explicit step-4 implementation authority applies to the policy
and tests documented above. Wider outage/platform qualification remains open.

A related fixture observation belongs in this review: an ordinary ingest job
can exhaust *currently available* token capacity while healthy peers hold their
reservations. The non-maintenance path currently turns that denial into a worker
failure, even though capacity may soon be released. Distinguish temporary
reservation pressure from exhausted total budget; do not solve it by weakening
budget accounting or repeatedly replacing healthy workers.

## RAG-OPS-005 — P1: simple continuation and renewable budgets

Status: backlog only. User direction on 11 September 2026: simplify the rules
and restart workflow. Whatever optional limits were selected, an operator must
be able to reset/renew the applicable budgets and continue existing work through
one straightforward product operation. Users must not have to align elapsed
time, aggregate provider hours, money, calls and token limits manually.

The overnight ingestion job stopped at its saved 72-hour aggregate provider-time
cap despite the later authorized wall-clock cutoff and remaining account quota.
The subsequent maintenance launch spent about three minutes preparing before
rejecting an operational configuration registration mismatch. Recovery required
separate public config diff, plan and apply commands before a second launch.
These are concrete examples of operational brittleness, not satisfactory normal
startup. Preserve the incident evidence in the 10–11 September overnight report.

The same session exposed a further continuation gap: pausing a degraded
maintenance pool left its job terminal while durable work remained. The normal
same-job restart then rejected it, requiring a fresh maintenance window whose
startup took about eight minutes. Resuming remaining work must not depend on
the operator diagnosing these internal job/window state distinctions.

Review every limit and distinguish essential safety protections from optional
operator controls. Candidate essentials include source/evidence integrity,
privacy and provider authorization, exclusive work ownership, and protection
against duplicate submission of uncertain external work. Time, spend, calls,
tokens, aggregate provider duration and replacement counts need an explicit
decision about purpose, defaults and whether they should exist in the normal
workflow at all. A user-requested stop time remains binding unless the user
changes it; external provider/account restrictions cannot be reset locally.

The intended operator experience is “continue” or “reset budget and continue”.
The product should show the actual stopping reason and the effective remaining
allowance in plain language, then perform the supported recovery and resume
eligible work. An obsolete internal counter must not permanently veto an
explicitly authorized renewal. Avoid hidden lifetime limits and interacting
defaults that require the operator to understand internal admission accounting.

Renewal must preserve cumulative usage and its audit history, completed work,
task attempts, receipts and uncertain outcomes. Record a new authorization or
allowance period instead of erasing historical spend or replaying completed work.
Distinguish temporarily reserved capacity from consumed budget. Optional limits
must have a clear way to be omitted, disabled or renewed without editing SQL,
rebuilding, manufacturing a replacement job or rewriting the configuration file.

Integrate routine semantically compatible configuration registration and worker
recovery into the normal command path where existing authorization permits it.
Check genuine incompatibilities early, before expensive worklist preparation,
and give one actionable recovery path when user input is actually required.
Do not make every routine restart a multi-command repair exercise. This
complements RAG-OPS-001, RAG-OPS-003 and RAG-OPS-004 rather than replacing their
ownership, diagnostics or worker-recovery requirements.

Acceptance must demonstrate through public commands: stop at an optional budget,
one operator renewal and successful continuation of the same remaining work;
conflicting/default limits that no longer require manual alignment; a permitted
operational configuration mismatch recovered during ordinary startup; and
preserved histories, held outcomes, healthy peers and explicitly retained cutoff.
Include pause/drain followed by continuation when internal job state is terminal
but eligible durable work remains; the public operation must handle that state.
Review the policy and command design before implementation. No budget reset API,
new defaults or code changes are introduced by this backlog entry.

## Earlier recovery record

Recorded 2026-09-06 after the Scottish corpus recovery investigation.

Current qualification is tracked in [the reliability review](reliability-coverage-review.md).
The dated results below retain their historical binaries and run states. They
must not be read as the current installation or live maintenance status.
The 7 September baseline repairs REL-001 through REL-020 locally; hosted
nightly soak, installed Linux replay and an explicit staged full-corpus
replacement workflow remain separate unfinished work. REL-014 protects a
complete index against an incomplete alternate embedding representation; it
does not implement a full corpus replacement command.

## RAG-REC-001 — incomplete replacement hides a complete vector baseline

Status: incident trigger and missing/corrupt sidecar recovery repaired in
baseline commit `48e0eee`; all 21 tests pass. A separate
explicit corpus-replacement workflow that stages a replacement until complete
remains open. Operational restoration is not a claim of installed release.

SQLite must contain the source evidence, embedding vectors, identities and
generation membership needed to recreate a vector sidecar. The `.rxvec` file
is a derived index for efficiency, not an independent source of truth. Losing
or rejecting that file must not require paid embedding generation when the
compatible vectors already exist in SQLite.

The incident violated publication availability, not durable vector storage:

- Erroneous semantic reingestion created replacement chunks for unchanged
  source content and advanced the published generation from 4799 to 7068.
- Generation 7068 exposed 15,153 active chunks but only 7,485 linked chunks.
  Its manifest advertised no vector sidecar. One stopped job still had active
  durable state.
- SQLite in the damaged library retained **all 13,707 distinct original
  vectors**, containing 42,107,904 bytes, and **all 15,153 original
  chunk-to-vector links**. The retained vectors match the backup byte for byte,
  including embedding identity, input digest, profile and dimension. Multiple
  chunks can reuse one distinct embedding.
- The older generation-4799 sidecar also remained on disk. Describing the
  vectors as deleted, or the sidecar as the only surviving copy, is incorrect.

The existing `ragembedding.buildannvectorgeneration` loads `e.vector` from
SQLite through generation-filtered `revision_chunk_embeddings` and
`revision_chunks`. It then trains and publishes the derived index without an
embedding-provider argument. This supports the intended architecture, but
rebuilding only the current incomplete membership is not sufficient to recover
the previously complete publication.

Required closure:

1. Prove that an unchanged corpus remains a no-op across prospective
   configuration changes: no replacement chunks, new jobs or provider calls.
2. Keep a complete published query baseline available until an explicitly
   reviewed replacement is ready. Intentional partial initial publication must
   remain distinguishable from replacing a complete baseline with incomplete
   work. Do not mix generations or weaken dimension/envelope validation.
3. Provide and qualify a bounded recovery operation that uses SQLite's stored
   vectors and memberships to rebuild a missing/corrupt sidecar, with zero
   provider calls and no loss of original provenance.
4. Test missing/corrupt sidecars and interruption before publication on scratch
   copies, verify citations and vector retrieval, and prove no paid work is
   inferred from a derived-index failure.

The earlier operational recovery used the complete generation-4799 backup,
preserving the damaged directory. The subsequent operator pass adds public
`vector rebuild` / `rag_vector_rebuild`, missing/corrupt/interrupted-file
regressions, and a hybrid preflight that detects an invalid sidecar before
provider use. Configuration and profile changes now apply prospectively,
without publishing a generation or replacing old chunks. Exact corpus-table
and vector-BLOB preservation is checked on a scratch library.

Machine evidence:
`/Users/adrian/testrag/recovery-20260906/sqlite-vector-authority-audit.json`.
The preserved database is
`/Users/adrian/testrag/library-quarantine-scottish-full-20260906-gen7068`.

## RAG-REC-002 — configuration migration leaves a stale manifest

Status: repaired and qualified in baseline commit `48e0eee`.
Originally observed in the existing uninstalled recovery artifact with
SHA-256 `eafeb2f98fec8913d3abe58b78b7728e5b6a88fcc6130fbe7ad52c188c0e1339`.

Applying a reviewed prospective configuration to a staged schema-8 backup
automatically migrated SQLite to schema 9, but left the manifest at schema 8.
`library verify` returned exit 7, `manifest_state=invalid`, one storage issue
and zero repository issues. The public `library migrate` operation republished
the manifest, after which verification passed with zero issues. Generation
4799 and all 44 compared domain/history tables remained unchanged.

Migration/configuration application must leave manifest and SQLite identity
aligned, or explicitly require and report the remaining migration step before
claiming success. Add a focused existing-bundle regression when the corrective
source is qualified. Do not edit the manifest or migration checksums by hand.

The repair records the pre-open schema version and republishes the manifest
only after a successful automatic migration. The durability regression builds
a schema-8 bundle, opens it through the ordinary read/write path, and checks
schema 9 plus an aligned manifest in both interpreters and optimisation modes.
This does not change migration checksums or weaken manifest validation.

## RAG-MNT-001 — hosted maintenance has an unacceptable exact-span rejection rate

Status: quotation-grounding repair qualified locally; broad hosted maintenance
requires a new bounded hosted qualification of the durable identity and
resolution route.
Observed on baseline `48e0eee`, 2026-09-06, with the Scottish
library and Gemini `gemini-3.5-flash-lite`. The reviewed top-5,000 census selected
4,969 concept reviews and 31 existing analysis leads. It required no embedding
repair or reingestion.

The test was stopped early after widespread rejection, with 76 provider calls:
6 processed items, 7 valid no-supported-claim skips, and 63 dead letters.
Of the failures, 60 were `provider mention does not match its exact evidence
span`, 2 were relationship span/confidence failures, and 1 was a canonical
alias conflict. Recorded test cost was $0.179673. The other 4,893 work items
were cancelled without provider calls. This is an incomplete, failed test,
not successful qualification of a 5,000-item batch.

The durable output reservation was 4,096 tokens, and there were no invalid-JSON
failures in these attempts. The earlier hidden 1,024-token cap therefore does
not explain this result. The observed failure was at the exact byte-span check
in `ragapplicationprovider`. A bounded diagnostic replay captured the mechanism:
`Forbes` was assigned bytes 296–302, which contain `--Forb`, instead of 290–296;
`Culloden` was assigned 339–347 instead of 359–367. This is not a uniform
codepoint/byte-frame conversion error. The model returned incorrect positions.

Providers now return `evidence_quote`. Level-G cREXX resolves exact text first,
then full Unicode casefold, then casefold with ASCII whitespace runs collapsed.
Every result maps to the original UTF-8 bytes. The whitespace pass was added
from retained responses that replaced printed line breaks with spaces, including
`Lord\nMacaulay`. Punctuation changes, ellipses, absent text, missing relationship
endpoints and invalid types remain rejected. Repeats choose the first occurrence
within the chunk; relationship endpoints resolve inside their support quotation.
The response schema enumerates the allowed types and note kinds. Existing
stored chunks, embeddings, configuration snapshots and source-ingest identity
are not rewritten by this protocol repair.

Rejected product JSON is bounded and credential-redacted before storage in the
failed provider run's existing diagnostic field. Malformed or oversized content
is omitted with a digest. Synthetic negative cases prove redaction and preserve
strict graph/evidence rejection.

This failure was already present in the initial load: 7,693 exact mention-span
dead letters; 10,767 initial extraction dead letters overall, with 1,963 processed
and 2,423 skipped items. Source/vector completeness was incorrectly reported as
if it implied complete extraction. Repair/replay uses stored chunks, not document
reingestion or embedding regeneration.

Qualification: all 22 tests pass, including both interpreters and optimization
modes for quotation grounding. One legacy diagnostic call and ten bounded
repair calls on copies cost $0.028613 total. The ten repair calls included three
completed items, three canonical-alias conflicts, and four rejected proposals
while the quotation contract was being corrected. The final two calls passed
quotation validation: one completed, one reached a canonical-alias conflict.
This small result is not successful qualification of 5,000 items.

## RAG-MNT-002 — cancellation after drain leaves a nonterminal job summary

Status: repaired and locally qualified. After both workers drained and all
reservations reached zero,
`job cancel` cancelled the remaining 4,893 queued items but left the job at
`cancel_requested`. `requestcancel` does not call `_refreshjob`, and an empty
worker claim does not refresh it either. Consequently `vector rebuild`
rejected the library as still having an active job.

Operational closure used a recorded, guarded SQLite transaction to reconcile
only this job's state, plus one audit event. It asserted zero active items,
workers and reservations, and applied the existing `_refreshjob` precedence:
`completed_with_errors` because dead letters exist. No item, attempt, evidence
or embedding was changed by that reconciliation. The product now refreshes the
job state inside the cancellation transaction and after expired-lease recovery.
Regression coverage includes queued-only work, a drained paused job, an in-flight
cancelled lease, and dead-letter precedence. No manual SQL reconciliation is
needed for these cases.

## RAG-REC-001 follow-up — interrupted maintenance also hides vector publication

The short maintenance test published valid graph changes through generation
4813. All 15,153 chunk links and all stored embedding BLOBs were preserved,
but the current manifest advertised no vector sidecar until final publication.
Draining a paused job made the controller refuse that final publication.
Availability preservation therefore needs to cover interrupted incremental
maintenance as well as explicit full-corpus replacement.

After terminal status reconciliation, the public `vector rebuild` successfully
published 15,153 rows at generation 4813 using SQLite only, with zero provider
calls. `library verify` passed with zero storage and repository issues. The
original source/revision/chunk and embedding tables are byte-identical to the
fresh pre-test backup. The successful graph changes and complete test history
remain in the live library; no backup rollback was performed.

Evidence and complete operational record:
`/Users/adrian/testrag/maintenance-5000-20260906/` and
`/Users/adrian/testrag/transcripts/90-baseline-and-top-5000-maintenance.md`.

## Configuration preservation invariant

User clarification, 2026-09-06: changing configuration does not invalidate the
database. Profiles, prompts and ranking/chunk policies govern subsequent
work. Historical objects keep their original configuration snapshots, spans,
provider provenance and vector identities. Existing rows are never deleted
or reset merely because configuration hashes differ.

ANN algorithm/tuning changes require only a new derived index from stored
vectors. Embedding model, dimension or input-encoding changes require a
compatible embedding set when explicitly requested. They retain the old set
and all other corpus data. An incompatible query embedding route is an
unavailable retrieval channel, not an invalid database.

The interrupted-maintenance follow-up is now locally repaired. All readers,
manifest projection, reports, maintenance census and backup share an eligibility
check for the newest ancestral index: both source-chunk and embedding-link
membership must match the requested semantic generation exactly. The index keeps
its original generation and checksum. Changed memberships and non-ancestor
branches fail eligibility. This does not claim completion of the separate full
corpus replacement workflow above. The final Scottish scratch copy verified at
generation 4827 with zero storage or repository issues, retaining the complete
15,153-row generation-4813 index. All ten source/embedding tables match the live
generation-4813 library byte for byte; no schema migration was introduced.

## RAG-MNT-003 — replay omitted the worker budget policy

Status: repaired and locally qualified. The first scratch replay created items
and job totals but no `budget-policy` event. Its worker rejected the item before
any provider call. Replay now atomically records the current reviewed policy
with the new job and rejects historical reservations that exceed that envelope.
The durability test claims replay work, reserves a call, settles it and completes
it, rather than checking lineage alone. The source job remains immutable.

## RAG-MNT-004 — canonical identity conflicts still block some maintenance

Status: repaired in the local candidate; final offline qualification is recorded
below. Broad hosted maintenance remains unqualified. Three of ten repair-probe attempts reached
`canonical alias conflict requires review`, including one of the final two
calls after quotation validation succeeded. Existing canonical ownership remains
protected. Do not merge identities or discard aliases merely to increase the
success rate. Investigate catalogue-aware proposal production and the explicit
review route before restarting broad maintenance. This is not evidence that
source text or embedding storage needs rollback.

Current evidence and closure note:
`/Users/adrian/testrag/grounding-repair-20260906/` and
`/Users/adrian/testrag/transcripts/91-quotation-grounding-and-maintenance-repair.md`.
The live 5,000-item job remains terminal and no automation was resumed.

Follow-up diagnosis on 6 September: captured candidate records include
`Macleans` (organisation), already an alias of `Clan Maclean`, and `Macdonalds`
(organisation), already an alias of `Clan Donald`. Other collisions cross
types, including `Mackay` as organisation versus the existing person alias.
The incident producer hashed the proposed canonical label without first
resolving it through the catalogue. These cases require identity reuse or
explicit contextual ambiguity, not indiscriminate merging. The replacement producer reuses a unique typed catalogue identity and records
unresolved collisions as durable questions. Validated reuse/distinct answers
retain aliases and ambiguity, then queue follow-up extraction. The local
fixtures cover automatic and supervised resolution without weakening identity
or quotation validation.

## RAG-MNT-005 — resolution work stops at mandatory operator review

Status: implemented in the local candidate; final offline qualification is
recorded below. See [Durable autonomous maintenance](autonomous-maintenance.md).

The previous route put conflicts and structural actions into `review-required`
even when automatic operation was intended. It had no dedicated resolution
worker or automatic split workflow for affected connections. The maintainer's intended
operation is a bounded maintenance window (for example five hours nightly)
that resolves routine issues and pursues opportunities automatically, resumes
unfinished work, and escalates exceptions instead of every decision.

The candidate adds typed resolution questions for the full task census,
incremental split/merge connection work, runtime policy, deduplicated
reconsideration, shared budgets, deadlines and settled-response recovery.
Retirement is gated on a complete impact census; source records, vector BLOBs,
claim/support history and moved note-link source spans are retained. The legacy
`reviewed` mode remains the compatibility default; the new automatic and
supervised modes are explicit runtime choices. No nightly automation was
created or resumed. The historical 5,000-item live run remains unqualified.

## Durable backlog local qualification — 6 September 2026

RAG-MNT-004/005 are implemented and locally qualified in the working tree.
All 24 tests pass, including both-VM connection workflows, cross-window settled
response reuse at the paid-attempt cap, note-link source history, manual census,
supervised follow-ups, and native Gemini valid/malformed/ungrounded cases.
`git diff --check` passes. The candidate is not committed or installed.

Native SHA-256:
`39379f44ab8042699cbbf395f858bb6377000136ab6edd5140266114946bb262`.
A fresh Scottish clone migrated to schema 10 at generation 4813. SQLite rebuilt
its 15,153-row index with the original checksum and returned five passages in a
stored-vector ANN query. All nine source/vector tables and sidecar identities
match live; verification reports zero issues. No provider calls were needed.

Evidence: `/Users/adrian/testrag/transcripts/94-durable-backlog-qualification.md`
and `/Users/adrian/testrag/durable-backlog-20260906/full-test-final.log`.
The live library and paused automation are unchanged. Broad hosted maintenance
and the historical top-5,000 test remain unqualified; this local closure does
not close the separate staged full-corpus replacement workflow in RAG-REC-001.
