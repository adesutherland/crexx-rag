# Paste-ready Gate-1A successor decision prompt

Work in the checked-out `crexx-rag` repository and read `AGENTS.md` plus
`docs/evidence/2026-07-28-phase0-gate1a/GATE-1A-DECISION-PACKET.md` completely.
Also read the approved-candidate closeout linked from that packet. Preserve
every pre-existing/user-owned change. Use an installed CREXX package first and
keep any CREXX source checkout read-only; do not assume the macOS checkout or
scratch-prefix paths exist on this Linux host.

Gate 1A is accepted as diagnostic evidence: the approved-candidate replay
passed 28/28 deterministic/loopback tests with no hosted call, closed CRI-01
through CRI-14 downstream, and stopped at the boundary decision. I make these
decisions (edit any line before sending if I do not accept the recommendation):

1. D1 SQLite — **approve recommended boundary**: opaque ownership-safe generic
   native handles and typed null/int64/real/text/blob primitives; SQL,
   repositories, schema, transactions, and paging policy remain cREXX.
2. D2 data — **approve recommended boundary**: typed cREXX records internally;
   production `rxjson.jsondocument` at provider/MCP boundaries; explicit
   `node_f32_array`/`node_i64_array` owning raw canonical-little-endian binary,
   with element type, count and dimensional meaning owned by application
   schema, never heuristic auto-packing.
3. D3 provider — **approve recommended boundary provisionally**: minimal
   provider-neutral request/result/error contract in cREXX, with isolated Google
   mapping. Do not treat the one Gemini canary as hosted qualification.
4. D4 vector — **approve recommended baseline**: bounded-page exact pure-cREXX
   cosine/top-k first. Compare generic acceleration only after the retained
   11,684-by-768 workload, and only on the packet's correctness/10,000-us/
   64-MiB triggers or a separately approved end-to-end SLA.
5. D5 publication — **approve recommended model**: immutable source artifacts
   and revisions, reusable content identities, independently addressable exact
   support, and atomic active semantic-generation publication/retraction.
6. D6 jobs — **approve recommended foundation**: short atomic claim with a
   DB-issued monotonic fence, work/provider calls outside that transaction, and
   current-fence verification inside atomic promotion/finalization.
7. D7 surfaces — **approve the recommended facade**: typed Level-B operation
   core and typed Level-G facade; thin CLI JSON, `ADDRESS RAG`, and MCP
   `structuredContent` adapters; external operations use the installed
   `crexx.operation-contract/1` helper.
8. D8 ownership — **approve this classification**: product algorithms and policy
   stay application cREXX; the opaque typed SQLite mechanism, exact raw-f32
   helpers and provider-neutral boundary remain local generic incubation;
   production JSON/projections, the RXPA SDK/CMake package, structured
   diagnostics and contract helper are installed CREXX facilities; donation
   candidates are only recorded/prepared when a later prompt explicitly
   authorizes donation work. No CREXX compatibility dependency is open at
   Gate 1A.

For D9, do not infer implementation authority. First produce a bounded Phase-1B
worklist mapped exactly to the roadmap items that these decisions unblock,
including explicit entry/exit evidence, target-only development loops, the full
gate validation, and an unconditional Gate-1B stop. Identify any proposed item
that would harden a library, prepare a donation, use a hosted provider, change
the installed prefix, modify CREXX, dual-write, or touch production schema, and
leave it unauthorized unless I explicitly approve it in a further turn.

Do not implement Phase 1B in this decision-recording turn. Update only the
decision ledger/status/handoff needed to make the proposed Phase-1B worklist
reviewable, then stop for my scope approval. Do not stage, commit, push, or open
a pull request.
