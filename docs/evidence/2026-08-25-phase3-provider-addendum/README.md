# Phase 3 Provider Addendum Closure

Date: 2026-08-25

Platform: macOS 64

Outcome: accepted for the recorded Phase 3 macOS scope

## Scope

This evidence closes the Phase 3 provider addendum for the maintained Level-G
`crexxrag` application. It covers provider-kind dispatch, Codex structured
extraction through managed ChatGPT authentication, local embedding generation
through llama.cpp's OpenAI-compatible endpoint, human provider diagnostics,
subscription-aware budgets, durable external-turn recovery and exact vector
publication.

It does not authorize cutover, release, push, shared-account service use,
native-v1 removal or an exact Linux claim. Codex App Server remains an
experimental local-personal integration and a hosted privacy route because
source content leaves the machine.

## Build And Permanent QA

The qualification used the installed toolchain first:

```text
crexx-1.0.0-beta.3+local.g1fbd89dc9afb.dirty (macOS 64 20260824)
```

The installed-toolchain application build produced:

```text
linked Level-G application SHA-256:
048ef808f1c0b4eb16ce1e88b179ced50c302afb6fe0f623a86bfb87c8e8fad5

native application package SHA-256:
ca6883c4b42e8141f3e84c480847713a66632063aee46ab6f5658659b3889b00
```

The native package passed library initialization and two-worker supervision.
The complete downstream wall passed:

```text
ctest --test-dir cmake-build-installed-latest --output-on-failure
100% tests passed, 0 tests failed out of 82
Total Test time (real) = 414.60 sec
```

The recurring Phase 3 addendum tests include:

| Test | Durable proof |
| --- | --- |
| `p3r_01a_config_file` | Provider kinds, bounded configuration and symbolic secrets |
| `p3r_01b_process_framework` | SQLite-coordinated multi-process controller and workers |
| `p3r_02_gemini_ingestion` | Human and machine ingestion, provider dispatch, progress, child failure handling, exact vector publication and no-op replay |
| `p3r_03_provider_durability` | One-turn subscription reservation, completed-output reuse, stale-reservation release and worker fencing across both VMs with and without optimization |
| `p3r_04_codex_protocol` | App Server initialize, account/rate-limit reads, schema-constrained turn, usage, durable identities and thread deletion across both VMs with and without optimization |

## Bounded Codex And Local-Embedding Walkthrough

A clean tutorial workspace used public synthetic architecture text. The human
surface reported a managed ChatGPT account with 83 percent allowance available,
then completed:

- one Codex structured extraction turn using the exact extraction schema;
- one local `nomic-embed-text-v1.5` embedding request through llama.cpp;
- two independently supervised worker processes;
- one validated directional `depends-on` claim with exact source support;
- one published 768-dimensional vector generation;
- a cited answer to `What does BillingService depend on?`;
- clean `doctor` and library verification results.

The durable provider rows recorded `subscription-allowance` for Codex and
`local-compute` for llama.cpp. The Codex row retained its external thread and
turn identities until settlement, observed the allowance bucket at 17 percent
used before and after, recorded 17,417 input and 325 output tokens, and cleared
the recovery payload after success. The local embedding row recorded 24 input
tokens and no monetary API charge. The unchanged second ingestion was an exact
no-op: it created no job, worker item or provider call.

## Bounded Google Walkthrough

A separate clean workspace used the same public source and the maintained
Google route. It made exactly two approved calls:

- `gemini-3.5-flash-lite` structured extraction;
- `gemini-embedding-2` embedding generation.

Both provider rows succeeded with `monetary-api` charging, the generation row
recorded 926 input and 242 output tokens, and the job completed both items. The
library contained one validated claim and one published vector generation,
returned the same cited dependency, and verified cleanly. Its unchanged replay
also created no job, worker item or provider call.

## Containment And Retention

Each Codex worker owns its App Server child, JSONL connection and isolated empty
working directory. The turn uses a read-only/no-network sandbox, no interactive
approvals and the exact output schema; normal cREXX validation remains the only
route from provider output to a typed claim. App Server owns OAuth credentials
and refresh. No bearer token, API key, prompt transcript or raw model response
is retained in this evidence bundle.

The installed CREXX prompt may still require a second Enter. The accepted
`--yes` route bypasses only the terminal prompt, not reviewed plan/apply
validation. The downstream Codex method was also split below the currently
observed 255-local-register runtime boundary; that avoids the toolchain defect
without claiming to fix it.

The provider protocol follows the official
[Codex App Server documentation](https://learn.chatgpt.com/docs/app-server).
