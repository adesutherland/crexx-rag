# Test 4 — extraction-hold inspection, 13 September 2026

**Inspection complete.** All **545 original extraction holds** remain actionable:
521 content failures and 24 operational failures. No response was resubmitted,
hold cleared, glossary changed or provider called during this inspection.

The inspected source job is
`job-sha256:fe38ada198b6c153eec6133810988200c510f9b37c9665d7d8583bc6a4938622`
in `/private/tmp/crexxrag-test3-repeat-tadMRjFu/library`, schema 18, generation
24,931. These are the original extraction holds; other historical jobs are
outside this count. The reconciliation view reports every one as actionable,
with no successful replay, waiver or active descendant resolving it.

## Content findings

One representative per reason was selected by item ID. Its retained response
was compared with its frozen source input. A temporary cREXX diagnostic composed
the existing `raggrounding` owner to inspect all 122 quotation/label cases in the
retained sample responses. It uses the product's exact UTF-8, Unicode casefold
and ASCII whitespace rules. This is representative inspection, not independent
semantic adjudication of all 521 responses. Counts below classify the last
attempt's first reported failure; one response can contain several defects.

| Last failure | Holds | Confirmed representative defect and required correction |
| --- | ---: | --- |
| Relationship quote lacks both endpoints | 173 | The Tay → Dundee quote contains Dundee but not Tay. Select one continuous source span naming both endpoints and supporting the direction, or omit the relationship. |
| Mention quotation absent from chunk | 139 | Provider changed source `de-` / newline / `parture` into `departure`. Preserve the literal OCR text. |
| Mention label absent from quotation | 112 | Label uses `Drummond’s`; quotation contains `Drum-` / newline / `mond’s`. Keep the literal surface label and use the separate canonical label for normalization. |
| Relationship quotation absent from chunk | 42 | Provider inserted a comma after `Somerled`. Copy the exact span, without punctuation repairs. |
| Invalid relationship endpoints | 20 | Response begins with a 0 → 0 self-link; later links also lack a literal endpoint. Remove unsupported links and renumber indexes after any mention deletion. |
| Analysis-note quotation absent from chunk | 12 | The Mar/Perth note stitches two passages around an omitted sentence. Quote one continuous span or separate the supported notes. |
| Reviewed glossary identity conflict | 11 | Source uses Breadalbane as a district, while the reviewed bare alias maps to organisation `Campbell of Breadalbane`. Review the alias ambiguity before correcting this case. |
| Discovery arrays exceed bounds | 11 | Response has 19 mentions against the reviewed maximum of 16. Retain a bounded supported subset and update dependent indexes. |
| Invalid mention label | 1 | A whole paragraph was used as a 538-character label, exceeding 512. Use a short literal surface label and retain the full passage as evidence. |

The sampled glossary and oversized-array responses contain additional grounding
defects. Resolving their first error alone would leave them invalid. Correction
must check the complete response: mentions, labels, relationship evidence and
direction, notes and dependent indexes. The observed evidence guards are useful;
removing them would admit unsupported claims. Product grounding and provider
validation already own these rules, so this report adds no new approval gate.

## Operational findings

All 24 item histories, including all retained provider-response and reconciliation
events, were inspected. None has a usable final response for its latest attempt.

| Last failure | Holds | Retained evidence and next disposition |
| --- | ---: | --- |
| Lease expired | 8 | Empty latest response; each already has an exact-turn `interrupted` reconciliation. Historical usage remains explicitly incomplete. A new bounded redo is needed to obtain new output. |
| Provider time budget exhausted | 7 | No provider response or run on the latest attempt. Redo under a fresh allowance. |
| Confirmed Codex turn interrupted | 5 | Empty latest response, confirmed interruption. Redo within ordinary attempt/job limits or an explicit compatible replay. |
| Codex allowance preflight timeout | 3 | No provider response or run. Retry after the transport is available. |
| Cannot begin provider reservation | 1 | No provider response or run. Reattempt through the normal admission owner under fresh limits. |

Five of these operational items retain an earlier nonempty response from an
already-rejected attempt. That is not a successful final result to publish.
Reconciliation of the expired leases has already occurred; repeating it will
not manufacture missing output or complete their historical usage.

## Recommended next work

1. Run a small operational redo first, keeping the existing eight-item/four-turn,
   five-minute and $0.005 smoke limits. Select explicit held items through the
   public retry/replay controls; preserve completed work and historical receipts.
   A new run is required because this turn's Test 3 allowance is finished.
2. Correct a small representative content batch through the existing extraction
   review/proposal workflow. Retained responses and source spans provide the
   starting material. Validate the whole corrected response before publishing.
3. Review the bare `Breadalbane` alias as a separate glossary decision: narrow
   the ambiguous organisation alias or resolve the geographical occurrence
   explicitly. Do not force the district passage into an organisation identity.

These are next actions, not claims that the backlog has been repaired. No broad
reimport or global retry is indicated by this inspection. There is no new SQL
performance finding in the sampled extraction failures.

[Evidence](qa/test4-extraction-holds-20260913/README.md) includes all reason counts,
the 14 samples, 24 operational histories, reconciliation state and the cREXX
grounding diagnostic. The database was opened read-only for this inspection.
