# Phase 3 Product Re-baseline Worklist

Status: Gate 3R accepted for the recorded macOS/Gemini scope on 2026-08-25.
Approved by Adrian on 2026-08-24; final defect closure approved 2026-08-25.

This worklist reopens **product ingestion acceptance** without discarding or
rewriting the accepted Phase-3 reconciler evidence. The original `P3-01`
through `P3-09` result remains the authority for source lifecycle, chunking,
incremental reconciliation, publication, and crash recovery. It is now
classified as a component gate rather than proof of a usable end-to-end
product.

`[ ]` is pending, `[~]` is active, `[x]` is accepted, and `[!]` is incomplete
with retained blocker evidence. At most one item may be active.

## Product outcome

Gate 3R ends only when a fresh installed cREXX application performs this
public sequence without a source checkout or phase/tutorial executable:

```text
crexx-rag library init
crexx-rag ingest plan
crexx-rag ingest apply
crexx-rag worker run --once|--follow
crexx-rag job status
crexx-rag query evidence
```

The sequence must ingest a public fixture, call a configured Google Gemini
generation route and Google embedding route, validate and promote a typed
claim, finish every queued ingestion item, and return the claim with the exact
source/revision/UTF-8-span citation.

## Reused implementation

The work must extend, not replace:

- `ragfolder` and `ragingest` discovery, identities, chunking, plans,
  reconciliation, publication, invalidation, FTS, and crash recovery;
- `ragclaims` candidate/mention promotion, typed proposals, deterministic
  validation, support, review, and idempotency;
- `ragwork` database-clock leases, attempts, fences, retry, cancellation,
  status, and reservations;
- `ragembedding`, `ragquery`, `ragretrieval`, and `ragevidencejson`;
- `ragcommand`, `ragproduct`, and the existing Level-G CLI main; and
- the generic provider contract, HTTP controller, Gemini/OpenAI/Anthropic and
  OpenAI-compatible adapters already under `incubator/phase1b/provider/`.

Existing phase scenarios and tutorials remain component tests. No
phase-numbered source becomes a production entry point.

## Ordered work

- [x] **P3R-00 — Re-baseline and acceptance contract.** Record the product
  boundary, reuse inventory, exact public flow, provider policy, acceptance
  assertions, exclusions, and live-call approval stop in this worklist and
  [`ACCEPTANCE-CONTRACT.md`](ACCEPTANCE-CONTRACT.md). Reclassify maintained
  roadmap/status/test documentation without rewriting dated historical
  evidence.
- [x] **P3R-01 — Enduring installed cREXX application.** Turn the existing
  Level-G CLI main and product dispatcher into one linked, installed
  `crexx-rag.rxbin` application image with a stable launcher/package contract.
  The installed consumer must not compile sources, enumerate runtime modules,
  or fall back to either source checkout. Preserve native-v1 unchanged as the
  oracle; changing the default `crexx-rag` command name remains a later
  explicit cutover decision. Also attempt a CREXX native package from the same
  linked application. Accept it only if application semantics remain cREXX and
  the generic SQLite/provider mechanisms are correctly packaged. If the
  dynamic SQLite boundary prevents native packaging, retain the exact failure
  and smallest generic packaging requirement instead of adding a
  product-specific C++ implementation. Accepted evidence:
  [`P3R-01.md`](P3R-01.md).
- [x] **P3R-01A — Declarative text configuration.** Add a bounded, versioned,
  human-editable text configuration format for operational settings and parse
  it in Level G into the existing typed `ragconfig` objects. Reject unknown or
  duplicate keys, unsupported provider kinds, invalid routes, path traversal,
  literal secrets, unbounded values, and executable module paths. Human CLI
  startup may select an explicit config file; MCP/agent startup receives a
  fixed operator-selected file and cannot change it. Domain profile code may
  remain an operator-registered cREXX module until separately redesigned.
  Accepted by `p3r_01a_config_file`, the linked CLI smoke, and the fixed-config
  MCP surface matrix; the maintained example is
  `crexx/application/config/google-gemini.conf`.
- [x] **P3R-01B — Durable process framework.** Add schema-migrated runtime
  coordination and an enduring Level-G `ragprocess` service. `worker start`
  supervises a configurable bounded number of the same linked `crexx-rag`
  application as OS processes through the public cREXX child-process channel;
  every process opens its own SQLite connection. Persist controller/worker
  parentage, host, PID, random start token, mode/job filter, state, control
  request and database-clock heartbeat. Expose bounded list/status, cooperative
  drain, authoritative stale-heartbeat classification, same-host PID
  diagnostics and explicit terminal/stale pruning. Do not attach ingestion or
  provider work in this slice: `worker.run` must report `framework-idle`.
  Accepted evidence: [`P3R-01B.md`](P3R-01B.md).
- [x] **P3R-02 — Configured application provider binding.** Implement one
  application-owned Level-G extraction component behind `.ragworkprovider`.
  It must resolve the registered job-snapshot role, construct the versioned
  request, call the existing generic provider, decode structured output into a
  typed proposal, and inject authoritative provider/model/request/prompt/
  profile/chunk provenance. Add an operator-registered Google Gemini
  configuration using only `env:GEMINI_API_KEY`; vendor choice must not branch
  ingestion algorithms. Accepted with P3R-03 through P3R-05A by the permanent
  native-product `p3r_02_gemini_ingestion` test and
  [`P3R-02.md`](P3R-02.md).
- [x] **P3R-03 — Durable work input and budget binding.** Extend schema and
  ingestion work so every item persists an exact canonical input envelope:
  source/revision/chunk/content identity, span/text digest, item type,
  config/profile/policy/prompt/schema versions, provider role/route/privacy,
  and reservation ceilings. The claim exposes that binding. Proposal
  application must prove it matches the claimed input before completing the
  item. Ingestion must create an immutable non-zero budget policy suitable for
  the reviewed plan. Existing unprovable queued items fail closed and are
  replanned rather than guessed or heuristically backfilled.
- [x] **P3R-04 — Complete ingestion processors.** Reuse accepted candidate
  decisions to promote canonical concepts/mentions through `ragclaims`, then
  process `claim-extraction` through the configured extractor and `embedding`
  through `ragembedding`. Each queued item has exactly one owning processor.
  Job completion requires no queued/running/dead-letter item and no outstanding
  reservation. Model output never writes graph state directly.
- [x] **P3R-05 — Public ingestion-worker dispatch.** Replace the accepted
  `framework-idle` worker body with `ragwork.runworkeronce`/
  `runworkerfollow` using the configured application provider, with exact
  access, worker/job, provider-role, lease/fence, cancellation, and result
  semantics. Resolve provider/policy per claimed job snapshot rather than from
  positional provider order or mutable current configuration. Keep process
  supervision operator-owned and keep long-running worker control out of
  read-only MCP.
- [x] **P3R-05A — Human progress surface.** Add typed, bounded progress events
  at the application boundary and a CLI renderer:
  `--progress off|plain|ansi`. Human commands default to ANSI on a colour
  terminal and plain otherwise; machine output remains off unless explicitly
  requested. Progress writes to stderr, leaving JSON/NDJSON stdout byte-stable.
  Progress covers discovery, plan/apply, item counts, provider admission and
  completion, validation/promotion, job reconciliation, and query readiness.
  It must redact secrets and source/provider bodies and must not become a
  second orchestration path. An optional interactive controller mode may query
  the same typed worker/job status while it supervises children; the existing
  separate `worker list/status` process remains the non-interactive authority.
- [x] **P3R-06 — Credential-free product and provider matrix.** Add a permanent
  installed-product target covering optimized/non-optimized compilation and
  both VMs. Run protocol/shape smokes for local OpenAI-compatible, OpenAI,
  Anthropic, and Gemini adapters; malformed schema, wrong input/chunk,
  privacy denial, missing secret, retry/dead-letter, stale fence, cancellation,
  restart, and no-op replay must fail or converge exactly as declared. These
  tests make zero hosted calls. Accepted proportionally: Phase 3's installed
  product path is the configured Gemini path in `p3r_02_gemini_ingestion`; the
  reusable `p1_llm_01` through `p1_llm_05` matrix covers local OpenAI-compatible,
  OpenAI, Anthropic, Gemini, malformed/retry/privacy and secret boundaries.
  Repeating every generic adapter as a product ingestion path is not a Phase 3
  requirement.
- [x] **P3R-07 — Real Gemini vertical slice.** After a separately recorded
  exact call/token/cost/privacy approval, run the installed public sequence on
  one public synthetic fixture. Google Gemini generation is mandatory; use a
  configured Google embedding model when embedding is enabled. Retain only
  symbolic secret reference, request/input hashes, provider/model/request
  identity, normalized result, usage/cost/latency, job reconciliation, final
  counts, and stable citation. Never retain the key, authorization material,
  or unredacted private source content. The approved two calls completed the
  real generation/embedding/claim/evidence path. A pre-call item-reservation
  defect required explicit dead-letter recovery. The separately approved fresh
  tutorial replay on 2026-08-25 completed both calls on their first attempts,
  published its vector generation, verified cleanly, and repeated unchanged
  with zero work; see [`P3R-07.md`](P3R-07.md).
- [x] **P3R-08 — Gate 3R closeout and later-phase boundary.** Accept proportional
  Phase-3 QA: native application build/smoke, the complete Phase-3/3R label,
  provider/renderer dependency tests, a pristine real Gemini walkthrough,
  unchanged replay, integrity verification, preservation review and
  `git diff --check`. Performance, soak, later-phase, full Release/sanitizer and
  exact Linux work are not Phase-3 defect tests and were not rerun. The closeout
  packet is [`P3R-08.md`](P3R-08.md). This acceptance does not authorize
  default-command cutover, native-v1 removal, push, release or publication.
- [x] **P3R-09 — Human-first Phase-3 tutorial.** Replace the current development
  tutorial with an installed-product walkthrough. It must show configuration
  file creation, `doctor`, library initialization, plan review, exact apply,
  ANSI/plain progress, worker execution, job status, evidence query, unchanged
  zero-call replay, changed-source replay, restart recovery, expected output,
  costs/privacy, and troubleshooting. Phase-numbered source scenarios may be
  linked as engineering evidence but are not tutorial commands. Maintained at
  [`docs/tutorials/phase-3-ingestion.md`](../../tutorials/phase-3-ingestion.md)
  with a runnable setup/config/source bundle in
  [`docs/tutorials/phase-3-ingestion/`](../../tutorials/phase-3-ingestion/).

## Provider smoke policy

Every supported adapter has a deterministic protocol smoke in recurring QA.
A live smoke is separately secret-gated for each provider deliberately
configured by the operator. Google Gemini is mandatory for Gate 3R. A hosted
adapter without a supplied credential is reported as `not-qualified`, never as
passed or silently skipped. No implicit provider fallback is permitted.

## Authority and exclusions

This approval authorizes the ordered application work above inside this
repository and scratch installations/libraries. It does not authorize:

- any hosted request before the exact P3R-07 budget is separately recorded;
- writing the user's normal CREXX prefix or editing/building the sibling CREXX
  checkout;
- dual-writing or migrating a live library;
- changing the default installed command, renaming/removing native-v1, or
  deleting the C ABI/`rx_rag` bridge before the P3R-08 decision;
- donation submission, push, pull request, release, or publication; or
- claiming exact Linux/cross-platform closure from macOS evidence.
