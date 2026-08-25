# Phase 6 tutorial: one `crexxrag` product for people and agents

Phase 6 keeps the human experience established in Phase 3. A person uses the
single native `crexxrag` executable; they do not assemble cREXX module lists or
invoke a VM directly. The same executable can serve the typed MCP interface for
an agent. `ADDRESS RAG` remains the embedded cREXX interface for application
authors, not an extra workflow a normal user must learn.

This is an unpublished macOS qualification path. Native-v1 remains the default
oracle until a later explicit cutover decision.

## 1. Prepare a self-contained walkthrough

From the repository root:

```sh
work_dir=$(./docs/tutorials/phase-6-surfaces/setup.sh)
cd "$work_dir"
```

The setup script reuses the Phase 3 bundle. It builds and copies `crexxrag`, a
public synthetic source, the selected text configuration, and the Phase 6 MCP
and ADDRESS examples. By default it selects Codex extraction/answering through
your ChatGPT subscription and local llama.cpp embeddings. Use
`setup.sh --google` for the separately bounded Gemini route.

## 2. Ingest and query as a person

Run these commands in the prepared folder:

```sh
./crexxrag provider status
./crexxrag init
./crexxrag ingest
./crexxrag query 'What does BillingService depend on?'
```

`crexxrag` discovers `./crexx-rag.conf`, selects its sole profile, uses
`./library`, shows the reviewed provider/privacy/budget plan, and supervises
the configured workers. The final query performs compatible hybrid retrieval
and, because the tutorial config has an answerer, returns provider-generated
prose only after validating its citations against the typed evidence.

The installed CREXX runtime can currently require a second Enter at the ingest
confirmation. `./crexxrag ingest --yes` bypasses only that prompt; it still
creates and revalidates the exact reviewed plan.

## 3. Serve the same library to an agent

No second executable or module-load script is required:

```sh
./crexxrag serve mcp < mcp-requests.jsonl
```

The example JSONL initializes MCP, lists tools, reads library status, and asks
one explicitly lexical evidence question. Each response is one JSON-RPC line.
Tool calls return a short text item and typed `structuredContent` containing the
same `crexx-rag.command-result/1` envelope used by CLI JSON and `ADDRESS RAG`.

The server starts with `read` capability by default. Grant only the authority
needed for a separate session, for example:

```sh
./crexxrag --access read,plan serve mcp
```

`plan` adds zero-library-write planning tools. `ingest`, `curate`, `control`,
and `diagnose` add only their declared tools. Knowing an apply tool exists does
not grant it, and no capability exposes raw SQL or raw graph mutation.

Provider-capable query tools are advertised as read-only but open-world and
non-idempotent: they do not write the library, but auto/hybrid embedding or
answer generation can consume a local service, API budget, or subscription
allowance. Explicit `mode: lexical` is the zero-outbound query route. Unknown,
duplicate, or incorrectly typed arguments are rejected to match each tool's
`additionalProperties: false` schema.

## 4. Use `ADDRESS RAG` inside cREXX

[`address-query.crexx`](phase-6-surfaces/address-query.crexx) is the complete
embedded example. Its important operations are:

```rexx
address RAG 'LIBRARY OPEN ./library --config-file ./crexx-rag.conf --profile it-architecture-profile --access read --format json'
address RAG 'LIBRARY STATUS' output status_lines
address RAG 'QUERY EVIDENCE "What does BillingService depend on?" --mode lexical' output evidence_lines
address RAG 'LIBRARY CLOSE'
```

`LIBRARY OPEN` validates and fixes the library, config file, profile, access,
and format for that session. A failed open leaves the previous session intact.
Every subsequent command uses the same dispatcher, policy, result envelope,
and exit taxonomy as `crexxrag` and MCP.

The permanent Phase 6 matrix compiles this environment optimized and
non-optimized and runs it on both `rxvme` and `rxbvm`. Application authors can
therefore embed it normally; the human walkthrough does not require them to do
so.

## 5. Use narrow agent instructions

The install includes four separate packages under `skills/`:

- `crexx-rag-qa` for read-only evidence and explicitly budgeted answers;
- `crexx-rag-ingest` for plan and separately authorized ingest apply;
- `crexx-rag-improve` for plan/review and separately authorized curation;
- `crexx-rag-diagnose` for integrity and redacted provider diagnostics.

Each manifest declares its tools, schemas, and write capabilities. Agent
instructions cannot enlarge the capabilities granted when `crexxrag serve mcp`
starts.

## 6. Back up and restore

Use product commands rather than copying live SQLite and vector files:

```sh
./crexxrag --access admin library backup --output ./library-backup
./crexxrag --library ./library-restored --access admin \
  library restore --input ./library-backup --output ./library-restored
./crexxrag --library ./library-restored --access diagnose library verify
```

Backup pins one authoritative database generation and its matching immutable
vector sidecars. Restore targets a fresh folder and verifies the result.

## 7. Machine automation when needed

Scripts can use canonical noun/verb commands and stable JSON without changing
the human defaults:

```sh
./crexxrag --format json query evidence \
  'What does BillingService depend on?' --mode lexical
./crexxrag --format ndjson job list
```

Ingest/improve/proposal planning is zero-library-write. Apply accepts only the
byte-identical canonical plan and digest and then revalidates expiry,
generation, config/profile, source fingerprints, provider routes, privacy,
reservations, and capability.

## Permanent proof

The focused native proof is:

```sh
ctest --test-dir cmake-build-debug --output-on-failure \
  -R '^p6r_01_native_surfaces$'
```

It performs native two-worker Gemini ingestion, then drives provider-backed and
lexical queries through `crexxrag serve mcp`, checks truthful annotations and
strict argument rejection, confirms no secret value escaped, and verifies the
library.

The broader proof is:

```sh
ctest --test-dir cmake-build-debug --output-on-failure \
  -R '^phase6_surfaces$'
```

That matrix covers optimized/non-optimized `rxvme`/`rxbvm`, exact reviewed
ingest, zero-write plans, CLI/ADDRESS/MCP semantic equality, atomic config-file
binding, capability denial, deprecation, backup/restore, and skill manifests.
