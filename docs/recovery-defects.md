# Operational hardening and recovery defects

## RAG-OPS-001 — P1: routine launch and recovery must be product operations

Status: open, high-priority backlog requirement raised by the user on
2026-09-10. Address after the current embedding run; this entry does not claim
that the operational workflow is hardened.

Starting or resuming an approved workload must be a repeatable command using
the already built, tested executable and ordinary configuration. It must not
depend on agent-written Python, SQL edits, generated per-run repair programs,
or rebuilding the application to repair a routine data/configuration state.
Validation must either lead to a supported recovery path or explain the
specific decision that requires operator input. Another blocking check alone
does not close this requirement.

The embedding launch on 10 September exposed an operational configuration
guard that classified a drained, paused extraction job as active. Correcting
that guard required another build after earlier tests. The exact launch path
had not been qualified in advance, delaying the requested processing. The
live launch subsequently used public configuration plan/apply, maintenance
plan/apply and worker commands; that success does not qualify the entire
operator recovery workflow. Broader regression risk remains open because the
user directed immediate live execution before the full suite completed.

The live run also retained one failed item with `cannot begin provider receipt`
after a metered embedding response, while other embeddings continued. Include
this observed receipt-persistence failure in the recovery review; its underlying
cause is not yet established. Inspect durable response/usage evidence before
replay, and require recovery through the public product surface.

Four successive live worker groups also stopped on generic transaction-start
failures. The confirmed replacement gap was classification: those exits were
recorded as generic failure, while the supervisor accepted explicitly recoverable
exits. The generic messages discarded the SQLite result code. The reservation
path also scanned the growing event ledger four times under its writer lock,
and quota deferrals repeatedly reclaimed work before capacity returned.
Candidate 13 adds bounded retries of transaction start only, retains diagnostics,
marks safely settled busy exits for the existing replacement policy, combines
the four ledger scans, and waits for quota capacity. The same real job is being
used for the user's requested eight-versus-sixteen-worker comparison. This is
ongoing live validation; the wider P1 requirement remains open.

The eight-worker interval then added 581 covered chunks and 450 successful
provider calls in 926 seconds, with no new dead letters or worker replacements.
Changing only `worker.processes` to sixteen exposed another mismatch: the
public operational configuration transition succeeded, but each worker still
required the original full configuration hash. The group was drained after
288 uncalled configuration rejections. Candidate 14 permits a difference only
in the worker-count field; provider, profile and all remaining configuration
fields remain exact. The original snapshots and job limits are preserved.
Recovery uses public `job retry` for those uncalled rejections before a fresh
sixteen-worker interval. A configuration error must also be diagnosed once at
the group boundary rather than propagated into hundreds of item dead letters;
include that case in the P1 operator-flow qualification.

Required closure:

1. Review the existing configuration, job, maintenance-window, worker and
   publication state transitions together. Assign each decision and repair to
   its owning cREXX component and reuse its public controls. Consolidate
   conflicting guards and remove superseded workarounds; do not introduce a
   parallel orchestration framework or a second source of job truth.
2. Provide one documented entry point for starting and resuming the requested
   backlog with configured workers and explicit time/spend limits. Repeating
   it must not duplicate a job, provider call or reservation, or reset the
   original deadline and budget. Normal operation must require no build step.
3. Make recoverable configuration, migration, stale-owner, settled-job,
   cached-embedding and sidecar problems diagnosable and repairable through
   the tool itself. Repairs must be bounded, idempotent and auditable, preserve
   corpus history, and leave unrelated paused work alone. Return an actionable
   public command when a separate repair step is necessary.
4. Make the controller continue eligible work after transient provider errors
   or recoverable worker exits, using shared backoff and durable attempt
   limits. If the controller itself stops, provide a supported resume path
   with the same limits. Keep genuinely uncertain paid requests inspectable
   and held; do not silently resubmit them. Show why progress is waiting or
   stopped and distinguish that from an exhausted backlog.
5. Qualify the exact installed executable through the complete operator flow:
   launch, stop, resume, controller/worker interruption, throttling, ordinary
   reader/writer contention, drained paused jobs, configuration transitions,
   cache reuse and final index publication on a representative corpus copy.
   Verify coverage and paid-call accounting, not merely process startup.
6. Have a fresh agent or operator execute the documented commands without
   source edits, bespoke scripts or private database knowledge. Any required
   workaround fails this acceptance case. Run the relevant regression suite
   on the final artifact before claiming closure; retain live-run results
   separately from deterministic test evidence.

Current priority: let the authorized embedding backlog run and address actual
processing failures. Do not turn this requirement into another prelaunch
redesign or delay. Subsequent repairs should be small, justified against the
owning state transition, and remove the need for operational intervention.

## Earlier recovery record

Recorded 2026-09-06 after the Scottish corpus recovery investigation.

Current qualification is tracked in [the reliability review](reliability-coverage-review.md).
The dated results below retain their historical binaries and run states. They
must not be read as the current installation or live maintenance status.
The 7 September baseline repairs REL-001 through REL-020 locally; hosted
nightly soak, installed Linux replay and an explicit staged full-corpus
replacement workflow remain separate unfinished work. REL-014 protects a
complete index against an incomplete alternate embedding representation; it
does not implement a full corpus replacement command.

## RAG-REC-001 — incomplete replacement hides a complete vector baseline

Status: incident trigger and missing/corrupt sidecar recovery repaired in
baseline commit `48e0eee`; all 21 tests pass. A separate
explicit corpus-replacement workflow that stages a replacement until complete
remains open. Operational restoration is not a claim of installed release.

SQLite must contain the source evidence, embedding vectors, identities and
generation membership needed to recreate a vector sidecar. The `.rxvec` file
is a derived index for efficiency, not an independent source of truth. Losing
or rejecting that file must not require paid embedding generation when the
compatible vectors already exist in SQLite.

The incident violated publication availability, not durable vector storage:

- Erroneous semantic reingestion created replacement chunks for unchanged
  source content and advanced the published generation from 4799 to 7068.
- Generation 7068 exposed 15,153 active chunks but only 7,485 linked chunks.
  Its manifest advertised no vector sidecar. One stopped job still had active
  durable state.
- SQLite in the damaged library retained **all 13,707 distinct original
  vectors**, containing 42,107,904 bytes, and **all 15,153 original
  chunk-to-vector links**. The retained vectors match the backup byte for byte,
  including embedding identity, input digest, profile and dimension. Multiple
  chunks can reuse one distinct embedding.
- The older generation-4799 sidecar also remained on disk. Describing the
  vectors as deleted, or the sidecar as the only surviving copy, is incorrect.

The existing `ragembedding.buildannvectorgeneration` loads `e.vector` from
SQLite through generation-filtered `revision_chunk_embeddings` and
`revision_chunks`. It then trains and publishes the derived index without an
embedding-provider argument. This supports the intended architecture, but
rebuilding only the current incomplete membership is not sufficient to recover
the previously complete publication.

Required closure:

1. Prove that an unchanged corpus remains a no-op across prospective
   configuration changes: no replacement chunks, new jobs or provider calls.
2. Keep a complete published query baseline available until an explicitly
   reviewed replacement is ready. Intentional partial initial publication must
   remain distinguishable from replacing a complete baseline with incomplete
   work. Do not mix generations or weaken dimension/envelope validation.
3. Provide and qualify a bounded recovery operation that uses SQLite's stored
   vectors and memberships to rebuild a missing/corrupt sidecar, with zero
   provider calls and no loss of original provenance.
4. Test missing/corrupt sidecars and interruption before publication on scratch
   copies, verify citations and vector retrieval, and prove no paid work is
   inferred from a derived-index failure.

The earlier operational recovery used the complete generation-4799 backup,
preserving the damaged directory. The subsequent operator pass adds public
`vector rebuild` / `rag_vector_rebuild`, missing/corrupt/interrupted-file
regressions, and a hybrid preflight that detects an invalid sidecar before
provider use. Configuration and profile changes now apply prospectively,
without publishing a generation or replacing old chunks. Exact corpus-table
and vector-BLOB preservation is checked on a scratch library.

Machine evidence:
`/Users/adrian/testrag/recovery-20260906/sqlite-vector-authority-audit.json`.
The preserved database is
`/Users/adrian/testrag/library-quarantine-scottish-full-20260906-gen7068`.

## RAG-REC-002 — configuration migration leaves a stale manifest

Status: repaired and qualified in baseline commit `48e0eee`.
Originally observed in the existing uninstalled recovery artifact with
SHA-256 `eafeb2f98fec8913d3abe58b78b7728e5b6a88fcc6130fbe7ad52c188c0e1339`.

Applying a reviewed prospective configuration to a staged schema-8 backup
automatically migrated SQLite to schema 9, but left the manifest at schema 8.
`library verify` returned exit 7, `manifest_state=invalid`, one storage issue
and zero repository issues. The public `library migrate` operation republished
the manifest, after which verification passed with zero issues. Generation
4799 and all 44 compared domain/history tables remained unchanged.

Migration/configuration application must leave manifest and SQLite identity
aligned, or explicitly require and report the remaining migration step before
claiming success. Add a focused existing-bundle regression when the corrective
source is qualified. Do not edit the manifest or migration checksums by hand.

The repair records the pre-open schema version and republishes the manifest
only after a successful automatic migration. The durability regression builds
a schema-8 bundle, opens it through the ordinary read/write path, and checks
schema 9 plus an aligned manifest in both interpreters and optimisation modes.
This does not change migration checksums or weaken manifest validation.

## RAG-MNT-001 — hosted maintenance has an unacceptable exact-span rejection rate

Status: quotation-grounding repair qualified locally; broad hosted maintenance
requires a new bounded hosted qualification of the durable identity and
resolution route.
Observed on baseline `48e0eee`, 2026-09-06, with the Scottish
library and Gemini `gemini-3.5-flash-lite`. The reviewed top-5,000 census selected
4,969 concept reviews and 31 existing analysis leads. It required no embedding
repair or reingestion.

The test was stopped early after widespread rejection, with 76 provider calls:
6 processed items, 7 valid no-supported-claim skips, and 63 dead letters.
Of the failures, 60 were `provider mention does not match its exact evidence
span`, 2 were relationship span/confidence failures, and 1 was a canonical
alias conflict. Recorded test cost was $0.179673. The other 4,893 work items
were cancelled without provider calls. This is an incomplete, failed test,
not successful qualification of a 5,000-item batch.

The durable output reservation was 4,096 tokens, and there were no invalid-JSON
failures in these attempts. The earlier hidden 1,024-token cap therefore does
not explain this result. The observed failure was at the exact byte-span check
in `ragapplicationprovider`. A bounded diagnostic replay captured the mechanism:
`Forbes` was assigned bytes 296–302, which contain `--Forb`, instead of 290–296;
`Culloden` was assigned 339–347 instead of 359–367. This is not a uniform
codepoint/byte-frame conversion error. The model returned incorrect positions.

Providers now return `evidence_quote`. Level-G cREXX resolves exact text first,
then full Unicode casefold, then casefold with ASCII whitespace runs collapsed.
Every result maps to the original UTF-8 bytes. The whitespace pass was added
from retained responses that replaced printed line breaks with spaces, including
`Lord\nMacaulay`. Punctuation changes, ellipses, absent text, missing relationship
endpoints and invalid types remain rejected. Repeats choose the first occurrence
within the chunk; relationship endpoints resolve inside their support quotation.
The response schema enumerates the allowed types and note kinds. Existing
stored chunks, embeddings, configuration snapshots and source-ingest identity
are not rewritten by this protocol repair.

Rejected product JSON is bounded and credential-redacted before storage in the
failed provider run's existing diagnostic field. Malformed or oversized content
is omitted with a digest. Synthetic negative cases prove redaction and preserve
strict graph/evidence rejection.

This failure was already present in the initial load: 7,693 exact mention-span
dead letters; 10,767 initial extraction dead letters overall, with 1,963 processed
and 2,423 skipped items. Source/vector completeness was incorrectly reported as
if it implied complete extraction. Repair/replay uses stored chunks, not document
reingestion or embedding regeneration.

Qualification: all 22 tests pass, including both interpreters and optimization
modes for quotation grounding. One legacy diagnostic call and ten bounded
repair calls on copies cost $0.028613 total. The ten repair calls included three
completed items, three canonical-alias conflicts, and four rejected proposals
while the quotation contract was being corrected. The final two calls passed
quotation validation: one completed, one reached a canonical-alias conflict.
This small result is not successful qualification of 5,000 items.

## RAG-MNT-002 — cancellation after drain leaves a nonterminal job summary

Status: repaired and locally qualified. After both workers drained and all
reservations reached zero,
`job cancel` cancelled the remaining 4,893 queued items but left the job at
`cancel_requested`. `requestcancel` does not call `_refreshjob`, and an empty
worker claim does not refresh it either. Consequently `vector rebuild`
rejected the library as still having an active job.

Operational closure used a recorded, guarded SQLite transaction to reconcile
only this job's state, plus one audit event. It asserted zero active items,
workers and reservations, and applied the existing `_refreshjob` precedence:
`completed_with_errors` because dead letters exist. No item, attempt, evidence
or embedding was changed by that reconciliation. The product now refreshes the
job state inside the cancellation transaction and after expired-lease recovery.
Regression coverage includes queued-only work, a drained paused job, an in-flight
cancelled lease, and dead-letter precedence. No manual SQL reconciliation is
needed for these cases.

## RAG-REC-001 follow-up — interrupted maintenance also hides vector publication

The short maintenance test published valid graph changes through generation
4813. All 15,153 chunk links and all stored embedding BLOBs were preserved,
but the current manifest advertised no vector sidecar until final publication.
Draining a paused job made the controller refuse that final publication.
Availability preservation therefore needs to cover interrupted incremental
maintenance as well as explicit full-corpus replacement.

After terminal status reconciliation, the public `vector rebuild` successfully
published 15,153 rows at generation 4813 using SQLite only, with zero provider
calls. `library verify` passed with zero storage and repository issues. The
original source/revision/chunk and embedding tables are byte-identical to the
fresh pre-test backup. The successful graph changes and complete test history
remain in the live library; no backup rollback was performed.

Evidence and complete operational record:
`/Users/adrian/testrag/maintenance-5000-20260906/` and
`/Users/adrian/testrag/transcripts/90-baseline-and-top-5000-maintenance.md`.

## Configuration preservation invariant

User clarification, 2026-09-06: changing configuration does not invalidate the
database. Profiles, prompts and ranking/chunk policies govern subsequent
work. Historical objects keep their original configuration snapshots, spans,
provider provenance and vector identities. Existing rows are never deleted
or reset merely because configuration hashes differ.

ANN algorithm/tuning changes require only a new derived index from stored
vectors. Embedding model, dimension or input-encoding changes require a
compatible embedding set when explicitly requested. They retain the old set
and all other corpus data. An incompatible query embedding route is an
unavailable retrieval channel, not an invalid database.

The interrupted-maintenance follow-up is now locally repaired. All readers,
manifest projection, reports, maintenance census and backup share an eligibility
check for the newest ancestral index: both source-chunk and embedding-link
membership must match the requested semantic generation exactly. The index keeps
its original generation and checksum. Changed memberships and non-ancestor
branches fail eligibility. This does not claim completion of the separate full
corpus replacement workflow above. The final Scottish scratch copy verified at
generation 4827 with zero storage or repository issues, retaining the complete
15,153-row generation-4813 index. All ten source/embedding tables match the live
generation-4813 library byte for byte; no schema migration was introduced.

## RAG-MNT-003 — replay omitted the worker budget policy

Status: repaired and locally qualified. The first scratch replay created items
and job totals but no `budget-policy` event. Its worker rejected the item before
any provider call. Replay now atomically records the current reviewed policy
with the new job and rejects historical reservations that exceed that envelope.
The durability test claims replay work, reserves a call, settles it and completes
it, rather than checking lineage alone. The source job remains immutable.

## RAG-MNT-004 — canonical identity conflicts still block some maintenance

Status: repaired in the local candidate; final offline qualification is recorded
below. Broad hosted maintenance remains unqualified. Three of ten repair-probe attempts reached
`canonical alias conflict requires review`, including one of the final two
calls after quotation validation succeeded. Existing canonical ownership remains
protected. Do not merge identities or discard aliases merely to increase the
success rate. Investigate catalogue-aware proposal production and the explicit
review route before restarting broad maintenance. This is not evidence that
source text or embedding storage needs rollback.

Current evidence and closure note:
`/Users/adrian/testrag/grounding-repair-20260906/` and
`/Users/adrian/testrag/transcripts/91-quotation-grounding-and-maintenance-repair.md`.
The live 5,000-item job remains terminal and no automation was resumed.

Follow-up diagnosis on 6 September: captured candidate records include
`Macleans` (organisation), already an alias of `Clan Maclean`, and `Macdonalds`
(organisation), already an alias of `Clan Donald`. Other collisions cross
types, including `Mackay` as organisation versus the existing person alias.
The incident producer hashed the proposed canonical label without first
resolving it through the catalogue. These cases require identity reuse or
explicit contextual ambiguity, not indiscriminate merging. The replacement producer reuses a unique typed catalogue identity and records
unresolved collisions as durable questions. Validated reuse/distinct answers
retain aliases and ambiguity, then queue follow-up extraction. The local
fixtures cover automatic and supervised resolution without weakening identity
or quotation validation.

## RAG-MNT-005 — resolution work stops at mandatory operator review

Status: implemented in the local candidate; final offline qualification is
recorded below. See [Durable autonomous maintenance](autonomous-maintenance.md).

The previous route put conflicts and structural actions into `review-required`
even when automatic operation was intended. It had no dedicated resolution
worker or automatic split workflow for affected connections. The maintainer's intended
operation is a bounded maintenance window (for example five hours nightly)
that resolves routine issues and pursues opportunities automatically, resumes
unfinished work, and escalates exceptions instead of every decision.

The candidate adds typed resolution questions for the full task census,
incremental split/merge connection work, runtime policy, deduplicated
reconsideration, shared budgets, deadlines and settled-response recovery.
Retirement is gated on a complete impact census; source records, vector BLOBs,
claim/support history and moved note-link source spans are retained. The legacy
`reviewed` mode remains the compatibility default; the new automatic and
supervised modes are explicit runtime choices. No nightly automation was
created or resumed. The historical 5,000-item live run remains unqualified.

## Durable backlog local qualification — 6 September 2026

RAG-MNT-004/005 are implemented and locally qualified in the working tree.
All 24 tests pass, including both-VM connection workflows, cross-window settled
response reuse at the paid-attempt cap, note-link source history, manual census,
supervised follow-ups, and native Gemini valid/malformed/ungrounded cases.
`git diff --check` passes. The candidate is not committed or installed.

Native SHA-256:
`39379f44ab8042699cbbf395f858bb6377000136ab6edd5140266114946bb262`.
A fresh Scottish clone migrated to schema 10 at generation 4813. SQLite rebuilt
its 15,153-row index with the original checksum and returned five passages in a
stored-vector ANN query. All nine source/vector tables and sidecar identities
match live; verification reports zero issues. No provider calls were needed.

Evidence: `/Users/adrian/testrag/transcripts/94-durable-backlog-qualification.md`
and `/Users/adrian/testrag/durable-backlog-20260906/full-test-final.log`.
The live library and paused automation are unchanged. Broad hosted maintenance
and the historical top-5,000 test remain unqualified; this local closure does
not close the separate staged full-corpus replacement workflow in RAG-REC-001.
