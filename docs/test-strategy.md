# Test strategy

The maintained suite tests the single shipping architecture rather than an old
implementation comparison.

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

The build declares the Level-G executable source cohort to CMake and invokes the
CREXX wrapper's incremental program mode once. CREXX supplies the sibling source
roots, bounded parallel compile wave, link barrier, content key, and atomic
publication. The independent `ADDRESS RAG` environment uses incremental library
mode. A repeated unchanged CMake build must report no work. Native packaging
uses the installed CREXX package's `rxsqlite` archive and native dependency
metadata directly.

## Default matrix

| Test | Main assurance |
| --- | --- |
| `linked_application` | installed `rxsqlite` provider mapping and both CREXX VMs |
| `configuration_contract` | format-1 compatibility, format-2/3 bounded settings, split identities, credential-free check/explain, identical/operational/prospective diff, tamper-resistant plan/apply, and a regression proving a provider-policy change leaves an existing corpus generation unchanged with zero new jobs or provider calls |
| `process_workers` | two-worker launch, observation, drain, stale PID detection, explicit pruning |
| `gemini_ingestion` | Gemini request/response mapping, compact gap-free LF/CR/CRLF normalization maps, durable work, claims, embeddings, vector publication, replay and failure paths |
| `gemini_extraction_validation` | invalid UTF-8 spans, unknown concept/relationship types and malformed extraction output dead-letter without product mutation or secret disclosure |
| `provider_durability` | reservation recovery, Codex turns, fencing, completed-turn reuse, durable cross-process admission, no false call record on preflight failure, immutable replay lineage, backlog reconciliation, and schema 1-to-9 migration with historic-cost backfill and prospective-transition auditing |
| `codex_protocol` | App Server initialize/account/turn/schema/usage/cleanup over JSONL |
| `codex_application` | public Codex extraction, worker-crash recovery from a persisted completed turn, duplicate-turn prevention, validation, allowance settlement and library verification |
| `gemini_maintenance` | hosted-style maintenance, glossary-drift rejection, durable cognitive notes, ANN publication/reuse, provider/profile discovery and external proposal review/promotion |
| `gemini_query` | query embeddings, hybrid retrieval, cited answers, deterministic library reporting, one-call cached advisory reporting with rejected-call history, churn-governed historic snapshots, duplicate coalescing, one-point trends, lexical zero-call and invalid citation rejection |
| `query_policy` | local/hosted privacy and every call/token/cost/allowance ceiling |
| `ann_methodology` | IVF-flat ANN publication/search, deterministic replay, bounded candidate work, recall against a frozen exact oracle and tamper fallback on both VMs |
| `lifecycle_methodology` | synonym, split, merge, type correction, retire/restore, exact impact census, migration-parent and atomic support/conflict handling on both VMs |
| `evidence_methodology` | outbound/inbound/both graph traversal without invented inverse claims, durable notes, leads and repeated query gaps on both VMs |
| `maintenance_methodology` | complete typed census, bounded deterministic ranking, stable worklist digest, generation binding and replay on both VMs |
| `native_surfaces` | human defaults, deterministic MCP reporting/snapshot/trend, configuration lifecycle, replay and external-schedule definition tools, and MCP structured-content/strict-argument behavior |
| `address_surface` | linked `ADDRESS RAG` report/trend/session/config/access behavior and snapshot denial on both VMs |
| `gemini_provider_smoke` | generation and embedding smoke, human/JSON/MCP, cancellation, aggregate budget, malformed output, secret redaction |
| `installed_product` | scratch-prefix installation, installed skills/tutorial, doctor/init/provider smoke/ingest/maintain/query using only installed product artifacts |
| `local_embedding_protocol` | llama.cpp-compatible `/v1/embeddings`, restricted local privacy, local-compute charging, and 429 `Retry-After` plus 503 exponential retry on both VMs and compiler modes |

The Gemini tests always exercise the Gemini adapter and Google request/response
shapes through a deterministic local fixture. Report tests additionally prove
that refresh makes one advisory call, cache reads make zero calls, unknown
citations are rejected and the previous valid cache survives. Historic tests
prove that the guided lifecycle captures a first point, exact duplicates are
suppressed/coalesced, a cached narrative is associated by report digests, and a
one-point trend refuses to infer direction. The suite does
not silently substitute a different provider. This makes the default suite
repeatable and zero-cost.

The CREXX repository owns the generic `rxsqlite` contract suite: typed values,
file databases, FTS, backup and integrity behavior, concurrent session
isolation, FULLMUTEX configuration, attached-task discovery, native packaging,
and installed external-consumer coverage. This suite does not duplicate those
driver tests. It proves that the linked, process-worker, backup, ingestion, and
installed native product paths consume the supported provider correctly.

## Live providers

Live calls are separate because they consume an external quota and require
credentials. Before a release candidate, run the native `provider test` against
the intended configuration, including Gemini even when Codex or local llama.cpp
routes are also under test:

```sh
export GEMINI_API_KEY='<key>'
cd docs/tutorial-work
./crexxrag provider test --yes
```

The reviewed configuration must bound calls, input/output tokens, timeout,
attempts, and either cost or subscription allowance. Test output must contain no
credential value.

## Change expectations

- Schema changes: fresh native build and all tests.
- Provider changes: Gemini ingestion/extraction-validation/query/smoke, Codex
  protocol/application/durability, local embedding protocol, policy tests,
  malformed output, and secret audit.
- Worker changes: process, ingestion, maintenance, replay, stale/prune tests.
- Public command changes: native surfaces plus the public discovery/proposal
  path inside `gemini_maintenance`.
- Documentation/config changes: tutorial setup and `crexxrag doctor` from the
  resulting folder.

## Configuration and derived-index preservation

The operator repair adds offline regressions for configuration-relative paths,
external prompt content identity, explicit standard-profile overrides, and
model/profile changes followed by unchanged ingestion. The query fixture
compares every existing SQLite table except the three configuration-history
tables before and after a reviewed model/profile change, including exact BLOB
encodings. It then checks old citations and database verification.

ANN methodology removes and corrupts sidecars and leaves an interrupted
recovery temporary; reconstruction and vector retrieval succeed with zero
provider runs. The public query fixture also exercises `vector rebuild`,
read-capability rejection, idempotent replay, and invalid-hybrid preflight
without any provider calls. The migration fixture opens a schema-8 bundle
through the ordinary write path and requires a schema-9 aligned manifest.

Maintenance methodology distinguishes successful and failed items within a
mixed-result job and recognizes embeddings repaired in a later generation.
The public maintenance fixture pages through more than 100 worklist items
with no duplicates or omissions, in both status and inspection operations.
