# Gate-1A Approved CREXX Candidate Replay Worklist

Status date: 2026-07-31. Authority is limited to selecting the approved CREXX
candidate, replaying the completed Phase-0/Phase-1A evidence, removing only
proven downstream accommodations, and returning to the Gate-1A stop. Phase 1B
and later work remain unauthorized.

Status: complete; all replay items accepted; stopped at Gate 1A.

Legend: `[ ]` not started, `[~]` active, `[x]` accepted, `[!]` blocked. At most
one item may be active. Each accepted item must link exact commands, versions,
hashes, focused results, failures, and remaining seams from this dated evidence
directory.

## Initial preservation snapshot

- Writable repository: `main` at
  `97cd87e91344d6ac1773a054bd38df23eb128ed2`, tracking `origin/main` at `+0/-0`.
- Its pre-existing tracked working diff is 27 files, 574 insertions and 55
  deletions. Its pre-existing staged diff is 17 rename-only files.
- Pre-existing fingerprints:
  - tracked binary diff:
    `97443028cfa8e86624fc5fda9ea5fb33d02f4d7413e5a8a848d92ec365288ef9`;
  - staged binary diff:
    `30cea35503c6dc073f3007218b9458f2bc0c28b2c7661327b9144036d5a7c61d`;
  - branch-aware porcelain-v2 status:
    `cef820082b229b46110683617b942275ae9f41ddb18802ef07bc2485d9fbd531`.
- Read-only CREXX: `develop` at the exact approved commit
  `ea25d1720c8dc4044614fa6ac4789811289dc8ca`, subject
  `feat: close crexx-rag integration ledger`, tracking `origin/develop` at
  `+0/-0` with empty tracked and staged diffs.
- CREXX has the five pre-existing untracked lifecycle `.rxbin` artifacts listed
  by its closeout. Its initial tracked and staged diff hashes are the empty-file
  SHA-256 and its branch-aware porcelain-v2 hash is
  `b2367883c01526fec417c6065157baa35cfafb57d8aa0a39656d1dfb50836efc`.
- No hosted call, credential use, normal-prefix install, sister-repository
  write, staging, commit, push, or pull request is authorized.

## Candidate replay

- [x] **R1 — freeze live state and select the approved CREXX source**
  - Maps to the Gate-1A preservation gate and CRI-01 through CRI-14 provenance.
  - Acceptance: required reading complete; both repositories audited; CREXX
    branch, HEAD, subject, status, and diff state match the approved candidate.
- [x] **R2 — clean CREXX build, scratch install, and artifact fingerprint**
  - Maps to `P1A-SDK-01` and CRI-07/08/14.
  - Acceptance: fresh `mktemp` build and install roots; installed executable,
    VM, header, library, helper, and CMake package manifest with hashes; no
    normal-prefix or source-tree selection.
- [x] **R3 — clean no-fallback downstream configure and provenance proof**
  - Maps to `P1A-SDK-01` and the Gate-1A full configure/build gate.
  - Acceptance: both fallback switches off; every selected CREXX path resolves
    beneath the scratch prefix; clean out-of-tree build succeeds or retains the
    exact seam.
- [x] **R4 — CRI-01/04/05/06 compiler-workaround removal**
  - Maps to `P1A-DATA-01`, `P1A-SUR-01`, and CRI-01/04/05/06.
  - Acceptance: intended Level G PARSE restored, dummy unreachable returns
    removed, imported typed record returned through Level G, and structured
    malformed-signature diagnostics asserted, each with the smallest focused
    optimized/non-optimized and dual-VM proof where applicable.
- [x] **R5 — CRI-02 binary-helper replay and accommodation decision**
  - Maps to `P1A-DATA-01` and CRI-02.
  - Acceptance: genuine read-only by-value helper matches checksums in all four
    mode/VM cells; exposure/direct access retained only where intrinsically
    appropriate, with exact timings and rationale.
- [x] **R6 — CRI-07/08 SDK fallback retirement**
  - Maps to `P1A-SDK-01` and CRI-07/08.
  - Acceptance: vendored/generated header and build-helper fallback paths are
    removed only after a focused scratch-installed consumer pass.
- [x] **R7 — CRI-09/13 production JSON and packed-numeric migration**
  - Maps to `P1A-DATA-01`/`P1A-VEC-01` and CRI-09/13.
  - Acceptance: competing incubator JSON/vector envelope retired; callers use
    production `rxjson.jsondocument` plus explicit `node_f32_array` and
    `node_i64_array` owning raw little-endian binaries whose type/count/
    dimension meaning belongs to the application schema.
- [x] **R8 — CRI-10/11/12 runtime and ADDRESS replay**
  - Maps to `P1A-LLM-01`, `P1A-SUR-01`, and CRI-03/10/11/12.
  - Acceptance: retired `rx_socket` module argument removed; deterministic
    loopback and both VMs pass; redirect lifecycle/argv behavior remains
    explicit; historical Google delay is not reclassified as `rxhttp`.
- [x] **R9 — CRI-14 external operation-contract adoption**
  - Maps to `P1A-SUR-01` and CRI-14.
  - Acceptance: any required external contract is generated as
    `crexx.operation-contract/1` through installed `crexx-contract` and
    `crexx_add_operation_contract()`; no private RXBIN graph dependency.
- [x] **R10 — complete deterministic/loopback validation and Gate-1A closeout**
  - Maps to the Gate-1A full configure/build/CTest/preservation gate.
  - Acceptance: exact totals, failures, skips, timings, hashes, full provenance,
    refreshed CRI-01 through CRI-14 disposition matrix, integration ledger,
    roadmap/status/test-strategy links, final preservation audit, and an
    unconditional stop before Phase 1B.
