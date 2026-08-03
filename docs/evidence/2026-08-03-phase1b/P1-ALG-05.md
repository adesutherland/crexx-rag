# P1-ALG-05 Native-Oracle Parity And Profile

Status date: 2026-08-03. Result: accepted with a crossed performance trigger.

The native-v1 semantic oracle was executed from the current Debug build and
matched the retained nine-record JSONL golden byte for byte. The Phase-1B
Level-B scenario then exercised the overlapping and strengthened semantics on
both VMs in optimized and non-optimized form:

- deterministic chunking and two-source lexical retrieval;
- identical-ingest zero writes and zero provider calls;
- unaffected paragraph identity reuse across immutable revisions;
- forward directional claim identity with exact active support;
- typed passage, ambiguity, and non-factual vector lead assembly; and
- source retraction followed by unsupported-claim retraction.

All semantic cells passed. The algorithm profile performs 2,000 representative
fixture fingerprint and paragraph-split operations. The inherited provisional
10,000-us trigger was crossed in every cell:

| Cell | Algorithm time | Process peak RSS |
| --- | ---: | ---: |
| noopt-rxvme | 102,460 us | 24,952,832 bytes |
| noopt-rxbvm | 104,666 us | 16,785,408 bytes |
| opt-rxvme | 64,396 us | 25,374,720 bytes |
| opt-rxbvm | 63,241 us | 17,178,624 bytes |

The 64-MiB process-memory trigger was not crossed. The timing is not hidden by
a faster Phase-0 microbenchmark: this measured workload includes the actual
Phase-1B fixture fingerprint and chunk-array construction. It is correctness
evidence, not production approval. Durable collision-resistant identity and
any measured generic acceleration require a later decision because
`P1-HASH-01` is excluded from this worklist.

```text
ctest --test-dir cmake-build-debug -R '^p1_alg_05$' --output-on-failure
ctest --test-dir cmake-build-debug -L '^P1-ALG-0[1-5]$' --output-on-failure
```

- exact item CTest: 1/1 in 8.47 seconds;
- algorithm closeout: 5/5 in 33.64 seconds, peak harness RSS 130,176 KiB;
- native output, per-cell metrics, timing, and hashes: `raw/p1-alg-05-*`;
- closeout evidence: `raw/algorithm-closeout-ctest.*`.

This accepts the bounded scratch-schema semantic parity slice and retains the
performance limitation for Gate 1B. It does not approve a production schema,
durable identity implementation, dual-write, or native-core replacement.
