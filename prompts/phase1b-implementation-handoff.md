# Paste-Ready Phase 1B Implementation Handoff

Status: completed on 2026-08-03 and retained as historical execution evidence.
All bounded items reached Gate 1B. This handoff is not active authority for a
replay, extension, Phase 2, or additional hosted-provider calls.
Phase-2 authority is recorded separately in `docs/gate1b-decision-ledger.md`.

Work in the checked-out `crexx-rag` repository. Execute only the bounded
Phase-1B authority recorded in `docs/gate1a-decision-ledger.md`. Gate 1A was
approved on 2026-08-03. Begin with the entry audit and dated resumable worklist,
then activate `P1-RXPA-01`. Continue through the approved items in order while
their entry conditions remain satisfied; do not stop after restating this plan.
Stop on a retained blocker that prevents meaningful progress, or
unconditionally at Gate 1B.

This prompt authorizes implementation within its exact limits. It does not
authorize staging, committing, pushing, opening a pull request, or any item in
the Not Authorized section of the decision ledger.

## Read First

Read `AGENTS.md` and every file in its Required Reading list completely. Read
the Gate-1A decision packet, approved-candidate closeout, Linux build review,
decision ledger, and this handoff. Treat archives as oracle evidence, not
current instructions.

Use the installed CREXX package first. Keep every CREXX source checkout
read-only. Do not install into the user's normal prefix. The later 2026-08-03
scope revision permits only low-cost, secret-gated OpenAI, Anthropic/Claude,
and Google Gemini qualification in `P1-LLM-04`; credentials remain
environment-only and must never enter output or evidence.

## Entry Audit

Before the first implementation edit:

1. record branch, HEAD, status, relevant pre-existing diffs, host/toolchain,
   installed CREXX identity, SQLite identity, and fixture hashes;
2. create a dated resumable evidence worklist mapped exactly to the approved
   roadmap IDs below, with no more than one item active;
3. configure/build/test the Debug oracle and configure/build Release;
4. retain the existing CRI-15 failure separately from product failures; and
5. use only scratch libraries, copies, sanitized fixtures, local providers, and
   deterministic loopback protocol fixtures.

If the baseline is not reproducible apart from the already retained CRI-15
failure, stop and record the blocker. Never reinterpret a failing baseline as
Phase-1B evidence.

## Execution Order

Work in this exact order. Complete and evidence each item before activating the
next one. An externally blocked item may remain incomplete after its blocker is
retained explicitly; do not misclassify blocker evidence as acceptance.

### 1. Installed SDK

Implement `P1-RXPA-01` and `P1-RXPA-02`. Prove an external dynamic plugin builds
and runs with downstream vendored/source fallbacks disabled. Retain version
match, module discovery, missing/incompatible package diagnostics, and both-VM
results. Scratch-prefix consumption is allowed; installed-prefix or CREXX
changes are not.

Exit: the external consumer is repeatable from the installed package, with
positive and negative compatibility evidence. Do not start or claim
`P1-RXPA-03`.

### 2. Generic SQLite

Implement `P1-SQL-01` through `P1-SQL-07` as a generic incubation with no RAG
vocabulary. Preserve opaque ownership and typed null/int64/real/text/blob
semantics. Retain large-value/result, transaction/savepoint, paging, FTS5,
JSON1 capability, foreign-key, WAL, busy/checkpoint, read-only zero-write,
separate-process reader/writer, backup/integrity, forced-cleanup, and optional
`ADDRESS SQLITE` evidence.

Exit: the correctness/concurrency matrix passes on supported VM variants and
forced failures demonstrate deterministic cleanup. SQL repositories, product
schema, migrations, and paging policy remain application cREXX and are not part
of this generic API.

### 3. Structured Data And Records

Implement `P1-JSON-01`, `P1-JSON-02`, and `P1-REC-01` by consuming installed
CREXX JSON/projection facilities. Prove Unicode, missing/null/empty distinction,
typed iteration, bounded encoding, representative provider/evidence payloads,
and Level-B/Level-G/plugin record crossings without corpus reserialization.

Exit: retained correctness and same-session comparison evidence selects the
typed record boundary without modifying CREXX or introducing a second JSON
library.

### 4. Provider Contract

Implement `P1-LLM-01` through `P1-LLM-05` behind one provider-neutral cREXX
contract. Use deterministic local fixtures plus configurable loopback/local
OpenAI-compatible generation and embedding. Test synthetic OpenAI, Anthropic,
Gemini, and local shapes; batch embedding; structured validation; bounded
retry/backoff; usage; privacy denial; supported/unsupported streaming and
cancellation; zero denied outbound requests; and secret-free logs/fixtures.

Exit: all deterministic and available local-provider cases pass, followed by
the explicitly authorized low-cost hosted qualification for OpenAI,
Anthropic/Claude, and Google Gemini in `P1-LLM-04`. Do not claim Linux timeout
qualification or accept the affected timeout evidence while CRI-15 remains
open; stop that acceptance path for an upstream fix or separate disposition.

### 5. Vector Boundary

Implement `P1-VEC-01` through `P1-VEC-04`. Use an explicit versioned float32
codec and application-owned dimension/type/count schema. Page the retained
11,684-by-768 workload through SQLite and report transfer, decode, arithmetic,
selection, peak memory, and total time on both VM variants.

Exit: exact ordering matches the oracle and the retained 10,000-us/64-MiB
triggers determine whether pure cREXX remains selected. Acceleration may be
recommended but no unapproved native/vector library may be implemented.

### 6. Algorithm Parity

Implement `P1-ALG-01` through `P1-ALG-05` in application cREXX over scratch
schemas only. Retain deterministic chunk/FTS, identical-ingest zero-write,
paragraph identity reuse, exact claim support/retraction, evidence assembly,
semantic parity, and profile evidence.

Exit: the bounded vertical slice matches oracle semantics without a production
schema, migration, dual-write, or native-core replacement.

### 7. Fenced Worker

Implement `P1-JOB-01` through `P1-JOB-03` in application cREXX over scratch
libraries. Use database-clock leases and monotonic fences, keep provider work
outside claim transactions, and verify the current fence during promotion.
Force termination at every specified boundary and enforce item/call plus
pre-call token/cost/time reservations.

Exit: recovery is idempotent, stale promotion is rejected, support is not
duplicated, cancellation/status are deterministic, and maximum in-flight
overrun is documented.

## Development And Evidence Loop

Give each roadmap item a target and CTest label based on its exact ID. During
development run only that target and label, for example:

```bash
cmake --build --preset debug --target <item-target>
ctest --test-dir cmake-build-debug -L '^P1-SQL-01$' --output-on-failure
```

Retain commands, raw output, fixture hashes, correctness results, elapsed time,
peak memory, failures, and unsupported capabilities in the dated evidence
directory. Maintained fixture, benchmark, and analysis logic belongs in cREXX;
CMake/CTest may orchestrate it. Do not add Python to the repeatable pipeline.

## Gate 1B

After every approved item is evidenced, run:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
cmake --preset release
cmake --build --preset release
git diff --check
```

The Gate-1B packet must contain the `rxsqlite` correctness/concurrency matrix,
structured record result, deterministic/local provider result, vector
breakdown/recommendation, algorithm parity slice, crash recovery, cREXX/oracle
profile, and capability ledger. Report CRI-15 truthfully; Gate 1B cannot claim
Linux provider timeout qualification while it remains unresolved.

Stop unconditionally for the user's production-capability decision. Gate 1B
does not authorize donation, Phase 2, production schema, hosted qualification,
dual-write, cutover, or native-core removal. Do not stage, commit, push, or open
a pull request without a separate user request.
