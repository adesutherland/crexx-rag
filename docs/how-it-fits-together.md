# How It Fits Together

This project is trying to do more than search a folder of text. The goal is a
small local knowledge library that can answer questions from source material,
show where the answer came from, and eventually follow meaningful relationships
between things.

The short version:

```text
source files
   -> chunks in SQLite
   -> lexical search and/or embeddings/FAISS
   -> candidate names and mentions
   -> cleaned concept registry
   -> typed entities and relationships with evidence
   -> answers with evidence and graph context
```

## The Local Library

A `.cprag` folder is the shareable library. It contains:

- `manifest.json`: basic library identity and settings
- `library.sqlite`: the source of truth for documents, chunks, entities, edges,
  provenance, and vector metadata
- `vectors.faiss`: an optional rebuildable vector-search sidecar

SQLite is the record book. FAISS is an acceleration structure that can be thrown
away and rebuilt from the vectors stored through SQLite metadata.

## Chunks

Large documents are split into chunks because retrieval works best on focused
pieces of text. A whole book is too broad; a paragraph-sized or section-sized
chunk is small enough to match a question and still large enough to carry useful
context.

Chunks keep their source path, title, confidence, source type, and time fields.
That matters because the answer should be able to say not just "this is true",
but "this source says this, in this context".

## Lexical Search

Lexical search is the traditional keyword-style path. It is good when the query
uses the same words as the source:

```text
query: Sutherland Mackays Gunns
source: Mackays--Macnicols--Sutherlands--Gunns
```

SQLite FTS5 provides this path locally. It is fast, simple, and explainable, so
it remains valuable even after vector search is available.

## Embeddings

An embedder turns text into a list of numbers called a vector. Text with similar
meaning should produce vectors that are close together.

For example, these may be close even if they do not use identical words:

```text
"authentication database"
"PostgreSQL stores user profile data for the auth service"
```

The embedder is the model that creates those numbers. In the local llama.cpp
path, `llama-server` runs `nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M` and
returns OpenAI-compatible embeddings.

The important design rule is that the native core does not care which embedder
made the vector. Ollama, llama.cpp, CREXX orchestration, or another local tool
can all provide vectors as long as the shape is consistent.

## FAISS

FAISS is not the embedder. FAISS is the fast vector index.

Without FAISS, vector search means comparing the query vector with every stored
chunk vector. That is fine for tiny tests, but it becomes wasteful as a library
grows. FAISS is a proven local library, originally from Facebook AI Research and
now maintained by Meta, for finding nearby vectors efficiently.

So the roles are:

- embedder: turns text into vectors
- SQLite: records which chunk each vector belongs to
- FAISS: quickly finds the nearest stored vectors for a query vector

That is why "FAISS versus vector search" is not quite the right comparison.
FAISS is one way to make vector search practical and fast.

## Relationships

Vector search is good at finding similar text. It is not enough when the answer
depends on how things are connected.

For example, a chunk may mention Sutherland. Another chunk may mention Mackay.
A third may say one clan held land from another, married into another family, or
was described by a source as a branch, rival, ally, tenant, or neighbour. Those
connections are relationships.

In `crexx-rag`, relationships are typed edges between typed nodes:

```text
Clan Sutherland --associated-with--> Clan Mackay
Clan Macnicol   --held-land-in-----> Assynt
Auth service    --accesses---------> PostgreSQL database
```

The relationship type is not decoration. It changes what traversal means. A
question about dependency, ownership, lineage, geography, or evidence should
not follow every link in the same way.

## How The Graph Is Built

The system should not throw every chunk at a large model. The better local-first
shape is:

```text
1. split documents into chunks
2. run a cheap pass to list candidate names and useful cues
3. count those candidates across the whole corpus
4. clean the list into good names, junk names, ambiguous names, and likely types
5. use that cleaned registry to score which chunks are worth deeper extraction
6. extract typed relationships only from the useful shortlist
7. revisit ambiguous or thin areas later as the library learns more
```

This matters because the first pass will be noisy. It may find real names such
as `Mackay`, `Lochiel`, or `Sutherland`, but it may also find phrases that are
not useful concepts. Counting and classifying candidates across the corpus turns
that noisy stream into a useful concept registry, an ignore list, and a queue of
ambiguities to resolve.

Vectors can help this process, but they play a different role from
relationships. A vector-near chunk says "this text is about similar things"; it
does not prove a historical, architectural, or causal relationship. Use vectors
to avoid redundant extraction, find related context, and spot bridge chunks. Use
rules or LLM extraction to earn typed graph edges.

## How Search Should Work

The intended retrieval path is hybrid:

1. Use lexical search for exact names, terms, and phrases.
2. Use vector search for similar meaning and paraphrases.
3. Use the graph to expand from matched entities to related entities.
4. Use provenance and confidence to prefer better evidence.
5. Return chunks and relationships together so an answer can cite sources.

This gives each component a reason to exist:

- lexical search catches exact terms
- embeddings catch meaning
- FAISS makes meaning search fast
- relationships connect facts across chunks
- provenance keeps answers honest about their sources

## Why Extract Concepts Before Relationships

For the graph layer, the useful order is:

```text
chunk text
   -> mentions in the text
   -> canonical concepts
   -> typed relationships
   -> evidence-backed graph
```

A mention is the exact wording found in a source, such as "Sutherlands" or "the
Mackays". A concept is the normalized thing those mentions refer to, such as
`Clan Sutherland` or `Clan Mackay`.

Relationships need stable endpoints, so the system should identify and
canonicalize concepts before storing important edges. It can still extract
candidate relationships directly from chunks, but those candidates should be
resolved to concepts before they become part of the durable graph.

## Why This Is Better Than Plain Vector Search

Plain vector search answers "which chunks are semantically close to my
question?" That is useful, but limited.

This approach can also answer:

- which source made the claim
- whether the claim came from a high-confidence or dated source
- which entities are connected even when no single chunk says everything
- what path links two things
- which relationship types matter for this question
- whether a source is describing a historical view rather than current fact

That last point matters for corpora such as older histories of Scottish clans.
The system should preserve what the source says without silently treating every
source claim as a modern consensus.

## Role Of CREXX And MCP

The native C++ core stores and retrieves. It should stay small, local, and
provider-neutral.

CREXX is the policy and orchestration layer. It is the right place to tune
profiles, choose vocabularies, call local models, score evidence, and decide how
far to traverse the relationship graph.

The same operation should be available through the right surface for the person
using it: CLI commands for humans and scripts, CREXX functions or address
environment commands for profile authors, and MCP tools for clients. The goal is
one shared vocabulary, not duplicate implementations.

Concrete profile examples for Scotland and Athens are described in
[`domain-profiles.md`](domain-profiles.md).

MCP is the client-facing adapter. It lets tools such as Codex ask the same core
for searches, timelines, sources, chunks, and graph operations. It should stay
thin and safe by default.

## The Main Advantages

- Local-first: works with local files, local SQLite, and local model providers.
- Explainable: keeps source chunks and relationship evidence available.
- Flexible: supports exact search, semantic search, and graph traversal.
- Provider-neutral: llama.cpp and Ollama are adapters, not core dependencies.
- Rebuildable: FAISS is a sidecar, not the source of truth.
- Domain-aware: typed relationships support IT architecture first, but the same
  mechanism can model history, materials, processes, or other structured
  domains.
