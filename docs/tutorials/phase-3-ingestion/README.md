# Phase 3 ingestion tutorial bundle

This folder contains everything needed for the maintained human walkthrough:

- `setup.sh` builds and copies the native `crexxrag` application;
- `crexx-rag.conf` selects Codex extraction through the user's ChatGPT
  subscription and local Nomic embedding generation through `llama.cpp`;
- `google-gemini.conf` is the separately bounded Google qualification route;
- `source-docs/architecture.txt` is the public synthetic source.

The default walkthrough is four commands from the repository root:

```sh
work_dir=$(./docs/tutorials/phase-3-ingestion/setup.sh)
cd "$work_dir"
./crexxrag provider status
./crexxrag init
./crexxrag ingest
./crexxrag query 'What does BillingService depend on?'
```

Setup starts only the local `llama.cpp` embedding server and proves its
OpenAI-compatible `/embeddings` endpoint before returning. `crexxrag` discovers
`./crexx-rag.conf`, uses `./library`, selects the sole profile and supervises
the configured worker processes. `ingest` reviews privacy, provider roles,
Codex allowance and budgets before asking for confirmation.

The installed CREXX runtime can require a second Enter at that prompt. This is
the accepted upstream `LINEIN()` defect; `./crexxrag ingest --yes` skips the
prompt without skipping plan/apply review.

For the Google route, use `setup.sh --google`, export `GEMINI_API_KEY`, and run
the same four `crexxrag` commands in that separate workspace.

See [`../phase-3-ingestion.md`](../phase-3-ingestion.md) for expected output,
privacy, subscription and monetary budgets, recovery, cleanup and automation.
