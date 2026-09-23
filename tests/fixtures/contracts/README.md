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

19 September approved local-search follow-up: only the answer system hash changes
from `4103233c…` to `4fc41304…`. The added contract explains request-local citation
references, excludes source footnotes/speaker labels and keeps IDs in the citation
array. All four schemas and the other three system prompts are unchanged.
`regression_prompt_inspection` and the public `gemini_query` cases verify canonical
restoration, literal source preservation and rejection. See
`docs/local-search-followup-20260919.md`; this is not the failed partial-answer
prompt experiment.

19 September ESC-OPS-04: retain all four existing system/schema pairs and add
`828bd9f8… / 75103edd…` for the two-call correction fixture. Captured text differs
from `b0314174…` only in the remaining-call value (2 instead of 1); no template or
schema changed. Ordinary and advanced journeys independently require 2 → 1 in
both sent system/user context with frozen input/reference identity preserved.
The snapshot therefore now contains five pairs. See
`docs/esc-ops-04-qa-cleanup-delivery-20260919.md` for the fail-first evidence.

20 September approved ESC-OPS-05 changes only the two resolution system hashes
(`828bd9f8…`/`b0314174…` become `a09a2b40…`/`d037405b…`; sorted order is not a
route mapping). Shared text adds retired-restore and active-alias collision
preconditions and directs supported alternatives or final no-change. All schema
hashes and extraction/answer/report system hashes remain unchanged. Direct
initial/correction ordinary/advanced inspection and lifecycle positive/refusal
cases provide behavioral evidence; see `docs/beta-delivery-20260920.md`.

23 September combined convergence candidate: only the two resolution captures
change (`a09a2b40…`/`d037405b…` become `6caff9d2…`/`c6155283…`). Their common
schema hash changes from `75103edd…` to `05b3f4a2…` for optional reviewed
impact dispositions and `insufficient-evidence`; the system prompts now require
source-supported equivalence before merge and distinguish final lack of evidence
from an affirmative no-change. Extraction, answer and report pairs remain
byte-identical. The lifecycle, settled-question and public maintenance scenarios
exercise these semantics; the captured requests and observed digest are retained
in the regression prompt-contract QA run.
