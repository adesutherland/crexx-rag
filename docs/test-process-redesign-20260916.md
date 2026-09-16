# Test process redesign — 16 September 2026

**Later runtime follow-up:** the [CREXX #701 retest](crexx-701-retest-20260916.md)
passes on installed `17e844441ed8` and removes the temporary exclusion. The
qualification counts and retained logs in this redesign record describe the
preceding runtime/artifact snapshot, not a full suite rerun on the update.

**Status: implemented and locally qualified, with the approved upstream #701
exclusion explicitly retained.** The historical stopped serial gate remains evidence;
the replacement parallel workflow is now implemented. No commit, publication,
installation into the operator prefix, hosted spend or corpus run is included.

## Outcome

Development should get a relevant answer in seconds, then run the affected
component tests. A formal commit/publication gate should account for the full
local integration coverage once for the candidate. Performance, scale, endurance
and hosted-model evaluation should be named, separate activities. A slow test
needs an explanation and an improvement owner; it is not automatically valuable
because it takes a long time.

## What actually happened

The process used in this task was:

1. Run eight existing affected checks once as the pre-change baseline: 76.02 s
   elapsed. This was not a full-suite baseline.
2. Add failing regressions with positive controls, then repair their owners.
   Each iteration selected tests with CTest name filters. Most new assertions
   were added to the large `durable_backlog` scenario, so selecting a small
   regression still ran the surrounding scenario.
3. Rebuild and repeat affected panels after product, fixture or contract changes.
   Review intentional prompt/metadata snapshot differences separately.
4. Configure/build the final candidate, then start **one** full CTest run. There
   was no second complete full run in this implementation session. That run
   repeated earlier passing tests as part of the broad gate.
5. Two source-maintenance fixture assertions failed because refreshed work now
   has a successor ID. While the full run continued, direct CMake checks on
   separate scratch directories diagnosed and verified the fixture correction.
   The intended next step was to rerun those two CTest entries, not the whole
   suite. The user stopped the run before that step.

The repeated testing concern is valid. The retained logs contain **88 completed
executions plus one disabled entry**, totalling **1,231.81 test-seconds** (about
20m32s). That sum excludes builds, direct CMake runs and the interrupted active
test; it is not total development time. `durable_backlog` alone ran **18 times,
301.73 seconds**. Configuration, prompt inspection, prompt contract and metadata
each ran four times. Those are counts, not proof that every repeat was waste:
implementation and test inputs changed between many runs. The current records
do not attach a complete input fingerprint and rerun reason to each execution,
so exact unchanged-input duplication cannot be reconstructed reliably.

There is also repetition *inside* tests: compiler optimization/VM combinations,
native versus linked execution, and build-tree versus installed-package journeys.
Some prove distinct compatibility boundaries. They should be visible dimensions
of qualification, not hidden costs in the development loop.

## Stopped run and timings

The process group was terminated and checked empty at approximately 12:45 BST.
It had run for about 11 minutes. Of 81 registered entries, 48 had reported:
**45 passed, two failed, one disabled**. Test 49 (`durable_backlog_provider`) was
interrupted; tests 50–81 were not reached. The two failed entries were the
source-maintenance/deadline fixture-ID assertions; both corrected direct CMake
scenarios passed on the unchanged binary, but their normal CTest reruns were
not performed. This is not a green full-suite result.

`controller_recovery` was **30/81**, in the middle, and passed in 48.63 s.
It follows `worker_recovery` (29/81), which passed in 144.07 s. Recovery was
relevant because this batch changed saved-output reuse in `ragwork` and retry
accounting in `raglifecycle`, alongside backlog reconciliation. That warrants
focused receipt/retry/handoff controls during iteration and the broader recovery
matrix in the formal gate. It does not warrant the full six-case, eight-worker
controller matrix after every maintenance edit.

| Test | Current run | Position | Observation |
| --- | ---: | ---: | --- |
| `worker_recovery` | 144.07 s | 29 | Eight cases, with additional subcases; includes preflight waiting and reconciliation. |
| `native_supervision` | 58.41 s | 21 | Six case matrix, including eight-worker journeys. |
| `controller_recovery` | 48.63 s | 30 | Six cases, each with 16 source files and eight workers. |
| `codex_protocol` | 41.04 s | 27 | Recompilation plus two optimization modes × two VMs, with protocol subcases. |
| `configuration_contract` | 33.14 s | 19 | Recompiles modules for two optimization modes and executes both VMs. |
| `installed_product` | 33.04 s | 42 | Package proof plus repeated provider, maintenance and three public journeys. |
| `process_workers` | 28.11 s | 23 | Native worker/process coordination and fault cases. |
| `regression_prompt_contract` | 27.63 s | 13 | Captures several real loopback journeys, not only prompt construction. |
| `temporal_provenance` | 22.83 s | 46 | Compiler/VM and semantic fixtures combined. |
| `native_surfaces` | 19.37 s | 38 | Includes an unconditional 11-second preparation delay. |
| `durable_backlog` | 18.48 s | 47 | Large combined domain scenario plus public follow-up checks. |

The prior complete 15 September run took **1170.38 s (19m30s)**. Its slowest
entries included worker recovery 144.63 s, embedding exhaustion 76.38 s, native
supervision 68.85 s and process workers 51.28 s. These are shared-machine
observations, not stable performance benchmarks. For tests not reached today,
[the complete inventory](qa-evidence/20260916-test-process/inventory.csv) clearly
separates historical timings from current results.

Evidence: [stopped run](qa-evidence/20260916-test-process/stopped-full.log),
[session execution records](qa-evidence/20260916-test-process/session-executions.json),
and the prior `cmake-build-debug/task-reset-20260915/full.log`. Native candidate
SHA256: `d93bf270b9977b6573b6c9ba8f6502a0769c6fa4c79da332ade79b3b32191c27`.

## Structural findings

- `CMakePresets.json` offers `debug` and `regression` test presets. Both select
  the full set; `regression` explicitly uses one job and continues after failure.
  There is no fast/component/integration division.
- Existing labels describe subjects such as recovery, maintenance and provider.
  They do not define priority or latency. In the stopped serial run, declaration
  order determined the sequence: cheap critical checks and slow matrices are
  interleaved. The main maintenance scenario did not run until position 47.
- No registered test currently declares `RESOURCE_LOCK`, `RUN_SERIAL` or
  `PROCESSORS`. Simply adding parallel jobs is unsafe: provider smoke and durable
  backlog fixtures reuse ports 19013–19016, and installed tests call some of the
  same scripts. Several tests themselves launch eight workers.
- Many tests compile/assemble/link inside the test and delete their scratch
  directories first. Build cost is hidden in execution cost and repeated even
  when the scenario has not changed.
- Several drivers already support `CPRAG_CASE`/`CPRAG_CASES`, but CTest exposes
  their whole matrix as one entry. A small failed case cannot be rerun cheaply.
- The native-surfaces 11-second sleep deliberately checks slow preparation
  after server readiness. It is a fixture-lifetime boundary test, not a reason
  to delay every MCP or CLI surface check.
- Worker recovery's `preflight-always` case permits 2000 polls at 20 ms; Codex
  fixtures include deliberate four/five-second delays. These are concrete
  candidates for case-level timing and shorter controlled waits. Their precise
  contribution has not been measured; timeout limits are not elapsed timings.

### Are performance tests mixed in?

Partly, but the names are misleading. `regression_sql_performance` currently
asserts query/data-access correctness with a small fixture; it does not measure
throughput or impose a wall-clock threshold. Keep that as a functional component
check and label it accurately. ANN recall and source/citation assertions also
belong to correctness testing.

The default durable provider matrix includes **40 decisions / 20 forced request
pairs**, a bounded concurrency correctness check with some load. Keep a minimal
concurrency proof in integration; classify larger repetitions as scale testing.
The 5,000-decision lane, full-corpus `FullVolume.cmake`, multi-hour soak and hosted
quality work are already separately invoked, not among these 81 entries.
No paid hosted calls were made by the stopped suite: its provider journeys use
local synthetic fixtures, even where names contain Gemini or Codex.

## Proposed suites and ordering

These are design targets, to measure during implementation, not achieved times.

| Suite | When | Coverage | Initial time budget |
| --- | --- | --- | --- |
| `fast` | After a relevant edit/build | Startup, schema/command/claim contracts, prompt construction, smallest state-transition regressions. One development runtime. | ≤30 s total; normally ≤5 s per case. |
| `component` | While implementing a capability | Selected owning-module cases plus immediate callers, meaningful failure and positive controls; small scratch SQLite fixtures. | ≤60 s for an affected selection; investigate any case >10 s. |
| `integration` | Before a formal commit or publish | All required functional coverage, actual provider adapters with loopback, processes, receipts/fences, publication, CLI/MCP and installation; explicit runtime matrix. | First target ≤10 min from today's ~20; review every case >30 s. |
| `performance` / `scale` | Relevant algorithm/SQL change and explicit qualification | Fixed dataset sizes, counts, latency/CPU/memory, scaling curves, larger concurrency ledgers. | Explicit dataset and duration, separately reported. |
| `endurance` / `hosted` / `platform` | Explicit qualification | Long runs, actual hosted model quality, supported-platform coverage. | Bounded run-specific authority and cost. |

The current 81-entry inventory gives every entry a proposed primary tier.
Entries marked component with a matrix require splitting before they meet that
budget. Other integration entries may contribute a small extracted fast case;
the inventory is not a proposal to relabel a 144-second matrix as fast.

Order by **change relevance and failure consequence**, then expected duration:

1. New or previously failing case and its positive control.
2. Cheap critical contracts and startup; validation/publication/accounting
   invariants relevant to the change.
3. Affected domain cases and their immediate service/public callers.
4. End-to-end adapter, concurrency, interruption and recovery cases required by
   the change; then the remaining formal integration coverage.
5. Installation/package proof. Separate performance/scale/endurance lanes follow
   only under their own selected gate.

Fast and component runs stop on the first unexpected failure. During planned
red reproduction, continue only the explicit positive controls needed to
interpret it. The formal gate also stops by default; completing the rest despite
a failure is an explicit diagnostic choice. Stage boundaries provide ordering;
within each stage, tests run in parallel by default after their isolation work
is complete. Serial execution requires a named resource or measurement reason.
Do not fake product dependencies merely to manipulate CTest ordering. On failure,
stop admitting more cases and let active cases finish or cancel with owned-child
cleanup; parallel execution cannot promise that only one case will have run.

Before execution show: suite, reason, selected case count, reused passes,
estimated duration and stages. During execution show, for example,
`integration 12/38 — recovery/receipt-write — estimate remaining 3–5 min`.
Estimates use recent real elapsed times with clear uncertainty. A slow current
case and its timeout must be visible without opening the source.

## Parallel execution is the default

This is a primary delivery requirement, not a later optional optimisation.
Classify every case as **parallel**, **parallel with a resource/worker limit**,
or **serial exception with a reason**. The inventory now records the proposed
class separately from its unqualified isolation status. A recovery or native
process test is not inherently serial: its workers and failure injection must
be private to that test. High worker counts require capacity accounting, not
blanket serialization of all recovery tests.

Each execution owns a directory such as
`qa/<run-id>/<test-id>/<variant>/`, containing its own:

- copied input fixtures and generated configuration;
- databases, WAL/SHM files, vectors, manifests and installation prefix;
- generated/build outputs needed by the case, temporary files and caches;
- provider request/response captures, stdout/stderr, result and timing logs;
- sockets, FIFOs, synchronization files and child-process records.

No case writes into another case's directory, a shared fixture directory, the
source tree or a user's library. Setup and cleanup are scoped to that execution;
retrying a case gets a fresh execution directory. Independently runnable cases
do not consume earlier tests' output or share a writable seed database. They
may copy a prepared immutable seed into their own directory. A test that must
compile at runtime does so in its own directory; normal scenario compilation
belongs in incremental build targets before the test run.

Folders alone are insufficient. Local servers must own distinct listening
ports, preferably by binding port zero and reporting the bound port while
keeping the listener open. Do not use a find-free-port/close/reopen race. Sockets,
process groups, named IPC and mutable configuration/cache locations also need
per-execution ownership. Failure injection targets only that case's children.
Stopping a case cleans its children; stopping the suite cleans all owned groups.
No global process-name killing or cleanup of a common temporary directory.

The only normal shared inputs are immutable build/toolchain artifacts and the
read-only source fixture originals used to make private copies. Build once,
then freeze those artifacts for the test run; no build may replace them while
tests are active. This is an explicit read-only exception, not shared test state.

Use CTest's parallel scheduling and worker/resource accounting. A case launching
eight workers must advertise that demand so running several cases does not
oversubscribe the machine. Isolation should remove locks on ordinary test data
and ports. Reserve locks/serial exceptions for genuinely exclusive resources
that cannot be isolated, or controlled performance measurements requiring an
otherwise idle resource. Every exception records its reason and owner.

## Dependencies and running each test once

The current 81 registrations declare **no CTest test dependencies or fixture
setup/required/cleanup dependencies**. The current serial order is therefore
not an expressed prerequisite chain. Scripts contain their own setup, matrices
and sometimes nested repeated journeys. Those internal costs and overlaps are
what need review; a sophisticated dependency scheduler is not the solution.

Use one explicit, deduplicated list of required case variants for a candidate.
Fast/component/integration are selections from that list, not wrappers that
silently run one another again. Expanding to integration runs the required cases
not already passed for the same candidate and test inputs. Once a matrix is
split, register its individual cases; do not also register an aggregate that
runs all of them again.

Keep a simple run record: candidate/build and runtime identity, case/variant,
test/fixture revision, command, result, elapsed time and log location. No new
general dependency engine, transitive fingerprint service or smart cache.

- Build prerequisites are handled once by the normal incremental build. Tests
  themselves must be independently runnable with private setup.
- Run each selected case variant once. An earlier valid pass counts when the
  selection expands or the exact tested candidate proceeds to publication.
- Rerun only for a named reason: relevant implementation changed, the test or
  fixture changed, runtime/environment changed, or the prior execution failed
  or was interrupted and the cause has been addressed. A planned repeatability
  experiment is a separate explicit lane, not an automatic retry-until-green.
- A docs-only change needs the docs check. A fixture-only correction needs its
  consuming cases. Product changes use a small, reviewed owner-to-test mapping;
  shared-core changes can legitimately select wider coverage. If impact is
  uncertain, name that uncertainty and the wider selection rather than build
  complicated automatic dependency inference.
- Distinct native/VM/compiler/installed variants may prove different boundaries.
  Retain them only with an explicit coverage reason and report them as separate
  variants. The same unchanged case/variant is not repeated for confidence.
- Failed, interrupted, disabled and not-run remain distinct from passed. The
  formal gate reports complete required coverage from valid retained passes
  plus the newly executed cases; it does not pretend that an incomplete suite
  passed merely because no additional test was run.

A failing baseline followed by a changed implementation and a passing rerun is
necessary regression evidence. Repeating unchanged successful work because a
new phase or suite began is not. Timing instrumentation and an explicit run
list are sufficient to make this distinction visible.

## Concrete acceleration work

| Priority | Change | Preserve |
| --- | --- | --- |
| 1 | Isolate every execution's files, databases, logs, ports and child processes; classify tests as parallel by default with explicit resource demand. | No shared writable fixtures or output, no cross-test cleanup and no port allocation race. |
| 1 | Register existing recovery/provider `CPRAG_CASE(S)` selectors as individually named cases. Split backlog tests by cohesive behavior with reusable setup and isolated writable databases. | Every existing assertion and meaningful positive/negative control; no aggregate test also repeating every child case. |
| 1 | Move scenario compilation/linking into incremental build targets; keep scratch runtime data separate from build outputs. | Correct imports and exact compiler/runtime variant. Development runs one variant; integration retains the explicit matrix. |
| 1 | Extract native-surfaces slow-readiness boundary into one named timing case; ordinary CLI/MCP checks skip that deliberate wait. | The original fixture-lifetime regression remains covered once. |
| 1 | Time worker preflight/cleanup subcases; replace incidental sleeps with observed-state barriers and minimum test-configured backoff. | Real timeout/backoff semantics where those are the behavior being tested; no product defaults changed to make tests green. |
| 2 | Reduce data/workers to the smallest counts proving each functional boundary. Controller core cases need an overlap and queued peer, not automatically 16 files × eight workers. Retain a separate wider concurrency case. | Genuine overlap/fences, exact receipts/calls/reservations; no loss of the multiworker requirement. |
| 2 | Separate direct prompt/schema contract tests from full capture journeys; run representative transport captures in integration. | Exact outgoing prompt/schema identities and adapter behavior. |
| 2 | Slim installed proof to installation, autoload/provider discovery and representative end-to-end behavior; retain specifically package-sensitive public cases. | Install-specific failures cannot be inferred from build-tree success; remove overlap only with a coverage justification. |
| 2 | Enable bounded parallel scheduling for the isolated cases; justify each remaining serial exception and measure wall-time gain. | Preserve process/resource limits; do not serialize whole categories merely because they spawn workers. |
| 3 | Give measured scale/performance tests their own labels, parameters and reports. | Small deterministic query/recall/algorithm correctness guards stay in functional suites. |

Every slow case must report setup/compile, product execution, waiting and cleanup
separately. A case exceeding its tier budget is a review finding with an owner,
not grounds to weaken assertions or merely increase the timeout. Measure the
largest contributors first; do not spend time shaving subsecond checks.

## How this escalation change should have been tested

Start with identity validation/no-change/deferral/routing cases and controls;
then retained search/read handoff and finality. Follow with config/prompt/schema
and the relevant CLI/MCP operations. Because saved-output and retry accounting
changed, include focused receipt reuse, reset and interrupted handoff cases.
One actual advanced-adapter request is relevant; rerunning its whole twelve-case
provider matrix for a prompt fix is not. The wider controller/process and
installation matrices belong to the formal integration gate once the batch is
stable. Their placement and expected cost should have been stated beforehand.

## Delivery sequence and acceptance

1. Add suite/tier/priority metadata and explicit fast/component/integration
   presets in the existing CMake test owner. Update `AGENTS.md` and test strategy
   so the full-gate instruction applies to formal qualification, not each edit.
2. Split high-cost selectable matrices and remove compile-time work from test
   execution. Keep a before/after assertion-to-case coverage map.
3. Give each case its own execution directory, ports and child ownership; classify
   parallel/resource-bounded/serial exceptions and enable parallel scheduling.
4. Add timing breakdown and a simple run-once record; remove measured waiting
   and setup waste. Avoid a new dependency-analysis framework.
5. Run the smallest affected harness checks, then one measured formal gate on a
   stable candidate. Publish timings and remaining slow-test findings.

- [x] TP1. All current assertions/variants are assigned a suite and owner; the
  approved upstream #701 disabled case remains visible and is never a pass.
- [x] TP2. Selection preview explains every included test, order and estimate;
  maintenance changes put maintenance acceptance before unrelated slow matrices.
- [x] TP3. Fast ≤30 s and representative component selection ≤60 s on this host;
  actual measurements and exceptions are recorded.
- [x] TP4. Each expensive matrix exposes individually selectable cases. Rerunning
  one failure does not execute its siblings or recompile unchanged dependencies.
- [x] TP5. A deduplicated case list executes each unchanged variant once; suite
  expansion reuses valid passes. Every rerun has a recorded change/failure reason,
  using a simple owner-to-test map rather than automatic dependency inference.
- [x] TP6. Setup/run/wait/cleanup times and longest cases are retained in durable
  reports. The formal gate has a measured improvement against 1170.38 s; the
  ≤10-minute target is accepted only after measurement.
- [x] TP7. Parallel execution is the default. Every case has private inputs,
  outputs, fixtures, databases, logs and IPC/child ownership. Resource demand is
  bounded; serial exceptions have explicit reasons. A bounded concurrent
  isolation check exercises same-case executions in separate folders and
  verifies no cross-writes, port collision or orphaned children after cancellation.
- [x] TP8. Full integration coverage remains available before formal commit or
  publish; scale, endurance, hosted and platform results are reported separately.

The approval released implementation and local qualification of this redesign.
The stopped serial invocation is not resumed. The replacement CTest selection
uses private execution directories and retained exact-input receipts.


## Implemented workflow and assertion mapping

The authoritative selections are `cmake/CrexxRagTestSuites.cmake` and
`CMakePresets.json`; `tests/qa/report.py` previews the current case inventory,
owner, priority, slots, locks, measured estimate and exact-input evidence.
See [test strategy](test-strategy.md#development-and-formal-qualification) for
commands and the explicit owner-to-test selection map. CTest is the scheduler;
there is no additional dependency engine or automatic test retry.

| Former registration / hidden work | Current selection | Coverage retained |
| --- | --- | --- |
| `worker_recovery` | Eight `worker_recovery_*` cases | Same case branches, receipt/retry/accounting assertions and controls |
| `controller_recovery` | Six `controller_recovery_*` cases | All eight-worker overlap and exact outcome/call assertions |
| `native_supervision` | Six `native_supervision_*` cases | All existing selectors; disabled worker-exit probe stays separate |
| `durable_backlog_provider` | Twelve `durable_backlog_provider_*` cases | Full decision, rejection, concurrent-40-item, budget, continuation and correction assertions |
| `durable_backlog` | Core plus `durable_backlog_escalation` | Both VMs; escalation/old-policy/finality assertions execute only in the escalation selection |
| `codex_protocol` | Four `codex_protocol_<mode>_<VM>` cases | Both optimization modes and VMs, UTF-8/noise/error controls |
| Hidden persistent 17,000-cycle Codex loop | `codex_protocol_turnover` in scale | Original request-space turnover boundary |
| `regression_controller_closure` | Eight named pipe/signal cases | Original Python `--cases` branches and real OS exit assertions |
| Native-surfaces unconditional idle wait | `qa_fixture_lifetime` | Fixture survives 11 seconds before the real loopback request |
| Per-test scenario compilation | Incremental `qa_*` build targets | Prompt inspection, project contracts, backlog, configuration and Codex protocol binaries reused read-only |
| Scratch install manifest in shared build tree | Private generated install driver | Same package sources/rules and installed acceptance; only manifest destinations move |

Smaller methodology/configuration scenarios retain their cohesive assertion
matrices. Splitting every assertion is not required for useful selection; the
measured expensive recovery, transport and backlog matrices are exposed above.
Other scenario compilation remains inside its owning case and is listed as a
remaining optimization if measurement warrants it. The full pass record prevents
unchanged cases from recompiling merely because the selection widens.

The harness has ordinary acceptance for simultaneous identical case names in
separate run roots, distinct live port-zero listeners, unchanged source fixtures,
private configuration cohorts, changed-input invalidation, unchanged-pass reuse,
failed-result nonreuse and cancellation of a spawned child. These checks first
exposed missing execution support, then path resolution and profile-cohort gaps;
they pass after the corresponding harness fixes. The formal integration run also
exposed GeminiQuery's source-relative profile assumption; it now declares the
profile explicitly. Product code was not changed by these harness repairs.

Every case retains wrapper setup, resource wait, command execution and cleanup
measurements. Internal command logs remain in its private directory. Deliberate
provider timeout/backoff sleeps remain where elapsed behavior is under test;
compilation inside legacy drivers is currently part of command time, not claimed
as an independently measured phase. Slow cases have named CMake owners in the
report. Fixed-port exceptions and their exact resources are listed in the test
strategy; all other cases are parallel or bounded by their internal worker pool.

### Qualification record

The enabled functional coverage is **121 passed**, with one separately approved
`worker_unexpected_exit` exclusion (upstream CREXX #701). The additional scale
case passes separately in **4.77 s**. There are 123 named registrations: nine
fast, 20 component, 93 integration (including the disabled entry), and one scale.
The increased case count comes from splitting existing assertions, not adding
123 new tests.

- Final fast selection: **9/9 in 3.38 s**.
- Representative changed component/adapter panel: **11/11 in 21.77 s** during
  harness development; later signature changes were requalified normally.
- First formal selection stopped on the query fixture's source-relative profile
  path: **41 new passes, nine retained passes, one failure, one disabled**,
  **119.64 s**. It stopped admitting cases and let active work finish.
- After repairing that fixture and completing the explicit helper-input map,
  continuation accounted for **73 new passes, 48 retained passes and the one
  disabled case**, **389.73 s**. No unchanged successful case was executed by
  the continuation. The changed helper-input declarations invalidated the
  affected receipts rather than pretending they had always covered those files.
- Fast plus those formal invocations total **512.75 s (8m33s)**, including the
  failed fixture attempt. This compares with the earlier **1170.38 s (19m30s)**
  baseline: about **56% less test wall time**. This is a composed qualification
  measurement with retained passes, not a claimed fresh cold run of 389.73 s.
  Build time, investigation and the separate scale lane are excluded.
- The final documentation and linked-provider manifest checks are targeted
  follow-ups (the first two-case closeout took 1.70 s); their logs are retained separately. Final report inspection proves
  all current enabled signatures have successful receipts. Disabled/empty
  selections correctly prevent `--require-complete` from reporting success.

[Implemented results](qa-evidence/20260916-test-process/implemented-results.json)
retain current case identities, ownership, timing breakdowns, reasons, resource
limits and logs. The same directory contains final CTest logs and a compact
implemented inventory; the old `inventory.csv` remains the historical baseline.
There are no unresolved local functional failures. Hosted-model quality,
corpus endurance and other platforms have not been qualified by this local run.

The native artifact remains
`d93bf270b9977b6573b6c9ba8f6502a0769c6fa4c79da332ade79b3b32191c27`;
linked bytecode remains
`bc498d7ebf4b05ac0cfba123829301f40cb0c29870f7b8bdd2a058a35b6aa47d`.
The harness changes did not alter the maintenance/escalation product candidate.
Only the local provider fixture and prebuilt test scenarios were rebuilt.


### Slow-case review and deliberate exceptions

| Owner / case | Observed cause or remaining investigation | Treatment |
| --- | --- | --- |
| `WorkerRecovery`: preflight-once | Event timestamps show successful processing followed by about 60 seconds in the live-owner refusal. `ragprocess` enforces `max(60, wait_seconds)` before refusing an undrained group. | Keep this real ownership boundary in integration; do not change product recovery semantics to shorten QA. |
| `WorkerRecovery`: preflight-always | Three preflight failures followed by the fixture's bounded 2,000 × 20 ms polling period. | Explicit slow finding; replacing the remaining polling tail with an observed-state stop is further fixture work, with the exact failure/accounting controls preserved. |
| `EmbeddingRecovery`: embedding-exhaustion | Six paid attempts and actual exponential backoff; the fixture asserts minimum arrival spacing and restart-persistent allowance. | Retain as a named integration timing boundary, outside iteration. |
| `ConfigContract`, `TemporalProvenance`, `PublicRegression` pages | Many meaningful native/VM cases; elapsed time rises under parallel CPU contention. | Review-budget flags stay visible. Configuration/Codex compilation moved to build; other cohesive matrices remain selectable by owner. |
| `InstalledProduct` | A separate package boundary: discovery, editable config, tutorial and provider/public routes from the scratch prefix. | Distinct installed variant. Its evidence cannot be replaced by a build-tree pass. |
| `PromptContract` | Actual captured request/schema hashes across ingestion, query and resolution reuse journey drivers. | Distinct capture variant in formal integration. A future smaller capture driver must preserve those exact outgoing contracts. |

These are recorded findings rather than silent timeout increases. The next
optimizations are bounded fixture changes, not a new scheduler or recovery
framework. Current acceptance preserves every original assertion; it does not
claim that every remaining integration case is now short.
