# Phase 5 Application Extension Closure

Date: 2026-08-25

Platform: macOS 64

Outcome: accepted for the recorded Phase 5 macOS application scope

## Scope

This evidence extends the maintained native Level-G `crexxrag` application
through the already accepted Phase 5 retrieval and evidence algorithms. It
covers compatible query embedding generation, hybrid retrieval, optional
configured answer generation, exact context/citation validation, human and
machine output, privacy, budgets and provider consumption reporting.

It does not reopen the frozen Phase 5 judgement or answer-quality evidence. It
does not authorize release, push, Linux qualification, cutover, native-v1
removal or donation submission.

## Implemented Surface

The ordinary human command is:

```text
crexxrag query 'What does BillingService depend on?'
```

When `role.answerer` is configured, the shorthand performs one query embedding
through the configured embedding route, requires its provider/model/dimension/
input-envelope identity to match the active `.rxvec` generation, retrieves the
typed packet, encodes the exact bounded `crexx-rag.answer-context/1`, and calls
the configured answerer. The answer is returned only when its two-field JSON
schema is exact and every citation already occurs in the evidence.

Canonical controls remain available:

```text
crexxrag query evidence QUESTION --mode auto
crexxrag query evidence QUESTION --mode lexical
crexxrag query evidence QUESTION --mode hybrid
crexxrag --format json query answer QUESTION
```

Lexical mode is zero-outbound. Automatic mode reports an attempted provider
call and explicit lexical fallback when embedding generation is unavailable.
Hybrid mode fails instead of silently falling back. Query opens the library
read-only and answer prose never changes claim or evidence state.

`ragquerypolicy` independently gates local/hosted privacy, maximum calls,
Codex turns, input tokens, output tokens, monetary cost and aggregate observed
usage. Monetary routes are admitted only when their catalogue price and
retry-adjusted worst-case use fit the reviewed ceiling. A monetary route with
unavailable pricing or consumption is rejected; local
compute and subscription allowance remain distinct charging bases rather than
being stored as zero monetary cost. Gemini single and batch embedding responses
now project their reported token use and estimated cost through the generic
provider result.

## Permanent QA

The installed toolchain was used first:

```text
crexx-1.0.0-beta.3+local.ge3d6b7b90158.dirty
```

The final application artifacts are:

```text
linked Level-G application SHA-256:
cb2a792433396a74bf26fc7c630b87cc2702519208b39675ae6cba7db88edf96

native application package SHA-256:
56d4ad0da8daa24216fec7ab008c8e84143906bcaabc73a40e2864e28759ff75
```

The native package passed library initialization and two-worker supervision.
The complete downstream wall passed:

```text
ctest --preset debug --output-on-failure -j1
100% tests passed, 0 tests failed out of 85
Total Test time (real) = 1675.82 sec
```

| Test | Coverage |
| --- | --- |
| `p5r_01_gemini_query` | Native init/ingest/query; compatible hybrid answer; concise human and stable JSON; exact citations; zero-request lexical; reported auto fallback; required-hybrid failure; unknown, duplicate, omitted and extra-field rejection; clean integrity |
| `p5r_02_query_policy` | Optimized/non-optimized on `rxvme`/`rxbvm`; local/hosted privacy; call, Codex-turn, input, output and cost ceilings; retry-adjusted worst-case pricing; unknown pricing/consumption; aggregate post-call accounting |
| `phase5_retrieval` | Existing nine frozen judgements, exact vector publication/search, fusion, typed evidence, stable historical citations, tutorial and baselines |
| `p3r_02_gemini_ingestion` | Regression for native worker ingestion, query embeddings, exact vector publication, zero-work replay and human output |
| `p1_llm_04` | Generic OpenAI, Anthropic and Gemini protocol projection, including Gemini embedding token usage |

## Clean Codex And Local Walkthrough

A new public synthetic tutorial library used Codex App Server for extraction
and answering, with local llama.cpp/Nomic for document and query embeddings.
Two supervised ingestion workers completed the two-item job, promoted one
cited directional claim, stored one 768-dimensional embedding and published
one exact vector generation. The human query returned the expected answer,
`active-exact-rxvector`, hybrid mode and the stable UTF-8 citation.

The query reported two calls. Local embedding generation used 11 input tokens.
The contained Codex answer turn used 17,228 input and 133 output tokens; the
ChatGPT allowance was 99 percent available before and after that clean turn.
The charging bases were `local-compute` and `subscription-allowance`. Final
library verification reported zero issues. The embedding server was stopped
after the run.

## Clean Google Walkthrough

A separate new public synthetic library used Gemini 3.5 Flash Lite and Gemini
Embedding 2 for both ingestion and query. Two supervised ingestion workers
completed extraction and embedding, accepted the cited directional claim and
published one exact vector generation. The short human query then completed
one query embedding and one structured answer, returned hybrid state and the
stable citation, and library verification reported zero issues.

After the embedding usage projection fix, the query reported seven Gemini
embedding input tokens and one estimated cost microunit. The answer reported
729 input and 188 output tokens and 688 estimated cost microunits. Both records
used the `monetary-api` charging basis and stayed within the configured 50,000
microunit command ceiling. No credential value was printed or retained.

## Containment And Boundaries

Each Codex answer owns its App Server child and isolated empty temporary
working directory. App Server owns managed ChatGPT authentication. The turn is
schema-constrained, permits no interactive approval, and its output still
passes cREXX validation. Query calls are read-only and ephemeral; durable
provider-run recovery continues to apply to ingestion and improvement workers,
not to a response that was never committed to library state.

Codex remains an experimental local-personal provider and a hosted privacy
route because content leaves the machine. Gemini remains the always-included
bounded hosted regression route. SQLite remains authoritative; `.rxvec`
generations are immutable rebuildable sidecars, and vector similarity never
creates a typed claim.
