# Local BGE and atomic embedding windows — delivery

User-approved scope, 18 September 2026: implement the agreed atomic window
design, qualify it on an isolated small Scottish corpus, and establish the
embedding-only replacement workflow. The Scottish master is not a test fixture
and no full-corpus replacement is authorized by this implementation run.

## Acceptance

1. A configured local `llama` route uses the pinned BGE-small artifact, verifies
   it, reuses a worker-owned model/session, and requires no network service.
   Invalid configuration/artifacts fail clearly. Existing hosted routes retain
   their protocol, privacy, receipt and charging behavior.
2. Short text produces one vector. Long text produces overlapping windows that
   pass the model's actual 512-token admission, including special tokens. The
   original source chunk and its graph/citation spans remain unchanged.
3. The complete window list is validated before publication. Any inference
   failure discards the list; a retry processes the whole chunk. A database
   failure rolls back all vectors/links and task completion together. Successful
   receipts remain recoverable without repeating inference.
4. Identity includes the pinned model and windowing version. Coverage and query
   compatibility use that same identity. Original embeddings and index bytes remain stored while a new representation
   is being prepared; selected query configuration may temporarily use lexical
   fallback. Uninterrupted live vector cutover remains QE-08 work.
5. Retrieval scores every admitted window, uses each parent's maximum score,
   and applies its result limit to distinct parents. A later window can win;
   repeated high-scoring windows cannot crowd out another parent.
6. An isolated small corpus demonstrates public ingestion, embedding-only
   replacement, repeat/no-op behavior, local querying and unchanged source,
   graph and citation identities. Record timings and retrieval examples.
7. Targeted acceptance and the complete required local gate pass. Keep model
   inference qualification distinct from deterministic protocol fixtures;
   no hosted calls are authorized here.

## Owners and coverage

The native provider owns CREXX model/session/request lifetime. Embedding input
policy owns window splitting and representation identity. `ragwork` owns atomic
publication; `ragretrieval` owns parent scoring. Existing policy/configuration,
maintenance census, receipts and query owners consume those contracts.
No schema migration, persisted offsets, per-window tasks or new recovery
protocol is required.

Baseline: main `e949884794cce8e3d3b9e46bb9225c214de7eda4`, installed CREXX
`e457f5ec3880`. Existing coverage inspected: `ann_methodology` checks independent
exact ranking, replacement publication, SQLite rebuilding and preserved old
profiles; `embedding_recovery` checks embedding-only maintenance, retry and
parallel workers; `publication` checks transactional fault injection and retained
usage. These did not cover multiple windows per parent.

New regression in `ann_methodology` adds four windows for one parent, a poor
first window, a strongest later window and a two-parent result limit. The
fail-first records and final evidence below cover the native adapter, atomic
publication, recovery, retrieval and public small-corpus acceptance.

**Implemented and locally qualified in the working tree.** No commit, publication,
production installation or Scottish master replacement was performed.

## Additional fail-first verification

The first Scottish product run completed all 339 embedding items, then
`library verify` reported one integrity issue. Its old duplicate check grouped
by parent/profile, so legitimate distinct windows were classified as duplicates.
Extended `ann_methodology` reproduced only `distinct windows are valid memberships`
as a failure in 3.68 seconds, with the single-window positive control and actual
duplicate-link rejection passing. The owning `ragstore` query now groups by
parent/embedding ID, matching existing reconciliation. No schema change is needed.

A fixture preparation attempt with 339 independent source files exceeded the
existing 256-description manifest bound before ingestion. The small corpus test
therefore uses two independent source sets (200 and 139 files). This is not a
model limit and does not affect embedding-only maintenance on existing chunks.

## Small Scottish corpus result

The frozen 17 September export supplied 339 literal passages (133,699 characters),
20 independently selected supported questions and four unsupported controls.
The isolated product library used two workers, native BGE-small, 6000-character
parent chunks, one ANN centroid/probe and ordinary hybrid ranking. This is a
small exploratory sample, not full QE-09 acceptance. All commands were run under
macOS network denial; no hosted call, extraction or answer generation occurred.

| Measure | Observed result |
| --- | --- |
| Parent embedding tasks | 339 processed, no failed or unfinished item |
| Parent/window links | 340; the Gaelic passage automatically needed two windows |
| Unique stored vectors | 338; two identical passages reused existing inputs |
| Native inference operations | 337, 30,367 input tokens |
| Two worker-job command times | 3.566 + 2.942 = **6.508 seconds**, including worker startup and index publication |
| Summed recorded provider time | 4.981 seconds across workers; not elapsed wall time |
| Explicit subsequent index rebuild | 0.282 seconds, identical no-op |
| Hybrid supported target at rank 1 / top 3 / top 12 | **17/20 / 19/20 / 20/20** |
| Vector ranking within returned candidates, rank 1 / top 3 | **17/20 / 20/20** |
| Cold query command median / maximum | **0.526 / 1.065 seconds** |
| Public citations | All 20 target passages resolve to their exact retained text |
| Unchanged embedding-only maintenance | No new items or inference; index identical no-op |

Vector ranking within the returned candidates is not a separately exhaustive
oracle. It agrees with the earlier native trial's top-1/top-3 result, despite
using automated 128-character overlap instead of that trial's manual split.
The final bounded-candidate build repeats all 24 questions with identical target
ranks; question 17 retains its expected evidence with 42 candidates instead of
339. Public citation resolutions are unchanged and remain exact.
Hybrid fusion places question 2 at rank 7 although its vector match is first;
this remains broader ranking evaluation work, not a windowing failure. The four
unsupported questions still return neighbours. No answerability or grounding
claim follows from their similarity scores.

The machine is Apple M5 / 24 GiB; native backend selection was automatic.
These end-to-end times do not isolate model load, inference or database cost,
and do not predict full-corpus performance or qualify all CPU/GPU combinations.
The source and graph chunks retain their original size; scratch library IDs
naturally differ from the original corpus and are mapped to the frozen citations.

Raw commands, inputs, scores, public citation resolutions, timings and the QA
harness are indexed in
[`cmake-build-debug/window-scottish-20260918/README.md`](../cmake-build-debug/window-scottish-20260918/README.md).
That library contains no extracted graph; the separate native replacement
regression seeds and compares nonempty concepts/claim/support rows exactly.

## Scottish corpus replacement decision

**The existing embedding-only maintenance job is sufficient for the work.**
It selects missing coverage for the configured embedding representation, retains
old vectors and resumes through ordinary task/receipt controls. A new migration
framework or source reingestion is unnecessary for this bounded offline use.

Before changing the Scottish master, rehearse against a fresh consistent copy:

1. Preserve its current configuration and published index, install the qualified
   executable/runtime cohort into the rehearsal folder, and provision the pinned
   BGE file separately.
2. Review/apply a prospective configuration selecting the native BGE route and
   384-dimensional embedding role; retain the source and graph configuration.
3. Plan/apply `maintain --embeddings-only` with explicit time/item/token limits
   sized from that copy's coverage. The job window must comfortably exceed the
   per-call timeout (for example, ten minutes with a sixty-second call limit).
   Use the normal `job run` and continuation
   controls if the bounded job ends before coverage completes.
4. Require complete parent coverage, a successful vector rebuild and clean
   library verification. Compare source revisions, chunks, citation spans,
   graph rows and original vectors; repeat the frozen retrieval questions.
5. Review measured time, memory and retrieval quality before authorizing the
   real master replacement. No full-corpus job was run in this session.

There is one operational limitation: selecting the new configuration before its
index is ready can make automatic queries use lexical fallback (explicit hybrid
queries report no compatible index). Old vectors are retained, but seamless
live vector handover remains QE-08 work. A paused/offline migration is therefore
the appropriate first full-corpus rehearsal. Model downloads, wider model
selection, local answer generation and standalone reader packaging remain their
existing roadmap work.

## Final candidate bound and installed check

Review of the initial implementation found that scoring every window had also
expanded the ranking candidate pool to every scanned parent (339 candidates in
the small installed query). `ann_methodology` now asserts two candidates for a
single page with a two-parent limit. That new assertion failed alone in 3.93
seconds before the correction. The scorer still evaluates every window, then
keeps only the best distinct parents per page. A parent below k distinct better
parents within a page cannot be global top-k; the existing bounded cross-page
candidate pool is therefore preserved. Later-window maxima and duplicate-parent
exclusion retain their separate assertions.

The preceding qualification was stopped after 121/127 cases had reported while
`embedding_exhaustion` was running, because that candidate was being superseded.
It is not a completed gate. The final gate must cover the rebuilt candidate.
Its earlier two fixture failures were copying only the executable without the
new native libraries; `GeminiIngestion.cmake` now copies the packager's declared
runtime cohort, and both affected tests subsequently passed.

A scratch-installed native executable, all 15 declared runtime files verified
against their hashes, performs the offline hybrid query using a private copy of
the small corpus. One attempt during the concurrent gate hit its configured
10-second model-load limit; the unchanged command then passed in 0.580 seconds
on a quiet host. Both outcomes are retained in
[`cmake-build-debug/window-installed-acceptance/`](../cmake-build-debug/window-installed-acceptance/).
This does not prove the timeout's cause or qualify worst-case load. Use the
user-guide example's 60-second native timeout for the corpus rehearsal, and keep
worker count and per-owner memory under observation. No product timeout or test
assertion was weakened to turn that failure into a pass.

## Final qualification

All seven bounded acceptance criteria pass, with the explicit lexical-fallback
limitation in criterion 4 and full-corpus decision deferred as described above.

- Native executable SHA-256:
  `fe7478d4348eb89fd5f36ae9badde83289621c6d30b5710194f43f213c84fd6e`.
- Linked application SHA-256:
  `90a496dc6019494f56a04b1dc1b2d88195ee4066be64afce8892f8b9fddd01a3`.
- Installed CREXX `e457f5ec3880`; BGE-small F16 model
  `f0b2fef971e8366438bfd2d9aefea1b0115919389448806d290237f638bae999`;
  native engine `5266f24da75dc449bd56cbed7addb9c8e4a6a73e`.
- Final fast suite: **9/9 in 5.12 seconds**.
- Final targeted selection: ANN methodology **5.21 seconds**, real native
  windows/recovery/replacement **11.48 seconds**, run concurrently. Both pass.
- Final required local gate: **127/127 accounted for in 528.58 seconds**;
  116 cases executed and 11 exact-input passes retained. CTest displays those
  retained passes as skipped; they are neither disabled nor unexecuted coverage.
  This includes Gemini smoke, hosted/local protocol and malformed-output/privacy
  fixtures, Codex, publication, worker recovery, installed-product and native BGE
  checks. No live hosted calls were made. Publication passed in 32.30 seconds.
- The final documentation receipt is refreshed after these result notes; the
  final `window-qa-report.json` audit requires complete current-input coverage.
- Exact final scratch-installed binary/runtime verification and offline hybrid
  query are retained in `cmake-build-debug/window-installed-final/result.json`.
  The 15 runtime files are verified against the CREXX packaging manifest.
- `git diff --check` passes. `window-source-manifest.json` records the dirty
  working-tree source/doc hashes and baseline commit; this is not a published SHA.

Local logs are `cmake-build-debug/window-final-fast.log`,
`window-final-targeted.log`, `window-final-regression.log`,
`window-final-documentation.log` and `window-qa-report.json`.
Earlier failed/stopped runs remain retained and are not reported as final passes.
The explicit scale lane, full Scottish rehearsal, non-macOS qualification and
broader QE-03/04/07/08/09 acceptance remain open in [ROADMAP.md](ROADMAP.md).
