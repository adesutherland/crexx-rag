# Maintenance refactoring delivery

This implements the five opportunities in the
[12 September ownership review](maintenance-refactoring-review-20260912.md),
starting at `1ebee11`. Each stage confirms coverage before product edits,
extends missing tests, passes the complete local regression workflow, updates
the user and architecture documentation, and is committed separately.

## Scope and operator interface

`crexxrag.conf` remains the single operator policy entry point. Referenced
profiles and optional prompt files are data selected by that policy, not
competing policies. Step 5 adds supported file editing/replacement commands
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
| 3 | Report, observation and query services: cohesive domain orchestration and bounded operator inspection | Green; 54/54 full regression tests |
| 4 | Command catalogue: one operation/argument/capability definition used by surfaces | Pending |
| 5 | Effective configuration policy and safe policy-file update/replacement commands | Pending |

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
