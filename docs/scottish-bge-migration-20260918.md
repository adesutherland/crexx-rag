# Scottish BGE embedding migration — 18 September 2026

User-authorized scope: migrate embeddings on an isolated copy with eight
workers, update its configuration and test it. Processing and corpus acceptance
are complete. The previously authorized master replacement completed at
19:24 BST, with the original library/tools/configuration retained together.
Adrian explicitly authorized replacement of the original after checks pass,
retaining a rollback backup, and accepted finishing with eight workers despite
the observed contention.

The working folder and durable run record are
[`reports/bge-migration-20260918/RUN.md`](/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/RUN.md).
It retains the original policy, generation-pinned backup, separate restored
library, exact installed tools, configuration/maintenance plans and public
command evidence. No SQL edits or source reingestion are used.

The starting corpus is schema 19, generation 29385: 11 source revisions,
36,319 parent chunks, 29,127 concepts, 8,105 claims and 8,383 supports.
The baseline public report has zero integrity issues and complete Gemini
embedding coverage. Twenty frozen reference citations resolve to their exact
original text before migration.

The executable is the exact locally qualified
[windowed BGE candidate](windowed-embedding-delivery-20260918.md), SHA-256
`fe7478d4348eb89fd5f36ae9badde83289621c6d30b5710194f43f213c84fd6e`.
All 15 native runtime files match the installed packaging manifest. No rebuild
or change to inference interfaces accompanies this run; RAG-PROV-01 stays deferred.

The replacement role selects pinned BGE-small F16, 384 dimensions, 512 tokens
per overlapping window, native concurrency eight and a 60-second call timeout.
The applied embedding-only plan starts with 36,319 missing parents and a
60-minute window, retaining the existing 50,000-call/item and token ceilings.
Network access is denied to the controller and its children. Generation routes
and prompts are preserved, and the selected job cannot perform extraction or
graph resolution. Original vectors remain stored.

Acceptance will report completed parent coverage, calls/usage, elapsed time,
worker health, vector publication, public source/graph report comparison,
unchanged reference citations and retrieval over the 24 frozen questions.
Lexical inspection supplies a zero-provider full-corpus comparison. This is
not a live hosted Gemini comparison or broad QE-09 qualification.

The completed acceptance below uses the preserved report-fixed installation,
not the partially rebuilt development output or newly replaced CREXX package. Wider
standalone-reader packaging, uninterrupted live cutover and common-interface
migration remain separate roadmap work.

## Completed corpus acceptance

The eight-worker job completed in **15,695.41 seconds (4 h 21 m 35 s)**,
publishing the replacement index at schema 19, generation 29748. All 36,319
parent chunks are covered by 36,328 BGE window memberships. The job processed
31,873 items; its item count is not the parent coverage denominator because
identical embedding inputs can be reused. All 31,864 recorded provider runs
succeeded, with zero failed attempts, dead letters, unsettled outcomes or
remaining active workers. One worker was automatically replaced successfully.
All calls were local and network-denied; recorded cost is zero.

The public report verifies an up-to-date 384-dimensional BGE index, complete
parent coverage, and zero storage/repository issues. Corpus, catalogue, graph,
relationship-length and top-concept rows match the original report. All eleven
source identities/revisions and metadata are unchanged, as are all twenty
sampled original citation records. The retained original Gemini sidecar has
the same SHA-256. Replanning selects no eligible embedding work; the completed
maintenance census independently reports zero missing parents.

| Frozen full-corpus question set | Lexical baseline | Native BGE hybrid |
| --- | ---: | ---: |
| Expected reference span at rank 1 | 3/20 | 5/20 |
| Within first 3 results | 4/20 | 5/20 |
| Within first 12 results | 4/20 | 12/20 |

All 24 queries (20 supported references and four unsupported controls) passed
their route checks: one local embedding call, active hybrid index and no
generated answer. Cold command median was **10.312 seconds**, maximum
**15.653 seconds**. The citation/search harness took **244.91 seconds**.
The predeclared minimum of four top-twelve reference hits passes. This measures
containment of one frozen reference span per question, not exhaustive relevance,
answerability or historical accuracy. Neighbours returned for unsupported
questions are not answers. No hosted Gemini comparison was run. Full-corpus
search speed remains an open performance finding despite the improved recall.

The first source comparison mistakenly equated the list's snapshot-generation
field with source identity. `ragresultpages` emits `page.snapshot_generation()`;
the harness now asserts each value against its corresponding report (29385 and
29748) and compares every other field unchanged. The only differences across
all eleven records were those expected generation values. No product change,
provider rerun or relaxed corpus-preservation requirement was needed.

Public backup `library-migrated-clean` was captured before query-history writes
(93.48 seconds) and verified independently (23.09 seconds, zero issues).
The query diagnostics remain on the test copy. All 257 files in the frozen
`tools-qualified/` installation match their retained hashes. The original
master database, manifest and configuration still matched their initial hashes
before staging, with no active registered processes.

Receipts are in the linked run folder: `evidence/acceptance.json`,
`qa-after.log`, `qa-after-timings.json`, `after-report.json`,
`after-maintenance.json`, `after-noop-plan.json`, `completed-backup-verify.json`
and `source-comparison-generation-detail.json`. The full required developer
suite was not repeated for this corpus acceptance.

## Master replacement

The clean pre-query snapshot was restored into a fresh staging directory in
184.00 seconds and verified there in 20.86 seconds, with zero issues. Public
configuration inspection exposed four expected source/profile/glossary path
relocations from the rehearsal folder to the original workspace; the effective
provider, prompt, budget and remaining policy fields were identical. The exact
reviewed public plan was applied to the staged library, with zero provider calls
and no corpus-generation change. A subsequent configuration diff was identical.

The original master database, manifest and policy fingerprints were checked
again and no active processes were registered before the directory switch.
At 2026-09-18T18:24:02Z, the clean corpus, preserved tested installation and
validated BGE policy became the master. The prior matching set is retained at
`/Users/adrian/Documents/ScottishHistory/backups/before-bge-cutover-20260918`.
All 257 installed artifact hashes match. Final installed status is schema 19,
generation 29748, aligned manifest and zero issues; configuration is identical
to its applied snapshot. Offline lexical inspection returns evidence with zero
provider calls and zero gap writes. Diagnostic query history was not promoted.
No processing window, source reingestion, generation call, commit or push was
started. [Operator report](/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/FINAL.md).

## Reporting follow-up

RAG-VEC-01 is reproduced independently on the existing 339-passage small
corpus, using the migration executable. `library report` reports 340 vector
rows/links, state `inconsistent` and coverage 1002949 millionths, while storage
and repository verification both report zero issues. One parent legitimately
has two windows. The shared report owner also counts links across retained
embedding profiles, rather than distinct parents for the published profile.
`ragreportservice` and its operational digest need the same corrected projection;
this is a reporting defect, not evidence that the embedding data is corrupt.
The fail-first `ann_methodology` regression reproduced the retained-profile and
window failures, with passing empty/partial controls. The shared owner now
selects one publication for all settings, counts distinct visible parents for
that profile, and treats an index with a dirty input revision as partial.
Targeted acceptance passed on both VMs in 12.15 seconds. The original small
corpus now reports 339 covered parents, 340 windows, coverage 1000000 and
`ready`, with zero integrity issues. The completed full-corpus acceptance above
also verifies this projection against 36,319 parents and 36,328 windows.
The running migration's private executable remains unchanged; it is not rebuilt
or replaced under its active workers.

The retained reproduction is
[`small-window-report.json`](/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/evidence/small-window-report.json).
Migration completeness must use the embedding-only run's `embedding_missing`
and `embedding_total` census, plus index publication and integrity checks.

## Local qualification

**Latest instruction:** after a global CREXX update changed compiler/VM inputs
during qualification, Adrian directed that nothing needs rerunning now; review
the update separately. The attempted new-package qualification build was stopped.
The migration's private installation is unchanged. Preserve the report-fixed
installed prefix from `qa/runs/installed_product/20260918T142820-e480f4f1` for the
original candidate; do not install the partially rebuilt development output.
All 127 functional cases have passing executions, but a fresh receipt audit
against the replaced global CREXX package reports 114 changed identities and
13 unchanged passes. This is not new-package qualification. No further test
reruns are authorized for that dependency change at this point.

After combining the report's link/parent counts into one membership aggregate,
the final `ann_methodology` check passed on both VMs in 8.66 seconds. Its pass is
reused by the full selection. The first parallel selection stopped after 51
cases when `regression_operator_diagnostics` raised `PermissionError` at
`tests/qa/run_case.py:164` (`os.killpg` during cleanup); no final case receipt or
product assertion failure was emitted. An unchanged isolated retry passed in
33.23 seconds. RAG-QA-05 retains the unresolved cleanup issue rather than treating
that retry as proof of its repair. Remaining qualification resumes with four
test slots while the separate migration retains eight workers; passing exact
inputs are reused. No timeout or assertion is weakened. These timings include
other machine workload and are not performance benchmarks.

Evidence is under `cmake-build-debug/report-vector-*.log` and the private QA
run directories. The failed attempt is
`qa/runs/regression_operator_diagnostics/20260918T142407-6366e435`.

The parallel `native_embedding_windows` case then failed its expected provider
count. Its retained scratch attempts identify `local embedding model load timed
out` under the fixture's 10-second provider limit; receipt recovery succeeded,
but the other worker could not finish startup. An unchanged isolated retry passed
in 14.04 seconds, including the same atomicity/recovery assertions. No provider
timeout, assertion or worker policy was changed. This repeats the earlier loaded
native-startup qualification limit; the corpus run uses 60 seconds and still has
zero failed attempts at the 14,415-parent checkpoint. The failed evidence is
`qa/runs/native_embedding_windows/20260918T142906-e97dfecf`. Concurrent cold-start
capacity is not established by its isolated pass.

## In-progress performance evidence

At 12:45:09 UTC, 6,461 parents were processed with all eight workers live,
zero failed attempts/dead letters and no held outcomes. Throughput declined
from the early rate. Two three-second process samples provide direct evidence
of SQLite transaction contention: worker 65577 had 232/258 main-thread samples
in `btreeBeginTrans -> sqliteDefaultBusyCallback -> unixSleep`, and worker 65580
had 213/260 there. The latter had two main-thread samples in native embedding
execution/Metal synchronization. This establishes waiting at those sampled
points, not a complete attribution of the run's elapsed time.

There are no hosted calls or authentication steps in this run; an expired
hosted session cannot explain this reproduction. It does not prove the cause
of the earlier hosted incidents. Keep the evidence with RAG-PERF-01 and inspect
write-transaction scope and repeated work before changing SQLite infrastructure
or claiming a native inference speed problem. The requested eight-worker setup
is unchanged, and this run does not introduce a performance repair.

Samples and public request timing are retained under `evidence/` in the run
folder. Provider timing is kept separate from end-to-end wall time. Summed worker
RSS rose from about 2,087 MiB to 3,040 MiB across early snapshots; it is not
unique physical memory and these samples alone do not establish a leak.

Three retained response receipts distinguish native latency from the recorded
whole provider step. Inputs of 10, 143 and 11 tokens report native latencies
8.549, 47.618 and 16.417 ms; their corresponding step timings are 824, 837 and
1,569 ms. The raw receipt's `latency_us` is therefore important when comparing
inference speed with job throughput. These three examples support a substantial
bookkeeping/waiting cost; they are not an exhaustive breakdown of every operation.
The public-command evidence and derived table are `timing-sample-*` and
`timing-comparison.json` in the run folder.

At 12:55:30 UTC, 9,671 parents were complete with zero failures/holds. The
initial one-hour deadline was extended to 15:34:07 UTC through `job deadline`
to finish the authorized copy migration; all item/call/token limits and the
eight-worker job remain unchanged. No budget renewal or worker restart occurred.

At 13:51:07 UTC the migration had processed 16,537 parents with zero failures,
dead letters or held outcomes. The deadline alone was extended to 18:34:07 UTC
to allow the authorized migration to finish at the observed rate. Eight workers,
item/call/token ceilings and the running installation remain unchanged.
