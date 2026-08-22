# `rxvector` Release 1 Design Decision

Status: approved by Adrian and implemented in CREXX. The mandatory first
ordinary-Release verdict was accepted on 2026-08-22; downstream bounded-page
and installed-package qualification are complete on macOS.

## Decision Scope

This decision covers a generic, exact, CPU `rxvector` provider. It does not
select an ANN algorithm, an external library, a SQLite extension, a persistent
index, or a RAG-specific policy. SQLite remains the source of truth and
`f32le-v1` remains the portable persisted representation in `crexx-rag`.

The provider builds on the accepted BINARY-01 boundary:

- `.packedfloat` owns contiguous host-native `rxfloat` values;
- `.packedint` owns contiguous host-native `rxinteger` values; and
- a native provider borrows those payloads read-only for the duration of a
  call, without calling `binary()`, boxing elements, or retaining a pointer.

## Considered Designs

### A. Packed exact CPU provider — recommended

Publish exact cosine and bounded top-k over `.packedfloat` and `.packedint`.
Keep an explicit bulk `f32le` import/export boundary so a portable stored value
is converted deliberately before native arithmetic. The provider is stateless
and owns no persistent index.

This reuses the language's one approved host-native numeric representation,
keeps persistence portable, permits bounded page-at-a-time use, and leaves an
ANN or prepared-index design open until it has matched evidence.

### B. Direct native search over `f32le-v1`

Accept canonical float32 database bytes directly in every arithmetic call.
This removes conversion and halves scan bandwidth, so it is an important
diagnostic ceiling. It is not recommended as the primary public contract
because it couples a numerical provider to one persistence encoding and would
create a second performance representation beside BINARY-01. A retained
direct-f32 control may still show whether conversion, binary64 bandwidth, or
the arithmetic kernel dominates the application result.

### C. Stateful prepared or ANN index

Return an opaque mutable handle backed by a prepared matrix, platform BLAS,
SQLite vector extension, FAISS, or another ANN engine. This may ultimately be
faster for repeated queries, but it introduces build/update policy,
fingerprints, task ownership, cancellation, memory limits, serialization,
backend discovery, and stale-index recovery. No matched evidence currently
selects one of those architectures, so it is deferred rather than hidden
behind the first exact API.

### D. Keep only the pure cREXX implementation

The existing implementation remains the portable correctness oracle and
fallback. It is not sufficient as the sole production route: arithmetic took
666,162 to 766,924 microseconds for the retained 11,684-by-768 workload, at
least 66 times the retained 10,000-microsecond acceleration trigger.

## Proposed Public Surface

Provider ID and public namespace are both `rxvector`. The initial direct RXPA
surface is:

```rexx
rxvector..decodef32le(data = .binary) = .packedfloat
rxvector..encodef32le(values = .packedfloat) = .binary
rxvector..cosine(left = .packedfloat, right = .packedfloat) = .float
rxvector..topkcosine(vectors = .packedfloat,
                     identities = .packedint,
                     dimensions = .int,
                     query_vector = .packedfloat,
                     requested = .int,
                     expose result_identities = .packedint,
                     expose result_scores = .packedfloat) = .void
```

The bulk conversion procedures are explicit interchange boundaries, not a
second packed type. `decodef32le` widens canonical little-endian IEEE binary32
items to native `rxfloat`; `encodef32le` narrows native `rxfloat` items to that
portable format. Empty input is valid for conversion. A partial final float,
non-finite value, or non-representable narrowing signals rather than silently
manufacturing an invalid vector payload.

`topkcosine` treats `vectors` as a zero-based, row-major matrix with
`dimensions` elements per row. The row count is inferred from the matrix size
and must equal `identities.size()`. `query_vector.size()` must equal
`dimensions`.
Callers initialize both result owners, normally as `.packedint(0)` and
`.packedfloat(0)`; the provider replaces their payloads. Result indexes are
zero-based owners, but result identities are the caller-supplied identity
values rather than matrix positions.

No Rexx declaration wrapper is required. A normal Level G caller imports
`rxfnsg` for the owner classes and `rxvector` for the direct provider metadata:

```rexx
options levelg
import rxfnsg
import rxvector

result_ids = .packedint(0)
result_scores = .packedfloat(0)
call rxvector..topkcosine(rows, ids, dimensions, query_vector, 10, result_ids, result_scores)
```

## Exact Semantics

1. `cosine` requires two nonempty equal-length owners. `topkcosine` requires a
   positive dimension, a whole number of rows, a matching identity count, an
   exactly dimensioned query, and `0 <= requested <= row_count`.
2. Every numeric input must be finite. A zero-norm query or candidate is an
   invalid argument. Invalid shape/value calls do not mutate the input owners.
3. Cosine is computed in native `rxfloat`. The implementation uses a
   numerically stable norm and dot-product strategy and reports an
   unrepresentable intermediate/result as `OVERFLOW_UNDERFLOW`.
4. Results order by score descending, then identity ascending, then source row
   ascending if both score and identity are exactly equal. No near-equality
   epsilon is used to invent ties.
5. `requested = 0` succeeds with two empty outputs. A failed call leaves both
   outputs empty and signals `OBJECT_NOT_INITIALIZED`, `INVALID_ARGUMENTS`,
   `OUT_OF_RANGE`, `OVERFLOW_UNDERFLOW`, or `FAILURE` as appropriate.
6. Inputs are borrowed read-only only for the call. Outputs own their bytes.
   The provider stores no global mutable state, task state, raw pointer, matrix,
   or index and is process-reentrant.

For bounded `k`, the selected algorithmic baseline is a single matrix scan
plus a size-`k` binary heap (`O(rows * dimensions + rows * log(k))`, `O(k)`
additional native working memory), followed by a final deterministic sort of
the retained results. The direct single-vector procedure is `O(dimensions)`.

## Level And Deployment Contract

`rxvector` is a Level G standard/default native provider, not core. Its
procedures are callable from Level B when the provider is installed, but a
minimal bootstrap environment is not guaranteed to contain it.

It uses the existing declarative provider route:

- dynamic artifact `rxvector.rxplugin`;
- static/native-package artifact `rxvector.a` (or platform equivalent);
- static provider resolution before trusted app/configured/installed dynamic
  lookup; and
- RXBIN dependency metadata emitted by the compiler and preserved/combined by
  `rxlink`.

`rxvm`, `rxbvm`, `rxtvm`, and `crexx -native` therefore load/select it without
hard-coded functions, a manual plugin list, a sidecar manifest, an initializer,
or a Rexx wrapper.

## Implementation And Evidence Gate

After approval, implementation proceeds in this order:

1. Retain the decision in the CREXX performance ledger/worklist and build
   isolated packed-scalar and direct-f32 diagnostic controls before selecting
   production kernel details.
2. Implement the four approved procedures, package metadata, errors, and
   focused unit/concurrency/autoload/static-package tests. Test optimized and
   non-optimized callers on both concrete VMs.
3. Prove standard vectors, unequal/empty/zero-norm/non-finite/overflow/shape
   errors, exact tie order, input immutability, output reset on failure,
   `f32le` round trip, and concurrent calls.
4. Freeze production changes after minimum correctness and run the mandatory
   profiling-off Release verdict. The machine ceiling is a direct C call over
   the same buffers; public RXPA and pure cREXX paths use the same data and
   expected ordering.
5. Replay the representative 11,684-by-768 workload in bounded pages. Record
   conversion, arithmetic/selection, total time, peak RSS, and exact top-ten
   identity/score agreement separately. Compare with the retained pure cREXX
   oracle; do not present preparation-inclusive and prepared-kernel timings as
   the same result.
6. Stop for Adrian's acceptance of the first Release verdict before broad QA,
   documentation closeout, downstream cutover, or investigation of a
   persistent/ANN backend.

The prior 10,000-microsecond value is an acceleration trigger, not a newly
invented SLA. The verdict will report whether the exact provider crosses it;
it will not declare failure solely because a correct, materially faster exact
fallback remains above 10 milliseconds.
