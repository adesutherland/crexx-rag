# Current CREXX Integration Replay

Status date: 2026-08-23. The current `crexx-rag` tree passes its complete
installed-only test inventory against the pulled CREXX `develop` head. This is
a macOS integration result and current-upstream evidence review; it is not an
exact downstream Linux replay or approval for a provider-contract redesign.

## Provenance

- Host: Darwin 25.5.0 arm64, 10 logical CPUs.
- CREXX source revision:
  `e3d6b7b9015847d247ab2b90e83c843881db9b2f`.
- Installed package identity:
  `crexx-1.0.0-beta.3+local.ge3d6b7b90158.dirty`.
- The CREXX dirty marker records the documentation-only RCC-6/RCC-7 roadmap
  transfer made before the build; no CREXX production source was locally
  modified.
- `crexx-rag` source revision before this evidence update:
  `f46c001373709a13b8823024317fd8e443f87b0d`.
- Scratch install prefix: `/tmp/crexx-current-install.6yzYQv`.
- Fresh downstream build:
  `/tmp/crexx-rag-current-replay.00ZyVT/build`.

The normal CREXX prefix was not changed. The downstream configure supplied
both `CMAKE_PREFIX_PATH` and `CREXX_DIR` from the scratch prefix, with
`CPRAG_ALLOW_VENDORED_CREXXPA=OFF` and
`CPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF`.

## Upstream Review

The pulled CREXX delta does not add a replacement public HTTP API. It closes
sanitizer and ownership findings around the already published facilities:

- supported Linux ASan/LSan passes 2,363/2,363 tests at exact commit
  `e3de72939df0dacf22c0793371233ed439227437` in the pulled lineage;
- all four CREXX-owned cREXX-RAG HTTP cells pass in the final Debug gate;
- the later process cancellation/replacement race is repaired in `c87809d2b`
  and has focused normal Debug plus Linux sanitizer evidence followed by a full
  ordinary Debug pass;
- the exact `rxvector` provider is now supported-Linux sanitizer-qualified; and
- the Level-G `.httpclient`/`.httpserver` surface remains the public HTTP
  contract, with typed responses, bounded admission/buffering, connection-owner
  pooling, compression, streaming primitives and cancellation primitives.

## Downstream Result

The exact command shape was:

```sh
cmake --build cmake-build-debug --parallel 10
cmake --install cmake-build-debug --prefix /tmp/crexx-current-install.6yzYQv
cmake -S . -B /tmp/crexx-rag-current-replay.00ZyVT/build -G Ninja \
  -DCMAKE_PREFIX_PATH=/tmp/crexx-current-install.6yzYQv \
  -DCREXX_DIR=/tmp/crexx-current-install.6yzYQv/lib/cmake/CREXX \
  -DCPRAG_ALLOW_VENDORED_CREXXPA=OFF \
  -DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF
cmake --build /tmp/crexx-rag-current-replay.00ZyVT/build --parallel 10
ctest --test-dir /tmp/crexx-rag-current-replay.00ZyVT/build \
  --parallel 10 --output-on-failure
```

Results:

- CREXX Debug build: passed, 1,599 steps.
- CREXX scratch install: passed.
- Fresh downstream configure: selected the exact scratch package.
- Downstream build: passed, 27/27 steps.
- Downstream CTest: passed, 62/62 in 97.99 seconds.
- Provider tests `p1_llm_01` through `p1_llm_05`: all passed.
- `p1_hash_01`, `p1_vec_01` through `p1_vec_03`, the installed SDK probes,
  generic pipeline and use-case wrapper: all passed.

No hosted provider call was made, no credential was read, no normal-prefix
install occurred, and no Phase-2 item was activated.

## Integration Disposition

No compatibility code change was required. Current `main` already uses the
public installed facilities selected by CREXX:

- typed Level-G `.httpclient` policies, headers, pooled request clients,
  responses and explicit close;
- installed `rxhash.sha256` for bounded immutable content identity; and
- installed exact `rxvector` with explicit `f32le` conversion for bounded-page
  cosine/top-k.

The provider adapters deliberately create one client pool per provider
operation. They therefore do not yet claim provider-lifetime connection reuse,
provider streaming or provider cancellation. Adding those capabilities changes
the provider lifecycle and interface and remains an approval-gated design item.

## Deferred Parallel Closure

These items do not block the ordered Phase-2 product work. The Linux replay is
scheduled for a later QA point after material progress on this host.

1. Run an exact current-package Linux downstream replay, including the retained
   CRI-15 socket-timeout reproducer, both VMs, all 62 tests and the supported
   sanitizer route. The current upstream Linux result makes this a downstream
   confirmation gate, not evidence that the old failure should be ignored.
2. If approved, design provider-owned persistent pool lifecycle, timeout-policy
   behavior and explicit close through the provider/facade boundary. Prove real
   keep-alive reuse with a multi-request loopback fixture before changing the
   `connection_reuse` capability from zero.
3. Decide separately whether provider streaming and cancellation are needed in
   the current product phase. The substrate primitives do not by themselves
   authorize adapter claims.
4. Keep independent package/donation work and incremental hashing outside this
   integration item until separately approved.
