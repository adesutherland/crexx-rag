# P1-LLM-02 Local OpenAI-Compatible Calls

Status date: 2026-08-03. Result: accepted for the available local provider.

The Level-B provider implementation now makes configurable plain-HTTP local
OpenAI-compatible generation and embedding calls through installed `rxhttp`
and parses responses through installed `rxjson`. The deterministic loopback
validated request path, model, streaming flag, Unicode prompt, embedding input,
normalized identity, token usage, latency, and explicit `f32le-v1` projection.

Optimized and non-optimized modules passed on `rxvme` and `rxbvm`. The server
recorded exactly four generation and four embedding requests. No hosted
credential was read and no hosted request was made. A real `llama-server` case
was unavailable because that executable is not installed; this is recorded as
an unavailable local-provider case, not accepted as real-model evidence.

```text
cmake --build --preset debug --target p1_llm_02
ctest --test-dir cmake-build-debug -L '^P1-LLM-02$' --output-on-failure
```

- final target: 7.58 seconds, peak RSS 132,244 KiB;
- final exact-label CTest: 1/1 in 9.16 seconds, peak RSS 132,168 KiB;
- four-cell and availability output: `raw/p1-llm-02-commands-and-output.txt`;
- raw loopback request log: `raw/p1-llm-02-loopback.out`;
- source and evidence hashes: `raw/p1-llm-02-hashes.txt`.

Those hashes identify the original acceptance state. The strengthened full
Unicode/input assertions and replacement source hashes are retained in
[`RECOVERY-CHECKPOINT.md`](RECOVERY-CHECKPOINT.md).

The retained first target failed on two cREXX inline method-call syntax errors.
The corrected adapter passed all four cells. The shared contract retains its
known compiler shadowing warning for factory initialization of a typed array;
the item-specific driver is warning-free.
