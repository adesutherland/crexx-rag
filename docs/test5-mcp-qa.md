# Test 5 — MCP access, evidence, relationships and Q&A

Test 5 is the separate, repeatable successor to the MCP extensions previously
recorded alongside Test 4. Test 4 remains the extraction/replay smoke. The user
requested this test on 14 September 2026, including performance observations on
a computer concurrently used for other work.

## Intended behavior and acceptance checklist

- [x] **Q0 — Identify the tested application and data.** Retain executable hash,
  configuration identity, library identity/generation and corpus counts. Use a
  fresh disposable copy of the completed Test 4 library and the same executable.
  Preserve existing implementation changes. No install, commit or corpus refresh
  is part of this test.
- [x] **Q1 — Establish actual MCP access.** Start a real persistent native stdio
  server, initialize it, discover tools and inspect their schemas/instructions.
  Confirm ordinary Q&A points to `rag_query_inspect` and assistant composition;
  the product answerer is explicitly optional and has a stated provider cost.
  Verify a control operation is denied under `read` access and a bad query limit
  is rejected. A subsequent valid request must still work.
- [x] **Q2 — Establish scope and pagination.** Read status, the profile and all
  source pages using returned cursors. No duplicate/missing sources. Measure the
  full overview once as an explicit diagnostic; reuse scope across questions.
- [x] **Q3 — Exercise retrieval quality and bounds.** Search the prior Bannockburn
  and Mackay/Dundee questions with hops 0, 1, 3 and 4; compare compact (3) and
  normal (12) passage limits. Include dense Scotland, focused quoted Nairn and
  an absent-term control. Check evidence schema, generation, configured bounds,
  repeat stability and whether the answering passage was actually retained.
  Empty results mean a retrieval gap, not historical absence.
- [x] **Q4 — Follow relationships.** Follow an actual returned lead with a focused
  inspection, and test outbound/inbound/both paths at one and three hops. Preserve
  direction, claim types and support. Do not infer a new historical relationship
  from a path. Explicit path tests may record normal query-gap observations only
  in this disposable copy, with `mode=lexical` and no provider calls.
- [x] **Q5 — Resolve citations and compose an answer.** Resolve original source
  spans through MCP, including a deliberately paged citation and Unicode text.
  Check the reassembled page against the full returned span. The current
  assistant writes a short supported answer and retains complete cited spans.
  No `rag_query_answer`, query embedding or other RAG provider call is included.
- [x] **Q6 — Assess performance without stopwatch gates.** Retain per-request
  server CPU samples, observed elapsed time, wire/evidence bytes, candidate and
  result counts, repeat behavior and provider calls. CPU samples are process
  user+system time at centisecond resolution from macOS `ps`, not SQL timings.
  Concurrent load, caches and host contention prevent speedup/latency claims.
  No elapsed-time threshold, benchmark tuning or forced quiet-machine rerun.
  Attribute known expensive work to its existing source owner; do not silently
  turn this test into a performance implementation project.
- [x] **Q7 — Close the run.** Independently verify no writes during the inspect/
  citation phase, no provider/attempt changes, no semantic publication or corpus
  changes, expected path-gap effects only, and a clean server exit. Retain requests,
  responses, results and any qualification limits. Tick this checklist and update
  the handoff and test strategy. The earlier 71/71 product result remains valid
  for its unchanged executable; this diagnostic does not require rebuilding it.

## Scope and interpretation

This is an ordinary MCP Q&A acceptance and local performance characterization.
It includes the real native MCP protocol and current-assistant evidence use;
it does not measure desktop planning, rendering or total conversational latency.
Hybrid search and the separate product answerer require their own explicitly
selected provider test. Historical answerer timings are context, not Test 5 data.

Correctness, bounded results, evidence coverage and absence of unnecessary model
calls determine acceptance. Timing observations neither fail nor certify a
performance target. Known ranking/setup costs remain explicit findings even if
all functional checks pass. Reuse the authoritative QA skill and architecture;
this checklist is not another policy implementation.

## Follow-up implementation checklist — approved 14 September

The user clarified that a useful passage ranking fourth is not itself a defect.
The intended workflow casts a broad net and lets the current assistant filter
the evidence. Keep the ordinary default at 12 and raise the optional maximum
to 200. Complete the remaining Test 5 follow-ups through their existing owners.

- [x] **F0 — Preserve the intended behavior.** Keep default 12, permit explicit
  query/configuration limits 1–200, retain candidate and evidence-byte controls,
  and do not retune ranking merely to satisfy a three-passage cutoff. Ordinary
  Q&A is read-only and provider-free; hybrid integrity controls still apply.
- [x] **F1 — Confirm failing acceptance first.** Cover file/typed configuration,
  MCP metadata and argument validation, CLI/ADDRESS execution, default behavior,
  200 accepted and 201 rejected. Exercise lexical independence from a broken
  vector profile with a positive hybrid refusal control and zero provider calls.
- [x] **F2 — Implement shared bounds and lexical routing.** Give the maximum one
  configuration owner, consume it in parsing/validation/query/schema, and move
  vector preparation inside the non-lexical branch. Check real retrieval beyond
  twelve passages and a fixture able to return all 200, not just argument parsing.
- [x] **F3 — Update shared guidance.** Ordinary scope uses status and source
  inventory, with full overview for an explicit coverage/health question. Update
  the query range in maintained skills/guides/templates and describe the existing
  independent candidate/byte limits. Preserve the default 12 and broad-net intent.
- [x] **F4 — Qualify and close.** Run focused acceptance, the required full local
  suite and a provider-free MCP repeat on a disposable corpus copy. Retain CPU,
  counts and payload sizes without stopwatch gates; update the handoff and mark
  each item complete. No install, commit or hosted call is included.

Implementation: `ragconfig.querypassagemaximum()` now supplies 200 to all five
enforcement sites: typed validation, file parsing, public query execution,
core retrieval validation and the shared MCP query schema. Default constructors
and supplied configurations remain at 12. `ragqueryservice` prepares vector
profiles/sidecars only in non-lexical mode. No schema, ranking or provider change
was needed. The shared QA skill now uses ordinary status/source inventory,
and the maintained query skills, user guide and corpus template describe 1–200.

Regression-first evidence reproduced the old bound in configuration, CLI/MCP,
ADDRESS and core retrieval, plus the irrelevant vector-profile refusal during
lexical inspection. The original cases retain their passing controls. The
200-passage fixture needed 600 candidates because its three variants share the
candidate allowance; this changes fixture settings, not retrieval policy.
The lexical check now measures strict file preservation around inspection and
logical row preservation around hybrid rejection, which can checkpoint SQLite.

Focused acceptance has passing results for all eight affected tests, including
both-VM configuration/retrieval/ADDRESS cases and native Gemini fixture controls.
The actual advertised metadata was compared field-by-field: only seven query
maximums changed from 12 to 200 in each access lane. Native SHA-256:
`88b2fe4a045c42f6a514323bd93804761256b77a15928876e95b5557154bf9c7`.

The new disposable corpus copy is
`/private/tmp/crexxrag-test5-followups-xmrd_jkq/library`. Its 53-request ordinary
MCP repeat passes without a full overview or provider calls. Six additional
boundary/breadth requests confirm default 12, explicit 13, explicit 200 and
rejection of 201. The real Scotland query returns 48 passages when asked for
200, matching the normal 48-candidate setting; the evidence is 224,580 bytes.
The synthetic fixture returns and resolves all 200 distinct passages on both
VMs. The final full local suite passes **71/71 in 647.07 seconds**, with the
same native artifact and the generated CTest file restored byte-for-byte.
All F0–F4 follow-ups are complete. Corpus hashes/generation are unchanged;
ordinary Q&A is read-only, while explicit paths add their normal ambiguity gap.
There are zero new provider runs or attempts. Timings remain observations on
the shared computer, not performance gates. Changes are uncommitted and the
normal installation is unchanged.

Evidence: [follow-up capture](qa/test5-followups-20260914/README.md).

### Earlier Test 5 measurement (before this implementation)

**Complete: functional smoke passed; performance characterized with three open
follow-ups below.** The main session completed 53 JSON-RPC requests, including
248 diagnostic assertions with no failures. Three additional requests in a
fresh session resolved the actual returned lead passage. Both servers exited
normally. These are diagnostic assertions, not 248 new CTest tests.

The tested executable is the unchanged Test 4 native build:
`88d257815970bbd786744c4c1ec48114060eb1ddf02356b4554ac2e74f8b9acd`.
Baseline `300c2ac` plus the uncommitted Test 4 implementation; no rebuild,
installation or commit occurred. The independent Test 5 library is
`/private/tmp/crexxrag-test5-tye6jn_s/library`, schema 19, generation 24,929,
normal configuration `config-a211c0fede4237fe77bbc797`.

### Functional and evidence results

- Initialization and discovery advertise the intended assistant-composed answer
  route. A control tool is unavailable under read access; an invalid query limit
  is rejected. Subsequent valid requests succeed in the same server.
- All nine sources were returned once across three pages. Status and full
  overview report zero storage/repository verification issues. Existing content
  and maintenance backlogs are still reported, not erased or classified as
  storage failures.
- Eighteen successful evidence searches stay within configured candidate,
  passage, claim, lead and evidence-byte limits. Four repeat comparisons return
  identical complete evidence. The absent-term control returns no invented
  passages or claims; the quoted Unicode query retrieves the Nairn passage.
- Six explicit directional path requests preserve stored subject/object order
  and support citations. Outbound Dundee returns one claim; inbound and both
  return two each. One and three hops return the same bounded selections in
  these samples. This does not qualify exhaustive deep-graph traversal, and
  `both` is not the union of all independently bounded directional packets.
- Following the returned Alaster Macdonald/Dundee lead retrieves its actual
  index passage. It is retained as a lead with unresolved identity/context,
  not promoted into an answer about Mackay or an inferred new relationship.
- Bannockburn and Nairn citations reassemble exactly over four and eleven small
  pages respectively. UTF-8 span lengths also agree with the complete returned
  text, including Unicode and original line breaks. The
  [current assistant's answer](qa/test5-mcp-20260914/assistant-answer.md) uses
  only these MCP-resolved sources and preserves full quoted spans.
- Ordinary inspection/citation calls leave SQLite's independently observed
  data version, counts and selected corpus hashes unchanged. The six explicit
  path calls add one ambiguity gap with occurrence count six. Sources, revisions,
  chunks, mentions and claims retain identical row hashes; generation is
  unchanged. Provider runs remain **82,563**, attempts **116,207**: **zero new
  RAG provider calls**. The original Test 4 copy is unchanged.

### Performance observations on the shared computer

The first session's 53 requests have both CPU and elapsed observations. The
additional lead-citation session is functional evidence only. CPU samples use
the native server PID, exclude the Python client and have 0.01-second resolution;
a recorded zero does not mean zero work. Cache and host effects remain. No
comparison with older wall-clock samples is a measured speedup.

| Operation | Samples | Approximate server CPU, median (range) | Observed elapsed, median (range) |
| --- | ---: | ---: | ---: |
| Library status | 2 | 0.025 s (0.02–0.03) | 0.061 s (0.022–0.100) |
| Source page | 3 | 0.01 s | 0.010 s (0.010–0.011) |
| Full overview | 1 | **10.37 s** | 41.111 s |
| Evidence inspection | 18 | **0.11 s** (0.08–0.20) | 0.113 s (0.079–0.197) |
| Directional path | 6 | 0.105 s (0.09–0.16) | 0.110 s (0.097–0.175) |
| Citation reads/pages | 18 | 0.01 s (0.00–0.01) | 0.010 s (0.009–0.012) |

The overview's elapsed/CPU difference includes waiting and scheduling effects;
it is not a measured SQL delay. Search responses range from 3,166 to 155,427
wire bytes, with no duplicate full-evidence text block. Response size is not
the outer assistant's measured token count. The current assistant's reasoning
and answer-writing latency is outside this server measurement.

### Historical follow-ups identified by the initial smoke

The approved implementation above supersedes these initial findings. In
particular, the user clarified that fourth place is not itself a ranking defect.

1. **Routine setup:** `ragreportservice.libraryreport` invokes full store and
   repository verification before its census. Its 10.37-second CPU sample is
   substantially more work than the focused requests. The shared QA skill still
   asks for an overview during scope setup. Use the shared guidance owner to
   distinguish routine status/inventory from an explicitly requested health
   report; no new report service or health check is required.
2. **Lexical preparation:** `ragqueryservice.querycommand` still calls
   `_activequeryembedding` and `_querysidecaravailable` before the mode branch.
   The latter hashes the compatible sidecar, **6,696,451 bytes** in this copy,
   although explicit lexical retrieval does not use vectors. This unnecessary
   work is confirmed by the source path; its individual CPU share is not measured.
   A fix needs lexical independence coverage and retained hybrid controls.
3. **Evidence breadth, not a demonstrated ranking defect:** the direct Bannockburn answer remains **fourth**. The
   compact three-passage packet loses it; the normal twelve-passage packet
   retains it. Do not shrink the normal evidence limit to make answers look
   faster. Carry this positive/negative pair into the existing
   [RAG-QE-06/RAG-QE-09 work](query-engine-backlog.md), owned by `ragquery` and
   `ragretrieval`, before changing variant, neighbor or diversity ranking.

No performance target was declared met. Hybrid retrieval, a fresh product
answerer call, installed-client upgrade and corpus-wide content repairs are
outside this Test 5. Evidence and reproducible invocation are in the
[capture directory](qa/test5-mcp-20260914/README.md).
