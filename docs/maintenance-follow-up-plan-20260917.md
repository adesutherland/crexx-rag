# Maintenance follow-up — approved 17 September 2026

Current status remains in [ROADMAP.md](ROADMAP.md). This is one bounded repair
batch arising from the [17 September soak](maintenance-soak-20260917.md).
Approved by Adrian. Local implementation, all eight delivery criteria and Scottish
installation are complete; see [the delivery record](maintenance-follow-up-delivery-20260917.md).
The separate live contention/content-quality qualification remains open.

## Plan vision and outcomes

Keep maintenance a single operator job. A brief outage should recover the worker
pool without exhausting an unnecessarily small restart allowance. Checkpoint
contention should not repeatedly kill workers. Existing inspection commands
should explain failures accurately, and remaining prompt mistakes should receive
specific corrections while preserving strict source and identity validation.

Keep Luna Low / Sol Medium. Use the existing Level-G owners, configuration,
receipts, scheduling and recovery. No new supervisor, logging service, database
schema or general recovery framework is proposed.

## 1. Set a practical restart allowance

Set ScottishHistory explicitly to **24 worker replacements across the whole job
per rolling 3600 seconds**, with its existing eight workers. This is protection
against a restart storm, not a lifetime cap or a separate allowance per worker.
Twenty-four permits three complete pool replacements within the hour.

The current setting defaults to two and accepts only 0–10. Raise the supported
ceiling to 24 in `ragworkerdefaults`; make the duplicate check in
`ragsupervision` consume that owner. Set `worker.max_restarts=24` through the
existing public configuration workflow after the tested package is installed.
An explicit value solves this workspace's requirement without reinterpreting
older omitted settings or frozen job configuration. Zero still disables
replacement; explicit lower settings remain supported.

Retain the rolling counter, existing capped backoff (5s, 30s, then at most 60s),
shared provider cooldown, deadline and stop controls. A controller restart must
not replenish the allowance. Worker replacement must not consume or reset an
individual task's retry allowance or blindly replay uncertain calls.

## 2. Reduce checkpoint contention

Use the saved lock/body timings and a bounded local eight-worker reproduction
to identify the costly or repeated work inside the maintenance writer transaction.
Inspect `ragbacklog.tickbacklogwindow`, its callers and the shared SQL/transaction
helpers. The soak establishes contention, but not which writer caused each wait.

First correct diagnostic clock labeling and failed-call duration where needed
for reliable correlation. Use existing transaction diagnostics; add only a
missing operation-boundary measurement needed to explain the reproduced wait.
Then shorten or avoid the measured redundant checkpoint work, preserving atomic
state transitions and revalidation. Reuse existing admission/retry or scheduling
behaviour for a BUSY failure before a transaction starts when safe. Never replay
a transaction body or provider request as a lock-retry workaround.

Do not declare the problem repaired merely because 24 replacements conceal
worker deaths or because a timeout was increased. Record comparable lock entry,
transaction body, throughput and worker-failure results on the same fixture.
If evidence requires an architectural change, report that specific decision;
this plan covers bounded changes in the existing owners.

## 3. Finish the existing diagnostic surface

- **Large events:** keep event lists bounded. Oversized messages return an
  explicit preview/omission marker, length/hash and the existing item/attempt
  inspection reference. `job inspect` supplies complete original bodies. Paging
  must continue past the event; ordinary small messages remain compatible.
- **Interrupted calls:** record elapsed time on every outcome, separately from
  admission wait. Preserve incomplete usage instead of reporting invented zeros.
- **Failure cause:** retain the original timeout/transport cause alongside the
  later confirmed-interruption outcome. Existing error filters must find the
  example; do not classify every interruption as a timeout.
- **Clock labels:** use consistent UTC or the correct explicit offset on failed
  lock diagnostics, including the path where SQLite cannot record an event.

Owners: `ragoperationsquery`/`ragcommandcatalog` for public projections,
`codex_provider`/`ragapplicationprovider` and `ragreceipts`/`ragusage` for retained
facts, and `ragbacklog`/`ragtrace` for transaction diagnostics. Preserve redaction,
read-only inspection and the current capture/receipt boundaries.

## 4. Tighten the three remaining evidence contracts

1. **Inactive identities:** determine whether each sampled candidate was already
   inactive when dispatched or became inactive during the call. Correct evidence
   selection/lifecycle visibility in `ragbacklog`. Keep apply-time validation.
   Reuse existing refresh and retry/advanced controls for a stale decision;
   do not introduce unlimited automatic retries or silently substitute an ID.
2. **Invalid split successors:** make the existing rule explicit in the shared
   resolution instructions and correction feedback, including a small example.
   A successor must not reproduce the parent identity. Where the permitted
   actions cannot express a supported split, use the existing supported
   alternative or final no-change. Never invent a label to evade validation.
3. **Literal quotations:** add a concise OCR/escape example to the existing
   quotation/correction owner if the retained cases demonstrate the gap. Prefer
   an exact sufficient span around the selected occurrence. Keep the strict
   validator and the later-occurrence regression/negative controls.

Use `ragresolutioncontract` and `ragquotationcontract` for shared prompt text;
initial requests, corrections, public prompt inspection and external proposals
must agree. Preserve the effective prompt/schema identity and compatibility
rules. This is targeted contract clarification, not a general prompt rewrite.

## Acceptance criteria

1. **Restart policy:** file, typed config, runtime and public status agree on
   explicit 24/hour. Zero, two and 24 work; 25 is rejected. Omitted/old policy
   retains its recorded meaning and canonical identity.
2. **Pool recovery and limiting:** after two earlier replacements, five workers
   fail in a local eight-worker outage fixture; when the provider recovers,
   all eight slots return within existing backoff. Concurrent reservations
   cannot exceed 24; the next replacement waits until the rolling boundary.
   Controller restart preserves the count; cancel/deadline prevents replacement.
3. **Contention:** the reproduced checkpoint path and normal positive control
   pass with no avoidable worker loss under the agreed contention fixture.
   Query/lock measurements show the effect of the repair; completed work,
   task identities, receipts, accounting and publication invariants agree.
   A deliberately persistent lock still reports an honest bounded failure.
4. **Honest diagnostics:** a short synthetic interrupted call reports its full
   elapsed duration and original cause, remains searchable after reconciliation,
   and preserves incomplete usage/held outcomes correctly. UTC/offset values
   correlate across worker and public event records.
5. **Complete inspection:** oversized event pages work on CLI/JSON/NDJSON/MCP;
   cursors skip nothing, full bodies reconstruct through inspection with exact
   hashes, small messages remain compatible, secrets remain redacted and reads
   do not change the library or call providers.
6. **Identity freshness:** an active candidate succeeds; an already-inactive
   candidate is not presented as usable; a candidate retired during a call
   cannot be applied. The failed task exposes a supported bounded next action,
   with attempts, usage and history preserved.
7. **Prompt contracts and convergence:** valid split and literal-quote controls
   pass; parent-duplicate splits, normalized OCR and wrong occurrences remain
   rejected. Shared instructions clearly explain supported alternatives. Routine
   escalation and advanced final no-change remain available without cycling.
8. **Delivery:** targeted acceptance and the complete required local suite are
   accounted for on one stable artifact, with no disabled/missing failures
   disguised as passes. Installed read-only CLI/MCP/config checks confirm that
   artifact and effective 24/hour policy; no maintenance job is started.

## Efficient QA and delivery

Confirm affected baseline coverage and add the missing failure-plus-positive
controls before each implementation change. Extend existing configuration,
`regression_supervision`, `worker_recovery_*`, `regression_operator_diagnostics`,
`observability_providers`, backlog, grounding and prompt-inspection cases.
Use fake clocks for rolling-hour boundaries and local synthetic providers for
outages; do not wait an hour or disrupt real connectivity/authentication.

Run focused cases during development in isolated parallel directories. Never
rebuild over running tests. On the stable batch run the required full local gate
once, reusing unchanged exact-input passes and auditing the receipts. Keep live
provider and scale tests separate. Update the coverage matrix, owner/delivery
notes and master register with actual results and elapsed test times.

**Approval of this plan covers** the bounded implementation, local QA and
installation of the tested artifact in the idle Scottish workspace, followed
by the explicit 24/hour configuration and read-only smoke checks. Preserve the
user's 1% allowance floor and the current model settings. No task reset, waiver,
commit, push or release is included.

After delivery, propose one comparable, bounded one-hour soak to validate the
remaining live contention and prompt-effectiveness questions. The previous
window is closed; a new live run needs its own explicit authority. Local fixture
success will not be presented as that live qualification.
