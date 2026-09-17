# Essential work inspection — approved

**Status: approved scope implemented and locally qualified; bounded copy run complete.**
See [delivery and acceptance evidence](observability-delivery-20260916.md).
This replaces the broader proposal. Current status belongs in
[ROADMAP.md](ROADMAP.md), under RAG-OPS-003; the
[run evidence](maintenance-acceptance-triage-20260916.md) explains the need.

## Outcome

Find useful examples, see what actually went in and came out, and understand
why they succeeded or failed. Use that evidence to improve prompts and investigate
the slowdown, without assuming authentication or database contention was its cause.

## Three things to deliver

### 1. Find examples

Extend existing job/item lists with a small set of combinable filters:
job or time range, work type, model, prompt identity, outcome and error category.
Support one job or an explicitly selected search across jobs in this library.
Return compact, paginated results with task, item and attempt IDs.

Essential searches: failed quotation checks; failed versus successful corrections;
advanced no-change versus applied change; authentication, timeout and database-lock
errors. A corrected success must still expose its original failed attempt.

### 2. Inspect one example

From a result or task ID, follow its attempts directly. Show:

- Exact submitted prompt and evidence, model/effort and prompt identity.
- Returned response, validation error and any correction input/output.
- Final outcome, timestamps, elapsed time and usage.
- Links between ordinary, advanced and recovered attempts.

Reuse retained inputs, receipts and decisions. Capture only missing facts needed
for these fields. Historical gaps are labelled unavailable; never regenerate an
old prompt from today's configuration. Load large bodies only when selected,
with paging and a completeness indicator. Preserve credential redaction and
existing read/diagnose permissions. Inspection makes no model calls or changes.

### 3. Explain a run

Extend the existing job summary with success/failure counts, common errors and
links to examples. Keep task, item and provider-call counts distinct. Include
recorded restarts and flag incomplete evidence.

Add only the timing needed for the observed problem: provider-call duration,
authentication/error events, and lock-wait versus transaction duration at the
maintenance checkpoint and claim-context checks. Include timestamp, worker/item
where available, operation and original error. A failed lock acquisition must
remain observable even when the database cannot accept a diagnostic write.
Reuse existing receipt/event/diagnostic paths, and surface the relevant records
through inspection. Do not log every SQL statement or every idle poll. This
provides a sequence of observations, not an automatic root-cause verdict.

## Implementation and validation

1. Inspect retained data and relevant regression coverage; add missing tests
   first. Implement filtered reads and example inspection using existing owners.
2. Add the small diagnostic fields/timings and summary. Use existing Level-G
   query, receipt, usage, backlog and tracing modules; keep adapters thin.
3. Run affected tests while iterating and account for the full required local
   gate once on the stable build. Use isolated parallel fixtures and reuse
   unchanged passing receipts. Document the commands and examples.
4. Rerun once on an isolated Scottish corpus copy: up to 30 minutes or 300 provider
   calls, whichever comes first; same prompts/models, eight workers, zero monetary
   budget, minimum 10% Codex allowance, five-minute checks. Finish with stopped
   workers, one verification and a short findings report. Leave the master
   installation and corpus unchanged.

Use synthetic fixtures for authentication failure, slow valid responses and lock
contention; do not deliberately expire real credentials. Approval of this plan
covers these steps and the bounded copy run, not a commit, push or release.

## Six acceptance criteria

1. **Find:** the example searches above work through CLI and MCP using filters
   and returned IDs, without SQL, private files or scanning unfiltered job pages.
2. **Inspect:** both successful and failed examples expose their original input,
   output and outcome; correction/escalation history stays linked. Old missing
   data is explicit, and changing a current prompt cannot alter an old record.
3. **Diagnose:** controlled authentication failure, slow provider and database
   contention cases produce distinguishable errors and timings. Failed lock
   acquisition is visible; unknown causes and missing timing remain explicit.
4. **Report:** summary counts agree with underlying examples and usage; retries
   and reused responses do not invent or double-count calls. Operators can move
   directly from a summary error to an example.
5. **Stay safe and efficient:** queries filter before paging and avoid loading
   bodies in lists. Measure read latency and recording overhead on an isolated
   corpus-sized fixture; investigate material regression before delivery.
   Inspection is read-only, secrets stay redacted, and recording does not change
   task, retry, recovery or deadline behavior.
6. **Qualify:** relevant regressions and the required local gate pass, then the
   bounded copy run provides a report, inspectable examples and clean closeout.
   If contention does not recur, report non-reproduction rather than a fix.

## Kept out of this change

No dashboard, new reporting framework, general query language, automatic prompt
optimisation, broad tracing, new retention service or speculative recovery fix.
Keep models, prompts and processing policy unchanged so the rerun is comparable.
Any new storage/index is limited to the fields needed above and preserves old
records. CREXX #699 is fixed locally per Adrian; the installed version header
identifies `94f2f228c31339f87bb66b714724bdb4ed3a8420`. It is not a blocker.
