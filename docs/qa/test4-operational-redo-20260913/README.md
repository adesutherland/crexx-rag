# Test 4 operational redo evidence

See [report](../../test4-operational-redo-20260913.md). Two one-item public
`job replay` / `job run` journeys operated only on the disposable copy.

`replay-preflight.json` is the initial configuration-compatibility rejection.
`config-*` selected the temporary original source scope with current smoke
budgets; `restore-*` restored the exact prior current snapshot after both jobs
completed. Only six `source.smoke-bannockburn.*` lines were omitted in the
temporary policy. The original policy file retains its pre-run SHA-256.

`run-*` captures controller results, timings and the enclosing run interval.
`status-fiers.json` and `status-nairn-final.json` are terminal status records.
`attempts-nairn.json` preserves the first failed citation validation and its
successful correction. The three-run ledger, two resolved replay lineages,
20 new mentions and two claims are in `after.json`; `new-claim-supports.json`
records exact supported endpoints and byte spans. `verify.json` is the public
integrity result. `citation.json` is byte-for-byte equivalent JSON to the
retained Test 2 citation response. No token values were read or retained.

The content-draft folder contains preparation artifacts only, with source
hold identities and normal grounding results. No draft was accepted or written
to the corpus. `content-inspect.json` retains the historical item lookup gap.
