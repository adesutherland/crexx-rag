# Reference and quotation installed soak — 17 September 2026

Adrian authorised one 15-minute Scottish maintenance window after the
[125-case local qualification](resolution-references-delivery-20260917.md).
The exact native candidate was installed without rebuilding; no commit or
publication occurred. Native SHA-256:
`1ee55563267ea04b061dd7bee2dda2c24cc586e0903e103c63b32edaa77e1dac`.

The fixed window was 17:47:50–18:02:50 BST. Eight workers, Luna Low / Sol Medium,
24 replacements/hour, zero paid API spend and the 1% allowance floor. The
maximum-call-duration admission guard stopped calls before the deadline; last
completion was 18:00:56. No renewal or second window. All workers stopped with
no failures/replacements, reservations, held uncertainty or incomplete usage.

362/368 calls passed validation (98.4%); six quotation failures all succeeded on
their single correction, with no ID rejections or dead letters. Luna: 221/227;
Sol: 141/141, including 130 no-change, nine change and two search/read steps.
Six inspected cases confirm stable S/C/E maps, canonical accepted IDs, useful
selected-span feedback and normal newlines. A raw literal-backslash-n quote
also passed after the narrow conversion and exact selected-source overlap.

246 of 296 selected task IDs were resolved at closeout; 266 selected tasks
received calls. Other states: 18 unresolved, one failed, 29 pending and two
superseded. 392 items comprise 362 processed, one stale-evidence skip and 29
deadline cancellations. Successful steps include escalation and gathering
evidence: they are not all concluding resolutions. The window recorded 86
applied-change and 131 final no-change decisions.

Final integrity passed once at schema 19 / generation 29317 with zero issues.
Original configuration restored byte for byte. Recorded checkpoint maximum
lock wait was 2929ms and body 3170ms, without worker disruption. Residual
contention and wider endurance remain open. The preceding hour's 90.3% call
acceptance is comparison context, not a controlled causal estimate.

## ESC-OPS-02: an advanced task ran out before concluding

The run revealed one bounded finality failure:

- Task `task:ea51a1784f876115fb3b479db5c8f786612fa8937c9203b874dc00ed1b2c484c`
  received one ordinary escalation, then advanced search and read.
- All three calls passed validation; read bound the selected source evidence.
- Its immutable read input and original prompt advertised
  `remaining_calls_including_this:2`, `advanced_attempts:3`.
- After read, public task inspection reported failed, attempts 3 and
  `bounded attempt limit reached`; no final decision call was made.

The advertised allowance and enforced cutoff disagree. This is an observed
failure; the exact shared-policy/scheduler cause and isolated reproduction are
pending. It is not an ID, quotation, authentication or worker failure. Leave the
task and evidence intact. Recommended next bounded repair: add the three-step
reproduction and direct-final-decision control, align remaining-call policy and
admission, and ensure an existing-limit concluding decision is available.
Increasing global budgets or corpus resets is not part of that acceptance.

Full operational evidence is in
[the Scottish assessment](/Users/adrian/Documents/ScottishHistory/reports/maintenance-references-soak-20260917/FINAL.md)
and [technical appendix](/Users/adrian/Documents/ScottishHistory/reports/maintenance-references-soak-20260917/TECHNICAL.md).
The run retains all 10052 public job events and all 368 original responses;
six examples contain eight complete original requests with matching hashes.
No repair was made during this soak. Current disposition belongs in ROADMAP.md.
