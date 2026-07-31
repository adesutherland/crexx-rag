# Phase 0 And Phase 1A Implementation Handoff

Copy the prompt below into the next implementation task.

```text
Work in /Users/adrian/CLionProjects/crexx-rag.

Objective

Execute only this approved diagnostic programme:

1. Phase 0 — Freeze The Oracle And Measurement Protocol.
2. If and only if Gate 0 is fully evidenced, Phase 1A — Bounded Boundary
   Selection.
3. Produce the Gate-1A decision packet and stop unconditionally for the user's
   boundary decision.

This prompt explicitly authorizes moving from a passing Gate 0 into Phase 1A
without another user turn. It does not authorize proceeding past an incomplete
Gate 0. It never authorizes Phase 1B, Phase 2, production hardening, full
donation work, hosted-provider qualification, cutover, native retirement,
commit, push, or pull request.

Required first actions

1. Read /Users/adrian/CLionProjects/crexx-rag/AGENTS.md completely.
2. Read these current programme documents completely:
   - docs/README.md
   - docs/crexx-only-vision-and-specification.md
   - docs/crexx-only-review-findings.md
   - docs/crexx-only-architecture.md
   - docs/crexx-only-implementation-roadmap.md
   - docs/crexx-only-user-guide.md
   - docs/test-strategy.md
   - docs/pipeline-status.md
   - prompts/crexx-rag-agent-AGENTS.md
3. Read the native-v1 archive index and the archived algorithm/oracle material
   needed by each fixture:
   - docs/archive/README.md
   - docs/archive/native-v1/project-readme.md
   - docs/archive/native-v1/graph-retrieval-methodology.md
   - docs/archive/native-v1/domain-profiles.md
   - docs/archive/native-v1/tutorial-import-improve-query.md
   - docs/archive/native-v1/pipeline-status.md
   - docs/archive/native-v1/test-strategy.md
   - docs/archive/native-v1/scotland-qa-test-notes.md
   - prompts/archive/native-v1/scotland-qa-agent-test-AGENTS.md
4. Inspect the current C ABI, chunker, core, MCP evidence assembly, cREXX
   wrapper/profile/controllers, CMake, tests, and fixtures relevant to each
   oracle behavior. Do not assume the archive is more authoritative than code.
5. Before inspecting the sister repository, read its instructions completely:
   - /Users/adrian/CLionProjects/CREXX/AGENTS.md
   - /Users/adrian/CLionProjects/CREXX/performance/AGENTS.md
6. Capture branch, HEAD, status, and diff summaries for crexx-rag and the sister
   CREXX checkout before editing. Treat every pre-existing change as user-owned.
7. Create a resumable implementation worklist mapped one-to-one to P0-01 through
   P0-07, explicitly including P0-04A, and P1A-SDK-01 through P1A-SUR-01. Keep
   at most one item active and attach exact evidence paths/results before
   accepting an item.

Repository and sister-work boundaries

- Make writes only in /Users/adrian/CLionProjects/crexx-rag and temporary
  scratch directories.
- Assume the sister CREXX PERF2 programme completes successfully for planning.
- Do not edit, build in, reconfigure, install into, commit, stash, clean, or
  otherwise change /Users/adrian/CLionProjects/CREXX. It is read-only reference
  material and has active user work.
- For P1A-SDK-01 only, exact required CREXX headers/helpers may be copied into a
  temporary version-matched scratch prefix. Write nothing back and do not
  install into /Users/adrian/.local.
- Preserve the native C++ core, stable C ABI, rx_rag bridge, version-1 bundle,
  CLI/MCP behavior, and current tests as the executable oracle.
- Never dual-write a live library. Use sanitized fixtures, scratch libraries,
  and copies.
- Do not stash, reset, clean, checkout over, or reformat unrelated changes. If
  an intended edit cannot be merged safely with user work, stop and report the
  exact overlap.
- Do not stage, commit, push, or open a PR unless separately requested.

Implementation rules

- Product/domain algorithms, SQL repositories, schema, source/chunk/claim/job
  semantics, policy, and evidence assembly are cREXX application code.
- Native Phase-1A experiments expose only generic mechanisms such as typed
  SQLite access. They must contain no RAG, source, chunk, graph, claim, profile,
  job, or embedding concepts.
- Do not move an algorithm into product-specific native code to hide a cREXX
  weakness. Record a minimized reproducer, exact measurement, and capability
  classification instead.
- Use cREXX Level B for maintained algorithms, fixtures, benchmarks, and
  analysis tools where practical; use Level G for thin facades, C/C++ only for
  generic plugins, and CMake/CTest for integration. Shell may bootstrap but
  must not own an algorithm. Do not introduce Python into the repeatable path.
- Provider calls in the new slice must use the cREXX provider/HTTP surface
  directly. Do not shell through curl, the native-v1 CLI, or a RAG-specific
  model adapter.
- This entire Phase-0/Phase-1A execution unit may use deterministic protocol
  fixtures and local loopback providers only. Make no hosted calls and use no
  hosted credentials.
- Use small target-only build/test loops while developing. Run the full project
  configure/build/CTest baseline in Phase 0 and again at Gate 1A.

Phase 0 deliverables

Complete P0-01 through P0-07, including P0-04A.

1. Create a dated evidence index containing exact crexx-rag and read-only CREXX
   commits/dirty-state descriptions, installed cREXX version, compiler and both
   available VM variants, machine/build/provider details, fixture/corpus hashes,
   commands, raw outputs, skips, and summaries.
2. Create redistributable fixtures:
   - a small version-1 generic IT-architecture fixture;
   - a sanitized Scotland-shaped fixture;
   - exact keyword/keyphrase, alias, semantic-paraphrase, ambiguity, chronology,
     multiple-support, source-stance, deletion, and directed-path cases.
   Do not commit copyrighted, secret, or private corpus material.
3. Capture semantic goldens for chunking, candidate census/adjudication,
   mention/graph seeding, extraction ranking, queue status, source deletion,
   lexical/vector/graph retrieval, and answer-evidence packets. Compare semantic
   records, not volatile row IDs or incidental serialization.
4. Add explicit negative demonstrations of the oracle's current defects:
   same-URI chunk-ID churn, stale graph support after source change/deletion,
   unsafe queue crash boundaries, and whole-result fixed-buffer JSON
   materialization. Label these as defects, never desired parity.
5. Convert the Scotland lessons and a held-out IT set into judged cases for
   passage relevance, keyword/alias expansion, claim support/stance/time, graph
   leads versus supported claims, citation resolution/entailment,
   ambiguity/conflict, and expected evidence gaps. Judge evidence, not exact
   generated prose.
6. Implement a same-session benchmark harness that reports SQLite, cREXX
   algorithm, provider wait, JSON/record/codec, and vector
   transfer/decode/compute/selection/memory separately. Preserve raw results;
   do not extrapolate from selected PERF2 microbenchmarks.
7. Produce the Gate-0 report with frozen fixture sizes, hashes, measurement
   protocol, provisional quality/context/latency/memory thresholds, and a
   fixed/blinded answer-evaluation protocol.

Gate 0 behavior

If any build, hash, golden, defect case, judgement label, raw benchmark, or
protocol is incomplete or non-reproducible, stop at Gate 0 and report the exact
blocker. Do not begin Phase 1A.

If Gate 0 passes, mark only evidenced P0 items accepted and continue to Phase 1A
under this prompt. Gate 0 does not authorize dual-write or retirement.

Phase 1A deliverables

Implement only P1A-SDK-01 through P1A-SUR-01. These are boundary experiments,
not production libraries.

P1A-SDK-01

- Assemble a temporary version-matched RXPA SDK in a scratch prefix.
- Build and run a trivial external plugin with the crexx-rag vendored fallback
  disabled.
- Record input hashes, paths, compile/link/load commands, and diagnostics.

P1A-SQL-01

- Put the generic experiment in a clearly separated incubation area.
- Implement only connection, prepared statements, typed null/integer/real/text/
  blob bind and read, cursor iteration, rollback, FTS5, structured errors, and
  deterministic cleanup.
- Use opaque ownership-safe handles and reject stale/closed handles.
- Do not expand into backup, full WAL administration, ORM behavior, ADDRESS
  SQLITE hardening, or donation packaging.

P1A-DATA-01

- Carry one representative provider payload through a parse-once typed boundary.
- Carry a paged SQLite result into typed cREXX records without a whole-corpus
  JSON string.
- Measure parse, copy/materialization, and encoding costs separately.

P1A-LLM-01

- Define the smallest provider-neutral cREXX request/result/error contract.
- Complete one local OpenAI-compatible generation call and one local embedding
  call, with timeout and structured-error evidence.
- Keep deterministic protocol tests independent of a live model, but require one
  recorded real local-provider canary for Gate 1A. Do not substitute hosted use.

P1A-VEC-01

- Round-trip a bounded page of versioned float32 blobs through SQLite.
- Run exact cosine/top-k in cREXX and compare deterministic ordering/ties with an
  oracle.
- Measure DB transfer, decode, arithmetic, selection, peak memory, and total
  time independently on both supported VM variants.
- Recommend a later baseline; do not implement FAISS/rxvector hardening.

P1A-ALG-01

Build one deliberately small cREXX vertical slice that:

- captures an immutable source artifact/revision;
- deterministically chunks and FTS-indexes it;
- reingests identical input with zero library writes and provider calls;
- edits one paragraph while reusing safe derived content;
- promotes one normalized directional claim with exact support;
- retracts that support when its revision is superseded/removed; and
- emits an evidence packet containing a passage, supported claim, ambiguity or
  graph/vector lead, stable citation, and explicit gap.

Use a scratch schema only. Do not begin the production schema-v2 module tree or
broad translation.

P1A-JOB-01

- Implement one durable item with atomic claim and a DB-issued monotonic fencing
  token.
- Perform provider/work execution outside the claim transaction.
- Verify the current fence during atomic promotion/finalization.
- Force termination before and after promotion; prove idempotent recovery,
  non-duplicated support, and rejection of a stale replaced worker.
- Do not harden the full scheduler, retry system, or multi-worker service.

P1A-SUR-01

Carry the same typed status/evidence record through a minimal Level G facade,
CLI JSON, ADDRESS RAG, and MCP structuredContent adapter. Assert semantic
equality across all four. Keep adapters thin; do not implement the full command
vocabulary, production MCP permissions, or installable skills.

Minimum validation

- Baseline and Gate 1A:
  cmake --preset debug
  cmake --build --preset debug
  ctest --preset debug --output-on-failure
- Target-only CTest coverage for every Phase-1A slice.
- SQLite: null, integer boundaries, real, Unicode and empty text, embedded-NUL
  blob, values beyond old buffers, rollback, FTS5, stale handle, forced cleanup.
- Data: Unicode, empty, missing, null, arrays/objects, malformed input, paging.
- Provider: deterministic success, malformed response, timeout, connection
  failure, plus the separate real local canary.
- Vector: ordering/ties and component measurements on both supported VMs.
- Algorithm: first load, identical no-op, paragraph edit/reuse, retraction,
  citation, and evidence contents.
- Job: required crash/fence boundaries and duplicate-support prevention.
- Surfaces: semantic equality across all four adapters.
- Record an explicit reason for an unavailable VM/provider mode.
- Finish with git diff --check, the full exact test count, and a status/diff audit
  proving pre-existing user work and every sister-repository file were preserved.

Gate 1A decision packet

Report evidence-backed choices for:

- SQLite ownership, handle, typed-value, and record boundaries;
- typed records versus parse-once JSON;
- provider request/result/error contract;
- pure-cREXX vector baseline and acceleration trigger;
- source/generation publication model revealed by the slice;
- lease/fencing model;
- Level G/CLI/ADDRESS/MCP facade shape;
- correctness, time, memory, and failure results;
- minimized cREXX surface weaknesses;
- application code versus local generic incubation versus future CREXX donation
  candidate versus blocked external dependency;
- rejected alternatives, unresolved risks, and the exact Phase-1B choices that
  require user approval.

Prepare a paste-ready successor decision prompt. Then stop. Do not implement the
selected production boundaries, expand to Phase 1B/2, prepare full donation
bundles, modify CREXX, retire native code, or continue automatically.

Stop early rather than expand scope if Gate 0 fails, the sister tree would need
a write, user work would be overwritten, generic code acquires RAG semantics,
the only solution hides application logic in native code, the SDK cannot be
made version-consistent in scratch, the real local canary is unavailable, or a
required boundary lacks retained correctness/profile evidence.
```
