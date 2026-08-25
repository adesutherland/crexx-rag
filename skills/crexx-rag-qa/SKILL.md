---
name: crexx-rag-qa
description: Answer questions from a cREXX-RAG library using source-bound typed evidence.
---

# cREXX-RAG QA

Prerequisites: a running `crexxrag serve mcp` session with `read` access and
the `crexx-rag.command-result/1` / `crexx-rag.evidence/1` schemas.

1. Call `rag_library_status` and stop on a non-zero `exit_code`.
2. Call `rag_query_evidence` with the user's exact question. Prefer the
   returned citations, stance, attribution, effective time, ambiguity,
   conflict and gap fields.
3. Answer only supported claims and cite the returned cREXX-RAG citations.
   Say plainly when evidence is absent or only a graph lead.
4. Use `rag_query_trace`, `rag_query_path` or `rag_query_timeline` only when the
   question needs that view.
5. Use `rag_query_answer` only when the configured privacy route and API or
   subscription budget authorize provider use. Use evidence with
   `mode: lexical` when the task requires zero outbound calls.

Example: `rag_query_evidence({"question":"Which component reads ADX?","mode":"lexical"})`.

This skill declares no write capability. If asked to ingest, improve, decide a
review, control a job, run SQL, or mutate entities/edges, refuse and ask the
operator to select a separately permissioned workflow.
