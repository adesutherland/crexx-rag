# Local provider replacements

`codex-app-server-fixture.sh` replaces the **Codex executable called by
cREXX-RAG**. It implements the App Server JSONL messages used by the adapter:
initialization, account/allowance inspection, thread creation, turn results,
history inspection and deletion. Its replies and usage figures are synthetic;
it starts no real Codex model session and makes no network calls.

The existing test harnesses select it with `CREXXRAG_CODEX`, pointing to a
generated executable wrapper around this script. Product configuration and the
real cREXX-RAG controller/worker code remain in use. The harnesses create their
own disposable libraries, synthetic source text and fixture-only environment.

From the repository root, after the normal build:

```sh
ctest --preset debug -R '^controller_recovery$' --output-on-failure
```

This runs six eight-worker cases in `cmake/ControllerRecovery.cmake`:

- A fake provider exits after submission; history confirms interruption and
  the real controller replaces the worker and completes the remaining work.
- A fake provider exits but history supplies its completed output; recovery
  reuses that output without another generation request.
- Provider cleanup fails after a completed response.
- History is unavailable, leaving only that outcome unresolved while peers run.
- Three failures exhaust the two-replacement allowance while healthy peers run.
- Only an unresolved item remains, followed by public reconciliation.

Retained results, method-call counts, command output and SQLite assertions are
under `cmake-build-debug/test-controller-recovery/`. The recorded provider calls
in those scratch libraries are fake protocol exchanges, not hosted usage.
These cases exercise ingestion extraction through the shared worker controller;
they are not an overnight maintenance endurance test.

For [T7-10](../../../docs/t7-10-controller-diagnosis-20260915.md), distinguish
the two process layers. This fixture replaces the inner provider. The suspected
failure is the **outer Scottish Codex task runtime** being shut down/recreated
while it owns a background cREXX-RAG command. The replacement can remove paid
providers from a future reproduction, but a passing provider fixture alone
does not reproduce or resolve the outer task-resume failure.
