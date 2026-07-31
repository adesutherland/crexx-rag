# Phase-0 Same-Session Measurement Protocol

The repeatable entrypoint is the `phase0_component_benchmark` CTest. It compiles
one maintained Level B cREXX harness once, launches one deterministic native
loopback HTTP provider, and serially runs the native component probe, `rxvme`,
and `rxbvm` in the same CTest session. `/usr/bin/time -l` records process memory.
No hosted endpoint or credential participates.

Fixed workloads:

- SQLite write: one transaction, 512 rows, 128 float32 values per BLOB;
- vector DB transfer: ordered read and copy of the same 512 BLOBs (262,144
  bytes), separated from decode;
- vector decode: BLOB bytes copied into float32 arrays;
- vector compute: 512 exact cosine calculations of dimension 128 (65,536
  multiply positions), excluding selection;
- vector selection: deterministic partial top-10 sort with ID tie-break;
- cREXX algorithm: 2,000 case-fold/search/word-count iterations;
- JSON parse: 1,000 provider-shaped nested-field/null reads over a fixed
  142-character payload;
- record materialization: 512 typed text/float/type records;
- JSON encoding: 1,000 three-field objects containing text, number, and null;
- provider wait: one cREXX `rxhttp` POST per VM to a loopback provider with a
  deliberate 25 ms response delay.

`elapsed_us` comes from monotonic native timing or cREXX `time("us")`. Each row
includes operations, payload bytes where meaningful, a correctness checksum,
and status. Peak memory is a process high-water mark, not an allocation delta.
The run is a bounded diagnostic fingerprint, not a statistically powered
performance claim. No selected PERF2 microbenchmark is extrapolated to this
workload.

Raw recorded results are immutable evidence for this Gate-0 review. A rerun may
vary in timing; correctness/status, workload sizes, component separation, and
threshold outcomes must remain reproducible.
