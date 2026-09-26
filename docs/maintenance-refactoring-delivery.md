# Maintenance refactoring delivery

## Sparse-node graph development — 25 September 2026

Coordinator review R1/R2 added two bounded controls. An actual pending worker
relationship review with a moved cited mention refused acceptance, then failed
both reject and dismiss before the repair (`durable_backlog_sparse_edge` red
receipt `20260925T202158-3333f085`). `reviewbacklogdecision` now applies its
current-evidence validation only on acceptance, within the existing fenced
transaction and after freshness checking. Reject and dismiss still require the
pending review identity and matching retained profile, then close the review
without a graph generation; the synthetic controls preserve decision, attempt,
event and provider-usage history. The prior unchanged worker acceptance remains
the positive control. A separate changed-source-context task proposes the exact
already active support with a distinct review. Acceptance records a resolved
decision with no applied generation, second claim/support, or provider call;
the original hashed identities remain active. No schema, index or recovery
protocol changed. The SQL checklist is in
`docs/sql-performance-delivery-20260913.md`.

This coordinator-reviewed local item-3 checkpoint starts from item-2 commit
`3625ecc336c3ee7cda763ca5055a3f6687e8f20a`. The clean baseline passed
`regression_prompt_inspection`, `regression_claim_policy`, `durable_backlog`,
`durable_backlog_reconsideration`, `regression_source_maintenance` and
`native_surfaces` (6/6). A new `durable_backlog_sparse_edge` synthetic control
then failed first: the sparse-node response contract had no relationship action.

`ragresolutioncontract` now owns `/9` prompt, strict `relationship_type` field
and action vocabulary, with exact `/7` and `/8` frozen binding reconstruction;
`ragresolutionreferences` projects the current contract's aliases. `ragbacklog`
owns the shared worker/external task validation and review transition. It binds
one quotation to resolved endpoint mentions in the selected source packet,
then composes `ragclaims` profile/claim validation and transaction publication.
`ragclaims` remains the sole owner of stable claim/support identities and graph
insertion. Worker and public external paths require review, which can reject
semantic overreach or omitted source scope. The claim writer receives the
existing staged generation; exact support replay produces no new generation.
The public CLI/MCP operation names and permissions are unchanged.
An independent `/8` concept prompt/schema hash pair was obtained by linking a
scratch probe against the retained clean-baseline QA executable, then frozen
in `regression_prompt_inspection`. The current binding accepts those exact
hashes and rejects a modified schema. The existing authentic `/7` hash case
also remains passing.
The external impact preview carries the prospective hashed claim and support
IDs, and the MCP acceptance fixture verifies that those exact identities are
the ones published after review.
The `/9` loopback provider responses now include the required empty field for
other actions. The existing citation-correction regression also exposed a
cREXX method-scope error in `ragapplicationprovider`: the second request sent
the literal `operational_input` instead of the refreshed operational packet.
The method now retains that variable across branches; the focused correction
case verifies system and presented allowances 2 then 1, one reference mapping,
the corrected quote, receipt count and unchanged durable input. The captured
provider contract fixture changes only for resolution prompt/schema pairs.

The focused fixture reads back two distinct accepted directional, typed and
qualified edges and exact support spans, including one through MCP plan/apply/
review; it also checks a real isolate, wrong endpoints, misquotation, invalid
type, separate review rejection of unsupported direction and omitted scope,
pending-review nonpublication and replay. Source text
and all libraries are synthetic. At linked image SHA-256
`f71dae8f776b915cf5ac3d9982d9fc4758a71a88b9d0bdd2119c99a009f5fbda`
and native executable SHA-256
`f754c7f9acb4dac111da42c2c073674224d9bfaedfa09868084ac934b3f4e1eb`,
the final 24-case affected selection and 11-case fast preset pass. All 15
zero-outbound maintenance provider variants pass, as do the captured prompt
contract, malformed-output and invalid-schema controls. The QA report records
33 current-input passes and 106 not-run cases; reused exact-input CTest skips
are not counted as new executions. A transient combined run failed
`durable_backlog` after printing its success marker; an isolated rerun and the
final serial selection passed. Earlier intentional fail-first, fixture-shape
and allowance-correction failures remain in QA history. `git diff --check`
passes. Full local regression, hosted/platform and
integrated long-run qualification remain the final programme gate, so no
installation or publication is claimed here.

## Mechanical debt and termination reporting — 25 September 2026

This coordinator-reviewed local item-2 checkpoint starts from reviewed item-1 commit
`dfd39b7fbe20f8bd1ac51816ba27336ec04632c9`. Ownership stays in
`ragreportservice` for the logical-question ledger and `ragbacklog` for window
closure and status. CLI and MCP consume their existing shared report/status
results; no schema, provider, prompt, scheduler or policy rule changes.

Before product edits, `durable_backlog` passed 1/1 and the existing
`native_surfaces` plus `regression_source_maintenance` passed 2/2. A new
read-only report fixture then failed with zero reopenings and settlements for
one superseded parent that retained a terminal decision and one changed-evidence
child. A selected finish-workflow fixture failed with `complete:complete` despite
a waiting workflow and linked pending review. The latter requires two bounded
checkpoints: the first visits its workflow and the second closes the window.
Coordinator review R1/R2 then found two further boundaries. An accepted
`defer:review:accept` with state `unresolved` first reported one false settlement
and delta -1; a changed-evidence successor would also invent a reopening.
A public nonempty identity cohort with a fourteen-second `--until` window stopped
for `deadline` before discovery, with zero selected tasks, zero completed
selected scans and zero provider calls, but initially recorded `run_state=complete`.

The repair counts a terminal decision once per task version after supersession,
matches a reopening only to a settled predecessor of the same logical question
with a changed evidence fingerprint,
and leaves ambiguous/missing parent history unreconciled. The current open-task
count and historical events remain separate; repeat provider decisions cannot
inflate closures. Accepted `defer` is excluded from the shared terminal-decision
predicate in both ledger and convergence census; the public review path retains
the task as unresolved. The finish run checks selected workflows, selected review IDs,
and reviews linked to selected tasks or workflow origins. Its summary distinguishes
`termination`, `run_state`, `selected_work_resolved`, exact selected denominator,
unseen-page cursor, pending consequences, processed items, admission deferrals,
provider calls and applied change decisions. `complete` window state means no
runnable work in that window; it does not prove selected or library resolution.
For nonempty identity/graph cohorts, close-time resolution also requires the
selected-kind and settled-question cursors completed for the current scan token.
The `closed_for_no_runnable_work` flag and `closed_epoch` label the retained close-time
observation; status does not run discovery.

The synthetic mixed-state control independently checks seven question keys,
four resolved task versions, one pending review, one waiting workflow and one
failed task before asserting ledger values 7 new + 1 reopening - 4 settlements
- 1 parked - 3 open = 0. It includes repeat resolution, an unfinished
superseded predecessor, dependent work and a technical hold. The prior
offsetting-negative malformed-history control still reports two unreconciled
questions. A terminal superseded parent with no current successor also remains
unreconciled when the global delta is zero. Repeated report calls leave a full
SQLite dump identical. Focused
`native_surfaces`, `regression_source_maintenance` and `durable_backlog` now
pass. The accepted item-1 MCP `minutes:0` schema had left its captured
`all` metadata digest stale; reversing that one field reproduces the old digest
exactly, and the fixture was updated without changing the command catalogue.
Full regression, hosted/platform and integrated long-running checks are the
separate final gate. No real corpus or installed product was operated. The
following hashes and 17-case report describe the pre-review candidate; updated
R1/R2 receipts are recorded in the private item-2 handoff.
At linked image SHA-256 `4404ccc1e7b32497e975b71702ab4687bce2c5cee1213fa83cfe9183cdc0c77d`
and native executable SHA-256
`d8e8e2140dcad9693dbe7582936a500c632e8f605c54e1f3ba6e10459a04fda4`,
the final focused selection passed 6/6 and fast passed 11/11. The QA report
records 17 current-input passing cases and 121 not run. After the final
documentation edit, fast reran one changed documentation case and reused ten
exact-input passes; the six focused cases retain their earlier current-input
executions. No disabled, interrupted or failed case is counted as a pass. The two
intentional fail-first runs and the earlier stale metadata digest failure are
retained separately in the private task handoff.
After R1/R2 correction, linked image SHA-256
`b0dbe8bd684429996d500ae2725e535805fb8e83e92dbd3c1cf2d677fe7bbe3c`
and native executable SHA-256
`55aae07715cb1b2fb4ba36a21f85fe5f900b8dd15e3e5a3095e7311dbfeaaed0`
passed the six focused cases in 37.54 seconds and all 11 fast cases in 5.56
seconds on changed artifact inputs. The private `02-HANDOFF.md` has exact case
receipt paths, fixture hashes and the coordinator-review fail-first evidence.
The coordinator independently audited all 17 current-input passes and 249
recorded input/artifact hashes, then accepted R1/R2 for one local checkpoint
commit. Full regression, hosted/platform and long-running acceptance remain
outside this checkpoint.

## Advanced response schema and terminal error — 24 September 2026

The clean source baseline is `a58ec95b7cfe30b1cb885846a6535bb10a0a2aff`.
The repair is committed as `7ea891956f473d5a9b02b4c42e020857356fc27e`
and published on `main`. The per-user product installation was updated;
the protected corpus workspace and its monitor were not touched. Installed CREXX is
`crexx-1.0.0-beta.3+local.g5949ef27efd8`. The local owner map was checked
before edits: `ragresolutioncontract` owns the prompt/schema/version,
`ragbacklog` owns lifecycle validation and retry scheduling,
`codex_provider` owns App Server protocol errors, and
`ragapplicationprovider` composes frozen bindings and durable receipts. The
provider source is part of this product; no CREXX provider fork is needed.
The committed product/test-file snapshot (16 sorted paths and bytes) has SHA-256
`fb09b9571b5ee8a5892b42feb540351b274cfded153a9a71691213ba28aad22c`.
The linked Level-G image is
`d965e1e576871478196b84c56246b9ee2bd2aa8440631c2f1454f3394c4db6a0`;
the native package executable is
`0714b6f116261bb3311c8611b6953bae7fd0d6d577a586ddd32c465643720ab8`.

Baseline `regression_prompt_inspection`, `provider_durability`,
`codex_protocol_noopt_rxvme`, `durable_backlog_escalation` and
`regression_lifecycle` passed before implementation. A recursive check of the
actual generated schema then failed for all 20 non-provenance subject/workflow
variants: root `required` omitted `dispositions`. It checks every nested object
and array, exact `required`/`properties`, and `additionalProperties:false`.

Contract `/8` requires `dispositions`; unused impact is `[]`. Legacy retained
responses may still omit it. Nonempty dispositions remain restricted to
split/merge/retire, with exact current impact, evidence and review validation
unchanged. The recommendation text and field example now agree. The prompt
and schema golden changed only for resolution; the synthetic Gemini fixture
returns the full strict shape. Exact `/7` frozen prompt/schema hashes are
verified before a queued old item uses the repaired request; tampered or
unsupported hashes are refused. This does not rewrite old work or receipts.

The Codex adapter retains bounded upstream message, code/type, HTTP status
and schema parameter from matching thread **and** turn, including fresh
`thread/read` and recovery. Deterministic invalid requests/authentication are
nonretryable; rate limit and service errors remain retryable; interrupted and
unknown outcomes remain separate. Only recognized short error messages leave
the adapter; source-like or unrecognized upstream text is withheld while the
safe classification fields remain. `ragapplicationprovider` records a terminal
failure receipt and settles its existing run, including rejection at
`turn/start` before a turn identity. Unknown outcomes keep the exact-turn hold.
An explicit task retry in an active window bypasses automatic backoff but
retains deliberate deferral, original attempt/call ceilings and all history.

Synthetic old-to-new native evidence was generated from the baseline
executable, then run with the candidate against the same disposable library.
A queued `/7` item preserved its old prompt/schema hashes while the actual
provider request used new hashes; it produced one validated no-change decision
and one response receipt. A separate `/7` HTTP-400 failure retained its
failed item and receipt. An explicit public `maintain retry` under the already
active window dispatched one `/8` item and one validated no-change decision;
the task resolved, the repeated worker run made zero calls, and the retry
request became `completed/already-complete`. No reset, SQL recovery edit,
configuration change across the upgrade, or added allowance was used. The
disposable fixture's original envelope was sized to include later evidence.
The old error had no reported usage; the test did not invent any.
An additional old-to-new synthetic run seeded an unrelated pending `reviews`
row and review-state task before upgrade. Both remained pending/in review;
the prior accepted extraction and chunk remained one each, the two original
`/7` items and failed receipt remained intact, and one `/8` decision added one
attempt. Provider usage moved from the existing 204/60 to 414/124 input/output
tokens after the one reported new call. Repeating the public retry returned
`completed/already-complete` with the same request ID.

The integration tests `codex_application_invalid-schema` and
`codex_application_invalid-schema-start` verify native worker settlement,
`-101`/HTTP 400/nonretryable durable receipt, and one turn start across replay.
`codex_protocol_*` covers matching turn/read-back and malformed, missing,
authentication, rate, transient and interrupted errors on both VMs and build
modes. `durable_backlog` checks empty/absent/nonempty dispositions and existing
split/merge/retire evidence and impact rules. `observability_providers` also
guards fresh read-back of interrupted turns while retaining the original
timeout or disconnect cause. `advanced_first_pass` runs a disposable native
four-worker window from invalid ordinary quotations through one correction,
escalation, an advanced `extract` decision and a successful typed follow-on.
Its accepted extraction receipt completes first-pass coverage; restarting the
workers and replaying the unchanged source add no work or provider response.
Local configuration/build and `ctest --preset fast --output-on-failure`
passed. Focused protocol/application/observability/first-pass selection passed
8/8. The final `ctest --preset regression --output-on-failure` selection
accounted for **138/138** required cases; `tests/qa/report.py` records 138
passing cases with no disabled, failed, interrupted or not-run entry. A prior
full selection exposed a transient local-model load timeout in the unrelated
`native_embedding_windows` fixture under concurrency. The unchanged case
passed alone in 10.55 seconds and its exact-input pass was retained in the
final selection. `git diff --check` passed. The exact committed package was
installed first in a scratch prefix and then with `install-local` at
`/Users/adrian/.local`. Both executable hashes equal
`0714b6f116261bb3311c8611b6953bae7fd0d6d577a586ddd32c465643720ab8`;
the installed resolution contract and Codex adapter match committed source
byte for byte. A disposable installed-library `init` and `verify` passed, and
the installed executable passed the four-worker `AdvancedFirstPass.cmake`
journey through accepted first-pass receipt and unchanged replay. The previous
product executable (SHA-256 `b83b34b07cde246449602a93b0a5412575a0849613053ada327f41f7726e18dc`)
and application support trees are retained at
`/Users/adrian/.local/rollback/crexxrag-pre-7ea8919/`.
The [hosted package run for exact repair commit `7ea8919`](https://github.com/adesutherland/crexx-rag/actions/runs/35987323104)
completed successfully: `metadata`, `macos-x86_64`, `macos-arm64` and
`windows-x64` passed. The release `publish` job was skipped because the source
was pushed to `main` without a version tag. This qualifies the hosted package
checks, not real-provider behavior or wider platform functional regression.
Corpus-specific qualification remains pending. No hosted provider call or
corpus installation was made.

### Proposed later corpus deployment and selective recovery (not executed)

After separate corpus authority, select a qualified exact product revision in
a controlled prefix (`cmake --install cmake-build-debug --prefix PREFIX` is the
local package form). Verify that prefix in an isolated scratch library before
selecting it for any retained library. Keep the pre-recovery executable
available for rollback. The per-user product installation reported above did
not select an executable for the protected corpus or start any recovery.

With the target monitor paused and its existing native backup verified by the
authorized operator, inspect each affected task, job item, receipt and exact
Codex turn through public commands. Reconcile any unknown turn before deciding
on a new call. A queued exact `/7` binding can use the repaired schema when its
existing window admits it. For a confirmed terminal invalid-schema item in an
active compatible window with unused original allowance, issue `maintain retry
TASK_ID --reason "corrected resolution schema"` only for that task, continue
the owning job, and inspect the new receipt and accepted first-pass census.
Repeat inspection/retry should add no call after completion. Do not reset the
task, edit the plan/database, renew budget, waive coverage or alter provider
policy. A closed window, insufficient original allowance, changed evidence,
review hold or uncertain turn needs an explicit operator decision and possibly
a separately reviewed plan; this repair does not make such a decision.

Before any recovery call, rollback is the prior executable/prefix switch with
the monitor still paused. Once `/8` work or new accepted results exist, pause
again on failure and use a forward repair; do not assume the older executable
can process the new contract or silently replace library state.

## Combined convergence candidate — 23 September 2026, in progress

`ragbacklog` owns the shared accepted-first-pass predicate, settled-question
context, bounded phase/cohort selection, identity candidate context and
coalesced alias follow-up. `ragmaintain` binds reviewed invalid-candidate
rejection to the retired occurrence; ingestion and extraction consumers honor
the latest accepted decision. `ragresolutioncontract` owns the revised
insufficient-evidence and lifecycle response schema/instructions.
`ragreportservice` owns the logical-debt projection and reconciliation;
`ragqueryservice` owns the evaluation gap-recording option and
`ragcommandcatalog` forwards explicit false through MCP. No schema or native
provider change is part of this candidate.

Fail-first controls reproduced the processed-control first-pass bypass,
irrelevant note/gap reopening, retirement impact omission, informational
recommendation scheduling and MCP false-option loss. Current targeted
`regression_source_maintenance`, `durable_backlog`, `native_surfaces`,
`regression_command_catalogue` and six evidence-overflow checks have passed
at their relevant intermediate builds. The required local gate accounts for
**135/135 exact-input passing cases**: the final selection executed 72 and
reused 63 retained passes; the QA report has no failed, disabled, interrupted
or not-run cases. An earlier full selection stopped at `durable_backlog_reconsideration`:
the new candidate-cluster display and an occurrence's own promoted mention
were misread as changed identity evidence. `ragbacklog._reviewcontext` now
excludes those self-effects while retaining other candidate passages and
identity changes; the isolated reconsideration case and final gate pass.
The next gate exposed the intentionally changed resolution prompt/schema
golden. Its reviewed snapshot now records the new `dispositions` and
`insufficient-evidence` contract; extraction, answer and report are unchanged.
Full cohort restart/fencing, deterministic canonical survivor
enforcement, complete unscoped dry-run discovery and a single end-to-end
synthetic C0–C6 journey remain unqualified. Do not treat this as an installed
or remotely published convergence release.

## Public evidence byte bounding — 23 September 2026, targeted local checks

`ragevidencejson` remains the owner of whole-record evidence encoding and its
configured byte ceiling. `ragqueryservice` exposes the encoder's incomplete
state and omission counts in public command fields, without adding a second
budgeting rule to the CLI or MCP adapter. The answer route retains its refusal
when an oversized packet could separate a generated answer from its citation.
Fail-first component and public lexical/hybrid tests, retained positive controls,
and the deferred full-QA boundary are recorded in the
[delivery evidence](query-evidence-bounding-20260923.md).

## Configured provider selection — 22 September 2026

`ragquerypolicy` and `provider_contract` remove the duplicated non-public/hosted
veto. Maintenance, resolution, query and advisory callers retain their existing
owners; labels and charging remain metadata. No new policy layer or native
implementation is introduced. The public maintenance regression reproduces the
reported refusal, and shared-contract cases cover every supported source label.
[Requirement, baseline and qualification](provider-route-selection-20260922.md).

## rxvector consolidation — 19 September 2026

`ragembedding` and `ragretrieval` switch to CREXX's installed binary float32
owner. Publication/reactivation stays with `ragbackup`; visibility and distinct
parent ranking stay in `ragretrieval`. No product policy or SQL moves into C.
The installed-provider consumer and unchanged public ingestion, query preflight,
receipt, recovery and backup journeys are the acceptance surface.
[Qualification](rxvector-consolidation-20260919.md).

## Native vector integration — 18 September 2026, locally qualified

`ragembedding`, `ragbackup`, `ragretrieval` and `ragconfig` retain their existing ownership. A generic native provider adds no product policy. Shared binary publication supports both formats and verified reactivation. Both VMs passed the new 52-window/distinct-parent, removal, recovery, backup/restore fixture and the fail-first A/B/A regression, including changed-generation/revision rejection. `ragqueryservice` accepts native indexes in hybrid preflight, and `ragmaintain` recognises a clean native publication so it converges without repeated rebuilding; public ingestion/answer and maintenance-census assertions cover both fixes. The complete local gate accounts for 131/131 passing cases. [Acceptance and evidence](native-vector-delivery-20260918.md).


## Vector report correction — 18 September 2026, locally verified

`ragreportservice` remains the owner of the public report and its operational
digest. A shared projection distinguishes parent coverage, current window links
and published index rows for one representation. `ragobservationservice`
continues to consume the report fields; its publication ordering already agrees.
Narrative cache validation uses the same projection and existing dirty revision.
No command adapter, provider, schema or worker behavior changes. Fail-first
`ann_methodology` checks cover retained profiles and multiple windows with
empty/partial positive controls. Final targeted acceptance passed on both VMs
in 8.66 seconds; the preserved installation also reports correct complete
coverage and zero issues for the full 36,319-parent/36,328-window Scottish copy.
[Acceptance and qualification boundaries](scottish-bge-migration-20260918.md#completed-corpus-acceptance).

## Atomic embedding windows — 18 September 2026, locally qualified

`ragembeddinginput` now owns representation envelopes previously repeated by
worker, backlog, product and query composition. It also owns temporary window
splitting; the native adapter owns token admission, model/session lifetime and
the pinned BGE/engine identity. `ragworktypes` carries a complete list while
preserving singular construction for existing providers. `ragwork` retains
transaction ownership; `ragretrieval` retains scoring and bounded parent aggregation.
`ragstore` verifies uniqueness by parent/embedding ID, agreeing with existing
`ragembedding` reconciliation while allowing distinct windows in one profile.
No schema, task type, durable window state or CREXX implementation change.
Baseline and boundary regressions are recorded in the
[delivery evidence](windowed-embedding-delivery-20260918.md).

## Essential observability — 16 September 2026, locally qualified

Existing owners remain in place: application request serialization/redaction in
`ragapplicationprovider`, immutable intent/response capture in `ragreceipts`,
diagnostic settlement in `ragusage`, bounded operator reads in
`ragoperationsquery`, and job projection in `ragrepository`. `ragwork` forwards
the optional request capture to the receipt owner. Generic adapters retain
rejected text separately from validated provider content. Checkpoint and
claim-context timing belongs to `ragbacklog`; `ragtrace` handles database-independent
failed-lock output. No new dependency cycle, schema, prompt or retry policy.
The [delivery record](observability-delivery-20260916.md) maps original passing
controls, diagnostic failure reproductions and the 123-pass local qualification.
The bounded corpus-copy run is tracked there separately.

## Lease validation follow-up — 16 September 2026

`configuration_contract` covers typed/file lease bounds at 1, 86,400, 0 and
86,401 seconds, with a pre-repair failure only at the typed upper rejection.
The existing `ragworkerdefaults` owner now supplies lease bounds to
`ragconfig`, `ragconfigfile` and `ragwork` claims/heartbeats. No reverse import,
transaction, schema, prompt or canonical-identity change. Final acceptance and
artifact evidence: [bounded publication](baseline-publication-20260916.md).
Current backlog status: [master register](ROADMAP.md).


ISSUE-01 worker replenishment (15 September): ownership stays in
`ragsupervision` (eligibility/status), `ragprocess` (observed completion and
durable process finish), and `ragwork` (initialized claim on early error).
Unexpected exit classification no longer excludes replacement. The existing
writer-lock helper handles process-finish contention; no new retry setting or
supervisor is introduced. Regression-first evidence and QA are tracked in the
[repair checklist](worker-pool-repair-20260915.md).

Job controls (15 September): `ragbacklog` owns deadline-only mutation and
expired admitted-work completion; `ragcontinuation` owns their orchestration
and the reset transaction. `raglifecycle` now owns effective ordinary attempts,
paid item calls, maintenance-task calls and embedding-identity calls, with
explicit immutable count baselines. `ragwork`, `ragbacklog`,
`ragapplicationprovider` and `ragreceipts` consume those same counts. Repository
SQL omits every job plan body; `ragresultpages` consistently points to detail.
The [checked delivery record](job-controls-delivery-20260915.md) records red
baselines, new boundary coverage and final QA. No schema or native changes.

T7-10 controller closure: `ragprocess` owns a process-local shutdown flag and
composes its existing drain/finish path for TERM/INT/HUP. `ragtrace` owns narrow
best-effort operator writes, shared by CLI result, process and store diagnostics;
provider and corpus I/O handlers remain unchanged. No owner moves, schema,
configuration, protocol or timeout is added. Before product edits,
`regression_controller_closure` passed healthy/EOF controls and failed closed
outputs and catchable signals; `regression_controller_term` passed its live
held-response control and failed graceful drain/reason assertions. The
[T7-10 checklist](t7-10-controller-diagnosis-20260915.md) records final QA.
The targeted pair and repaired parent-exit controls pass; full QA is **75/76**
with only the separate, already-red PC-01 expired-window continuation case.

Test 7 T7-08: `ragapplicationprovider.reconcile` no longer applies the worker's
whole-configuration guard to inspection/settlement of an existing Codex turn.
Original provider identity remains checked; `ragreceipts.readexternalidentity`
reads the retained attempt ceiling through the existing indexed budget-policy
event and apply uses it instead of current configuration. Worker validation
retains its compatibility guard. `worker_recovery` first passed original-config
inspection and wrong-provider controls, then reproduced exit 6 after source,
budget and retry-setting changes (`test7-reconcile-baseline.log`). Added controls
cover unchanged observation digest/SQLite, retained ceiling, atomic rollback,
idempotence, usage, and refusal to run the old request under altered policy.
Final acceptance and installation status remain in the Test 7 checklist.

Test 7 T7-06: `ragoperationsquery.operatordiagnostics` owns the optional
`job.items` uncertainty filter, reusing `raglifecycle.uncertainitem` and the
existing status state split. The catalogue advertises `all`, `active` and
`held`; filtering precedes pagination and intersects state. The regression first
passed ordinary reads and live/held status, then failed on the missing option.
It selects two held outcomes beyond 100 ordinary failures and checks receipts,
active/held separation, job/state scope, continuation, empty jobs, strict
arguments, CLI/MCP parity and unchanged database. Final test/staging evidence
remains in the Test 7 checklist.

Test 7 agent guidance: `skills/crexxrag-maintain/SKILL.md` owns the common
long-job monitoring, model-selection and progress workflow. Ingest/diagnose
skills reference it; the reusable corpus template and Scottish instance files
record setup and continuity without adding per-item approval or monitoring
requirements. Agent integration documents source-scoped backlog and returned
review IDs with installed-version qualifications. Documentation contract and
all four changed skill validators pass; installed guidance copies match the
source. Runtime staging and live repair retests remain on the Test 7 checklist.

Test 7 T7-03/04/05: `ragimprove` preserves the existing validator's reason on
rejected external plans. `ragrepository` owns indexed exact source/review reads
through its existing projection; `ragproduct` routes instead of post-filtering
a list page. `ragoperationsquery` owns source-filtered task inspection and a
compact backlog summary in one read transaction, using current source/chunk
membership and the existing subject index. `regression_source_backlog` first
passes ordinary inspection then fails on the missing source option; it covers
undiscovered chunks, unrelated tasks before pagination, states, cursor, empty
and missing sources, CLI/MCP and independent zero-write/zero-call assertions.

Test 7 T7-02: `ragimprove.applyexternalproposalplan` now retains review IDs
already returned by `ragclaims`; public `proposal.apply` emits one paired
`proposal-review` result per proposal after its existing summary. This adds no
query or identity rule. `gemini_maintenance` first confirms the stored external
review independently, then fails on the baseline's missing returned ID; repaired
acceptance uses the returned ID for the ordinary decision/publication journey.

Test 7 T7-01: source include matching belongs in `ragfolder`. The existing
`ragproduct` plan/apply callers now forward validated include patterns; no
adapter filtering, SQL, schema or configuration format is added. The new
`regression_folder_include` public journey first passes unrestricted discovery
and apply with zero provider calls, then reproduces exact-filename selection
returning six files instead of one against the pre-fix native artifact. It also
covers root/nested wildcards, zero-directory `**`, alternative/overlapping
patterns, case sensitivity, unsupported files and apply's independent stored
membership. [Test 7](test7-overnight-soak-20260914.md) records final qualification.

Test 5 follow-ups: `ragconfig.querypassagemaximum` supplies the shared 200-passage
ceiling to file/typed validation, core retrieval, public query execution and
MCP schema construction. The catalogue gains only that configuration dependency;
it remains independent of dispatcher/repository services. `ragqueryservice`
keeps vector preparation inside non-lexical routing. Shared QA guidance owns
routine status/inventory and broad agent-side evidence filtering. The default
12, canonical identity bytes, candidate/byte policies and hybrid controls remain.
The [Test 5 workplan](test5-mcp-qa.md) retains regression-first evidence, actual
200-passage/citation acceptance and final qualification status.

Test 4 replay repair: the whole-snapshot veto moves from `ragwork` to the
existing `ragconfiguration` owner, using one field projection in `ragcanonical`
for current configuration identities and selected frozen work. Source/role
selection excludes unrelated configuration entries; original identity hashes
and replay history remain unchanged. Regression-first and final qualification
are tracked in the [Test 4 checklist](test4-repair-delivery-20260914.md).

Current Test 2 follow-up: [action checklist](test2-recovery-delivery-20260914.md).
The existing provider, publication, store and retrieval owners now implement
independent item/search availability and ordinary completion retry. Qualification
is complete: focused 5/5, live Test 2 pass, and all 71 local checks pass after
the reviewed metadata-fixture correction. The checklist retains exact results.

This implements the five opportunities in the
[12 September ownership review](maintenance-refactoring-review-20260912.md),
starting at `1ebee11`. Each stage confirms coverage before product edits,
extends missing tests, passes the complete local regression workflow, updates
the user and architecture documentation, and is committed separately.

The approved follow-ups retain these owners: UX-03 connection previews and
UX-04 targeted workflow closure each passed a full 59/59 gate. The third
[public recovery slice](public-recovery-journey.md) extends lifecycle and query
owners with waiver/reopen and consistent observations. Its final full gate passed **59/59 in 1238.52 seconds**; the frozen installed replay also passed.

## Shared-rule simplification — 13 September 2026

The user approved removing unnecessary checks and searching for duplicates.
The [repair record](rule-simplification-repair-20260913.md) tracks this follow-up.
`ragconfiguration` now records future policy without a global execution veto;
continuation composes that owner. `raglifecycle` owns completion precedence,
explicit-redo eligibility, replay-family decisions and active claim ownership.
Work, receipt, maintenance and legacy claimed-proposal consumers delegate to it.
Inner publication helpers no longer recheck ownership in the same writer
transaction, and missing historical receipts no longer veto vector publication.
No schema, provider transport or new orchestration framework was added.

## Instruction audit — 12 September 2026

The post-recovery audit found stale review-preview and pagination guidance,
incomplete resolution/diagnostic recovery instructions, and five resolution
skill tools missing from its manifest. The existing documentation check passed;
a new cross-check of every skill's prose, manifest and the canonical command
catalogue reproduced the omission before the instruction fixes. It now also
checks required access and write capabilities. This is a consistency check,
not proof that an independent agent completes every workflow.

Human and agent instructions now agree on current effects, workflow discovery,
reconciliation, operational waiver/retry, progress/usage and capability boundaries.
All five distributable skills were audited. `documentation_contract` and
`installed_product` passed **2/2 in 110.83 seconds**. The scratch installation's
11 skill files and human/agent/recovery guides matched their sources exactly;
the native binary retained the public recovery gate's SHA-256. Product code and
MCP schemas were unchanged, so the earlier 59/59 product gate remains the code
baseline. `git diff --check` and relative document-target checks passed.
Existing installed or copied workspace skills require a separate update; a
source commit does not activate them in an already-running MCP client.

## Scope and operator interface

`crexxrag.conf` remains the single operator policy entry point. Referenced
profiles and optional prompt files are data selected by that policy, not
competing policies. Step 5 supplies supported file editing/replacement commands
alongside the existing reviewed library configuration transition. File changes
must validate before replacement and must not silently change active jobs.

The service and command stages also address bounded operator queries currently
requiring SQL, using existing storage owners and the same CLI/JSON/ADDRESS/MCP
vocabulary. No arbitrary SQL endpoint is planned. Recovery history, access
control, original evidence and provider usage remain authoritative.

| Stage | Owner and intended outcome | Status |
| --- | --- | --- |
| 1 | `ragclaimrules`: one effective claim-policy factory | Committed `b038495`; 51/51 full regression tests |
| 2 | Domain prompt/contracts: complete effective requests and schemas together | Committed `f62158f`; 53/53 full regression tests |
| 3 | Report, observation and query services: cohesive domain orchestration and bounded operator inspection | Committed `e792f1d`; 54/54 full regression tests |
| 4 | Command catalogue: one operation/argument/capability definition used by surfaces | Committed `14677d1`; 57/57 full regression tests |
| 5 | Effective configuration policy and safe policy-file update/replacement commands | Complete; 59/59 full regression tests |

## Stage 1 — claim policy

Baseline `1ebee11`: the new `regression_claim_policy` characterization and
existing `gemini_ingestion`, `gemini_extraction_validation`,
`gemini_maintenance` and `quotation_grounding` passed **5/5 in 23.06 seconds**
before product changes. The new scenario checks profile isolation, exact
vocabulary tokens, profile versions, explicit external version overrides and
every stance weight on both VMs. Existing ingestion and external-review routes
cover validation, promotion, rejected output and original source grounding.

`ragclaimrules.effectiveclaimpolicy` now constructs the policy for workers,
proposal planning/apply and review acceptance. `ragproposalio.profileclaimpolicy`
is a compatibility delegate. `ragclaims` still owns typed policy semantics,
validation and graph publication; it does not import the factory. There is no
new configurable weight or policy file, and no transaction or schema change.
The post-change scenario also exercises the shared factory directly.

The complete `cmake --workflow --preset regression` passed **51/51 in
706.70 seconds**. Native SHA-256:
`8b7d3d096c62f963c89982ee585c618089feaaf0f674b4f6237dde89a2cba505`.
Evidence: `/tmp/crexx-rag-refactor-1-baseline.log`,
`/tmp/crexx-rag-refactor-1-build.log` and
`/tmp/crexx-rag-refactor-1-full.log`. The new factory body is identical to the
baseline after renaming; namespace inspection found no cross-module production
import cycle. The ADDRESS adapter's extension of installed `_rxsysb` is not a
product dependency cycle. Final documentation and whitespace checks pass.
No hosted calls, user-library changes or global installation were used.

## Stage 2 — prompts and response contracts

Before product edits, captured actual Gemini fixture request bodies from
ingestion, query/report generation and maintenance resolution with a correction.
The new `regression_prompt_contract` retains four independently captured system
prompt/schema hash pairs, checks correction message order and runs the existing
end-to-end assertions. It and `local_embedding_protocol`/`temporal_provenance`
passed **3/3 in 57.53 seconds** against the stage 1 artifact. The separate
`regression_prompt_inspection` first passed its configuration control and then
failed because `config prompt` did not exist. Captures exclude HTTP headers;
fixtures contain synthetic data and credentials only.

Domain owners now construct the complete message lists and response schemas.
`ragquotationcontract` owns shared quotation instructions and bounded correction
feedback; `ragresolutioncontract` also owns the action vocabulary used by both
its schema and `ragbacklog` validation. `ragpromptdefaults` owns compatibility
role objectives. Execution, preflight, retained responses and settlement stay
in their existing owners. Configured objectives remain editable data.

`config prompt --role extractor|resolution|answerer|advisory` and
`rag_config_prompt` expose the configured objective, effective system text,
schema and hashes without library access or calls. Resolution inspection shows
the union schema; task inspection still supplies its narrower applicable
schema. Inspection states where per-request source context, correction history
and optional provenance contracts are added. The two-VM scenario exercises
direct builders, optional assessment, subject/workflow action restrictions,
typed dispatch, MCP, access denial and unknown arguments.

Contract versions identify the extracted builders for inspection. This
behavior-preserving stage retains all existing configuration, work and replay
identities; it does not introduce an identity migration. A future behavioral
contract change must review its effective identity and retained-work semantics,
not merely change the inspection version or update a golden file.

The inspection regression exposed an MCP transport defect: it always passed an
empty `--library` even for library-independent operations. The adapter now omits
that argument when no library is bound; library-requiring commands still fail
normal parsing. Native inspection passed before this MCP correction.

The captured ingestion journey also exposed a timing assumption in the
post-registration child-death fixture under concurrent machine load. Its fixed
one-second sleep could kill a child before registration. The fixture now waits
for that specific child and its controller to acknowledge registration before
killing it, and fails separately if this precondition is never reached. The
production supervision implementation is unchanged.

The final `cmake --workflow --preset regression` passed **53/53 in 733.58
seconds**. Native SHA-256:
`d68a356a37ebc4451661a55de2490fb411d137d4b84197e1b02c0bf39b799d5d`.
The corrected inspection test passed on native CLI and both VMs; the stable
artifact request/recovery rerun passed **2/2 in 111.26 seconds**. Evidence:
`/tmp/crexx-rag-refactor-2-baseline.log`,
`/tmp/crexx-rag-refactor-2-inspection-red.log`,
`/tmp/crexx-rag-refactor-2-inspection2.log`,
`/tmp/crexx-rag-refactor-2-focused2.log` and
`/tmp/crexx-rag-refactor-2-full.log`. An earlier mixed build/test run was invalid
because packaging briefly replaced the running test's executable; it is not
qualification evidence. The final gate ran serially without concurrent builds.

Self-review found no blocking issue. The four captured request contracts remain
identical, all 65 production namespaces have no cross-module import cycle,
documentation links resolve, and staged whitespace checks pass. This is local
qualification using synthetic providers and scratch libraries/installations;
no live hosted calls or global installation were performed.

## Stage 3 — domain services and operator diagnosis

Coverage first: the stage 2 full gate on `f62158f` passed all 53 tests, including
`gemini_query`, `query_policy`, `native_surfaces`, `address_surface` and the
scratch-installed product. Those journeys exercise cached/refresh reports,
rejected narrative citations, immutable observations, query privacy, failed-call
usage and retained responses. Before product edits, the new
`regression_operator_diagnostics` passed fixture initialization and the existing
job-status control, then failed on the missing `job items` operation (0.55 s).
It uses only a scratch library with foreign-key-checked synthetic rows.

`ragreportservice` owns report assembly, narrative validation and report-cache
SQL. `ragobservationservice` owns observation capture and trend SQL and composes
the report service directly. `ragqueryservice` owns query/citation orchestration
and answer validation; retrieval algorithms remain in `ragretrieval`/`ragquery`.
`ragdirectcalls` owns existing direct-call accounting and usage projection.
Argument/access/error helpers have one `ragcommandutil` owner; small SQLite
scalar/error helpers are in `ragsqlsupport`. Role lookup is in `ragconfig`,
snapshot matching in `ragconfiguration`, query privacy in `ragquerypolicy`, and
citation-array operations in `ragevidencejson`. None imports the dispatcher.
An independent normalized comparison found all 49 moved function bodies
unchanged apart from names; the task-page extension is reviewed separately.

`ragoperationsquery` owns bounded read-only job status/events/plans/items,
attempts, task pages/evidence inventory and workflow inventory. `job items` and `job attempts` expose durable state and
provider-run references without raw request/response bodies. Task/workflow
queries accept exact subject IDs or exact canonical concept labels; name
matches preserve homonymous concepts and workflow successors. Filters are
applied before pagination. CLI and MCP share the service, while schema/state
transitions stay with existing storage and lifecycle owners.

The first diagnostic run passed job-item/attempt pagination and task filters,
then exposed the separate CLI shorthand list's missing `workflows` verb. A
further pre-fix negative reproduced a previously ignored two-positional-ID
error in task listings: option reads cleared the error and returned an
unfiltered list. The shorthand registration is corrected; task inspection now
rejects that error immediately. NUL filters are rejected before SQL. Exact
provider/CLI role lookup copies now consume `ragconfig` as well.

The new diagnostic regression checks maximum-size pages and continuations,
job/item/subject ownership, intersecting filters, missing versus empty jobs,
quoted and Unicode labels, homonyms, invalid arguments, CLI/MCP equivalence and
an identical complete database dump before/after reads. The six focused tests
passed in 54.70 seconds, then the complete `cmake --workflow --preset regression`
passed **54/54 in 785.99 seconds**. Native SHA-256:
`4242955df2d37391ca4e40f853acd4c9863f1dd6e31baa2180bd4c4995f9cbe9`.
Evidence: `/tmp/crexx-rag-refactor-3-red.log`,
`/tmp/crexx-rag-refactor-3-arguments-red.log`,
`/tmp/crexx-rag-refactor-3-focused.log` and
`/tmp/crexx-rag-refactor-3-full.log`. Self-review found no blocking issue;
all 72 production namespaces have no cross-module import cycle, documentation
links resolve, and whitespace checks pass. This is local qualification with
synthetic providers and scratch libraries/installations. This interface work
does not close the broader operational recovery or external-retirement outcomes.


## Stage 4 — command catalogue

Coverage first: stage 3 `e792f1d` passed the full 54-test gate. Before product
edits, `regression_command_metadata` captured and froze the advertised schemas,
required fields, descriptions and annotations for 32 read tools and all 63
tools; it passed in 0.36 seconds. The new argument journey initialized its
scratch library and passed a no-call maintenance-plan control, then reproduced
the advertised `embeddings_only` boolean being rejected as a non-string
(0.55 seconds). `reconcile` had the same separate-validator discrepancy.

`ragcommandcatalog` declares each tool's canonical operation, input schema,
capability, library requirement, positional mapping, fixed flags, description
and annotations together. MCP derives tool metadata, required/type/enum/bounds
validation and argument forwarding from those entries. CLI and ADDRESS parse
the same canonical operation list; CLI shorthand recognition and default-library
selection use it too. CLI-only operations are explicitly marked in the same
catalogue. Capability inheritance has one implementation used by MCP and the
product/foundation access helpers. Domain services retain state-dependent
validation and enforce access when invoked directly.

Boolean false omits an enabling flag; true enables it. Declared argument bounds
are now rejected at the MCP invalid-parameters boundary instead of being passed
to product usage validation. Forwarded option values use inline assignments,
and positional values follow `--`, so caller text resembling an option remains
data. No operation gains authority and no library or provider is opened by
catalogue inspection. The first focused run caught an empty-string corner in
oneOf matching: alternatives must count supplied fields independently of their
nonempty-value validation. That regression now passes. The two-VM fixture also
needed explicit clearing before reusing an argument array.

Under concurrent machine load, the existing native surface fixture expired its
ten-second idle interval while seven provider-free numeric checks ran between
its ingestion and answering requests. Alternating the exact stage 3 binary and
stage 4 `config check` five times gave medians 0.349 and 0.354 seconds; this
comparison does not show a material startup regression in that route. The
surface rerun and corrected two-VM scenario passed 2/2 in 14.52 seconds. The
numeric checks now run after the live provider interval; no timeout or assertion
was weakened. Source review removed two unused copies of the old capability
helper left behind by extraction; only the catalogue now implements inheritance.
The partial gate was stopped and rerun against that cleaned source.

The final `cmake --workflow --preset regression` passed **57/57 in 715.52
seconds**, with no rebuild needed. Native SHA-256:
`053ea92ab4e9ef26ff25e1fc24fdb503d077ae168eb2c4f722b349fbbde76771`.
Evidence: `/tmp/crexx-rag-refactor-4-baseline.log`,
`/tmp/crexx-rag-refactor-4-red.log`,
`/tmp/crexx-rag-refactor-4-focused1.log`,
`/tmp/crexx-rag-refactor-4-focused3.log`,
`/tmp/crexx-rag-refactor-4-timing-before.txt` and
`/tmp/crexx-rag-refactor-4-full.log`. The earlier interrupted gate is retained
separately and is not qualification evidence. Advertised metadata is unchanged;
empty grants now correctly advertise no tools. Source review found no remaining
parallel capability implementation or cross-module import cycle, and changed
documentation links and whitespace checks pass. The optional full-volume
harness also has the updated module dependency; no unrequested corpus was used.
This is local qualification with synthetic providers and scratch installations.


## Stage 5 — worker defaults and policy-file administration

Coverage first: stage 4 `14677d1` passed 57/57. Before product edits, the extended
`configuration_contract` passed in 29.37 seconds. It compares omitted versus
explicit compatibility defaults, exact canonical identity, typed lower/upper
bounds and invalid neighbors, and semantic versus operational identity. An
initial test compared different config formats and was corrected before the
passing baseline; it was not a product defect. New native and two-VM file tests
passed the existing config-check control, then failed on absent file operations.
An additional parser control reproduced an explicit `true` value incorrectly
marked as a bare flag. That distinction is now fixed in `ragcommand`.

`ragworkerdefaults` owns the five optional worker runtime/recovery defaults and
bounds, consumed by typed construction/validation, file loading/key recognition
and canonical omission. Explicit default bytes and historical identities are
preserved. The other setting families and schema invariants retain their
existing owners; this is the first bounded family from the original proposal.
`ragpolicyfile` owns selected-file commands and validation; `ragpolicypublication`
owns file bytes, edit coordination and publication. It depends only on file,
hash, SQLite and scalar helpers, not worker orchestration. CLI and MCP use the
same loader, and the catalogue declares the three new operations together.

Read `config show` exposes path, SHA-256, existence and validation state. Admin
`config set` edits one key and removes a competing role prompt-source key;
`config replace` validates a replacement or repairs a bounded invalid policy.
`missing` is the explicit bootstrap token. Validation includes referenced profiles
and prompts, resolved relative to the destination policy. Both operations require
the inspected hash, preserve library history and make no provider calls.
A file-bound MCP server reloads configuration and profiles on subsequent product
calls, sees its own edits, can expose repair commands from an invalid starting
file, and refuses a removed profile instead of reusing a stale registry.

Publication holds an exclusive SQLite lock in a stable adjacent coordination
file. It verifies staged bytes and rechecks the target before rename, reports
conflict for another editor, and retains the new hash if post-publication cleanup
fails. Killed-owner locks release without manual recovery, and orphan temporary
files never become policy or block a retry. This is process-crash recovery with
rename publication; custom mode/ACL preservation, arbitrary external-writer
coordination and power-loss durability are explicitly limited by the installed
filesystem API. See the [integration record](integration-issues.md#policy-file-publication-metadata-and-durability).
The subsequent 12 September decision accepts custom metadata and policy-file
power-loss limits outside active defect work, including manual policy restoration
after power loss. It retains ordinary process-crash recovery and all library,
receipt and usage protections; this disposition does not change stage 5 QA.

The first focused run passed six tests; its sole failure was the intentionally
changed metadata snapshot. An independent JSON comparison found precisely one
new read tool and two admin tools, no removals, unchanged old schemas/annotations,
and only a clarified `config apply` description among the original 63 tools.
The reviewed snapshot now records 33 read tools and 66 tools with all grants.
The native policy fixture covers invalid/stale input, no-op bytes, literal true,
prompt switches, destination-relative replacement, repair, MCP freshness, actual
cross-process lock conflict/SIGKILL recovery, orphan staging, publication I/O
failure and an identical complete library dump. Both VMs exercise the same
service directly. The scratch-installed test edits a copy of the shipped
policy/profile/prompt cohort and inspects the resulting effective objective.

Baseline and focused evidence: `/tmp/crexx-rag-refactor-5-baseline2.log`,
`/tmp/crexx-rag-refactor-5-red.log`, `/tmp/crexx-rag-refactor-5-true-red.log`,
`/tmp/crexx-rag-refactor-5-focused1.log`, and
`/tmp/crexx-rag-refactor-5-focused2.log`. The revised focused gate passed
**5/5 in 52.71 seconds**, including the installed round trip. The first full run completed **56/59 in 1,445.68 seconds**. It retained three
failures: the backlog fixture exited after ten idle seconds before a call at
about eleven seconds; heartbeat contention exceeded its 30-second harness
limit; and concurrent publication missed its second pair after HTTP timeouts.
Heavy independent compiler/test activity was observed at the time. Failed
fixtures and logs are retained under `/tmp/crexx-rag-refactor-5-failed-fixtures`
and `/tmp/crexx-rag-refactor-5-full.log`; this run is not a green qualification.

Further surface review found that ADDRESS kept the registry from `LIBRARY OPEN`.
The extended `address_surface` scenario passed its existing controls and the
policy edit, then reproduced a stale prompt in 4.06 seconds before the fix
(`/tmp/crexx-rag-refactor-5-address-red2.log`). MCP and ADDRESS now share
`ragpolicyfile.refreshpolicyrequest`; both ADDRESS execution and its function
interface compose it. The regression also covers invalid-file refusal, unbound
function repair, config-ID changes and removed profiles. A fixture-only direct
class construction was corrected before this reproduction. The focused replay
passed **6/6 in 93.45 seconds**, including ADDRESS, policy editing and all three
previously timed-out cases, with unchanged assertions and timeouts
(`/tmp/crexx-rag-refactor-5-focused3.log`).

The final `cmake --workflow --preset regression` passed **59/59 in 737.26
seconds**, with no rebuild needed. All three original result/Unicode defects
and the three earlier timing failures pass in this full run. Native and
scratch-installed SHA-256 both equal
`7e03aa31f86ce170086538dfc4b7be001fd3047c004498da8067e1bee91fb330`;
linked application SHA-256 is
`42e7307a5f90c8910cf1e1d6682dc9678be0212b019c8a95547e217130a768b6`.
Evidence: `/tmp/crexx-rag-refactor-5-build3.log`,
`/tmp/crexx-rag-refactor-5-full-final.log` and
`/tmp/crexx-rag-refactor-5-review.txt`. Final source review found no blocking
issue or cross-module import cycle; changed documentation links/anchors and
whitespace checks pass. This is local qualification with synthetic providers
and scratch libraries/installations. No timeout or assertion was weakened to
obtain the final green gate; the earlier failed run remains recorded.


## Maintenance assessment after the five changes

The demonstrated improvement is ownership: claim policy, domain prompt/schema
assembly, report/query/observation orchestration, command metadata/access and
worker runtime defaults each have a named source owner and boundary tests.
The dispatcher is now 1,925 lines versus 3,351 at the review baseline;
`ragmcp` delegates catalogue and policy work. These counts help
navigation; they do not measure reliability. `ragproduct` and `ragprocess` still
contain substantial orchestration, and the other default families have not all
been consolidated. Further extraction should follow a concrete change or failure,
with the same test-first discipline, rather than a target file size.

There is no measured long-term regression-rate comparison yet. Tests exposed
real interface drift during this work: missing shorthand registration, ignored
positional errors, advertised boolean arguments rejected by a separate map and
an explicit true value misclassified as a flag. The new owners remove those
specific duplication paths and the regressions preserve their acceptances.
Unresolved operational P1 outcomes, comprehensive recovery/renewal journeys,
long-run/hosted/platform qualification and retrieval-quality evaluation remain
tracked in the [roadmap](ROADMAP.md). Separate executables are not required for
these ownership improvements. The future native model bridge remains a CREXX
provider responsibility behind the existing product boundary.

## Follow-up — UX-04 external workflow reconciliation

`ragbacklog` now supplies a shared per-workflow census for ordinary maintenance
and the public targeted reconciliation command. `raglifecycle` retains unknown
outcome classification; `ragmaintain` owns shared workflow holds, readiness and
atomic graph/workflow retirement for every publisher. CLI/MCP
contracts live only in `ragcommandcatalog`, with service presentation in
`ragproduct`. The clean full gate passed **59/59 in 805.49 seconds**, including
the retained preparation-delay regression for the repaired shared test fixture.
See [test-first evidence and qualification](external-workflow-recovery.md).

## Follow-up — UX-03 connection effect previews

The approved sequence starts with trustworthy previews, then external lifecycle
completion (UX-04/OPS-002), then the combined public recovery journey.
`ragmaintain` owns connection effects and shared publication checks;
`ragbacklog` owns task/response binding and one acceptance validator;
`ragproduct` owns command snapshots; `ragcommandutil` owns bounded presentation.
The new tests preceded each repair. Full local QA passed **59/59 in 758.92
seconds**; no import cycle was introduced. See [the detailed qualification](connection-effect-previews.md).

## Complete operator continuation follow-up — 12 September

The [operator continuation delivery](operator-continuation.md) composes existing
owners. `ragallowance` owns effective cumulative allowances and immutable named
period history. `ragcontinuation` coordinates compatible configuration,
drained ownership, the existing window/job transitions and retry reconsideration.
The public adapter only parses/selects the operation and uses the existing
configured process supervisor.

`ragbacklog` now exposes one retry-facts decision for both inspection and
execution, including current reviewed attempt ceilings and explicit embedding
precedence. `ragoperationsquery` owns bounded source/operation progress and
item recovery explanations; `ragsupervision` reads configured/runtime worker
facts using `ragworkerdefaults`. `ragusage` retains usage/accounting ownership.
Schema 16 adds recovery lookup/period indexes and immutable period triggers;
earlier migrations remain unchanged. Both VM module cohorts and native
packaging include the new owners.

The [coverage matrix](regression-coverage.md#complete-operator-continuation-follow-up--12-september)
records the tests added before repairs and the missed historic cases. The
[handoff](operator-continuation-handoff.md) is the authoritative in-flight
QA/commit/live-run checkpoint. Original plans, task attempts, receipts,
reservations and usage are not rewritten to create a completion claim.

Full qualification exposed an additional startup race before worker replacement:
concurrent WAL acquisition could return SQLITE_BUSY immediately despite the
configured busy timeout. The deterministic two-VM regression precedes the fix.
`ragstore` now owns one bounded lock-acquisition helper for both journal startup
and transaction admission; no transaction body or provider work is retried.

Qualification checkpoint 2026-09-12 21:54 UTC: build 7 passed the full **63/63** suite
in **848.41 seconds**, plus the scratch-installed continuation/held journey.
The isolated full-corpus copy rehearsal reconciled both interrupted turns
without generation calls; provider-run count stayed 20809 and uncertainty
became zero. Incomplete usage remains a lower bound. The exact hashes and
logs are in the [handoff](operator-continuation-handoff.md). Actual processing
master ingestion and 60-minute maintenance are still required live evidence.

## Live maintenance checkpoint repair — RAG-SMK-003

The first 60-minute Scottish maintenance attempt stopped after sustained writer
contention; it is a failed smoke, not completed maintenance. Corpus-copy profiling
measured 27.28 seconds in census/evidence construction, 28.18 seconds selecting
dispatch candidates and 27.40 seconds counting remaining eligible questions.
The common review predicate repeatedly scanned the entire review table per task.
An isolated public-predicate SQL measurement was 28.56 seconds; a temporary
subject/state index reduced it to 0.00365 seconds. All diagnostic copy writes
were rolled back and made no provider calls.

The owning repair is one additive `ragschema` migration, version 17, installing
`reviews_subject_state`. `ragbacklog` retains task dispatch and transaction
ownership; `ragmaintain` retains lifecycle readiness. Review, attempt, policy,
receipt and usage semantics do not change. Schema-16 upgrades retain pending
review identity/content. Fresh and upgraded scale regressions failed before
the implementation. Full QA and the replacement live smoke remain required.

Schema-17 repair qualification: full **63/63 in 847.44 seconds**. The new
scale/fresh/upgrade controls pass alongside worker, provider, publication and
installed-product regressions. Actual replacement maintenance smoke remains
required; see the [handoff](operator-continuation-handoff.md).


## Four smoke/restart repairs — 13 September 2026

The [repair record](four-smoke-fixes-20260913.md) records the pre-change failures,
new boundary coverage, source ownership and current gate. `raglifecycle` now
shares read projection and active/error totals across job pages and both report
paths. `ragsupervision` supplies shared process-presence/claim-admission facts;
`ragprocess` owns selected-group drain/cleanup and fresh launch; `ragwork` checks
the managed worker's original controller under the claim writer lock. These
interfaces preserve transaction ownership and avoid an import cycle or a new
schema. Public commands compose the existing services. No provider/prompt,
retry-policy or live-library change is included in this delivery.

The final candidate passes **67/67 in 932.92 seconds** and a separate
**5/5** scratch-installed replay on the matching native hash. The record retains
the regression-first failures and exact source/artifact evidence.

## Automatic vector publication — RAG-SMK-006

The [repair record](smk006-publication-repair-20260913.md) documents the failing
partial-ancestral-index reproduction, passing controls and exact artifacts.
Manifest alignment now belongs to `ragembedding.buildannvectorgeneration` for
both new and replayed indexes, using the existing transactional store recovery.
The command-specific and replay-only copies are removed. No dependency, provider
contract, schema, receipt or worker-fencing change is introduced. Focused QA
passes 5/5; full QA passes 68/68 in 944.08s, and the matching
scratch-installed publication/fault/history replay passes.


## SQL review implementation — 13 September 2026

The [SQL repair checklist](sql-performance-delivery-20260913.md) tracks the
implementation and acceptance independently. `ragclaims` now composes
`raglifecycle` for job completion and owns the shared chunk-rank projection;
`ragimprove` consumes it and retains context only for selected work.
`ragbacklog` owns the automatic preview/activation distinction and bounded
census. `ragusage` owns grouped job usage. `ragreportservice` owns grouped
operational projections; `ragstore` owns complete FTS parity, reused by
repository verification only in the same read snapshot. `ragsqlsupport`
provides numeric-row decoding without taking transaction or domain ownership.
The original 69-test baseline passed in 943.87 seconds. Final focused QA passes
4/4 in 25.51 seconds and the complete suite passes **70/70 in 919.24 seconds**.
The new SQL regression covers stronger shared-content occurrences, complete
FTS parity, row-decoding cleanup and workflow cursor progress across publication.
The final native corpus plan/apply takes 0.204/0.625 seconds for eight items,
with no provider calls; full report semantics match the installed baseline.
See the checklist's retained evidence for exact source and executable hashes.

## Unchanged index retry — 14 September

Schema 19 owns invalidation; `ragembedding` owns rebuild completion;
`ragstore.currentvectorpredicate` supplies the shared maintenance census and
completion rule. See [A8](test2-recovery-delivery-20260914.md) for acceptance.

## Scottish acceptance repairs — 14 September

Existing owners remain: `raglifecycle` projects incomplete embedding outcomes,
`ragbacklog` supplies run status/inspection, and `ragadmission` owns the monetary
route decision used by backlog selection and worker reservation. No new state or
orchestration layer. See the [repair checklist](acceptance-repairs-20260914.md).

## T7-07 source selection, 14–15 September 2026

The confirmed source starvation had two causes: lexicographic whole-corpus
census pages only advanced after busy dispatch waves, and retained old catalogue
tasks ranked above extraction. The bounded repair adds source selection to
ordinary durable windows; it does not alter priorities or add scheduling.
`ragrepository.currentsourcechunks` is shared by task inspection and backlog
selection. `ragbacklog` owns scope before census bounds, dispatch, retry facts,
closure and source-local summary. Plan/apply freeze selection in operational
window policy without changing knowledge/task identity. CLI and MCP compose it.

Regression-first `regression_source_maintenance` passed the unscoped high-ranked
work positive control, then failed on the baseline binary
`74ac6bbc5629f2710e380d741d2f173ab0092d5fc43a2abddc4173c1190f22f4`
with exit 2, `unknown option --source`. After repair, the focused set passed
6/6 in 38.89 seconds: `regression_source_maintenance` (8.17s),
`regression_source_backlog` (2.06s), `regression_command_arguments` (8.19s),
`documentation_contract` (0.25s), `durable_backlog` (16.81s) and
`regression_sql_performance` (3.41s). The backlog scenario now characterizes
source continuation retaining exact policy, deadline and item allowance without
widening or calls. Final native SHA-256 is
`eb74de625d11fbb2f5416385a0c3e7a43dbe48885734e5198d2486e202747fcc`.
Combined full suite passed 74/74 in 1045.12 seconds (session 43642); the tested
artifact was installed at 00:54 BST after Boswell drained. Fresh installed CLI
status passed at schema 19/generation 24641. Live source-window qualification
remains in the Test 7 checklist.

## Task reset (15 September)

The bounded reset remains in `ragbacklog`, with current evidence/policy and
existing successor handling. `raglifecycle` shares effective retry baselines
with job reset through an optional task selector; catalogue/dispatcher changes
expose one CLI/MCP operation. No new module, schema, recovery protocol or
window reconstruction. External resolution/refresh no longer depends on a
historical window; normal validators/review remain. Baseline and acceptance
are tracked in [the task-reset checklist](task-reset-delivery-20260915.md).

Task-reset final QA: 80 enabled checks passed across the complete run and the
new-tool metadata snapshot's targeted correction; one user-approved CREXX #701
test remains disabled. The prior command-contract hash is reproduced exactly
by removing only `rag_task_reset`. No schema or additional recovery framework.

## MCP session stop — original batch (15 September)

`ragcommandcatalog` owns `rag_mcp_stop`/`mcp.stop`; `ragmcp` owns a local stop flag
and standard response, and the CLI stream owner exits only after writing it.
Current stateless dispatcher signatures remain compatible; non-MCP execution
returns an explicit usage error. No domain/policy/SQL decision moved into the
adapter. `native_surfaces` now contains closure/reconnect, invalid-argument and
missing-policy cases with an unchanged-database assertion. The original build/test deferral and its subsequent release by approval are
recorded in [the batch checklist](batch-changes-20260915.md); current combined
qualification is in the [delivery record](maintenance-escalation-delivery-20260916.md).

## Approved maintenance escalation routing (16 September 2026)

The [delivery record](maintenance-escalation-delivery-20260916.md) tracks the
regression-first evidence and final combined gate. `ragbacklog` retains one
eligibility/order/outcome implementation for worker dispatch, queue inspection,
external plans and reviews. Search composes existing `ragretrieval` and
`ragevidence`; source identity remains validated by the citation and claim
owners. Configuration and prompt/schema owners retain their established split.
The public queue/defer operations live in `ragcommandcatalog` and delegate to
that owner. No database migration, provider implementation or alternate runner
is introduced. Explicit extraction is a resolver action using the existing
work-item type and claim pipeline, not a new task family.

## Resolution prompt and selected-quotation repair (17 September 2026)

The [bounded delivery record](prompt-grounding-delivery-20260917.md) records
the regression-first failures, controls and final QA. `ragresolutioncontract`
now owns initial and citation-correction route outcomes together, with explicit
reuse/no-change field examples and selected-source context. The generic
quotation owner retains extraction correction as its default. Provider
composition selects the domain builder; no route rule is duplicated there.
`raggrounding` adds overlap-constrained matching, consumed by the existing
`ragbacklog` validator for both provider and external proposals. Its previous
unscoped and contained-scope API remains unchanged. No schema, transaction,
scheduler or recovery owner moved.

## Approved maintenance follow-up — 17 September 2026

Ownership remains unchanged. `ragworkerdefaults` now supplies the explicit
24 ceiling to both `ragsupervision` and the `ragprocess` controller; canonical
omission still means two. `ragbacklog` owns the read-only active-batch guard and
active-only alias packet projection; `ragwork` handles only pre-claim BUSY
scheduling. `ragapplicationprovider` retains original transport failure through
exact-turn reconciliation and measures the provider step. `ragoperationsquery`
projects bounded event previews, retained references, failure categories and
separate timing/usage facts. `ragresolutioncontract` and `ragquotationcontract`
share their examples across initial/correction consumers. No schema or new
public operation is introduced. Regression-first evidence and qualification
status are in [the delivery record](maintenance-follow-up-delivery-20260917.md).

## Maintenance reference and quotation boundary (17 September 2026)

The new `ragresolutionreferences` domain module owns frozen short-reference
projection and expansion. `ragresolutioncontract` composes it for model messages;
`ragapplicationprovider` composes it for retained request mapping and expansion
before canonical validation, including recovered responses. `ragbacklog` keeps
eligibility, lifecycle, source validation and application ownership. The quotation
owner adds specific feedback; the existing grounding owner adds only a one-pass
exact newline fallback after normal overlap matching. No policy/SQL moved into
adapters and no transaction, schema or recovery ownership changed. The
[seven-criterion delivery record](resolution-references-delivery-20260917.md)
links regression-first evidence and qualification, including canonical validation
and native retained-response recovery at the new boundary.

## Advanced-call correlation repair (17 September 2026)

`ragbacklog._routecallcount` retains ownership of the route-count projection.
Its inner task lookup now uses a distinct alias, preserving correlation when
selection and reconciliation pass an outer task expression. `raglifecycle`
continues to own distinct provider-run counts and reset baselines; no policy
moves into adapters. The [ESC-OPS-02 record](advanced-call-budget-delivery-20260917.md)
retains baseline passes, the isolated failing worker sequence, three/five-call
acceptance and final qualification status.

## Retrieval traversal repair (18 September 2026)

`ragretrieval._vector` retains ownership of ANN selection, member validation,
candidate bounds and parent scoring. It now enumerates selected JSON members
once and uses the existing dictionary to deduplicate full parent/window keys
while retaining first-seen order. No SQL, transaction, prompt, configuration or
adapter ownership changed. Generic immutable JSON buffer borrowing belongs to
CREXX and is published separately. The expanded ANN baseline, focused acceptance
and full-corpus result equivalence are recorded in
[the profiling and repair record](retrieval-profiling-20260918.md). Full local
qualification accounts for 127/127 passing cases in 763.96 seconds, including
two reused exact-input passes and scratch-installed acceptance.

## Retrieval verification ownership (19 September 2026)

`ragretrieval` now owns both preflight selection/verified request bytes and final
current-publication checks. `ragqueryservice` composes that owner before provider
work; workers and other callers retain the six-argument entry point. `ragfile`
retains bounded I/O ownership. Native `rxvector` norm validation replaces the
duplicate component loop with the same controlled zero-norm failure. No schema,
configuration, transaction or generic provider contract changes. Boundary tests
cover path/checksum/ceiling invalidation, changed publication, current visibility,
independent bytes and early rejection without provider work. See
[delivery and full-gate status](retrieval-tightening-20260919.md).

## Bounded answer context and references (19 September 2026)

`raganswercontract` owns the shared alias instruction, schema and contract/2
version, including effective prompt inspection. `raganswerreferences` owns the
request-local context/3 projection and reverse map; `ragqueryservice` composes it
with existing canonical citation validation and durable direct-call accounting.
`ragquerypolicy` owns the existing-role/model-derived context ceiling and
`ragevidencejson` owns whole-record selection and omission qualifications.
No command adapter, SQL repository, embedding profile or provider-selection
ownership changes. Workers retain their separate resolution reference contract.

The baseline public query first reproduced full-ID output; new direct controls
cover deterministic maps, canonical restoration, literal text/provenance and
graph preservation, unknown/full-ID bypass rejection and cross-request isolation.
The small-context source-versus-related-claim regression failed before the
selection repair. Public loopback tests additionally reject reported output
overruns and independently assert retained canonical maps in provider history.
Only the answer system-prompt digest changes; all response schemas and other
prompt digests remain unchanged. [Acceptance and final QA record](local-search-followup-20260919.md).

## ESC-OPS-03 lifecycle preflight (19 September 2026)

The existing different-type rule is exposed by `ragmaintain.validatetypechange`
and reused by `ragbacklog.validatebacklogresponse`; profile and transactional
checks stay in their original owners. Backlog concept/note selection is extracted
unchanged into one private helper shared by preflight/application. Provider,
worker, external proposal and review paths retain the common validator.
`durable_backlog_recording` supplies a failing baseline and genuine-change
control before implementation, plus source/history/receipt/usage and final
no-change assertions. Existing lifecycle/backlog tests cover the preserved
application paths. [Acceptance and QA](esc-ops-03-delivery-20260919.md).

## ESC-OPS-04 correction allowance (19 September 2026)

No prompt/schema template or route policy changes. `ragbacklog` exposes a small
request-only allowance projection using its existing route/reset ledger and the
frozen ceiling. `ragapplicationprovider` composes it after checking the original
prompt binding and before sending a correction; the same message builder renders
system and user context. Frozen evidence and references remain original, and
receipt replay bypasses refresh. Ordinary/advanced public loopback regressions
first reproduced 2,2 remaining calls, then require 2,1 plus unchanged input hash
and references, actual prompt hashes and normal receipt/usage/source controls.
[Delivery](esc-ops-04-qa-cleanup-delivery-20260919.md).

## 20 September beta candidate ownership

No module ownership moves. `ragbacklog` owns settled discovery, local comparison
and post-publication assessment retention; worker completion and both review
acceptance paths compose that owner. `ragresolutioncontract` adds the existing
restore/synonym preconditions for every resolution route; `ragmaintain` remains
the validator. `codex_provider` records operation clock/phase facts and
`ragapplicationprovider` selects the effective lease limit and preserves cleanup
time. There is no new schema, task kind, provider route or reporting service.
Regression and qualification evidence: [beta delivery](beta-delivery-20260920.md).

## Optional aggregate limits — 25 September 2026

This local implementation starts from clean `5f1324447cebbca6edaed773f828092d0ca9d837`
in an isolated worktree. Baseline configuration, backlog-budget,
policy-file, backlog, ingestion-capacity and native continuation controls
passed before implementation. The fail-first format-4 case rejected the new
format; the admission case could not compile the proposed zero-unlimited
argument. Both were repaired with their legacy positive controls retained.

`ragconfigfile` and `ragconfig` own explicit format-4 opt-in;
`ragcanonical`/`ragconfiguration` preserve exact older semantic bytes.
`ragadmission` owns aggregate fit/cap, and `ragwork` persists the marker in
the job policy and checks measured, reserved and uncertain usage within its
writer transaction. `ragbacklog` owns the zero-deadline window, discovery
batch, route affordability and no-work close; `ragingest`, `ragimprove` and
`ragquerypolicy` consume the shared rule. `ragallowance` retains zero-time
continuation and reports the marker through public job status.
`ragapplicationprovider` refreshes only
operational remaining-call context on a retained resolution packet after
frozen binding validation. The CLI displays opted-in zero limits as
`Unlimited` and uses the same fit rule for its synthetic smoke command. No
schema, provider or external account policy changes were introduced.

The local debug build and fast tier pass. Focused `configuration_contract`,
`durable_backlog_budget`, `query_policy`, `regression_ingest_capacity`,
`regression_source_maintenance` and `native_admission` pass after the
query-policy harness included the shared admission module. Synthetic
assertions cover paid no-spend compatibility,
concurrent reservations, zero-turn subscription accounting, finite time-only
deferral, release/settlement, automatic discovery, pause/continuation,
no-work closure, public plan/apply/status and the retained
3-to-1 advanced allowance packet. Full local regression, installed/hosted
and long-running multi-worker qualification are deferred to the agreed
separate gate. No real corpus, hosted provider or installed executable was
used; this is a reviewed local checkpoint, with formal qualification pending.

Coordinator review found four item-1 gaps. Fail-first native calls reproduced
the explicit-`--until` rejection under a zero default and the MCP
`minutes: 0` schema rejection; VM checks reproduced same-job retry closure
before backoff elapsed. `ragallowance` now reports independent cost and
Codex-turn reservations, verified through public status with synthetic
values 123 and 7. `ragbacklog` lets explicit finite timing override the
unlimited default and retains an unlimited window for an ordinary provider
retry with a receipt in that same job. An operator deferral with a future
date does not keep the window polling; empty work still closes. The MCP
`rag_maintain_plan` schema now permits zero, while the format-3 product
guard still refuses unlimited time. `rag_job_continue.minutes` remains a
positive renewal period and retains its minimum of one. The ten affected
cases pass at the current build identity, including exact-input reused
receipts; the external handoff has the report and reproduction details.

## 23 September worker compatibility and first-pass source maintenance

No module ownership moves. `ragconfiguration` now checks the semantic bindings
of unfinished selected job items rather than comparing whole worker snapshots;
`ragapplicationprovider` repeats that check for a claimed item before a
provider call. `ragcanonical` retains role-only source independence and
`ragconfigfile` carries explicit legacy embedding batch size into typed
validation. This permits unrelated completed-phase, source and operational
changes while rejecting relevant pending role/source changes and invalid
provider limits. The unfiltered multi-job worker launch remains a separate
compatibility concern.

`ragbacklog` owns first-result discovery, task dispatch and completion for
the source-scoped `initial_extraction_only` selection. `ragproduct` freezes
it in the reviewed plan; `ragcommandcatalog`, `ragcommandutil` and
`crexxrag_cli` expose the same flag through MCP, canonical CLI and guided
CLI. Outcome reconciliation still sees a task after its first result. There is
no schema, task-kind, provider-route or ingestion change.

Before implementation, `worker_recovery_preflight-once` reproduced the
legacy batch-size parse omission and then the whole-snapshot refusal; its
positive control retained the original setting. The existing
`regression_source_maintenance` baseline passed before the new
`initial-extraction-only` case failed with an unknown option. The expanded
source case checks ordinary alias admission, first-pass exclusion, completion,
repeat planning, no writes or provider calls during planning, guided/MCP parity
and invalid selector combinations. See the current qualification results in
[regression coverage](regression-coverage.md).
## Actionable corrections and honest closure — 25 September 2026

The Item 4 candidate starts from the coordinator-reviewed Item 3 commit
`4e9eeb0d6f7e2f04d7b163b95f014e4d913de730` in the isolated
`temp/item4-actionable-closure` worktree. Before product edits, `cmake --preset
debug` and `cmake --build --preset debug` passed; `durable_backlog`,
`durable_backlog_reconsideration`, `durable_backlog_sparse_edge`,
`regression_prompt_inspection`, `regression_source_maintenance` and
`native_surfaces` passed 6/6. The new `durable_backlog_actionability` first
failed because correction actions were absent from the frozen Item 3 contract
(receipt `20260925T204645-ec0b63d2`).

`ragresolutioncontract` owns `/10` prompt, schema and action vocabulary, with
`resolution_text` required for every new response and empty outside correction
or capability wait. It reconstructs and verifies frozen `/7`, `/8` and `/9`
bindings before queued work uses the current contract. `ragresolutionreferences`
recognizes `/10`. `ragbacklog` remains the single validation, dispatch,
review and apply owner. A grounded note correction creates a reviewed
replacement observation with its own exact source link, and preserves the old
note and associations as superseded history without copying unsupported links.
A grounded answer closes an open query gap only
after review. No-change and supported retention do not stage a graph
generation. Evidence and capability waits retain an unresolved task and a
specific reason while excluding unchanged packets from dispatch; material
subject/source/linked-context change creates a linked successor. Existing
review and external proposal paths carry the same effects and validation.
`ragreportservice` projects the five distinct outcomes, pending corrective
reviews and applied note/gap changes. No SQLite schema, policy default, corpus or
native provider changes were made.

The first repaired `durable_backlog_actionability` pass is
`20260925T210346-febe6895`; after the additional retention, no-change and
changed-wait assertions it passed again. `durable_backlog`,
`durable_backlog_reconsideration` and `durable_backlog_sparse_edge` passed 4/4
with that first repair; the sparse-edge case keeps a stable support identity
across `/9` and `/10`. `regression_prompt_inspection` passed with an authentic
independently captured `/9` prompt/schema hash and tampering control. The
native `regression_prompt_contract` first refused the longer `/10` request at
its two-worker fixture's 4,096-token per-call reservation; the synthetic
aggregate allowance was raised to 16,384 without changing product limits.
Its next run reached the expected intentional resolution hash mismatch; the
other three provider contract pairs stayed byte-identical. The reviewed
resolution pairs are retained in `provider-contracts.sha256`.

The expanded focused case also passes public MCP task inspection and read-only
overview interpretation, external note and gap plans with exact effect
previews, mandatory pending reviews, accepted replacements and no fabricated
provider usage. A selected unlimited identity cohort closes while its evidence-wait task
stays unresolved and visible. The fast tier has 11 current passing receipts
(CTest reused one exact-input pass as skipped). The affected backlog, sparse,
reconsideration, public source and native surface cases pass; bounded loopback
provider valid, malformed, correction and correction-failed cases pass with
secret redaction retained. `regression_prompt_contract` passes with the
reviewed `/10` pairs and unchanged extraction, answer and report captures.

This is a local candidate for coordinator review. The full formal regression
suite, hosted/platform checks, integrated long-running run,
installation and publication remain for the final programme gate.

The first-review linked image SHA-256 was
`fd63b45b4a33e88dfac56ad10dbe4cff0268aedf97f298531129c23d3198e42a`;
the native package is
`a6a2531a44862545216d87473365dc3ee4177dbffabe7778c73b78ed446e3f70`.
The final `durable_backlog_actionability` receipt is
`20260925T214626-116ce92a`. `ctest --preset fast` passed 11/11 at that
linked image. The 15 affected cases have current-input passes. The combined
selection passed with that exact-input actionability receipt reused as a CTest
skip; five sibling backlog cases were rerun after the shared scenario gained
the external gap control. The selection included core backlog,
reconsideration, sparse edge, budget, escalation, native surfaces, source
maintenance, SQL performance, prompt contract, valid/malformed/correction
loopback cases and the invalid-schema negative. `documentation_contract`
passed after the record edits. The final QA ledger records 26 passed, 114
not-run and no failed, disabled or interrupted case. `git diff --check` passed.
These counts are a focused checkpoint, not the required full regression gate.

The coordinator's first review found four bounded issues in that candidate.
R1: `_terminaldecision` classified any accepted review other than `defer` as
settled, even when the review owner retained an evidence or capability wait as
unresolved. An authentic older pending `insufficient-evidence` worker review
failed debt reconciliation first at `20260925T220827-1359d422`. The report
predicate now excludes reviewed waits from settlements; a historically resolved
task still counts through its state. Worker and external reviewed-wait controls
keep both `reconciliation_delta` and `unreconciled_logical_questions` stable.

R2: `reviewagentaction` could settle a wait but leave its blocking
`escalation_origin` on the task, and `enqueuebacklogtask` copied it onto the
changed successor. The external wait-to-supported-retain chain failed first at
`20260925T221141-819220a9`. The shared `_clearfulfilledwait` transition now
consumes only a fulfilled wait marker after worker, worker-review or external
review resolution. Successor routing also refuses a stale wait tag retained by
older resolved records. Decisions, review receipts, attempts and usage remain
intact. The successor is selected and serviced; unchanged context stays quiet.

R3: `_scansettled` missed unresolved waits outside their old source selectors,
and a corrected observation had no assessed task of its own. The ordinary
window route failed first at `20260925T221705-3c9d5403`. The existing paged
census now compares unresolved waits, and note correction atomically records a
settled assessment of the replacement's own source-only citation. A new
independent source passage and linked context reopens the corrected observation
and an identity wait outside the ordinary identity selector. An unchanged
follow-up census creates no duplicate question or provider call. Missing
capability availability alone has no automatic trigger; reviewed external
resolution or explicit task reset remains the supported path.

R4: the source-bound validator now has explicit wrong-subject, absent-grounding
and misquotation refusals for both correction actions. Stale note and gap
acceptance refuses after a changed note or cited source passage; safe
reject/dismiss retains the
original decision and exact provider usage without publication. The exact debt
control also caught changed unfinished packets being superseded without a
parent, despite aggregate delta zero (`20260925T222621-a8adc5b5`). The
existing enqueue owner now links such successors within the same logical
question. The final actionability case passed both VMs at
`20260925T223502-dce8f7be`, with exact zero reconciliation delta and zero
unreconciled logical questions, two applied worker/external note corrections,
two gap resolutions, two supported retentions, two justified no-change
assessments, and read-only report stability. The source passage is restored
after the safe dismissal in the synthetic fixture. A selected 16-case affected
selection passed; CTest reused the exact-input actionability pass as skipped.
No protected corpus, hosted provider, schema, policy default or sibling CREXX change was
made. Full formal regression and publication remain with the final programme
gate. This repaired branch remains uncommitted for a second coordinator review.
The repaired linked image SHA-256 is
`941e5cabd03f43cbce512c56f2bbdc0a0aa70fc8aa1ae41c511a4ed7f63f47ec`;
the native executable SHA-256 is
`b6146cff76af565ed29eb7945ff6a621a6a400cded4231dc46a8cdc93a484218`.
`ctest --preset fast` passed 11/11 after the documentation edit. The current
QA ledger records 27 passing, 113 not-run, zero failed, disabled or
interrupted cases. The private Item 4 handoff has the exact final receipt and
the first-review findings mapped to code and controls.

### Second coordinator review R5: retained settlement history

The second review identified a precise gap in `_debtledger`: current resolved
state and terminal worker decisions did not prove an accepted external
resolution or a corrected-note assessment after that version was superseded.
The settlement and its changed-evidence reopening could disappear together
while the aggregate debt equation still balanced. The exact before/after
assertions failed first at `durable_backlog_actionability/20260925T224625-9718e2ae`.

`ragreportservice._settledtask` now supplies the common predicate to the
ledger and the materially reopened census. It recognizes a retained terminal
decision, accepted external resolution, accepted review assessment, or
post-decision job assessment, and counts each task version once. A reviewed
evidence or capability wait remains open. `ragbacklog` stores the corrected
observation's assessed context on its accepted correction review, so an
external correction without a job has an inspectable source-context receipt.
It no longer associates that replacement assessment with an unrelated latest
job. The same receipt lets the normal bounded census reopen the corrected
observation when a newly cited passage changes its context.

The actionability fixture independently requires the known synthetic totals
17 new, 7 reopened, 10 settled and 14 open both before and after superseding
the accepted external-resolution and corrected-observation predecessors.
The no-job correction adds one further reopening and retains its settlement
after supersession. Two synthetic retained old reviewed-resolution shapes
exercise historical uncertainty: a post-decision assessment proves one past
settlement and linked reopening, while the receipt-free counterpart is left
unsettled and reported as one unreconciled logical question. These fixtures
model old retained state; they do not claim execution of an old binary.
The completed actionability case passed both VMs at
`20260925T225703-e5f5faa1`. The selected 16-case affected run completed
with 15 executions passed and the exact-input actionability pass reused as a
CTest skip; it includes core backlog, recording, reconsideration, sparse edge,
source maintenance, SQL performance, native surfaces, prompt contract and
provider loopback positive/negative controls. Current source and artifact
hashes and the final QA ledger are recorded in the private Item 4 handoff.
No task reset, hosted call, protected corpus access, installation, commit or
publication was made during R5 repair. Full formal qualification remains
deferred. The third coordinator review (`04-REVIEW-03.md`) accepted R1-R5 for
one local checkpoint commit on `temp/item4-actionable-closure` with parent
`4e9eeb0d6f7e2f04d7b163b95f014e4d913de730`. It independently checked the
fixed-count and no-job receipts and audited 27 current-input passes and 262
distinct matching recorded hashes. No further implementation or broad QA was
requested. The exact checkpoint SHA and final focused evidence belong in the
private Item 4 handoff. Full regression, hosted/platform, long-running,
installation and publication gates remain separate.

## 26 September bounded large evidence, item 5

`ragbacklog` remains the task/evidence, source-inventory, validation,
acquisition and refresh owner. Its complete builder still owns small packets.
A bounded wrapper retains a source-inventory fingerprint, exact omitted
passage/catalogue counts and `evidence_complete:false` when a concept question
exceeds that builder's byte or 100-concept ceiling. The worker can page current
passages or candidates with a cursor and completion flag, bind only a previously
inspected exact candidate, and read an exact source citation into the task
packet. Read/target selections replay from the task; one page is never
presented as a complete inventory. Workflow-impact and provenance/extraction
cases keep their complete-packet requirements. The fingerprint also covers
current concept claims and supports.

`ragresolutioncontract` owns `/12` inspect and scoped acquisition-wait guidance,
action schema and the incomplete-packet warning. It reconstructs authentic frozen `/7`–`/11`
prompt/schema bindings without resubmitting old schema. `ragresolutionreferences`
recognizes `/12`, leaves inspect cursors native and expands a visible
`catalogue-target` C reference to its canonical concept ID. `ragapplicationprovider` serializes the same message/input/schema body
for measurement and receipt capture; it compares fresh calls with the smaller
of reserved input and model context minus output, using the selected three-byte
input envelope. Receipt replay remains exempt. An oversized fresh call asks
`ragbacklog` to record a measured, uncalled `request-capability` hold. Its
extraction correction path checks the same full serialized request and settles
oversize corrections without a second call or a maintenance task. Inspection
returns the largest prefix that fits both row count and 8,192 serialized bytes;
a single unrepresentable record enters an `evidence-limit` hold. On incomplete
partially inspected tasks, `acquisition-wait` records the inspected scope and
remaining acquisition after calls or reads are exhausted, without claiming
whole-subject validation or changing the graph. Its
`evidence-limit` and request-capability holds do not re-enter ordinary worker
selection. `ragbacklog` blocks whole-subject retain, no-change and
insufficient-evidence on an incomplete packet and keeps older decisions in
SQLite while reporting when only the latest 32 fit the model history.

Existing reviewed refresh planning/digest/apply owns reconsideration. A
technical hold can produce a scoped incomplete successor under a reviewed
envelope. Repeating the same scoped bytes/concept count and configuration is
refused with a changed-envelope/configuration next action. The predecessor,
attempts, receipts, usage, question and lineage are not reset. Other refresh
still requires a complete packet. The surface catalogue description and user
guidance point to the same controls; no new adapter state, schema, provider
route, global default or external orchestration was added.

The before case was a catalogue-overflow task held in review with a falsely
acceptable whole-subject no-change. The new core assertion failed first at
`durable_backlog/20260925T232557-07e7a247`; the pre-change four-case backlog
baseline passed. The byte-heavy synthetic fixture has more than 500 passages
and 100 candidate concepts. Native inspection finds a late exact passage and
late target on later pages, then produces a source-quoted directional
relationship proposal that remains in mandatory review. The separate
source-absent control produces `insufficient-evidence:unresolved`. The
correction limit fixture stops a 21,311-byte serialized request at a 21,000-byte
selected bound; the old content-only estimate was 20,414 bytes. Three earlier
provider requests/receipts remain and reservations return to zero. Existing
successful correction, malformed output, rejection, advanced route, budget,
small-packet, stale-review, public surface and legacy prompt controls stay in
the focused selection.

Six direct cases and eleven adjacent regressions passed after the final
product edit. The strengthened core preservation assertion and four sibling
backlog cases then passed again. Fast accounted for 11/11; after the
documentation edits, its documentation case executed and the other ten
retained exact-input passes appeared as CTest skips. The first item-5 QA report
counted 27 current-input passes and 115 not-run cases, with no failed or
disabled case. Full formal regression, hosted calls,
protected corpus use, installed/platform checks and publication remain outside
this item-5 checkpoint. The fixture establishes functional bounds and
provenance; it is not a long-history or large-scale throughput benchmark.

Coordinator review R1–R4 was addressed in the same uncommitted item-5
worktree. Fail-first extraction correction and normal-ID catalogue receipts
showed the two prior boundary failures. The repaired extractor preserves one
earlier receipt and 4,000:4 usage while refusing an oversized correction before
provider dispatch; a fitting correction remains a positive control. The
native catalogue fixture now proves no skipped or duplicate rows across
byte-fitting pages, and a single unrepresentable row retains an
`inspect:unresolved` technical hold. The reference test round-trips a target
also present in competing identities, keeping raw cursors and raw target IDs.
Ordinary and advanced partial-isolate cases bind one read, preserve omitted
debt and stop as `acquisition-wait:unresolved` at the read boundary without
repeated dispatch. The external-proposal path refuses that worker-only wait
and names the existing inspection and reviewed refresh controls. A real Gemini loopback executes inspection and the scoped
wait through `ragapplicationprovider` under finite budgets. The `/12` prompt
and schema hashes were reviewed and the contract fixture updated. Fast
accounted for 11/11; affected focused tests passed. The latest QA ledger has
26 current-input passes, 118 not-run and no failed/disabled/interrupted cases.
Formal regression and external qualification remain separate.

The second coordinator review repaired the worker's direct technical-hold
continuation in `ragbacklog`. Scoped reviewed refresh accepts genuine worker
`unresolved:evidence-limit` results, with the same changed-envelope or current
configuration guard as the prior review hold. Missing prior refresh limits on
an actual worker hold use configured defaults, including when the SQL numeric
read yields a negative missing value. Changed-context discovery reads
the retained worker decision before inheriting `evidence-limit`: a prior
`acquisition-wait` releases when the new packet is complete; a prior
`inspect:unresolved` record-size limit releases when its exact offending
record fits or leaves the current inventory.
The check follows inherited parent lineage, while a still oversized successor
keeps its hold. A completed wait and a later settled successor clear obsolete
origins. Existing review, worker ownership and per-request admission owners
remain in force; no schema, policy default or new retry mechanism was added.

The extended `durable_backlog_large_evidence` case first failed at
`20260926T083932-a57ff2cd`: actual worker holds could not plan their bounded
scoped successor, and an advanced changed successor retained the obsolete
origin. A later red receipt at `20260926T084437-0482c946` exposed the missing
numeric-limit fallback on unchanged native refresh. The direct-hold case reaches `acquisition-wait:unresolved` and
`inspect:unresolved` through fixture-provider processing, plans and applies a
smaller incomplete packet from each, refuses the unchanged current envelope
before apply and an unchanged re-plan of the
superseded source, and independently checks parent packet, decisions, attempts,
provider receipts and usage. A distinct advanced held task loses its source
bound and dispatches one linked successor; an unchanged task stays quiet, a
changed still oversized task stays held, and a supported retained resolution
followed by another material change keeps advanced routing without the obsolete
origin. A separate native `inspect:unresolved` control adds a small row before
the offending record and stays held; only repairing that exact row releases a
linked successor. The current positive receipt is recorded in the private item-5 handoff.
The affected 15-case selection and 11-case fast preset passed with exact-input
reuse noted by CTest. The real-provider loopback still qualifies only the
two-call inspect-then-wait journey; late target/read/proposal remains direct
native fixture evidence. Formal regression and hosted/corpus/platform gates
remain open.

The third review found one further continuation path: changed evidence can
produce a `pending:evidence-limit` child when the original worker bound still
applies. That child remains correctly excluded from dispatch, but the scoped
refresh branch previously recognized only review and unresolved states. The
extended native case created both advanced and ordinary held children from real
`acquisition-wait:unresolved` parents. Before the owner fix,
`durable_backlog_large_evidence/20260926T092014-3b1d973d` failed on the
unchanged-envelope refusal and changed incomplete plan for both children.
`planbacklogrefresh` now recognizes only the pending `evidence-limit` origin in
addition to its prior states. The existing `planagentaction` pending-review,
active-item and waiver guards and exact transactional re-plan still own
admission. The native case checks those ownership guards, then applies a
changed scoped envelope, verifies both parent links, exact old packets,
decisions, attempts, receipts and total usage, and refuses a repeat on the
superseded child. No state rewrite substitutes for either worker hold or the
inherited child. The final positive receipt is in the private item-5 handoff.
This remains focused local evidence awaiting coordinator review; full formal,
hosted, corpus and platform qualification is still open.
