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
Every locally implemented donation candidate must also keep user-facing
`README.md` and maintainer-facing `SYSTEM.md` documentation beside its
implementation and have a current entry in `incubator/README.md`.

This project is deliberately a non-trivial cREXX reference application. Do not
hide a cREXX surface weakness in product-specific native code; preserve a
minimized reproducer, workload measurement, and capability-ledger entry.

Level G is the default language level for advanced user-facing libraries and
all application code, including algorithms, repositories, orchestration,
providers, jobs, fixtures, benchmarks, and tests. Level B is reserved for
CREXX bootstrap/foundation facilities or a minimized low-level capability that
cannot reasonably be expressed at Level G. Every local Level-B exception must
state that reason beside the implementation and have focused evidence. A
facade must provide a real public contract; do not add one only to bridge
language levels.

## Approved Scope And Stop Point

Phase 0, Gate 0, Phase 1A, Gate 1A, and the bounded Phase-1B worklist are
complete. Gate 1B was accepted on 2026-08-04, including all 28 bounded
Phase-1B item results and their recorded limitations. Phase 2, `P2-01` through
`P2-10`, is complete at its bounded item level. Its dated worklist and entry
baseline are under `docs/evidence/2026-08-04-phase2/`. All ten items are
accepted; Gate 2 is the active unconditional stop and no Phase-3 item is
authorized.

Do not activate a Phase-2 item until its predecessor has accepted evidence or
explicit blocker evidence and remains marked incomplete. The decision does not
authorize Phase 3, additional hosted-provider calls,
normal-prefix or sibling-CREXX changes, donation submission, dual-write,
cutover, native-core removal, commit, push, or pull request. Treat the Gate-1A
ledger and Phase-1B handoff as completed execution evidence.

CRI-15 remains an open installed-CREXX Linux dependency. Do not hide it in a
product workaround or claim Linux provider timeout qualification until it is
fixed or separately dispositioned. CRI-16 separately withholds industrial
high-throughput approval from the installed HTTP transport.

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
- `docs/gate1b-decision-ledger.md`
- `incubator/README.md`
- `docs/evidence/2026-07-28-phase0-gate1a/GATE-1A-DECISION-PACKET.md`
- `docs/evidence/2026-07-31-gate1a-crexx-candidate/CANDIDATE-INTEGRATION-CLOSEOUT.md`
- `docs/evidence/2026-08-03-linux-build/LINUX-BUILD-REVIEW.md`
- `docs/evidence/2026-08-03-phase1b/GATE-1B-DECISION-PACKET.md`
- `docs/evidence/2026-08-03-phase1b/CAPABILITY-LEDGER.md`
- `docs/evidence/2026-08-04-phase2/WORKLIST.md`
- `docs/evidence/2026-08-04-phase2/ENTRY-BASELINE.md`
- `docs/evidence/2026-08-04-phase2/P2-01.md`
- `docs/evidence/2026-08-04-phase2/P2-02.md`
- `docs/evidence/2026-08-04-phase2/P2-03.md`
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
- Implement maintained application, reusable advanced-library, fixture,
  benchmark, test, and analysis logic in cREXX Level G. Level G may consume
  installed Level-B foundation libraries normally. C/C++ is for generic
  plugins; CMake/CTest is for integration. Shell may bootstrap but must not own
  product algorithms. Do not make Python part of the repeatable pipeline.
- Keep CLI, `ADDRESS RAG`, Level G, and MCP as thin bindings over one cREXX
  operation vocabulary.
- Keep MCP read-only by default. Mutations require explicit capability gating,
  plan/apply revalidation, and negative tests.
- Provider calls belong behind one cREXX local/hosted contract. Do not shell
  through `curl` or the native-v1 RAG CLI in the new path.

## Completed Phase 1B Evidence

- Preserve the dated worklist, item evidence, raw results, and handoff as the
  exact record of the completed bounded sequence.
- Keep generic mechanisms separated from application code. SQL repositories,
  schema, and graph/source/claim/job algorithms and policy remain cREXX
  application responsibilities.
- Do not reinterpret the five secret-gated `P1-LLM-04` calls as authorization
  for more hosted traffic. Never retain credentials or unredacted authorization
  material.
- Follow the Phase-2 worklist in order with at most one item active. Give every
  parallel generic capability stream its own equivalent boundary. Continue to
  use scratch libraries/copies and never dual-write a live library.

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
