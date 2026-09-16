# CREXX and platform integration issues

The [consolidated roadmap](ROADMAP.md#other-qualification-research-and-upstream-dependencies)
maps these dependencies and qualification limits to the product backlog.

These are current boundaries, accepted limitations and recorded repairs. Any
source-level containment used by the product is stated explicitly.

## Test 7 long-run controller lifetime — open, 15 September 2026

The Scottish soak's first Boswell controller was absent with no launcher
completion receipt and an unavailable tool session. Public pause, missing-PID
confirmation and prune retained unfinished work; a fresh source window recovered
it normally. At 05:52 the final window also reports no live workers, a controller
heartbeat 1986 seconds old and unfinished work before its configured deadline.
The second controller PID 51500 was independently confirmed absent in the
launcher's visibility domain; public pause/prune receipts 129–133 retain its
34 queued items and confirm no active ownership. The reporting wrapper has
no subprocess timeout and writes the final receipt only on return.

The 15 September [T7-10 diagnosis](t7-10-controller-diagnosis-20260915.md)
now strongly implicates Codex coordinator resumption: both last controller
heartbeats match the exact second of Desktop `thread/resume`, and the second
incident's App Server log records shutdown and replacement of that coordinator
instance. The first incident's detailed host records have rotated out. The exact
OS exit signal and host reproduction remain outstanding. A separate plain
parent-exit fixture now passes: the real controller survives reparenting to
PID 1 and finishes cleanly, so parent exit alone does not explain the incident.
Explicit command termination in the installed Codex App Server has separately
returned 137 (SIGKILL) for a signal-recording synthetic child; this is not a
reproduction of task resumption. Real-controller fixtures also reproduce SIGPIPE
on closed stderr and abrupt TERM/HUP/INT exits. The candidate product repair
tolerates lost operator output and drains catchable shutdown requests; the
linked T7-10 checklist owns its qualification. No clean endurance result is
claimed. The installed
product passed 74 developer tests, but this interrupted/repaired night does not
qualify clean long-running process endurance. Exact phase/receipt references and
the pending investigation are T7-10 in
[the soak checklist](test7-overnight-soak-20260914.md).

## Installed compiler source-import finding during T7-10

Filed as [CREXX #699](https://github.com/adesutherland/CREXX/issues/699) under
`adesutherland` on 15 September 2026. The report contains the repeated build
failure, successful alternative and explicit absence of a reduced reproducer.

On installed CREXX `g037e7939bc29`, the first failed-output cleanup using public
`closefile` compiled and ran on both VMs, but the full source-project build
repeatedly reported `INTERNAL_CONVERGENCE_ERROR` in `ragcommand` and a provider
`TYPE_MISMATCH` in `ragprocess`. Both importing modules compiled successfully
against built interfaces. The equivalent existing `lineout(stream)` close form
passes both VMs and the ordinary project build, and is used by the repair.
This is a bounded source-form finding, not evidence that all `closefile` use
fails. No compiler change or native product workaround was introduced. The
[T7-10 evidence](t7-10-controller-diagnosis-20260915.md) retains the failed retry
and successful build; the compiler issue remains upstream work.

## Child pipe inheritance — transferred upstream, local investigation closed

Filed as [CREXX #701](https://github.com/adesutherland/CREXX/issues/701) under
`adesutherland` on 15 September 2026, against installed CREXX `g037e7939bc29` on
macOS arm64. Concurrent process launches can leave a worker holding an unrelated
worker's stdout pipe write end. The runtime obtains the original worker's exit
status but waits for output EOF before delivering completion; a healthy peer's
unused inherited handle delays EOF and therefore automatic replacement.

The [worker repair record](worker-pool-repair-20260915.md#full-suite-finding--upstream-child-pipe-inheritance)
contains the descriptor evidence and qualification result. The GitHub report
includes the reproduction procedure, exact source links and standard descriptor
cleanup/close-on-exec repair direction. Launch timing is intermittent; a reduced
standalone CREXX reproducer has not yet been packaged.

**Adrian's decision:** close this investigation in RAG and let CREXX own the
repair. Accept delayed replacement as a known runtime limitation in the meantime;
do not add product monitoring or a native workaround. At that checkpoint no runtime fix was claimed. Adrian subsequently approved temporarily
disabling `worker_unexpected_exit` pending this fix; retain its code and report
it as not run, never as passing. Other supervision coverage remains enabled.
This exclusion does not establish the cause of every historical stale worker.

**16 September follow-up:** installed CREXX `17e844441ed8` passes the unchanged
three-case downstream `worker_unexpected_exit` regression after rebuilding the
native RAG executable. Replacement happens while the seven healthy peers stay
alive and undrained; unknown outcomes and exit-write refusal remain correct.
The temporary exclusion is removed and the regression is enabled with eight
scheduling slots. See [exact artifacts and focused evidence](crexx-701-retest-20260916.md).
This verifies the reported mechanism locally; it does not retrospectively assign
all historical controller failures to #701 or assert a fresh full-suite result.

## Worker execution architecture

CREXX now supports declared native-provider discovery and isolated RXPA
sessions in attached task VMs, including the installed `rxsqlite` provider.
The former discovery integration gap is closed upstream.

`crexxrag` continues to use operating-system worker processes by product
design. Every process starts a fresh VM and opens its own SQLite connection,
which is supported and covered by regression tests. Moving work into attached
tasks would be a separate architecture and recovery-policy decision; native
SQLite handles would remain VM-local and must never be transferred.

**Agreed decision, 12 September 2026:** retain process workers as the default
for independent replacement and containment of a worker native crash. Attached
threads share the process failure boundary; cancellation depends on runtime and
plugin capabilities. Either layout still requires durable task identities,
receipts, usage accounting and publication fencing.

The existing CREXX `lib/plugins/sqlite/tests/rxsqlite_attached_test.crexx`
passed through installed `crexx` (`5ccf057a1633`) on 12 September: the controller
and two attached workers each resolved their own SQLite provider session. This
proves the narrow integration capability, not a RAG worker migration or a
performance gain. A bounded thread comparison may accompany the forthcoming
llama.cpp bridge under QE-04, measuring persistent model ownership, memory,
throughput and cancellation before any architecture change.

## Local process liveness and permission boundary

The installed `ADDRESS CREXX ps PID` reports a POSIX `kill(pid,0)` failure as
not found, including permission denial. It does not expose the distinction
between `ESRCH` and `EPERM`, or an operating-system process birth identity.
This was confirmed while testing restart ownership on 10 September against
the installed `5ccf057a1633` route. Native changes belong in CREXX.

RAG's automatic restart/prune qualification covers its local workers launched
under the same operating-system account and process visibility/permission domain.
Tests retain a live process owned by
that account and retain remote ownership despite old heartbeats. Running a
shared library's workers across OS accounts is not qualified for automatic
pruning. A positive PID check is conservative, including a reused live PID;
the stored process-start token is a RAG identity, not an OS birth token.

The 12 September smoke reproduced this boundary even under the same account:
a restricted observer reported all nine active controller/worker PIDs missing,
while an observer with the launcher's process visibility reported those exact
PIDs alive. The paired public reads are retained in
[the continuation evidence](qa/operator-continuation-20260912/). Never use a
restricted missing result to prune a group launched outside that visibility
domain. Retain this as a separate upstream improvement; this evidence does not
justify replacing processes with threads. The proposed CREXX result
should distinguish alive, missing and unknown/error; RAG must then retain
uncertain ownership rather than automatically pruning it. This richer result
and its consuming guard are not implemented or qualified by this decision.

## SQLite heartbeat contention and diagnostic ownership

The 2026-09-09 eight-worker smoke completed ingestion, then maintenance lost one
worker on its first heartbeat after approximately the five-second SQLite busy
wait. Its diagnostic was blank because RAG called `sqlitefinalize` before
reading the error. The installed provider correctly clears a session's previous
diagnostic on each normal call; this was a RAG error-handling defect.

An independent-connection regression reproduces the same blank error under
writer contention. RAG now captures diagnostics before cleanup and retries only
`SQLITE_BUSY`/`SQLITE_BUSY_RECOVERY`, at most three attempts with the existing
five-second busy timeout and 100/200 ms pauses. It logs each retry and retains
the final error on exhaustion. Constraints, missing process rows and
`SQLITE_BUSY_SNAPSHOT` remain errors; no transaction or provider call is replayed.
The regression releases its writer only after observing the first retry and
requires recovery on the same heartbeat on both VMs.

The live SQLite code was erased and cannot be recovered retrospectively.
Writer contention is supported by the timing and reproduction, not proven by a
retained live code. The original smoke evidence is in
`/Users/adrian/testrag/overnight-browne-luna-8w-20260908/channel-release-smoke-2h-20260909/`.

The embedding remediation extends supervisor tolerance to four bounded heartbeat
cycles while preserving the low-level heartbeat contract. It also removes repeated
busy-batch census checkpoints and unused chunk catalogue work. Embedding-only
maintenance skips cognitive census categories. These are RAG orchestration and
query changes; the SQLite provider contract and worker-process architecture are
unchanged. Scale qualification must still use a consistent full corpus copy.

The subsequent 10 September live embedding run exposed additional transaction
start failures in work claims, reservations and provider receipt/admission.
Those paths discarded the SQLite diagnostic and exited as generic failures,
which the controller deliberately did not replace. Contention is consistent
with the retained heartbeat diagnostics and writer workload, but the old generic
errors cannot prove their exact SQLite result codes retrospectively.

The [15 September ISSUE-01 repair](worker-pool-repair-20260915.md) removes that
exit-code exclusion: every unexpected registered-worker exit is eligible under
the existing replacement limits. It also preserves errors during exit-state
writes and removes a secondary panic after pre-claim checkpoint failure.
These are product fixes; they do not retrospectively identify the SQLite cause
of the earlier incidents or require a CREXX provider change.

The current candidate consolidates four reservation-ledger scans under the
writer lock into one indexed pass, parks quota-blocked work until capacity can
return, and shares bounded transaction-start retries with preserved diagnostics.
Only ordinary busy/busy-recovery is retried, before executing any transaction
body. Safely settled workers exhausting that path now use the existing bounded
replacement classification. The user chose the live job, including 15 minutes
with eight workers followed by 15 minutes with sixteen, as the immediate test.
The eight-worker measurement completed in 926 seconds with 581 newly covered
chunks, 450 successful calls and no new failed items. At the user's request,
the sixteen-worker sample ended after 416 seconds: 212 covered chunks, 173
successful calls, 78 transaction and 9 heartbeat busy retries, and no new
failed items or replacements. All sixteen workers drained cleanly. Eight
workers then resumed the same job. This demonstrates live recovery inside the
retry loops; it does not qualify replacement after exhausted retries or Codex
transport recovery. Evidence is in
`/Users/adrian/testrag/embedding-remediation-20260910/BENCHMARK.md`.

## Provider lifetime

HTTP adapters use operation-scoped provider instances. The Codex adapter keeps
one App Server child and its byte channels for the lifetime of a worker.

### Proposed native embedding capability

The current local embedding integration uses the OpenAI-compatible llama.cpp
endpoint. An in-process inference provider is proposed in
[CREXX-NI-01 through NI-06](https://github.com/adesutherland/CREXX/blob/develop/docs/planning/native-inference-backlog.md),
captured 2026-09-11; it is not supplied by the installed CREXX package described
here. CREXX owns its native library, model lifecycle, CPU/Metal support and
packaging. The product's provider selection, persistent request scheduling,
embedding profiles and migration requirements are in
[RAG-QE-04, QE-07 and QE-08](query-engine-backlog.md).
Use existing long-lived worker facilities; a new attached-worker architecture
or durable-service framework is not a prerequisite. This is a future capability
dependency, not a regression in the supported HTTP route.

### Long-lived Codex channels: completed-request retention

Repaired upstream and installed on 2026-09-09 in clean CREXX commit
`5ccf057a1633652a7b506bb52acc89ba2e064263`. RAG explicitly releases observed
terminal Codex byte requests and supervised child-process requests with the new
`.channelrequest.release()` API. Saved completion values remain usable. Pending
timeouts are cancelled and reclaimed by whole-channel cleanup; they are not
released before terminal observation. Rebuild RAG with the matching installed
class library and runtime; an old native executable retains its old archives.

The original defect was reproduced against installed clean CREXX commit
`7de12145a0695a81b345eeff8405203c23586e8c`. The private channel core retains
observed completed tickets until channel close. Its context-wide ceiling is
65,535 tickets; the next start returns `RXVM_CHANNEL_RESOURCE_EXHAUSTED` (8).
The byte provider also retains request state until close. Destruction visits
oldest tickets while removing them from a newest-first linked list, making
cleanup quadratic in the retained request count.

A standalone, zero-network probe linked to the installed archives completed
65,535 synchronous byte-channel operations, observed all 65,535 tickets still
live, and reproduced status 8 on operation 65,536. Closing took 14.377 CPU
seconds, versus 1.175 CPU seconds for the successful operations; all tickets
were released only at close. The probe used approximately 19 MB resident
memory. Evidence and source are in
`/Users/adrian/testrag/worker-identity-repair-20260909/runtime-diagnosis/`.

The live eight-worker run developed the same status in one Codex worker after
about an hour. Samples of that worker and an otherwise successful worker put
cleanup in `byte_channel_request_destroy`. The exact live ticket count was not
captured, so slot exhaustion in that process remains an inference supported by
the reproduced runtime mechanism. Generic status 8 can also cover allocation
or thread-creation failures. This is distinct from Google's HTTP 429 response.

RAG now stops new claims on an unhealthy transport, preserves successful
responses and uncertainty holds, and supports replacement after worker exit
under a durable job-wide ceiling and the original budgets/deadline. This is
application recovery, separate from request reclamation. A replacement waits
for the old process to exit. Provider cleanup attempts each resource even when
an earlier channel operation fails. The Codex protocol gate exercises 17,000
account cycles on one adapter (over 68,000 byte requests), beyond the former
unreleased-ticket ceiling. Upstream local qualification and installation are
documented in CREXX `concurrency/CHANNEL-REQUEST-LIFETIME.md`; Linux/Windows
qualification remains separately owned upstream.
Completed-request reclamation and cleanup complexity belong in CREXX; this
repository must not hide them with a second transport implementation.

## Installed Linux replay

The exact installed-package Linux replay of the hosted-provider path remains a
separate platform qualification. macOS evidence must not be represented as
Linux qualification.

## CREXX project-build scaling

Closed upstream and installed locally on 2026-09-06 in CREXX
`crexx-1.0.0-beta.3+local.g7de12145a069` (clean commit
`7de12145a0695a81b345eeff8405203c23586e8c`). The application uses the normal
optimised installed project build again.

The upstream repair limits inline-contract inspection to declarations,
registers binary forward class declarations before source fallback, and uses
member dependency snapshots for incremental invalidation. Its 48-member RAG
qualification measured 509.45 to 70.98 seconds for the release application and
156.18 to 11.53 seconds for ADDRESS. An unchanged build compiled zero members;
a private edit compiled 14 instead of 48. Strict metadata/link checks remain.

Evidence: the CREXX repository's
`performance/evidence/2026-09-06-rxc-project-scaling-qualification/README.md`.
The subsequent RAG recovery/configuration build also completed with this
installed compiler; logs are in
`/Users/adrian/testrag/rag-issues-20260906/`. Compiler scaling and corpus runtime
remain separate measurements.

## cREXX lexical scope at mixed branches

The earlier branch-local value-merge diagnosis was incorrect. A grouped `DO`
arm creates a local scope while a single-statement arm executes in the
enclosing scope, so implicit first assignments with the same spelling can
legally create different variables. CREXX now reports `#NOT_IN_SAME_SCOPE` for
that ambiguous implicit-binding shape; this is source scoping plus diagnostic
coverage, not a register-allocation defect.

`crexxrag` explicitly declares the provider-result object in the enclosing
scope when both branches are intended to assign one joined value. The existing
application regression retains that source-level contract.

## Interactive input

**Recorded upstream repair; installed route verified 12 September 2026.**
The earlier outstanding extra-Enter label was stale. Repository history records
three distinct fixes:

| Issue | Cause | CREXX repair |
| --- | --- | --- |
| #670 | `linein()` probed beyond the newline and waited for another character. | `1d69fa79c`, 25 August |
| #669 | The driver's `ADDRESS CREXX` launch substituted null input instead of inheriting stdin. | `1eb26ab89`, 25 August |
| #678 | Child process-group ownership conflicted with terminal access/restoration. | `b64f67a00`, 28 August |

Installed `crexx -version` reports `1.0.0-beta.3+local.g5ccf057a1633`; all three
repairs are ancestors of that build. Scratch copies of the existing CREXX
`lib/rxfnsb/tests_functional/ts_linein_stdin.crexx` were run through that
installed driver with `linein_stdin_harness.c` and `linein_tty_harness.c`. Both
passed after one newline, with the former keeping its input pipe open and the
latter using a real pseudo-terminal. These are focused macOS installation
checks, not a new full or cross-platform QA run.

Retain pipe, real-terminal and terminal-restoration regression coverage when
changing process launch or input handling. These repairs are separate from the
PID permission-inspection limitation above and do not establish a reason to
replace process workers. After reviewing a plan, `--yes` remains the normal
explicit automation path; it is not a required workaround on this installation.

## RexxScript configuration boundary

RexxScript can be called as a function and is relevant to future configuration
or rule authoring. The current product does not need it: strict declarative
configuration and bounded TSV glossary/profile data cover all present operator
controls without executable selection. Introducing RexxScript solely because
it may become more powerful would add a second authoring path without a current
requirement, so integration is intentionally deferred rather than treated as a
missing capability.

## Policy-file publication metadata and durability

The installed `rxfs` API provides file creation and same-directory rename but
no mode/ACL preservation or file/directory fsync contract. Policy edits therefore
publish validated complete bytes using the new file's process-default metadata;
they do not promise preservation of custom permissions or power-loss durability.

**Accepted limitations, agreed 12 September 2026:** custom ACL/mode preservation
and policy-file power-loss durability are outside active defect work. Normal
process-default metadata and manual restoration of the policy after a sudden
power failure are acceptable for the current use case. No new filesystem layer
or upstream flush API is required for this work plan. Any future generic API
would belong in CREXX. Ordinary replacement is locally qualified on macOS;
non-macOS replacement remains a separate QA-03 qualification requirement.

This acceptance applies only to policy-file replacement. Keep candidate
validation, hash checks, staged rename and ordinary process-crash recovery.
SQLite WAL/FULL settings, transactional publication, provider receipts,
cumulative usage and uncertain-outcome recovery remain required protections.

A stable adjacent SQLite coordination file serializes cooperating policy editors.
It stores no policy and no library data. Native process death releases its lock;
an orphan staging file is never selected as policy. External editors do not use
this lock. Rechecking the target hash catches ordinary stale edits but cannot
make their arbitrary writes participate in an atomic compare-and-swap protocol.
