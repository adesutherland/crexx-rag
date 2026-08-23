# Float32 And Exact Vector Usage

Status: implemented Level-G integration with the installed CREXX `rxvector`
provider. This directory retains the portable float32 blob codec and pure
exact cosine/top-k oracle/fallback; the representative path converts bounded
SQLite pages to host-native packed owners and calls the accepted provider.
P2-09 adds a reproducible review recipe in [`BUNDLE.tsv`](BUNDLE.tsv),
explicitly non-released [`PACKAGE.toml`](PACKAGE.toml) metadata, and a compiled
portable [`candidate_probe.crexx`](candidate_probe.crexx).

See [SYSTEM.md](SYSTEM.md) for representation, complexity, evidence, and the
proposed donation split.

## Modules

- [`vector_codec.crexx`](vector_codec.crexx): `f32le-v1` encode, decode,
  validation, and `.vectorblob` metadata record.
- [`vector_search.crexx`](vector_search.crexx): pure exact cosine scoring and
  deterministic top-k oracle/fallback, including the small cross-page merge.
- installed `rxvector`: bulk `f32le` conversion and exact packed cosine/top-k
  for each bounded page.

Both modules use generic numeric and binary vocabulary and import no RAG
application module.

## Minimal Example

```rexx
options levelg

import vector_codec
import rxfnsg
import rxvector

left_payload = "0000803F00000000"x as .binary
right_payload = "0000003F0000003F"x as .binary
left = rxvector..decodef32le(left_payload)
right = rxvector..decodef32le(right_payload)
say rxvector..cosine(left, right)
return 0
```

The payload is headerless. Persist `codec`, `element_count`, and dimensional
meaning in the owning schema beside the bytes. Never infer those values from a
blob length alone.

## Codec API

| Operation | Result |
| --- | --- |
| `f32codecversion()` | Current identifier, `f32le-v1` |
| `encodef32(values, payload)` | Encodes a nonempty `.float[]` into owning binary |
| `validatef32blob(codec, count, meaning, payload)` | Checks version, positive count, nonempty meaning, and exact byte length |
| `decodef32(codec, count, meaning, payload, values)` | Validates and materializes an owning `.float[]` |
| `.vectorblob(...)` | Keeps codec/count/meaning/payload together in cREXX calls |

Validation statuses are `-1` for codec mismatch, `-2` for invalid count, `-3`
for missing dimensional meaning, and `-4` for byte-length mismatch.

## Search APIs

The selected installed surface is `rxvector.decodef32le`, `encodef32le`,
`cosine`, and `topkcosine`. `topkcosine` consumes a row-major `.packedfloat`
matrix, `.packedint` identities, the dimension, a `.packedfloat` query and the
requested count. It returns owning packed identities and scores ordered by
score descending, identity ascending, then source row ascending.

The retained local `cosinef32` scores two equal-length payloads without
decoding them into arrays.
It returns `-1` for incompatible counts, `-2` for invalid payload lengths, and
`-3` for a zero-norm input.

`cosinesf32` scores an array of payloads against one query. `selecttopk` orders
by score descending and then integer identity ascending. This tie rule makes
results deterministic across both CREXX VMs.

## Tests

Run the codec, ordering, and representative workload qualification with:

```bash
ctest --preset debug -R '^p1_vec_0[1-3]$' --output-on-failure
```

The retained workload is 11,684 vectors at dimension 768 with keyset-paged
SQLite transfer. Tests compare exact top-k and tie behavior across both VMs and
both compiler modes.
P2-09 also stages the review bundle and runs the portable codec/cosine probe in
all four compiler/VM cells through `p2_09_donation_bundles`.

## Current Limits

- Exact search remains linear in vector count and dimension; `rxvector` is an
  accelerated exact fallback, not an ANN index.
- The retained pure implementation measured about 0.75 to 0.86 seconds on the
  representative workload. The accepted upstream RXVECTOR verdict measured
  an 8.4-8.5 ms prepared packed kernel. The installed bounded SQLite replay
  totals 0.123-0.130 seconds, including 0.029-0.031 seconds of conversion and
  0.054-0.055 seconds of native arithmetic/selection across 92 calls; these
  timing boundaries are deliberately reported separately.
- The modules do not store vectors, choose an embedding model, manage index
  generations, or define application similarity policy.
- The installed provider rejects NaN and infinity. The retained local pure
  fallback has no separate finite-value policy and remains an oracle/fallback,
  not the selected production route for untrusted numeric input.
- Prepared matrices, persistent handles, ANN indexes and external vector
  backends remain future designs with explicit lifecycle gates.
