# Phase 3 Tutorial: Ingest With `crexx-rag`

Status: maintained human walkthrough for the Gate-3R-accepted, unpublished
macOS application. It uses the enduring native Level-G `crexx-rag` product.
Exact Linux, release and cutover qualification remain open.

This walkthrough makes two real Google Gemini calls against one public,
synthetic document. The application—not a shell script—reviews the plan, starts
the workers, reports progress and presents the result.

## Set up once

From the repository root:

```sh
work_dir=$(./docs/tutorials/phase-3-ingestion/setup.sh)
cd "$work_dir"
export GEMINI_API_KEY='<Google AI Studio key>'
```

The setup script builds the native application and creates a fresh isolated
folder containing:

```text
<work-dir>/
├── crexx-rag
├── crexx-rag.conf
└── source-docs/
    └── architecture.txt
```

The API key stays in the process environment. Do not put it in the config,
source, command line or captured output.

## 1. Create the library

```sh
./crexx-rag init
```

The command automatically finds `./crexx-rag.conf`, selects its only profile
and creates `./library`. Human output is concise:

```text
OK: library initialized

library status
  schema version: 4
  state: initialized

config snapshot
  config id: phase3-gemini-tutorial
```

An existing library is never silently replaced.

## 2. Ingest the source

```sh
./crexx-rag ingest
```

Before changing the library or contacting Google, the command shows the
reviewed route and ceilings:

```text
Ingestion plan

  Source set:       architecture-docs
  Source folder:    ./source-docs
  Data policy:      public
  Maximum calls:    2
  Maximum cost:     $0.05
  Worker processes: 2
  Provider:         gemini / gemini-3.5-flash-lite
  Provider:         gemini / gemini-embedding-2
  Plan digest:      <sha256>
Continue? [y/N]
```

The current installed CREXX runtime has a known interactive `LINEIN()` defect:
after entering `y`, this prompt can require one additional Enter. That upstream
limitation is accepted for now. `./crexx-rag ingest --yes` skips only the prompt
while retaining the same reviewed plan/apply boundary.

Answer `y` to apply that exact plan. The native application queues one embedding
and one claim-extraction item, starts two independent worker processes and waits
for the durable job to complete. Each process opens its own SQLite connection;
SQLite WAL, leases and fences coordinate them.

An interactive colour terminal gets ANSI progress by default. The progress
stream contains operation, worker, provider and disposition identities, but
never credentials, source bodies, prompts, provider responses or authorization
headers. At the end, the human result includes:

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

Useful variations are:

```sh
./crexx-rag --progress plain ingest   # stable plain-text progress
./crexx-rag --progress off ingest     # no progress stream
./crexx-rag ingest --workers 1        # one process, within the configured ceiling
./crexx-rag ingest --yes              # retain plan/apply, skip the y/N prompt
```

## 3. Ask for evidence

```sh
./crexx-rag query 'What does BillingService depend on?'
```

The short command uses the canonical `query evidence` operation. It reports the
supported directional claim and its exact source span without dumping the JSON
evidence envelope:

```text
OK: typed evidence retrieved; optional answer generation was not requested from a provider

query evidence
  candidate count: 1
  summary: BillingService --depends-on--> CustomerDatabase
  citation: crexx-rag:<library>:<source>:<revision>:utf8-0-87
```

The Gemini response does not write graph state directly. cREXX validates the
typed proposal and only promotes it when the endpoints, relationship and
independently addressable source support match the claimed work item.

The concise query can currently report `vector state: disabled` even though
ingestion published the `.rxvec` generation. This command has no provider-
generated query vector, so it correctly falls back to lexical and typed-graph
retrieval. Query-vector generation is a retrieval-phase concern, not missing
Phase 3 ingestion work.

## Configuration, calls and privacy

[`crexx-rag.conf`](phase-3-ingestion/crexx-rag.conf) is deliberately small and
human-editable. A fresh tutorial run permits exactly:

- one `gemini-embedding-2` request;
- one `gemini-3.5-flash-lite` structured-extraction request;
- 16,384 input tokens and 1,024 output tokens;
- 50,000 USD microunits ($0.05); and
- two minutes, one attempt per item.

The source is declared `public`, and both hosted routes are `public-only`.
The config stores only `env:GEMINI_API_KEY`. Missing credentials or a
non-public source fail before a provider socket is opened.

## Repeat and monitor

Running `./crexx-rag ingest` again reviews the source state and converges an
unchanged library without creating a job, starting workers, or making provider
calls. Its result says `identical-no-op`, `items queued: 0`, and omits a job id.
To exercise changed-source
ingestion, edit `source-docs/architecture.txt` and run the same command again;
the durable plan contains only the new delta.

While ingestion is active, a second terminal in the same work directory can
inspect the database-backed worker registry:

```sh
./crexx-rag worker list --local --stale-seconds 15
./crexx-rag job list
./crexx-rag --access diagnose library verify
```

The database heartbeat is authoritative. A same-host PID check is an additional
diagnostic. Terminal or stale rows are retained for inspection until an
operator explicitly prunes them.

## Machine and LLM use

Humans get the guided command by default. Scripts and agents retain the closed,
stable operation vocabulary and JSON/NDJSON renderers. They explicitly perform
reviewed plan/apply and worker supervision; guided `ingest` is intentionally
human-only:

```sh
./crexx-rag --format json --access plan \
  ingest plan --source-set architecture-docs

./crexx-rag --format json --access ingest \
  ingest apply --plan-json '<canonical-plan>' --expect-digest '<sha256>'

./crexx-rag --format ndjson --access control \
  worker start --count 2 --job '<job-id>'
```

JSON/NDJSON stdout remains byte-stable; opt-in progress is written to stderr.

## Recovery and credential-free QA

Work is durable. A failed item keeps its attempts and becomes a dead letter; it
is not silently retried. After correcting the cause, an operator can inspect
the job and explicitly requeue the exact item with canonical `job retry`.
Starting `crexx-rag` again against the same folder sees the same SQLite state.

The permanent product test covers both the canonical machine surface and the
three-command human surface without spending credits:

```sh
ctest --preset debug -R '^p3r_02_gemini_ingestion$' --output-on-failure
```

It runs two fresh libraries through a deterministic four-request Gemini
loopback and proves native execution, automatic defaults, confirmation-safe
plan/apply, two concurrent worker processes, extraction, 768-dimensional
embedding, automatic immutable vector publication, validated claim promotion,
exact citation, truthful zero-work replay, non-empty controller failures,
concise human output, stable machine JSON, sanitized progress and credential-
value absence.
