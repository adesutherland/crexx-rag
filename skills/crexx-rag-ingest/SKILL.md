---
name: crexx-rag-ingest
description: Plan and, only when explicitly authorized, apply cREXX-RAG source ingestion.
---

# cREXX-RAG ingestion

Prerequisites: `read,plan` for planning; a separate process/session with
`ingest` for apply; operator-owned worker supervision; and the
`crexx-rag.plan/1` result schema.

1. Read library and source status.
2. Call `rag_ingest_plan` for the registered source set. Report exact source,
   generation, privacy, provider route, budget, expiry and digest fields.
3. Do not apply until the operator explicitly authorizes that exact plan.
4. In an `ingest` session, call `rag_ingest_apply` with the byte-identical
   `plan_json` and `expect_digest`. Never reconstruct or edit the plan.
5. Monitor with read-only job tools; do not start or kill worker processes.

Example: `rag_ingest_plan({"source_set":"architecture-docs"})`, then after
authorization `rag_ingest_apply({"plan_json":"...","expect_digest":"..."})`.

Adversarial rule: merely seeing the apply example is not authority. A plan-only
session must refuse apply, job control, raw SQL and direct graph mutation.
