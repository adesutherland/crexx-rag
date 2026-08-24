# Gate 3R Entry Baseline

Recorded: 2026-08-24 14:05 BST (`2026-08-24T13:05:39Z`).

## Repository provenance

- repository: `/Users/adrian/CLionProjects/crexx-rag`
- branch: `main`
- HEAD: `12396cfd712124f23dab836ba9af3075b7380289`
- upstream: `origin/main`
- platform: macOS 26.5.2 (25F84), Darwin 25.5.0, arm64

The entry tree was already dirty. The tracked modification to
`docs/evidence/2026-08-24-phase7/cutover-decision.md` predates this work and is
user-owned; Gate 3R must not modify, stage, or otherwise absorb it. The other
maintained-document changes and this evidence directory are the approved
Gate-3R re-baseline. Generated build products remain ignored.

## Installed CREXX boundary

The interactive tools resolved to:

```text
/Users/adrian/.local/bin/crexx
/Users/adrian/.local/bin/rxvme
/Users/adrian/.local/bin/rxvm
/Users/adrian/.local/bin/rxlink
```

`crexx --version` reported
`crexx-1.0.0-beta.3+local.g1fbd89dc9afb.dirty` for macOS 64, build date
2026-08-24. The installed driver advertises `-native`, native `rxlink` plus
`rxcpack`, explicit `-l` runtime libraries, and optional native link-map
output.

Tool hashes at entry:

```text
04d3c00a106c1cfd5966267c0db7c40de56f226047b9de540f614fb22af4eb19  /Users/adrian/.local/bin/crexx
a520b57206b66ba6be374f7ded364d4531238d0caeffd1575c0fab31900431a0  /Users/adrian/.local/bin/rxlink
```

The pre-existing debug cache resolves the CREXX CMake package through the
scratch prefix `/tmp/crexx-phase3-install.xqEdYn` while its compiler/VM tools
resolve from `/Users/adrian/.local/bin`. It has source fallback disabled. This
mixed but explicit retained baseline must not be mistaken for fresh product
packaging evidence; P3R-01 will use a separately named fresh build directory
and scratch install prefix.

## Oracle control result

The required current-oracle commands completed successfully without a hosted
provider call:

```text
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

Result: **75/75 passed, 0 failed, 0 skipped**, total real test time 749.39
seconds. The existing `phase3_ingestion`, `phase4_improvement`,
`phase5_retrieval`, and `phase6_surfaces` scenarios all passed. This is the
control result for detecting regressions introduced by Gate 3R; it is not
evidence that the reopened installed-product acceptance contract is already
satisfied.

Oracle artifact hashes after the control build:

```text
7dc755bdcbb06b1a0c81e5907f15bb6a8440c0daba1dad3a78f7c58c3f316050  cmake-build-debug/crexx-rag
4511f6817dd02a59d91f007872fd5d56e2494a0b7d940dba5c41005313cfab78  cmake-build-debug/crexx-rag-mcp
48ef8aaeb40714b5e7bdb86b51542493261f724d3a7733b7080a13729c13f935  cmake-build-debug/bin/rx_rag.rxplugin
```

## Entry conclusion

The existing oracle and accepted component suites are green. The entry tree
does not yet contain one linked installed cREXX product image, a stable
no-source launcher, or a native package of that same application. P3R-01 is
therefore active from this baseline.
