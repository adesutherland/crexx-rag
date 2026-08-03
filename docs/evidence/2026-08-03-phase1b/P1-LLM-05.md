# P1-LLM-05 Privacy And Secret Controls

Status date: 2026-08-03. Result: accepted.

The hosted route policy rejects `local` and `restricted` requests before an
HTTP client or socket is constructed. Missing hosted credentials fail through
the same pre-transport path. Authorization headers are assembled only inside
the transport call; the cREXX surface exposes neither a raw request builder nor
an authorization-header helper.

Optimized and non-optimized modules passed on `rxvme` and `rxbvm`. Each cell
denied OpenAI, Anthropic, Gemini embedding, and local OpenAI-compatible hosted
routes, then rejected one public request with a missing credential. A dedicated
observer listened throughout all four cells and accepted zero connections:

```text
SUMMARY scenario=zero-outbound connections=0
```

The test also compared the three real environment credential values against the
Phase-1B evidence tree, provider source/fixtures/tests, CMake scripts, hosted
output, and item output. It found zero matches. The values and authorization
headers were never printed or written by the audit.

```text
cmake --build --preset debug --target p1_llm_05
ctest --test-dir cmake-build-debug -L '^P1-LLM-05$' --output-on-failure
```

- final target: 17.64 seconds, peak RSS 175,772 KiB;
- final exact-label CTest: 1/1 in 18.41 seconds, peak RSS 175,904 KiB;
- four-cell, observer, and credential audit:
  `raw/p1-llm-05-commands-and-output.txt`;
- observer output: `raw/p1-llm-05-loopback.out`;
- command, timing, and source hashes: `raw/p1-llm-05-*`.

The scan proves absence from the retained project/evidence surfaces named
above; it is not a general operating-system process-memory secrecy claim.
