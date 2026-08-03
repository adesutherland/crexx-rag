# Phase 1B Entry Audit

Status date: 2026-08-03. Baseline validation is complete. This audit is not
Phase-1B acceptance evidence and does not reinterpret CRI-15 as a product
failure.

## Repository

- branch: `main`
- HEAD: `bcf291d070ca80a776366fe822131ec150b8bd15`
- upstream relation: `origin/main`, ahead 2, behind 0
- ahead commits: `4e0a40a fix: establish Linux build baseline` and
  `bcf291d docs: authorize bounded Phase 1B worklist`
- initial tracked, staged, and untracked status: clean
- initial tracked and staged diffs: empty

## Host And Toolchain

- host: Ubuntu 26.04 LTS, Linux `7.0.0-28-generic`, x86_64
- CPU: Intel Core i5-1135G7, 4 cores / 8 logical CPUs
- memory: 20,197,146,624 bytes physical, 8,589,930,496 bytes swap
- CMake/CTest: 4.2.3
- Ninja: 1.13.2
- GCC/G++: 15.2.0
- process measurement: GNU `time`

## Installed CREXX

- prefix: `/home/adrian/.local`
- display identity: `crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty`
- recorded commit: `ea25d1720c8dc4044614fa6ac4789811289dc8ca`
- package timestamp: `20260728T083858Z`
- platform/build date: `linux 64 20260801`
- available VMs: `/home/adrian/.local/bin/rxvme` and
  `/home/adrian/.local/bin/rxbvm`
- installed development surface found: `include/rxpa/crexxpa.h`,
  `lib/cmake/CREXX/CREXXConfig.cmake`, `CREXXConfigVersion.cmake`, and
  `RXPluginFunction.cmake`

The installed prefix is consumption-only. Every CREXX source checkout remains
read-only and no normal-prefix installation is authorized.

## SQLite

- runtime package/library: Ubuntu `libsqlite3-0` `3.46.1-9ubuntu0.2`,
  `/usr/lib/x86_64-linux-gnu/libsqlite3.so.0.8.6`
- system `sqlite3` CLI and `pkg-config` development metadata: unavailable
- development input: repository-ignored `.local/sqlite-dev/usr/include/sqlite3.h`
  version `3.46.1` plus the installed versioned runtime library, matching the
  retained Linux baseline
- runtime SHA-256: `c43daabc6597cb20c84ae5b785d7c6072220966bd79dd12b961b98fb48ba224a`
- header SHA-256: `f319f664239fdd3154721a70b7cf37fa1475703c6a4deaf7605511851c1edb17`

## Fixture Identity

All 19 entries in the frozen Phase-0 hash manifest match. Current fixture hashes
and the line-by-line verification are retained in
`raw/entry/fixture-hashes.txt`.

## Entry Commands

The required entry sequence is:

```text
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
cmake --preset release
cmake --build --preset release
git diff --check
```

## Entry Results

- Debug configure: passed in 0.29 seconds, peak RSS 25,980 KiB.
- Debug build: passed with no work required in 0.06 seconds, peak RSS
  19,532 KiB.
- Debug CTest: 27/28 passed in 425.79 seconds, peak RSS 227,048 KiB.
- The sole failure is `p1a_provider_boundary` in the known `rxvme` timeout
  cell: socket status is overwritten by invalid-UTF-8 status `-5`. This is the
  exact CRI-15 dependency and is retained separately from product failures.
- Release configure: passed in 0.16 seconds, peak RSS 25,976 KiB.
- Release build: passed with no work required in 0.08 seconds, peak RSS
  19,536 KiB.
- `git diff --check`: passed.

Complete raw output is under `raw/entry/`. No additional baseline failure was
observed, so `P1-RXPA-01` may be activated.
