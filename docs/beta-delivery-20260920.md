# Beta delivery — 20 September 2026

Implemented, locally qualified and installed under the [approved plan](beta-release-plan-20260920.md).
The master roadmap owns status. The development candidate is ready for publication;
the beta tag/release is held for the explicit ESC-OPS-06 exception described below.

## Baseline and coverage

Starting source: `789b92107c9630f9a9a0faa248ae3e06c404140a` on `main`.
Existing local review/plan documents are retained. Before product edits, the six
affected controls were selected and their exact-input receipts audited: prompt
inspection, `codex_protocol_noopt_rxvme`, `durable_backlog`, its escalation and
budget cases, and `observability_providers`. All six pass through receipt reuse;
no unchanged product execution was repeated. Machine report:
`cmake-build-debug/beta-baseline-receipts.json`.

Coverage gaps to close before implementation: premature deadline versus healthy
delayed completion and explicit limiting-clock diagnosis (AC-1/2); settled-subject
discovery, meaningful-context comparison and post-application convergence
(AC-3/6); consistent restore/synonym preconditions and positive controls (AC-7).

## ESC-OPS-06 investigation

The retained failed item was claimed at 08:02:36.844 UTC, submitted at
08:02:37.429, and failed at 08:02:50.899. Claim lock wait was zero and its body
2 ms. The restored Scottish configuration specifies a 300-second lease and
120-second provider timeout. These values and the effective run configuration
must be reconciled with the adapter's shared operation clock before assigning
the cause. The old receipt remains incomplete usage, with confirmed interruption.

Both the actual temporary run policy and restored policy specify the same
300-second lease and 120-second provider timeout. The claim started 0.585 seconds
before the request; claim lock wait was zero/body 2 ms. These facts do not explain
a 13.47-second timeout. The adapter uses a wall-clock microsecond timer and
shares its remaining allowance across preflight, setup and reads. Controlled
healthy delayed operations and notification traffic have not reproduced the
historical early expiry. A clock adjustment remains a hypothesis, not a diagnosis;
the narrow retained host-log query provided no supporting event.

A separate short-lease fixture did reproduce a recovery defect: a seven-second
claim reserves five seconds for cleanup, but outcome inspection subtracted that
reserve again. Its resulting one-millisecond inspection failed, leaving lease
expiry instead of confirmed interruption. `ragapplicationprovider` now uses the
reserved interval for inspection. This repair does not explain the original
300-second-lease incident. ESC-OPS-06 remains a release gate unless its cause is
established or Adrian explicitly accepts a beta exception.

New requests retain configured timeout, effective budget, provider/claim-lease
limiter, local-wall-clock start/elapsed and claim expiry. Deadline failures retain
phase and elapsed operation time. Limits/restart counts are unchanged.

## Targeted fail-first evidence

- Initial `durable_backlog_reconsideration` failed the changed-source/non-sparse
  discovery assertion (`20260920T123145-b3d3ba9c`). The first implementation passed
  both VMs in 5.52 s; existing split/merge/core acceptance passed in 9.47 s.
- `regression_prompt_inspection` failed absent lifecycle instructions
  (`20260920T122333-110a6f8f`), then passed after the shared contract repair.
  `lifecycle_methodology` positive/negative graph controls passed in 6.89 s.
- `observability_providers` first established missing deadline context
  (`20260920T122644-1f335178`), then the genuine short-lease inspection failure
  (`20260920T123313-504870f8`). Final repair acceptance is recorded below.
- Expanded healthy/noisy `codex_protocol_noopt_rxvme` passed in 12.47 s. Remaining
  VM variants are included in the final complete gate.

All run directories are under `cmake-build-debug/qa/runs/`. Test-fixture mistakes
(trying to parse a paged request as complete JSON, duplicate lease setting,
canonical-label-only collision without an alias, and an invalid six-month SQL
date) were corrected; they are not product defects or green acceptance.

## Implemented boundaries

`ragbacklog` now pages settled concept/closed-alias leaf questions, compares local
meaning/source/connection context and records post-decision fingerprints using
existing history. It retains immutable provider input and decisions, predecessor
links, advanced routing and operator holds. The legacy path compares retained
evidence and accounts for own applied actions without mass resets. Relationship
fields never recorded by older tasks are baselined at first visit; historical
changes to those absent fields cannot be reconstructed. Read-only query behavior,
source-only windows and structural follow-up ownership remain unchanged.

Shared prompts state the existing retired-restore and active-alias collision
preconditions; validators remain authoritative. Candidate qualification, copied
corpus acceptance, installed identities and publication are recorded below only
once they complete.

## Stable focused acceptance

Final targeted candidate: `durable_backlog_reconsideration` passed on both VMs
in 4.21 s; `observability_providers` passed in 22.02 s; captured public prompt
contract passed in 35.59 s. The latter two share run prefix `20260920T130141`.
The reconsideration case additionally covers six-month deferral, active waiver,
advanced successor routing, legacy reuse/distinct, applied-synonym convergence,
complete packet limits and six late subjects reached through one-item pages
without provider calls. The original split/merge, external-review, task-reset,
source-scope and parallel-worker controls remain part of the required full gate.

The expanded tests caught two introduced errors before delivery: uninitialized
output variables in the bounded connection reader and deadline metadata attached
to a non-timeout disconnect. Both were repaired; the controls remain. A missing
accepted-candidate row in the new distinct fixture was also corrected.

`out/beta-20260920/query-plans.txt` confirms endpoint indexes, indexed support
lookup and indexed assessment-event lookup. Sorting applies only to selected
local rows. Public Scottish backup and restore completed at generation 29928;
copy policy publication and operational configuration activation succeeded.
No live provider call had been made at that phase. Full regression then started
after the candidate stabilized; exact-input retained passes are accounted below.

The first full-gate selection stopped at `durable_backlog_recording`: its older
fixture expected a successful type correction itself to enqueue the next task.
The new approved finality contract deliberately prevents that. The fixture now
asserts that own publication stays settled, introduces a new direct mention,
and retains every original worker/public-validator, generation, source, receipt,
usage and review assertion for the repeated-correction defect. No validator or
refusal expectation was weakened. The gate resumes using exact-input receipts.

## Complete local qualification and hosted regression

The resumed formal selection completed **133/133** cases in **718.37 seconds**:
104 fresh executions and 29 retained exact-input passes. The first selection's
74.87 seconds and its fixture failure remain recorded above; it was stopped,
not counted as a green full run. A stronger timer-reset assertion then required
four healthy operations to exceed a single operation's allowance; only the four
changed protocol variants reran, all passing in 14.24 seconds. Documentation was
checked separately after its wording update. The current-input audit accounts
for **133 passed, zero failed/disabled/not-run**, in
`out/beta-20260920/qa-report.json`. No scale lane or new endurance claim is made.

Qualified native SHA-256:
`a4e3e5ea10c5bc302a10cff9514fad5cdfc20e9c17dfa76ea8f3cd8c91e58f5b`.
Linked SHA-256:
`201af19248498682d5d3c298bba0238f3ea32be971a2d5b4f01b40a41b8c96f7`.
The scratch-installed executable matches the qualified native artifact.

Two live public-synthetic Gemini calls passed with one attempt each: generation
252/68 input/output tokens and embedding 7/0 tokens, dimension 768. Estimated
total cost is **USD0.000246**, within the approved four-call/ten-minute/USD1 cap.
The earlier machine-CLI syntax refusals made no outbound calls. Deterministic
malformed-output, rejected-grounding and secret-redaction cases also passed.

## Bounded Scottish copy acceptance

The installed candidate completed the one approved window at its **200-call cap**,
before the fixed 12:35:38 UTC deadline. Activation was 12:20:38; the last item
completed at 12:32:06, approximately **11 minutes 28 seconds**. Four workers,
local BGE, ordinary Luna Low and advanced Sol Medium. The controller exited zero;
all four children stopped cleanly. No extension, restart or second window.

| Result | Retained evidence |
|---|---|
| 200/200 successful calls/items: 89 Luna, 111 Sol | `final-status.json`, two complete `final-items-page*.json` pages |
| 144 distinct selected tasks: 128 resolved, 15 unresolved, one superseded | Final item task-policy projection; calls and tasks are different counts |
| Zero failed calls, dead letters, corrections, replacements, held uncertainty or incomplete usage | Public status diagnostics and controller receipt |
| Zero live ownership and zero reserved calls/tokens/cost/turns | Terminal status; controller stopped, all four workers completed |
| 3,855,793 input / 59,524 output tokens; subscription charging, zero monetary cost | Provider ledger summary; no unknown/unpriced runs |
| 266 admission deferrals made no provider request | 466 worker attempts comprise 200 successful submitted calls and 266 pre-submission cancellations; these are not failed/repeated model calls |
| Copy schema 20, generation 29928 to 29948, zero integrity issues | One final `library verify`; all 36,319 parents retain local embeddings |

All evidence is under `out/beta-20260920/`, including the verified pre-run backup,
copy, configuration, public receipts and `RUN.md`. No copied graph result was
written back to the main corpus. There were no failed provider calls to review.
The sampled multi-attempt item confirms admission deferral without submission;
it subsequently used one successful request, not a correction/replay.

Nine purposively selected decisions cover seven questions, both routes and two
ordinary-to-advanced handoffs. They are examples, not an accuracy estimate:

| Sample | Observed decision and assessment |
|---|---|
| 1 / family / Sol | Final no-change; distinguishes a kinship phrase from a contextual religious category and does not endorse the stored type. |
| 2 / Highlands / Sol | Linked successor after an eligible candidate changed type; retains place-reading versus identity uncertainty. Final no-change, without another live successor in the completed window. |
| 3 / Clanranald / Sol | Individual reading is distinguished from proof of the supplied identity; final no-change. |
| 4 and 7 / boatmen / Luna then Sol | Changed direct context and a competing identity produce a linked question. Ordinary escalation receives a final advanced no-change. Different groups remain uncertain; no forced collective classification or unsupported split. |
| 5 / Culloden / Luna | Reuses the event candidate from the explicit battle wording in an index entry. This supports the occurrence's sense, not an independent historical assertion. |
| 6 and 8 / Macleod of the Lewis / Luna then Sol | Fragmentary personal/dynastic wording leads to escalation and then final no-change; no invented fuller identity. |
| 9 / WATSON / Sol | Distinct speaker is supported by the two attributed speech turns; retains the literal source label without expanding the identity. |

Original immutable inputs and canonical grounded decisions are retained in
`samples/`. All 13 cited passages were compared with those inputs: twelve quotes
are literal substrings; one differs only in whitespace under the existing
grounding normalization. Its retained source span remains inspectable. The
sampled live request also confirms Sol Medium and a 120,000 ms provider-limited
operation budget, with start/elapsed and claim expiry now visible.

The two changed alias decisions leave their existing extraction follow-up tasks
visibly pending, linked to the resolved origin. The earlier Lord of the Isles
split remains `migrating`, with 29 connection tasks; the originating decision is
not reported as finished connection work. No new split/merge happened in this
small window; completed structural follow-up is proved by deterministic QA.
Changed/unchanged, held, legacy and post-action convergence are controlled there,
while this live run used actual predecessor-linked corpus questions rather than
inserting artificial historical sources. It is not an exhaustive census proof.

## Installation and beta disposition

The exact qualified native and linked hashes above are installed in `~/.local`
and `/Users/adrian/Documents/ScottishHistory/tools`. The previous package cohort
is retained under `out/beta-20260920/rollback/`. Installed CREXX remains
`5949ef27efd8`; no upstream source change was made. Installation reused the
qualified artifacts, without rebuilding or repeating product tests.

The main Scottish policy changed exactly one line: the ordinary action summary
now says synonym must not collide with another active concept and restore needs
a retired concept. Public compare-and-publish and exact configuration plan/apply
succeeded, with zero active jobs and no provider calls. Its semantic hash is
unchanged; `config diff` reads `identical`. Policy file SHA-256 changed from
`144f48fade22ab37ab2dbb04bbbe150c7590ef9ba7a8c6ade8bf69fb3f5c3869` to
`0e476e4b755474b0948e0e9de1fde3fe1b8dc7651ea1b8459327ed59419c7ce7`.
Models, local BGE, eight-worker persisted default, budgets and other policy remain
unchanged; the accepted live copy used four workers explicitly.

Installed lexical/graph inspection returned three passages, zero provider calls
and zero gap writes. Main generation remains **29928**, manifest aligned. The
initial unsupported CLI `--version`/`--question` invocations are retained as usage
refusals, not successful smoke checks; identity is verified by artifact hashes
and the corrected documented positional query succeeds.

| Plan acceptance | Disposition |
|---|---|
| AC-1/2 | Controlled deadline/reset/recovery and cleanup-reserve repair pass. Historical early expiry remains unexplained. |
| AC-3/4/5 | New reconsideration case plus source/reset/budget/concurrent-worker controls pass; live linked questions settle. |
| AC-6 | Existing structural migration and retirement controls pass; live pending alias/connection work remains visible. |
| AC-7 | Shared initial/correction prompt captures and positive/refusal lifecycle cases pass; Scottish summary installed. |
| AC-8 | Local 133-case gate, Gemini, copy closeout and installed smokes pass. Beta release remains conditional on the explicit historical-timeout exception. |

**Release recommendation:** publish this qualified development candidate, retain
ESC-OPS-06 as open, and request an explicit exception before tagging
`v0.1.0-beta.1`. The short-lease repair and clean 200-call window do not establish
the old 13.47-second cause. New diagnostics, tested interruption/replacement and
preserved unknown-usage handling reduce the operational impact; they do not
prove it cannot recur. No timeout or restart limit was increased.

Qualification is local macOS only. T7-10 historical host-resumption cause,
RAG-QA-01 wider endurance, RAG-QA-02 unseen-case/health-and-social-care quality,
RAG-QA-03 other installed platforms and RAG-QA-04 broader adversarial-source
qualification stay open. Semantic prompt/profile tuning remains separate.
