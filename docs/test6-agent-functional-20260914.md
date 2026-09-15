# Test 6 — agent workflows and corpus-specific tuning

Requested by Adrian after the Scottish master acceptance and five delegated
review decisions. This extends Tests 1–5 into broader functional coverage before
soak testing. It does not start a soak run.

Baseline: `main` at `dd96144bb3689ad4da4a9a43c8df914555402877` plus the existing
uncommitted acceptance repairs. Tested and staged native SHA-256:
`2828fc4a3a251aab3731afd2c9f378c8f670c7e171aa3a8397fa129de6f8abb6`.
Scottish master starts at schema 19, generation 23213. Prior qualification:
71/71 local regressions; successful eight-chunk ingestion and independent index
activation; four delegated retain decisions accepted and one unsupported
classification proposal rejected. These are retained controls, not new runs.

## Intended behavior

Failed embedding: leave that item pending or failed. Successfully stored
embeddings: include them in search independently. Existing documents: retain
usable search coverage while new work proceeds. Restart/retry: finish
outstanding work and index activation within the configured allowance.

An agent should discover the operation, inspect the relevant evidence, complete
the authorized work and report its actual outcome. Reuse returned IDs and
existing session context. Do not repeatedly enumerate unrelated queues, invent
prechecks, or require another approval for each already delegated decision.
Missing evidence may correctly remain unresolved; queue clearance alone is not
success. CPU, request counts, response bytes and provider usage are measured;
shared-machine stopwatch times are observations, not acceptance thresholds.

Corpus-specific objectives belong in the selected instance configuration.
Shared response schemas, quotation validation, task lifecycle and provider
execution remain product capabilities. The same binary must support both the
Scottish objective and an unrelated generic instance without configuration
leakage or reingestion of unchanged sources.

## Action checklist

- [x] Review current branch, changes, ownership, capability catalogue and prior
  acceptance evidence. Preserve the existing uncommitted repairs.
- [x] Assign the corpus-facing investigation and candidate prompt to the
  existing **Plan Scottish History acceptance run** task.
- [x] Define capability families and meaningful journeys below; distinguish
  existing coverage from new execution and from deliberate exclusions.
- [x] Verify the installed/public tool inventory against its authoritative
  catalogue and retain the complete operation-to-coverage mapping.
- [x] Run the focused, offline functional controls needed for this wider scope:
  16/16 in the main panel, plus `native_publication` 1/1.
- [x] Execute agent discovery, retrieval, evidence, failure diagnosis and
  resolution/configuration preview journeys on the master without provider
  jobs or corpus changes.
- [x] Author and freeze a Scottish objective derived from recorded failures.
- [x] Exercise additional held-out evidence without retuning the candidate;
  distinguish previously inspected but unprocessed controls from unseen cases.
- [x] Exercise instance-local prompt editing and inspection on disposable
  instances; prove schema/core and unrelated-instance preservation.
- [x] Establish the simplest supported configured-model test route. A ranked
  pilot uses existing maintenance; exact paired task selection is unavailable
  and is not a reason to introduce a new workflow or block this test.
- [x] Prepare the concrete pilot configuration, frozen rubric and execution
  bounds before fresh model calls.
- [x] Prepare a disposable master backup/restore with local source/profile
  copies and register the pilot configuration; verify before handing it over
  for the new bounded inference approval. No maintenance window is activated.
- [x] Obtain the fresh Luna pilot approval and dispatch it to the existing
  corpus task. Correct the prepared general call ceiling to eight; the zero
  monetary ceiling excludes paid API work. Preserve the rejected zero-call
  plan as setup evidence.
- [x] Execute the approved configured-Luna pilot: eight successful first-attempt
  calls, no corrections or failures; verify stored grounding and original-text
  citation resolution for all 23 response quotations.
- [x] Complete the semantic assessment and retain the five raw-quote fidelity
  deviations separately from successful canonical grounding.
- [x] Return findings to engineering. No new core defect was demonstrated;
  no implementation fix or additional regression run is needed for this pilot.
- [x] Close the exercised functional workflows with evidence and report the
  remaining quality and scope limits. The functional result permits soak
  planning; it does not authorize or establish a successful soak run.

### Retained follow-up

- [ ] **FT6-Q01 — raw quotation fidelity:** five of 23 provider quotes changed
  whitespace/case despite the frozen prompt. Preserve these cases for a future
  corpus-prompt evaluation; do not claim this quality target passed or silently
  retune the frozen sample. Original-source grounding and citations passed, so
  this is not a new runtime blocker or reason to add validation rules.

## Capability review and functional journeys

The shipping catalogue currently declares 88 interface entries: 71 named MCP
tools and 84 unique operations. Multiple entries may share an operation.
Capability flags describe access; they are not separate product algorithms.
The machine inventory will retain every entry, including CLI/ADDRESS-only
operations. Exercise workflows rather than calling every alias redundantly.

| ID | Capability family and expected journey | Evidence route |
| --- | --- | --- |
| F6-01 | Discover CLI/MCP commands, access, profile vocabulary, source inventory, schedules, effective configuration and diagnostics. Known object IDs should be directly usable. | Public inventory; agent run; `native_surfaces`, command catalogue/argument and documentation controls. |
| F6-02 | Ask corpus questions, vary breadth/direction/time filters, follow relevant relationships and resolve complete citations. Empty or ambiguous retrieval remains explicit. Ordinary Q&A uses no RAG answerer/provider call. | Agent MCP journey; prior Test 5 controls; retrieval/evidence/temporal fixtures. |
| F6-03 | Diagnose failures through jobs, attempts/events, task history and paged evidence; distinguish content, policy and transport outcomes. Refresh/escalation previews identify their actual effects. | Agent selected-task inspection/previews; `durable_backlog`, `worker_recovery`. |
| F6-04 | Prepare a grounded resolution or external claim, inspect effects, accept a supported proposal or reject an unsupported one, and confirm resulting task/review state. | Five completed master reviews as retained control; new agent previews; `durable_backlog`, `gemini_maintenance`. |
| F6-05 | Synonym, split, merge, type correction, connection migration, reconciliation, retirement and restoration preserve source supports and history. | `native_lifecycle`, `lifecycle_methodology`, `durable_backlog` on synthetic disposable libraries. Do not manufacture graph changes on the master. |
| F6-06 | Ingest/change a source, preserve metadata and citations, store successful embeddings independently, activate the index and treat unchanged ingestion as no-op. | Completed master ingestion as retained control; existing ingestion/publication/temporal fixtures. |
| F6-07 | Inspect progress; pause, continue, cancel or retry the selected work; replay retained failures and reconcile a known provider outcome without duplicate generation. | Existing restart/recovery/continuation fixtures; no deliberate interruption of master work. |
| F6-08 | Verify, back up, restore to a fresh destination, migrate an old schema, rebuild derived vectors, and inspect snapshot/trend history. | `native_publication` backup/restore and public-surface/configuration fixtures; prior master migration and vector-rebuild evidence. |
| F6-09 | Provider routes, privacy/charging bases, limits, optional generated answers and advisory reports behave as documented. | Deterministic Gemini/Codex/local protocol and query-policy fixtures; recent bounded live provider evidence. No login or quota-consuming probe merely for discovery. |
| F6-10 | Change only the Scottish resolution objective through instance configuration. Effective prompt changes, shared response schema does not; another instance and original policy stay unchanged. Existing data is not reingested. | New disposable-instance comparison plus `regression_policy_file`, `regression_prompt_inspection`, `configuration_contract`. |
| F6-11 | Failure-derived prompt tuning preserves grounded decisions and uncertainty. Test known failures and independent controls, then run the candidate through the configured model on a disposable corpus. | Frozen objectives, exact task preview controls and independent rubric; bounded configured-Luna pilot. A ranked sample is not a paired causal improvement claim. |
| F6-12 | Operator handoff is concise and actionable: actual decisions, remaining work, usage and product issues. A failure in one item does not block independent successful work. | Agent report/checklist and final functional synthesis. |

ADDRESS transport, experimental provenance enrichment, optional answerer/advisory,
provider negative cases and destructive lifecycle/recovery operations retain
their deterministic fixture coverage. They are not all repeated against the
master. Hosted/Linux/Windows and unattended-duration qualification remain
separate from this local functional run.

## Scottish prompt experiment

The corpus task owns its candidate, cases and evidence in
`/Users/adrian/Documents/ScottishHistory/reports/functional-test6-20260914/`.
Core QA evidence belongs in `docs/qa/test6-functional-20260914/`.

Use `maintenance.resolution_prompt`, the existing inline instance setting.
It currently has no `_file` companion; `system_prompt_file` belongs to role
objectives. A text file may hold the authored resolution candidate for review,
with its exact single-line contents passed to `config set`. No new setting or
alternate prompt engine is needed for this experiment.

The known failures justify investigating: quotations bound to the selected
occurrence rather than a repeated label elsewhere; OCR/newline preservation;
distinguishing a person's designation from a nested place/family name; mixed
meanings across occurrences; and modest conclusions from index or bibliographic
references. The candidate must generalize these lessons without naming expected
test answers or weakening the shared source validator.

Freeze the candidate before opening untouched holdout evidence. Test the exact
bad responses and supported agent corrections through public resolution
previews. For the configured-model pilot, retain the same model and reasoning
level, use normal ranked selection, and judge every actual selected packet
against the frozen rubric. Count first-pass valid outputs, valid corrections,
supported decisions, harmful changes, preserved uncertainty, calls and tokens.
Valid JSON or an accepted quotation alone does not establish semantic quality.
Separate agent-generated demonstrations from configured-Luna results.

An exact old/new prompt A/B comparison would require the same packets, model,
reasoning and output limits. Current `maintain plan` selects a ranked backlog;
its `input` option is only for provenance enrichment. `job replay` delegates
maintenance items to their task retry owner, and retry does not isolate a
selected task or bypass advanced-reasoning flags. Consequently two independent
ranked samples are not automatically matched A/B arms. Exact paired quality
measurement is optional follow-up, not an added functional prerequisite.

The first phase uses no new RAG provider calls. Fresh hosted inference, if
needed for a matched comparison, gets a concrete bounded execution proposal;
expired acceptance allowances are not reused. No soak run, publication or
master-wide prompt rollout is implied by this experiment.

## Completion criterion

Functional green means the required journeys above have passed with their
stated evidence routes, demonstrated core defects are fixed and retested, and
the prompt controls and configured-model pilot have no unsupported structural changes or control
regressions. A case whose evidence is insufficient may pass by correctly
remaining unresolved. A missing operation, failed validation or unevaluated
model pilot remains explicitly incomplete. Preparing a prompt is not
evidence that the configured model performs better with it.

Once green, prepare a separate soak plan covering sustained ingestion,
maintenance, queries during work, normal restart, retained usage and memory/CPU
behavior. Soak duration and budgets will be chosen then, not silently started.

## Results

- Public MCP initialization and `tools/list` match all 71 named catalogue tools,
  with no duplicate tool names or library creation. Every one of the 88 entries
  and 84 operations is retained in `qa/test6-functional-20260914/capability-inventory.json`.
- The frozen Scottish candidate contains 3,796 characters and uses the existing
  inline resolution setting. Its initial three controls are unprocessed tasks,
  but were inspected in the earlier acceptance preflight; they must not be
  described as unseen holdouts. Engineering verified their exact IDs against
  the earlier retained packets and requested separate unseen evidence controls
  under the already frozen candidate.
- Instance isolation passes on two disposable generic-profile libraries using
  the actual Scottish candidate. Thirteen public CLI calls cover initialization,
  prompt edit/inspection, configuration check/plan/apply and generation status.
  Only the selected objective/effective prompt changed. The response schema,
  mandatory appended contract, other instance's prompt, original config, shared
  contracts/skills and native executable remain unchanged; applying the prompt
  transition publishes no corpus generation. The transition is classified as
  operational under the existing resolution-policy owner. Evidence:
  `qa/test6-functional-20260914/instance-isolation.json` and the retained scratch
  command results it identifies.
- The offline functional panel passed **17/17**: sixteen selected tests in
  335.67 seconds observed, plus the populated backup/restore and publication
  concurrency/failure control in 8.89 seconds. These use local deterministic
  provider fixtures and scratch libraries, with no hosted RAG calls. Logs are
  `qa/test6-functional-20260914/focused-ctest.log` and `publication-ctest.log`.
  No product implementation change was needed for these results.
- The corpus agent completed six successful resolution previews: a corrected
  known failure, three previously inspected/unprocessed controls, and two
  additional cases whose evidence was held out of prompt drafting. The exact
  two bad Hamiltons responses still fail grounding, and the inapplicable-action
  control is rejected. Evidence inventory paging and stale-generation refusal
  also passed. These are agent/public-validator results, not Luna A/B results.
- Public backup, restore, configuration check/apply and final verification all
  passed for the prepared `pilot-library` in the corpus report directory. It
  remains schema 19, generation 23213, with zero verification issues. The master
  remains at generation 23213 with its original runtime configuration. This
  preparation activated no provider run or maintenance window.
- The approved execution used one five-minute, two-worker ranked maintenance
  sample on that disposable library using the frozen candidate and configured
  `gpt-5.6-luna` at low reasoning. The configured ceiling is eight items/eight
  managed turns including corrections, 262,144 input/131,072 output tokens,
  with existing per-call caps 32,768/16,384 and provider timeout 120,000 ms.
  The general model-call and Codex-turn ceilings are both eight; the monetary
  budget is zero. Existing retry and
  advanced-reasoning holds stay in effect. The concrete corpus
  `PILOT-PROPOSAL.md` and registered `pilot.conf` contain the ready execution route;
  `pilot-proposed.conf` is the earlier preparation artifact.
  Adrian approved this pilot and it has been dispatched to the existing corpus
  task. Its first plan rejected the prepared `budget.model_calls=0`: this is a
  general call ceiling, not a paid-only ceiling. Correcting it to eight with
  `budget.codex_turns=8` and `budget.cost_microunits=0` expresses the approved
  allowance; it does not fund Gemini. This was a setup interpretation error,
  not a demonstrated planner defect.
- The pilot job
  `job-maintenance:f31e978d312ea333eff599a6d8919546f233503e08f8568819c211efbd6e0f31`
  completed all eight items with eight first-attempt successful Luna calls,
  zero corrections, failed or uncertain runs, and zero paid cost/Gemini calls.
  Recorded usage was 182,843 input and 3,837 output tokens; aggregate provider
  time was 102,182 ms, an observation rather than a performance threshold.
  Both workers stopped. Final verification found zero issues at generation
  23213; the master and its configuration were unchanged. Seven retain and one
  investigate proposals remain in supervised review; none was accepted or
  applied by this pilot.
- All 23 quotation supports map to their required occurrences and resolve to
  the original source text. Eighteen raw response quotes are literal matches;
  five in three outputs change whitespace and/or initial case. These five miss
  the frozen prompt's literal-fidelity request but match the documented
  case/whitespace grounding behavior in `raggrounding`. They are retained
  prompt-quality findings, not evidence of a core validator defect or lost
  source fidelity. Evidence: corpus `luna-quotation-audit.json`,
  `luna-canonical-grounding-check.json`, and the 23 public citation resolutions.
  Soak testing is not started.
- The corpus task's `luna-semantic-review.md` assesses every actual output.
  The seven retain proposals support the broad existing types; they do not
  establish that unnamed chiefs or the two Wood references identify one person,
  nor settle Forfar's town/county extent. The STUART investigation preserves the
  unanswered classification question. No unsupported structural change was
  proposed. `luna-case-results.json`, `luna-findings.json`, `luna-metrics.json`
  and `luna-closeout-proof.json` retain decisions, limits, usage and final state.

## Functional disposition and next step

The exercised **functional workflow scope is green**: the 17 fresh fixture
controls, public agent journeys, instance isolation, bounded configured-Luna
execution, semantic action review, canonical citations and final verification
passed through their declared evidence routes. FT6-Q01 remains an open prompt
quality result; the frozen objective has not achieved perfect literal quoting
and this ranked sample establishes no causal improvement over the old prompt.
Review acceptance was covered by the earlier five-review journey; these eight
pilot proposals intentionally remain pending in the disposable copy. No master
prompt rollout, queue-wide maintenance, commit, publication or soak occurred.

The next useful step is a bounded soak combining normal maintenance, embeddings-
first ingestion of a selected public document, queries and relationship/citation
lookups during work, and one ordinary restart/continue. Use the existing
commands and two configured workers. Specify duration and total provider/item
allowances before launch, retain successful work independently, and assess
progress, usage, CPU/memory growth and final integrity rather than imposing a
shared-machine stopwatch threshold. No extra preflight framework is required.
