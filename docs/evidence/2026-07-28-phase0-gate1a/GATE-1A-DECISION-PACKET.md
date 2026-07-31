# Gate 1A Boundary Decision Packet

Status date: 2026-07-31. Gate result: **passed as a diagnostic boundary-selection
gate; approved CREXX candidate replay passed; stopped unconditionally for the
user's Phase-1B decisions**.

This packet selects no production boundary by itself. It records what the
bounded experiments support, what they do not support, and the exact choices
required before any Phase 1B work. The native-v1 core, ABI, bridge, bundle,
CLI/MCP behavior, and tests remain the executable oracle.

## Gate evidence

- Gate 0 remains accepted for P0-01 through P0-07 including P0-04A.
- P1A-SDK-01 through P1A-SUR-01 each have an accepted focused result in the
  one-to-one worklist.
- The original pre-candidate Gate-1A configure/build/CTest result was 27/27
  passed, 0 failed, 0 skipped in 37.05 seconds. `git diff --check` passed.
- Both installed VMs were available. JSON correctness/benchmark/probe and
  vector measurements passed on both `rxvme` and `rxbvm`.
- The single user-authorized Gemini canary returned matching generation and an
  exactly 8-dimensional packed embedding. The key was not printed or retained.
- The read-only CREXX sister tree remains clean at its initial
  `12a11815ab082086fb95e4ca5e41bd1c0e241342`; crexx-rag remains on its initial
  `97cd87e91344d6ac1773a054bd38df23eb128ed2`. No commit or publication occurred.
- On 2026-07-31 the separately approved CREXX candidate
  `ea25d1720c8dc4044614fa6ac4789811289dc8ca` was scratch-built and installed,
  then replayed downstream with both fallback switches off. The refreshed
  deterministic/loopback suite passed 28/28, 0 failed, 0 skipped in 110.30
  seconds. CRI-01 through CRI-14 are closed downstream; no hosted call occurred.

Exact validation and preservation details are in
`raw/gate1a-validation.txt`.

## Recommended boundary choices

### D1 — SQLite ownership, handles, typed values, and records

Recommendation: **accept the P1A shape for later hardening**.

- Native generic mechanism: opaque native-payload-backed database and prepared-
  statement handles with reference-counted copies, deterministic finalizers,
  explicit close, parent-to-child invalidation, and stale/wrong-kind rejection.
- Boundary values: explicit null, signed int64, real, UTF-8 text, and exact-
  length blob bind/read; row iteration is a cursor operation.
- Application ownership: SQL text, repositories, migrations, transactions,
  paging policy, schema, and all source/chunk/claim/job meaning stay in cREXX.
- Record boundary: a cREXX repository consumes one cursor page directly into
  typed records. JSON is not the SQLite row transport.

Evidence includes int64 extrema, Unicode/empty/1,100,005-byte text, embedded-NUL
blob, rollback, FTS5, stale handles, and forced cleanup. Not evidenced: backup,
WAL administration, concurrency hardening, busy policy, or production packaging.

### D2 — Typed records, parse-once JSON, and explicit numeric projections

Recommendation: **accept typed records internally and parse-once JSON only at
external/provider/MCP boundaries**.

- One immutable production `rxjson.jsondocument` owns the source and a
  structural index.
- Typed node traversal plus compatibility-shaped accessors permit mechanical
  migration away from repeatedly reparsed JSON calls.
- Numeric JSON arrays remain arrays until a known contract explicitly requests
  `node_f32_array` or `node_i64_array`. The result is owning, headerless,
  canonical-little-endian binary. JSON alone does not identify a mathematical
  vector, count, dimension or precision, so automatic packing is rejected.
- The application schema owns element type, count and dimensional meaning.
  Hot loops acquire the raw payload once and use direct typed access.

For a 58,435-byte 3,072-number payload, one parse took 985–1,703 us; ten `f32`
projections took 2,306–2,665 us and ten direct scans 211–264 us. Repeated legacy
deep access was orders of magnitude slower in the retained exact workload. The
indexed source plus structural index has a real memory cost and still needs
object-heavy and arbitrary-key-path review before library replacement.

### D3 — Provider request/result/error contract

Recommendation: **accept the minimal provider-neutral Level-B contract and keep
Google mapping in an adapter**.

- Request: operation (`generate` or `embed`), provider-neutral model/input,
  timeout, and explicit bounded embedding dimension.
- Result: provider/model identity, generation text or raw owning `f32le`
  embedding with application-owned count/dimensions, and usage counters.
- Error: stable category, local code, HTTP status, retryability, and safe
  diagnostic text.
- Transport: direct cREXX `rxhttp`; no curl, native-v1 CLI, or RAG-specific
  native model adapter.

Deterministic success, malformed JSON, provider error, timeout, and connection
failure passed. The real Google canary measured generation at 1,446,777 us and
embedding at 364,282 us. The observed service accepted the top-level bounded-
dimension compatibility field and returned exactly 8 values; the nested form
had previously returned the full 3,072. This mapping is provisional adapter
behavior and must be reconciled with the provider's documented schema during
later provider hardening. One canary is correctness evidence, not hosted
reliability, retry, privacy-route, streaming, cancellation, or SLA evidence.

### D4 — Pure-cREXX vector baseline and acceleration trigger

Recommendation: **use exact Level-B cosine/top-k over bounded raw-f32 pages as
the initial baseline; do not select FAISS, an SQLite extension, or `rxvector`
yet**.

The human-auditable oracle returned IDs `10,20,30`, including deterministic
identity ordering for equal scores. A 32-row by 768-dimensional page transferred
98,304 payload bytes. In the candidate replay `rxvme` measured
transfer/decode/arithmetic/selection/total at 84/12/1,368/12/1,489 us;
`rxbvm` measured 81/11/1,271/12/1,384 us. The schema separately records
`f32le`, count 768 and meaning `embedding`.

Proposed exact acceleration trigger: first run P1-VEC-02/03 against the retained
11,684-by-768 representative workload. Open a generic acceleration comparison
only if exact results/order fail, VM peak exceeds the existing 64 MiB provisional
limit, or the calibrated 512-by-128 top-10 component exceeds the existing
10,000-us provisional threshold. A later end-to-end SLA may add a stricter
trigger, but selected PERF2 microbenchmarks do not substitute for this workload.

### D5 — Source/revision and semantic-generation publication

Recommendation: **accept immutable artifact/revision occurrences plus reusable
content identities and atomic active-generation publication**.

The slice proved first publication, identical-input zero writes/provider calls,
one-paragraph edit with safe reuse, one active revision, exact directional
claim support, and support/FTS retraction on removal. Evidence packets retained
the passage, supported claim, ambiguity lead, deterministic revision/paragraph
citation, and explicit gap.

The scratch fingerprint is deliberately not a production digest, and its schema
is not schema v2. Later production work must use collision-resistant source and
revision envelopes, independently addressable spans, one pinned semantic
generation for readers, and one short transaction for support/FTS/generation
promotion. It must not mutate a live native-v1 library or dual-write.

### D6 — Lease and fencing model

Recommendation: **accept DB-issued monotonically increasing fences with work
outside the claim transaction and fence revalidation inside atomic promotion**.

Four separate VM processes proved a committed fence-1 claim followed by forced
exit 73 before promotion, replacement by fence 2, stale-fence rejection, work
outside the claim transaction, atomic unique support promotion followed by
forced exit 74, and same-fence idempotent recovery with exactly one support row.

This does not evidence the production scheduler, database clock/lease expiry,
heartbeat, cancellation, retries, budgets, or multiple concurrent workers.

### D7 — Level G, CLI, ADDRESS RAG, and MCP facade shape

Recommendation: **accept one typed operation vocabulary and Level-B record,
with a typed Level-G facade and thin serialized CLI/ADDRESS/MCP adapters**.

The actual CLI executable, actual `ADDRESS RAG`, Level-G facade, and MCP
`structuredContent` wrapper produced semantically equal status/evidence records.
The approved candidate fixes imported nominal record identity. The retained
two-file reproducer and the real surface pass optimized/non-optimized on both
VMs. Serialization remains only at CLI/ADDRESS/MCP boundaries. The external
status-evidence contract is generated as `crexx.operation-contract/1` by the
installed CMake helper.

## Correctness, time, memory, and failure summary

| Area | Correctness/failure result | Retained measurement |
| --- | --- | --- |
| SDK | external plugin and `_rag` build/load with fallbacks off; returned version and 42 | focused build/run 2.28 s in Gate suite |
| SQLite | all typed values, large values, rollback, FTS5, stale/cleanup passed | mechanism test; no production throughput claim |
| Data | Unicode/empty/missing/null/containers/malformed and pages 2,2,1 passed | 200 iterations: parse 16,987 us; materialize 3,138 us; encode 3,575 us |
| JSON/packed | four opt/noopt by two-VM cells passed; f32/i64 failures covered | 3,072-value component ranges and 22.0–27.6 MiB benchmark RSS retained |
| Provider | deterministic matrix plus one real generation/embed passed | 1,446,777 us generation; 364,282 us embedding |
| Vector | exact order/ties passed on both VMs | 507/562 us total; 26.6/20.1 MiB process RSS |
| Algorithm | load/no-op/edit/reuse/support/retraction/citation/gap passed | bounded semantic slice; no production load profile |
| Job | both forced-exit boundaries, stale rejection, idempotency passed | two fences, one support, four VM processes |
| Surfaces | all four adapters semantically equal | focused test 1.16 s; no transport load profile |
| Gate | full oracle plus Phase-1A suite passed | 27/27 in 37.05 s |

The table above retains the original 2026-07-29 Gate result. The approved
candidate replay adds one concrete closure-reproducer test and passes 28/28 in
110.30 seconds. Its raw-binary/vector figures supersede the retired downstream
F32V/I64V envelope measurements for current planning.

## Minimized cREXX surface weaknesses

The five original minimized weaknesses are closed by the approved candidate:
Level G PARSE lowering, terminal-loop definite return, malformed RXPA
diagnostics, optimized read-only binary by-value helpers and imported Level-B
record identity through Level G. Their reproducers remain retained evidence;
the downstream accommodations have been removed. No new CREXX compatibility
blocker was found.

## Capability ownership classification

| Classification | Items |
| --- | --- |
| cREXX application code | SQL repositories/schema/migrations; source/revision/chunk/claim/support algorithms; job policy; provider routing; operation vocabulary; evidence assembly |
| Local generic incubation | opaque typed SQLite mechanism; exact raw-f32 cosine/top-k helpers; provider-neutral boundary experiment |
| Installed CREXX production facility | `rxjson.jsondocument`, explicit f32/i64 projections, RXPA SDK/CMake package, structured diagnostics and operation-contract helper |
| Future CREXX donation candidate, only after approval/evidence | generic SQLite plugin; possibly generic vector helpers after representative workload |
| Blocked external dependency or upstream fix | none at Gate 1A |

No donation bundle, sister edit, installed-prefix replacement, production module
tree, or provider qualification has begun.

## Rejected alternatives

- Whole-result or whole-corpus JSON strings as internal data transport.
- Repeated raw-string `rxjson` path calls for one provider payload.
- Automatically interpreting every numeric JSON array as a vector.
- Boxed float/int arrays as the large-embedding hot representation.
- SQL, schema, source/chunk/claim/job semantics, or evidence assembly in native
  code.
- RAG vocabulary in the generic SQLite/vector/provider mechanisms.
- Selecting FAISS/ANN from unrelated PERF2 results or this small page alone.
- Live-library dual writes or comparison by volatile row IDs/serialization.
- Expanding the SQLite PoC into ORM, backup/WAL administration, or ADDRESS
  hardening during boundary selection.
- Treating one hosted canary as broad provider qualification.
- Blocking all surfaces on the former Level-G record-return bug, hiding the
  record in native code, or retaining the bounded string-facade workaround
  after the approved candidate fixed typed record identity.

## Unresolved risks

- The generic incubations are PoCs, not production APIs, packages, or ABI
  commitments.
- Production `rxjson.jsondocument` still needs object-heavy, arbitrary-key,
  memory-distribution, and mutation/streaming qualification before broad
  product use.
- Google embedding dimensionality request behavior differs from the nested form
  initially tried and needs documented, versioned adapter tests.
- Provider retry/backoff, privacy routing, cancellation, batch embedding,
  structured generation, and secret-negative tests remain unimplemented.
- The vector sample is bounded; the 11,684-by-768 representative workload is
  still required before accepting or rejecting acceleration.
- The lifecycle slice used a diagnostic fingerprint and tiny scratch schema;
  production digests, spans, migrations, concurrency, and generation snapshots
  remain open.
- The job slice lacks real leases/clock expiry, heartbeat, cancellation,
  contention, budgets, and multi-worker tests.
- Cross-platform validation remains necessary for the now-typed Level-G facade
  and installed operation-contract path.
- Validation is on one Apple-arm64 machine; no Linux/Windows qualification is
  implied.

## Exact decisions required before Phase 1B

The user must explicitly approve, revise, or defer each item:

1. **D1 SQLite:** opaque ownership-safe native handles plus typed primitives,
   with all SQL/repositories in cREXX.
2. **D2 data:** typed internal records, parse-once JSON at external boundaries,
   and explicit schema-directed packed `f32`/`i64` projections.
3. **D3 provider:** the minimal provider-neutral request/result/error contract,
   with Google-specific REST mapping isolated and still provisional.
4. **D4 vector:** pure-cREXX bounded-page exact search as baseline and the stated
   representative-workload acceleration trigger.
5. **D5 publication:** immutable source/revision occurrences, reusable content
   identities, exact support, and atomic semantic-generation publication.
6. **D6 jobs:** DB-issued monotonic fence, outside-transaction work, and atomic
   fence-checked promotion as the scheduler foundation.
7. **D7 surfaces:** Level-B typed core plus typed Level-G facade;
   CLI/ADDRESS/MCP remain thin serialized boundaries and external operations
   use the installed durable contract helper.
8. **D8 ownership:** which local generic incubations may be hardened in this
   repo, which may only be prepared as future CREXX donation candidates, and
   whether any item must wait on an upstream dependency.
9. **D9 Phase-1B execution:** exact approved worklist IDs, validation gate, and
   stop point. Approval of D1–D8 alone does not authorize implementation.

Until those decisions are supplied, Gate 1A is the unconditional stop point.
Phase 1B, Phase 2, production hardening, full donation work, hosted-provider
qualification, cutover, and native retirement remain unauthorized. Publishing
this Gate-1A evidence does not authorize any of them.
