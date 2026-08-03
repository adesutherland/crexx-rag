# P1-VEC-01 Versioned Float32 Codec

Status date: 2026-08-03. Result: accepted.

The Level-B `vector_codec` owns a headerless canonical little-endian float32
payload. The surrounding application record and SQLite columns own the codec
identifier `f32le-v1`, element count, and dimensional meaning. This avoids a
second binary envelope while making incompatible or stale representations
detectable before arithmetic.

The four-cell proof compiled optimized and non-optimized modules and ran them
on `rxvme` and `rxbvm`. Each cell established:

- exact known bytes for `1.0`, `-2.5`, and `0.5`;
- distinct rejection of an unversioned codec, non-positive count, absent
  dimensional meaning, and byte-count mismatch;
- a 768-element record with a 3,072-byte payload;
- exact SQLite blob round trip through typed `rxsqlite` bindings; and
- SQLite rejection of a row whose payload length disagreed with its
  application-owned element count, reported through the structured boundary
  error contract.

Only per-cell scratch databases below the build directory were created. No
production schema, migration, vector sidecar, native vector library, or
production data was touched.

```text
cmake --build --preset debug --target p1_vec_01
ctest --test-dir cmake-build-debug -L '^P1-VEC-01$' --output-on-failure
```

- final target: 2.74 seconds, peak RSS 127,536 KiB;
- exact-label CTest: 1/1 in 3.01 seconds, peak RSS 127,616 KiB;
- four-cell result: `raw/p1-vec-01-commands-and-output.txt`;
- command, timing, and source hashes: `raw/p1-vec-01-*`.

This accepts the codec and storage boundary only. Representative ordering and
performance remain unclaimed until `P1-VEC-02` through `P1-VEC-04` complete.
