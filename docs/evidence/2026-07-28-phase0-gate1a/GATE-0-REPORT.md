# Gate 0 Report — Passed

Date: 2026-07-28.

## Decision

Gate 0 passes. P0-01 through P0-07, including P0-04A, have exact retained
evidence and reproducible validation. The Gate-0 full build passed 17/17 tests.
Under the approved execution unit, Phase 1A may proceed without another user
turn. This decision authorizes no dual-write, retirement, Phase 1B, Phase 2,
production hardening, donation packaging, commit, push, or pull request.

The exact Gate-0 commands and results were:

```text
cmake --preset debug                       exit 0
cmake --build --preset debug               exit 0; ninja: no work to do
ctest --preset debug --output-on-failure   17/17 passed; 26.17 sec
```

## Accepted Phase-0 Evidence

- P0-01: repository/toolchain/machine/provider fingerprint plus the initial
  compiler failure and bounded Level B recovery;
- P0-02: 8 synthetic redistributable fixture files, 9,039 bytes total, with
  exact SHA-256 hashes and every required case shape;
- P0-03: 2 semantic golden files and 2 exact-comparison CTests covering all
  required oracle behaviors without volatile IDs;
- P0-04: 5 Scotland-shaped evidence judgement cases;
- P0-04A: 4 held-out IT questions with a separately retained answer key;
- P0-05: 4 negative defect goldens, all explicitly `desired_parity:false`;
- P0-06: same-session native/`rxvme`/`rxbvm` component measurements with raw
  CSV and process memory evidence; and
- P0-07: 19 verified frozen artifact hashes, provisional thresholds, and a
  fixed/blinded evidence-answer protocol.

The first clean-oracle run failed reproducibly:

```text
64% tests passed, 4 tests failed out of 11
```

The four failed tests were:

1. `crexx_deterministic_extractor_smoke`
2. `crexx_hybrid_extractor_smoke`
3. `crexx_generic_pipeline_smoke`
4. `use_case_wrapper_smoke`

All four fail during installed `rxc` compilation, before the cREXX controller
or oracle behavior runs. The exact compiler is
`crexx-1.0.0-beta.3+local.g057592681c0c` built 2026-07-28. It emits optimized
`parseplan` inline assembler from ordinary Level G `PARSE VAR`, then rejects the
generated fragment:

```text
Internal error in exit_fragment @ 2:56 - #ASSEMBLER_ONLY_LEVELB: Inline assembler is only supported in Level B.
```

The focused test rerun failed identically. The seven native/CLI/MCP/plugin tests
that do not compile the affected Level G parse sites passed. Configure and build
also passed. The user then authorized reverting the maintained procedural
controllers to Level B while keeping the facade Level G. After that bounded
change, the focused recovery passed 4/4 and the exact full baseline passed
11/11. The original failure remains retained as a compiler-surface defect.

## Minimized Reproducer

[`repro/levelg-parseplan-repro.crexx`](repro/levelg-parseplan-repro.crexx) is a
standalone Level G program containing only an argv array, a loop, and one
`PARSE VAR` delimiter operation. Installed `rxc` fails it with the same single
`#ASSEMBLER_ONLY_LEVELB` diagnostic. `rxc -n` fails identically, so disabling
the normal optimizer flag is not a local workaround.

## Frozen Thresholds And Protocol

The provisional selection thresholds are retained in `thresholds.json`:

- quality: at least 13/16 per case, 85% over the 9 judged cases, at least 90%
  required-passage recall, and zero critical evidence failures;
- context: at most 65,536 serialized evidence bytes, 12 narrative passages, 8
  accepted claims, 8 graph leads, and zero unresolved citations;
- latency: 5 ms SQLite write, 10 ms bounded vector total, 10 ms cREXX algorithm,
  100 ms JSON parse, 5 ms record materialization, 20 ms JSON encoding, and 100
  ms for the deterministic 25 ms provider-wait case; and
- memory: at most 16 MiB for the native bounded vector probe and 64 MiB for each
  cREXX VM process.

All measured rows were inside these thresholds. The protocol blinds answer
production from rubric/answer keys, blinds two scorers from implementation
identity, uses a third adjudicator for material disagreement, and judges
evidence propositions/citations rather than exact prose.

## Provider Scope Amendment

Phase 0 made no hosted call and did not read `GEMINI_API_KEY`. The user's later
instruction selects Google/Gemini APIs for Phase-1A LLM access and supplies the
credential through that environment variable. That explicit later instruction
supersedes the original local-only provider choice for the one bounded Phase-1A
canary. Deterministic provider tests remain loopback-only, the credential must
never be printed or retained, and no non-Gemini hosted provider is authorized.

No inference from sister PERF2 results was used. The read-only CREXX checkout
remained untouched throughout Gate 0.
