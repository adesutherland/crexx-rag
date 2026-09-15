# T7-10 — controller lifetime diagnosis, 15 September 2026

The subsequent [job-controls repair](job-controls-delivery-20260915.md) closes
PC-01 and passes **79/79 local tests**, including both controller regressions.
The 75/76 results below retain this investigation's earlier checkpoint.
Installation, host-mechanism attribution and endurance confirmation remain open.

**Local pipe/signal repair tested; historical host-resume mechanism remains open.**
Both controller heartbeats stop in the exact second that Codex Desktop resumes
the Scottish coordinator after unsubscribing it. For the second incident,
the retained App Server log explicitly records shutdown of the existing Codex
instance during `thread/resume`, followed by creation of a replacement instance.
This is a specific explanation for the lost background command session and
missing outer completion receipt. It is not evidence of a SQLite, provider
timeout or maintenance-deadline defect.

The exact historical OS exit signal has not been recovered. The installed
Codex binary has a pipe-child kill implementation that uses signal 9 (SIGKILL)
and separate TERM/INT operations; that static finding alone does not establish
which path ran during either incident. Do not describe the host mechanism as
independently reproduced,
or the long-run qualification as passed. T7-10 remains open. This is a local
engineering reference, not a submitted GitHub/OpenAI issue.

**Plain parent exit has now been tested and does not reproduce the failure.**
A small Python launcher started the real controller and then exited normally.
The controller was reparented to PID 1, continued heartbeating, and completed
its bounded idle-worker run cleanly. The parent-stays-alive control also passed.
Neither case involved Codex, fake model responses, provider calls or corpus work.
The host-resume correlation remains, but termination signals/process-tree
cleanup or inherited pipe/terminal closure must be distinguished from merely
losing the launching parent.

**Pipe failure is independently reproduced.** The real controller exits from
SIGPIPE when its stderr reader closes, leaving a stale `running` runtime row.
Closing stdout produces SIGPIPE at final-result output, after both runtime rows
finish successfully. Closing stdin is harmless. SIGTERM, SIGHUP and SIGINT also
terminate the baseline without a recorded shutdown reason. These observations
justify the bounded output/drain repair below, even though they do not identify
the signal used in the two historical incidents.

A separate, zero-model-call probe of the installed Codex App Server's
`command/exec/terminate` returns exit code **137** for a synthetic child whose
TERM/INT/HUP/PIPE handlers would record the signal and exit normally. No handler
runs. This agrees with the retained binary's SIGKILL path. It confirms explicit
command termination, not Desktop unsubscribe/resume. Evidence is
`qa/t7-10-controller-diagnosis-20260915/codex-command-terminate/result.json`;
selected disassembly and binary identity are retained in the same parent folder.

## Agreed repair and acceptance checklist

- [x] Separate normal parent exit, stdin EOF, stdout/stderr reader loss and
  explicit TERM/HUP/INT/KILL using real processes and scratch libraries.
- [x] Add ordinary failing `regression_controller_closure` acceptance: healthy
  and stdin-EOF controls pass; stdout/stderr and TERM/HUP/INT fail on the old
  build with their actual negative OS wait codes. SIGKILL remains uncatchable.
- [x] Add `regression_controller_term`: first prove a live controller/worker,
  one held synthetic provider response and one queued peer. Baseline fails
  because TERM exits 143 without requesting drain or recording its reason.
  Result/claim/usage retention controls still pass. Both test baselines are in
  `qa/t7-10-controller-diagnosis-20260915/closure-baseline/acceptance.log`.
- [x] Implement best-effort operator output in `ragtrace`, shared by progress,
  process/store diagnostics and CLI result output. Disable only a failed output
  sink; keep provider/file failures outside that handler.
- [x] Implement a process-local first-signal flag in `ragprocess`; compose the
  existing drain and completion path, retain the reason in public runtime
  detail, and avoid new timeout, supervisor, protocol or schema machinery.
- [x] Update shared maintenance instructions, the corpus AGENTS template, core
  integration/architecture guidance and Scottish AGENTS/README/installed skill.
  Agents inspect durable status and routinely resume authorized unfinished work
  after actual loss; no panic, automatic data repair or repeated approval.
- [x] Build and pass the two targeted regressions: **2/2**, including
  held-response drain, retained accounting, no new claim and public shutdown
  reason. Parent-waits and parent-exits also pass on the repaired native
  artifact `f3c4ff83b07df7170599541e72bd00441cdcf009c151b6edfa197f154248bb48`.
  See `qa/t7-10-controller-diagnosis-20260915/repair-acceptance/`.
- [x] Run the full required local suite: **75/76 pass**, 1037.72 seconds on
  the shared computer. The only failure is the already-red PC-01
  `regression_source_maintenance`: expired-window continuation still requires
  renewal. All new closure/drain and existing provider, recovery, publication,
  retrieval, documentation and scratch-installation checks pass. See
  `repair-acceptance/full-suite.log`; no assertion was disabled or weakened.
- [ ] Stage the qualified executable and run a separately authorized long
  confirmation. Documentation updates alone do not install the candidate.

The Scottish shared skill update is installed through its existing `.agents`
symlink. Master data and cancelled work remain unchanged.

Implementation iteration retained two useful failures. The first repair fixed
stderr but had an incorrect `SELECT CASE` spelling and left failed stdout bytes
for process-exit flushing. Correcting the dispatch and explicitly closing only
the failed sink addresses those cases. Both installed VMs pass the isolated
closed-stdout probe, including a second attempted write. Using public
`closefile` for cleanup triggered `INTERNAL_CONVERGENCE_ERROR` in `ragcommand`
and a provider type mismatch in `ragprocess` during the normal source-project
build, including an unchanged retry; both modules compiled against built
interfaces. The implementation instead uses the already-used `lineout` API's
documented close form, with the same narrow NOTREADY containment. The failed
build log is retained as `compiler-closefile-retry.log`; no sibling CREXX source
was changed.

Upstream report: [CREXX #699](https://github.com/adesutherland/CREXX/issues/699),
filed by `adesutherland` on 15 September with the recorded application-level
sequence, exact diagnostics and working alternative. A reduced reproducer is
not yet available; this is explicit in the report. The submitted body is retained
as `qa/t7-10-controller-diagnosis-20260915/github-compiler-issue.md`.

The final ordinary configure/build and packaging smoke pass. Closed stdout and
stderr now return OS exit zero, with both runtime rows stopped successfully;
TERM/HUP/INT return zero and retain their exact shutdown reason. The busy TERM
case observes drain on both rows before releasing its synthetic response,
retains one successful provider run/claim and one queued peer, and releases all
reservations. The original plain-parent pair still passes, including reparenting
to PID 1. These are behavior assertions, not stopclock performance gates.
Shared skill validation, documentation contract and diff whitespace checks pass.

## Evidence and timeline

All times below are UTC; add one hour for BST. The heartbeat times are calculated
from retained public observations, at their one-second resolution.

| Event | First Boswell controller | Final backlog controller |
| --- | --- | --- |
| PID / command session | 93339 / 93914 | 51500 / 44346 |
| CLI launch | 00:38:49, runner 094 | 03:14:38, runner 126 |
| Desktop unsubscribes coordinator | 01:38:56.118 | 04:15:49.117 |
| Last controller heartbeat | **01:58:45** | **04:18:32** |
| Desktop starts resuming coordinator | **01:58:45.347** | **04:18:32.267** |
| Resume response | 01:58:45.664 | 04:18:32.568 |
| New coordinator turn starts | 01:58:45.925 | 04:18:32.818 |
| Later process confirmation | PID absent; no runner receipt | PID absent; no runner receipt |

Both resumptions followed engineering `send_message_to_thread` handoffs. The
first message concerned provider timeouts; the second requested final closeout
preparation while the final workers were healthy. This association implicates
the coordination/launch arrangement; it does not mean every message, every turn
or every unsubscribe kills a process. Ordinary earlier follow-ups reused the
loaded coordinator without this resume sequence.

The decisive retained App Server records for the second incident are:

- `328024806`, 04:18:32.323951: the Scottish session receives `op: Shutdown`.
- `328024813`, 04:18:32.325772: `Shutting down Codex instance`.
- `328024821`, 04:18:32.328321: `Agent loop exited`.
- `328024822`, 04:18:32.328353: `resume_running_thread` clears the listener
  during thread-state teardown; `had_active_turn=false`.
- `328024895`, 04:18:32.609761: `resume_thread_with_history` creates the new
  session shell snapshot.

These records identify the Scottish coordinator task
`01a0a027-4ffe-7832-a904-42fd1381ab06`, not one of the provider's temporary model
tasks. Desktop reports version `26.901.51231`; the installed bundled CLI reports
`0.153.4`. At collection, the log database retained only 1,000 records for the
coordinator, beginning at 02:37:28 UTC. Consequently the equivalent low-level
records for the first incident are unavailable; its Desktop log and rollout
still establish the matching resume/heartbeat timing.

Focused macOS unified-log checks around both heartbeat boundaries found no
matching controller PID or crash/termination record. The inspected diagnostic
report directories contained no matching 15 September cREXX-RAG/Python crash
report. Absence of such a record does not rule out a signal or native failure.

Selected evidence is retained in
[the diagnosis evidence directory](qa/t7-10-controller-diagnosis-20260915/):
`desktop-lifecycle.json`, `app-server-shutdown.json`,
`heartbeat-correlation.json`, `coordinator-turns.json` and the regression log.
The JSON files identify original files/line numbers or database record IDs;
the heartbeat evidence includes receipt SHA-256 values. No provider payloads,
credentials or general user conversation dump were copied.

## Product and launcher review

`ragprocess.startworkerprocesses` owns the controller. Its observation loop
updates the controller heartbeat once per wall-clock second, observes children,
and handles bounded replacement. Normal controller errors emit stderr and
attempt to record a failed runtime row before draining children. Normal
completion records the terminal controller result. A channel exception has an
outer diagnostic handler; abnormal termination can still bypass ordinary
cleanup. The stale `running` row alone therefore cannot identify a native crash.

Workers check their recorded controller's presence before taking more work;
claim admission repeats the controller check. Their exit after parent loss
matches the existing simple restart design. Maintenance windows and provider
deadlines are enforced by their existing owners; neither explains loss of the
outer Python command session at coordinator resumption.

The soak's `capture_cli.py` calls `subprocess.run(..., capture_output=True)`
without a timeout. It writes the JSON receipt only after the child returns.
If the enclosing command/session is terminated, its buffered stdout/stderr and
final return code are not retained in that receipt. This is an evidence-capture
weakness in the test launcher, not grounds for new product recovery machinery.

Existing `--progress plain` writes progress to stderr; worker errors already
inherit controller stderr. Direct file redirection can preserve those bytes
without new product debugging messages. It cannot itself preserve a command's
lifetime or guarantee a final receipt if its recorder dies.

Official [App Server documentation](https://learn.chatgpt.com/docs/app-server#api-overview)
documents that unsubscribed tasks can be unloaded and that background terminals
belong to loaded tasks. It does not prove the exact OS termination mechanism in
this installed version; the incident diagnosis relies on the local logs above.

## Verification and remaining actions

- [x] Run Adrian's plain-parent-exit experiment using
  `tests/fixtures/launcher-exit.py`: parent stays alive / parent exits normally.
  Both pass on the unchanged native build. In the exit case, the controller's
  PPID changes from the launcher PID to 1 while the controller and worker remain
  alive; a later heartbeat advances and both runtime rows finish with exit code
  zero. Final public output reports success. The orphan's OS wait status is
  unavailable to the observer and is explicitly null, not inferred. Zero jobs
  and zero provider runs are independently checked in both scratch libraries.
  Stdout/stderr go to ordinary files; no PTY, pipe-reader loss, signal or session
  detachment is involved. This isolates parent exit only, not busy maintenance.
- [x] At Adrian's request, confirm the existing replacement Codex executable
  and run `controller_recovery`: all six eight-worker cases pass with only
  local synthetic provider exchanges. See the
  [fixture instructions](../tests/fixtures/providers/README.md) and retained
  `fake-codex-regressions.log`. These cover inner-provider exits, completed-output
  reuse and isolation; they do not test outer Codex task resumption. No new
  fake-model implementation or product change was needed.
- [x] Correlate both original runners, missing PIDs, public heartbeat timestamps
  and coordinator resume events.
- [x] Retain the available host shutdown/teardown records before log rotation.
- [x] Review controller, child observation/admission, normal exit and launcher
  receipt paths; distinguish host shutdown from provider-task cleanup.
- [x] Re-run `process_workers`, `regression_controller_loss` and
  `regression_restart_live`: **3/3 pass**, 31.33 seconds on the shared computer.
  The native test binary and installed Scottish binary both hash to
  `fd7b6537ebb73e3ea23d328a21fefbef58d7193602ef8130ebdca324bb44bbf7`.
  The controller-loss test has a live parent/child positive control, kills only
  its scratch controller, and checks no subsequent claim and child exit. The
  restart test checks fresh ownership and preserved completed work. These tests
  do not exercise Desktop task unload/resume or qualify unattended endurance.
- [ ] Confirm the host mechanism using a small disposable command, with its
  process identity/output captured outside the task being resumed. Compare an
  ordinary follow-up with unsubscribe/resume while the command remains active.
  Capture command exit/signal and background-session presence. This needs no
  corpus, embeddings or maintenance model calls; it has not been run here.
- [ ] With that result, prepare an upstream Codex report or validate an existing
  independently owned terminal launch. Do not add a product daemon, heartbeat
  monitor, extra retries or timeout changes to conceal the host failure.
- [ ] Only after the launch lifetime is established, agree a bounded long
  maintenance confirmation with Adrian. Write stdout/stderr directly to files,
  retain exit status from a surviving launcher, and use public job status for
  light monitoring. Select existing configuration and budgets explicitly.

The initial diagnosis changed no product code. The subsequent authorized repair
changes operator output and signal draining as listed above; Scottish agent
documentation is updated, but its executable and master library are untouched.
The cancelled master job remains cancelled. No paid call or new long maintenance
run was launched. PC-01 is separate continuation work.

## Repeat the parent-exit experiment

From the repository root, using a new scratch directory:

```sh
python3 tests/fixtures/launcher-exit.py \
  --application cmake-build-debug/crexxrag-native/package/crexxrag \
  --work-dir cmake-build-debug/t7-10-parent-exit-repeat
```

The fixture refuses to reuse an existing directory. Each case retains its
launch arguments, controller stdout/stderr, before/after process observations,
runtime rows and result JSON. It uses the same `startworkerprocesses` owner as
`job run`, with an empty library and 80 idle polls. It does not imitate Codex or
install a service. Selected results are retained alongside the earlier
diagnosis evidence.

The likely recovery policy remains the existing simple one: a fresh agent uses
public status to discover the durable job and its controller. A surviving run
is observed through fresh CLI/MCP commands; SQLite carries status and control,
so reconnecting the original stdin/stdout is unnecessary. After actual controller
loss, use the normal restart path with preserved committed work and history.
`job run` itself performs cleanup/start, so do not use it merely to observe a
live controller. Graceful handling of a catchable termination signal may improve
drain/diagnostics once the signal is established; it cannot replace recovery
after SIGKILL. Do not introduce blanket signal ignoring or new recovery policy.
