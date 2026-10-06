# 6 October 2026 bounded release repairs

Scope: four reported product/documentation issues and the RAG packaging route
for CREXX 1.0.0-beta.3 binary assets. Other roadmap items and a corpus reset
are outside this delivery.

## Baseline and reproduction

The starting checkout was clean `main` at `40c3808d559b70a9e84f269ec3b6ba8fe517977d`.
Before product edits, `configuration_contract` and `durable_backlog` passed 2/2
on the existing local build. The `task_reset` fixture then added an oversized
workflow catalogue (>1000 concepts) beside eligible tasks and a running task.
On the old binary, the bulk MCP reset returned
`resolution catalogue exceeds 1000 concepts`, changed neither eligible task,
and failed the new partial-progress assertion. The existing single-task reset
and running-task refusal were positive controls. `regression_source_maintenance`
already covered format-4 all-zero plan/apply; the new legacy format-3 assertion
requires the refusal to name the zero call budget and format 4.

## Owners and behavior

`ragbacklog.resetbacklogtasks` retains the transaction and retry-reset owner.
The all-task path now skips a bounded evidence failure after recording that
task's ID and reason, then commits the eligible resets. Running tasks are also
listed individually. `ragproduct` returns a nonzero partial outcome with
`tasks_reset`, `tasks_blocked`, `running_tasks_skipped` and a parseable
`blocked_tasks` JSON string. Direct reset still refuses the affected task.
Source, graph, attempts, receipts, usage and accepted decisions remain unchanged
for the blocked task. The next supported inspection command is included in its
reason. This does not increase the 1000-concept ceiling or add recovery state.

`ragreportservice` adds short definitions beside the existing convergence
fields. Its census, ledger formula and SQL are unchanged. The user guide gives
the exact meanings and explains why retained unlinked histories need not
reconcile. `ragproduct` now identifies legacy zero call-budget rejection and
points to format 4; the budget interpretation still belongs to the established
configuration and admission owners. README and method guidance use the working
`library report --narrative off` command.

The release workflow now selects SHA-256-pinned CREXX beta 3 core and matching
llama.rexx ZIPs for macOS arm64, macOS x86_64 and Windows x64. It checks the
CREXX source SHA and release version in `BUILDINFO`, and the llama commit,
platform and backend in its manifest. The CMake binary-prefix path consumes the
downloaded compiler, native packager and static providers directly. Ordinary
local development continues to use the installed CREXX CMake package. No CREXX
source checkout or CREXX build occurs in the release workflow.

## Qualification

`cmake --preset debug` and `cmake --build --preset debug` passed. The targeted
reset, format-3/format-4 budget, command metadata/catalogue, report surface,
durable backlog and configuration controls passed after the fixture corrections.
`ctest --preset regression --output-on-failure` completed with 145/145 passing
exact-input receipts; CTest showed `task_reset` as skipped because the QA runner
reused its passing targeted receipt. The QA report records 145 passed, with no
failed or disabled cases. Earlier fail-first and fixture-correction failures
remain in the individual QA run logs; they were not counted as passes.

`actionlint` and the release packaging contract passed. On macOS arm64, the
actual beta-3 core and llama assets passed binary-prefix configure/build,
native library-init/two-worker smoke, install, unsigned PKG/ZIP packaging and
relocated ZIP smoke (`provider calls: 0`). This local binary-prefix check covers
macOS arm64 only; the GitHub three-platform packaging gate is a separate release
qualification. No user library or hosted provider was used in local checks.
