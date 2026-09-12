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
| 2 | Domain prompt/contracts: complete effective requests and schemas together | Complete; 53/53 full regression tests |
| 3 | Report, observation and query services: cohesive domain orchestration and bounded operator inspection | Pending |
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
