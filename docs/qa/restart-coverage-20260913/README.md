# Restart and smoke-status coverage evidence — 13 September 2026

Test-only baseline against review HEAD
`9292c8d8d724b52fce34047c868f15531348faca`, product implementation `1edb325`.
Native artifact SHA-256:
`02f2d4ef292ff6cb6417a466178d682c42265c6878b999708101a01365a07fb5`.

- `baseline.log`: before new tests, six affected existing gates pass.
- `configure.log`, `build.log`: configure passes; product build is unchanged.
- `full-suite.log`: **63/67 pass in 879.91s**; exactly the four new
  known-defect tests fail. All 63 pre-existing tests pass.
- `final-focused.log`: **2/6 pass in 15.28s**, the same four failures;
  original interruption and documentation gates pass. This rerun includes the
  final stale-but-alive and non-target listing controls added during review.
- `*-commands.log`: public responses from the final four reproductions.
- `test-sources.sha256`: final fixture/registration hashes, paths relative to
  repository root. No product implementation changed during either run.

The complete gate is **red**, as required for a pre-repair baseline. Setup,
read-only, known-live/empty/unknown/pause and repeated-continuation controls pass.
Tests use `SEND_ERROR` for the known mismatches so subsequent controls and
cleanup still run; errors retain CTest exit 8. No failure is inverted or hidden.
One initial fixture assertion counted retained controller rows even though
normal pruning removes them; that assertion was corrected to compare new
identities before the full run. It is not recorded as a product defect.

Run the full gate from `crexx-rag-review` with:

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

The named `known-defect` tests remain ordinary failures until the product is
repaired. Scratch libraries and local provider fixtures only; no hosted calls,
Scottish library mutation or new policy authorization. See the
[coverage matrix](../../regression-coverage.md#current-status--13-september-2026)
for controls, owners and limits.
