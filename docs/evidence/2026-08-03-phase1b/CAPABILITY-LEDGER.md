# Gate 1B Capability Ledger

Status date: 2026-08-03. Phase-1B evidence is complete; production acceptance
requires the Gate-1B decision.

## Accepted Evidence

| Capability | Result | Production boundary |
| --- | --- | --- |
| Installed SDK | External no-fallback plugins and consumers pass both VMs and both compiler modes | Installed package is consumed read-only; no normal-prefix or CREXX source writes |
| SQLite | Opaque ownership, typed values, transactions, FTS5/JSON1/WAL, read-only, concurrency, backup, integrity, cleanup, and optional address facade pass | Generic local incubation; no production repository/schema |
| Structured data | Parse-once JSON and nominal typed Level-B/Level-G records pass without corpus JSON reserialization | Installed `rxjson` plus application records |
| Provider contract | OpenAI-compatible, OpenAI, Anthropic, and Gemini mappings; modalities; structured output; batch embeddings; usage/cost; privacy; retry; catalog; and five low-cost hosted calls pass | Contract accepted; installed HTTP transport withheld from high-throughput production approval |
| Vector | Versioned `f32le-v1`, exact ordering, paging, component timing, and memory pass | Pure cREXX retained as oracle/fallback; not accepted as sole production backend |
| Algorithms | Immutable revisions, stable chunks, FTS, no-op/reuse, normalized claim support/retraction, typed evidence, and native-golden parity pass | Scratch application code only; no production schema or durable hash identity |
| Worker | DB-clock lease, heartbeat, fence, attempts, cancellation, idempotent promotion, four crash boundaries, and hard budget reservations pass | Bounded single-process scratch implementation; no production scheduler or multi-process claim |

## Issue Classification

| ID | Classification | Evidence-led disposition |
| --- | --- | --- |
| CAP-APP-01 | Application code | Production schema, migrations, repositories, source/claim policy, commands, and cutover remain unimplemented by design. A later Phase-2 decision must keep them in cREXX. |
| CAP-APP-02 | Application code | Multi-process workers, supervisors, public status surfaces, queue rebuild, and production recovery remain outside the single-process Phase-1B slice. |
| CAP-INC-01 | Local incubation | `rxsqlite` is correct across the approved matrix. It is neither installed as a donated package nor authorized for donation preparation. |
| CAP-INC-02 | Local incubation | Provider contracts/adapters and the model-capability catalog are industrialized at the cREXX interface. Transport concurrency and TLS throughput are not qualified. |
| CAP-INC-03 | Local incubation | The scratch `fixture-v1` fingerprint is deterministic but deliberately weak. Durable collision-resistant identity and the crossed 2,000-operation profile require a separately authorized `P1-HASH-01`-class decision. |
| CAP-DON-01 | Proposed CREXX donation candidate only | A generic `rxvector` mechanism should be qualified against the exact 11,684-by-768 workload. No implementation, backend selection, packaging, or donation work is authorized yet. |
| CAP-EXT-01 / CRI-15 | Blocked external dependency | Installed Linux `rxvme` overwrites receive-timeout status with invalid-UTF-8 status `-5`; `rxbvm` also returns a two-byte timeout payload. Linux provider timeout qualification remains withheld. |
| CAP-EXT-02 / CRI-16 | Blocked external dependency | Installed `rxhttp` opens one synchronous connection per request, forces close/identity encoding, has no configured response ceiling, and exposes no streaming or cancellation. Industrial high-throughput hosted transport approval remains withheld. |
| CAP-EXT-03 | Blocked external environment | No real `llama-server` executable was available. The configurable local OpenAI-compatible path is deterministically qualified, but a real local-model deployment is not claimed. |

## Trigger Decisions

- Vector arithmetic is 666,162 to 766,924 us and full exact search is 750,316
  to 857,843 us, at least 66 times the retained 10,000-us trigger. Peak RSS is
  18,845,696 to 26,595,328 bytes, below 64 MiB.
- The representative 2,000-operation fingerprint/chunk profile is 63,241 to
  104,666 us, 6.3 to 10.5 times the retained trigger. Peak VM RSS is
  16,785,408 to 25,374,720 bytes, below 64 MiB.
- Provider semantics, low-cost hosted protocol qualification, denied-route
  zero-outbound behavior, and secret retention pass. These do not override
  CRI-15 or CRI-16.

## Recommended Decision Units

1. Accept the Phase-1B cREXX skeleton and retained correctness evidence without
   authorizing native-v1 removal.
2. Authorize a generic HTTP/TLS capability programme covering pooling,
   keep-alive, bounded response buffering, compression, cancellation/streaming
   requirements, and measured concurrent TLS workloads.
3. Authorize matched generic vector-acceleration qualification while retaining
   SQLite as truth and pure cREXX as the correctness fallback.
4. Authorize durable hashing/identity and its matched application profile.
5. Decide separately whether to begin the Phase-2 cREXX product skeleton and
   production schema/migration work.

No proposed donation, Phase 2 work, production schema, cutover, native-core
removal, or additional hosted call has started.
