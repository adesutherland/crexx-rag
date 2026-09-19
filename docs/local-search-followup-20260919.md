# Local search follow-up — approved 19 September 2026

## Vision and boundary

Make optional local assisted search practical with bounded evidence and short
model-facing citation references, while preserving canonical source identity,
graph qualifications and strict product validation. Repair CREXX's rejection of
valid per-layer GGUF geometry in its separately authorized hotfix checkout.
Use the existing `openai-compatible` answer route; ingestion/maintenance models,
the Scottish production corpus/configuration and the native admission budgets
remain outside this change.

Authority: “Agreed plus fix of crexx.” Evidence and retained cases are in
`/Users/adrian/Documents/ScottishHistory/reports/local-generation-20260919/`;
`ENGINEERING-NOTES.md` describes the approved bounded follow-ups.

## Acceptance criteria

1. **AC-01:** Valid scalar and per-layer GGUF geometry is admitted conservatively;
   malformed arrays and out-of-range values fail before allocation. Actual 12B
   native preparation/generation is attempted with recorded resource limits.
2. **AC-02:** Answer requests use short, request-local references. Only references
   actually supplied in the bounded context can be returned; unknown, duplicate
   and missing citations fail. Public answers retain exact canonical source IDs.
3. **AC-03:** The answer context respects the existing answer-role/provider token
   limits through a documented conservative bound. Whole-record omission is
   explicit, mandatory qualifications survive, graph/source evidence is retained
   when it fits, and mandatory-context overflow fails before the answer call.
4. **AC-04:** The three recorded public-query misses and identity/partial-answer
   examples remain inspectable evaluation cases. Test transport/schema compliance
   separately from semantics; do not deploy the failed prompt clarification or
   claim a small-model quality pass merely from well-formed JSON.
5. **AC-05:** Focused baseline/reproduction and positive controls precede product
   edits; targeted acceptance and the complete required local RAG suite are
   accounted for once on the final inputs. Document limitations and exact evidence.

## Implementation steps and status

1. **STEP-01 — complete:** Inspect owners and current tests; establish baseline,
   add decisive failing controls and record gaps (AC-01–03, AC-05).
2. **STEP-02 — complete locally; depends on STEP-01:** Repair and qualify CREXX geometry in
   `CREXX-hotfix`, with its own delivery record (AC-01).
3. **STEP-03 — complete locally; depends on STEP-01:** Implement answer-owned reference
   projection/validation and conservative context budgeting; update callers and
   prompt inspection together (AC-02–03).
4. **STEP-04 — complete, limitations recorded; depends on STEP-02–03:** Run bounded scratch local-model
   acceptance with retained examples and effective-control evidence (AC-04).
5. **STEP-05 — complete locally; depends on STEP-02–04:** Complete required QA and update
   roadmap, coverage and owning documentation (AC-05).

## Baseline and evidence

RAG starts clean at `883b3ccb86c21b259eb5e4853e48c07991c4237e`;
CREXX hotfix starts clean at `bc1ab4f886f55722e4b895b320030742353a3561`.
The previous published vector baseline remains qualified; its unchanged tests
are not a substitute for testing these new provider/retrieval inputs.

Native memory-estimate optimization is investigation only: preserve admission
bounds and distinguish estimates from measured allocations. Broader provider
migration and automatic semantic judging are not part of this delivery.

The five inspected baseline cases had exact-input passing receipts, verified by
the QA report: `regression_prompt_inspection`, `regression_prompt_contract`,
`query_policy`, `gemini_query`, `evidence_methodology`. The new public alias
requirement reproduced the old full-ID request in `gemini_query` (5.61 s).
After implementation, reference/source preservation, budgeting and public query
checks passed. The prompt snapshot correctly detected the deliberate answer-only
system-text change; review confirmed all four schemas and the other three system
prompts unchanged, then updated that one expected hash.

The first scratch run restored normal 12-passage/3-hop/8-claim retrieval. It found
the Cameron source, but the small context dropped it in favour of a related claim
and its metadata. A new `evidence_methodology` case reproduced that loss (4.16 s)
while its roomy-context source-plus-graph control passed. The bounded selector
now retains the best source passage when only it or the last graph claim fits.
No provenance is stripped from retained records; omissions remain explicit.

Current evidence root:
`/Users/adrian/Documents/ScottishHistory/reports/local-generation-followup-20260919/`.
The Scottish production library/configuration and the prior completed experiment
are unchanged; the new `rag-public/library` is an APFS scratch copy.

## Local model results and remaining boundaries

All three formerly unsuccessful public queries now return the requested fact
with a validated canonical citation: France, Carbre Riada and Carryl's bow.
Whole-query times are **34.99 / 47.53 / 42.21 s**; the answer-provider portions
are **31.03 / 45.05 / 36.42 s**. The founder answer additionally misinterprets
Bede's agreement as a contrast, so this is not a three-of-three semantic pass.
The retained identity and true-partial controls remain evaluation inputs, not
an automatic quality gate. No failed experimental prompt clarification ships.

Normal retrieval selects 12 passages and 5/3/1 graph claims. The actual 4K-model
requests retain one answering source passage each, with explicit omissions of
the other passages and graph records. Captured JSON requests show context/3,
E1, temperature zero, schema-constrained output and a 768-token output limit.
Runtime logs confirm 4096 context tokens and no prompt truncation. The byte
estimate is not an exact model tokenizer or proof of every server-internal
resource bound. Scratch SQLite `quick_check` passes and publication generation
remains **29748**.

Ollama 0.30.8 performs an initial thinking pass before constrained JSON generation;
the returned usage describes the final pass rather than all internal generation.
This contributes to observed latency and limits the completeness of reported
token accounting. Its pinned OpenAI adapter supports `reasoning_effort="none"`,
but RAG currently permits that setting only for Codex and does not forward it
through the OpenAI-compatible driver. Qualifying that existing control for local
HTTP generation is a separate bounded follow-up under QE-03/09, not implemented
by this delivery. See the scratch `REPORT.md` and pinned upstream source links
there for the request/runtime evidence.

CREXX's separately qualified metadata repair admits the exact 12B model on
Metal at 512 context tokens: preparation **27.71 s**, three synthetic EOS controls
**1.37 / 1.32 / 1.51 s**. At 4096 tokens the unchanged 20 GiB budget is still
refused by the conservative estimate. These execution controls do not qualify
native Scottish answer quality. Details and malformed/scalar controls are in
CREXX-hotfix `docs/planning/native-inference-layer-geometry-20260919.md`.

## QA closeout

Five focused acceptance cases passed in **162.01 s**. The first full selection
stopped after **182.03 s** on a fixture error: alias-only query requirements were
also applied to the standalone canonical-citation provider smoke command.
The fixture now distinguishes those two contracts, retaining strict checks for
each. `gemini_provider_smoke` and `gemini_query` pass in **13.33 s**. The changed
fixture invalidates its declared consumers; unchanged receipts remain reusable.
The final selection passed in **520.27 s**, with 80 fresh executions and 50
retained passes. The closing documentation-only check and exact-input audit
account for **130/130 required passing cases**, with no disabled or unresolved
cases. Product/artifact inputs remained unchanged after the fixture repair;
there is no second full product execution for the documentation closeout.

Changes are local and uncommitted. No new install, publication, hosted-provider
call, cross-platform qualification or Scottish production migration occurred.
