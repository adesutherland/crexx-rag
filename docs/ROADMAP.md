# Master roadmap and defect register

Current decision and status authority — updated 24 September 2026.
The [final beta plan](beta-release-plan-20260920.md) is **implemented, locally qualified and installed; beta release held**.
The candidate passes 133 required local cases, two live Gemini smokes and the
bounded Scottish-copy run: 200 successful calls, clean closeout and integrity.
Bounded reconsideration (RAG-MNT-006) and lifecycle guidance (ESC-OPS-05) are
delivered. The historical early deadline (ESC-OPS-06) remains unexplained and
requires the explicitly agreed beta exception before `v0.1.0-beta.1`.
[Delivery and acceptance evidence](beta-delivery-20260920.md). No beta tag/release is claimed.

The [19 September baseline](baseline-publication-20260919.md) builds against
published CREXX `5949ef27efd8` in the normal user prefix, includes local BGE atomic
embedding windows and the CREXX rxvector binary owner, and passes all 130 required
local cases. Source `7bf0c6b` is published to origin/main and its qualified artifact
is installed in `~/.local`. CREXX Build and CodeQL are terminally green; exact
source, artifact and per-job evidence are recorded in that delivery record.
The master Scottish corpus and its configuration are untouched by this phase.

The earlier runtime baseline `4a9a8c3`, its 126-case qualification and its
Scottish installation remain dated evidence in [the previous publication](baseline-publication-20260917.md)
and [fifteen-minute soak](maintenance-budget-soak-20260917.md). The observability,
prompt/quotation, checkpoint/restart and advanced-call repairs remain included.

## Recent defects and delivery status

Advanced resolution strict schema and terminal-error repair (24 September):
**local product candidate; corpus recovery, installation and hosted validation
pending**. The actual `/7` resolution schema omitted `dispositions` from root
`required`; the Codex adapter replaced terminal `invalid_json_schema` detail
with a retryable generic failure. `/8` requires the field, represents unused
impact as `[]`, preserves lifecycle checks, and retains exact `/7` frozen
bindings for queued work. Terminal error classification now reaches durable
receipts. Synthetic old-to-new queued and explicit-retry journeys, including
an unrelated pending review, passed. The local gate accounts for 138/138
required passing cases after an unchanged local-model timeout case passed in
isolation; the QA ledger has no failed, disabled, interrupted or unrun entry.
[Ownership and evidence](maintenance-refactoring-delivery.md#advanced-response-schema-and-terminal-error--24-september-2026)
and [coverage](regression-coverage.md#advanced-resolution-schema-and-terminal-error--24-september-2026).

Combined convergence and evidence-bound candidate (23 September): **local
implementation in progress; not installed, published or corpus-qualified**.
The first-pass predicate now requires a validated successful extraction receipt;
phase/cohort selection, relevant-context settlement, scoped invalid-node
retirement, identity candidate passages, coalesced alias follow-up, input-hold
completeness and logical-debt reporting have focused synthetic coverage.
Evaluation evidence queries can suppress gap observations. The whole-record
query-output overflow repair is included and both graph-enabled retrieval
modes pass synthetic tests. The current combined build accounts for **135/135
required local passes** with exact-input receipt reuse. Remaining acceptance
includes full cohort restart/fencing, deterministic canonical survivor
enforcement, complete read-only discovery and the integrated C0–C6 journey. No
private-corpus maintenance or installation has been run for this candidate.
[Ownership and focused evidence](maintenance-refactoring-delivery.md#combined-convergence-candidate--23-september-2026-in-progress),
[coverage matrix](regression-coverage.md#combined-convergence-and-evidence-bound-candidate--23-september-2026),
[overflow delivery](query-evidence-bounding-20260923.md).

Provider selection (22 September): the operator-selected route must not be
overridden by an automatic source-privacy veto. Both shared refusals are removed
locally; fail-first public-maintenance and provider-contract acceptance is
recorded. Full local qualification covers 135/135 required cases. The operator
has authorized commit, publication and local installation after this gate.
[Requirement and evidence](provider-route-selection-20260922.md).

Worker compatibility and source first-pass maintenance (23 September):
**locally qualified; not installed or exercised on the Scottish corpus**. A
resumed worker now compares unfinished
work bindings instead of vetoing every saved-job configuration change except
worker count. The format-1 embedding batch setting is effective and still
subject to provider bounds. The focused recovery case permits batch 100 to
1,000 with four workers, completed-phase model and unrelated operational/source
changes; it rejects a changed pending provider model/source and an over-limit
batch, while preserving attempts, usage and budgets. The new
`--initial-extraction-only` source selector freezes first concept-review
selection in the reviewed plan and excludes alias follow-ups, embedding repair
and already reviewed chunks. Guided CLI and MCP share that option.
`regression_source_maintenance` passes its fail-first extension.
Configuration/build, fast and full local gates pass; the QA report accounts for
135/135 required cases (14 retained exact-input passes in the final CTest
selection), with no disabled or failed case. [Ownership and baseline evidence](maintenance-refactoring-delivery.md#23-september-worker-compatibility-and-first-pass-source-maintenance)
and [coverage](regression-coverage.md#t7-07-source-scoped-maintenance-acceptance).
The broader [veto audit](veto-rule-audit-20260923.md) remains a dated
recommendation inventory, not a claim that its other narrowing proposals are
implemented. Hosted gates and release status are separate from this local QA.

| ID | Status | Scope and evidence |
| --- | --- | --- |
| RAG-REL-001 | Merged and published; real-signing qualification remains separate | Windows x64 and macOS Apple Silicon/Intel build/installers, unsigned macOS fallback when credentials are missing, pinned CREXX dependency, package identity/hash checks and separate Windows post-release signing. [PR #1](https://github.com/adesutherland/crexx-rag/pull/1) merged on 22 September. Its [final hosted gate](https://github.com/adesutherland/crexx-rag/actions/runs/35518552817) passes all three platforms, including native builds, portable ZIPs, actual installer execution and Windows reinstall/PATH/uninstall controls. The initial Windows NSIS wildcard defect is repaired and its early compiler fixture passes. A published upstream SDK archive is the preferred future dependency route; current runtime snapshots lack required SDK files. [Dependency evidence](integration-issues.md#snapshot-sdk-packaging--20-september-2026), [delivery](installer-delivery-20260920.md), [operator setup](build-and-release.md). The held beta tag remains separate. |

“Locally repaired” closes the named reproduction, not the wider umbrella
qualification. Historical corpus outcomes remain dated evidence.

The 19 September operator assessment treats current SQLite contention as
acceptable and monitored, rather than a blocker requiring database redesign.
Eight fast workers may exceed efficient concurrency; compare worker counts only
when a future bounded run calls for it. Historical contention evidence remains.

Prompt and model tuning (C1/C2) is an ongoing quality activity, separate from
internal application defects. Correctly rejecting an unsupported quotation is
not itself a software defect. Incorrect validation, application, task state,
accounting or model-facing operational facts are internal defects. Quality and
repeatability acceptance remains necessary even when the software gate is green.

| ID | Current status | Evidence / remaining acceptance |
| --- | --- | --- |
| RAG-VEC-02 | Closed — published in the 19 September baseline | Changing groups and then returning to the original setting reproduces `immutable sidecar target already exists or aliases the source`. Deterministic old identity is superseded, excluded from replay lookup and incorrectly sent through new publication. Preserve immutable guards; add validated reactivation with A → B → A regression, retained embeddings/provenance, one published selection and failure checks. The isolated experiment is preserved; public backup restoration recovers the original corpus/index. The fail-first A/B/A case passes on both VMs, alongside native/legacy switching, missing superseded-file restoration and generation/revision/identity rejection that preserves the prior publication. The final local gate accounts for 131/131 passing cases. [Integration qualification](native-vector-delivery-20260918.md). [Reproduction, owner and acceptance](vector-group-comparison-20260918.md#rag-vec-02--superseded-index-reactivation-fails). |
| RAG-VEC-01 | Repaired, corpus-verified and published in the 19 September baseline | The shared report/digest projection selects one published profile and distinguishes its window memberships from distinct covered parents. Fail-first retained-profile/multi-window regression and positive controls pass. Scottish acceptance reports 36,319 covered parents, 36,328 windows, 100% coverage, current index and zero integrity issues. Publication and the newer installed CREXX qualification are complete in [the 19 September baseline](baseline-publication-20260919.md). [Migration evidence](scottish-bge-migration-20260918.md#completed-corpus-acceptance). |
| ESC-VAL-01 | Locally repaired | Empty distinct identity fields rejected before review; [delivery](maintenance-escalation-delivery-20260916.md). |
| ESC-VAL-02 | Locally repaired | Inactive migration parents rejected before review through shared validation; [delivery](maintenance-escalation-delivery-20260916.md). |
| ESC-OPS-01 | Locally repaired | Serial revalidation reuses unaffected responses and rejects stale evidence; [delivery](maintenance-escalation-delivery-20260916.md). |
| ESC-OPS-02 | Repaired, published and installed; bounded live acceptance passed | The shared route-counter SQL alias repair aligns selection/exhaustion with inspection and fresh task prompts. Three/five-call regressions and all 126 local cases pass. In the [published baseline soak](maintenance-budget-soak-20260917.md), the previously failed escalation/search/read task naturally used its third advanced call and resolved, with four total calls retained. A separate task exhausted exactly three advanced calls/five total calls on invalid quotations. No limit increase or reset. [Repair and local evidence](advanced-call-budget-delivery-20260917.md). |
| ESC-OPS-03 | Published and installed; local qualification passed | The retained request already had the proposed type. A private positive-control/repeated-correction test reproduces the generic recording failure and identifies the run/action/subject UNIQUE constraint. Shared lifecycle validation now rejects unchanged types before recording, names a supported concluding action and retains SQL diagnostics for real recording failures. No schema/history rewrite. New isolated regression passes on both VMs; full local gate 131/131 in 676.62s, with retained source/history/usage and reviewed no-change recovery. [Repair and acceptance](esc-ops-03-delivery-20260919.md).  [Published baseline and bounded quality run](maintenance-quality-publication-20260919.md). |
| ESC-OPS-04 | Published and installed; local qualification passed | Ordinary and advanced corrections now refresh their displayed remaining-call allowance from the existing ledger and frozen ceiling. Private public-provider regressions reproduce 2,2 before the repair and require 2,1 in both sent system/user context, with frozen task/evidence/reference identity, receipt replay and accounting preserved. The final gate accounts for 132/132 passing cases. This is application-supplied operational context, separate from prompt tuning. [Repair and qualification](esc-ops-04-qa-cleanup-delivery-20260919.md).  [Published baseline and bounded quality run](maintenance-quality-publication-20260919.md). |
| ESC-OPS-05 | Delivered and locally qualified — shared lifecycle action guidance | The main-corpus review found an active-concept restore and two colliding synonym proposals. Runtime validation correctly refused them; retained action instructions omit the retired-state/collision preconditions. Shared initial/correction guidance now states both rules, with fail-first and positive graph controls. The Scottish operator summary is aligned through public configuration publication; other policy is preserved. Full local gate and bounded copy acceptance passed. This is separate from semantic prompt tuning. [Run evidence](maintenance-final-review-20260920.md), [bounded plan and AC-7](beta-release-plan-20260920.md#3-align-the-operational-action-guidance). |
| ESC-OPS-06 | Open historical cause; diagnostics and short-lease repair qualified and installed | One Codex response deadline occurred about 13.47 seconds after its request despite a 120-second configured timeout. Exact-turn interruption and worker replacement succeeded; usage remains incomplete. The code also caps the operation by remaining claim lease, which is a lead rather than a diagnosed cause. Current-input local QA passes 133/133. Configured/effective allowance, limiter and phase are retained; a separately reproduced double-subtracted cleanup reserve is repaired. Bounded live acceptance adds 200 successful calls and clean closeout. The historical 13.47-second cause is still unproved and requires diagnosis or an explicit beta exception. [Delivery evidence](beta-delivery-20260920.md). No timeout increase or attribution to SQLite/authentication is justified. [Run evidence](maintenance-final-review-20260920.md), [diagnosis and AC-1/2](beta-release-plan-20260920.md#1-diagnose-the-early-deadline-before-changing-policy). |
| ESC-OPS-07 | Local product gate 138/138; publication, corpus recovery and hosted qualification pending | Resolution `/7` omitted a required strict-schema field; terminal Codex errors were lost. Offline schema, protocol, receipt, four-worker first-pass and synthetic upgrade evidence is in [the delivery record](maintenance-refactoring-delivery.md#advanced-response-schema-and-terminal-error--24-september-2026). |
| ISSUE-01 | Locally repaired | Unexpected-worker replacement and exit-write error handling; #701 downstream exclusion removed. [Worker evidence](worker-pool-repair-20260915.md), [runtime retest](crexx-701-retest-20260916.md). |
| PC-01 | Closed locally and installed | Expired admitted-work continuation, deadline preservation and reset controls; [delivery](job-controls-delivery-20260915.md). |
| T7-01 | Repaired; caller check passed | Source include filtering; [Test 7](test7-overnight-soak-20260914.md#t7-01--source-include-ignored). |
| T7-02 | Locally repaired; natural caller acceptance pending | Returned proposal/review IDs; [Test 7](test7-overnight-soak-20260914.md#t7-02--external-proposal-apply-omits-review-ids). |
| T7-03 | Repaired; caller check passed | Original validator diagnostics; [Test 7](test7-overnight-soak-20260914.md). |
| T7-04 | Repaired; caller check passed | Exact indexed source/review lookup beyond first page; [Test 7](test7-overnight-soak-20260914.md). |
| T7-05 | Repaired; caller check passed | Per-source backlog and progress inspection; [Test 7](test7-overnight-soak-20260914.md). |
| T7-06 | Repaired locally and installed | Select held provider outcomes; [Test 7](test7-overnight-soak-20260914.md). |
| T7-07 | Repaired locally and installed | Source-scoped maintenance discovery/dispatch; [Test 7](test7-overnight-soak-20260914.md). |
| T7-08 | Repaired; retained-outcome caller check passed | Inspect/reconcile original provider outcomes after later config changes, with no repeated call; [Test 7](test7-overnight-soak-20260914.md). |
| T7-09 | Configured; one bounded live replacement observed | Temporary 24/hour ceiling and original policy restoration retained. In the [20 September main run](maintenance-final-review-20260920.md), one confirmed-interrupted provider timeout caused automatic replacement; the replacement completed 38 items and stopped cleanly. Historical [Test 7](test7-overnight-soak-20260914.md) remains dated evidence. |
| T7-10 | Open investigation / endurance qualification | Broken-output and catchable-signal repairs pass locally. Historical host-resumption mechanism remains unproved; run a small host reproducer before a new soak. [Diagnosis](t7-10-controller-diagnosis-20260915.md). |
| Scottish AC-04 | Selected embedding holds subsequently resolved | Original one-attempt policy block was not a new defect. The master's five gaps were later repaired under bounded authority in [Test 7](test7-overnight-soak-20260914.md). Other retry-policy changes remain separate. |
| Scottish AC-05–AC-08 | Repaired and bounded installed acceptance passed | Incomplete embeddings, maintenance run lookup, removal of the preview-count prerequisite and independent zero-monetary routes; [acceptance evidence](acceptance-repairs-20260914.md). |
| C1 / C2 | Improved live evidence; quotation/ID reliability and content quality remain open | The [follow-up one-hour soak](maintenance-follow-up-soak-20260917.md) settled 1314/1455 calls (90.3%), with 862/1078 selected tasks resolved at closeout. Inactive-identity rejections fell from 25 to zero and parent-duplicate split rejections from 15 to zero; five splits succeeded. Remaining failures: 128 grounding, nine outside-packet evidence, four candidate IDs. Nine original examples show miscopied hashes, literal backslash-plus-n, normalized OCR and wrong selected occurrences; 98/119 correction items processed. Sol Medium settled 419/426 calls with concluding actions; keep Luna Low/Sol Medium. Approved short references, readable excerpts, specific correction feedback and exact-only newline fallback are locally qualified (125/125); [local qualification record](resolution-references-delivery-20260917.md). The subsequent [15-minute installed soak](resolution-references-soak-20260917.md) accepted 362/368 calls (98.4%), corrected all six quotation failures and had no ID rejections; 246/296 selected tasks were resolved. Short references and the narrow newline fallback were exercised live. One advanced search/read sequence exposed the separate ESC-OPS-02 allowance mismatch. Different workloads and nine samples do not establish causal improvement, historical accuracy or corpus convergence. [Installed repair](maintenance-follow-up-delivery-20260917.md), [earlier soak](maintenance-soak-20260917.md). The [published baseline soak](maintenance-budget-soak-20260917.md) adds 231 calls, seven grounding failures, no ID errors and six original cases. Wrong-occurrence quotation persists on both models; one correction repeats the rejected quote. Actual budgets remain bounded; stale correction allowance wording is tracked separately as internal defect ESC-OPS-04. Keep current models; selected-occurrence presentation and model behaviour remain ongoing tuning.  The [19 September copy run](maintenance-quality-soak-20260919.md) adds 1278 calls, 803/905 selected tasks resolved and 32 reviewed items. Unsupported identity choices, confident retention of weak classifications and bare-name corrections remain tuning concerns, including one advanced identity requiring corpus corroboration. The [approved prompt/model comparison](maintenance-prompt-comparison-20260919.md) now corrects the five problem decisions while preserving three positive controls, with 24 successful calls and 33 grounded quotations. The original-pair repeat agrees on all eight actions/identities. Revised Scottish prompts are installed; Luna Low/Sol Medium stay selected because Sol Medium/Sol High showed no decision-quality gain on these tuning cases. Unseen-case and full lifecycle acceptance remain open.  The [20 September main-corpus review](maintenance-final-review-20260920.md) adds 1098 calls, 638/711 selected tasks resolved and 32 reviewed items/41 original pairs. Sampled corrections retain context; conflicting identities, collective typing and successor coverage remain tuning concerns. Keep Luna Low/Sol Medium. The acceptance emphasis is sufficient quality with dependable reconsideration (RAG-MNT-006), not perfection on every pass. |
| RAG-VAL-012 | Repaired, locally qualified and installed; bounded soak complete | Shared grounding finds the eligible occurrence overlapping the selected span, retaining exact-source and negative controls. Full local gate: 123 passes. The installed one-hour soak retained strict validation; inspected residual failures altered literal quotations/OCR rather than reproducing the first-occurrence defect. This closes the named repair, not all quotation failures. [Repair](prompt-grounding-delivery-20260917.md), [soak](maintenance-soak-20260917.md). |
| RAG-SMK-001 | Repaired and installed | Active calls versus reconciliation holds; [recovery evidence](recovery-defects.md#rag-smk-001--p2-active-calls-displayed-as-reconciliation-holds). |
| RAG-SMK-002 | Repaired and installed | Codex byte-stream UTF-8 decoding; [recovery evidence](recovery-defects.md). |
| RAG-SMK-003 | Repaired; bounded live checkpoint acceptance passed | The [installed follow-up](maintenance-follow-up-soak-20260917.md) completed with all eight workers, no failures/replacements and 16 recorded checkpoints with zero measured lock-entry wait, versus 700 records, 4494ms successful maximum wait and two failed acquisitions in the earlier hour. Checkpoint bodies still reached 4773ms. Four heartbeat-write BUSY retries recovered; residual contention, competing-writer attribution and wider endurance remain open. The repair avoids redundant active-batch writers and reschedules safe pre-claim BUSY; the identical eight-connection local fixture fell from 160 failed acquisitions to zero. Full local gate 124/124. [Repair](maintenance-follow-up-delivery-20260917.md), [earlier live evidence](maintenance-soak-20260917.md), [measured diagnosis](observability-delivery-20260916.md).  The [four-worker copy run](maintenance-quality-soak-20260919.md) completed without replacement: 15 checkpoints with zero lock-entry wait, eight positive claim waits up to 265ms and four recovered BUSY messages. No database redesign is indicated by this bounded evidence.  The [20 September four-worker main run](maintenance-final-review-20260920.md) records 13 checkpoint lock waits of zero, three positive claim waits up to 22 ms, and no logged BUSY error; its provider timeout is not evidence of contention. |
| RAG-SMK-004 | Repaired and locally/installed qualified | Stale-worker reporting; [four repairs](four-smoke-fixes-20260913.md). |
| RAG-SMK-005 | Repaired and locally/installed qualified | Consistent terminal states and activity; [four repairs](four-smoke-fixes-20260913.md). |
| RAG-SMK-006 | Repaired and locally/installed qualified | Automatic vector publication; [repair](smk006-publication-repair-20260913.md). |
| RAG-SMK-007 | Repaired | Historical jobs no longer veto future config; [simplification](rule-simplification-repair-20260913.md). |
| RAG-SMK-008 | Repaired | Repeated cancel remains stable; [simplification](rule-simplification-repair-20260913.md). |
| RAG-SMK-009 | Repaired | Gemini holds receive supported recovery guidance; [simplification](rule-simplification-repair-20260913.md). |
| RAG-SMK-010 | Repaired; selected live replay passed | Selected-work compatibility; [repair](test4-repair-delivery-20260914.md). |
| RAG-SMK-011 | Repaired; live repeat passed | Independent indexing and ordinary retry; [repair](test2-recovery-delivery-20260914.md). |

## Essential observability — locally qualified, bounded acceptance complete

[Essential requirements and six acceptance criteria](observability-plan-20260916.md)
cover RAG-OPS-003: find examples, inspect original inputs/outputs and provide a
small diagnostic run summary. Reuse existing commands and receipts, adding only
missing facts and targeted timings. All 123 local checks passed; the isolated
copy run completed in 10m54s with 267 provider calls and clean stopped/verified
closeout. All called attempts retain original input/output. The
[delivery record](observability-delivery-20260916.md) records limits, timings and
examples. That copy run left prompts and policy unchanged. The later installed
[one-hour soak](maintenance-soak-20260917.md) completed after the prompt repairs,
with improved settlement but renewed checkpoint worker failures. It also exposed
bounded event-rendering, interrupted-duration, classification and clock-labeling
gaps. These four follow-ups are now locally qualified and installed through
[the approved repair](maintenance-follow-up-delivery-20260917.md). The subsequent
[authorized follow-up soak](maintenance-follow-up-soak-20260917.md) passed bounded
live checkpoint and large-event inspection acceptance; residual contention and
content quality remain open.

## Approved maintenance follow-up — installed; bounded live soak complete

[Maintenance follow-up plan and eight acceptance criteria](maintenance-follow-up-plan-20260917.md):
explicit Scottish job-wide 24 replacements/hour, measured checkpoint-contention
repair, four existing
inspection/diagnostic gaps, and targeted identity/split/quotation clarification.
Keep Luna Low/Sol Medium. Adrian approved work under RAG-OPS-003/004,
RAG-SMK-003 and C1/C2. All 124 required local cases pass; the exact artifact is
installed and Scottish 24/hour policy is applied through public controls.
[Delivery evidence](maintenance-follow-up-delivery-20260917.md) records the eight
criteria, unchanged schema 19/generation 28,711 and successful read-only CLI/MCP
checks at installation. Adrian separately authorized the
[follow-up one-hour soak](maintenance-follow-up-soak-20260917.md): all eight workers
completed without failure/replacement, large event inspection passed and final
integrity/closeout passed at generation 29202. Residual heartbeat contention,
quotation/ID reliability, live shared-outage recovery and wider content/endurance
qualification remain explicit. No commit or publication occurred.

## Reference and quotation batch — installed; short soak complete, 17 September 2026

[Seven acceptance criteria and delivery evidence](resolution-references-delivery-20260917.md)
track the bounded C1/C2 follow-up: deterministic S/C/E references for new model
requests, canonical expansion before existing validation, retained original
input/output/map, readable source excerpts, specific correction feedback and a
single exact newline interpretation after normal matching fails. No persistent
ID/schema/model/budget change. Native replay, correction and candidate/lifecycle
boundary checks pass. The first combined gate also exposed and reproduced one
small observability omission: byte-operation deadline failures were absent from
timeout searches. The shared classifier is repaired; combined local
qualification is complete: 125/125 required passes, with two exact-input passes reused, in 8m 58s. The delivery record retains the earlier failed gate and final artifact hashes.
The exact candidate is now installed. The [authorised 15-minute soak](resolution-references-soak-20260917.md)
completed with eight healthy workers, 362/368 accepted calls, six successful
quotation corrections, no ID rejections/dead letters and clean verification at
generation 29317. Stable short-reference maps and the exact newline fallback
were exercised live. There were 246 resolved selected tasks out of 296, with
29 pending after cutoff. One advanced search/read sequence exposed ESC-OPS-02:
remaining-call instructions and the enforced attempt limit disagree. The [bounded repair](advanced-call-budget-delivery-20260917.md) passes targeted
acceptance and all 126 local checks. The final repair is now published/installed and its previous stranded task resolved
in the [fresh fifteen-minute soak](maintenance-budget-soak-20260917.md). That run
settled 223/231 calls, with seven quotation rejections and the separate ESC-OPS-03
recording failure. All eight workers stopped cleanly and final verification passed.
Keep Luna Low / Sol Medium; selected-occurrence presentation and stale frozen
remaining-call wording on corrections remain bounded prompt follow-ups.
Different workloads prevent a causal comparison with earlier rejection rates.
Wider hosted/platform/endurance and historical quality acceptance remain open;
this is not a release or corpus-quality sign-off.

## Scope and status

`ROADMAP.md` is the sole master for current defect, capability and qualification
status. Design, audit, incident and delivery documents retain requirements and
historical evidence; their old open/closed labels do not override this register.
Update this file when scope or status changes and link the supporting evidence.
Do not copy current-status tables into new delivery records.

Reconciled 16 September against committed baseline `549887f`, the configuration
audit (all 53 HC IDs), operational/query/reliability/recovery registers, Scottish
Test 7, escalation triage and the worker repair. The former narrative is retained
in [the dated snapshot](roadmap-history-20260916.md). GitHub had zero open RAG
issues at reconciliation. Adrian reports #699 fixed in the local CREXX installation on 16 September; upstream issue status has not been rechecked. #701 was closed and qualified. The absence of GitHub
issues does not close the local backlog.

- **Open:** the requirement is not delivered or its acceptance is outstanding.
- **Partial:** implemented and tested pieces exist, but the whole requirement
  remains open.
- **Recorded repair:** named historical implementation/QA evidence exists;
  this does not establish unattended, hosted or platform qualification.
- **Proposed:** a review recommendation or experiment, not implementation approval.
- **Accepted limitation:** an explicitly agreed boundary, outside active defect
  work; reopen only when the supported use case or requirement changes.
- **Upstream:** CREXX owns implementation; RAG owns downstream qualification.

P1 means high priority in RAG-OPS. HC priorities retain the configuration audit's
different definition: P0 blocked its next paid batch, P1 belonged in its
configuration repair, and P2 was hardening. They are not directly comparable
severity ratings. QE items have no original severity. A hidden constant is not
automatically a defect; distinguish policy, format guards and invariant rules.

## Operational P1 requirements

OPS-001–004 remain partial umbrella requirements. Their implemented subcases
are recorded below; corpus content decisions and hosted/endurance/platform
qualification remain distinct. OPS-005 and OPS-006 are closed.

| ID | Status and owning components | Required outcome and remaining acceptance |
| --- | --- | --- |
| RAG-OPS-001 | Partial — operator composition in `ragproduct`; configuration, lifecycle, receipt/usage and worker owners | One repeatable launch/resume path, early compatible configuration handling, supported recovery and idempotence without builds, SQL or bespoke scripts. `job run`, pre-claim checks and Codex reconciliation exist. Step 3 now tests receipt-write failure for extraction/embedding: original usage survives, saved Codex output is reused and unavailable output remains held without a blind repeat. The [public recovery follow-up](public-recovery-journey.md) tests composed diagnosis/retry/waiver on a frozen installed artifact. Compatible worker-count registration is now implemented and covered in the continuation journey. The installed gate and actual original-queue/maintenance continuation passed. The simple controller restart follow-up is implemented and qualified separately in the four-fix record. Test 1 closes the five missing embeddings using public recovery. RAG-SMK-006 is locally repaired and qualified. Selected operational retries and prospective source configuration beside inherited held jobs remain separate acceptance; see the publication repair record. |
| RAG-OPS-002 | Partial — shared rules/requests in `raglifecycle`; task/window execution in `ragbacklog`, claims in `ragwork` | Accept a durable, deduplicated retry request for **every task state**, including closed windows/terminal parents; distinguish accepting the request from when execution is safe. Preserve attempts, receipts, usage, uncertain outcomes and explicit authorized ceilings. Step 2 implements request acceptance, task reconsideration and shared job-state projection; native cases cover five retained failures, covered work and exhausted/uncertain holds. Reasoned waiver/reopen controls are implemented in the [public recovery follow-up](public-recovery-journey.md), retaining missing coverage, attempts and uncertainty. The UX-04 follow-up adds targeted external-retirement controls; its qualification is recorded separately. The continuation follow-up reproduces and repairs an actual old one-attempt failure under a later policy, plus explicit embedding six versus reasoning one. Shipped Gemini examples now use three; existing explicit policies remain intact. Full local QA passed 63/63; real hold inspection and request retention passed. Test 1 explicitly authorized an embedding ceiling of two and completed all five retained failures with five calls, preserving every original attempt and completing the retry requests. Broader policy increases remain unauthorized; automatic publication required provider-free recovery (RAG-SMK-006). |
| RAG-OPS-003 | Partial — essential work inspection delivered locally; wider reporting remains | Documented commands alone explain progress, denominators, unique coverage versus attempts, failures, retry eligibility, waiting reasons, configured/live workers, recovery allowance, interval throughput and known/incomplete usage. Steps 1/4 add admission/supervision waiting status, pool counts and rolling capacity. Step 5 repairs UX-02's maximum-page and large-plan discovery failures, with complete detail reads. The [public recovery follow-up](public-recovery-journey.md) adds consistent actual item counts versus limits, recorded/incomplete usage, interval throughput and correction outcomes; The continuation follow-up adds paged source/operation totals, current item retry facts, provider time and controller/heartbeat/replacement details, with corpus-scale read evidence. Final full QA and corpus-scale reads passed. RAG-SMK-004 (stale registrations called live) and RAG-SMK-005 (disagreeing final states/activity) are repaired through shared supervision and lifecycle readers; their CLI/MCP parity regressions pass. See the four-fix record for exact full and installed qualification. The 16 September inspection gap is now closed locally: filtered job/item/task searches, paged original request/response and correction history, and a diagnostic summary pass 123 local checks plus the 267-call isolated run. [Essential observability delivery](observability-delivery-20260916.md). Master installation and the [17 September soak](maintenance-soak-20260917.md) are complete; publication remains separate. The four observed follow-ups are now locally qualified and installed: bounded large-event previews with full retained-body references, full interrupted-step elapsed timing, original transport cause through reconciliation, and UTC failed-lock diagnostics. All ten formerly unreadable corpus events render with matching hashes; 124/124 required local cases pass. [Follow-up delivery](maintenance-follow-up-delivery-20260917.md). The [follow-up live soak](maintenance-follow-up-soak-20260917.md) paged all 42625 events without gaps, verified all 1455 response hashes and reconstructed 13 original sampled requests matching preview digests. Interrupted elapsed/cause behavior was not exercised live. The decision section remains item-level eventual state even for a selected earlier failed attempt; preserve this interpretation caveat in reporting. Wider reporting remains separate. |
| RAG-OPS-004 | Partial — `ragadmission`, `ragsupervision`, `ragenvironment` | Temporary capacity pressure, rolling worker replacement and safely uncalled shared preflight backoff are implemented. [Supervision evidence](supervision-recovery.md) covers expiry, controller restart, concurrent reservations, zero healthy workers, eight-worker outage/recovery and task isolation. Task attempts, uncertain outcomes, cumulative usage and cutoffs remain independent. The continuation gate additionally reproduced a WAL startup race; `ragstore` now shares bounded BUSY acquisition retry with transaction admission, tested by an exclusive-lock rendezvous on both VMs. Final full QA passed 63/63; actual timeout interruption/replacement and healthy-peer progress passed in the bounded corpus smoke. The [17 September soak](maintenance-soak-20260917.md) confirms that two earlier checkpoint replacements exhausted the hourly allowance before five outage-aligned transport failures, leaving three healthy peers. The approved explicit 24/hour policy is now installed, leaving the default two unchanged. Shared bounds, five-of-eight outage recovery after two prior replacements, exact rolling expiry, restart/cancel/deadline and concurrent-capacity controls pass locally. [Follow-up delivery](maintenance-follow-up-delivery-20260917.md). The [follow-up hour](maintenance-follow-up-soak-20260917.md) kept all eight original workers healthy with zero replacements and the full 24 still available. No outage occurred, so adequacy in a new live shared outage and wider platform qualification remain open. |
| RAG-OPS-005 | Closed — local full QA 63/63 and actual same-job ingestion/maintenance continuation; configuration, job, budget and window owners | One continuation/renewal operation handles optional exhausted budgets, operational configuration registration and remaining work under terminal internal jobs/windows. Preserve cumulative usage, attempts, receipts, held outcomes and completed work through a new authorization period; do not erase history. Distinguish reserved from consumed capacity. Agree essential versus optional controls, omission/renewal semantics and defaults before code; external account restrictions and the user's unchanged cutoff remain binding. |

### Time-window retry policy — RAG-OPS-006

**Closed as superseded — 15 September 2026.** Adrian withdrew the rolling-hour
retry proposal in favour of explicit `job reset-retries JOB` or `--all`.
The [job controls checklist](job-controls-delivery-20260915.md) owns implementation
and acceptance. Reset preserves historical attempts, receipts, actual usage,
other limits and held outcomes. It does not run work or replenish a budget.
Provider cooldown and worker replacement windows remain separate existing
controls. No rolling retry policy remains planned under this item.

### Commented job files — RAG-OPS-007

**Agreed requirement — implementation open, 15 September 2026.** The
[standing architecture guidance](architecture.md#commented-job-files--agreed-design)
owns the design; this replaces the earlier optional-feature wording.

- [x] Record the requirement in core and Scottish standing instructions and the
  corpus template, with one shared design owner.
- [ ] Implement a simple editable job-file surface over existing controls,
  documenting when edits take effect and preserving unrelated parameters.
- [ ] Preserve explanatory comments, run notes, existing approvals and retry
  instructions through edit/continue; keep per-run content out of AGENTS.
- [ ] Verify those public journeys and retained job/usage history with local
  acceptance before claiming the interface is available.

### Simple controller restart — OPS-001/004, implemented

Follow the [architecture decision](architecture.md#durable-ingestion) and the
simplicity rule in AGENTS.md. Controller failure ends that run. Every ordinary
launch/restart performs the same cleanup/start sequence; there is no election,
worker adoption or extra supervisor. Losing unfinished in-flight work is an
accepted small cost. OPS-005 budget renewal remains closed and is not redesigned.

| Responsibility | Owning area | Acceptance before closure |
| --- | --- | --- |
| Child lifetime | `ragprocess`, existing runtime registry | Record child and controller PIDs in SQLite; before taking further work, the child checks its controller and exits if it has gone. Killing only the controller while a response is held must not permit another claim. `regression_controller_loss` now passes; startup and original-parent identity controls also pass. |
| Routine launch/restart | `ragprocess`; `ragproduct` composes public commands | Politely stop the recorded old controller and children for the selected job, reconcile abandoned runtime state, then start a fresh controller and children. Do the cleanup every time, even when nothing remains. `regression_restart_live` exercises ordinary `job run` with a surviving group and repeated `job continue` after drain. The implemented path uses these existing commands. |
| Durable state | Existing `ragwork`/`raglifecycle`, receipt and usage owners | Preserve committed results, task/attempt history, receipts and cumulative usage. Reuse existing handling for unfinished or uncertain work; cleanup does not renew budgets, retry holds or duplicate paid requests. Existing interruption/receipt/continuation gates remain required alongside the new repeated-cleanup assertions. |
| Process visibility and scope | Existing process checks and public diagnostics | Use the launcher's permission domain and restrict cleanup to the selected registered group. A permission failure is not proof of death. Selected-group isolation, remote refusal without mutation and PID-zero reservation controls pass. The installed probe still conflates absent and inaccessible PIDs; qualification covers same-domain local processes only. |

Keep the mechanism in its existing owning modules. A separate executable or
attached-thread conversion is not part of this outcome. Local fault injection
and a green full suite establish the tested behavior; any further installed,
platform or live-corpus qualification must be named separately.

OPS-001 is the overall operator journey; OPS-002/004/005 define transitions and
OPS-003 makes their outcomes visible. Implement shared decisions once; avoid five
independent wrappers. The [controller repair](controller-recovery-report.md)
closes peer isolation cases, not rolling replacement or renewable budgets.
The [LLM repair plan](llm-processing-repair-plan.md) records earlier partial
qualification; its interruption failure is followed by the later controller
repair evidence, while its representative extraction/maintenance/agent trials
remain separate acceptance work.

## Query and embedding roadmap

All nine are open requirements. Preserve the complete acceptance conditions in
[the query-engine backlog](query-engine-backlog.md). The following is their
consolidated delivery and dependency map, not a new feature specification.

| ID | Outcome | Existing owner, dependency and acceptance focus |
| --- | --- | --- |
| RAG-QE-01 | Selectable graph entry points in search results | `ragretrieval`, evidence types/serialization and shared surfaces. Stable concept IDs, types, mention citations, passage origin, lifecycle/ambiguity and generation; bound/page candidates and expose truncation. Do not invent nodes for unextracted passages. |
| RAG-QE-02 | Explicitly selected, bounded graph expansion | Query plan plus traversal/evidence. Preserve ordinary inferred anchors. Selected IDs, direction/hops/time, generation/staleness, missing IDs, cycles, high-degree nodes and duplicate paths need tested bounds and trace. The Q03 graph-on public-packet overflow has a local whole-record bounding repair with explicit omissions and synthetic lexical/hybrid tests; the combined required local gate passes 135/135. Installed Q03 replay and publication remain pending. [Focused delivery](query-evidence-bounding-20260923.md). Compare curated and optional automatic expansion under QE-09; similarity is not a claim. |
| RAG-QE-03 | Standalone human or optional LLM-directed querying | Shared query service and surfaces. Installed reader without extraction credentials; preserve zero-write/zero-provider `query inspect`. Bound searcher calls/privacy/budgets, validate citations/IDs, and prevent implicit claim writes. Answerer changes do not invalidate embeddings. |
| RAG-QE-04 | Local embeddings with persistent CREXX ownership | Existing provider abstraction and process/session ownership; upstream NI-01–06. Prove offline installed cold/warm use, model reuse, actual CPU/GPU backend, per-owner memory, bounded batches and durable recovery. Preserve HTTP routes; no cross-process native handles or assumed shared allocation. |
| RAG-QE-05 | Deliberately embedding-free lifecycle | Configuration, ingest, maintenance, health and query. Disabled is distinct from missing/failed required coverage; no embedding calls or endless repair census. Later enabling creates only embedding/index work, retaining evidence and graph. This crosses more than the query adapter. |
| RAG-QE-06 | Measured lexical baseline and improvements | `ragquery` and lexical retrieval. **Step 6 repairs the reproduced Unicode query loss**, independently of broader ranking work; see [qualification](public-result-lexical-repair.md). Names/inflections/OCR/typos/aliases/phrases and variant allocation then need frozen-question evidence of gain and precision loss, preserving original citations. |
| RAG-QE-07 | Stable, reproducible embedding profiles | Configuration/work/vector identity; upstream NI-05. Bind weights/checksum, revision, tokenizer, preparation, query/document instructions, pooling, normalization, truncation, dimensions and precision. Retain artifacts/licence and backend qualification. Same dimensions/display name cannot prove compatibility. |
| RAG-QE-08 | Resumable embedding-model migration | Embedding-only maintenance, storage and publication; QE-07. Keep complete old model/index queryable until replacement coverage passes; resume, publish atomically and roll back. No repeated source import/extraction, mixed embedding spaces or paid sidecar rebuild. |
| RAG-QE-09 | Comparative retrieval, exploration, performance and longevity evaluation | Cross-route QA. Start with 60–100 independently supported questions, fixed corpus/graph/settings and agreed thresholds. Compare lexical, graph and small/stronger embeddings; separate ANN error, graph maturity and iterative exploration. Measure useful packet evidence, displacement, calls, latency/tails, memory, throughput and rebuild time on identified hardware/artifacts. Retain Nomic comparison; model candidates are experiments, not selected defaults. |

Begin QE-09 baselining and QE-01/02 interface design early. QE-06 should precede
embedding-model selection; QE-07 should precede freezing a native profile.
QE-04 needs both upstream capability and a concrete persistent request owner.
The [17 September scratch evaluation](native-scottish-evaluation-20260917.md)
proves installed native BGE CPU/Metal execution and provides initial Scottish
retrieval/timing evidence: 339 passages, 20 supported questions, and four
unsupported controls. SmolLM2 failed the grounded-answer screen. This is partial
QE-09 evidence. The [18 September window delivery](windowed-embedding-delivery-20260918.md)
adds the native BGE adapter behind the RAG provider interface, with a persistent
model/session per process worker, atomic complete-list publication and receipt
recovery. All 127 required local checks pass, and the 339-passage small-corpus result
retains 17/20 supported questions at hybrid rank 1 and 19/20 in its top three.
The bounded native, retrieval and small-corpus acceptance is recorded there;
wider model/concurrency, memory and standalone-reader qualification remains
open. Admission and recovery retain the existing worker protocol.
The [18 September interface review and proposed comparisons](native-model-follow-up-20260918.md)
records installed common drivers and broader GGUF support, the BGE-small/base
comparison, a bounded Gemma grounding screen and the separate longer-input trial.
The [same-day scratch comparison](native-interface-comparison-20260918.md) now
includes BGE-small, both BGE-base artifacts and Nomic Q4, plus paired common/direct
API timings. Nomic works at 2048 tokens; 8192 extension remains blocked by current
admission, and Q4 CPU/Metal ranking differences need qualification. BGE-small is now selected for this bounded local embedding implementation; the
full Scottish copy rehearsal is now authorized and running with eight workers;
see the [migration record](scottish-bge-migration-20260918.md). Master replacement
has not occurred. Gemma answer quality and
broader QE-09 coverage remain open.
The agreed [atomic embedding-window design](architecture.md#atomic-embedding-windows--agreed-design)
keeps one local embedding model and the original larger graph chunks. Each chunk
produces a complete list of vectors, published atomically; failure retries the
whole chunk. Search takes the best window score per parent. Window positions and
per-window recovery state are excluded. The implementation and its targeted
failure/retrieval evidence are in the delivery record. QE-04/07/08/09 remain open
for their broader acceptance, particularly complete reader packaging, additional
profiles/models, uninterrupted live vector cutover and the larger comparison.
The agreed 12 September decision retains process workers for fault isolation
and replacement. A bounded attached-thread comparison is an optional QE-04
experiment alongside the bridge, measuring model lifetime, memory, throughput
and cancellation; it is not the remedy for cross-account PID inspection.
Deliver QE-08 with profile changes rather than adding migration after adoption.
Qualify QE-03 and QE-05 as complete installed workflows. Operational P1 closure
remains a parallel prerequisite for unattended work, not an implication of
better retrieval scores.

### Common CREXX inference interfaces — RAG-PROV-01, deferred

**Decision, 18 September 2026: retain the current adapters.** Staged use of the
common CREXX interfaces is the intended direction, but this decision authorizes
recording the work, not implementing a migration. It does not block the current
BGE work or authorize Scottish corpus replacement. Recheck capabilities against
the installed CREXX version before scheduling it; the reviewed package is
`e457f5ec3880`.

`.llm` is the generation interface; `.embedding` is the separate embedding
interface. Keep the existing RAG `.provider` contract and migrate its
implementations individually. Generic inference and lifecycle belong to CREXX;
window splitting, profile compatibility, atomic storage, validation, receipts,
retry policy, privacy, budgets and recovery remain with their existing RAG owners.

| Route | Direction and current prerequisite |
| --- | --- |
| Native BGE embeddings | First migration candidate, after common `.embedding` exposes token admission without inference and actual input-token usage. Retain the current typed `llama` adapter meanwhile. |
| Future local generation | Existing `openai-compatible` HTTP generation supports an optional local answerer. The 19 September bounded query follow-up implements short references, existing-budget context selection and retained evaluation cases; the CREXX metadata repair is locally qualified. [Delivery and QA state](local-search-followup-20260919.md). Three earlier queries now return the requested facts, but one adds a false interpretation. Ollama's internal thinking pass adds latency and is absent from final-pass usage; qualify the existing reasoning-effort control for the HTTP route next. Native RAG generation integration and ingestion/maintenance migration remain separate under QE-03/09. |
| Hosted embeddings | Retain the HTTP adapter: common `.embedding` currently supports native llama only. |
| Hosted generation | Retain the HTTP adapter until common drivers support schema-constrained output, required message roles/system prompts, actual input/output usage, real provider finish reasons and equivalent timeout/error/cancellation behavior. `generateJson` currently returns the HTTP JSON body; it does not request constrained generation. |
| Managed Codex generation | Retain the App Server adapter. Common drivers do not supply its managed authentication, progress/usage observation and retained-outcome recovery lifecycle. |

The smallest upstream embedding extension is (1) token counting/admission using
the exact query/document preprocessing, without inference, with a distinguishable
over-limit result; and (2) input-token usage on results, including consumed work
on failure where available. The current window splitter uses typed admission to
fit BGE's 512-token limit. Calling inference to discover each boundary or guessing
token counts would lose that behavior. See the
[integration dependency](integration-issues.md#common-inference-interface-gaps).

Performance is not the reason for deferral. The retained
[paired comparison](native-interface-comparison-20260918.md#common-interface-versus-direct-llama)
found identical BGE vectors and no measurable steady-state penalty: Metal query
medians were 2.502 ms direct and 2.332 ms common. Common startup was somewhat
slower in those observations; neither result is a universal timing guarantee.

Before closing a migrated route, prove unchanged profile identity and results,
whole-chunk failure/atomic publication, accurate usage and receipt recovery, and
bounded persistent ownership. Reuse the existing route regressions and add only
the missing interface checks; retain offline installed acceptance for native
inference and Gemini, malformed-output and secret-redaction coverage for hosted
changes. Record full local qualification once for the resulting candidate.
This adapter change should require no schema or operator-workflow redesign.

## Agent and public-surface findings outside the numbered backlogs

These review IDs identify existing findings from
[copied-corpus MCP trials](mcp-soak-trials.md#recommended-next-changes-and-repeat-tests);
they do not create duplicate implementations. Original trials and preserved
data provide evidence, not a new live authorization.

| Register ID | Status | Requirement, mapping and acceptance |
| --- | --- | --- |
| RAG-UX-01 | Closed — local QA and actual named Turray discovery on 12 September | Task lookup by subject/concept and addressable workflow inventory. Maps to OPS-003. The actual repeat found Turray through `maintain workflows --concept Turray` without supplying evaluator IDs, then paged its related tasks. The original failed trial remains historical evidence. |
| RAG-UX-02 | Recorded repair — steps 5a/5b; see [qualified boundaries](public-result-lexical-repair.md) | Coherent pagination and large-row detail. Maps to HC-33/34 and OPS-003. Tests demonstrate the 99/100 review-page boundary and a one-job page failing at 65,536 retained-plan characters after 65,535 succeeds, in human/JSON/NDJSON/MCP. The copied-corpus trial also found a 1,468,714-character plan. The repaired summary/detail projection preserves exact full-detail access, with ADDRESS and installed-copy boundary checks. Wider result-shape limits remain HC-34. |
| RAG-UX-03 | Closed — full QA 59/59 and actual Turray effect preview/acceptance | Connection plans and pending external acceptance previews expose affected claims, supports and conflicts, plus connection dispositions. Lifecycle validation is shared with publication; old saved plans remain immutable. See [coverage and qualification](connection-effect-previews.md). |
| RAG-UX-04 | Closed — full QA 59/59 and actual Turray retirement at generation 24,219 | Targeted public workflow census enqueues remaining connection or retirement questions with generation and ownership/outcome checks. Existing reviewed retirement completes the parent/workflow while preserving history. See [external workflow recovery](external-workflow-recovery.md). Maps to the external-retirement part of OPS-001/002; broader operator qualification remains separate. |
| RAG-UX-05 | Proposed | Source-scoped query inspection and citation-adjacent context. Maps to QE-01/02/06/09. Repeat fixed historical questions and measure coverage, citations, faithful qualification and calls. |

Inline claim submission and complete task-evidence refresh were subsequently
implemented and trialled; retain those as recorded repairs, not open copies of
the earlier synthetic-trial gaps. External-agent tests do not establish general
prompt-injection resistance or historical truth.

## Configuration audit reconciliation

The [22 September veto review](veto-review-20260922.md) records the new product
direction: accept the configured model, eliminate mandatory catalogue/privacy
paperwork, validate only the requested operation's dependencies, and narrow
configuration/recovery checks to the affected work. It includes nine isolated
probes and separates necessary integrity checks from optional workflow policy.
This supersedes treating every HC literal as a request for another configuration
setting. The wider simplification is reviewed, not implemented; the narrow
[privacy-route repair](provider-route-selection-20260922.md) has its own QA record.

All 53 HC IDs are retained below, including fixed and partially fixed entries,
so none disappears during consolidation. Detailed original behavior,
classification and proposed controls remain in
[the configuration audit](configuration-audit.md#runtime-and-semantic-configuration-findings).
Its original line numbers are historical. Here, **recorded repair** follows the
dated audit; **partial/open** avoids assuming every literal was migrated.
The review verified representative current call sites and specific drift noted
below; it did not execute a separate acceptance test for every HC row.

| ID | Original priority | Consolidated status and remaining scope |
| --- | --- | --- |
| HC-01 | P0 | Recorded repair: role extraction envelopes replace hidden ingest/maintenance limits. |
| HC-02 | P0 | Recorded repair: duplicate extraction output clamp removed. |
| HC-03 | P0 | Recorded repair: embedding dimensions derive from reviewed role/catalogue. |
| HC-04 | P0 | Recorded repair: shared embedding role cost envelope. |
| HC-05 | P0 | Recorded repair: bounded inline config/3 catalogue/capability/pricing records; separate catalogue files remain an optional layout proposal. |
| HC-06 | P0 | Recorded repair: actual prompt text and file inputs enter canonical configuration. |
| HC-07 | P0 | Partial: sidecar byte guard configurable; whole-payload loading/ANN memory design remains open, overlapping QE-04/09 performance. |
| HC-08 | P0 | Recorded repair: guided wait derives from reviewed runtime policy. |
| HC-09 | P1 | Recorded repair: answerer input/output envelope configured. |
| HC-10 | P1 | Open query policy: question, alias, spelling and edit-distance limits; map evaluation to QE-06/09. |
| HC-11 | P1 | Open query language/intent rules; map to QE-06. |
| HC-12 | P1 | Open analysis-note retrieval limit. |
| HC-13 | P1 | Open lead mentions per passage. |
| HC-14 | P1 | Open diversity and evidence/temporal ranking weights; measure before tuning under QE-09. |
| HC-15 | P1 | Open policy/representation review: accepted-claim confidence is still 1.0 and hop breakdown uses .75. The later algorithm guide explicitly defines 1.0 as a validation marker, not probability; do not label it a newly discovered false-probability calculation. Decide whether the machine field and score breakdown communicate that meaning clearly; do not replace it with an arbitrary tunable confidence. |
| HC-16 | P1 | Recorded repair: stage 1 shares `ragclaimrules` across workers, external proposals and reviews. Baseline characterization and the complete 51-test gate pass; see the staged delivery record. Configurable weight changes remain separate policy work. |
| HC-17 | P1 | Open claim promotion threshold policy (500,000 millionths). |
| HC-18 | P1 | Open extraction cue/ranking policy. |
| HC-19 | P1 | Open maintenance context limits for prior notes/query gaps. |
| HC-20 | P1 | Open maintenance priority/scoring policy; preserve ordering of essential repairs. |
| HC-21 | P1 | Open maintenance cognitive-trigger policy. |
| HC-22 | P1 | Open ingest work priority and its relation to maintenance priorities. |
| HC-23 | P1 | Open unconfigured ingestion fallback; explicit policy should reach production paths. |
| HC-24 | P1 | Recorded repair: vector row/embedding item/batch controls. |
| HC-25 | P1 | Recorded repair: configured provider batch capability. |
| HC-26 | P1 | Implemented in source: source file/depth guards flow through config and collection; retain operator-configuration regression. |
| HC-27 | P1 | Open storage policy decision. Do not make WAL/FULL casually mutable: choose only supported modes after workload/durability evidence. Foreign keys remain invariant. |
| HC-28 | P1 | Open named backup page/retry/wait policy; preserve installed `rxsqlite` semantics. |
| HC-29 | P1 | Open provider-admission grace/poll policy; review alongside OPS-004, not as independent knobs. |
| HC-30 | P1 | Partial: worker runtime/recovery defaults and bounds now share `ragworkerdefaults` across typed config, file input and canonical identity. Stale/prune/controller timing still needs one coherent policy. |
| HC-31 | P1 | Locally qualified repair: typed validation now matches file/claim/heartbeat lease bounds, 1–86,400 seconds, through `ragworkerdefaults`. The new `configuration_contract` first reproduced acceptance of 86,401 in typed construction while file rejection and valid controls passed. Qualification: [bounded batch](baseline-publication-20260916.md). Processes remain 1–32 and one in-flight item; timing consolidation beyond these bounds stays HC-30. |
| HC-32 | P1 | Implemented in source: plan TTL used by planning and configuration transitions. |
| HC-33 | P1 | Partial: maintenance cursor handling and UX-02 maximum review/job/event pages are implemented. Wider defaults/maxima still need coherent presentation policy. |
| HC-34 | P1 | Partial: UX-02 maximum-page and large-job bounds are repaired with complete plan access; broader result-shape/field limits still need review. |
| HC-35 | P1 | Open snapshot churn weights; lower urgency than correctness/recovery. |
| HC-36 | P1 | Open report-health thresholds and narrative subject policy. |
| HC-37 | P1 | Recorded repair: provider smoke uses configured embedding dimensions/envelope. |
| HC-38 | P1 | Partial: one selected runtime policy now has validated public show/set/replace commands and fresh MCP registry loading; labelled compiled compatibility fallbacks remain. Broader registry simplification remains a decision. |
| HC-39 | P1 | Partial: editable profile TSVs exist; compiled fallback remains. Preserve compatibility rather than deleting it as incidental cleanup. |
| HC-40 | P2 | Open named HTTP wire/buffer guards; expose only operator-relevant policy. |
| HC-41 | P2 | Open documented transport timeout/protocol-version guards. |
| HC-42 | P2 | Open hidden Anthropic missing-output fallback within generic adapter; verify whether a supported product route reaches it before prioritizing. |
| HC-43 | P2 | Open named Codex bounds/close timing; completed-request retention was separately repaired upstream and must not be counted as still open here. |
| HC-44 | P2 | Open central parser/bootstrap format limits; they cannot depend on the unparsed file they protect. |
| HC-45 | P2 | Original 65,535/16-MiB plan-parser mismatch is resolved in current planning/configuration source. Bulky generic job result fields remain UX-02/HC-34. |
| HC-46 | P2 | Partial: supported extensions, MIME mapping, selection rules and unsupported-file behavior are now explicit in the [user guide](user-guide.md#folder-connector-formats). Parsers remain code capabilities. A per-file skipped-format diagnostic remains proposed; no parser or ingestion behavior changed. |
| HC-47 | P2 | Open shared platform/executable discovery and named temporary-allocation guard. |
| HC-48 | P1 | Partial: config/3 next-batch requirements and compatibility projection exist; full policy migration is not complete. |
| HC-49 | P2 | Open central generated-response bounds; relation to reviewed evidence/citation policy must remain explicit. |
| HC-50 | P1 | Recorded repair: `ragresolutioncontract.resolutionactions` is consumed by both response schemas and backlog validation, with subject/workflow and optional-provenance regressions. Independent grounding and untrusted-output validation remain mandatory. |
| HC-51 | P1 | Open replay-lineage depth/truncation visibility. |
| HC-52 | P2 | Open: glossary discovery has a 100,000 candidate-occurrence guard. A configurable occurrence budget and plan/explain visibility need bounded scale acceptance; this is distinct from returned candidate count. |
| HC-53 | P2 | Open policy alignment: direct claim traversal caps at eight hops; ordinary retrieval policy caps at four. Keep both bounds explicit and test cycles/truncation before changing either. |

Do not implement this as 53 unrelated configuration switches. Shared typed
policy, compatible validation/canonicalization and a small set of justified
operator controls should replace duplication. Preserve the distinction between
semantic identity, operational identity and corpus reprocessing authority.

## Recovery and reliability history

These records are retained regression obligations. The 7 September
[REL repair record](reliability-coverage-review.md#current-issue-register)
supersedes the earlier open/fixed labels in the
[6 September investigation](reliability-coverage-review-20260906.md). New OPS
requirements may expose related gaps without invalidating an older test's
specific result. Current peer-isolation behavior follows the 10 September
controller record rather than the older whole-job uncertainty hold.

| IDs | Recorded repair or remaining work | Acceptance/evidence owner |
| --- | --- | --- |
| REL-001 | Recorded repair: manifest writer ownership | `publication`; SQLite ownership spans projection/rename. |
| REL-002 | Recorded repair: batch and single-proposal atomic publication | `publication`, `native_publication`; no graph prefix after late failure, usage retained. |
| REL-003 | Recorded repair: task-appropriate resolution actions | `durable_backlog`, provider/grounding negatives. |
| REL-004 | Recorded repair: paid call success distinguished from item publication | Native semantic/attempt/usage/reservation censuses. |
| REL-005 | Recorded repair: generic extraction/embedding durable-response recovery | `native_receipts`, Codex/durability; no second call for retained output. Stage 3 adds receipt-INSERT faults for both work types and Codex, preserving known usage and saved output without a blind repeat. See [receipt recovery](receipt-recovery.md); OPS-001 operator/platform qualification remains open. |
| REL-006 | Partial qualification: bounded concurrent fault matrix implemented | Native/SQLite rendezvous tests; multi-hour, installed Linux and larger combined workloads remain below. |
| REL-007 | Recorded repair: rollback/commit before manifest projection, first-index recovery | `publication`, `native_interruption`; no requeue after committed mutation. |
| REL-008 | Partial: graph-only vector reuse correct; training CPU for comparison remains | `ann_methodology`, maintenance; optimize only with QE-09 measurement. |
| REL-009 | Recorded repair: ancestral-index observations accepted under membership proof | ANN/repository verification. |
| REL-010 | Historical wording repair; ongoing documentation governance obligation | Do not generalize local, synthetic or dated evidence into whole-product readiness. |
| REL-011 | Recorded repair: admitted cancelled call retains usage and settles reservation | `publication`, `native_interruption`. |
| REL-012 | Recorded repair: late/excess/duplicate usage distinguished from publication authority | `publication`, provider/window policy tests. |
| REL-013 | Recorded repair: extraction resolves active survivor during merge | `durable_backlog`; no migration-parent revival or partial graph. |
| REL-014 | Recorded repair: incomplete alternate vector profile cannot replace complete publication | `ann_methodology`; full staged migration remains REC-001/QE-08. |
| REL-015 | Recorded repair: events command reads event ledger, status exposes error | Public event paging and interruption checks; broader status remains OPS-003. |
| REL-016 | Recorded repair: compatible legacy relative URI no-op | `publication`; require original envelope and working-directory evidence. |
| REL-017 | Recorded repair: remainder incorrectly used for unit conversion | Receipt latency/lease and retry-delay checks; historic bad duration is not silently rewritten. |
| REL-018 | Recorded repair: oversized numeric command input rejected without panic | `native_surfaces`; maintain cross-surface bounds. |
| REL-019 | Recorded repair: durable task census enters reports/health/snapshots | `durable_backlog_provider`; OPS-003 is wider. |
| REL-020 | Recorded repair: original question preserved in query-gap evidence/search | `durable_backlog`; broad retrieval quality remains QE-06/09. |
| RAG-REC-001 | Partial: prospective config/no-op, sidecar recovery and compatible ancestry repaired; explicit complete staged corpus replacement still open | [Recovery record](recovery-defects.md#rag-rec-001--incomplete-replacement-hides-a-complete-vector-baseline). QE-08 covers embedding-model replacement, not every full-corpus replacement. |
| RAG-REC-002 | Recorded repair: migration republishes matching manifest | Durability schema-8/9 case; retain later schema migration coverage. |
| RAG-MNT-001 | Partial: quote-to-original-byte grounding repaired; real extraction success/maintenance quality remains separate | Grounding/provider negatives, LLM trial plan; preserve exact evidence validation. |
| RAG-MNT-002 | Recorded repair: drained cancellation reaches terminal state | Cancellation/recovery cases; OPS-002/005 expose other terminal-state interactions. |
| RAG-MNT-003 | Recorded repair: replay atomically retains reviewed budget policy | Durability claims/reserves/settles/completes replay, not lineage alone. |
| RAG-MNT-004 | Recorded repair: typed identity reuse and explicit alias questions | Backlog/provider fixtures; broad hosted success not inferred. |
| RAG-MNT-005 | Recorded local implementation: autonomous resolution and connection workflows | Backlog/native fixtures and local UX-04 external completion are recorded; fresh-operator and unattended qualification remain open. |
| RAG-MNT-006 | Delivered and locally qualified — bounded selection and reconsideration | Existing paged census now includes settled non-sparse concepts and closed alias questions. Local meaning, direct evidence and connection changes create linked successors; unchanged and own-publication context stays final without model calls. Holds, routing, legacy history and structural follow-up are retained without a schema or task-type addition. Targeted fail-first/positive controls, 133-case local gate and live predecessor-linked samples pass. Legacy fields absent from old packets are baselined; remote graph changes remain outside this local boundary. [Delivery](beta-delivery-20260920.md), [retained pre-change behavior](maintenance-reconsideration-20260920.md), [approved scope and AC-3/6](beta-release-plan-20260920.md#2-make-reconsideration-selective-and-convergent). |

## Other qualification, research and upstream dependencies

The [recommended corpus prompts](../skills/crexxrag-maintain/prompts/README.md)
now make the Scottish maintenance guidance and subsequent extraction/control
clarifications reusable by agents. They are selectable policy templates; the
stopped follow-on smoke is not completed comparative qualification. RAG-QA-02
remains open, and compiled defaults and validators are unchanged.

The IDs in this section index existing unnumbered work; they do not silently
raise its priority above the operational P1s.

| Register ID | Status | Scope and source |
| --- | --- | --- |
| RAG-QA-01 | Open | Bounded multi-hour mixed-workload/long-ledger soak with recorded faults, public readers/backup and resource measurements. The historical 5,000-decision fixture is not unattended qualification. [Test strategy](test-strategy.md#bounded-scale-gates), [process cases](qa-process-cases.md). |
| RAG-QA-02 | Open | Representative extraction, cognitive maintenance and fresh-agent operator acceptance on preserved copies; retain mandatory bounded hosted Gemini qualification. [LLM plan item 4](llm-processing-repair-plan.md#4-qualify-extraction-then-cognitive-maintenance-and-the-agent-handoff). QE-09 measures retrieval quality separately. The completed Scottish run is partial acceptance: 708 processed items, 123 applied-change and 127 final no-change decisions, with 551 failed provider runs and an operator restart. Closeout/integrity passed; two illustrative decisions do not establish overall accuracy, and historical failed-response/model attribution remains incomplete. The subsequent 267-call isolated run supplies exact original input/output and model/effort for new attempts, with clean closeout but 90 dead-letter items; this closes the inspection gap, not wider quality/endurance qualification. The [17 September installed soak](maintenance-soak-20260917.md) adds 1303 calls, 808 resolved selected tasks, nine inspected cases and clean integrity/closeout, but seven historical worker failures and remaining validation errors keep endurance/content qualification open. The [follow-up hour](maintenance-follow-up-soak-20260917.md) adds clean eight-worker completion, 1455 calls, 862 resolved selected tasks and nine original examples; remaining quotation/ID failures and unexercised outage/multi-hour behavior keep broad qualification open. [Earlier evidence](observability-delivery-20260916.md), [original triage](maintenance-acceptance-triage-20260916.md).  The [19 September run](maintenance-quality-soak-20260919.md) passes bounded four-worker operational closure and matches all 1278 request/response pairs; 32 inspected decisions expose semantic limitations. The subsequent [prompt comparison](maintenance-prompt-comparison-20260919.md) records 24 successful calls on eight frozen tuning cases, 33 grounded quotations and 8/8 action/identity agreement on the original-pair repeat. Revised Scottish objectives are installed; stronger models showed no decision-quality gain in this sample. Full lifecycle replay, unseen-case quality, wider endurance and health/social-care qualification remain open.  The [20 September main run](maintenance-final-review-20260920.md) restored policy and verified generation 29928, with one automatic replacement and one incomplete-usage observation. Its response deadline arrived about 13.47 seconds after the request despite configured 120 seconds; the precise expired deadline remains to be diagnosed. Selection/reconsideration coverage is now the next explicit acceptance focus under RAG-MNT-006. |
| RAG-QA-03 | Open | Installed Linux replay and non-macOS release/fault coverage, including filesystem/disk-full behavior. [Integration issues](integration-issues.md#installed-linux-replay), [process cases](qa-process-cases.md). |
| RAG-QA-04 | Open qualification boundary | General malicious-source/prompt-injection behavior is not established by the bounded MCP trials. Preserve untrusted provider/evidence and authorization boundaries; scope any future adversarial qualification explicitly. [MCP trials](mcp-soak-trials.md). |
| RAG-QA-05 | Published; local qualification passed | The runner now reserves child identity through cleanup and handles reproduced macOS EPERM from zombie-only groups only after confirming no live member remains. Actual or uncertain cleanup failure retains a failed, non-reusable receipt and original process exit code. Nine harness controls plus all 132 required cases pass, including the original operator-diagnostics journey. The old run did not retain enough process-state evidence to prove its exact mechanism; its missing-receipt failure and the reproduced cleanup boundary are repaired. [Delivery](esc-ops-04-qa-cleanup-delivery-20260919.md), [original incident](scottish-bge-migration-20260918.md#local-qualification).  [Published baseline and bounded quality run](maintenance-quality-publication-20260919.md). |
| RAG-PERF-01 | rxvector consolidation published and installed; migration contention remains open, 19 September | The generic float32 binary owner, portable codec and exact search now live in CREXX rxvector as C. RAG removes its incubating plugin, USearch vendor and private SDK/C++ packaging. Existing RXVIDX/1 sidecars read unchanged. A paired Release comparison gives identical 0.965 s full-query medians and all twenty passage orders; maximum score difference 9.38e-8, twelve known reference hits per route. Focused retrieval and provider/native-memory checks pass. The 541.25 s full selection exposed a mixed-cohort launcher fixture and a native model-load timeout. The selected-runtime fixture passes in 32.12 s; the unchanged real-model case passes alone in 10.91 s and now declares eight scheduling slots. Closing documentation and exact-input audit account for 130/130 required passing cases; the full selection is not repeated. [Current delivery](rxvector-consolidation-20260919.md). The normal CREXX install now uses published `5949ef27efd8`; rebuilt RAG passes 130/130 in 720.51 s and its qualified artifact is installed. [Publication and automatic CI closure](baseline-publication-20260919.md) supersede the initial private-cohort boundary. RAG other-platform qualification remains separate. The exact route remains opt-in; default IVF settings remain 16/4 following the measured recall comparison. Earlier accepted repairs: [JSON/SQL retrieval](retrieval-profiling-20260918.md), [binary reader/verification](retrieval-tightening-20260919.md), [native publication and RAG-VEC-02 closure](native-vector-delivery-20260918.md), [group comparison](vector-group-comparison-20260918.md). Migration contention remains separate and open (eight workers, 4 h 21 m 35 s, sampled transaction waits; history-size attribution unproven). [Migration evidence](scottish-bge-migration-20260918.md#in-progress-performance-evidence). HC-07, REL-008 and QE-09 share these evidence records. |
| RAG-RET-01 | Proposed | Retention of bulky resolved payloads with compact outcome/lineage/usage audit, respecting recovery and evidence dependencies. No purge implemented. [Retention follow-up](reliability-coverage-review.md#proposed-retention-follow-up). |
| RAG-EXP-01 | Proposed research | Source expansion and controlled graph-value comparison; map retrieval measurements to QE-09 rather than claiming higher claim counts prove better answers. [Scottish development](scottish-corpus-development.md). Reconcile that document's old approval/run language against the later metadata-only decision before acting. |
| RAG-EXP-02 | Optional experiment | Per-support time/provenance assessment is separate from normal document metadata. Broad automatic assessment was rolled back as default; do not reopen it via older proposal wording. [Current contract](time-and-provenance.md), [dated proposal](claim-time-provenance-proposal.md). |
| CREXX-NI-01–06 | Upstream dependency; RAG integration unqualified | Generic native inference, CPU/GPU, persistent model owner, packaging, artifact identity and qualification. RAG consumes installed capability via QE-04/07/08; no native inference copy in RAG. [Dependency record](integration-issues.md#proposed-native-embedding-capability). |
| CREXX-NI-07 | Investigation after Scottish BGE migration acceptance | Review installed local models for short evidence-grounded answers, then bounded follow-up search/graph traversal; measure cold startup, latency, memory, supported claims/citations and insufficient-evidence decisions. Assess ingestion separately for validated extraction quality and throughput. Keep offline embedding/database retrieval usable with generation disabled. No generation benchmark has yet been qualified by the full-corpus embedding run. |
| RAG-PROV-01 | Deferred — retain current adapters, agreed 18 September | Staged adoption of common `.llm`/`.embedding` behind the existing RAG provider contract, after capability parity. Native token admission/usage is the first prerequisite; hosted embeddings, structured generation and managed Codex have separate gaps. [Decision and acceptance](#common-crexx-inference-interfaces--rag-prov-01-deferred), [upstream dependency](integration-issues.md#common-inference-interface-gaps). |
| CREXX #701 — child pipe inheritance | Closed upstream; downstream repaired and locally qualified | Installed CREXX `17e844441ed8` passes all three original worker-exit faults; `worker_unexpected_exit` is enabled without exclusions. Keep the broader T7-10 investigation separate. [Retest](crexx-701-retest-20260916.md), [issue](https://github.com/adesutherland/CREXX/issues/701). |
| CREXX #699 — source-import compiler failure | Fixed in local CREXX installation, reported by Adrian 16 September | No longer treated as a current local blocker. This planning change did not rerun the original source-import reproduction or recheck upstream issue status. Historical `lineout(stream)` containment remains documented. [Integration evidence](integration-issues.md#installed-compiler-source-import-finding-during-t7-10), [issue](https://github.com/adesutherland/CREXX/issues/699). |
| Policy publication boundary | Accepted limitation — agreed 12 September | Custom mode/ACL preservation and policy-file power-loss durability are outside active defect work. Process-default metadata and manual policy restoration after power loss are accepted. Retain validation, staged rename, ordinary process-crash recovery and all SQLite/receipt/usage protections. Non-macOS replacement remains QA-03 qualification. [Integration issues](integration-issues.md#policy-file-publication-metadata-and-durability). |
| Process identity boundary | Lower-priority upstream improvement / qualification limit | Keep process workers and same-account local pruning. A future CREXX check should distinguish alive, missing and unknown/error; unknown ownership must prevent automatic pruning. OS birth identity remains unavailable. No same-account failure was established by this review; changing to threads is not required. [Integration issues](integration-issues.md#local-process-liveness-and-permission-boundary). |
| Interactive input | Recorded upstream repair — installed route verified 12 September | CREXX fixes #670, #669 and #678 are included in installed `5ccf057a1633`. Existing pipe and real-PTY driver regressions both pass after one newline. The stale outstanding label is closed for this installation; retain regression coverage and the normal `--yes` automation path. [Repair history and verification](integration-issues.md#interactive-input). |
| Channel request retention; project-build scaling; attached-provider discovery | Recorded upstream repairs | Retain installed-package regression obligations; do not duplicate as open RAG implementations. [Integration issues](integration-issues.md). |
| RexxScript configuration | Deferred feature choice | Current declarative configuration suffices; no evidence requires an additional executable configuration language. |

## Recommended execution order

Approved 16 September: reconcile this master, fix bounded low-risk items with
regression-first targeted checks, complete baseline operational acceptance and
one final local gate, publish/install the exact candidate, then review this
register again. [The execution record](baseline-publication-20260916.md) records
the numbered acceptance criteria, exact artifacts and publication receipts.

This batch includes HC-31 lease validation, HC-46 format guidance and stale
escalation/QA documentation. It does not change retrieval ranking or add policy
switches. Defer T7-10 host/endurance experiments, HC-07 memory architecture,
OPS-007 job files and QE implementation to subsequent scoped work. Hosted
acceptance remains QA-02; no paid corpus processing follows from publication.

## REG-01 — Regression coverage before implementation

Regression coverage is a standing requirement. Confirm the affected behavior
before implementation, retain ordinary failing reproductions and positive
controls, then qualify the repair. Use the [test strategy](test-strategy.md)
for disjoint parallel tiers and exact-input receipt reuse, and the
[coverage matrix](regression-coverage.md) for executable contracts. Full local,
installed, hosted, endurance and platform results must be reported separately.

The first deliverable is a risk-based acceptance matrix and executable baseline:

| Coverage area | Required observable checks |
| --- | --- |
| Data and publication | Unchanged ingestion/configuration is a no-op; source bytes, spans, graph history and vectors survive failure; incomplete replacements cannot displace a complete baseline; committed work is not repeated after projection failure. |
| Task/job/window lifecycle | Start, pause, drain, cancel, close and continue; failed tasks under each relevant parent state; retry requests and repeated requests; retain durable history while allowing the agreed loss of an unfinished in-flight task. Cover OPS-002's closed-window case explicitly. |
| Receipts and accounting | Before submission, after receipt, before/after settlement and publication; exact and conflicting duplicate receipts; unknown outcomes; actual usage versus reservation; no repeated paid request for durably retained output. |
| Worker and environment failure | A bad task, failed worker and shared outage have distinct effects; healthy peers continue; controller restart replaces runtime ownership while preserving durable history; temporary reserved capacity differs from total budget exhaustion. Rolling replacement and shared preflight recovery now have native/VM acceptance; renewal and wider infrastructure qualification remain separate. |
| Public surfaces | Equivalent CLI/JSON/MCP/ADDRESS semantics where supported; maximum pages including cursor overhead; large individual records; meaningful previews; complete externally driven correction/recovery. Preserve the reproduced 99/100 review-page boundary. |
| Retrieval and evidence | Frozen representative questions and independently identified evidence; direction, citations, ambiguity, absent answers, Unicode/OCR names and embedding compatibility. Seed QE-09's broader comparison without assuming current rankings are the oracle. |
| Installation and bounded load | A fresh installed package performs the supported journeys without source-tree access; deterministic concurrent requests and a bounded longer ledger/load case retain exact semantic/usage assertions. Keep multi-hour, hosted and platform qualification explicitly separate. |

Distinguish three kinds of evidence: passing tests for supported guarantees;
failing reproductions of known defects; and proposed acceptance for behavior
that does not exist yet. A known bug must not become the asserted desired
behavior merely to keep the suite green. Record any expected failure explicitly
against its issue, require the failure to be the intended one, and remove that
designation when the repair passes. Setup errors are not defect reproductions.

For each prioritized historical failure, retain its trigger, expected outcome,
owning component and a named executable case. Use deterministic rendezvous and
independent state/call-count assertions rather than timing guesses or success
messages alone. Include normal alternatives so tests do not merely mirror the
patch. Existing fixed REL cases remain in the required regression panel.

REG-01 is ready when the prioritized matrix has no unexplained coverage gaps,
the baseline's passing results and known failing reproductions are repeatable
on an identified artifact, and one documented command runs the required gate
and retains failures. Agree unresolved product-policy expectations explicitly;
do not invent them in a test. This is not a promise of exhaustive coverage.
Subsequent work begins by making its specific acceptance test fail, implements
the smallest change, and then runs the affected panel and required full suite.

For future updates, change the consolidated status here and link the exact
implementation/acceptance evidence. Keep dated incident reports append-only in
meaning. Do not infer completion from a test count, a successful provider call,
an implementation commit, or a related repaired ID.

## Current delivery boundary

This publication is a local macOS operational baseline. Closure requires the
checks in [the delivery record](baseline-publication-20260916.md), not a claim of
unrestricted unattended or cross-platform readiness. Existing corpus approvals
and expired run windows are not renewed.
