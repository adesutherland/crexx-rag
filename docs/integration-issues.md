# CREXX and platform integration issues

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

## Provider lifetime

HTTP adapters use operation-scoped provider instances. The Codex adapter keeps
one App Server child and its byte channels for the lifetime of a worker.

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
