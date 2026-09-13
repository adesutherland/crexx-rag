# Four smoke/restart repair evidence — 13 September 2026

Review checkout `temp/project-review`, uncommitted on
`9292c8d8d724b52fce34047c868f15531348faca`.
See [the repair record](../../four-smoke-fixes-20260913.md) for exact outcomes,
implementation ownership and remaining qualification boundaries.

- `extended-baseline.log`: four extended regressions fail before product changes.
- `status-*`: first status build and 5/5 focused result.
- `restart-*`: first complete candidate build and 8/9 result; added parent-removal check fails.
- `final-*`: corrected original-parent propagation, build and 7/7 focused result.
- `full-before-prepare-*`: 64/67 full gate that exposed active preparation draining ownership; one later fixture readiness failure followed.
- `prepare-ownership-baseline.log`: exact runtime ownership mutation reproduced before the correction.
- `prepare-build.log`, `prepare-targeted.log`: corrected launch-versus-prepare boundary, build and final 9/9 focused panel.
- `full-*`: final full suite, console output and detailed CTest assertions.
- `installed-*`: scratch-prefix install, five fixture invocations and public command evidence for the four repairs.
- `artifact-sha256.txt`: tested native, linked and separately installed binary hashes.
- `source-sha256.txt`: affected product/test source hashes, including the retained pre-repair test changes.
- `evidence-sha256.txt`: hashes of retained log files.

The focused log predates removal of resolved `known-defect` labels; those labels
never changed test success semantics. Final source hashes describe the assertions
used by the full and installed gates. Fixtures use bounded local providers,
synthetic credentials and scratch libraries only. The installed prefix was
`/private/tmp/crexxrag-four-fixes-rZcd4v/installed`.

The original test-only 63/67 gate remains separately retained in
[the baseline directory](../restart-coverage-20260913/).
