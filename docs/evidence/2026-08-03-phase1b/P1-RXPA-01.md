# P1-RXPA-01 Installed SDK External Consumer

Status date: 2026-08-03. Result: accepted. This is local downstream evidence,
not donation preparation or an installation into the normal prefix.

## Contract Exercised

The independent project under `incubator/phase1b/rxpa_consumer/`:

- uses `find_package(CREXX CONFIG REQUIRED)`;
- requires the installed `CREXX::RXPA` target and
  `add_dynamic_plugin_target()` helper;
- fails configuration if either the vendored-header or CREXX-source fallback
  is enabled;
- builds a dynamic RXPA plugin with installed headers under `-Werror`; and
- compiles and runs a Level-B consumer optimized and non-optimized on both
  installed VMs.

The generated build graph contains `/home/adrian/.local/include` and no path
from the sibling CREXX source checkout. Both fallback cache entries are `OFF`.

## Correctness Matrix

| Mode | VM | Version match | Result |
| --- | --- | --- | --- |
| non-optimized | `rxvme` | `crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty` | 42 |
| non-optimized | `rxbvm` | `crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty` | 42 |
| optimized | `rxvme` | `crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty` | 42 |
| optimized | `rxbvm` | `crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty` | 42 |

## Commands And Measurements

```text
cmake --preset debug
cmake --build --preset debug --target p1_rxpa_01
ctest --test-dir cmake-build-debug -L '^P1-RXPA-01$' --output-on-failure -V
```

- target rerun: passed in 2.65 seconds, peak RSS 114,036 KiB;
- exact-label CTest: 1/1 passed in 2.73 seconds, peak RSS 114,016 KiB;
- selected SDK and generated-plugin hashes are in
  `raw/p1-rxpa-01-selected-prefix-manifest.txt`;
- source and retained-output hashes are in `raw/p1-rxpa-01-hashes.txt`.

## Development Failure

The first target attempt passed configure, external compilation, and consumer
compilation but invoked the runtime with `external_consumer` instead of the
helper-generated module filename `rx_external_consumer`. It failed before the
first VM cell with `ERROR reading module file external_consumer`. The harness
argument was corrected and the failed output remains in
`raw/p1-rxpa-01-target.txt`; no SDK or CREXX change was made.

## Unsupported Or Excluded

No supported VM mode is unavailable. Missing/incompatible-package and module-
discovery diagnostics belong to the next ordered item, `P1-RXPA-02`.
`P1-RXPA-03`, installation changes, and CREXX source changes remain excluded.
