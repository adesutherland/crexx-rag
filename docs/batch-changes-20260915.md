# Batched changes after baseline 5aad670

**Latest instruction, 16 September:** implement the approved test-process
redesign. See [implementation and qualification](test-process-redesign-20260916.md).
The combined batch has 121 enabled local functional passes and a separate scale
pass through the new selections; the approved upstream #701 exclusion remains.

**Current authority: approved on 16 September.** The user's "Approved" releases
implementation and focused checks, with the combined full QA at the end. The
original 15 September instruction deferred compilation until the batch was
ready; the approval below supersedes that deferral. No commit, installation,
publication or corpus run is included. The [escalation delivery record](maintenance-escalation-delivery-20260916.md)
contains current evidence.

## MCP-01 — stop/reconnect the current MCP session

- [x] Inspect existing stdio/catalogue callers and regression coverage. The
  current loop exits on input EOF; it has no explicit session-stop tool. Existing
  native-surface tests cover ping, EOF and ordinary read-only calls.
- [x] Add pending stream acceptance before implementation: acknowledge and exit
  before another queued request; a fresh process is usable; invalid arguments
  leave the connection usable; missing policy cannot block closure; corpus/job
  database remains unchanged.
- [x] Implement `rag_mcp_stop({})` with read access and no library requirement.
  The MCP adapter returns a local stop flag with its response; the CLI writes
  that response then exits. Keep existing dispatch interfaces compatible.
- [x] Update shared user/agent guidance, corpus template, diagnosis skill and
  manifest. Restart is client-owned; no global PID targeting, daemon, new
  configuration or job/corpus mutation.
- [ ] Build the completed batch and run `native_surfaces`,
  `regression_command_catalogue`, `regression_command_metadata` and
  `documentation_contract`. Review/update the metadata snapshot once for all
  intentional tool changes in the batch (new tool affects read and all lists).
- [x] Complete agreed local batch QA and record exact results before any
  separately requested installation; see the replacement qualification record.

The MCP specification permits the server to close its output stream and exit;
it does not define a mandatory shutdown/restart RPC or require automatic client
reconnection. This is an explicit product tool followed by standard transport
closure: https://modelcontextprotocol.io/specification/2025-06-18/basic/lifecycle#shutdown.

Original staging status: **implemented, unbuilt and untested**; now included in
the approved combined qualification. Scottish installation remains the
previous tested baseline. Do not advertise this pending feature as installed.

## Scottish escalation handoff — triage only, 16 September

- [x] Record ESC-VAL-01, ESC-VAL-02 and ESC-OPS-01 with owners, evidence limits,
  existing related issues and bounded acceptance in the
  [engineering triage](escalation-triage-20260916.md) and roadmap.

At this original triage checkpoint the reporting request added no implementation
authority. The later approval below releases the bounded repairs and local
tests; corpus work remains separate.

## Task model and final-pass direction — 16 September

- [x] Document current kinds, states, escalation marking, prompt/model selection,
  counters, chunk rediscovery and generation numbers, with current/desired diagrams.
- [x] Record the user's bounded final-pass intent and numbered acceptance in
  [the task guide](work-tasks-and-escalation.md), separating delivered behavior
  from design requirements.
- [x] Agree the smallest implementation mapping for prompt/model selection,
  final no-change and evidence-dependent deferral; then implement and qualify
  within the combined batch.

That review increment changed documentation only. The later approval below
authorises its bounded implementation and local qualification.

## One maintenance job — approval plan, 16 September

- [x] Map the requested prioritisation, per-task deferral, model/prompt selection,
  internal corpus search, durable evidence handoff and final outcomes to current
  owners and coverage in [the approval plan](maintenance-escalation-plan-20260916.md).
- [x] Obtain approval of the proposed bounded scope and defaults: Adrian replied
  "Approved" on 16 September. This releases compilation and focused regression
  work for implementation; run the full suite at the end of the combined batch.
- [x] Implement the approved increments and complete AC1–AC12 locally, with the
  explicit upstream #701 exclusion and hosted/endurance/platform limits.

The approved increment adds a bounded internal search/read/result cycle using
existing corpus read owners and validated source spans. It is explicit product
work, not a prompt-only claim. Full QA remains at the completed batch.
