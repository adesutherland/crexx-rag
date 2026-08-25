# Phase 4 Tutorial: Improve With `crexxrag`

Status: maintained human walkthrough for the unpublished macOS application.
Phase 4 reuses the Phase 3 library, providers and worker framework. It adds a
reviewed background-improvement command; a human does not need to construct a
plan file, start a worker script or inspect SQLite.

The normal sequence is:

```text
crexxrag init -> crexxrag ingest -> crexxrag improve -> crexxrag query
```

## Set up the tutorial workspace

If the Phase 3 tutorial workspace is still available, continue in that folder.
Otherwise, from the repository root:

```sh
work_dir=$(./docs/tutorials/phase-3-ingestion/setup.sh)
cd "$work_dir"
```

The setup command builds the native Level-G `crexxrag`, copies the public
architecture fixture and configuration, and starts only the local llama.cpp
embedding server. On macOS the server is owned by `launchd`, so it remains
available after setup exits. The application, not the setup script, owns all
library planning, ingestion, improvement and worker orchestration.

For a Google-only workspace instead:

```sh
google_work=$(./docs/tutorials/phase-3-ingestion/setup.sh --google)
cd "$google_work"
export GEMINI_API_KEY='<Google AI Studio key>'
```

## 1. Create and ingest the library

Skip this step if the Phase 3 tutorial already completed it:

```sh
./crexxrag provider status
./crexxrag init
./crexxrag ingest
```

The ingest job must finish with `state: completed`. The Codex/local route uses
one ChatGPT-subscription extraction turn and one local embedding request. The
Google route uses one Gemini extraction and one Gemini embedding request.

## 2. Review and run improvement

```sh
./crexxrag improve
```

Before writing or starting a provider turn, the application prints the work it
selected and the exact configured route and ceilings:

```text
Improvement plan

  Items selected:   1
  Triggers checked: 6
  Worker processes: 2
  Extraction:       Codex using your ChatGPT subscription
  Hosted data:      Public content only
  Maximum calls:    2
  Input token limit: 65536
  Output token limit: 1024
  Codex allowance:  <current value>% available
  Codex turn limit: 1
  Monetary API cost: Not applicable
  Plan digest:      <sha256>
Continue? [y/N]
```

Answer `y`. The currently known CREXX `LINEIN()` issue can require one extra
Enter. `./crexxrag improve --yes` skips only this prompt; plan revalidation,
privacy checks and all budgets still apply.

`crexxrag` then:

1. applies the exact reviewed plan;
2. stores one immutable provider input per selected chunk;
3. starts the configured number of independent OS-process workers;
4. validates every proposal through the same candidate, type, relationship,
   confidence and evidence rules as ingestion; and
5. reports the final durable job.

A successful run ends like this:

```text
improve apply
  disposition: queued
  items: 1

worker controller
  workers requested: 2
  workers completed: 2
  workers failed: 0

job status
  state: completed
  planned total: 1
  processed: 1
  dead letter: 0
```

Improvement generates claims, not embeddings, so its worker summary does not
show an irrelevant vector-publication state. Every process opens its own SQLite
connection; SQLite serializes writers, while leases and monotonically
increasing fences prevent a late or crashed worker from promoting stale work.

## 3. Inspect reviews and evidence

Model output can become an accepted, evidence-backed claim, a no-claim result,
or a typed pending review. It never writes canonical graph rows directly.

```sh
./crexxrag review list
./crexxrag query 'What does BillingService depend on?'
./crexxrag --access diagnose library verify
```

`review list` is empty for the supplied fixture because the extracted claim is
valid and already supported. Low confidence, unresolved endpoints, ambiguity,
canonical conflicts and external proposals remain pending for an explicit
operator decision.

## 4. Prove replay safety

Run the same command again:

```sh
./crexxrag improve --yes
```

The trigger may still identify the same useful chunk, but its immutable work
identity already exists. Apply therefore returns:

```text
improve apply
  disposition: identical-no-op
  items: 0
  provider calls: 0
```

No job, worker or provider call is created. This is based on the provider input
identity, not a changing rank score.

## Operator controls

The short command supervises a bounded worker group in the foreground. Another
`crexxrag` process can inspect the SQLite-backed state at any time:

```sh
./crexxrag worker list --local
./crexxrag job list
./crexxrag job status '<job-id>'
```

Explicit controls remain available for long-running or independently
supervised work:

```sh
./crexxrag --access control job pause '<job-id>'
./crexxrag --access control job resume '<job-id>'
./crexxrag --access control job cancel '<job-id>' --reason operator-request
./crexxrag --access control worker drain '<worker-id>'
```

Machine callers retain the stable plan/apply vocabulary and JSON output:

```sh
./crexxrag --format json --access plan improve plan
./crexxrag --format json --access curate \
  improve apply --plan-json '<canonical-plan>' --expect-digest '<sha256>'
```

## Cleanup

For the default Codex/local workspace:

```sh
CPRAG_LLAMA_STATE_DIR="$PWD/.llama-servers" ./stop-local-embedding.sh
```

Recurring QA uses a deterministic Gemini protocol fixture and makes no hosted
request. Phase 4 qualification separately includes bounded real Codex and
Google improvement turns. Exact Linux, release, cutover and native-v1 removal
remain outside this phase.
