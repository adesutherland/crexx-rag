# Float32 And Exact Vector System Design

## Boundary And Candidate Split

This directory contains two related generic mechanisms with different donation
readiness:

1. the `f32le-v1` storage/transfer codec; and
2. exact cosine and deterministic top-k primitives used as an oracle/fallback.

The selected acceleration capability is the installed, generic CREXX
`rxvector` exact CPU provider. It adds no FAISS dependency, SQLite vector
extension, index format, persistent handle, or ANN backend.

## Representation

`f32le-v1` is an owning, headerless sequence of IEEE float32 elements in
canonical little-endian order. The owning schema must store:

- codec/version;
- element count;
- dimensional or coordinate meaning; and
- any model/profile/input identity required by its application.

The codec does not embed metadata into the payload and does not infer semantic
meaning. This keeps the binary mechanism generic and permits exact SQLite BLOB
round trips.

## Module Responsibilities

| Module | Responsibility |
| --- | --- |
| [`vector_codec.crexx`](vector_codec.crexx) | Typed metadata record, version, shape validation, array-to-binary encoding, binary-to-array decoding |
| [`vector_search.crexx`](vector_search.crexx) | Pure direct-binary cosine and deterministic top-k oracle/fallback; small cross-page merge |
| installed `rxvector` | Explicit f32le/packed conversion and exact packed cosine/top-k |
| `p1_vec_01.crexx` | Codec and SQLite round-trip qualification |
| `p1_vec_02.crexx` | Bounded-page accelerated ordering and tie comparison |
| `p1_vec_03.crexx` | Transfer, validation, conversion, arithmetic/selection, merge, total-time, and memory measurement |

Both local modules are Level G and consume `rxfnsb` binary primitives as a
CREXX foundation dependency. The application imports installed `rxfnsg` packed
owners and `rxvector` provider metadata directly; there is no Rexx declaration
wrapper or manual runtime plugin list.

## Algorithms And Complexity

`cosinef32` walks two payloads once, accumulating dot product and squared norms,
then uses a bounded Newton iteration for square root. Time is `O(d)` and
additional memory is constant for dimension `d`.

`rxvector.topkcosine` scans a page once and maintains a native size-`k` heap,
taking `O(n*d + n*log(k))` and `O(k)` additional native memory. The application
uses the retained pure `selecttopk` only to merge at most `page_count*k`
candidates. Equal scores use ascending integer identity as the stable tie
break; the provider adds source-row order for identical scores and identities.

The exact equality tie rule is intentional for retained deterministic fixtures;
callers must not reinterpret near-equal floating-point values as ties without a
separate policy.

## Ownership And Errors

Encoded and decoded values are owning cREXX binary/packed/array values. Procedures
initialize exposed outputs before validation, so a failed call does not return a
partially populated result. Statuses describe shape, representation, and
zero-norm errors; there is no global diagnostic state.

The local codec validates version, positive counts, meaning, and byte length.
The installed provider additionally rejects NaN, infinity, zero norms,
incompatible packed shapes and unrepresentable conversion/calculation results.

## Storage And Index Boundary

SQLite remains the source of truth for embeddings and their identity metadata.
Each keyset page is concatenated as portable `f32le-v1`, converted once to an
owning `.packedfloat` matrix, searched through `rxvector`, and discarded before
the next page. A future accelerated index remains a rebuildable sidecar and
cannot create a typed fact. This package does not own model selection, stale
index rejection, or atomic index generation publication.

## Evidence

The four-cell installed-only result proves the exact codec, identities, scores,
and tie ordering over 11,684 x 768 values in 92 pages. The bounded provider path
measured 122,740-129,974 microseconds total, including 29,444-31,261
microseconds of conversion and 54,161-54,472 microseconds of native
arithmetic/selection. The estimated per-page working set is 1,193,280 bytes;
process peak RSS, which includes the VM and libraries, was 86,196,224-99,434,496
bytes.

The retained pure path measured 750,316-857,843 microseconds total and
666,162-766,924 microseconds for arithmetic. The broad endpoint comparison is
therefore about 5.8x-7.0x in favor of the bounded installed path. The accepted
upstream 8.4-8.5 millisecond result is a prepared full-matrix kernel boundary,
so it is not presented as the SQLite application result.

Current commands, package hashes, scores, timings, memory, and QA disposition
are retained in
[`MACOS-RXVECTOR.md`](../../../docs/evidence/2026-08-22-crexx-capability-sync/MACOS-RXVECTOR.md).
The original pure evidence remains under
[`docs/evidence/2026-08-03-phase1b/`](../../../docs/evidence/2026-08-03-phase1b/).

## Donation Readiness

For the codec/exact primitives:

- settle package/module names and a compatibility/version policy;
- add independent package metadata and installed-consumer examples;
- define finite-value and cross-platform floating-point behavior;
- retain dual-VM correctness and representative benchmark thresholds; and
- decide whether codec and exact search should be one or two contributions.

For later prepared or ANN acceleration, define dimension, model/profile,
metric and backend compatibility fingerprints; specify bounded memory,
build/update, cancellation and stale-index recovery; and select a backend only
from matched evidence. None of those concerns is hidden inside the accepted
stateless exact provider.
