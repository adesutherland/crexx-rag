# Phase 4 Application Extension Closure

Date: 2026-08-25

Platform: macOS 64

Outcome: accepted for the recorded Phase 4 macOS application scope

## Scope

This evidence extends the maintained Level-G `crexxrag` application through
Phase 4. It covers the human improvement command, configured extractor-role
dispatch, immutable provider-ready improvement inputs, OS-process worker
supervision, subscription and monetary budgets, truthful progress, and exact
replay suppression.

The work reuses the accepted Phase 4 claim, review, planning and worker
libraries. It does not repeat the completed overnight soak or broaden their
recorded scope. It does not authorize cutover, release, push, native-v1 removal
or an exact Linux claim.

## Implemented Surface

The normal human sequence is now:

```text
crexxrag init
crexxrag ingest
crexxrag improve
crexxrag query 'What does BillingService depend on?'
```

`crexxrag improve` creates and displays a read-only plan, obtains confirmation,
revalidates and applies its exact canonical bytes, starts the configured number
of OS-process workers, and reports the final durable job state. Canonical
`improve plan`, `improve apply`, `worker start` and `job status` commands remain
available for automation.

Configured apply now resolves `role.extractor`, not the first provider in a
configuration. Each selected chunk is persisted as an immutable
`crexx-rag.work-input/1` envelope containing the exact text and source span,
candidate catalog, configuration/profile/policy/prompt identity, provider
route/model/charging basis and reservation ceilings. Its digest is the durable
work identity. A repeated selection therefore returns `identical-no-op` before
a second job or provider call is created, even if its later rank changes.

Improvement-only work does not publish embeddings, so the human controller no
longer prints an irrelevant vector state. The Phase 3 tutorial setup also uses
an isolated installed-toolchain build directory and starts llama.cpp through a
macOS launch agent that remains alive after the setup shell exits.

## Build And Permanent QA

The qualification used the installed toolchain first:

```text
crexx-1.0.0-beta.3+local.g1fbd89dc9afb.dirty
```

The installed-toolchain application build produced:

```text
linked Level-G application SHA-256:
cb01012033d2d3c2e6aeabe904d358d2c2db408d6d000dee7a982b7a4f238aef

native application package SHA-256:
10dd29c2020fe7d84b92c96977ad1e7584a7a8acb9b3d6c7d537014581cf205c
```

The native package passed library initialization and two-worker supervision.
The complete downstream wall passed:

```text
ctest --test-dir cmake-build-installed-latest --output-on-failure
100% tests passed, 0 tests failed out of 83
Total Test time (real) = 416.09 sec
```

The Phase 4-specific recurring evidence is:

| Test | Durable proof |
| --- | --- |
| `phase4_improvement` | Both compiler modes and concrete VMs; claim/review behavior, leases/fences, two OS workers, retry/dead-letter, cancellation, reservations and the configured work-input envelope |
| `p4r_01_gemini_improvement` | Linked native application; human init/ingest/improve, concise progress, completed job, exactly three fixture requests, and zero-call improvement replay |
| `p3r_02_gemini_ingestion` | Regression protection for the preceding human ingestion path and exact vector publication |

The deterministic Gemini fixture observed exactly two ingestion requests and
one improvement request. The repeated human improvement returned
`identical-no-op`, with zero queued items and no fourth request.

## Bounded Codex Walkthrough

A clean public synthetic architecture library completed one configured Phase 4
improvement through Codex App Server and one supervised OS worker. The job
completed its single planned item with no dead letter. Its durable provider run
recorded:

- operation `improve-extraction`;
- provider `codex-extract`, profile `default`;
- charging basis `subscription-allowance`;
- 17,413 input and 249 output tokens;
- the allowance bucket at 19 percent used before and after;
- one external thread identity and one turn identity;
- cleared recovery state after successful settlement.

The resulting claim retained one independently addressable support. A repeated
`crexxrag improve --yes --workers 1` returned an exact zero-call no-op, and
library verification was clean.

## Bounded Google Walkthrough

A separate clean public synthetic library used the maintained Google route.
Initial ingestion completed one Gemini extraction and one Gemini embedding,
then Phase 4 completed one additional Gemini improvement extraction through a
supervised worker. All three provider runs succeeded with `monetary-api`
charging. The improvement row recorded 933 input and 242 output tokens. The
job completed its one planned item, its claim retained one independent support,
the unchanged improvement replay made no provider call, and library
verification was clean.

## Containment And Boundaries

Codex improvement retains the accepted containment boundary: each worker owns
its App Server child and isolated empty working directory, uses the exact
structured-output schema, permits no interactive approval, and passes output
through normal cREXX proposal validation. App Server owns managed ChatGPT
authentication. No credential, bearer token, raw response or transcript is
retained in this evidence bundle.

Gemini remains the bounded hosted regression route. Codex remains an
experimental local-personal integration and a hosted privacy route because
source content leaves the machine. Local llama.cpp remains the accepted Phase
3 embedding-generation route; Phase 4 improvement itself creates claims, not a
new vector-index publication.
