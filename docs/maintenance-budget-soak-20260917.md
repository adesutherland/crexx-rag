# Published baseline fifteen-minute soak — 17 September 2026

## Authority, identity and closeout

Adrian authorised committing/publishing the baseline, installing it and one fresh
fifteen-minute ScottishHistory soak. Runtime source commit
`4a9a8c318196fc7c8fb4ac597d49f565fc3633bb` is published to origin/main and installed
in both ~/.local and ScottishHistory/tools. Qualified native/linked hashes and
126 passing required local cases are in [publication](baseline-publication-20260917.md).
No rebuild, model/prompt change, reset, waiver or manual repair during the run.

The fixed activated window was 17:47:49–18:02:49 UTC; last call completed
18:00:42.960Z, with ordinary maximum-call reservation closing admission early.
All eight workers completed without failure/replacement; no held/incomplete
outcome, unsettled reservation or monetary cost. Original cost policy restored
byte for byte and registered. One final verification passed at schema 19 /
generation 29385, zero issues. Shared allowance 88%. No further window authorised.

Operational receipts and six complete examples are retained in
`/Users/adrian/Documents/ScottishHistory/reports/maintenance-budget-soak-20260917/`:
RUN.md, FINAL.md, TECHNICAL.md, run-state.json, all public pages, original I/O,
analysis.json and example-verification.json. Export used public CLI only.
The five-minute monitor next woke after cutoff at 18:06:01Z; that delayed closeout,
not the product deadline. Earlier expired runs remained closed.

## Outcomes and model evidence

231 calls: 223 successful item settlements, seven grounding rejections, one
validated provider result that failed at lifecycle-action recording. There are
224 successful provider receipts: receipt success is distinct from publication.
266 items: 223 processed, 2 stale skips, 4 dead letters and 37 deadline cancellations.
Six correction requests; three correction items processed; no identifier errors.
219 selected task IDs: 155 resolved, 37 pending, 22 unresolved, 3 superseded, 2 failed.
204 task IDs received calls. These are not unique-content completion percentages.

| Route | Calls | Settled | Outcomes |
| --- | ---: | ---: | --- |
| Luna Low | 120 | 116 | 68 escalations; three quotation failures and one recording failure |
| Sol Medium | 111 | 107 | 87 final no-change,20 changes; four quotation failures |

All 107 settled advanced calls concluded; 107/108 called advanced task IDs resolved.
Window decisions: 57 applied changes, 87 final no-change, 68 escalations, 11 retains.
231 original request/response pairs are present, all response hashes match.
Eight full original requests across six cases were reconstructed through paged
inspection and checked against retained SHA-256, not inferred from previews.
1,120 uncalled admission deferrals among 1,353 attempts add no provider calls.

## ESC-OPS-02: local repair installed and live acceptance passed

The previous stranded task
`task:ea51a1784f876115fb3b479db5c8f786612fa8937c9203b874dc00ed1b2c484c`
was selected naturally, received an accurate one-call-left instruction and
resolved using its retained search/read evidence. Public final facts: four total
calls, three advanced calls, limit three. No reset, retry command or limit change.
This sequence spans both runs; no new search/read response occurred this window.
A different advanced task exhausted exactly three advanced calls (five total,
including two ordinary), with a rejected quotation on its final call. That is
bounded failure, not early exclusion or uncounted execution. Three/five-call
configurations, corrections and shared budgets also retain local regression
coverage in [the delivery record](advanced-call-budget-delivery-20260917.md).

## ESC-OPS-03: lifecycle action recording — open, bounded diagnosis required

One Luna type-correction passed provider validation but failed with
`cannot record validated lifecycle action`; raw response, usage and failure are
retained, no applied decision. Task
`task:4b385a604c0d3bac02ff7eaa56ba24e2b8187ee76bf32a308f0751d88f151266`,
item `item-maintenance:7adead713a5bcd9074a7308d3e454ed8d293827ebfe87ddfeda50173ae0fe436`.
`ragbacklog` emits this error at the maintenance_items INSERT, before lifecycle
application. It uses a stable maintenance-action/task key; the table has primary
and run/action/subject uniqueness constraints. A collision is a hypothesis only.
The retained error omits underlying SQLite detail. Do not infer database
contention or a specific constraint without reproduction. Claim check wait 0ms /
body 2ms does not measure this later write. Final integrity remained clean.

Next bounded work: reproduce on isolated state with a passing lifecycle control;
retain the actual SQLite diagnostic; repair the owning rule with receipt/usage
and no-partial-publication assertions. No SQL inspection/repair of the master,
replay or product change occurred in this test. This failure remains open and
prevents claiming a wholly clean live application pass.

## Quotation, prompt and operational follow-ups

Two failed samples quote real text at the wrong occurrence. Advanced: quotation
bytes 926:964, selected 965:971. Ordinary: quotation 425:486, selected 500:505; the
correction repeated its rejected quotation despite exact selected-span feedback.
A successful advanced correction switched E5 from 519:624 to 0:108, overlapping
selected 73:78. Preserve strict overlap validation. Consider clearer presentation
of the selected occurrence before broader normalization or a model upgrade.
The correction request also repeats its original frozen three-calls-left text,
although the second actual advanced call is counted. A prompt clarity follow-up
should refresh that instruction without changing admission or evidence identity.

Four recorded checkpoints had zero measured lock-entry wait, maximum body 3403ms.
Claim-context maximum wait 59ms/body 23ms. No worker/authentication/transport
failure; this limited instrumentation does not establish absence of all contention.
No new identifier failure. An accepted two-successor split exercises the pathway,
not historical truth or the fitness of every taxonomy choice.

Keep Luna Low / Sol Medium. The earlier 15-minute run had 368 calls/362 processed
and 246/296 selected tasks resolved; these different cohorts, model mix and
admission behavior do not support causal throughput/quality comparisons. Wider
content/endurance, hosted Gemini, live outage and platform qualification remain
open. This is an operational baseline, not a tagged release or corpus-quality sign-off.
