# ESC-OPS-03 — lifecycle recording repair

## Outcome and scope

Fix the retained Scottish type-correction failure without changing the corpus,
relaxing evidence checks, replacing historical decisions or widening maintenance
budgets. The user approved this repair and a review of other pre-run issues on
19 September 2026. Work starts from clean RAG `710a1d570bc7`.

The original frozen request already describes the subject as organisation,
version 2, following an earlier correction. The model requests organisation
again. Backlog validation admits it, then inserts a lifecycle item before the
lifecycle owner checks that the new type differs. The table also permits only
one action of each type per concept per run. Reproduce these boundaries before
concluding whether the observed recording error was a uniqueness collision.

## Acceptance criteria

1. **AC-01:** Reproduce the retained repeated-correction pattern on private state,
   with a passing real type-change control and the concrete SQLite diagnostic.
2. **AC-02:** Reject a correction that changes nothing before lifecycle recording;
   share the rule with the lifecycle owner and give the model/operator a supported
   concluding action. Worker and external-review validation must agree.
3. **AC-03:** Preserve the earlier action/version, source evidence, provider
   receipt/usage and generation on rejection; a subsequent supported conclusion
   can settle the task. Keep genuine SQL errors visible and atomic.
4. **AC-04:** Pass affected acceptance and the complete required local suite once
   on stable inputs, reusing unchanged receipts. Review remaining pre-run issues
   in the master roadmap without silently expanding this repair.

## Steps

1. **STEP-01 — complete:** Inspect owner/callers, retained I/O and baseline
   coverage; add failing regression and positive controls (AC-01).
2. **STEP-02 — complete:** Make the smallest owner-level repair and
   retain the underlying SQLite failure detail (AC-02–03).
3. **STEP-03 — complete:** Qualify, update ownership/coverage and
   reconcile the relevant roadmap items (AC-04).

No Scottish maintenance window, hosted provider calls, installation or new
publication is included in this repair. Previous run evidence remains at
`ScottishHistory/reports/maintenance-budget-soak-20260917/`.

## Reproduction and ownership

The new isolated `durable_backlog_recording` case seeds a real concept, version
and literal source span. A real concept → evidence-span correction succeeds.
A fresh question in the same window requesting evidence-span again reproduces
`resolution-rejected cannot record validated lifecycle action`. The independent
constraint probe reports SQLite 19 / extended 2067 on
`maintenance_items.run_id,item_type,subject_type,subject_id`. The original event did not retain its SQLite diagnostic, so the precise original
constraint cannot be established retrospectively; the private reproduction
identifies the failure mechanism for the retained no-op pattern. Before the repair,
both shared response validation and external proposal planning admit the no-op.
Generation, prior lifecycle action/version and paid receipt/usage assertions pass.

Fail-first receipt: `cmake-build-debug/qa/runs/durable_backlog_recording/20260919T171533-ee35d9d8`
(2.43 seconds). The initial placement at the end of the large core scenario was
unsuitable because earlier cases leave conflicting fixture state; the dedicated
case now starts from private clean state and also runs on both VMs. The subsequent
external conclusion explicitly closes the window and reconciles worker completion
before planning. Concept and note-selected positive/negative controls pass,
including the existing note next-action fallback and unrelated-catalogue rejection.

`ragmaintain.validatetypechange` owns the shared nonempty/different-type rule.
The transactional lifecycle boundary retains permitted-profile and lifecycle
checks. `ragbacklog` uses the rule in common response validation, so provider,
worker completion, external proposals and review acceptance agree. Its existing
concept/note subject selection is shared between validation and application.
Actual recording failures capture `ragsqlsupport.sqliteerrordetail` immediately,
before rollback or another statement can overwrite it. No schema or uniqueness
rule changes; this repair does not allow multiple same-kind lifecycle mutations
of one subject in one run.

Existing baseline receipts were audited before implementation: `durable_backlog`
31.34s, `durable_backlog_escalation` 20.24s, provider correction 7.72s, provider
valid 13.85s and `gemini_maintenance` 23.09s all passed. The old coverage did not
exercise a new question repeating an already-applied type correction.

## Other pre-run items

- **ESC-OPS-04 — internal:** `ragapplicationprovider` builds the correction from
  unchanged job input; `ragresolutioncontract` repeats that input's original
  remaining-call count. Actual admission/accounting remains correct. This is a
  bounded follow-up for operational context, not a model-tuning item.
- **RAG-SMK-003 / RAG-PERF-01 — performance/endurance:** residual recovered BUSY
  and migration contention remain unqualified; attribution is not established.
  Preserve transaction timing during the next bounded run.
- **T7-10 — controller/endurance:** the historical host-resumption failure needs
  its small reproducer before a new soak, as the master register already states.
- **RAG-QA-05 — test infrastructure:** the cleanup signalling failure remains
  open; an unchanged successful retry did not qualify the failing path.
- **C1/C2 — ongoing prompt/model tuning:** wrong-occurrence or altered quotations
  rejected correctly by the validator belong here. No prompt/model change is
  part of this repair. **RAG-QA-02 / QE-09** remain quality/repeatability acceptance,
  distinct from application defects and required before the more sensitive corpus.

The next maintenance route remains local BGE embeddings and hosted OpenAI
Luna Low / Sol Medium. This record authorizes no new live calls or corpus run.

## Local qualification

Targeted acceptance passed: `lifecycle_methodology` 7.21s, `durable_backlog`
8.09s and the final isolated `durable_backlog_recording` 3.74s on both VMs.
The complete required local gate passed **131/131 in 676.62 seconds** (11m 17s):
129 fresh executions and two exact-input retained passes (`lifecycle_methodology`
and `durable_backlog_recording`). No failures or disabled cases. The regression
selection was run once after product code stabilized. Final documentation-only
verification and the exact-input receipt audit complete the closeout without
repeating product execution. `git diff --check` is clean.

Native artifact SHA-256:
`f1189fc488efca0fd68ac6b9a24f9db40ef879ba438a4add929adef4c74d8830`.
Current evidence: `cmake-build-debug/qa-report.json`; immutable per-case run
receipts and logs remain under `cmake-build-debug/qa/runs/`.

All four acceptance criteria are locally satisfied for the retained repeated-type
pattern. The original corpus failure remains historical evidence; this does not
claim a new live Scottish pass, cross-platform qualification or closure of the
other registered issues. No hosted call, corpus run, installation, commit or
publication was performed for this repair.
