# Float32 And Exact Vector Usage

Status: implemented generic Level-G cREXX incubation. The directory contains a
portable float32 blob codec and deterministic exact cosine/top-k primitives.
They are potential CREXX contributions, but they are not a released `rxvector`
package and exact search is not accepted as the sole production backend for the
representative workload.

See [SYSTEM.md](SYSTEM.md) for representation, complexity, evidence, and the
proposed donation split.

## Modules

- [`vector_codec.crexx`](vector_codec.crexx): `f32le-v1` encode, decode,
  validation, and `.vectorblob` metadata record.
- [`vector_search.crexx`](vector_search.crexx): exact cosine scoring, batch
  scoring, and deterministic top-k selection.

Both modules use generic numeric and binary vocabulary and import no RAG
application module.

## Minimal Example

```rexx
options levelg

import vector_codec
import vector_search

left = .float[]
left[1] = 1.0
left[2] = 0.0
right = .float[]
right[1] = 0.5
right[2] = 0.5

left_payload = .binary
right_payload = .binary
if encodef32(left, left_payload) \= 0 then return 1
if encodef32(right, right_payload) \= 0 then return 1

left_blob = .vectorblob(f32codecversion(), left.0, "example-axis", left_payload)
if left_blob.valid() = 0 then return 1

score = 0.0
if cosinef32(left_payload, left.0, right_payload, right.0, score) \= 0 then return 1
say score
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

## Search API

`cosinef32` scores two equal-length payloads without decoding them into arrays.
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

## Current Limits

- Exact search is linear in vector count and dimension; it is a correctness
  oracle and bounded fallback, not an ANN index.
- Full representative exact search measured about 0.75 to 0.86 seconds, well
  beyond the retained 10 ms acceleration trigger.
- The modules do not store vectors, choose an embedding model, manage index
  generations, or define application similarity policy.
- Inputs are shape-checked but there is no explicit finite-value/NaN policy.
- A generic accelerated backend, package metadata, installed-consumer test, and
  donation approval remain future work.
