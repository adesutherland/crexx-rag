---
name: crexxrag-diagnose
description: Diagnose a crexxrag library, provider route, and job state without mutation.
---

# cREXX-RAG diagnosis

Prerequisites: `diagnose` access for verification/provider diagnostics and
`read` access for status, sources and jobs.

1. Call `rag_library_status`, `rag_library_overview`, then `rag_library_verify`.
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
   ownership, retry, validation and provider-run references. Inspect a linked
   task with `rag_maintain_inspect` for evidence, retry holds and waiver state.
   Follow every relevant `next_cursor`; job/item/attempt/event pages allow
   1–100 data rows plus a cursor record. Use these tools instead of SQL.
6. Report the failing layer, exact `exit_code`, stable message and next bounded
   check. Hand off recovery to the maintenance workflow with the observed IDs
   and holds; this diagnostic session cannot retry, waive or accept a proposal.
   Do not claim provider cancellation, streaming or lifetime reuse.

Example: `rag_library_verify({})` followed by
`rag_provider_diagnostics({})`. An explicitly authorized smoke call is
`rag_provider_test({"provider":"gemini-generate"})`.

This skill declares no write capability. Refuse repair-by-SQL, job control,
apply calls, supervisor launch/kill, outbound provider tests without explicit
operator authorization and a declared budget, and any request to print a
credential value.
