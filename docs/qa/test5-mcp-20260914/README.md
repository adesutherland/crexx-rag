# Test 5 MCP evidence — 14 September 2026

See [the Test 5 definition and result](../../test5-mcp-qa.md).

`identity.json` names the unchanged Test 4 native artifact, its normal
configuration and the independent Test 5 copy. The computer was shared with
other work. No provider, migration, installation or corpus processing was run.

`run/` contains all 53 requests and actual MCP responses, per-request CPU/wire/
elapsed measurements, 248 passing diagnostic assertions, before/after state and
the one normal path-gap effect. `followup/` contains a separate three-request
session resolving the returned lead's actual passage. Both servers exited zero.
`assistant-answer.md` was composed by the current assistant from resolved MCP
spans, retained exactly in `answer-citations.json`; no product answerer was used.
`summary.json` summarizes measured requests. `sidecar-observation.json` records
the size of the file still unnecessarily checked before explicit lexical queries.

For another Test 5, make a fresh disposable copy, create an identity JSON naming
its `executable`, `library` and `config`, and use a new output directory:

```sh
python3 docs/qa/test5-mcp-20260914/run_mcp.py /path/to/identity.json /path/to/new-results
```

The diagnostic Python program is an external stdio MCP client, like the retained
Test 4 clients. Product orchestration and SQL remain in cREXX. SQLite access in
this diagnostic is read-only independent verification, not an answer source or
replacement command path. The runner now resolves the lead passage inline;
this recorded run retained that final read as the three-request supplement.
It creates no provider calls. Explicit lexical path queries may record gap
observations in the selected disposable copy. Do not point it at a master corpus.

There are no latency thresholds. The 120-second transport guard detects a
non-response only; a guard expiry requires investigation, not a performance
failure label. CPU is sampled from macOS `ps` for the server PID at centisecond
resolution. Concurrent load and cache effects prohibit a speedup claim from
these elapsed samples. Hashes preserve raw response whitespace in `SHA256SUMS`.
