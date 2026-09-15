# REF-001 — bounded extraction-referral response access

## Requirement and authority

The Scottish coordinator reports a public-surface gap during authorized manual
review: extraction referrals direct the manager to original responses and
correction feedback in `job events`, but MCP accepts only id/cursor/limit and
cannot select an item. Task inspection/evidence does not include those responses.
The first 100 events were unrelated to the three held referrals. Whole-queue
scanning is not an acceptable substitute for a missing bounded public control.

Provide an item-filtered public event/response path, or exact relevant event
references in the referral. Preserve immutable original output, correction
feedback and final validation diagnostics. Use shared catalogue/operations
owners, existing indexed access and normal CLI/MCP vocabulary. Core fixtures
only; do not mutate or restart the Scottish master.

Evidence:
`/Users/adrian/Documents/ScottishHistory/reports/escalation-review-20260915/evidence/extraction-events-first-page.json`
and `initial-0.json`. This is separate from ISSUE-01 and ESC-001.

## Checklist

- [x] Record the reported gap and core-only scope.
- [ ] Inspect existing task/event projections and their actual response fields;
  identify the smallest shared public control that supplies the missing evidence.
- [ ] Run baseline public controls; add a failing bounded target-item journey
  with unrelated events before it, plus paging and original-response assertions.
- [ ] Repair the owner, catalogue and surface consumers together; verify indexed
  SQL scope and preserve unfiltered public behavior.
- [ ] Update agent/user guidance and coverage; run focused/full QA and report
  candidate versus installed availability to the coordinator.

Status: deferred after Adrian's subsequent clarification. The three historical
model/content failures are unconfirmed under current prompts. The coordinator
will run bounded current-prompt retries and send fresh reproduced failures.
Historical-response access is not a blocker to those retries. No implementation,
master mutation or engineering-owned retry has been performed. ESC-001
was subsequently superseded by the completed task-reset repair; worker
replacement is covered by its own completed local repair record.
