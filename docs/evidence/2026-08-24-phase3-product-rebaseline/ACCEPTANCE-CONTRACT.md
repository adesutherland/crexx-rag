# Gate 3R End-to-End Ingestion Acceptance Contract

Status: satisfied for the recorded macOS/Gemini scope on 2026-08-25. Exact
Linux, release and cutover remain separate decisions.

## Boundary under test

The subject is the installed cREXX `crexx-rag` application, not a source-level
scenario, phase tutorial, direct provider probe, direct SQLite script, or the
native-v1 executable. All commands enter through the Level-G CLI main and the
shared `ragproduct` dispatcher.

The product artifact is one linked `crexx-rag.rxbin` application image plus a
thin launcher/runtime package. The launcher may locate the installed CREXX VM
and product image, but it owns no product algorithm, policy, prompt, provider
mapping, or SQL. Runtime use must not require a compiler, source checkout, CMake
script, manual module list, or phase-numbered program.

The build must also attempt CREXX native packaging of the same linked
application. A native result must execute the identical command contract and
may depend only on correctly packaged generic CREXX facilities. A retained
native-packaging limitation is acceptable for the implementation item but not
silently converted into RAG-specific native product logic.

Operational configuration is a bounded versioned text file that is parsed into
the same typed configuration model used by the application. It may contain
only declarative source/provider/role/privacy/budget/worker settings and
`env:NAME` secret references. It cannot name or load executable modules. The
operator registry continues to control domain profile implementations.

## Fixture and provider

- redistributable public synthetic IT-architecture fixture;
- one source and one changed-source replay;
- at least two accepted candidate concepts and one direct typed relationship;
- exact normalized UTF-8 evidence span;
- configured `extractor` route: Google Gemini;
- configured `embedding` route: a Google embedding model when embedding is
  enabled; and
- credential reference: `env:GEMINI_API_KEY` only.

The exact available Google models, pricing, call ceiling, input/output token
ceilings, cost ceiling, timeout, attempts, and privacy classification must be
recorded and approved immediately before the live gate. Until then, the live
gate is blocked by design and no credential may be resolved.

## Required public sequence

1. Install into a fresh scratch prefix and prove no source-tree fallback.
2. Initialize a fresh scratch library through `crexx-rag library init`.
3. Produce a zero-write `ingest plan` showing the exact source delta, item
   types, provider roles/routes, privacy, and reservation ceilings.
4. Apply only that canonical plan and reviewed digest.
5. Process the returned job only through `crexx-rag worker run`.
6. Observe completion only through public job status/events.
7. Retrieve the promoted relationship through `crexx-rag query evidence`.
8. Repeat unchanged ingestion.
9. Change the source, plan/apply/process again, then restart and replay.
10. Repeat the human walkthrough with plain or ANSI progress enabled and prove
    machine output is unchanged when progress is off.

## Mandatory assertions

### Application and packaging

- one enduring installed application image and stable command contract;
- no source compilation, source fallback, manual runtime-module list, phase
  executable, direct provider probe, or native-v1 mutation;
- command/result and exit schemas remain versioned and bounded; and
- native-v1 remains an independently invocable read-only oracle until a later
  decision.
- text configuration is size-bounded, deterministic, duplicate/unknown-key
  rejecting, literal-secret rejecting, and semantically equal to its typed
  configuration projection; and
- `--progress off|plain|ansi` writes only to stderr, never alters machine
  stdout, and contains no secret or source/provider body. Human terminal
  commands select ANSI/plain by default; machine callers remain explicit.

### Initial ingestion

- the applied plan returns one durable job id;
- every queued item contains a canonical exact work-input envelope;
- accepted candidate concepts/mentions exist before claim validation;
- the configured Gemini adapter makes the admitted structured-generation call;
- the configured Google embedding adapter processes its owned item;
- provider/model/request identities and actual usage link to the exact attempt;
- the proposal matches the claimed chunk, span, input hash, profile, prompt,
  schema, provider route, and config snapshot;
- deterministic validation, not the model, decides accept/review/reject;
- the accepted claim has independently addressable exact source support;
- the job has zero queued/running/dead-letter/cancelled items unless the test
  explicitly expects one, and reservations reconcile to zero; and
- public evidence retrieval returns the same claim and resolvable stable
  citation.

### Incremental and replay behavior

- identical ingestion produces zero SQLite semantic writes and zero provider
  calls;
- a changed source reprocesses only invalidated inputs and retracts or
  re-anchors old support correctly;
- a worker/process restart does not duplicate provider-run identity,
  embeddings, concepts, claims, support, attempts, or finalization; and
- stale fences, plans, work inputs, routes, models, or provider outputs fail
  closed.

### Provider safety

- deterministic protocol smokes cover local OpenAI-compatible, OpenAI,
  Anthropic, and Gemini mappings;
- missing/invalid secrets, denied privacy, unsupported capability, malformed
  JSON/schema, timeout, retryable and terminal provider errors have explicit
  results;
- denied/missing-secret cases construct no outbound client and make zero
  socket connections;
- provider fallback is never implicit; and
- credential values and authorization headers have zero retained matches.

## Evidence retained

Retain exact repository/toolchain provenance, installed manifest and artifact
hashes, commands, public result records, provider/model/request identities,
input/request/result hashes, usage/cost/latency, item/attempt/reservation
reconciliation, final semantic counts, citation resolution, no-op and changed
replay counts, and credential scans.

Do not retain secret values, headers, environment dumps, private source text,
or unrestricted provider response bodies.

## Gate decision

Gate 3R fails if any step begins below the installed public application
boundary, if any queued ingestion item lacks an owner, if the real Gemini call
is replaced by a deterministic fixture, if the query result depends on
pre-seeded graph rows, or if unchanged replay makes a provider call.

The maintained Phase-3 tutorial must itself execute this public installed
sequence. A tutorial that asks the reader to compile cREXX sources, construct a
runtime module list, invoke a phase scenario, seed graph rows, or call a
provider harness directly fails the human-experience requirement.

Passing Gate 3R proves a usable cREXX ingestion vertical slice for the recorded
provider/platform scope. It does not by itself authorize default-command
cutover, native removal, release, donation, or exact Linux qualification.

Gate 3R was accepted on 2026-08-25 from the permanent credential-free matrix
plus a fresh native tutorial replay with exactly one Gemini generation and one
Google embedding call. The job completed without recovery, its vector
generation was published, unchanged replay created no job or calls, and library
verification reported zero issues. Deterministic retained Phase-3 scenarios
cover changed-source and restart semantics without spending additional hosted
calls. See [`P3R-08.md`](P3R-08.md).
