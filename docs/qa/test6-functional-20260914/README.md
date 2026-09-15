# Test 6 core functional evidence

The active checklist and capability-family review are in
[Test 6](../../test6-agent-functional-20260914.md). The corpus agent's prompt,
resolution previews, controls and prepared live pilot are recorded separately
under `/Users/adrian/Documents/ScottishHistory/reports/functional-test6-20260914/`.

The native executable is the unchanged staged candidate
`2828fc4a3a251aab3731afd2c9f378c8f670c7e171aa3a8397fa129de6f8abb6`.

- `capability-inventory.json`: all 88 shipping interface entries, 84 unique
  operations and 71 MCP tools, with access and library requirements.
- `inventory-requests.ndjson` / `inventory-responses.ndjson`: actual public
  initialization and tool discovery. The named tools match the source catalogue
  exactly; metadata discovery creates no library or provider call.
- `instance-isolation.json`: two disposable instances, actual frozen Scottish
  candidate applied through public configuration controls. The other instance,
  shared schema/contract, binary, original config and skills remain unchanged;
  the configuration transition does not publish a corpus generation. Detailed
  CLI results remain in the identified scratch directory.
- `focused-ctest.log`: 16/16 selected functional controls passed. Coverage includes
  policy editing, prompt inspection/contracts, command metadata/arguments,
  configuration transitions, lifecycle, worker recovery, query policy, native
  and ADDRESS surfaces, installation, skills, local embeddings, temporal
  provenance and durable external-agent workflows.
- `publication-ctest.log`: populated public backup/restore, concurrent readers
  and publication failure/recovery passed, including exact vector and provider
  history preservation.

All 17 tests use local fixtures and disposable libraries. The observed 335.67
and 8.89 seconds are not shared-machine performance thresholds. The prior full
71-test result remains the complete baseline; this panel is additional targeted
functional execution, not a new full-suite run or configured-Luna quality test.
No product source was changed in Test 6.

The approved disposable configured-Luna pilot subsequently completed eight of
eight items on the first attempt, with no corrections or provider failures.
Seven retain proposals and one focused investigation remain in supervised
review; no proposal was applied. All 23 canonical supports bind their selected
occurrences and resolve to original source text. Recorded usage was 182,843
input/3,837 output tokens, zero monetary cost and zero Gemini calls. Final
verification passed at generation 23213 and both workers stopped.

The preparation incorrectly set the general `budget.model_calls` ceiling to
zero. Public config set/plan/apply corrected it to eight within the approval,
with `budget.codex_turns=8` and monetary budget zero. This was a test-setup
correction, not a planner defect.

The exercised functional scope is green. The frozen prompt's literal quotation
target remains incomplete: five of 23 raw quotes changed whitespace/case;
documented grounding normalization preserved the original supports and
citations. Keep FT6-Q01 visible as a corpus-prompt quality follow-up. No core
fix, extra inference, master rollout or soak was performed.

Corpus evidence: `luna-semantic-review.md`, `luna-case-results.json`,
`luna-findings.json`, `luna-quotation-audit.json`,
`luna-canonical-grounding-check.json`, `luna-metrics.json` and
`luna-closeout-proof.json` in the report directory above. The checklist records
remaining sampling, platform, performance and quotation-fidelity limits.
