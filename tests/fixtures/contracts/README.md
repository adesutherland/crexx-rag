# Captured provider contracts

`provider-contracts.sha256` was captured from the stage 1 native artifact
`8b7d3d096c62f963c89982ee585c618089feaaf0f674b4f6237dde89a2cba505`
before extracting prompt builders. Each sorted line contains the SHA-256 of
the actual system text, then the SHA-256 of the response schema rendered by
CMake's JSON reader. The four pairs cover extraction, resolution, answer and
report requests under the existing deterministic fixtures.

`regression_prompt_contract` runs the ordinary public ingestion/query/report
and maintenance paths, including a citation correction. Test-only HTTP body
capture excludes credential headers. The test retains request JSON and
`observed-contracts.txt` in its scratch directory for diagnosis. It never
rewrites this expected file. A behavior-preserving extraction must match it;
an intentional prompt/schema change needs its own behavior and identity review,
not automatic acceptance of a new digest. Source context and correction history
are variable request data, and their semantic controls remain in the journey
tests and the direct contract scenario.

On 16 September 2026 the approved maintenance escalation contract intentionally
updated the resolution pair. Captured extraction, answer and report pairs are
unchanged. Resolution now includes final no-change, dated expected-evidence
waits and bounded corpus search/read controls, with explicit remaining calls
and the final-route instructions. `durable_backlog`, prompt inspection and the
native advanced fixture exercise the behavior; this snapshot guards the exact
approved effective text/schema rather than treating a changed hash as proof.

On 17 September the approved prompt repair changed only the resolution system
hash (`1504fdc8…` to `cb36d8a9…`). All four captured schema hashes and the other
three system hashes remain unchanged. Explicit reuse/no-change field examples,
consistent ordinary/advanced outcomes and legacy-question guidance account for
the change. Selected context and route-specific correction history are checked
by the semantic scenarios. See `docs/prompt-grounding-delivery-20260917.md` for
the pre-repair failures and combined qualification.

17 September approved follow-up: command metadata changes only the large-event
inspection description; counts, schemas and access annotations are unchanged.
Provider captures change only extraction and resolution system prompts: shared
literal OCR/escape examples and the resolution split-parent rule. All four
response-schema hashes and answer/report system hashes remain unchanged.
Reviewed fragments are retained in `out/maintenance-follow-up-20260917/prompt-review.json`.

17 September approved reference handling: only the resolution system hash changes
from `37350e03…` to `b0314174…`, adding the frozen S/C/E reference contract,
candidate restrictions, exact read-citation exception and readable-newline
instructions. All four response-schema hashes and the extraction/answer/report
system hashes remain unchanged. Short-reference projection, canonical expansion,
rejection, correction and native receipt recovery have behavioral tests in
`docs/resolution-references-delivery-20260917.md`.
