# Maintenance escalation delivery — 16 September 2026

Implementation is retained against the [approved scope](maintenance-escalation-plan-20260916.md).
**Replacement local QA: 121 enabled functional passes, plus one scale pass;
approved upstream #701 exclusion retained.**
The [implementation record](test-process-redesign-20260916.md) owns current
coverage and timings. The earlier stopped serial gate below remains historical.
The twelve acceptance criteria in that plan remain the closure checklist.
Baseline is `main` at `5aad6706102c2ee35faf38020f8859cc4ef8afd7`, preserving
the previously staged MCP-stop and documentation changes. No installation,
hosted calls, corpus processing, commits or publication are included.

## Regression-first evidence

- Existing focused baseline: eight checks passed in 76.02 seconds:
  `regression_policy_file`, `regression_prompt_inspection`,
  `regression_prompt_contract`, `regression_command_catalogue`,
  `provider_durability`, `codex_application`, `durable_backlog`, `task_reset`.
- ESC-VAL-01/02 reproduction: `durable_backlog` failed on exactly three new
  assertions: empty distinct label, empty distinct type, and supplied
  migration-parent reuse accepted by the early validator. Active supplied reuse,
  valid distinct and unchanged-publication controls passed. The actual late
  refusal is `ragclaims._activeconcept`, reached by `promotemention`.
- Repair: expose that existing active-concept query as `activeclaimconcept`;
  one `ragbacklog._identityselection` check serves early validation and alias
  publication. Candidate membership is restricted to the particular task.
  The rebuilt scenario passes those assertions and the existing graph controls.
- Next reproduction: the mixed ordinary/advanced fixture fails exactly on
  advanced-first selection and recording its distinct model/prompt. The future
  six-month date and zero-call planning controls pass.

## Historical stopped qualification (superseded below)

Configure/build passed and the combined CTest run started, then was stopped by
the user during test 49 of 81. It reported 45 passes, two fixture-ID failures
and one disabled test; remaining integration entries were not reached. Both
fixture corrections passed direct CMake checks, but were not rerun through CTest.
At that checkpoint the full gate was **incomplete**, not passed.
The existing explicitly approved `worker_unexpected_exit` exclusion remains
tracked against upstream CREXX #701 and must be reported separately from passes.

## Implemented owners and current focused evidence

- `ragbacklog` owns shared eligibility/order, queue projection, dated deferral,
  route selection, evidence read/binding, final outcomes and serial revalidation.
  It composes `ragretrieval`/`ragevidence` for lexical search and canonical corpus
  citations. Test link lists include those existing module dependencies.
- `ragconfig`, `ragconfigfile` and `ragcanonical` own optional ordinary/advanced
  resolver roles and bounded maintenance settings. `ragresolutioncontract` owns
  the prompt/schema; `ragapplicationprovider` consumes frozen role/objective.
- `ragwork` excludes already-decided provider output from recovery reuse. An
  interrupted uncommitted decision retains the existing receipt-recovery path.
- `ragcommandcatalog` and `ragproduct` expose queue/defer through the same
  operation and access vocabulary as CLI/MCP. Prompt inspection reports binding.
- Configuration-contract targeted run passed (40.38 s) after the new optional
  roles/settings. Later default-action changes still require the final rerun.
- The search/handoff fixture passed its individual assertions: lexical search
  finds a source outside the packet; an unbound lead cannot be cited; a precise
  read binds its offsets; dated deferral survives a new maintenance window; due
  advanced no-change settles the task. Exactly four decisions/calls are retained,
  with no graph publication. At that checkpoint the entire backlog suite still
  failed on queue/legacy-preview/old-policy work, so it is not a suite pass.
- Real unrelated forward publication now has an explicit serial-response reuse
  regression, alongside the pre-existing backward-generation and genuinely stale
  evidence controls. Empty historical impact previews remain compatible at the
  original generation; reuse after publication requires matching fresh effects.

Remaining work is tracked by the numbered criteria in the approved plan;
intermediate assertion passes do not establish full qualification.

## Final focused repair cycle

The bounded outcome controls, explicit advanced extraction, CLI/MCP queue/date,
repeat-request refusals, unchanged deferral refusal, final reuse, explicit final
reset and dated evidence-successor tests passed their individual assertions.
A remaining-budget regression reproduced early window closure using the ordinary
input reservation when a smaller advanced route still fitted. Inspection also
found that advanced counting bypassed the existing retry-reset baseline. The
first reset test had an incorrectly scoped fixture variable; after correcting
that fixture, it verifies restored advanced allowance with paid history retained.
The reset defect is therefore inspection-derived, not claimed as a valid
pre-repair executable reproduction.

The repair extends `raglifecycle.taskretrycallcount` with an optional capability
filter and records its advanced baseline through the existing reset event.
`ragbacklog` composes that owner and reports route calls separately from total
history. Early window closure checks whether any configured route still fits;
actual admission remains responsible for hard reservations and shared caps.

The real prompt-contract journey completed its ingestion, query and maintenance
controls. Inspection confirmed exactly one intentionally changed resolution
prompt/schema pair; extraction, answer and report pairs were byte-identical.
The expected resolution pair was updated after that inspection. Command
metadata is separately reviewed for queue/defer/stop, prompt selectors and the
explicit-final-reset description. Full qualification is still pending.

The native `durable_backlog_provider` suite passed in **53.57 seconds**, including
the added advanced-role request through the actual provider adapter and final
no-change without a publication. Existing malformed/rejected output, redaction,
concurrency, continuation, shared-budget and citation-correction cases passed.
The route-reset and affordable-advanced continuation assertions also passed.
A subsequent regression isolated the old no-funded-work closure status; the
small final correction preserves normal completed-scan status while retaining
budget-exhausted status when funded routes exhaust their allowance.

## Acceptance evidence map

| Criteria | Executable evidence |
| --- | --- |
| AC1–AC2 | `durable_backlog`: one mixed-route job, advanced-first priority, stable paged queue, CLI/MCP parity, missing-route zero-call control and existing review/waiver/ownership holds. `regression_source_maintenance` retains source isolation and later unscoped resumption. |
| AC3 | `durable_backlog`: explicit six-month CLI/MCP date, persisted model deferral across windows, no early dispatch, unchanged-date preservation through relevant-evidence successors, due advanced selection. `regression_job_deadline` retains independent deadline behavior. |
| AC4 | `configuration_contract`, `regression_prompt_inspection`, `regression_prompt_contract`, `durable_backlog_provider`: actual configured role/model, frozen objective/schema hashes and appropriate extraction contract. `durable_backlog`: separate advanced/reset allowance, cumulative history and affordable-route continuation under shared budget. |
| AC5–AC6 | `durable_backlog`: ordinary search of an additional source, refusal to cite an unbound lead, exact read/offset binding, retained handoff and advanced conclusion; repeated/reworded read, forged citation, read allowance and final-call controls. Existing support-completeness, packet-limit, refresh and ownership refusals remain. |
| AC7–AC8 | `durable_backlog`: supported mutations and no-change, supervised reviews, forbidden advanced unresolved, no-evidence-expected deferral refusal, justified dated deferral, unchanged-evidence rollover refusal and failure-without-publication controls. |
| AC9 | `durable_backlog`: repeated census/final reuse, routine route edit, explicit named reconsideration, changed-evidence successor and advanced empty extraction. Existing ingestion idempotency and source-maintenance coverage remain. |
| AC10 | `durable_backlog`: distinct multi-step decisions/receipts without replay; existing saved-output and review recovery. `durable_backlog_provider`, `provider_durability`, `worker_recovery`, `native_receipts`, `native_interruption` retain real adapter, receipt and interruption journeys. |
| AC11 | `durable_backlog`: early identity validation reproductions with valid controls; unrelated forward publication reuses the response, while backwards generation and changed evidence still refuse. |
| AC12 | Combined configure/build/CTest, public metadata, documentation contract and whitespace gate; exact final results and exclusions recorded below. |

These are deterministic local fixtures, including loopback provider requests.
They establish the implemented state/validation contracts; they do not measure
hosted-model answer quality or establish long-running/platform reliability.

## Combined-run fixture correction

The full run exposed two assertions in `regression_source_maintenance` and its
`regression_job_deadline` variant that expected the seeded legacy task ID after
pre-dispatch evidence refresh. The selected current task was its linked
successor, with the same subject, kind and priority. The fixture now validates
that lineage and fresh packet, captures the selected task ID, and follows it
through retry isolation, untouched-source and later resumption assertions.
Both direct CMake scenarios pass against the unchanged candidate binary;
normal CTest reruns were not performed before the user stopped the run.

## Historical stopped qualification

The user stopped testing because its cost, ordering and repetition were impeding
development. No new test execution followed until Adrian approved the test-process redesign. Configure/build and completed test
results remain evidence; the interrupted provider test and unrun integration
cases remain unqualified. The native artifact was unchanged during the stopped
full run. Timing inventory, repetition analysis and the proposed tiered process
are retained in [the redesign](test-process-redesign-20260916.md).


## Replacement local qualification complete

The [test-process implementation record](test-process-redesign-20260916.md)
contains the complete enabled local coverage: 121 functional passes with the
approved upstream #701 disabled case explicitly excluded, plus the separate
17,000-request scale boundary pass. Configure/build, public metadata, normal
source-maintenance/deadline CTest cases, scratch-installed product, documentation
and whitespace checks pass. AC1–AC12 are complete for this local scope.

The evidence table above now refers to both `durable_backlog` core and the
separately selectable `durable_backlog_escalation`; provider, worker/controller
recovery and signal matrices use their individually named child cases. The
assertions are retained. Final no-change, evidence search/binding, prompt/model
selection and deferral are local deterministic acceptance, not a guarantee of
hosted model judgment. Installation into the operator prefix, publication,
corpus processing, hosted evaluation and endurance/platform qualification remain
outside this delivery authority.
