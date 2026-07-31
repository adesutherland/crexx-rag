# 2026-07-28 Phase 0 And Phase 1A Evidence Index

Programme status: **Gate 0 passed; all bounded Phase-1A experiments passed;
Gate 1A reached and stopped for the user's boundary decision**.

The first exact baseline configured and built successfully, but full CTest failed
reproducibly at 7/11 after the installed cREXX toolchain changed to
`crexx-1.0.0-beta.3+local.g057592681c0c`. The compiler lowers ordinary Level G
`PARSE VAR` to a `parseplan` inline-assembler fragment and then rejects that
generated fragment with `#ASSEMBLER_ONLY_LEVELB`. This initially blocked the
native-v1 cREXX extractor/profile and use-case oracle tests. The user then
authorized reverting maintained procedural controllers to Level B. The focused
recovery passed 4/4 and the repeated exact full baseline passed 11/11. The
Level G facade remains Level G.

## Accepted Evidence

| Item | Result | Evidence |
| --- | --- | --- |
| P0-01 | Accepted after a user-authorized Level B recovery; full baseline 11/11 | [`raw/p0-01/environment.txt`](raw/p0-01/environment.txt), [`raw/p0-01/crexx-rag-git-state.txt`](raw/p0-01/crexx-rag-git-state.txt), [`raw/p0-01/crexx-git-state.txt`](raw/p0-01/crexx-git-state.txt), [`raw/p0-01/checksums.sha256`](raw/p0-01/checksums.sha256), [`raw/p0-01/baseline-build-and-test.txt`](raw/p0-01/baseline-build-and-test.txt), [`raw/p0-01/levelb-recovery.txt`](raw/p0-01/levelb-recovery.txt) |
| P0-02 | Accepted; 8 files, 9,039 bytes, full required-case coverage | [`fixtures/manifest.tsv`](fixtures/manifest.tsv), [`fixtures/coverage.md`](fixtures/coverage.md) |
| P0-03 | Accepted; 2/2 exact semantic golden tests | [`goldens/oracle-semantics.jsonl`](goldens/oracle-semantics.jsonl), [`goldens/answer-evidence.jsonl`](goldens/answer-evidence.jsonl) |
| P0-04 | Accepted; 5 Scotland-shaped judged cases | [`judgements/scotland-shaped-judgements.jsonl`](judgements/scotland-shaped-judgements.jsonl), [`judgements/rubric.md`](judgements/rubric.md) |
| P0-04A | Accepted; 4 blinded held-out IT cases | [`judgements/it-held-out-questions.jsonl`](judgements/it-held-out-questions.jsonl), [`judgements/it-held-out-judgements.jsonl`](judgements/it-held-out-judgements.jsonl) |
| P0-05 | Accepted; 4 undesired native-v1 defects reproduced | [`defects/oracle-defects.jsonl`](defects/oracle-defects.jsonl) |
| P0-06 | Accepted; native plus both VM variants measured in one session | [`benchmarks/protocol.md`](benchmarks/protocol.md), [`raw/p0-06/native.csv`](raw/p0-06/native.csv), [`raw/p0-06/rxvme.csv`](raw/p0-06/rxvme.csv), [`raw/p0-06/rxbvm.csv`](raw/p0-06/rxbvm.csv) |
| P0-07 | Accepted; 19 hashes, thresholds, fixed/blinded protocol | [`frozen-hashes.tsv`](frozen-hashes.tsv), [`thresholds.json`](thresholds.json), [`ANSWER-EVALUATION-PROTOCOL.md`](ANSWER-EVALUATION-PROTOCOL.md) |
| Gate 0 | Passed; full CTest 17/17 | [`GATE-0-REPORT.md`](GATE-0-REPORT.md), [`raw/p0-07/gate0-validation.txt`](raw/p0-07/gate0-validation.txt) |
| P1A-SDK-01 | Accepted; scratch version-matched external RXPA probe, fallbacks off | [`raw/p1a-sdk-01/sdk-manifest.txt`](raw/p1a-sdk-01/sdk-manifest.txt), [`raw/p1a-sdk-01/commands-and-diagnostics.txt`](raw/p1a-sdk-01/commands-and-diagnostics.txt) |
| P1A-SQL-01 | Accepted; focused CTest 1/1, typed SQLite/ownership cases passed | [`raw/p1a-sql-01/commands-and-results.txt`](raw/p1a-sql-01/commands-and-results.txt) |
| P1A-DATA-01 | Accepted; focused CTest 1/1, parse/materialize/encode and typed pages passed | [`raw/p1a-data-01/commands-and-results.txt`](raw/p1a-data-01/commands-and-results.txt) |
| P1A-DATA-01 refinement | Accepted; indexed JSON plus packed f32/i64 correctness/benchmark matrix on both VMs | [`JSON-DOCUMENT-REPORT.md`](JSON-DOCUMENT-REPORT.md), [`raw/p1a-data-01-json-document/final-commands-and-results.txt`](raw/p1a-data-01-json-document/final-commands-and-results.txt) |
| P1A-LLM-01 | Accepted; deterministic failure matrix plus one successful generation and exact 8-dimensional embedding canary; initial timeout retained separately | [`raw/p1a-llm-01/deterministic-provider.txt`](raw/p1a-llm-01/deterministic-provider.txt), [`raw/p1a-llm-01/gemini-canary.txt`](raw/p1a-llm-01/gemini-canary.txt), [`raw/p1a-llm-01/gemini-canary-failure.txt`](raw/p1a-llm-01/gemini-canary-failure.txt) |
| P1A-VEC-01 | Accepted; exact order/ties and component measurements on both VMs | [`raw/p1a-vec-01/commands-and-results.txt`](raw/p1a-vec-01/commands-and-results.txt) |
| P1A-ALG-01 | Accepted; immutable revision/no-op/reuse/support/retraction/evidence slice | [`raw/p1a-alg-01/commands-and-results.txt`](raw/p1a-alg-01/commands-and-results.txt) |
| P1A-JOB-01 | Accepted; real process crash/fence/idempotency matrix | [`raw/p1a-job-01/commands-and-results.txt`](raw/p1a-job-01/commands-and-results.txt) |
| P1A-SUR-01 | Accepted; Level G/CLI/ADDRESS/MCP semantic equality and minimized compiler weakness | [`raw/p1a-sur-01/commands-and-results.txt`](raw/p1a-sur-01/commands-and-results.txt) |
| Gate 1A | Passed as diagnostic selection gate; full 27/27 and stopped for D1–D9 user decisions | [`GATE-1A-DECISION-PACKET.md`](GATE-1A-DECISION-PACKET.md), [`raw/gate1a-validation.txt`](raw/gate1a-validation.txt), [`WORKLIST.md`](WORKLIST.md) |

No item is active. Gate 1A is the unconditional decision stop. The earlier stop
and its later authorized resolution are both preserved in
[`PHASE-1A-BLOCKER-REPORT.md`](PHASE-1A-BLOCKER-REPORT.md).

## Frozen Repository State

- `crexx-rag`: branch `main`, HEAD
  `97cd87e91344d6ac1773a054bd38df23eb128ed2`, upstream `origin/main`, `+0 -0`.
  The pre-existing user-owned documentation/archive work is enumerated in the
  retained git-state file. Programme evidence files were added without staging.
- read-only CREXX: branch `develop`, HEAD
  `12a11815ab082086fb95e4ca5e41bd1c0e241342`, upstream `origin/develop`,
  `+0 -0`, initially clean.
- No sister-repository write, build, reconfiguration, install, stash, clean,
  commit, push, or pull request occurred.

## Toolchain And Machine Summary

- Installed cREXX driver/compiler/assembler/VMs:
  `crexx-1.0.0-beta.3+local.g057592681c0c`, build date `20260728`.
- VM variants: `rxvme` threaded mode and `rxbvm` bytecode mode.
- Host: Apple M5, 10 physical/logical CPUs, 24 GiB RAM, macOS 26.5.2
  build 25F84, Darwin 25.5.0 arm64.
- Build: CMake 4.3.2, Ninja 1.13.2, Apple clang 21.0.0, SQLite 3.51.0,
  Debug preset, FAISS disabled.
- Local provider executable: llama.cpp `llama-server` build 9770
  (`75ad0b23e`), AppleClang 21.0.0, Darwin arm64.
- Provider status at capture: embedding `127.0.0.1:8081`, chat
  `127.0.0.1:8080`, and advisor `127.0.0.1:8084` were all down with stale or
  missing PID files. No provider call was made.

## Commands

The exact required baseline commands were:

```text
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

The focused reproduction was:

```text
ctest --preset debug -R crexx_hybrid_extractor_smoke --output-on-failure
rxc -o <temporary-prefix>/levelg-parseplan-repro \
  docs/evidence/2026-07-28-phase0-gate1a/repro/levelg-parseplan-repro.crexx
```

Both the first full and focused runs failed with the same compiler diagnostic.
Adding `rxc -n` did not avoid it. The user-authorized Level B recovery then
passed the focused 4/4 and final Gate-0 17/17 runs; both outcomes are retained.
