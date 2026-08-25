# CREXX Integration Issues

Status date: 2026-08-24. The current installed-only macOS replay uses CREXX
`develop` at revision `1fbd89dc9afb7dbbf2e8e577624a87b1076ff11e`,
copied from existing out-of-tree builds only into fresh scratch prefixes. The
configured package display remains the earlier `e3d6b7b90158.dirty` identity;
the complete executable SHA-256 surface and exact distinction are retained in
the [Gate-2 closeout](evidence/2026-08-23-phase2-gate2-closeout/README.md).

All fourteen original Gate-1A CREXX integration requests have an accepted
upstream disposition and an Apple downstream replay. Fresh Linux qualification
originally opened CRI-15 for the installed socket receive timeout contract, and
Phase-1B provider measurement opened CRI-16 for the then-installed HTTP
capability ceiling. Current CREXX now has green Linux ASan/LSan and cREXX-RAG
HTTP evidence for the replacement Level-G surface, and the full current
downstream inventory passes on macOS. SQLite task/thread hardening opened
CRI-17 for attached cREXX task discovery of native RXPA providers. Exact
downstream Linux confirmation, provider-lifecycle expansion, and that task
integration remain open. No issue authorizes a
product workaround, donation, cutover, or native-v1 retirement.

## CRI-01 through CRI-17 current disposition

| ID | CREXX disposition | Downstream disposition and proof |
| --- | --- | --- |
| CRI-01 | Fixed | Resolved by the approved CREXX candidate. Cross-module Level B record identity now survives Level G return, assignment and invocation without weakening nominal checks. The string-only facade was removed after CLI, ADDRESS and MCP semantic comparison passed. |
| CRI-02 | Fixed | Resolved. Exact read-only, non-escaping by-value binary formals no longer materialize a payload copy when inlined. The retained probe has matching checksums on both VMs and no optimized inversion. Exposure is no longer required as a compiler workaround; direct access remains only in the naturally direct cosine hot loop. |
| CRI-03 | No CREXX change | Closed as no CREXX transport defect. Deterministic timeout, malformed-response and connection failures remain structured; the historical hosted delay was repeated downstream reparsing plus an ineffective dimension field. No hosted call was made in this replay. |
| CRI-04 | Fixed | Resolved. Terminal non-fall-through `do forever` is accepted while reachable fall-through still requires a return. The two downstream dummy returns were removed and the retained reproducer compiles optimized and non-optimized. |
| CRI-05 | Fixed | Resolved. Authored Level G `PARSE` compiles normally while its certified lowering is legal and authored Level G assembler remains rejected. All affected profile/controller sources are Level G again, and the concrete PARSE reproducer passes both modes and both VMs. |
| CRI-06 | Fixed | Resolved. Malformed RXPA signature declarations produce `RXPA_IMPORT_SIGNATURE_INVALID` with source location, plugin, routine, field and declaration; no internal compiler error remains. The downstream negative runs in both modes. |
| CRI-07 | Documented/package-closed | Resolved. The installed package provides version-matched headers, imported CMake targets, explicit directories and the plugin helper. The external no-fallback consumer passes both VMs; vendored headers, generated-header copying and source-checkout fallback logic were removed. |
| CRI-08 | Fixed | Resolved without an ABI layout change. Setter and signal paths accept immutable diagnostic/status strings. The external SDK probe now passes the installed version string as `const char *`; unnecessary mutable casts were removed. |
| CRI-09 | Fixed | Resolved by generic JSON facilities, not provider vocabulary: production `rxjson.jsondocument` supplies parse-once typed traversal, noisy-container scanning, null/missing distinctions, Unicode, malformed/truncated failure and explicit statuses. The competing downstream JSON class was deleted and all callers migrated. |
| CRI-10 | Documented/package-closed | Existing scalar/array ADDRESS redirects capture stdout, stderr, status, empty and Unicode/multiline output. The downstream surface equality test remains green. |
| CRI-11 | Documented/package-closed | `CREXX run :argv[]` remains the supported shell-free argv-preserving route, with whitespace, empty arguments, quotes, Unicode and metacharacters covered by the retained package evidence. No downstream workaround was needed. |
| CRI-12 | Documented/package-closed | Redirect arrays append; callers use `arraydrop` when replacement rather than accumulation is required. No downstream workaround was needed. |
| CRI-13 | Fixed | Resolved. One immutable production JSON document projects explicit `node_f32_array`/`node_i64_array` owning raw little-endian binary. JSON does not infer width, byte order, dimensions or vector meaning; the application schema stores `element_type`, `element_count` and dimensional meaning. The F32V/I64V envelope and wrapper classes were deleted. |
| CRI-14 | Fixed | Resolved by the durable build-time `crexx.operation-contract/1` artifact, `crexx-contract` and installed CMake helper. The status-evidence contract is generated by `crexx_add_operation_contract()` and consumers do not inspect private RXBIN graph metadata. |
| CRI-15 | Upstream current path qualified; downstream Linux confirmation open | The retained 2026-08-03 Linux package made `rxvme` turn a blocking socket receive timeout into status `-5` (`received text is not valid UTF-8`) while `rxbvm` returned a two-byte payload. The pulled CREXX lineage passes the supported 2,363-test Linux ASan/LSan gate and all four CREXX-owned cREXX-RAG HTTP cells; the later process repair has focused Linux sanitizer evidence, and the current macOS installed-only downstream replay passes 69/69. Close only after the retained downstream reproducer passes against the current installed package on supported Linux and both VMs. No product-specific workaround is accepted. |
| CRI-16 | Upstream substrate qualified; downstream lifecycle decision open | Current installed Level-G `rxfnsg` supplies typed responses, connection-owner pooling/keep-alive, bounded request/response handling, gzip/deflate, streaming and cancellation primitives, with supported-platform feature evidence and Linux sanitizer qualification in the pulled lineage. The product-safe downstream adapters deliberately use one bounded synchronous connection per attempt and truthfully report connection reuse, streaming, and cancellation as unsupported. Closure requires exact downstream Linux/package replay plus an approved provider-lifecycle and capability scope; it does not require pretending substrate support is already an adapter feature. |
| CRI-17 | CREXX infrastructure: native RXPA provider discovery inside attached tasks open | The SQLite provider itself uses RXPA V2 per-VM sessions and `SQLITE_OPEN_FULLMUTEX`; a four-thread provider-session lifecycle harness passes. Separate worker processes load providers and open independent connections normally. A native-bearing `crexx-rag` image additionally confirmed that its internal pooled HTTP client cannot seed an attached bytecode task after native providers are present: sealing after load is excluded (`RXVM_PROGRAM_NATIVE_EXCLUDED`), while sealing first leaves the child task without a provider search path. The generic application provider therefore uses a bounded synchronous connection-per-attempt transport; it does not share SQLite across threads or claim pooling. Closure belongs on the CREXX roadmap: support declarative provider loading and normal RXPA V2 session lifecycle in each attached task VM. This is not a SQLite library/plugin defect and does not block OS-process workers. |

## Selected-package and replay facts

- Scratch install: 195 files. Production `rxvector.rxplugin`, `rxvector.a`, and
  compatibility `rxvector_static.a` are present; all three benchmark-only
  native providers are absent.
- Selected current identity: `crexx-1.0.0-beta.3+local.ge3d6b7b90158.dirty`.
- No-fallback cache: `CPRAG_ALLOW_VENDORED_CREXXPA=OFF` and
  `CPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF`.
- Clean downstream build: 27 Ninja steps. Its build graph, CTest file and cache
  contain no CREXX sister-checkout or normal-prefix selection.
- The current installed-only inventory passes 69/69 in ordinary Debug and
  69/69 from a fresh Release build. The earlier 62-test replay remains retained
  in the 2026-08-22 evidence bundle.
- Read-only binary probe checksum: `47201280` in every cell. Optimized
  by-value was 1,194 us versus 3,573 us non-optimized on `rxvme`, and 1,209 us
  versus 3,613 us on `rxbvm`, satisfying the accepted `<=0.90x` inversion gate.
- Generated operation contract SHA-256:
  `de7266e1bc7aeafb8b8731c0fac9305049b92f71ddcce8c426220f99be8b6c7f`.
- The complete installed `rxhash` SHA-256 family now owns deterministic
  downstream content identity and fixed-memory sidecar hashing, while the
  bounded 11,684-by-768 vector path uses installed `rxvector` with
  exact dual-VM results. Their macOS evidence is indexed by
  [`WORKLIST.md`](evidence/2026-08-22-crexx-capability-sync/WORKLIST.md).

Exact commands, artifact hashes, focused results, baseline failures and the
preservation audit are indexed by
[`evidence/2026-07-31-gate1a-crexx-candidate/`](evidence/2026-07-31-gate1a-crexx-candidate/).

## Remaining seams

CRI-15 remains open only for exact downstream installed-package Linux
confirmation; the old failure evidence is not erased by broader upstream
success. For CRI-16, current upstream pooling, TLS, compression, streaming,
cancellation, cross-platform build and Linux sanitizer evidence is accepted as
substrate evidence. Downstream provider-lifetime reuse, streaming and
cancellation remain truthful unsupported capabilities and need a separate
design decision. CRI-17 is the attached-task/native-provider discovery and
lifecycle seam; it does not revoke the SQLite session/thread qualification.
The macOS SHA-256 and RXVECTOR capability work is complete.
Exact downstream Linux replay remains open. Phase 2 and Gate 2 are accepted
for the macOS scope; this does not authorize Phase 3.

The historical Google timeout remains retained negative evidence. It must not
be reclassified as an `rxhttp` defect, and no hosted credential or call belongs
in the repeatable Gate-1A pipeline. CRI-15 is a separate deterministic Linux
loopback defect and does not reinterpret that hosted canary.

## Policy for this repository

Consume CREXX through an installed CMake package. Do not restore vendored RXPA
headers, generated-header copying, a sister-source fallback, or a normal-prefix
install as an implicit dependency. Keep the CREXX source checkout read-only.
