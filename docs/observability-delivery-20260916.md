# Essential observability delivery — 16 September 2026

Implements the [approved six-criterion plan](observability-plan-20260916.md).
Current status belongs in ROADMAP.md. Implementation and the full local gate
have passed. The approved bounded corpus-copy run and its closeout have also
passed. Master installation and publication are outside this authority.

## Baseline and coverage

Source baseline: `6b706308220b43bcf163c79410f879f850169f2e`, clean product source
before this change. Existing documentation changes were preserved. The installed
CREXX header identifies `94f2f228c31339f87bb66b714724bdb4ed3a8420`; Adrian reports
#699 fixed in that local installation.

Before implementation, `regression_operator_diagnostics` passed (8.85s),
`regression_prompt_inspection` passed (3.55s), and
`regression_command_metadata` passed (0.53s). Their assertions cover read-only
CLI/MCP parity, filters before pagination, prompt builders and frozen public
schemas. The initial component-only selection matched none because these named
cases are in fast/integration; the regression selection ran exactly these three.

The operator fixture was extended first with cross-job model/error selection,
original request/failed response inspection, unavailable legacy request, literal
filter text and wrong-item/attempt ownership. The unchanged native baseline
failed as intended at `job items --all --model fixture-sol --error grounding`:
`unknown option --all`. Earlier positive controls in the same case passed.
Receipt: `cmake-build-debug/qa/runs/regression_operator_diagnostics/20260916T205540-cb48aaf8`.

## Acceptance tracking

1. Find — passed: filters before paging, selected matching attempt IDs, task
   lineage, CLI/MCP parity and advanced no-change/applied/retained controls.
2. Inspect — passed: immutable original requests, successful/rejected output,
   correction history, receipt reuse, Unicode paging and explicit legacy gaps.
3. Diagnose — passed synthetic authentication, slow valid provider, malformed
   response and independent SQLite writer controls. Original errors and separate
   lock-wait/body timings survive; failed BEGIN is visible on stderr.
4. Report — passed: summary/error examples agree with attempts, including
   preflight authentication cancellations, without inventing provider calls.
5. Safe and efficient — passed read-only database comparisons, credential
   redaction and corpus-sized measurement below. Cold-read limits are explicit.
6. Qualify — passed: 123 local checks, one bounded isolated-copy run, stopped
   workers and one clean copy verification. Operational/content defects remain
   tracked separately; this does not claim perfect maintenance quality.

No commit, push, release or master corpus modification is authorised by this
record. The approved run is limited to an isolated copy under the plan's ceilings.

## Capture and query work

The initial filtered item/inspection acceptance passed (10.30s), including
unchanged-library dumps. Expanded job-list/summary acceptance then reproduced
missing job filters on the unchanged query baseline.

Before capture changes, `provider_durability` (13.53s), `native_receipts` (5.96s),
`native_receipt_failure` (7.81s), and `gemini_extraction_validation` (4.82s) all
passed in isolated parallel fixtures. Request-retention assertions added to the
last two fixtures failed as intended: zero retained original requests. The
existing positive controls still verified recovery without duplicate calls,
original-attempt accounting, rejected-output redaction and no graph publication.

Capture is composed into the existing intent transaction in `ragreceipts`;
`ragwork` forwards its optional argument. `ragapplicationprovider` serializes the
application request. Provider adapters preserve rejected text separately from
validated content, so diagnostic retention cannot make rejected output replayable.
Queries remain in `ragoperationsquery`, using the repository's existing job
projection; catalogue and product dispatch remain adapters. No schema migration
or new diagnostic service has been added.

The subsequent acceptance extended adapter failure capture, transaction
timings, summary counts and search history before the final gate below.

Request capture acceptance passed in `native_receipts` (8.50s) and
`gemini_extraction_validation` (8.30s). The expanded query case exposed padding
on the final detail page; the implementation now bounds that substring to the
remaining characters. Metadata changes were reviewed for read permissions,
bounded arguments and CLI/MCP parity before updating the frozen metadata hashes.

The unmodified supervision case passed (23.64s). An independent writer fixture
then failed on both VMs because checkpoint and claim-context errors discarded
SQLite code and lock timing. The new provider observation fixture passed its
synthetic authentication and 250ms valid-response controls, then failed because
malformed Codex output was absent from durable inspection. These are diagnostic
reproductions, not evidence that contention caused the earlier live slowdown.


## Stable-build local qualification

Candidate native SHA-256:
`ca6d0af96292afc86759676f4a41eb749d7fa46c506b06b5def2895c5cc11075`.
Linked application SHA-256:
`2a411698b5879a2afafe11aa4076c5bfd178068e1bb8971457cb3ac91e029a93`.
The same native binary is staged only under the private run directory.

`ctest --preset regression --output-on-failure` took **534.54 seconds**:
121 fresh passes plus two retained exact-input passes (`observability_providers`
and `regression_operator_diagnostics`). The required receipt audit
`python3 tests/qa/report.py --json out/observability-20260916/qa-report.json --require-complete`
confirmed **123 passed**, with no disabled, missing or failed functional cases.
The explicit long-turnover scale lane remains separate and was not run.
No hosted Gemini call was made; the local Gemini contract, malformed-output and
secret-redaction journeys passed. This is local qualification, not new hosted or
cross-platform qualification.

Targeted checks took roughly four minutes of parallel wall-clock execution
across the baseline, deliberate failures and repair iterations. From the initial
baseline selection at approximately 20:54 BST to final gate completion at 21:40
BST, about 46 minutes elapsed, including editing and rebuilding. The final full
gate reused unchanged passes. No second full gate is required for the documentation closeout. Local
receipts and logs: `out/observability-20260916/{full-qa.log,qa-report.json,qa-audit.txt}`.

## Corpus-sized read and recording measurement

The public backup copied the 4.04 GB Scottish SQLite/sidecar library at generation
28234. Five serial read samples per case were taken after QA completed, comparing
the installed baseline with the candidate where the command already existed.

| Read | Baseline median | Candidate median | Candidate first sample |
| --- | ---: | ---: | ---: |
| Job status | 268 ms | 268 ms | 269 ms |
| Job items | 223 ms | 217 ms | 217 ms |
| Cross-job item search by model/error | — | 269 ms | 1,021 ms |
| Job search by model/error | — | 584 ms | 5,591 ms |
| Diagnostic summary | — | 314 ms | 313 ms |

Selected historical detail sections took 195–202 ms each (one sample each).
Original missing requests were reported unavailable. The filtered job search has
visible cold-read cost; subsequent reads are subsecond. This small sample is not
a latency guarantee, and no claim of constant-time scaling is made.

Three isolated synthetic call/recording journeys per binary retained one actual
call each. Median elapsed time was 374 ms for the baseline and 381 ms for the
candidate (about 7 ms / 2% difference), with 15,073 request bytes newly retained
per candidate call. Compiled CREXX runtimes differ, so this bounds end-to-end
regression in this fixture rather than isolating capture CPU cost. Provider work
was synthetic and immediate; no real provider call or corpus mutation was needed.
No material regression appeared in the existing reads or this recording sample.
Raw samples and fixtures: `out/observability-20260916/performance.json` and
`measurement-fixtures/`.


## Inspectable live examples

The read-only example collector uses public filtered item lists and `job inspect`
only. It saves every page, pins the selected attempt, and verifies the assembled
character count and SHA-256. Original requests in this sample range from 14,139
to 64,725 characters; the longest requires eight pages. Example receipts and
complete bodies are under `out/observability-20260916/examples/`, indexed by
`index.json`. These are selected illustrations, not an accuracy sample.

- **Identity failure:** Luna Low returned `reuse` with a supplied Highlands
  concept ID in `object_id`, leaving `target_concept_id` empty. The existing
  identity validator selects the latter field; this explains that rejection
  without assuming the model invented a concept. The request schema supplies
  both fields as strings, while the retained prompt does not explicitly map
  `reuse` to the target field. Compare `identity-failure-request.json` and
  `identity-failure-response.json`.
- **Advanced final no-change:** the retained request verifies Sol Medium, and
  its response declines a type correction or merge for a generic Highlander
  reference. The accepted decision and parent-task link are retained. This is
  evidence of the route and final-null mechanism, not an independent historical
  accuracy judgment.
- **Applied change:** Luna Low uses the alias subject as `object_id` and a
  supplied concept as `target_concept_id`; its `reuse` passes validation and
  has an applied generation. This is a positive control for the field mismatch
  in the failed example.
- **Correction success:** the original assistant response and validation
  feedback are present in the next request; the corrected outcome is an
  accepted escalation. Successful correction is not necessarily task closure
  or graph mutation.
- **Correction failure:** original response, feedback and a second rejected
  quotation remain separately inspectable. No extra retry was introduced.

The concrete next prompt review is the subject/action field mapping, including
an explicit `reuse` example and consistent correction guidance. Prompts and
processing policy were deliberately preserved for this acceptance run; no prompt
repair or comparative model-quality claim is included in this delivery.


## Bounded Scottish copy run and closeout

Job `job-maintenance:9bcb0b068ceb88ddf412f8b86dcc6407cd62d88c134bc289d7275effdc67fa0c`
ran from **20:45:16 to 20:56:10 UTC** (21:45–21:56 BST), about **10m54s**.
The 300-item allowance closed the window with 267 actual provider calls, before
either the 300-call or 30-minute ceiling. Eight workers used the unchanged
Luna Low / Sol Medium policy and prompts. No ingestion, resets, allowance
renewals or second window occurred. Monetary cost was zero. Account-wide
remaining allowance was 17% before and 16% after; that coarse shared change is
not attributable solely to this job.

The copied policy retained the original read-only absolute source/glossary paths
so relocation did not change semantic configuration identity. Public config diff
confirmed the same semantic hash. All SQLite, vector, policy publication, worker,
installation and output state belonged to the private copy.

| Measure | Result |
| --- | ---: |
| Materialised items / distinct linked tasks | 300 / 259 |
| Processed / skipped / dead letter | 162 / 48 / 90 |
| Provider runs: successful / failed | 164 / 103 |
| Final no-change / applied-change decisions | 41 / 44 |
| Input / output tokens | 5,093,282 / 108,537 |
| Correction requested / corrected item processed | 20 / 6 |
| Worker failures / replacements | 0 / 0 |
| Terminal queued / running / held uncertain / reserved calls | 0 / 0 / 0 / 0 |

The job correctly ends `completed_with_errors`; controller completion is not
content-quality success. Processed items, distinct tasks, decisions and provider
successes have different meanings. In particular, a validated provider response
can fail subsequent domain checks; an accepted escalation is not final task
closure. Whole-backlog resolved tasks increased by 90, distinct from 162
processed items.

The first approximately five-minute observation reported 71 processed items and
14.2/min over its 300-second interval; the next reported 149 processed and
16.6/min. All eight workers remained live, with no replacements, held uncertainty
or recorded authentication failure. The previous severe throughput degradation
was **not reproduced** in this shorter, subsequent-task sample.

### What the timings establish

Eight heartbeat SQLITE_BUSY retry messages occurred. Neither instrumented BEGIN
failed in this run. The synthetic independent-writer acceptance proves those
failed acquisitions remain observable when diagnostic writes cannot succeed.

| Measurement | Recorded count | Median | 95th percentile | Maximum |
| --- | ---: | ---: | ---: | ---: |
| Checkpoint lock wait | 426 | 0 ms | 669 ms | 3,465 ms |
| Checkpoint transaction body | 426 | 110 ms | 229 ms | 3,377 ms |
| Claim-context lock wait | 1,069 | 0 ms | 0 ms | 359 ms |
| Claim-context transaction body | 1,069 | 0 ms | 2 ms | 24 ms |

Checkpoint samples deliberately include only operations whose wait plus body
reached 100ms; these are not percentiles for every checkpoint. Body timing ends
before commit. Millisecond rounding can report very short work as zero.

This establishes that appreciable lock waits and writer work also occur during
a run with healthy authentication and steady progress. It does not identify the
exact blocker for every wait or disprove authentication as a contributor to the
earlier incident. RAG-SMK-003 remains open for targeted contention investigation;
no speculative retry or transaction-policy repair was made here.

### Reconciled capture and errors

Public attempt/event pages account for 1,069 attempts and **267 distinct provider
runs**, with **267 original request and 267 response records**. Every called
attempt has its request. The 802 attempts without requests are 754 uncalled
admission deferrals and 48 stale-evidence skips. They are not lost provider calls.
This distinction matters when reading the summary's `attempts_without_request`.

The 105 failed/dead-letter attempts comprise 44 identity target-selection errors,
28 invalid object selections on resolution control actions, 26 quotation-grounding
errors, two citations outside the packet, three stale identities and two invalid
split successors. The compact categories deliberately leave unclassified domain
errors as `unknown`; the original validation message is retained. Prompts should
be improved from these paired inputs/outputs, not just the category totals.

The controller and all eight workers stopped cleanly. One final `library verify`
passed with zero issues and aligned manifest at generation **28283** (from 28234).
All 36,319 existing embeddings remain present. Master status exactly matches the
pre-run receipt at generation **28234**; master policy bytes and native SHA-256
are unchanged. No commit, push, release or master installation was performed.

Evidence: private `RUN.md`, `check-01-*`, `check-02-*`, `final-*`,
`transaction-timings.json`, `run-audit.json`, `run.stderr.log` and the selected
example index under `out/observability-20260916/`. Data files are local acceptance
artifacts, not checked-in corpus content. The sole final documentation check and
receipt re-audit close the documentation changes without rerunning product QA.
