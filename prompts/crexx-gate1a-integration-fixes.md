# CREXX Agent Prompt — Close The crexx-rag Integration Ledger

Work in `/Users/adrian/CLionProjects/CREXX` as the home repository.

## Objective

Address every CREXX compiler, runtime, library, packaging, documentation, and
performance issue recorded by the completed `crexx-rag` Gate-1A programme before
the `crexx-rag` migration proceeds.

The sister checkout `/Users/adrian/CLionProjects/crexx-rag` is read-only
evidence. You may read it and may use temporary out-of-tree builds that point at
it, but you must not edit, build in, reconfigure in, install into, stage, commit,
stash, clean, or otherwise change that checkout.

This prompt authorizes implementation in `/Users/adrian/CLionProjects/CREXX`
only for bounded, evidence-backed fixes that preserve the language design and
public ABI. It does not authorize silently choosing new language syntax,
changing a public ABI or serialized format, publishing changes, or using hosted
services. Obey all mandatory CREXX design and performance decision gates even
when that requires stopping for Adrian and resuming later.

Do not declare the programme complete merely because the immediate
`crexx-rag` build can be made to pass. Every ledger item below must have an
accepted disposition.

## Required First Actions

1. Read `/Users/adrian/CLionProjects/CREXX/AGENTS.md` completely.
2. Read `/Users/adrian/CLionProjects/CREXX/performance/AGENTS.md` completely.
3. Read every current CREXX instruction or architecture document required by
   those files for the areas you will touch. At minimum:
   - the compiler architecture and debugging guides for compiler fixes;
   - the Level B authoring guide before adding maintained cREXX tests, tools, or
     benchmarks;
   - the Level B classes, data-types, and statements guides for record,
     `.binary`, array, JSON, or control-flow work;
   - the RXVM interpreter guide before ADDRESS/runtime work;
   - `performance/ROADMAP.md`, the current dated performance programme report,
     and the relevant benchmark guide before performance work.
4. Read these `crexx-rag` files completely as read-only evidence:
   - `/Users/adrian/CLionProjects/crexx-rag/AGENTS.md`
   - `/Users/adrian/CLionProjects/crexx-rag/docs/crexx-integration-issues.md`
   - `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/GATE-1A-DECISION-PACKET.md`
   - `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/WORKLIST.md`
   - `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/raw/gate1a-validation.txt`
5. Capture branch, HEAD, status, diff summaries, submodule state, configured
   remotes, installed cREXX version, compiler identity, and both available VM
   variants for CREXX. Capture branch, HEAD, status, and diff summaries for
   `crexx-rag` before any work. Treat all pre-existing changes in both trees as
   user-owned.
6. Do not assume the version observations in the integration ledger are still
   current. Fingerprint the live CREXX source, installed toolchain, candidate
   build, and every scratch install separately.
7. Run and retain a clean, dedicated baseline for the relevant focused tests and
   the full CREXX Debug CTest suite before the first production edit. Use a
   dedicated build directory and temporary log directory so active user work is
   not overwritten. Record the exact test count and all failures/skips.
8. Create a resumable CREXX-side worklist with one item for each `CRI-01`
   through `CRI-14` below. Keep at most one item active. An item is accepted
   only when its exact reproducer, diagnosis, change or disposition, commands,
   raw results, tests, and remaining risks are linked from the worklist.

## Repository And Safety Boundaries

- Write only in `/Users/adrian/CLionProjects/CREXX` and temporary scratch
  directories.
- Never modify `/Users/adrian/CLionProjects/crexx-rag`. Before final handoff,
  repeat its branch/HEAD/status/diff audit and prove its pre-existing state was
  preserved.
- Do not install a candidate into `/Users/adrian/.local` or another normal user
  prefix. Use a version-matched `mktemp -d` scratch prefix.
- Do not use `GEMINI_API_KEY`, any other credential, or any hosted provider.
  The historical Google timeout is retained evidence, not authority for another
  hosted call.
- Do not stash, reset, clean, checkout over, or reformat unrelated work. If a
  required edit overlaps user-owned changes and cannot be merged safely, stop
  and report the exact files and hunks.
- Do not stage, commit, push, create a pull request, or publish/install a release
  unless Adrian separately requests it.
- Start every complex compiler/runtime issue with the smallest cREXX
  reproducer. Preserve it as a regression test where appropriate.
- Do not work around a cREXX weakness in product-specific native code.
- New or changed maintained benchmark and analysis programs must be cREXX Level
  B. Python must not become part of a repeatable test or benchmark path.
- Redirect verbose output to retained temporary logs rather than flooding the
  terminal.

## Accepted Dispositions

Each `CRI` item must finish in exactly one of these states:

- **fixed** — production change, focused regression, required documentation,
  and full validation all pass;
- **documented/package-closed** — no semantic code change was needed, but the
  public contract, install surface, or consumer proof is complete and tested;
- **no-CREXX-change** — a minimized reproduction proves the reported symptom is
  outside CREXX or already fixed, with a regression retained where useful;
- **decision-blocked** — a language, architecture, public-ABI, or performance
  choice genuinely needs Adrian's approval. Provide measured alternatives, a
  recommendation, the smallest exact decision, and a paste-ready continuation
  prompt, then stop as required by the applicable AGENTS instructions.

“Not investigated,” “probably fixed,” “works around it downstream,” and
“future work” are not accepted dispositions.

## Issue Ledger And Acceptance Criteria

### CRI-01 — Level G Return Of An Imported Level B Record

Evidence:

- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/repro/levelg-record-contract.crexx`
- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/repro/levelg-imported-record-return-repro.crexx`
- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/raw/p1a-sur-01/commands-and-results.txt`

The installed compiler rejected a Level G method returning an imported Level B
record class with `#TYPE_MISMATCH`.

Diagnose imported class identity through parse, symbol resolution, method
return checking, assignment, invocation, and code generation. Fix the compiler
if the reproducer remains valid. Add focused positive and negative tests for
cross-module record returns and assignments, including optimized and
non-optimized compilation and both VMs wherever runtime execution is relevant.
Do not weaken type checking to make the test pass.

### CRI-02 — Optimized `.binary` By-Value Hot-Loop Regression

Evidence:

- `/Users/adrian/CLionProjects/crexx-rag/incubator/p1a/rxjson_projection/binary_argument_optimizer_probe.crexx`
- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/raw/p1a-data-01-json-document/`

The retained samples have matching checksums, but optimized by-value helper
calls took roughly 3.8–4.0 ms versus roughly 0.23–0.28 ms for an exposed value
and 0.21–0.24 ms for direct access; non-optimized by-value was roughly
1.15–1.17 ms. Reproduce afresh rather than treating those values as the current
baseline.

This is governed performance work. Follow `performance/AGENTS.md` and
`performance/ROADMAP.md`, register the work with the required performance IDs,
compare plausible mechanisms, prove mathematical/byte-level correctness first,
and measure optimized/non-optimized behavior on both VMs. Retain raw paired
samples, build fingerprints, workload lifecycle, checksums, instruction/profile
evidence, and memory/copy evidence sufficient to explain the regression.

Predeclare an acceptance rule from the reproduced baseline before editing. At
minimum, the candidate must remove the optimizer-induced inversion without
changing `.binary` value semantics, public RXAS/RXBIN/ABI, or unrelated
performance portfolio guards. Do not obtain speed by changing the benchmark to
an exposed/global value or by deleting the by-value boundary under test.

After the first production performance edit, run focused correctness, freeze
the state, run the mandatory smallest decisive Release comparison, report the
first Release verdict to Adrian, and stop at that mandatory decision point.
Resume broader validation only after the required approval.

### CRI-03 — Historical Hosted `rxhttp` Timeout Classification

The Gate-1A investigation showed that the apparent Google timeout was caused by
downstream repeated full embedding reparsing and an incorrect dimension field,
not by a demonstrated transport defect. The corrected canary passed.

Audit the local deterministic timeout, malformed-response, and connection-error
coverage for `rxhttp`. Reproduce only with loopback fixtures. If current tests
cover the contract and there is no independent transport failure, close this as
`no-CREXX-change` and explicitly state that the old hosted symptom is not an
`rxhttp` defect. Do not make a hosted call and do not alter timeout semantics to
fit the historical symptom.

### CRI-04 — Terminal `do forever` False Missing-Return Diagnostic

Evidence:

- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/repro/levelb-do-forever-return-repro.crexx`
- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/raw/p1a-data-01/commands-and-results.txt`

The compiler emitted `#RETVAL_MISSING` for a value-returning Level B routine
whose terminal `do forever` has no reachable fall-through.

Fix definite-return/control-flow analysis if still reproducible. Add positive
and negative tests distinguishing truly non-terminating loops, loops with a
reachable `leave`, conditional exits, nested loops, explicit returns, and real
fall-through. Cover optimized and non-optimized compilation. Do not add a
dummy unreachable return to the regression source as the fix.

### CRI-05 — Level G `PARSE VAR` Emits Forbidden `parseplan`

Evidence:

- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/repro/levelg-parseplan-repro.crexx`
- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/raw/p0-01/`

An ordinary Level G `PARSE VAR` form was lowered to the Level-B-only
`parseplan` instruction and then rejected.

Trace feature-level validation and lowering order. Preserve Level B lowering
and restore a legal Level G path. Add Level G tests for literal delimiters,
multiple fields, empty fields, missing delimiters, and representative supported
templates, plus Level B comparison tests. Compile optimized and non-optimized
and execute on both VMs where supported.

### CRI-06 — RXPA Malformed Signature Reports An Internal Error

Evidence:

- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/raw/p1a-sdk-01/commands-and-diagnostics.txt`

An invalid RXPA signature such as `.int,.int` produced
`#INTERNAL_ERROR_PARSING_IMPORT_AST` instead of a structured user diagnostic.

Add a minimized compiler reproducer and fix validation/diagnostic routing. Test
valid zero-, one-, and multi-argument signatures and malformed separators,
types, returns, and empty components. The failure must be deterministic,
specific, location-bearing where the diagnostic framework supports it, and
must never be classified as an internal compiler error.

### CRI-07 — Installed RXPA SDK And External Consumer Contract

Evidence:

- `/Users/adrian/CLionProjects/crexx-rag/incubator/p1a/sdk_probe/`
- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/raw/p1a-sdk-01/sdk-manifest.txt`
- `/Users/adrian/CLionProjects/crexx-rag/docs/evidence/2026-07-28-phase0-gate1a/raw/p1a-sdk-01/commands-and-diagnostics.txt`

Close the installed-development-package gap. A clean scratch install and an
external consumer must have a version-matched, public route to:

- `rxpa/crexxpa.h`;
- the transitive generated `crexx_version.h` or a public header arrangement
  that removes that private dependency;
- a CMake package/imported target or equally durable supported build helper,
  including the capability currently supplied by `RXPluginFunction.cmake`;
- explicit compiler import and runtime plugin-load paths;
- machine-readable development metadata if it is still needed after the CMake
  package is complete;
- maintained external-plugin build documentation.

Implement and test the smallest coherent public SDK. Do not copy private build
tree paths into installed metadata. Add an install/consumer CTest that installs
to a fresh scratch prefix, configures and builds a trivial external plugin with
no source-tree or vendored fallback, compiles its cREXX importer, and loads and
runs it. Record an artifact manifest with hashes and compile/link/load commands.
Test failure against version mismatch or missing runtime path where practical.

### CRI-08 — RXPA `SETSTRING` / `RETURNSIGNAL` Const Correctness

The public surface currently forces copies or casts for constant diagnostic and
status strings because callbacks/macros accept mutable `char *`.

Minimize the C and C++ consumer cases, trace actual ownership/mutation, and
separate source compatibility, binary ABI, and generated-code implications. If
const-correctness can be fixed without a public ABI or language-design choice,
implement it and add `-Werror` consumer coverage. If it changes a public ABI or
requires choosing an ownership model, stop with measured alternatives and an
explicit recommendation before changing the ABI.

### CRI-09 — Fuzzy Parsing And Validation Of Model/Tool Output

Determine what is already available in CREXX libraries for extracting and
validating a typed payload from noisy text: leading/trailing prose, fenced JSON,
missing/extra fields, nulls, Unicode, truncation, and malformed structures.

Do not add RAG or provider vocabulary to CREXX. Produce a generic minimized
workload and tests. If this is a missing library feature, provide at least two
small public-API options, their error/ownership contracts, compatibility and
performance implications, and a recommendation. Treat new syntax or a broad
public API as a decision gate; do not invent it silently.

### CRI-10 — Ergonomic Multiline `ADDRESS` Output Capture

Reproduce the current supported mechanisms for capturing multiline stdout,
stderr, exit status, empty output, Unicode, and embedded delimiters. Confirm
whether the gap is documentation, a library/facade gap, or interpreter
semantics. Add documentation/tests if the capability already exists. If a new
surface is required, provide concrete alternatives and stop for the required
language/architecture decision before implementation.

### CRI-11 — Argument-Vector Form For `ADDRESS COMMAND`

Use a harmless local executable fixture to demonstrate whitespace, empty
arguments, quotes, Unicode, and shell metacharacters without invoking a shell
unsafely. Establish whether an argv-preserving command path already exists.
Close a documentation/test gap if it does. Otherwise provide API and ownership
alternatives, platform implications, and a recommended exact contract. A new
language or ADDRESS syntax requires Adrian's explicit approval.

### CRI-12 — Redirect Array Lifecycle

Verify and document the required lifecycle when an array used for command
redirection is reused, including whether `arraydrop` is required. Add regression
examples for first capture, reuse, empty output, and failure. If observed
behavior contradicts the documented language semantics, treat it as a runtime
bug; do not normalize the discrepancy only in prose.

### CRI-13 — Parse-Once JSON And Packed Numeric Entities

Use the `crexx-rag` JSON-document and packed-vector experiment as read-only
input, including its benchmark and optimizer probe. Establish what the current
CREXX JSON implementation reparses, what object/iterator lifetime is possible,
and whether existing `.binary` syntax is the cleanest representation for packed
float32 and integer sequences.

The public design must keep JSON values semantically JSON: JSON numeric arrays
do not by themselves guarantee float32, integer width, byte order, or packed
storage. Any packed specialization must be explicit or safely inferred under a
documented, reversible contract, with ordinary array/object traversal still
correct. Include malformed input, null/missing distinction, Unicode, empty
containers, nested values, numeric boundaries, repeated traversal, and large
embedding-shaped arrays.

Retain a benchmark that separately reports first parse, repeated traversal,
typed materialization/copy, packed float and integer conversion, encoding, peak
memory, and total time. Compare current JSON, the candidate parse-once surface,
and direct packed `.binary` access without repeatedly reparsing the same input.
Cover both VMs and optimized/non-optimized compilation. Coordinate conclusions
with `CRI-02`; do not hide the by-value optimizer regression in the JSON API.

If a clean parse-once JSON class already exists in the current CREXX worktree,
validate and finish it rather than creating a competing class. If the needed
class or packed-entity semantics require a new public contract, prepare the
design decision and stop for approval before committing to that contract.

### CRI-14 — Generic Schema/Contract Surface For External Tool Consumers

Identify the smallest generic way for a CREXX operation to describe its typed
input, result, and structured error contract to external consumers. Keep this
independent of RAG, MCP, Gemini, or any specific application. Inventory existing
class metadata, annotations, documentation generation, and runtime reflection
before proposing anything new.

Provide a minimized consumer and at least two bounded alternatives if there is
no existing supported surface. Define versioning, nullability, arrays/records,
error representation, evolution rules, and what is compile-time versus runtime.
New annotations, reflection behavior, syntax, or wire formats require an
explicit design decision before implementation.

## Work Sequence

Use this sequence unless a dependency discovered in the code requires a
documented adjustment:

1. **Freeze and reproduce:** baseline, fingerprints, worklist, and minimized
   reproductions for all concrete defects.
2. **Compiler correctness and diagnostics:** `CRI-01`, `CRI-04`, `CRI-05`, and
   `CRI-06`, one at a time.
3. **Transport classification:** `CRI-03`.
4. **Performance:** `CRI-02`, including its mandatory first Release verdict and
   stop.
5. **RXPA distribution boundary:** `CRI-07`, followed by `CRI-08` if no ABI
   decision blocks it.
6. **Library/runtime/documentation surfaces:** `CRI-09` through `CRI-14`, fixing
   clear bugs/docs gaps and preparing explicit decisions for genuine new public
   contracts.
7. **Scratch-installed downstream proof:** after all approved fixes, validate a
   fresh CREXX scratch install against read-only `crexx-rag` reproductions and
   consumers.
8. **Closeout:** full validation, preservation audits, disposition ledger, and
   a downstream resumption prompt.

Do not keep working on later items after a mandatory CREXX design, ABI, or
performance stop. Preserve the worklist so the same programme resumes exactly
where it stopped after Adrian's decision.

## Validation Requirements

For every implemented fix:

- run the smallest focused compiler/runtime/library test first;
- test optimized and non-optimized compilation where relevant;
- run both supported VMs where relevant and record an explicit reason for any
  unavailable mode;
- test failures and boundary values, not only the happy path;
- use the CREXX sanitiser workflow for affected C/C++ runtime or library code;
- preserve raw commands, stdout/stderr, exit codes, versions, and timings.

At the appropriate gates run:

1. the full CREXX Debug CTest suite with the repository-prescribed parallelism;
2. the mandatory Release performance verdict and later full performance
   validation required by `performance/AGENTS.md` for `CRI-02`;
3. a scratch-prefix install and clean external RXPA consumer with all vendored
   or source-tree fallbacks disabled;
4. read-only downstream replays of every `crexx-rag` reproducer against the
   candidate compiler/runtime;
5. an out-of-tree `crexx-rag` configure/build/CTest in a temporary build
   directory against the scratch CREXX installation if the project exposes the
   necessary toolchain override. Do not make a hosted call; use only retained
   deterministic/loopback tests. If an override is unavailable, record the
   exact missing integration seam rather than modifying `crexx-rag`;
6. `git diff --check` in CREXX;
7. final branch/HEAD/status/diff and exact test-count audits for CREXX, plus a
   repeat branch/HEAD/status/diff audit proving `crexx-rag` was unchanged.

Do not claim a fix from a warm build only. At least the final compiler/package
and external-consumer evidence must be reproduced from clean dedicated build
and scratch-install directories.

## Required Decision Packets

When an item reaches a mandatory design, ABI, or performance gate, report:

- the exact minimized source and command;
- baseline behavior and root cause;
- at least two viable alternatives, including retaining the current contract;
- correctness, compatibility, ABI, time, memory, maintenance, and platform
  consequences;
- the recommended choice and why;
- the smallest exact decision Adrian must make;
- a paste-ready continuation prompt that resumes the worklist at that item.

Do not bury several unrelated design choices in one yes/no question.

## Final CREXX-Side Deliverables

When every item has an accepted disposition and all mandatory approvals have
been incorporated, provide:

1. a one-to-one `CRI-01` through `CRI-14` disposition table;
2. exact CREXX source, test, documentation, packaging, and benchmark changes;
3. exact baseline/candidate versions, commands, test counts, skips, failures,
   raw evidence paths, performance verdicts, and scratch SDK manifest/hashes;
4. a compatibility and ABI statement;
5. a list of rejected alternatives and unresolved risks;
6. proof that pre-existing CREXX work and every `crexx-rag` file were preserved;
7. a downstream unblock matrix identifying which temporary `crexx-rag`
   accommodations may now be retested or removed, including:
   - the Level B fallback used around the Level G `parseplan` failure;
   - the unreachable-return workaround;
   - the string-only Level G surface workaround;
   - the `.binary` hot-loop exposure/direct-access workaround;
   - vendored RXPA SDK/header/helper fallback;
   - any diagnostic-only expectations for malformed RXPA signatures;
8. suggested closure text for each entry in
   `docs/crexx-integration-issues.md`—do not edit that read-only file;
9. a paste-ready prompt for the `crexx-rag` agent to install/select the approved
   CREXX candidate, replay Gate-1A evidence, remove only proven-unnecessary
   workarounds, refresh the integration ledger, and stop again before Phase 1B.

## Stop Conditions

Stop and report the exact blocker if:

- a required edit would overwrite user-owned work;
- the reproducer cannot be made version-consistent;
- the only apparent fix weakens type/correctness semantics or moves
  application-specific logic into native code;
- a language syntax, architecture, public ABI, or serialized-format choice is
  required without Adrian's approval;
- the `CRI-02` mandatory first Release verdict has been reached;
- a scratch-installed external consumer still depends on private/source-tree
  artifacts;
- a required correctness, profile, memory, failure, or cross-VM result is not
  retained and reproducible;
- validating the candidate would require writing to `crexx-rag`, installing to
  the normal user prefix, using hosted credentials, or making a hosted call.

At a stop, leave the resumable worklist accurate, keep at most one item active,
and provide the exact next decision or command. Do not declare the overall
integration ledger closed until every `CRI` item is accepted.
