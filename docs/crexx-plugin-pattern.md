# CREXX Dynamic Plugin Pattern

This project targets the installed CREXX toolchain, not the sibling CREXX source
checkout. The sibling checkout is useful for reading current RXPA examples and
headers, but it is not the compatibility target because it may be in flux.

## Native Signatures

CREXX native functions are exposed through RXPA macros in the plugin C source:

- `PROCEDURE(name)` defines the C implementation.
- `GETSTRING`, `GETINT`, `GETFLOAT`, and related macros read CREXX arguments.
- `SETSTRING`, `SETINT`, `SETFLOAT`, and related macros write return values.
- `RETURNSIGNAL` reports a CREXX-visible failure.
- `LOADFUNCS` / `ADDPROC` / `ENDLOADFUNCS` publish typed signatures into the
  binary so the compiler and VM can discover callable functions.

Example shape:

```c
PROCEDURE(search)
{
    /* validate NUM_ARGS, call native core, SETSTRING(RETURN, json) */
    RESETSIGNAL
}

LOADFUNCS
ADDPROC(search, "rxrag.search", "g", ".string", "path=.string,query=.string,top_k=.int,hops=.int");
ENDLOADFUNCS
```

Level G is currently close to Level B in the installed toolchain, but it is the
right compatibility level for this project because CREXX-facing RAG policy and
LLM/RAG orchestration are expected to diverge there.

Class and interface metadata also exists through RXPA macros such as `ADDCLASS`,
`ADDINTERFACE`, `ADDIMPLEMENTS`, `ADDFACTORY`, and `ADDMETHOD`, but the native
plugin stays procedure-style for now. The object-shaped surface is implemented
in CREXX itself by `crexx/cprag.crexx`.

## Compile And Run

There are two separate paths:

- Compile/import path: `rxc -i <plugin-dir>...` lets the compiler read native
  signatures from `.rxplugin` files.
- Runtime module path: `rxvme -l <plugin-dir> <program> cprag rx_rag` lets the
  VM load the CREXX wrapper module and the `rx_rag.rxplugin` runtime module.
  `rxvme` already embeds the CREXX library; use `rxvm` only if you need to list
  the library module explicitly.

The installed CREXX driver `crexx -i ...` is not enough by itself because `-i`
only affects compilation/import. The runtime still needs the native plugin in
the VM module list.

The CTest smoke uses the installed tools directly:

```bash
rxc -i "cmake-build-debug/bin;/Users/adrian/.local/bin" \
  -o cmake-build-debug/crexx-profile-smoke/cprag \
  crexx/cprag.crexx
rxas -o cmake-build-debug/crexx-profile-smoke/cprag \
  cmake-build-debug/crexx-profile-smoke/cprag
rxc -i "cmake-build-debug/crexx-profile-smoke;cmake-build-debug/bin;/Users/adrian/.local/bin" \
  -o cmake-build-debug/crexx-profile-smoke/balanced-profile \
  crexx/profiles/balanced.crexx
rxas -o cmake-build-debug/crexx-profile-smoke/balanced-profile \
  cmake-build-debug/crexx-profile-smoke/balanced-profile
rxvme -l cmake-build-debug/bin \
  cmake-build-debug/crexx-profile-smoke/balanced-profile \
  cprag rx_rag
```

The portable project entry point is:

```bash
ctest --preset debug -R crexx_profile_smoke --output-on-failure
```

For manual late-bound profile experiments that use CREXXSAA caching, inspect or
clear the cache with:

```bash
crexxsaa --location
crexxsaa --list
crexxsaa --clear
```

The CTest path above still compiles and assembles explicitly with `rxc` and
`rxas`, so it is a direct installed-toolchain smoke rather than a CREXXSAA cache
test.

## Address Environments

CREXX/Rexx address environments are the right style for command-shaped RAG and
model operations. They should be treated as a programmer-friendly surface over
the same operations exposed by the native API and CLI, not as a separate
implementation.

The design target is one operation vocabulary with several bindings:

```text
native helper/API
  -> CLI command for humans and shell scripts
  -> CREXX function for direct profile calls
  -> CREXX address environment command for profile orchestration
```

For example, a future `ADDRESS CPRAG` surface could expose commands shaped like:

```text
COLLATE CANDIDATES PROFILE scotland
ADJUDICATE CANDIDATES MODEL qwen2.5-3b
RANK CHUNKS USING graph vector
PUSH EXTRACTION SOURCE chunk:123
EXPORT DOT TYPES clan,place
```

Those commands should call the same core/adapter operations as `crexx-rag`
commands. This keeps the CLI useful for humans while making CREXX profiles read
like policy scripts rather than hand-written shell pipelines.
