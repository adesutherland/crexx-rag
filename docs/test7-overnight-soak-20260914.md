# Test 7 — Scottish overnight soak, 14–15 September 2026

**Later engineering acceptance:** the [completed job-controls repair](job-controls-delivery-20260915.md)
closes PC-01 and the superseded rolling retry proposal. The combined candidate
passes 79/79 local tests, including T7-10's controller regressions. It is not yet
installed; historical results below do not claim final-candidate soak acceptance.

Status: **CLOSED at 05:55 BST on 15 September, before the 06:00 cutoff.
Restoration, verification and backup passed. Functional repairs passed; clean endurance qualification remains
open because two long-running controllers disappeared without exit receipts.**
The sole engineering heartbeat is paused. No overnight processing authority
continues. [Final operator report](/Users/adrian/Documents/ScottishHistory/reports/overnight-soak-20260914/FINAL.md)
contains complete phase, usage, query and backup evidence. Remaining engineering
items below stay open for a separate continuation, not another automatic run.
The launch was approved on 14 September at approximately 21:00 BST.
The final change list is approved. Gemini budget is approved at **US$20
for the whole night**. Managed OpenAI subscription use and the removal of the
10% reserve are approved; Adrian will reset his own subscription allowance.
Higher retry allowances and conditional tested increases are approved. The concrete initial settings and
conditional escalation below replace the earlier three-attempt/US$5 proposal.
This document does not renew the exhausted Test 6 pilot.

### Launch and supervision record

**Final cleanup receipts checked:** restore 137 passes with zero active jobs
and no provider calls, retaining the two imported source registrations. Vector
activation 138 is an identical no-op with 36319 rows. Verification 139 passes
schema 19/generation **26751**, aligned manifest and **zero integrity issues**.
Backup 140 publishes that generation with its sidecar at
`/Users/adrian/Documents/ScottishHistory/backups/post-test7-20260915`;
worker read 141 returns no running workers. Recorded whole-night totals from
`usage.json`: **6479 provider runs, 5265 processed items, 95759926 known input /
2586927 output tokens, US$0.035403 Gemini cost**, zero held outcomes and twelve
older incomplete-usage attempts. Known usage is a lower bound, not a complete
token accounting claim. Final job preserves 34 queued items; previous queued
work, content holds and superseded tasks were not blindly restarted.
Unresolved follow-ups: T7-02's real returned-review-ID caller test, T7-10
controller lifetime investigation, retained content/backlog work and controlled
evaluation of the Scottish prompt candidate. This night used multiple repaired
builds; 74/74 developer tests do not establish clean host endurance.

**05:52 BST closeout recovery:** the final job has no live/registered/unverified
workers or running claims but still reports a running controller, whose last
heartbeat is 1986 seconds old. It retains 34 queued items, 837 processed,
842 skipped and 287 dead letters; zero held/incomplete outcomes in this window.
Its 1238 runs recorded 23487211 input/538882 output tokens, zero monetary cost.
Receipt: `cmake-build-debug/test7-final-0552-status.json`. The coordinator has an
immediate pause/missing-PID/prune and prepared-restoration/verify/backup handoff.
No restart, new window or provider work is authorized now. A second unexplained
controller/runner disappearance is suspected; verify its launch-domain process
state before attributing a cause. Cleanup may finish after 06:00 if necessary,
but must report that overrun. This is not a clean unchanged-build endurance pass.

**05:18 BST closeout arranged:** final job remains healthy with eight workers,
823 processed, 842 skipped, 281 retained dead letters, 67 processed in the recent
five minutes, zero held uncertainty/incomplete usage or replacements. Receipt:
`cmake-build-debug/test7-final-0518-status.json`. This is the final routine wake
before 05:45. The coordinator has been resumed for useful closeout preparation:
old/new query/relationship/citation checks concurrent with the final workers,
prepare restoration preserving source registrations, collect runner 126 at its
fixed 05:40 finish, then restore/index activation/one verify/backup/report by
about 05:45. No new windows/renewals or provider work after 06:00. It will send
terminal/drained and final-report evidence to engineering; pause this heartbeat
only after closeout is actually complete.

**04:47 BST light check:** the final window is healthy with eight live workers,
417 processed, 485 skipped, 144 retained dead letters, 64 processed in the
recent five minutes, no held uncertainty/incomplete usage or replacements.
Receipt: `cmake-build-debug/test7-final-0447-status.json`. No intervention or
coordinator wake. Next routine wake is the last before the 05:40 deadline;
ensure closeout starts by 05:45 as already handed off.

**04:16 BST final window active:** unscoped backlog job
`job-maintenance:1341c44534c526dd58a4b00e22254ba1bf5ebf48ed1b339567a109b0bab9c4b1`,
runner 126/session 44346, fixed deadline **05:40 BST (04:40 UTC)** in plans
124–125. Startup 127 confirms eight healthy workers and restart ceiling ten.
Configuration `e9590870...` deducts completed usage and reserves twelve older
incomplete-attempt token maxima; no renewed allocation. Leave the coordinator
idle until completion, significant failure or final cleanup. Existing heartbeat
only; arrange cleanup by 05:45 and no new provider work after 06:00.
Boswell recovery runner 114 exited 0 with all eight workers completed and no
restarts. Source summary 119 at generation 26031 confirms all 1233 chunks have
extraction tasks, zero undiscovered; 1221 resolved/27 unresolved task records
across policies do not certify complete content extraction. Scottish prompt and
hard-case results are in `reports/overnight-soak-20260914/prompt-quality-outcome.md`
and `prompt-quality-candidate.txt`. The candidate is unactivated guidance for
a later comparison, not a measured improvement or running-window change.
T7-02 still lacks a naturally valid new external-proposal caller retest.

**04:13 BST final-backlog handoff:** Boswell recovery completed early with
256 materialized items, 255 processed and one content dead letter (mention
quotation absent from the chunk), zero queued/running or retained worker
ownership, zero held uncertainty/incomplete usage. Its 284 provider runs
include 255 successes/29 failures, 5216759 input/186351 output tokens,
4398597 ms reported provider time and zero monetary cost. No replacements were
needed in this window, so the new ceiling is configured but not exercised by a
fresh transport failure. Receipt:
`cmake-build-debug/test7-boswell-recovery-0413-status.json`.
The coordinator has been resumed to collect runner 114/source coverage and
start a final unscoped backlog window ending by 05:40 BST, with deducted
whole-night limits and twelve older incomplete-attempt reserves. Cleanup starts
by 05:45: restore temporary policy while retaining sources, activate vectors,
old/new retrieval/relationship/citation checks, one final verify and backup,
and final results including Scottish prompt/hard-case outcomes. No new provider
work after 06:00. The next active job remains to be recorded by the coordinator.

**03:40 BST live recovery PASS:** installed inspections 104/105 and applies
106/107 succeed on both original held outcomes: failed with no final answer,
zero generation calls. Status 115 has zero held outcomes, unchanged 2217 runs
and known tokens. Its incomplete-usage count rises from two to four because
the two newly observed outcomes join two other incomplete attempts; the owner
counts each attempt once using its latest observation, not all event rows.
No accounting repair is indicated. The coordinator has the interpretation and
will carry four old-block plus eight Boswell incomplete attempts in conservative
cross-phase reserves at the next normal boundary, with no live interruption.
Fresh-window apply 113 closes the paused predecessor through normal lifecycle:
116 confirms its 17 queued items cancelled and zero queued/running, while
existing unfinished task history remains available. New Boswell job
`job-maintenance:b3e191878559364bb3896f10b8350ba5c81f6176e96acb9c1635149cbe0bd835`
is active with eight workers, configured replacement ceiling ten, runner 114
(session 92861), deadline about 04:39 BST. Resume the coordinator when it drains
early, then general backlog before 05:45 cleanup. No additional monitor.

**03:36 BST activated recovery repair:** coordinator pause 096, missing-PID
confirmation 101, supported prune 102 and paused/drained status 103 confirm
no remaining worker/controller ownership. The old runner's process ID was
unavailable and no completion file existed; controller disappearance is
unexplained, not a demonstrated product cause. Native `fd7b6537...` is now
installed; previous `eb74de...` tools are preserved at
`backups/tools-before-test7-reconcile-20260915` in the Scottish workspace.
Fresh installed status passes schema 19/generation 25776, aligned manifest,
zero issues (`cmake-build-debug/test7-reconcile-installed-status.json`).
The coordinator has the two recovery retests and fresh Boswell source-window
handoff. Use deducted remaining allowances, not renewal of the old 45k allocation.
The existing maintenance-apply path checkpoints/closes a paused prior window,
returns its unprocessed dispatched tasks to pending, and retains task/attempt
history for the new source window. This handles the 17 queued items through
normal commands. Set the temporary replacement ceiling of ten, then complete
eligible Boswell work and general backlog before the existing cutoff.

**03:30 BST recovery boundary:** one public status read confirms Boswell is
parked with zero live/registered/unverified workers, zero recent progress,
964 processed, two skipped, 17 dead letters, 17 queued and no running claims.
There are zero held uncertain items and eight incomplete-usage observations.
The coordinator has been asked to pause/drain the existing controller through
the normal public path and return its terminal receipt before engineering
activates the tested T7-08 package. No healthy workers are being restarted.
After activation, perform the two retained-outcome retests, apply the existing
replacement ceiling of ten, finish eligible Boswell source work and then run
general backlog within the same budget/05:45 cleanup/06:00 cutoff. The queued
request is recovery of an observed stall; the old runner is not yet confirmed
drained. Receipt: `cmake-build-debug/test7-boswell-0330-status.json`.

**02:59 BST operational follow-up:** Boswell remains running, 950 processed,
two skipped, 17 dead letters and 31 processed in the recent five minutes.
Only two workers remain; the two-per-hour replacement budget is exhausted.
One bounded public worker listing confirms App Server timeouts and byte-read
deadline failures. No held uncertain items; two active unsettled calls and
eight incomplete-usage observations are retained. The controller will reconsider
replacement automatically at epoch 1789439510; do not restart healthy peers.
The coordinator has this significant-failure handoff and will use the existing
`worker.max_restarts = 10` at the next natural boundary for the remaining soak,
within the approved increased timeout/retry allowance, then restore it at
closeout. No new product mechanism or extra monitor. See T7-09 below.

**02:25 BST engineering continuation:** T7-08 is implemented and its focused
recovery acceptance passes. The full **74-test suite passed, zero failures**,
977.65 seconds shared-machine elapsed; session `34110` exited 0.
Output is `cmake-build-debug/test7-reconcile-full-ctest.log`. Candidate
native is `fd7b6537ebb73e3ea23d328a21fefbef58d7193602ef8130ebdca324bb44bbf7`.
Stage at a coordinated natural drain and obtain the two real reconciliation
retests. Installed `eb74de...` remains active. One public Boswell status read at
02:25 BST confirms healthy progress: 800 materialized, 739 processed, one skipped,
12 dead letters, eight active workers, 76 processed in the recent five minutes;
eight active unsettled calls, zero held uncertainty/incomplete observations.
Receipt: `cmake-build-debug/test7-boswell-0225-status.json`. Do not restart or
wake the coordinator for this unchanged healthy phase.
The complete tested package is prepared alongside it at
`/Users/adrian/Documents/ScottishHistory/tools-test7-reconcile-candidate-20260915`;
its native hash matches the tested candidate, its 200-file inventory omits no
old installation files, and a fresh candidate CLI library-status read passes
schema 19 with zero issues. Install/status logs are
`cmake-build-debug/test7-reconcile-install.log` and
`cmake-build-debug/test7-reconcile-candidate-status.json`. At the next natural
drain, retain `tools/` as `backups/tools-before-test7-reconcile-20260915`, activate
the prepared package as `tools/`, verify fresh installed status and request the
Scottish coordinator's public recovery retest before the next backlog window.
One account refresh reports 5% used / 95% remaining; no reset redeemed.
Fragments completed early with 171 processed, one skipped and
one content dead letter. The coordinator launched Boswell at 01:38 BST: job
`job-maintenance:7d46f8eacdc0632d98b8d3a96891d3920c4cdf87677354e675049373b916c640`,
runner 094, eight workers, 1233 source chunks/zero missing embeddings, deadline
03:38:09 BST. The allowance is a maximum: the existing heartbeat must resume the
coordinator when runner 094 completes early, rather than wait until its deadline.
Actual phase budgets are deducted in the coordinator handoff; no new monitor.

**Current engineering handoff — after midnight, 15 September:** T7-06 held
outcome filtering and T7-07 source-scoped maintenance are implemented, with
regression-first focused acceptance passing. At the 00:52 BST engineering wake,
the combined **74-test full suite passed with zero failures**, command session
43642 exited 0, 1045.12 seconds shared-machine elapsed. Full output is retained
in `cmake-build-debug/test7-source-and-held-full-ctest.log`. Final candidate native:
`eb74de625d11fbb2f5416385a0c3e7a43dbe48885734e5198d2486e202747fcc`.
**Activated at 00:54 BST:** Boswell runner 074 and terminal receipt 076 confirmed
1233/1233 processed, zero remaining/dead-letter/uncertain, all eight workers
stopped and no registered/unverified workers. Its 1233 Gemini runs include 1226
successes and seven temporary service failures recovered normally; 167582 input
tokens, US$0.033032, zero Codex calls. The prior `4eb47d...` tools are retained at
`/Users/adrian/Documents/ScottishHistory/backups/tools-before-test7-source-repairs-20260915`.
The tested `eb74de...` package and matching docs/skills are now active in `tools/`.
Fresh installed CLI status passes at schema 19/generation 24641, aligned manifest
and zero issues. No old-only installed files were omitted. Install log:
`cmake-build-debug/test7-source-and-held-install.log`. One account refresh reports
3% used / 97% remaining; no reset was redeemed. The coordinator has the launch
handoff to use
`maintain plan --source SOURCE_ID` / `rag_maintain_plan.source` for Fragments
and Boswell after their embeddings, followed by an unscoped old-backlog window.
Reuse existing cumulative budgets; source selection grants no new allowance.
Installed filter receipt 080 returns both held IDs directly. Reconciliation
inspection receipts 078/079 fail the original-configuration check after later
approved source/budget changes; T7-08 below tracks this separate recovery issue.
Fragments source-window runner 086 launched at 00:56 BST with eight workers and
a 60-minute allowance ending at 01:56:33 BST; source work may drain earlier.
No commits, pushes or master SQL.

Metadata review for this candidate confirms only `rag_job_items` and
`rag_maintain_plan` descriptions and optional `uncertainty`/`source` parameters
changed; existing fields/access and tool counts remain. Updated metadata test
and final operator diagnostics pass. Source/continuation/SQL focused checks
pass 6/6; shared skill validators and whitespace checks pass. T7-02 still awaits
a naturally valid new external proposal; do not manufacture one to close it.

**Engineering continuation checkpoint — 22:39 BST:** the five repairs below are
implemented and the complete **73-test local suite passed**, zero failures,
1437.92 seconds of shared-machine elapsed time. Command session **95038** ended
with exit 0. The complete CTest log, independently containing 73 passed test
records, is retained at `cmake-build-debug/test7-soak-repairs-ctest.log`.
Current candidate
native SHA-256:
`4eb47d730ef55acbae94efb33b949c0a42085ebf29a958d0022a4dbbe017d762`.
At 23:12 BST the tested package was installed alongside the live tools at
`/Users/adrian/Documents/ScottishHistory/tools-test7-candidate-20260914`.
Its native hash and shared skills match the tested source; install output is
`cmake-build-debug/test7-candidate-install.log`. The live `tools/` directory has
not been switched. No commit or push has happened. The Scottish coordinator was
resumed specifically for the upcoming phase/staging boundary: let the first Luna
block drain naturally around 23:21 BST, report its terminal outcome and notify
engineering when the live tools can be replaced, before launching the next block.
Preserve old tools at the unused
`/Users/adrian/Documents/ScottishHistory/backups/tools-before-test7-repairs-20260914`
path, then activate the prepared candidate as `tools/`; the existing launcher,
MCP configuration and skill links will continue to select that location.

**Activated at 23:45 BST:** coordinator receipt 064 and reaped runner 048
confirmed zero queued/running/live/registered/unverified workers. The first
block ended `completed_with_errors`: 2,800 materialized items, 1,627 processed,
799 skipped, 347 dead-letter and 27 cancelled; 2,217 provider runs and two held
uncertain outcomes. This is a completed block with unresolved work, not a clean
soak pass. The old tools were preserved at the backup path above and the prepared
candidate renamed to `tools/`. No old-only installed files were omitted. Fresh
installed CLI status passes at schema 19/generation 24640, aligned manifest and
zero status issues. The Scottish coordinator has the installation handoff for
five retained caller retests, normal uncertain-outcome recovery and the next
substantial block. Fresh CLI/new test-owned MCP processes select the new binary;
an already-running MCP process may retain the old one. Mark the repaired-build
soak segment separately from the preceding acceptance-build block.
An idle Scottish coordinator while its recorded job is healthy is normal;
do not wake it for routine progress or make it track individual census steps.
The coordinator's retained runner session is 86876; its CONTINUE record owns
current master execution state. At staging, preserve the old tools, install the
tested candidate, refresh test-owned MCP sessions where needed, and request
one public retest of each repaired journey. Routine live supervision is now
every thirty minutes and at phase boundaries.

One stale-record refresh at 22:39 BST found the existing Luna block running,
controller heartbeat age zero, seven live workers, 1,133 processed items and
1,500 provider runs; 73 items completed in the preceding five minutes. Two
items are held with uncertain provider outcomes, with no active unsettled items;
retain these for normal diagnosis/reconciliation at the phase boundary. Other
work is progressing. Do not restart healthy workers or waive unknown outcomes.

- Launch dispatched to the Scottish coordinator at approximately 21:00 BST on
  14 September after Adrian's final approval. Actual backup/configuration/job
  and first-provider-work receipts are recorded by the coordinator in
  `/Users/adrian/Documents/ScottishHistory/reports/overnight-soak-20260914/CONTINUE.md`.
- Engineering heartbeat **Test 7 Scottish soak until 06:00**, automation ID
  `test-7-scottish-soak-until-06-00`, is active on this engineering task every
  thirty minutes after Adrian's light-monitoring correction. Its instructions expire this run at the stated cutoff and pause
  the monitor after final closeout. Historic monitors remain paused.
- Bounded sleep prevention: `/usr/bin/caffeinate -i -s`, PID **62472**, started
  for this run and expires automatically at 06:15 BST on 15 September, allowing
  bounded final cleanup. It owns no RAG workflow and does not extend processing
  authority beyond 06:00. Stop only this owned process early after closeout if
  it is still the same process.
- Launch account observation: 90% used / **10% remaining**. Adrian owns reset
  redemption; no reset was consumed by engineering.
- Scottish helper assignments are active as `/root/soak_sources` (source
  preparation and query checks) and `/root/soak_hard_cases` (advanced evidence
  investigations), initially through approximately 22:45 BST. The coordinator
  owns their follow-up assignments and records results in its run record.
- Actual provider execution confirmed around 21:05 BST: baseline public backup
  `/Users/adrian/Documents/ScottishHistory/backups/pre-test7-20260914` published
  at generation 23213; approved initial configuration
  `config-907121987cf4dd82d8e6163e` registered. Five-gap repair job
  `job-maintenance:b1de2097a2ecb5d13a88cf19e5d52327bc732b7a29b53dd9618ebf12f713ab18`
  processed all five items with five successful Gemini calls, 1,051 input tokens,
  2,024 ms reported provider time and **US$0.000208** recorded cost. No failed,
  uncertain or incomplete usage outcomes. All eight requested workers completed;
  the public job-run receipt reports the vector index published. Source helper
  prepared Fragments body (41,535 bytes), Boswell (700,725 bytes) and Mackenzie
  (602,364 bytes); new-document ingestion follows the same embeddings-first rule.

Work on the Scottish master from launch this evening until **06:00 BST on
15 September 2026** (`2026-09-15T06:00:00+01:00`, 05:00 UTC). The time check at
definition was 20:35 BST on 14 September, leaving about nine hours twenty-five
minutes. Use sustained one-to-two-hour blocks with useful work between them.
Around 05:45, finish processing and begin final drain, verification and report.
No new provider work after 06:00. Normal configured call timeouts and public
shutdown apply; never interrupt a database commit to meet the clock. Report any
cleanup overrun rather than claiming an exact process-kill guarantee.

## Objective and working principles

Exercise substantial real imports, embeddings, LLM extraction/enrichment,
maintenance, source-grounded reviews, prompt improvement and concurrent queries.
Reduce the existing actionable backlog and repair demonstrated engineering
defects while work continues. A successful short job is not an overnight soak.

Failed embedding: leave that item pending or failed. Successfully stored
embeddings: include them in search independently. Existing documents: retain
usable search coverage while new work proceeds. Restart/retry: finish
outstanding work and index activation. Preserve recorded attempts, responses,
usage and task history. Missing evidence remains explicit; do not clear the
queue by silently dropping or waiving hard questions.

Use existing commands, configuration and supervisors. No new orchestration
framework, alternate SQL workflow, repeated full preflight, repeated approval
for delegated work, or tiny pilot budgets. Identify and remove demonstrated
redundant checks in their shared owner, with regression evidence. Keep actual
source grounding, supported graph changes and transaction integrity.

## Responsibilities and parallel work

| Owner | Work |
| --- | --- |
| Scottish coordinator: **Plan Scottish History acceptance run** (`01a0a027-4ffe-7832-a904-42fd1381ab06`) | Own document queue, master source registrations, policy changes, ingestion, job launch/continuation, routine maintenance, source-grounded review accept/reject decisions and corpus prompt versions. Keep work moving until cutoff. |
| Scottish source/query helper | Prepare the next public source and its edition metadata; test old/new retrieval, relationship following and complete citations while processing runs. Return findings to the coordinator. |
| Scottish difficult-task helper | Investigate disjoint advanced tasks and pending reviews, including supported Hamiltons/Lochgary follow-ups. Return evidence-grounded proposals and uncertainty; coordinator applies decisions. |
| Engineering: **Review P1 P2 smoke fixes** (`01a09a57-602d-72d0-8587-0a3aa895c410`) | Supervise progress, reproduce core defects, add failing regression plus positive control, fix the shared owner, run required checks, stage the tested artifact at a drained checkpoint, then obtain a real corpus retest. |

Helpers receive concrete one-to-two-hour assignments with disjoint subjects.
They do not each launch another maintenance window or edit the master policy.
This leaves normal product worker concurrency intact. The current master has
**eight configured workers**; retain that starting setting rather than copying
the two-worker Test 6 pilot limit. Respect each provider's existing concurrency
and pacing settings. Record any evidence-led worker-count adjustment.

Engineering uses the current `crexx-rag` checkout and installed CREXX package.
No sibling CREXX source changes, public release or push are implied. An upstream
fault gets an exact reproducer and integration issue. Product fixes may be
built and staged for this authorized soak; preserve unrelated working changes.

## Sources and processing order

The master is `/Users/adrian/Documents/ScottishHistory/library`, selected policy
`/Users/adrian/Documents/ScottishHistory/crexxrag.conf`, launcher
`/Users/adrian/Documents/ScottishHistory/crexxrag`. Test 6's disposable library
and its eight pending proposals are not the master work queue.

The existing reading list is
`/Users/adrian/testrag/corpus-development-20260908/user-source-proposal.md`.
Most candidates are not downloaded. Begin with the remaining material from
*Fragments*, whose retained raw text is
`/Users/adrian/Documents/ScottishHistory/reports/codex-acceptance-20260914/evidence/gutenberg-8161-original.txt`
(90,035 bytes). Its 4,884-byte preface is already imported and must not be
reintroduced as new material. Select the remaining sections and keep edition
and source provenance. Determine actual chunk counts through normal planning.

Acquire further suitable public texts from the existing queue while this work
runs, prioritising readily obtainable clean sources such as Boswell or
Mackenzie's Highland Clearances after checking exact work/edition availability.
The reading-list titles are acquisition leads, not verified source metadata.
Already imported Browne, Keltie, Johnson and the M'Pherson lecture are controls,
not new documents. No promise of a particular number of whole books tonight.

For **each selected batch**, the order is:

1. Capture source/metadata and ingest with `discovery.mode=maintenance` so
   immediate work focuses on Gemini embeddings, with Codex turns zero.
2. Store successful embeddings, activate search and check a representative new
   passage/citation. One failed vector must not block the rest of the batch.
3. Run configured Luna extraction/enrichment through normal deferred maintenance
   and process existing catalogue/graph tasks. Do not reingest unchanged text
   merely to request LLM work.
4. Resolve reviews and difficult tasks, improve Scottish objectives from actual
   failures, and validate useful changes on different evidence.

Track **new-document LLM completion separately from general maintenance**.
Normal ranking can prefer old repairs and does not guarantee a chosen task mix.
If the supported workflow cannot progress new-document enrichment as well as
old work, report the exact selection/starvation issue to engineering; a busy
maintenance job must not disguise unprocessed new sources.

## Work blocks and controls

| Period | Main work |
| --- | --- |
| Initial block, up to one–two hours | One baseline backup; prepare/import the first source batch, repair the five existing embedding gaps, establish usable vector coverage. Helpers acquire sources and investigate old hard tasks. Move on early if the batch completes. |
| Following one–two-hour blocks | Substantial Luna processing and existing backlog reduction, with review decisions and old/new search, graph and citation queries running alongside. Further prepared imports receive their embedding pass before their LLM work. |
| Between blocks | Compact progress/usage summary, source or prompt changes if justified, engineering updates if ready, then start/continue the next useful block without returning for per-block approval. |
| Final block ending around 05:45 | Prioritise outstanding work and reviews; complete one ordinary restart/continue exercise if no repair restart already covered it. Avoid beginning a large import that cannot receive useful processing. |
| Around 05:45–06:00 | Drain normally, finish index activation, query old/new sources, run one final verification and capture final backup/report. Stop the overnight supervision schedule. |

Keep routine maintenance in the master's existing **automatic** mode and
supported action policy. The Scottish coordinator is delegated to examine and
accept or reject reviews through public commands; it need not ask Adrian for
each source-supported decision. Unsupported structural changes stay rejected
or unresolved. External proposals use the same validation/review path.

The existing master budgets are generous enough for blocks, unlike the exhausted
eight-turn pilot: 50,000 items/calls, 30,000 managed turns, 1,000,000,000 input and
300,000,000 output tokens, and US$5 configured monetary allowance. Overnight
aggregate ceilings reuse the call/item/token values and raise the monetary
allocation to **US$20 total for Gemini embeddings**, not US$20 replenished at
every block (`budget.cost_microunits=20000000` for the overall allocation).
Register phase allocations
through existing public controls and count cumulative consumption across them;
no new reservation framework is required. If that Gemini allowance is consumed,
continue eligible subscription processing, reviews and research rather than
idling the entire night. All hosted payloads are selected
public Scottish source text plus ordinary task/catalogue/correction context.
Gemini serves embeddings; configured managed `gpt-5.6-luna` at low reasoning
serves routine LLM work. The coordinating/research agents handle harder cases.

The necessary policy changes are explicit:

- Set `budget.minimum_codex_allowance_percent` from 10 to 0 for the night. The
  observed account has 11% remaining; retaining a 10% reserve would stop useful
  processing almost immediately. Notify Adrian of low allowance (about 5%) so
  he can perform his promised reset. Do not redeem a reset on his behalf. Real
  account exhaustion can prevent both corpus and engineering agents working;
  resume retained work after the reset, without resetting product usage.
- Raise `provider.gemini-embed.max_attempts`,
  `provider.codex-extract.max_attempts` and `maintenance.maximum_attempts` from
  **1 to 10** initially. These are cumulative attempts, so the five old
  embedding tasks with one recorded attempt can make up to nine further
  attempts. Updating all three avoids leaving a separate lower maintenance
  ceiling that prematurely blocks retryable LLM transport failures. Existing
  backoff, cooldown and `Retry-After` behavior remain in force.
- Ten is the current configuration maximum, enforced in `ragconfigfile` and
  typed `ragconfig`; the lower worker machinery already accepts larger values.
  If actual retryable timeouts/transport failures exhaust ten and otherwise
  useful work is blocked, engineering may raise the supported cumulative ceiling
  further, up to **100**, after reproducing the block and testing the narrow
  shared configuration change. The coordinator can then apply the justified
  increase within this same US$20/time allowance, without a new per-item
  permission request. This is conditional repair authority, not a request to
  make an unnecessary implementation change before launch.
- A larger transport allowance does not turn rejected content into a valid
  result. Existing one-correction and repeated-content-failure escalation remain
  separate; the Scottish agent resolves those cases from evidence. Preserve
  all past attempts/receipts, count actual incurred usage and reconcile unknown
  outcomes before issuing another call. No counter reset or waiver is implied.

The originally requested **N retries in a rolling hour** proposal was not part
of this night's scheduling algorithm. On 15 September Adrian replaced it with
explicit one/all-job retry reset; `RAG-OPS-006` is now closed as superseded in
[the roadmap](ROADMAP.md#time-window-retry-policy--rag-ops-006). The
[job controls repair](job-controls-delivery-20260915.md) owns that replacement.

### Why the five embedding gaps still appear

The original 13 September Test 1 repaired the separately evolved overnight
corpus under `/Users/adrian/testrag/overnight-scottish-20260909/`, reaching zero
missing embeddings at schema 17/generation 24922. The current master derives
from the earlier 11 September generation-23208 snapshot and did not receive
those later vectors. Both inherited the same library ID, so path and generation
must accompany that ID in scope claims. Later Test 1 repeats repaired disposable
smoke libraries. For example, the 14 September repeat used
`/private/tmp/crexxrag-tests1-5-yhw_zrgr/library` and explicitly excluded the
master. Its five successful calls did not populate the separate Scottish master.
The master acceptance later observed 34,913 chunks and 34,908 compatible
embeddings, with five historical tasks held at one attempt. Eight new preface
embeddings succeeded there independently. This is a corpus-copy distinction,
not evidence that repaired master vectors vanished or software repairs were
lost. See the [repeat scope and
results](smoke-tests-1-5-20260914.md) and [master acceptance](acceptance-repairs-20260914.md).

Tonight's first embedding phase explicitly repairs the main master and records
its actual before/after missing count. The targeted pre-overnight public check
confirmed schema 19/generation 23213, 34,913 chunks, 34,908 active compatible
embeddings and published vector rows, five missing and no active job. All five
original failures on 10 September are **provider resource-exhaustion/429**;
none is a recorded timeout or content failure. The message alone cannot
distinguish account quota from temporary capacity/rate exhaustion. Their current
block is the inherited one-attempt ceiling, not evidence of a fresh service
outage. Exact identities and results are in
`/Users/adrian/Documents/ScottishHistory/reports/codex-acceptance-20260914/execution/pre-overnight-five-gap-check.json`.

Keep models, dimensions, provider timeouts and shared schemas unchanged unless
a demonstrated fault calls for a tested change. Apply Scottish prompt updates
only at natural boundaries, record their versions and avoid repeatedly
reconsidering the whole corpus just because wording changed. Test 6's five raw
quotation-format deviations are a quality follow-up; canonical source fidelity
already passed and is not a reason to block overnight processing.

## Supervision, engineering and evidence

Attach one lightweight heartbeat to the engineering task, checking
about every thirty minutes and reacting to engineering reports from the Scottish
coordinator. An idle coordinator with a healthy running job needs no wakeup.
Resume it at phase completion, a significant failure, or tested repair staging;
check progress and quota when actionable, and schedule the next block within
the same overnight authority.
Use existing normal restart/continue when needed. Inspect a real stall before
acting; do not repeatedly restart a healthy group or create duplicate windows.
Old monitors found in this session are paused and target obsolete corpora;
leave them paused rather than reviving their old instructions.

Keep the Mac powered, prevent idle sleep for the bounded run, and leave the
desktop app running. Local scheduled work needs the computer and app available
([official scheduled-task documentation](https://learn.chatgpt.com/docs/automations?surface=app)).
The heartbeat cannot guarantee availability through an outage or exhausted
subscription. Record actual gaps, repair interruptions and artifact changes.

Adrian's monitoring correction: Astra High handles engineering while healthy
long jobs run independently. Routine supervision belongs at thirty-minute or
block boundaries, not individual item/census/receipt steps. Missing IDs,
per-source backlog/eligibility information and necessary public controls are
engineering gaps; do not compensate with queue pagination, ID reconstruction or
manual tracking assignments. Notify on an actionable failure, quota need,
phase completion or tested repair readiness. The last routine wake before
05:45 arranges the closing block and scheduled drain with the coordinator.

A core issue report needs the operation, job/task IDs, expected/actual result,
small retained diagnostic and affected source/build. Engineering fixes and
retests it; Scottish work continues on unaffected tasks. A successful fix is
retested through the real caller and marked resolved in the shared checklist.
Do not restart the full night after a fix or describe different builds as one
uninterrupted unchanged-build endurance measurement. A changed artifact gets
its own sustained post-fix observation period; any inadequate duration remains
an explicit release-qualification limit.

Use one evolving run record and issue list. At block boundaries record imported
documents/chunks; stored/missing embeddings; new-document extraction; baseline
backlog completed versus newly discovered work; accepted/rejected/unresolved
reviews; failures/retries/restarts; per-provider usage/cost; and process CPU/RSS
where available. Query samples cover search breadth, relationships and original
citations. Shared-machine elapsed timings are observations, not speed gates.

## Action checklist

### Shared documentation and model setup

- [x] Update the shared maintenance workflow for light monitoring, independent
  worker model selection, per-source inspection, returned IDs and engineering
  gaps. Ingestion and diagnosis reference this common guidance.
- [x] Update the reusable corpus AGENTS template, agent-integration guide and
  tutorial; existing authorization covers work within the approved scope.
- [x] Refresh Scottish AGENTS, README and continuation handoff, plus installed
  copies of the shared skills, integration guide and template. Record Luna/low
  for routine workers, Gemini embeddings and Astra High coordination separately.
- [x] Keep candidate-only commands distinct from the installed acceptance build;
  this documentation refresh changes no model configuration or running job.
- [x] Pass the documentation contract and all four changed skill validators;
  verify installed guidance matches the canonical source and check whitespace.

### T7-01 — source include ignored

- [x] Retain the Scottish caller's seven-file plan and exact configuration;
  the broadened plan was not applied. Continue with isolated source roots.
- [x] Trace both public plan/apply to `ragfolder`: neither passed the stored
  include patterns and the collector had no matching logic.
- [x] Add `regression_folder_include` before implementation. The unrestricted
  positive control passes plan/apply and independently stored membership with
  zero provider calls; exact `wanted.txt` fails, selecting six supported files.
  Baseline: `cmake-build-debug/test7-folder-include-baseline.log` against native
  SHA-256 `2828fc4a3a251aab3731afd2c9f378c8f670c7e171aa3a8397fa129de6f8abb6`.
- [x] Implement matching in the shared collector and pass patterns from both
  callers. Document root-relative wildcard semantics and existing source-set
  reconciliation behavior. No new SQL, index, schema or configuration is needed.
- [x] Pass focused folder acceptance, including exact names, recursive/root
  patterns, alternatives, case, supported formats and literal wildcard filenames.
- [x] Pass the complete local suite: 73/73, zero failures, session 95038.
- [x] Stage the tested artifact at the 23:45 drained checkpoint. Scottish
  receipt 071 confirms the real Boswell exact include selects one file from the
  multi-file preparation folder. T7-01 caller acceptance passes.
- [x] Record the new artifact segment: Boswell job
  `job-sha256:ba3972b9fb2b552cdac1fa5c0a4044c9215b2ca33a2765e8d4e284dc6afdefd5`,
  1233 embedding items, eight workers, zero Codex allowance, generation 24641.

### T7-02 — external proposal apply omits review IDs

- [x] Retain Cornwallis proposal/apply receipts 033/035 and the bounded failed
  review-discovery report. Apply succeeded but returned only a count; the
  current list surface has no direct proposal filter.
- [x] Extend `gemini_maintenance` before the fix: its existing independent list
  finds the stored review, then the new assertion fails because apply omitted
  the paired ID. Baseline `cmake-build-debug/test7-review-id-baseline.log`.
- [x] Preserve IDs returned by `ragclaims` in `ragimprove` and render paired
  `proposal_id`/`review_id` records in public apply. Update catalogue/user docs.
- [x] Pass returned-ID assertions and normal review acceptance in the fixture;
  inspect the metadata change (only `rag_proposal_apply` description changed).
- [x] Pass the full suite: 73/73.
- [ ] Stage and retest. Cornwallis was verified by the direct
  decision preview and accepted in receipts 062/063. Its earlier failed `show`
  is T7-04, not a missing review. Agent ID reconstruction is not the workflow.

### T7-03 — external proposal rejection hides the validator reason

- [x] Retain Gordon/Gibraltar's failed public proposal plan and unchanged input
  in the Scottish `hard-cases` report. The specific validation cause is not yet
  established; independent work continues.
- [x] Trace the generic message to `createexternalproposalplan`, which hides
  the validator's reason when the result is not the external-review route.
- [x] Reproduce hidden diagnostics with a known invalid-confidence proposal
  plus a valid control, then return the existing validator reason unchanged.
  Baseline: `cmake-build-debug/test7-diagnostics-baseline.log`.
- [x] Pass the focused valid-proposal/invalid-confidence diagnostic journey.
- [x] Pass full tests: 73/73.
- [x] Stage and replay the unchanged Gordon input. Scottish receipt 066 now
  reports `competing canonical claim requires review`. T7-03 diagnostic repair
  passes; the historical claim remains unresolved without altered confidence,
  vocabulary or grounding.

### T7-04 — source/review show filters only the first list page

- [x] Reproduce missing review 125 after passing review 1 in
  `regression_operator_diagnostics`; independently reproduce source 125 missing
  after source 1 succeeds. All rows exist in the scratch fixture.
- [x] Use the same `ragrepository` projection with bound indexed equality for
  exact source/review requests; eliminate the adapter's redundant page filter.
  Keep normal listing/pagination and generation visibility unchanged.
- [x] Pass source/review late-ID and missing-ID controls and read-only dump parity.
- [x] Pass full tests: 73/73.
- [x] Scottish receipt 065 returns the correct accepted Cornwallis review by
  exact ID; T7-04 caller acceptance passes.

### T7-05 — per-source backlog visibility and new-document progress

- [x] Record the product gap: job progress counts only materialized job items;
  task lists lack a source filter, so missing per-source deferred work cannot
  be assessed in one normal request. No per-chunk/census tracking workaround.
- [x] Extend the existing task inspection owner with source-level filtering and
  a compact summary distinguishing active chunks, retained extraction tasks
  and chunks not yet represented in the maintenance backlog. Use indexed
  source/chunk/task joins; no new scheduler or persisted reporting state.
- [x] Add ordinary regression/positive controls before implementation, including
  unrelated records before the source, undiscovered chunks and empty sources.
  `regression_source_backlog` first passes normal task inspection, then fails
  with `unknown option --source`; `test7-source-backlog-baseline.log` also
  confirms the four earlier issue journeys pass on their repaired artifact.
- [x] Pass CLI/MCP source-backlog acceptance, including source-wide counts,
  unrelated tasks before pagination, cursor, empty/missing sources and unchanged
  database/provider data. Metadata review confirms only two descriptions and
  the optional `rag_task_list.source` parameter changed; existing types/access
  and tool counts remain. The updated metadata contract test passes.
- [x] Pass full tests: 73/73.
- [x] Scottish receipt 067 confirms the source-backlog capability. Its first
  full-block result demonstrates missing discovery and no completed new-source
  extraction; T7-05 visibility passes, and T7-07 owns the separate workflow fix.

### T7-06 — select held provider outcomes directly

- [x] Record real caller gap: first block status reports two held outcomes but
  job items cannot select them from 347 dead letters. No queue scan assigned.
- [x] Extend `regression_operator_diagnostics` before implementation: existing
  live/held status and ordinary reads pass, then `--uncertainty held` fails with
  usage/unknown option. Log: `cmake-build-debug/test7-held-filter-baseline.log`.
- [x] Add optional `job.items --uncertainty all|active|held` in the existing
  query/catalogue, composing `raglifecycle.uncertainitem` and the status
  active/held state split before pagination; no schema/index/state changes.
- [x] Pass held/active/receipt/job/state/pagination controls, CLI/MCP parity and
  unchanged database. `test7-held-filter-acceptance.log`: pass in 8.60 seconds;
  argument/documentation checks and diagnosis skill validation also pass. Native
  candidate `74ac6bbc5629f2710e380d741d2f173ab0092d5fc43a2abddc4173c1190f22f4`
  is not installed. A CMake unquoted `active` literal in the first repaired test
  collided with its numeric status variable; quote corrected, asserted IDs unchanged.
- [x] Review metadata: only the two intended tools add optional parameters;
  existing fields/access/counts remain. Metadata and operator tests pass on the
  combined final candidate.
- [x] Pass the combined 74-test suite with T7-07: zero failures, exit 0,
  1045.12 seconds, session 43642. Runtime staging remains below.
- [x] A focused-tested candidate's public read-only filter obtains exactly the
  two real held IDs at generation 24641 without replacing the live installation,
  writes or provider calls. Receipt: `cmake-build-debug/test7-held-filter-live.json`.
  IDs/task states were handed back to the coordinator for ordinary recovery;
  one task is superseded and must not be blindly revived. This is a candidate
  diagnostic retest, not full-suite or installed-build qualification.
- [x] Stage after the 74-test pass and Boswell drain, at 00:54 BST. Normal
  provider reconciliation remains owned by the Scottish coordinator.
- [x] Installed caller receipt 080 returns exactly the two known held IDs.
  Recovery inspection is separately blocked by T7-08; unknown usage and the
  superseded task remain preserved.

### T7-07 — new-document discovery and dispatch did not progress

- [x] Retain first full-block result: 173 Fragments active chunks; 13 pending
  concept-review tasks at priority 600000; 160 without tasks; zero new-source
  extraction completed despite 1627 older items processed. T7-05 visibility is
  working, but the enrichment objective is not met.
- [x] Start a bounded read-only owner/controls investigation while T7-06 is
  implemented. No source reingestion or manual chunk selection workaround.
- [x] Confirm no existing configuration meets the requested phase order.
  Add optional `maintain plan --source SOURCE_ID` in the normal durable window,
  frozen in its plan/policy but excluded from knowledge identity. The shared
  source projection bounds census before pagination, dispatch, eligibility and
  completion; unscoped ranking stays unchanged. Initial focused source-window
  and source-backlog tests pass, including embedding-only and held-work controls.
- [x] Focused final checks pass 6/6 in 38.89 seconds: source maintenance/backlog,
  command arguments, documentation, durable backlog including continuation, and
  SQL performance. New source/control holds and ordinary-backlog resumption are
  covered. Unscoped retry retains its no-extra-query path, and summary policy/
  waiver reads are reused instead of duplicated.
- [x] Pass the combined full suite: 74/74, zero failures.
- [x] Stage at the 00:54 BST natural drain and hand off source-window launch.
- [x] Measure live new-document completion separately from old-backlog progress.
  One public status read at 01:36 BST confirms the Fragments window completed
  early: 173 total, 171 processed, one skipped, one dead letter for endpoint
  grounding. All workers drained; zero uncertain/incomplete outcomes. There are
  190 recorded runs (172 successes, 18 failures), 3437554 input/87496 output
  tokens, zero monetary cost. Receipt:
  `cmake-build-debug/test7-fragments-0137-status.json` (approximate filename).
  The coordinator was resumed for runner/source-summary closeout and Boswell.
  This passes source dispatch; the one content failure is retained, not green.

### T7-08 — retained provider outcome inspection rejects later configuration

- [x] Record installed caller failure: reconciliation inspection receipts
  078/079 exit 6 with “reconciliation requires the original configuration”
  before reading provider history. Later approved source registration and
  budget changes altered the selected configuration; neither held item was
  retried or applied. Fragments processing proceeds independently.
- [x] Locate the whole-snapshot check in `ragapplicationprovider.reconcile`.
  Original provider model/charging route is checked separately. Reconciliation
  currently takes the retry ceiling from selected configuration, while the
  original job's ceiling is retained in its budget-policy event.
- [x] Confirm a simple supported configuration route or add a failing
  `worker_recovery` regression with unchanged-configuration positive control.
  Cover harmless source/budget changes, original provider identity, retained
  attempt ceiling, receipt/usage settlement and idempotence.
  Original-config inspection and wrong-provider controls pass; changed source,
  budget and retry limit reproduce exit 6 in `test7-reconcile-baseline.log`.
  Selecting an old config file would restore the overly broad prerequisite,
  rather than make normal inspection work with the current policy.
- [x] Fix only the demonstrated reconciliation restriction in its shared owner;
  preserve original request identity and normal validation of retained output.
  Reconciliation now uses the original budget-policy attempt ceiling; the
  ordinary execution compatibility check is unchanged. Focused `turn-disconnect`
  acceptance passes, including atomic/idempotent settlement, known usage and
  reuse of retained output without a new generation. Build passes; candidate
  native `fd7b6537ebb73e3ea23d328a21fefbef58d7193602ef8130ebdca324bb44bbf7`.
  Logs: `test7-reconcile-build.log`, `test7-reconcile-acceptance.log` under
  `cmake-build-debug`. Installed `eb74de...` is unchanged until the next drain.
- [x] Pass focused recovery acceptance and the required full suite; update
  architecture, recovery guidance and coverage evidence for the final behavior.
  Full suite 74/74 passes, zero failures, 977.65 seconds; `worker_recovery`
  passes in 144.02 seconds. Session 34110 exit 0; log
  `cmake-build-debug/test7-reconcile-full-ctest.log`.
- [x] Install at the confirmed 03:36 BST drained boundary and hand off inspection.
- [x] Have the Scottish coordinator inspect the
  two exact held outcomes through public recovery. Preserve unavailable history,
  unknown usage and superseded work rather than treating them as completed.
  Receipts 104–107 pass inspection/apply, no new generation; 115 shows zero held
  outcomes and retained incomplete usage. The old queued/superseded tasks were
  not blindly restarted. Source-window lifecycle receipts 113/116 also pass.

### T7-09 — timeout exits exhaust the worker replacement allowance

- [x] Retain public evidence in `cmake-build-debug/test7-boswell-0257-status.json`
  and `test7-boswell-0259-workers.json`: eight requested/two live workers,
  replacement-window wait after two replacements, App Server response/byte-read
  timeouts. Processing continues; elapsed time alone is not a performance finding.
- [x] Confirm existing controls in the shared worker defaults and user guide:
  `worker.max_restarts` supports 0..10 per rolling window; the current one-hour
  window preserves history and automatically reconsiders missing slots. This is
  an operational allowance issue, not evidence that replacement itself is broken.
- [x] Hand off a temporary ceiling of ten at the next natural phase boundary,
  leaving current healthy workers running and retaining uncertainty/usage. No
  provider timeout, model, item-attempt limit or corpus evidence rule is changed.
- [x] Record public configuration apply and the next phase's effective setting;
  receipts 108–111 apply deducted remaining budgets and replacement ceiling ten;
  startup 117 confirms eight live workers with that ceiling.
- [ ] Observe normal replacement behavior if another transport failure occurs.
- [x] Restore the temporary setting during final closeout and retain any content
  failures, incomplete usage or underlying transport issue for the final report.
  Public restoration 137 passed; baseline restart ceiling two restored with
  original policy and new source registrations. No live replacement was needed
  after the ceiling changed, so that additional live observation was not exercised.

### T7-10 — controller/runner loss at Codex coordinator resumption

15 September diagnosis: both last heartbeats coincide with Desktop resuming
the Scottish coordinator; the second incident includes explicit App Server
shutdown/teardown records. See the [evidence and checked investigation plan](t7-10-controller-diagnosis-20260915.md).
Host lifecycle is the strongly supported cause; independent reproduction and
endurance confirmation remain open. The output/signal repair passes its targeted acceptance and the final full
suite has 75/76 passes, with only the separate PC-01 continuation failure.
The subsequent plain-parent-exit test passes: the controller survives its
launcher's normal exit, continues heartbeating and finishes cleanly. Parent
exit alone is therefore excluded by that bounded fixture. Closing stderr now
independently reproduces SIGPIPE and stale controller state; explicit TERM
also reproduces immediate exit without graceful drain. Neither observation
establishes the exact mechanism in the original incidents.

- [x] Retain the first event: Boswell runner 094's tool session disappeared,
  no completion receipt, controller PID absent, paused/pruned normally in
  receipts 095–103. Product cause is not established.
- [x] At 05:52 the final window again shows no workers, a stale controller and
  missing progress before its deadline; coordinator is confirming process state.
  The capture helper uses ordinary `subprocess.run` without a timeout, and
  writes its receipt only after process exit. Missing receipt therefore does
  not establish the product's exit code or signal.
- [x] Confirm the second process exit and retain final cleanup evidence.
  Coordinator receipts 129–133: pause succeeds, PID 51500 absent in the same
  launcher visibility domain, supported prune removes stale/terminal ownership;
  paused job retains 34 queued items and no live controller/workers. Runner 126
  has no receipt and session 44346 is unavailable. No product exit code inferred.
- [x] Review retained host logs and product/launcher code; correlate exact
  heartbeat/resume times, retain available shutdown evidence, and re-run the
  three process/controller-loss/restart regressions (3/3 pass).
- [x] Reproduce closed-output and catchable-signal failures independently, with
  positive controls and a busy synthetic provider drain regression.
- [x] Update core and Scottish agent guidance: inspect durable status and use
  routine authorized continuation after loss, including uncatchable SIGKILL.
- [x] Qualify the output/signal repair locally through the linked T7-10
  checklist: new tests pass; full suite 75/76 with only the separate PC-01
  failure. Exact historical host mechanism and installed endurance remain open.

### Whole-night work

- [x] Define the overnight objective, master, date/cutoff and division of work.
- [x] Obtain the Scottish coordinator's real candidate list and retained backlog.
- [x] Identify current provider, worker, quota-floor and attempt-limit settings.
- [x] Record proposed phase order, long blocks, delegated reviews and repair loop.
- [x] Update the Gemini allowance to US$20, specify initial ten-attempt settings
  and conditional tested increases, and add the later rolling-hour retry item.
- [x] Receive the requested final approval for the revised change list:
  Adrian's “Approved for launch”. Start preparation and execution now.
- [x] Launch the agreed plan with one baseline backup and recorded configuration.
- [x] Start bounded engineering supervision and sleep prevention.
- [x] Start the Scottish helper assignments and record their identities.
- [x] Repair the five old master embedding gaps and publish their vectors.
- [x] Complete embeddings-first imports of the selected new documents.
- [x] Run substantive new-document LLM processing and existing maintenance work.
  Content failures and unfinished backlog remain explicitly retained.
- [x] Process reviews and hard tasks; evaluate corpus-specific prompt changes.
  Scottish candidate guidance remains unactivated and unmeasured.
- [x] Exercise queries/relationships/citations while processing continues.
  Closeout checks: eight requests, 47 passages, 22 leads, three full citations,
  zero query provider calls/writes; `closeout-queries.md` retains the evidence.
- [ ] Reproduce, fix, stage and retest all demonstrated engineering defects.
  T7-01/03/04/05/06/07/08 have their relevant installed caller passes.
  T7-02 awaits its naturally valid proposal caller; T7-10 has a tested local
  output/signal repair, with historical signal and installed endurance open.
- [x] Observe ordinary restart/continue and preserve independently successful work.
  Fresh source-window lifecycle and exact-turn recovery pass; host-associated
  controller exits remain a separate endurance limitation.
- [x] Close out by 06:00 with actual completed and remaining work, usage, defects,
  configuration/build changes, verification, final backup and stopped supervision.
  Coordinator report closes at 05:55 BST; final receipts 137–141 pass.
  Engineering paused the sole heartbeat after checking those receipts.
  The owned bounded `caffeinate` process (PID 62472, matching original command)
  was stopped after closeout; unrelated processes were untouched.

Success means substantial useful work across the night, demonstrated recovery
and searchable new coverage, resolved actionable backlog, preserved supported
knowledge and a clear defect/remaining-work report. It does not mean inventing
answers to empty the queue or treating this one Mac run as all-platform release
certification. Execution is closed; the coordinator's final report and retained
receipts are authoritative for phase/job/usage details and remaining work.
