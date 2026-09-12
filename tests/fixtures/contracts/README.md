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
