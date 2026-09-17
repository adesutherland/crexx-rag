# Maintenance references and quotation handling — approved 17 September 2026

## Outcome and scope

Adrian approved short task-context references, readable quotation presentation,
specific correction feedback and consideration of a newline fallback after the
original search fails. Keep Luna Low / Sol Medium and existing task/budget
limits. Implement in the shared Level-G contract, provider boundary and grounding
owners; no database migration or changes to durable object identities.

The ordinary/full-ID external proposal contract remains available. Automatic
maintenance uses a versioned model-facing projection and expands its references
before normal validation/application. Retain original provider input/output and
the reference mapping for inspection and replay. The Scottish soak is complete;
this implementation does not restart it, reset its tasks or publish a release.

## Numbered acceptance

1. Supplied subject, concept and evidence references are short and deterministic
   within a frozen input. Corrections and retained-output recovery use that same
   mapping. Original IDs remain authoritative; source text is never rewritten
   while projecting identifiers.
2. Expand only recognized reference fields. Reject unknown/wrong-kind references;
   candidate eligibility, selected evidence and lifecycle checks still reject
   a syntactically valid but inappropriate selection. External full-ID proposals
   and the supported reset/re-plan path for older tasks remain intact.
3. Original model request/response and the mapping remain inspectable, while
   accepted decisions and replay use canonical IDs with unchanged accounting.
4. Selected source excerpts display actual line breaks. Feedback identifies the
   failing field/reference, quotation and selected occurrence; ordinary/advanced
   finality and the existing single correction/budget limits remain unchanged.
5. After normal maintenance overlap matching fails, a single literal `\n` to LF
   interpretation may succeed only on an exact source substring overlapping the
   selected occurrence. Normal matches take precedence. Preserve genuine literal
   backslashes, Unicode byte offsets, OCR and wrong-occurrence rejection; no
   repeated unescaping or general escape/whitespace repair is introduced.
6. Saved failure shapes plus normal/negative controls pass. Worker/provider
   execution, original receipts, correction and external-proposal journeys agree.
   Run focused tests while iterating, then one full local gate with exact-input
   receipt reuse and honest remaining hosted/platform/endurance boundaries.
7. Document the model-facing projection, newline interpretation, ownership and
   remaining release acceptance. Do not claim historical accuracy from successful
   validation or close broader roadmap items by implication.

## Baseline and regression-first evidence

Baseline: `main`, HEAD `6b706308220b43bcf163c79410f879f850169f2e` plus the existing
qualified uncommitted candidate. Preserve that work. Seven affected baseline
cases are retained exact-input **passes**, audited with `tests/qa/report.py
--require-complete`: `quotation_grounding`, `regression_prompt_inspection`,
`durable_backlog`, `durable_backlog_escalation`, and
`durable_backlog_provider_{valid,advanced,correction}`. CTest selection took
0.12 seconds without duplicate executions.

Coverage inspected: normal/Unicode/case/whitespace/selected-occurrence grounding;
current prompt and correction inspection; lifecycle and external full-ID
decisions; advanced finality/search/read; native provider validation/correction
with independent source/vector/usage assertions. Missing acceptance is short
reference projection/expansion/recovery, readable newline presentation and the
new narrow fallback. Add failing observable checks before product edits.

## Reproduced failures and implementation

Before product edits, compiled `quotation_grounding` failed the two new
literal-backslash-plus-n positives (1.06s), with existing controls passing.
`durable_backlog_provider_valid` rejected the fixture's short S1/E1 response
(3.87s). Rebuilt `regression_prompt_inspection` failed its short-reference
projection assertion (1.83s); an earlier stale prebuilt execution is not counted
as regression-first evidence. Logs are retained under `cmake-build-debug/qa/runs/`
with executions `20260917T163348-0b3e82e2`, `20260917T163348-1b5afeb5` and
`20260917T163457-3bcabc2b` respectively.

`ragresolutionreferences` owns deterministic version-5 projection and response
expansion. `ragresolutioncontract` consumes it for ordinary and advanced
requests and readable source excerpts; public prompt inspection uses the same
version. `ragapplicationprovider` retains the map alongside the original request
and decodes both fresh and recovered raw responses before calling unchanged
backlog validation. Raw receipts remain model text; accepted decisions remain
canonical. Unknown/wrong-kind references use the existing single bounded
correction. Full-ID external proposals, specialized provenance extraction and
version-4 representation remain intact.

`ragquotationcontract` produces field/reference/selected-occurrence feedback,
redacted at the provider boundary. `raggrounding.findoverlap` first runs its
existing exact/casefold/ASCII-whitespace matching. Only on failure does it try
one literal `\n` to LF conversion, with exact bytes and selected overlap;
doubled backslashes disable conversion. General extraction `find` is unchanged.
No schema migration, task type, scheduler, model/effort or budget change.

## Acceptance evidence

| Criterion | Coverage and result |
| --- | --- |
| 1. Frozen references | `regression_prompt_inspection`: deterministic maps, structural-only expansion, unchanged reason text, refresh isolation, empty fields and read-citation exception. `durable_backlog_provider_correction` and `correction-failed`: both requests retain the identical map. |
| 2. Validation boundaries | Prompt inspection rejects unknown/wrong-kind/full-ID model responses; legacy version 4 passes through. `durable_backlog`: a known contextual concept reference cannot bypass identity candidate eligibility; a once-eligible expanded ID fails after retirement. Existing canonical external proposal/application controls pass. |
| 3. Receipts/recovery | `durable_backlog_provider_valid` independently asserts original S1/E1 response, retained map and canonical accepted decision. New `durable_backlog_provider_receipt-recovery` faults settlement after receipt commit; two replacement workers recover the same response with no repeat call, no unfinished work or reservations, and unchanged source/vector state. |
| 4. Presentation/feedback | Prompt inspection checks actual source line breaks, rejected field/reference/quote and selected UTF-8 span. Ordinary/advanced and successful/failed/budget-limited correction controls remain required. |
| 5. Matching | `quotation_grounding`: newline positives including preceding Unicode, literal-backslash precedence, doubled escaping, case change after conversion, wrong occurrence and other escape rejection; both VMs and optimization modes. |
| 6. Combined qualification | Focused native recovery, valid/correction, backlog identity and grounding checks pass. Final local gate: 125/125 exact-input passes audited below. |
| 7. Documentation | Architecture owner table and flow diagram, user prompt/inspection/correction guidance, this numbered acceptance record, master register and coverage matrix. |

First focused run: six of seven passed in 8.24s; the new inspection SQL
incorrectly tried to parse an empty embedding response as JSON. The assertion
now handles empty content explicitly; no product assertion was removed. Native
valid/correction/recovery then passed in 6.04s. Subsequent identity eligibility,
retirement, native recovery and both correction cases passed. Prompt capture
correctly detected the approved resolution system text change; reviewed update
`37350e03…` → `b0314174…` leaves all four schemas and other system hashes unchanged.

## Additional defect found by the combined gate

The first combined selection stopped on failure after 82/125 cases in 122.02s:
81 passed, including three retained passes. `observability_providers` observed
the real Codex runtime wording `stdout failed: byte operation deadline exceeded`;
original error and interruption evidence were retained, but `job items --error
timeout` missed it because the shared message classifier returned `transport`.
This was a deterministic classification omission exposed by a timing variant,
not a new worker recovery failure or evidence of database contention.

Before the one-clause repair, `regression_operator_diagnostics` reproduced it
in 0.68s with a passing closed-stdout transport control and the already supported
response-deadline/timed-out variants. `ragoperationsquery._errorcategory` now
recognizes the precise byte-operation deadline wording as timeout. Existing
filter, detailed inspection and summary consumers share that implementation.
No provider behaviour, retry or recovery change. A changed product binary
requires fresh combined qualification; earlier receipts are not claimed for it.

## Final local qualification

**All 125 required local cases passed**, verified by
`python3 tests/qa/report.py --json cmake-build-debug/qa-report.json --require-complete`
(`{"passed":125}`). No disabled, failed, interrupted or not-run required cases.
The final combined run took **538.17 seconds (8m 58s)**: 123 executions and two
retained exact-input passes (`regression_operator_diagnostics`,
`observability_providers`), whose focused run took 18.35s. The earlier stopped
122.02s run remains recorded above; it was not silently counted for the final
binary. Final documentation edits receive only their affected documentation
check and a fresh read-only receipt audit, not another full product run.

Final native SHA-256:
`1ee55563267ea04b061dd7bee2dda2c24cc586e0903e103c63b32edaa77e1dac`.
Linked application SHA-256:
`750a63af1df2f322c75926020c8632738613356d36b3021b71be97b47c1f831b`.
`git diff --check` passed. The final gate includes installed-product CLI/MCP,
Gemini loopback smoke and malformed/secret-redaction negatives, both ordinary
and advanced resolution, successful/failed/budget-limited correction, concurrent
maintenance, task reset and native receipt recovery. The new resolution receipt
recovery case took 6.22s in the final selection.

For timing review, the longest receipt executions were `embedding_exhaustion`
77.02s, `installed_product` 77.00s, `worker_recovery_preflight-once` 73.14s,
`temporal_provenance` 64.56s, `regression_prompt_contract` 56.68s and
`regression_pages` 55.47s. These remain visible in the QA report; this delivery
does not claim to have improved their performance. The explicit scale lane and
hosted/platform/endurance qualification are separate from this 125-case gate.

The seven local acceptance criteria are complete. No Scottish
library mutation, installation, commit, publication or hosted model call is
included in this delivery. Local loopback acceptance cannot establish a lower
live rejection rate or historical correctness. Next operational acceptance
should compare original normal/advanced outputs and rejection categories on a
bounded Scottish run; broader hosted/platform/outage/endurance gates remain
open in the master register.

## Subsequent authorised installation and live acceptance

The exact qualified candidate was subsequently installed under separate
authority for a 15-minute Scottish soak. The [dated live record](resolution-references-soak-20260917.md)
reports 362/368 accepted calls, all six quotation corrections successful, no
identifier rejections and clean stopped/verified closeout. It also records the
new ESC-OPS-02 advanced-call allowance mismatch. This later run does not alter
the local qualification scope or imply publication.
