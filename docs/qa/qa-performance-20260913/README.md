# MCP QA performance evidence — 13 September 2026

See [analysis](../../qa-performance-20260913.md). Diagnostic drivers use Python
only as a stdio MCP benchmark client; product orchestration remains in cREXX.
They launch a real persistent native server and time each JSON-RPC round trip
with a monotonic clock, retaining raw replies, wire sizes and structured results.
They are not a product workflow or a new performance gate.

`measure_mcp.py LANE` tests initialization, tool discovery, status, full overview,
ten inspect calls and two citation resolutions. LANE is `configured_qa`,
`current_same_qa` or `repaired_copy`. The first two use the same permanent QA
library with old/current executables and invoke only read-only product operations.
The third uses the separately approved disposable copy. Runs were sequential;
filesystem/cache state was not reset. The numbers are local observed samples.

`measure_answer_path.py repaired_copy` tests six directional paths and two
hosted Codex answers (compact/default evidence), with matching no-call evidence
reads. This script makes paid/subscription calls and must not be rerun without
new bounded authority. `measure_followups.py repaired_copy` tests dense graph
searches, a returned follow-up question, a focused search and answer citations;
its path operation records ordinary gap signals in the disposable copy.

The three drivers originally wrote under
`/private/tmp/crexxrag-qa-performance-20260913`. The output directories retain all
responses plus `metrics.json`. `summary.json` checks every command result and
records the final copy state and exact provider receipts. `cli-metrics.json`
retains the matching command arguments and process-plus-query time.

The two answer calls consumed 53,833 input and 615 output tokens, no Gemini and
subscription allowance rather than a monetary-API route. Their stored cost is
unpriced (-1). All server processes exited normally. Current product
and installed executable remain the qualified `7febbca` build. No permanent QA
library, configuration, private executable or skill was changed.
