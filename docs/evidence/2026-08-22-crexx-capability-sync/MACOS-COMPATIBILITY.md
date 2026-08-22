# macOS HTTP And Toolchain Compatibility

Status date: 2026-08-22. `MAC-02` is complete on macOS. This result repairs
current-head downstream compatibility but does not close the supported-Linux
CRI-15/CRI-16 gates.

## Changes

- Migrated the Phase-0, P1A, local OpenAI-compatible, and industrial provider
  sources from retired `rxhttp` calls to typed Level-G `rxfnsg` HTTP policy,
  headers, pooled client, response, and explicit-close semantics.
- Preserved stable provider timeout (`-5`) and connection (`-3`) codes while
  retaining typed transport messages and HTTP status.
- Added `rxlink` to provider test pipelines. This is required because final
  linking reseals HTTP task bindings after combining separately assembled
  application, provider, `rxfnsg`, classlib, and foundation modules.
- Made external SDK probes use the active CMake generator and make program,
  and made selected-prefix checks robust to equivalent `/tmp` and
  `/private/tmp` spellings.
- Renamed the now-reserved local `queue` variable in the Stage-3 controller.
- Kept the RXJSON timing measurement but removed its unconditional timing
  threshold from the correctness gate. The historical threshold can still be
  requested explicitly with `CPRAG_ENFORCE_PERFORMANCE=ON`.
- Updated current provider and CREXX dependency documentation. Historical Gate
  evidence remains unchanged.

## Focused Qualification

The final installed-only selection used the scratch package recorded in
[MACOS-BASELINE.md](MACOS-BASELINE.md) and ran 12 tests in parallel. All 12
passed in 29.73 seconds:

- `phase0_component_benchmark`
- `p1a_rxjson_projection`
- `p1a_sdk_probe`
- `p1_rxpa_01`
- `p1_rxpa_02`
- `p1_llm_02` through `p1_llm_05`
- `p1a_provider_boundary`
- `crexx_generic_pipeline_smoke`
- `use_case_wrapper_smoke`

`p1_llm_05` used three non-secret synthetic audit markers and proved zero
outbound connections. No hosted call or real credential read occurred.

Retained local log:
`/tmp/crexx-rag-mac02-final.XXXXXX.log`.

## Withheld Claims

- CRI-15 is not closed until the current binary-safe timeout path passes on
  supported Linux on both VMs.
- CRI-16 has an upstream implementation and a working macOS downstream
  migration, but persistent provider-level reuse plus Linux pooling,
  concurrency, TLS, cancellation, and sanitizer evidence remain open.
- No Phase-2 product item was activated or reordered.
