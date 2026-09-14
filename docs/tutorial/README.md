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

The folder now contains `crexxrag`, `crexxrag.conf`, the optional reviewed
`architecture.glossary.tsv`, and `source-docs/`.

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

## 3. Run a maintenance census

```sh
./crexxrag maintain
```

The preview ranks concept, graph, analysis-note, query-gap, embedding and vector
work. After approval it performs only the bounded worklist and republishes or
reuses the generation-bound ANN index. A settled replay makes no provider call.

## 4. Query

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

When setting up a Codex/MCP corpus workspace, follow the
[agent setup](../agent-integration.md) and
[corpus AGENTS.md template](../templates/corpus-AGENTS.md). Both are also
packaged under `<prefix>/share/doc/crexxrag/`. For ordinary Q&A,
the current assistant uses `rag_query_inspect`, follows evidence and resolves
citations, then writes the answer itself. Only use cREXX-RAG's own answerer
when explicitly requested: it adds another model generation step, latency and
provider usage. The shared QA skill includes the measured performance context.

Useful inspection commands are `./crexxrag worker list`, `./crexxrag job list`,
and `./crexxrag --access diagnose library verify`.

## Subscription-first alternative

Codex can provide structured generation through your own ChatGPT login while a
local llama.cpp server generates embeddings:

```sh
llama-server \
  -hf nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M \
  --embedding --pooling mean -c 2048 -np 1 \
  --host 127.0.0.1 --port 8081
work_dir=$(docs/tutorial/setup.sh --no-build --provider codex-local)
cd "$work_dir"
./crexxrag provider login codex
./crexxrag provider test --yes
./crexxrag init
./crexxrag ingest
./crexxrag maintain
```

The plan identifies Codex as a hosted public-only route, reports subscription
allowance rather than zero API cost, and identifies embeddings as local. Stop
the llama.cpp server with Ctrl-C when it is no longer needed.
