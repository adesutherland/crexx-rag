# SQLite authority and vector publication recovery defects

Recorded 2026-09-06 after the Scottish corpus recovery investigation.

## RAG-REC-001 — incomplete replacement hides a complete vector baseline

Status: incident trigger and missing/corrupt sidecar recovery repaired in the
uncommitted operator pass; all 21 tests pass. A separate
explicit corpus-replacement workflow that stages a replacement until complete
remains open. Operational restoration is not a claim of installed release.

SQLite must contain the source evidence, embedding vectors, identities and
generation membership needed to recreate a vector sidecar. The `.rxvec` file
is a derived index for efficiency, not an independent source of truth. Losing
or rejecting that file must not require paid embedding generation when the
compatible vectors already exist in SQLite.

The incident violated publication availability, not durable vector storage:

- Erroneous semantic reingestion created replacement chunks for unchanged
  source content and advanced the published generation from 4799 to 7068.
- Generation 7068 exposed 15,153 active chunks but only 7,485 linked chunks.
  Its manifest advertised no vector sidecar. One stopped job still had active
  durable state.
- SQLite in the damaged library retained **all 13,707 distinct original
  vectors**, containing 42,107,904 bytes, and **all 15,153 original
  chunk-to-vector links**. The retained vectors match the backup byte for byte,
  including embedding identity, input digest, profile and dimension. Multiple
  chunks can reuse one distinct embedding.
- The older generation-4799 sidecar also remained on disk. Describing the
  vectors as deleted, or the sidecar as the only surviving copy, is incorrect.

The existing `ragembedding.buildannvectorgeneration` loads `e.vector` from
SQLite through generation-filtered `revision_chunk_embeddings` and
`revision_chunks`. It then trains and publishes the derived index without an
embedding-provider argument. This supports the intended architecture, but
rebuilding only the current incomplete membership is not sufficient to recover
the previously complete publication.

Required closure:

1. Prove that an unchanged corpus remains a no-op across prospective
   configuration changes: no replacement chunks, new jobs or provider calls.
2. Keep a complete published query baseline available until an explicitly
   reviewed replacement is ready. Intentional partial initial publication must
   remain distinguishable from replacing a complete baseline with incomplete
   work. Do not mix generations or weaken dimension/envelope validation.
3. Provide and qualify a bounded recovery operation that uses SQLite's stored
   vectors and memberships to rebuild a missing/corrupt sidecar, with zero
   provider calls and no loss of original provenance.
4. Test missing/corrupt sidecars and interruption before publication on scratch
   copies, verify citations and vector retrieval, and prove no paid work is
   inferred from a derived-index failure.

The earlier operational recovery used the complete generation-4799 backup,
preserving the damaged directory. The subsequent operator pass adds public
`vector rebuild` / `rag_vector_rebuild`, missing/corrupt/interrupted-file
regressions, and a hybrid preflight that detects an invalid sidecar before
provider use. Configuration and profile changes now apply prospectively,
without publishing a generation or replacing old chunks. Exact corpus-table
and vector-BLOB preservation is checked on a scratch library.

Machine evidence:
`/Users/adrian/testrag/recovery-20260906/sqlite-vector-authority-audit.json`.
The preserved database is
`/Users/adrian/testrag/library-quarantine-scottish-full-20260906-gen7068`.

## RAG-REC-002 — configuration migration leaves a stale manifest

Status: repaired and focused-qualified in the uncommitted operator pass.
Originally observed in the existing uninstalled recovery artifact with
SHA-256 `eafeb2f98fec8913d3abe58b78b7728e5b6a88fcc6130fbe7ad52c188c0e1339`.

Applying a reviewed prospective configuration to a staged schema-8 backup
automatically migrated SQLite to schema 9, but left the manifest at schema 8.
`library verify` returned exit 7, `manifest_state=invalid`, one storage issue
and zero repository issues. The public `library migrate` operation republished
the manifest, after which verification passed with zero issues. Generation
4799 and all 44 compared domain/history tables remained unchanged.

Migration/configuration application must leave manifest and SQLite identity
aligned, or explicitly require and report the remaining migration step before
claiming success. Add a focused existing-bundle regression when the corrective
source is qualified. Do not edit the manifest or migration checksums by hand.

The repair records the pre-open schema version and republishes the manifest
only after a successful automatic migration. The durability regression builds
a schema-8 bundle, opens it through the ordinary read/write path, and checks
schema 9 plus an aligned manifest in both interpreters and optimisation modes.
This does not change migration checksums or weaken manifest validation.

## Configuration preservation invariant

User clarification, 2026-09-06: changing configuration does not invalidate the
database. Profiles, prompts and ranking/chunk policies govern subsequent
work. Historical objects keep their original configuration snapshots, spans,
provider provenance and vector identities. Existing rows are never deleted
or reset merely because configuration hashes differ.

ANN algorithm/tuning changes require only a new derived index from stored
vectors. Embedding model, dimension or input-encoding changes require a
compatible embedding set when explicitly requested. They retain the old set
and all other corpus data. An incompatible query embedding route is an
unavailable retrieval channel, not an invalid database.
