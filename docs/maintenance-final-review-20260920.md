# Main Scottish maintenance acceptance — 20 September 2026

The explicitly authorized fixed-hour run operated on the **main** Scottish corpus,
using the installed `9bd5963` runtime, revised operator prompts, native local BGE
embeddings and managed Luna Low / Sol Medium. Four workers. No new product build,
prompt change, ingestion, reset, waiver, deadline extension or repeat window.

Closeout is complete with preserved failures: 1,098 provider calls, 1,079 processed
items, six dead letters, ten skips and 51 deadline cancellations. Of 711 selected
task IDs, 638 resolved, 51 remain pending, 11 superseded, six unresolved and five
failed. All 469 advanced calls reached a conclusion: 457 no-change and 12 changes.
One automatically replaced worker had a confirmed-interrupted provider turn and
incomplete usage. No live workers, reservations or held uncertain outcomes remain.

Original policy was restored byte for byte; accepted main-corpus changes remain.
One full verification passed at schema 20/generation 29928, zero issues. The
verified pre-run backup is retained. All 36,319 parent chunks still have embeddings;
the run generated no new embeddings. Existing software QA retains 132 passing
required cases; only the affected documentation check and receipt audit are needed
for this documentation update. No commit or publication is requested here.

A purposive 32-item review covers 31 distinct tasks, six original corrections and
three additional advanced follow-ups: 41 complete original request/receipt pairs
were publicly paged and hash-verified. Four sampled successful corrections retain
substantive context. Remaining tuning concerns include conflicting lifetime
contexts, identity versus type, collective categories and split-successor coverage.
An accepted split is still migrating with 29 follow-up tasks. These are not a
requirement that every decision be perfect. The next acceptance focus is whether
later maintenance revisits affected decisions and connections without repeating
unchanged work: [current behavior and proposed acceptance](maintenance-reconsideration-20260920.md).

Two narrow engineering observations remain separate from semantic tuning:

- The shared action guidance omits the existing retired-state precondition for
  restore and collision precondition for synonym; the validator correctly refused
  those operations. Track guidance alignment as ESC-OPS-05. The separate
  contextual-candidate rejection ignored an already explicit instruction.
- One response-deadline error arrived about 13.47 seconds after its request event,
  despite the 120-second configured timeout. Interruption and replacement were
  confirmed; the precise expired deadline is unestablished. Record and diagnose
  it without assuming authentication or database contention.

All 16,025 events match 1,098 request/response/called-attempt sets. Thirteen
checkpoint entries waited 0 ms for the lock; only three of 2,303 claim checks had
positive wait, maximum 22 ms. No BUSY message was logged. Checkpoint body median
was 3,084 ms, maximum 3,738 ms; commit timings are not measured. No database
redesign is indicated by this bounded evidence.

ESC-OPS-03's exact no-op trigger and ESC-OPS-04's advanced 2→1 correction branch
were not naturally exercised. Six inspected ordinary correction pairs retain
their frozen evidence/references and show 1→1 under the existing exception. No
advanced search/read sequence occurred, so prior targeted coverage is retained
rather than claimed as new live proof. Automatic worker replacement was exercised;
historical host teardown and wider endurance remain open.

Operational evidence is retained locally at
`/Users/adrian/Documents/ScottishHistory/reports/maintenance-final-review-20260920/`:
`FINAL.md`, `TECHNICAL.md`, `REVIEW.md`, `RUN.md`, `run-state.json`, public receipts
and all original packets. The health/social-care corpus is untouched. Keep the
current model pair and four workers for a later authorized bounded run; focus
next on sufficient quality plus dependable reconsideration, not endless tuning.
