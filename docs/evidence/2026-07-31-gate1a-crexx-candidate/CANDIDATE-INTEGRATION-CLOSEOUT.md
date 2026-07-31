# Gate-1A approved CREXX candidate downstream closeout

Status: **candidate integration complete; stopped at Gate 1A**

Date: 2026-07-31

Approved CREXX source:

- branch: `develop`
- commit: `ea25d1720c8dc4044614fa6ac4789811289dc8ca`
- subject: `feat: close crexx-rag integration ledger`

This replay changes only `crexx-rag`. It does not authorize Phase 1B,
production hardening, a donation package, hosted-provider qualification,
cutover, commit, push or pull request.

## Initial state and preservation boundary

`crexx-rag` began on `main` at
`97cd87e91344d6ac1773a054bd38df23eb128ed2`, tracking `origin/main` at
`+0/-0`. Before this replay it already had:

- 27 tracked files changed: 574 insertions, 55 deletions;
- 17 staged rename-only files;
- tracked diff SHA-256
  `97443028cfa8e86624fc5fda9ea5fb33d02f4d7413e5a8a848d92ec365288ef9`;
- staged diff SHA-256
  `30cea35503c6dc073f3007218b9458f2bc0c28b2c7661327b9144036d5a7c61d`;
- branch-aware porcelain-v2 SHA-256
  `cef820082b229b46110683617b942275ae9f41ddb18802ef07bc2485d9fbd531`;
- untracked manifest SHA-256
  `67f85423db498ff9e6ce007c359fdd8193f44aa4dc604dab267488f283d773a6`.

CREXX began on the exact approved branch/commit/subject with no tracked or
staged diff and five pre-existing untracked lifecycle `.rxbin` files. Its
branch-aware porcelain-v2 SHA-256 was
`b2367883c01526fec417c6065157baa35cfafb57d8aa0a39656d1dfb50836efc`;
its untracked manifest SHA-256 was
`dbbe52cf73ea23cfa1accb710664c75380aa866e3296a949b72a6edfd3a098b2`.

## Host and clean scratch build

- host: Darwin arm64 25.5.0, Apple M5, 24 GiB, 10 logical CPUs;
- CMake 4.3.2;
- Ninja 1.13.2;
- AppleClang 21.0.0.21000101;
- CREXX build root: `/tmp/crexx-rag-crexx-build.9bQN4y/build`;
- CREXX install prefix: `/tmp/crexx-rag-crexx-prefix.1GWSHu`;
- final downstream build: `/tmp/crexx-rag-final-build.wyrBJz`.

Exact CREXX commands:

```console
cmake -S /Users/adrian/CLionProjects/CREXX \
  -B /tmp/crexx-rag-crexx-build.9bQN4y/build -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX=/tmp/crexx-rag-crexx-prefix.1GWSHu
cmake --build /tmp/crexx-rag-crexx-build.9bQN4y/build
cmake --install /tmp/crexx-rag-crexx-build.9bQN4y/build
```

Configure, 1,539-step build and 141-file scratch install all exited zero. The
installed identity is `crexx-1.0.0-beta.3+local.gea25d1720c8d`. No normal
prefix was written.

The complete 141-file install manifest has SHA-256
`ea5a0da5723c8f58f368d4beefc201a348b5c85147a5137bdbf650fef2fdc318`.
Selected installed artifacts were fingerprinted as follows:

| Selected artifact | SHA-256 |
| --- | --- |
| `BUILDINFO` | `89c7414dd2a45d5e2d0b3bde57b5ab24cc8d63ff6040d56001e04e7da8f09fcc` |
| `bin/crexx` | `803bb8535476fc9140642532b39581ed3f43def8ecfe4eab34dbfa9f74b74deb` |
| `bin/rxc` | `2027adc753f025a066b4009b1a88cceb049a368c0683c4efe74151cac89aadd4` |
| `bin/rxas` | `c003836f5168875a38e90e7b577dac8a41cabbe135cc8ed37196f57e1783a256` |
| `bin/rxvme` | `b158ea72655c5f080d2d691967b4fde5b2f0167012d7b3b62b26fd35d7e57f57` |
| `bin/rxbvm` | `0f996ea51f23683f6ab281fd25d8eb92d67b603bbfa751f8e58602ac09a32ae4` |
| `bin/crexx-contract` | `3b7dbbee32ca233984112e67024f8021399e4021a64f959f6770e12457b9fe8f` |
| `bin/library.rxbin` | `07d7351deed25681394171648b982cad241804863169edc085748f59a9e08eca` |
| `bin/rxfnsg.rxbin` | `fea584fb38987a782b58a8c63b8a885c4a8dd59e718b85e1bc31249e7db2f56b` |
| `bin/rxfnsc.rxbin` | `2cd13b86f1383dca461dbd2c7330008f19c29359c77a0f5d9899a8b36394896c` |
| `include/crexx_version.h` | `1ffbc1f64255bcb462dc687f0104dbfad3302299817ec3d7367fd7eb581cf183` |
| `include/crexxsaa.h` | `5a27694e99e2705b8ef34f869a557884918627b99db09491ba44b4bcb37e3b75` |
| `include/platform/rxinteger.h` | `663e667b3343900f0e6535add8ee8c3946431eb246dd4cb67f0aa631c3cd6d0b` |
| `include/rxpa/crexxpa.h` | `8a00cc2d7c501252ffd15c0219b9c08e3dd539c7a06372c991607e8f5d7eac22` |
| `lib/cmake/CREXX/CREXXConfig.cmake` | `97f84c3ff96e44097ef73941f946457b7ce101e05b657ddb5dc3045cf55c1d6d` |
| `lib/cmake/CREXX/CREXXConfigVersion.cmake` | `f1e79939dfaba0392f914537e69e0ad7ba208bd0e661cb35004e4ad51c3c1310` |
| `lib/cmake/CREXX/CREXXTargets.cmake` | `c6451c376307956053b7a601ba5e4835320c9af287c17ec7ddceff0be4af25d5` |
| `lib/cmake/CREXX/CrexxOperationContract.cmake` | `294cb459ddd9f481a9822719eaad57df81b2a773aa2b1791b34fb8237cec7d39` |
| `lib/cmake/CREXX/RXPluginFunction.cmake` | `c00716429bdb07b6b4017fa5c9ba16f8447a713f5cd509de0a1c51c47d8a62d8` |

## Baseline replay before removals

The first downstream attempt intentionally sanitized the environment but
omitted Homebrew from `PATH`; it exited 127 with `env: cmake: No such file or
directory`. No source changed as a result. The retry selected the scratch
prefix explicitly, configured with both fallback switches off and completed a
25-step build.

The unchanged candidate baseline passed 23/27, failed 4, skipped 0 in 44.44
seconds:

1. `phase0_component_benchmark`: obsolete runtime module `rx_socket` was not
   found;
2. `p1a_json_document`: production `rxjson.jsondocument` exposed the competing
   downstream class and its obsolete `as_f32_vector`/`as_i64_vector` surface;
3. `p1a_sdk_probe`: the external consumer itself ran, but a stale assertion
   required commit `057592681c0c`;
4. `p1a_provider_boundary`: obsolete `as_f32_vector` was absent.

These were the expected removal seams plus the stale version assertion. There
was no new CREXX failure.

## Downstream configure and provenance

Exact final command:

```console
cmake -S /Users/adrian/CLionProjects/crexx-rag \
  -B /tmp/crexx-rag-final-build.wyrBJz -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH=/tmp/crexx-rag-crexx-prefix.1GWSHu \
  -DCREXX_DIR=/tmp/crexx-rag-crexx-prefix.1GWSHu/lib/cmake/CREXX \
  -DCPRAG_ALLOW_VENDORED_CREXXPA=OFF \
  -DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF
cmake --build /tmp/crexx-rag-final-build.wyrBJz --verbose
ctest --test-dir /tmp/crexx-rag-final-build.wyrBJz --output-on-failure
```

Hosted key variables were unset for configure, build and CTest. The final
cache records only the scratch `CREXX_DIR` and both fallback values `OFF`.
`CMakeCache.txt`, `build.ninja`, `CTestTestfile.cmake` and
`cmake_install.cmake` contain no CREXX sister-checkout or normal-prefix
selection. Verbose plugin builds use only scratch-prefix CREXX include paths.

## CRI-01 through CRI-14 matrix

| ID | Upstream disposition | Downstream result |
| --- | --- | --- |
| CRI-01 | fixed | Typed imported Level-B record now returns through Level G; concrete and real-surface tests pass. |
| CRI-02 | fixed | By-value checksums match in all four cells and optimized inversion is absent. |
| CRI-03 | no CREXX change | Deterministic structured failures pass; no hosted call; historical timeout not reclassified. |
| CRI-04 | fixed | Two dummy terminal-loop returns removed; concrete source compiles both modes. |
| CRI-05 | fixed | Seven intended profile/controller sources restored to Level G; concrete PARSE runs both modes/VMs. |
| CRI-06 | fixed | Both negative modes emit structured `RXPA_IMPORT_SIGNATURE_INVALID`; no internal error. |
| CRI-07 | documented/package-closed | Installed CMake package/helper builds plugins; vendored/generated/source fallbacks deleted. |
| CRI-08 | fixed | Immutable SDK version string and const status paths compile; no ABI-layout workaround retained. |
| CRI-09 | fixed | All active callers use production `rxjson.jsondocument`; competing class deleted. |
| CRI-10 | documented/package-closed | ADDRESS multiline/structured surface remains green. |
| CRI-11 | documented/package-closed | Existing argv-vector contract retained; no downstream workaround. |
| CRI-12 | documented/package-closed | Existing redirect-array lifecycle contract retained; no downstream workaround. |
| CRI-13 | fixed | Explicit f32/i64 owning raw little-endian projection passes; schema owns type/count/meaning. |
| CRI-14 | fixed | Installed helper generates and validates `crexx.operation-contract/1`. |

## Workarounds removed, retained or modified

| Accommodation | Disposition | Focused proof |
| --- | --- | --- |
| Level-B fallback for Level-G PARSE | Removed | Seven sources restored; `crexx_profile_smoke` and the opt/noopt dual-VM PARSE reproducer pass. |
| Unreachable returns after terminal `do forever` | Removed | `p1a_data_boundary` passes; retained concrete source compiles in both modes. |
| String-only Level-G record facade | Removed | `p1a_surface_boundary` passes typed return plus CLI/ADDRESS/MCP equality; concrete record matrix passes. |
| `.binary` exposure workaround | Removed from production JSON/vector paths | Four-cell checksum/timing probe passes; exposure remains only as a measurement control. |
| Direct binary access workaround | Modified | Removed from the retired wrapper; retained in the cosine loop because it is the naturally direct hot-loop operation. |
| Vendored RXPA headers and generated companion | Removed | `_rag`, `_sqlite_boundary`, valid/invalid independent plugins build solely from `CREXX::RXPA`. |
| Source/build helper fallback | Removed | Main and external CMake projects use `find_package(CREXX CONFIG)` and the installed helper. |
| Mutable RXPA status/version strings | Removed where only const-API compatibility required | SDK consumer passes; lifetime-preserving copies in the native-v1 oracle bridge remain for their original ownership reason. |
| Internal-error malformed-signature expectation | Replaced | Both modes report location-bearing `RXPA_IMPORT_SIGNATURE_INVALID`, plugin, field and declaration. |
| `rx_socket` runtime module argument | Removed | Phase-0 component benchmark passes both VMs; provider loopback passes both VMs. |
| Incubator `jsondocument`/`f32vector`/`i64vector` and F32V/I64V envelope | Removed | Production projection, provider, vector, algorithm and surface focused tests pass. |
| Implicit vector metadata in payload | Replaced | SQLite application schema stores `element_type=f32le`, count and meaning; payload is exactly `count*4` bytes. |
| Ad-hoc external schema description | Replaced | Installed helper emits contract SHA-256 `de7266e1bc7aeafb8b8731c0fac9305049b92f71ddcce8c426220f99be8b6c7f`. |

## Focused raw results

### Production JSON and read-only binary

Every projection cell reports f32 count/dimensions 3, 12 f32 bytes, 24 i64
bytes and no envelope. The 3,072-element benchmark returns 12,288 bytes.

| VM/mode | by-value us | exposed control us | direct control us | checksum |
| --- | ---: | ---: | ---: | ---: |
| `rxvme` noopt | 3,573 | 3,123 | 814 | 47,201,280 |
| `rxbvm` noopt | 3,613 | 3,176 | 817 | 47,201,280 |
| `rxvme` opt | 1,194 | 872 | 787 | 47,201,280 |
| `rxbvm` opt | 1,209 | 866 | 793 | 47,201,280 |

Optimized by-value is 0.334x noopt on `rxvme` and 0.335x on `rxbvm`, passing
the accepted `<=0.90x` downstream inversion gate.

### Provider, vector and contract

- Provider: generation, raw-f32 embedding count 3, malformed response, 50 ms
  timeout, connection failure and structured provider error pass on both VMs;
  `hosted=0`.
- Vector: exact top IDs `10,20,30` on both VMs. The 32-by-768 page carries
  98,304 raw bytes. `rxvme` transfer/decode/arithmetic/selection/total is
  84/12/1,368/12/1,489 us; `rxbvm` is 81/11/1,271/12/1,384 us.
- SDK: valid external result 42 and exact version on both modes/VMs. Invalid
  `.int,.int` reports `#RXPA_IMPORT_SIGNATURE_INVALID` at line 6 column 5 with
  `import_file="rx_sdk_probe_bad.rxplugin"` and `field="arguments"`.
- Contract: format `crexx.operation-contract`, format version 1, operation
  `surface_operation.statusoperation.status_evidence`, contract version 1.0.0.

## Complete deterministic/loopback result

The clean final build completed 27/27 Ninja steps. CTest then passed 28/28,
failed 0 and skipped 0 in 110.30 seconds. No hosted provider call occurred.

Retained temporary log hashes:

| Log | SHA-256 |
| --- | --- |
| final configure | `aebf38872150383df4feea21d8924b4b840c5a3e22c0b5bf43f9d2b0c9bf81c1` |
| final post-cleanup verbose build | `8b6d19c6047238aa12435b8a1083593d35d9182ccd644bacecc6dd75098a4f57` |
| final CTest | `619259d5c581b2d8d6e389a3dc7bacd894e8f35d9c9a24dfc11f8fc41b543136` |

## Final preservation audit

CREXX remains exactly `develop` at
`ea25d1720c8dc4044614fa6ac4789811289dc8ca`, subject
`feat: close crexx-rag integration ledger`, with `origin/develop +0/-0`, empty
tracked/staged diffs, and the same five untracked files and hashes. Its final
branch-aware porcelain-v2 SHA-256 is the initial
`b2367883c01526fec417c6065157baa35cfafb57d8aa0a39656d1dfb50836efc`;
its untracked manifest is the initial
`dbbe52cf73ea23cfa1accb710664c75380aa866e3296a949b72a6edfd3a098b2`.

`crexx-rag` remains `main` at
`97cd87e91344d6ac1773a054bd38df23eb128ed2`, `origin/main +0/-0`. The initial
17-file staged rename patch remains byte-identical at SHA-256
`30cea35503c6dc073f3007218b9458f2bc0c28b2c7661327b9144036d5a7c61d`.
Reverse-application checks prove all 18 pre-existing tracked paths outside the
approved integration edit set are byte-for-byte unchanged. Of the 132 initial
untracked files, 99 are byte-for-byte unchanged, 28 are intentionally modified
by this replay, and the five retired JSON-incubator files are intentionally
removed; ten scoped replacement/evidence files were added, giving 137 current
untracked files. No unrelated path changed. `git diff --check` passes.

No stash, reset, clean, source-tree build/reconfigure, normal-prefix install,
stage, commit, push or pull request was performed.

## Remaining failures and integration seams

There are no remaining deterministic/loopback test failures and no open CREXX
compatibility seam in CRI-01 through CRI-14. The remaining work is deliberately
outside this authority: explicit Phase-1B boundary selection, production schema
and migrations, provider hardening, representative vector crossover/SLA work,
cross-platform validation, donation readiness where separately approved, and
cutover policy.

## Smallest next decision

Adrian may approve, revise or defer the refreshed D1-through-D9 Gate-1A
boundary choices. The smallest executable next decision is the exact bounded
Phase-1B worklist and stop point. Until then, stop here.
