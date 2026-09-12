# Operator continuation: live handoff

Updated: 2026-09-12 21:54 UTC. This file is the persistent task state; update it
at every QA/commit/live-run boundary. No outcome is closed merely because one
slice compiles. Read the current Git diff and current logs before continuing.

## Authority and target

The user explicitly authorizes implementation of the complete outcome:
“An operator can continue interrupted Scottish processing, understand every
hold, and finish ingestion and maintenance through ordinary commands.”
Then update documentation/roadmap, commit when green, ingest the remaining
Scottish processing corpus, and run maintenance for **60 minutes**. Fix actual
run failures and record defects. This is an overnight run: no further approval
is required inside this scope. Do not push, modify sibling CREXX, use reset
credits, or silently waive unresolved/uncertain work. The user separately
requested persistent findings/progress so a fresh session can take over.

Authoritative checkout: `/Users/adrian/CLionProjects/crexx-rag-review`, branch
`temp/project-review`, clean baseline `0e99708`. Original cwd
`/Users/adrian/CLionProjects/crexx-rag` is unrelated older work; do not edit it.
Review checkout writes/builds/commits need sandbox escalation. Read AGENTS.md;
all product orchestration and rules stay in Level-G cREXX. No subagents are
authorized. Existing source changes in this checkout belong to this task.

## Initial checkpoint (historical; latest dated checkpoint below is authoritative)

Implementation is **in progress, uncommitted, not fully tested**. No paid
Scottish calls have started, and the processing master has not been upgraded.
No item is newly declared closed. At this initial checkpoint the public pre-run backup was running (see later completion).

Baseline recovery checks passed **6/6 in 127.87 s**:
`regression_command_metadata`, `native_lifecycle`, `configuration_contract`,
`native_supervision`, `regression_lifecycle`, `native_lifecycle_holds`.
Log: `/private/tmp/crexx-continuation-baseline.log`.

Tests added before implementation:

- `native_continuation`: same maintenance job, named renewal, idempotence,
  historic attempt/provider preservation, five successful public retries.
  Baseline failed at unknown `job continue` as intended.
- `native_legacy_retry_ceiling`: actual one-attempt old window -> new reviewed
  three-attempt window. Baseline produced **zero queued retries, expected five**.
  Previous green lifecycle cases used three in BOTH windows and missed this.
- `regression_operator_diagnostics` extended with public `job progress` and
  uncertainty query-plan coverage. Baseline rejected `job progress`.
  Independent EXPLAIN confirmed `SCAN u` over job_events for EACH item.

Evidence logs: `/private/tmp/crexx-continuation-red.log`,
`crexx-legacy-retry-red.log`, `crexx-progress-red.log` in the same directory.

First candidate processed all five continuation retries. Its history assertion
incorrectly included new attempts because recovery now uses the same job;
corrected to compare original `historic-worker` attempts only. Other original
history/paid-call assertions remain. No assertion was removed to hide a defect.

Second candidate built both routes, no full test yet:
- native SHA256 `e9a840175493a8a885039fc78a6ed49a21d7a22e3ae0558b9701229e948aa6d7`
- linked SHA256 `57ae6fececb65d9a050464d6f5377c043d8e5241d9ba9de1482b13970d0104ea`
- logs `/private/tmp/crexx-continuation-build-2.log`, configure-2.log.
- build cache now `CREXXRAG_REXX_BUILD_JOBS=8`; the WAVE output reported 83 members, which is not evidence of 83 concurrent
  processes. Use the bounded cache setting and do not interrupt unrelated jobs.

Current additions: `ragallowance` owns original allocation plus named cumulative
renewal in append-only `allowance-period` events; `ragcontinuation` composes
existing job/window owners; `job continue [--renew NAME] [--minutes N] [--prepare]`
uses the existing worker launcher. `--prepare` records/prepares but makes no
provider call. Repeat NAME cannot add allowance or move the deadline; different
minutes under the same NAME must fail. Original task attempts and per-call
ceilings remain. `job progress` groups actual items by immutable input source
and operation, partitioning deferred from queued. Item inspection includes
source and retry facts. `job list` no longer embeds full plans; `job plan` is
the existing full paged read. Gemini example defaults changed from one to three
attempts; explicit existing configurations remain unchanged.

Schema 16 is additive: item/event lookup index, unique named allowance index,
and immutable allowance update/delete triggers. Earlier migration statements
and checksums are unchanged. `taskretryfacts` in ragbacklog is shared by retry
execution and status. A compatible active reviewed policy supplies the current
cumulative ceiling; historic calls are not reset.

**Prepared but not yet applied at this timestamp**:
`/private/tmp/continuation-refinement.patch` (generated by
`refine-continuation.py`) adds recorded renewal deadline, normal maintenance
cleanup timing, shared retry reconsideration, compatible worker-count config
registration, paused hold descriptions and provider-time usage reporting.
`/private/tmp/continuation-vm-modules.patch` adds new owners to raw VM module
lists, which use bare module names rather than .crexx paths. Apply these before
next build. Inspect patch and test; do not assume they are correct.

Composition tests already added expect the config-registration refinement:
change fixture worker.processes 2 -> 3, assert one operational config event and
unchanged original job snapshot. CLI and MCP repeat an ordinary ingestion
renewal without paid calls. Immutable allowance deletion and conflicting
minutes are negative controls. `native_continuation` currently uses the normal
five-failure fixture; add equivalent uncertainty/exhaustion protection if not
already adequately covered by native_lifecycle_holds and the actual continuation.

## Real Scottish scope

Processing master:
`/Users/adrian/testrag/overnight-scottish-20260909/library`
Selected policy:
`/Users/adrian/testrag/overnight-scottish-20260909/crexxrag.conf`
Ingestion job:
`job-sha256:fe38ada198b6c153eec6133810988200c510f9b37c9665d7d8583bc6a4938622`

Do NOT resume `/Users/adrian/Documents/ScottishHistory`: its README identifies
it as an independent query copy whose queued execution history was deliberately
cancelled for relocated configuration registration. Do not mutate it.

Original eight sources are already imported/normalized/chunked. “The rest” is
remaining extraction/validation and five missing embeddings, not a full source
reimport. Dated Sept11 report (must refresh before asserting current): 31,578
items; 14,536 processed, 15,321 skipped, 1,206 queued, 515 held/dead letters;
34,900/34,905 chunks embedded; aggregate provider time reached 72h allowance.
Maintenance backlog contains genuine evidence/review holds. Do not waive these
or fabricate completion to obtain an empty queue.

Current public job list confirms that ingestion job is paused and the original
embedding job `job-maintenance:cf5808df5d3703bf71ff2ec0881f5660e65b14741f6dcbbade1f34d6e5815fbf`
still exists. Full list saved `/private/tmp/scottish-baseline-jobs.json`.
Baseline `job status` ran >several minutes at 100% CPU due to missing event item
index and was stopped (only PID 16079 from this task). Public `worker list
--state running --limit 100` returned no rows. `worker status` requires a
process ID; general diagnostic prose should say `worker list` first.

New backup target:
`/Users/adrian/testrag/overnight-scottish-20260909/continuation-20260912/before`
Running via frozen baseline public `library backup`; execution session **27263**,
log `/private/tmp/scottish-continuation-backup.log`. Do not assume completion
until final exit/result. This is a generation-pinned SQLite+sidecar backup.
Next restore a scratch qualification copy through public `library restore`,
upgrade/test the exact green committed candidate there, then resume master.
The master SQLite file is ~2.6 GB. No ad hoc SQL/data repairs in the live journey.

Policy currently uses managed Codex App Server gpt-5.6-luna low for extraction,
Gemini embedding-2 (768 dimensions), workers 8, individual provider max_attempts
1, maintenance.maximum_attempts 1. Budget: 4320 provider minutes, 50000 items and
calls, 1e9 input / 3e8 output tokens, 5e6 monetary microunits, 30000 Codex turns,
minimum Codex allowance 10%. Maintenance provider time is intentionally disabled
(0); wall-clock remains bounded. Use existing symbolic env credential only.
User's new scope authorizes remaining ingestion plus 60 minutes maintenance,
not unlimited retries of unknown paid outcomes. Renew explicit periods and
retain ordinary provider/account limits. Do not reuse old unreviewed wrappers.

## Remaining work, in order

1. Apply pending refinements/module-list patch; build; run new focused tests.
   Fix actual failures, then add missing controls (unknown outcomes, exhausted
   tasks, renewal rollback, ordinary allowance consumption and config handling).
2. Review boundaries carefully: stale owners must not duplicate claims; a
   retry request may be pending without execution authority; repeated period
   must retain limits/deadline; maintenance cleanup must use existing time owner.
   New modules must be linked on BOTH VMs and native installation.
3. Update authoritative docs/roadmap/coverage/architecture and human/agent
   guidance for the complete outcome. Read skill-creator (already read) before
   skill edits; preserve access boundaries. User already authorized this task,
   so skills must not invent another approval pause. Keep diagnostic skills read-only.
4. Full automated QA (baseline was 59 tests; new registrations make 61),
   installed exact-artifact journey, `git diff --check`, inspect final diff.
   Update command metadata contract hashes only after reviewing exact changes.
5. Commit locally when all required gates are green; no push. Record exact SHA
   and native/linked artifact hashes here and in run evidence.
6. Complete/verify backup + restored copy, then use public commands on actual
   processing master to finish eligible ingestion and exactly 60-minute
   maintenance period. Monitor ordinary status/progress/items/attempts/events,
   requests/receipts and worker/provider state. Fix bounded real failures and
   record outstanding evidence/review/uncertainty honestly. No silent blanket
   waiver or invented evidence. Preserve unrelated paused jobs/query copy.
7. Record run start/stop, allowances, actual paid calls/usage, coverage and all
   defects with reproduction, owner, exact artifact and whether blocking.
   Report actual closure versus incomplete requirements; smoke pending is not
   an excuse to call known missing implementation complete.

Use `caffeinate -i` for long local commands. Poll tool sessions with waits <=60s
and communicate meaningful progress. No new approval should be requested for
already authorized work. Escalate workspace/corpus writes as needed through
normal tool review. If forced to stop, update this file first with exact state.

## Checkpoint 2026-09-12 20:43 UTC

Both pending refinement/module-list patches above are now applied. Build 3 is
running (tool session 2237, `/private/tmp/crexx-continuation-build-3.log`). The
second-candidate focused gate passed operator diagnostics and the true legacy
retry ceiling; continuation failed exactly at missing compatible config
registration (expected event 1, actual 0), now implemented in build 3. Test log
`/private/tmp/crexx-continuation-focused-2.log`.

Backup and restore both completed successfully at generation 23208, one sidecar,
680391 SQLite pages. Qualification library now exists at the path above. Logs
`/private/tmp/scottish-continuation-backup.log` and
`/private/tmp/scottish-continuation-restore.log`. Master remains untouched and no
paid calls have started. General worker inspection is `worker list`; worker
status needs an explicit process ID.

Human/architecture/roadmap/coverage and ingest/maintain/diagnose skill updates
are drafted. `documentation_contract` passes. New operator guide is
`docs/operator-continuation.md`. Skills add public progress and explicitly
operator-authorized continuation (diagnose stays read-only). Remaining test,
full QA, commit and live-run steps above still apply. Do not claim closure.

## Checkpoint 2026-09-12 20:55 UTC

The current implementation is still uncommitted, with no paid calls and no
master-library mutation. Build 5 is running (session 36950,
`/private/tmp/crexx-continuation-build-5.log`). All prior sessions are finished.
All pending patches described above have been applied.

Focused gate 3 passed 6/6 in 45.43 seconds, including both raw-VM lifecycle
routes, diagnostics, legacy ceiling and continuation with retained exhausted
and uncertain tasks. Gate 4 passed 5/5 in 31.67 seconds: metadata, documentation,
supervision and both continuation cases. Copy both logs into the evidence
folder at the next gate. No full suite has run yet for this candidate.

Two additional test-first findings:

- With no recent controller event, status reported zero configured workers.
  The red fixture expected three and got zero. The fix reads selected canonical
  configuration and the existing worker-default owner; it separately reports
  live workers, historic requested count and controller heartbeat/state.
- Explicit embedding allowance six with reasoning allowance one still queued
  zero retries (expected five). Build 5 centralises the effective retry ceiling
  in ragbacklog, with explicit embedding precedence and legacy fallback. The
  new `native_embedding_retry_policy` reproduces this independently. Full test
  registration is now **63**, including four new tests versus baseline 59.

Frozen complete candidate 4: `/private/tmp/crexx-continuation-candidate4`;
SHA256 `323f26ff8888e74e4acc5f769f07b05167bb6b9772d5a3c03d9dcd8d110db7d3`.
Do not test the package path while the build replaces it. The explicit embedding
red log is `/private/tmp/crexx-explicit-embedding-policy-red.log`.

Public backup/restore succeeded (generation 23208, one sidecar, 680391 pages).
On `continuation-20260912/qualification-library` only, candidate 3 upgraded to
schema 16 and prepared `qualification-only` named renewal with provider_calls 0.
Status took 0.777 s, progress 0.378 s, five held items 0.187 s. Verified workload:
31578 total, 14536 processed, 15321 skipped, 1206 queued, 515 dead letters;
no running/cancelled items. There are two uncertain items and ten incomplete
usage observations. Provider history: 20809 runs, 17846 succeeded, 2961 failed,
two other; 258346621 ms recorded provider time. All this is qualification-copy
state, not permission to assume the master was changed.

Queued extraction by source: Browne IV 474, III 360, II 319, Johnson 51,
McPherson 2. Held work: 510 extraction plus five embedding items. Sampled holds
are actual literal-quotation/endpoint validation failures. Do not relax evidence
validation or clear them merely to claim ingestion complete. The two uncertain
outcomes require public receipt/reconciliation inspection before any retry.

Next: finish build 5; focused embedding/continuation/legacy tests; full 63-test
suite; exact installed-artefact continuation check; final review/docs/gate;
commit; then public master continuation and the real 60-minute maintenance
journey. Record the exact committed artifact and all unresolved holds before
claiming any outcome closed. Update this handoff at each gate.

## Checkpoint 2026-09-12 21:01 UTC

Build 5 finished. Focused gate 5 **6/6 passed in 113.35 seconds**, including the
explicit embedding policy regression. The full **63-test** suite is running as
session **30576**, log `/private/tmp/crexx-continuation-full-qa.log`. Do not run
another full suite concurrently. Its first 14 tests have passed. No product
code has changed since this build.

Candidate native SHA256:
`7130539505b72fe475cdf83407d7f50df06dcb83290c52a0e7c116ff3d41522d`.
Linked SHA256:
`8e5482f719248e4366ed6a3c3d9d91acedd5ff05902fd572bb3fd91a9c3750b6`.
Public status on the qualification copy now correctly reports eight configured
workers, zero live, no active controller and an actionable continuation hold.

All 515 retained failures were read through six ordinary `job items` pages
(no live SQL): 487 content-validation failures, 28 operational/allowance or
embedding failures. Full reason totals and both uncertain item identities are
in `docs/qa/operator-continuation-20260912/scottish-qualification-hold-inventory.json`.
Raw pages remain `/private/tmp/scottish-qualification-held-page1.json` through
page6.json. The two unknown items end `...7aa0ac2c` and `...a077078`; use full IDs
from the inventory, inspect `job reconcile` before any apply/retry.

After the full gate, freeze/install the exact artifact and run the public
continuation/held lifecycle recipe against that installed binary. Update docs
with the actual full result, commit, then start the master. The master remains
unchanged and **no paid calls have started**. Read the full hold inventory when
planning recovery; content validation must not be weakened to empty the queue.

## Checkpoint 2026-09-12 21:09 UTC — full gate found a regression

Full suite session 30576 is still running on candidate 5 (reached test 44).
`installed_product` failed its existing plan-detail regression: small job plan
value should be `{}` but the attempted job-list compact projection returned
empty text while `value_complete` remained true. This is a regression introduced
in this task, not a pre-existing defect. **Do not commit candidate 5.**

The speculative `ragrepository` compact-list change has been removed from the
source diff, restoring HEAD's established bounded summary/detail contract.
The native candidate has not yet been rebuilt. Wait for the current full suite
to finish so later defects are captured; then build 6, run the affected
plan-detail/installed acceptance and the full suite. No other product change
has been made since build 5. The earlier compact-list claim in this chronological
log is superseded. Status indexing and new progress/hold diagnostics remain.

The separate scratch-installed continuation-with-holds journey passed on the
exact candidate-5 hash. It now also checks five-source pagination, source and
operation filters, CLI/MCP agreement, and refusal to renew during owned work.
Its first invocation exposed only a test harness empty-cursor argument; corrected
the first page to omit the optional flag, preserving all assertions. Both logs
are retained. Full-suite cases 60/62 will execute these additional assertions.

The no-provider `doctor` on the Scottish qualification copy passed with zero
issues and aligned manifest. No master mutation or paid call has occurred.
Next build/full gate/commit/live-run steps remain outstanding.

## Checkpoint 2026-09-12 21:12 UTC — rebuild after complete first gate

First full suite finished: **61/63 passed in 778.85 seconds**. The two failures
were the same job-list compatibility regression in `installed_product` and
`regression_plan_detail`; all other tests, including the strengthened new
continuation controls, passed. Full log is retained as
`docs/qa/operator-continuation-20260912/full-qa-first.log`.

Build 6 is running, session **90163**, log
`/private/tmp/crexx-continuation-build-6.log`. Its only product change from
candidate 5 is restoration of baseline `ragrepository` job-list projection.
Next run affected plan-detail acceptance, then the whole 63-test suite again.
Reinstall the resulting exact candidate into the scratch qualified prefix and
repeat its continuation-with-holds journey. Update evidence and commit only
when green. No paid calls or master mutation yet.

A provider-free public `library report` was also retained for comparison.
Generation 23208: eight sources, 34905 chunks; 34900 active/published embeddings;
4190 pending reviews; 30606 durable open maintenance tasks; 18 migrating
workflows. Historical job-wide dead-letter totals are much larger than the
selected remaining-ingestion job's 515 and must not be conflated with unique
coverage or this run's failures. All storage/repository/provenance checks pass.
The requested maintenance run is a 60-minute interval, not a promise that every
existing cognitive/review backlog question can finish in that interval.

## Checkpoint 2026-09-12 21:20 UTC — second gate and race investigation

Build 6 finished. Native SHA256
`71645584c3811f0f6ae0fb9f7f6a958ae09d372671ee91908f9d7795a28e2ef7`;
linked `e8a4eb75df5c0c048d22a91c76691496ea7a285de294c1386f26c493fe550d71`.
`regression_plan_detail` passes in 7.73 seconds. The repaired scratch-installed
continuation-with-holds journey also passes (log `crexx-continuation-installed-final.log`).
The prefix `/private/tmp/crexx-continuation-qualified-prefix` contains build 6.

Second full suite is running, session **42329**, log
`/private/tmp/crexx-continuation-full-qa-final.log`. **It is not green:**
`regression_supervision` failed once with only one `RACE=0` result; the second
RXBVM process emitted nothing and exited before reservation reporting. Main
RXVME/RXBVM scenarios passed, and native supervision passed afterward.
Original failing scratch state is copied to
`/private/tmp/crexx-supervision-race-first-failure`.

Do not dismiss this as a flaky test or weaken its one-winner assertion. A
standalone 30-iteration reproduction is running, session **74604**, log
`/private/tmp/crexx-supervision-race-repro.log`. It uses the existing harness
and `/private/tmp/supervision-race-diagnostic.crexx`, which only prints the
previously silent openragstore error. Workdirs are
`/private/tmp/crexx-supervision-race-repro-N`. At least five iterations passed.
Potential mechanism (not yet proven): simultaneous readwrite opens both enable
WAL, while closeragstore best-effort converts a closed bundle back to DELETE.
The existing open uses a 5-second SQLite busy timeout but no outer retry for
journal-mode acquisition. Capture exact diagnostics before changing product.
No product change since build 6; source fixture has not yet been edited.

Read-only public `job reconcile` on the qualification copy successfully observed
both retained uncertain Codex turns as **interrupted**, with zero generation
calls and incomplete usage retained as lower bounds. Observation files are
copied into the repo evidence folder. On the master after the green commit,
inspect again while paused/drained, then apply only those exact observed
digests. Master still has not been changed; no paid generation has started.

Remaining: finish/reproduce/fix the race if needed, green full QA, update
current docs, commit, then actual master recovery/ingestion and 60-minute
maintenance. Preserve the cutoff/allowance/history and do not silently clear
content holds. Update this checkpoint before a compaction or handoff.

## Checkpoint 2026-09-12 21:33 UTC — startup race reproduced and fixed in source

The second full gate completed **62/63 in 866.30 seconds**. Only the intermittent
`regression_supervision` concurrent-open case failed; installed-product and
plan-detail compatibility are now green. Log copied as `full-qa-second.log`.

The startup race reproduced at isolated iteration **95** with exact evidence:
`RXBVM concurrent reservation exit=1 left=2 right=0`;
`RACE_OPEN_FAIL=enable WAL: database is locked [boundary=-6,sqlite=5,extended=5,operation=exec]`.
The earlier 94 passing iterations and 1600 successful open/close stress cycles
had not disproved the race. Logs/scratch recipes are in the repo evidence.
The first failed original fixture remains in `/private/tmp/crexx-supervision-race-first-failure`;
exact diagnosed reproduction is `/private/tmp/crexx-supervision-race-repro-95`.

A deterministic regression was then added **before product repair**: a separate
SQLite connection holds an exclusive DELETE-journal lock until the product
reports its first BUSY retry, then releases it. Both RXVME and RXBVM failed at
`enable WAL` on candidate 6, as intended. Red log `crexx-wal-acquisition-red.log`
(15.47 seconds). The test retains the normal five-second busy timeout and uses
a handshake, not a release sleep. The supervision fixture also now preserves
both child exit codes/stderr and prints the previously silent open error.

Product repair is applied in `ragstore`: `_acquirelock` shares the existing
six-attempt BUSY/BUSY_RECOVERY policy between `BEGIN IMMEDIATE` and
`PRAGMA journal_mode=WAL`. No transaction body or provider call is replayed;
non-busy and BUSY_SNAPSHOT errors remain errors. No provider implementation or
SQL schema was changed for this fix. This addresses the observed opening race
rather than modifying worker replacement eligibility.

**Build 7 is running**, session **84460**, log
`/private/tmp/crexx-continuation-build-7.log`. All earlier tool sessions have
finished. Do not test a partially repackaged executable. Product is still
uncommitted. Master unchanged; no paid generation calls.

Next: finish build 7, run controlled `regression_supervision`, publication,
process/native supervision and continuation/held acceptance as needed; repeat
the full 63-test gate on this artifact; scratch install/exact continuation;
update docs/roadmap and commit. Then reobserve/apply the two confirmed
interrupted master outcomes through public commands, renew/continue retained
ingestion, repair the five missing embeddings through reviewed policy/window
controls, and run maintenance for 60 minutes. Record actual calls, holds,
unique coverage and defects. Never mark incomplete implementation as closed.

## Checkpoint 2026-09-12 21:41 UTC — startup repair focused gate green

Build 7 finished. Native SHA256
`8015c65a512698b135c3409cec15c65a82c878738ebcaef9c04a7c5f1b9bc9df`;
linked `6040aa5f6228482cf86d870c6d701bc59cd9da789bf4d53b684ebeed9e4aef2c`.
The scratch prefix `/private/tmp/crexx-continuation-qualified-prefix` now contains
this artifact. No product source changes since build 7.

Focused repair gate passed **4/4 in 115.50 seconds**: controlled two-VM
`regression_supervision` (15.73 s), `native_supervision`, `publication` and
`native_continuation_holds`. The WAL test observed the real first BUSY retry on
both VMs, then successful open, and compared complete logical SQLite dumps
before/after to require unchanged records. Retry traces and focused log are in
the repo evidence directory. The earlier unexplained race is now a reproduced,
repaired startup defect, not an unresolved flaky-test classification.

Third full **63-test** gate is running, session **52184**, log
`/private/tmp/crexx-continuation-full-qa-third.log`. This is the required final
gate before commit. The separate installed build-7 continuation/held journey
is running as session **51358**, log
`/private/tmp/crexx-continuation-installed-build7.log`.
All earlier tool sessions are complete. Build/package paths are stable.

Next: wait for these gates, inspect any failures without weakening tests;
copy final logs, update current qualification/roadmap status and commit all this
authorized work locally. Then the public master reconciliation/ingestion and
60-minute maintenance run. Master remains unchanged and no paid generation
has started. The two external observations from build 6 remain retained evidence;
reobserve on the master with the committed build before digest-checked apply.

## Checkpoint 2026-09-12 21:49 UTC — installed journey and actual reconciliation rehearsal passed

Installed build-7 recovery completed: `LIFECYCLE_RECOVERY_OK failures=5 calls=3
history=preserved requests=durable live-owner=deduplicated`. Log is retained as
`installed-build7.log`. Third full gate remains running, session 52184; first 39
cases passed at this checkpoint, no failure yet. Product source unchanged.

Both actual uncertain Codex turns were reobserved and digest-checked applied
through public `job reconcile` on the **qualification copy only**, after pausing
it. Both were terminal interrupted with no output. Public status is paused,
1206 queued, 515 dead letters, zero running and now **zero uncertain items**.
Recorded provider runs remain **20809**, provider time 258346621 ms and recorded
tokens/cost unchanged. Two previously unknown records are now failed;
12 incomplete usage observations remain explicitly lower bounds. No generation
call was made. Original attempts and provider identities were not replaced.

One automatic review initially rejected pausing this outside-workspace copy.
The rejection was disclosed. Original public restore logs proved fresh-target
creation; filesystem verification showed distinct master/copy inodes 54423092
and 55512124, link count one and no symlinks. The exact action was approved on
retry with this evidence. This was an isolated rehearsal, not the master.

Master remains unchanged. After full green/docs/commit, repeat observation and
apply on the master using the committed artifact, then explicit named renewal
and configured eight-worker continuation. Remaining paid ingestion and the
60-minute maintenance run have **not started**. Do not report the whole outcome
complete. The copy's period `qualification-only` must never be confused with
actual master authorization/history.

## Checkpoint 2026-09-12 21:54 UTC — implementation qualification green

Third full gate completed **63/63 in 848.41 seconds**, with no disabled
or weakened case. Earlier failures remain in retained evidence: job-list
compatibility regression was reverted; concurrent WAL opening was reproduced
and fixed with a deterministic two-VM test. Build 7 product files are unchanged
since their build. Scratch-installed recovery and real interrupted-turn rehearsal
on the isolated copy also passed. Final logs copied into repo evidence.

Next: final documentation/whitespace review, local commit, then run the exact
qualified executable against the processing master. It remains unchanged at
this checkpoint; no new Scottish generation has run. Real ingestion and the
60-minute maintenance outcome are still pending, not closed by local QA.
