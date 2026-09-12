# Reliability and use-case coverage review

The [consolidated roadmap](ROADMAP.md#recovery-and-reliability-history) indexes
these repaired cases alongside later open requirements. Keep their separate
qualification boundaries when assessing current readiness.

This is dated qualification evidence. Live-library statements below describe
the named run at that time, not current operating status. Later MCP and copied
corpus trials are recorded in [the agent trial report](mcp-codex-trials.md).
The subsequent [10 September controller repair](controller-recovery-report.md)
changes the job-wide uncertain-outcome pause described in this dated record.

Current repair record: 7 September 2026, based on `dfe25ed`. The previous review
and held-run incident census are preserved in
[the 6 September record](reliability-coverage-review-20260906.md). Its open/fixed
labels describe that earlier candidate, not the current working tree.

REL-005 was known but unfinished when the previous maintenance run resumed.
The earlier repair covered Codex completed turns and durable resolution outputs;
it did not preserve general extraction and embedding responses. Treating those
partial recovery tests as adequate for another paid run was a qualification
failure. The current repair closes that implementation gap and tests both work
kinds through actual native worker exit and public restart.

This is a local baseline qualification record, not installation or permission to
resume the held live job. The live Scottish library remains at generation
7024 with maintenance workers stopped. Destructive fault tests use disposable
libraries. The separately requested quality report and agent Q&A added one
derived observation, query-gap observations and five query-embedding ledger
entries; no corpus maintenance was resumed. No new schema migration or
installation is part of this repair. The user subsequently requested the
query-gap repair and a local baseline commit before the next test. Product changes remain
Level-G cREXX; the C++ change is the existing
loopback HTTP test fixture. No Python source is introduced.

## Current issue register

“Repaired” refers to the implementation and the named executable boundary. It
never means all possible interleavings, platforms or unattended durations have
been proved. The full-suite and scale results are recorded below when terminal.

| Issue | Current repair and acceptance evidence |
| --- | --- |
| REL-001: shared manifest temporary | Repaired in the baseline. SQLite write ownership spans projection read and rename. `publication` holds a real writer on an independent connection and rejects the competing publisher without touching its projection. |
| REL-002: partial extraction publication | Repaired for both discovery batches and the older single-proposal path. Promotions, claims, fence, item completion and generation commit are one transaction. `publication` rejects a late mention and a missing second candidate; `native_publication` injects a claim INSERT failure after staging mentions. No graph prefix survives; usage does. A post-commit manifest error cannot requeue the committed item. |
| REL-003: inappropriate resolution actions | Repaired in the baseline. Request schemas derive actions from task and workflow context; normal validation enforces applicability. `durable_backlog`, `durable_backlog_provider` and quotation negatives cover the typed contract and grounded decisions. |
| REL-004: misleading successful-call checks | Repaired. Native tests reconcile terminal items, decisions, concepts, mentions, claims, supports, attempts, calls and reservations. The SQL-failure case explicitly requires successful paid accounting alongside a visibly failed item and no partial graph. |
| REL-005: missing general response recovery | Repaired. Immutable `provider-intent` and `provider-response` events bind request/input/configuration; bounded redacted envelopes retain generation output and lossless embedding payloads before validation, settlement or publication. Restart reuses received output under normal validation and fresh publication ownership. `native_receipts` faults usage settlement for extraction and embedding separately, restarts two native workers, and requires exactly two total fixture calls, original-attempt usage and zero reservations. Codex completed output remains retained after settlement as well. `codex_application` and `provider_durability` retain their managed-turn recovery gates. |
| REL-006: incomplete process/fault matrix | Bounded matrix implemented: `native_publication` combines two busy workers, queries, backup, restore and verification at two explicit request rendezvous; `native_interruption` kills a busy worker/controller, cancels an admitted call and rejects a post-commit manifest write. `publication` pins readers/backups while another connection owns an actual uncommitted graph mutation and aborts incomplete backup staging. The larger deterministic backlog lane is separately bounded. A multi-hour nightly soak and platform gates remain release qualification requirements; they are not inferred from these tests. |
| REL-007: rollback/projection ordering | Repaired in the baseline, with first-index recovery completed here. SQLite rollback commits before manifest projection. `publication` rejects the pointer update and verifies preservation. `native_interruption` leaves a committed extraction with failed manifest publication, then repairs the manifest and builds the first vector index without repeating the extraction call. |
| REL-008: graph-only vector rebuild | Repaired in the baseline. Complete membership/payload comparison permits index ancestry reuse; native maintenance and ANN fixtures assert zero-call reuse. Training still occurs for deterministic payload comparison, so large-index rebuild CPU optimization is not claimed. |
| REL-009: valid ancestral observation rejected | Repaired in the baseline. Verification checks published ancestry and the recorded source/embedding membership rather than exact generation equality. Native query/maintenance and ANN verification preserve the historic checks. |
| REL-010: overstated recovery/readiness documentation | Repaired in this record, the process matrix, maintenance recovery guide and test strategy. Actual usage, successful publication, rejection, explicit uncertainty and unfinished qualification are distinguished. |
| REL-011: cancelled call loses accounting | Repaired and tested with an actual busy native process. Returning usage settles under original reservation authority; cancellation prohibits knowledge publication and releases reservations. Both-VM API interleaving and `native_interruption` require terminal cancellation with one accounted call. |
| REL-012: late/excess/duplicate usage | Repaired. Settlement accepts verifiable original-attempt usage after expiry or above the estimate, records an exception and never grants stale publication rights. Identical duplicate receipts are idempotent; conflicting duplicates fail. Shared final-call admission and running Codex-turn reservation accounting are tested in `publication`; existing provider/window tests retain token, cost and deadline boundaries. |
| REL-013: extraction selects a migration parent | Repaired. Catalogue lookup selects active identities only. Publication resolves mention identities again under the writer transaction and rebinds relationship endpoints. An unresolved retired/parent identity becomes an alias-resolution issue; it cannot revive a parent or leave a partial relationship. `durable_backlog` creates a real unfinished merge, adds the old spelling to its survivor and publishes a deliberately stale extraction result against the active survivor while preserving the parent. |
| REL-014: incomplete alternate vector representation | Newly reproduced and repaired. An incomplete replacement profile cannot displace a different complete published representation. `ann_methodology` rejects the partial replacement, queries the retained index, then publishes the completed replacement while retaining old BLOBs. Initial partial libraries and same-profile repair remain supported. |
| REL-015: job events displays items | Newly found and repaired. `job events` now filters and pages the durable event ledger by job before applying its numeric cursor and limit. `job status` exposes the last error/uncertainty reason. The busy kill fixture proves the uncertainty event is publicly inspectable. |
| REL-016: legacy folder URI expansion replaces unchanged sources | Newly reproduced on the full Scottish copy and repaired. A legacy `file:./...` URI and its absolute spelling in the same working directory can match only after the entire original envelope also matches, including bytes, text, metadata and parser/policy identities. The original revision/membership stays published. `publication` proves no-op and changed-byte discrimination. Unknown relative-path origins are not guessed; repeat ingestion from the original working directory while the library retains legacy relative URIs. |
| REL-017: remainder used for unit conversion | The larger offline run exposed early cumulative time-budget exhaustion. Level G `%` computes remainder; several provider durations, admission leases, retry delays and embedding repair allowances incorrectly used it as integer division. These now divide and explicitly convert to integer. `native_receipts` compares retained microsecond latency against accounted milliseconds and checks exact admission lease length; `publication` requires a 2000 ms retry to become two seconds. The code audit retains `%` only for genuine parity/jitter calculations. Historic durations produced by the older code are not rewritten without reliable original timing evidence. |
| REL-018: oversized numeric command input crashes | Reproduced with `job events --limit` above the signed 64-bit range. The shared command validator now checks the integer range before casting. `native_surfaces` covers overflow at the exact boundary and far above it, valid maximum cursors and leading zeroes. This also protects report, trend, query and worker numeric options using the same validator. |
| REL-019: reports omit durable maintenance tasks | Reproduced on the native manual-maintenance fixture: four durable review questions were absent and review health said pass. Reports now include task states, workflow states and decisions; their operational digest includes that census. Open tasks contribute to maintenance health and snapshot work backlog; durable review tasks contribute to review health and snapshot review counts. Historic snapshots remain immutable. `durable_backlog_provider` reconciles report counts with the actual tasks and checks manual review health and persisted snapshot counters. |
| REL-020: query-gap maintenance loses the original question | Reproduced: a generic warning was both the evidence subject text and the lexical search input, omitting the stored original question. The packet now includes `subject.question` from `normalized_question`, and source selection uses that question while preserving the diagnostic separately. `durable_backlog` fails on the old code and passes on both VMs after repair: matching source selection, absent/stopword-only questions, stale interpretation replacement, idempotence, ordinary census/dispatch, grounded settlement, unresolved missing evidence and source/vector preservation. All eight existing Scottish gap packets were rebuilt read-only on both VMs; original questions match exactly and no observation, job, generation or provider ledger was changed. |

## Recovery contract

SQLite is authoritative for source bytes, normalized text, chunks, embedding
BLOBs and membership, graph/provenance, jobs, receipts and usage. A sidecar is a
rebuildable projection. A configuration change does not authorize corpus-wide
reprocessing. A new incompatible vector representation requires explicit new
derived work and preserves the old representation until replacement is complete.

The generic event receipt is scoped to the same immutable work item and input.
An ordinary restart or same-item retry reuses it; an explicitly created replay
job is new work and may make a new call. Resolution outputs additionally have
their existing task/window cache. Do not describe either mechanism as recovery
of a response that was never durably received.

An expired outbound intent with no durable response is uncertain. Recovery
records `provider-outcome-uncertain`, leaves the affected item inspectable as a
dead letter, pauses the job and refuses further admission for that unresolved
intent. It does not infer zero usage or silently request the answer again. The
operator can inspect events, reconcile the provider outcome and explicitly
choose subsequent work. Actual externally incurred usage and current publication
ownership are separate facts.

## Qualification evidence

Local evidence root:
`/Users/adrian/testrag/reliability-closure-20260907/`.

- `rel013-before.log`: active-survivor lookup regression on the earlier code.
- `accounting-before.log`: original late/excess settlement rejection.
- `replacement-before.log`: incomplete alternate-profile publication regression.
- `snapshot-turns-before.log`: running Codex turn double-counting, with successful
  concurrent reader/backup assertions in the same fixture.
- `legacy-uri-before.log`: unchanged source revision replaced solely by URI expansion.
- `time-conversion-before.log` and `retry-conversion-before.log`: incorrect
  duration/lease and retry-delay conversions. `offline-5000-final.log` retains
  the first larger run's failure; it is not successful scale qualification.
- `suite-10.log`: 28/28 before the final legacy-URI repair and expanded combined
  native reader/backup gate.
- `focused-11.log`: final URI compatibility, combined busy-worker reader/backup,
  cancellation, kill and post-commit recovery gates pass.
- `suite-13.log`: final maintained suite, **28/28 passed**, 173.29 seconds.
- `offline-5000-13/result.txt` and `final-census.csv`: **5000/5000 decisions**
  completed with two native workers and 2500 forced overlapping request pairs.
  Exactly 5002 loopback calls including the initial extraction and embedding;
  no failed/unfinished items or reservations, preserved source/vector state,
  and public verification passed. This is the deterministic local provider
  lane, not a restart of the held Scottish hosted experiment.
- `full-volume/noop-13-qualified.log`: exact final native candidate; unchanged
  ingestion in 569 ms, generation 7024 retained, two unchanged sources, zero
  queued items/calls; subsequent public verification has zero issues. The
  earlier 60-second verification bound under concurrent scale load timed out;
  the final 180-second bound completed verification in 63.84 seconds.
- `full-volume/vector-probe-13/{rxvme,rxbvm}.log`: both VMs retrieve the original
  Macknights/Macneits passage through ANN, 15153 rows / 2328 candidates,
  768 dimensions, zero provider calls; catalogue selects active Macneits.
- `full-volume/{candidate,live}-table-comparison.csv`: all ten source/vector
  tables plus jobs, items, attempts and provider runs equal the immutable
  stopping-point backup in both directions. Live generation remains 7024.
- Candidate-13 native SHA-256:
  `e0e1a530b620d7a3c5f0544b648b7599dd2818bc7bc4b2e9e9548b1c09fc7401`.
  Source manifest and larger-backlog results are in the closure note. Setup
  failures and timed-out experiments remain evidence, not passing gates.

The subsequent quality-report review repaired REL-018 and REL-019. Its final
native SHA-256 is
`731922c769d6b0a0082ecc5e95f60e7c4ac48e6a6f1beb7320034d2779dd7456`;
the maintained suite passed **28/28 in 199.84 seconds**. Evidence is under
`/Users/adrian/testrag/quality-qa-20260907/`, with terminal notes in
`/Users/adrian/testrag/transcripts/97-quality-report-and-agent-questions.md`.
The earlier 5,000-decision scale gate remains evidence for the unchanged worker
path; it was not repeated for the reporting/input-validation revision.

The query-gap revision adds REL-020 and is the requested local baseline.
Native SHA-256:
`76bde25dfee1bf80349725238110149064499d0b7f3f01db684e6e4b8890a73e`.
The focused regression failed on the old code, passed after the repair on both
VMs, and the full maintained suite passed **28/28 in 154.18 seconds**. Evidence:
`/Users/adrian/testrag/query-gap-fix-20260907/`. Read-only reconstruction of all
eight existing gap packets passed on both VMs, preserving each exact stored
question and the 65536-byte evidence bound. Eight bounded passage leads per
packet do not prove each question answerable or close any observation. The
eight gaps remain open for the next authorized maintenance census; no live
maintenance task or provider call was created. Existing gap records require no
rewrite because their original question is already stored. Broad lexical
ranking remains the separately recorded quality limitation.

Full corpus reports at generations 4799 and 7024 verified with zero issues.
Current observation 3 retains the report; all ten source/vector tables still
equal the original pre-maintenance backup. The six-question agent conversation
is preserved with exact requests, source-context follow-ups and twelve resolved
final citations. Four hybrid searches succeeded; a fifth embedding request
received Gemini resource exhaustion, so remaining searches used lexical mode.
One answer remains partial, and the original Pictish grading criterion is more
categorical than the source. Broad-query ranking still produces noisy passages
and headings; successful agent follow-up is not a claim that this retrieval
quality limitation has been solved or that maintenance alone caused better
answers.

The maintained tests run against the installed CREXX toolchain, using normal
optimization and both VMs where the scenario matrix specifies them. Hosted
Gemini regression, unattended duration qualification and non-macOS platform
qualification remain separate. This repair does not authorize restarting the
held 5,000-item Scottish hosted experiment. See the
[operator process cases](qa-process-cases.md) for the precise tested boundaries.

Subsequent verification on 12 September closed the stale extra-Enter label for
installed CREXX `5ccf057a1633`: the upstream repairs are present and both pipe
and real-PTY driver checks pass after one newline. These are CREXX repairs,
not effects of the RAG changes in this report. Retain the
[history and regression boundary](integration-issues.md#interactive-input).
The compiler scaling issue is already closed in the installed CREXX version.
RexxScript configuration is a deferred feature choice; current declarative
configuration does not require recompilation.

## Proposed retention follow-up

Resolved or replaced dead letters should leave the actionable backlog while
retaining a compact audit trail of outcome, replacement lineage, processing
usage and disposition. A future retention policy could remove bulky payloads
and diagnostics after a chosen period, once recovery, evidence and reference
dependencies have been checked. Historical integrity does not itself require
indefinite retention of every payload. Unresolved failures and responses still
needed for recovery must remain protected. This is a design proposal, not an
implemented purge operation; no historical records were deleted for this
baseline.
