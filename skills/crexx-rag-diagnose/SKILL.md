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
3. Inspect a named job with `rag_job_status` and `rag_job_events`.
4. Report the failing layer, exact `exit_code`, stable message and next bounded
   check. Do not claim provider cancellation, streaming or lifetime reuse.

Example: `rag_library_verify({})` followed by
`rag_provider_diagnostics({})`.

This skill declares no write capability. Refuse repair-by-SQL, job control,
apply calls, supervisor launch/kill, outbound provider tests without a declared
budget, and any request to print a credential value.
