# macOS Current-Head Installed Replay

Status date: 2026-08-22. This is the retained `MAC-01` entry result for the
parallel CREXX capability-sync stream. It is a compatibility baseline, not a
release or Linux qualification result.

## Provenance

- host: Darwin 25.5.0 arm64, 10 logical CPUs
- CMake/CTest: 4.3.2
- CREXX source: `develop` at
  `6e6f0ea55d38db346bf78b6542635b2354ba2f04`, clean before replay
- `crexx-rag` source: `main` at
  `de380401603fc0c01bccf00afa36520c1d4e5971`, clean before replay
- installed package: `crexx-1.0.0-beta.3+local.g6e6f0ea55d38`
- scratch root: `/tmp/crexx-rag-macos-current.RXxLgQ`
- scratch prefix: `/tmp/crexx-rag-macos-current.RXxLgQ/prefix`

The normal installed prefix was not changed. The downstream configure used an
explicit `CREXX_DIR` and `CMAKE_PREFIX_PATH` rooted in the scratch prefix with
both source and installed fallbacks disabled.

## Results

- current CREXX Debug build: passed (1,666 build steps)
- scratch install: passed
- fresh downstream configure: passed and selected the scratch package
- downstream build: passed (27/27 steps)
- downstream CTest: 51/61 passed in 90.21 seconds

The ten failures are compatibility findings reproduced by the fresh install:

1. `phase0_component_benchmark`, `p1_llm_02` through `p1_llm_05`, and
   `p1a_provider_boundary` still call the retired `rxhttp` client surface.
2. `p1_rxpa_01` compares the canonical `/private/tmp` prefix with the
   generator's equivalent `/tmp` spelling; `p1_rxpa_02` hard-codes
   `/usr/bin/ninja`.
3. `crexx_generic_pipeline_smoke` and `use_case_wrapper_smoke` use `queue` as a
   local identifier in `stage3_extract_queue.crexx`, which current CREXX
   correctly rejects as reserved.

No hosted request was made, no credential was read, no live library was
opened, and neither normal prefix nor native-v1 state was changed.

## Retained Scratch Logs

- CREXX build: `/tmp/crexx-rag-macos-current.RXxLgQ/crexx-build.log`
- CREXX install: `/tmp/crexx-rag-macos-current.RXxLgQ/crexx-install.log`
- downstream configure:
  `/tmp/crexx-rag-macos-current.RXxLgQ/crexx-rag-configure.log`
- downstream baseline CTest:
  `/tmp/crexx-rag-macos-current.RXxLgQ/crexx-rag-ctest-baseline.log`

These temporary logs are sufficient for this active local stream but are not a
substitute for the final Linux evidence bundle.
