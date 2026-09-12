# Operator continuation: live handoff

Updated: 2026-09-12 23:06 UTC. This file is the persistent task state; update it
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

## Checkpoint 2026-09-12 21:59 UTC — committed; master recovery and run launched

Implementation commit **702af3a** (`702af3a` resolves in temp/project-review),
full QA 63/63 in 848.41 seconds and final docs contract green. Clean checkout
was verified immediately after commit. Only later live evidence/notes should
be dirty. No push. Exact installed executable is now durable under the run:
`/Users/adrian/testrag/overnight-scottish-20260909/continuation-20260912/artifact/bin/crexxrag`.
Its SHA256 is **8015c65a512698b135c3409cec15c65a82c878738ebcaef9c04a7c5f1b9bc9df**,
identical to build 7 and installed qualification. Use this `CREXXRAG_SELF` path
for children. The run directory also stores `implementation-commit.txt`.

Master has now migrated normally to schema16 at unchanged generation23208.
The pre-migration read-only status remained running after 35 seconds because
schema15 lacks the new item/event index; only that observed read PID72780 was
terminated. `job pause` opened/migrated the library but returned unavailable
because the job was already paused. Indexed public status then confirmed
paused/1206queued/515dead/0running/2uncertain. Worker inventory retained historic
stale entries, which normal continuation prunes; no external work was assumed
uncalled from those entries.

Both master Codex turns were freshly observed as interrupted and applied by
exact digest through public `job reconcile`. The commands succeeded with zero
generation calls. Named `job continue --renew scottish-ingestion-20260912
--prepare` then succeeded with provider_calls0. Original plans and histories
remain; aggregate limits gained one original allocation. Existing per-task
one-attempt policy is unchanged. Run snapshots are retained beside the artifact
and copied into repo QA evidence.

At **21:58:27 UTC**, detached launcher PID **72923** started ordinary `job run`
for ingestion job `job-sha256:fe38ada198b6c153eec6133810988200c510f9b37c9665d7d8583bc6a4938622`
under caffeinate with the selected original policy/configured8workers.
Logs in the run directory: `ingestion.log`, `ingestion.err`,
`ingestion-launcher.log`, `ingestion-started.txt`; `ingestion.exit` is written
only after the command terminates. Initial launch alone does not yet prove
provider activity; confirm current process/public status and useful work next.
Do not launch a duplicate supervisor. The process is detached to survive context
or session takeover; no new shell-owned product workflow was introduced.

Remaining work: monitor actual ingestion and fix run problems; inspect all
resulting holds and preserve strict evidence. The known baseline includes
487 content-validation holds, 23 operational extraction holds and five missing
embeddings; reconcile current public inventory before retry/replay decisions.
Ingestion retry requests respect original ceilings; reviewed replay/new work
must use ordinary controls and preserve lineage. Afterwards use the single
policy file's public config controls to authorize reasonable retry settings
(three reasoning, explicit six embedding as previously agreed), public
config plan/apply, request the five failed tasks and use a reviewed embedding
repair window. Do not blindly replay unknown outcomes or overwrite old budgets.
Run ordinary automatic maintenance for **60 minutes** under the configured
policy/managed authentication/account reserve; record the actual start/deadline,
stop, outcomes/usage, unique coverage and every failure. Maintenance has not yet
started. Record functional remainders honestly and finish docs/roadmap/evidence
with a final local commit; do not call the entire outcome complete yet.

## Checkpoint 2026-09-12 22:01 UTC — persistent session replaces ended launcher

The detached launcher PID72923 and its descendants were absent on the next
process check; no exit marker or worker-start output was produced. Do not rely
on shell backgrounding across this command runner. Public status afterward
proved no live workers, no reservations/uncertain items and unchanged 20809
provider runs. The durable job was running with 1206 queued and the one named
allowance. This was a launch-execution problem, not evidence of failed paid work.

Ordinary `job run` was then started in **persistent exec session 70061** at
22:00 UTC, using the same artifact/config/job/allowance. New authoritative logs:
`ingestion-session.log`, `ingestion-session.err`,
`ingestion-session-started.txt`, and terminal `ingestion-session.exit`, all in
`/Users/adrian/testrag/overnight-scottish-20260909/continuation-20260912`.
The controller now reports `start workers=8`. One worker has logged its first
bounded heartbeat SQLITE_BUSY retry. Public progress/worker snapshot is being
captured; actual useful work is not yet confirmed at this checkpoint.

An optional 10-minute recurring heartbeat was requested for takeover, but automatic
approval review rejected it as insufficiently bounded future paid-processing
scope/automation authority. The rejection was disclosed; **no automation exists**
for this run. Do not silently recreate it or implement a workaround scheduler.
Continue the already-authorized work in this active session. Older Scottish
heartbeats are PAUSED and belong to other runs; leave them unchanged.

## Checkpoint 2026-09-12 22:07 UTC — useful live work; diagnostic regression reproduced

The first live snapshot at 22:01:34 showed 20 new processed items, 5 valid skips,
1 new dead letter,1172queued/8running and all 8 live workers. Controller
`controller-9ca4b364b485551aed8787993ff4d264`, PID73021, had a one-second
heartbeat and zero replacements. Worker PIDs73023-73030. Multiple heartbeat
and one transaction-acquisition BUSY retries were logged; no worker exit yet.
Snapshot/evidence files `scottish-master-live-status-1.json` and
`scottish-master-live-workers-1.json` are retained in repo QA.

**RAG-SMK-001** found during smoke: normal active provider intents appear in
`uncertain_items`, and active-item guidance incorrectly recommends reconcile.
Do not interpret the five unmatched live intents as five held failures. A new
synthetic public regression first passed the old status control, then failed
on the active item's erroneous next action (red 0.64 s). Its distinct held unknown
and matched receipt control the counts. Source repair in ragusage and
ragoperationsquery adds `active_unsettled_items`/`held_uncertain_items`, preserving
the old total and all accounting/guard semantics; active ownership guidance
comes first. Test and docs changes are uncommitted after 702af3a.

Candidate8 build is running, session **40745**, log
`/private/tmp/crexx-active-outcome-build8.log`. Do not change the live frozen
artifact yet. Next: finish build, focused diagnostics/continuation-held gate,
then required full63 and installed evidence before a separate fix commit.
Meanwhile actual ingestion continues in **session 70061** and its authoritative
`ingestion-session.*` logs. No automation was created. Continue active monitoring
and retain logs/holds/usage. Remaining ingestion, operational recovery,
five-embedding repair and 60-minute maintenance are still outstanding.

## Checkpoint 2026-09-12 22:11 UTC — five retry requests accepted; diagnostic QA running

All five actual failed embedding tasks were inspected through public `job items`
on original maintenance job cf5808df5d3703bf71ff2ec0881f5660e65b14741f6dcbbade1f34d6e5815fbf.
Each has one confirmed quota-failed call, no uncertainty and an explicit
attempt-limit hold. Public `maintain retry` accepted every request; repeating
the first returned the same request ID with retry_accepted=0. No embedding call
has been made; repair still needs a reviewed policy/window after ingestion.
Exact task IDs/requests: `scottish-five-embedding-holds.json` and
`scottish-embedding-retry-request-*.json` in repo evidence and run directory.
Do not repeat selection by guessing task IDs or equate acceptance with coverage.

At 22:09:53 UTC the ingestion status was 1032 queued, 6 running, 14666 processed,
15356 skipped, 518 dead letters; all 8 live workers, zero replacements,
21009 provider runs. Relative to start: 130 processed, 35 skips and 3 new holds.
Content and operational hold classification must be checked after drainage;
normal active unmatched intents are not final unknown holds.

Candidate 8 build completed. Native hash
`af99d5e94405942834cbd19c3957c143d0bb3082c3561612fda54c57702f3ee6`,
linked `7038e88785f08571af7a404b17421c7502d3a286adfd47d65f025e5cea248c9b`.
Focused diagnostic/held/docs gate passed **3/3 in 26.98 seconds**. Full 63-test
gate is running as **session 65462**, log `/private/tmp/crexx-active-outcome-full.log`.
A separate scratch install/public diagnostics check is running under
`/private/tmp/crexx-active-outcome-installed`, log
`/private/tmp/crexx-active-outcome-installed-check.log`. No product source changes
since candidate 8 build. Commit the diagnostic repair only after full green;
keep live 702af3a executable untouched until its supervisor drains.

Actual ingestion remains **session 70061** with `ingestion-session.*` logs.
No recurring automation exists. Continue the active run, maintain durable
checkpoints, finish eligible remaining work/embedding recovery and the requested
60-minute maintenance, then verify/record/commit final outcomes. No push.

## Checkpoint 2026-09-12 22:26 UTC — diagnostic repair fully green

Candidate 8 full suite passed **63/63 in 933.50 seconds**, with its separate
installed CLI/MCP diagnostic check also passing. Focused gate was3/3 in26.98s.
RAG-SMK-001 is repaired and qualified; the old unmatched-intent total is retained,
active/held parts are disjoint, and active item guidance respects ownership.
No accounting, budget, attempt, recovery or publication rule changed.

Next: final whitespace/docs review and local fix commit, then install candidate8
to a NEW run prefix so the existing live 702af3a supervisor/children keep their
frozen executable. Public read-only status can validate the new diagnostics
on real in-flight work; later recovery and maintenance can use the new artifact
once the current supervisor drains. Actual ingestion remains session70061 and
its ingestion-session logs; no recurring automation exists. Remaining original
queued work, operational recovery, five missing embeddings and the60-minute
maintenance still need completion. Do not report the whole outcome closed.

## Checkpoint 2026-09-12 22:34 UTC — diagnostic committed; first real worker crash

Diagnostic repair committed **d1cc6f5**, full 63/63 in 933.50 seconds and installed
CLI/MCP check green. Installed to separate run prefix
`continuation-20260912/artifact-diagnostics/bin/crexxrag`, native hash
`af99d5e94405942834cbd19c3957c143d0bb3082c3561612fda54c57702f3ee6`.
Use this for diagnostics; existing ingestion children remain on702af3a under
`artifact/bin/crexxrag`. Real read-only status verified disjoint active/held
counts, and seven active item records gave correct worker guidance.

At22:27:14 status showed736queued/6running/14883processed/15424skipped/529dead,
7live workers and zero replacements. Its six unmatched outcomes divided into
five active and **one held**. Logs show a real panic:
`PANIC: Invalid UTF-8 in binary-to-string conversion (SIGNAL UNICODE_ERROR)`.
Worker `worker-eeaf2d2bfcee39b8117e9e8054b241ff`, PID73027, exited9 after
registration. Public status confirmed failed/not-running. The controller and
seven peers continue. Full pre-recovery log is `ingestion-failure-1.err` in the
run directory; worker snapshots are in repo evidence. This is now a confirmed
run defect **RAG-SMK-002**, not a normal contention retry or content rejection.

Six public held-item pages identified exactly one uncertain item:
`item-sha256:f385bee6340faf49dba0990fbca56c42ecd56e1e93c5fb24ecbddba486e15c3c`,
attempt4, Browne volume4, last reason lease-expired. Exact public reconciliation
inspection returned interrupted/no output, incomplete usage0 lower bound,
provider_calls0. Provider run `provider-run-sha256:01c2557d1ce2ddbadd1483843d909b0ddef18492458aa3109cd89e748c7b12e0`,
thread `01a097ba-7fd3-7c30-b624-f51b177bddd9`,
turn `01a097ba-809f-74e3-95d9-f4d7d09c03f7`,
digest `90ce81e20d097859b0d5b5a9142f859c9cd1eb2c96b3349a95fa2d1590c0281b`.
Observation saved as `scottish-utf8-crash-observe.json`; **not applied yet**
because healthy workers are still active. Reobserve/apply only after public
pause/drain, then use normal retry/replay as eligible. Never assume a crash was
uncalled or erase its reservation/unknown usage.

Source investigation: `crexx/providers/codex_provider.crexx` stores `_read_buffer`
as string and casts each byte-endpoint read to string before newline framing
(line495 at d1cc6f5). A split multibyte character can therefore panic even when
the overall JSONL is valid. This is a concrete suspected mechanism, not yet a
captured live raw stream. Add regression before repair: fixture now splits
valid2/3/4-byte characters and emits separately a complete invalid UTF-8 frame;
probe requires exact Unicode roundtrip or bounded error. `codex_protocol` runs
both VMs/noopt+opt. **Red is running session80517**, log
`/private/tmp/crexx-codex-utf8-red.log`. Only test files have changed afterd1cc6f5;
no provider implementation repair has been applied yet.

Likely narrow repair after confirmed red: accumulate `.binary`, find newline
with byte functions, then decode a complete bounded frame; catch unicode_error
as a provider transport/format failure, preserving existing response recovery.
Do not modify CREXX or relax source validation. Provider changes require focused
Codex protocol/application/recovery plus Gemini/negative controls, full63 and
installed qualification before commit/new live artifact. Existing supervisor
only replaces exit75 or clean exhausted workers, so native panic9 is currently
not automatically replaced; do not broaden exit policy without evidence.

Continue observing ingestion session70061 and its logs while preparing the fix.
If further faults materially degrade the pool, preserve evidence and publicly
pause/drain before recovery; never overlap groups. Finish remaining ingestion,
reviewed operational recovery, the five embedding requests already recorded,
and the60-minute maintenance. No recurring automation exists or is authorized
by automatic review. Current proof must be updated before another compaction.

## Checkpoint 2026-09-12 22:38 UTC — UTF-8 framing mechanism reproduced and fixed

`codex_protocol` reproduced all eight expected panics (valid fragments and
invalid frame, both VMs/noopt+opt), red35.86s. Source repair is now applied in
`crexx/providers/codex_provider.crexx`: binary accumulation, byte newline search,
complete-frame conversion and caught unicode_error. No CREXX modification,
provider generation policy or response-validation weakening. The existing4MiB
ceiling is counted as bytes. Protocol/17,000-cycle regression passed41.61s.
The exact live raw fragment was not captured; this reproduces and removes the
matching panic mechanism including both valid fragmentation and invalid input.

**Build9 is running**; log `/private/tmp/crexx-codex-utf8-build9.log`.
Product is uncommitted afterd1cc6f5. Next: finish build, focused provider/Codex
application/recovery/Gemini negatives, required full63 and scratch-installed
qualification. Then local commit/new run prefix, preserve live evidence,
public pause/drain, reobserve/apply the retained interrupted crash turn and
continue the SAME ingestion allowance with the new artifact. Keep queued and
held work/history intact; do not create a new allowance period to replace workers.

The live run remains session70061 using original702af3a; its log still shows
exactly one panic/worker failure. Seven peers continue; no restart yet. Native
panic exit9 is outside the current automatic replacement exit75 policy. Preserve
and recover through ordinary controls after the fix. Five embedding retry
requests are already retained for the later reviewed policy/window. The user
still requires remaining ingestion/recovery plus60-minute maintenance, final
verification, honest defect/roadmap updates and final local evidence commit.
No automation exists. Do not end merely because a repair is committed or a
worker launch succeeds; record actual completion and unresolved evidence holds.

## Checkpoint 2026-09-12 22:51 UTC — build 9 focused/installed green; full QA running

Build9 complete. Native SHA256
`de42459f5612a95c8a297169ae7f685af832a14d656f9fa215287ad900a32d8f`;
linked `a8755769ac9551a3a6c6c3e740b62af4322c00b3794b75e2f6921eefa50b0bb9`.
Focused packaged gate passed **5/5 in20.84s** (Codex application, native receipt
failure/interruption, Gemini smoke and malformed extraction/secret controls).
Scratch-installed Codex application receipt/interruption test exited0 with
its expected receipt-reuse and provider-call accounting assertions; prefix
`/private/tmp/crexx-codex-utf8-installed`, fixture summary copied to evidence.
Provider implementation unchanged since build9. **Full63 is running as
session74490**, log `/private/tmp/crexx-codex-utf8-full.log`. All older build/QA
sessions are finished. Commit RAG-SMK-002 only after this gate and final docs.

The live original702af3a run remains session70061. First native UTF-8 panic
worker stayed failed; seven peers continued. A SECOND worker
`worker-977161015ed6d2985265f6f0ed86bced` (PID73026) later reported
`Codex App Server response timed out;processed=94;polls=374` and was automatically
replaced by `worker-a62a578d9728ad7145800dd1184652f7`. This is successful observed
replacement, separate from the unhandled exit9. Public detail does not establish
the timeout's exact provider phase; do not infer it was preflight or free. At
22:42:23 the public counters were473queued/6running/15076processed/15489skipped/
534dead,7live workers,1replacement and1held uncertain outcome. A new status8
snapshot follows in evidence. Preserve original logs before future drainage.

Next after full green: local fix commit; install to NEW `artifact-utf8` prefix
in the authorized run directory (never overwrite running old executable);
public pause/drain and verify all old workers/controller exit; reobserve/apply
the exact held turn(s), then normal `job continue`/`job run` with SAME named
period, no extra allowance. Continue remaining work on fixed artifact; prepare
reviewed operational recovery as required. Five embedding retry requests remain
pending, requiring reviewed retry policy/new window after ingestion. Then
ordinary maintenance for60minutes, public verification/report/coverage/usage,
final honest roadmap/docs and local evidence commit. No push or automation.

For the later human command, `maintain --minutes 60 --yes` requires human format
(omit JSON, or use `--format human`). Machine operation is the separate public
`maintain plan` / digest-checked `maintain apply` / `job run` sequence. Use
configured workers, keep one policy file and preserve the10percent account
reserve. `library migrate` is the ordinary explicit schema upgrade command;
it is now documented before large older-schema diagnostic reads.

## Checkpoint 2026-09-12 23:06 UTC — UTF-8 repair full QA green

Build9 full suite passed **63/63 in 938.12 seconds**, alongside focused
5/5 in20.84s, both-VM/optimization UTF-8 framing/invalid-byte cases and the
scratch-installed receipt/interruption journey. Native hash remains
`de42459f5612a95c8a297169ae7f685af832a14d656f9fa215287ad900a32d8f`;
linked `a8755769ac9551a3a6c6c3e740b62af4322c00b3794b75e2f6921eefa50b0bb9`.
No product changes since this build. Final logs copied to repo evidence.

Next: docs/whitespace, local RAG-SMK-002 fix commit, install NEW artifact-utf8
prefix, preserve full current runtime evidence, public pause/drain and verify
old controller/workers exit (session70061). Reobserve/apply held turns via fresh
digests while drained. Resume SAME ingestion with the fixed artifact and same
existing named allowance. Do not grant another period or change the old policy
just to restart workers. Then remaining operational retries/replays, reviewed
policy and five embedding repairs, the full60-minute maintenance, final public
verification/report and truthful docs/roadmap/evidence commit. Overall live
outcome is still incomplete. No push, sibling changes, usage reset or automation.
