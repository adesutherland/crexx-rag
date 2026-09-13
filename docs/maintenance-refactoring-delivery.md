# Maintenance refactoring delivery

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
