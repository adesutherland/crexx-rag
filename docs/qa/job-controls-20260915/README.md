# Job controls acceptance — 15 September 2026

The [delivery checklist](../../job-controls-delivery-20260915.md) owns scope,
implementation and final status. All execution uses disposable libraries and
local synthetic provider fixtures; no hosted calls or master operations.

- `baseline.log`: six passing controls and the original PC-01 failure.
- `new-baseline.log`: deadline/list/native-reset failures before implementation;
  the first ordinary-reset fixture also has a duplicate synthetic plan digest.
- `reset-baseline.log`: corrected ordinary fixture, missing-command failure.
- `reconcile-reset-baseline.log`: nine earlier calls plus one unknown outcome;
  after reset, reconciliation incorrectly returns the item to dead letter.
- `targeted-final.log`: all nine affected checks pass after repair.
- `identity.json`: native/linked artifact and owning source/test hashes.
- `sql-access-paths.json`: existing indexed access paths for retry counts.

Elapsed test times are diagnostics from a shared machine, not performance
qualification. Job-list payload comparison is 66,275 bytes before versus
736 bytes after, with the original 65,535-character plan still retained.
`full-suite-before-edge-review.log` records the first 79/79 pass, followed by
`edge-baseline.log` reproducing the two additional cases. `edge-final.log`
records their six-test passing panel. `identity.json` describes the final
candidate; `identity-before-edge-review.json` retains the earlier one.
`full-suite.log` records the final candidate: **79/79 pass**, zero failures,
1562.73s on the shared machine. The candidate and all recorded owning source/test
hashes were verified after that run. Configure/build and both changed skill
validators pass; the delivery checklist is complete.
