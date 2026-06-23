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
ADDPROC(search, "rxrag.search", "b", ".string", "path=.string,query=.string,top_k=.int,hops=.int");
ENDLOADFUNCS
```

Class and interface metadata also exists through macros such as `ADDCLASS`,
`ADDINTERFACE`, `ADDIMPLEMENTS`, `ADDFACTORY`, and `ADDMETHOD`, but object
construction is less complete. For now, `crexx-rag` exposes procedure-style
functions and keeps object-shaped APIs as a later layer.

## Compile And Run

There are two separate paths:

- Compile/import path: `rxc -i <plugin-dir>...` lets the compiler read native
  signatures from `.rxplugin` files.
- Runtime module path: `rxvme -l <plugin-dir> <program> rx_rag` lets the VM
  load `rx_rag.rxplugin` as a runtime module. `rxvme` already embeds the CREXX
  library; use `rxvm` only if you need to list the library module explicitly.

The installed CREXX driver `crexx -i ...` is not enough by itself because `-i`
only affects compilation/import. The runtime still needs the native plugin in
the VM module list.

The CTest smoke uses the installed tools directly:

```bash
rxc -i "cmake-build-debug/bin;/Users/adrian/.local/bin" \
  -o cmake-build-debug/crexx-profile-smoke/balanced-profile \
  crexx/profiles/balanced.crexx
rxas -o cmake-build-debug/crexx-profile-smoke/balanced-profile \
  cmake-build-debug/crexx-profile-smoke/balanced-profile
rxvme -l cmake-build-debug/bin \
  cmake-build-debug/crexx-profile-smoke/balanced-profile \
  rx_rag
```

The portable project entry point is:

```bash
ctest --preset debug -R crexx_profile_smoke --output-on-failure
```
