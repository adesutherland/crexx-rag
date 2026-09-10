# LLM processing repair plan — 10 September 2026

Items 1–3 were approved on 10 September and implemented in the isolated
`temp/llm-recovery` worktree after committing baseline `17d7acb`. The user then
stopped further offline testing and authorized the live LLM backlog until
16:30 BST. Eight workers started at approximately 14:34 BST using the existing
built artifact, after the four interrupted turns were inspected and reconciled
through public commands with zero generation calls. Monitoring is active;
publication of source changes must leave that running artifact unchanged.

## Qualification at publication

The latest complete suite ran all 32 tests in 414.38 seconds: 30 passed and
two failed. The provider-durability failure was an incorrect test update in
baseline `17d7acb`: the deferred admission's recommended retry delay was still
compared with elapsed waiting time. The corrected test subsequently passed
all four compiler/runtime combinations in 9.81 seconds, including a check
that deferral creates no extra admission. No product change was required for
that correction.

One test remains unresolved: `native_interruption` reaches the public
`job run` restart after killing a worker, then reports unavailable embedding
coverage (`0/1 active chunks`) during vector finalization. Its later assertions
and remaining scenarios were not reached. Full regression qualification is
therefore incomplete; the user authorized the live run and source publication
with further test execution stopped. Local run evidence is retained in
`/tmp/crexx-rag-llm-full-2.log` and `/tmp/crexx-rag-llm-provider-final.log`.

Running native artifact SHA-256:
`fe154f4b0ef7d74044a1b328c92299b7b08ee7d6905d55072ad71ecf72ef4c39`.
The controlled corpus-copy and fresh-agent trials proposed in item 4 remain
separate from this ongoing live backlog run.

## Evidence collected before repair

The paused ingestion job had 11,914 queued extraction chunks, 2,841 accepted,
838 skipped and 196 dead letters. These counts were reread from the live
SQLite library on 10 September; they are unique items, not provider attempts.
The 196 terminal items break down as follows:

| Observed final failure | Items |
| --- | ---: |
| Relationship quote omits one or both literal endpoints | 82 |
| Mention quotation absent from source chunk | 44 |
| Mention label absent from its quotation | 42 |
| Relationship quotation absent from source chunk | 6 |
| Invalid relationship endpoints | 6 |
| Output arrays exceed reviewed bounds | 3 |
| Analysis-note quotation absent from source chunk | 3 |
| Contradiction of reviewed glossary identity | 2 |
| Codex account-preflight timeout | 3 |
| Provider reservation transaction could not start | 1 |
| Expired ownership with an unsettled Codex request | 4 |

Thus 188 items failed output validation, four lost their external outcome,
three failed before generation during account preflight, and one failed in
storage. A validator correctly rejecting unsupported evidence is not by itself
a product regression. The repair must improve production/correction of valid
answers while preserving the evidence rules.

Four external turns from this ingestion job were read at 02:34:49 BST: each
was interrupted without a final answer, after approximately 126–134 seconds.
SQLite still records their provider runs as running. Three additional running
Codex records belong to an older job; inventory them separately and do not
silently fold them into this job's recovery. External status must be reread
before applying any reconciliation; the saved observation is historical.

The overnight main maintenance job processed embeddings only. It did not
qualify broad cognitive maintenance. Likewise, today's embedding stress test
qualified recovery from observed SQLite waits, not Codex transport recovery.
The older channel-ticket retention defect already has an installed upstream
repair and RAG release calls; treat a recurrence as a new evidence question,
not as the established explanation for the later timeouts.

## Recommended implementation order

### 1. Repair outcome reconciliation and transport recovery together

Owners: `ragwork` owns durable attempts, receipts, reservations and usage;
`codex_provider` owns App Server transport; `ragapplicationprovider` connects
them; `ragproduct` exposes public operations.

The current general receipt lookup returns an uncertainty hold before the
Codex-specific `recoverexternalrun` / `recover_structured` path is reached.
Consequently the intended external recovery cannot settle these held requests.
Use those existing components to provide a public inspect/reconcile flow for
the exact stored job, item, provider run, thread and turn identities. Final
command names should fit the existing job vocabulary; this is not a second
recovery service or an instruction to edit SQLite.

Reconciliation must distinguish completed output, confirmed interruption with
no final answer, still-running work and unavailable/ambiguous history. Reuse
completed output through normal validation without a new generation call.
Persist terminal observations and known usage once; unknown usage remains
explicit. A confirmed interrupted request can become eligible for a bounded
fenced retry without erasing its first attempt. An ambiguous request stays
held. Repeat reconciliation must be a no-op. Inspect must not cancel a live
external turn; cancellation is a separately explicit apply action.

Trace the recorded timeout through account preflight, turn wait, byte-channel
read, cleanup and ownership expiry. The adapter currently applies its timeout
to individual reads and marks the transport unhealthy after a failed read.
Do not simply increase all timeouts. Define the existing request timeout,
worker lease and job deadline consistently, then reconcile the exact external
turn after a lost response. Preflight failure before generation must not use a
generation-call allowance. Preserve the existing unhealthy-worker replacement
path and shared contention repair; extend only demonstrated gaps in identity,
usage and completed-output persistence.

Acceptance: the four held requests can be inspected and settled through public
commands; completed-output recovery makes zero new generation calls; confirmed
interruption permits only the bounded retry; repeated recovery neither double
charges nor republishes; unknown history remains held. Exercise a pre-call
timeout and a post-submission timeout separately.

### 2. Make ordinary restart one supported operator flow

Reuse RAG-OPS-001, existing worker supervision and job controls. Reconcile stale
embedding queue entries through the embedding closeout operation before
resuming mixed ingestion. Do not reimport the texts or replay the whole job.
Any selection/retry control added for extraction should extend the existing
operation and preserve the original snapshots and accounting.

Check configuration compatibility once at group startup, using the same rule
as workers, before claiming items. Today's worker-count transition showed how
one configuration mismatch can otherwise produce hundreds of false dead
letters. Return the concrete public repair operation. Keep worker-count
differences operational while retaining provider/profile compatibility.

Acceptance: the documented fixed command resumes eligible work without source
edits, config/data patch scripts, duplicate embedding calls or reset budgets.
An eligible worker exit is actually replaced under the original restart ceiling;
controller loss is recovered only after old ownership is gone. This replacement
case remains to be exercised: the embedding stress run recovered inside retries
and therefore needed no replacement.

### 3. Improve extraction grounding and bounded correction

Owners: `ragapplicationprovider` produces the request and validates the result;
`ragwork` owns the existing single citation-correction attempt and accounting.

Use retained source passages, initial outputs, correction feedback and corrected
outputs from the failure groups above. The single correction route already
exists: establish why it still ends with invalid output before changing it.
Prioritize the 82 missing-endpoint cases and 86 mention-quotation/label cases.
Include OCR hyphenation, line breaks, repeated names, aliases, removed mentions
and shifted relationship indexes in the retained examples.

Improve source-surface labels, literal contiguous quotation selection and
specific correction feedback. A response may omit unsupported components and
their dependent relationships, preserving supported claims. Keep exact source
mapping, directional relationship support, glossary identity and reviewed array
limits; do not relax validators to inflate acceptance. Keep corrections bounded
and separately accounted. Audit accepted outputs as well as rejected ones so
that fewer dead letters cannot conceal poorer evidence.

For cases requiring stronger reasoning, reuse the existing
`advanced-reasoning` capability and evidence-backed task workflow. The current
automatic flag applies to resolution-content failures, not every extraction
dead letter. Confirm the extraction-to-review handoff; add only that bridge if
missing, retaining the source and rejected-output history. Transport/storage
failures must not be classified as difficult reasoning.

Acceptance: the same retained examples show fewer invalid answers after a
bounded correction; every accepted mention and relationship still passes the
unchanged evidence checks. Difficult cases become inspectable review work,
without an endless retry loop or indiscriminate model escalation.

### 4. Qualify extraction, then cognitive maintenance and the agent handoff

First replay retained protocol/response cases locally through the owning code,
without generation calls. Use the existing test bundles for the confirmed
timeout, receipt, retry and evidence failures; avoid a separate test framework.
Then prove the repaired operator flow by running real work on a consistent
corpus copy before resuming the live extraction backlog.

Proposed first live extraction trial for agreement: eight configured workers,
100 selected chunks or 20 minutes, whichever comes first, at most one existing
correction per chunk (200 generation calls maximum), preserving the agreed
Codex allowance floor and using no reset credit. Mix retained failure examples
with unseen chunks and known accepted controls. These are proposed future
limits, not authority to start LLM work now.

Report accepted, correctly skipped, deferred, review and dead-letter chunks
separately; also show calls per accepted chunk, correction success, latency,
known usage, unresolved usage and worker recovery. Build/package once, run the
relevant regression suite on that artifact, and reuse it for the real trial
and production command. Do not insert another build into ordinary launch.
Retain the Gemini regression route and malformed-output/secret-redaction
negative cases alongside the Codex receipt and channel-lifetime cases.

After extraction passes, run a separate bounded cognitive-maintenance sample
covering retain, identity reuse/ambiguity, split/merge connection work and
reclassification. Have a fresh agent use the documented skill/MCP tools to
discover a flagged task, explore its evidence, prepare a proposal and follow
the existing review/apply controls. Measure useful grounded resolutions and
correct escalation; embedding throughput is not its acceptance criterion.

## Evidence and status boundaries

- [Live embedding comparison](/Users/adrian/testrag/embedding-remediation-20260910/BENCHMARK.md)
- [Overnight report](/Users/adrian/testrag/overnight-scottish-20260909/MORNING-REPORT.md)
- [Saved external-turn observations](/Users/adrian/testrag/overnight-scottish-20260909/codex-timeout-external-status.json)
- [Operational recovery backlog](recovery-defects.md)
- [Existing agent workflow](agent-integration.md)

The public recovery flow is documented under [Jobs](user-guide.md#jobs).
Local protocol fixtures exercise outcome inspection and atomic reconciliation,
completed-answer reuse, bounded worker replacement, configuration rejection
before claims, citation correction and the advanced-reasoning handoff. The real extraction and
fresh-agent acceptance trials in item 4 still require their separate bounded
agreement; deterministic correction fixtures are not a claim of measured
improvement in hosted model accuracy.
