# Task reset — restore a usable current task

Status: **implementation and QA complete**, all checklist items checked.
Adrian subsequently authorized committing this baseline and installing it in
ScottishHistory, including merged agent guidance. The installation receipt is
`/Users/adrian/Documents/ScottishHistory/reports/task-reset-install-20260915/`.
This follow-up does not authorize a push or resetting/processing corpus tasks.

## Agreed outcome

Implement `maintain reset TASK` and `maintain reset --all` through the shared
CLI/MCP catalogue. Reset repairs obsolete task context and blocking state and
clears effective retry counts. Success means the normal current software can
then resolve or close the task, including a justified no-change decision.
Do not merely clear a counter or report a successful UPDATE. `--all` covers
outstanding tasks and does not reopen completed decisions. Preserve source
documents and accepted knowledge; loss of obsolete task bookkeeping is accepted.
No broad rules audit, new recovery framework or historical-window reconstruction.
Fix only blockers encountered on the reset-to-resolution/closure journey.

Adrian authorized implementation and asking the Scottish agent for representative
blocked examples. Engineering uses scratch libraries; no master reset, provider
call, installation, commit or publication is implied. Existing ISSUE-01 edits
are retained, with its upstream CREXX #701 test exclusion already approved.

## Checklist

- [x] Confirm scope, current checkout and ownership; request Scottish examples.
- [x] Inspect relevant baseline/public tests and reproduce missing reset plus
  the old-policy/no-window resolution failure before implementation.
- [x] Implement one-task/all-outstanding reset in the existing task owner,
  reusing retry-count handling and current evidence/policy construction.
- [x] Prove effective retry counts are zero; obsolete review, waiver, retry and
  job links cannot block the reset task. Running work has an actionable drain
  outcome rather than a conflicting reset.
- [x] Prove reset -> normal resolution/closure on representative old task
  types through CLI/MCP, with source/graph preservation during reset and no
  automatic reopening of a closed decision on unchanged evidence.
- [x] Strengthen enduring simplification/recovery guidance and update user,
  agent, architecture and coverage records without duplicating domain rules.
- [x] Run affected acceptance, required QA and whitespace checks; report
  exact results, the known upstream exclusion and any remaining limitation.

## Ownership and baseline

`ragbacklog` owns maintenance-task context, evidence, decisions and state;
`raglifecycle` owns effective retry counts; `ragcommandcatalog` owns CLI/MCP
operation metadata; `ragproduct` remains a transport-neutral dispatcher.
Current native baseline is SHA256
`9825666f67bfa649af2896f38509e1a6d7f0314c9bedb5a84b334253b5f4d486`.
The preceding full run passed 77/80; its two manual-recovery fixtures now pass
their targeted rerun, and `worker_unexpected_exit` is explicitly disabled for
CREXX #701. No new clean full-suite result is claimed yet.

Baseline evidence: `durable_backlog`, `regression_reset_retries` and
`regression_command_catalogue` passed 3/3 (20.88 s). New `task_reset`
reproduced the exact Scottish no-window failure, then failed on the missing
`maintain reset` command before implementation. Logs are under
`cmake-build-debug/task-reset-20260915/`.

## Implementation and focused evidence

Reset uses a current-policy successor with the existing complete-evidence marker.
It resets effective item/task/embedding retry baselines, cached attempts, semantic
failures, retry delay and capability. Pending old reviews/requests and queued
work are retired. Sources, graph, attempts and provider rows are unchanged.
The original ID returns its successor on repeat; completed tasks stay closed.
External resolution/refresh no longer needs an obsolete window. Provenance
assessment without a worker job uses the current configuration snapshot.
No window, provider receipt, budget or semantic decision is fabricated.

The first focused run passed the three existing controls; reset reached normal
closure on every legacy fixture but the final census used advisory mode. The
documentation check also found missing new-tool manifest entries. Both fixture
and manifest were corrected; `task_reset` and `documentation_contract` then
passed 2/2 (4.45 s). Final acceptance additionally checks running-task skip/drain,
missing-subject closure, actual repeated census and foreign-key consistency.
Final build/full QA are complete below; elapsed times are test-run records, not
performance measurements on this shared machine.

Scottish examples (read-only, no corpus changes):
`task:00d6a156ae3241d348ea6dc10792ae8a7f5873dd426f904b7bb1ecf62f97d0e6`,
`task:00db0d680da774f701874ad921bc02a004ebf1317f538539b41aa5f8833c0ab3`,
`task:00f2f045524185d50462e8893fd67d02dddef7771311b556c6fe87e6a8638ae8`.
All are unresolved chunk extraction reviews with policy fingerprint
`615bb108b715e129cfee8f248b12c2e7547cd3b32481125baa8a248daa4eca47` and no
compatible window. The fixture reproduces that failure shape with synthetic
source evidence. Corpus receipts are in
`/Users/adrian/Documents/ScottishHistory/reports/escalation-review-20260915/evidence/`.

Expanded acceptance passed (7.64 s): live-item exclusion and all-task skip,
post-drain reset, missing subject closure, current-policy census preserving the
resolved chunk question, and SQLite integrity/foreign keys. Final native build
passed package initialization/two-worker supervision; SHA256
`b3be057eacb467a046995863945c8d6334a17b99e4d0e2d2459c4289b4295950`.
The required complete suite is recorded in `full.log`. It retains the explicitly
approved disabled `worker_unexpected_exit` upstream CREXX #701 regression.

## Final QA and closeout

- Configure/build succeeded. Final native SHA256 remains
  `b3be057eacb467a046995863945c8d6334a17b99e4d0e2d2459c4289b4295950`.
- The complete 81-entry suite finished in 1170.38 s: **79 passed, one metadata
  snapshot failure, one explicitly disabled upstream test**. The final binary's
  `task_reset` acceptance passed in 5.23 s. No product/runtime regression failed.
- The metadata failure was the expected addition of `rag_task_reset`: removing
  only that tool reproduced the previous 73-tool contract hash exactly
  (`01f9f08c632a59928d1f573a4d96384b9d23197d7d41db07e4326d41a004ea81`).
  Read-only metadata was unchanged. The reviewed snapshot now contains 74 tools;
  its targeted rerun **passed 1/1** in 0.38 s. No product change or second full
  run was needed. Current enabled coverage is therefore **80 passed**, based on
  the full run plus that snapshot-only rerun.
- `worker_unexpected_exit` remains **Disabled / not passed** under the earlier
  explicit user decision pending upstream CREXX #701. This task does not reopen
  that transferred issue.
- Evidence: `full.log`, `metadata-fixed.log`, `verify-metadata.cmake`, build logs,
  baseline/targeted logs and the scratch test `commands.log`/`mcp-reset.jsonl`.
  `git diff --check` passed. Fixtures used scratch libraries and synthetic local
  providers; no Scottish master mutation or new paid call was made.

The user-selected reset repair is complete. The former broad ESC-001 action
review is retired in favour of fixing concrete blockers as encountered. The subsequent authorized commit/installation uses this exact tested binary
and records the installed commit and short smoke checks in the Scottish receipt
directory above. Publication remains a separate action.
