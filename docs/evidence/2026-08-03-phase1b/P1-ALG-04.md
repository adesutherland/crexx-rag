# P1-ALG-04 Typed Evidence Packet

Status date: 2026-08-03. Result: accepted.

The Level-B `evidence_packet` assembles typed evidence without flattening its
epistemic roles. A lexical passage and its normalized support ground an
accepted directional claim. An unresolved ambiguity remains explicit, and a
cosine result is labelled only as a vector lead with a mandatory limitation.

The four-cell proof established one packet containing:

- one current lexical passage;
- one accepted `subject-to-object` typed claim;
- one exact revision/byte-span support citation;
- one unresolved ambiguity with two candidate concepts;
- one vector lead produced by the accepted exact cosine boundary; and
- an explicit statement that vector proximity and ambiguity are not claims.

```text
cmake --build --preset debug --target p1_alg_04
ctest --test-dir cmake-build-debug -R '^p1_alg_04$' --output-on-failure
```

- exact CTest: 1/1 in 10.04 seconds, peak RSS 130,108 KiB;
- four-cell result: `raw/p1-alg-04-commands-and-output.txt`;
- CTest timing and source hashes: `raw/p1-alg-04-*`.

This accepts the bounded multi-kind evidence packet. Native-oracle parity and
profile evidence remain for `P1-ALG-05`.
