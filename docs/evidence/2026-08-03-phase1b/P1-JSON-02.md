# P1-JSON-02 Same-Session JSON Comparison

Status date: 2026-08-03. Result: accepted.

One cREXX process per cell compared installed legacy repeated-path `rxjson`
calls with one installed indexed `.jsondocument` over identical in-memory
payloads. Optimized and non-optimized programs passed on `rxvme` and `rxbvm`.

The deterministic provider response was 713 bytes and carried Unicode content,
typed usage, and a 64-value embedding. Both routes returned content
`Gràdh 中 answer`, 22 total tokens, 64 dimensions, and checksum -12.75. Legacy
access took 14,761-17,168 us; indexed parse took 271-385 us and indexed typed
access took 537-777 us.

The paged evidence workload contained four separately encoded eight-row pages.
Both routes returned 32 rows and checksum 2677. Legacy repeated paths took
54,893-75,320 us; four indexed parses took 1,527-1,895 us and typed traversal
took 761-982 us. These are this same-session synthetic workload's observations,
not extrapolations to other payloads.

```text
cmake --build --preset debug --target p1_json_02
ctest --test-dir cmake-build-debug -L '^P1-JSON-02$' --output-on-failure
```

- target: 5.11 seconds, peak RSS 123,068 KiB;
- exact-label CTest: 1/1 in 4.38 seconds, peak RSS 123,020 KiB;
- raw per-cell timings: `raw/p1-json-02-commands-and-output.txt`;
- source and evidence hashes: `raw/p1-json-02-hashes.txt`.
