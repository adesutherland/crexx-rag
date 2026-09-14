# Consolidated roadmap and defect register

**14 September Test 5 complete:** ordinary MCP access/search/relationships/cited
Q&A now have a [separate smoke definition](test5-mcp-qa.md). All 56 requests pass,
with zero RAG provider calls and preserved corpus state. Performance is recorded
using server CPU, response sizes and bounded work on a shared computer, with no
stopwatch gate. Full overview work, redundant lexical sidecar preparation and
the fourth-ranked Bannockburn answer were the three initial follow-ups. The
approved workplan now keeps default 12, raises the optional maximum to 200,
skips vector preparation for lexical mode and simplifies shared setup guidance.
Fourth place is a coverage observation, not a ranking defect. All F0–F4 follow-ups
are complete: eight affected focused tests, the **71/71** full local suite and
59 provider-free MCP requests pass. The synthetic fixture returns all 200
passages with resolved citations. Changes are uncommitted; installation is unchanged.

**14 September Test 4 complete:** **RAG-SMK-010 (P2, repaired)** uses the shared
semantic projection to compare only selected replay work. Final QA **71/71**.
The live Nairn retry succeeds under normal configuration in 77.35 seconds with
one Codex turn. Its supported claim is published; two incorrect proposals were
held and rejected through normal review. Both Fiers and Nairn are resolved;
543 other extraction roots remain outside this bounded smoke. Source history,
vector coverage and zero-call retry are verified. See the
[completed checklist](test4-repair-delivery-20260914.md). Changes are uncommitted
after `300c2ac`; normal installation and authoritative libraries are unchanged.

**14 September Test 2 closure:** A0–A8 are complete and the
[checklist is retired](test2-recovery-delivery-20260914.md). Final local QA is
**71/71**; unchanged full-corpus job retry fell from **26.14 to 2.080 seconds**
with no provider calls or repeated attempts. The baseline was committed as
`300c2ac`. The subsequent [Test 4 checklist](test4-repair-delivery-20260914.md) also
completed; its current result is recorded above.

**14 September smoke repeat:** baseline `0a85f9d` was committed before all four
tests ran on a fresh disposable pre-Test-1 restore. Tests 1 and 3 passed. Test 2
completed its items but required provider-free vector recovery after a worker
stream failure. **RAG-SMK-011 (P1, repaired 14 September):** the
[Test 2 repair](test2-recovery-delivery-20260914.md) removes optional account
refresh, isolates committed vector availability and makes ordinary job retry
finish indexing. Focused tests and fresh live Test 2 pass; all 71 local checks
pass after correcting the previously stale metadata expectation. Test 4 repaired
Fiers, but Nairn's corrected response still lacked a literal endpoint. RAG-SMK-010
also reproduced. There are 544 actionable original extraction roots and one
resolved root in this new copy. [Full results](smoke-repeat-20260914.md) distinguish
controller, content and compatibility failures; this is not an all-green smoke.

**Historical checkpoint, 13 September 2026:** all twelve SQL repairs are committed
as `7febbca`, installed and qualified by 70/70 local tests plus the successful
[Test 3 repeat](test3-repeat-sql-20260913.md). [Test 4 continuation](test4-operational-redo-20260913.md)
repaired two operational extraction holds; 543 original roots remain actionable.
**RAG-SMK-010 (P2, open at that checkpoint):** whole-configuration replay compatibility rejects
unchanged old items after an unrelated source-set addition. The corpus smoke
demonstrates both the rejection and a temporary source-scope workaround;
Additive-source regression and shared-owner repair were outstanding then;
their completed qualification is recorded at the top of this file.
The dated summaries below retain their historical qualification scopes.

**Current implementation:** the approved [rule simplification](rule-simplification-repair-20260913.md)
removes global configuration vetoes and duplicate checks, makes completion and
cancellation stable, and supports explicit redo without repairing old responses.
RAG-SMK-007/008/009 are repaired and locally qualified: **69/69** tests pass in
**901.87 seconds**. The disposable corpus imports the new document, repeats as
an exact no-op, resolves its citation and prepares only its four new items. The earlier
expanded-guard proposal and its ten-probe investigation are historical.

**Latest qualification:** RAG-SMK-006 automatic publication is repaired on the
rebuilt CREXX `g037e7939bc29` candidate: focused **5/5**, full **68/68 in 944.08s**,
matching scratch-installed replay passed. See the
[publication repair record](smk006-publication-repair-20260913.md).

**Latest live acceptance:** [Test 1](test1-embeddings-20260913.md) repaired all five
missing embeddings: **34,905/34,905** stored and published, integrity green, five
Gemini calls costing **$0.000208**. Automatic publication required provider-free
recovery; the subsequent local RAG-SMK-006 qualification is recorded above.
The 545 extraction holds remain.

**Current checkpoint, 13 September 2026:** the user authorized all four repairs
after the test-only baseline. RAG-SMK-004/005 and simple controller-loss/restart
behavior are now implemented through shared owners. The final focused panel
passes **9/9 in 67.06 seconds**. Full QA passes **67/67 in 932.92 seconds**;
the separate scratch-installed replay passes **5/5**. See [the repair record](four-smoke-fixes-20260913.md),
[current coverage](regression-coverage.md#current-status--13-september-2026)
and [takeover instructions](operator-continuation-handoff.md).

All five maintenance refactors are implemented; see the
[coverage and implementation record](maintenance-refactoring-delivery.md).
Each stage confirmed or extended regression coverage before implementation and
passed its full local gate. At the end of those five refactors, the suite passed
**59/59 in 737.26 seconds**.
Shared owners now cover claim policy, domain prompt contracts, report/query
services, command metadata and worker defaults. One selected policy file has
validated public editing/replacement and consistent CLI/MCP/ADDRESS behavior.

Earlier repair milestone, 12 September 2026: the review baseline and full regression
gate are committed in `5d1481a`. Steps 5a/5b and 6 now implement the three
previously failing public-result/Unicode acceptances: **50/50 tests pass** in
the full local workflow. Qualification and exact
artifact evidence are in the [repair record](public-result-lexical-repair.md).
The [coverage record](regression-coverage.md) distinguishes the original red
baseline from the completed gate; all review tests are retained in Git.
The [post-repair maintenance review](maintenance-refactoring-review-20260912.md)
ranked the five ownership changes now recorded in the delivery record.

| Acceptance | Repair and owner |
| --- | --- |
| `regression_page_max` | UX-02: `ragcommand` validates 100 data rows plus bounded cursor metadata, composed by `ragresultpages` |
| `regression_large_job` | UX-02: `ragrepository` supplies bounded summaries and exact plan slices; `job plan` / `rag_job_plan` expose complete detail |
| `regression_retrieval_unicode` | QE-06: `ragquery` preserves indexed Unicode text, with source/citation, both-VM and installed-copy controls |

These bounded repairs do not close all operational P1s or the wider QE-06
quality requirement. The remaining operator, renewal, profile/migration and
qualification requirements below keep their existing scope.

Reviewed 11 September 2026 against `df9649d7ae18fcc74a40616f5ff9b515f86b382b`.
This is the starting point for current priorities and outstanding acceptance
work. The linked design and incident records retain detailed requirements,
historical measurements and evidence. Their dated statements about running
jobs, installations or approvals are not current operational status.

This register consolidates requirements. The subsequently authorized REG-01
work adds regression tests and a local gate; it does not choose new recovery
limits, authorize hosted provider calls or close an item because another
related item passed tests. See the
[architecture and regression assessment](project-review-20260911.md).

Subsequent user direction: **confirm regression coverage before each fix,
refactor or feature implementation**, adding missing tests first. Robust
recovery and cohesive source modules are priorities: keep the logic for an
aspect together and separate different aspects behind clear interfaces.
Separate executables are only an optional, lower-priority surface
simplification. They are not a prerequisite or an early delivery milestone.

## Scope and status

The review inventoried all 177 tracked files at the baseline, searched source,
tests, build files, guides and operating skills for defect IDs, priorities,
TODOs and open/deferred work, and reconciled the detailed records below. The
task's original checkout was the older `e1a616a` maintenance branch; the QE
requirements and latest operational P1s were found in the newer query-backlog
worktree. This register follows the newer baseline. Generated builds and local
library directories are not competing roadmap sources. No remote issue-tracker
census or live-library inspection is claimed.

- **Open:** the requirement is not delivered or its acceptance is outstanding.
- **Partial:** implemented and tested pieces exist, but the whole requirement
  remains open.
- **Recorded repair:** named historical implementation/QA evidence exists;
  this does not establish unattended, hosted or platform qualification.
- **Proposed:** a review recommendation or experiment, not implementation approval.
- **Accepted limitation:** an explicitly agreed boundary, outside active defect
  work; reopen only when the supported use case or requirement changes.
- **Upstream:** CREXX owns implementation; RAG owns downstream qualification.

P1 means high priority in RAG-OPS. HC priorities retain the configuration audit's
different definition: P0 blocked its next paid batch, P1 belonged in its
configuration repair, and P2 was hardening. They are not directly comparable
severity ratings. QE items have no original severity. A hidden constant is not
automatically a defect; distinguish policy, format guards and invariant rules.

## Operational P1 requirements

The [final operator continuation smoke](operator-continuation-smoke-20260913.md)
now records original ingestion drain and the successful repaired maintenance
window on 1edb325: full 63/63 QA, exit 0, eight workers completed and one safe
timeout replacement. The fixed window was 60 minutes; actual worker runtime
was 56m55s. Integrity passes at generation 24,922. **OPS-005 is closed.**
Turray's actual UX-01/03/04 recovery and RAG-SMK-001/002/003 are closed on their
named evidence. The five embedding repairs are complete in Test 1. The whole recovery outcome
remains open for retained extraction holds, broader retry-policy authorization
and the new-source configuration boundary beside inherited held jobs. RAG-SMK-004/005
now have local repairs; their qualification is recorded separately above.
Do not label the remaining corpus outcomes complete.

| ID | Status and owning components | Required outcome and remaining acceptance |
| --- | --- | --- |
| RAG-OPS-001 | Partial — operator composition in `ragproduct`; configuration, lifecycle, receipt/usage and worker owners | One repeatable launch/resume path, early compatible configuration handling, supported recovery and idempotence without builds, SQL or bespoke scripts. `job run`, pre-claim checks and Codex reconciliation exist. Step 3 now tests receipt-write failure for extraction/embedding: original usage survives, saved Codex output is reused and unavailable output remains held without a blind repeat. The [public recovery follow-up](public-recovery-journey.md) tests composed diagnosis/retry/waiver on a frozen installed artifact. Compatible worker-count registration is now implemented and covered in the continuation journey. The installed gate and actual original-queue/maintenance continuation passed. The simple controller restart follow-up is implemented and qualified separately in the four-fix record. Test 1 closes the five missing embeddings using public recovery. RAG-SMK-006 is locally repaired and qualified. Selected operational retries and prospective source configuration beside inherited held jobs remain separate acceptance; see the publication repair record. |
| RAG-OPS-002 | Partial — shared rules/requests in `raglifecycle`; task/window execution in `ragbacklog`, claims in `ragwork` | Accept a durable, deduplicated retry request for **every task state**, including closed windows/terminal parents; distinguish accepting the request from when execution is safe. Preserve attempts, receipts, usage, uncertain outcomes and explicit authorized ceilings. Step 2 implements request acceptance, task reconsideration and shared job-state projection; native cases cover five retained failures, covered work and exhausted/uncertain holds. Reasoned waiver/reopen controls are implemented in the [public recovery follow-up](public-recovery-journey.md), retaining missing coverage, attempts and uncertainty. The UX-04 follow-up adds targeted external-retirement controls; its qualification is recorded separately. The continuation follow-up reproduces and repairs an actual old one-attempt failure under a later policy, plus explicit embedding six versus reasoning one. Shipped Gemini examples now use three; existing explicit policies remain intact. Full local QA passed 63/63; real hold inspection and request retention passed. Test 1 explicitly authorized an embedding ceiling of two and completed all five retained failures with five calls, preserving every original attempt and completing the retry requests. Broader policy increases remain unauthorized; automatic publication required provider-free recovery (RAG-SMK-006). |
| RAG-OPS-003 | Partial — job/worker/task/report queries and command adapters; step 5 public-result repairs delivered | Documented commands alone explain progress, denominators, unique coverage versus attempts, failures, retry eligibility, waiting reasons, configured/live workers, recovery allowance, interval throughput and known/incomplete usage. Steps 1/4 add admission/supervision waiting status, pool counts and rolling capacity. Step 5 repairs UX-02's maximum-page and large-plan discovery failures, with complete detail reads. The [public recovery follow-up](public-recovery-journey.md) adds consistent actual item counts versus limits, recorded/incomplete usage, interval throughput and correction outcomes; The continuation follow-up adds paged source/operation totals, current item retry facts, provider time and controller/heartbeat/replacement details, with corpus-scale read evidence. Final full QA and corpus-scale reads passed. RAG-SMK-004 (stale registrations called live) and RAG-SMK-005 (disagreeing final states/activity) are repaired through shared supervision and lifecycle readers; their CLI/MCP parity regressions pass. See the four-fix record for exact full and installed qualification. |
| RAG-OPS-004 | Partial — `ragadmission`, `ragsupervision`, `ragenvironment` | Temporary capacity pressure, rolling worker replacement and safely uncalled shared preflight backoff are implemented. [Supervision evidence](supervision-recovery.md) covers expiry, controller restart, concurrent reservations, zero healthy workers, eight-worker outage/recovery and task isolation. Task attempts, uncertain outcomes, cumulative usage and cutoffs remain independent. The continuation gate additionally reproduced a WAL startup race; `ragstore` now shares bounded BUSY acquisition retry with transaction admission, tested by an exclusive-lock rendezvous on both VMs. Final full QA passed 63/63; actual timeout interruption/replacement and healthy-peer progress passed in the bounded corpus smoke. Wider outage/platform classification remains open and separate. |
| RAG-OPS-005 | Closed — local full QA 63/63 and actual same-job ingestion/maintenance continuation; configuration, job, budget and window owners | One continuation/renewal operation handles optional exhausted budgets, operational configuration registration and remaining work under terminal internal jobs/windows. Preserve cumulative usage, attempts, receipts, held outcomes and completed work through a new authorization period; do not erase history. Distinguish reserved from consumed capacity. Agree essential versus optional controls, omission/renewal semantics and defaults before code; external account restrictions and the user's unchanged cutoff remain binding. |

### Simple controller restart — OPS-001/004, implemented

Follow the [architecture decision](architecture.md#durable-ingestion) and the
simplicity rule in AGENTS.md. Controller failure ends that run. Every ordinary
launch/restart performs the same cleanup/start sequence; there is no election,
worker adoption or extra supervisor. Losing unfinished in-flight work is an
accepted small cost. OPS-005 budget renewal remains closed and is not redesigned.

| Responsibility | Owning area | Acceptance before closure |
| --- | --- | --- |
| Child lifetime | `ragprocess`, existing runtime registry | Record child and controller PIDs in SQLite; before taking further work, the child checks its controller and exits if it has gone. Killing only the controller while a response is held must not permit another claim. `regression_controller_loss` now passes; startup and original-parent identity controls also pass. |
| Routine launch/restart | `ragprocess`; `ragproduct` composes public commands | Politely stop the recorded old controller and children for the selected job, reconcile abandoned runtime state, then start a fresh controller and children. Do the cleanup every time, even when nothing remains. `regression_restart_live` exercises ordinary `job run` with a surviving group and repeated `job continue` after drain. The implemented path uses these existing commands. |
| Durable state | Existing `ragwork`/`raglifecycle`, receipt and usage owners | Preserve committed results, task/attempt history, receipts and cumulative usage. Reuse existing handling for unfinished or uncertain work; cleanup does not renew budgets, retry holds or duplicate paid requests. Existing interruption/receipt/continuation gates remain required alongside the new repeated-cleanup assertions. |
| Process visibility and scope | Existing process checks and public diagnostics | Use the launcher's permission domain and restrict cleanup to the selected registered group. A permission failure is not proof of death. Selected-group isolation, remote refusal without mutation and PID-zero reservation controls pass. The installed probe still conflates absent and inaccessible PIDs; qualification covers same-domain local processes only. |

Keep the mechanism in its existing owning modules. A separate executable or
attached-thread conversion is not part of this outcome. Local fault injection
and a green full suite establish the tested behavior; any further installed,
platform or live-corpus qualification must be named separately.

OPS-001 is the overall operator journey; OPS-002/004/005 define transitions and
OPS-003 makes their outcomes visible. Implement shared decisions once; avoid five
independent wrappers. The [controller repair](controller-recovery-report.md)
closes peer isolation cases, not rolling replacement or renewable budgets.
The [LLM repair plan](llm-processing-repair-plan.md) records earlier partial
qualification; its interruption failure is followed by the later controller
repair evidence, while its representative extraction/maintenance/agent trials
remain separate acceptance work.

## Query and embedding roadmap

All nine are open requirements. Preserve the complete acceptance conditions in
[the query-engine backlog](query-engine-backlog.md). The following is their
consolidated delivery and dependency map, not a new feature specification.

| ID | Outcome | Existing owner, dependency and acceptance focus |
| --- | --- | --- |
| RAG-QE-01 | Selectable graph entry points in search results | `ragretrieval`, evidence types/serialization and shared surfaces. Stable concept IDs, types, mention citations, passage origin, lifecycle/ambiguity and generation; bound/page candidates and expose truncation. Do not invent nodes for unextracted passages. |
| RAG-QE-02 | Explicitly selected, bounded graph expansion | Query plan plus traversal/evidence. Preserve ordinary inferred anchors. Selected IDs, direction/hops/time, generation/staleness, missing IDs, cycles, high-degree nodes and duplicate paths need tested bounds and trace. Compare curated and optional automatic expansion under QE-09; similarity is not a claim. |
| RAG-QE-03 | Standalone human or optional LLM-directed querying | Shared query service and surfaces. Installed reader without extraction credentials; preserve zero-write/zero-provider `query inspect`. Bound searcher calls/privacy/budgets, validate citations/IDs, and prevent implicit claim writes. Answerer changes do not invalidate embeddings. |
| RAG-QE-04 | Local embeddings with persistent CREXX ownership | Existing provider abstraction and process/session ownership; upstream NI-01–06. Prove offline installed cold/warm use, model reuse, actual CPU/GPU backend, per-owner memory, bounded batches and durable recovery. Preserve HTTP routes; no cross-process native handles or assumed shared allocation. |
| RAG-QE-05 | Deliberately embedding-free lifecycle | Configuration, ingest, maintenance, health and query. Disabled is distinct from missing/failed required coverage; no embedding calls or endless repair census. Later enabling creates only embedding/index work, retaining evidence and graph. This crosses more than the query adapter. |
| RAG-QE-06 | Measured lexical baseline and improvements | `ragquery` and lexical retrieval. **Step 6 repairs the reproduced Unicode query loss**, independently of broader ranking work; see [qualification](public-result-lexical-repair.md). Names/inflections/OCR/typos/aliases/phrases and variant allocation then need frozen-question evidence of gain and precision loss, preserving original citations. |
| RAG-QE-07 | Stable, reproducible embedding profiles | Configuration/work/vector identity; upstream NI-05. Bind weights/checksum, revision, tokenizer, preparation, query/document instructions, pooling, normalization, truncation, dimensions and precision. Retain artifacts/licence and backend qualification. Same dimensions/display name cannot prove compatibility. |
| RAG-QE-08 | Resumable embedding-model migration | Embedding-only maintenance, storage and publication; QE-07. Keep complete old model/index queryable until replacement coverage passes; resume, publish atomically and roll back. No repeated source import/extraction, mixed embedding spaces or paid sidecar rebuild. |
| RAG-QE-09 | Comparative retrieval, exploration, performance and longevity evaluation | Cross-route QA. Start with 60–100 independently supported questions, fixed corpus/graph/settings and agreed thresholds. Compare lexical, graph and small/stronger embeddings; separate ANN error, graph maturity and iterative exploration. Measure useful packet evidence, displacement, calls, latency/tails, memory, throughput and rebuild time on identified hardware/artifacts. Retain Nomic comparison; model candidates are experiments, not selected defaults. |

Begin QE-09 baselining and QE-01/02 interface design early. QE-06 should precede
embedding-model selection; QE-07 should precede freezing a native profile.
QE-04 needs both upstream capability and a concrete persistent request owner.
Adrian reports a forthcoming CREXX plugin with a linked llama.cpp bridge
(11 September). Treat this as a planned QE-04 implementation route. Keep it
behind the RAG provider interface; confirm model/session lifetime, concurrency,
cancellation, failure isolation and memory ownership before choosing the worker
layout. Admission and recovery should remain independent of HTTP versus a
linked bridge. The installed runtime is not yet qualified for this route.
The agreed 12 September decision retains process workers for fault isolation
and replacement. A bounded attached-thread comparison is an optional QE-04
experiment alongside the bridge, measuring model lifetime, memory, throughput
and cancellation; it is not the remedy for cross-account PID inspection.
Deliver QE-08 with profile changes rather than adding migration after adoption.
Qualify QE-03 and QE-05 as complete installed workflows. Operational P1 closure
remains a parallel prerequisite for unattended work, not an implication of
better retrieval scores.

## Agent and public-surface findings outside the numbered backlogs

These review IDs identify existing findings from
[copied-corpus MCP trials](mcp-soak-trials.md#recommended-next-changes-and-repeat-tests);
they do not create duplicate implementations. Original trials and preserved
data provide evidence, not a new live authorization.

| Register ID | Status | Requirement, mapping and acceptance |
| --- | --- | --- |
| RAG-UX-01 | Closed — local QA and actual named Turray discovery on 12 September | Task lookup by subject/concept and addressable workflow inventory. Maps to OPS-003. The actual repeat found Turray through `maintain workflows --concept Turray` without supplying evaluator IDs, then paged its related tasks. The original failed trial remains historical evidence. |
| RAG-UX-02 | Recorded repair — steps 5a/5b; see [qualified boundaries](public-result-lexical-repair.md) | Coherent pagination and large-row detail. Maps to HC-33/34 and OPS-003. Tests demonstrate the 99/100 review-page boundary and a one-job page failing at 65,536 retained-plan characters after 65,535 succeeds, in human/JSON/NDJSON/MCP. The copied-corpus trial also found a 1,468,714-character plan. The repaired summary/detail projection preserves exact full-detail access, with ADDRESS and installed-copy boundary checks. Wider result-shape limits remain HC-34. |
| RAG-UX-03 | Closed — full QA 59/59 and actual Turray effect preview/acceptance | Connection plans and pending external acceptance previews expose affected claims, supports and conflicts, plus connection dispositions. Lifecycle validation is shared with publication; old saved plans remain immutable. See [coverage and qualification](connection-effect-previews.md). |
| RAG-UX-04 | Closed — full QA 59/59 and actual Turray retirement at generation 24,219 | Targeted public workflow census enqueues remaining connection or retirement questions with generation and ownership/outcome checks. Existing reviewed retirement completes the parent/workflow while preserving history. See [external workflow recovery](external-workflow-recovery.md). Maps to the external-retirement part of OPS-001/002; broader operator qualification remains separate. |
| RAG-UX-05 | Proposed | Source-scoped query inspection and citation-adjacent context. Maps to QE-01/02/06/09. Repeat fixed historical questions and measure coverage, citations, faithful qualification and calls. |

Inline claim submission and complete task-evidence refresh were subsequently
implemented and trialled; retain those as recorded repairs, not open copies of
the earlier synthetic-trial gaps. External-agent tests do not establish general
prompt-injection resistance or historical truth.

## Configuration audit reconciliation

All 51 HC IDs are retained below, including fixed and partially fixed entries,
so none disappears during consolidation. Detailed original behavior,
classification and proposed controls remain in
[the configuration audit](configuration-audit.md#runtime-and-semantic-configuration-findings).
Its original line numbers are historical. Here, **recorded repair** follows the
dated audit; **partial/open** avoids assuming every literal was migrated.
The review verified representative current call sites and specific drift noted
below; it did not execute a separate acceptance test for every HC row.

| ID | Original priority | Consolidated status and remaining scope |
| --- | --- | --- |
| HC-01 | P0 | Recorded repair: role extraction envelopes replace hidden ingest/maintenance limits. |
| HC-02 | P0 | Recorded repair: duplicate extraction output clamp removed. |
| HC-03 | P0 | Recorded repair: embedding dimensions derive from reviewed role/catalogue. |
| HC-04 | P0 | Recorded repair: shared embedding role cost envelope. |
| HC-05 | P0 | Recorded repair: bounded inline config/3 catalogue/capability/pricing records; separate catalogue files remain an optional layout proposal. |
| HC-06 | P0 | Recorded repair: actual prompt text and file inputs enter canonical configuration. |
| HC-07 | P0 | Partial: sidecar byte guard configurable; whole-payload loading/ANN memory design remains open, overlapping QE-04/09 performance. |
| HC-08 | P0 | Recorded repair: guided wait derives from reviewed runtime policy. |
| HC-09 | P1 | Recorded repair: answerer input/output envelope configured. |
| HC-10 | P1 | Open query policy: question, alias, spelling and edit-distance limits; map evaluation to QE-06/09. |
| HC-11 | P1 | Open query language/intent rules; map to QE-06. |
| HC-12 | P1 | Open analysis-note retrieval limit. |
| HC-13 | P1 | Open lead mentions per passage. |
| HC-14 | P1 | Open diversity and evidence/temporal ranking weights; measure before tuning under QE-09. |
| HC-15 | P1 | Open policy/representation review: accepted-claim confidence is still 1.0 and hop breakdown uses .75. The later algorithm guide explicitly defines 1.0 as a validation marker, not probability; do not label it a newly discovered false-probability calculation. Decide whether the machine field and score breakdown communicate that meaning clearly; do not replace it with an arbitrary tunable confidence. |
| HC-16 | P1 | Recorded repair: stage 1 shares `ragclaimrules` across workers, external proposals and reviews. Baseline characterization and the complete 51-test gate pass; see the staged delivery record. Configurable weight changes remain separate policy work. |
| HC-17 | P1 | Open claim promotion threshold policy (500,000 millionths). |
| HC-18 | P1 | Open extraction cue/ranking policy. |
| HC-19 | P1 | Open maintenance context limits for prior notes/query gaps. |
| HC-20 | P1 | Open maintenance priority/scoring policy; preserve ordering of essential repairs. |
| HC-21 | P1 | Open maintenance cognitive-trigger policy. |
| HC-22 | P1 | Open ingest work priority and its relation to maintenance priorities. |
| HC-23 | P1 | Open unconfigured ingestion fallback; explicit policy should reach production paths. |
| HC-24 | P1 | Recorded repair: vector row/embedding item/batch controls. |
| HC-25 | P1 | Recorded repair: configured provider batch capability. |
| HC-26 | P1 | Implemented in source: source file/depth guards flow through config and collection; retain operator-configuration regression. |
| HC-27 | P1 | Open storage policy decision. Do not make WAL/FULL casually mutable: choose only supported modes after workload/durability evidence. Foreign keys remain invariant. |
| HC-28 | P1 | Open named backup page/retry/wait policy; preserve installed `rxsqlite` semantics. |
| HC-29 | P1 | Open provider-admission grace/poll policy; review alongside OPS-004, not as independent knobs. |
| HC-30 | P1 | Partial: worker runtime/recovery defaults and bounds now share `ragworkerdefaults` across typed config, file input and canonical identity. Stale/prune/controller timing still needs one coherent policy. |
| HC-31 | P1 | Partial policy consolidation: process and one-in-flight checks are explicit. File parsing and runtime claims now cap leases at 86,400 seconds, superseding the audit's old 3,600 figure. The typed config validator checks positivity only, but a public 86,401-second config probe was correctly rejected before library access; do not report a reproduced public lease-bounds defect. |
| HC-32 | P1 | Implemented in source: plan TTL used by planning and configuration transitions. |
| HC-33 | P1 | Partial: maintenance cursor handling and UX-02 maximum review/job/event pages are implemented. Wider defaults/maxima still need coherent presentation policy. |
| HC-34 | P1 | Partial: UX-02 maximum-page and large-job bounds are repaired with complete plan access; broader result-shape/field limits still need review. |
| HC-35 | P1 | Open snapshot churn weights; lower urgency than correctness/recovery. |
| HC-36 | P1 | Open report-health thresholds and narrative subject policy. |
| HC-37 | P1 | Recorded repair: provider smoke uses configured embedding dimensions/envelope. |
| HC-38 | P1 | Partial: one selected runtime policy now has validated public show/set/replace commands and fresh MCP registry loading; labelled compiled compatibility fallbacks remain. Broader registry simplification remains a decision. |
| HC-39 | P1 | Partial: editable profile TSVs exist; compiled fallback remains. Preserve compatibility rather than deleting it as incidental cleanup. |
| HC-40 | P2 | Open named HTTP wire/buffer guards; expose only operator-relevant policy. |
| HC-41 | P2 | Open documented transport timeout/protocol-version guards. |
| HC-42 | P2 | Open hidden Anthropic missing-output fallback within generic adapter; verify whether a supported product route reaches it before prioritizing. |
| HC-43 | P2 | Open named Codex bounds/close timing; completed-request retention was separately repaired upstream and must not be counted as still open here. |
| HC-44 | P2 | Open central parser/bootstrap format limits; they cannot depend on the unparsed file they protect. |
| HC-45 | P2 | Original 65,535/16-MiB plan-parser mismatch is resolved in current planning/configuration source. Bulky generic job result fields remain UX-02/HC-34. |
| HC-46 | P2 | Proposed connector capability documentation; supported parsers remain code, includes remain configuration. |
| HC-47 | P2 | Open shared platform/executable discovery and named temporary-allocation guard. |
| HC-48 | P1 | Partial: config/3 next-batch requirements and compatibility projection exist; full policy migration is not complete. |
| HC-49 | P2 | Open central generated-response bounds; relation to reviewed evidence/citation policy must remain explicit. |
| HC-50 | P1 | Recorded repair: `ragresolutioncontract.resolutionactions` is consumed by both response schemas and backlog validation, with subject/workflow and optional-provenance regressions. Independent grounding and untrusted-output validation remain mandatory. |
| HC-51 | P1 | Open replay-lineage depth/truncation visibility. |

Do not implement this as 51 unrelated configuration switches. Shared typed
policy, compatible validation/canonicalization and a small set of justified
operator controls should replace duplication. Preserve the distinction between
semantic identity, operational identity and corpus reprocessing authority.

## Recovery and reliability history

These records are retained regression obligations. The 7 September
[REL repair record](reliability-coverage-review.md#current-issue-register)
supersedes the earlier open/fixed labels in the
[6 September investigation](reliability-coverage-review-20260906.md). New OPS
requirements may expose related gaps without invalidating an older test's
specific result. Current peer-isolation behavior follows the 10 September
controller record rather than the older whole-job uncertainty hold.

| IDs | Recorded repair or remaining work | Acceptance/evidence owner |
| --- | --- | --- |
| REL-001 | Recorded repair: manifest writer ownership | `publication`; SQLite ownership spans projection/rename. |
| REL-002 | Recorded repair: batch and single-proposal atomic publication | `publication`, `native_publication`; no graph prefix after late failure, usage retained. |
| REL-003 | Recorded repair: task-appropriate resolution actions | `durable_backlog`, provider/grounding negatives. |
| REL-004 | Recorded repair: paid call success distinguished from item publication | Native semantic/attempt/usage/reservation censuses. |
| REL-005 | Recorded repair: generic extraction/embedding durable-response recovery | `native_receipts`, Codex/durability; no second call for retained output. Stage 3 adds receipt-INSERT faults for both work types and Codex, preserving known usage and saved output without a blind repeat. See [receipt recovery](receipt-recovery.md); OPS-001 operator/platform qualification remains open. |
| REL-006 | Partial qualification: bounded concurrent fault matrix implemented | Native/SQLite rendezvous tests; multi-hour, installed Linux and larger combined workloads remain below. |
| REL-007 | Recorded repair: rollback/commit before manifest projection, first-index recovery | `publication`, `native_interruption`; no requeue after committed mutation. |
| REL-008 | Partial: graph-only vector reuse correct; training CPU for comparison remains | `ann_methodology`, maintenance; optimize only with QE-09 measurement. |
| REL-009 | Recorded repair: ancestral-index observations accepted under membership proof | ANN/repository verification. |
| REL-010 | Historical wording repair; ongoing documentation governance obligation | Do not generalize local, synthetic or dated evidence into whole-product readiness. |
| REL-011 | Recorded repair: admitted cancelled call retains usage and settles reservation | `publication`, `native_interruption`. |
| REL-012 | Recorded repair: late/excess/duplicate usage distinguished from publication authority | `publication`, provider/window policy tests. |
| REL-013 | Recorded repair: extraction resolves active survivor during merge | `durable_backlog`; no migration-parent revival or partial graph. |
| REL-014 | Recorded repair: incomplete alternate vector profile cannot replace complete publication | `ann_methodology`; full staged migration remains REC-001/QE-08. |
| REL-015 | Recorded repair: events command reads event ledger, status exposes error | Public event paging and interruption checks; broader status remains OPS-003. |
| REL-016 | Recorded repair: compatible legacy relative URI no-op | `publication`; require original envelope and working-directory evidence. |
| REL-017 | Recorded repair: remainder incorrectly used for unit conversion | Receipt latency/lease and retry-delay checks; historic bad duration is not silently rewritten. |
| REL-018 | Recorded repair: oversized numeric command input rejected without panic | `native_surfaces`; maintain cross-surface bounds. |
| REL-019 | Recorded repair: durable task census enters reports/health/snapshots | `durable_backlog_provider`; OPS-003 is wider. |
| REL-020 | Recorded repair: original question preserved in query-gap evidence/search | `durable_backlog`; broad retrieval quality remains QE-06/09. |
| RAG-REC-001 | Partial: prospective config/no-op, sidecar recovery and compatible ancestry repaired; explicit complete staged corpus replacement still open | [Recovery record](recovery-defects.md#rag-rec-001--incomplete-replacement-hides-a-complete-vector-baseline). QE-08 covers embedding-model replacement, not every full-corpus replacement. |
| RAG-REC-002 | Recorded repair: migration republishes matching manifest | Durability schema-8/9 case; retain later schema migration coverage. |
| RAG-MNT-001 | Partial: quote-to-original-byte grounding repaired; real extraction success/maintenance quality remains separate | Grounding/provider negatives, LLM trial plan; preserve exact evidence validation. |
| RAG-MNT-002 | Recorded repair: drained cancellation reaches terminal state | Cancellation/recovery cases; OPS-002/005 expose other terminal-state interactions. |
| RAG-MNT-003 | Recorded repair: replay atomically retains reviewed budget policy | Durability claims/reserves/settles/completes replay, not lineage alone. |
| RAG-MNT-004 | Recorded repair: typed identity reuse and explicit alias questions | Backlog/provider fixtures; broad hosted success not inferred. |
| RAG-MNT-005 | Recorded local implementation: autonomous resolution and connection workflows | Backlog/native fixtures and local UX-04 external completion are recorded; fresh-operator and unattended qualification remain open. |

## Other qualification, research and upstream dependencies

The IDs in this section index existing unnumbered work; they do not silently
raise its priority above the operational P1s.

| Register ID | Status | Scope and source |
| --- | --- | --- |
| RAG-QA-01 | Open | Bounded multi-hour mixed-workload/long-ledger soak with recorded faults, public readers/backup and resource measurements. The historical 5,000-decision fixture is not unattended qualification. [Test strategy](test-strategy.md#bounded-scale-gates), [process cases](qa-process-cases.md). |
| RAG-QA-02 | Open | Representative extraction, cognitive maintenance and fresh-agent operator acceptance on preserved copies; retain mandatory bounded hosted Gemini qualification. [LLM plan item 4](llm-processing-repair-plan.md#4-qualify-extraction-then-cognitive-maintenance-and-the-agent-handoff). QE-09 measures retrieval quality separately. |
| RAG-QA-03 | Open | Installed Linux replay and non-macOS release/fault coverage, including filesystem/disk-full behavior. [Integration issues](integration-issues.md#installed-linux-replay), [process cases](qa-process-cases.md). |
| RAG-QA-04 | Open qualification boundary | General malicious-source/prompt-injection behavior is not established by the bounded MCP trials. Preserve untrusted provider/evidence and authorization boundaries; scope any future adversarial qualification explicitly. [MCP trials](mcp-soak-trials.md). |
| RAG-PERF-01 | Open | Measure long-ledger reservation/admission, census, lock duration, backup and vector loading/rebuild separately. Recent indexed scans and shared transaction-start retries are implemented; eight/sixteen-worker runs do not establish unlimited scaling. HC-07, REL-008 and QE-09 share this evidence. |
| RAG-RET-01 | Proposed | Retention of bulky resolved payloads with compact outcome/lineage/usage audit, respecting recovery and evidence dependencies. No purge implemented. [Retention follow-up](reliability-coverage-review.md#proposed-retention-follow-up). |
| RAG-EXP-01 | Proposed research | Source expansion and controlled graph-value comparison; map retrieval measurements to QE-09 rather than claiming higher claim counts prove better answers. [Scottish development](scottish-corpus-development.md). Reconcile that document's old approval/run language against the later metadata-only decision before acting. |
| RAG-EXP-02 | Optional experiment | Per-support time/provenance assessment is separate from normal document metadata. Broad automatic assessment was rolled back as default; do not reopen it via older proposal wording. [Current contract](time-and-provenance.md), [dated proposal](claim-time-provenance-proposal.md). |
| CREXX-NI-01–06 | Upstream, open | Generic native inference, CPU/GPU, persistent model owner, packaging, artifact identity and qualification. RAG consumes installed capability via QE-04/07/08; no native inference copy in RAG. [Dependency record](integration-issues.md#proposed-native-embedding-capability). |
| CREXX-NI-07 | Upstream, optional | Local generation; not prerequisite to standalone reader/query support. |
| Policy publication boundary | Accepted limitation — agreed 12 September | Custom mode/ACL preservation and policy-file power-loss durability are outside active defect work. Process-default metadata and manual policy restoration after power loss are accepted. Retain validation, staged rename, ordinary process-crash recovery and all SQLite/receipt/usage protections. Non-macOS replacement remains QA-03 qualification. [Integration issues](integration-issues.md#policy-file-publication-metadata-and-durability). |
| Process identity boundary | Lower-priority upstream improvement / qualification limit | Keep process workers and same-account local pruning. A future CREXX check should distinguish alive, missing and unknown/error; unknown ownership must prevent automatic pruning. OS birth identity remains unavailable. No same-account failure was established by this review; changing to threads is not required. [Integration issues](integration-issues.md#local-process-liveness-and-permission-boundary). |
| Interactive input | Recorded upstream repair — installed route verified 12 September | CREXX fixes #670, #669 and #678 are included in installed `5ccf057a1633`. Existing pipe and real-PTY driver regressions both pass after one newline. The stale outstanding label is closed for this installation; retain regression coverage and the normal `--yes` automation path. [Repair history and verification](integration-issues.md#interactive-input). |
| Channel request retention; project-build scaling; attached-provider discovery | Recorded upstream repairs | Retain installed-package regression obligations; do not duplicate as open RAG implementations. [Integration issues](integration-issues.md). |
| RexxScript configuration | Deferred feature choice | Current declarative configuration suffices; no evidence requires an additional executable configuration language. |

## Recommended execution order

The four status/controller/restart repairs are implemented. Start with the
[current qualification](four-smoke-fixes-20260913.md) and
[REG-01](regression-coverage.md#current-status--13-september-2026); preserve the
pre-repair failures and all required assertions. The full and scratch-installed
gates are green; local qualification of these four repairs is complete.

The next separate work is evidence-based content fixtures and profiling
of the census writer section. Retained validation failures are not automatically
product defects. The five missing embeddings are repaired in Test 1. Selected operational
retries remain separate live acceptance. RAG-SMK-006 now has a passing regression,
full gate and installed replay. The next source-import preparation exposed the
prospective configuration guard around inherited paused/uncertain jobs; resolve
that boundary without erasing history, or select an explicitly fresh test library.
Do not resume the expired overnight window from this roadmap.

The [implementation plan](recovery-implementation-plan.md) is the historical numbered
work sequence and records source owners, coverage checkpoints and exit gates.
Use REG-01 before **every** step; it is a standing requirement rather than a
separate step that offsets the numbering.

1. **Completed step 1:** admission pressure, `4500e77`.
2. **Completed step 2:** shared lifecycle and durable retry, `10a91d2`.
3. **Completed step 3:** receipt persistence and usage recovery, `d36db07`.
4. **Completed step 4:** rolling supervision and shared preflight recovery,
   `8e4f5a8`. These are scoped deliveries, not closure of all operational P1s.
5. **Implemented steps 5a/5b:** maximum-page and large-plan repairs under
   UX-02, with ADDRESS/installed boundaries and exact plan-detail access.
6. **Implemented step 6:** Unicode lexical query loss under QE-06, with
   independent citation/index controls. The complete gate and all review
   documentation are versioned; see the current qualification record.

The approved sequence has delivered **UX-03 effect previews** and **UX-04 with
OPS-002 external correction and lifecycle closure**, each with a full 59/59 local
gate. The third slice implements the public diagnostic/recovery journey under OPS-001/003,
including reasoned task waiver; see [implementation and remaining qualification](public-recovery-journey.md).
The third slice passed **59/59 in 1238.52 seconds** and the frozen installed recovery replay. Confirm regression
coverage first and commit only after the full local gate is green at each step.
OPS-005 renewal/continuation is closed on the [coherent operator delivery](operator-continuation.md) and final bounded smoke evidence. OPS-001/002/003 retain the corpus retry acceptance; see the [handoff](operator-continuation-handoff.md). Wider shared
infrastructure recovery and hosted/platform/long-run qualification remain open
under OPS-004 and QA-01/02/03. Claim policy, prompt contracts, query/reporting
services and command metadata now have shared owners. Extend the
lexical seed into QE-09 evidence before ranking/model choices; preserve the
upstream ownership and profile/migration dependencies of QE-04/07/08.

The earlier order left UX-02 movable and grouped Unicode with later query
work. That scheduling gap is corrected above. Broad file movement,
configurable-everything changes and executable splitting remain later choices
that need a demonstrated benefit.

## REG-01 — Regression coverage before implementation

Current increment: four native/public regression cases reproduced the status
and simple-restart gaps before implementation and now pass with the repairs.
Additional scope, startup and parent-identity controls are retained. See the
[current evidence](regression-coverage.md#current-status--13-september-2026)
for full and installed qualification.

Historical first increment: **implemented**, using the existing
Level-G/CMake/native fixture infrastructure. Eight new executable cases cover
public page/row bounds, retry history and terminal parents, a frozen retrieval
corpus and ordinary-ingestion reservation pressure. See the
[executable coverage and remaining acceptance matrix](regression-coverage.md).
Known defects remain ordinary failing tests in the required gate; this does
not close their product requirements or establish exhaustive coverage.
The pre-implementation full run was **36/41 passing**, with all 33 original tests passing
and five identified acceptance failures retained (UX-02 twice, OPS-002,
OPS-004 and QE-06). Step 1 subsequently passes both admission tests and all 33
original checks; the full review run is **38/42 in 493.45 seconds**, with the
four UX-02/OPS-002/QE-06 failures still visible. See the
[admission repair record](admission-recovery.md). Step 2 qualification is recorded
in [lifecycle recovery](lifecycle-recovery.md): **42/45 passing in 554.81 seconds**,
with all 38 scoped tests green and only the two UX-02 cases and QE-06 Unicode
case remaining red. Later step 3 reached **43/46** and step 4 reached **45/48**
with those same three failures. These are historical checkpoints; the
[current coverage status](regression-coverage.md#current-status--13-september-2026)
records the latest full run and fresh focused confirmation.

Run the complete gate with `cmake --workflow --preset regression`. Hosted calls
are not part of ordinary regression execution.

The first deliverable is a risk-based acceptance matrix and executable baseline:

| Coverage area | Required observable checks |
| --- | --- |
| Data and publication | Unchanged ingestion/configuration is a no-op; source bytes, spans, graph history and vectors survive failure; incomplete replacements cannot displace a complete baseline; committed work is not repeated after projection failure. |
| Task/job/window lifecycle | Start, pause, drain, cancel, close and continue; failed tasks under each relevant parent state; retry requests and repeated requests; retain durable history while allowing the agreed loss of an unfinished in-flight task. Cover OPS-002's closed-window case explicitly. |
| Receipts and accounting | Before submission, after receipt, before/after settlement and publication; exact and conflicting duplicate receipts; unknown outcomes; actual usage versus reservation; no repeated paid request for durably retained output. |
| Worker and environment failure | A bad task, failed worker and shared outage have distinct effects; healthy peers continue; controller restart replaces runtime ownership while preserving durable history; temporary reserved capacity differs from total budget exhaustion. Rolling replacement and shared preflight recovery now have native/VM acceptance; renewal and wider infrastructure qualification remain separate. |
| Public surfaces | Equivalent CLI/JSON/MCP/ADDRESS semantics where supported; maximum pages including cursor overhead; large individual records; meaningful previews; complete externally driven correction/recovery. Preserve the reproduced 99/100 review-page boundary. |
| Retrieval and evidence | Frozen representative questions and independently identified evidence; direction, citations, ambiguity, absent answers, Unicode/OCR names and embedding compatibility. Seed QE-09's broader comparison without assuming current rankings are the oracle. |
| Installation and bounded load | A fresh installed package performs the supported journeys without source-tree access; deterministic concurrent requests and a bounded longer ledger/load case retain exact semantic/usage assertions. Keep multi-hour, hosted and platform qualification explicitly separate. |

Distinguish three kinds of evidence: passing tests for supported guarantees;
failing reproductions of known defects; and proposed acceptance for behavior
that does not exist yet. A known bug must not become the asserted desired
behavior merely to keep the suite green. Record any expected failure explicitly
against its issue, require the failure to be the intended one, and remove that
designation when the repair passes. Setup errors are not defect reproductions.

For each prioritized historical failure, retain its trigger, expected outcome,
owning component and a named executable case. Use deterministic rendezvous and
independent state/call-count assertions rather than timing guesses or success
messages alone. Include normal alternatives so tests do not merely mirror the
patch. Existing fixed REL cases remain in the required regression panel.

REG-01 is ready when the prioritized matrix has no unexplained coverage gaps,
the baseline's passing results and known failing reproductions are repeatable
on an identified artifact, and one documented command runs the required gate
and retains failures. Agree unresolved product-policy expectations explicitly;
do not invent them in a test. This is not a promise of exhaustive coverage.
Subsequent work begins by making its specific acceptance test fail, implements
the smallest change, and then runs the affected panel and required full suite.

For future updates, change the consolidated status here and link the exact
implementation/acceptance evidence. Keep dated incident reports append-only in
meaning. Do not infer completion from a test count, a successful provider call,
an implementation commit, or a related repaired ID.

## Current delivery boundary

The approved next outcome is “An operator can continue interrupted Scottish
processing, understand every hold, and finish ingestion and maintenance through
ordinary commands.” It includes the known functional remainder across OPS-001,
OPS-002, OPS-003 and OPS-005 and composes the existing OPS-004 supervision rules.
The [continuation record](operator-continuation.md) and [handoff](operator-continuation-handoff.md)
track implementation, full regression gate, commit and real-corpus run separately.
A missing command or incorrect retry rule is unfinished implementation, not
“complete subject to smoke”. Closure counts must reflect that distinction.

### Live continuation finding — RAG-SMK-001

Active submitted calls were included in aggregate uncertainty, and active-item
guidance prematurely recommended reconciliation. A failing public regression
precedes the repair in the existing usage/query owners. Candidate 8 separates
active unsettled from held unknown outcomes while retaining the old total;
full QA passed **63/63 in 933.50 seconds**, and its installed CLI/MCP
confirmation passed. See [the finding](recovery-defects.md#rag-smk-001--p2-active-calls-displayed-as-reconciliation-holds)
and [current run state](operator-continuation-handoff.md). This is an OPS-003
operator clarity defect; do not mistake it for five new failed calls.

### Live continuation finding — RAG-SMK-002

One live worker exited9 after a UTF-8 decoding panic. Its held turn and usage
were preserved while seven peers continued. Test-first reproduction found
per-read text decoding in the Codex adapter unsafe for split multibyte
characters; malformed bytes also escaped the provider boundary. Both VMs and
optimization modes now pass byte-framed decoding/error containment tests.
Packaging and full QA passed **63/63 in 938.12 seconds**. The ordinary
drained-worker upgrade/recovery then completed the original ingestion queue
with exit 0 and no further decoding panic. This P1 is recorded in [the defect register](recovery-defects.md#rag-smk-002--p1-codex-byte-stream-decoding-can-terminate-a-worker).

### Live maintenance finding — RAG-SMK-003

The first real maintenance window failed with sustained writer contention.
The review-hold query performed a full review scan for each pending task;
corpus-copy profiling and a temporary index reproduced and isolated the cost.
The narrow additive schema-17 repair passed full63/63 in 847.44s, including
installed qualification. The repaired fixed 60-minute window now passed with
exit 0 and 56m55s actual worker runtime; nine batch transitions had no terminal
heartbeat failure. RAG-SMK-003 and OPS-005 are closed on this evidence.
OPS-001/002/003 retain the concrete remainder in the final smoke report. Turray's actual external reviewed connection and retirement
journey has now completed, closing that named repeat; retained paid retry
ceilings and corpus evidence holds remain explicit.

RAG-SMK-004 (P2, OPS-003) is repaired: public status distinguishes registered,
confirmed-live and unverified workers through shared process observations.
`regression_smoke_stale_workers` passes through CLI/MCP with live, stale-but-alive,
confirmed-missing, empty, remote and PID-zero controls. See the
[incident evidence](recovery-defects.md#rag-smk-004--p2-job-status-calls-stale-registered-workers-live).

RAG-SMK-005 (P2, OPS-003) is repaired: status, bounded job listing, report counts
and report cache validation use the same lifecycle rule.
`regression_smoke_terminal_state` passes with running, intentional-pause,
unknown-outcome and completed-job controls and an unchanged SQLite dump.
See the [incident](recovery-defects.md#rag-smk-005--p2-final-public-job-states-disagree)
and [current qualification for both fixes](four-smoke-fixes-20260913.md).
