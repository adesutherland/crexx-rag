# Ingest and query a small architecture corpus

This walkthrough uses Gemini for both structured extraction and embedding
generation. The sample text is public and the config caps each command to two
provider calls and $0.05.

## 1. Prepare the folder

From the repository root, after building `crexxrag`:

```sh
work_dir=$(docs/tutorial/setup.sh --no-build)
cd "$work_dir"
export GEMINI_API_KEY='<Google AI Studio key>'
```

The folder now contains only `crexxrag`, `crexxrag.conf`, and `source-docs/`.

Optional preflight using public synthetic text:

```sh
./crexxrag provider test --yes
```

## 2. Initialize and ingest

```sh
./crexxrag init
./crexxrag ingest
```

The ingestion preview shows the source set, public-only hosted-data policy,
Gemini extraction and embedding models, provider-call/cost ceilings, worker
count, and canonical plan digest. After confirmation, terminal progress follows
source discovery, durable queueing, both worker processes, provider calls, and
vector publication.

Running `./crexxrag ingest` again should report an identical no-op and make no
provider calls.

## 3. Query

```sh
./crexxrag query 'What does BillingService depend on?'
```

The answer must name `CustomerDatabase` and include a stable source citation.
To see evidence without answer generation:

```sh
./crexxrag --format json query evidence \
  'What does BillingService depend on?' --mode lexical
```

That route reports `provider_calls: 0`.

Useful inspection commands are `./crexxrag worker list`, `./crexxrag job list`,
and `./crexxrag --access diagnose library verify`.

## Subscription-first alternative

Codex can provide structured generation through your own ChatGPT login while a
local llama.cpp server generates embeddings:

```sh
scripts/start_local_llama_servers.sh --embedding-only
work_dir=$(docs/tutorial/setup.sh --no-build --provider codex-local)
cd "$work_dir"
./crexxrag provider login codex
./crexxrag provider test --yes
./crexxrag init
./crexxrag ingest
```

The plan identifies Codex as a hosted public-only route, reports subscription
allowance rather than zero API cost, and identifies embeddings as local. Stop
the server with `scripts/stop_local_llama_servers.sh` when it
is no longer needed.
