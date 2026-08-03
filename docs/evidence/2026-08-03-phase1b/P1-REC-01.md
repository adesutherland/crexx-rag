# P1-REC-01 Typed Record Boundary

Status date: 2026-08-03. Result: accepted.

The selected boundary keeps generic typed SQLite values in the plugin and
materializes application records in Level B cREXX. Nominal `.typedrow[]` arrays
then return through a Level G facade and pass back into Level B operations.
Neither the record module, facade, nor test imports `rxjson`; CMake enforces that
source invariant before compilation.

Optimized and non-optimized modules passed on `rxvme` and `rxbvm`. Every cell
paged six scratch rows as `2,2,2,0`, checked direct Level B and imported Level G
array returns, and passed Level G arrays into the Level B checksum operation.
Unicode text, exact real values, null versus empty text, and owning eight-byte
blobs survived the crossings. Every cell produced checksum 676 and reported
zero corpus JSON bytes.

```text
cmake --build --preset debug --target p1_rec_01
ctest --test-dir cmake-build-debug -L '^P1-REC-01$' --output-on-failure
```

- final target: 5.72 seconds, peak RSS 120,292 KiB;
- exact-label CTest: 1/1 in 5.30 seconds, peak RSS 120,376 KiB;
- raw four-cell crossing matrix: `raw/p1-rec-01-commands-and-output.txt`;
- source and evidence hashes: `raw/p1-rec-01-hashes.txt`.

The first build attempted to return a typed-array constructor expression from
failure exits, which cREXX rejects. The retained compiler output led to a typed
empty-array helper; nominal return types and behavior remained unchanged.
