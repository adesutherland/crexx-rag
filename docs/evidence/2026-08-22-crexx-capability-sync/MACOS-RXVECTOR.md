# macOS `rxvector` capability closeout

Status: accepted first ordinary-Release verdict and completed macOS downstream
qualification on 2026-08-22. Supported Linux sanitizer and transport
qualification remain the separate `LINUX-01`/`LINUX-02` gates.

## Selected contract

The installed CREXX provider is `rxvector`, a process-reentrant exact CPU
provider over owning `.packedfloat` and `.packedint` values. The application
retains `f32le-v1` as its portable SQLite representation, converts one bounded
page at a time, calls `rxvector.topkcosine`, and uses the pure cREXX selector
only to merge page winners. There is no Rexx declaration wrapper, explicit
plugin list, persistent native handle, ANN index, or RAG-specific provider
policy.

The accepted upstream profiling-off Release verdict measured public prepared
kernel medians of 8,431 us on `rxbvm` and 8,486 us on `rxtvm`, respectively
15.622x and 14.682x faster than the paired Level B oracle and indistinguishable
at this scale from the shared direct-C kernel. All 72 recorded cells returned
the exact `1034.2` checksum. The governed distribution is retained in CREXX at
`performance/evidence/2026-08-22-rxvector01-first-release-verdict/`.

## Installed-only replay

- CREXX base revision: `6e6f0ea55d38db346bf78b6542635b2354ba2f04`
  with the uncommitted accepted RXVECTOR candidate.
- `crexx-rag` base revision:
  `de380401603fc0c01bccf00afa36520c1d4e5971` with this capability-sync work.
- Scratch prefix:
  `/var/folders/nr/7ckzqpl91kz80mcy3316h1tr0000gn/T/crexx-rag-rxvector-publish.JFlZVuY1XH/prefix`.
- Installed package identity:
  `crexx-1.0.0-beta.3+local.g6e6f0ea55d38.dirty`, 195 files.
- Downstream cache selects only that prefix through `CREXX_DIR`; both
  `CPRAG_ALLOW_VENDORED_CREXXPA` and
  `CPRAG_ALLOW_CREXX_SOURCE_FALLBACK` are `OFF`.
- A clean downstream build completed 27 Ninja steps.

The package contains the normal dynamic provider and both current static
names:

| Artifact | SHA-256 |
| --- | --- |
| `bin/rxvector.rxplugin` | `c102adac6d63fc78fcbdb7ec032e20a7bf711d7ef2abd9b31cf6fde08bafe994` |
| `bin/providers/rxvector.a` | `fe7c4a650ff463f6b1ba9e6f13cca19fec5c2d50b2fe31b049a4cb659a4bcd43` |
| `bin/providers/rxvector_static.a` | `fe7c4a650ff463f6b1ba9e6f13cca19fec5c2d50b2fe31b049a4cb659a4bcd43` |
| `bin/rxc` | `321754f00e8eda23500f20c02607cdb7e58f40126ad71bc7540509b3f491c15d` |
| `bin/rxvm` | `1a740a0d65afd7b630a88b661f07cc91adb9817b7f49a53e0e47c6f58eac3956` |

The benchmark-only `rx_rxvector01_direct`, `rx_rcc5f_stats_boxed`, and
`rx_rcc5f_stats_direct` providers are absent. The installed external-SDK test
passes dynamic autoload on both installed VMs and automatic static selection
through `crexx -native` without a user-maintained provider list.

The replay command shape was:

```sh
cmake --install cmake-build-debug --prefix "$prefix"
cmake -S . -B "$build" -G Ninja \
  -DCMAKE_PREFIX_PATH="$prefix" \
  -DCPRAG_ALLOW_VENDORED_CREXXPA=OFF \
  -DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF
cmake --build "$build" --parallel 10
ctest --test-dir "$build" --parallel 10 --output-on-failure
```

Upstream normal-Debug qualification used a current build followed by
`ctest --test-dir cmake-build-debug --parallel 30 --output-on-failure`.

## Representative bounded workload

The downstream proof scans 11,684 vectors of dimension 768 in 92 pages of at
most 128 rows. Every cell returns top checksum `1031` and page-score checksum
`3.19999999523163`; exact identities, scores, and tie order match the retained
oracle. Raw component rows are in [rxvector-metrics.csv](rxvector-metrics.csv).

| Cell | SQLite transfer | Validation | f32 conversion | Native arithmetic/selection | Merge | Total | Peak RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| noopt `rxbvm` | 34,013 us | 5,225 us | 30,813 us | 54,277 us | 2,226 us | 129,496 us | 86,196,224 B |
| noopt `rxvme` | 34,076 us | 5,186 us | 31,261 us | 54,188 us | 2,190 us | 129,974 us | 99,434,496 B |
| opt `rxbvm` | 32,106 us | 2,647 us | 29,444 us | 54,161 us | 1,560 us | 122,740 us | 86,261,760 B |
| opt `rxvme` | 32,418 us | 2,644 us | 29,579 us | 54,472 us | 1,549 us | 123,596 us | 99,418,112 B |

The estimated page working set is 1,193,280 bytes. Process peak RSS also
contains the VM and loaded libraries and is not a page-buffer measurement.
Against the retained pure totals of 750,316-857,843 us, the current single-run
totals are about 5.8x-7.0x lower by the broad endpoints. The 122.7-130.0 ms
application result intentionally includes SQLite transfer, validation, 92
portable-to-native conversions/calls, and merge; it is not comparable to the
8.4-8.5 ms prepared full-matrix upstream kernel as though the timing boundaries
were the same. The historical 10 ms value remains an acceleration trigger, not
an application SLA.

## Qualification disposition

- The three focused vector tests pass against the scratch install.
- The installed-only broad downstream run passed 61/62 tests initially. The
  sole failure correctly detected that compatibility work had edited the
  frozen Gate-0 benchmark in place. The historical file was restored to its
  recorded SHA-256 and the maintained Level-G HTTP benchmark moved to
  `phase0_components_current.crexx`; the frozen-hash gate, language-level audit,
  and current component benchmark then pass. Thus every current test has
  passing evidence, without redundantly replaying the other 59 unaffected
  tests.
- Upstream normal Debug passed 2,359/2,361 tests initially. The two failures
  were the new performance harness omitting its required variant argument.
  Supplying one exact public-provider smoke iteration makes both modes pass;
  the other 2,359 tests were not repeated.
- No sanitizer-clean or cross-platform claim is made here. Supported Linux
  ASan/LSan, CRI-15, and CRI-16 remain release-QA work.
