# Six-item maintenance programme: final local QA

Date: 26 September 2026. Candidate base:
`847cea88d1248f352498b4cc5a70d456641b884b` plus the final QA fixture,
two bounded zero-deadline owner corrections and this record. This record does not supersede the
individual implementation and coordinator-review receipts in
`maintenance-refactoring-delivery.md`.

## Baseline and final selection

The selected worktree was built against installed CREXX
`crexx-1.0.0-beta.3+local.g5949ef27efd8`. The linked Level-G application
SHA-256 was `ddf29209bf7a24b086eeb5c1b56c38d7d392a8d7876b9ef9e6189700bda34d0d`;
the native executable was
`1bf16951f05260e7e3dba916886e965515f0b95aa38f319a03650fbae830727e`.
The hashes below precede the subsequent zero-deadline owner corrections.
No installed CREXX file changed in this QA task.

Before the fixture addition, the first 144-case regression selection stopped
at 137: 136 passed, one `native_embedding_windows` case failed when the
second local model load exceeded its configured 10-second timeout, and seven
had not run. The unchanged case passed alone in 11.17 seconds. Resuming the
selection produced a complete 144/144 passing QA ledger. The original failed
receipt is retained under `cmake-build-debug/qa/runs/native_embedding_windows/`;
the passing control and final selection do not erase it.

Before the final fixture and product corrections, `ctest --preset regression --output-on-failure`
passed 145/145 in 364.99 seconds. The read-only
`python3 tests/qa/report.py --json cmake-build-debug/qa-final-145.json
--require-complete` audit returned `{"passed":145}`. CTest's skipped lines are
exact-input passing receipt reuse; the QA ledger has no failed, disabled,
interrupted or not-run required case **for that earlier input set**. The separate `ctest --preset scale`
turnover lane also passed.

## Late-target model-wire acceptance

`durable_backlog_provider_large-target` uses the existing provider-loopback
fixture, a typed local-only configuration and a new synthetic scratch library.
The source has an exact 38-byte dependency quotation. Twelve earlier subject
mentions and 500 byte-heavy entries occupy a separate, non-decisive source
chunk. The unique 38-byte dependency quotation first appears through passage
continuation; 105 catalogue fillers place the target beyond the first catalogue
page. The new absence assertion failed against the old seed with `0:8:8`, then
passed with `0:0:1` for initial, first-page and continued-page visibility.
Every inspection response remained within 8,192 bytes.

The model inspected the late target, read the exact source citation, and
proposed `PlatformService depends-on AzureStore`. The fixture deliberately
returned an invented quote first. The product requested one correction; the
corrected response became one pending review, with no premature claim. All
11 provider requests, including ingestion and the correction, retained exact
serialized byte counts below the selected 98,304-byte per-call limit. The
fixture accepted the review through the public command and independently
checked one directed claim and support on `late-chunk`, UTF-8 bytes 0–38.
There were 11 retained provider runs and zero aggregate reservations. SQLite
integrity, foreign keys and `library verify` passed. The pre-existing
`correction-limit` test remains a negative control for an over-limit full
serialized request.

The new fixture's earlier failed runs exposed its setup boundaries: a
legacy-format role input setting was ineffective, short synthetic source IDs
were invalid for exact reads, and direct SQL source insertion needed the FTS
row. Each was corrected in the fixture; no product behavior or timeout was
weakened. The initial 24,576-byte and then 49,152-byte request holds were
expected guard behavior for those selected limits and remain visible in
retained scratch receipts. The typed Gemini config is now captured and copied
as a QA input. Its passing targeted receipt hashes the template as
`38bc888b60c595163ebf7c12c391956e1de41284e27993feccc59d68fe6999ff`.
An edit to a private copy changed the inspected identity key from
`48878677a50a67ab2f670cc7010e02d31cc20385d93cea0159800af67a00bddf`
to `d46ddc35e94d216bf82ced028fa615dbdeaee546ff039d92bce13a9b3e5730db`.

## Zero-deadline owner correction

A bounded synthetic format-4 run exposed a real defect: a maintenance window
with the documented unlimited deadline `0` reached provider admission but was
rejected as expired. The retained failing QA receipt is
`durable_backlog_provider_unlimited_restart/20260926T134935-82f0879f`, with
two earlier finite calls and zero of two expected unlimited calls settled.
`ragenvironment` now applies the deadline check only to positive deadlines;
`ragsupervision` uses the same rule for worker replacement. A later exploratory
eight-item run with these owner changes settled eight note calls but also
dispatched an additional source-review call beyond its fixed loopback count.
Adrian then withdrew the exploratory harness and directed no further test
runs. The owner correction is **not claimed as passing current-input QA**;
the earlier 145/145 result predates it.

## Bounded load and package boundary

The separately declared bounded concurrency lane ran the existing native `concurrent` case
with 400 maintenance items, a 400 maintenance-call ceiling, two native workers,
200 forced overlapping request pairs and a 20-minute per-command timeout in
`cmake-build-debug/qa-long-400`. It finished in 15.94 seconds with 400
`retain:resolved` decisions, 402 total provider receipts including ingestion,
two distinct worker IDs, zero unfinished items or reservations, SQLite
`integrity_check=ok` and zero foreign-key violations. Its result file records
the source/vector invariant. This is a throughput and ledger control; it does
not assess semantic quality or simulate a multi-hour soak. Adrian withdrew the
additional timed synthetic gate. An eight-hour run on the correct corpus is a
separate later task and was neither selected nor started here. The earlier
regression selection covers restart, quiescence, policy, review, correction and
outcome transitions on its earlier input set.

`cmake --install` staged this Debug candidate in a private build-tree prefix.
Its native executable initialized a disposable library, supervised two
workers and passed library verification without a provider call. This is a
staged executable smoke, not a release-inventory or relocated-ZIP check:
`release.json` and its exact source identity require a committed SHA. The
workflow's macOS Apple Silicon/Intel and Windows x64 package and installer
checks remain to be observed after publication. No global install, protected
corpus, beta tag or release was used.

No live Gemini or corpus call was made. Existing automated Gemini, malformed
output and redaction cases remain the available local evidence. Live-provider,
real-corpus and endurance qualification remain unrun.
