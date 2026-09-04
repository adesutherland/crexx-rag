# Repository guidance for crexxrag

## Product boundary

`crexxrag` is one cREXX application. Product algorithms, SQL repositories and
migrations, orchestration, policy, configuration, commands, jobs, retrieval,
evidence, and provider selection belong in Level-G cREXX.

The generic SQLite provider is owned and installed by CREXX as `rxsqlite`.
This repository must not carry a second SQLite implementation or provider.
Do not add product vocabulary or RAG policy to C/C++. Do not recreate the
removed native prototype, compatibility bridge, or old schema importer.

SQLite is authoritative. Vector sidecars are rebuildable. Every typed claim is
directional and backed by an independently addressable source span. Provider
output is untrusted until normal cREXX validation succeeds.

## Required reading

Before product work, read:

- `README.md`
- `docs/architecture.md`
- `docs/user-guide.md`
- `docs/test-strategy.md`
- `docs/integration-issues.md`

Consult the installed CREXX `rxsqlite` reference before changing the provider
integration contract. SQLite implementation changes belong in CREXX under its
separate repository authority.

## Public surface

The enduring executable name is `crexxrag`. Keep human commands concise and
terminal-friendly. The local defaults are `./crexxrag.conf` and `./library`.
Machine callers use the same operation vocabulary with JSON/NDJSON or MCP.
Do not add shell scripts that own product workflows.

Gemini remains the hosted regression route. Codex uses managed App Server
authentication; never extract tokens. Local embeddings use the
OpenAI-compatible llama.cpp endpoint. Preserve privacy route classification and
charging basis in reviewed plans and completed usage.

## CREXX boundary

Use the installed CREXX package. A sibling CREXX checkout is read-only unless
the user separately authorizes changes there. CREXX infrastructure gaps belong
in `docs/integration-issues.md`; do not hide them in product-specific native
code.

Worker processes each open their own SQLite connection. CREXX supports
provider discovery for child task VMs, but changing this product to attached
workers is a separate architecture decision; native handles remain VM-local.

## Build and QA

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
git diff --check
```

Run focused tests while iterating, then the full suite after changes affecting
schema, providers, workers, public commands, or retrieval. Provider changes
must retain the Gemini smoke test and the malformed-output/secret-redaction
negative cases. Hosted live calls require explicit bounded authority.

## Worktree and publication

Inspect branch, HEAD, status, and relevant diffs before editing. Preserve
unrelated user changes. Never stash, reset, clean, push, release, or modify the
sibling CREXX checkout without explicit authority. Use scratch libraries for
tests and never operate on an unrequested user library.

Local commits are made only when requested. Push and release are separate
authorities.
