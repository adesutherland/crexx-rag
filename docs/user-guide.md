# User guide

## Local defaults

Run `crexxrag` in a folder containing:

- `crexxrag.conf` — simple text configuration;
- `source-docs/` — or another configured source root;
- `library/` — created automatically by `crexxrag init`.

`CREXXRAG_CONFIG` or global `--config-file PATH` overrides the local config.
Global `--library PATH` overrides `./library`.

Human output and terminal progress are the default. Use `--format json` or
`--format ndjson` for automation. `NO_COLOR=1` selects plain progress; explicit
`--progress off|plain|ansi` takes precedence.

## Human workflow

```sh
crexxrag doctor
crexxrag provider status
crexxrag init
crexxrag ingest
crexxrag query 'What does BillingService depend on?'
```

`ingest` shows source, privacy, provider, budget, worker count, and plan digest
before asking for confirmation. After approval it applies the reviewed plan,
starts the configured number of worker processes, and reports the final job and
vector state. `--yes` is intended for an already reviewed non-interactive run.

Re-running unchanged ingestion is an `identical-no-op`: no work and no provider
calls are made.

## Providers

```sh
crexxrag provider list
crexxrag provider status
crexxrag provider test --yes
crexxrag provider test gemini-embed --yes
crexxrag provider login codex
```

The smoke test uses fixed public synthetic text. It validates structured
generation and embedding shape while enforcing the configuration's combined
budget. It never sends library content.

Gemini credentials are normally configured as `env:GEMINI_API_KEY`. Codex login
is owned by Codex App Server. Never place credential values in a config file.

For local embeddings, start llama.cpp and configure an `openai-compatible`
provider at `http://127.0.0.1:8081/v1`. The terms are:

- embedding generation: converting text into vectors;
- vector-index publication: publishing the resulting `.rxvec` generation.

The tutorial includes a ready-to-copy Codex plus local-embedding configuration:

```sh
work_dir=$(docs/tutorial/setup.sh --no-build --provider codex-local)
```

## Workers

```sh
crexxrag worker list
crexxrag worker status WORKER_ID
crexxrag worker drain WORKER_ID
crexxrag worker prune --stale-seconds 30
```

Controllers and workers register PID, host identity, process-start token,
heartbeat, state, and current item in SQLite. Lists can therefore distinguish
local/remote, live/stale, idle/running, and stopped records. Pruning is explicit;
stale rows are not silently deleted.

Workers are operating-system processes, not attached cREXX threads. Each owns a
VM, provider process/session, and SQLite connection.

## Improvement and external proposals

```sh
crexxrag improve
crexxrag review list
crexxrag review show REVIEW_ID
crexxrag review decide REVIEW_ID --decision accept --apply
```

Normalized external claims use NDJSON and must declare `external: 1`:

```sh
crexxrag --access plan --format json \
  proposal plan --input proposals.ndjson
```

Automation then submits the exact returned `canonical_plan` and `digest` to
`proposal apply`. Apply only creates mandatory pending reviews. Accepting an
external review internalizes the proposal and runs the normal deterministic
claim validator before publication.

## Query

```sh
crexxrag query 'What does BillingService depend on?'
crexxrag --format json query evidence 'question' --mode lexical
crexxrag --format json query answer 'question'
```

Lexical mode makes no embedding call. Automatic mode reports provider fallback
truthfully if query embedding is unavailable. Explicit hybrid mode fails if its
required embedding route fails. Generated answers are rejected for unknown,
duplicate, or missing citations.

## Automation and MCP

Canonical commands separate planning, applying, and supervision:

```text
ingest plan / ingest apply
improve plan / improve apply
proposal plan / proposal apply
worker start / worker run
job list / job status / job events
query search / evidence / answer / trace / path / timeline
library status / verify / backup / restore
```

Start the same vocabulary over stdio MCP with:

```sh
crexxrag --access read serve mcp
```

Mutation tools are only advertised/accepted when the corresponding capability
is supplied. MCP is read-only by default.
