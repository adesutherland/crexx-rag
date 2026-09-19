# Scottish-copy maintenance quality run — 19 September 2026

**Bounded operational acceptance passed; semantic quality and repeatability remain
open.** The [published repairs](maintenance-quality-publication-20260919.md) ran
with four workers, local BGE selected for embeddings, routine Luna Low and advanced
Sol Medium. No prompt, model, retry allowance or deadline was changed during the
run. The master corpus/policy remained unchanged; no copy-back occurred.

## Scope and closure

Runtime source: `9bd5963841b4e88b990c6f61823a6686a25f68bb`, published to origin/main
and installed in `~/.local` and ScottishHistory/tools. Native SHA-256:
`91ad7e7a23ef9bc80acba01b429a0d3a22facdea55233279be6f51372d0feddb`.
The required local gate accounts for 132/132 passing cases. Only changed
documentation checks and the complete receipt audit are needed for this closeout.

One public backup/restore made an isolated copy at generation 29748; its ordinary
opening migrated the copy from schema 19 to 20. Configuration activation changed
only operational identity: four workers and zero paid API spend. Its semantic
identity and prompts stayed fixed. All new calls were maintenance resolution;
the already complete BGE embeddings required no generation.

Job `job-maintenance:b6cd6929fdb4c51a0951838120791d54bb116b9c2588cc16779f3cbb9cb91b5c`
had a fixed activated deadline of 2026-09-19T19:56:39Z. The last provider response
was recorded at 19:54:42Z; admitted work drained before the deadline. The controller
exited zero with all four workers completed and no replacements. The window is
`deadline`; the durable job stays paused with unfinished work explicitly retained.
No restart, reset, waiver, renewal or second window occurred.

| Measure | Result |
| --- | --- |
| Provider calls | 1278: 1261 accepted, 17 rejected |
| Luna Low | 805 calls: 788 accepted, 17 rejected |
| Sol Medium | 473 calls, all accepted |
| Advanced outcomes | 451 final no-change, 13 reuse, eight distinct, one search; 472 distinct tasks |
| Corrections | 16 requested; 15 ran and succeeded; one queued at deadline |
| Item states | 1261 processed, seven stale skips, one dead letter, 88 cancelled, one queued |
| Distinct selected tasks | 905: 803 resolved, 88 pending, 11 superseded, one unresolved, one dispatched, one failed |
| Provider uncertainty / incomplete usage / reservations | Zero at closeout |
| Scratch verification | Generation 30097, zero issues |
| Master | Schema 19/generation 29748 and byte-identical policy |

The 3229 attempt records include 1944 call-free admission deferrals and seven
stale skips. They are not repeated model calls. All 1278 actual call attempts
match independently captured request and response events with actual model/effort.
The 21953 event rows were paged without duplicate IDs. Recorded use is 24425561
input tokens, 358024 output tokens and zero monetary cost. Shared account allowance
moved 21%→17%; that also includes other account activity.

There are 454 final no-change and 213 applied-change decisions across the window.
Whole-library pending questions did not decrease (35306→35313). Discovery,
refresh and follow-up work make this a different measure from selected-task closure;
neither number establishes corpus-wide convergence or historical accuracy.

## Contention and operational limits

All 15 measured maintenance checkpoints had zero lock-entry wait. Their bodies
took a median 2736 ms and maximum 5814 ms. Eight of 3229 claim checks had a positive
lock wait, at most 265 ms; claim-body median/p95/maximum was 1/3/32 ms. Commit time
is not measured. Three heartbeat BUSY retries and one claim-entry retry recovered
without worker replacement, held uncertainty or a failed storage/provider attempt.
This supports continuing with four workers; it is not a controlled comparison
against eight workers or evidence requiring database redesign.

The coordinator overlapped write-capable `maintain status` with full verification
after the run. WAL-open retries were refused during that overlap; the refusal is
retained, and status succeeded after verification finished. This was post-run
operator overlap, not a worker-run failure. Serialize those closeout operations.
The verification itself ran only once and required no repair.

## Repair acceptance

- ESC-OPS-03: no lifecycle-recording failure occurred. The original no-op case
  was not forced/reset; the published regression remains the specific proof.
- ESC-OPS-04: four complete ordinary correction pairs retain original input hashes
  and reference maps. Their admitted one-call correction exception shows 1→1.
  No advanced citation correction occurred, so the repaired 2→1 correction branch
  remains locally proved, not naturally re-exercised here.
- ESC-OPS-02: one retained ordinary escalation led to advanced search and final
  no-change. Advanced allowance correctly showed 3→2; both calls were counted.
  Search results were treated as unread leads. No evidence-read action was selected.
- T7-10: this controller survived the ordinary heartbeat observations and drained
  normally. The historical Desktop-resume mechanism and wider endurance remain open.
- RAG-QA-05 remains qualified by the harness regression, not by corpus success.

## Quality review and next step

Thirty selected items were inspected: eighteen routine and twelve advanced,
including four successful corrections, the dead letter and the uncalled correction.
Two advanced applied cases were added because the original advanced sample contained
only no-change. All 32 original request/response sections were fully paged and
hash-checked, with their supplied source passages; four pre-correction pairs were
also retained. This purposive sample is not an estimated corpus accuracy rate.

The sampled advanced no-change decisions generally preserve candidate ambiguity
and terminate. Accepted decisions still include unsupported or insufficiently
explained identity/type choices. A routine correction picks one of two possible
people without distinguishing source evidence. Another confidently retains a bare
adjective as an event. Two specific identity mappings—including one advanced
decision—are plausible using outside history but need candidate-specific corpus
corroboration. These are evidence-reasoning/tuning findings, not new validator defects.

All four sampled corrections shrink quotations to bare names. That can repair
mechanical matching while losing the justification for an identity. The current
matcher still maps permitted case/whitespace variants back to original source
offsets; one inspected accepted newline-to-space quotation uses that existing
behavior, not the separate literal-backslash-n fallback or a new relaxation.

Keep Luna Low/Sol Medium as the comparison baseline. The proposed small refinement
is to distinguish type from specific identity, treat candidate labels as hypotheses,
require affirmative source support for retain, and preserve decision-supporting
context when correcting a quotation. Eight complete cases are frozen for a later
controlled comparison. No second model run or prompt change occurred. Repeatability
and health/social-care readiness remain open; no additional types, schema,
automatic reviewer or database project is implied.

Detailed evidence is retained in
`/Users/adrian/Documents/ScottishHistory/reports/maintenance-quality-20260919/`:
`RUN.md`, `run-state.json`, `FINAL.md`, `TECHNICAL.md`, `REVIEW.md`,
`review-assessments.json`, `observability-audit.json`, `compact-event-summary.json`,
`advanced-sequence/`, and `frozen-repeatability-sample.json`. The proposal is in
`PROMPT-TUNING.md`; it is not executable configuration. The master roadmap owns
current status; these files retain this run's bounded evidence.
