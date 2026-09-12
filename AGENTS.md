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

Keep the logic for each cohesive aspect together in its owning source module,
and separate different aspects behind narrow module interfaces. Shared policy
and state-transition decisions must have one implementation; ingestion,
maintenance, workers and public commands should compose it. Command dispatch
and transport adapters should not accumulate domain rules. Preserve transaction
ownership and avoid circular imports when extracting modules.

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

The enduring executable name is `crexxrag`. Keep human commands concise and
terminal-friendly. The local defaults are `./crexxrag.conf` and `./library`.
Machine callers use the same operation vocabulary with JSON/NDJSON or MCP.
Do not add shell scripts that own product workflows.

Gemini remains the hosted regression route. Codex uses managed App Server
authentication; never extract tokens. Local embeddings use the
OpenAI-compatible llama.cpp endpoint. Preserve privacy route classification and
charging basis in reviewed plans and completed usage.

## CREXX boundary

Use the installed CREXX package. A sibling CREXX checkout is read-only unless
the user separately authorizes changes there. CREXX infrastructure gaps belong
in `docs/integration-issues.md`; do not hide them in product-specific native
code.

Worker processes each open their own SQLite connection. CREXX supports
provider discovery for child task VMs, but changing this product to attached
workers is a separate architecture decision; native handles remain VM-local.

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
checks must remain passing. Run the required full suite and report any remaining
tracked defects explicitly. Never hide failures by disabling tests, weakening
their assertions, or treating known-defect labels as passes. The maintained
[coverage matrix](docs/regression-coverage.md) records the current baseline and
unimplemented acceptance; update it with the work.

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
git diff --check
```

Run focused tests while iterating, then the full suite after changes affecting
schema, providers, workers, public commands, or retrieval. Provider changes
must retain the Gemini smoke test and the malformed-output/secret-redaction
negative cases. Hosted live calls require explicit bounded authority.

## Worktree and publication

Inspect branch, HEAD, status, and relevant diffs before editing. Preserve
unrelated user changes. Never stash, reset, clean, push, release, or modify the
sibling CREXX checkout without explicit authority. Use scratch libraries for
tests and never operate on an unrequested user library.

Local commits are made only when requested. Push and release are separate
authorities.
