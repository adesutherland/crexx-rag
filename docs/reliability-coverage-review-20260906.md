# Reliability and use-case coverage review

> Historical record of the 6 September baseline and held hosted run. The
> [current repair register](reliability-coverage-review.md) supersedes the status
> labels below. The original assessment and incident evidence are retained.

Review completed 6 September 2026 against baseline `e369449` and the subsequent
repair recorded in this commit. This is a qualification record, not a release
approval. After the final 26-test pass, the user explicitly requested a baseline
commit and another bounded maintenance attempt. That attempt resumes the held
Scottish job with its remaining original limits and two workers; it does not
close the unattended-operation gaps below. Concurrent operation is required;
a single-worker run does not close any concurrency requirement.

## Finding

The original 24-test pass was insufficient evidence for unattended, concurrent,
long-running maintenance. The tests contain useful storage, provenance and
provider assertions, but those assertions do not collectively prove the complete
operator lifecycle. In particular, `ProcessWorkers.cmake` observes two **idle**
workers, and `DurableBacklogProvider.cmake` originally executes one maintenance
item with one worker. The native packaging smoke has the same idle-worker
limitation. Calling those checks concurrent maintenance qualification was wrong.

The live run exposed a request-contract mismatch and publication races. The
generic resolution schema offered alias-only actions to note tasks. Manifest
writers shared `manifest.json.new` without publication ownership. Extraction
completion promoted mentions and claims in separate transactions before marking
the work item complete. A late failure could therefore leave partial knowledge
changes, and retrying the item could request another paid answer.

SQLite integrity alone cannot establish recovery: source bytes, embeddings,
membership, evidence links, published generation, manifests, query results,
durable work and usage must be checked together.

The [operator process acceptance cases](qa-process-cases.md) turn this matrix
into explicit starting states, interruptions, expected outcomes and recovery
steps. They identify which sequences are executable today and which remain
qualification work.

## Required operator outcomes

1. A completed item has one accountable result and complete provenance. A
   rejected item cannot leave an unreported partial publication.
2. Multiple workers make provider requests concurrently. Short SQLite write
   transactions serialize publication without serializing network calls.
3. A process can stop at any boundary. Recovery preserves committed facts,
   prevents stale workers from publishing, and distinguishes recovered work from
   a new paid attempt. A response lost before durable receipt is explicitly
   uncertain; it must not be described as exactly-once external execution.
4. Pause, drain, cancellation, deadline and budget exhaustion have distinct,
   inspectable outcomes. None means "all requested work succeeded".
5. Configuration changes preserve existing source and derived-data identities
   unless an explicit compatible transition requires new derived work.
6. Query access uses a coherent published view. Losing a derived file cannot
   destroy the authoritative source or embedding representation.
7. Backup and restore produce a usable, independently verified library with its
   history, provenance and compatible indexes, including after interruption.
8. Operators can explain every requested item and every accounted call without
   reconstructing the result from private scripts or misleading success codes.

## Coverage against use cases

"Partial" means assertions exist, but the stated end-to-end failure boundaries
have not been proved. It does not mean the behavior is known to work.

| Use case / invariant | Existing executable evidence | Gap / required additional proof | Gate |
| --- | --- | --- | --- |
| Concurrent maintenance publication | Idle process launch/drain; sequential backlog scenarios; new forced native request pairs | Combined extraction/lifecycle/readers, interruption and long-duration proof remain required | Critical, focused pairs pass; combined gate open |
| All-or-nothing extraction item | Strict adapter validation; exact four-mention/two-support ingestion result; new late rejection and injected SQL failure | Same atomic contract must cover the older single-proposal path and interrupted completion | Critical, batch cases pass; full gate partial |
| Task-specific resolution contract | Note/alias/connection/conflict/gap schema checks; invalid action rejection; native note resolutions | Replay captured provider outputs across the full applicable action/context combinations | Critical, scoped fixtures pass; matrix partial |
| Worker death before claim / during call | Expired leases, stale PID pruning, controller child failure | Real process kills at each publication/settlement boundary with another worker continuing, then restart | Critical, partial |
| Settled response survives process death | Codex completed-turn crash fixture; durable resolution cache across leases/windows | Gemini extraction and embedding settlement do not have the resolution cache's recovery proof; generic paid-result replay must be audited and tested separately | Critical, open |
| Fences prevent stale publication | Claim, reservation, cancellation and stale-resolution checks | Expire/reassign a lease while a full extraction batch is preparing, then attempt publication from the old worker | Critical, partial |
| Pause, drain, resume, cancel | SQL state scenarios and real idle-worker drain | Busy native workers, in-flight provider response, bounded shutdown, subsequent public recovery, truthful final exit/status | Critical, partial |
| Item/call/token/cost/deadline ceilings | Reservation, provider admission, query-policy and bounded window scenarios | Simultaneous workers at each last-unit boundary; actual usage vs reservation reconciliation after crashes and cancellations | Critical, partial |
| Long nightly window and durable backlog | Manual/supervised/automatic scenarios, cursors, dedup, retry caps, follow-up tasks | Multi-wave concurrent soak with unchanged evidence, mixed failures, restart and exact terminal accounting; no repeated paid reconsideration loop | Critical, partial |
| Split / merge / connection reassignment | Both-VM lifecycle and backlog scenarios cover mentions, aliases, individual supports, notes, ambiguity and conflicts | Concurrent lifecycle changes with extraction and queries; interruption during fan-out and before retirement | Critical, partial |
| Configuration without recompilation | Plan/digest checks, operational/prospective transitions, no-op corpus regression, exact table preservation | Cross-product of active/paused/settled work and each identity class; new embedding representation must preserve old source/history and query baseline | Critical, partial |
| Sidecar deletion/corruption/rebuild | ANN and public query fixtures remove/corrupt indexes, check zero calls and exact rebuilt checksum | Concurrent rebuild/publication; interruption at install/SQLite/manifest boundaries with readers; preserve previous complete publication | Critical, partial |
| Query access while maintenance runs | Directional retrieval, stable citations, graph-only index reuse, old-ancestor checks | Continuous readers during real concurrent publication, writer kill and recovery; coherent source/span/index generation | Critical, open |
| Backup/restore under load | Public completed-library backup/restore; pinned SQLite snapshot implementation | Concurrent writers during backup, interruption at each staging phase, missing historical shadow, restore plus query and exact source/vector preservation | Critical, partial |
| Storage / filesystem failure | Missing/corrupt sidecars and bounded negative fixtures | Inject failed SQL writes, failed manifest writes/rename, full destination, permission error and incomplete backup; previous usable publication retained | Critical, open |
| Malformed/untrusted provider output | Gemini malformed/type/span negatives, redaction, answer-citation rejection | Separate genuine model rejection from transport, publication and recovery defects in operator status; replay captured real responses across task kinds | High, partial |
| Provider throttling and privacy | Shared admission, Retry-After/backoff, route classification and query-policy tests | Concurrent timeout/429/cancellation while reservations expire; prove no uncalled failure is charged or silently treated as successful work | High, partial |
| Operator status and audit | JSON/NDJSON/MCP/ADDRESS surface tests; replay lineage; snapshots/trends | Assert all terminal result meanings and item/call reconciliation, including completed-with-errors, held windows and cancelled unstarted items | Critical, partial |
| Full-volume behavior | Prior Scottish scratch preservation/rebuild/query evidence | An executable, repeatable full-size qualification protocol with bounded cost and restart/fault points, tied to the exact candidate | Critical, not qualified |
| Platform/install identity | Native local fixtures, scratch installed-product test, both interpreters | Named platform gates and identical qualified/install SHA; macOS results do not establish Linux or an installed release | High, partial |

## Concrete defects and test weaknesses

- **REL-001 / critical:** unowned shared manifest temporary. Reproduced by an
  independent SQLite connection holding an IMMEDIATE transaction while another
  publisher writes successfully. Fix under test: acquire SQLite write ownership
  before reading the latest projection and retain it through rename.
- **REL-002 / critical:** extraction batch publication is fragmented across
  per-mention/per-claim generations. Fix under test: stage and validate the whole
  batch, including fence and completion, in one generation/transaction. Mention
  savepoints preserve the supported alias-question path without retaining a
  failed mention prefix.
  This repair covers the discovery-batch path. `runworkeronce` also retains a
  single-proposal path with separate candidate promotions; that path needs the
  same atomic completion contract before the all-work-kind claim can close.
- **REL-003 / critical:** resolution request schema is not task-specific. Fix
  under test: derive the permitted action enum from subject/workflow and enforce
  the same applicability during normal validation. Runtime prompting alone is
  insufficient structural assurance.
- **REL-004 / critical:** successful provider accounting is not evidence of
  successful publication. The original native backlog fixture checked only
  failed provider runs after ingestion, allowing a later dead-lettered item to
  escape that check. The fixture must also assert terminal item states and
  semantic contents.
- **REL-005 / critical:** response recovery differs by work kind. Resolution
  JSON is persisted with settlement in `maintenance_provider_outputs`; general
  extraction/embedding results are held in the worker result object. The hard
  review must not generalize the Codex/resolution recovery tests to all work.
- **REL-006 / critical:** no end-to-end crash/fault matrix covers simultaneous
  maintenance, readers and backup. The required boundaries are listed below.
- **REL-007 / critical, reproduced and repaired candidate:** `rollbackgeneration` renamed the
  rollback manifest before rebuilding FTS, updating the SQLite generation
  pointer and recording/committing the event. A later SQL failure can leave the
  file describing a rollback that SQLite rejected. SQLite retains its prior
  committed data, but manifest coherence and uninterrupted access are not
  guaranteed. `rollback-before-fix.log` reproduces the exact stale-manifest
  failure with an injected pointer-write rejection. The repair commits SQLite
  before projecting it; failed and successful rollback checks pass on both VMs
  in `recovery-process-focused.log`. This closes the rejected-SQL ordering
  defect, not the separate crash-after-commit recovery matrix. It was not a
  reproduced live incident.
- **REL-008 / high, repaired candidate:** vector building keyed replay only to
  the current semantic generation, rebuilding after a graph-only publication.
  The candidate proves ancestral membership compatibility and compares the
  complete deterministic payload before reusing the original index identity.
  Training is still performed for that comparison; this is not a claim that
  large-index no-op CPU cost has been eliminated.
- **REL-009 / high, repaired candidate:** observation verification demanded
  exact vector/observation generation equality, contradicting supported
  ancestral index reuse. The new native verification assertions exposed this.
  Verification now requires published ancestry and identical source/embedding
  membership for the specific recorded index; a later compatible index does
  not erase a valid historic observation. The check is not bypassed.
- **REL-010 / high:** operator documentation generalized resolution response
  recovery to all work and equated a 24-test pass with implementation readiness.
  Those claims are corrected and linked to this review. Configuration guidance
  must also distinguish prospective interpretation from explicit corpus work.
- **REL-011 / critical, reproduced:** cancellation during an admitted call
  caused `settlecall` to reject the returning usage as cancelled. The item stayed
  pending cancellation, no provider run was recorded, and its reservation
  remained open. `cancellation-before-fix-2.log` reproduces all three failures
  using the normal worker and cancellation APIs at a deterministic boundary.
  The repair separates settlement authority from publication authority and
  acknowledges cancellation only after reservation settlement. The normal
  worker/API interleaving now passes on both VMs in
  `cancellation-recovery-focused.log`: no graph publication, one accounted call
  for the cancelled attempt, no remaining reservation and terminal cancellation.
  This is not a real busy-native-process kill test. The earlier
  `cancellation-before-fix.log` contains a fixture
  compile error and is not reproduction evidence.
- **REL-012 / critical, code finding:** late/oversized actual usage remains a
  separate accounting gap. Settlement rejects expired fences and usage above
  the reservation before recording the result. Recovery must preserve the
  external usage fact, even if the worker no longer owns publication or the
  provider exceeded its allowance. The cancellation repair alone does not
  establish that ledger guarantee. Tests must cover late receipts after lease
  reassignment, actual usage above the admitted estimate, and duplicate receipts
  without permitting a stale worker to change knowledge.

## Priority and ownership

These are RAG orchestration, repository and qualification issues. No current
finding justifies moving policy into native code or blaming the SQLite provider
or compiler. The repair uses Level-G cREXX; the C++ file is the existing test
HTTP fixture. No Python product or test source is introduced.

| Order | Work package | Required acceptance evidence |
| --- | --- | --- |
| 1 | Complete transactional publication and result recovery (`ragwork`, `ragclaims`, `ragstore`) | Every extraction shape, resolution and embedding: fail after an earlier mutation, preserve prior knowledge, settle usage once, recover a durably received result without a second external call, and reject a stale fence. Distinguish a committed item whose manifest needs repair from an uncommitted item eligible for retry. |
| 2 | Crash, cancellation and resource-boundary matrix (`ragprocess`, `ragbacklog`, provider admission) | Real busy worker death/drain/cancel; another worker continues; restart through public commands; final call/token/cost/turn ceilings and reservations reconcile. Include the final available call/token/cost unit and deadline. |
| 3 | Coherent readers, vector rebuild and backup (`ragproduct`, `ragembedding`, `ragbackup`, `ragrepository`) | Query during writes and injected interruption; rebuild a deleted/corrupt shadow from SQLite; backup under writers, restore into a new library and query it. Compare complete source/vector tables and retained histories. |
| 4 | Bounded full-volume and long-duration qualification | Exact candidate on a full Scottish copy, multiple dispatch waves and mixed decisions, recorded restart/fault points and stable memory/queue progress. Then a separately bounded hosted run using the authorized remaining limits. No earlier gate may be inferred from this run alone. |

An operator-visible outcome must separate: successful publication; valid
uncertainty; human review required; provider-output rejection; transport failure;
publication failure before commit; committed result needing projection repair;
budget/deadline stop; and user cancellation. For each, tests must assert the
public exit/status, durable item/attempt state, usage, allowed recovery operation
and whether a new paid call will occur. A controller finishing is not proof that
all items succeeded. The native injected-failure fixture deliberately produces
one dead letter despite successful provider accounting and controller exit.
Publication authority and accounting authority are distinct: a cancelled or
expired worker must not publish knowledge, but a verifiable admitted provider
receipt must not disappear from usage history. Reservation limits control new
admission; they cannot make already incurred external work cease to exist.

## Qualification protocol

For each critical row, record the exact candidate SHA or dirty-tree diff digest,
native hash, configuration, library snapshot, trigger, expected outcome, actual
outcome and evidence path. A test must fail on the defect it is intended to
detect; a fixture setup error or a permitted review is not that proof.

Use deterministic rendezvous and injected failures. Cover: before provider
admission; after request admission; after durable response/usage settlement;
after staging the first graph mutation; before SQL commit; after SQL commit
before manifest publication; after temporary file write before rename; after
rename; and during final vector/backup publication. At every boundary verify
source/vector bytes and membership, history, graph/span consistency, item and
attempt ownership, reservations, accounted calls, recovery behavior and a
provider-free retrieval query.

The native concurrent provider fixture must hold the first response until a
second independent worker request arrives. Merely passing `--workers 2`, relying
on a sleep, or observing two PIDs is insufficient. The workload must include
extraction and resolution publications, multiple dispatch waves and lifecycle
follow-ups, with a reader observing coherent generations. The current added
fixtures establish overlapping extraction and resolution separately; they do
not yet establish simultaneous lifecycle follow-ups, readers and backup.

Each failure fixture must identify its boundary with an observable rendezvous
or injected storage failure. A polling timeout bounds a missing event; it must
not be used as proof that the intended race occurred. Persist bounded request
and response identities, deterministic seeds, SQL/event censuses and native
hashes so a failed long run can become a small replayable regression.

The intended QA layers are: the maintained local smoke suite; required bounded
concurrency/fault tests for relevant changes; a zero-outbound multi-hour soak;
and full-size/installed/platform qualification. The latter three are release
requirements, not claims that those CI lanes already exist. Set explicit time
and resource ceilings and retain the failure artifact on timeout. Count closed
operator invariants and exercised failure boundaries, not test names or line
coverage percentage.

Run focused regressions, then the full maintained suite. Run a bounded full-size
copy qualification after those pass. The live 5,000-item test can resume only
when the critical publication/recovery gates for that path are demonstrably
closed; it must not be used to discover repeated paid infrastructure failures.

## Current boundary

The baseline is committed, but the 5,000-item concurrent run has **not** completed
and is **not** qualified. The repair is uncommitted and not installed. Live
workers are stopped; the pre-run backup and all incident evidence are preserved
under `/Users/adrian/testrag/maintenance-durable-5000-20260906/`. Passing newly
added tests does not close the remaining partial/open rows above.

## First qualification checkpoint

Candidate native SHA-256:
`4bb760affb267cecfa8728b19340f87aec4960db9b3972f4e59f9fed8bc2c2d3`.
The source remains an uncommitted repair of `e369449`; it is not the pinned
executable that ran against the live library.

All **26 maintained tests passed**, zero failures, in 161.02 seconds.
`git diff --check` passed. The suite retains both-VM, Gemini malformed-output
and secret-redaction checks and the scratch installed-product check. The latter
does not install or promote the repair into the operator's environment.
Evidence root: `/Users/adrian/testrag/maintenance-durable-5000-20260906/`.

| Assertion now demonstrated | Evidence |
| --- | --- |
| The committed native baseline publishes a failed extraction prefix | `native-publication-before.log` and `native-publication-before/write_failure/census.txt`: injected claim INSERT failure leaves two concepts/four mentions, despite one dead-lettered extraction. The failure trigger is retained in its scratch library. |
| The repaired native path rolls back that prefix | `cmake-build-debug/test-native-publication/write_failure/census.txt`: zero concepts/mentions/claims/supports, one source/chunk/embedding link, two calls/two attempts, zero reservations, one expected dead letter. Public verification passes. |
| Actual simultaneous extraction requests complete | `cmake-build-debug/test-native-publication/concurrent/`: four source chunks, two native workers, two forced request pairs, eight calls/attempts, two concepts, 16 mentions, one claim/eight supports, zero failed/unfinished items. |
| Actual simultaneous resolution requests complete across bounded dispatch | `cmake-build-debug/test-durable-backlog-provider/concurrent/`: 40 resolutions with 10-item waves, two native workers, 20 forced pairs, zero failed/unfinished items or reservations, unchanged source/vector values and valid final library. |
| Manifest ownership and late semantic rejection | `publication` passes on both VMs; the independent second connection cannot publish while the first owns SQLite's write transaction. Rejected batch leaves no graph prefix and retains its call accounting. |
| Complete maintained suite | `reliability-full-suite.log`; build evidence `concurrency-build-5.log`. Intermediate failed fixture/build logs are retained, not counted as passing proof. |
| Held live library remains usable and preserves source/vector data | `review-held-library-verify.json`: schema 10, generation 5191, aligned manifest, zero repository issues. `review-held-preservation.csv`: exact bidirectional equality of all ten source/embedding tables against the pre-run backup, including 15,153 chunk links and 13,707 BLOBs; integrity ok, zero foreign-key issues. |

Paths beginning `cmake-build-debug/` are relative to the repository; the others
are relative to the evidence root. These fixture outputs are also retained in
the review evidence bundle. The original semantic-rejection fixture selected a
permitted review instead of an error; its early failing output is not counted as
proof. The independent native SQL failure above supplies the valid before/after
comparison.

No hosted calls were made for this repair/review. The live experiment remains
at 268 calls and $0.395655 recorded incremental cost. The corrected window has
191 processed, 24 dead-letter, three skipped and 82 queued items. Stopped
workers are not a completed window. No new retry allowance, schedule, commit,
push or global installation was created for the repair.

**Admission decision: keep long-running live maintenance held.** The new
tests close specific observed defects, but generic paid-result recovery,
single-proposal atomicity, late/excess usage accounting and the combined
busy-worker, reader, backup and budget fault matrix remain open. Full-volume concurrent
qualification of this exact candidate has not been performed. These are
explicit follow-on work packages above, not an assertion that another smoke
pass will resolve them.

## Process walkthrough checkpoint

Following the user's emphasis on a firm QA foundation, the walkthrough added
rejected/successful rollback, cancellation during an admitted call, and a full
public detect/recover/query/backup/restore/verify/query sequence. These exposed
and reproduced REL-007 and REL-011 before their repairs. The cancellation case
exercises the normal worker and cancellation APIs on both VMs; real busy native
process death/cancellation remains a separate unproved boundary.

Final native SHA-256:
`c2e9462eb4f8be74c28ebc985cba22654914454cf77dc4b164184af29e269b59`.
**26/26 tests pass in 136.53 seconds** in `reliability-final-suite.log`, after
the focused checks in `cancellation-recovery-focused.log`. Build evidence is
`cancellation-repair-build-2.log`; the earlier build correctly rejected source
drift during compilation and was not qualified. `git diff --check` passes.

The final binary is pinned as `bin/crexxrag-reliability-final`. Tracked product
and test changes are retained in `reliability-product-tracked.patch` (SHA-256
`b7aca87feb632fa1707f5b23b920b06d7a03b85b251db00366d305a5b90accab`),
with all changed/new product and test file hashes in
`reliability-source-hashes.txt`. New fixture sources are copied to
`review-source/`; final process outputs are retained in
`process-fixtures-final/`. These paths are relative to the evidence root.

Rollback now projects committed SQLite state. Cancellation records returned
usage under the still-valid settlement fence, prevents result publication,
releases the reservation and acknowledges terminal cancellation. A missing
manifest after terminal work is detected and recovered using public commands;
both the recovered and restored libraries answer lexical evidence queries
without provider calls, retaining vector BLOBs, memberships and usage.

The admission decision is unchanged. The next foundational work is generic
durable provider receipts/replay and late/excess-usage accounting, followed by
the remaining publication and combined process fault matrix. Live workers
remain stopped; no new paid calls or library mutations were made during these
walkthroughs. Repairs remain uncommitted and not installed.

## Committed baseline and bounded hosted reattempt

The user subsequently requested a baseline commit and a maintenance attempt.
Commit `dfe25ed23e70a94302279dc17d66f8f50beb026e` contains the qualified repairs
above. Source hashes and the final native hash were rechecked before committing;
the same pinned executable ran two native workers. There was no push or global
installation. A fresh generation-5191 backup passed full public verification
before the existing job resumed, retaining its original remaining limits.

The continuation ran from 20:33:35 to approximately 21:21:57 UTC on 6 September
2026. It processed 2,074 additional items, rejected 751 attempts and skipped
112 items. There were 2,825 new provider calls costing $5.049311. No recurrence
of the earlier manifest or expected-parent publication races was recorded.
The rejection count includes the lifecycle defect below; most other rejections
concern quotation grounding. These are not 2,074 fully resolved knowledge
questions: processed outcomes include explicit unresolved/investigate decisions.

Both workers were drained when the new lifecycle defect was identified. The
current window is held at 2,265 processed, 775 dead-letter, 115 skipped and
45 queued; it dispatched 3,200 of its 4,900 items. Including the first window,
the experiment dispatched 3,300 items and used 3,093 calls / $5.444966. The
5,000-item run is incomplete. All OS workers/controller stopped and all
reservations settled. Controller exit 8 reports that the deliberately held job
is still running; it does not report successful terminal vector publication.

The held library passes full public verification at generation 7024 with zero
issues. All ten source/embedding tables match the pre-run backup in both
directions, retaining 15,153 embedding links and 13,707 vector BLOBs. SQLite
integrity and foreign keys pass; the manifest is aligned. Evidence is retained
under `reliability-resume-*` in the experiment directory named above.
A fresh stopping-point backup at
`/Users/adrian/testrag/library-backup-scottish-full-reliability-stop-gen7024-20260906`
also passes full public verification with zero issues and retains the complete
checksum-matched vector sidecar. All earlier backups remain untouched.

### REL-013 / high, open: extraction identity during a merge workflow

Live event 145764 at 21:19:40.592 UTC rejects extraction of the chunk
`Macknights, or Macneits, ii. 231.` with `selected catalogue identity changed`.
Macknights became a `migration-parent` at generation 6912, 21:18:11.547 UTC,
before the failed attempt began. No publication occurred inside that attempt's
recorded interval. This is not evidence of the earlier concurrent manifest race.

`ragbacklog.resolveknownconcept` admits every visible non-retired concept,
including migration parents. The exact lookup for Macknights/organisation
returns both active Macneits and the Macknights migration parent, so it returns
no unique identity. `ragworkmention` then derives the label/type identity, which
is the existing Macknights parent ID. `_stageproviderbatch` accepts that ID by
visibility; `ragclaims._activeconcept` subsequently requires lifecycle `active`
and rejects it. The lookup, fallback and publication contracts disagree.

The database predicate mismatch and fallback hash are independently reproduced
in `reliability-lifecycle-identity-proof.sql` and its CSV output. The generic
Gemini extraction response is not retained, so the exact model mention array
cannot be replayed from this failed receipt; that is the existing REL-005 gap.
The observed chunk/history and deterministic code path strongly support this
diagnosis without recovering the missing response.

Required regression: begin a merge with connections still pending; add the
parent label as an alias of the successor; extract the same source spelling
before and after connection migration, with two workers and a retained receipt.
Identity resolution must follow the reviewed lifecycle/evidence policy or leave
an explicit unresolved task, without reviving/duplicating the parent, losing
evidence, leaving a partial publication or requesting another paid answer for
the same retained receipt. Do not weaken publication validation. This mixed
extraction/lifecycle case remains unqualified and the defect is not repaired in
`dfe25ed`.
