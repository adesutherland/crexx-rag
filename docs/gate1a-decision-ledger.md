# Gate 1A Decision Ledger

Status: approved by the user on 2026-08-03. This ledger records boundary and
execution authority; it is not evidence that Phase 1B is implemented.

Provider-scope revision: later on 2026-08-03, after `P1-LLM-02` acceptance,
the user explicitly authorized low-cost, secret-gated hosted qualification for
OpenAI, Anthropic/Claude, and Google Gemini during `P1-LLM-04`. Credentials
must remain environment-only and secret-free evidence is still mandatory. This
revision changes only the hosted-provider exclusion; all other limits and the
Gate-1B stop remain in force.

The decision uses the retained Gate-1A packet, the approved CREXX-candidate
closeout, and the Linux build baseline at
`4e0a40ad750f54d4b9653926e6aeb46b50461471`.

## Approved Boundaries

| ID | Decision |
| --- | --- |
| D1 SQLite | Use opaque ownership-safe generic native handles and typed null/int64/real/text/blob primitives. SQL, repositories, schema, transactions, and paging policy remain cREXX. |
| D2 data | Use typed cREXX records internally and production `rxjson.jsondocument` at provider/MCP boundaries. Raw `f32`/`i64` projections are explicit, owning, canonical little-endian values whose element type, count, and dimensional meaning are application schema. |
| D3 provider | Provisionally use a minimal provider-neutral request/result/error contract in cREXX with isolated Google mapping. The retained Gemini canary is not hosted qualification. |
| D4 vector | Start with bounded-page exact pure-cREXX cosine/top-k. Consider generic acceleration only after the retained 11,684-by-768 workload crosses the packet's correctness, 10,000-us, or 64-MiB triggers, or a separately approved end-to-end SLA. |
| D5 publication | Use immutable source artifacts/revisions, reusable content identities, independently addressable exact support, and atomic active semantic-generation publication/retraction. |
| D6 jobs | Use a short atomic claim with a database-issued monotonic fence, perform work/provider calls outside that transaction, and verify the current fence inside atomic promotion/finalization. |
| D7 surfaces | Use a typed Level-B operation core and Level-G facade with thin CLI JSON, `ADDRESS RAG`, and MCP `structuredContent` adapters. External operations use `crexx.operation-contract/1`. |
| D8 ownership | Product algorithms and policy remain application cREXX. The typed SQLite mechanism, exact raw-f32 helpers, and provider-neutral boundary may be hardened only as local generic incubation. Installed JSON/projections, RXPA SDK/CMake, diagnostics, and contract helpers are consumed as CREXX facilities. Donation work remains separately gated. |

CRI-15 remains an open installed-CREXX Linux dependency. This approval does not
authorize a CREXX edit or product-specific workaround, and Linux provider
timeout qualification cannot be claimed until CRI-15 is fixed or separately
dispositioned.

## Approved Phase 1B Worklist

D9 authorizes only these roadmap items, in this order, with at most one item
active:

1. `P1-RXPA-01` and `P1-RXPA-02`: installed-SDK external-consumer and
   development-package qualification using isolated scratch prefixes.
2. `P1-SQL-01` through `P1-SQL-07`: generic typed SQLite contract, correctness,
   concurrency, recovery, and optional `ADDRESS SQLITE` facade.
3. `P1-JSON-01`, `P1-JSON-02`, and `P1-REC-01`: parse-once JSON and typed-record
   boundary validation without corpus reserialization.
4. `P1-LLM-01` through `P1-LLM-05`: provider-neutral hardening using local
   loopback/OpenAI-compatible providers, deterministic synthetic provider
   shapes, and the explicitly authorized low-cost hosted qualification in
   `P1-LLM-04` for OpenAI, Anthropic/Claude, and Google Gemini.
5. `P1-VEC-01` through `P1-VEC-04`: versioned raw-f32 transfer, representative
   exact-search measurement, and evidence-led backend selection.
6. `P1-ALG-01` through `P1-ALG-05`: the bounded application-cREXX algorithm
   parity slice over scratch schemas and libraries only.
7. `P1-JOB-01` through `P1-JOB-03`: the bounded single-process fenced worker,
   recovery, and budget slice over scratch libraries only.
8. Full Gate-1B evidence and validation, followed by an unconditional stop for
   the production-capability decision.

Each item requires item-specific correctness, time, memory, failure, and
unsupported-capability evidence where applicable. Development uses target-only
build/test loops; Gate 1B uses the full configured oracle validation.

## Not Authorized

- `P1-RXPA-03` donation-ready packaging or any other donation preparation;
- `P1-HASH-01` or a new native hashing/plugin boundary;
- hosted-provider calls outside the secret-gated, low-cost `P1-LLM-04`
  qualification authorized above;
- writes to the user's normal install prefix or modifications to CREXX;
- a product-specific CRI-15 workaround;
- production schema or migrations, live-library dual-write, cutover, or native
  core removal;
- Phase 2 or later; or
- commit, push, or pull request without a separate user request.

The execution instructions and evidence contract are in the
[Phase 1B implementation handoff](../prompts/phase1b-implementation-handoff.md).
