# P1-ALG-02 Revision No-op And Chunk Reuse

Status date: 2026-08-03. Result: accepted.

The Level-B `source_lifecycle` layers immutable revision replacement over the
accepted scratch source store. Identical input returns before `BEGIN`, reports
zero library writes and provider calls, and preserves the active revision.
A superseding edit creates a new revision occurrence set while content-owned
chunk rows remain reusable.

The four-cell proof established:

- exact replay retained the original revision and did not change
  `total_changes()`;
- changing one of two paragraphs created one new chunk identity and reused the
  unaffected paragraph's exact existing identity;
- two immutable revisions retained four ordered occurrences backed by three
  unique chunk rows;
- only one revision remained active; and
- lexical retrieval returned only current-revision occurrences.

The scratch fixture fingerprint collision path rejects mismatched content
instead of silently merging it. Production hashing remains outside this item.

```text
cmake --build --preset debug --target p1_alg_02
ctest --test-dir cmake-build-debug -R '^p1_alg_02$' --output-on-failure
```

- exact CTest: 1/1 in 4.66 seconds, peak RSS 127,648 KiB;
- four-cell result: `raw/p1-alg-02-commands-and-output.txt`;
- CTest timing and source hashes: `raw/p1-alg-02-*`.

This accepts identical-ingest zero-write behavior and unaffected chunk identity
reuse. Claim support and retraction remain for `P1-ALG-03`.
