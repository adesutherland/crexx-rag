# crexxrag

`crexxrag` is a human-first cREXX application for building a local evidence
library and typed knowledge graph from documents. SQLite is the durable source
of truth. Embedding vectors are rebuildable sidecars; they never create claims.

This repository now contains one product implementation. The former native
C++ prototype and its compatibility/migration material have been removed; Git
history remains the recovery mechanism.

## What it does

- discovers and incrementally ingests configured folders;
- uses validated LLM output to propose directional, source-supported claims;
- runs a configurable group of independent worker processes coordinated through
  SQLite;
- applies one durable cross-process provider admission policy for request,
  token, concurrency and retry pacing;
- publishes embedding generations and supports lexical, vector, and graph
  retrieval;
- reports generation-bound corpus, graph, provenance, vector, review and
  maintenance health, with an optional cached citation-validated advisory
  summary;
- retains churn-governed historic observation points and deterministic trends
  without duplicating unchanged or transient current-state reports;
- produces cited evidence and optional provider-generated answers;
- exposes the same operation vocabulary through the human CLI, JSON/NDJSON,
  `ADDRESS RAG`, and MCP;
- supports Gemini, ChatGPT-authenticated Codex App Server generation, and local
  OpenAI-compatible llama.cpp embeddings.

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
crexxrag maintain [--workers N] [--yes]
crexxrag review list
crexxrag --access control job replay JOB_ID [--item ITEM_ID] [--reason TEXT]
crexxrag library report [--top N] [--narrative off|cached|refresh] [--yes]
crexxrag --access control library snapshot [--trigger TYPE] [--reason TEXT]
crexxrag library trend [--limit N]
crexxrag query QUESTION
crexxrag provider list|status|test
crexxrag provider login codex
crexxrag config check|explain|diff
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

## Providers and privacy

Gemini is the tested hosted default. Codex generation uses the official local
App Server process, which owns ChatGPT login and token refresh; it is still a
hosted privacy route because source content leaves the machine. Local llama.cpp
embedding generation uses the OpenAI-compatible `/v1/embeddings` protocol.

Credentials are symbolic `env:NAME` references in configuration and are never
stored in the library. Subscription allowance, local compute, and monetary API
charging are distinct budget bases.

Configuration format 2 adds explicit per-provider request/minute,
token/minute, concurrent-request, initial/maximum-backoff and jitter controls.
`config check` and `config explain` compute split semantic/operational
identities without resolving credentials or making provider calls. A changed
configuration is classified and applied only through an exact reviewed plan;
semantic changes require a new ingestion generation.

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

The default suite covers native and linked applications, both CREXX VMs,
installed `rxsqlite` integration, multi-process workers, Gemini ingestion,
embeddings, maintenance, external proposal review/promotion, hybrid retrieval,
cited answers, deterministic and advisory library reports, provider budgets,
Codex App Server protocol, MCP, and negative provider-output cases. See [the
test strategy](docs/test-strategy.md).

The project is not yet released. Current platform and CREXX integration limits
are listed in [integration issues](docs/integration-issues.md).
