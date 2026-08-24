# Phase 6 public-surface evidence

Status: implemented and focused macOS acceptance passed on 2026-08-24. Phase 7
still owns corpus-wide production selection and cutover. Exact Linux replay is
not claimed.

## Checklist

| Item | Retained result |
| --- | --- |
| P6-01 | Level-G noun/verb CLI returns bounded human, JSON, and NDJSON `crexx-rag.command-result/1` records; `queue-status` emits a deprecation record. |
| P6-02 | Real `ADDRESS RAG` binds an immutable validated session and returns the same library identity/status and capability errors. |
| P6-03 | cREXX stdio MCP implements protocol `2025-06-18`, strict JSON-RPC validation, capability-specific tools, text plus typed `structuredContent`, and no raw mutation tools. |
| P6-04 | Ingest/improve/proposal plans and review previews are zero-write; exact reviewed ingest apply runs; control/ingest/curate tools are separately gated. |
| P6-05 | Four installable `SKILL.md` packages have versioned manifests, prerequisites, tool/schema lists, write declarations, examples and adversarial refusal rules. |
| P6-06 | The installed-source, no-checkout-fallback walkthrough is maintained in the [Phase-6 tutorial](../../tutorials/phase-6-surfaces.md). |
| P6-07 | The selected `queue-status` alias is retained for one compatibility release with replacement/removal metadata. |

## Focused matrix

`cmake/Phase6Surfaces.cmake` compiled the application and all transports both
optimized and non-optimized, then ran each on `rxvme` and `rxbvm`. Every cell:

- initialized a new schema-v2 bundle;
- proved database and manifest hashes unchanged by read and plan sessions;
- created ingest, improvement and proposal plans;
- applied the exact reviewed ingest plan to installed tutorial sources;
- returned bounded typed evidence;
- returned the same library identity through CLI, ADDRESS and MCP;
- rejected an apply tool from plan-only MCP despite the caller knowing its
  exact name and arguments;
- validated strict/malformed JSON-RPC behavior and capability-specific tool
  advertisement;
- emitted the machine-readable deprecation record; and
- completed generation-pinned backup and fresh-target restore.

Focused result: four of four cells passed. Provider credentials were neither
resolved nor printed and no hosted request was made.

## Packaging

The CMake install now includes the preserved native-v1 oracle executables, the
generic SQLite dynamic boundary, cREXX application/provider sources, four
skills, tutorial fixture, tutorials, and an installed compile helper. A scratch
consumer compiled exclusively from the installed prefix with CREXX source
fallback disabled, then initialized and inspected a fresh library in all four
optimized/non-optimized by `rxvme`/`rxbvm` cells. Existing CREXX
`rxhash`/`rxvector` dynamic and static/native provider selection remains
consumed authority; the local SQLite boundary is a namespaced donation
candidate rather than an invented static product handle. The full Level-G
product still uses that dynamic SQLite boundary, so this is not represented as
a fully static native product package.

Retained scratch result:

```text
P6_INSTALLED_OK mode=opt vm=rxvme source_fallback=off
P6_INSTALLED_OK mode=opt vm=rxbvm source_fallback=off
P6_INSTALLED_OK mode=noopt vm=rxvme source_fallback=off
P6_INSTALLED_OK mode=noopt vm=rxbvm source_fallback=off
```

## QA

- fresh ordinary Debug `phase6_surfaces`: pass in all four cells;
- fresh Release `phase6_surfaces`: pass in all four cells;
- focused Apple AddressSanitizer `phase6_surfaces`: pass through the CREXX
  runner with a coherent ASan-installed CREXX product and downstream build;
  retained log
  `/tmp/crexx-rag-asan-logs/phase6/20260824-014829-build/build.log`;
- Apple LeakSanitizer: unsupported, explicitly disabled, and not claimed;
- scratch-installed external consumer with source fallback off: pass in all
  four compiler/VM cells; and
- full ordinary Debug CTest: 73/73 passed in 205.89 seconds; and
- exact downstream Linux: open and not claimed.

`git diff --check` is recorded at the ordered Phase-6 commit closeout.

## Gate statement and limitation

Gate 6 is accepted for the recorded macOS human/agent surface and safety scope.
The Phase-4 worker engine, fencing and supervisor soak remain authoritative.
The public provider-backed long-running worker adapter and the cREXX hosted
POST-completion failure are explicit Phase-7 cutover limitations; therefore
this gate does not select the cREXX path as the production default. MCP is
read-only by default, skill knowledge never grants write authority, and
operator process supervision remains outside agent permissions.
