# Level-G-First Migration Evidence

Status date: 2026-08-04. Result: accepted implementation of the user's
Level-G-first language strategy. This is a post-Gate maintenance migration; it
does not revise retained Gate-1B measurements or approve a withheld production
capability.

## Decision

Advanced user-facing libraries and application code use Level G. Level B is
reserved for CREXX bootstrap/foundation implementation or an explicitly
justified low-level mechanism that Level G cannot express. Importing an
installed Level-B foundation library does not require a Level-B caller, and a
facade must provide a real public or transport contract rather than exist only
to cross language levels.

This decision is recorded as G1B-D6 in the
[Gate-1B decision ledger](../../gate1b-decision-ledger.md). It supersedes the
historical Gate-1A D7 Level-B-core/Level-G-facade split for maintained and
future implementation.

## Toolchain And Source State

- repository baseline: `428204e27e38fc45c184ba2519956ee2b553386f` on `main`,
  with the documented housekeeping worktree changes present;
- installed compiler: `crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty`;
- host: Linux 7.0.0-28-generic x86_64;
- Phase-1B cREXX sources: 46 Level G, zero Level B after migration.

## Constraint Requalification

Before editing maintained sources, the retained CRI-01/04/05 closure CTest
passed optimized and non-optimized on `rxvme` and `rxbvm`. Scratch copies of
all 46 Phase-1B cREXX sources then compiled as Level G in both compiler modes.
The generated-plugin external consumer passed its dedicated installed-SDK
proof, and the following representative runtime tests passed on both VMs in
both modes:

- provider contract and facade;
- typed SQLite record and facade boundaries;
- native-golden algorithm parity;
- job budget reservation and settlement;
- the complete 11,684-by-768 vector workload; and
- the installed RXPA external consumer.

This confirms that the historical CRI-01 record-return and CRI-05 Level-G
`PARSE` constraints are closed in the installed toolchain. Direct float32
access used by the exact vector implementation also compiles and runs at Level
G; it does not require an authored assembler block.

## Maintained Changes

- changed every `incubator/phase1b/**/*.crexx` source to `options levelg`;
- replaced Level-B/Level-G crossing terminology in live result strings and
  CMake labels with direct/facade/plugin boundary terminology;
- updated the programme decision, vision, architecture, roadmap, status, test
  policy, root README, and source-adjacent package documentation;
- added `crexx_language_level_audit`, which scans maintained Phase-1B and
  current `crexx/` sources and checks authoritative policy anchors.

Completed Gate-1A probes, dated evidence sources, minimized compiler/runtime
reproducers, and the Phase-0 component benchmark retain their historical
language levels. They are evidence or low-level capability probes, not the
template for Phase 2.

## Verification

```text
cmake --preset debug
  PASS

cmake --build --preset debug
  PASS, 10 build steps

ctest --preset debug \
  -R '^(donation_docs_audit|crexx_language_level_audit|p1_rxpa_01|p1_rec_01|p1_llm_01|p1_vec_03|p1_alg_05|p1_job_03)$' \
  --output-on-failure
  PASS, 8/8 in 37.32 seconds

ctest --preset debug --output-on-failure
  EXPECTED BASELINE, 57/58 in 494.77 seconds
  Phase-1B: 28/28 passed
  Sole failure: p1a_provider_boundary (CRI-15)
```

The full run reproduced CRI-15 unchanged: Linux `rxvme` converted the intended
socket receive-timeout state into `-5`, `received text is not valid UTF-8`.
That failure is independent of the Level-G migration and remains open in the
[integration issue ledger](../../crexx-integration-issues.md). No hosted request
was made during this qualification.

## Conclusion

There is no current technical requirement for a Level-B application core or
Level-G compatibility wrappers. Phase 2 can start from one Level-G application
and advanced-library model, consuming Level-B foundation facilities only at
their natural CREXX boundary.
