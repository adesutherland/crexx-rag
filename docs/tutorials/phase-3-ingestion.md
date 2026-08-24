# Phase 3 Tutorial: Initial And Incremental Ingestion

Status: executable development tutorial for the accepted Phase-3 implementation.
The module contracts below are implemented and tested, but the public CLI and
installed application package are Phase 6 work. This is not a release claim.

This tutorial uses the real Level-G folder connector, ingestion planner,
generation reconciler, schema-v2 repositories, FTS projection, and job queue.
CTest compares its output with
`tests/expected/tutorial-phase3.jsonl`; the prose is not scraped as a substitute
for executing the product path.

## 1. Run The Shipped Scenario

Use a CREXX installation containing the complete public SHA-256 surface. The
configured build consumes that installation without a sister-source fallback.

```bash
cmake --build cmake-build-debug --target phase3_ingestion --parallel 10
ctest --test-dir cmake-build-debug -R '^phase3_ingestion$' --output-on-failure
```

The target compiles optimized and non-optimized cREXX and runs both `rxvme` and
`rxbvm`. It also runs the tutorial, native-oracle comparisons, and real
`SIGKILL`/resume cases.

The tutorial corpus is deliberately small:

```text
tests/fixtures/tutorial/architecture-mini/
├── README.md
├── operations.txt
└── services/auth.crexx
```

The folder connector sorts the relative paths and uses them as stable keys. It
reads each selected file through a caller-supplied byte ceiling, retains exact
raw bytes or a verified SHA-256 reference, records MIME and UTF-8 encoding, and
hands immutable observations to the planner.

## 2. Understand The Plan

The development API is:

```text
ragfolder.collectfolderobservations(root, source_set_id, retain_raw,
                                    maximum_file_bytes, captured_at,
                                    expose observations, expose error) = .int

ragingest.createingestplan(store, source_scope, config_snapshot_id,
                           policy_version, parser_version,
                           maximum_chunk_characters, observations,
                           expose plan, expose error) = .int

ragingest.applyingestplan(store, plan, observations) = .ragingestresult
```

`createingestplan` performs no library writes. The canonical
`crexx-rag.ingest-plan/1` value binds the published generation, configuration
snapshot, source scope, parser/policy versions, stable keys, raw/text/metadata
digests, and revision envelopes. `applyingestplan` recomputes all those values
before starting `BEGIN IMMEDIATE`; a stale generation or changed observation is
rejected before writes.

The plan is immutable but is not a capability token. A future public apply
surface must still require the explicit ingest capability described in the
architecture.

## 3. Apply And Inspect

The first tutorial run prints five NDJSON records. The important properties are:

- three stable sources become one atomic generation;
- five immutable chunk contents are projected into occurrence rows and FTS;
- missing embedding and claim-extraction work is queued with versioned,
  idempotent input hashes;
- candidate census and representative-evidence decisions are recorded without
  a model call; and
- a second plan/apply over the same bytes is an exact zero-write,
  zero-provider-call no-op.

Raw artifact, revision, chunk-content, occurrence, continuity, plan, work-item,
and candidate identities use canonical lowercase SHA-256. Occurrence ids bind a
revision and UTF-8 byte span for citations. Content ids bind text plus the
parser/policy input fingerprint, so unchanged text can be reused safely across
revisions while parser changes invalidate only dependent work.

## 4. Try An Incremental Edit

Copy the fixture and use a scratch library so the repository files remain
unchanged:

```bash
scratch=$(mktemp -d /tmp/crexx-rag-phase3-tutorial.XXXXXX)
cp -R tests/fixtures/tutorial/architecture-mini "$scratch/source"
```

Run the compiled tutorial program shown in
`cmake-build-debug/phase3-ingestion/commands-and-output.txt`, substituting
`$scratch/library` and `$scratch/source`. Edit one paragraph in the copied
`operations.txt`, then run the same command again. The second run opens the
existing library, plans against its current generation, publishes one new
generation, reuses unchanged content, and queues only new content inputs. Run
it once more without editing: the apply result is `identical-no-op` with
`library_writes=0` and `provider_calls=0`.

The permanent scenario additionally covers append, middle edit, reorder,
mapped and unmapped rename, duplicates, deletion, metadata-only changes,
CRLF/Unicode span mapping, invalid UTF-8 rejection, verified external
references, parser-version invalidation, support re-anchoring/retraction,
embedding reuse, stale plans, and interrupted resume.

## 5. Provider Credentials

Phase 3 deliberately makes no provider call; ingestion queues embedding and
extraction work consumed by the Phase-4 worker path. Provider credentials are
nevertheless part of the product
configuration model. Hosted qualifications in later phases use symbolic
references such as `env:OPENAI_API_KEY`. Put the key in the process environment
or CI secret store only. Never put a credential in a cREXX module, plan,
fixture, evidence file, command transcript, or Git history.

The Phase-3 result reports `provider_calls=0`, which proves that unchanged
ingestion cannot accidentally spend a hosted-model budget. Phase 4 now consumes
queued work through the provider-neutral contract with explicit call, token,
cost, privacy, route, and reservation policy; its recurring tutorial remains
deterministic and zero-outbound.

## Current Limits

- Normalized source text is UTF-8. Invalid UTF-8 and undeclared encodings are
  rejected before binary-to-string conversion; raw SHA-256 remains binary-safe.
- The folder connector supports Markdown, text, Rexx, and cREXX files. Path
  selection, symlink policy, and application size ceilings remain caller policy.
- Candidate adjudication is deterministic Phase-3 census policy. Provider
  proposals, canonical graph promotion, review, and workers are implemented by
  Phase 4 and remain separate from ingestion's zero-provider replay invariant.
- The native-v1 implementation remains the executable oracle. Phase 3 neither
  cuts over the product nor removes native code.
- Current acceptance is macOS. Exact downstream Linux qualification remains
  open and is not implied by the dual-VM result.
