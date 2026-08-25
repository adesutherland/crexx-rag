# Phase 5 Tutorial: Ask The Ingested Library

Phase 5 turns the Phase 3 library into a useful human query experience. You
ask one question with `crexxrag`; the application generates a compatible query
embedding, searches lexical, vector and typed-graph evidence, gives the exact
evidence packet to the configured answer model, validates its citations and
prints a short answer.

The ordinary walkthrough is three commands after the one-time setup. It uses a
scratch folder and cannot alter another library.

## 1. Create The Tutorial Folder

From the repository root, choose one of the two tested provider routes.

The subscription-first route uses Codex for extraction and answers, and a
local llama.cpp Nomic model for embedding generation:

```bash
work_dir=$(docs/tutorials/phase-3-ingestion/setup.sh)
cd "$work_dir"
```

The setup checks the installed native `crexxrag`, copies the configuration and
sample source into one folder, and starts only the local embedding server.
Codex App Server owns ChatGPT login and token refresh. Source text still leaves
the machine when Codex is used, so the supplied source is deliberately public.

To use the always-qualified Google route instead:

```bash
work_dir=$(docs/tutorials/phase-3-ingestion/setup.sh --google)
cd "$work_dir"
export GEMINI_API_KEY='<Google AI Studio key>'
```

The key is read from the environment at the provider boundary. It is not put
in the configuration, command output, library or evidence.

## 2. Check, Initialize And Ingest

Run:

```bash
./crexxrag provider status
./crexxrag init
./crexxrag ingest
```

`provider status` does not make a model request. The ingestion plan names the
source, extraction and embedding providers, privacy route, workers and hard
budget before asking for confirmation. After confirmation, `crexxrag` starts
the configured OS-process workers and reports their progress. A successful
run ends with a completed two-item job and one published vector generation.

Progress is for humans and goes to the terminal. Use `--progress off`,
`--progress plain` or `--progress ansi` to control it. JSON and NDJSON stdout
remain machine-stable.

## 3. Ask A Question

Run the enduring human command:

```bash
./crexxrag query 'What does BillingService depend on?'
```

With the supplied configuration, the shorthand selects the configured
answerer. Expected key output is:

```text
OK: evidence-backed answer generated with validated citations
query evidence
  vector state: active-exact-rxvector
  generated answer: BillingService depends on CustomerDatabase.
  citation: crexx-rag:...:utf8-0-87
  retrieval mode: hybrid
  query embedding state: generated
  provider calls: 2
```

The two calls are one embedding generation and one structured answer turn.
The provider records show the route, model, charging basis, token usage and,
for Google, estimated monetary consumption. Codex reports subscription
allowance before and after the turn instead of pretending its cost is zero.

The answer is accepted only when every returned citation is present in the
exact `crexx-rag.answer-context/1` supplied to the model. Unknown, duplicate,
omitted and extra-schema citation output is rejected. The answer never changes
the library.

## 4. Inspect Evidence Or Force A Retrieval Mode

To retrieve the same typed packet without answer generation:

```bash
./crexxrag query evidence \
  'What does BillingService depend on?'
```

`--mode auto` is the default. It uses a vector only when the active `.rxvec`
generation exactly matches the configured embedding provider, model,
dimension and input-envelope fingerprint. If the provider is unavailable it
reports the attempted call and falls back lexically.

For a deliberate zero-outbound query:

```bash
./crexxrag query evidence \
  'What does BillingService depend on?' --mode lexical
```

For a query that must use the compatible vector route or fail:

```bash
./crexxrag query evidence \
  'What does BillingService depend on?' --mode hybrid
```

Machine callers can request the complete evidence packet and provider records:

```bash
./crexxrag --format json query answer \
  'What does BillingService depend on?'
```

SQLite remains authoritative. Embedding generation converts text to a vector;
vector-index publication creates the immutable, rebuildable `.rxvec`
generation. Vector or graph proximity can create a lead, never a typed claim.

When finished with the subscription-first route:

```bash
CPRAG_LLAMA_STATE_DIR=.llama-servers ./stop-local-embedding.sh
```

## Regression And Qualification Evidence

`p5r_01_gemini_query` permanently exercises the native human and JSON paths:
ingestion, compatible hybrid retrieval, schema-constrained cited answers,
zero-outbound lexical mode, visible automatic fallback, required-hybrid
failure, four invalid answer shapes and post-query library verification.

`p5r_02_query_policy` exercises hosted/local privacy and every model-call,
Codex-turn, input-token, output-token and monetary ceiling with and without
optimization on both concrete VMs. The existing `phase5_retrieval` matrix
continues to cover the detailed algorithms, nine frozen judgements, exact
vector generations, stable historical citations and native/full-context
baselines.

Bounded clean walkthroughs are also run through both real routes: Codex plus
local llama.cpp, and Google Gemini for extraction, embedding, query embedding
and cited answer generation. Hosted calls are qualification evidence, not the
ordinary repeatable CTest oracle.

## Current Boundary

This extends the maintained native Level-G `crexxrag` application through the
accepted Phase 5 scope. It does not authorize release, Linux qualification,
cutover from native-v1, native-v1 removal, push or publication. Phase 6 owns
transport consistency for CLI, `ADDRESS RAG`, MCP and skill consumers.
