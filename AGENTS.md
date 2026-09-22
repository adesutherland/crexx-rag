# Repository guidance for crexxrag

## Product boundary

`crexxrag` is one cREXX application. Product algorithms, SQL repositories and
migrations, orchestration, policy, configuration, commands, jobs, retrieval,
evidence, and provider selection belong in Level-G cREXX.

The generic SQLite provider is owned and installed by CREXX as `rxsqlite`.
This repository must not carry a second SQLite implementation or provider.
Do not add product vocabulary or RAG policy to C/C++. Do not recreate the
removed native prototype, compatibility bridge, or old schema importer.

SQLite is authoritative. Vector sidecars are rebuildable. Every typed claim is
directional and backed by an independently addressable source span. Provider
output is untrusted until normal cREXX validation succeeds.

## Architecture and bounded changes

Prioritise architecture, small changes, common reusable components, and careful
dependency and compatibility review. Identify the owning component and its
existing public controls before editing. Do not bundle unrelated refactoring,
new frameworks, schema changes or reporting systems into a small request.

Prefer the simplest complete design that meets the user's stated outcome.
Accepted small losses of unfinished work are a design constraint, not a defect
to eliminate through extra recovery machinery. Reuse existing commands, state
and modules before adding abstractions, protocols, configuration or services.
Do not expand a bounded local workflow into a general availability system.
When proposing additional complexity, name the observed problem it solves and
explain why the simple approach is insufficient. Regression coverage comes
first; tests should prove the agreed behavior, not expand it.

Old task state must have a supported recovery path under the current software.
An explicit task reset restores a task that can be resolved or closed, including
its retry allowance; clearing counters alone is insufficient. Accepted loss of
obsolete task bookkeeping must not be defeated by additional preservation rules.
A refusal must name a supported next action. Fix encountered blockers in their
owner; do not turn a recovery request into a broad audit of hypothetical rules.
See the task-reset contract in `docs/architecture.md`.

The authoritative controller-recovery direction is the simple restart decision
in `docs/architecture.md`: one routine cleanup/start path, fresh children and
accepted loss of unfinished work. Follow it instead of extending the earlier
more elaborate proposal. Use `docs/task-reset-delivery-20260915.md` for the current
repair/QA and installation record; `docs/publication-20260915.md` retains the
earlier publication history.

Keep the logic for each cohesive aspect together in its owning source module,
and separate different aspects behind narrow module interfaces. Shared policy
and state-transition decisions must have one implementation; ingestion,
maintenance, workers and public commands should compose it. Command dispatch
and transport adapters should not accumulate domain rules. Preserve transaction
ownership and avoid circular imports when extracting modules.

Before changing a rule, prompt, command or effective configuration value,
consult the owning-module map in `docs/architecture.md` and inspect its callers.
Update the authoritative owner and confirm all worker, external-proposal and
public-surface consumers still agree. Keep related prompt text, schema and
version decisions reachable from the domain owner. Record ownership changes
and their regression evidence in `docs/maintenance-refactoring-delivery.md`.

Robust recovery is a priority: preserve task identity, attempts, provider
receipts, cumulative usage, uncertain outcomes and publication fencing across
failures and restarts. Separate task outcome, worker health, provider admission
and environment health. Separate executables are an optional, lower-priority
surface simplification, not a prerequisite for source modularity or recovery.

When asked for a standalone cREXX wrapper, deliver a standalone script that
composes existing commands. Leave product implementation bodies, contracts,
build files and tests unchanged. Use wrapper arguments for time, spend and batch
size; do not repurpose global job budgets or change persisted configuration.
If an existing command cannot support the request, explain that specific gap
before proposing a separate product change. Do not tighten approximate limits
into new deadline or reservation machinery: item-count batches, approximate
five-minute checks and modest spend overshoot are acceptable for this workflow.

Keep product orchestration in cREXX. Do not introduce JavaScript, Python, shell
or complex CMake orchestration. Runtime settings belong in configuration or
arguments, with worker counts taken from configuration. Validate the requested
use case without expanding implementation scope to suit the tests.

## Required reading

`docs/ROADMAP.md` is the sole current defect, capability and qualification
register. Update status there and link detailed evidence; other audit, incident
and delivery records retain their dated scope rather than competing worklists.

Before product work, read:

- `README.md`
- `docs/architecture.md`
- `docs/user-guide.md`
- `docs/test-strategy.md`
- `docs/integration-issues.md`

Consult the installed CREXX `rxsqlite` reference before changing the provider
integration contract. SQLite implementation changes belong in CREXX under its
separate repository authority.

## Public surface

For new or revised corpus objectives, use the
[recommended prompt templates](skills/crexxrag-maintain/prompts/README.md) as the
agent starting point. Adapt them to the corpus, retain the shared response
contracts, and select them through the existing configuration workflow. They
are recommendations, not automatically installed product defaults.

The enduring executable name is `crexxrag`. Keep human commands concise and
terminal-friendly. The local defaults are `./crexxrag.conf` and `./library`.
Machine callers use the same operation vocabulary with JSON/NDJSON or MCP.
Do not add shell scripts that own product workflows.

`crexx/application/surfaces/ragcommandcatalog.crexx` owns canonical operation
recognition and the MCP tool/schema/capability/forwarding definitions. Change
that entry together with its owning service, public-surface tests and user/agent
documentation; do not introduce a second adapter map.

`crexxrag.conf` is the single selected operator policy entry point. File edits
belong in `ragpolicyfile` and publication/locking in `ragpolicypublication`;
workers and surfaces must consume validated configuration. Worker runtime and
recovery defaults/bounds are owned by `ragworkerdefaults`, including canonical
omission. Use public policy inspection/edit and operational query commands
instead of maintaining a competing policy file or ad hoc SQL workflow.

Gemini remains the hosted regression route. Codex uses managed App Server
authentication; never extract tokens. Local embeddings use the
OpenAI-compatible llama.cpp endpoint. Preserve privacy route classification and
charging basis in reviewed plans and completed usage.

## Job files and run notes

Commented, human/agent-editable job files are an agreed product requirement.
Follow the [standing design](docs/architecture.md#commented-job-files--agreed-design)
and track implementation under RAG-OPS-007 in the roadmap. Keep each run's
parameters, notes, already-granted approvals and retry instructions together;
AGENTS holds enduring conventions and a pointer to that run record. Preserve
comments through edits and reuse existing job controls and policy owners.
Until the interface is implemented, use the existing run record and public
commands. Recording this requirement does not make file edits executable.

## CREXX boundary

Use the installed CREXX package. A sibling CREXX checkout is read-only unless
the user separately authorizes changes there. CREXX infrastructure gaps belong
in `docs/integration-issues.md`; do not hide them in product-specific native
code.

Worker processes each open their own SQLite connection. CREXX supports
provider discovery for child task VMs, but changing this product to attached
workers is a separate architecture decision; native handles remain VM-local.

## SQL and data access

Follow the SQL and data access rules in `docs/architecture.md`. Change the
owning query/projection and its callers together; check indexing, repeated
reads and loop/transaction scope. Keep the repair checklist and affected
regression evidence in `docs/sql-performance-delivery-20260913.md` current.
Do not duplicate those rules in command adapters or additional approval gates.

## Build and QA

Implementation must start by confirming regression coverage, including before
a refactor. Identify the affected public journeys, module contracts, state
transitions and failure/recovery invariants; inspect and run the relevant tests
against the chosen baseline before changing product implementation. A test's
name or a previously green full suite is not sufficient evidence of coverage.

If coverage is missing or inadequate, add the necessary tests first. A defect
fix needs a reproduction of the intended failure plus a passing positive
control; a behavior-preserving refactor needs passing characterization tests
before code moves. Use independent state, source, receipt and usage assertions
where relevant. Record the test names, baseline results and remaining gaps in
the change notes. Extend coverage at each new module boundary.

After implementation, the targeted acceptance must pass and previously passing
checks must remain passing. Use focused checks while iterating and account for
the complete required suite once at formal qualification. Report any remaining
tracked defects explicitly. Never hide failures by disabling tests, weakening
their assertions, or treating known-defect labels as passes. The maintained
[coverage matrix](docs/regression-coverage.md) records the current baseline and
unimplemented acceptance; update it with the work.

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset fast --output-on-failure
# Select affected component cases while iterating:
ctest --preset component -R '<affected-case-pattern>'
# Before a requested formal commit or publication:
ctest --preset regression
python3 tests/qa/report.py --json cmake-build-debug/qa-report.json
git diff --check
```

The `debug` test preset is an alias for fast development checks. Fast, component
and integration tiers are disjoint; `regression` covers their union. Exact-input
passing receipts are reused when widening a selection, with no duplicate product
execution. CTest reports reuse as skipped: audit the report, and distinguish
retained passes from disabled, failed, interrupted and not-run cases. A disabled
case is never a pass. Keep the explicit scale lane separate. Never rebuild over
running tests; all writable state belongs to the private execution directory.
Tests run in parallel by default with declared process demand and narrow locks
only for unavoidable fixed endpoints. See `docs/test-strategy.md` for ownership,
selection and formal coverage. Changes affecting schema, providers, workers,
public commands or retrieval require the full local gate before delivery. Provider changes
must retain the Gemini smoke test and the malformed-output/secret-redaction
negative cases. Hosted live calls require explicit bounded authority.

## Worktree and publication

Inspect branch, HEAD, status, and relevant diffs before editing. Preserve
unrelated user changes. Never stash, reset, clean, push, release, or modify the
sibling CREXX checkout without explicit authority. Use scratch libraries for
tests and never operate on an unrequested user library.

Local commits are made only when requested. Push and release are separate
authorities.
