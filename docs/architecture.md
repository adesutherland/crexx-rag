# Architecture

## Shape

`crexxrag` is a Level-G cREXX application packaged as one native executable.
The CLI, JSON/NDJSON, `ADDRESS RAG`, and MCP adapters translate into the same
typed command request and result vocabulary.

```text
human CLI / JSON / MCP / ADDRESS RAG
                 |
          ragproduct dispatcher
                 |
 config + policy + plans + jobs + retrieval + evidence
                 |
       cREXX SQL repositories and orchestration
                 |
        generic SQLite RXPA provider
                 |
     library.sqlite + immutable .rxvec sidecars
```

There is no second product implementation or compatibility bridge.

## Durable ingestion

1. The controller discovers configured source files and creates a canonical,
   digest-bound zero-write plan.
2. Apply revalidates the source set, configuration snapshot, profile, provider
   route, and budget before publishing source/chunk state and durable work.
3. `worker start` launches independent `crexxrag worker run` processes. Every
   process starts its own CREXX VM, loads the SQLite provider, and opens its own
   WAL connection.
4. A worker reserves provider usage, validates the provider result, promotes a
   supported claim or creates a review, and settles the reservation.
5. Embeddings are recorded with provider/model/dimension/envelope identity and
   published as a generation-specific `.rxvec` sidecar.

SQLite rows are the process communication mechanism. Leases, fencing,
idempotency keys, attempts, provider runs, events, heartbeats, and requested
worker state make recovery explicit.

## Evidence and claims

Sources, revisions, chunks, concepts, claims, and support use stable
content-derived identities. Claims are directional. Support binds a claim to a
specific active chunk and UTF-8 byte span. Contradiction and ambiguity remain
explicit records rather than being flattened into an answer.

Lexical, vector, and graph retrieval produce an evidence packet with stable
citations. Optional answer generation receives only the bounded evidence
context and must return schema-valid citations already present in that context.

## Providers

The provider factory selects by configured `kind`:

- `gemini`: hosted structured generation and embedding generation;
- `codex`: structured generation through a worker-owned Codex App Server child
  process and managed ChatGPT OAuth;
- `openai-compatible`: local llama.cpp generation or embedding endpoints;
- `openai`: hosted OpenAI-compatible API route when explicitly configured.

Every route declares local/hosted privacy and a charging basis. Codex is hosted
even though the client is a local process. Subscription allowance is not
reported as zero monetary API cost; it has its own turn/token/remaining-
allowance ceilings.

Codex extraction runs in an empty working directory with non-interactive,
restricted settings and an exact output schema. External thread/turn identity
is stored with `provider_runs` so a crash can distinguish completed work from a
real retry.

## Schema and publication

Because no earlier product was released, the active database begins with one
initial schema migration and bundle format 1. The ordered migration/checksum
mechanism is part of the format so every schema evolution remains ordered and
checksum-verified. There is no old schema importer.

Semantic generations are immutable once published. Vector generations are
separate rebuildable publications. Backup pins SQLite and sidecar identities;
verification checks schema, manifest, repositories, and published sidecars.
