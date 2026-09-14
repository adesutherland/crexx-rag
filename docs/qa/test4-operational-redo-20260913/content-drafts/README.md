# Content corrections prepared from retained responses

These four JSON responses are drafts, not accepted provider output or published
claims. `inventory.json` binds each to its original item, chunk and retained
response hash. Original sample material is retained in
`../../test4-extraction-holds-20260913/test4-samples-raw.json`.

- `mackay.json`: retains seven grounded mentions and only the supported Mackay
  pursuit of Dundee relationship. Unsupported links are omitted.
- `drummond.json`: uses the original OCR label `Lord  John  Drum-` followed by
  the original newline and `mond’s new  regiment`; the canonical label remains
  normalized. It preserves the supported Lady Clifford/France relationship and
  the note distinguishing a wished-for appointment from confirmed service.
- `somerled.json`: fixes the added comma, makes the conquest the subject of
  `had-participant` Alexander II, and represents Ranald's stated relationship
  to Somerled without inventing a more specific permitted type.
- `mar.json`: gives the note one continuous quote including the planned Dunblane
  march, instead of stitching separated text and omitting part of its support.

All 45 cases in `grounding-input.json` pass the existing product `raggrounding`
owner, with results in `grounding-output.ndjson`. The diagnostic source is
`../../test4-extraction-holds-20260913/grounding_check.crexx`. Shape/count/label
length and relationship endpoint bounds were checked separately. This does not
replace full provider/catalogue validation or authorize publishing a claim.

`breadalbane-glossary.patch` is a draft removing the ambiguous bare organisation
alias. `glossary-source.sha256` records its source version. The glossary is
unchanged; the draft must go through ordinary glossary/configuration validation
and an occurrence/catalogue review before application.
