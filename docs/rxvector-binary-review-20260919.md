# Binary sidecar and rxvector consolidation — 19 September 2026

Implementation follow-up: the approved C/rxvector consolidation is recorded in
[the delivery](rxvector-consolidation-20260919.md). The following is the retained
pre-implementation experiment and decision.

Adrian prefers a generic float32 matrix owner and binary import/search in
`rxvector`, and confirms that the sidecar can use the backend's binary format.
The investigation supports that direction. A scratch backend without USearch
retains the complete-query speed of the current binary integration. Consolidation
into CREXX remains implementation work; the qualified product is unchanged.

## Where the JSON cost applies

The older `ivf-flat-v1` sidecar stores its complete cluster/member catalogue in
JSON. Each fresh query constructs a `jsondocument` for the entire file before
selecting clusters. The measured parse/index stage costs about 591 ms.

`rxjson` already avoids materializing a token list and delays decoding values.
Its document constructor still walks and structurally indexes the complete
input. There is no existing lazy-document option that skips unselected groups.
The compatibility `jsonget` path also scans the complete strict input; repeatedly
calling it would not solve this. The earlier buffer-borrowing repair is already
present in the measured runtime.

The new `exact-native-v1` route already uses binary. It does not pay this large
JSON parse cost. Its version-1 `RXVIDX` file contains dimensions, row count,
length-prefixed opaque metadata and labels, then row-major float32 vectors.
This is the generic backend's exported format, independent of USearch internals.
RAG can keep using encode/open; it need not acquire a second serialization layer.
The roughly half-second benefit is already present in the 0.9-second route.

Removing JSON from this vector path does not require replacing RAG's JSON
commands, provider messages or other structured data. Reworking the IVF file
into binary groups would also remove its parse cost, but adds another format
and keeps approximate candidate selection and per-member SQL. Exact search of
this corpus already costs only milliseconds. Consolidating the working binary
exact route is the smaller useful next change.

## End-to-end dependency-free experiment

Only copied generic provider sources change. The immutable owner, binary codec,
labels, validation, interface and unchanged RAG bytecode remain. USearch sources
and headers are omitted from the scratch build; exact search uses a bounded
deterministic heap, float32 storage and double accumulation. The prototype still
uses the current C++ wrapper/runtime; removing that runtime requires the planned
C port into `rxvector`.

The current binary sidecar is read directly, without rebuilding or re-embedding.
Forty offline queries alternate the two executables on the twenty frozen
Scottish questions, generation 29748, BGE, three graph hops and twelve passages.
They run serially on the existing disposable corpus copy, with network denied.

| Full CLI query | Median | Range | Median peak RSS | Known reference hits |
| --- | ---: | ---: | ---: | ---: |
| Qualified binary route with USearch | **0.940 s** | 0.87–1.15 s | 459 MiB | 12/20 |
| Same binary route, dependency-free kernel | **0.950 s** | 0.89–17.41 s | 458 MiB | 12/20 |

The first scratch executable launch is the retained 17.41-second outlier; its
cause is unproven. Caches were not cleared and these are not cold-start promises.
All twenty ordered passage lists match. All evidence fields other than 61
cosine score values match; the largest score difference is 9.38e-8. Different
accumulation/rounding therefore needs an explicit numerical tolerance, rather
than a claim of byte-identical output. Complete parsed evidence is identical for one question and differs only in
those scores for nineteen.

The unchanged generic core controls pass, including malformed/numeric rejection,
binary round-trip and 257-way ties. Interface controls pass on both VMs and the
native packager, including copy/close lifetime and UTF-8/NUL labels. This is
bounded feasibility evidence, not full qualification of a migrated `rxvector`.
Initial scratch packaging used an already-linked input and was rejected for
duplicate imports; using the original project bytecode resolves it. Failed
logs remain retained.

## Bounded implementation in CREXX

1. Add an immutable float32 matrix/index owner to `rxvector`, preserving the
   existing packed-double procedures and their numerical/error contracts.
   Keep dimensions, row count and opaque labels/metadata available; the native
   provider must not interpret RAG IDs, generations, visibility or policy.
2. Move the generic binary import/export capability into that owner. Reuse the
   current versioned format where practical. Validate lengths, overflow, shape,
   finite values, norms and trailing bytes before exposing an owner. Retain
   deterministic export and a checked import with a useful error.
3. Add exact search directly over the owned float32 matrix, using native C
   accumulation and deterministic bounded top-k. Return packed row IDs/scores
   as today. Keep the matrix as float32 instead of widening all rows to doubles.
4. Implement and test native-owner lifetime and provider capabilities: copies
   remain usable after another copy closes, close is idempotent, invalid output
   is cleared, and each VM/process owns its handles. Preserve the current
   stateless procedures' reentrancy; new owner operations need their own reviewed
   capability declarations and dynamic/static/native packaging coverage.

The current generic implementation already separates codec/owner from its short
USearch search call. Its behavior and tests can be reused; the substantive new
work is the C/RXPA owner integration and qualification, not a new search service.
No application-specific SQL or grouping code belongs in the native provider.

## RAG integration and acceptance

`ragembedding` and `ragretrieval` can consume the installed `rxvector` owner in
place of the incubating provider. Keep the existing binary route and its public
controls, with RAG owning publication/checksums, current SQLite visibility and
best-window-per-parent aggregation. Compatible binary files can be reused;
unsupported versions must give the existing rebuild path. Rebuilding consumes
stored vectors and needs no new embedding calls.

Acceptance must establish:

1. The existing `rxvector` contract and new generic numeric/codec/lifetime tests
   pass on both VMs, native packaging and relevant supported platforms.
2. Frozen matrix oracle comparisons retain ranking/cutoff behavior with stated
   score tolerance, including duplicate vectors, near ties and extreme inputs.
3. The RAG publication, corruption, preflight/no-provider-call, visibility,
   multiple-window, backup/restore and A/B/A journeys remain green.
4. The final full-corpus comparison preserves ordered evidence and reference
   hits while retaining approximately the current binary-route latency and
   bounded memory. Run the full required local gate once after implementation.

After that acceptance, remove the incubating plugin/vendor and private C++
packaging workarounds from RAG. This review changes no product default, schema,
installed runtime or master corpus. The existing qualified route remains usable.

## Evidence and qualification boundary

Evidence directory:
`/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/rxvector-binary-review-20260919/`.
It retains copied sources and hashes, build/interface logs, package/link maps,
all forty query outputs/timings, `results.json` and `evidence-differences.json`.
The qualified product executable remains
`d4fcf1ebf547c4c91fd11367a780e9b896d54508bed5750dd0a2b9d0254efbf4`.
Its earlier 131/131 local qualification is retained. This turn changes only
documentation in the repository, followed by its targeted contract check and
receipt audit; no second full functional run is needed for a scratch experiment.

[Previous timing and qualification](retrieval-tightening-20260919.md).
