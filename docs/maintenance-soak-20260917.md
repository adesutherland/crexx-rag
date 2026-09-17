# Installed maintenance soak — 17 September 2026

The user-authorized one-hour Scottish master window is closed. The installed
candidate produced substantially better task settlement than the earlier short
copy run, but this is **partial operational acceptance**, not unattended-quality
or historical-accuracy closure. No implementation changes, retry resets, waivers,
new windows or model changes were made during the run or its analysis.

## Artifact and outcome

Base `6b706308220b43bcf163c79410f879f850169f2e` plus the uncommitted candidate in
[prompt/grounding delivery](prompt-grounding-delivery-20260917.md). Native SHA-256:
`21a6373c1b00640c6c6804a50107ceb82d1f633919a793b44e070268bd31bc18`.
The already-passed 123-case local gate was reused; no rebuild or duplicate full
suite for installation/reporting. Fresh installed doctor, CLI and MCP checks
passed. Eight workers used Luna Low and Sol Medium under a zero-monetary ceiling.

| Measure | Result |
| --- | --- |
| Fixed window | 10:46:22–11:46:22 BST |
| Called work | 1303 calls; 898 Luna Low, 405 Sol Medium |
| Successful task settlement | 1164/1303 = 89.3%; earlier copy run 162/267 = 60.7% |
| Materialized items | 1387; 1164 processed, 99 skipped, 66 dead-letter, 58 cancelled |
| Selected task IDs / current states | 1061; 808 resolved, 145 superseded, 47 failed, 58 pending, 3 unresolved |
| Durable window decisions | 356 applied-change; 331 final no-change |
| Attempts without calls | 3163 admission deferrals and 99 stale-evidence skips |
| Worker failures | Two checkpoint lock failures replaced; five later transport failures unreplaced |
| Closeout | Zero active/held uncertainty, all reservations released, all processes stopped |
| Integrity | One verification passed, zero issues, generation 28234 → 28711 |

The final call settled at 11:44:31; existing admission policy reserves the
120-second call ceiling and five-second cleanup margin before the fixed deadline.
The job reports `completed_with_errors`, window `deadline`, controller failed
because unreplaced slots failed. No continuation was started. Normal monetary
ceiling 5000000 was restored through public config plan/apply; the user's 1%
allowance floor remains. Five interrupted calls retain incomplete usage.

## Supported findings

- **RAG-SMK-003 remains open.** Failed maintenance checkpoint acquisitions waited
  5172/5190ms around 11:11/11:20 BST. Successful measured checkpoint entry waits
  reached 4494ms and bodies 3535ms; commit timing/lock holder remain unavailable.
  These failures preceded the user-reported 11:32:58–11:33:04 internet outage.
- **RAG-OPS-004: observed recovery limit.** Five calls overlapped that outage and
  were confirmed interrupted after roughly 120 seconds. Timing strongly fits
  the outage but is not a network-level causal proof. The two earlier replacements
  exhausted the existing two/hour allowance; three healthy peers continued and
  throughput dropped from about 22–24 to 8 items/minute. The limit behaved as
  configured; adequacy for shared outages remains a policy/qualification question.
- **C1/C2: improvement with residual contract errors.** Invalid no-change-object
  errors fell from 28 to zero; candidate-selection errors from 44 to five.
  Remaining failures include 82 grounding, 25 inactive identities, 15 invalid
  split successors, five outside-packet citations, two invalid type corrections
  and five confirmed interruptions. No recorded authentication failure.
  Sol settled 395/405 calls, mostly final no-change; it produced no re-escalation,
  defer, search or read actions. Keep Luna Low/Sol Medium. Different task mixes
  and changed conditions prevent a controlled model/prompt comparison.
- **RAG-OPS-003: four bounded diagnostic follow-ups.** Ten oversized raw request
  events cannot render, even singly; paged job inspection recovers all ten with
  digest checks. All 1303 original requests/responses are available. Interrupted
  provider duration omits most of the 120-second elapsed time; interrupted-turn
  reconciliation becomes the `unknown` search category; failed-lock stderr has
  local-looking times labeled offset zero. Repair the existing owners and
  surfaces rather than adding a second logging system.
- **RAG-QA-02 remains partial.** Nine representative in/out/correction cases
  explain outcomes but do not establish historical accuracy. A supplied inactive
  candidate needs freshness/lifecycle investigation. A rejected split repeats
  its parent label/type; clarify permitted alternatives without artificial
  renaming. A failed quotation correction normalized OCR; preserve strict
  validation. Search/read capability was not exercised in this run.

The main report and evidence are retained in the Scottish workspace:
[assessment](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-20260917/FINAL.md),
[technical appendix](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-20260917/TECHNICAL.md),
[exact analysis](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-20260917/analysis.json),
[run authority](/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-20260917/RUN.md).
The archive includes the installed artifact identity, source patch, backup,
public receipts, all readable event pages, explicit oversized gaps and paged
recovery, original example bodies, timestamps and restored-policy diff.

Next work should first diagnose checkpoint transaction duration/lock ownership,
then address recovery policy and the small observability/contract gaps. This
record does not authorize implementation, another soak, commit or publication.
