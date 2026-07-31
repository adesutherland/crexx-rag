# P1A-DATA-01 Follow-up — Indexed JSON Document

Status date: 2026-07-29. This user-approved follow-up refines only
`P1A-DATA-01`. At the time of this experiment it did not itself resume the
blocked Gemini canary or reach Gate 1A. It later became the accepted parse-once
boundary used to resolve that blocker under separate user authority. It still
does not replace the CREXX library or authorize Phase 1B.

## Decision result

The boundary is viable as maintained Level-B cREXX:

- `jsondocument` owns one immutable source value and parses it once into a
  packed structural index;
- `type`, `get`, `count`, and `members` retain the current one-based dot/bracket
  path semantics, so later call-site migration can be mechanical;
- JSON does not select a packed representation automatically. The caller must
  explicitly request either `as_f32_vector` or `as_i64_vector`, with an expected
  dimension where the contract knows one;
- `f32vector` and `i64vector` use a validated 16-byte, versioned,
  little-endian envelope. Their packed sizes at 3,072 elements are 12,304 and
  24,592 bytes respectively, including the header;
- callers obtain `payload()` once and use direct `<at..f32>` or `<at..i64>` in
  hot loops. Per-element object methods remain diagnostic conveniences.

An “array” is the JSON/IT representation. Once the caller supplies element type,
dimension, and (for `f32`) normalization metadata, the resulting value is a
mathematical vector represented by packed binary storage. JSON alone contains
no reliable signal that a numeric array is a vector, which precision is
intended, or whether it is normalized; heuristic auto-packing was therefore
rejected.

## Correctness evidence

CTest `p1a_json_document` compiled the module, test, benchmark, and minimized
probe as optimized and `-n` images and passed all four runtime cells:

| Compiler mode | Runtime | Result |
| --- | --- | --- |
| `-n` | `rxvme` threaded | pass |
| `-n` | `rxbvm` bytecode | pass |
| optimized | `rxvme` threaded | pass |
| optimized | `rxbvm` bytecode | pass |

Coverage includes raw and escaped Unicode (including a surrogate pair), empty,
missing, null, boolean, number, object, array, malformed/trailing input,
one-based dot/bracket paths, semantic agreement with installed `rxjson`, repeat
access, empty and 3,072-element projections, expected-dimension rejection,
non-numeric rejection, float32 range rejection, signed-int64 extrema and range
rejection, versioned envelope validation, corrupt/truncated payload rejection,
and direct packed access.

The repeatable command is:

```text
cmake --preset debug
ctest --preset debug -R '^p1a_json_document$' --output-on-failure
```

Result: `1/1`, 100% passed. The CTest entry internally executes four correctness
runs, four same-session benchmark runs, and four minimized optimizer-probe runs.
No provider call was made and no credential was read.

## Same-session measurements

Environment:

- installed compiler/runtime: `crexx-1.0.0-beta.3+local.g057592681c0c`;
- runtimes: `rxvme` threaded and `rxbvm` bytecode;
- host: Apple M5, arm64, macOS 26.5.2 build 25F84;
- access fixture: 4,394 bytes, 60 rows, 30 iterations;
- provider-shaped float fixture: 58,435 bytes and 3,072 values;
- integer fixture: 14,265 bytes and 3,072 values;
- projection/scan iterations: 10.

Across the four final cells, legacy repeated `rxjson` access and indexed reuse
reported these elapsed ranges:

| Operation | Installed `rxjson` | Indexed document |
| --- | ---: | ---: |
| deep get, 30 calls | 13,378–15,402 us | 167–224 us |
| tail get, 30 calls | 13,484–15,040 us | 117–159 us |
| count, 30 calls | 25,753–29,053 us | 43–52 us |
| members, 30 calls | 13,090–14,710 us | 52–102 us |
| one indexed parse | n/a | 215–374 us |
| reconstruct indexed document 30 times | n/a | 5,229–9,994 us |

The exact legacy extraction baseline deliberately stops at 128 float values:
9,150–11,365 us for one complete pass. It is not extrapolated. The indexed
128-value projection took 19–24 us after parsing.

For the 3,072-value provider-shaped fixture:

| Component | Four-cell elapsed range |
| --- | ---: |
| parse 58,435-byte JSON once | 985–1,703 us |
| ten `f32` projections | 2,306–2,665 us |
| ten direct `f32` scans | 211–264 us |
| parse 14,265-byte integer JSON once | 628–1,240 us |
| ten `i64` projections | 3,905–4,651 us |
| ten direct `i64` scans | 254–273 us |
| whole benchmark process maximum RSS | 22,020,096–27,623,424 bytes |

The packed document index used 123,060 bytes for the 3,072-value float fixture.
This is an explicit source-plus-index ownership cost, not a zero-copy claim.
The timing values are retained diagnostic observations, not an SLA or a
multi-run distribution.

## Minimized compiler-surface finding

The first implementation called tiny read helpers that accepted `.binary` by
value inside the element loop. In optimized images this made the 3,072-element
projection markedly slower. The retained minimized probe performs the same
30,720 reads three ways:

| Variant | `-n` range | optimized range |
| --- | ---: | ---: |
| helper with `.binary` by value | 1,145–1,170 us | 3,784–4,034 us |
| helper with `expose .binary` | 881–902 us | 228–277 us |
| direct `<at..u32>` | 189–232 us | 208–244 us |

All variants return the same checksum. The maintained class now uses explicit
exposure at necessary parser call boundaries and direct typed access in hot
loops. That removes the application regression without hiding the cREXX
weakness in native code. The minimized probe is a future CREXX compiler/library
candidate and remains part of this project's benchmark matrix.

## Retained artifacts

- implementation, tests, benchmark, probe, and API notes:
  `incubator/p1a/json_document/`;
- orchestration: `cmake/P1AJsonDocument.cmake` and CTest
  `p1a_json_document`;
- exact compile/load commands, outputs, component timings, process memory, and
  instruction/cycle counters:
  `raw/p1a-data-01-json-document/final-commands-and-results.txt` (the sibling
  `commands-and-results.txt` is the retained preliminary matrix);
- focused CTest, registered-test census, diff check, and repository-preservation
  audit: `raw/p1a-data-01-json-document/validation.txt`.

Final input hashes:

```text
2050072d552227d7c163771bc32440ee377c908fae98e79c57f216baff6a5586  binary_argument_optimizer_probe.crexx
581a0de24db50bc5f7a2f0e3e01f098c8476355ca93d7c28a1d00118e21878f9  json_document.crexx
167dbed913ab98ad373fc7a4765a34e14304932d6d34a9a76e0bb36017a80c6a  json_document_benchmark.crexx
683052a0a7580a67286ab99e8e1d8e538867f7ef0f5d0157d9b526e1c7af7879  json_document_test.crexx
6fcb54a073688540884752547476f837f3624dcc2e340c23b7085771d088262b  README.md
5b909e3bc53df7a34b407f40d851975d1ad70cc88d55fb04a90fb6e6a77558d7  P1AJsonDocument.cmake
767ae6fcfa3cacce97a538156587b16065dabd61df0d1c8352c4a27a61340254  final-commands-and-results.txt
```

## Boundary limitations and next decision

This experiment intentionally does not provide mutation, a full DOM/value
hierarchy, arbitrary-key path escaping, streaming input, automatic packing,
`f64`/`i32` codecs, schema coercion, or production packaging. The 40-byte node
record and linear sibling lookup are appropriate for the measured provider
payload but should be reviewed against larger object-heavy fixtures before a
CREXX-library replacement.

The clean release direction is to replace raw-string repeated calls with one
document object per payload, retain compatibility-shaped methods as a migration
aid, and make packed numeric projection explicit. Replacing CREXX `rxjson`,
changing dependent components, or preparing a donation remains a later,
separately approved action.
