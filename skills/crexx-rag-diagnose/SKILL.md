---
name: crexx-rag-diagnose
description: Diagnose cREXX-RAG bundle, provider-route and job state without product mutation.
---

# cREXX-RAG diagnosis

Prerequisites: `diagnose` access for verification/provider diagnostics and
`read` access for status, sources and jobs.

1. Call `rag_library_status`, then `rag_library_verify`.
2. Use `rag_provider_diagnostics` to inspect redacted route/capability state.
   Credential output must remain a symbolic `env:NAME` reference.
3. Only when the operator explicitly authorizes a provider smoke call, use
   `rag_provider_test` for one named provider. Confirm that the selected
   configuration has a suitable call/token/cost or subscription allowance
   budget. The tool sends only its fixed public synthetic text; it must not be
   substituted with library or user content.
4. Inspect a named job with `rag_job_status` and `rag_job_events`.
5. Report the failing layer, exact `exit_code`, stable message and next bounded
   check. Do not claim provider cancellation, streaming or lifetime reuse.

Example: `rag_library_verify({})` followed by
`rag_provider_diagnostics({})`. An explicitly authorized smoke call is
`rag_provider_test({"provider":"gemini-generate"})`.

This skill declares no write capability. Refuse repair-by-SQL, job control,
apply calls, supervisor launch/kill, outbound provider tests without explicit
operator authorization and a declared budget, and any request to print a
credential value.
