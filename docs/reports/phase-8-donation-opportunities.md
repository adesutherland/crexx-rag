# Phase 8 donation, adoption, compatibility, and retirement opportunities

Report date: 2026-08-24

Status: Phase-8 report complete. Gate 8 programme closeout is **not satisfied**.
This report is intentionally not a tutorial. It records opportunities and
ownership/adoption state; it does not submit a donation, coordinate an upstream
decision, cut over the product, start a compatibility-release clock, remove
native code, publish a release, push a branch, or edit the CREXX repository.

## Executive conclusion

cREXX-RAG has already converted several originally identified gaps into
installed CREXX capabilities: parse-once JSON, concurrent HTTP/TLS, the full
public SHA-256 family, and packed exact vector search. Those are upstream
adoptions to consume, not code to donate again.

Three locally owned generic candidates remain. The SQLite boundary is the
strongest near-term donation opportunity. The portable float32/vector package
is useful as a codec/reference fallback but needs a crisp split from installed
`rxvector`. The provider-neutral LLM package has broad value, but the current
cREXX hosted response-completion failure and unresolved lifecycle scope make it
unready for submission.

Gate 7 rejected/deferred product cutover. Consequently none of the RAG-specific
C++ core, C ABI, `rx_rag` plugin, native CLI/MCP, or shell orchestration is ready
for retirement. Native-v1 remains the default oracle.
No compatibility window has started.

## Opportunity ledger

| Facility | Ownership/adoption state | Evidence now available | Donation opportunity | Blocking work and decision |
| --- | --- | --- | --- | --- |
| SQLite typed boundary (`rxsqlite` candidate) | Locally owned native generic mechanism under `incubator/p1a/sqlite_boundary`; product SQL/repositories remain Level G | 20-file role-labelled maintained bundle; typed/binary values, statements, transactions, read-only, WAL processes, RXPA V2 session isolation, four-thread/400-row qualification, backup/integrity/cleanup, ADDRESS facade, optimized/non-optimized dual-VM probe, application use | **High / nearest ready.** A small installed SQLite mechanism would remove the downstream dynamic-boundary dependency without donating product policy | Final public name/version, upstream-owned package layout, installed external-consumer proof, CREXX task/native-provider integration, exact Linux/platform QA, API review, and explicit donation approval |
| Provider-neutral LLM/embedding (`rxllm` candidate) | Locally owned Level-G incubation over installed `rxfnsg`; product role/routing policy remains application-owned | 19-file bundle; normalized generation/structured/embedding records, OpenAI-compatible/OpenAI/Anthropic/Gemini mappings, deterministic shapes, privacy denial, usage/errors, external hosted quality and generation/embedding evidence | **Medium / valuable but not ready.** The contract and mappings could become a reusable advanced library | cREXX hosted response completion fails; provider-lifetime reuse, streaming/cancellation, catalogue/version policy, installed package proof, exact Linux, second consumer, API review, and explicit approval |
| Portable float32 codec and exact-vector fallback | Locally owned Level-G codec/oracle; accelerated `rxvector` is already installed upstream | 14-file bundle; canonical `f32le-v1`, pure exact ordering, benchmark, four-cell probe, matched 11,684 × 768 evidence, application fallback | **Medium.** Donate only the portable representation/reference layer if CREXX wants it beside native `rxvector` | Decide package split and ownership versus installed `rxvector`, establish second consumer, finalize version/policy, installed proof, Linux, API review, explicit approval |
| Parse-once JSON (`rxjson`) | Already installed and consumed upstream | P1-JSON/P1-REC tests and Phase 3–7 application use | **No local donation.** Continue adoption and regression reporting | Upstream maintenance only; do not fork or rebundle |
| Concurrent HTTP/TLS (`rxfnsg`) | Already installed upstream | Typed bounded responses, compression, pooling/streaming/cancellation substrate, TLS tests, downstream local/synthetic use | **No substrate donation.** Report the hosted completion reproducer upstream as integration evidence | Exact downstream Linux and hosted provider completion; provider lifecycle belongs in `rxllm`, not HTTP duplication |
| SHA-256 (`rxhash`) | Already installed upstream and consumed directly | Eight public procedures, immutable transfer-safe state, file hashing, dynamic/static/native packaging, dual-VM/mode and downstream ingestion/backup use | **Adoption complete; no donation.** Keep the RAG workload as integration evidence | Exact downstream Linux only; no local hash implementation should return |
| Packed exact vector provider (`rxvector`) | Already installed upstream and selected acceleration | Exact portable ordering, static/native packaging, 11,684 × 768 matched workload | **Adoption complete.** Preserve portable fallback candidate separately | Exact downstream Linux and policy for the optional portable library split |
| Typed configuration/command helpers | No credible generic implementation boundary | Product `ragconfig`, `ragregistry`, and `ragcommand` provide design examples only | **Future research opportunity**, not a current bundle | Demonstrate a second non-RAG consumer and separate generic semantics from product vocabulary before creating a package |
| MCP transport helpers | No generic implementation boundary | Product `ragmcp` proves strict JSON-RPC, capability-scoped tools, and typed `structuredContent` | **Future research opportunity**, not a current bundle | Establish reusable server/codec API, second consumer, tests, packaging, and ownership; do not donate the RAG tool catalogue |

## Existing bundle status

P2-09 originally prepared three canonical review bundles totalling 52
hash-verified files. The maintained SQLite bundle now contains its session/
thread qualification, bringing a current staging run to 53 files without
rewriting the dated P2-09 evidence:

| Candidate | Files | Required roles | Submission state |
| --- | ---: | --- | --- |
| `rxsqlite-candidate` | 20 | docs, package, contract, source, tests, example, benchmark, reproducer, evidence | `review-bundle-not-approved`; `donation_submission_authorized=false` |
| `rxllm-candidate` | 19 | docs, package, contract, source, tests, example, benchmark, reproducer, evidence | `review-bundle-not-approved`; `donation_submission_authorized=false` |
| `rxvector-portable-candidate` | 14 | docs, package, contract, source, tests, example, benchmark, reproducer, evidence | `review-bundle-not-approved`; `donation_submission_authorized=false` |

The bundles are review inputs, not installable releases. Frozen P2-09 evidence
remains unchanged. The maintained `incubator/README.md` is the live candidate
inventory.

## Recommended donation sequence

1. **SQLite boundary first.** Request an upstream API/ownership review using the
   existing bundle, without proposing application SQL or immediate adoption.
   Add the missing installed-consumer/platform evidence before submission.
2. **Portable vector split second.** Agree whether CREXX wants only the codec,
   codec plus pure exact reference, or no separate package because `rxvector`
   already owns the public surface.
3. **Provider library after repair.** Do not submit `rxllm` while the current
   cREXX hosted provider cannot reliably complete the qualified POST. Repair
   that path, settle connection lifetime/stream/cancel scope, add a second
   consumer, then re-run the complete local/synthetic/hosted matrix.
4. **Future helpers only after a second consumer.** Configuration/command and
   MCP patterns are valuable design evidence but are still product-shaped.

Each future submission needs separate user approval and an upstream-owned
destination/branch. A report recommendation is not authority to create an issue, pull request, donation branch, or CREXX commit.

## Installed capability preference and fallback policy

The downstream CMake build already prefers the installed CREXX package through
`find_package(CREXX CONFIG)` and resets both retired source/vendored fallback
options to `OFF`. The installed compile helper fails when the application,
provider, or dynamic SQLite boundary is missing; it never searches the sibling
source tree. Runtime modules and the operator registry are explicit.

For future adopted donations:

- detect an installed facility by package/API version, never only by a filename;
- accept a known-compatible version range and fail clearly outside it;
- retain a namespaced local candidate only while the installed capability is
  absent or incompatible;
- never silently copy from a source checkout; and
- remove the local candidate only after installed-consumer, migration, and
  compatibility evidence passes.

## Compatibility and retirement readiness

| Native/product asset | Current role | Retirement readiness |
| --- | --- | --- |
| `cprag_core`, public C ABI, and `rx_rag` | Default executable oracle, version-1 semantics, comparison and migration authority | **Not ready.** Gate 7 rejected cutover; full same-session product evidence is incomplete |
| Native `crexx-rag` CLI | Current default operator entry and version-1 migration surface | **Not ready.** The Level-G public worker/provider and embedding-item path is incomplete |
| Native `crexx-rag-mcp` | Current default MCP oracle and retained evidence comparison | **Not ready.** cREXX MCP is staged but product cutover is rejected |
| Shell orchestration/wrappers | Current workflows and historical compatibility | **Not ready.** Remove only after a released cREXX default covers the workflow and migration period |
| Frozen native fixtures/goldens/defect evidence | Historical and semantic authority | **Never delete as retirement cleanup.** Preserve under the existing frozen-evidence policy |

A future compatibility release would first make cREXX the explicitly approved
default while retaining native-v1 read-only migration/diagnostics. Only after
that release's separately approved compatibility window could deletion be
considered. No release or window exists today.

## Gate 8 assessment

Gate 8 programme closeout is not satisfied:

- the product still contains and depends operationally on RAG-specific native
  algorithm/oracle code;
- default installed operation is still native-v1;
- no local generic candidate has an accepted upstream ownership status;
- no cREXX-default compatibility release has occurred; and
- retirement approval has not been requested or granted.

The useful Phase-8 deliverable is this maintained opportunity report plus its
audit. It gives each candidate and native asset an honest state and next proof
without converting proposed work into a donation, adoption, release, or
retirement claim.
