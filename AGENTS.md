# AGENTS.md

Repository guidance for `crexx-rag`.

## Intent

Build an LLM-first local RAG and typed-graph knowledge store as a cREXX
application. Product/domain algorithms, SQL repositories and migrations,
orchestration, policy, configuration, commands, jobs, retrieval, and evidence
assembly belong in cREXX.

Native code is allowed only for small, general-purpose mechanisms that
reasonably require host APIs, initially SQLite and only measurement-justified
hashing, binary, HTTP/TLS, or vector primitives. Any such capability may be
incubated here, but it must have an independent API, tests, examples, packaging,
and benchmarks with no RAG vocabulary before it is a CREXX donation candidate.

This project is deliberately a non-trivial cREXX reference application. Do not
hide a cREXX surface weakness in product-specific native code; preserve a
minimized reproducer, workload measurement, and capability-ledger entry.

## Approved Scope And Stop Point

Phase 0, Gate 0, Phase 1A, and the Gate-1A boundary decision are complete. The
approved immediate execution unit is the bounded Phase-1B worklist in
`docs/gate1a-decision-ledger.md`. Follow
`prompts/phase1b-implementation-handoff.md` and stop unconditionally at Gate 1B
for the user's production-capability decision.

This authorizes only the listed local generic capability hardening and bounded
application-cREXX slices. It does not authorize `P1-RXPA-03`, `P1-HASH-01`,
hosted-provider calls or qualification, normal-prefix or CREXX changes,
production schema/migrations, donation preparation, Phase 2, dual-write,
cutover, native-core removal, commit, push, or pull request.

CRI-15 remains an open installed-CREXX Linux dependency. Do not hide it in a
product workaround or claim Linux provider timeout qualification until it is
fixed or separately dispositioned.

## Required Reading

Before programme implementation, read these files completely:

- `docs/README.md`
- `docs/crexx-only-vision-and-specification.md`
- `docs/crexx-only-review-findings.md`
- `docs/crexx-only-architecture.md`
- `docs/crexx-only-implementation-roadmap.md`
- `docs/crexx-only-user-guide.md`
- `docs/test-strategy.md`
- `docs/pipeline-status.md`
- `docs/gate1a-decision-ledger.md`
- `docs/evidence/2026-07-28-phase0-gate1a/GATE-1A-DECISION-PACKET.md`
- `docs/evidence/2026-07-31-gate1a-crexx-candidate/CANDIDATE-INTEGRATION-CLOSEOUT.md`
- `docs/evidence/2026-08-03-linux-build/LINUX-BUILD-REVIEW.md`
- `prompts/phase1b-implementation-handoff.md`
- `prompts/crexx-rag-agent-AGENTS.md`

Files below `docs/archive/` and `prompts/archive/` are frozen native-v1 oracle
evidence. Use them to reproduce behavior and derive fixtures; do not treat them
as current architecture, user guidance, or agent instructions.

## Programme Boundaries

- Preserve the current C++ core, C ABI, `rx_rag` bridge, version-1 bundle,
  CLI/MCP behavior, and tests as the executable oracle until an explicit later
  cutover decision.
- Do not dual-write a live library. Compare scratch libraries, copies, and
  sanitized fixtures semantically rather than by incidental row ids or JSON
  formatting.
- Keep SQLite as the source of truth. Vector stores are rebuildable sidecars and
  vector similarity never creates a typed claim.
- Every typed claim must be directional and backed by independently addressable
  source support. Ambiguity and contradiction stay explicit.
- Implement maintained application, fixture, benchmark, and analysis logic in
  cREXX Level B where practical, with Level G facades. C/C++ is for generic
  plugins; CMake/CTest is for integration. Shell may bootstrap but must not own
  product algorithms. Do not make Python part of the repeatable pipeline.
- Keep CLI, `ADDRESS RAG`, Level G, and MCP as thin bindings over one cREXX
  operation vocabulary.
- Keep MCP read-only by default. Mutations require explicit capability gating,
  plan/apply revalidation, and negative tests.
- Provider calls belong behind one cREXX local/hosted contract. Do not shell
  through `curl` or the native-v1 RAG CLI in the new path.

## Phase 1B Discipline

- Establish a resumable worklist mapped to the roadmap IDs before the first
  implementation edit; keep at most one item active.
- Implement only the exact Phase-1B IDs in the decision ledger, in its stated
  order. Do not start an item until its predecessor has retained exit evidence
  or explicit blocker evidence and remains marked incomplete.
- Keep approved generic mechanisms in a clearly separated incubation area.
  SQL repositories/schema and graph/source/claim/job algorithms and policy
  remain cREXX application code.
- Use item targets and CTest labels for development loops. Run the full
  configure/build/CTest baseline at entry and Gate 1B.
- Record exact correctness, time, memory, failure, and unsupported-capability
  evidence. Do not infer this workload's result from sister PERF2 benchmarks.
- Use local loopback/OpenAI-compatible providers and deterministic synthetic
  protocol fixtures only. Do not use hosted credentials or make hosted calls.
- Use scratch libraries/copies only. Never dual-write a live library or touch a
  production schema.

## CREXX Compatibility Boundary

Use the installed CREXX toolchain first. Any sibling CREXX checkout is read-only
reference material and may be changing underneath this project.

For planning, assume the sister PERF2 programme completes successfully. Do not
edit, build in, reconfigure, commit, stash, clean, sequence, or otherwise
interfere with that work. An approved SDK qualification may copy exact required
artifacts into a temporary scratch prefix; it must write nothing back and must
not install into the user's normal prefix.

Installed-package and plugin gaps belong in
`docs/crexx-integration-issues.md`. The native-v1 RXPA workaround is historical
evidence, not the target data boundary.

## Current Oracle Build

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

The debug preset uses Ninja and `cmake-build-debug`. Preserve the defensive
SQLite CMake link order: `SQLite3::SQLite3`, then `SQLite::SQLite3`, then legacy
variables. Keep build artifacts, `.cprag` libraries, `.local/`, and `.idea/`
untracked.

For current-oracle maintenance details only, consult
`docs/archive/native-v1/AGENTS-native-v1.md`. Its old native-core intent and
milestone are superseded by this file.

## Worktree And Publication

- Inspect branch, HEAD, status, and relevant diffs before editing.
- Treat pre-existing tracked and untracked changes as user-owned. Never stash,
  reset, clean, overwrite, or reformat unrelated work.
- Update the roadmap, `docs/pipeline-status.md`, `docs/test-strategy.md`, and
  evidence links whenever a programme gate or implemented behavior changes.
- Keep target documents explicit about implemented versus specified behavior.
- Do not edit archived evidence except to repair an archive label or broken
  link; record new findings in current documents or dated evidence.
- Do not stage, commit, push, or open a pull request unless the user separately
  requests it.
- Before publication, run the full configure/build/CTest commands above and
  `git diff --check`.
