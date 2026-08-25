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
- publishes embedding generations and supports lexical, vector, and graph
  retrieval;
- produces cited evidence and optional provider-generated answers;
- exposes the same operation vocabulary through the human CLI, JSON/NDJSON,
  `ADDRESS RAG`, and MCP;
- supports Gemini, ChatGPT-authenticated Codex App Server generation, and local
  OpenAI-compatible llama.cpp embeddings.

## Build

An installed CREXX package and SQLite development library are required.

```sh
cmake --preset debug
cmake --build --preset debug
```

The native application is produced at:

```text
cmake-build-debug/crexxrag-native/package/crexxrag
```

Install that native executable and its support artifacts into a chosen prefix:

```sh
cmake --install cmake-build-debug --prefix /path/to/prefix
```

The command is then `/path/to/prefix/bin/crexxrag`.

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
crexxrag improve [--workers N] [--yes]
crexxrag review list
crexxrag query QUESTION
crexxrag provider list|status|test
crexxrag provider login codex
crexxrag profile list
crexxrag profile show PROFILE_ID
crexxrag doctor
crexxrag serve mcp
```

Canonical plan/apply, job, worker, review, proposal, and query operations remain
available for scripts and agents. See [the user guide](docs/user-guide.md).

## Providers and privacy

Gemini is the tested hosted default. Codex generation uses the official local
App Server process, which owns ChatGPT login and token refresh; it is still a
hosted privacy route because source content leaves the machine. Local llama.cpp
embedding generation uses the OpenAI-compatible `/v1/embeddings` protocol.

Credentials are symbolic `env:NAME` references in configuration and are never
stored in the library. Subscription allowance, local compute, and monetary API
charging are distinct budget bases.

## Source layout

```text
crexx/application/   product policy, storage, jobs, retrieval, and surfaces
crexx/providers/     provider contract and provider adapters
native/sqlite/       generic RXPA SQLite provider
tests/               provider fixtures and public-surface inputs
cmake/               build and regression orchestration
docs/                current architecture, use, testing, and tutorial
skills/              narrow MCP operating skills
```

## Test

```sh
ctest --preset debug --output-on-failure
```

The default suite covers native and linked applications, both CREXX VMs,
SQLite thread/session isolation, multi-process workers, Gemini ingestion,
embeddings, improvement, external proposal review/promotion, hybrid retrieval,
cited answers, provider budgets, Codex App Server protocol, MCP, and negative
provider-output cases. See [the test strategy](docs/test-strategy.md).

The project is not yet released. Current platform and CREXX integration limits
are listed in [integration issues](docs/integration-issues.md).
