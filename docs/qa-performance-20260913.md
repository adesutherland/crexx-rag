# MCP search, relationships and answer performance — 13 September 2026

The extended smoke identifies **setup and answer-generation latency**, with
smaller search costs and an important retrieval-quality constraint. Ordinary
MCP searches on the repaired disposable copy have a **0.47-second median**;
directional path lookups take **0.45–0.60 seconds**. The default library overview
takes **9.5 seconds** even on that copy. Two generated answers take about **12–13
seconds**. These are measured samples, not latency guarantees.

## The configured QA executable is older

`/Users/adrian/Documents/ScottishHistory/.codex/config.toml` launches
`/Users/adrian/Documents/ScottishHistory/tools/bin/crexxrag`, a private native
copy dated September 10, SHA-256
`caf17c66db6237c07a0de22f5a27d25178a3fdba0fc64b7ecf61035003e2cf3a`.
The normal installation is the qualified `7febbca` native, SHA-256
`e3967d87a24df035fa43373719bc5ed611592c7cf49433326dca85115cc762ab`.
Updating the normal installation did not update that configured private copy.

Fresh real stdio MCP sessions tested both executables against the **same
permanent QA library**, generation 23,208. Only `rag_library_status`,
`rag_library_overview`, `rag_query_inspect` and citation reads were used there;
its configuration, executable and library were not changed. A third session
used the current executable and repaired disposable copy, schema 18,
generation 24,933. That third lane has different data/configuration and must
not be presented as an isolated executable speedup.

| Stage | Configured private executable, permanent QA copy | Current executable, same QA copy | Current executable, repaired disposable copy |
| --- | ---: | ---: | ---: |
| MCP initialize | 0.236 s | 0.181 s | 0.171 s |
| Library status | 2.432 s | 0.201 s | 0.206 s |
| Library overview | 32.111 s | 8.952 s | 9.536 s |
| Search median, ten calls | 0.684 s | 0.753 s | 0.472 s |
| Citation resolution | 0.005–0.006 s | 0.011 s | 0.011–0.012 s |

The current executable substantially improves the same-library overview and
status samples. **It did not improve search latency on that unchanged QA
library** in this run. Database state, indexes and warm-cache variation matter;
the later disposable-copy timings alone do not prove which one caused its
search improvement. Some later first calls were slower than repeats, including
a 1.85-second dense search followed by 0.54-second searches.

## Search and relationship coverage

Each lane searched “Who defeated Edward II at Bannockburn?” and “How were
Mackay and Dundee connected?” at hop limits 0, 1, 3 and 4, then repeated the
three-hop query and resolved a returned citation. All commands succeeded.

On the disposable copy, actual `rag_query_path` calls for Dundee returned one
claim in the outbound case and two in inbound/both cases. Their times were
0.45–0.60 seconds. Following the returned question, “What is the relationship
between Alaster Macdonald and Dundee?”, took **0.518 seconds**, returning three
claims and three leads. A dense Scotland query returned the configured eight
claims and eight leads. One versus three/four hops often returned the same
bounded results; this is not an exhaustive deep-graph or unbounded fan-out test.

The matching current CLI Mackay query took 0.657 seconds versus approximately
0.48 seconds in the persistent MCP session. MCP transport is not the dominant
delay in these samples. This comparison includes CLI process startup and is
not a precise measurement of transport CPU cost.

## Answer speed must retain answer coverage

Two explicitly bounded hosted calls used the current copy and existing
`codex-extract` / `gpt-5.6-luna` answerer. Both used lexical retrieval, one
generation call each, no query embedding and **zero Gemini calls**. Both use
subscription allowance rather than a monetary-API route. Their ledger cost
field remains unpriced (`-1`), not a recorded numeric zero. They recorded
53,833 input tokens and 615 output tokens in total.
The question was “What happened at Bannockburn in 1314?”

| Evidence setting | Retrieval | MCP answer call | Input / output tokens | Result |
| --- | ---: | ---: | ---: | --- |
| Three passages, one hop | 0.586 s | 13.022 s | 21,459 / 331 | Valid partial answer about location; battle evidence absent from the selected packet |
| Twelve passages, three hops | 1.750 s | 11.873 s | 32,374 / 284 | Valid partial answer identifying Bruce's defeat of Edward II, citing the Test 2 excerpt |

The first three passages are the same in both packets. The directly useful
Test 2 passage is **fourth**. Thus cutting the passage limit loses available
answer evidence. The larger packet was not slower overall in these two samples;
model variability prevents a general speed claim from one pair. Both answers
passed citation validation, and all their cited spans resolved successfully.
The partial compact answer is not a successful answer to the battle question.

The provider ledger records 10.460 and 9.235 seconds respectively, leaving about
2.6 seconds of each end-to-end answer call outside the provider's reported
duration. That remainder includes retrieval, managed-session setup/account
checks, validation and persistence; it is not a measured SQL-only duration.

The compact evidence MCP response is about 29 KB; the default response is
about 83 KB. These are wire sizes, not measured Codex-client token counts.
MCP already returns a short text message plus one structured result; there is
no duplicate full-evidence text payload to remove.

This measures the product's Codex answerer, including its managed App Server
interaction. It does **not** measure the outer Codex desktop agent's planning,
tool-choice, conversation-prefill or rendering time. The user was invited to
supply an actual slow question; these results use the named representative cases.

## Fixes indicated, in order

1. **Update the QA launch target deliberately.** The private executable is
   stale. Point the MCP configuration at the supported installation, or refresh
   the private installation, and qualify a backed-up QA library migration
   before claiming it has all schema-18 access paths. Restart the MCP client
   after changing its launch configuration. This test did not perform that upgrade.
2. **Avoid a full health report for routine question setup.**
   `crexxrag-qa/SKILL.md` currently asks for `rag_library_overview`, which maps to
   `library.report`. `ragreportservice.libraryreport` runs full store/repository
   verification and corpus/history aggregates. Use status plus source inventory
   when establishing ordinary QA scope; source listing measured **0.014 seconds**.
   Keep the full report available for an explicit coverage/health request, rather
   than repeating it per question or introducing another parallel report owner.
3. **Skip vector preparation in explicit lexical mode.**
   `ragqueryservice.querycommand` currently calls `_activequeryembedding` and
   `_querysidecaravailable` before checking the mode. The latter hashes the
   whole vector sidecar, even though these lexical queries use no vectors.
   The unnecessary work is confirmed by the code; its isolated latency share
   was not measured. A fix must retain hybrid validation and prove that lexical
   results do not depend on the presence or integrity of a vector sidecar.
4. **Improve ranking before shrinking evidence.** The battle passage ranks
   behind a geographic hit and two irrelevant neighboring passages. Retain the
   current useful evidence allowance until a ranking regression proves that the
   directly answering span survives a compact result. Review primary-match and
   neighboring-context ordering in the shared retrieval owner. Do not tune away
   source coverage merely to reduce response bytes.

No product implementation, skill rule, permanent QA setting or installation was
changed by this performance extension. These findings need the appropriate
regressions before implementation. Search-only tests were read-only; path and
answer tests recorded their ordinary gap signals/usage only in the disposable
copy. No claims, sources, revisions or semantic generations changed in this
extension. All benchmark servers exited.

See [retained evidence and reproduction](qa/qa-performance-20260913/README.md).
The earlier [operational redo](test4-operational-redo-20260913.md) repaired two
holds and remains a separate completed result.
