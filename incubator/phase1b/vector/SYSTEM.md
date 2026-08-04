# Float32 And Exact Vector System Design

## Boundary And Candidate Split

This directory contains two related generic mechanisms with different donation
readiness:

1. the `f32le-v1` storage/transfer codec; and
2. exact cosine and deterministic top-k primitives used as an oracle/fallback.

An accelerated `rxvector` or ANN backend is only a proposed capability. No
native vector implementation, FAISS dependency, SQLite vector extension, index
format, or backend selection is present here.

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
| [`vector_search.crexx`](vector_search.crexx) | Direct binary cosine arithmetic, batch scoring, deterministic bounded top-k selection |
| `p1_vec_01.crexx` | Codec and SQLite round-trip qualification |
| `p1_vec_02.crexx` | Exact representative ordering and tie comparison |
| `p1_vec_03.crexx` | Transfer, decode, arithmetic, selection, total-time, and memory measurement |

Both implementation modules are Level G and consume `rxfnsb` binary primitives
as a CREXX foundation dependency. Direct float32 access is valid at Level G and
does not require an authored assembler block or Level-B wrapper.

## Algorithms And Complexity

`cosinef32` walks two payloads once, accumulating dot product and squared norms,
then uses a bounded Newton iteration for square root. Time is `O(d)` and
additional memory is constant for dimension `d`.

`cosinesf32` applies that operation to each candidate, taking `O(n*d)` and an
`O(n)` output-score array. `selecttopk` maintains an ordered result of at most
`k` entries, taking `O(n*k)` and `O(k)` result memory. Equal scores use ascending
integer identity as the stable tie break.

The exact equality tie rule is intentional for retained deterministic fixtures;
callers must not reinterpret near-equal floating-point values as ties without a
separate policy.

## Ownership And Errors

Encoded and decoded values are owning cREXX binary/array values. Procedures
initialize exposed outputs before validation, so a failed call does not return a
partially populated result. Statuses describe shape, representation, and
zero-norm errors; there is no global diagnostic state.

The code validates version, positive counts, meaning, and byte length. It does
not currently reject NaN or infinity or define cross-hardware tolerance beyond
the qualified CREXX VMs.

## Storage And Index Boundary

SQLite remains the source of truth for embeddings and their identity metadata.
A future accelerated index is a rebuildable sidecar and cannot create a typed
fact. This package does not own SQLite access, paging, model selection, stale
index rejection, or atomic index generation publication.

## Evidence

The four-cell Phase-1B result proves an exact 768-element SQLite round trip and
deterministic ordering over 11,684 x 768 values. Peak RSS stayed below 64 MiB.
Full search measured 750,316 to 857,843 microseconds and arithmetic measured
666,162 to 766,924 microseconds, crossing the retained 10,000-microsecond
acceleration trigger by at least 66 times.

Exact commands, hashes, scores, timings, and memory are retained under
[`docs/evidence/2026-08-03-phase1b/`](../../../docs/evidence/2026-08-03-phase1b/).

## Donation Readiness

For the codec/exact primitives:

- settle package/module names and a compatibility/version policy;
- add independent package metadata and installed-consumer examples;
- define finite-value and cross-platform floating-point behavior;
- retain dual-VM correctness and representative benchmark thresholds; and
- decide whether codec and exact search should be one or two contributions.

For acceleration:

- run a separately authorized generic backend comparison against the exact
  workload and oracle;
- define dimension, input, metric, and backend compatibility fingerprints;
- specify bounded memory, build/update, cancellation, and failure behavior;
- package the backend without RAG vocabulary; and
- select a backend only from matched evidence.
