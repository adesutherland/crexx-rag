# Operator continuation: live handoff

Updated: 2026-09-14, after shared MCP QA guidance and reusable corpus setup updates. This file records the current result and next action.
The detailed history below is retained for reference.

## Current checkpoint — baseline for the requested Tests 1–4 repeat

Ordinary MCP Q&A now explicitly retrieves evidence, resolves citations and
uses the current assistant to compose the answer. The separate product answerer
requires an explicit request to use or test it; shared instructions document
its additional generation latency and provider usage. MCP initialization and
tool descriptions agree. The ScottishHistory model is available as
`docs/templates/corpus-AGENTS.md`, linked from the setup examples and guides.
ScottishHistory standing instructions and both installations' shared instruction
and setup files have been refreshed. Installed executable files are unchanged.

The build passes; its native SHA-256 is
`4b5937a14302b4f1e8f121c0de78e60992a30db15f6157673e27fdf2db3baba5`.
`native_surfaces` and `documentation_contract` passed before the wording change
(2/2, 18.57s) and after it (2/2, 17.90s). Actual rebuilt MCP initialization,
tool descriptions and unchanged access annotations were inspected. This is a
guidance change; command execution, schemas and provider admission are unchanged.

The user requested committing this baseline, then repeating Tests 1–4 under
their existing bounded scopes on a fresh disposable copy. Use the retained
pre-Test-1 public backup so the five missing embeddings and new-document path
are exercised again. These new results must be recorded separately from the
historical passes below. RAG-SMK-010 and the wider performance findings remain
open; the instruction update does not repair them.

## Previous checkpoint — Test 4 repairs two operational holds

The user extended testing to search, answers and following relationships.
[QA performance results](qa-performance-20260913.md) show 0.47-second median
MCP searches and 0.45–0.60-second path calls on the repaired copy; two Codex
answers took 12–13 seconds. The permanent ScottishHistory MCP configuration
still launches a September 10 private executable. On the same permanent QA
library, the current executable reduced overview time from 32.1 to 9.0 seconds,
but did not improve search latency in this sample. No permanent QA files changed.

Next QA fixes indicated: update that stale launch target deliberately, avoid
the full health report in routine QA setup, skip vector-sidecar hashing in
lexical mode, and improve answer-span ranking before reducing passage limits.
Three passages missed the battle evidence; twelve retained it. Both benchmark
answer calls were within the bounded extension, using subscription allowance
and no Gemini or monetary-API route (the cost field remains unpriced).
They recorded only query usage/gaps in the disposable copy; generation remains
24,933. All benchmark servers have exited. These findings are not yet fixes.

Continue in `/Users/adrian/CLionProjects/crexx-rag` on `main`, product commit
`7febbca54fefa33ec90cc775f1b9ab01045fcad9`. Product code and installation are
unchanged from the successful Test 3 repeat below.

[Test 4 continuation](test4-operational-redo-20260913.md) repaired two original
operational holds in the same disposable copy. Both explicit replay jobs
completed, using three Codex turns including one citation correction, $0 API
cost, no Gemini and no failed/restarted workers. The 183-second interval stayed
within the fresh five-minute authority. No more hosted work is running.

The copy now verifies at schema 18, generation **24,933** with zero issues,
20 new mentions and two new claims. Sources, revisions, 34,907 chunks and vector
coverage remain intact. Original extraction history is retained; reconciliation
shows **543 actionable roots and two resolved** (521 content / 22 operational
still actionable). Current snapshot `config-a211c0fede4237fe77bbc797` is restored.

**Open RAG-SMK-010:** the whole-configuration replay hash rejects old items after
an unrelated source set is added. Temporarily selecting the original source
scope through public configuration commands allowed this smoke; that workaround
is not a product repair. Add the additive-source regression and fix compatibility
in its shared owner before making that an ordinary operator workflow.

Four content-correction drafts pass 45 original-grounding checks; they remain
unpublished and do not resolve their holds. A draft removes the ambiguous bare
Breadalbane organisation alias; the global glossary remains unchanged. Review
these through ordinary proposal/catalogue controls. Smoke evidence and the
updated handoff are uncommitted; no push or authoritative-library change occurred.

## Previous checkpoint — repaired installation and Test 3 pass; Test 4 inspected

Continue in **`/Users/adrian/CLionProjects/crexx-rag` on `main`**, commit
`7febbca54fefa33ec90cc775f1b9ab01045fcad9`. The normal installed executable now
matches the qualified SQL repair native, SHA-256
`e3967d87a24df035fa43373719bc5ed611592c7cf49433326dca85115cc762ab`.

The approved [Test 3 repeat](test3-repeat-sql-20260913.md) passed: planning
**0.207 seconds**, apply **0.705 seconds**, execution **55 seconds**, exit 0.
The fresh five-minute window selected eight items and stopped at four managed
Codex turns, with zero Gemini calls and **$0 monetary API usage**. Three tasks
resolved; Welsh correctly remains unresolved. Four unstarted items were
cancelled when the window closed and their tasks remain pending. One App Server
timeout caused a successful automatic worker replacement. All workers and the
controller stopped, with no uncertain or unsettled items in this job.

Disposable library: `/private/tmp/crexxrag-test3-repeat-tadMRjFu/library`.
Schema 18, generation **24,931**, zero verification issues; source revisions,
34,907 chunks, 7,969 claims and the Test 2 citation remain unchanged. Existing
published vectors still cover all 34,907 chunks. The original scratch corpus,
master library and permanent query copy were not changed.

[Test 4 inspection](test4-extraction-holds-20260913.md) is complete. All **545**
original extraction holds remain actionable: **521 content** and **24
operational**. One retained response per content reason was inspected using
the existing cREXX grounding owner; all 24 operational histories were inspected.
The samples show valid rejections, including changed OCR, stitched quotations,
missing endpoints and invalid response shape. A bare `Breadalbane` glossary
alias also conflicts with a geographical use. No hold was retried or waived.

Next: a small bounded redo of operational failures, then targeted content
correction through the existing extraction-review workflow, including a
reviewed Breadalbane alias decision. There is no usable final response on the
24 latest operational attempts; eight expired leases already have retained
interrupted-turn reconciliation. Keep their historical incomplete usage explicit.
The approved Test 3 window has finished; no further provider work is running.
These smoke reports are uncommitted follow-up documentation; no push occurred.

## Previous checkpoint — all twelve SQL repairs complete and locally tested

Continue in **`/Users/adrian/CLionProjects/crexx-rag` on `main`**. The
[delivery checklist](sql-performance-delivery-20260913.md) records F01–F12,
their shared owners, regression evidence and measured corpus results. The SQL
repair changeset is based on `bfbbdfd95d95a080262d47711c759bc2a9df18a0`.
Schema 18 adds the reviewed access paths; earlier migrations remain unchanged.
The authoritative SQL/data rules are in `docs/architecture.md`, referenced by
`AGENTS.md` rather than duplicated in adapters or approval gates.

Final build and focused QA pass (4/4 in 25.51 seconds). Full acceptance passes
**70/70 in 919.24 seconds**, exit 0. The final
native scratch smoke plans in 0.204 seconds and applies eight items in 0.625
seconds, with a full 900-second allowance and zero provider calls. The job and
all eight items were cancelled. Corpus report semantic output matches the
installed baseline, with zero storage/repository verification issues.

The built native is `e3967d87a24df035fa43373719bc5ed611592c7cf49433326dca85115cc762ab`.
The normal installed executable remains the earlier baseline below. The repair
is committed locally; no new hosted run, normal installation or push occurred.
All library mutations used test fixtures or the new disposable corpus copy.

Recommended next smoke: repeat Test 3 once using the repaired executable and
a fresh five-minute window, preserving the prior eight-item, eight-call,
four-Codex-turn and $0.005 monetary limits. This exercises actual worker
execution after the changes to selection, cursor progress and timing; the
latest corpus smoke stopped after plan/apply. Then move to Test 4's targeted
extraction-hold inspection. This recommendation does not start either run.

## Previous checkpoint — complete refactoring merged into main and installed

Use **`/Users/adrian/CLionProjects/crexx-rag` on `main`** for further product work.
The complete `temp/project-review` history, including the substantial shared-owner
refactoring and smoke repairs, has been fast-forwarded into local `main`.
All local/fetched branch histories were included, and the pending smoke results
and performance audit were committed as `207a2a4`. Earlier worktree authority
statements below describe their historical checkpoints.

The normal **`/Users/adrian/.local/bin/crexxrag`** now matches the freshly built
primary-checkout native, SHA-256
`ba35a980f1a4bcc06ea7cae5e6011bd4aeb0e123cbac3a7bf705d23b68737816`.
All 103 checked installed application/provider/skill files match the source.
Build and eight focused/documentation checks passed. Product/build/test trees
are unchanged from the 69/69-tested baseline `ab620e5`.

See the [consolidation record](version-consolidation-20260913.md) for exact
scope and evidence. This was a local merge/install; no push, release, user-library
change or new hosted run occurred. The next engineering work is the
[unfinished maintenance preparation performance repair](maintenance-planning-performance-20260913.md).

The subsequent [wider SQL review](sql-performance-review-20260913.md) catalogues
all production SQL construction sites and ranks twelve findings. The installed
provider census experiment improved from 76.14 to 6.00 seconds on a disposable
copy, with identical task identities, evidence fingerprints and dispositions.
The proposed first repair is eight P1 access paths plus reducing repeated
automatic preparation. These remain proposals: product code and installation
are unchanged, and no further hosted smoke has run.

## Previous checkpoint — Test 3 bounded maintenance complete

[Test 3](test3-maintenance-20260913.md) completed in **62 seconds**, exit 0,
on baseline `ab620e5`, using the same disposable corpus and unchanged native
artifact. Four managed Codex turns produced **three retained/resolved reviews**
and **one correctly rejected split**; there were zero Gemini calls. Three
unstarted tasks remain pending and one stale alias task was superseded.
The window closed at its four-turn limit; both workers and controller stopped.

Library verification passes at generation **24,928**, with zero issues and all
**34,907 chunks** still covered by published vectors. Source revisions, claims
and the Test 2 citation are unchanged. The rejected Borodale split cited a
quotation outside its selected mention; its task, response and usage survive.
It is not completed content and no correction call was made beyond the budget.

Preparation remains a finding: plan took 160 seconds and apply 218 seconds.
A 15-minute plan deadline allowed that preparation while actual worker execution
remained below the separate five-minute cap. A literal five-minute end-to-end
maintenance launch is therefore not qualified. The report records the timing
path and the difference between preview notes and the actual durable dispatch.

No product/configuration changes, further commits, push, normal installation or
master-library changes occurred. Test 2 and Test 3 evidence and this handoff are
uncommitted follow-up documentation. No more hosted work is running; the next
previously proposed smoke is targeted inspection of extraction holds (Test 4),
not a broad retry or cleanup.

## Previous checkpoint — baseline committed; Test 2 passed

Baseline committed as `ab620e5f303696ba477d6b91845f075789b779c9` on
`temp/project-review`, with the unchanged tested native artifact and 69/69 QA.
The user then authorized the prepared bounded live Test 2. It passed in
**53 seconds (16:06:03–16:06:56 UTC), exit 0**: all four new-document items
processed, using two successful managed Codex turns and two successful Gemini
embedding calls. Recorded Gemini cost was **$0.000049**.

Automatic publication covers **34,907/34,907 chunks** at generation 24,925.
Library verification found zero issues and an aligned manifest. New-source
retrieval and exact citation resolution pass. Both workers and the controller
stopped; no queued, failed or uncertain work remains in this new job.

See [Test 2 result and evidence](test2-new-document-20260913.md). The disposable
library, policy and job below remain the Test 2 identities. The master corpus,
permanent query copy and normal installation were untouched. No push occurred.
This result and handoff are uncommitted follow-up documentation after the requested
baseline commit. Test 2 is complete; further hosted or maintenance runs need
their own bounded scope. Previous checkpoints below are historical.

## Previous checkpoint — simplification complete; document ready for live smoke

The approved [shared-rule simplification](rule-simplification-repair-20260913.md)
is implemented. Global configuration vetoes and duplicate claim/replay checks
are removed. Completed work stays complete; explicit redo retains history and
uses ordinary limits. Reconciliation now works from a drained terminal parent
without an artificial pause; the focused eight-worker case passes.

Final native candidate: `751e3ca283c036f524feee93d5eb6b7565ec424bd4cd18fce038bc419fae0da3`.
Full QA passes **69/69 in 901.87 seconds**, exit 0. Evidence is retained in
`docs/qa/rule-simplification-20260913/full-reconciliation.log`.
Temporary installation: `/private/tmp/crexxrag-simplify-20260913/installed/bin/crexxrag`.

The disposable corpus accepted its new source configuration and imported one
public Bannockburn excerpt as two chunks and four work items. Repeat import is
an exact no-op; lexical retrieval and exact citation resolution pass. Original
job snapshots, 82,549 provider runs and 116,184 attempts remain unchanged.
The final executable successfully prepared the new job without provider calls.

Prepared library: `/private/tmp/crexxrag-smk006-V6YatF/smoke-library`.
Policy: `/private/tmp/crexxrag-smk006-V6YatF/test2.conf` (two workers, five minutes,
eight calls, four managed Codex turns, $0.005 monetary provider budget).
Policy SHA-256: `0541ed3efa5cfc78f07e39ea3e9fed50fb5547d1e5b82e8214fc92956be15dcb`.
New job: `job-sha256:0916c52c55fea9da892cd37de730e5abc2af5c17e882fb5cd0bf8444e2f38095`.

Next: hosted processing of this new job, pending bounded authority. Product
repairs, full QA, temporary installation and provider-free corpus smoke are complete. No master-library or normal installation
change, no hosted calls, commit or push; do not reuse expired Test 1 authority.

## Previous checkpoint — Test 2 configuration barrier investigated

The user selected investigation: "yes we need to get these runs working.
investigate the issue." Diagnosis on the disposable copy and ten synthetic
fixtures confirms three open findings: RAG-SMK-007 inconsistent configuration
execution guard, RAG-SMK-008 cancellation toggling a held parent's stored state,
and RAG-SMK-009 Gemini diagnostics recommending Codex-only reconciliation.
See [the investigation and proposed repairs](configuration-hold-investigation-20260913.md).

Existing relevant controls pass **3/3 in 35.36s**. The corpus copy still verifies,
generation 24,922, and all provider/attempt/event/item counts are unchanged.
No product source, policy, master or installation change; no hosted calls.
Documentation QA passed 1/1; all 19 retained evidence hashes and diff whitespace passed.
New regression probes expose missing acceptance; the last 68/68 suite is not
closure of these findings. All investigation/QA processes finished.

Recommended repair: one drained-execution guard for future configuration while
retaining old snapshots/holds, stable cancellation/refresh and capability-aware
recovery guidance. Do not clear uncertainty to add the source. Register failing
regressions before implementation, then full QA and installed/corpus-copy tests.
The new-document source is staged but not imported. Its hosted run remains
pending concrete bounded authority. The earlier preference question is answered.

## Previous checkpoint — RAG-SMK-006 qualified on updated CREXX

The approved work resumed after installed CREXX was updated to
`crexx-1.0.0-beta.3+local.g037e7939bc29`. Both RAG artifacts were rebuilt.
The new regression reproduced the automatic partial-index publication failure
before implementation; existing controls passed **3/3**. Shared manifest
recovery is now in `ragembedding`; focused QA passes **5/5 in 52.41s**.
Full QA passes **68/68 in 944.08s**, exit 0. The separate scratch-installed
publication fixture passes with the identical native hash and two synthetic calls.
Native candidate: `1572df54e58261d6300bbdf44903edfb3b36a07f6cd164ad3357b7d95377a7a5`.
Linked candidate: `c1da0015c6ff6bf99f44e2ca5750cfc9cc7ec9e7510fb160e7d91cb2c0e5a5af`.
See [the repair record](smk006-publication-repair-20260913.md).

Evidence/work: `/private/tmp/crexxrag-smk006-V6YatF`; current full log is
`full-fixed.log`; retained evidence is in `docs/qa/smk006-20260913/`. All QA
commands have finished. No new hosted calls, master-library changes, commit or push.
The new document and verified disposable corpus copy are prepared. Prospective
configuration is blocked by inherited paused/uncertain jobs. A public cancel
request only in the copy did not remove uncertainty; history remains held.
The user has been asked whether to investigate this barrier first or run the
new-document smoke in a fresh empty scratch library. Do not bypass the guard
with SQL or waive unknown outcomes. Existing dirty checkout work is preserved.

## Previous checkpoint — Test 1 embedding repair complete

The user explicitly approved the five-chunk Gemini Test 1 run. All **five**
missing embeddings are repaired: **34,905/34,905** stored and published vectors,
zero missing, integrity passes at generation **24,922**, schema 17. Five
successful calls cost **$0.000208**; no reasoning calls. All eight workers and
their controller stopped. The fixed window ended at **12:28:19 UTC** and grants
no further paid authority.

The initial `job run` failed at automatic vector publication with a manifest
alignment error. Public `vector rebuild --reconcile` completed publication
without more provider calls and reconciled ten historical embedding items.
This is corpus recovery, not closure of that new product defect: **RAG-SMK-006
remains open**. All five original failed attempts and receipts are preserved.
The original ingestion now has zero embedding dead letters and **545 retained
extraction holds**. See [Test 1 and exact evidence](test1-embeddings-20260913.md).

Current selected policy changes only `provider.gemini-embed.max_attempts` **1 → 2**;
the resulting SHA-256 is
`9a180b6121e8cdbcb663817a5613a513d87aeb78e175b8ad3abc1aae37039c6d`, snapshot
`config-bd4ae91b6a019ac3453baeba`. Reasoning/general maintenance stay at 1.
The former broader 3/6/3 proposal is still unauthorized. The verified pre-test
backup and frozen current executable are retained beneath
`/Users/adrian/testrag/overnight-scottish-20260909/test1-embeddings-20260913/`.
No new product changes, commits or pushes were made in Test 1. The original
checkout and permanent ScottishHistory query copy remain untouched. Final
documentation QA passed 1/1; diff whitespace and all 43 evidence hashes passed.

## Previous checkpoint — four defects complete, 13 September 2026

The user explicitly requested **"OK Please fix the 4 now"**. All four repairs
are implemented and locally qualified in this review checkout, uncommitted on
`9292c8d8d724b52fce34047c868f15531348faca` (`temp/project-review`). Existing
test/documentation work is retained. The previous test-only restriction was
superseded for these defects; no commit, push, live run or retry-policy change
was requested.

- RAG-SMK-004: shared observations distinguish registered, confirmed-live and
  unverified workers.
- RAG-SMK-005: status, job pages and report/cache activity use the same lifecycle
  rule while retaining real pauses and uncertainty.
- OPS-001/004 controller loss: managed children stop taking work when their
  controller ends, including startup and parent-link loss.
- OPS-001/004 routine restart: existing job commands drain/clean the selected
  old group and start fresh controller/children, retaining durable history.

The extended baseline reproduced all four failures before product changes.
The final focused panel passed **9/9 in 67.06s**. The full suite passes **67/67
in 932.92s**, CTest exit 0. A separate scratch install matches the tested
native hash and passes **5/5** fixture invocations: the four repaired cases plus
original interruption. No test assertion was disabled or weakened.

Native SHA-256:
`62eaaa2292e210b0c468d2de58ed126ca92557a1a24760109d863c764b85fa81`.
Linked SHA-256:
`01712c8c081097b4208d982208035502735f2fbd84c574428dcd8bc0047e340c`.
See [the repair record](four-smoke-fixes-20260913.md) and
[retained evidence](qa/four-smoke-fixes-20260913/).

At that four-fix checkpoint, no live library or selected policy changed.
The subsequent Test 1 above supersedes only the five-embedding and embedding-policy
parts of that earlier boundary. Process recovery is qualified only in the
launcher's local process visibility domain; the installed CREXX hidden-PID
limitation and non-macOS qualification remain separate. No QA process remains
active after the final checkpoint below.

## Previous checkpoint — test-only handoff

**No paid process remains active. Do not launch another live run.**
The requested tests/documentation checkpoint is complete. Full CTest finished:
**63/67 pass in 879.91s; all 63 old tests pass and exactly the four new
regressions fail.** The final focused repeat confirms the same four defects
with passing controls. No test process or exec session remains active. Changes
are uncommitted on `9292c8d`; start a new session for product repairs.
See [coverage and evidence](regression-coverage.md#current-status--13-september-2026).

The following describes the completed live smoke, not a current run:
Session 59810 ended with exit 0 at 01:19:59 UTC on 13 September. Its fixed
60-minute window ended at 01:21:32; actual worker runtime was 56m55s. Eight
workers drained, with one confirmed interrupted timeout safely replaced.
The final public integrity check passed at generation **24,922**, schema 17.
The master still uses the frozen `artifact-review-index` executable at product
commit **1edb325**. The selected policy hash is unchanged; 63% account allowance
remains, with a 10% reserve. No further paid work is authorized by this window.

Latest user direction: **simplify controller recovery**. AGENTS.md now requires
the simplest complete solution and accepts small losses of unfinished work.
The architecture/roadmap describe one ordinary cleanup/start path using the
recorded controller/child PIDs, polite shutdown and fresh children. This
supersedes the prior elaborate proposal. Four new regression tests now expose
the two public-status defects and missing controller-loss/live-group restart
behavior. Product implementation is unchanged. The tests and documentation are
uncommitted on HEAD `9292c8d`; do not start repairs in this test-only session.
See [the current coverage record](regression-coverage.md#current-status--13-september-2026).

Read [the final smoke report](operator-continuation-smoke-20260913.md) and current
ROADMAP. OPS-005, UX-01/03/04 and RAG-SMK-001/002/003 are closed on named evidence.
The whole recovery outcome remains open. RAG-SMK-004/005 are concrete public
status defects; five embeddings and retained ingestion holds remain. The exact
3/6/3 retry-policy approval is still pending; the rejected policy write never ran.
Do not bypass it through another policy, replay, waiver or reset history.

Final smoke evidence/docs passed their documentation gate and were committed
as `9292c8d`. Product `1edb325` had a full 63/63 gate. The new test-only changes
extend that suite to 67 tests; the four new tests are intended ordinary failures
until repaired, not additional green product qualification.
The latest dated checkpoint below is the takeover state; older live-session
instructions are historical and must not trigger another paid run.

## Authority and target

Previous four-fix scope: fix the four reproduced status/controller/restart defects, retain
and extend regression coverage, run full local QA and scratch-installed checks,
and document exact results. No live run, retry-policy change, commit or push is
authorized by this repair request. The original cwd remains untouched.

The following authority describes the completed overnight outcome:
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

## Checkpoint 2026-09-12 23:12 UTC — committed UTF-8 repair deployed; same ingestion resumed

**HEAD3b4c481**, full63/63 in938.12s, focused5/5 and installed receipt recovery
green, final docs contract green. Installed NEW `artifact-utf8` under the live
run root; native `de42459f5612a95c8a297169ae7f685af832a14d656f9fa215287ad900a32d8f`,
linked `a8755769ac9551a3a6c6c3e740b62af4322c00b3794b75e2f6921eefa50b0bb9`.
Original ingestion session70061 is FINISHED exit8 reporting the recorded UTF-8
worker failure after seven peers settled normally. Public `job pause` was
sufficient for this job-filtered group to drain; all ten retained process rows
(controller plus original/replacement workers) are terminal and `not-running`,
confirmed by an escalated public `worker list`. The earlier sandboxed list
reported even a live controller PID as missing: that restricted observation is
not proof of absence. No live ownership was pruned on that evidence.

Fresh exact-turn read on the drained master again observed interrupted/no output,
digest `90ce81e20d097859b0d5b5a9142f859c9cd1eb2c96b3349a95fa2d1590c0281b`.
Public digest-checked reconciliation applied, generation calls0, incomplete
usage retained. Same-job `job continue --prepare` then succeeded with no new
period/allowance. The original selected policy is unchanged, SHA256
`e2d82f0fe11043986f25c03e917b9897ab11a47f5b10ff833db906902d516bb0`.

**ACTIVE session60732**: ordinary `job run` on artifact-utf8, configured8workers,
started23:10:47UTC. Logs `ingestion-utf8.log`/`.err`, terminal marker `.exit`,
start marker `ingestion-utf8-started.txt` in run root. `CREXXRAG_SELF` uses this
exact native binary; persistent exec, no background automation. At
2026-09-12T23:11:01Z: queued49,running8,processed15416,
skipped15556,deadletter549,live workers8,
held uncertain0,incomplete observations13.
Controller `controller-cea4078becb412740d2bca2215d086bf`. Do not launch another group.

Operator invocation mistakes preserved: initial `--progress on` rejected at
parse before work (use `plain`); an attempted retry had a mistyped policy path
and automatic approval review rejected it before any command ran. User informed.
The verified original path/hash was restored and the exact corrected launch
approved. No current approval blocker. Optional recurring monitor remains
rejected/not created; do not recreate it.

NEXT: let remaining ingestion finish; capture all held items/lineage and public
status/progress/report, settle any new unknowns via public observation/apply when
drained. Review operational failures and ordinary replay under the planned
policy; preserve evidence-validation/advanced-review holds. Change the ONE
selected policy through hash-checked public config set, review config plan/apply
(3reasoning attempts, explicit6embedding, maintenance3) only after old work has
finished. Five retained embedding retry requests already exist; new compatible
embedding-only maintenance window must actually repair missing5 without
reextraction. Then run the requested60-minute automatic maintenance, record
actual timing/outcomes/holds, public verification/report/coverage/usage and final
roadmap/docs/evidence commit. Overall outcome remains unfinished. No push,
sibling modification, blind uncertain retry, blanket waiver, new source import
or usage reset. Continue updating this handoff before compaction.

## Checkpoint 2026-09-12 23:21 UTC — original queue finished; retry setting approval blocked

**Ingestion session60732 finished exit0**, all8workers completed,0failed/restarted,
vector publication identical-no-op. Artifact/HEAD3b4c481 is unchanged and qualified.
At23:14:27UTC the original job is `completed_with_errors`: queued0,running0,
processed15463,skipped15565,deadletter550,held uncertain0,incomplete usage13.
Provider runs22211,provider time276824086ms,input335474436,output10242466,
recorded monetary91578micro-units. First-run failures and all paid history remain.
Complete public six-page hold inventory now accounts for **521 evidence failures,
24 operational extraction failures and5embedding items**, no uncertain outcomes.
Full JSON inventory and24 reviewed candidate selectors are in repo/run evidence.
No operational replay has been created yet. The original source job is now
terminal, satisfying that public replay prerequisite. Do not bulk replay the
evidence holds, maintenance-owned work or already-covered lineage.

Public `library report --narrative off` passed storage/repository/lexical and
provenance checks (unsupported claims0). Generation24135,8sources/34905chunks,
27448concepts,62814mentions,7965claims,8245supports,4402pending reviews.
34900 embeddings and published rows:5still missing. Active jobs0. Historic
all-job deadletters13872 include other old jobs; do not equate them with550
selected items. Durable open tasks30640,18migrating workflows; no waivers.

**NEW APPROVAL BLOCKER: automatic review rejected public config set** of
`provider.codex-extract.max_attempts=3`, saying trusted messages did not explicitly
authorize that exact persistent paid-processing setting. NO POLICY WRITE RAN.
The original policy still has1reasoning/1embedding/1maintenance attempts and
SHAe2d82f0fe11043986f25c03e917b9897ab11a47f5b10ff833db906902d516bb0.
Earlier checkpoints called3/6/3 agreed; the broad recovery approval plus recorded
requirements did not satisfy automatic review. A read of recent thread messages
found approval for the outcome but no new explicit exact setting approval.
Do not bypass by another policy file, budget reset or alternate paid retries.

User was informed of rejection, and **one async approval question is pending**:
may the existing policy use3reasoning/maintenance attempts and6embedding while
retaining cumulative history, all overall budgets and10percent reserve? If user
answers approving, apply only through hash-checked config set/reread and reviewed
config plan/apply while writers are drained. If no answer, keep settings intact;
finish unaffected work and honestly report the5embedding recovery as blocked by
automatic review. No repeated question or implied elapsed-time approval.

**ACTIVE read-only maintenance plan session94322, PID44642**, using committed
artifact and UNCHANGED policy: `maintain plan --minutes 60`, output
`/private/tmp/scottish-maintenance60-plan.json`. At2m10s planner is CPU-bound100%,
not idle/lock waiting; no output yet. Plan makes no generation calls and has not
been applied. Preserve planning time as smoke evidence. On return inspect exact
canonical plan/current original1attempts, budgets, fixed timing/expiration and
10percent reserve; public digest-apply then run the returned job in a persistent
exec session. This is the explicitly authorized60-minute maintenance under the
original policy, independent of the rejected higher retry settings. No live
provider group is running at this checkpoint. Do not duplicate the planner.

Also observed: `job list --state queued` is unsupported; it rejected before any
write. Use supported job list paging (currently includes full plan, known size
limitation) or library report active_jobs (0before new work). Restricted sandbox
worker reads can say missing even while same-account workers heartbeat; escalated
reads with run visibility confirmed all old workers gone before continuation.
Update existing process-liveness limitation to include visibility boundaries.

Next: maintenance plan/apply/run and60-minute observed window; operational
recovery within authorized unchanged policy if safe and not circumventing retry
rejection, or after explicit approval of revised policy. The five retry requests
are already retained; do not resubmit new requests as an attempted bypass.
Record the actual remaining holds, complete public verification/report/coverage,
review UX-03/04 actual Scottish workflow acceptance, update docs/roadmap and
commit final evidence. Overall outcome is not complete. No push or automation.

## Checkpoint 2026-09-12 23:23 UTC — original-policy maintenance apply running

Read-only planner94322 FINISHED exit0 after approximately142seconds of CPU
census work. Canonical maintenance plan digest
`d40ed9c08dc658d3c7449f56d816c50a76a58cd630588800eede91b8c29ae3a9`,
creation1789255211,expiration1789258811. Fixed60-minute maintenance window
starts23:17:49UTC and ends **2026-09-13 00:17:49UTC** (01:17:49British time).
Plan timing includes census preparation; record actual worker runtime separately
from the requested wall-clock window. It preserves current configuration
`config-fe479707411d396de0e334e6`,1attempt,8workers,gpt-5.6-luna low,original
call/token/monetary budgets and10percent reserve. Aggregate maintenance provider
time remains disabled0. Preview100census items is only the initial bounded
selection; automatic scope is durable backlog/follow-ups within the window.

**ACTIVE mutation session71178**: public `maintain apply` using the exact
reviewed plan/digest and UNCHANGED original policy. Output
`/private/tmp/scottish-maintenance60-apply.json`. Do not duplicate or change the
policy while it is running. No rejected retry-policy change was made; approval
question3/6/3 remains pending. Applying/running the existing1attempt policy is
unaffected authorized60-minute maintenance, not an alternative retry grant.
On completion inspect returned job_id then run that job onartifact-utf8 in a
persistent exec with CREXXRAG_SELF matching. Save start/end/log/exit and update
this file. No provider group currently running before apply finishes.

## Checkpoint 2026-09-12 23:31 UTC — maintenance workers running; Turray evidence prepared

Maintenance apply71178 FINISHED exit0, provider_calls0, created job
`job-maintenance:d40ed9c08dc658d3c7449f56d816c50a76a58cd630588800eede91b8c29ae3a9`.
**ACTIVE provider session24180**, ordinary `job run`, started23:27:22UTC using
HEAD/artifact3b4c481, unchanged selected policy,8workers. Controller
`controller-2a68a64ff5b3389c4a155ed1ecb61bba`. Run-root evidence:
`maintenance60-started.txt`, `maintenance60.log`, `maintenance60.err`; completion
will write `maintenance60.exit` and `maintenance60-ended.txt`. Fixed reviewed
window ends **00:17:49UTC /01:17:49British time13September**. Start of planning
was23:17:49; census/apply/preparation consumed about9.5minutes. Record actual
worker runtime separately; do not call that60minutes of active workers.
No pending build/tests. No second group should be launched.

At23:28:42UTC the window's first100materialized items show56queued,8running,
21processed,13skipped,2dead,0held uncertain,8live workers. Public failure read
shows exactly two content validations: selected connection quote not grounded,
and split successor equals migration parent. Neither is a runtime crash or
unknown paid outcome. Check status/logs in bounded intervals, preserve real
failures, and let the existing fixed deadline/cutoffs govern. Higher3/6/3retry
policy question remains pending; NO SETTING WAS CHANGED. Do not grant or replay
paid work to circumvent that rejection. Five retained embedding requests remain
held by1attempt;24operational ingestion candidates are inventoried, not replayed.

A public lookup found the actual Turray workflow on the processing master:
`workflow:task:48057daa37dbcb56d4246e26e106943bb9aed22ac1ce1cccf64fe02ae964420b`.
It is migrating with1remaining impact,0ownership/reviews/uncertain outcomes.
Alias and mention connections are resolved. The failed support connection is
`task:3f2a84e7ef5a80316f9cc82cb00c0eb32e8ffdba3eab77178e261208f5e4341d`,
3old attempts; retained claim
`claim-sha256:b0649fe90968aee4b8ee59aa319341946b6404cf9358ece94fa81de3931e7163`,
support `support-sha256:cfac5050fee55cdc663364154b292f744f732abead5fb5d4c2959f25a8ba1952`.
The immutable108-character source was fully resolved by public citation show:
`[241] _Turray_ is the old name of Turriff.--Gordon of Rothiemay, vol.\nii. p. 254. Gordon of Sallagh, p. 401.`
ParentTurray `concept-sha256:aa20285dbb62db4828c70246261ef075169f7d1c00b0dc4880be3dd9d4bbccdb`;
successorTurriff `concept-sha256:5e1608b3f90c57f1543bb85b788a070e7244948cdbd8257bd28d64fb44ccac78`.
The related-to claim is redundant after identity merge; moving it would make a
self-relation. Prepared twelve-field response is
`/private/tmp/scottish-turray-retraction-response.json`, copied to evidence.
NO resolve plan/submission/review/semantic write has been made for it yet.

Installed skill read and user informed:
`artifact-utf8/share/crexxrag/skills/crexxrag-resolve/SKILL.md`. Follow its public
resolve-plan/resolve-apply, mandatory review preview/accept, then targeted
maintain reconcile preview/apply and retirement resolution/review. It requires
source grounding and existing authority; no extra approval imposed by skill.
This Turray replay is the real UX-03/04 acceptance already owed in this task,
using external reviewed reasoning, not an extra hosted provider retry. Wait
until current maintenance writers drain to keep generation checks reviewable;
reinspect current task/claim before planning. Then complete and verify retirement
while preserving all source/history and provider accounting. No direct SQL.

After window ends: collect final status/task dispositions, safely reconcile any
unknowns, verify library/report/coverage, finish Turray as above, handle the
policy approval if received (only after drainage), repair5embeddings and24
operational failures when authorized, update the consolidated defects/roadmap
and docs with actual closures and exact remainder, docs gate and final evidence
commit. Retain automatic-review refusal if still blocking; don't hide it under
smoke pending. Continue in active session; no scheduled automation exists.

## Checkpoint 2026-09-12 23:41 UTC — maintenance smoke FAILED; diagnose before restart

**Maintenance session24180 FINISHED exit8.** Sustained writer contention caused
controller and7peer workers to exhaust heartbeat tolerance. At23:33:20UTC, first
100items were83processed/13skipped/4dead,0queued/running,0held uncertain;
heartbeat age76seconds. Public pause afterwards SUCCEEDED. Original fixed
deadline00:17:49UTC remains; don't declare60minute smoke complete. No automatic
restart yet, no new allowance, no higher retry policy. Async3/6/3approval remains
pending. Need freshly verify all terminal ownership with escalated worker list
and current job status before restarting on any repaired artifact.

**RAG-SMK-003 P1: maintenance checkpoint stalls writer coordination.** Source
`ragbacklog.tickbacklogwindow` holds BEGIN IMMEDIATE across outcome reconciliation,
census/evidence construction and dispatch when a100item batch empties. The real
run had100finished items and sustained explicitSQLITE_BUSY heartbeat diagnostics.
At6m31s runtime, the last worker44891 (`worker-d2aab79c6fe6b7a60fa419098abd22f1`)
had107secondsCPU; others had exited. Exact slow SQL/body is not yet proved; do
not assume all census work or add indexes speculatively. No source fix or new
regression has been made for this failure yet. Do not merely increase heartbeat
retries or change paid limits to conceal a long product writer transaction.

Read-only developer profiling is on the existing **qualification-library**
copy, never raw SQL as a live operator repair. InstalledCREXX generic profiling
script `/private/tmp/profile-rag-query.crexx` accepts DB and one-lineSQL file:
`crexx SCRIPT -args DB SQLFILE`. IMPORTANT: -args is required; earlier omitted
-args made the driver parse the SQLite filename as another input and produced
exit_fragment errors. Those are invocation mistakes, not an upstream finding.
`profile-census-identity.crexx` independently ran actual identity census query
on the copy:100rows in2.641s, automaticstate index plus SCANd. That alone does
NOT explain the>60second lock. Pending task allowance query was0.0107s despite
SCANmaintenance_provider_outputs, so also not the cause on this snapshot. Sparse
query result is `/private/tmp/scottish-sparse-census-before.log`. Need profile
actual evidence construction/census stages or use runtime profile support to
identify the dominant path, then a reproducing regression before narrow repair.
All profiling processes have finished except check latest tool state if another
is launched. No paid group is running. Full63gate/installed verification and
new local commit/artifact remain required after a product/schema repair.

Separate existing platform boundary now conclusively reproduced in paired public
reads on the SAME active maintenance PIDs: restricted sandbox reports missing,
while escalatedsame-account visibility reports alive for controller+8workers.
Files `scottish-maintenance60-sandbox-workers.json` and `...visible-workers.json`.
No pruning used the restricted result. Update existing integration limitation
to include visibility boundaries; don't falsely call sameaccount sufficient.
This is distinct from the writer stall; native fix belongs to CREXX.

Turray source/response preparation and original550ingestion holds remain as
previous checkpoint; no externalproposalwriteyet. While repair/QA proceeds, its
ordinary reviewed zero-provider connection/retirement journey can now be completed
after confirming drained ownership. Do not let that substitute for repairing
and rerunning the failed maintenance smoke. Keep final closures honest.

## Checkpoint 2026-09-12 23:54 UTC — Turray public recovery completed

Actual processing-master Turray workflow is COMPLETE at generation24219, using
artifact-utf8/3b4c481 and only public commands. Connection proposal digest
a6bedd8b12e982f55bc46fa252aa3b7c50bf5e39a592eb5999c7b1161466912c was
source-validated, submitted, review-previewed and accepted: generation24218
retracted the redundant related-to claim/support. Census then found zero
remaining impacts/owned items/reviews/unknowns and created retirement task
task:1f1e75ecf7d05f72174abc2288c7562153d87d2fcb9892829f59e85dd387f697.
Retirement proposal d4f851f954e474b66d0665fc1958744901fa9dbef60c6579d8d5807097774474
was submitted, previewed and accepted: generation24219. Fresh public reconcile
returns complete/already-complete, all four hold counts0, provider_calls0.
Actor codex-operator, model unspecified, honest external attribution. No fake
provider receipt, paid retry, budget/policy update, waiver or SQL repair.
All scottish-turray-* JSON evidence copied into repo evidence and live run root.
Still verify retained source citation and parent/successor history. This closes
the actual Turray repeat, not the failed60minute maintenance outcome.

Final failed maintenance read:200 materialized items,88processed/16skipped/4dead/
92cancelled,0queued/running. Controller failed, one worker stopped, seven stale
idle records whose exact PIDs are missing even in escalated process domain.
No live processes. Public job run owns restart/prune; do not treat retained
worker_live_workers7 status count as OS proof of seven processes. Files
scottish-maintenance60-terminal-workers/status.json retain the distinction.

Read-only evidence harness:100alias packets4.25s,100notes3.03s,100concepts6.36s,
100chunks0.018s,25supports0.006s. Actual temporary instrumented _scan on the
qualification copy in a rolled-back transaction:27.25s total; identity category
10.59s, sparse6.46s, alias4.72s,notes3.47s,18workflows~1.77s. None alone explains
the observed >100sec CPU lock. Extended profile now running session14835,
/private/tmp/scottish-checkpoint-before2.log: includes actual dispatch selection,
outcome reconciliation and eligible-count. Temporary tools/diagnostic namespace
only; NO product/test edit for RAG-SMK-003 yet. Earlier extended harness had
8compile errors from overly broad diagnostic text replacement, fixed by restricting
it to the profilescan wrapper; not a product defect. Script
/private/tmp/prepare-scan-profile.py regenerates base diagnostic source; then
/private/tmp/extend-scan-profile.py adds dispatch timing; cmake -P
/private/tmp/profile-scan.cmake compiles/runs copy. It rolls ALL data writes back
and makes zero provider calls. Do not run against master.

Higher3/6/3retry policy approval still pending; current1/1/1 and policyhash
unchanged. Five embedding retry requests held;24operational extraction candidates
not replayed. Continue diagnosis, regression-first repair, full63gate, commit,
new artifact and replacement60minute smoke. No automation exists.

## Checkpoint 2026-09-13 00:05 UTC — narrow review-index repair in full QA

**Active full gate session36144**, log `/private/tmp/review-index-full-qa.log`.
No paid worker group is running. No higher retry policy approval has arrived.
Current HEAD remains3b4c481; schema repair is uncommitted. Build92715 finished0.
New native SHA02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5;
linked059354153691243cfc04c57ac6a29fb5802ee88505add33df5f646b91c58d113.
Product change is ONLY additive schema17 `reviews_subject_state` on
reviews(subject_id,state). Earlier checksums and all review/attempt/policy/usage
semantics are unchanged. Owning source ragschema; no changes to ragbacklog
transaction logic, heartbeat tolerance, retry limits or budgets. Six CMake
expected schema-version assertions now17.

Independent cause proof: isolated pending-review predicate28.558205s, indexed
0.003647s. Full temporary copy profile BEFORE: scan27.283556s, reconcile0.010951s,
dispatch-select28.176061s, dispatch-body0.055285s, eligible27.397190s/28928rows.
Public native `library migrate` upgraded qualification-library to17, preserved
generation23208/aligned manifest. AFTER same profile: scan27.617854s,
reconcile0.010957s, dispatch-select0.047991s, body0.052443s, eligible0.039572s
with SAME28928rows. Both profiles rolled back all census/dispatch writes.
This removes the reproduced repeated review scans, not every possible source
of a long future census. The replacement real60minute run is still required.

Regression first: provider_durability adds30,000pending tasks/5,000reviews,
asserts indexed plan without host-speed threshold, checks pending blocks only
its own subject, accepted/unrelated reviews do not, and review retention.
Unchanged product valid red in3.02s: exactly2access-path failures, fresh+upgrade.
Earlier compile-red was test-only reserved `query` identifier; retained separately.
Postfix focused run passed durable_backlog15.59s, native_continuation12.97s,
held18.82s; provider_durability exposed a NEW TEST JSON-string escaping error.
Corrected fixture via SQLite json_object, no product edit/relaxed assertion.
Provider_durability then passed all noopt/opt and rxvme/rxbvm in12.17s, including
schema16->17 pending-review identity/proposal retention. Full63suite nowrunning.

Turray verification is complete: public current-context inventory proves
retired/version3 plus versions1/2 retained, final named workflow complete at24219,
and original108character citation text EXACTLY unchanged. All JSON saved in
repo evidence and runroot. Roadmap now honestly closes UX-01 named discovery,
UX-03 effects and UX-04 targeted completion against these actual observations.
This does NOT close whole OPS items, content holds or failed maintenance.

Next: await fullgate terminal result; do not launch a second suite or group.
Fix any real failures; ifgreen, scratch-install/ordinary recovery verification,
document actualresults, whitespace/secret/file-size review, localcommit. Then
freeze new `artifact-review-index` in live runroot, verifysha, public migrate
MASTER after confirming ownership drained. Current master stillschema16,
generation24219, no activegroup. Use same selectedpolicyhash
e2d82f0fe11043986f25c03e917b9897ab11a47f5b10ff833db906902d516bb0.
Restart failed job-maintenance:d40ed9c08dc658d3c7449f56d816c50a76a58cd630588800eede91b8c29ae3a9
through public job continue with a SINGLE named renewal/minutes60 once its old
deadline passes. Do not extend a period by repeating it. Userauthorized rerun
within recovery outcome; do not raise the rejected per-task3/6/3ceilings.
Capture actual group start/end, window start/end, all holds, reserve10percent;
run required60minute maintenance. Product `job run` prunes stale missing
records in its correctly escalated visibility domain before workerstart.
Keep policyapproval pending; five embeddingrequests remainheld and24operational
extraction candidates remainnotreplayed. Fullcorrpuscoveragecannotbeclaimed.
No automation exists. Do not end at commit or launch.

## Checkpoint 2026-09-13 00:18 UTC — schema17 full gate GREEN, commit then rerun

Full session36144 FINISHED0:63/63 in 847.44s. Logs copied to repo evidence.
No additional source/test edits after qualification. Product hashes remain
native02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5;
linked059354153691243cfc04c57ac6a29fb5802ee88505add33df5f646b91c58d113.
Scratch prefix `/private/tmp/crexx-review-index-installed` has matching native
and libexec/crexxrag/crexxrag.rxbin (the linked file is NOT bin/crexxrag.rxbin).
Full gate includes installed-product qualification.144changed-doc relative links
resolved; credential-pattern scan found no matches in evidence. Recheck docs
contract after final prose updates, then localcommit all task changes.

New recorded OPEN P2RAG-SMK-004: readsupervision counts nonterminal registry
rows as live even when stale/exited; correctly visible publicworkerlist confirmed
all7stale PIDs missing. This is distinct from restrictedprocessvisibility.
No codefixclaim; userguide/diagnoseskill/maintainskill explain the current
field and require launchvisibility. Their manifests/toolauthority are unchanged.
No skillapproval requirement was added. Reinstall latest instructions in final
frozenartifactaftercommit. Lastproviderstatus had65percent accountallowance
available, above10percentreserve, no modelcall.

Master remains generation24219/schema16, no activeworkers, higher3/6/3question
stillpending andpolicyunchanged. Exactfailedmaintenancejob/renewalstrategy in
previouscheckpoint. Freeze `artifact-review-index`, capturecommitSHA, public
migrateMASTER, verifyownershipsamevisibility, and resume SAMEfailedjob using
one named60minuteperiod `scottish-maintenance-recovery-20260913` ifolddeadline
expired. Then runandmonitor realmaintenanceforrequiredwindow; recordwallwindow
andactualworkertime separately. Fullgatealone doesNOTcloseRAG-SMK-003orOPS.
No automation exists; stayinactivesession. NeveruseSQLtoliverepair, neverwaive
contentholdsorchangeattemptceilingswithoutthependingauthority.

## Checkpoint 2026-09-13 00:25 UTC — replacement maintenance RUNNING, do not relaunch

**ACTIVE PAID WORKER SESSION59810**. Frozenartifact
`/Users/adrian/testrag/overnight-scottish-20260909/continuation-20260912/artifact-review-index/bin/crexxrag`
from CLEAN committed **1edb325e784fdc0103820f66984da2d89097aab0**.
Full63/63 in847.44s plusinstalledproduct andfinaldocsgate passed beforecommit.
Native02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5;
linked059354153691243cfc04c57ac6a29fb5802ee88505add33df5f646b91c58d113.
Allaccumulatedpriorlogs/docs/Turrayclosureareinthatcommit. Newrunobservations
aftercommitareuncommittedforthenext evidencecommit. No sourceor tests pending.

All9oldownershiprecordswereverifiedexitedinthecorrectescalatedvisibilitydomain.
Publicmasterlibrarymigrateappliedschema17, preservedgeneration24219/aligned
manifest; libraryverifyPASSED. Session78407finished0. Oldartifact-utf8isschema16;
USE NEW ARTIFACT for master now. The selectedpolicyhash remains
e2d82f0fe11043986f25c03e917b9897ab11a47f5b10ff833db906902d516bb0,1attempt.

Publicjobcontinue SAMEfailedjob withone renewal
`scottish-maintenance-recovery-20260913`,minutes60,preparetrue FINISHED0
(session84117),provider_calls0. **Do not add anotherperiod or extendthisone.**
Windowfixed **2026-09-13T00:21:32Z →01:21:32Z**, cleanup5s/percallceiling120s.
Actualgroupstarted **00:23:04Z**. Recordwallwindowvsactualworkertimehonestly;
preparationconsumed92seconds. Monitorthroughcompletionandrecordnormaladmission
cutoff,don'tclaim60minutesofactiveworkers.
Job `job-maintenance:d40ed9c08dc658d3c7449f56d816c50a76a58cd630588800eede91b8c29ae3a9`.
Controller **controller-fde633966985475488f4c4f277910227**,8workers.
Status00:23:23Z:running,89queued/8running/91processed/16skipped/4dead,
0helduncertain,heartbeatage0. Historicalfailedrunbaseline88processed/16skipped/
4dead/92cancelled. Newwindowprepared100freshmaterializeditems;useactualtotals
fromstatusratherthanassumingcancelledIDsrevived. Renewedbudget100000items/calls,
2e9input/6e8output/10m monetaryµ/60000turns; allpriorusagepreserved,per-task1
andper-calllimitsunchanged. Lastaccountread65percentavailable,minimumreserve10.

Runrootfiles:
- maintenance60-review-index-started.txt
- maintenance60-review-index.log
- maintenance60-review-index.err
- maintenance60-review-index.exit and-ended.txt appearONLYaftercompletion.
Latestpublicstatus `/private/tmp/scottish-review-index-maintenance-status-1.json`;
summaryfile `...maintenance-summary-1.json` hasmaintenance-window.backlog JSON
withdeadline/timing/cumulativeprovider_calls. Bothcopiedrepo/runroot.
Statusprovider-time is cumulative1178930ms,112provider_callsatthelatestread;
notnewwindow-onlyfigures. Fiveembeddingsstillmissing34905total.

No otherexecsessionsactive. Do NOT launchanothergroupwhile59810runs.
Pollsession/logs and publicstatus atboundedintervals; provideraccountreserve
aboutfive-minutechecks. Preserveactive_unsettled vsheld_uncertain distinction.
Ifgroupfails,pause/drain,recordfreshPIDs/outcomesbeforeanyrepair/restart.
Fixrunblockerswithregressionfirst/fullQA/commit/newartifact; recordnonblocking
findings forlater. RAG-SMK-004 staleregisteredworkerdisplayremainsOPENP2.
RAG-SMK-003islocallyqualifiedbutLIVEqualificationisongoing.

The3/6/3reasoning/embedding/maintenanceretryapprovalquestionremainsPENDING.
Automaticapprovalreviewrejectedthatpolicywrite; itNEVERran. Don'tbypassvia
newpolicyorpaidreplay.5embeddingrequestsheld,24operationalingestioncandidates
notreplayed,521evidenceholdsretained. Originalingestionqueued0/uncertain0.
TurrayUX01/03/04closedat24219withpublichistory/sourceverification.

Aftermaintenanceends: finalstatus/holds/allowance, correctvisibilityownership,
publiclibraryverify/report/sourceprogress andusage. Reportelapsedwindowandactual
processingseparately; don'tcallglobalbacklogfinishedorcorpuscoveredwhileholds
remain. Updateallcurrentstatus/docs/roadmapandcommitfinalevidence. Endonlyafter
requestedworkiscompletedoractualexternalapprovaldependencyisclearlyreported.
No scheduledautomationexists. Activeexecutionmustcontinue.

## Checkpoint 2026-09-13 00:31 UTC — first replacement batch transition passed

Session59810 is STILL RUNNING. Status00:29:13Z:400actual items,92queued,
8running,170processed,20skipped,18dead,92cancelled;8registeredworkers,
controller running, heartbeat age0, held_uncertain0. This is82additional
processed/4skipped/14dead compared with the failed-run baseline88/16/4.
The batch transition produced explicit SQLITE_BUSY heartbeat retry diagnostics
but recovered without a worker replacement or terminal heartbeat failure.
Do NOT describe this as zero contention. Both repeated review scans are fixed;
census/evidence construction still holds the writer for a bounded batch.
The whole60minute smoke remains in progress, not closed by this transition.

Public hold inventory at00:27-ish had14total failures:8quotation-not-grounded,
4successor-equals-parent,2successor-catalogue-conflict. A later status had18;
refresh final inventory before reporting totals. These are provider response
validation holds; do not relax validation or invent accepted coverage.
Last public provider status now64percent available; preserve10percentreserve.
No unknown outcomes or paid retry policy change. Both diagnostic read sessions
are finished. ONLY59810 remains active.

Current front summary has been added and its timestamp refreshed to make
takeover immediate. Continue roughlyminute publicstatus reads and meaningful
progress updates, five-minute allowance checks, recording batch transitions
and any actual faults. Files throughstatus4/firstholds/secondallowanceread
are copied into repo evidence and runroot. Partial stderr snapshot
maintenance60-review-index-transition1.err is explicitly a mid-run capture.
When eventually finished, capture complete logs/status and final source/coverage
verification, update roadmap/docs with honest closures and remaining holds,
then commit evidence. No scheduler exists and no second group is authorized
while this one is active. Do not end at this checkpoint.

## Checkpoint 2026-09-13 00:36 UTC — two batch transitions passed; run still active

Only paid session **59810** is active; do not relaunch it. At00:35:30 UTC,
status-7 reported500 materialized items:264 processed,39 skipped,28 dead,
92 historically cancelled,69 queued and8 running. The restart has therefore
added176 processed,23 skipped and24 validation failures to baseline88/16/4.
The third new100-item batch is underway. Both transitions recovered bounded
SQLITE_BUSY heartbeat retries without replacement or terminal failure.
Controller state running, heartbeat age0, held uncertain0, replacements0.
Do not describe this as zero contention or as completed60-minute qualification.

Correctly escalated public `worker list` verified controller+8worker PIDs alive
(`scottish-review-index-live-workers-1.json`). Account read3 reported64percent
available, minimum reserve10. Both reads completed; no extra sessions remain.
Snapshots throughstatus7 and providerstatus3 are copied to repository evidence
and runroot; stderr transition2 is explicitly a partial log snapshot.

HEAD1edb325 and product/tests are unchanged and fully qualified. Only ongoing
run notes/evidence are dirty. Master remains on schema17 and the frozen
artifact-review-index. Fixed window still ends01:21:32 UTC; actual group began
00:23:04. Continue minute-scale status and five-minute reserve/process checks,
keep the handoff current, and complete the run plus final public verification,
documentation and evidence commit. The pending higher retry-setting authority
has not arrived; current1attempt remains. No original ingestion replay or
embedding retry bypass, SQL repair, waiver or second allowance was performed.

## Checkpoint 2026-09-13 00:46 UTC — real timeout recovered; maintenance continues

**Only paid session59810 is active.** At00:44:45 UTC, status12 reported600
materialized items,376 processed/46 skipped/42 dead/92 historical cancelled,
43 queued/1 running; controller heartbeat age2,8 registered workers,1 recorded
replacement,0 held uncertain outcomes. New work since restart:288 processed,
30 skipped,38 failures. Do not claim a failure-free run. Fixed window remains
00:21:32→01:21:32 UTC; actual workers began00:23:04.

The third batch's final paid call reached the120-second Codex deadline. Worker
`worker-65ff1fb51bb0e8e676efa28fe4c5e6d4` exited; supervisor replaced it with
`worker-44a3b213ab4bb57fd7ac2bf8ccefc27d` and continued. Public held-item facts
confirm the exact turn is interrupted, not uncertain, with one recorded paid
call and an attempt-limit hold under the unchanged ceiling1. Item:
`item-maintenance:ef465875a2547818dd4afe0f3f7584372ba68417d30d5c8afab5f071617670a8`;
task `task:545363ebb336fe8f6488471cfa9645a212f4b2f7b60cfc491c72205a55668971`.
Its ten claim attempts comprise nine cancelled deferrals with provider_run_id
NULL and one paid attempt,00:39:31.464→00:41:31.765. Provider run
`provider-run-sha256:8b6917094c40d902d4e6f2525fe6e07235dc05027d57b17469c0f9c2e6e1eeec`.
No blind retry or higher ceiling was used. The public status last_error can
retain the old uncertain message even after held_uncertain=0; the current
item's recovery facts say confirmed interrupted/uncertain0/recorded_calls1.

Public worker-list3 in correct launch visibility now confirms controller+8
current workers alive, and the failed old worker not-running. Provider-status5
reports64percent available; minimum reserve10 remains. These reads finished.
Evidence throughstatus12,holds2,timeout-attempts,process-read3 andreserve5 is
copied into repository evidence and runroot. recovery1.err is a partial
stderr snapshot including the real automatic replacement.

At the holds2 snapshot,41 total failures were22 quotation-grounding,3 outside
durable packet,3 successor catalogue conflict,9 successor equals parent,
1 missing identity label/type,1 unsupplied identity candidate,1 synonym
collision,1 confirmed interrupted. Status12 subsequently had42, so refresh
final counts. These source validations remain in force. No new product change
is required merely because an invalid model response was rejected. Record
actual outcomes and distinguish paid transport interruption from content holds.

HEAD1edb325/schema17/frozen artifact remain unchanged. Continue the one group,
minute status and roughlyfive-minute actual PID/reserve checks, preserving its
fixed named renewal. Higher3/6/3policy approval is STILL PENDING; it was never
applied. No additional original ingestion replay/embedding retry/waiver/SQL
repair. The first maintenance attempt remains a failed smoke; this replacement
is still underway. Complete final public verification/report/hold inventory,
update roadmap and evidence, and commit afterwards. Do not end now.

## Checkpoint 2026-09-13 00:58 UTC — window past midpoint; fifth batch transition passed

**Only paid session 59810 is active.** Status 16 at 00:57:10 UTC reports
800 materialized items: 546 processed, 61 skipped, 64 dead, 92 historically
cancelled, 29 queued and 8 running. Compared with the failed-run baseline
88/16/4, this restart adds 458 processed, 45 skipped and 60 holds. The controller
heartbeat age is zero, one replacement is recorded, and held uncertainty is
zero. Six active unsettled calls are work in flight, not reconciliation holds.

The fixed deadline remains 01:21:32 UTC; actual worker start was 00:23:04.
Public process read 5 in the launch permission domain confirms one live
controller and eight live current workers. The earlier failed worker remains
visible as failed/not-running. Provider status 7 reports 63% available.
Summary 2 still reports five missing embeddings and zero waivers. No policy
change, paid replay, extra renewal or direct SQL repair has been performed.

All temporary review-index JSON snapshots through status 16, process read 5,
provider read 7 and maintenance summary 2 have been copied to repository
evidence and the run root. Product code/tests are unchanged at 1edb325; the
remaining dirty files are ongoing evidence and this handoff. Continue to the
fixed deadline, collect terminal logs/exit and public integrity, progress,
current holds and drained ownership. Update roadmap and commit final evidence.
The 3/6/3 retry-policy question is still unanswered; do not perform dependent
retries or claim complete corpus coverage. RAG-SMK-004 remains open P2.

## Checkpoint 2026-09-13 01:05 UTC — bounded maintenance continues

Only paid session **59810** is active. Public status at 2026-09-13T01:05:15Z
reports 1000 materialized items: 670 processed,
73 skipped, 75 dead, 92 historical
cancellations, 82 queued and 8 running. Since restart,
that is 582 additional processed items, 57
skips and 71 holds. Recorded replacements:
1; held uncertainty: 0;
controller heartbeat age: 0 seconds.
All current temporary JSON snapshots are copied to run root and repository.
No product or policy changes. The fixed window still ends **01:21:32 UTC**.

Source review confirms that an automatically replaced failed slot is removed
from the current failure count (`ragprocess`, replacement launch), while its
original process/attempt history remains. A terminal exit 0 would therefore
mean the group recovered and drained; it would not mean no timeout occurred.
Report the actual terminal result, replacement and retained holds separately.

After session 59810 finishes and its .exit file exists, the prepared one-time
read-only audit script `/private/tmp/scottish-final-public-audit.py` can be run
with escalation for launch-domain process visibility and evidence writes. It
uses only public commands, follows all hold cursors for both jobs, and captures
source progress, report, verify and maintenance state. No paid work or repair.
Inspect every result, then update final docs/roadmap/coverage/handoff and commit.
Do not run another maintenance window or bypass the pending retry-policy
approval. There is no automation. Continue this live task through verification.

## Checkpoint 2026-09-13 01:15 UTC — bounded maintenance continues

Only paid session **59810** is active. Public status at 2026-09-13T01:14:53Z
reports 1100 materialized items: 817 processed,
99 skipped, 92 dead, 92 historical
cancellations, 0 queued and 0 running. Since restart,
that is 729 additional processed items, 83
skips and 88 holds. Recorded replacements:
1; held uncertainty: 0;
controller heartbeat age: 7 seconds.
All current temporary JSON snapshots are copied to run root and repository.
No product or policy changes. The fixed window still ends **01:21:32 UTC**.

Source review confirms that an automatically replaced failed slot is removed
from the current failure count (`ragprocess`, replacement launch), while its
original process/attempt history remains. A terminal exit 0 would therefore
mean the group recovered and drained; it would not mean no timeout occurred.
Report the actual terminal result, replacement and retained holds separately.

After session 59810 finishes and its .exit file exists, the prepared one-time
read-only audit script `/private/tmp/scottish-final-public-audit.py` can be run
with escalation for launch-domain process visibility and evidence writes. It
uses only public commands, follows all hold cursors for both jobs, and captures
source progress, report, verify and maintenance state. No paid work or repair.
Inspect every result, then update final docs/roadmap/coverage/handoff and commit.
Do not run another maintenance window or bypass the pending retry-policy
approval. There is no automation. Continue this live task through verification.

## Checkpoint 2026-09-13 01:26 UTC — live run and final audit complete; evidence commit next

Paid session 59810 and audit sessions 19605/61731 are finished. No active
controller/worker PIDs remain. Complete logs, final paged hold inventories,
status/progress/report, search/citation and provider reserve are retained in
repository evidence and run root. The corrected diagnose-access verification
passed with zero issues; the first read-access denial is retained as an
invocation mistake. Policy SHA remains e2d82f0fe11043986f25c03e917b9897ab11a47f5b10ff833db906902d516bb0.

Final maintenance totals: 879 processed/128 skipped/101 dead/92 historical
cancelled, zero queued/running/held uncertainty. Restart delta: 791/112/97.
Original ingestion: 15463 processed/15565 skipped/550 dead, zero queued/running/
uncertain. Five embeddings missing; no waivers. Final generation24922, 8sources,
34905chunks, 34900embeddings. Global durable open32565, migratingworkflows44.

New RAG-SMK-005: public job status projects completed_with_errors, job list
retains paused, report counts it active, while maintenance window is deadline
and all PIDs exited. Owner raglifecycle projection through ragwork versus raw
ragrepository/ragreportservice readers. Recorded open P2 with parity regression
requirements; no code fix performed. RAG-SMK-004 also remains open P2.

Final acceptance, architecture, roadmap, defects, coverage and test-strategy
notes are updated. Run the documentation_contract gate and git diff --check,
review actual changed files/evidence for secrets and incorrect closure claims,
then commit all this task's final docs/evidence locally. Do not run new paid work
or modify product code merely to hide retained content holds. No push/release.
The pending exact retry-policy approval is still unanswered and was not applied.

## Checkpoint 2026-09-13 01:28 UTC — final verified takeover state

No process, tool session or automation is running. The authorized bounded live
work ended and its final audit is complete. Product remains 1edb325/schema17;
final docs/evidence are the only subsequent changes. Documentation contract
passed 1/1 in 0.08s, git diff --check passed, 119 relative links resolved, all
new JSON parsed, and the bounded credential-pattern scan found no matches
across the 99 changed files at that scan. Exact logs are retained. The local
commit containing this checkpoint is the final evidence commit; no push.

Start any next session from the final smoke report and ROADMAP, not the old
running checkpoints. RAG-SMK-004/005 are open P2 with named owners and required
regressions. Five embeddings and retained operational/content holds remain;
exact 3/6/3 retry policy approval is pending and no such write ran. No new
paid continuation period is authorized by the expired window. Preserve the
single selected policy, all histories, 10% reserve and separate query copy.
The broader corpus outcome is explicitly open; only the named closures in the
final report are closed. User can plan from those actual acceptance boundaries.

## Checkpoint 2026-09-13 08:19 UTC — user-directed simplicity and routine restart

User explicitly corrected the proposed recovery complexity: persist worker and
controller PIDs; children stop taking work and exit when the controller is gone;
restart always performs polite shutdown, database runtime cleanup and starts
fresh children. An incomplete task is an accepted small cost. Codified the
simplicity principle in AGENTS.md, the implementation direction and ownership
in architecture.md, and the pending work in ROADMAP.md. Do not revive the prior
proposal for new liveness protocols, controller election or preserving every
in-flight result. Keep existing committed-data/accounting/retry protections.

No product code, schema, policy, library or paid run changed. These documentation
changes are uncommitted; this discussion did not request a new commit or runtime
implementation. Documentation_contract passed 1/1 and git diff --check passed.
The next implementation must first confirm regression coverage for the simple behavior.
The completed smoke at product1edb325/evidence9292c8d remains historical evidence;
this new controller-loss contract is pending implementation. No active run.

## Checkpoint 2026-09-13 08:52 UTC — test-only baseline, full gate running

Authoritative checkout remains `crexx-rag-review`, `temp/project-review`, HEAD
`9292c8d8d724b52fce34047c868f15531348faca`. Product source is unchanged.
`cmake --preset debug` passes; build reports no work. Native SHA-256:
`02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5`.

Pre-change affected panel: 6/6 pass, 129.55s; log
`/private/tmp/smoke-regression-baseline-20260913.log`.
Two new public tests in `cmake/SmokeStatus.cmake` fail only their intended
SMK-004/005 expectations, with positive and read-only controls passing.
`cmake/NativeInterruption.cmake` retains its three original cases and adds
controller-only death (1 initial attempt becomes 3) and ordinary restart with
live ownership (exit 6, no fresh controller). The original interruption gate
still passes. The repeated-continuation assertion compares fresh identities,
not retained runtime row counts, because normal pruning can remove old rows.

Full CTest is running as exec session **49902**. Log:
`/private/tmp/smoke-regression-full-20260913.log`. Expected result: the previous
63 pass, the four new named regressions fail. Inspect every other failure;
fixture failure is not valid defect evidence. Finish the run, retain exact logs
under `docs/qa/restart-coverage-20260913/`, replace pending results in the coverage
record and this handoff, then run documentation/diff checks. Do not implement
product fixes to turn this explicitly requested red baseline green.

Roadmap records routine cleanup/start, controller and child PID ownership,
child exit before further work, fresh children, accepted unfinished-task loss,
and preservation of committed history/usage. It also corrects the obsolete
OPS-005-open sentence. Instructions already require regression coverage first.
Remaining process-scope/permission branches, adjudicated content fixtures and
census-duration profiling are explicit limits, not claimed covered outcomes.
All changes remain uncommitted for the requested next session. No live activity.

## Checkpoint 2026-09-13 09:02 UTC — test-only handoff complete

Full local suite: **63/67 pass in 879.91s**, CTest exit 8. The previous 63
checks all pass; the only failures are the four new ordinary regressions:

- `regression_smoke_stale_workers`: confirmed exited worker still counted live.
- `regression_smoke_terminal_state`: drained status differs from list/activity.
- `regression_controller_loss`: child takes further work after controller death.
- `regression_restart_live`: ordinary job run rejects surviving ownership
  instead of cleaning it and starting a fresh controller/children.

Final focused repeat: **2/6 pass in 15.28s**, same four failures;
original interruption and documentation tests pass. New controls verify live
processes even with old heartbeats, real pauses/unknown outcomes in listings,
unchanged read-only SQLite, and completed work/receipts preserved when ordinary
continuation is repeated after drain. Scratch provider/process fixtures only.
`git diff --check` passes. No product implementation, live library or policy
changed. No commit, push or live run was performed in this test-only step.

Evidence: `docs/qa/restart-coverage-20260913/` contains baseline/configure/build,
full and final-focused logs, public command responses and test source hashes.
Native hash remains `02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5`.
The tracked work plus new `cmake/SmokeStatus.cmake` and evidence files are all
uncommitted; retain them together. Nothing is stashed or reset.

Next session: read AGENTS.md, the current coverage section, and the simple
restart section in ROADMAP/architecture. Fix the two status readers and then
the simple controller/restart outcome, keeping related rules in their existing
owners. Confirm additional affected branch coverage before editing. The four
new tests must become green through product fixes; do not skip/invert them.
Do not revive the old election/adoption design or require perfect recovery of
unfinished work. All historical paid-run windows are over; current test work
adds no live-run or retry-policy authority. The wider retained corpus/content
acceptances and qualification limits remain listed rather than silently closed.

## Checkpoint 2026-09-13 11:34 UTC — full gate caught preparation regression

Full first candidate 64/67 in 975.40s; continuation and continuation-holds failed
because preparation drained live ownership. Legacy retry then failed fixture
readiness after the first failed test left the port occupied. All four requested
regressions and the later embedding-policy case passed. The stronger exact
runtime-request check reproduces the mutation (37.62s); `ragproduct` now skips
cleanup for `--prepare` and leaves existing ownership refusal in charge.
Build/focused/full/installed gates remain required. No live library changed.

## Checkpoint 2026-09-13 11:40 UTC — corrected focused panel green

Preparation-only guard build passes on native `62eaaa2292e210b0c468d2de58ed126ca92557a1a24760109d863c764b85fa81`, linked `01712c8c081097b4208d982208035502735f2fbd84c574428dcd8bc0047e340c`.
Focused **9/9 in 67.06s** includes all four repaired regressions, original
interruption, both continuation cases and both legacy/embedding retry cases.
Full rerun session 52467 is running with `caffeinate`. Inspect final status;
then separately install to the working evidence directory's `installed` prefix,
verify the native hash and run the four fixtures plus original interruption.
No live operations, commit or policy change is authorized by this repair.

## Checkpoint 2026-09-13 11:57 UTC — four repairs locally qualified

Build and full QA completed: **67/67 in 932.92s**, exit 0. Separate
scratch-installed replay: **5/5**, installed native SHA-256 `62eaaa2292e210b0c468d2de58ed126ca92557a1a24760109d863c764b85fa81`.
No product source changed after the full gate. The current front summary and
[four-fix record](four-smoke-fixes-20260913.md) supersede the earlier test-only
instructions. Changes remain uncommitted on `9292c8d`; no push or new live run
was performed. The retained logs preserve the failed baseline and intermediate
parent-identity failure as well as the final passing gates.
