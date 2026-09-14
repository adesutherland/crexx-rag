# Test 2 recovery and independent vector availability

Authority: the user requested an action plan and implementation on 14 September
2026. Work in `/Users/adrian/CLionProjects/crexx-rag`, starting at `0a85f9d`.
Existing smoke records are retained. The user authorized the local commit after
completion. No push, installed executable replacement or authoritative corpus
change is part of this repair.

**Retired as complete, 14 September 2026.** A0–A8 have no outstanding actions.
Keep this file as the acceptance and evidence record. The enduring workflow and
SQL rules live in [architecture](architecture.md); the active next work is
[Test 4](test4-repair-delivery-20260914.md).

## Acceptance checklist

- [x] **A0 — Preserve the workflow principles throughout implementation and
  context compression.** These are the user's acceptance criteria, not optional
  implementation suggestions:
  - **Failed embedding:** leave that item pending or failed.
  - **Successfully stored embeddings:** include them in search independently.
  - **Existing documents:** retain usable search coverage while new work proceeds.
  - **Restart/retry:** finish outstanding work and index activation.
  A failed item, claim extraction or worker housekeeping step must not hold
  successful vectors or unrelated jobs hostage. Preserve completed data and
  receipts; redo only unfinished work. Check every implementation decision and
  regression against these principles. Tick A0 only after the final results
  demonstrate all four, and reread it first after any context compression.
- [x] **A1 — Establish cause and owners.** `ragapplicationprovider` performs
  optional post-result account refresh/history cleanup with two-second timeouts;
  its transport error becomes worker failure after successful settlement.
  `ragproduct._workerstart` skips vector finalization on any controller error
  and refuses a completed job restart. `ragstore.compatiblevectorpredicate`
  invalidates a shared ancestral index when unrelated membership changes.
  `ragembedding` already builds partial coverage; `ragretrieval` resolves vector
  members against SQLite. These existing owners will contain the fixes.
- [x] **A2 — Demonstrate missing acceptance before product edits.** Extend
  deterministic native provider/publication and ANN tests. Retain passing
  controls and record exact baseline failures below.
- [x] **A3 — Remove redundant Codex housekeeping.** Remove the optional
  post-result account refresh and its hardcoded two-second timeout. The required
  preflight reads current allowance before new work; receipts settle actual
  usage. Remaining provider protocol operations use the existing configured
  timeout and operation budget, not another policy or timeout knob. A history
  cleanup failure after durable output cannot fail successful work or stop
  peers. Dispose of the unusable transport and reopen normally for the next
  item; retain required preflight and uncertain-turn handling.
- [x] **A4 — Finish through the normal job command.** Attempt index activation
  from committed embeddings after worker errors as well as success. Repeating
  `job run JOB_ID` on a drained terminal job completes index work without model
  calls or changing completed attempts. Return useful retry guidance if index
  activation itself fails. Preserve genuine worker-failure history.
- [x] **A5 — Keep independent vectors searchable.** Retain a same-profile
  ancestral index during pending additions/removals. Resolve only still-valid
  indexed memberships in the current snapshot; do not return removed or changed
  members. Rebuild includes all available committed vectors independently of
  item/job failures. Keep model/dimension, file integrity, ancestry and atomic
  publication protections; do not add a separate index per job or a service.
- [x] **A6 — Shared guidance.** Update architecture, operator retry guidance,
  coverage matrix and existing delivery records; remove contradictory completed
  job refusal and all-or-nothing membership rules in affected guidance/tests.
- [x] **A7 — Verify completion.** Focused regressions, full debug suite,
  `git diff --check`, then fresh bounded Test 2 on a disposable corpus copy.
  Repeat the existing public Bannockburn scope: two embeddings, two extraction
  items, at most four Codex turns/eight total calls, five minutes, $0.005, two
  workers. Verify automatic index activation, retrieval/citation, same-command
  zero-call retry, exact usage and no surviving processes. Record results here.
- [x] **A8 — Skip unchanged index construction.** Keep A0 intact. In the shared
  index builder, use a stored database dirty marker, as explicitly requested by
  the user. Relevant data transactions invalidate it; successful rebuilding
  clears it. The existing `vector rebuild` command forces rebuilding. No input
  fingerprint scan or sidecar format change. Retain checksum validation and
  normal missing/corrupt-file recovery. Cover unchanged retry, changed settings,
  same-count changes, post-rollback generation jumps and migration; measure the same 34,902-vector scratch
  library with zero provider calls. Keep existing indexes searchable when dirty.

## Final result and evidence

**Complete, 14 September 2026.** All checklist actions and all four A0 workflow
principles are verified. The functional results below precede the A8 follow-up;
the final candidate and full-suite result are recorded at the end of this file.

| Check | Result |
| --- | --- |
| Failed item stays isolated | Both-VM ANN removal/pending-addition cases, embedding exhaustion, receipt failure and bounded maintenance passed. Five historical missing embeddings were unchanged in the live copy. |
| Successful embeddings become searchable independently | Actual failed child exit after four successful items still activates the index; public partial-coverage and bounded-worker tests pass. |
| Existing documents retain coverage | Pending live import kept its ancestral sidecar; ANN tests retrieve valid remaining members and omit removed members, preserving ancestry, rollback, checksum and representation controls. |
| Normal restart/retry finishes work | Completed `job run` activates/rechecks the index and preserves exact attempts and receipts with zero new calls. Missing-manifest recovery uses that same command. |
| Focused final suite | **5/5, 80.23 seconds**: Test 2 completion, embedding publication, ANN methodology, bounded provider maintenance and documentation. |
| Full debug suite | **70/71, 941.94 seconds** initially; the sole failure was the stale metadata expectation described below. Corrected metadata plus documentation rerun **2/2, 0.60 seconds**. All 71 distinct checks now have passing results on the unchanged product artifact. |
| Live Test 2 | **4/4 items succeeded in 52.26 seconds**; automatic activation, zero failed/restarted workers, no manual rebuild. |
| Live repeat | Normal job retry `identical-no-op`, **26.14 seconds**, zero calls; repeat import `identical-no-op`, zero queued items. |
| Data and evidence | Public verification zero issues; citation exactly matches UTF-8 bytes **502–951**; eight original source records unchanged; no reserved usage or surviving live-smoke/retry processes. |

The live scratch is `/private/tmp/crexxrag-test2-repair-v2310lhx`; its frozen
native executable SHA-256 is
`806487a1ee1a861fa17cffcfd55672bb8f269dabffe1f238cbd65fab032b0ba7`.
It was restored from the pre-Test-1 backup and migrated through public commands.
That backup deliberately still has five historical missing embeddings. Test 2
adds two embeddings and activates **34,902 stored vectors** for **34,907 chunks**;
it neither repairs nor blocks on those unrelated five items.

Recorded live usage: two Gemini embedding calls (248 input tokens,
**$0.000049** API cost) and two Codex subscription turns (36,640 input /
1,974 output tokens). This stays within the repeated five-minute, eight-call,
four-Codex-turn, $0.005 scope. Queries and retries made no additional calls.
Live execution overlapped the zero-outbound full suite; its elapsed time is not
an isolated performance benchmark.

The initial repair still spent **26.14 seconds** rebuilding before recognising
an unchanged index. The user subsequently requested the simple database dirty
marker in A8; its implementation and measured improvement are recorded below.

### Regression-first evidence

`ann_methodology` failed five new availability/evidence assertions against the
baseline while its existing controls passed. `embedding_publication` completed
its original repair control then rejected the new normal job retry. Native
optional-refresh and optional-delete injections reproduced the worker failure.
The first worker-stop SQL injection did not cause an OS-process failure; it was
replaced with a wrapper that exits 75 after the real worker completes. Against
frozen `0a85f9d`, that exact fault produced **4 processed / 4 successful calls /
0 published indexes / 0 reservations**, followed by exit 6 on ordinary retry.
The same acceptance passes after the repair; the failed child remains reported.

The full-suite metadata failure was already present in frozen `0a85f9d`, which
advertises exactly the same metadata as this repair. A field-by-field comparison
against the earlier installed artifact proved that only the two previously
approved Q&A tool descriptions changed. Counts, schemas, arguments and access
were unchanged. The exact expected hashes were updated; strict comparison
remains. See `metadata-reviewed-diff.json` and the passing rerun.

Evidence is retained under `docs/qa/test2-recovery-20260914/`, including baseline
failures, final build/focused/full logs, metadata comparison and `live/` command
outputs, receipts, attempts, events, manifests and independent data checks.
The ANN lookup plan uses indexed chunk, digest/profile and membership keys;
statements are reused per bounded page. No schema or provider integration
contract changed. The final guidance search also removed the stale user-guide
rule that bounded work must wait for a completed or paused job before indexing.

RAG-SMK-011 is repaired. RAG-SMK-010 replay compatibility and the previously
reported Nairn extraction hold remain separate outstanding work; this result
does not claim that all four historical smoke scenarios are now green.

## A8 — Simple dirty-marker follow-up

The user explicitly selected a database invalidation marker instead of a
per-retry fingerprint of all embeddings. The final change uses schema 19:
`embedding_profiles.vector_revision` identifies the last relevant mutation,
while `vector_generations.input_revision` records what that index includes.
Their inequality is the dirty flag. Recording the observed revision avoids
losing a data change made during a build, without holding a training-time lock.
The existing centroid/probe fields plus `build_iterations` identify the settings.

Schema triggers own invalidation for embedding/profile edits, membership
insert/update/delete, chunk visibility changes and generation rollback/jumps. Graph
changes alone do not invalidate vectors. `ragembedding` checks the marker before
reading vectors or training, and marks successful builds clean. The existing
`vector rebuild` command invalidates first, forcing reconstruction. A failed
build stays dirty. Search availability ignores the marker, preserving A0.
Maintenance census/completion share `ragstore.currentvectorpredicate`.

There is no new operator setting, fingerprint scan or sidecar format. Upgraded
indexes need one ordinary build to establish their marker. Existing derived
files remain readable and their checksums unchanged when inputs are unchanged.

| Check | Result |
| --- | --- |
| Focused regressions | **6/6, 54.29 seconds**: both-VM ANN methodology, migration/provider durability, public Gemini query, Test 2 completion, embedding publication and documentation. |
| First normal retry after schema migration | **26.820 seconds**, establishes the marker for the existing index. |
| Subsequent normal retries | **3.000 and 1.696 seconds**, `identical-no-op`, including fresh worker startup/shutdown. |
| Explicit forced rebuild | **25.839 seconds**, same derived content, zero provider calls. |
| Normal retry after forcing | **3.892 seconds**, `identical-no-op`. |
| Receipts and attempts | Exact hashes unchanged across **82,548 provider-run rows** and **116,174 attempt rows**. |
| Library verification after migration/retries | **Zero storage and repository issues**, aligned manifest, unchanged index checksum. |
| Final full debug suite | **71/71, 530.53 seconds**, after the generation-jump correction. The earlier serial full run also passed 71/71 in 943.95 seconds. |

These are whole-command timings on the same disposable **34,902-vector,
768-dimension** library used for the earlier 26.14-second retry. Some timings
overlapped local regression work, so they are operational smoke measurements,
not an isolated microbenchmark. The native artifact SHA-256 is
`ef14f76fb87ae9608bc1ec565a9efc545e482388a10190f0b52788f76930e014`.
The normal installed executable and authoritative corpus were not changed.

The baseline confirmed unnecessary full construction on unchanged retry; the
initial regression also exposed that converged centroids alone cannot identify
training iteration settings. The final acceptance covers settings, transaction
rollback, explicit invalidation, failure staying dirty, same-count vector edits,
and membership changes that reuse an existing embedding without a new timestamp.
Existing missing/corrupt-sidecar, graph-only, rollback and representation
controls remain passing. Invalidation uses existing indexed membership/embedding
lookups. Evidence is in `docs/qa/index-retry-20260914/`.


Final audit found one additional invalidation transition: rebuilding at a
rolled-back generation and then publishing past retained later intervals. The
extended ANN acceptance reproduced a clean marker on that changed view. The
existing generation trigger now invalidates on rollback **or a skipped generation
number**, while ordinary consecutive graph-only publications remain clean.
This adds no state or operator workflow. `baseline-rollback-jump.log` retains the
failure. A fresh schema-18 disposable fixture is prepared from the same corpus
copy for the final public migration and timing, preserving the first smoke.


Final candidate `32c4ac3f10340b590012ab344e1780fbc33c71eb66ac4e9503ab0ddf6d1f4bb7`
passed the extended both-VM ANN and migration/provider-durability checks **2/2
in 18.47 seconds**. On `/private/tmp/crexxrag-index-retry-final-cr61v8pl`, public
migration took **0.352 seconds**, the first rebuild established the marker in
**26.093 seconds**, and the unchanged job retry took **2.080 seconds**. Exact
provider-run/attempt hashes and the 34,902-vector sidecar identity are unchanged.
The final full suite runs with two CTest slots; temporary locks serialize shared
TCP fixtures and identical work directories. The generated test file was
restored after the **71/71, 530.53-second** run; checked-in test definitions and product settings are
unchanged by that scheduling choice.

**A8 complete.** The final candidate passes all 71 local cases, the additional
rollback regression and the full-corpus zero-call retry. `git diff --check`
passes. Ready for the user-authorized local commit; no normal installation or
authoritative corpus was changed.
