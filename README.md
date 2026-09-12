# crexxrag

`crexxrag` turns a collection of documents into a local, inspectable evidence
library and typed knowledge graph. People and agents can explore the corpus,
ask questions with source citations, inspect uncertainty, and review proposed
corrections without losing the original evidence.

The method combines retrieval with gradual, validated knowledge construction.
An LLM proposes interpretations; the application checks their vocabulary,
direction, source support and provenance before they can enter the accepted
graph. SQLite holds the authoritative corpus, graph and work history.
Embeddings and rebuildable vector indexes help find evidence; similarity does
not establish a fact.

## How the method works

1. **Capture the sources.** Discover configured folders, retain immutable source
   revisions, normalize text and create addressable chunks. Unchanged inputs
   are reused. Document metadata remains linked to its source revision.
2. **Discover concepts and relationships.** Use a domain profile, optional
   glossary and bounded LLM extraction to propose typed concepts, directional
   claims and cited analysis notes.
3. **Validate before promotion.** Resolve quotations to original UTF-8 spans,
   check literal endpoints and permitted types, and route ambiguity, conflict
   and external proposals through review. Notes and co-mentions remain leads
   until a supported claim is accepted.
4. **Retrieve and answer.** Combine lexical, vector and graph retrieval into
   cited evidence. Inspect paths and timelines, or request an optional generated
   answer constrained to the supplied citations. Preserve unknowns and
   contradictory evidence.
5. **Improve the library.** Rank durable maintenance questions, investigate
   gaps, and review changes to concepts and connections. Split and merge
   workflows retain the old concept while its connections are reassigned;
   retirement requires the remaining impact to be accounted for.

For example, suppose a tutorial source says “BillingService accesses
CustomerDatabase.” The library can retain **BillingService → accesses →
CustomerDatabase**, supported by that exact source passage. A question can
follow the edge and resolve its citation. The passage supplies no reverse
relationship. If another source disagrees, the disagreement remains visible;
acceptance under the application's rules is not proof that either account is
true.

Time has several meanings: when a relationship held, when someone asserted it,
when a document was written or published, and when the system captured it.
Unknown dates stay unknown. A default document date is not an inferred event
date. Routine processing uses document metadata; per-support historical and
provenance assessment is a separate, explicit experiment. See the
[methodology](docs/algorithm.md) and [time and provenance contract](docs/time-and-provenance.md).

## Current capabilities

| Area | Supported behavior |
| --- | --- |
| Corpus understanding | Corpus overview, profile vocabulary, source citations, accepted claims, ambiguity, leads and coverage gaps |
| Retrieval and answers | Lexical, vector and graph retrieval; directional paths; timelines; optional citation-validated generated answers |
| Curation | Reviewed claim additions, synonyms, splits, merges, type corrections, connection changes, retirement and restoration |
| Difficult tasks | Explicit or repeated content-failure escalation to an advanced-reasoning queue; paged evidence exploration, bounded evidence refresh and exact resolution plans |
| Autonomous maintenance | Ranked worklists, configurable worker processes, bounded windows, durable leases, retries, review policy and auditable recovery |
| Operations | Shared admission and budgets, configuration checks before claims, supervised `job run`, digest-checked Codex outcome reconciliation, verification, generation-pinned backup/restore and historical trends |
| Interfaces | One operation vocabulary through the human CLI, JSON/NDJSON, `ADDRESS RAG` and MCP |
| Providers | Gemini, managed Codex App Server generation, and OpenAI-compatible routes including local llama.cpp embeddings |

## Work with Codex and other agents

An external Codex task can use MCP to understand the corpus and answer questions,
then investigate difficult maintenance tasks with the installed operating skills:

- `crexxrag-qa` explores evidence and gives cited answers;
- `crexxrag-resolve` investigates difficult tasks and prepares grounded corrections;
- `crexxrag-maintain` inspects and plans maintenance;
- `crexxrag-ingest` plans source ingestion;
- `crexxrag-diagnose` inspects library and provider health.

Start with `read,plan` access. `query inspect` and `library overview` support
exploration with no corpus writes or RAG provider calls. An agent can page task
evidence and original citations, prepare inline new-claim proposals, or plan a
complete evidence refresh when a task's packet is too small. Resolution
submission requires `curate` access and creates a mandatory review; acceptance
rechecks the evidence and uses the normal lifecycle engine.

The advanced-reasoning flag is independent of task priority. Workers can assert
it, repeated resolution-content validation failures can set it, and terminal
extraction-content failures create source-backed review tasks with links to
their rejected-output and correction history. Transport failures use job
recovery. The flag hands
work off for deeper investigation; it does not automatically launch a stronger
model. Missing source evidence may remain unresolved after that investigation.

An uncertain Codex provider call has a supported inspection and recovery path:
`job reconcile JOB_ID --item ITEM_ID` observes its exact retained thread and
turn. Applying the returned digest settles a confirmed terminal outcome once,
without generating another answer. Completed output still passes the normal
evidence validators. `job run JOB_ID` resumes eligible work using the existing
configuration, budget and restart ceiling. See the [operator workflow](docs/user-guide.md#jobs).

Codex **as an external corpus operator** is separate from Codex **as the
configured extraction provider**. Each has its own session, permissions and
usage. See [agent setup and contracts](docs/agent-integration.md) for project-local
MCP configuration, skill discovery, bounds and review controls.

## Build

An installed CREXX package containing the supported `rxsqlite` component is
required. CREXX supplies the SQLite implementation, dynamic provider, native
archive, and packaging metadata; no separate SQLite SDK is needed here.

```sh
cmake --preset debug
cmake --build --preset debug
```

CMake invokes the installed CREXX wrapper once for the executable application
source cohort. The wrapper resolves sibling source imports, compiles the members
in a bounded parallel wave, links after that wave succeeds, and reuses the
published project when its content key is unchanged. The separate `ADDRESS RAG`
environment is built with the wrapper's incremental library mode. CMake remains
the thin outer build for native packaging, installation, and QA.

The native application is produced at:

```text
cmake-build-debug/crexxrag-native/package/crexxrag
```

Install that native executable and its support artifacts into a chosen prefix:

```sh
cmake --install cmake-build-debug --prefix /path/to/prefix
```

The command is then `/path/to/prefix/bin/crexxrag`.

For the normal per-user installation, build the convenience target:

```sh
cmake --build --preset debug --target install-local
```

It installs to `$HOME/.local` by default, including the native executable at
`$HOME/.local/bin/crexxrag` and the separate ADDRESS environment module under
`$HOME/.local/libexec/crexxrag`. Set `CREXXRAG_LOCAL_INSTALL_PREFIX` at
configure time to give that target another prefix.

`crexxrag` is the only executable product name. The linked VM image and launcher
remain build/test artifacts for CREXX qualification.

## Try it with Gemini

The self-contained tutorial prepares a small public corpus and local config:

```sh
work_dir=$(docs/tutorial/setup.sh --no-build)
cd "$work_dir"
export GEMINI_API_KEY='<Google AI Studio key>'
./crexxrag init
./crexxrag ingest
./crexxrag maintain
./crexxrag query 'What does BillingService depend on?'
```

The local `crexxrag.conf` and `./library` are discovered automatically.
Interactive commands render human output and terminal progress; automation can
select `--format json` or `--format ndjson`.

Run `./crexxrag provider test --yes` before ingestion when you want a bounded
smoke test of both configured Gemini roles using public synthetic text.

For a ChatGPT-subscription plus local-embedding setup, use:

```sh
work_dir=$(docs/tutorial/setup.sh --no-build --provider codex-local)
```

## Main commands

```text
crexxrag init
crexxrag ingest [SOURCE_SET] [--workers N] [--yes]
crexxrag maintain [--minutes N | --until TIMESTAMP | --overnight HH:MM-HH:MM] [--workers N] [--yes]
crexxrag review list
crexxrag --access control job replay JOB_ID [--item ITEM_ID] [--reason TEXT]
crexxrag library report [--top N] [--narrative off|cached|refresh] [--yes]
crexxrag --access control library snapshot [--trigger TYPE] [--reason TEXT]
crexxrag library trend [--limit N]
crexxrag query QUESTION
crexxrag provider list|status|test
crexxrag provider login codex
crexxrag config show
crexxrag --access admin config set --key KEY --value TEXT --expect-sha256 SHA256
crexxrag --access admin config replace --input FILE --expect-sha256 SHA256_OR_missing
crexxrag config check|explain|diff
crexxrag config prompt --role extractor|resolution|answerer|advisory
crexxrag --access plan config plan --reason TEXT
crexxrag --access admin config apply --plan-json JSON --expect-digest SHA256
crexxrag profile list
crexxrag profile show PROFILE_ID
crexxrag schedule list
crexxrag schedule show SCHEDULE_ID
crexxrag doctor
crexxrag serve mcp
```

Canonical plan/apply, job, worker, review, proposal, and query operations remain
available for scripts and agents. Start with the
[standalone setup](docs/standalone-setup.md), then see the
[user guide](docs/user-guide.md), [agent integration](docs/agent-integration.md),
the [methodology and algorithm description](docs/algorithm.md), and the
[methodology closure checklist](docs/methodology-closure.md).

## Complete embedding coverage

Use `crexxrag maintain --embeddings-only --workers 8 --minutes 360 --yes` to
repair missing embeddings within the configured budgets while leaving extraction
and knowledge maintenance held. Workers share provider limits, durable cooldowns
and bounded retries. Stored vectors are reused before making a paid call.
Inspect coverage separately from the maintenance window's stop reason.
After workers drain, `crexxrag --access control vector rebuild --reconcile`
reconciles already covered queued work and duplicate links, preserves history,
and publishes from SQLite without provider calls. Finish with `library verify`.
See the [worker and recovery controls](docs/user-guide.md) for retry settings,
paused-job boundaries and the matching MCP operations.

## Providers and privacy

Gemini is the tested hosted default. Codex generation uses the official local
App Server process, which owns ChatGPT login and token refresh; it is still a
hosted privacy route because source content leaves the machine. Local llama.cpp
embedding generation uses the OpenAI-compatible `/v1/embeddings` protocol.

One selected `crexxrag.conf` is the operator policy entry point. `config show`
returns its hash and validation state; admin `config set` and `config replace`
validate before publishing changes. Role objectives are editable inline or via
referenced prompt files. Inspect `config prompt`, then review and apply the
library configuration transition for future work. See the
[policy-file workflow and platform limits](docs/user-guide.md).

Credentials are symbolic `env:NAME` references in configuration and are never
stored in the library. Subscription allowance, local compute, and monetary API
charging are distinct budget bases.

Configuration format 2 adds explicit per-provider request/minute,
token/minute, concurrent-request, initial/maximum-backoff and jitter controls.
`config check` and `config explain` compute split semantic/operational
identities without resolving credentials or making provider calls. A changed
configuration is classified and applied only through an exact reviewed plan;
changes apply prospectively without reingesting unchanged source content.

## Source layout

```text
crexx/application/   product policy, storage, jobs, retrieval, and surfaces
crexx/providers/     provider contract and provider adapters
tests/               provider fixtures and public-surface inputs
cmake/               build and regression orchestration
docs/                current architecture, use, testing, and tutorial
skills/              narrow MCP operating skills
```

An installed prefix also contains the tutorial configurations and corpus under
`share/crexxrag/tutorial`, the agent skills under `share/crexxrag/skills`, and
the user documentation under `share/doc/crexxrag`.

## Test

```sh
ctest --preset debug --output-on-failure
```

The default suite uses deterministic loopback provider fixtures and covers native and linked applications, both CREXX VMs,
installed `rxsqlite` integration, multi-process workers, Gemini ingestion,
embeddings, maintenance, external proposal review/promotion, hybrid retrieval,
cited answers, deterministic and advisory library reports, provider budgets,
Codex App Server protocol, MCP, and negative provider-output cases. See [the
test strategy](docs/test-strategy.md).

The 9 September MCP baseline passed all 30 local regression tests. Fresh Codex
trials also exercised corpus questions, task discovery, inline claims and
complete evidence refresh through the actual MCP server. Further trials on a
copy of the real soak corpus validated cited questions, a complete evidence
refresh and a reviewed connection correction. They also exposed remaining
backlog-discovery, effect-preview and final-retirement gaps. These are bounded
integration results; they do not establish historical accuracy, general
prompt-injection resistance or unrestricted unattended operation. See the
[synthetic trial record](docs/mcp-codex-trials.md) and
[copied-corpus results](docs/mcp-soak-trials.md) for artifact identities, measured
results and recommended repeat tests.

The project is not yet released. Current platform and CREXX integration limits
are listed in [integration issues](docs/integration-issues.md).
Development priorities and outstanding acceptance work are collected in the
[consolidated roadmap and defect register](docs/ROADMAP.md).
The [maintenance refactoring delivery](docs/maintenance-refactoring-delivery.md)
records current module ownership, operator-interface changes and the full
regression qualification for each separately committed stage.
Repeatable launch/resume and recovery without bespoke repair scripts remain an
open [high-priority hardening requirement](docs/recovery-defects.md#rag-ops-001--p1-routine-launch-and-recovery-must-be-product-operations).

Read-only operator diagnosis is available through `job items`, `job attempts`,
`maintain workflows --concept LABEL` and `maintain tasks --concept LABEL`.
See the [operator guide](docs/user-guide.md#find-work-and-failures-without-direct-sql)
and [module ownership](docs/architecture.md#report-observation-query-and-diagnostic-services).

Canonical operations and MCP argument contracts have one source owner,
`ragcommandcatalog`. Tool schemas, argument validation and forwarding are kept
together; the same catalogue supplies CLI operation recognition and library
requirements. See [module ownership](docs/architecture.md).
