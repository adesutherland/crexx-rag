# Installed follow-up soak — 17 September 2026

The separately authorized one-hour Scottish maintenance window is complete.
The checkpoint repair passed this bounded live run: all eight original workers
completed, none failed or required replacement. Residual heartbeat contention,
content quality, multi-hour endurance and live shared-outage recovery remain
separate concerns. This is not a full corpus-accuracy qualification.

## Artifact and fixed scope

Published base `6b706308220b43bcf163c79410f879f850169f2e` plus the qualified,
uncommitted candidate in [follow-up delivery](maintenance-follow-up-delivery-20260917.md).
Native SHA-256 `5da3e47db632771b27be323cdcb52ba9ec85a1f56c24ad09445e37379fe43b84`.
The existing **124/124 local gate** belongs to this installed artifact; it was
not rebuilt or rerun for the soak/reporting.

Applied window: **14:48:21–15:48:21 BST**. Eight workers; explicit 24 replacements
across the job per rolling 3600 seconds; Luna Low ordinary, Sol Medium advanced;
fixed prompts; zero monetary spend; 1% allowance floor. No ingestion, task reset,
waiver or extra window. The final call settled at 15:46:32 within existing
call-admission/cleanup limits.

| Measure | Earlier hour | Follow-up hour |
| --- | ---: | ---: |
| Successful calls / called attempts | 1164 / 1303 | 1314 / 1455 |
| Distinct selected tasks / resolved at closeout | 1061 / 808 | 1078 / 862 |
| Applied-change / final no-change window decisions | 356 / 331 | 327 / 371 |
| Dead-letter items | 66 | 24 |
| Worker failures / replacements | 7 / 2 | 0 / 0 |
| Recorded checkpoint count / maximum successful lock wait | 700 / 4494ms | 16 / 0ms |
| Incomplete usage observations / verification issues | 5 / 0 | 0 / 0 |

The workload and operating conditions differ; these are descriptive comparisons,
not causal model/prompt or throughput measurements. There were 1468 items:
1314 processed, 120 stale-evidence skips, 24 dead-letter and 10 cancelled.
Selected task states at closeout: 862 resolved, 160 superseded, 40 unresolved,
nine pending and seven failed. Accepted escalations are successful steps, not
final task resolutions. Global eligible backlog remains 35461 tasks, including
44 advanced tasks. Attempts without calls include 5072 admission deferrals.

## Findings and qualification boundaries

**RAG-SMK-003 — bounded checkpoint acceptance passed.** All 16 recorded
checkpoints acquired the writer without measured wait; no checkpoint failure
appears in launcher diagnostics and no worker died. Body time still reached
4773ms; avoiding redundant active-batch work does not remove substantive batch
transactions. Claim-context maximum lock wait was 278ms. Four heartbeat writes
encountered BUSY and recovered on retry. These messages lack timestamps and
duration, so they cannot identify the competing writer or a causal incident.
This run does not establish zero contention or broader unattended endurance.

**RAG-OPS-003 — large-event inspection passed live.** All 42625 events paged
without gaps. Every called attempt has a request preview/reference and readable
response; all 1455 response content hashes match. Nine distinct samples cover
13 called attempts, with full original request/response/correction sections
reconstructed and hashed; all 13 requests match their event-preview digests.
Full original request bodies were sampled, not all independently reconstructed.
No call was interrupted, so the repaired elapsed/cause path retains local fixture
qualification without new live fault evidence. A remaining interpretation caveat:
the decision section is item-level eventual state even when inspecting an earlier
failed attempt; use attempt response and validation to determine that outcome.

**RAG-OPS-004 — configured recovery allowance observed, unused.** All eight
workers stayed healthy and all 24 replacements remained available. There was no
observed outage or authentication failure. Adequacy during a new real shared
outage is still unexercised; the existing eight-worker local recovery fixture
remains the evidence for that fault path.

**C1/C2 — targeted repairs encouraging; quotation/ID reliability remains open.**
Inactive-identity failures fell from 25 to zero, parent-duplicate split failures
from 15 to zero and invalid type corrections from two to zero. Five splits were
accepted, including four advanced calls. Remaining rejections: 128 grounding,
nine outside-packet evidence and four unsupplied-candidate IDs. Samples show an
altered evidence hash, a repeated segment in a candidate hash, a literal
backslash-plus-n instead of newline, normalized OCR/spacing and a quote at the
wrong occurrence. A successful Sol correction selected the right occurrence;
the earlier first-occurrence validator defect was not reproduced.

Luna settled 895/1029 calls (87.0%), including 448 escalations; Sol settled
419/426 (98.4%), including 366 no-change responses. Sol returned no escalation,
defer, search or read action. Overall 98 of 119 items requesting correction
subsequently processed. Keep Luna Low/Sol Medium. The next bounded proposal is
specific correction feedback naming the offending field/ID and selected span,
with saved negative/positive controls. More generic quotation prose already
failed to prevent these examples. Do not weaken grounding or silently repair
IDs. Short request-local references would be a separate contract decision.

**Closeout passed.** Job `completed_with_errors`, window `deadline`, controller
stopped successfully; all processes stopped, reservations released, no held or
active uncertain outcomes, no incomplete usage. Original config restored
byte-identically, including the 5000000-microunit monetary ceiling. One final
verification passed at schema 19, generation **29202**, zero issues. Core
allowance was 97% remaining; no reset credit was used. Generation and account-wide
allowance changes are not task-quality or exclusive billing measures.

## Evidence and next work

Scottish workspace:
[assessment](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-followup-20260917/FINAL.md),
[technical appendix](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-followup-20260917/TECHNICAL.md),
[exact analysis](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-followup-20260917/analysis.json),
[sample index](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-followup-20260917/examples/index.json),
[authority and closeout](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-followup-20260917/RUN.md).

Current status belongs in [ROADMAP.md](ROADMAP.md). Preserve the live checkpoint
acceptance separately from remaining content-quality, residual heartbeat and
multi-hour/shared-outage qualification. No product change, rebuild, commit,
push or publication is included in this closeout.
