# Phase 2 Entry Baseline

Status date: 2026-08-04. The baseline is complete and `P2-01` is the sole
active Phase-2 item. This record does not treat the known CRI-15 reproducer as
a product regression.

## Repository

- branch: `main`
- HEAD: `9fd93d965a46952319002da4bd0c2a4352e542e4`
- commit: `refactor: adopt Level G application boundary`
- upstream: `origin/main` at the same commit
- entry status: clean, with no staged or untracked files

## Host And Toolchain

- host: Ubuntu 26.04 LTS, Linux `7.0.0-28-generic`, x86_64
- CMake/CTest: 4.2.3
- Ninja: 1.13.2
- GCC/G++: 15.2.0
- installed CREXX: `crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty`
- installed platform/build date: `linux 64 20260801`
- available VMs: `/home/adrian/.local/bin/rxvme` and
  `/home/adrian/.local/bin/rxbvm`

The installed prefix and every sibling CREXX checkout remained read-only.

## Commands

```text
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
cmake --preset release
cmake --build --preset release
git diff --check
```

## Results

- Debug configure: passed.
- Debug build: passed with no work required.
- Debug CTest: 57/58 passed in 585.54 seconds.
- All 28 Phase-1B tests passed.
- The sole failure was `p1a_provider_boundary`, reproducing CRI-15 exactly:
  Linux `rxvme` changed the intended socket receive-timeout result into
  invalid-UTF-8 status `-5`.
- Release configure: passed.
- Release build: passed all 10 Ninja steps.
- `git diff --check`: passed.

No hosted request was made, no credential was read or retained, no live
library or production schema was touched, and no source or normal-prefix
artifact was created. The native-v1 implementation remains the executable
oracle.

## Entry Decision

No new product regression was found. The Level-G application skeleton may
begin with `P2-01`; all later worklist items remain inactive.
