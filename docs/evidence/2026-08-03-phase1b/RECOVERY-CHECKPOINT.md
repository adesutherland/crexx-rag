# Phase 1B Recovery Checkpoint

Status date: 2026-08-03. Result: accepted recovery baseline before
`P1-LLM-03` implementation.

The interrupted session had completed `P1-LLM-01` and `P1-LLM-02`, marked
`P1-LLM-03` active, and created no `P1-LLM-03` implementation artifact. The
accepted provider sources and tests were reproducible. Recovery review then
corrected these housekeeping issues:

- provider methods now reject a request whose declared operation does not
  match the invoked method;
- result-state transitions clear stale embeddings, usage, and latency;
- the local OpenAI-compatible fixture validates the complete UTF-8 generation
  prompt and the exact embedding input;
- the typed-array initialization shadowing warning is removed;
- the `P1-LLM-01` warning statement and `P1-SQL-01` through `P1-SQL-07`
  programme-status range are accurate; and
- the user's later low-cost hosted-qualification authorization is recorded in
  the decision ledger and handoff without changing other exclusions.

Focused recovery validation passed both optimized and non-optimized programs
on `rxvme` and `rxbvm`:

```text
cmake --build --preset debug --target p1_llm_01 p1_llm_02
ctest --test-dir cmake-build-debug -L '^P1-LLM-0[12]$' --output-on-failure
```

The exact-label result was 2/2 passed in 12.58 seconds. Both compilation logs
were warning-free.

The required checkpoint baseline then produced:

- Debug configure/build: passed;
- Debug CTest: 41/42 passed in 307.39 seconds;
- sole failure: the unchanged CRI-15 `rxvme` socket-timeout status defect in
  `p1a_provider_boundary`;
- Release configure/build: passed; and
- `git diff --check`: passed.

No hosted request was made during this checkpoint and no credential value was
read, printed, or retained.

## Corrected Source Hashes

```text
674b211855709cb7436c16629887c527078dada1848da3b5a2a484d88f26693b  incubator/phase1b/provider/provider_contract.crexx
b9c0fd50d510da3646ec40364d19fae6fe5b676ac1a3986644bac74d7fb3e11f  incubator/phase1b/provider/provider_facade.crexx
f4c9f40eddbadd229a1657b42954461f6fb1b2f6b7ded3beacfd5d50a093f1b3  incubator/phase1b/provider/openai_compatible_provider.crexx
e195b2a86579e9c2b709478b172b5ff8b9c414deb49fe4810626f4a6e5afe26c  incubator/phase1b/provider/p1_llm_01.crexx
5b5996c51e5866ce6768a2f02da2ec2a97132fb33d6caae50d12071e78f6484e  incubator/phase1b/provider/p1_llm_02.crexx
e9b6c5ee93252661766b4f003af19e4b1944f560637ce7a095f61dd12503ea8c  cmake/P1Llm01.cmake
1774c62926ab895193e107fa06b7ae80e7f3e25acab186da610dacf8976a6725  cmake/P1Llm02.cmake
6c46c6b397bdc834be8d71a5d23d482190a2b0f787c123cdc09725f80f871f26  tests/p1a_provider_loopback.cpp
```
