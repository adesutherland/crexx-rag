# Hard-coded configuration audit

**Status authority:** [the master register](ROADMAP.md) owns current status and
priority. This document retains dated evidence and detailed requirements; its
checkpoint labels and checklists are historical unless linked as current by the master.

See the [consolidated roadmap](ROADMAP.md#configuration-audit-reconciliation)
for all HC IDs reconciled with later repairs and overlapping requirements.
The inventory and source locations below retain the dated audit's evidence.

Recorded audit status: recovery and operator configuration repair qualified
(21/21 tests at that baseline); remaining policy backlog explicitly open.
This is an audit and repair record. Use the [user guide](user-guide.md) for
current controls and the [test strategy](test-strategy.md) for the maintained matrix.
Audit date: 2026-09-06
Scope: production Level-G application and provider sources under
`crexx/application` and `crexx/providers`; tests were used as evidence but are
not part of the runtime inventory.

## Conclusion

The concern is justified. The application has a sound configuration,
canonicalisation, plan and audit-history foundation, but runtime behaviour is
not consistently derived from it. Several important settings are duplicated
as literals in ingestion, maintenance, query, worker, vector and provider
paths. The 1,024-token extraction ceiling is one instance of a systemic issue,
not an isolated mistake.

The most serious findings are:

1. Ingestion and maintenance independently clamp extractor output to 1,024
   tokens even though the configured Gemini model catalogue says 65,536. A
   later provider layer separately clamps it to 4,096. The live Scottish run
   showed 326 invalid-JSON dead letters at this boundary.
2. The embedding dimension is repeated as the literal 768 in work input,
   profile identity, provider smoke output and CLI text. It is not selected by
   configuration or the model catalogue.
3. Profile prompt identifiers are configuration data, but the actual extractor,
   answerer and narrative prompts are compiled strings. Changing the profile's
   template id does not change the text sent to the model.
4. Model capabilities, defaults, observed dates and prices are compiled into
   `provider_catalog.crexx`, and price data is duplicated in separate lookup
   functions. Updating a price or model therefore requires a rebuild and can
   make cost admission and reporting stale.
5. Vector build and retrieval each impose a 64 MiB whole-sidecar ceiling. This
   is a near-term corpus scale limit and also contributes to RSS. It needs a
   configurable guard plus streaming/compact representation; merely raising
   the literal is not a safe fix.
6. Guided ingestion and maintenance force 100 ms polling for 100 polls. That
   is only ten seconds and is unrelated to the reviewed job time budget.

HC-01 through HC-08 are now resolved at the configuration/runtime boundary and
qualified without paid calls. Config/3 carries provider capabilities, effective
prices and observed dates directly; typed role bindings carry the execution
envelope and prompt text; guided waits and vector scale guards are explicit.
Formats 1 and 2 remain compatibility projections. Whole-sidecar loading remains
the separate RSS architecture item: the formerly hidden 64 MiB ceiling is now
configurable, but compact/streamed ANN storage has not been claimed complete.

The same coherent change also closes HC-09, HC-24, HC-25, HC-37 and the
next-batch portion of HC-48. The remaining P1/P2 rows are still the reviewed
closure backlog; the table preserves their original evidence so they do not
return as one-at-a-time discoveries.

The original full semantic-reingestion transition was a regression and is
superseded. Configuration changes apply prospectively through a reviewed
`config plan`/`config apply`. Unchanged source content remains an ingest no-op;
changing a prompt, model catalogue or operational setting does not enqueue the
existing corpus. Profile edits also apply prospectively; reinterpreting old
content requires a separately reviewed operation. See
[recovery defects](recovery-defects.md).

The 6 September operator repair adds prompt text files, configuration-relative
source/profile/glossary/prompt paths, editable standard profile TSVs with
explicit overrides, source file/depth guards and reviewed-plan TTL. Worker
commands use the configured polling interval. `config explain` exposes these
effective choices and labels compiled profile compatibility fallbacks. This
is runtime data loaded per invocation; no recompilation is needed to change it.
The complete 21-test suite passed on 6 September without paid calls. The
current work note is `/Users/adrian/testrag/transcripts/89-rag-recovery-and-operator-configuration.md`.
The changes remain uncommitted and are not installed in the user prefix.

## What is already correctly configurable

The following surfaces are already represented in `ragconfig`, parsed from
`crexxrag.conf`, validated, explained by `config explain`, and included in the
full/semantic/operational canonical forms as appropriate:

- source roots, include patterns, privacy, stable-key policy and raw retention;
- provider URL, model, route, privacy, credential reference, timeout, attempts,
  rate limits, concurrency, backoff and jitter;
- provider role bindings;
- command budgets for time, items, model calls, tokens, cost and Codex turns;
- worker process count, one-in-flight constraint and lease duration;
- discovery mode, glossary, candidate and output counts;
- ANN algorithm, centroids, probes, iterations and recall threshold;
- lexical/vector candidate counts, vector scan, graph hops and direction,
  evidence counts, RRF and the configured graph boosts;
- sparse-node and query-gap thresholds and bounded maintenance batch size;
- observation cooldown, staleness, churn thresholds and narrative output size;
- profile concept/relationship vocabulary, aliases, chunking, named ranking
  weights, prompt identities and validators.

Compatibility defaults remain for omitted settings and legacy profiles.
`config explain` reports effective operator values and profile origins;
`editable-gemini.conf` uses explicit profile files and external prompt text.
The remaining algorithm-specific policy literals are listed below.

## Runtime and semantic configuration findings

Priority meanings: P0 blocks the next paid corpus batch; P1 belongs in the
consolidated configuration repair; P2 is follow-on hardening. "Semantic" means
the value can change corpus meaning, selection or model output and must be
covered by semantic identity and exact plans. "Operational" means it changes
resources, timing or presentation and belongs in operational identity. "Guard"
means a documented defensive ceiling, not an operator tuning default.

| ID | Priority | Current hard-coded behaviour | Location(s) | Classification | Proposed authority |
|---|---:|---|---|---|---|
| HC-01 | P0 | Extractor input 8,192 tokens, or 32,768 for Codex; output 1,024; per-call cost 100,000 microunits | `ragingest.crexx:1313,1320-1324`; `ragproduct.crexx:2017-2020` | Semantic envelope plus operational budget | Explicit per-role execution policy; one shared derivation used by ingest and maintain |
| HC-02 | P0 | Provider execution applies another 4,096-token extraction clamp | `ragapplicationprovider.crexx:109` | Accidental duplicate | Remove; validate the reviewed work reservation against the selected model capability |
| HC-03 | P0 | Embedding dimension is 768 throughout durable inputs, repair work, profile ids, smoke tests and text | `ragingest.crexx:1396`; `ragimprove.crexx:367`; `ragmaintain.crexx:358`; `ragproduct.crexx:1049-1055,2085-2086`; `crexxrag_cli.crexx:364-365` | Semantic | `role.embedding.dimensions`, checked against catalogue and hashed into semantic config/work identity |
| HC-04 | P0 | Embedding per-call cost is capped at 1,000 microunits in four paths | `ragingest.crexx:1331,1392`; `ragproduct.crexx:1918`; `ragwork.crexx:1077` | Operational budget | One embedding role envelope; derive admission from configured price and remaining budget |
| HC-05 | P0 | Model records, capability limits, default models, dates and prices are compiled; prices are duplicated | `provider_catalog.crexx:73-127` | Reviewed external data | Versioned bounded `catalog.file`; one record per provider/model/effective date; catalogue digest in plans and provider runs |
| HC-06 | P0 | Actual extractor, answerer and report prompts are compiled strings despite profile prompt ids | `ragapplicationprovider.crexx:101`; `ragqueryprovider.crexx:41,62` | Semantic | Versioned prompt data files bound by template id; content digest in semantic config, work input and cache identity |
| HC-07 | P0 | ANN payload/build and retrieval read the entire sidecar with a 64 MiB ceiling | `ragembedding.crexx:228`; `ragretrieval.crexx` bounded sidecar read | Operational guard plus architecture | `vector.maximum_sidecar_bytes` as an explicit guard, followed by streamed/mapped compact storage so the guard does not define RSS |
| HC-08 | P0 | Guided workflows poll at 100 ms and stop after 100 polls | `crexxrag_cli.crexx:172-173,236-237` | Operational | Guided completion deadline derived from the reviewed time budget; explicit worker polling policy; terminal state is authoritative |
| HC-09 | P1 | Query input is capped at 65,536 tokens and generated answer at 1,024 independently of provider/model config | `ragquerypolicy.crexx:32,53` | Operational for answer, semantic for evidence envelope | `role.answerer.max_input_tokens` and `.max_output_tokens`, bounded by catalogue and total budget |
| HC-10 | P1 | Question length 4,096; alias alternatives 2; spelling census 512; edit distance 2 | `ragquery.crexx:128,234,265-280` | Semantic query policy | Versioned query-policy data referenced by config |
| HC-11 | P1 | Query intent terms and quoted-phrase markers are compiled English rules | `ragquery.crexx:307-310,366` | Semantic rule | Query-policy data now; RexxScript later only if rules need executable composition |
| HC-12 | P1 | Retrieval returns at most 8 analysis notes regardless of retrieval config | `ragretrieval.crexx:173` | Semantic selection | `retrieval.analysis_note_limit` |
| HC-13 | P1 | Lead construction reads 3 mentions per passage | `ragretrieval.crexx:597` | Semantic selection | `retrieval.lead_mentions_per_passage` |
| HC-14 | P1 | Diversity minimum 3, duplicate penalty .05, evidence-class weights .002/-.002 and temporal bonus .001 are compiled | `ragretrieval.crexx:476-497` | Semantic ranking | Named profile/query ranking weights, with defaults in profile data rather than code |
| HC-15 | P1 | Accepted-claim hop decay .75 and displayed confidence 1.0 are compiled | `ragretrieval.crexx` claim assembly | Semantic/evidence semantics | Named retrieval weights; confidence must be derived from support, not a display constant |
| HC-16 | P1 | Claim stance weights 1000/700/600/500/300 are constructed twice | `ragproposalio.crexx:141`; `ragprocess.crexx:535` | Semantic claim policy | Named profile claim weights; one policy builder |
| HC-17 | P1 | Claim promotion threshold is 500,000 millionths | `ragclaims.crexx:417` | Semantic validation | `claim.minimum_promotion_confidence_millionths` in profile/policy data |
| HC-18 | P1 | Extraction ranking uses compiled cue words and weights for concepts, novelty, redundancy, bridge, evidence class and unresolved risk | `ragclaims.crexx:386-397` | Semantic selection | Versioned extraction-ranking rules, populated by profile weights |
| HC-19 | P1 | Maintenance context includes exactly 8 query gaps and 8 prior notes | `ragimprove.crexx:390,406` | Semantic model context | `maintenance.context_query_gap_limit` and `.context_analysis_note_limit` |
| HC-20 | P1 | Maintenance priority bands and scoring formulae are compiled (990k, 980k, 950k, 940k, 900k, etc.) | `ragmaintain.crexx:120-213` | Semantic scheduling/rules | Versioned maintenance-policy data; critical repair bands must remain ordered by validation |
| HC-21 | P1 | Maintenance cognitive trigger list is compiled | `ragproduct.crexx:2031` | Semantic selection | `maintenance.cognitive_triggers` in policy data |
| HC-22 | P1 | Ingest work-item priority is always 100 | `ragingest.crexx:1402` | Operational scheduling | `ingest.work_priority`, validated relative to maintenance priority bands |
| HC-23 | P1 | Discovery fallback candidate limit is 100,000 when no config object is supplied | `ragingest.crexx:1299` | Accidental compatibility path | Remove unconfigured production ingestion; tests supply an explicit policy |
| HC-24 | P1 | ANN publication maximum rows is 1,000,000; embedding build items 100,000 and requested batch 1,024 | `ragproduct.crexx:1876`; `ragembedding.crexx:145,208` | Operational scale policy/guard | `vector.maximum_rows`, `embedding.maximum_items`, and catalogue-bounded `embedding.batch_size` |
| HC-25 | P1 | Gemini batch capability is separately fixed at 100 | `industrial_provider.crexx:28,85` | Provider/model capability | Read from the selected catalogue entry, not a protocol-wide literal |
| HC-26 | P1 | Source collection passes a 2,147,483,647-byte per-file ceiling; traversal depth is 64 | `ragproduct.crexx:1773,1815`; `ragfolder.crexx:32` | Connector operational/guard | `source.<id>.maximum_file_bytes` and `source.<id>.maximum_depth` |
| HC-27 | P1 | SQLite busy timeout is 5,000 ms; read-write journal is WAL; synchronous is FULL | `ragstore.crexx:732-746` | Operational storage policy, except foreign keys | `storage.busy_timeout_ms`, `.journal_mode`, `.synchronous`; keep `foreign_keys=ON` invariant |
| HC-28 | P1 | Backup uses SQLite backup arguments 128, 20 and 5 | `ragbackup.crexx:283` | Operational backup policy | Named `backup.page_batch`, retry and wait settings after confirming installed `rxsqlite` argument semantics |
| HC-29 | P1 | Provider admission adds 30 seconds lease grace and polls every 50 ms | `ragwork.crexx:622,636` | Operational concurrency | `worker.admission_lease_grace_seconds`, `.admission_poll_ms` |
| HC-30 | P1 | Worker defaults: poll 1,000 ms; list stale 15 s; prune stale 300 s; controller wait 1,000 ms | `ragproduct.crexx:1582,1630,1670,1743`; `ragprocess.crexx:446` | Operational | Extend worker policy; CLI options remain explicit overrides |
| HC-31 | P1 | Worker/process hard maxima 32 processes, 60 s poll, 1,000,000 polls and 3,600 s work lease differ from config validation | `ragprocess.crexx:322-424`; `ragwork.crexx:359,424` | Architecture guard plus inconsistent validation | One named invariant set and compatible config ranges; do not advertise `max_in_flight` as tunable while only 1 is implemented |
| HC-32 | P1 | Reviewed plan TTL is 3,600 s in foundation and config transition plans | `ragplanning.crexx:86,116`; `ragconfiguration.crexx:130-142` | Operational | `plan.ttl_seconds`, included in reviewed plan bytes |
| HC-33 | P1 | Report top defaults/max 10/20; trend 20/50; repository pages 20/100; maintenance status silently stops at 99/100 | `ragproduct.crexx:167-174,564-566,1121-1126,2121,2136` | Presentation/pagination | Output policy plus cursor pagination for maintenance; no silent truncation |
| HC-34 | P1 | Command renderer caps 100 records/fields, 65,535-byte values, 16 MiB plans, 1 MiB evidence and truncates human values at 240 | `ragcommand.crexx:268-328` | Presentation/guard | Named output policy; machine surfaces paginate or stream instead of failing complete valid results |
| HC-35 | P1 | Snapshot churn event weights remain compiled although thresholds are configured | `ragproduct.crexx:503-519` | Operational observation policy | Add named weights for semantic, vector, health, settlement, work, dead-letter, review and age changes |
| HC-36 | P1 | Graph health uses >50% isolated and >=90% relationship concentration; narrative response shape fixes 10 subjects | `ragproduct.crexx:348,668-677`; `ragqueryprovider.crexx` report schema | Reviewed reporting policy | `report.health.*`, `report.subject_limit`, and generated schema from policy |
| HC-37 | P1 | Provider smoke fixes embedding dimension 768 and generation output 128 | `ragproduct.crexx:1049-1060` | Qualification policy | Use configured embedding dimension and explicit `provider_test.output_tokens` |
| HC-38 | P1 | Compiled production registry supplies an architecture config and two profiles with hidden values | `config/architecture_local_config.crexx`; `config/profiles/*.crexx`; `config/operator_registry.crexx` | Hidden default configuration | Production registry loads bounded config/profile data; retain compiled objects only as test fixtures if needed |
| HC-39 | P1 | Profile prompt ids, ranking weights and chunk policy can be data-defined, but compiled profiles remain normal fallback | `operator_registry.crexx`; `generic_profile.crexx`; `it_architecture_profile.crexx` | Semantic fallback | Install equivalent `.profile.tsv` data and make selection explicit |
| HC-40 | P2 | Direct HTTP response wire limit is 8,650,752 bytes and receive chunk is 8,192 bytes | `provider_http.crexx:232-235` | Response guard and implementation buffer | Provider response guard derived from requested output/catalogue with bounded overhead; buffer remains a named internal constant |
| HC-41 | P2 | HTTP timeout is clipped to 600,000 ms and Anthropic API version is compiled | `provider_http.crexx:138,153` | Safety guard / protocol version | Keep maximum timeout as documented guard; move provider API version to catalogue/adapter version metadata |
| HC-42 | P2 | Anthropic silently uses 64 output tokens when a request omits a limit | `industrial_provider.crexx:239` | Hidden provider default | Reject missing generation limit at the application boundary or supply the explicit role policy |
| HC-43 | P2 | Codex adapter message/read/line/channel bounds and a 2,000 ms close wait are compiled | `codex_provider.crexx:102,281,320-384` | Adapter safety/operational | Name and document guards; expose only the close/wait deadline if operational evidence requires tuning |
| HC-44 | P2 | Config, profile, glossary and proposal parsers have fixed byte, line, entry and field ceilings | `ragconfigfile.crexx`; `ragprofilefile.crexx`; `ragglossary.crexx`; `ragproposalio.crexx` | Bootstrap safety guards | Central documented format limits. They cannot be configured by the file they protect; changes require a format-version decision, not ad-hoc literals |
| HC-45 | P2 | Plan input is limited to 65,535 bytes while rendering permits 16 MiB | `ragplanning.crexx:94`; `ragconfiguration.crexx:137`; `ragcommand.crexx:281` | Inconsistent guard | One plan-format limit plus compact plan representation; reject or paginate coherently |
| HC-46 | P2 | Folder extension/MIME mapping is compiled | `ragfolder.crexx:65-83` | Connector capability | Keep supported parsers as code capabilities; let include patterns choose files and report unsupported formats explicitly |
| HC-47 | P2 | Temporary Codex executable/path fallbacks and 32 directory-allocation attempts are compiled | `ragapplicationprovider.crexx:234-240`; `ragproviderdiagnostics.crexx:80` | Platform discovery/guard | Keep environment override; centralise platform discovery and name the allocation guard |
| HC-48 | P1 | Newer config keys are optional and obtain compiled defaults (discovery, vector, retrieval, maintenance, observation and provider rate policy) | `ragconfig.crexx:84,275-410`; `ragconfigfile.crexx:116-246` | Hidden compatibility defaults | `config/3` makes runtime choices explicit; older formats project and report labelled compatibility defaults |
| HC-49 | P2 | Generated proposal/note/answer fields have compiled size and count ceilings, including 131,072-byte proposals, 4,096-byte notes, 16,384-byte actions, 8,192-byte answers and 12 citations | `ragclaims.crexx:409`; `ragapplicationprovider.crexx:224`; `ragproduct.crexx:1086,1381-1383` | Provider-output safety and semantic response shape | Central response-contract limits; citation count derives from passage policy; guards are named and reported on failure |
| HC-50 | P1 | Analysis-note kinds, lifecycle operations, disposition object types/actions and maintenance review vocabulary are repeated in schema and validators | `ragschema.crexx`; `ragapplicationprovider.crexx:224`; `ragmaintain.crexx:439-491`; `ragclaims.crexx` | Semantic rules/schema | One versioned lifecycle/note policy generates both validation and schema constraints; policy digest is semantic |
| HC-51 | P1 | Dead-letter reconciliation follows at most 64 replay descendants | `ragschema.crexx:143` | Operational recovery policy/guard | `replay.maximum_lineage_depth`, with truncation made visible as a reconciliation issue rather than silently treated as terminal |
| HC-52 | P2 | Glossary discovery aborts after 100,000 candidate occurrences | `ragingest.crexx:650` | Operational scale guard | `discovery.maximum_candidate_occurrences`, included in the ingest plan and explained configuration |
| HC-53 | P2 | Direct claim traversal accepts at most 8 hops independently of query graph policy | `ragclaims.crexx:515` | Semantic traversal guard | Reuse an explicit traversal/query policy maximum; keep a documented absolute cycle-safety ceiling |

## Values that should remain invariants

Not every numeric or string literal is configuration. The following should stay
in code, but should be named centrally or documented so they cannot be confused
with operator policy:

- SQLite step result codes and transaction rules;
- HTTP success/retry status semantics and TLS requirements;
- boolean representations, array indexes and unit conversions;
- SHA-256 digest length, float32's four-byte width and schema version strings;
- foreign-key enforcement, exact source-span validation, directionality and
  provider-output distrust;
- stable public exit-code taxonomy and MCP/JSON-RPC protocol codes;
- absolute parser/bootstrap ceilings that protect the parser before
  configuration exists;
- architecture constraints that are genuinely not implemented, such as one
  in-flight item per worker VM. Such a constraint must not be presented as a
  user-tunable setting.

## Build and support configuration

The repository-wide pass also covered CMake and the local llama.cpp support
scripts. Build/test fixture ports, temporary paths and synthetic values are not
product runtime configuration. The actual build knobs (`CREXXRAG_BUILD_TESTS`
and `CREXXRAG_REXX_BUILD_JOBS`) are already CMake options/cache values. The
llama.cpp host, port, model, context, batch, ubatch, parallelism, cache and state
directory defaults are all overridable with named `CREXXRAG_*` environment
variables. They are not part of corpus configuration or its canonical history;
if local-provider launch becomes an application-owned workflow, those values
must move into a separately reviewed launcher configuration rather than being
copied into Level-G product policy.

## Proposed configuration structure

The current flat file can support the repair without introducing RexxScript.
RexxScript is not needed for simple values and tables. It remains an appropriate
future option only if operator rules require conditional composition.

The proposed additions are grouped rather than appended one literal at a time:

```text
format = crexx-rag.config/3
catalog.file = ./provider-catalog.tsv
prompts.file = ./prompts.tsv
query_policy.file = ./query-policy.tsv
maintenance_policy.file = ./maintenance-policy.tsv

role.extractor.provider = gemini-extractor
role.extractor.max_input_tokens = 8192
role.extractor.max_output_tokens = 4096
role.extractor.max_call_cost_microunits = 100000
role.extractor.temperature_millionths = 0

role.embedding.provider = gemini-embedding
role.embedding.dimensions = 768
role.embedding.batch_size = 100
role.embedding.max_input_tokens = 8192
role.embedding.max_call_cost_microunits = 1000

role.answerer.provider = gemini-answerer
role.answerer.max_input_tokens = 65536
role.answerer.max_output_tokens = 1024
role.answerer.temperature_millionths = 0

storage.busy_timeout_ms = 5000
storage.journal_mode = wal
storage.synchronous = full
backup.page_batch = 128

worker.poll_ms = 100
worker.guided_deadline_seconds = 0
worker.admission_poll_ms = 50
worker.admission_lease_grace_seconds = 30

vector.maximum_rows = 1000000
vector.maximum_sidecar_bytes = 67108864
source.scottish.maximum_file_bytes = 2147483647
source.scottish.maximum_depth = 64
```

These numbers show compatibility defaults, not recommended final tuning. The
extractor output default should immediately be raised from the defective 1,024
limit; the exact value will be selected from observed response sizes, budget and
the catalogue capability before implementation. `worker.guided_deadline_seconds
= 0` means derive the deadline from the reviewed job budget, not wait forever.

The first implementation keeps role prompts and provider catalogue records
inline in config/3. They are bounded data, not executable module names, and
their content enters the effective canonical configuration. Separate rule TSVs
remain the proposed P1 consolidation when the query, claim and maintenance rule
rows below are implemented.

## Canonical and migration rules

The implemented next-batch subset follows these rules for provider, role,
worker and vector settings. References below to storage, backup, presentation
and rule-policy data describe the retained P1 target, not completed coverage.

1. `config/3` requires the next-batch execution settings implemented in this
   change. Remaining P1/P2 policy is tracked explicitly below and is not yet
   represented as complete config/3 coverage.
2. `config/1` and `config/2` remain readable for compatibility. Their old
   defaults are projected explicitly into the effective canonical config and
   `config explain` marks each value as `compatibility-default`.
3. Extractor prompts, model, input/output envelope, embedding dimensions,
   query/extraction/claim/maintenance selection rules and profile weights enter
   semantic identity.
4. Timeouts, rates, worker/storage/backup settings, presentation limits and
   answer/report resource ceilings enter operational identity.
5. Every provider work item stores the resolved role envelope. Workers consume
   it; they do not recompute or lower it with private literals. Provider
   capability and price data enter the configuration snapshot identity.
6. The effective model capability is the intersection of configured policy and
   the selected catalogue entry. A mismatch fails during planning, before paid
   calls.
7. Prices carry a reviewed observation date. Provider usage persists the
   completion-time cost calculated from the active configuration snapshot, so
   later configuration changes do not rewrite historical usage.
8. Full and semantic hashes are provenance and change-detection identities;
   they are not corpus-invalidation instructions. Provider, prompt, route,
   source-selection and configuration-schema changes apply prospectively after
   review. Profile changes also apply prospectively. They never queue all
   visible chunks or invalidate historical evidence.

## Consolidated implementation and qualification

The next-batch repair was implemented as one coherent change:

1. Added typed role, provider catalogue, worker and vector scale settings;
   introduced required `config/3` keys and compatibility projection for older
   files. Storage, backup, output and rule-policy settings remain P1 backlog.
2. Extended canonical full, semantic and operational forms and configuration
   history for those implemented settings.
3. Refactored ingestion, maintenance, query, guided workers, vector publication
   and provider adapters to consume the resolved next-batch policy. Removed the
   duplicate extraction clamp and embedding cost fallback.
4. Added cross-path format/config, ANN, query, provider and evidence tests. A
   broader invariant allowlist/static test remains with the P1 policy migration.
5. The initial qualification exposed an invalid semantic-transition design:
   it derived ingestion identity from the full semantic hash and queued every
   visible chunk. That path was removed. Configuration changes are now applied
   prospectively with immutable audit history, while source ingestion retains
   a stable algorithm identity.
6. A zero-call regression applies a provider-policy change to an existing
   corpus and requires the next ingest to remain on the same generation with
   zero new jobs and zero provider calls. The same check is repeated against an
   independent generation-4799 Scottish-corpus backup.
7. Paid replay remains a separate explicit bounded action after qualification;
   it is never inferred from configuration churn.

## Operator repair on 6 September

The current change completes the following bounded operator and recovery work:

- configuration/profile edits apply prospectively; unchanged ingestion is a
  no-op even after model and chunk-policy changes;
- prompt files are loaded and content-hashed, relative paths use the config
  directory, and standard profiles have editable TSV equivalents with explicit
  override and origin reporting (HC-06, operator portion of HC-38/39/48);
- source byte/depth limits and plan TTL are configurable (HC-26, HC-32);
- worker run/start uses configured polling; work leases support the same
  1–86,400-second range as configuration (parts of HC-30/31);
- maintenance success/failure is reconciled per work item and repaired
  embeddings are checked at the current generation;
- maintenance status/inspect has complete cursor pagination (maintenance part
  of HC-33/34), and plan input/parser/renderer uses one 16 MiB format ceiling
  (guard inconsistency in HC-45). OS argument-size limits and large-plan RSS
  still require a compact/file-based plan design;
- public SQLite-only vector recovery and schema/manifest migration alignment
  are repaired; missing/corrupt sidecars never imply paid embedding work;
- the upstream compiler scaling defect is closed by the installed CREXX repair.

These are the top five remaining work groups, in order. They are **open**, not
claims that this pass fixed every algorithm or scale-policy literal:

1. A separately reviewed corpus replacement must stage its replacement until
   complete before changing the published query baseline (RAG-REC-001's
   remaining publication workflow). Configuration editing cannot request it.
2. Compact or streamed vector-sidecar and canonical-plan processing, with
   measured RSS at the full corpus scale (HC-07 architecture portion, HC-45).
3. Typed query, claim, ranking and cognitive-maintenance policy data, including
   evidence confidence derived from support (HC-10–23).
4. Storage/backup, provider-admission timing and the remaining worker/reporting
   operator settings (HC-27–31, remaining HC-33–36).
5. Central response/format contracts and explicit replay/traversal truncation
   handling (HC-40–44, HC-47, HC-49–53).

Below-cut queue: eliminating the legacy compiled registry entirely (HC-38/39),
complete explicit/default provenance for every optional key (HC-48), and
platform-specific installed replay. MIME parser capability selection (HC-46)
remains code by design; include filters select among supported formats.

The original table above is historical source evidence and proposed ownership;
this closure list states the current implementation boundary. See
[recovery defects](recovery-defects.md) for the vector-authority findings and
remaining publication workflow.

## Audit completeness rule

The source pass covered every production `.crexx` member in
`crexx/application`, `crexx/application/config`, `crexx/application/surfaces`
and `crexx/providers`. Literals were reviewed in four groups: resource/size
bounds, time/retry/concurrency values, ranking/selection/rule values, and
provider/model/protocol data. Literal zero/one values, SQL column ordinals,
schema field counts and identifier/hash widths were excluded only where they
are contract mechanics rather than runtime choices. Future reviews should use
the invariant allowlist and static regression test described above, so this
does not return to one-at-a-time discovery.
