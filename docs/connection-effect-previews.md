# UX-03 connection effect previews

This follows the approved 12 September sequence: UX-03, UX-04 with OPS-002,
then the complete public recovery journey. It repairs the empty connection
impact observed in the Turray trial. External resolutions still require exact
plan submission and separate reviewed acceptance.

## Behavior and ownership

Connection plans now enumerate affected claims, selected or dependent supports,
and conflicts with their proposed effects. Removing one of several supports
retains the claim; removing its final support or retracting the claim closes its
remaining support and conflict publication. Migration previews include the
successor and distinguish carried pending conflicts from settled conflicts.
A retained note is shown as resolved, matching the existing settlement rule.

`ragmaintain.connectioneffects` owns that projection. It shares support membership,
successor-span validation and migrated claim identity with publication.
`ragbacklog` supplies the validated response and workflow and uses one validator
for pending-review previews and acceptance. Acceptance repeats validation inside
its write transaction. `ragproduct` owns a consistent read snapshot for the review
preview, releasing it before returning or applying. `ragcommandutil` presents
the effects; it owns no lifecycle decisions.

Both resolution plans and pending external acceptance previews show effect rows
in human output. `impact_count`, `impact_shown` and `impact_truncated` explicitly
bound the human list to 99 rows alongside its summary. `impact_json` retains the
complete bounded array for JSON, NDJSON and MCP, including when it exceeds the
ordinary 65,535-character field limit. The configured impact ceiling still
rejects an oversized plan; no pagination or effect is silently invented.

An older pending review can recompute effects from its retained response and
validated generation even when its saved canonical plan contains `impact: []`.
Its original action bytes and attribution remain immutable. A stale accept
preview fails with a replan instruction; the operator can still reject the
review. Previewing makes no corpus writes or provider calls.

## Regression evidence

Starting product commit: `643bf558cc0b08ee7afe2997df878010ce1f30c4` on
`temp/project-review` in `crexx-rag-review`. The separate agreed process/policy
notes were committed as `52c37b0` during this work.

Before product edits, configuration/build and `lifecycle_methodology` plus
`durable_backlog` passed **2/2 in 15.62 seconds**. Added tests then reproduced
seven connection planning failures in **10.28 seconds**, while grounded proposal,
publication, source, usage and replay controls passed. The first lifecycle repair
passed both tests in **16.57 seconds**. The public review tests next reproduced
four missing-output assertions in **10.49 seconds** before their implementation.

Additional fixture mistakes (a duplicate support identity, SQL quoting, evidence
size/order, a reserved variable name, immutable action updates and nonexistent
generations) were corrected and are not counted as product failures. Corrected
compatibility cases passed; variant tests then reproduced precisely two wrong
effect labels in **10.95 seconds**, with migration publication passing.

`durable_backlog` now covers both VMs and asserts:

- support-level versus claim-level retraction, active supports and conflicts;
- planning rejection of a self relationship and configured impact overflow;
- supported claim migration, carried conflicts and preserved prior rows;
- public human/JSON previews, unchanged pending state and legacy action bytes;
- stale accept rejection with rejection still available;
- a 1,000-effect result retaining its complete JSON and explicit display bound;
- exact proposal replay, one publication per acceptance, unchanged source and
  provider counts, and foreign-key integrity.

Focused final QA passed **3/3 in 23.66 seconds**: `durable_backlog`,
`lifecycle_methodology` and `native_surfaces`. The complete `ctest --preset debug
--output-on-failure` passed **59/59 in 758.92 seconds**, including installed
product, ADDRESS/MCP, receipt failures, worker/controller recovery and the three
original page/large-plan/Unicode defect tests. No tests were disabled or their
assertions weakened. Final whitespace and documentation links pass; production
imports have no cycles.

The final build passed linked/native packaging and its two-worker smoke check.
Linked SHA-256:
`37e1c817222ab70e6d42cbca970f52ae606419e8b8f34300c80ba59e0a9e1140`.
Native SHA-256:
`ff1e671ba32aa541ad3ea0f82fdb677e96e89e8cf224a2c4187ba40a7becfc77`.

Logs are retained under `/private/tmp/crexx-ux03-*`: `baseline.log`, `red.log`,
`focused.log`, `review-red.log`, `variants-red.log`, `final-focused.log` and
`full.log`. Failed fixture runs are retained separately; they are not closure
or red/green evidence for a product defect.

## Qualification boundary

This is local synthetic regression evidence against the installed CREXX package.
No live hosted calls, user-library mutation or global installation is involved.
It does not claim a fresh Turray corpus trial, non-macOS qualification, complete
external retirement (UX-04), or the public recovery journey (OPS-001/003).
Concept-level lifecycle proposals retain their existing impact census; this
change specifically repairs connection effects and their reviewed presentation.
