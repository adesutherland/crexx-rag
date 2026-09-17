# Maintenance follow-up delivery — 17 September 2026

Status: all eight local delivery criteria passed; installed in ScottishHistory.
Live contention and content-quality qualification remain open. The approved scope and
numbered acceptance criteria remain in [the plan](maintenance-follow-up-plan-20260917.md).
The [master register](ROADMAP.md) owns current qualification. No commit, publication
or new live soak is included. Preserve the existing Luna Low / Sol Medium routes
and the operator's 1% allowance floor.

## Regression-first evidence

The eight affected baseline cases retained exact-input passing receipts (0.11s).
New compiled configuration and supervision assertions rejected explicit 24 against
the old ceiling. New prompt, alias packet and interrupted-call tests reproduced
missing split/OCR guidance, offered migration parents without lifecycle state,
and original timeout loss on exact-turn reconciliation. A 70,011-character event
reproduced `string field is too long`, including with a page limit of one.

Evidence is under `out/maintenance-follow-up-20260917`: `baseline-tests.log`,
`restart-red.log`, `evidence-red.log`, `contention-events-red.log`. The first
large-event fixture also changed the known missing-request total from 102 to
101; that expectation was corrected before the rendering reproduction. The
initial parallel lock fixture blocked connection startup; it was corrected to
open all eight connections before holding the writer lock. Its startup failures
are not checkpoint measurements. The original independent-connection checkpoint
regression did reproduce fatal BUSY handling before the implementation change.
A proposed split assertion initially called only the evidence validator with
noncanonical fixture IDs. The final control calls the lifecycle owner with a
real canonical child identity and checks the specific rejection and unchanged
generation. These fixture corrections do not weaken product acceptance.
Focused native checks also caught a conversion error in the new elapsed-step
calculation: subtracting untyped clock strings inferred floating-point division,
whose fractional value cannot be cast to an integer. A tiny isolated probe
reproduced it; explicit integer microsecond samples fix the calculation. This
is a product implementation correction, not an upstream CREXX defect.
The added deadline fixture also initially left its synthetic capacity window
active, conflicting with the following checkpoint fixture. Closing that completed
fixture restores their isolation; the single-active-window invariant stays strict.

## Owning changes

- `ragworkerdefaults` accepts explicit 0–24 replacements; omitted/default two
  and canonical identity remain unchanged. `ragsupervision` and `ragprocess` consume the shared
  bounds instead of carrying separate ceilings. The native eight-worker test
  reproduced the remaining controller refusal before its repair.
- `ragbacklog` avoids a checkpoint writer transaction while an active funded
  batch still has queued/running work. Drained batches, expired windows, budget
  closure and stop controls retain the normal path. Actual admission still
  rechecks bounds in its transaction. `ragwork` reschedules only a BUSY before
  checkpoint BEGIN; no claim, transaction body or provider request is replayed.
- Failed-lock timestamps come from SQLite's UTC clock without a write, avoiding
  the runtime's misleading civil-time/offset combination. Original SQLite
  error boundaries remain classifiable. Persistent failed acquisition remains
  an explicit bounded error on the checkpoint API and diagnostic stream.
- `ragapplicationprovider` preserves the original failure and measured wait
  when exact-turn inspection confirms interruption. The provider step's elapsed
  time includes preflight/submission/reconciliation on every called outcome;
  existing accounting retains admission wait. `job inspect --section timing`
  separately exposes provider elapsed, admission wait and known usage completeness.
- `ragoperationsquery` bounds large event previews and supplies original length,
  byte count, SHA-256 and an item/attempt section reference where available.
  Full retained requests/responses remain paged by `job inspect`; small events
  keep their existing fields. Timeout and disconnect filters preserve the
  original cause alongside the terminal interruption.
- Alias candidates are active only and expose lifecycle state. Apply-time
  checks still reject mid-call retirement. Existing bounded retries and evidence
  refresh/supersession retain old attempts, usage and decisions.
- Resolution contract 4 explains parent-duplicate splits, supported alternatives
  and final no-change. The shared quotation owner explains literal OCR/newline
  escaping in initial and correction prompts. Validators remain strict.

## Measured checkpoint and candidate evidence

The same eight-connection, 160-poll fixture was rerun with the installed baseline
`ragbacklog` owner compiled in a private module directory, then with the current
owner. All connections open before the competing writer begins. The baseline
records 160 failed BEGINs per VM: 5,710ms summed lock wait / 0.771s wall on RXVME,
and 5,701ms / 0.764s on RXBVM. No transaction body begins and neither fixture
changes retained state. The repaired owner completes all 160 read-only polls
without a failed BEGIN or state changes (RXVME 0.051s; RXBVM 0.043s). The current
required regression separately verifies persistent lock error reporting,
nonfatal worker scheduling, UTC clocks, normal reconciliation, call counts and
rolling replacement controls. This measures redundant checkpoint admission;
it does not identify every competing writer or establish live task throughput.

The sampled British candidate was rejected as inactive at 09:55:53 UTC and
again in the 10:31:02–10:31:12 call, over 35 minutes later. Saved responses show
reuse in both cases; no split/restore response names that concept during this
run. This supports the already-inactive packet-selection explanation for the
sample, rather than attributing it solely to a change during the sampled call.
It does not classify all 25 inactive-candidate failures. The regression covers
both already-inactive selection and a separately simulated mid-call retirement.
`sample-identity-history.json` retains exact item/attempt facts.

## Qualification and delivery

All **124 required local cases pass** on the stable native/linked artifact.
`qa-report.json` and `qa-report.txt` account for every fast, component and
integration case; there are no disabled, missing or failed required receipts.
The scale lane and hosted live calls are separate and were not run in this batch.

The full-gate CTest invocations took **409.09s (6m49s)**: 38.61s, 98.42s and
272.06s. Two existing assertions needed alignment with the approved contracts:
`regression_policy_file` now rejects 25 and positively edits 24; `native_receipts`
retains exact original receipt-time conversion for expired/recovered calls while
allowing ordinary total provider-step time to exceed transport latency. Both
now pass. No product rebuild was needed for these assertion updates. The final
invocation executes 21 cases and reuses 103 exact-input passes, including earlier
focused acceptance; reuse is audited, not counted as an unexplained skip.
This is full-gate runtime, excluding earlier regression-first development,
builds, receipt-report generation and installed checks.

The frozen contract review preserves all four response-schema hashes. Only
extraction and resolution system-prompt hashes change, for the approved OCR and
split instructions. Metadata changes only the `rag_job_events` description;
78 total tools and 37 read tools remain unchanged. Exact reviewed differences
are in `prompt-review.json` and `metadata-review.json`.

Installed candidate, based on `6b706308220b43bcf163c79410f879f850169f2e` plus
uncommitted changes (not a new published SHA):

- Native SHA-256 `5da3e47db632771b27be323cdcb52ba9ec85a1f56c24ad09445e37379fe43b84`.
- Linked SHA-256 `3038ff23ebe696b8162aad830a9f7466479b6949934d78582a7c8447b2472c3a`.
- Installed into `/Users/adrian/Documents/ScottishHistory/tools` without rebuilding.
  Previous tools remain in `backups/tools-before-maintenance-follow-up-20260917`.
- The only policy-file change is `worker.max_restarts = 24`. Public set and exact
  plan/apply classify it as operational, retain the semantic hash and register
  snapshot `config-0d0407bfbe18ae0e757c3412`. A fresh public diff is identical.
  The rolling window remains the existing 3600s default, across the whole job.
  Omitted configurations elsewhere still default to two; historical jobs keep
  their recorded policy. Eight workers, Luna Low, Sol Medium, all other settings
  and the operator's 1% floor are unchanged.
- Installed doctor (including integrity verification), CLI status/config/prompt
  checks and a fresh five-call read-only MCP smoke pass. All ten previously
  unreadable corpus events now return bounded previews, exact original body
  hashes and correct cursors. Existing paged inspection retains full bodies.
- Schema 19, generation **28,711**, zero integrity issues. All 40 job records
  match the preinstallation snapshot; all 29 historical process registrations
  remain stopped/failed with no live process. No provider call or new job was
  started. Historical missing timing/cause facts are not invented retroactively.

The Scottish record is `reports/maintenance-follow-up-20260917/INSTALL.md`, with
exact policy plan/apply, before/after reads, source patch/untracked files, QA
receipts and artifact identity. Existing MCP sessions should reconnect to load
the new executable. No commit, push or release was made.

## Remaining live question

Recommend one separately authorized, comparable one-hour maintenance soak on
this installed policy: eight workers, Luna Low / Sol Medium and the 1% floor.
Use the same lightweight five-minute observations and fixed end time. Compare
checkpoint lock failures/waits, worker loss/replacement, throughput, incomplete
usage and failed/accepted ordinary versus advanced decisions. Inspect concrete
input/output examples for inactive identity, split and quotation failures.
Do not reset tasks, expand budgets or extend the window implicitly. The local
fixture repairs are complete; identification of every live competing writer and
improved corpus-level prompt effectiveness remain open until that run.
