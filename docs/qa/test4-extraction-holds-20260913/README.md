# Test 4 extraction-hold evidence — 13 September 2026

See [findings](../../test4-extraction-holds-20260913.md). These diagnostics read
`/private/tmp/crexxrag-test3-repeat-tadMRjFu/library/library.sqlite` with SQLite
`mode=ro`. They make no provider calls or library mutations.

- `test4-inventory.json`: original source-job holds grouped by the latest attempt.
- `test4-reconciliation.json`: all 545 roots from `dead_letter_reconciliation`.
- `test4-samples-raw.json`: one item per last-failure reason, lexical item order;
  frozen input and up to 12 most recent events for representative content inspection.
- `test4-operational.json`: all 24 operational items, latest attempt, every response
  summary and every retained reconciliation, using their complete event histories.
- `test4-grounding-input.json`: every mention, relationship and analysis-note quote
  in the retained nonempty sample responses, with original body and literal labels.
- `grounding_check.crexx`: temporary diagnostic composing the existing product
  `raggrounding` and file reader; no new normalization implementation.
- `test4-grounding-output.ndjson`: 122 case results from the linked product owner.
- `summary.json`: aggregate coverage and findings; counts are not all-response adjudication.

The diagnostic was compiled with installed `rxc`, assembled with `rxas`, linked
with `rxlink` against the qualified `crexxrag-project.rxbin` plus `rxfnsg`, `classlib`
and `library`, and executed with installed `rxvme` and its provider path. Input was
the retained JSON file; output was NDJSON. `grounding-build.log` records compilation.
Structural array, length and endpoint checks were compared with the existing
`ragapplicationprovider.crexx` validator; the quote diagnostic does not validate
relationship semantics or the entire glossary contract.

An operational response from an older failed attempt is retained history, not proof
of completion. Latest empty responses and confirmed interruptions remain explicit.
