# Maintenance and ownership review after the public-result repairs

12 September 2026. This review ranks maintenance changes by demonstrated
ownership problems, change size and available regression protection. These are
proposals, not additional implementation in the public-result repair.

## Reviewed delivery and qualification

The previously uncommitted review, roadmap and regression work is retained in
`5d1481a9b59b433e255c3db4dba6655d56960607`. The repair reviewed here is
`8fb4ea1c02b4372143034cefba7fdf2888108a15` on `temp/project-review`.

All three reproduced failures are repaired: maximum-size result pages,
large retained job plans and Unicode lexical queries. The complete
`cmake --workflow --preset regression` passed **50/50 tests in 654.74 seconds**,
including the original defect cases, new boundary controls, both-VM checks and
scratch-installed product checks. The [repair record](public-result-lexical-repair.md)
records the exact artifact, input checks and test evidence.

Post-commit self-review found no remaining blocking issue in this repair.
The review checked the committed result-bound logic, parameterized repository
reads, character/cursor units, command/MCP registration, access checks,
compatibility controls and source dependency direction. This is local
qualification with the installed CREXX package; it does not establish hosted,
cross-platform or long-running operational acceptance. The five operational
P1 outcomes and broader retrieval-quality requirements remain open or partial
in the [consolidated register](ROADMAP.md).

## Assessment

Targeted modularisation remains justified. The new `ragresultpages` owner
separates result projection from repository SQL and command routing. The
admission, lifecycle, receipts/usage and supervision owners from steps 1–4
also have concrete contracts and failure tests. No cross-module production
import cycle was found by namespace/import inspection.

There is still a large concentration of unrelated work: `ragproduct` contains
3,351 physical lines and `ragapplicationprovider` 998. Size is a navigation
signal, not a reliability measure. The clearest maintenance problems are
repeated decisions, contracts split across call sites and hard-to-find effective
prompts. Tests caught two integration mistakes during these repairs: a missing
CLI operation registration and a cursor check that rejected existing task-page
metadata. Both were repaired before final qualification. Neither establishes
a measured long-term change in regression frequency.

## Evidence locations

- Claim factories: [worker policy](../crexx/application/ragprocess.crexx) and
  [external-proposal policy](../crexx/application/ragproposalio.crexx).
- Effective requests and validation: [application provider](../crexx/application/ragapplicationprovider.crexx),
  [query provider](../crexx/application/ragqueryprovider.crexx),
  [backlog schemas](../crexx/application/ragbacklog.crexx), and
  [editable prompts](../crexx/application/config/prompts/).
- Defaults and identity: [typed configuration](../crexx/application/ragconfig.crexx),
  [file loading/defaults](../crexx/application/ragconfigfile.crexx), and
  [canonical identities](../crexx/application/ragcanonical.crexx).
- Commands and transport: [dispatcher](../crexx/application/ragproduct.crexx),
  [command contract](../crexx/application/ragcommand.crexx), and
  [MCP maps](../crexx/application/surfaces/ragmcp.crexx).

## Ranked opportunities

### 1. Give claim-policy construction one owner — HC-16

**Evidence:** `ragprocess._profilepolicy` and
`ragproposalio.profileclaimpolicy` independently derive the same concept and
relationship vocabulary, version prefix and five stance weights
(1000/700/600/500/300). The external-proposal path also supports an explicit
policy-version override. A policy change currently needs coordinated edits in
worker and proposal I/O code.

**Proposed owner:** `crexx/application/ragclaimrules.crexx`. It should construct
the effective policy from a profile and optional version override. Keep
validation/promotion in `ragclaims`; process control and proposal decoding
should consume the shared policy. Move only the factory first, preserving every
weight and version. This is the smallest high-confidence maintenance refactor.

**Coverage first:** characterize worker/internal and external-proposal policy
outputs and accepted/rejected outcomes on the same profile, including the
version override. Retain grounding, quotation, lifecycle and provider validation
negatives. Do not tune policy in the extraction commit.

### 2. Keep effective prompts, response schemas and contract versions together

**Evidence:** editable role prompts live under `config/prompts/`, while
`ragconfigfile._rolepromptdefault` supplies compiled compatibility text and
`ragmaintenancepolicy` carries a default resolution prompt. Actual extraction
and resolution requests append lengthy rules in `ragapplicationprovider`
(lines around 184–220), including `_quotationcontract` and correction text.
The extraction response schema and its decoder are in that provider module;
resolution schemas also come from `ragbacklog.backlogschema`. Answer/report
schemas are in `ragqueryprovider`. `ragassessment` and `ragenrich` already show
useful examples of domain prompt/schema ownership.

**Proposed owners:** start with `ragextractioncontract.crexx`, then
`ragresolutioncontract.crexx`; introduce answer/report contract owners as those
services are extracted. Each domain owns its effective prompt builder, response
schema, bounded feedback vocabulary and explicit contract version. Shared
quotation rules belong beside `raggrounding` in one reusable contract helper.
Keep editable objectives in `config/prompts/`; program-enforced evidence rules
remain owned by code and its validators. Provider adapters should receive the
complete request, rather than append product rules that callers cannot inspect.
Avoid one global prompt file mixing every domain.

Expose the effective prompt and origin through existing configuration/plan
inspection where useful, without secrets. `ragcanonical` already hashes
configured prompt text, but additional runtime text is assembled elsewhere.
Trace the complete effective request/version identity before changing it; this
review identifies a synchronization risk, not a reproduced identity/replay bug.

**Coverage first:** capture exact effective messages/schema for each operation,
including correction and optional provenance mode. Characterize config defaults
and file overrides, effective identity changes, input-envelope accounting,
secret redaction, and retained-response recovery. Keep strict validation
independent of model compliance. Extract with identical effective text first;
changing prompting behavior is a separately measured change.

### 3. Turn `ragproduct` into composition, starting with reporting then queries

**Evidence:** report assembly, narrative validation/cache persistence,
observation snapshots and trends occupy the early part of `ragproduct`;
query retrieval, privacy selection, answer validation and direct-call accounting
occupy another large block. The same file also implements jobs, workers,
ingestion and maintenance commands. A report wording or query change requires
navigating unrelated operational code.

**Proposed owners:** `ragreportservice.crexx` for report/narrative behavior,
`ragobservationservice.crexx` for snapshots/trends, then `ragqueryservice.crexx`
for query/answer composition. Keep their SQL read/write owners explicit and
reuse admission/usage services where the contracts actually match. The public
dispatcher should translate validated arguments into service calls and assemble
results, with domain policy behind those calls. The existing `ragresultpages`
is the bounded first step in this direction.

**Coverage first:** retain `gemini_query`, `query_policy`, `native_surfaces`,
`address_surface` and installed-product checks. Characterize cached versus
refresh calls, narrative citation failures, immutable historical results,
zero-write query inspection, failed-call usage and transport equivalence.
Extract one service per change, without changing schemas or ranking.

### 4. Make the command vocabulary and transport metadata one maintained catalogue

**Evidence:** a public operation is represented independently in
`ragcommand._validoperation`, `ragproduct.dispatchproduct`, and several MCP
maps: tool-to-command mapping, argument forwarding, tool schema, allowed keys
and required keys. The missing `job plan` parser registration during this fix
is a direct example of the coordination burden. Existing tests caught it.

**Proposed owner:** a small Level-G `ragcommandcatalog.crexx` in the existing
`surfaces/` area, consumed by parsing and MCP metadata. Store operation identity,
argument names/types/bounds, read/write annotations and required capability in
one explicit descriptor. Keep the actual operation implementation in its
service; do not introduce reflection, code generation or a new framework merely
to replace a few tables.

**Coverage first:** enumerate catalogue operations and compare CLI/MCP/ADDRESS
recognition, missing/unknown arguments, integer boundaries and read/write
annotations. Retain the runtime authorization checks. Move one command family
first; do not weaken validation to make vocabulary alignment easier.

### 5. Consolidate configuration defaults and effective-policy projection

**Evidence:** defaults and validation are distributed among typed policy
factories in `ragconfig`, file loading in `ragconfigfile`, compatibility configs
in `config/`, and canonical identity construction in `ragcanonical`.
Some repetition is required for backward compatibility, but finding the
actual value and semantic-versus-operational identity needs several files.

**Proposed approach:** introduce focused policy factories for one family at a
time, starting with worker/recovery settings. File loading supplies overrides;
the factory yields the validated effective policy and provenance. Canonical
identity consumes that same value. Keep schema/bootstrap guards independent
of configuration parsing, and retain compatibility defaults until an explicit
migration replaces them. Do not make every invariant configurable.

**Coverage first:** omitted versus explicit defaults, file versus typed input,
limits, semantic/operational identity, invalid input before library access,
worker restart behavior and an installed configuration round trip. Existing
`configuration_contract` and supervision tests provide starting controls.

## Location and sequencing

Use the named source owners before a directory shuffle. Keep editable prompts
in `crexx/application/config/prompts/`, transport adapters/catalogue under
`crexx/application/surfaces/`, domain owners under `crexx/application/`, and
matching contract tests under `crexx/application/tests/`. Record each owner's
public functions, authoritative state and allowed dependencies in
`docs/architecture.md`. Related rules should be reachable from that owner,
without searching incident reports for the implementation.

Start with claim-policy deduplication, then the extraction prompt/contract
boundary. Interleave these small changes with the still-open operator recovery
and renewal outcomes; the architecture programme is not a prerequisite for
fixing those outcomes. Keep separate executables and a wholesale directory
reorganisation deferred. The future CREXX llama.cpp bridge remains upstream;
these product contracts should work with either HTTP or an installed bridge.

Success criteria are one implementation per shared decision, one inspectable
effective prompt per operation, stable identities and transactions, and a
clean checkout running the complete regression gate. Shorter files alone are
not an acceptance criterion.
