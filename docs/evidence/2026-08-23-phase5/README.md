# Phase 5 Retrieval And Evidence Record

Date: 2026-08-23

Scope: current macOS ARM64 development host

Status: Phase 5 and Gate 5 accepted for the recorded macOS scope; exact
downstream Linux and the Phase-7 hosted cREXX transport qualification remain
open.

## Implementation

| Item | Result |
| --- | --- |
| P5-01 | `ragquery` implements deterministic normalized plans, exact phrases, registered aliases, bounded spelling candidates, comparison/time/relationship intents, ambiguity and canonical SHA-256 identity. |
| P5-01A | Query terms retain phrase/prefix/expansion source plus versioned FTS occurrence, chunk, source-diversity and fingerprint statistics. |
| P5-02 | `ragretrieval` combines bounded FTS5 passages/context and directed typed-graph expansion resolved back to supporting immutable revision spans. |
| P5-03 | `ragembedding` owns immutable provider/model/dimension/input profiles, missing/reusable census, bounded batching, resumable persistence and atomic exact `.rxvec` generations over installed `rxvector`; incompatible state falls back lexically. |
| P5-04 | Deterministic reciprocal-rank fusion retains lexical/vector/graph ranks, directness, source diversity, hop decay, temporal relevance and diversity with stable ties. |
| P5-05 | `ragevidencejson` encodes bounded `crexx-rag.evidence/1` and `crexx-rag.answer-context/1`; stable citations bind library, source, revision and UTF-8 byte span and resolve historically. |
| P5-06 | Accepted claims, independent support/contradiction, stance, attribution, effective time, conflicts, ambiguity, graph leads and gaps remain separate typed fields. |
| P5-07 | The frozen nine-question IT/Scotland matrix passes twice-reset deterministic scoring at 9/9, 144/144, required recall 17/17 and zero critical failures in all four compiler/VM cells. |
| P5-08 | The same packets were compared with the current native-v1 MCP output and a controlled full-source baseline; a separate bounded Gemini qualification scored typed evidence 143/144 versus control 130/144 with zero critical failures. |

No public Phase-6 transport surface is claimed by this phase.

## Permanent Focused Gate

The `phase5_retrieval` target and CTest compile `ragquery`, `ragembedding`,
`ragretrieval`, `ragevidencejson`, their Phase-2/3/4 dependencies, the scenario
and executable tutorial optimized and non-optimized, then execute both `rxvme`
and `rxbvm`.

The repeated 2026-08-23 direct gate passed:

```text
Phase 5 passed: four optimized/non-optimized dual-VM retrieval/tutorial cells, exact rxvector generation, 9/9 frozen deterministic judgements, stable evidence packets, and native-v1/full-context baselines
```

Representative optimized results were:

| VM | Questions | Score | Required recall | Critical failures | P50 / P95 / total |
| --- | ---: | ---: | ---: | ---: | ---: |
| `rxvme` | 9/9 | 144/144 | 17/17 | 0 | 73,423 / 117,628 / 608,162 us |
| `rxbvm` | 9/9 | 144/144 | 17/17 | 0 | 73,513 / 116,932 / 614,753 us |

Each judgement run resets the deterministic scorer twice. The matrix exercises
phrase/prefix/alias/spelling expansion; time/comparison/relationship intent;
published term statistics; binary exact vector search and lexical fallback;
direct graph paths versus adjacency; stable/historical citations; stance,
contradiction, ambiguity, conflict and gaps. Provider privacy denial proves
zero calls before the deterministic embedding route.

The executable tutorial produced six records byte-for-byte equal to
`tests/expected/tutorial-phase5.jsonl` in every cell.

## Baseline Measurements

The current native-v1 binary was used only as an executable oracle. Six frozen
sources were imported to a scratch version-1 library and nine
`library_answer_evidence` MCP requests were sent through one process.

| Projection | Nine-question bytes |
| --- | ---: |
| cREXX typed answer contexts | 69,295 |
| cREXX full evidence packets | 128,146 |
| current native-v1 MCP responses | 92,385 |
| repeated full micro-corpus text | 45,891 |

The largest cREXX answer context was 10,638 bytes. The typed answer projection
is smaller than the current native MCP response set and preserves explicit
stable citations, stance, time, ambiguity and gaps. The deliberately tiny
5,099-byte source corpus is smaller when repeated wholesale and lacks those
types; this record therefore makes no universal whole-context size claim.

## Hosted Qualification

The checked-in `tools/qualify_phase5_hosted.py` harness is opt-in and refuses
to send data without `--confirm-hosted-public-fixtures`. It uses only the six
public frozen fixtures and a symbolic `env:GEMINI_API_KEY` reference. Secret
values and headers are never retained or printed.

Exact protocol:

- Gemini 3.5 Flash;
- temperature zero and minimal thinking;
- one attempt per call;
- maximum 768 answer and 512 scorer output tokens;
- one typed and one full-context answer for each of nine questions;
- two blinded scorer resets per pair, with a third only for the declared
  disagreement rule; and
- exact structured response schema, request hashes, response/model ids, usage
  and latency retained per case.

Result:

```text
P5_HOSTED_OK provider=gemini model=gemini-3.5-flash credential_reference=env:GEMINI_API_KEY temperature_millionths=0 thinking_level=minimal max_attempts=1 public_fixtures=1 passing=9/9 score=143/144 control_score=130/144 critical_failures=0 calls=36 adjudications=0 input_tokens=183033 output_tokens=7335
```

`hosted/summary.json`, `hosted/case-1.json` through `case-9.json`, and
`hosted/qualification.log` are the retained exact result. The output is a
single bounded hosted qualification, not a deterministic CTest.

## cREXX Hosted Transport Finding

An equivalent hosted probe through the incubated Level-G
`industrial_provider` was attempted against both Gemini and OpenAI on both
concrete VMs. It returned `HTTP total deadline exceeded before response
completion` before decoding a response. Direct `curl --http1.1` calls to the
same APIs returned HTTP 200 in approximately 0.9 and 1.66 seconds, and the
existing CREXX TLS live test passed its trusted-host and mismatch cases.

This narrows the current finding to completion handling for these hosted POST
responses in the cREXX provider/HTTP-controller path; it is not evidence of a
general TLS or provider outage. The external secret-safe harness establishes
the Phase-5 quality result, but it does not qualify the cREXX hosted adapter.
Phase 7 owns the minimized reproduction and transport/provider-surface closure.

## Validation And Boundaries

- focused Phase-5 direct gate: pass;
- optimized and non-optimized compilation: pass;
- `rxvme` and `rxbvm`: pass;
- exact installed `rxhash`, `rxjson`, SQLite and packed `rxvector`: pass;
- current native-v1 CLI/MCP oracle: pass;
- deterministic zero-outbound regression: pass;
- bounded public-fixture Gemini qualification: pass;
- credential-value audit of retained Phase-5 files: zero matches;
- fresh ordinary Debug focused target: pass;
- fresh Release focused target: pass;
- focused Apple AddressSanitizer target: pass through the CREXX runner with a
  coherent ASan-installed CREXX product and downstream build; retained log
  `/tmp/crexx-rag-asan-logs/phase5/20260824-014602-build/build.log`;
- focused Apple-ASan provider compatibility regression (`p1_llm_02`,
  `p1_llm_03`, `p1_llm_04`): pass; retained log
  `/tmp/crexx-rag-asan-logs/phase5-provider-regression/20260824-021711-build/build.log`;
- Apple LeakSanitizer: unsupported, explicitly disabled, and not claimed;
- full ordinary Debug CTest: 72/72 passed in 147.01 seconds after the
  temperature-mapping compatibility regression was repaired;
- `git diff --check`: recorded at the ordered Phase-5 commit closeout; and
- exact downstream Linux: not run and not claimed.

No source in the sibling CREXX repository was changed. No live library was
dual-written, no provider key was retained, and no native code was removed.

The first full Debug closeout found that the shared loopback fixture had begun
requiring `temperature: 0` in the older hardening scenario even though the
compatible request default is unspecified/omitted. That made all 25 sequential
`P1-LLM-03` calls fail. The final fixture requires explicit zero temperature in
the new mapping scenarios while retaining the older omission contract.
`P1-LLM-02`, `P1-LLM-03`, and `P1-LLM-04` then passed in Debug, Release, and
Apple ASan before the final 72/72 Debug gate.
