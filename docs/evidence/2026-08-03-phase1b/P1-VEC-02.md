# P1-VEC-02 Representative Exact Ordering

Status date: 2026-08-03. Result: accepted.

The retained workload shape is represented by a deterministic scratch SQLite
fixture containing 11,684 `f32le-v1` vectors of dimension 768. The fixture uses
a closed-form cosine oracle: identity `101` is the query vector, identities
`202` and `303` are an intentional equal-score pair, identity `404` is fourth,
and every remaining dense non-zero vector is orthogonal to the query.

The Level-B exact-search module reads keyset pages of 128 rows, validates the
application-owned codec/count/meaning before arithmetic, computes cosine
directly over the canonical bytes, selects page top-k, and merges only those
page results into the global top-k. It never materializes the corpus as a
single cREXX array.

Optimized and non-optimized modules passed on `rxvme` and `rxbvm`. Every cell
processed 92 pages, 11,684 rows, and 35,893,248 vector bytes. All returned the
same top ten:

```text
101,202,303,404,1,2,3,4,5,6
```

The `202,303` tie followed the specified score-descending,
identity-ascending rule. Scores also matched the human-auditable oracle at
approximately `1.0`, `0.8`, `0.8`, `0.6`, then `0.0`.

```text
cmake --build --preset debug --target p1_vec_02
ctest --test-dir cmake-build-debug -L '^P1-VEC-02$' --output-on-failure
```

- final target: 7.81 seconds, peak RSS 127,748 KiB;
- exact-label CTest: 1/1 in 7.63 seconds, peak RSS 127,732 KiB;
- four-cell result: `raw/p1-vec-02-commands-and-output.txt`;
- command, timing, and source hashes: `raw/p1-vec-02-*`.

The fixture is synthetic, deterministic, and shape-representative because the
historical corpus library is not a live test dependency. It proves exact
ordering, not corpus relevance or a production latency/memory result;
component measurements remain `P1-VEC-03` work.
