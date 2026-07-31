# Phase 0 And Phase 1A Diagnostic Worklist

Status date: 2026-07-28. Authority is limited to Phase 0, then Phase 1A only
after a fully evidenced Gate 0. Stop unconditionally at Gate 1A.

Legend: `[ ]` not started, `[~]` active, `[x]` accepted, `[!]` blocked. At most
one item may be active. An item is accepted only after its exact retained
evidence path and result are recorded here.

## Baseline Preservation Snapshot

- `crexx-rag`: `main` at `97cd87e91344d6ac1773a054bd38df23eb128ed2`.
  The pre-existing worktree contains the user-owned documentation archive move,
  current cREXX-only programme documents, and edits summarized in
  `raw/p0-01/crexx-rag-git-state.txt` once P0-01 captures the retained copy.
- read-only CREXX: `develop` at
  `12a11815ab082086fb95e4ca5e41bd1c0e241342`; initial status was clean.
- No staging, commit, push, pull request, sister-repository write, hosted call,
  hosted credential use, live-library dual-write, native retirement, or work
  beyond Gate 1A is authorized.

## Phase 0

- [x] **P0-01 — Environment and oracle fingerprint**
  - Evidence: `INDEX.md`, `raw/p0-01/environment.txt`, both retained git-state
    files, `raw/p0-01/checksums.sha256`, and
    `raw/p0-01/baseline-build-and-test.txt`.
  - Acceptance result: exact state captured. The initial CTest run reproducibly
    failed 4/11 under installed cREXX `g057592681c0c`; after the user-authorized
    Level B compatibility change, the focused recovery passed 4/4 and the exact
    full baseline passed 11/11. Both results are retained.
- [x] **P0-02 — Redistributable generic IT and Scotland-shaped fixtures**
  - Evidence: `tests/fixtures/phase0/`, `fixtures/manifest.tsv`, and
    `fixtures/coverage.md`.
  - Acceptance result: 8 original redistributable files, 9,039 bytes total;
    exact hashes and required keyword/keyphrase, alias, semantic paraphrase,
    ambiguity, chronology, multiple-support, stance, deletion, and directed-path
    coverage are frozen.
- [x] **P0-03 — Native-v1 semantic goldens**
  - Evidence: `goldens/oracle-semantics.jsonl`,
    `goldens/answer-evidence.jsonl`, `tests/phase0_oracle_semantics.cpp`, the two
    focused CTests, and `raw/p0-03/semantic-golden-validation.txt`.
  - Acceptance result: both exact semantic comparisons passed (2/2), covering
    chunking, census, adjudication, mention/graph seeding, ranking, queue,
    deletion, lexical/current-vector/graph retrieval, and evidence packets
    without comparing volatile IDs or serialization trivia.
- [x] **P0-04 — Scotland-shaped judgement cases**
  - Evidence: `judgements/scotland-shaped-judgements.jsonl`,
    `judgements/rubric.md`, `judgements/passage-map.tsv`, and
    `raw/p0-04/judgement-validation.txt`.
  - Acceptance result: 5 fixed cases convert all archived lesson groups into
    evidence-level labels for direct phrase, chronology/translation,
    agency/ambiguity, adjacency, source layering, conflict, citation, and gaps.
- [x] **P0-04A — Held-out IT-architecture judgement cases**
  - Evidence: `judgements/it-held-out-questions.jsonl`, separately retained
    `judgements/it-held-out-judgements.jsonl`, the shared rubric/passage map, and
    `phase0_judgement_catalog`.
  - Acceptance result: 4 blinded cases cover passage relevance, alias expansion,
    directional claims, stance/time, lead handling, citation entailment,
    ambiguity/conflict, and expected gaps; question/key IDs match exactly.
- [x] **P0-05 — Explicit current-defect demonstrations**
  - Evidence: `defects/oracle-defects.jsonl`, `defects/README.md`,
    `tests/phase0_oracle_defects.cpp`, `phase0_oracle_defect_golden`, and
    `raw/p0-05/defect-validation.txt`.
  - Acceptance result: all 4 negative cases reproduced in scratch and matched
    the semantic golden: same-URI chunk-ID churn, stale graph support after
    change and deletion, unsafe unclaimed/unfenced queue visibility, and the
    1 MiB whole-result buffer failure. Every case is labelled undesired.
- [x] **P0-06 — Same-session component benchmark harness**
  - Evidence: `crexx/benchmarks/phase0_components.crexx`, native vector/SQLite
    probe and loopback provider targets, `phase0_component_benchmark`,
    `benchmarks/protocol.md`, and `raw/p0-06/`.
  - Acceptance result: same-session CTest passed on `rxvme` and `rxbvm`; retained
    rows separately report SQLite, cREXX algorithm, provider wait, JSON parse,
    record materialization, JSON encode, vector transfer/decode/compute/
    selection/total, and native plus per-VM peak memory. No PERF2 extrapolation
    or hosted call was used.
- [x] **P0-07 — Gate-0 thresholds and evaluation protocol**
  - Evidence: `thresholds.json`, `ANSWER-EVALUATION-PROTOCOL.md`,
    `frozen-hashes.tsv`, `phase0_gate_protocol`, `GATE-0-REPORT.md`, and
    `raw/p0-07/gate0-validation.txt`.
  - Acceptance result: 19 hashes verified; fixed fixture sizes and provisional
    quality/context/latency/memory thresholds validated; blinded answer/key and
    scorer/adjudicator separation frozen; full Phase-0 CTest passed 17/17.

## Gate 0

- [x] **Gate 0 self-review — passed**
  - Evidence: completed `GATE-0-REPORT.md`, `raw/p0-07/gate0-validation.txt`,
    the recovered baseline, initial compiler failure, and all accepted P0 paths.
  - Decision rule: any incomplete or non-reproducible build, hash, golden,
    defect case, judgement label, raw benchmark, or protocol stops the programme
    here. No Phase-1A item is active.

## Phase 1A — Bounded Boundary Selection

- [x] **P1A-SDK-01 — Scratch version-matched RXPA SDK probe**
  - Evidence: `incubator/p1a/sdk_probe/`, `p1a_sdk_probe`, and
    `raw/p1a-sdk-01/{sdk-manifest,commands-and-diagnostics}.txt`.
  - Acceptance result: exact installed commit `057592681c0c...` artifacts were
    extracted into scratch, both crexx-rag `_rag` and a trivial external plugin
    built with both fallbacks off, and the plugin compiled/loaded/ran returning
    the installed version and integer 42. No sister or normal-prefix write.
- [x] **P1A-SQL-01 — Minimal generic typed SQLite experiment**
  - Evidence: `incubator/p1a/sqlite_boundary/`, `p1a_sqlite_boundary`, and
    `raw/p1a-sql-01/commands-and-results.txt`.
  - Acceptance result: focused CTest passed 1/1. Native-payload-backed opaque
    database/statement handles safely copy, finalize, close, and reject stale
    use; typed null, int64 boundaries, real, Unicode/empty/1,100,005-byte text,
    and embedded-NUL blob bind/read passed with cursor iteration, rollback,
    FTS5, structured errors, and forced cleanup.
- [x] **P1A-DATA-01 — Parse-once and paged typed-record experiment**
  - Evidence: `incubator/p1a/data_boundary/`, `p1a_data_boundary`, and
    `raw/p1a-data-01/commands-and-results.txt`.
  - Acceptance result: focused CTest passed 1/1. One provider payload traversed
    once into a typed record with Unicode/empty/missing/null/array/object and
    malformed coverage; SQLite pages 2,2,1 became typed record arrays without
    whole-corpus JSON. Retained 200-iteration component times were 16,987 us
    parse, 3,138 us materialize/copy, and 3,575 us encode.
- [x] **P1A-DATA-01 follow-up — Indexed JSON document and packed numeric projections**
  - Authority: user-approved diagnostic refinement on 2026-07-29. This is
    mapped solely to `P1A-DATA-01`; it does not reopen Gate 1A or authorize
    production replacement of CREXX `rxjson`.
  - Evidence: `incubator/p1a/json_document/`, explicit versioned
    `float32` and signed-`int64` projections, focused CTest on both VM variants,
    retained same-session legacy-versus-indexed benchmark output, and
    `JSON-DOCUMENT-REPORT.md` plus
    `raw/p1a-data-01-json-document/final-commands-and-results.txt`.
  - Acceptance result: focused CTest passed 1/1 and internally passed optimized
    and `-n` correctness/benchmark/probe runs on both `rxvme` and `rxbvm`.
    A 58,435-byte provider-shaped 3,072-value payload parsed in 985–1,703 us;
    ten `f32` projections took 2,306–2,665 us and produced 12,304-byte versioned
    payloads. Signed-`i64` packing, extrema, failure cases, compatibility-shaped
    access, and a minimized optimized `.binary` by-value regression are also
    retained. CREXX `rxjson` was not replaced and no provider call was made.
- [x] **P1A-LLM-01 — Provider-neutral Google/Gemini generation/embedding experiment**
  - Evidence: `incubator/p1a/provider_boundary/`, deterministic
    `p1a_provider_boundary`, and `raw/p1a-llm-01/`.
  - Acceptance result: deterministic success, malformed response, provider
    error, timeout, and connection failure passed 1/1. The repaired adapter
    parses each response once, projects embeddings directly to versioned packed
    `f32`, and sends the empirically effective bounded-dimension field. The
    single user-authorized canary returned matching generation and exactly 8
    embedding dimensions in 1,446,777 us plus 364,282 us; the key was neither
    printed nor retained. The earlier timeout remains as negative diagnostic
    history in `gemini-canary-failure.txt`.
- [x] **P1A-VEC-01 — Float32 page and exact cREXX cosine/top-k experiment**
  - Evidence: `incubator/p1a/vector_boundary/`, focused
    `p1a_vector_boundary`, and `raw/p1a-vec-01/commands-and-results.txt`.
  - Acceptance result: exact cosine and top-3 ordering `10,20,30`, including
    equal-score identity tie-break, passed on both VMs. A bounded page of 32
    versioned 768-dimensional blobs transferred 98,816 bytes. `rxvme` measured
    transfer/decode/arithmetic/selection/total at 48/17/420/16/507 us with
    26,607,616-byte process RSS; `rxbvm` measured 36/18/495/7/562 us with
    20,054,016-byte process RSS. Pure cREXX exact search is the later baseline;
    acceleration is not indicated by this bounded-page result alone.
- [x] **P1A-ALG-01 — Small cREXX lifecycle/evidence vertical slice**
  - Evidence: `incubator/p1a/algorithm_slice/`, focused
    `p1a_algorithm_slice`, and `raw/p1a-alg-01/commands-and-results.txt`.
  - Acceptance result: the Level-B scratch schema passed first load,
    deterministic two-paragraph chunk/FTS publication, identical zero-write and
    zero-provider-call reingest, one-paragraph edit with one reused derived
    value, immutable supersession, normalized directional claim plus exact
    support, removal retraction, deterministic citation, passage, ambiguity
    lead, and explicit gap. No production schema or native application logic.
- [x] **P1A-JOB-01 — One durable fenced item experiment**
  - Evidence: `incubator/p1a/job_slice/`, focused `p1a_job_slice`, and
    `raw/p1a-job-01/commands-and-results.txt`.
  - Acceptance result: four separate VM processes proved initial creation,
    committed atomic claim with DB-issued fence 1 then forced exit 73 before
    promotion, replacement by fence 2 with work outside the claim transaction,
    stale-fence rejection, atomic support promotion then forced exit 74, and
    idempotent recovery with exactly one support row. Scheduler hardening was
    not started.
- [x] **P1A-SUR-01 — Thin four-surface typed-record pass-through**
  - Evidence: `incubator/p1a/surface_boundary/`, focused
    `p1a_surface_boundary`, `raw/p1a-sur-01/commands-and-results.txt`, and the
    minimized Level-G record-return reproducer under `repro/`.
  - Acceptance result: one typed status/evidence semantic record passed through
    a string-only Level-G facade, an actual CLI executable, actual `ADDRESS
    RAG`, and an MCP `structuredContent` adapter with parse-once semantic
    equality. Installed `rxc` rejects a Level-G method returning the imported
    Level-B record with `#TYPE_MISMATCH`; the approved interim boundary keeps
    the record in Level B and the Level-G facade thin.

## Gate 1A

- [x] **Gate 1A validation and decision packet**
  - Evidence: `raw/gate1a-validation.txt`, exact 27-test census,
    `GATE-1A-DECISION-PACKET.md`, and
    `prompts/gate1a-boundary-decision.md`.
  - Acceptance result: exact configure/build/CTest passed 27/27 in 37.05
    seconds; `git diff --check`, credential-value scan, user-work audit, and
    clean read-only sister audit passed. Evidence-backed recommended boundaries,
    rejected alternatives, weaknesses, ownership classifications, risks, and
    D1–D9 decisions are frozen. No item is active; stop unconditionally.
