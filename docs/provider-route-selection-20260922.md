# Configured provider selection — 22 September 2026

Adrian's requirement is that the tool must not impose an additional privacy
restriction on extraction through the provider he has selected. The reported
error was `library privacy denies the configured maintenance extractor route`.

The cause was two hard-coded rules: `ragquerypolicy.queryrouteallowed` refused
every hosted route for any non-public source label, and
`provider_contract.validateproviderroute` repeated the refusal at transport
entry. Maintenance combined all configured source labels before applying the
first rule. Neither rule consulted the provider's `privacy_policy` value.
Existing tests encoded that behavior; they did not establish a user requirement
for it. This decision supersedes that earlier behavior.

## Behavior and ownership

The configured provider controls routing. Source privacy labels, local/hosted
route classification, charging basis and the existing `privacy_policy` field
remain readable and retained in configuration/history. Those labels and the
legacy policy field do not veto provider use. There is no replacement approval
switch or privacy override setting. Existing configuration files still load.

`ragquerypolicy` retains provider-availability and budget preflight. The
redundant maintenance refusals are removed from `ragproduct`.
`provider_contract` retains request-shape and route-class validation; it also
accepts the already-supported configuration label `internal`. HTTP, Codex and
native embedding adapters continue to consume that same contract. Backlog
resolution, query and advisory services consume the existing shared preflight.
No domain policy moves into native code, and no provider protocol, schema,
prompt, persistence or transaction owner changes.

Human previews display the hosted route and source classification without the
obsolete claim that hosted calls accept public content only.

Output validation, quotations, configured budgets, credentials, HTTPS transport
requirements and receipt/usage accounting keep their existing behavior.

## Regression evidence

Baseline: clean `main` at `6364011706330c91f72e430d2943b478b9929d01`, using
installed CREXX `5949ef27efd8`. Before product edits:

- `query_policy` passed in 7.32 seconds, including all budget controls.
- `durable_backlog_provider_valid` passed in 5.55 seconds, including real
  loopback execution, source/vector preservation, exact references and usage.
- `gemini_maintenance` passed in 12.65 seconds, including reviewed maintenance,
  grounding, query and external-proposal controls.

New acceptance failed before repair:

- `query_policy` reproduced both shared vetoes for `restricted`, `local` and
  `internal`, plus the request-validator mismatch for `internal`. Public and
  local-route positive controls and the budget assertions still passed.
- `durable_backlog_provider_configured_route` reproduced the exact reported
  message through public `maintain plan`, after ordinary ingestion and public
  configuration application in an isolated scratch library. It selects hosted
  HTTPS providers with a `local` source label and unchanged `public-only`
  metadata. Planning makes no hosted call. Final assertions require retained
  classification/charging and unchanged job, provider-run and task counts.

The first fixture attempts exposed test compilation/HTTPS-configuration mistakes;
those were corrected before recording the behavioral reproductions above.

After repair, all four focused cases passed: `query_policy`,
`durable_backlog_provider_configured_route`, `durable_backlog_provider_valid`
and `gemini_maintenance` (13.32 seconds elapsed for the selection).

The initial full selection exposed a timing-dependent fixture in
`backlog_scenario.zerobudgetchecks`. Cell 1 deliberately leaves funded ordinary
work unfinished. Cells 2 and 3 expected an embedding but could select that
same-priority ordinary task depending on timestamp/task-id ordering. The
retained rxvme/rxbvm SQLite rows show the different selected work. Cells 2–4 now
explicitly select embeddings for their embedding admission controls. The
mixed-route cell 1 and paid-zero cells 1/5 retain their existing assertions;
product scheduling is unchanged. `durable_backlog` then passed in 7.81 seconds.

Evidence locations:

- Fail-first acceptance: `cmake-build-debug/qa/runs/query_policy/20260922T162703-755308d2`
  and `cmake-build-debug/qa/runs/durable_backlog_provider_configured_route/20260922T162640-d1143beb`.
- Initial full selection: `/tmp/crexxrag-provider-route-regression-20260922.log`;
  fixture rows in `cmake-build-debug/qa/runs/durable_backlog/20260922T163614-d1329adc`.
- Resumed full selection: `/tmp/crexxrag-provider-route-regression-resumed-20260922.log`.

The full local regression selection passed in 612.29 seconds: 106 executions
and 29 reused exact-input passing receipts, covering all 135 required cases.
The final documentation check and `tests/qa/report.py --require-complete`
account for the completed working copy; no disabled or failed case is a pass.
The separate scale lane and live hosted-provider calls are outside this gate.

Qualified native executable SHA-256:
`b83b34b07cde246449602a93b0a5412575a0849613053ada327f41f7726e18dc`.
The subsequent fixture-only rebuild did not change this executable.

Adrian subsequently authorized committing, publishing and installing the
qualified change locally. Those steps follow the local gate; the source review
does not claim implementation of the wider recommendations. Publication and
installation receipts are retained under `out/provider-route-publication-20260922/`.
