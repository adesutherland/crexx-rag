# Methodology closure checklist

This is the definitive acceptance list for the implemented `crexxrag`
methodology. A checked row requires executable QA evidence; source or prose
alone is not proof. The final closure run records the exact test result beside
every row.

| Done | Requirement | Implementation evidence | Required QA proof |
| --- | --- | --- | --- |
| [x] | Optional bounded UTF-8 glossary with canonical labels, types, aliases and exclusions | `ragglossary.crexx`, discovery configuration | `configuration_contract`: valid load plus malformed, duplicate, collision, exclusion and missing-file rejection |
| [x] | Ingestion plan freezes source observations, discovery policy and exact glossary bytes; drift fails before mutation/provider use | `ragingest.crexx`, `ragproduct.crexx`, `ragplanning.crexx` | `gemini_ingestion`: mutate glossary after plan, reject apply, restore exact bytes, then succeed |
| [x] | Maintenance plan freezes the discovery policy and exact glossary bytes; drift fails before mutation/provider use | `ragimprove.crexx`, `ragproduct.crexx` | `gemini_maintenance`: mutate glossary after plan and prove zero-call rejection before successful reviewed apply |
| [x] | LLM concept discovery is the normal ingestion route; deterministic capitalized-token discovery is a weak, explicitly selected fallback | `ragconfig.crexx`, `ragconfigfile.crexx`, `ragingest.crexx` | `configuration_contract` plus `gemini_ingestion`: modes/bounds parsed and reviewed all-chunk Gemini extraction executes |
| [x] | One extraction turn accepts zero through configured-many concepts, relationships and grounded notes | `ragapplicationprovider.crexx`, `ragwork.crexx` | `gemini_ingestion` and `gemini_maintenance`: two supported relationships in one response; zero-relationship maintenance response with a durable note |
| [x] | Every provider mention and relationship support uses validated exact UTF-8 spans; glossary identity/exclusions and profile registries are enforced | `ragapplicationprovider.crexx`, `ragclaims.crexx` | `gemini_ingestion`, `gemini_extraction_validation` and `configuration_contract`: positive exact spans plus dead-letter/no-mutation malformed span, unknown type/relationship, malformed output, glossary contradiction and exclusion cases |
| [x] | Analysis notes are durable typed objects with provider provenance, exact citations, uncertainty, importance and next action | `ragschema.crexx`, `ragwork.crexx`, `ragretrieval.crexx`, `ragevidencejson.crexx` | Evidence methodology test and `gemini_maintenance`: persist, retrieve and serialize a cited note without promoting it to a claim |
| [x] | Co-mentions remain analysis leads, query gaps are durable and repeated gaps become maintenance input | `ragretrieval.crexx`, `ragmaintain.crexx` | Evidence methodology test: lead/claim separation, repeated gap count and maintenance selection |
| [x] | Maintenance automatically inventories and deterministically ranks cognitive review, conflicts, sparse nodes, notes, query gaps, missing embeddings and missing ANN publication | `ragmaintain.crexx`, `ragimprove.crexx` | Maintenance methodology test: every item type, bounded ordering, stable digest/replay and exact generation binding |
| [x] | Reviewed maintenance executes bounded LLM diagnosis plus embedding repair/vector publication through durable workers and converges on replay | `ragproduct.crexx`, `ragmaintain.crexx`, `ragwork.crexx` | `gemini_maintenance`: plan/apply/workers/status, provider usage, ANN state, durable note and zero-call identical replay |
| [x] | Synonym, split, merge, type correction, retirement and restoration publish versioned canonical state | `ragmaintain.crexx`, lifecycle schema | `lifecycle_methodology`: every operation on both CREXX VMs with repository verification |
| [x] | Split and merge retain the old concept as a migration parent; uncertain connections stay on it | `ragmaintain.crexx` | `lifecycle_methodology`: migration-parent state, lineage and `keep-parent` dispositions |
| [x] | Structural apply requires the exact affected alias, mention, claim and note census; claim support moves atomically with its claim; retirement rejects unresolved impact | `ragmaintain.crexx` | `lifecycle_methodology`: exact-set rejection, atomic retirement failure, complete dispositions and no dangling active conflict/ambiguity state |
| [x] | Production vector retrieval is checksum-bound IVF-flat ANN; exact search exists only as a frozen QA recall oracle | `ragembedding.crexx`, `ragretrieval.crexx`, vector policy | `ann_methodology`: bounded candidates below total rows, deterministic publication, recall target and tamper fallback on both VMs |
| [x] | Graph retrieval supports outbound, inbound and both traversal while returned claims preserve stored direction and no inverse claim is invented | `ragretrieval.crexx` | Evidence methodology test: distinct route results and stored subject/relationship/object in all directions |
| [x] | Every semantic graph/catalogue change republishes or reuses a compatible generation-bound ANN index | `ragproduct.crexx`, `ragembedding.crexx` | Gemini ingestion, maintenance, accepted external proposal and lifecycle finalisation assertions |
| [x] | `crexxrag maintain` is human-first and the same plan/apply/status/inspect vocabulary is available in JSON/NDJSON, MCP and `ADDRESS RAG` | CLI, `ragmcp.crexx`, ADDRESS environment, `ragproduct.crexx` | Native surface, ADDRESS surface and Gemini maintenance tests, including strict MCP schemas/access gates |
| [x] | Installed agent skill is `crexxrag-maintain` and uses only the enduring maintenance tools/capabilities | `skills/crexxrag-maintain` and agent guide | Installed-tree audit plus MCP tool-list/call tests |
| [x] | Gemini remains the mandatory provider regression route; Codex App Server and local llama.cpp embeddings retain privacy, budget and durability guarantees | provider factory/adapters and configuration | Gemini smoke/ingest/maintenance/query, Codex protocol/durability, `local_embedding_protocol`, malformed-output and secret-redaction tests |
| [x] | Standalone native installation works from scratch with local config/default library and no workflow-owning shell scripts | native package, install rules, tutorial artifacts | Scratch-prefix install; `doctor`, `init`, provider smoke, ingest, maintain and query using installed `bin/crexxrag` |
| [x] | Methodology, user, agent, architecture and test documents describe only the implemented product surface and contain no product-methodology postponement list; the separate CREXX integration-issue ledger remains factual | `README.md`, `docs/`, `skills/` | Documentation audit for obsolete public `improve` surface and product-methodology postponement language, followed by `git diff --check` |
| [x] | Complete clean regression wall passes after all changes | build/test presets | Native build plus full CTest suite, both CREXX VMs where defined, library/repository verification and final feature-to-test cross-check |

The checklist is closed only when every row is checked and the final report
includes the build identity, test counts, provider routes exercised and any
external-call authority boundary.

## Closure evidence

The final independent build and regression wall completed on 2026-08-26:

| Evidence | Result |
| --- | --- |
| Build tree | New scratch build, independent of the maintained debug tree |
| CREXX package | `crexx-1.0.0-beta.3+local.g1fbd89dc9afb.dirty` from the installed package |
| Linked Level-G image SHA-256 | `1470b1a5036450f0a5523734d4cd454974ba6d669c0dc8b1407226d466c6bbf2` |
| Native `crexxrag` SHA-256 | `04dfb0a8915c4e230a42a133c84f209d0f0011cae8aa0e482d3ffce377346a90` |
| Full CTest result | 21/21 passed in 56.65 seconds |
| Installed product | Scratch-prefix install followed by installed-only doctor, init, provider smoke, ingestion, maintenance and query passed |
| Gemini route | Mandatory deterministic fixture exercised Google Gemini generation/embedding request and response shapes, positive workflows and negative validation |
| Codex route | App Server JSONL protocol, schema, subscription allowance, containment identities, cleanup and durable crash recovery passed against the deterministic fixture |
| Local embedding route | OpenAI-compatible llama.cpp `/v1/embeddings` protocol passed four compiler/VM cells with restricted local privacy and local-compute charging |
| External-call boundary | The closure wall made no hosted call and consumed no Gemini API or Codex subscription allowance; live calls remain an explicit, bounded operator action |

`git diff --check` completed without error after the implementation changes.
