# P1-LLM-03 Provider Hardening

Status date: 2026-08-03. Result: accepted within the installed transport's
truthfully reported limits.

The provider-neutral Level-B contract now carries provider and model capability
metadata, input/output modalities, maximum output tokens, embedding dimensions,
stream intent, retry attempts/delay, route policy, and normalized failure
usage/latency. The configurable OpenAI-compatible implementation adds ordered
batch embeddings, structured requests, response validation, bounded exponential
retry/backoff, idempotency and client request identifiers, and privacy checks
before client construction.

The structured validator deliberately claims a bounded JSON Schema subset: valid
JSON, root type, required top-level members, and the declared type of required
members. It rejects malformed schemas and responses. It does not claim complete
JSON Schema evaluation.

Optimized and non-optimized modules passed on `rxvme` and `rxbvm`. Each cell
proved a valid structured response, a missing-required-member rejection, two
ordered three-dimensional embeddings, HTTP 429 then 503 then success with
1/2 ms backoff, immediate HTTP 400 failure, pre-transport hosted privacy denial,
and explicit unsupported streaming and cancellation. The retry delay uses the
in-process `ADDRESS CREXX sleep` command rather than shelling out.

The same four cells made 25 measured sequential loopback generations each.
Observed averages were 1,420-1,656 microseconds per call. The server counted 128
connections for 128 total requests and all 128 carried `Connection: close`.
This is local-loopback evidence, not a hosted TLS performance projection. It
confirms that installed `rxhttp` has no connection reuse; CRI-16 records the
industrial transport gap.

```text
cmake --build --preset debug --target p1_llm_03
ctest --test-dir cmake-build-debug -L '^P1-LLM-03$' --output-on-failure
```

- final target: 7.83 seconds, peak RSS 137,164 KiB;
- exact-label CTest: 1/1 in 7.77 seconds, peak RSS 137,124 KiB;
- four-cell output and transport measurements:
  `raw/p1-llm-03-commands-and-output.txt`;
- server connection accounting: `raw/p1-llm-03-loopback.out`;
- command, timing, and source hashes: `raw/p1-llm-03-*`.

CRI-15 still prevents Linux timeout acceptance. Timeout is therefore excluded
from this result rather than hidden by a provider workaround. `rxhttp`
connection reuse, streaming, cancellation, compression, bounded response size,
and multiplexing are also not claimed.
