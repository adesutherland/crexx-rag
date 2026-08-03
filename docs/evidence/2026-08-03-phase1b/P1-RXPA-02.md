# P1-RXPA-02 Development-Package Qualification

Status date: 2026-08-03. Result: accepted. The installed package was consumed
read-only; no installed prefix or CREXX source file changed.

## Package Surface

The qualifier finds and hashes `BUILDINFO`, version and SAA headers, platform
integer and RXPA headers, `CREXXConfig.cmake`, `CREXXConfigVersion.cmake`,
`CREXXTargets.cmake`, `RXPluginFunction.cmake`, both compiler tools, and both
VMs. The independent consumer is the locally maintained example and requires
the exported `CREXX::RXPA` target plus `add_dynamic_plugin_target()`.

`BUILDINFO`, the package config, the plugin runtime, and the consumer all match
the display identity
`crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty`. Exact base-version discovery
accepts `1.0.0`.

## Positive And Negative Matrix

| Case | Result |
| --- | --- |
| exact compatible package `1.0.0` | configured; exported target/helper present |
| missing package | rejected; diagnostic names `CREXXConfig.cmake`, `CMAKE_PREFIX_PATH`, and `CREXX_DIR` |
| incompatible exact package `2.0.0` | rejected; diagnostic reports installed candidate version `1.0.0` |
| `rxvme`, plugin directory present | version match and result 42 |
| `rxbvm`, plugin directory present | version match and result 42 |
| `rxvme`, plugin directory absent | deterministic `ERROR reading module file rx_external_consumer` |
| `rxbvm`, plugin directory absent | deterministic `ERROR reading module file rx_external_consumer` |

## Commands And Measurements

```text
cmake --build --preset debug --target p1_rxpa_02
ctest --test-dir cmake-build-debug -L '^P1-RXPA-02$' --output-on-failure -V
```

- final target: passed in 2.06 seconds, peak RSS 113,976 KiB;
- exact-label CTest: 1/1 passed in 2.00 seconds, peak RSS 113,824 KiB;
- full diagnostics and runtime output:
  `raw/p1-rxpa-02-commands-and-output.txt`;
- development-package and plugin hashes:
  `raw/p1-rxpa-02-development-package-manifest.txt`;
- fixture and retained-output hashes: `raw/p1-rxpa-02-hashes.txt`.

## Development Failures

The first run used regex matching for a literal build identity containing `+`
and stopped at the BUILDINFO check. The second run disabled environment lookup
for the missing-package case without pinning a generator and stopped before
package discovery. Exact line comparison and an explicit Ninja path corrected
the harness. Both outputs remain in `raw/p1-rxpa-02-target.txt` and
`raw/p1-rxpa-02-target-rerun.txt`.

## Exit

`P1-RXPA-01` and `P1-RXPA-02` together establish a repeatable installed-package
external consumer with positive and negative compatibility evidence and both-VM
module discovery. `P1-RXPA-03` remains unstarted and unauthorized.
