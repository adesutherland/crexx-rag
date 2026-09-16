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

**Status: approaching a first release — 15 September 2026.** The core
architecture, public interfaces and recovery workflows are implemented. The
installed baseline passed **79/79 local tests**, and five smoke workflows
have been repeated on a disposable copy of a real historical corpus, including
**59 successful MCP requests**. Release preparation now centres on the remaining
content-quality findings and wider operational/platform qualification. See
[testing and release readiness](#testing-and-release-readiness) for the evidence
and remaining work.

The [Scottish overnight soak](docs/test7-overnight-soak-20260914.md) exercised
imports, embeddings, source-scoped extraction, backlog processing and recovery
on the master corpus. The completed repairs are committed and installed there;
the [publication record](docs/publication-20260915.md) owns the current identity.
Content failures and long-run qualification remain. The
[controller investigation](docs/t7-10-controller-diagnosis-20260915.md) links two
losses to host task resumption and independently reproduces broken-output and
signal-handling defects. Their candidate repair and regression results are
tracked there; this repaired night is not a clean endurance pass.

The [job-controls repair](docs/job-controls-delivery-20260915.md) adds deadline-only
updates, admitted-work continuation after expiry and explicit one/all-job retry
resets, and makes all job lists compact. The combined candidate passes **79/79
local tests**, including the controller repairs. Its completed checklist retains
the evidence. Scottish installation and read-only MCP acceptance pass; a fresh
soak remains the next operational qualification.

For operational diagnosis, safe retry, reasoned waivers and migration completion,
follow the [public recovery journey](docs/public-recovery-journey.md).

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

## Implementation and architecture

The product is one **Level-G cREXX application**, packaged as the native
`crexxrag` executable. Product algorithms, SQL repositories, migrations,
provider selection and orchestration live in cREXX. The installed CREXX package
owns the generic `rxsqlite` provider and SQLite implementation.

Shared domain modules now own claim policy, effective prompts and response
contracts, query/report services, command metadata and configuration. CLI,
JSON/NDJSON, MCP and `ADDRESS RAG` compose those same owners. The SQL review
also addressed missing indexes, repeated corpus reads,
queries inside loops and unbounded maintenance preparation. The common
[architecture and data-access rules](docs/architecture.md) describe how these
decisions are maintained; the [refactoring delivery](docs/maintenance-refactoring-delivery.md)
and [SQL repair record](docs/sql-performance-delivery-20260913.md) retain their
regression evidence.

SQLite is authoritative for source revisions, claims, jobs, attempts and
provider receipts. Workers use separate processes and SQLite connections.
Restart uses one cleanup/start path with fresh workers, preserving completed
work and recorded usage. Replay compares the configuration relevant to the
selected work, so an unrelated new source does not block an old item's retry.

Search availability follows successful work independently: a failed item does
not withhold other stored embeddings, and existing documents remain searchable
while new work proceeds. Index activation runs when a worker group ends, and
ordinary `job run JOB_ID` also finishes outstanding activation. A database
mutation marker lets unchanged retries reuse the existing vector index;
`vector rebuild` explicitly forces a rebuild.

## Work with Codex and other agents

An external Codex task can use MCP to understand the corpus and answer questions,
then investigate difficult maintenance tasks with the installed operating skills:

- `crexxrag-qa` explores evidence and gives cited answers;
- `crexxrag-resolve` investigates difficult tasks and prepares grounded corrections;
- `crexxrag-maintain` inspects and plans maintenance;
- `crexxrag-ingest` plans source ingestion;
- `crexxrag-diagnose` inspects library and provider health.

For ordinary MCP questions, the current assistant retrieves evidence, follows
relevant graph leads, resolves citations and writes the answer itself.
cREXX-RAG's own answerer is for explicit requests to use or test it and adds a
separate model generation step, latency and provider usage. See the
[agent setup](docs/agent-integration.md) and the
[corpus workspace template](docs/templates/corpus-AGENTS.md), based on the
ScottishHistory setup.

Start with `read,plan` access. Use library status and source inventory for
routine setup, then `query inspect` for read-only lexical evidence with no
provider calls or vector-index preparation. Use `library overview` for an
explicit coverage or health question; its full verification is unnecessary
setup work for ordinary Q&A. The supplied passage default is **12**, with an
optional maximum of **200** for a broader search that the agent filters.
Candidate availability and the configured response-size ceiling still apply.

An agent can page task evidence and original citations, prepare inline new-claim
proposals, or plan a complete evidence refresh when a task's packet is too small. Resolution
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
crexxrag --access control job run JOB_ID
crexxrag --access control job replay JOB_ID [--item ITEM_ID] [--reason TEXT]
crexxrag library report [--top N] [--narrative off|cached|refresh] [--yes]
crexxrag --access control library snapshot [--trigger TYPE] [--reason TEXT]
crexxrag library trend [--limit N]
crexxrag query QUESTION
crexxrag query inspect QUESTION [--limit 200] [--hops 0]
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
Successful vectors are activated automatically when the worker group ends,
including when another item fails. If activation is interrupted, repeat
`crexxrag --access control job run JOB_ID`; completed items make no new provider
calls, and an unchanged index is reused. For explicit reconstruction and cleanup,
`crexxrag --access control vector rebuild --reconcile` reconciles already covered
queued work and duplicate links, preserves history, and publishes from SQLite
without provider calls. Use `library verify` to check integrity after recovery.
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

## Testing and release readiness

```sh
ctest --preset regression --output-on-failure
```

The latest full local suite passes **71/71**. It uses deterministic local
provider fixtures and covers native and linked applications, both CREXX VMs,
installed `rxsqlite` integration, migrations, process workers, interruption and
retry, independent vector publication, Gemini and Codex protocols, maintenance,
external review, hybrid retrieval, exact citations, MCP/CLI/ADDRESS contracts,
budget accounting, malformed output and secret redaction. New behavior is
covered before implementation, with failing reproductions and positive controls
for defect repairs. See the [test strategy](docs/test-strategy.md) and
[latest full-suite evidence](docs/qa/test5-followups-20260914/README.md).

The [14 September Tests 1–5 repeat](docs/smoke-tests-1-5-20260914.md) used committed
baseline `696858c` and the same tested native artifact, starting from a fresh
pre-repair backup:

| Smoke workflow | Result |
| --- | --- |
| 1 — Missing embeddings | All five repaired; automatic index activation succeeded. |
| 2 — New document | Import, extraction, embeddings, indexing, exact citation, completed-job retry and repeat-import no-op passed. |
| 3 — Bounded maintenance | Workers completed within the allowance; one decision resolved, two remained explicitly unresolved and one identity choice was rejected. |
| 4 — Extraction replay | Both selected holds resolved under normal configuration; one used its ordinary correction turn. A figurative-place classification remains a content-quality finding. |
| 5 — Agent access and Q&A | All 59 MCP requests passed: access controls, search, relationship paths, citation paging and passage limits; no RAG provider calls or ordinary Q&A writes. |

Final verification found **zero integrity issues**, with **34,907 indexed chunks
across nine sources**. Original source/history rows and provider receipts were
preserved, all workers stopped, and no manual index repair or temporary source
configuration workaround was needed. The 200-passage maximum also has a
synthetic regression that returns and resolves all 200 passages. Performance
observations retain CPU, work counts and response sizes; timings on the shared
computer are not release gates or latency guarantees.

The implementation and repeated operational results put the project close to a
first release. Remaining work is explicit:

- **Content interpretation and rule agreement:** review the figurative phrase
  classified as a place and the maintenance target present in the wider
  catalogue but rejected by the narrower candidate-selection rule. Both are
  tracked in the [smoke follow-up checklist](docs/smoke-tests-1-5-20260914.md#content-follow-ups).
  Grounded quotations and successful processing do not guarantee correct
  historical interpretation; uncertainty and review remain part of the product.
- **Wider operational qualification:** complete the outstanding operator and
  outage cases and qualify broader unattended use. Bounded corpus smokes do not
  establish unrestricted autonomous operation. The
  [consolidated roadmap](docs/ROADMAP.md) owns the remaining acceptance work.
- **Platform qualification:** the installed Linux hosted-provider replay and
  non-macOS policy replacement remain separate checks. The
  [integration record](docs/integration-issues.md) also states accepted policy-file
  metadata and power-loss limitations. Local macOS results do not close these.

This is the current pre-release baseline; a formal release has not been declared.

Read-only operator diagnosis is available through `job items`, `job attempts`,
`maintain workflows --concept LABEL` and `maintain tasks --concept LABEL`.
See the [operator guide](docs/user-guide.md#find-work-and-failures-without-direct-sql)
and [module ownership](docs/architecture.md#report-observation-query-and-diagnostic-services).

Canonical operations and MCP argument contracts have one source owner,
`ragcommandcatalog`. Tool schemas, argument validation and forwarding are kept
together; the same catalogue supplies CLI operation recognition and library
requirements. See [module ownership](docs/architecture.md).

Interrupted processing uses the [operator continuation journey](docs/operator-continuation.md):
inspect actual source/operation progress, retain retry/receipt history and use
named allowance periods when explicitly renewing work. The
[live delivery handoff](docs/operator-continuation-handoff.md) records current
qualification, corpus smoke results and the next outstanding work.
