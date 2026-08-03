# P1-ALG-03 Normalized Claim Support And Retraction

Status date: 2026-08-03. Result: accepted.

The Level-B `claim_store` adds directional typed claims and independently
addressable support to the scratch source model. Claim semantic identity uses
normalized subject, predicate, and object identifiers; display labels are not
part of identity. Support records retain revision, reusable chunk, zero-based
UTF-8 byte span, exact passage, polarity, stance, and active state.

The four-cell proof established:

- one `subject-to-object` service/data-store claim became `accepted` with one
  exact active support;
- citation `#b0-40` resolved to the exact 40-byte passage;
- a mismatched span/passage pair was rejected before publication;
- revision retraction atomically deactivated its support and recalculated the
  unsupported claim to `retracted`; and
- the inactive historical support remained addressable.

```text
cmake --build --preset debug --target p1_alg_03
ctest --test-dir cmake-build-debug -R '^p1_alg_03$' --output-on-failure
```

- exact CTest: 1/1 in 6.13 seconds, peak RSS 127,612 KiB;
- four-cell result: `raw/p1-alg-03-commands-and-output.txt`;
- CTest timing and source hashes: `raw/p1-alg-03-*`.

This accepts the bounded normalized support/retraction lifecycle. Evidence-kind
assembly remains for `P1-ALG-04`.
