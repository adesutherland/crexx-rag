# Phase 3 Gemini ingestion

This is the complete input bundle for the maintained human walkthrough:

- `setup.sh` builds and copies the native `crexx-rag` application;
- `crexx-rag.conf` selects bounded Google Gemini generation and embedding;
- `source-docs/architecture.txt` is the public synthetic source.

From the repository root:

```sh
work_dir=$(./docs/tutorials/phase-3-ingestion/setup.sh)
cd "$work_dir"
export GEMINI_API_KEY='<Google AI Studio key>'

./crexx-rag init
./crexx-rag ingest
./crexx-rag query 'What does BillingService depend on?'
```

`crexx-rag` discovers `./crexx-rag.conf`, uses `./library`, selects the sole
profile and runs the configured two worker processes. `ingest` shows the data
route, providers, maximum calls/cost and reviewed digest before asking for
confirmation. In a colour terminal, progress is ANSI by default; set
`NO_COLOR=1` or use `--progress plain` for plain text.

The current CREXX runtime can require a second Enter at the confirmation prompt
because of a known `LINEIN()` defect. This is accepted for now; use
`./crexx-rag ingest --yes` to skip the prompt without skipping plan/apply review.

See [`../phase-3-ingestion.md`](../phase-3-ingestion.md) for expected output,
privacy and cost boundaries, automation mode, monitoring and recovery.
