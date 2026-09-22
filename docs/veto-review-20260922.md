# Indexer veto review — 22 September 2026

## Conclusion and requirement

The application still imposes several unnecessary vetoes. The clearest are
mandatory provider catalogue/pricing metadata, validation of unused roles,
whole-configuration equality before reading existing evidence, and refusal of
operator-selected parent-relative paths. Moving these requirements into more
configuration switches would preserve the problem.

Adrian's direction is that this is an indexing tool, not a governance system.
The selected model is an operator choice. The application needs enough transport
information to call it and enough information about the returned data to use
that data correctly. A compulsory parallel model catalogue is not necessary.

This is a current source review with isolated executable probes, not a claim
that every refusal branch has been independently executed. The review covers
configuration parsing/validation, command planning, queries, worker compatibility,
call admission, task retry and claim/maintenance promotion. Historical HC findings
are checked against current owners rather than treated as current by default.
The [roadmap](ROADMAP.md) remains the sole current register.

## Remove or narrow

Source links refer to the reviewed working copy; the quoted functions and
behaviors identify the finding if line numbers subsequently change.

Configuration owners: [parser](../crexx/application/ragconfigfile.crexx),
[typed validation](../crexx/application/ragconfig.crexx),
[file refresh](../crexx/application/ragpolicyfile.crexx),
[snapshot compatibility](../crexx/application/ragconfiguration.crexx).
Execution owners: [query admission](../crexx/application/ragquerypolicy.crexx),
[plans](../crexx/application/ragplanning.crexx),
[claim promotion](../crexx/application/ragclaims.crexx),
[support assessment](../crexx/application/ragassessment.crexx),
[maintenance outcomes](../crexx/application/ragbacklog.crexx),
[retry lifecycle](../crexx/application/raglifecycle.crexx),
[provider contract](../crexx/providers/provider_contract.crexx).

| Veto | Current evidence | Assessment and simplest direction |
| --- | --- | --- |
| Non-public source blocks the selected hosted provider | Two shared hard-coded refusals, plus maintenance/query/report preflights. [Repair evidence](provider-route-selection-20260922.md). | **Remove.** The source-level repair is in this working copy. Keep truthful source/route metadata without another permission decision. |
| Model selection requires a catalogue date, input/output prices, context/output limits and embedding capability declarations | `ragconfigfile` lines 139–149 requires eight catalogue fields per provider in config/3, even for generation-only providers. | **Remove mandatory metadata.** Accept the selected model; optional estimates must not be prerequisites for ordinary use. An explicitly requested monetary ceiling is a separate optional feature. |
| Unknown prices block a query before the provider is tried | `ragquerypolicy.querypreflight`, lines 27–49, requires positive monetary allowance, known prices and enough budget for configured worst-case retry envelopes. | **Conditional only.** Justified when the operator explicitly requires a hard monetary ceiling. Not justified as a universal model-admission rule. Unknown cost should be reported as unknown, not fabricated as zero. |
| Locally declared model capabilities overrule role settings | `ragconfig` lines 791–818 checks role input/output/dimensions/batches against the additional catalogue record. | **Narrow.** Validate actual returned vector shape and real driver limits. Do not require the operator to maintain a second model specification that can veto the selected model. |
| Unused provider roles block unrelated commands | Config/3 loops through advisory, extractor, embedding and answerer with required bindings; typed validation additionally requires advisory/extractor/embedding. `ragconfigfile` lines 160–183; `ragconfig` lines 821–823. | **Remove global requirement.** Validate the role needed by the requested operation. A reader/indexer should not need an advisory model merely to load its configuration. |
| All selected configuration must validate before ordinary CLI/MCP operations | `ragpolicyfile.refreshpolicyrequest`, lines 30–41, reloads the complete registry. File show/repair has a bypass; ordinary operations do not. | **Narrow to dependencies.** Continue checking syntax and the values actually used. A broken optional provider must not obstruct evidence inspection or unrelated local operations. |
| Changing a worker setting blocks a lexical read | `ragconfiguration.querysnapshotmatches`, lines 346–355, compares full config/profile hashes; `ragqueryservice` invokes it before `query.inspect`. | **Remove this read veto.** Read the stored index with the requested retrieval settings. Actual vector/model compatibility applies only when that representation is used. Reproduced with worker count 2 → 3. |
| Worker restart refuses almost any configuration difference | `ragconfiguration.worksnapshotmatches`, lines 53–65, excludes only worker count. `checkworkerconfiguration`, lines 67–87, applies it across selected jobs; the provider repeats it per item. | **Narrow to the work.** Retain actual request and result identities. Resume a frozen request or explicitly redo it with the current settings; unrelated query/source/report settings must not prevent either operation. |
| A normal configuration edit needs plan/apply publication before use | `ragconfiguration.applyreconfigureplan`, public config plan/apply, and the query/worker snapshot checks. | **Remove the manual ceremony for ordinary prospective settings.** New work can capture the selected configuration automatically. Preserve history and atomic writes internally. A stored snapshot is useful evidence, not an additional approval authority. |
| A plan expires or becomes stale because unrelated library state changes | `ragplanning.validatefoundationplan`, lines 91–162, binds generation, all sources/provider routes/reservations, exact canonical bytes and TTL. | **Narrow.** Atomic checks on affected objects prevent stale destructive writes. Routine ingestion/start can create and execute its current work internally. A retained explicit plan need not survive every edit, but a global snapshot need not gate ordinary commands. |
| `../source-docs`, parent-relative prompt/model/profile/glossary paths are rejected | `ragconfigfile._safesourcepath`, lines 509–514, rejects `..` before `resolveconfigpath`, which already normalizes it. Absolute paths outside the config directory are permitted. | **Remove for trusted operator paths.** This provides no meaningful containment while obstructing normal project layouts. Keep separate containment rules for untrusted archive entries or provider-supplied paths. |
| Privacy metadata is compulsory even after it ceases to control routing | `ragconfigfile` lines 76 and 105–106; enum checks in `ragconfig` lines 747 and 783. | **Remove as a requirement.** Existing files can retain the fields for compatibility; basic setup should not need to declare them. This remains beyond the narrow routing repair. |
| A hosted label requires HTTPS and an environment credential reference, irrespective of the selected endpoint | `ragconfig` lines 775 and 787. The credential exception is Codex; ordinary hosted adapters require a reference even if an operator's service needs none. | **Separate useful transport defaults from blanket admission.** HTTPS is a defensible default for credential-bearing network calls. Actual authentication requirements belong to the selected service/adapter; a route label alone does not prove a credential is necessary. |
| Confidence below 0.5, self-relations, conflicting claims or any external proposal require review | `ragclaims.validateproposal`, lines 471–476 and 532–551. | **Do not impose a separate review decision universally.** A model's self-reported 0.5 is not an integrity boundary. Retain conflicting source assertions and uncertainty; a self-relation is not intrinsically invalid. External provenance is worth recording but does not alone establish that an otherwise valid item must pass another approval step. |
| An unidentified quoted speaker or a type outside the profile delays promotion | `ragassessment` lines 75–76 marks unknown quotation/report voices for review; `ragclaims` lines 475–477 and 512–514 requires review for profile-disallowed types/relationships and unknown voices. | **Retain uncertainty without compulsory curation.** Do not invent the speaker. A selected ontology can define a typed graph, but unclassified mentions and unknown voices can remain indexed and inspectable. A typed projection's limitation need not become a source-ingestion veto. |
| Maintenance forces finality, prohibits repeat reads and restricts honest deferral | `ragbacklog._validateoutcome`, lines 1640–1664: final reasoning cannot remain unresolved; extraction is advanced/chunk-only; the last call cannot request evidence; repeated reads and repeated unchanged deferrals are rejected. | **Simplify workflow, not truth.** These rules deliberately try to stop loops, but recording unresolved work and ending the attempt serves that purpose without forcing a conclusion. Explicit call/time budgets can bound loops. They are maintenance design choices, not conditions for retaining/indexing source material. |
| Operator/model parameters are constrained by blanket enums and bounds | `ragconfig` lines 778–779 restricts reasoning effort to Codex; `provider_contract` uses fixed effort names, 0..2 temperature and at most ten attempts. `ragconfig` fixes 32 workers, four retrieval hops, eight claims/leads and 64 extracted mentions/relations/notes. | **Require a concrete technical reason for each bound.** Some reflect actual implementation capacity; others are arbitrary policy. Prefer driver-owned parameter handling and explicit operator limits, with batching/truncation information where appropriate. Do not blindly delete allocation or termination bounds. |

## Vetoes that have a defensible purpose

| Protection | Why it is justified | Scope that is justified |
| --- | --- | --- |
| Malformed response/schema, invalid numeric values, wrong vector length or incompatible embedding representation | The program cannot correctly interpret or search those bytes. | Reject the unusable result, retain the source and diagnostic, and continue independent work. Discover actual dimensions where supported; do not demand a manually maintained capability catalogue. |
| Missing source, invalid citation/span, unknown concept IDs, unsupported quotation | The stored index/claim would point to nonexistent or different evidence. | Refuse that graph promotion. This does not justify losing the source text or stopping unrelated indexing. Core exact-span requirements are explicit in AGENTS and architecture. |
| Active worker ownership, transactions, foreign keys, duplicate publication and checksum checks | Prevent races, corrupt indexes, lost updates and attaching results to the wrong input. | Keep one check at the owning transaction boundary. Avoid repeating equivalent checks or extending them to unrelated historical work. |
| Actual unsupported provider operation/driver, missing required authentication, invalid transport | There is no implemented way to perform that call correctly. Codex embedding and the current BGE-only native adapter are real implementation limits. | Validate at the selected adapter. Do not misrepresent an absent model catalogue entry as an unsupported provider operation. Avoid resolving unused credentials. |
| Explicit cancellation/pause, requested deadline, deliberate retry/call/spend limits | These are operator instructions. Respecting them makes the tool controllable. | Enforce the selected run's controls, not an unrelated run's history. Optional budgets need not become compulsory setup paperwork. A deadline that requires every call's full timeout to fit is stricter than a simple stop-starting-work boundary. |
| Pausing automatic retry after an outcome may already have consumed a paid call | Prevents an unattended duplicate call and preserves honest usage. | A deliberate retry must remain possible with the unknown earlier outcome retained. Current `retryrequested`/`retryblockeditem` already provides this escape; do not report the old unconditional veto as still present. |
| Evidence changed while applying a destructive graph edit | The previously selected object/effect may no longer be the one the caller meant. | Recheck the affected evidence and effects in the transaction; preserve the retained proposal for retry. Do not require whole-library identity equality. |
| Opt-in review/action/impact policy for autonomous graph restructuring | Useful when an operator explicitly wants to limit large automatic edits. | Keep it optional and limited to graph changes. It is not a prerequisite for text indexing, evidence retrieval or ordinary model configuration. |

## Executable checks

Candidate: `main` based on `6364011706330c91f72e430d2943b478b9929d01` plus the
uncommitted privacy repair. All probes use private files and synthetic sources;
no user library, live provider or resolved credential was involved.

| Probe | Observed result |
| --- | --- |
| Unmodified config/3, `provider list` | Pass; explicitly reports zero outbound requests. |
| Replace generation model with `operator-chosen-model`, retain other fields | Pass. No general model-name allowlist was found on this path. |
| Remove catalogue dates | Exit 3: requires `provider.gemini-generate.catalog_observed_date`. |
| Remove prices | Exit 3: requires `provider.gemini-generate.input_price_microunits_per_million`. |
| Remove unused advisory role | Exit 3: requires `role.advisory.provider`. |
| Select `../source-docs` | Exit 3: source root contains traversal or a control character. |
| Remove privacy metadata | Exit 3: requires `source.architecture-docs.privacy`. |
| `query inspect BillingService` on a copied fixture library | Pass: typed evidence retrieved. |
| Same lexical inspection, only worker count 2 → 3 | Exit 6: configuration changes have not been applied; requires config diff/plan. |

Retained probe configs and outputs:
`/var/folders/nr/7ckzqpl91kz80mcy3316h1tr0000gn/T/crexxrag-veto-review-20260922-5q5jwwsd`.
The query/worker compatibility, promotion and maintenance rows above are direct
source findings; they are not claimed as separately reproduced end-to-end cases.
Only the lexical mismatch has the additional executable reproduction listed.

Review/promotion is distinct from ingestion: several claim rules retain a
proposal in a review state rather than rejecting source text. They are included
because they prevent otherwise grounded assertions reaching the normal graph
without another decision. The recommendation is to preserve evidence and
uncertainty, not automatically treat every proposed assertion as established.

An unused `providerroutepolicy` class still exposes per-label permission fields
in the generic contract module. The source search found no callers or instances;
it is a legacy API remnant, not an additional active refusal on this path.

## Recommended order

1. Make provider selection simple: selected adapter/endpoint/model, authentication
   where needed, and optional generation parameters. Eliminate required privacy,
   price, observation-date and capability paperwork. Preserve existing files.
2. Decouple operations: a read validates its reader dependencies; an extraction
   validates its extractor; an unused advisory role is irrelevant.
3. Make configuration prospective without manual publication. Keep snapshots
   internally; constrain restart/replay compatibility to the actual request.
4. Remove promotion and maintenance policy masquerading as index integrity.
   Keep grounded assertions, alternatives and unresolved work inspectable, with
   optional graph curation controls where requested.
5. Retain the small set of technical integrity checks and explicitly chosen run
   limits, with an ordinary supported next action when a check fails.

These are review recommendations. Only the separately documented privacy-route
repair has been implemented in this working copy. The previous HC audit often
recommended additional configuration controls; that approach does not satisfy
the simpler product direction stated here.
