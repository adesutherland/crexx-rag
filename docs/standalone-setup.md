# Standalone human setup

This guide starts from an installed `crexxrag` package. It does not require a
source checkout, CMake, CREXX tools, or repository shell scripts.

## What the installation contains

Choose the prefix used when the package was installed. The relevant files are:

```text
<prefix>/bin/crexxrag
<prefix>/libexec/crexxrag/rag_address_environment.rxbin
<prefix>/share/crexxrag/tutorial/crexxrag.conf
<prefix>/share/crexxrag/tutorial/crexxrag-codex-local.conf
<prefix>/share/crexxrag/tutorial/architecture.glossary.tsv
<prefix>/share/crexxrag/tutorial/source-docs/architecture.txt
<prefix>/share/crexxrag/skills/
<prefix>/share/doc/crexxrag/
```

The examples use `/opt/crexxrag` below. Replace it with the actual prefix. A
user-writable prefix such as `$HOME/.local` is equally valid.

From a source checkout, the supported per-user installation is:

```sh
cmake --preset debug
cmake --build --preset debug --target install-local
```

That target builds and validates the native artifact and the separate ADDRESS
environment module before installing them to `$HOME/.local` by default. Ensure
`$HOME/.local/bin` is on `PATH` if you want to run the executable simply as
`crexxrag`.

## Gemini: the shortest complete route

Gemini is the hosted regression route and the simplest first end-to-end test.
The sample is deliberately public, contains one repeated relationship, and has
a two-call, $0.05 command budget.

Prepare a normal working folder:

```sh
mkdir -p "$HOME/crexxrag-demo/source-docs"
cp /opt/crexxrag/share/crexxrag/tutorial/crexxrag.conf \
  "$HOME/crexxrag-demo/crexxrag.conf"
cp /opt/crexxrag/share/crexxrag/tutorial/architecture.glossary.tsv \
  "$HOME/crexxrag-demo/architecture.glossary.tsv"
cp /opt/crexxrag/share/crexxrag/tutorial/source-docs/architecture.txt \
  "$HOME/crexxrag-demo/source-docs/architecture.txt"
cd "$HOME/crexxrag-demo"
export GEMINI_API_KEY='<Google AI Studio key>'
```

Confirm the installation and both configured provider roles before sending the
corpus:

```sh
/opt/crexxrag/bin/crexxrag doctor
/opt/crexxrag/bin/crexxrag provider status
/opt/crexxrag/bin/crexxrag provider test --yes
```

`provider test` sends fixed public synthetic text, not the library. It consumes
the configured small provider budget and validates both structured generation
and embedding shape.

The normal human workflow is four commands:

```sh
/opt/crexxrag/bin/crexxrag init
/opt/crexxrag/bin/crexxrag ingest
/opt/crexxrag/bin/crexxrag maintain
/opt/crexxrag/bin/crexxrag query 'What does BillingService depend on?'
```

`crexxrag` finds `./crexxrag.conf` and uses `./library` automatically. `ingest`
shows the source, hosted-data classification, models, workers, budgets, and
plan digest before it asks for confirmation. It then supervises the configured
worker processes and publishes the vector generation. `maintain` inventories
and ranks concept, claim, note, gap, embedding and vector work before asking for
approval; it then supervises only the selected bounded work. A repeated settled
cycle is an `identical-no-op` and makes no provider calls.

The answer should identify `CustomerDatabase` and carry a stable citation. To
inspect evidence without an answer-generation call:

```sh
/opt/crexxrag/bin/crexxrag --format json \
  query evidence 'What does BillingService depend on?' --mode lexical
```

Lexical mode makes no embedding or answer-provider call. It is the safest
diagnostic when a hosted provider or local embedding service is unavailable.

For an agent workspace, use the [MCP and skill setup](agent-integration.md)
and [corpus AGENTS.md template](templates/corpus-AGENTS.md). Ordinary MCP Q&A
uses `rag_query_inspect` and citation resolution, then the current assistant
composes the answer. The separate cREXX-RAG answerer shown in this human
walkthrough is for an explicit request to use or test it; it adds another
model generation step, latency and provider usage.

## Codex generation with local embeddings

This route uses a person's own ChatGPT-authenticated Codex allowance for
structured extraction and a local llama.cpp model for embedding generation.
Codex is still a hosted privacy route because source text ultimately leaves the
machine. The embedding route remains local.

First start an OpenAI-compatible llama.cpp embedding server in a second
terminal. This command uses the model expected by the packaged example:

```sh
llama-server \
  -hf nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M \
  --embedding --pooling mean -c 2048 -np 1 \
  --host 127.0.0.1 --port 8081
```

The first run may download the model. If it is already cached, llama.cpp uses
the local copy. Keep the server running while ingesting and querying.

Prepare a separate workspace:

```sh
mkdir -p "$HOME/crexxrag-codex-demo/source-docs"
cp /opt/crexxrag/share/crexxrag/tutorial/crexxrag-codex-local.conf \
  "$HOME/crexxrag-codex-demo/crexxrag.conf"
cp /opt/crexxrag/share/crexxrag/tutorial/architecture.glossary.tsv \
  "$HOME/crexxrag-codex-demo/architecture.glossary.tsv"
cp /opt/crexxrag/share/crexxrag/tutorial/source-docs/architecture.txt \
  "$HOME/crexxrag-codex-demo/source-docs/architecture.txt"
cd "$HOME/crexxrag-codex-demo"
```

Then authenticate and preflight the two routes:

```sh
/opt/crexxrag/bin/crexxrag provider login codex
/opt/crexxrag/bin/crexxrag provider status
/opt/crexxrag/bin/crexxrag provider test --yes
```

Codex App Server owns login, token storage, and refresh. `crexxrag` never asks
for or stores a bearer token. The plan and completed job report
`subscription-allowance`, Codex turn/token limits and remaining allowance
separately from monetary API cost.

Run the same human workflow:

```sh
/opt/crexxrag/bin/crexxrag init
/opt/crexxrag/bin/crexxrag ingest
/opt/crexxrag/bin/crexxrag maintain
/opt/crexxrag/bin/crexxrag query 'What does BillingService depend on?'
```

If Codex is installed outside its usual application location, set
`CREXXRAG_CODEX` to the absolute Codex executable path before running these
commands.

## Make `crexxrag` convenient

If `<prefix>/bin` is not already on `PATH`, add it using the normal mechanism
for the operating system or shell. After that, the commands above reduce to:

```sh
crexxrag doctor
crexxrag init
crexxrag ingest
crexxrag maintain
crexxrag query 'What does BillingService depend on?'
```

Keep each library in its own working folder. The local text config and local
library make the selected sources, providers, privacy rules, and budgets
visible and portable. Do not place credential values in the config; use only
symbolic references such as `env:GEMINI_API_KEY`.

## What to inspect when a run fails

Use the human commands before opening SQLite or adding scripts:

```sh
crexxrag doctor
crexxrag provider status
crexxrag worker list
crexxrag job list
crexxrag --access diagnose library verify
```

`worker list` distinguishes live, stale, local, and remote worker records.
`library verify` checks the database, manifest, generations, and vector
sidecars. Provider status redacts secrets and reports route, privacy, charging,
and Codex allowance state.

For provider-specific errors, run a single bounded smoke test only after
confirming that the configured budget and privacy route are appropriate:

```sh
crexxrag provider test gemini-generate --yes
```

The historical extra-Enter issue is fixed in installed CREXX `5ccf057a1633`;
pipe and real-terminal checks passed on 12 September 2026. See the
[repair history and verification](integration-issues.md#interactive-input).
After reviewing the plan, use `--yes` for explicit automation as usual.
