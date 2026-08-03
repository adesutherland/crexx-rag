# P1-ALG-01 Scratch Source And Lexical Slice

Status date: 2026-08-03. Result: accepted.

The Level-B `source_store` creates a scratch-only source model with immutable
revisions, content-owned chunks, revision/chunk occurrences, and an FTS5 index.
Paragraphs are split deterministically at blank lines. Active-revision joins
exclude stale FTS rows from retrieval without coupling source lifecycle rules
to the generic SQLite plugin.

The four-cell proof compiled optimized and non-optimized modules and ran them
on `rxvme` and `rxbvm`. Each cell established:

- one source, one active immutable revision, and three ordered paragraphs;
- deterministic revision and content-chunk identifiers;
- exact lexical hits for a term and a phrase, plus an empty miss;
- typed lexical-hit records containing revision, ordinal, body, rank, and
  stable chunk identity; and
- scratch database isolation with no production schema or provider calls.

`fixture-v1` is an explicitly weak deterministic fixture fingerprint. It is
not represented as collision-resistant or approved for production identity;
`P1-HASH-01` remains outside this worklist.

```text
cmake --build --preset debug --target p1_alg_01
ctest --test-dir cmake-build-debug -R '^p1_alg_01$' --output-on-failure
```

- exact CTest: 1/1 in 3.21 seconds, peak RSS 127,632 KiB;
- four-cell result: `raw/p1-alg-01-commands-and-output.txt`;
- CTest timing and source hashes: `raw/p1-alg-01-*`.

This accepts the scratch schema, deterministic chunking, and lexical FTS
slice. Revision no-op and paragraph reuse remain for `P1-ALG-02`.
