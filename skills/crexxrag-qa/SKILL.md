---
name: crexxrag-qa
description: Answer questions from a crexxrag library using source-bound typed evidence.
---

# cREXX-RAG QA

Prerequisites: a running `crexxrag serve mcp` session with `read` access and
the `crexx-rag.command-result/1` / `crexx-rag.evidence/2` schemas.

1. Call `rag_library_status` and stop on a non-zero `exit_code`.
2. Use `rag_library_overview` for corpus coverage and `rag_source_list` for
   source metadata. Call `rag_query_inspect` with the user's question for
   strictly read-only lexical retrieval with no provider calls. Decode the
   returned `evidence_json`. If a broad question finds nothing, try focused
   names or phrases before concluding evidence is absent. Prefer the
   returned citations, stance, attribution, effective time, ambiguity,
   conflict and gap fields.
3. Answer only supported claims and cite the returned cREXX-RAG citations.
   Say plainly when evidence is absent or only a graph lead.
4. Resolve returned citations with `rag_citation_show`; occurrence, note and
   concept IDs are not citation IDs. Its text is an immutable source span.
   Source capture dates are not automatically claim effective dates. Preserve
   disagreements, attribution and uncertain time even when the graph has only
   one accepted edge. Use `rag_query_trace`, `rag_query_path` or
   `rag_query_timeline` when their projections are needed and gap recording is
   authorized; these older query routes record durable query-gap observations.
5. Use `rag_query_answer` only when the configured privacy route and API or
   subscription budget authorize provider use. `rag_query_evidence` can use
   hybrid retrieval and records gaps; `rag_query_inspect` makes neither writes
   nor provider calls. A tool approval failure is not evidence of absence.

Query limits are 1–12, graph hops 0–4, and source-list limits 1–100. Keep
searches focused and decode nested JSON before answering; empty graph conflict
fields do not override disagreement in the original passages.

Example: `rag_query_inspect({"question":"Which component reads ADX?","hops":2})`.

This skill declares no write capability. If asked to ingest, maintain, decide a
review, control a job, run SQL, or mutate entities/edges, refuse and ask the
operator to select a separately permissioned workflow.
