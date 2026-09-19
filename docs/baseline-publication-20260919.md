# Local vector baseline publication — 19 September 2026

Adrian approved publishing the generic rxvector changes in CREXX through the
available hotfix checkout, installing that published cohort, and then rebuilding,
qualifying and publishing the accumulated RAG baseline against it. This record
owns the delivery evidence; [ROADMAP.md](ROADMAP.md) remains the current register.

## Outcome and acceptance

- **PUB-01 (open):** CREXX's generic C float32 owner, binary codec, exact search
  and documentation are published through hotfix to origin/develop after normal
  local product/functional gates; automatic publication CI is checked by SHA.
- **PUB-02 (passed):** The exact clean CREXX product is installed to `~/.local`,
  with matching native-inference packaging and installed provider acceptance.
- **PUB-03 (passed; closing documentation audit below):** RAG builds against that normal published cohort and the
  complete required 130-case local selection passes with exact-input receipt
  accounting. Provider changes retain Gemini smoke and malformed/privacy cases.
- **PUB-04 (open):** The reviewed RAG baseline is committed/published to
  origin/main and installed; installed artifact hashes and a fresh scratch
  public CLI/MCP check match the qualified build. No user corpus processing,
  tagged release or hosted model calls are part of this publication.

## Steps

1. **PUB-STEP-01 (active):** Qualify and publish CREXX, preserving unrelated
   working changes; verify automatic development workflows (PUB-01).
2. **PUB-STEP-02 (complete):** Preserve the previous installed cohort, install
   the published CREXX product and verify the new API/package (PUB-02).
3. **PUB-STEP-03 (complete):** Reconfigure RAG for the normal installation,
   rebuild once and run the required disjoint QA selection, reusing valid
   targeted receipts when widening coverage (PUB-03).
4. **PUB-STEP-04 (active):** Baseline/publish/install RAG, verify identity and
   installed behavior, and record remaining scope (PUB-04).

## Scope and existing evidence

The RAG baseline includes the previously approved local BGE atomic embedding
windows, profile replacement, vector reporting and publication/reactivation
repairs, retrieval reader/verification improvements and the final rxvector
consolidation. USearch and the private vector SDK overlay are removed. SQLite
and all product policy remain Level G. Existing RXVIDX/1 sidecars remain readable.
The exact route is opt-in; IVF configuration and the original Scottish corpus
are unchanged by this publication.

[Initial consolidation qualification](rxvector-consolidation-20260919.md)
retains the 130/130 local receipts, provider ASan/UBSan checks and paired Scottish
query comparison: twenty identical passage orders, median 0.965 s on both
rxvector and USearch, maximum score difference 9.38e-8. That private runtime
cohort is historical evidence; the newly installed toolchain requires a fresh
RAG gate. The model-load scheduling and launcher-cohort fixture repairs are
included rather than repeating the known failing arrangements.

CREXX source: `5949ef27efd813b8bb96d23c58717b9a72aad1b9`, published to
origin/hotfix and origin/develop and installed to `~/.local` with `dirty=0`.
Its RXVECTOR-02 plan owns upstream acceptance. The ordinary development
publication policy uses local product/affected functional checks and automatic
Build/CodeQL gates; separate overnight deep/sanitizer matrices are not manually
dispatched for this routine publication.

Evidence root:
`/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/rxvector-publication-20260919/`.
The previous user prefix is retained under `previous-user-prefix/`. The normal
Release product, optional providers and matching native-inference runtime package
built successfully. The unique union of essential/smoke, vector and RXPA object
checks passed **210/210 in 51.05 seconds**. The external native consumer built
through the installed CREXX driver and returned `RXVECTOR_INDEX_OK`.

Installed `bin/rxvector.rxplugin` and `bin/providers/rxvector.rxplugin` agree:
`918a38ee15d965bfcd70c797248bc29bbbaedfb6f703a7c66324f84af57d6c2f`.
Both installed static archive locations agree:
`eff583097f198f7a2e330596433bcdc291f854cee992d888cffa662fb378499e`.
`installed-crexx.json` retains the clean BUILDINFO and hashes.

Automatic [Build CREXX](https://github.com/adesutherland/CREXX/actions/runs/35438671112)
and [CodeQL](https://github.com/adesutherland/CREXX/actions/runs/35438670978)
are running for the exact source SHA. RAG builds with
`CREXX_DIR=/Users/adrian/.local/lib/cmake/CREXX`.

## RAG qualification and installation

The complete required selection passed **130/130 in 720.51 seconds**: all 130
cases executed once against the changed installed runtime. No failure, disabled
case or product repair occurred. This includes the Gemini loopback smoke,
malformed-output/privacy controls, native vector/publication and BGE window
contracts, worker recovery, and scratch-installed product journey. The real BGE
case passed in 12.18 s and the selected-runtime process-worker case in 32.43 s.
Only changed documentation needs a final focused check and exact-input audit.

Qualified and normally installed native SHA-256:
`b84eb9127977dbbc6ce0a4d2c353106e07ca0cb9e5b2aba13bdb4510900d6ee5`.
Qualified and normally installed linked SHA-256:
`a5cf3777edfa2b4f60e95aae183673b2b9f96b61d0d2f899e0e853088bd7b8dc`.
The existing qualified artifacts were installed without rebuilding.

Fresh scratch initialization, doctor, status and verification passed through
the actual `~/.local/bin/crexxrag`; fresh MCP status and verification passed too.
The initial smoke mistakenly requested doctor for an explicitly selected library
before initialization; its expected missing-library refusal is retained in
`installed-smoke/doctor-before-init.json`. Initializing that scratch library
completed the ordinary public precondition; no product or test-suite change
was needed.

One network-denied hybrid query against the existing frozen Scottish scratch
copy used one local BGE call and `rxvector-exact`. All twelve ordered passages,
scores and claims exactly match the retained rxvector reference at generation
29748. It took 2.41 s; this is an actual-install smoke, not a replacement for
the retained twenty-query performance comparison. The master corpus was untouched.

`installed-rag.json`, `installed-smoke.json` and
`installed-query-comparison.json` retain these installation checks. The commit
containing this baseline records the qualified product sources; exact Git
publication identities and automatic CI closure follow in this record.

## Remaining scope

This is publication of development branches, with no new beta tag. RAG has no
configured hosted workflow; its 130-case gate is local macOS qualification.
The separate scale lane, Linux leak assurance, RAG cross-platform/endurance and
hosted model acceptance remain separate. ESC-OPS-03 lifecycle recording,
quotation/content quality and migration database contention remain open in the
master register. This vector baseline does not close those unrelated outcomes.
