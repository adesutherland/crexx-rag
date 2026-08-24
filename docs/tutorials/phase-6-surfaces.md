# Phase 6 tutorial: one product through CLI, ADDRESS RAG, MCP, and skills

This tutorial starts from a scratch install, compiles only the installed
cREXX-RAG application package, and exercises the same Level-G dispatcher
through all three public transports. It does not use either source checkout at
runtime. The permanent `phase6_surfaces` test executes the walkthrough in
optimized and non-optimized modes on `rxvme` and `rxbvm`.

The native-v1 executables are still installed as the comparison oracle. Phase
7 owns the cutover decision; this tutorial does not rename, delete, or silently
replace them.

## 1. Install and compile the staged cREXX application

From a configured downstream build and the installed CREXX prefix used to
configure it:

```bash
export CREXX_PREFIX=/path/to/installed-crexx
export RAG_PREFIX=/tmp/crexx-rag-phase6-install
export RAG_APP=/tmp/crexx-rag-phase6-app

cmake --install cmake-build-debug --prefix "$RAG_PREFIX"
cmake \
  -DCPRAG_INSTALL_PREFIX="$RAG_PREFIX" \
  -DCPRAG_RXC="$CREXX_PREFIX/bin/rxc" \
  -DCPRAG_RXAS="$CREXX_PREFIX/bin/rxas" \
  -DCPRAG_CREXX_BIN_DIR="$CREXX_PREFIX/bin" \
  -DCPRAG_OUTPUT_DIR="$RAG_APP" \
  -P "$RAG_PREFIX/share/crexx-rag/cmake/CompileInstalledCrexxRag.cmake"
```

The helper fails if an installed source/provider file is absent. It writes the
compiled modules and `runtime-modules.txt` under `$RAG_APP`; it has no source
checkout fallback. Add `-DCPRAG_NOOPT=ON` and use a different output directory
to compile the same installed package without optimization.

For the commands below, define the installed dynamic-provider path and module
list:

```bash
export RAG_IMPORTS="$RAG_APP;$RAG_PREFIX/lib/crexx-rag/providers;$CREXX_PREFIX/bin"
export RAG_LIBRARY=/tmp/crexx-rag-phase6-library
export RAG_MODULES="$(cat "$RAG_APP/runtime-modules.txt")"
```

The examples spell out the runtime so it is obvious which VM is being used:

```bash
"$CREXX_PREFIX/bin/rxvme" -l "$RAG_IMPORTS" \
  "$RAG_APP/crexx_rag_cli" $=RAG_MODULES -a \
  --library "$RAG_LIBRARY" --config architecture-local \
  --profile generic-profile --access admin --format json library init
```

In zsh, `$=RAG_MODULES` expands the retained whitespace-separated module list.
Use a shell array in bash. Repeat the tutorial with `rxbvm` to select the
portable VM.

## 2. Review a zero-write plan, then apply exactly that plan

Copy the installed tutorial sources into the registered relative source-set
path and work from its parent:

```bash
mkdir -p /tmp/crexx-rag-phase6-work/source-docs
cp -R "$RAG_PREFIX/share/crexx-rag/tutorial/architecture-mini/." \
  /tmp/crexx-rag-phase6-work/source-docs/
cd /tmp/crexx-rag-phase6-work
```

Create the plan with `plan` authority. The JSON result includes
`records[0].fields.canonical_plan`, `digest`, expiry, the required `ingest`
capability, privacy/route choices, and budgets:

```bash
"$CREXX_PREFIX/bin/rxvme" -l "$RAG_IMPORTS" \
  "$RAG_APP/crexx_rag_cli" $=RAG_MODULES -a \
  --library "$RAG_LIBRARY" --config architecture-local \
  --profile generic-profile --access plan --format json \
  ingest plan --source-set architecture-docs > ingest-plan.json
```

Inspect the plan before granting write authority. For a machine-assisted local
walkthrough, extract the two exact strings without rewriting either value:

```bash
PLAN_JSON="$(jq -r '.records[0].fields.canonical_plan' ingest-plan.json)"
PLAN_DIGEST="$(jq -r '.records[0].fields.digest' ingest-plan.json)"

"$CREXX_PREFIX/bin/rxvme" -l "$RAG_IMPORTS" \
  "$RAG_APP/crexx_rag_cli" $=RAG_MODULES -a \
  --library "$RAG_LIBRARY" --config architecture-local \
  --profile generic-profile --access ingest --format json \
  ingest apply --plan-json "$PLAN_JSON" --expect-digest "$PLAN_DIGEST"
```

Apply revalidates the digest, expiry, generation, library/config/profile,
source set, provider route and capability before changing the library. Editing
the JSON or digest must return a conflict/integrity result rather than applying
something "close enough".

## 3. Query evidence and inspect work

```bash
"$CREXX_PREFIX/bin/rxvme" -l "$RAG_IMPORTS" \
  "$RAG_APP/crexx_rag_cli" $=RAG_MODULES -a \
  --library "$RAG_LIBRARY" --config architecture-local \
  --profile generic-profile --access read --format json \
  query evidence "Which component reads ADX?"

"$CREXX_PREFIX/bin/rxvme" -l "$RAG_IMPORTS" \
  "$RAG_APP/crexx_rag_cli" $=RAG_MODULES -a \
  --library "$RAG_LIBRARY" --config architecture-local \
  --profile generic-profile --access read --format json job list
```

`query evidence` returns `crexx-rag.evidence/1` inside the stable
`crexx-rag.command-result/1` envelope. `query answer` currently returns the
same evidence with a JSON `null` optional-answer field unless a qualified
answer provider is selected by the caller.

The deprecated one-release alias below still works and adds a machine-readable
`deprecation` record naming `job list` as the replacement:

```bash
# same global arguments as above
queue-status
```

The durable worker engine, crash recovery, fencing and literal eight-hour soak
are proven in Phase 4. Process supervision remains operator-owned. The staged
Phase-6 application deliberately does not pretend that the current
one-operation provider adapter supplies production worker lifetime reuse,
streaming or cancellation; Phase 7 records that cutover limitation.

## 4. Improvement and proposal review without mutation

These commands require only `plan` and do not write the SQLite database or
manifest:

```bash
# same runtime/module/global prefix, with --access plan
improve plan
proposal plan --input-digest aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
review list --limit 20
review decide REVIEW_ID --decision accept --apply false
```

The separately granted `curate` capability is required for
`improve apply`, `proposal apply`, or an applied review decision. The exact
canonical plan and digest remain mandatory. Accepted review records do not by
themselves bypass exact proposal replay.

## 5. Use ADDRESS RAG from cREXX

Import the installed `rag_address_environment` module, then bind a session:

```rexx
options levelg
import rxfnsb
import rag_address_environment

address RAG "LIBRARY OPEN /tmp/crexx-rag-phase6-library --config architecture-local --profile generic-profile --access read --format json"
address RAG "LIBRARY STATUS" output status_lines
address RAG "QUERY EVIDENCE \"Which component reads ADX?\"" output evidence_lines
address RAG "LIBRARY CLOSE"
```

Quoted command arguments preserve case and content. `LIBRARY OPEN` updates the
session only after all options validate. Failed opens do not partially replace
the previous session. The same capability gates and result envelope apply.

## 6. Use the cREXX MCP server and narrow skills

Start the compiled cREXX server read-only:

```bash
"$CREXX_PREFIX/bin/rxvme" -l "$RAG_IMPORTS" \
  "$RAG_APP/ragmcp" $=RAG_MODULES -a \
  --library "$RAG_LIBRARY" --config architecture-local \
  --profile generic-profile --access read
```

It implements MCP `2025-06-18` initialization, `tools/list`, and `tools/call`.
Tool results contain both a short text item and typed `structuredContent` equal
to the CLI/ADDRESS result. Read mode advertises status, sources, evidence,
search, trace/path/timeline, and job status/events. `plan`, `diagnose`,
`control`, `ingest`, and `curate` add only their declared tools; no mode exposes
raw SQL or raw entity/edge mutation.

Install one narrow package from `$RAG_PREFIX/share/crexx-rag/skills`:

- `crexx-rag-qa` — read-only evidence and answers;
- `crexx-rag-ingest` — plan, with separately authorized ingest apply;
- `crexx-rag-improve` — plan/review, with separately authorized curation; or
- `crexx-rag-diagnose` — read-only verification and redacted diagnostics.

Each manifest lists tools, schemas and write capabilities. Calling a known
apply tool from a plan-only MCP process fails: knowing the workflow does not
grant authority.

## 7. Backup and restore

```bash
# with the same runtime/module prefix
--library "$RAG_LIBRARY" --config architecture-local --profile generic-profile \
  --access admin --format json library backup --output /tmp/phase6-backup

--library /tmp/phase6-restored --config architecture-local --profile generic-profile \
  --access admin --format json library restore \
  --input /tmp/phase6-backup --output /tmp/phase6-restored
```

The Phase-6 matrix performs the same pinned backup/fresh-target restore in all
four compiler/VM cells. Never copy a live SQLite file and sidecars by hand.

## Expected proof

From the source tree, the complete permanent walkthrough is:

```bash
cmake --build cmake-build-debug --target phase6_surfaces
```

A pass ends with:

```text
Phase 6 passed: four optimized/non-optimized dual-VM fresh-product cells, exact reviewed ingest, zero-write plans, CLI/ADDRESS/MCP semantic equality, capability denial, deprecation, backup/restore, and installable skill manifests
```
