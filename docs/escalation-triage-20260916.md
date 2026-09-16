# Scottish escalation findings — engineering triage, 16 September 2026

**Status authority:** [the master register](ROADMAP.md) owns current status and
priority. This document retains dated evidence and detailed requirements; its
checkpoint labels and checklists are historical unless linked as current by the master.

**Implementation follow-up:** the approved [delivery record](maintenance-escalation-delivery-20260916.md)
now records regression reproductions and bounded repairs for ESC-VAL-01/02 and
ESC-OPS-01. The observations below retain their original evidence status; final
combined qualification is tracked separately.


## Scope and status

Reporting and read-only triage only, requested through the Scottish coordinator.
The source handoff is
`/Users/adrian/Documents/ScottishHistory/reports/escalation-processing-20260915/ENGINEERING-HANDOFF-20260916.md`.
It retains the full incident identities and proposed resolver requirements.
This record adds the findings to the engineering backlog; it does not authorize
implementation or renew corpus processing. The existing
[deferred-test agreement](batch-changes-20260915.md) remains in force.

- [x] Read the handoff and persistent Irish/generation-conflict receipts.
- [x] Trace the relevant validation, candidate selection and acceptance owners.
- [x] Compare existing defect records and affected regression source.
- [x] Record each finding, its evidence limits and bounded next acceptance.
- [ ] Reproduce and repair the validation findings when implementation is requested.
- [ ] Qualify any eventual repair with the agreed batch; no new tests ran here.

The source checkout is `main` at `5aad6706102c2ee35faf38020f8859cc4ef8afd7`
with the pending MCP-stop source changes preserved. The handoff reports that
same installed baseline, native SHA256
`b3be057eacb467a046995863945c8d6334a17b99e4d0e2d2459c4289b4295950`,
schema 19 and published generation 27957. Those installed facts are supplied
by the coordinator's 16 September checks, not a new live inspection here.

## ESC-VAL-01 — confirmed late validation of distinct identity fields

**Open defect.** The retained Irish receipt shows a planned `distinct` response
with empty `canonical_label` and `concept_type`, followed by acceptance error
`identity decision requires a label and type`. The handoff reports successful
preview too. The corrected receipt supplies `Irish` / `evidence-span`, accepts
successfully and records the task as resolved. This verifies the reported
workaround, not the suitability of that profile type for all language concepts.

Evidence under the handoff's `evidence/` directory:
`astra-irish-validation-failure.json` and `astra-irish-closed.json`.
Task: `task:3adb3a004b77294ff28e786370632b1ad56728019a0e0a5aecaab6227d3cd93f`.
Failed review: `review:agent-action:cacdfcc44f5c26b101191256b342d3e22a94280c979b90be37ec6ddf819bbe26`.

The source trace supports the gap. `ragresolutioncontract` owns the response
schema and prompt. `ragbacklog.validatebacklogresponse` checks string presence,
shape, applicable action and grounding, but not these nonempty fields for
`distinct`. `planagentaction` checks a type only when supplied; queueing repeats
planning. Preview and acceptance share `_checkagentreview`, but `_resolvealias`
enforces the missing fields only during application.

Next bounded acceptance: an isolated alias task must reject an otherwise valid
`distinct` response with either required field empty before queuing a review;
keep a valid distinct control that reaches normal acceptance. Cover existing
queued invalid responses at preview/acceptance, with no semantic changes on
failure. Keep action requirements shared across worker and external paths, with
schema/prompt guidance owned by `ragresolutioncontract`; do not make unused
fields mandatory for unrelated actions. No new control or recovery framework
is indicated.

## ESC-VAL-02 — British supplied-target acceptance failure

**Open investigation; root cause unproven.** Planning, queueing and preview
reportedly succeeded, but acceptance returned `selected catalogue identity
changed`. The error is a transcription in the handoff, not a newly captured
failure here. The coordinator re-read the frozen action and live generation as
27957. A concurrent semantic publication has not been established.

- Original task: `task:f2726b37fe0da48f52108ececced4f5da7426774e5327d47e186f17088ce3b22`.
- Selected target: `concept-sha256:1f1aaf1303fc3f0406bcaff0656c3a5d806822f972e934793f081c6b048e61d9`.
- Frozen action: `agent-action:5087ab6954b88d1a4190667ab3573ead62b3e1b82a6839c3aecedf87f47b8db3`.
- Reset successor: `task:c78b88c3cb82cef9ba789215fcd4045e42e489d8cabb6c8991839df392724911`.

The successor remains pending and supplies the same target in
`subject.candidates`, absent from its 14-entry `evidence.catalogue`. Reset has
not been shown to cure the rejection. These two lists have different query
scopes: alias candidates use matching labels/aliases; the surrounding catalogue
uses mentions in the evidence chunks. Absence from the latter alone does not
prove a defect or an invalid selection.

A concrete code lead exists: the alias-subject query and `_resolvealias` accept
current concepts with `lifecycle_state<>'retired'`; `ragclaims._activeconcept`
requires `lifecycle_state='active'` and generation visibility. The final error
also covers label/type mismatch or lookup failure. The target's actual rejecting
branch is not established by this static trace. Migration parents can legitimately
remain evidence; do not remove them indiscriminately or allow their revival.

Next bounded acceptance: isolate external reuse with an active supplied target
as the positive control, then the corresponding migration-parent/visibility
case at an unchanged published generation. Identify the rejecting branch before
choosing a repair. Align early validation with final application, retain a
specific diagnostic and supported next action, and assert that rejection leaves
the graph and generation unchanged. No forced live acceptance or weakened claim
validation is proposed.

## ESC-OPS-01 — generation binding serialises acceptance

**Open throughput/design constraint, not classified as a correctness defect.**
`batch001-alias-accept.jsonl` contains a successful acceptance followed by
`external resolution generation, profile or configuration changed; reject and re-plan`.
The companion plans/apply receipts bind the sibling work to generation 27797.
`ragbacklog._checkagentreview` compares the global published generation as well
as profile/configuration and task evidence; acceptance publishes a new generation.

The demonstrated workaround is to complete plan/apply/preview/accept for one
task before planning the next. Future throughput work should examine retaining
expensive evidence/model work while validating and committing against current
state serially. Whether an unaffected response can be reused without another
model call needs explicit acceptance. Preserve stale-evidence protection and do
not simply remove the generation check.

## Duplicate check and existing coverage

The repository defect register and relevant delivery records were searched;
this was not a fresh GitHub issue inventory.

| Existing item | Relationship to this report |
| --- | --- |
| REL-013, [recorded repaired](reliability-coverage-review.md) | Closest related issue to ESC-VAL-02: the same error and active-versus-migration-parent distinction, but its repaired path is extraction. `backlog_scenario.crexx` explicitly exercises stale extraction after a merge. External alias review is a different consumer. Link them; do not claim the British cause is proved, reopen the fixed extraction case, or mark this report a confirmed duplicate. |
| C2, [Argyll selection](smoke-tests-1-5-20260914.md#content-follow-ups) | Related candidate/catalogue boundary, but the Argyll response selected outside its supplied identity candidates. British selects a supplied candidate. Separate incidents, no established duplicate. |
| [ESC-001](escalation-closure-review-20260915.md) and [task reset](task-reset-delivery-20260915.md) | Historical missing-context/closure work was superseded by the installed reset. These new reports concern current validation/acceptance and do not justify reopening the retired broad audit. |
| ESC-VAL-01 and ESC-OPS-01 | No matching issue entry found in the searched repository register; recorded here under the supplied IDs. |

Existing `durable_backlog` source has valid worker reuse, supervised distinct,
external split, stale task-plan rejection, grounding and effect-preview cases.
These are useful controls, not proof of the missing invalid-distinct and
external supplied-parent cases. Extend that owning journey when authorized;
no new test framework is needed. Existing test source was inspected, not run.

## Resolver proposal and non-product findings

The proposed product-owned resolver remains design context. Start from existing
durable tasks, provider roles, evidence refresh and review/application owners;
do not assume a second queue or supervisor is necessary. Broader, bounded,
durably cited evidence, a configurable escalation model, resumable work and
clear supported-change/no-change/manual outcomes are the requested direction,
not delivered capabilities. Benchmark representative cases with independent
semantic assessment before treating accepted-task counts as quality evidence.

The handoff separately records weak no-change decisions, whitespace-based
identity reasoning, uninspected effects, byte-offset mistakes, progress-count
errors and premature coordinator stopping. Those are not product defects here.
Its 161 resolved / 392 open figure is a reconciled historical cohort checkpoint,
not a fresh census or a semantic-quality score. Worker replacement/reset gain
no new endurance qualification from this review. No implementation, build,
installation, provider call, corpus mutation or restart was performed.
