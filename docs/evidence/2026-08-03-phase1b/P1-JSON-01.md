# P1-JSON-01 Parse-Once Typed JSON

Status date: 2026-08-03. Result: accepted.

The application consumes the installed `rxjson.jsondocument`; it introduces no
second parser or serialized document representation. Optimized and
non-optimized programs passed on `rxvme` and `rxbvm` using one immutable
document and its document-local node identifiers.

Every cell retained the source and private index, iterated seven object members
and seven heterogeneous array elements in source order, and used typed
string/int64/real/boolean getters. The 16-node fixture proved exact member names,
Unicode escape and surrogate decoding to `Gràdh 中 😀`, and distinct missing,
null, empty-string, empty-array, and empty-object states. Invalid unpaired
Unicode retained the installed parser's stable `truncated` code, position, and
surrogate diagnostic.

A cREXX helper delegates quoting to installed `rxjson` and caps the final UTF-8
object size. Its 50-byte result round-tripped, the exact 50-byte cap passed, and
a 49-byte cap returned -2 with empty output.

```text
cmake --build --preset debug --target p1_json_01
ctest --test-dir cmake-build-debug -L '^P1-JSON-01$' --output-on-failure
```

- final target: 4.13 seconds, peak RSS 123,644 KiB;
- exact-label CTest: 1/1 in 4.57 seconds, peak RSS 123,224 KiB;
- raw four-cell output: `raw/p1-json-01-commands-and-output.txt`;
- source and evidence hashes: `raw/p1-json-01-hashes.txt`.

The first run expected `syntax` for an unpaired high surrogate. Inspection of
the installed documented contract showed `truncated` because the low-surrogate
sequence is incomplete. That failed assumption is retained; the corrected
assertion verifies the exact code and diagnostic.
