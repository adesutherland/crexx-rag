# Prompt and selected-quotation repair — 17 September 2026

The user approved the four improvements identified from the isolated 267-call
maintenance run, including a rebuild and local QA. The outcome is clearer
resolution instructions and correct grounding at an explicitly selected source
occurrence. This is a bounded repair within the existing owners, with no new
task types, schema, scheduling policy or provider. Current status remains in
[the master register](ROADMAP.md).

## Evidence and acceptance criteria

The saved review is `out/observability-20260916/prompt-model-review-20260917.md`.
It found 44 rejected reuse attempts, 28 invalid no-change control objects and
26 quotation failures. These are attempt counts, not independent task outcomes
or an accuracy comparison. Six quotation failures had a later exact occurrence
overlapping the selected span that the earlier-first matcher missed.

1. Reuse instructions explicitly map the alias issue to `object_id` and a
   supplied candidate concept to `target_concept_id`, with a field example.
   Identity eligibility and evidence validation remain authoritative.
2. Final no-change instructions specify empty unused fields and provide a
   complete JSON example. A reasoned decision may decline a change without
   inventing facts or evidence.
3. Initial and correction prompts share route-specific cognitive outcome instructions:
   ordinary work can escalate; advanced work concludes a supported change or
   final no-change. Existing bounded search/read and exceptional evidence-based
   deferral remain available under their current policy. Legacy task questions
   describing unresolved uncertainty cannot override the current outcome rules.
   Provenance enrichment retains its separate complete-support assessment
   envelope and existing uncertainty behavior, composed from `ragenrich`.
4. Prompts show the selected UTF-8 byte interval and up to 64 characters of
   source context on either side. Grounding selects the first eligible exact,
   casefolded or whitespace-folded match overlapping that interval, in that
   precedence order. Contextual quotes may start before the selected interval;
   quotes found only elsewhere and invented wording remain rejected.
5. Existing extraction matching, correction behavior, external proposal
   validation, publication fencing, receipts and retry/deferral policy retain
   their regressions. Complete the full local gate once the build is stable.

## Ownership and compatibility

`ragresolutioncontract` owns contract version 3, examples, contextual excerpts
and shared route outcomes. `ragquotationcontract` composes citation feedback
with an optional outcome instruction; its default remains extraction-specific.
`ragapplicationprovider` chooses the resolution correction builder for
maintenance-resolution work. `ragbacklog` owns new task-question text and uses
`raggrounding.findoverlap` in its shared provider/external-response validator.
The existing `find` API retains unscoped and contained-scope behavior.

Existing stored questions and operator configuration are not rewritten. The
effective route instructions clarify older unresolved wording. No validator
acceptance rule for identity, OCR spelling, punctuation or unsupported evidence
has been relaxed. The repair changes which valid source occurrence is selected.

## Regression-first record

The unchanged baseline selection reused four exact-input passing receipts:
`quotation_grounding`, `regression_prompt_inspection`, `durable_backlog` and
`durable_backlog_escalation`; the baseline report confirmed all four passes.
New scenario assertions were then compiled against the unchanged product.
`red-built.log` records failures for repeated selected quotation 2, missing
reuse/no-change field guidance and contradictory unresolved fallback. The
first-occurrence, contextual-quote and rejection controls passed.

An initial test invocation used prebuilt scenario executables and therefore
did not exercise the new assertions. It is not regression-first evidence;
the compiled red run above is. Build the scenario targets before relying on
changed test sources.

Additional coverage includes both VMs with and without optimization, expanding
Unicode casefolds, whitespace mapping, out-of-bounds spans, source-relative
offsets, valid no-change JSON, ordinary/advanced correction instructions and
unchanged extraction correction. The first eight affected checks passed in
10.20 seconds. Compiled follow-up checks then failed on legacy task-question
wording (`question-red.log`, 1.94s) and provenance correction incorrectly using
a cognitive final outcome (`provenance-red.log`, 1.92s). The repair composes the
existing provenance instructions from their owner; it does not change that
assessment schema or policy.

## Complete local qualification

All **123** required functional checks pass in the exact-input receipt audit,
with no disabled, missing or failed cases. The first full invocation took
146.85 seconds and stopped scheduling on the intentional resolution prompt
snapshot mismatch. Review confirmed that only its system hash changed: all
four response-schema hashes and the other three system hashes are unchanged.
After updating that reviewed snapshot, its targeted check passed in 26.99
seconds. The resumed full selection took 324.99 seconds, executing 66 checks
and retaining 57 exact-input passes. Total formal qualification wall time was
**498.83 seconds (8m19s)**; unchanged successful product checks were not repeated.
The final documentation closeout is checked separately after this record is
completed. The explicit scale lane and hosted Gemini qualification remain
separate; local Gemini, malformed-output and secret-redaction cases passed.

Final native SHA-256:
`21a6373c1b00640c6c6804a50107ceb82d1f633919a793b44e070268bd31bc18`.
Linked application SHA-256:
`7d24daf8d2ca204d613d8c9d071f4a6e343b1888d54ae5f7b010bc4a3c00cd62`.
Evidence: `full-qa.log`, `prompt-contract-final.log`, `full-qa-resumed.log`,
`qa-report.json` and `qa-audit.txt` under the run directory.

Use a fresh maintenance plan after a future installation. Existing frozen work
keeps the normal prompt-identity check and supported reset/re-plan refusal;
the repair does not silently rewrite historical requests or accepted decisions.

## Model comparison and delivery boundary

Keep the configured Luna Low and Sol Medium defaults. The prior run used
different workloads for each route, so its failure percentages cannot select
the better model. The user explicitly replaced the earlier 10% allowance floor
with 1% and will manage any reset. The bounded follow-up compares four identical
saved ordinary inputs on Luna Low and Medium, plus two saved advanced inputs on
Sol Medium: at most ten first-response calls, one attempt and 180 seconds per
call, without follow-up tools, corrections or library mutation. The scratch
Level-G replay composes the current domain prompt and Codex provider; preserved
type/relationship lists and response schemas come from the original requests.
All cases retain their original evidence and route context. Do not consume a
reset credit automatically. Results and request hashes are retained under
`out/prompt-grounding-20260917/model-comparison/`.

The ten calls completed successfully at the transport/schema level, with no
correction calls or corpus changes. The final two Sol cases were the previously
rejected Kelpies no-change and Highlanders quotation, selected before any Sol
calls. Four Luna input pairs have identical request hashes across efforts.
This is a first-response replay using the current prompt, original evidence,
allowed types and schema; it does not apply decisions, refresh catalogue state,
follow search/read requests or establish whole-task completion.

| Saved case | Luna Low | Luna Medium |
| --- | --- | --- |
| Highlands, two competing place identities | Escalate; grounded | Escalate; grounded |
| Colonel Fraser, competing person identities | Escalate; grounded | Escalate; grounded |
| The king, one supplied person candidate | Reuse; correct identity fields and grounding | Same |
| Dundee, selected later occurrence | Reuse; correct identity fields and grounding | Reuse; wrong-occurrence quotation rejected |

The actual rebuilt `raggrounding` owner checked every returned citation. All
four Low responses passed selected-span and field checks; three of four Medium
responses did. Medium's Dundee quotation covers bytes 0–64 while the selected
occurrence is 899–905. This remains correctly rejected: choosing a different
source quotation is not permission to ignore the selected connection. Low
quoted the selected contextual occurrence. Average provider latency was 11.41s
for Low and 12.31s for Medium; recorded output usage was 1,459 versus 1,715
tokens, with equal recorded input usage (84,188 tokens per effort). This tiny
single-run sample does not establish a general performance or accuracy ranking.

Both Sol Medium responses concluded `no-change` with the required empty fields:
Kelpies has only a bibliographic heading, and the Highlanders passage does not
distinguish the supplied organisation identities. Their reasons preserve
uncertainty without inventing a change. They used no citations, which the
existing no-change contract permits. The sample checks structure, fields,
source grounding and visible reasoning; it is not full transactional acceptance
or an independent historical accuracy benchmark.

**Recommendation: retain Luna Low and Sol Medium.** The replay provides no
evidence that raising Luna's effort improves these tasks. Total recorded usage
for ten calls was 211,417 input and 3,591 output tokens. No reset credit was used.
`model-comparison/audit.json` records per-response facts and native grounding
results; `manifest.json` links each frozen source request.

Local logs and receipt reports are under `out/prompt-grounding-20260917/`.
No commit, publication, master corpus change or installed-package replacement
is part of this delivery. Wider live acceptance, throughput and task convergence
remain to be measured in the next separately bounded maintenance run.

## Subsequent approved installation and soak

Adrian subsequently authorized installation and a one-hour soak on 17 September.
The exact native candidate above is now installed in
`/Users/adrian/Documents/ScottishHistory/tools`. The previous tools and a public
generation-pinned corpus backup were retained. Fresh installed doctor, CLI and
MCP checks passed; installation preserved schema 19/generation 28234. No rebuild,
commit or publication was needed. Source patch and untracked candidate files
are archived beside the installation record.

The active run record is
`/Users/adrian/Documents/ScottishHistory/reports/maintenance-soak-20260917/RUN.md`,
with machine-readable `run-state.json`. One automatic maintenance window uses
eight workers, unchanged Luna Low/Sol Medium, zero paid API spend and the user's
1% allowance floor. Its activated deadline is **11:46:22 BST**. One five-minute
heartbeat performs bounded observation and required closeout/analysis. The
planned preview deadline differs from activation by 34 seconds; both are
retained and no deadline edit was made. Endurance and broader prompt-quality
qualification remain pending until the run's final report. Ordinary failed
responses and active unsettled calls must not be confused with held uncertainty.

## Completed installed soak

The separately authorized one-hour Scottish soak is now stopped and verified.
The [installed soak record](maintenance-soak-20260917.md) supersedes the active-run
status above: 1303 calls, 1164 successful task settlements, 356 applied-change
and 331 final no-change decisions. All original requests/responses are retained;
nine inspected cases support the narrower contract improvements. Remaining
content, contention and observability findings are recorded in the master
roadmap. No code, model or prompt change was made during the soak; no repeated
full product gate is required for this documentation-only closeout.
