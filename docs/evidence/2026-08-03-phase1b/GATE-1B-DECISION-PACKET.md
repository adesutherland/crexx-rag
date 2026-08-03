# Gate 1B Decision Packet

Status date: 2026-08-03. Result: Gate 1B reached; production-capability decision
required. Programme execution stops here unconditionally.

## Executive Result

All 28 bounded Phase-1B implementation IDs are accepted on their item-specific
evidence. The Gate baseline builds Debug and Release and runs 56 tests. Exactly
55 pass; the sole failure is the unchanged CRI-15 installed-CREXX Linux
receive-timeout defect. No new baseline failure was found.

The outcome is a strong cREXX capability skeleton, not a production cutover
candidate. The provider interface is industrialized across OpenAI-compatible,
OpenAI, Anthropic, and Gemini protocols, multiple input modalities, structured
generation, batch embeddings, usage/cost accounting, privacy routing, and a
dated model-capability catalog. The installed `rxhttp` implementation is not an
industrial high-throughput transport, so that production claim is explicitly
withheld.

## Required Evidence

| Gate requirement | Result | Primary evidence |
| --- | --- | --- |
| `rxsqlite` correctness/concurrency | Accepted across seven items and four cells | `P1-SQL-01.md` through `P1-SQL-07.md` |
| Structured data/records | Accepted parse-once and nominal typed crossings | `P1-JSON-01.md`, `P1-JSON-02.md`, `P1-REC-01.md` |
| Provider contract | Accepted protocol/application boundary; transport limitations withheld | `P1-LLM-01.md` through `P1-LLM-05.md`, `PROVIDER-CLOSEOUT.md` |
| Vector boundary | Exact and memory-bounded; latency trigger crossed | `P1-VEC-01.md` through `P1-VEC-04.md` |
| Incremental/claim/evidence slice | Accepted scratch semantics and native-golden parity | `P1-ALG-01.md` through `P1-ALG-05.md` |
| Crash recovery | Accepted at four forced process boundaries | `P1-JOB-01.md` through `P1-JOB-03.md` |
| cREXX/oracle profile | Native nine-record golden exact; application profile trigger crossed | `P1-ALG-05.md`, `raw/p1-alg-05-*` |
| Capability classification | Complete | `CAPABILITY-LEDGER.md` |

## Gate Validation

```text
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
cmake --preset release
cmake --build --preset release
git diff --check
```

- Debug configure: passed.
- Debug build: passed in 1.23 seconds, peak RSS 60,280 KiB.
- Final Debug CTest after atomic-heartbeat hardening: 55/56 passed in 490.18
  seconds; harness elapsed 490.21 seconds and peak RSS 227,388 KiB. The initial
  pre-hardening run is also retained and had the same sole failure.
- Sole failure: test 47, `p1a_provider_boundary`, with CRI-15 status `-5`
  replacing the expected timeout status.
- Release configure: passed.
- Release build: passed with no work required in 0.07 seconds, peak RSS
  19,432 KiB.
- `git diff --check`: passed with zero output.
- Credential audit: three environment credential values scanned across all
  publication files, zero matches.
- CREXX sister checkout: entry and Gate both record clean `develop` at
  `b27446868d0de2c069574cdae57914b50b640dd5`; no write was made.

Raw Gate output is `raw/gate1b-*`; final rerun files use the
`raw/gate1b-final-*` prefix. Item-level raw results and hashes remain in the
same evidence directory.

## Withheld Production Claims

- Linux provider timeout behavior is not qualified while CRI-15 is open.
- Installed HTTP is not approved for pooled, concurrent, streaming, or bounded
  high-throughput hosted traffic while CRI-16 is open.
- Pure cREXX exact vector search is not approved as the only production backend
  for the representative workload.
- The fixture fingerprint is not a durable content hash, and the application
  algorithm timing trigger is crossed.
- No production schema/migration, multi-process worker, public target command
  set, dual-write, cutover, or native-core removal has been implemented.

## Decision Requested

The recommended decision is to accept the Phase-1B skeleton and authorize
separate bounded hardening for HTTP/TLS, vector acceleration, and durable
hashing before treating the stack as industrial production capability. Phase 2
and any production schema should remain a distinct explicit decision. The
native-v1 oracle must remain intact until a later proven cutover.

No further programme item is active. This packet is the mandatory Gate-1B stop.
