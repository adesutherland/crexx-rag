# Public recovery journey — OPS-001/002/003

This is the third approved follow-up, after UX-03 and UX-04. The local
implementation adds reasoned task waivers, complete status observations and
recovery of an older unfinished workflow marker. It composes existing public
controls and preserves the original task outcomes, calls and allowances.
Broader fresh-operator, hosted, platform and long-run qualification remains open.
OPS-005 budget renewal is still separate design work.

## Operator path

Use the tested installed `crexxrag`, the intended library and its ordinary
policy file. No build, database edit or repair script is an operator step.

1. Read `library status`, `library report --narrative off` and `job list`.
   Follow returned page cursors. Select a job from its real identity and
   creation time; job IDs are not chronological.
2. Read `job status JOB_ID --seconds 300`, `job items JOB_ID --state dead_letter`
   and `job events JOB_ID`. Item detail exposes its durable task identity;
   `maintain tasks` and `maintain inspect TASK_ID` expose evidence, attempts,
   retry disposition and the latest waiver. Resolve actual source citations
   before drawing conclusions about corpus content.
3. Recover safely retained output using the existing digest-checked
   `job reconcile` preview/apply journey where supported. An unknown provider
   outcome remains held; repeating a retry or waiver cannot authorize a blind
   paid repeat. See [receipt recovery](receipt-recovery.md).
4. Request reconsideration with `maintain retry TASK_ID --reason REASON`
   or `job retry JOB_ID --item ITEM_ID --reason REASON`. Acceptance is durable
   and idempotent; the returned disposition explains whether execution is safe.
   Existing compatible jobs use `job run JOB_ID`. Closed maintenance windows
   need an ordinary new reviewed `maintain plan` / `maintain apply` and worker
   execution. The old window, paid attempts and ceilings remain unchanged.
5. If the operator accepts leaving this exact question unfinished, settle its
   active work and pending reviews, then run
   `maintain waive TASK_ID --reason REASON`. This requires control access.
   Inspect the retained reason and `operator_disposition: waived`. Missing
   embeddings remain missing. A later explicit retry reopens the waiver under
   the same limits; it does not renew an exhausted allowance.
6. For an external migration, discover `maintain workflows --concept 'Label'`
   and follow [workflow reconciliation](external-workflow-recovery.md).
   `complete-retired-workflow` means a retained, published retirement can finish
   an old workflow marker without another generation, task or provider call.
   Remaining graph impact, active ownership, reviews and unknown outcomes still
   prevent completion. `waiting-retired-impact` requires investigation.
7. Repeat status and report reads. Distinguish current coverage, original
   failed items, resolved historical failures, waived failures and remaining
   actionable work. A waiver is never evidence that a source was processed.

The native CLI and MCP share the same command catalogue and owner procedures.
MCP adds `rag_task_waive({id, reason})` with control access; explicit
`rag_task_retry` reopens it. `rag_job_status({id, seconds})` accepts 1–86400
seconds, default 300. Workflow preview/apply uses the existing UX-04 tools.

## Status and reporting contract

`planned_total` is the number of materialized items, equal to queued + running
+ processed + skipped + dead_letter + cancelled in one read snapshot.
Cancel-requested items count as running. `item_limit` is the separate reviewed
allowance. Stored old job state is projected through the shared lifecycle rule;
unknown outcomes can keep a job paused even when its original window closed.

`recorded_provider_runs` counts distinct run identities linked to job attempts.
Recorded token/cost totals retain failed calls and cannot multiply through
multiple attempt links. `uncertain_items`, `incomplete_usage_observations`,
`unpriced_runs`, `other_provider_runs` and `timestamp_unknown_runs` qualify those
amounts; zero recorded cost is not a claim that all usage is known.
`interval_processed` and `interval_skipped` count item outcomes by their recorded
update time. Provider interval counts use recorded completion time; unknown
timestamps cannot be assigned to an interval. `processed_per_minute` divides
accepted items by the explicitly reported interval. Correction-requested items,
correction-processed items and interval correction completions are separate
counts. Provider attempts are not unique source coverage.

Library reports retain original task/job/item totals and vector coverage.
`resolved_dead_letters` includes successful later maintenance windows;
`waived_dead_letters` and `waived_tasks` expose explicit dispositions, while
`unwaived_open_tasks` and `actionable_dead_letters` expose remaining work.
Historical health totals can still draw attention to retained failures; inspect
these named reconciliation fields rather than interpreting history as new work.
The report's named `operator_dispositions` context is also part of its cache
comparison, so a waived/reopened question cannot reuse a stale narrative.
The existing positional durable-census array and response schema are unchanged.

## Module ownership and compatibility

- `raglifecycle` owns waiver/reopen rules, identity, uncertainty and retry
  dispositions. `ragbacklog` owns the transactional public task operation and
  excludes active waivers at its shared dispatch/proposal gate.
- `ragmaintain.publishedretirement` proves the retained lifecycle history;
  `ragbacklog._censusworkflow` checkpoints compatible old workflow markers.
- `ragwork` owns job item counts and correction/interval facts. `ragusage`
  owns recorded provider amounts and their uncertainty qualifiers.
  `ragoperationsquery` composes these with supervision in one read snapshot.
- `ragreportservice` owns one named disposition projection for both public
  report context and narrative cache validation. No duplicate prompt policy
  or correction protocol was introduced.
- `ragproduct` is the command adapter; `ragcommandcatalog` remains the only
  operation/MCP schema and capability catalogue.

Schema 15 adds the immutable waiver ledger and extends the historical
reconciliation view. Read-only schema 13/14 inspection remains non-mutating;
the ordinary writable open upgrades to 15. Earlier migration statements and
checksums remain unchanged. A waiver keeps the task's evidence/policy identity,
original reason and creation record. Its only update is a one-way reopening
linked to a retained retry request; deletion or rewriting identity is rejected.
Repeated closure/reopening cycles retain distinct records without resetting
attempt counts. Different future evidence/policy may create a different task.

## Regression evidence

Baseline `9f4c76e` passed all 59 tests. Before product edits, the extended native
recovery cases reproduced wrong item denominators, missing limits/usage/interval
status and missing waiver commands (two expected failures, 22.74 seconds).
The workflow case reproduced the old retired-parent/unfinished-marker error
in 12.16 seconds while its earlier controls passed.

Schema 13/14/15 migration, immutable waiver/reopen history and native recovery
checks were added before their implementations. A later public report regression
failed in 33.70 seconds before named dispositions were added. The real citation
correction fixture also reproduced missing correction outcome metrics before
adding them to the status owner. Metadata review found exactly one added tool
and the optional status interval; no other tool schema changed.

The focused gate passed **6/6 in 195.80 seconds**. The three real correction
cases reported respectively requested/processed counts of 1/1, 1/0 and 1/0;
the failed and budget-held cases retained their distinct provider-call counts.
A frozen scratch installation passed both native recovery journeys: five
recoverable failures used exactly five calls, while the held variant recovered
three, kept two embeddings missing, and exercised waiver/reopen with original
attempt/receipt/usage history unchanged. The frozen held journey took 42.81 seconds.

The native SHA-256 is
`b9f9ff361dfc3ed6428c994eeff752676f22fd281a68a1e62b83e6a5696bbf43`;
the linked application SHA-256 is
`6a2b11cc9aa9191ca6f9613bc4717a44325e7f9f4e52da737ad09f6c16b55619`.

The first full run encountered an environmental timeout in `process_workers`:
the Mac entered idle sleep at 19:26:52 BST and woke at 19:33:24 (392 seconds).
Retained output shows all eight workers completed successfully, followed by
drain, stale detection and pruning; the sleep interval explains the 409.89-second
elapsed timeout. Its scratch state and power timestamps are retained under
`/private/tmp/recovery-process-timeout-evidence` and
`/private/tmp/recovery-process-sleep-evidence.log`. With idle sleep prevented,
the unchanged two-VM process test passed in **36.61 seconds**. No test timeout,
product budget or assertion was relaxed. The complete gate is repeated under
a temporary `caffeinate -i` assertion that ends with CTest.

The second full run finished **58/59 in 1592.96 seconds**, with only the existing
`regression_pages` test exceeding its 180-second aggregate limit. Its 49 completed
commands all returned success. The host load average had reached 96 on a
10-logical-CPU machine during a concurrent compiler/runtime batch; this same
artifact had passed the test in 32.67 seconds in the first full run. After that
batch ended and load fell to 4.61, the unchanged pagination replay passed in
**35.48 seconds**. The failed scratch state is retained in
`/private/tmp/recovery-pages-timeout-evidence`; load and replay evidence are in
`/private/tmp/recovery-pages-load-evidence.txt` and
`/private/tmp/recovery-pages-quieter-replay.log`. No product or test code changed
between these runs. The third complete run uses the quieter host and the same
idle-sleep guard, with the original test limits.

The first full run finished **58/59 in 1286.33 seconds**, with only the confirmed
host-sleep timeout. The final quiet-host run passed **59/59 in 1238.52 seconds**.
Configure, build and `git diff --check` also passed. The focused, frozen-install
and full runs used the same native/linked artifact hashes above. The product
namespace import audit found no cycles (runtime namespace extensions excluded),
and all relative document file targets in changed documentation exist.

Retained logs include `/private/tmp/crexx-public-recovery-full.log`,
`/private/tmp/crexx-public-recovery-full-sleep-interrupted.log`,
`/private/tmp/crexx-public-recovery-full-loaded-host.log`,
`/private/tmp/crexx-public-recovery-focused-final.log`,
`/private/tmp/recovery-frozen-journey.log`, `/private/tmp/recovery-frozen-holds.log`
and `/private/tmp/recovery-process-awake-replay.log`.
Loopback providers use synthetic credentials and data; no hosted spending or
user-library operation was performed. This qualifies the local implementation;
fresh human/agent discovery on a real copied corpus, hosted providers, other
platforms and sustained operation remain separate acceptance.
