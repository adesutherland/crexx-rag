# CREXX and platform integration issues

The [consolidated roadmap](ROADMAP.md#other-qualification-research-and-upstream-dependencies)
maps these dependencies and qualification limits to the product backlog.

These are current boundaries. Any source-level containment used by the product
is stated explicitly.

## Worker execution architecture

CREXX now supports declared native-provider discovery and isolated RXPA
sessions in attached task VMs, including the installed `rxsqlite` provider.
The former discovery integration gap is closed upstream.

`crexxrag` continues to use operating-system worker processes by product
design. Every process starts a fresh VM and opens its own SQLite connection,
which is supported and covered by regression tests. Moving work into attached
tasks would be a separate architecture and recovery-policy decision; native
SQLite handles would remain VM-local and must never be transferred.

## Local process liveness and permission boundary

The installed `ADDRESS CREXX ps PID` reports a POSIX `kill(pid,0)` failure as
not found, including permission denial. It does not expose the distinction
between `ESRCH` and `EPERM`, or an operating-system process birth identity.
This was confirmed while testing restart ownership on 10 September against
the installed `5ccf057a1633` route. Native changes belong in CREXX.

RAG's automatic restart/prune qualification covers its local workers launched
under the same operating-system account. Tests retain a live process owned by
that account and retain remote ownership despite old heartbeats. Running a
shared library's workers across OS accounts is not qualified for automatic
pruning. A positive PID check is conservative, including a reused live PID;
the stored process-start token is a RAG identity, not an OS birth token.

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

The current CREXX line-input behavior can require an additional Enter after a
confirmation prompt on affected builds. This is a known CREXX issue; the
product does not carry a duplicate roadmap entry. Interactive use remains safe
because no apply begins before an affirmative answer is read. After reviewing
the displayed plan, use `--yes` for automation and repeatable smoke tests; that
path does not read stdin and is not affected by the extra-Enter behavior.

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
A generic metadata-preserving durable replacement API belongs in CREXX, not a
product-specific native bridge. The current route is locally qualified on macOS;
Windows replacement and crash/power-loss behavior need separate qualification.

A stable adjacent SQLite coordination file serializes cooperating policy editors.
It stores no policy and no library data. Native process death releases its lock;
an orphan staging file is never selected as policy. External editors do not use
this lock. Rechecking the target hash catches ordinary stale edits but cannot
make their arbitrary writes participate in an atomic compare-and-swap protocol.
