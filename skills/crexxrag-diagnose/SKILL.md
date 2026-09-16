---
name: crexxrag-diagnose
description: Diagnose a crexxrag library, provider route, and job state without mutation.
---

# cREXX-RAG diagnosis

Prerequisites: `diagnose` access for verification/provider diagnostics and
`read` access for status, sources and jobs.

1. Start with `rag_library_status` and the reported failing operation. Use
   `rag_library_overview` for coverage questions and `rag_library_verify` when
   integrity is in question or at a requested qualification checkpoint.
   Distinguish original failure history from actionable, resolved or waived
   work. Waived tasks retain any missing corpus coverage.
2. Use `rag_provider_diagnostics` to inspect redacted route/capability state.
   Credential output must remain a symbolic `env:NAME` reference.
3. Only when the operator explicitly authorizes a provider smoke call, use
   `rag_provider_test` for one named provider. Confirm that the selected
   configuration has a suitable call/token/cost or subscription allowance
   budget. The tool sends only its fixed public synthetic text; it must not be
   substituted with library or user content.
4. Discover jobs with `rag_job_list`, comparing creation times rather than IDs.
   Read `rag_job_status` with optional `seconds` (1–86400, default 300).
   Use `rag_job_progress` for actual source/operation groups; queued excludes
   deferred and each item belongs to one group. Inspect the status allowance
   object separately from recorded usage and reservations.
   `planned_total` counts actual items; `item_limit` is the separate allowance.
   Report accepted item throughput and correction completions separately from
   provider attempts, recorded usage, incomplete usage and uncertain outcomes.
5. Use `rag_job_items`, `rag_job_attempts` and `rag_job_events` for the retained
   ownership, retry, validation and provider-run references.
   Use `rag_job_items` with `uncertainty: "held"` for held outcome IDs when
   advertised by the installed build; `active` and `all` match the other status
   uncertainty scopes. This filters before pagination and can combine with
   `state`. Missing filter support is an engineering/version gap, not a reason
   to scan the entire failed queue. Inspect a linked
   task with `rag_maintain_inspect` for evidence, retry holds and waiver state.
   Follow every relevant `next_cursor`; job/item/attempt/event pages allow
   1–100 data rows plus a cursor record. Use these tools instead of SQL.
   A retained worker count is a durable registry observation, not proof that
   those OS processes are alive. PID checks need the launcher's process
   visibility/permission domain; the current CREXX probe can report a running
   but sandbox-inaccessible PID as missing, even under the same account.
   Report that uncertainty instead of treating a restricted missing result as
   proof of exit or recommending pruning from it.
6. Report the failing layer, exact `exit_code`, stable message and next bounded
   check. Hand off recovery to the maintenance workflow with the observed IDs
   and holds; this diagnostic session cannot retry, waive or accept a proposal.
   Do not claim provider cancellation, streaming or lifetime reuse.

Follow the [shared long-job workflow](../crexxrag-maintain/SKILL.md#long-jobs-and-model-selection)
for monitoring. A healthy job does not need repeated full diagnostics. Missing
IDs, document-specific backlog or actionable error text should be reported with
the operation, installed build, expected/actual result and a small retained
receipt; investigate relevant pages only. Keep unresolved work on the continuation
checklist rather than compensating with ongoing manual item tracking.

Example: `rag_library_verify({})` followed by
`rag_provider_diagnostics({})`. An explicitly authorized smoke call is
`rag_provider_test({"provider":"gemini-generate"})`.

This skill declares no write capability. Refuse repair-by-SQL, job control,
apply calls, supervisor launch/kill, outbound provider tests without explicit
operator authorization and a declared budget, and any request to print a
credential value.

When the user requests stopping/reconnecting this MCP session, call
`rag_mcp_stop({})`. It acknowledges and closes only the current server process;
reconnect the client to load the installed binary. This needs read access and
works even with unavailable policy/library. It does not stop corpus jobs or
other sessions, and cannot interrupt an earlier blocking call. Automatic client
reconnection is not guaranteed. Use this for an intended session stop/update,
not merely because a corpus query has no results.
