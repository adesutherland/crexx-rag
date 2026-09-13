# Scottish continuation smoke — 12–13 September 2026

Later local repair: the two public-status defects and the controller-loss/restart
requirements have been implemented in the review checkout. See the
[four-fix qualification](four-smoke-fixes-20260913.md). This report retains the
actual earlier live smoke outcome; no new corpus run is implied.

The requested implementation and bounded maintenance smoke are complete. **The
whole corpus recovery outcome is not closed:** retained ingestion failures,
five missing embeddings and two public-status defects remain. This report is
the current acceptance record; the [handoff](operator-continuation-handoff.md)
contains exact operational identities and the [roadmap](ROADMAP.md) owns status.

## Artifact, QA and actual run

The continuation implementation was committed as `702af3a`. Three smoke repairs
were independently reproduced, tested and committed: `d1cc6f5` (active versus
held uncertainty), `3b4c481` (Codex UTF-8 frame decoding), and `1edb325`
(review-hold lookup index, schema 17). Each passed the full 63-test suite;
the final product gate passed **63/63 in 847.44 seconds**, including installed
qualification. No source change followed that gate; this final commit records
live evidence and documentation. No push or release was performed.

The processing master is `/Users/adrian/testrag/overnight-scottish-20260909/library`.
Its frozen executable is
`/Users/adrian/testrag/overnight-scottish-20260909/continuation-20260912/artifact-review-index/bin/crexxrag`.
The permanent ScottishHistory query copy was not processed or replaced.

| Boundary | Actual evidence |
| --- | --- |
| Product commit | `1edb325e784fdc0103820f66984da2d89097aab0` |
| Native SHA-256 | `02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5` |
| Linked SHA-256 | `059354153691243cfc04c57ac6a29fb5802ee88505add33df5f646b91c58d113` |
| Named renewal | `scottish-maintenance-recovery-20260913`, same retained maintenance job |
| Fixed 60-minute window | 13 September, 00:21:32–01:21:32 UTC |
| Actual worker group | 00:23:04–01:19:59 UTC: **56 minutes 55 seconds** |
| Shutdown | New-call admission stopped before the deadline; the last call settled and all workers drained |
| Result | Exit 0; 8 completed workers, 0 unreplaced failures, 1 recovered timeout/replacement |
| Final process read | Controller and all nine historical/current worker PIDs not running |
| Publication | One publication check, `identical-no-op`; existing vectors retained |
| Final policy | SHA-256 `e2d82f0fe11043986f25c03e917b9897ab11a47f5b10ff833db906902d516bb0`, unchanged |
| Account reserve | 63% available; retained minimum 10%; no reset credit used |

This is a completed **bounded 60-minute-window smoke**, not 60 minutes of
active worker execution. Preparation consumed 92 seconds; conservative call
admission and draining ended execution before the fixed deadline. The earlier
maintenance smoke failed with writer contention and remains recorded as failed.
The replacement made nine batch transitions without terminal heartbeat failure.
It still emitted bounded SQLite BUSY heartbeat retries; it was not contention-free.

## Processing results and remaining coverage

| Work | Processed | Skipped | Retained dead letters | Queued/running |
| --- | ---: | ---: | ---: | ---: |
| Original ingestion job, final | 15,463 | 15,565 | 550 | 0 / 0 |
| Maintenance job, including first failed run | 879 | 128 | 101 | 0 / 0 |
| Added by repaired maintenance run | **791** | **112** | **97** | — |

Maintenance also retains 92 historical cancellations from the failed run.
Neither job has a held unknown provider outcome or an active unsettled call.
The original ingestion retains 13 incomplete usage observations; maintenance
retains one. Its 1,103 provider runs, 21,364,230 input tokens, 511,021 output
tokens and 12,477,012 aggregate provider milliseconds include the first failed
run and parallel calls. Those provider milliseconds are not wall-clock runtime;
subscription cost recorded as zero is not evidence that processing was free.

Final library verification passed at **generation 24,922**, schema 17, with zero
storage/repository issues and aligned publication. The report shows:

- 8 sources, 8 revisions and 34,905 chunks; no source reimport.
- 34,905 lexical rows; source provenance passes, with zero unsupported claims.
- 34,900 stored/published embeddings: **five still missing**.
- 27,509 concepts, 28,736 aliases, 63,056 mentions, 7,964 claims and 8,244 supports.
- 4,402 pending reviews; 32,565 durable open tasks and 44 migrating workflows.
- Zero waived tasks and zero waived dead letters.

The durable open-task count rose from 30,640 after ingestion to 32,565 after
maintenance. Processing counts are completed operations, not a net backlog
reduction or a quality score; census and workflow fan-out can expose additional
work. The 60-minute sample did not finish all maintenance or all content review.
A lexical Turray query returned typed evidence, and the complete 108-character
Turray citation remained unchanged after maintenance.

The complete original hold inventory is **521 evidence-validation failures,
24 operational extraction failures and five embedding failures**. The 24
operational reasons are eight expired leases, seven provider-time exhaustion,
five confirmed interruptions, three uncalled preflight timeouts and one failed
reservation begin. No replacement ingestion job or higher-policy paid replay
was submitted. All 550 are retained job-history rows; do not claim all are
currently actionable solely from that count. The whole-library reconciliation
reports 13,973 historical dead letters, 13,597 actionable, 376 resolved, zero
replaying and no reconciliation warning. Those totals span all jobs.

Maintenance's 101 retained holds comprise 52 ungrounded connection quotations,
three citations outside the packet, 28 successors equal to the parent, three
catalogue conflicts, nine unsupplied identity candidates, four missing identity
label/type responses, one synonym collision and one confirmed interruption.
Four content failures belong to the first run; the repaired run added 96 content
holds and the one interrupted call. Validation was not weakened to improve counts.

The timeout's exact Codex turn was confirmed interrupted, with no reusable
answer; the supervisor replaced its worker and healthy peers continued. Its
paid attempt and nine uncalled deferrals remain in history. No unknown paid
call was blindly repeated, and no attempt history was reset.

## Closure and next work

| Item | Current conclusion |
| --- | --- |
| RAG-SMK-001 | Closed: active submitted work and held uncertainty separated; automated and actual-run evidence |
| RAG-SMK-002 | Closed: split UTF-8 framing reproduced/fixed; upgraded original ingestion drained without another panic; exact original live fragment was not captured |
| RAG-SMK-003 | Closed for the reproduced review-scan stall: scale/upgrade regression plus successful repaired bounded maintenance run; remaining census contention is separately documented |
| UX-01 / UX-03 / UX-04 | Closed for the named actual Turray discovery, reviewed connection correction and retirement acceptance at generation 24,219 |
| RAG-OPS-005 | Closed: ordinary same-job renewal/continuation works on stopped ingestion and the failed maintenance window, retaining limits, history and cutoff |
| RAG-OPS-001 / RAG-OPS-002 | Whole recovery acceptance remains open: five embedding repairs and selected operational retries were not executed under a higher retry policy |
| RAG-OPS-003 | Open: RAG-SMK-004 stale registered workers called live, and RAG-SMK-005 conflicting final job states |
| RAG-OPS-004 | Local outage/burst/restart controls and actual isolated timeout recovery pass; broader outage/platform qualification remains explicitly outside this smoke |

Automatic approval review rejected a persistent retry-ceiling increase as an
exact paid-processing policy change needing authorization. The requested
reasoning/maintenance ceiling 3 and embedding ceiling 6 remain **unapplied**;
the existing one-attempt policy is unchanged. The earlier approval question is
still unanswered. This dependency was not bypassed with a second policy, reset
history, waived coverage or an alternative paid replay. The public retry
requests for the five embeddings remain retained and held.

Prioritize the two small status defects by using the shared lifecycle and
supervision facts consistently in all public readers. Next, use retained
content failures as fixtures for `ragresolutioncontract`/`ragquotationcontract`
and their validators before changing prompts. Separately profile and shorten
`ragbacklog`'s census writer critical section while preserving snapshot and
publication fences. The proven immediate stall was an access-path defect;
additional executables would not have fixed it. These are evidence-led next
changes, not completed work in this commit.

## Evidence and invocation corrections

[Retained evidence](qa/operator-continuation-20260912/) includes all final public
hold pages, both job progress/status reports, process ownership, account reserve,
library report/verify, search/citation checks, exact artifact hashes and complete
worker logs. `scottish-review-index-final-audit-summary.json` indexes the reads.
The first audit `library verify` used `read` access and was correctly denied;
its corrected `diagnose` invocation passed. Both results are retained. That was
an invocation mistake, not a product defect. No live SQL repair was used.
