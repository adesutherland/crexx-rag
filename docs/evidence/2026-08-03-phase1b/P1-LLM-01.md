# P1-LLM-01 Provider-Neutral Contract

Status date: 2026-08-03. Result: accepted.

Level B now defines one nominal provider contract for capability discovery,
normalized messages/inputs, role/model/schema, timeout and retry bounds,
privacy class, idempotency/request identity, normalized content or embeddings,
typed usage, latency, finish reason, and classified errors. A Level G facade
forwards the same `generate`, `generate_structured`, `embed`, `embed_batch`, and
`cancel` vocabulary to any implementation of the provider interface.

Optimized and non-optimized modules passed on `rxvme` and `rxbvm`. The focused
adapter proved chat, structured output, one and batch `f32le-v1` embeddings,
typed usage, capability limits, request validation, and explicit unsupported
streaming/cancellation. No transport or credential was used by this item.

```text
cmake --build --preset debug --target p1_llm_01
ctest --test-dir cmake-build-debug -L '^P1-LLM-01$' --output-on-failure
```

- final clean target: 6.25 seconds, peak RSS 122,948 KiB;
- final exact-label CTest: 1/1 in 6.03 seconds, peak RSS 123,108 KiB;
- raw four-cell output: `raw/p1-llm-01-commands-and-output.txt`;
- source and evidence hashes: `raw/p1-llm-01-hashes.txt`.

Those hashes identify the original acceptance state. The warning-free
post-crash corrections and replacement source hashes are retained in
[`RECOVERY-CHECKPOINT.md`](RECOVERY-CHECKPOINT.md).

Retained development failures cover method-call syntax and the required
zero-argument fixture-class factory. A later passing run exposed a shadowing
warning in the embedding setter; the final rerun renamed that formal. The
shared result constructor still emitted a compiler shadowing warning for typed
array initialization at acceptance time; this is corrected by the subsequent
provider-hardening checkpoint.
