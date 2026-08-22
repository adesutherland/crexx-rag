# macOS Installed SHA-256 Adoption

Status date: 2026-08-22. `MAC-03` is complete for the installed one-shot binary
contract. Incremental hashing and file/path convenience are not claimed.

## Contract And Application Use

- Public call: `rxhash.sha256(data = .binary) = .binary`.
- Result: exact 32 raw digest bytes; application identities encode them as
  lower-case hexadecimal.
- Loading: the compiled native-provider metadata autoloads `rx_hash`; no native
  library or provider name is present on the VM command line.
- Logical source identity remains the connector URI/stable key. SHA-256 owns
  immutable content identity only.
- Scratch revision keys now use `<uri>@sha256:<digest>` and reusable chunk keys
  use `chunk-sha256:<digest>`.
- The weak `fixturefingerprint()` procedure and `fixture-v1` key surface were
  removed rather than retained as a pre-release alias.

This is an application proof in the Phase-1B scratch algorithm. It does not
activate `P2-10`, write a production library, or change the Phase-2 schema.

## Qualification

`p1_hash_01` passed optimized/non-optimized compilation and both `rxvme` and
`rxbvm` in 1.68 seconds. It verifies:

- raw 32-byte result ownership;
- empty and `abc` standard vectors;
- embedded zero and `0xff` bytes;
- UTF-8 input; and
- equality of text and explicitly equivalent binary bytes.

All five application algorithm tests then passed in 9.06 seconds. Their
revision no-op, edited-paragraph reuse, exact support/retraction, evidence, and
native-golden semantics remain unchanged apart from the stronger identities.

The retained 2,000-operation fingerprint/chunk profile crossed the historical
10,000-us observation trigger in every cell:

| Cell | Elapsed |
| --- | ---: |
| noopt `rxvme` | 24,721 us |
| noopt `rxbvm` | 24,701 us |
| opt `rxvme` | 24,225 us |
| opt `rxbvm` | 24,219 us |

That is approximately 12 microseconds per small content digest plus the
existing chunk/string work. It is expected native-call-dominated behavior for
short payloads and is acceptable for durable identity. It is not evidence for
high-throughput whole-file hashing.

Retained local log:
`/tmp/crexx-rag-mac03-algorithms.XXXXXX.log`.

## Incremental And File Decision

Recommendation:

1. Keep `rxhash.sha256(.binary)` as the Release-1 in-memory contract for plans,
   normalized text, chunks, and other already-owned bounded payloads.
2. Do not add `rxhash.sha256file(path)`. It would mix filesystem policy,
   connector ownership, cancellation, size limits, and hashing in the wrong
   package, and it would not help non-file sources.
3. Add an incremental binary contract only when the ingestion/file-stream
   boundary is implemented. Prefer process-reentrant opaque value state—init,
   update returning a new small state value, and final—over a native pointer
   handle. That keeps task transfer, cleanup, and provider reentrancy simple.

A concrete incremental API remains a language/library architecture decision
and requires separate approval before CREXX production changes.
