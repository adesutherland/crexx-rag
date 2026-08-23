# Phase 2 And Gate 2 macOS Closeout

Status date: 2026-08-23. Decision: accepted for the current macOS scope. Exact
downstream Linux replay remains open. Phase 3 is not authorized.

This is the maintained successor to the pre-decision
[Gate-2 packet](../2026-08-04-phase2/GATE-2-DECISION-PACKET.md). It does not
rewrite that dated item evidence. It records the user's Gate-2 decision, the
current installed-CREXX capability review, the downstream compatibility repair,
and the post-decision macOS replay.

## Decision Boundary

- `P2-01` through `P2-10` remain accepted.
- Gate 2 is accepted on macOS.
- CRI-15 remains open only for the exact installed-package downstream Linux
  replay on both concrete VMs. No macOS result is relabelled as Linux evidence.
- CRI-16 remains a separate application provider-lifecycle decision. The
  upstream HTTP substrate is qualified, but the current one-operation/one-pool
  adapters still truthfully report cross-operation reuse, streaming, and
  cancellation as unsupported.
- Phase 3 ingestion, hosted calls, donation submission, dual-write, cutover,
  native-v1 removal, normal-prefix installation, sister-checkout edits,
  commit, and push were not authorized by this decision.

## Installed Capability Review

The downstream remains an installed-package consumer with
`CPRAG_ALLOW_VENDORED_CREXXPA=OFF` and
`CPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF`.

The read-only CREXX checkout is at
`1fbd89dc9afb7dbbf2e8e577624a87b1076ff11e` (`Add complete public SHA-256
facilities`). Its existing Debug and Apple-ASan build trees were copied into
scratch install prefixes; CREXX was not reconfigured or rebuilt by this task.
Those build trees retain their earlier configured display identity
`crexx-1.0.0-beta.3+local.ge3d6b7b90158.dirty`. The installed provider itself
contains `RXSHA256`, `rxhash.sha256finalhex`, and `rxhash.sha256filehex`, and
the executable tests below exercise the complete new surface. Both facts are
recorded rather than silently relabelling the configured package identity.

- `rxjson.jsondocument` remains the direct parse-once structured-data surface.
- Level-G `rxfnsg` remains the typed HTTP/TLS surface; no shell transport or
  product-specific native HTTP bridge was introduced.
- `rxvector` remains the direct packed `f32le` exact cosine/top-k provider.
- the RXPA CMake package remains the only plugin-development/package boundary.
- `rxhash` now supplies the complete public SHA-256 family and replaces the
  application's former whole-file accumulation.

The exact public hash procedures consumed and proved downstream are:

```text
rxhash.sha256(data = .binary) = .binary
rxhash.sha256hex(data = .binary) = .string
rxhash.sha256init() = .binary
rxhash.sha256update(state = .binary, data = .binary) = .binary
rxhash.sha256final(state = .binary) = .binary
rxhash.sha256finalhex(state = .binary) = .string
rxhash.sha256file(path = .string) = .binary
rxhash.sha256filehex(path = .string) = .string
```

Raw results are 32 bytes; hexadecimal results are 64 canonical lowercase
characters. The immutable public state is the installed provider's canonical,
pointer-free 152-byte version-1 value: magic `RXSHA256`, version/flags/header,
big-endian byte count and chaining words, pending length and zero-padded block,
then an integrity SHA-256. The provider validates exact length, magic, version,
flags, header size, reserved bytes, count/pending consistency, canonical
padding, initial-state consistency, length limits, and integrity before use.
Updates and finalization never mutate their input state.

## Compatibility Repair

The first fresh replay against the new package passed 68 of 69 tests. The sole
failure, `p2_05_backup_restore`, was a compiler ambiguity between the newly
public `rxhash.sha256file(path)` and the existing unqualified application helper
of the same name and five-argument contract. This was task-attributable rather
than an unexplained platform failure.

The application helper is now explicitly named and called as
`ragfile.sha256filebounded`. It keeps the application-owned byte ceiling and
returned byte count, reads binary data in fixed 64 KiB chunks, and feeds each
chunk into immutable `sha256update` state. `sha256finalhex` returns the final
identity. The prior whole-file binary concatenation is gone. The Level-B
exception remains narrow because it owns `freadb`/`fwriteb`, byte counting, and
the application ceiling; all product/storage callers remain Level G.

Permanent coverage now also proves the direct public file routines over an
embedded-NUL/invalid-UTF-8 fixture. The Level-G installed-capability harness
covers all eight public procedures, empty updates, immutable independently
forked states, repeated finalization, raw/hex equivalence, provider autoload,
optimized and non-optimized compilation, both VMs, and installed
`crexx -native` static-provider selection.

## Validation

Focused repaired-path results:

- `p1_hash_01`: pass, including four dynamic compiler/VM cells and one native
  package/run.
- `p2_05_backup_restore`: pass across its four application cells, including
  binary file, crash, sidecar, backup, and restore scenarios.
- `p2_08_foundation_facade` and `p2_10_plan_revalidation`: pass after their
  helper calls were explicitly qualified.

Final current-worktree results:

- scratch installed-package Debug build: complete 27-step downstream build;
- full ordinary Debug CTest: 69/69 passed in 98.58 seconds with ten Phase-2,
  29 Phase-1B, dynamic-provider, external installed-SDK consumer, package,
  native/static, and zero-outbound tests included;
- fresh Release build: complete 27-step downstream build and 69/69 CTests in
  103.26 seconds;
- Apple AddressSanitizer: an existing installed CREXX Apple-ASan product plus
  ASan-built downstream core/plugins passed all 10 Phase-2 tests in 147.31
  seconds; focused `p1_hash_01`, including native/static packaging, passed in
  6.71 seconds with no sanitizer diagnostic;
- Apple LeakSanitizer: unsupported and not claimed; `detect_leaks=0` was used
  only for the Apple-ASan runs;
- documentation and language-level audits: 2/2 passed;
- `git diff --check`: passed;
- CREXX preservation: the read-only checkout remains at `1fbd89d`; its three
  pre-existing modified documentation files remain modified and were not
  edited, staged, reverted, or copied into this worktree;
- publication: no hosted call, credential read, normal-prefix install, sibling
  source edit, push, or pull request occurred. This closeout is committed only
  after the recorded QA under the user's later phase-by-phase commit authority.

An initial mixed-instrumentation experiment was rejected by Apple's runtime
before product scenarios ran: instrumented downstream plugins cannot be
sanitizer-qualified by late-loading them into the normal non-instrumented
compiler/VM. It emitted only interceptor/load-order and nested-runtime aborts,
not a source finding. The accepted sanitizer result above uses the coherent
all-instrumented installed product.

## Residual Work

The only Phase-2 platform residual explicitly accepted by the user is the
exact downstream Linux replay tracked by CRI-15. Provider-lifecycle expansion,
multi-process workers, ingestion, transports, and cutover belong to separately
authorized later scopes; they are not hidden Phase-2 failures.
