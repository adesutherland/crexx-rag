# Project architecture, regression and coverage assessment

11 September 2026. Product baseline:
`df9649d7ae18fcc74a40616f5ff9b515f86b382b`.

This is the historical initial assessment. Recovery steps 1–4 subsequently
changed and committed product implementation. For current progress, remaining
defects and the corrected next sequence, use the
[12 September status in the implementation plan](recovery-implementation-plan.md#current-status-and-next-work)
and the [current coverage result](regression-coverage.md#current-status--12-september-2026).
The original module counts, defect descriptions and validation statements below
describe their dated baseline; they are not the current release status.

## Assessment

Targeted modularisation is justified. A wholesale redesign is not supported by
the evidence. The overall architecture is sensible: one application, a common
command vocabulary, SQLite authority, rebuildable vector indexes, explicit
evidence validation and separate provider adapters. The recurring weakness is
that ownership of operational decisions is less clear than ownership of data
and provider protocols. Several modules independently interpret the same job,
task, budget, configuration or failure state.

Every implementation slice starts by confirming regression coverage, following
the user's subsequent direction: establish repeatable passing guarantees and
failing defect reproductions before changing implementation. The highest-value change
is to make operational decisions consistent through complete operator journeys.
Smaller files can help make this work
reviewable, but moving existing bodies into new files without changing their
contracts would leave the principal regression mechanisms intact.

The [consolidated register](ROADMAP.md) now brings together the five operational
P1s, nine QE requirements, 51 HC findings, 20 REL cases, seven REC/MNT records,
additional copied-corpus agent findings, qualification gates and upstream
dependencies. It preserves original IDs, priorities and detailed sources.
Finding that information required multiple records and a newer worktree; this
is a demonstrated documentation/navigation problem, not by itself proof of
poor runtime architecture.

## Scope and evidence

The original task checkout is clean `temp/maintenance-deadlines` at `e1a616a`.
The supplied QE examples identified the newer query-backlog baseline. All six
pre-existing worktrees were checked and were clean at inspection. Review edits
are isolated in `temp/project-review`, based on `df9649d`; other worktrees and
libraries were not edited.

The review inventoried all 177 tracked baseline files and searched across
product sources, tests, CMake, scripts, documentation and operating skills for
priorities, defect IDs, TODOs, open requirements and qualification limits.
It read the architecture/user/test/integration guidance, both reliability
records, operational and configuration audits, QE roadmap, controller and LLM
repair reports, and synthetic/copied-corpus MCP findings. Representative code
paths and their tests were traced; this was not a line-by-line proof of all
28,108 product source lines or a fresh reproduction of every historical incident.
Local Git history and worktree references were used, not a refreshed remote
issue-tracker inventory. Live-library status in older reports was not reread.

## Architecture and organisation

There are 56 tracked production `.crexx` files, excluding test directories,
totalling 28,108 physical lines. Counts include declarations, comments and
formatting; they are size indicators, not complexity or fault measurements.

| Module | Lines | Responsibilities relevant to the review |
| --- | ---: | --- |
| `ragproduct` | 3,304 | Dispatch, configuration and provider operations, reports/snapshots/narratives, direct-call accounting, query, jobs/workers, ingestion, maintenance and external-agent operations |
| `ragwork` | 1,956 | Work/result types, claims/fences, budget reservations, admission, receipts, external reconciliation, retries/cancellation, worker execution and semantic publication |
| `ragingest` | 1,693 | Source/chunk identity, ingestion planning/application, candidate generation and work creation |
| `ragbacklog` | 1,494 | Maintenance time/policy, census, task evidence, dispatch, window closure, lifecycle decisions and external-agent workflows |
| `ragstore` | 1,100 | Store handles, migrations, generation transactions, manifest projection, verification and shared write-start retry |
| `ragretrieval` | 1,014 | Lexical/vector/graph candidates, ranking, evidence assembly, citations and query-gap recording |

Static namespace/import inspection found no cross-module application import
cycle. The ADDRESS module's `_rxsysb` runtime namespace self-reference was
excluded from that statement. `ragproduct` directly imports 36 other product
namespaces; 19 product files call SQLite prepare/step/exec. Direct database
access is not inherently wrong for this design, but it means repository
ownership is conventional rather than enforced by a narrow interface.
`ragstorehandle.database()` exposes the underlying connection throughout the
application.

In the last 16 commits ending at this baseline, `ragproduct`, `ragwork` and
`ragbacklog` each changed in 10 commits; `ragapplicationprovider` changed in nine.
Recent changes often combine features, protocol work, recovery and qualification
across many files. This makes review and cause isolation harder. Change counts
do not show that the code is defective or measure regression frequency; several
commits intentionally span a complete use case.

Useful existing boundaries should be retained:

- `provider_contract` and the adapters separate protocol mapping from product
  tables, evidence policy and promotion.
- `raggrounding`, `ragperiod` and `ragassessment` provide focused deterministic
  logic with explicit inputs and negative tests.
- CLI, MCP and ADDRESS share a product vocabulary and dispatcher.
- Generation transactions and compatible-vector ancestry already provide
  reusable durability rules; the installed CREXX provider remains the sole
  SQLite implementation.

## What the defects actually demonstrate

| Finding | Evidence and mechanism | Architectural implication |
| --- | --- | --- |
| Job and task recovery rules disagree | OPS-002 records failed tasks under a completed parent which both retry/replay reject. `ragbacklog._closewindow` independently computes job completion; `ragwork._refreshjob` has different dead-letter/uncertainty precedence; retry guards interpret those strings again. Embedding closure now has a special missing-coverage adjustment, but the every-task/every-parent requirement remains open. | Put terminal-state and recovery-eligibility decisions under one explicit owner. A further state-guard bypass would leave task/window lifecycle disagreement. |
| Configuration accepted at one boundary rejected at another | OPS-001 records 288 uncalled worker rejections after a permitted worker-count configuration change. Current code has a count-only compatibility accommodation plus group preflight. | One compatibility decision should be consumed by plan, registration and execution. Preserve exact provider/input history without making operators reconcile multiple interpretations. |
| Failure scope was wrong, including in the tests | The controller report reproduces one lost outcome stopping peer admission; the old tests expected whole-job pausing. Later repair keeps healthy peers working, including after replacement exhaustion. Rolling replacement and shared-outage policy remain open under OPS-004. | Model task outcome, worker health and shared environment state separately. Agree expected policy before adding another retry counter. |
| Admission deferral depends on job kind | `ragwork._defermaintenancecall` returns a rollback error when no maintenance window exists. OPS-004 records temporary ordinary-ingest reservation pressure becoming worker failure. | Shared admission should distinguish temporary reservation pressure from total exhaustion and expose a decision both ingestion and maintenance understand. |
| Diagnostics and recovery policy are coupled to strings | `ragstore.sqlitebusyerror` recognizes formatted diagnostic substrings. Some `ragprocess` scalar/list failure branches still finalize before calling the diagnostic reader, the same ordering class involved in the heartbeat incident. | Use a small typed storage-failure result captured before cleanup; render text afterwards. This is a code risk finding, not a reproduced new live incident. Do not create another SQLite provider or blindly retry transaction bodies. |
| Claim policy has two constructors | `ragprocess._profilepolicy` and `ragproposalio.profileclaimpolicy` build the same stance weights. HC-16 remains. | Share the policy constructor and effective identity, with compatibility tests across worker and external-proposal paths. |
| Public contracts do not cover actual-sized results | Copied-corpus trials show a 100-review page overflowing after adding its cursor, a large job-plan row failing even at page size one, empty impact previews and a corrected workflow not reaching retirement. The page-size failure was freshly reproduced on this review's native build: limit 99 succeeds; advertised limit 100 exits 10. | Command/result boundaries need shared size/paging contracts and full operator acceptance, not more nominal endpoint tests. |

Relevant code locations at the reviewed baseline:

- [Window closure](../crexx/application/ragbacklog.crexx), `_closewindow`, line 679;
  [job lifecycle](../crexx/application/ragwork.crexx), `_refreshjob`, line 1898,
  `retrydeadletter`, line 1242, and `_defermaintenancecall`, line 633.
- [Worker supervision](../crexx/application/ragprocess.crexx),
  `reserveworkerreplacement`, near line 700, and `_profilepolicy`, line 765;
  [external proposal policy](../crexx/application/ragproposalio.crexx), line 137.
- [Storage failure classification](../crexx/application/ragstore.crexx),
  `beginwritetransaction`/`sqlitebusyerror`, lines 1038/1050.
- [Controller evidence](controller-recovery-report.md),
  [operational incidents](recovery-defects.md), and
  [copied-corpus findings](mcp-soak-trials.md#independent-protocol-and-application-checks).

Not every failure is a regression. The LLM repair census records 188 of 196
terminal items failing output validation; correctly rejecting unsupported
quotes is part of the product's contract. Other cases are previously uncovered
defects, requirement changes or external failures. The channel-ticket ceiling
was CREXX-owned and locally repaired upstream. A downstream refactor cannot
remove that upstream mechanism. The records do not support a defensible
numerical claim that regressions are increasing, or a measured percentage that
modularisation would prevent.

Some older findings also need narrower interpretation. The 16-MiB plan parsing
mismatch has been fixed. File-based configuration rejects a lease above 86,400
seconds before library access; a fresh 86,401-second public probe confirmed
that, despite the typed validator having a less specific check. The algorithm
guide explicitly documents accepted-claim confidence 1.0 as a validation marker,
not a calibrated probability. Its field naming deserves review, but reporting
a newly discovered false-probability calculation would overstate the evidence.

## Test coverage

The suite has substantial strengths. It exercises both VMs on selected paths,
optimized/unoptimized combinations where relevant, deterministic Gemini/Codex/
local protocols, malformed output and secret redaction, native installation,
stale fences, late/duplicate accounting, retained receipts, real process death,
failed SQL publication and concurrent reader/backup behavior. Rendezvous-based
tests establish actual overlapping requests. These are meaningful tests, not
just an inflated number of smoke commands.

The weaker areas are coverage of complete combinations and usefulness:

1. **Operator state transitions.** Successful individual endpoints do not prove
   failed-task retry under a closed window, renewal under terminal job state,
   mixed healthy/failed workers, or recovery after the replacement allowance
   becomes available. The five OPS requirements describe the missing journeys.
2. **Representative scale and shape.** The 40-decision loopback and historical
   5,000-decision run are useful but do not exercise every long-lived ledger,
   real result size or mixed lifecycle workload. The copied-corpus pagination
   and retirement findings escaped nominal surface tests.
3. **Retrieval quality.** ANN methodology uses a 12-vector, two-dimensional
   synthetic case and one top-1 exact-oracle comparison. That proves a specific
   bounded ANN path, not broad recall or embedding usefulness. There are good
   deterministic direction/citation tests, but no maintained 60–100-question
   independently judged comparison of lexical, graph, embeddings and iterative
   exploration. QE-09 directly addresses this gap.
4. **Qualification enforcement.** No checked-in CI workflow or branch/line
   coverage instrumentation was found in the tracked tree. External automation
   may exist; it was not audited. Full-volume and long-duration/platform gates
   remain separately invoked or unfinished. The documentation test checks
   selected vocabulary and required phrases, not agreement between roadmap
   status, source and executed acceptance.

There is no measured line/branch coverage percentage to report. Test count and
test-source line count would not supply one. Most tests are larger scenarios
driven by CMake, so adding focused tests for shared decisions should improve
failure localization while retaining the end-to-end cases. A data-driven state
matrix would be particularly useful: start state, event, next state, remaining
allowance, permitted side effects and public recovery action. The central
assertions are no duplicate external call, no lost usage, no stale publication,
no unintended peer shutdown and a usable continuation path.

The review's fresh build and test results are recorded in the validation section
below. Passing those tests does not close the new OPS or QE acceptance work.

## How much modularisation to do

Keep one coherent product and the present storage/runtime boundary. The user's
clarified priority is cohesive source ownership: keep an aspect's logic together
and separate different aspects into modules with narrow interfaces. Robust
recovery comes first. The [initial implementation proposal](recovery-implementation-plan.md)
maps admission, lifecycle, receipts/usage and supervision to concrete source
owners and coverage checkpoints.

Adrian's subsequent note about a forthcoming CREXX plugin with a linked
llama.cpp bridge reinforces the provider boundary: model loading/inference
belongs upstream; RAG composes the adapter with shared admission, durable jobs
and recovery. It does not yet establish the right process layout. QE-04 must
confirm model lifetime, cancellation, concurrency and memory per owner before
selecting that layout. Keep this planned capability separate from the installed
runtime qualification reported below.

Separate executables remain an optional, lower-priority surface simplification.
They are not a prerequisite for these refactors or an early roadmap milestone.
A reader/operator split can be evaluated later if it demonstrably simplifies
use and installation; shared policy, evidence and repositories must still have
one implementation. Packaging should follow clear module boundaries and tested
journeys, rather than drive the recovery programme.

| Proposed boundary | Benefit | Constraint |
| --- | --- | --- |
| Shared job/task/window transition policy | One interpretation of completion, retry request, continuation and waiting conditions | Distinct durable entities remain distinct; use current repositories/transactions rather than a second state store. |
| Admission/accounting and receipt lifecycle | Explicit distinction between permission to make work, actual incurred usage and permission to publish | Preserve original-attempt receipts, unknown usage, fencing and existing atomicity. Receipt persistence must remain before subsequent destructive transitions. |
| Worker supervision and environment health | Task errors do not kill healthy processes; shared outages do not trigger replacement storms | Agree rolling policy and escalation first; retain controller restart history and current process ownership. |
| Effective claim/query/maintenance policy | Eliminate duplicated policy builders and private limits | Central ownership need not mean every value becomes configurable; validation remains independent of provider promises. |
| Query service and reporting service behind `ragproduct` | Extract cohesive bodies so dispatcher changes are easier to review; direct accounting/repositories have named owners | Keep public vocabulary and behavior stable; moving code alone is not a defect fix. |
| Shared result pagination and storage diagnostics | Remove reproduced cross-surface size mistakes and fragile string-based recovery decisions | Narrow helpers only; avoid a universal CRUD layer or another provider implementation. |

Start with [REG-01's regression coverage](ROADMAP.md#reg-01--regression-coverage-before-implementation),
before product changes. Then address concrete OPS transitions and UX result
defects. Extract shared
decisions during those bounded fixes, with old/new behavior comparisons. Split
report/snapshot/narrative bodies out of `ragproduct` as a separate mechanical
change once their interfaces are characterized. Review query/policy boundaries
while implementing QE-01/02/06. Avoid a repository-wide file shuffle concurrent
with changes to runtime recovery semantics.

Measure whether this helps: fewer independent writers of job terminal state,
one claim-policy constructor, no control decisions based on rendered diagnostic
text, a documented owner for each table/state transition, and complete public
operator journeys passing after changes. Over time track escaped failures by
invariant and affected change, rather than attributing success to shorter files.

## Assessment of the QE roadmap

The QE roadmap is well directed and more explicit about evidence than a generic
feature list. It preserves the installed CREXX boundary, provenance, selected
graph roots and reproducible model identity. Its most important sequencing
point is to **start QE-09 before feature/model selection**, as its own suggested
order already says. Overall regression protection under REG-01 comes first;
its representative retrieval cases seed this wider evaluation.
Establish the lexical baseline before selecting a default embedding model or
assuming that more graph expansion helps.

QE-01/02 make the existing graph usable for deliberate exploration and fit the
current query/evidence boundaries. QE-06 has a specific code basis: ordinary
word splitting in `ragquery._words` is ASCII-only. The subsequent REG-01 tests
now demonstrate actual loss: quoted `Élodie` and `東京` return no passage through
CLI or MCP even though direct FTS lookup finds their indexed source text. This
does not imply every Unicode query fails. Preserve the exact source/citation
oracles when choosing normalization or stemming changes.

QE-04 needs more design than adding a provider kind. A short-lived CLI process
cannot retain a loaded model across separate invocations by itself. Specify
which existing long-lived process/session owns the model, how a query reaches
it, how its loss is recovered and how memory is bounded per owner. This does
not require moving SQLite handles into attached workers. QE-07's exact profile
identity and QE-08's staged replacement should accompany local-model adoption,
not be deferred until an operator needs to migrate.

QE-05 crosses config, work creation, maintenance census, health and query. A
lexical query fallback is not an embedding-free library lifecycle. QE-03 should
retain the existing provider-free `query inspect` boundary and independently
configured answerer/searcher. Neither these features nor a stronger model closes
the OPS continuation/recovery gaps. Better modular ownership supports this
roadmap, but a large preliminary rewrite would delay its measurement and add
another source of regressions.

## Validation and change boundary

The changes include this assessment, the consolidated roadmap and navigation
links, plus the subsequently requested regression coverage increment: eight
new CTest cases, their fixtures and a configure/build/test workflow preset.
Product implementation, schemas, user libraries and global installation are
unchanged. Tests and probes use disposable libraries. No commit, push or hosted
provider call is part of this work; provider tests use local deterministic
fixtures. See [REG-01 coverage](regression-coverage.md) for exact assertions and
remaining acceptance.

- Installed CREXX: `crexx-1.0.0-beta.3+local.g5ccf057a1633`.
- Fresh review build: native and linked application plus ADDRESS, from the
  reviewed `df9649d` product sources. Native SHA-256:
  `6ab6af6e5709eb21ff81dd5f31d7407883d6a9de5c7417af6d1168cca3f3d47c`.
- Review build log: `/tmp/crexx-rag-review-build.log`.
- After the authorized REG-01 increment: **36/41 passed in 495.38 seconds**
  through `cmake --workflow --preset regression`; all 33 original tests pass.
  Five ordinary failing acceptance cases expose page size, large job rows,
  closed-parent retry/replay, Unicode query loss and ingestion reservation
  pressure. The native executable hash is unchanged. Full gate log:
  `cmake-build-debug/regression.log`; see the
  [coverage record](regression-coverage.md#original-recorded-run--11-september-2026).
- Before adding REG-01 tests: **33/33 passed in 460.29 seconds**, including controller,
  embedding-exhaustion, native interruption and installed-product tests.
  Terminal log: `/tmp/crexx-rag-review-tests.log`. These results coexist with
  the separately reproduced pagination defect; the suite does not cover that
  boundary adequately. The new gate includes ordinary failing acceptance
  cases for these exposed gaps rather than hiding them as expected passes.
- Documentation verification: every one of the 92 original numbered IDs is
  present in the register; all 43 added local links/anchors resolve. The
  documentation contract and whitespace checks passed at that review point.
  These historical counts precede the REG-01 links and test implementation.
- Earlier-checkout baseline: 30/30 passed in 316.68 seconds on `e1a616a`.
  This is not substituted for the newer review baseline's result.
- Public lease-bound probe: 86,401 seconds rejected by config parsing with
  exit 3 before library access. Scratch evidence:
  `/var/folders/nr/7ckzqpl91kz80mcy3316h1tr0000gn/T/crexx-rag-review-lease-24mzvix8/`.
- Public pagination reproduction: initialized a disposable library and seeded
  101 synthetic review rows. `review list --limit 99` returns 100 records
  including the cursor; `--limit 100` exits 10 with
  `result exceeds the 100-record rendering bound`. This reproduces UX-02 on
  current product code without a provider call or a user-library mutation.
  Evidence: `/var/folders/nr/7ckzqpl91kz80mcy3316h1tr0000gn/T/crexx-rag-review-pages-vhzvny8z/`.

The recommended sequence is to confirm coverage for each change, repair
recovery through cohesive source owners, then progress the remaining policy
and query roadmap. Separate executables are optional and lower priority.
