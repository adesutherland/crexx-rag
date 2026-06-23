# CREXX Integration Issues

This project intentionally treats the installed CREXX toolchain as the
compatibility target. The sibling `../CREXX` checkout is useful for reading
current source and documentation, but it is not the default build dependency
because it can change independently of the installed user experience.

## Observed On This Machine

- Installed `crexx`: `/Users/adrian/.local/bin/crexx`
- Version reported by `crexx --help`:
  `crexx-1.0.0-beta.2+local.g5eb8fdc73263` built `20260617`
- Installed directory contains runtime binaries, `.rxplugin` files, static
  libraries, and native link flag files.
- No installed `crexxpa.h` was found under `/Users/adrian/.local`.
- No installed `RXPluginFunction.cmake` was found under `/Users/adrian/.local`.
- The rxpa `SETSTRING`/`RETURNSIGNAL` macros ultimately pass strings to a
  callback typed as mutable `char *`, so plugin code that naturally has
  `const char *` status messages needs local mutable copies to avoid compiler
  warnings.
- The installed driver separates compile-time import roots from runtime module
  loading. `-i cmake-build-debug/bin` lets `rxc` read native signatures from the
  plugin, but the VM still needs `rx_rag` listed as a runtime module and
  `cmake-build-debug/bin` on the VM location path.

## Current Impact

`crexx-rag` can build the native core, CLI, MCP server, and tests from the
installed system dependencies. It can also build and run the `rx_rag.rxplugin`
dynamic CREXX plugin against the installed CREXX runtime, provided the temporary
vendored rxpa development header remains available.

The runtime smoke is:

```bash
ctest --preset debug -R crexx_profile_smoke --output-on-failure
```

The underlying installed-tool pattern is documented in
[`crexx-plugin-pattern.md`](crexx-plugin-pattern.md).

The project still cannot build the plugin from the installed CREXX package alone
because the rxpa development header is not installed.

As a temporary bridge, this repo vendors a copy of `crexxpa.h` from the sibling
CREXX source tree at `third_party/crexx-rxpa/crexxpa.h`. That header depends on
generated `crexx_version.h`, so this repo also vendors a generated sibling-copy
of that companion header. TODO: remove both files and the fallback when CREXX
installs version-matched development headers.

The CMake build uses the CREXX plugin header in this order:

- `-DCREXX_RXPA_INCLUDE_DIR=/path/to/installed/include` points at an installed
  directory containing `crexxpa.h`.
- `third_party/crexx-rxpa/crexxpa.h` exists and
  `CPRAG_ALLOW_VENDORED_CREXXPA=ON`.
- `-DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=ON` is set for temporary source-checkout
  diagnosis.

To verify the installed CREXX package without the vendored shim:

```bash
cmake --preset debug -DCPRAG_ALLOW_VENDORED_CREXXPA=OFF
```

## Requests For CREXX

- Install `rxpa/crexxpa.h` as part of a CREXX development package or default
  local install.
- Install the transitive development headers required by `crexxpa.h`, including
  a version-matched generated `crexx_version.h`.
- Install or generate a CMake package/config file for external native plugin
  projects.
- Include the plugin target helper or equivalent metadata outside the source
  tree, for example an installed `RXPluginFunction.cmake`.
- Provide a machine-readable command such as `crexx --print-dev-info` or
  `crexx --print-plugin-cflags` that reports:
  - include directories
  - plugin suffix and prefix
  - linker flags for native/plugin builds
  - runtime plugin search directories
  - CREXX version/build id
- Document the recommended external dynamic plugin build flow against an
  installed CREXX tree.
- Document clearly that an external project must expose a locally built
  `.rxplugin` to both the compiler/import phase and the runtime module loader.
- Consider making rxpa string setter APIs accept `const char *` where the
  callee does not mutate the passed string.

## Policy For This Repo

Do not silently rely on `../CREXX/rxpa/crexxpa.h`. If that fallback is needed,
enable it explicitly and leave a note here if the installed package is still
missing something that external plugin authors need.
