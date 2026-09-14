---
name: crexxrag-qa
description: Answer questions from a crexxrag library using source-bound typed evidence.
---

# cREXX-RAG QA

Prerequisites: a running `crexxrag serve mcp` session with `read` access and
the `crexx-rag.command-result/1` / `crexx-rag.evidence/2` schemas.

For ordinary MCP Q&A, retrieve evidence and compose the cited answer yourself
in the current assistant conversation. cREXX-RAG supplies passages, graph
evidence and citation resolution; no separate answer-generation call is needed.

1. Call `rag_library_status` and stop on a non-zero `exit_code`.
2. Use `rag_source_list` for routine source scope and reuse it while the library
   generation is unchanged. Use `rag_library_overview` when the user asks for
   corpus coverage or health: it includes full verification and is unnecessary
   setup work for an ordinary question. Call `rag_query_inspect` with the user's question for
   strictly read-only lexical retrieval with no provider calls. Decode the
   returned `evidence_json`. If a broad question finds nothing, try focused
   names or phrases before concluding evidence is absent. Prefer the
   returned citations, stance, attribution, effective time, ambiguity,
   conflict and gap fields.
3. Compose the answer yourself from supported claims and cite the returned
   cREXX-RAG citations.
   Say plainly when evidence is absent or only a graph lead.
4. Resolve returned citations with `rag_citation_show`; occurrence, note and
   concept IDs are not citation IDs. Its text is an immutable source span.
   Source capture dates are not automatically claim effective dates. Preserve
   disagreements, attribution and uncertain time even when the graph has only
   one accepted edge. Use `rag_query_trace`, `rag_query_path` or
   `rag_query_timeline` when their projections are needed and gap recording is
   authorized; these older query routes record durable query-gap observations.
5. Use `rag_query_answer` only when the user explicitly requests using or
   testing cREXX-RAG's own answerer, and the configured privacy route and API
   or subscription budget authorize provider use. An ordinary request for a
   cited answer, a configured provider, or available budget is not that request.
   This route adds a separate model generation step, latency and provider
   usage before the current assistant can respond. `rag_query_evidence` can use
   hybrid retrieval and records gaps; `rag_query_inspect` makes neither writes
   nor provider calls. A tool approval failure is not evidence of absence.

Performance context: two 13 September 2026 smoke samples took 11.9–13.0 seconds
for the separate answer route, including 9.2–10.5 seconds in provider generation;
ordinary evidence searches on the repaired test copy had a 0.47-second median.
These are samples, not guarantees or timings of the current assistant's full
response. Its own reasoning and generation still take time. Do not reduce
evidence coverage or skip citation resolution merely to save time.

Query limits are 1–200 and graph hops 0–4. Omit `limit` to use the configured
passage default (12 in the supplied configurations). For exploratory questions,
retain a broad evidence set and filter it yourself; use a larger explicit limit
when useful. Candidate availability, diversity and the configured evidence-byte
ceiling still apply, so the requested maximum is not a promised result count.
Do not reduce the ordinary limit to three merely to shorten an answer.
Source-list pages accept 1–100
data rows plus a separate cursor record. Continue until `next_cursor` is empty. Keep
searches focused and decode nested JSON before answering; empty graph conflict
fields do not override disagreement in the original passages.

Example: `rag_query_inspect({"question":"Which component reads ADX?","hops":2})`.

This skill declares no write capability. If asked to ingest, maintain, decide a
review, control a job, run SQL, or mutate entities/edges, refuse and ask the
operator to select a separately permissioned workflow.
