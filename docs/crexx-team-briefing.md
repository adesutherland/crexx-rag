# CREXX Team Briefing: External Plugin And RAG Controller Findings

> [!CAUTION]
> Historical snapshot prepared on 2026-06-28. Its native-core ownership model
> is superseded by the approved [cREXX-only specification](crexx-only-vision-and-specification.md).
> Retain it as CREXX surface evidence; do not use it as current architecture.

Prepared from the `crexx-rag` repository documentation and a local toolchain
check on 2026-06-28.

## Executive Summary

`crexx-rag` is using CREXX in the role it is best suited for: a tunable policy
and orchestration layer over a native C/C++ core. The core owns storage,
retrieval, graph writes, queue state, and adapter-neutral data contracts. CREXX
profiles choose vocabulary, ranking policy, model routing, ambiguity handling,
and validation before facts are written.

The current experience proves that CREXX can run this style of workload, but it
also exposes several issues that matter for external adopters:

- The installed CREXX package has the compiler, assembler, VM, runtime plugins,
  and libraries, but not the RXPA development header or installed plugin build
  metadata needed by an external native plugin project.
- Dynamic plugin execution works, but the distinction between compile/import
  paths and runtime module loading is easy to miss and needs first-class
  documentation or tooling.
- CREXX profile controllers now call local model and CLI adapters in realistic
  loops. This has surfaced practical needs around `ADDRESS COMMAND` argv
  handling, stdout/stderr capture, array lifecycle, and multi-line output.
- Local LLM orchestration repeatedly needs tolerant parsing, schema validation,
  and structured repair diagnostics for "nearly right" tool or model output.
- Large JSON traversal through repeated `jsonget` calls can become a bottleneck
  in corpus-scale controllers. Paged native APIs are the current workaround, but
  CREXX-side parsed handles, iterators, or cursor-like access would help.

The highest-value CREXX-side improvement is a complete installed development
surface for native plugins. The next highest is a small set of runtime/library
ergonomics for command-shaped tool calls and structured-output validation.

## Project Context

`crexx-rag` is a local-first GraphRAG experiment with these layers:

- `cprag_core`: native C/C++ library and stable C ABI.
- `crexx-rag`: command-line tool for human use, smoke tests, and model adapters.
- `crexx-rag-mcp`: read-oriented MCP adapter for client tools.
- `rx_rag.rxplugin`: CREXX RXPA dynamic plugin over the same native core.
- `crexx/cprag.crexx`: object-shaped CREXX wrapper over raw plugin functions.
- `crexx/profiles/pipeline_profile.crexx`: shared profile policy contract.
- Staged CREXX controllers for candidate census, adjudication, graph seeding,
  extraction queue ranking, and gated extraction.

The intended design keeps native code responsible for durable state and CREXX
responsible for orchestration:

- Native core: chunks, sources, graph writes, support accumulation, candidate
  tables, work queues, attempts, traversal, and search.
- CREXX profiles: which stage to run, limits, cursors, queue names, local model
  routing, validation policy, and profile vocabulary.
- CLI and MCP: adapters over the same core operations, not separate pipelines.

CREXX is therefore not being asked to provide embeddings, FAISS, a graph
database, or an LLM runtime. It is being used as the profile and controller
language that decides when and how those adapter-level pieces are invoked.

## Local Toolchain Facts

Observed on this machine on 2026-06-28:

- `crexx`: `/Users/adrian/.local/bin/crexx`
- `rxc`: `/Users/adrian/.local/bin/rxc`
- `rxas`: `/Users/adrian/.local/bin/rxas`
- `rxvme`: `/Users/adrian/.local/bin/rxvme`
- `crexx --help` reports:
  `crexx-1.0.0-beta.3+local.gb1ea36795be6.dirty` built `20260624`
- No installed `crexxpa.h` was found under `/Users/adrian/.local`.
- No installed `RXPluginFunction.cmake` was found under `/Users/adrian/.local`.
- An isolated configure check with
  `-DCPRAG_ALLOW_VENDORED_CREXXPA=OFF` completed, but CMake warned that the
  installed CREXX RXPA header was missing and skipped the CREXX plugin target.

Current repository workaround:

- `third_party/crexx-rxpa/crexxpa.h` is vendored temporarily from the sibling
  CREXX source checkout.
- `third_party/crexx-rxpa/crexx_version.h` is also vendored because
  `crexxpa.h` includes the generated version header.
- The source-checkout fallback is opt-in only and should remain diagnostic, not
  a normal external-project dependency.

## What Works Today

The non-CREXX core, CLI, MCP server, and tests build without CREXX headers.

With the temporary vendored RXPA header, the project can build
`rx_rag.rxplugin` and run installed-toolchain smoke tests that explicitly call
`rxc`, `rxas`, and `rxvme`.

The working dynamic plugin pattern is:

```bash
rxc -i "<compiled-wrapper-dir>;<plugin-dir>;<crexx-bin-dir>" -o <program> <source.crexx>
rxas -o <program> <program>
rxvme -l "<compiled-wrapper-dir>;<plugin-dir>" <program> pipeline_profile rx_rag -a ...
```

The important lesson is that `-i` lets the compiler import plugin signatures,
but it does not by itself make the native plugin available to the VM at runtime.
The runtime still needs the plugin directory in the VM location path and the
plugin module name, such as `rx_rag`, listed in the runtime module list.

CREXX also works well conceptually as the policy layer. The staged controllers
now prove realistic controller behavior:

- Stage 1 records a cheap candidate census.
- Stage 1b adjudicates candidates into keep, junk, ambiguous, type, and alias
  decisions.
- Stage 2 uses a native page helper to seed graph evidence in transactions.
- Stage 2b builds durable extraction queue rows.
- Stage 3 consumes queue rows, calls a local extraction adapter, validates
  proposals, writes accepted graph facts, and records `work_attempts`.

## Priority Findings And Requests

### P0: Install A Complete RXPA Development Surface

Finding:

External native plugin projects cannot build from the installed CREXX package
alone because the RXPA development header is not installed. The current project
must vendor `crexxpa.h` and the generated `crexx_version.h`, which creates a
version-skew risk and makes the installed package look incomplete to plugin
authors.

Requested CREXX changes:

- Install `rxpa/crexxpa.h` as part of the default local install or a clearly
  named development package.
- Install every transitive header required by `crexxpa.h`, especially the
  version-matched generated `crexx_version.h`.
- Expose the RXPA ABI version and CREXX build id through the installed headers
  or a machine-readable command.

Suggested acceptance test:

```bash
cmake -S /path/to/crexx-rag -B /tmp/crexx-rag-no-vendor -G Ninja \
  -DCPRAG_ALLOW_VENDORED_CREXXPA=OFF
cmake --build /tmp/crexx-rag-no-vendor --target _rag
ctest --test-dir /tmp/crexx-rag-no-vendor -L crexx --output-on-failure
```

Expected result: the plugin target is configured and built against installed
CREXX development files, with no vendored header and no sibling source checkout.

### P0: Provide Installed Plugin Build Metadata

Finding:

External CMake projects need to know the include directories, plugin naming
convention, compile definitions, link flags, runtime plugin search locations,
and CREXX version. Today `crexx-rag` carries local CMake discovery logic and
guesses likely include directories near the installed binary.

Requested CREXX changes:

- Install a CMake package/config file for external native plugin projects.
- Install `RXPluginFunction.cmake` or an equivalent target helper outside the
  source tree.
- Provide a command such as `crexx --print-dev-info`,
  `crexx --print-plugin-cflags`, or `crexx --print-plugin-json`.

Suggested machine-readable fields:

```json
{
  "version": "crexx-1.0.0-beta.3",
  "build_id": "gb1ea36795be6",
  "bin_dir": "/Users/adrian/.local/bin",
  "include_dirs": ["/Users/adrian/.local/include/crexx"],
  "library_dirs": ["/Users/adrian/.local/lib"],
  "plugin_prefix": "rx",
  "plugin_suffix": ".rxplugin",
  "rxpa_cflags": ["-DBUILD_DLL"],
  "rxpa_defines": ["PLUGIN_ID=<module>"],
  "runtime_module_paths": ["/Users/adrian/.local/bin"],
  "tools": {
    "rxc": "/Users/adrian/.local/bin/rxc",
    "rxas": "/Users/adrian/.local/bin/rxas",
    "rxvme": "/Users/adrian/.local/bin/rxvme"
  }
}
```

Acceptance criteria:

- An external CMake project can discover CREXX with one `find_package` or one
  documented command invocation.
- The same metadata tells the project how to compile, name, and run a dynamic
  plugin without reading the CREXX source checkout.

### P1: Document And Diagnose Dynamic Plugin Loading

Finding:

The compiler/import phase and VM runtime phase are separate. `rxc -i` can see a
locally built `.rxplugin`, but `rxvme` still needs the plugin directory and the
runtime module name. This is correct once understood, but it is easy for new
plugin authors to misdiagnose.

Requested CREXX changes:

- Document the external dynamic plugin flow against an installed CREXX tree.
- Clearly state that `-i` is compile/import only.
- Show a minimal `rxc`, `rxas`, and `rxvme` sequence for a locally built plugin.
- Add driver or VM diagnostics that suggest the missing runtime module or
  plugin search path when a known imported native function cannot be resolved.

Useful example:

```bash
rxc -i "<plugin-dir>;<crexx-bin-dir>" -o my_profile my_profile.crexx
rxas -o my_profile my_profile
rxvme -l "<plugin-dir>" my_profile rx_rag -a --args
```

Acceptance criteria:

- A user can build and run an external plugin using only installed CREXX docs,
  installed files, and a small sample project.
- Missing runtime module errors point users toward `rxvme -l ... <module>`.

### P1: Improve RXPA String API Const Correctness

Finding:

The RXPA `SETSTRING` and `RETURNSIGNAL` macro path ultimately passes strings to
a callback typed as mutable `char *`. External plugin code often has string
literals or `const char *` error/status messages, which produces warnings or
forces local mutable copies.

Requested CREXX changes:

- Consider accepting `const char *` where the callee does not mutate string
  contents.
- If ABI compatibility prevents that, provide const-safe wrapper macros for
  common return and signal cases.

Acceptance criteria:

- A plugin can return string literals and immutable error text without casts,
  local buffers, or compiler warnings.

### P1: Add A First-Class `ADDRESS COMMAND` Argv Form

Finding:

CREXX controllers call command-shaped adapters such as:

- `crexx-rag advise-llama-server --stdin ...`
- `crexx-rag extract-llama-server --stdin ...`

Passing chunk text through stdin works well and avoids quoting user text. The
remaining rough edge is command construction. Current lessons are:

- Use direct `ADDRESS COMMAND`, not `sh`, unless a shell feature is truly
  needed.
- Leave the executable token unquoted.
- Quote arguments, not the executable path.
- Send source text through stdin arrays.
- Capture stdout/stderr into arrays.
- Clear output arrays with `arraydrop` before reuse because captures append.

Requested CREXX changes:

- Provide or document an argv-vector form for `ADDRESS COMMAND`.
- Preserve stdin-from-array and stdout/stderr-to-array behavior.
- Avoid command-string parsing ambiguity for executable paths, model ids, URLs,
  profile names, and user-provided text.

Illustrative target shape:

```rexx
argv = .string[]~of(cli, "advise-llama-server", "--stdin",
                    "--task", "candidate-adjudication",
                    "--profile", profile,
                    "--base-url", base_url,
                    "--model", model)
ADDRESS COMMAND argv input lines output out error err
```

The exact syntax is a CREXX design choice; the core need is to avoid rebuilding
shell quoting rules in every profile script.

Acceptance criteria:

- Paths with spaces, model identifiers with punctuation, URLs, and arbitrary
  user text can be passed without shell quoting.
- Existing stdout, stderr, and stdin array capture use cases remain supported.

### P1: Make Multi-Line Command Capture Easier And Safer

Finding:

LLM and CLI adapters naturally emit line-oriented output. CREXX can redirect
stdout/stderr into arrays today, but profile authors must remember array
lifecycle details and write manual loops each time.

Requested CREXX changes:

- Document stdout/stderr array capture prominently with examples.
- Document that repeated captures append unless the redirect target is cleared.
- Provide a standard reset option or capture object that does not require
  explicit `arraydrop` before every command.
- Provide small helpers to iterate, map, join, and inspect captured lines.

Acceptance criteria:

- A profile can repeatedly call a CLI adapter in a loop without stale output
  leaking into the next result.
- The recommended pattern is obvious from the command documentation.

### P1: Improve Large JSON Traversal Performance

Finding:

The Scotland Stage 1b trial exposed a performance cliff: loading a full
candidate census JSON array into Rexx and repeatedly calling `jsonget` made
`rxvme` CPU-bound before the first model call. The project-side mitigation was
to expose paged native APIs such as `pendingcandidatecensus` and keep each page
small. Even so, profile scripts still perform many repeated JSON path reads.

Requested CREXX changes:

- Add cached parsed JSON handles, so a string is parsed once and then traversed
  many times.
- Add object/array iterators or cursor-like access for large result sets.
- Consider compiled/cached JSON paths for repeated path lookups.
- Provide a convenient way to materialize an array of records into CREXX-native
  objects or stems without repeated string path walking.

Acceptance criteria:

- Traversing a page of candidate records scales with the number of records and
  fields, not with repeated reparsing or expensive path interpretation.
- A benchmark resembling `pendingcandidatecensus -> loop rows -> jsonget fields`
  is fast enough to keep model calls, not JSON traversal, as the dominant cost.

### P1: Add Tolerant Structured-Output Helpers For LLM/Tool Workflows

Finding:

Local models often return output that is close to the requested structure but
not exact: missing optional fields, extra commas around numbers, Markdown table
rows instead of plain records, confidence values with punctuation, or unexpected
enum casing. The profile should repair harmless deviations, reject unsafe rows,
and record what happened.

Requested CREXX changes:

- Provide tolerant record parsing for pipe-separated rows, CSV-ish rows, and
  Markdown table rows.
- Provide numeric coercion with defaults and min/max clamping.
- Provide enum validation with canonicalization.
- Provide field-count repair for missing optional fields and obvious extra
  separators.
- Return structured diagnostics for each repaired or rejected field.
- Consider a small schema/contract surface for external tool results.

Illustrative target shape:

```text
fields:
  status: enum keep|junk|ambiguous
  type: enum clan|person|place|event|generic default generic
  confidence: number min 0 max 1 default 0.5
  aliases: list separator comma optional
policy:
  repair harmless whitespace/case/punctuation
  reject unknown status
  report repaired fields
```

Acceptance criteria:

- CREXX profile code can safely consume imperfect local-model output without
  duplicating parser boilerplate across controllers.
- Repairs and rejections are visible to logs or durable attempt metadata.

### P2: Make Custom Address Environments Easy To Build

Finding:

`crexx-rag` wants one operation vocabulary across native helpers, CLI commands,
CREXX functions, CREXX address-environment commands, and MCP tools. A future
`ADDRESS CPRAG` environment should be a programmer-friendly command surface over
the same operations, not a shell-script reimplementation.

Requested CREXX changes:

- Provide a documented template for implementing custom address environments
  backed by native plugins or CREXX modules.
- Include examples for command parsing, typed arguments, diagnostics, and
  mapping command verbs to native operations.
- Clarify how address environments should report structured errors.

Candidate commands for a future `ADDRESS CPRAG` surface:

```text
COLLATE CANDIDATES PROFILE scotland
ADJUDICATE CANDIDATES MODEL qwen2.5-3b
RANK CHUNKS USING graph vector
PUSH EXTRACTION SOURCE chunk:123
EXPORT DOT TYPES clan,place
```

Acceptance criteria:

- A profile author can write policy-shaped CREXX instead of hand-building CLI
  command strings while still calling the same native operations.

### P2: Strengthen Long-Running Job Observability

Finding:

Long-running ingestion, embedding, extraction, endpoint-resolution, and
background-improvement jobs need durable progress that can be read without raw
SQLite polling. The Scotland embedding run showed that ad hoc read-only progress
checks can still collide with writer-heavy jobs and contribute to
`database is locked` failures.

This is partly an application concern, not solely a CREXX runtime concern.
However, CREXX controllers are the foreground orchestration layer, so the
language and libraries can help.

Requested CREXX-adjacent support:

- Encourage status APIs rather than raw database polling in examples.
- Make it easy for controllers to publish planned, processed, failed, skipped,
  current-item, last-error, model/provider, timestamps, and throughput fields.
- Provide simple patterns for resumable controller loops and periodic status
  updates.

Acceptance criteria:

- A long-running CREXX controller can expose progress through public project
  APIs and logs without requiring an operator to inspect implementation tables.

### P2: Document CREXXSAA Cache Behavior For Plugin Authors

Finding:

Manual late-bound experiments can be affected by CREXXSAA cache state. The
project docs currently remind operators to use:

```bash
crexxsaa --location
crexxsaa --list
crexxsaa --clear
```

Requested CREXX changes:

- Document when CREXXSAA caching applies and when explicit `rxc`/`rxas`/`rxvme`
  flows bypass it.
- Include plugin-development troubleshooting guidance for stale cached binaries.

Acceptance criteria:

- External plugin authors know whether they are testing a newly assembled module
  or a cached artifact.

## Suggested CREXX Roadmap

1. Ship RXPA development headers and version-matched generated headers.
2. Ship CMake/dev metadata or a machine-readable `crexx --print-dev-info`.
3. Publish a minimal external dynamic plugin sample that builds from an
   installed CREXX tree only.
4. Improve diagnostics and documentation for compile/import versus runtime
   module loading.
5. Add or document argv-vector `ADDRESS COMMAND` execution and robust line
   capture patterns.
6. Add parsed JSON handles or iterators for efficient repeated traversal.
7. Add tolerant structured-output parsing and schema-validation helpers.
8. Provide custom address-environment templates for operation vocabularies.

## Suggested Acceptance Suite For CREXX

These tests would directly cover the issues surfaced by `crexx-rag`:

- External plugin no-source-checkout test:
  build a tiny RXPA plugin from installed CREXX files only.
- External plugin CMake test:
  configure with `find_package(CREXX)` or `crexx --print-dev-info`.
- Dynamic plugin runtime test:
  compile with `rxc -i`, then run with `rxvme -l ... <module>`, and verify a
  helpful failure when the runtime module is omitted.
- Const string plugin test:
  return a string literal and signal a string-literal error without warnings.
- `ADDRESS COMMAND` argv test:
  pass executable paths, URL arguments, model ids, and stdin text without shell
  quoting.
- Command capture lifecycle test:
  run repeated stdout/stderr captures and verify there is no stale output when
  using the recommended reset/capture form.
- JSON traversal benchmark:
  parse a result page once, iterate records, and read several fields per record.
- Tolerant parser tests:
  validate enum coercion, numeric clamping, Markdown-table repair, field-count
  repair, and structured diagnostics.

## Why This Matters For CREXX

The `crexx-rag` workload is a useful stress test because it is not a toy "call
one function" integration. It combines:

- native dynamic plugins;
- compiler-visible signatures;
- VM runtime modules;
- long-running CREXX controllers;
- command-shaped model adapters;
- multi-line stdout/stderr capture;
- structured but imperfect local-model output;
- paged result processing;
- resumable queues and audit records.

If CREXX makes this workload pleasant, it becomes a credible language for local
AI orchestration: small policy scripts, strong native extension points, local
tooling, and explicit validation before side effects. The requested changes are
mostly packaging, documentation, and focused runtime ergonomics rather than a
new architectural direction.

## References In This Repository

- `docs/crexx-integration-issues.md`: raw issue list and local installation
  observations.
- `docs/archive/native-v1/crexx-plugin-pattern.md`: archived working dynamic
  plugin pattern for the native-v1 oracle.
- `docs/archive/native-v1/domain-profiles.md`: archived staged profile and
  local-model orchestration details.
- `docs/archive/native-v1/graph-retrieval-methodology.md`: archived rationale
  for CREXX as policy gate and lessons from corpus-scale runs.
- `docs/archive/native-v1/pipeline-status.md`: frozen native-v1 behavior.
- `docs/test-strategy.md`: current cREXX-only programme acceptance policy.
- `docs/crexx-only-vision-and-specification.md`: approved replacement direction.
- `crexx/profiles/history/stage1b_adjudicate_candidates.crexx`: current
  candidate adjudication controller and JSON traversal/capture patterns.
- `crexx/profiles/history/stage3_extract_queue.crexx`: current queue-consuming
  extraction controller.
- `crexx/plugins/rag/rxrag.c`: RXPA plugin surface and function signatures.
