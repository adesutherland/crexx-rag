# Phase 3 Tutorial: Ingest With `crexxrag`

Status: maintained human walkthrough for the unpublished macOS application.
The default route uses Codex through your own ChatGPT subscription for one
structured extraction turn and a local `llama.cpp` Nomic model for embedding
generation. A bounded Google Gemini route is retained as the hosted-provider
qualification path. Exact Linux, release and cutover qualification remain open.

The application reviews the plan, starts independent worker processes, reports
progress and presents the result. The setup script only prepares the isolated
folder and, for the default route, starts the local embedding server.

## Set up once

From the repository root:

```sh
work_dir=$(./docs/tutorials/phase-3-ingestion/setup.sh)
cd "$work_dir"
```

This builds the native Level-G application and creates:

```text
<work-dir>/
├── crexxrag
├── crexx-rag.conf
├── stop-local-embedding.sh
├── .llama-servers/
└── source-docs/
    └── architecture.txt
```

The cached `nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M` model is served at
`http://127.0.0.1:8081/v1`. Setup waits for a real embedding smoke test before
returning. It does not start the unrelated local chat or advisory models.

## 1. Check the providers

```sh
./crexxrag provider status
```

Expected human output identifies both roles without exposing tokens:

```text
provider status
  provider id: codex-extract
  kind: codex
  charging basis: subscription-allowance
  state: ready
  allowance available percent: <current value>

provider status
  provider id: local-embed
  kind: openai-compatible
  model: nomic-embed-text-v1.5
  charging basis: local-compute
```

Codex App Server owns ChatGPT OAuth and token refresh. If the account is not
already authenticated, run:

```sh
./crexxrag provider login codex
```

Do not copy Codex bearer tokens into the config. Codex remains a hosted privacy
route because the public source text ultimately leaves this machine; only the
embedding text stays local.

The protocol and managed-authentication boundary follow the official
[Codex App Server documentation](https://learn.chatgpt.com/docs/app-server).

## 2. Create the library

```sh
./crexxrag init
```

`crexxrag` automatically finds `./crexx-rag.conf`, selects its only profile and
creates `./library`:

```text
OK: library initialized

library status
  schema version: 5
  state: initialized

config snapshot
  config id: phase3-codex-local-tutorial
```

An existing library is never silently replaced.

## 3. Ingest the source

```sh
./crexxrag ingest
```

Before changing the library or starting a model turn, the application displays
the reviewed route and ceilings:

```text
Ingestion plan

  Source set:       architecture-docs
  Source folder:    ./source-docs
  Data policy:      public
  Maximum calls:    2
  Input token limit: 65536
  Output token limit: 1024
  Worker processes: 2
  Extraction:       Codex using your ChatGPT subscription
  Embeddings:       Local llama.cpp / nomic-embed-text-v1.5
  Hosted data:      Public content only
  Codex allowance:  <current value>% available
  Codex turn limit: 1
  Charging basis:   Subscription allowance
  Monetary API cost: Not applicable
  Plan digest:      <sha256>
Continue? [y/N]
```

Answer `y`. The current installed CREXX runtime can require one additional
Enter after that answer because of the known interactive `LINEIN()` defect.
That limitation is accepted for now. `./crexxrag ingest --yes` skips only the
prompt; it retains the same plan/apply revalidation.

Two worker processes then claim the durable items through SQLite. The Codex
worker owns its own App Server child process, isolated empty working directory,
read-only sandbox, exact output schema and non-interactive approval policy. The
embedding worker opens its own SQLite connection and calls the local
OpenAI-compatible `/embeddings` endpoint. No process handle, App Server session
or credential is shared between workers.

In a colour terminal, progress is ANSI by default. It reports operation,
worker, provider and disposition identities without printing source bodies,
prompts, provider responses, credentials or authorization headers. Completion
should include:

```text
worker controller
  workers failed: 0
  vector generations: 1
  vector state: published

job status
  state: completed
  processed: 2
  dead letter: 0
```

Useful variants are:

```sh
./crexxrag --progress plain ingest
./crexxrag --progress off ingest
./crexxrag ingest --workers 1
./crexxrag ingest --yes
```

## 4. Ask for evidence

```sh
./crexxrag query 'What does BillingService depend on?'
```

The short command uses the canonical `query evidence` operation:

```text
OK: typed evidence retrieved; optional answer generation was not requested from a provider

query evidence
  candidate count: 1
  summary: billingservice --depends-on--> customerdatabase
  citation: crexx-rag:<library>:<source>:<revision>:utf8-0-87
```

The model response never writes graph state directly. cREXX validates the
candidate identities, types, directional relationship, confidence and exact
source support before promoting the proposal.

`vector state: disabled` on this Phase-3 evidence query is truthful: ingestion
has generated and published the chunk vector, but this command has not generated
a query vector. It therefore uses lexical and typed-graph retrieval. Query-side
embedding generation belongs to the later retrieval phase.

## Budgets, recovery and cleanup

The default configuration permits one Codex turn, one local embedding request,
65,536 input tokens (32,768 admitted for the Codex turn), 1,024 output tokens,
five minutes and no monetary API
spend. The reviewed plan also requires at least 10 percent Codex allowance to
remain before a new extraction turn starts.

Codex thread and turn identities are stored with the durable provider run. If a
worker dies after the turn completed, another fenced worker reads and validates
the completed output instead of spending a second turn. An incomplete turn is
interrupted/deleted and must pass the budget gate before a real retry. Expired
leases release their durable reservations. Completed and abandoned threads are
deleted; the application retains only the validated provider-run facts needed
for audit and recovery.

Running `./crexxrag ingest` again against unchanged input returns
`identical-no-op`: it creates no job, starts no workers and makes no provider
calls. To stop only the embedding server created in this tutorial workspace:

```sh
CPRAG_LLAMA_STATE_DIR="$PWD/.llama-servers" ./stop-local-embedding.sh
```

## Google qualification route

Google remains part of Phase-3 provider qualification. To create a separate
Gemini tutorial workspace:

```sh
google_work=$(./docs/tutorials/phase-3-ingestion/setup.sh --google)
cd "$google_work"
export GEMINI_API_KEY='<Google AI Studio key>'
./crexxrag provider status
./crexxrag init
./crexxrag ingest
./crexxrag query 'What does BillingService depend on?'
```

That reviewed config permits exactly one `gemini-3.5-flash-lite` structured
extraction request, one `gemini-embedding-2` request and $0.05. It also accepts
public content only. The credential remains an `env:GEMINI_API_KEY` reference.

## Automation and monitoring

Humans use the concise commands above. Scripts and agents retain the stable
operation vocabulary and JSON/NDJSON renderers:

```sh
./crexxrag --format json --access plan \
  ingest plan --source-set architecture-docs

./crexxrag --format json --access ingest \
  ingest apply --plan-json '<canonical-plan>' --expect-digest '<sha256>'

./crexxrag --format ndjson --access control \
  worker start --count 2 --job '<job-id>'
```

A second process using the same folder sees the SQLite-backed controller and
worker registry:

```sh
./crexxrag worker list --local --stale-seconds 15
./crexxrag job list
./crexxrag --access diagnose library verify
```

The database heartbeat is authoritative; a same-host PID check adds confidence
about local rows. Stale rows remain inspectable until explicit pruning.

Permanent QA uses deterministic provider fixtures and durable recovery tests.
The release qualification additionally runs one bounded Codex/local end-to-end
walkthrough and the bounded Google walkthrough; hosted calls are never part of
ordinary credential-free CTest.
