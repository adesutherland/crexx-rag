# P1-VEC-03 Representative Component Measurements

Status date: 2026-08-03. Result: accepted.

The `P1-VEC-02` deterministic 11,684-by-768 fixture was measured with fixture
construction outside the search total. The search retained keyset pages of 128
rows and reported SQLite materialization, codec validation, cosine arithmetic,
top-k selection/merge, bounded working memory, process peak RSS, and total time
separately.

The final exact-label CTest produced:

| Cell | SQLite transfer (us) | Decode/validate (us) | Arithmetic (us) | Selection (us) | Total (us) | Peak RSS (bytes) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `noopt-rxvme` | 56,688 | 7,213 | 666,162 | 16,230 | 750,316 | 26,083,328 |
| `noopt-rxbvm` | 59,214 | 8,695 | 712,400 | 16,464 | 800,996 | 18,845,696 |
| `opt-rxvme` | 60,153 | 7,557 | 688,406 | 15,487 | 776,000 | 26,595,328 |
| `opt-rxbvm` | 61,755 | 8,889 | 766,924 | 15,529 | 857,843 | 19,587,072 |

Every cell transferred 35,893,248 payload bytes, performed 8,973,312
dimension operations, retained the exact `P1-VEC-02` ordering, and produced
the same score and top-id checksums. The bounded page/query/top-k estimate was
399,680 bytes. Actual process RSS remained below the provisional 64-MiB
trigger on both VMs.

Arithmetic dominated the approximately 0.75-to-0.86-second search total. The
full-workload arithmetic and total both exceed 10,000 us by a wide margin;
correctness and memory did not trigger. `P1-VEC-04` owns the resulting backend
recommendation and must distinguish this full-workload result from any smaller
calibrated benchmark.

```text
cmake --build --preset debug --target p1_vec_03
ctest --test-dir cmake-build-debug -L '^P1-VEC-03$' --output-on-failure
```

- final target matrix: 7.65 seconds;
- exact-label CTest matrix: 1/1 in 8.01 seconds;
- per-cell target and CTest metrics: `raw/p1-vec-03-*-metrics.txt`;
- combined output, command timing, and source hashes: `raw/p1-vec-03-*`.

These are workload measurements on deterministic scratch data, not an
end-to-end retrieval SLA and not evidence that an unapproved vector backend is
already suitable.
