# P1-VEC-04 Evidence-Led Backend Recommendation

Status date: 2026-08-03. Result: accepted.

## Trigger Result

The vector section established the versioned storage boundary, exact ordering,
and the retained 11,684-by-768 component measurements. The decision triggers
resolve as follows:

| Trigger | Evidence | Result |
| --- | --- | --- |
| Exact correctness/order | Four cells returned `101,202,303,404,1,2,3,4,5,6`, including the `202,303` tie | Not crossed |
| 10,000-us latency | Full arithmetic measured 666,162 to 766,924 us; total measured 750,316 to 857,843 us | Crossed |
| 64-MiB process memory | Peak RSS measured 18,845,696 to 26,595,328 bytes | Not crossed |

Arithmetic, rather than SQLite transfer or codec validation, dominates. The
full-workload arithmetic is at least 66 times the retained 10,000-us trigger.
The result is not close enough for measurement noise to change the decision.

## Recommendation

Retain bounded-page pure-cREXX exact cosine/top-k as the Phase-1B correctness
oracle, functional fallback, and current implementation. It is correct,
deterministic, memory-bounded, and requires no unapproved dependency.

Do not approve it as the only production backend at Gate 1B. Recommend a
separately authorized generic `rxvector` qualification because the measured
bottleneck is reusable vector arithmetic. That capability must have an
independent non-RAG API, tests, examples, packaging, and matched workload
benchmarks before selection or CREXX donation is considered.

Do not select a SQLite vector extension or FAISS from this evidence. Neither
has an equivalent matched benchmark in the approved worklist, and the result
does not justify coupling vector truth to SQLite: SQLite remains the source of
truth while any vector accelerator remains a rebuildable sidecar or mechanism.
No vector backend, native plugin, production schema, or sidecar is implemented
or authorized by this recommendation.

## Validation

```text
ctest --test-dir cmake-build-debug -L '^P1-VEC-0[1-3]$' --output-on-failure
```

All three executable vector tests passed in 19.12 seconds. The retained result
is `raw/vector-closeout-ctest.txt`; item sources, timings, metrics, and hashes
are indexed by `raw/p1-vec-01-*` through `raw/p1-vec-03-*`.

This closes the Phase-1B vector section. It requests a later production
capability decision; it does not bypass the Gate-1B stop.
