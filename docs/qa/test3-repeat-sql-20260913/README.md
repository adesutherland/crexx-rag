# Installed Test 3 repeat evidence — 13 September 2026

See [result](../../test3-repeat-sql-20260913.md). Captured from the normal
installed executable and a fresh disposable public-corpus backup. `status-final.json`
is the post-completion status observed at 20:13:49 UTC. All commands exited 0.

- `install.log`, `after.json`: installation result and installed binary digest.
- `backup.json`, `migrate.json`, `before.json`: copy identity and starting data.
- `plan.json`, `apply.json`, `preparation.json`: reviewed policy, durable job and timings.
- `payload-review.json`, `selected-input-review.json`: public input selection metadata.
- `run.*`, `status-final.json`: execution, recovered timeout and terminal accounting.
- `decisions.json`, `provider-runs.json`, `items.json`: retained read-only ledger extracts.
- `verify.json`, `after.json`, `citation.json`: integrity and preservation evidence.

`after.json` compares source/revision identity, sources, chunks, claims and provider
run totals with `before.json`. The source/revision digest is SHA-256 over compact
JSON arrays of `(source_id,current_revision_id)`, ordered by source ID. The complete
citation response is equal to the retained Test 2 response. Test 4 subsequently
read the same copy without mutations. Full product acceptance is retained separately
under `../sql-performance-fixes-20260913/`; no product inputs changed in this smoke.
