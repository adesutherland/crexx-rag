# Public results and Unicode lexical repair

Steps 5a/5b and 6, 12 September 2026. Baseline: `5d1481a`, which committed
all outstanding review documents, fixtures and the full regression workflow.
That checkpoint deliberately retains the three ordinary failing acceptances.

## Coverage before implementation

The fresh baseline ran `query_policy`, `evidence_methodology`,
`regression_pages`, `regression_page_max`, `regression_large_job`,
`regression_retrieval` and `regression_retrieval_unicode`: **4/7 passing in
41.00 seconds**. All three intended defects reproduced after their positive
controls. The native hash was the previously qualified step-4 artifact.

Before product edits, the tests were extended with full traversal at limit 100,
a multi-byte retained plan and exact detail reconstruction, quoted/unquoted
Unicode names and combining forms, direct planner assertions and ADDRESS
boundaries. The new ADDRESS scenario reproduced page, large-summary,
missing-detail and Unicode failures while its normal-page and invalid-result
controls passed. The scratch installation also reproduced the maximum-page
failure. A proposed absence assertion for an English operator-name phrase
was discarded during test design: the existing exploratory query deliberately
returns focused variants, so strict-phrase-only retrieval was not its contract.
Literal phrase construction is tested directly without changing that behavior.

Baseline logs are `/tmp/crexx-rag-results-baseline.log`,
`/tmp/crexx-rag-results-expanded-red.log`,
`/tmp/crexx-rag-result-contract-red.log` and
`/tmp/crexx-rag-installed-results-red.log`. Test-only compiler setup errors
were corrected before interpreting executable failures as product evidence.

## Ownership and behavior

- `ragcommand.validcommandresult` permits 100 data rows plus one bounded final
  `page` record. The extra-record allowance rejects 101 data rows,
  duplicate/non-final page metadata, missing/oversized cursors and inconsistent
  limits. Existing bounded task-page metadata and other field bounds remain.
- `ragresultpages` owns repository result projection, cursor construction and
  plan-page presentation. Repository and event handlers compose it.
  `ragproduct` retains command access and routing.
- `ragrepository` owns the SQL projections. A small job plan remains in `value`;
  a larger plan yields an empty value with `value_complete=false`, its character
  count and `detail_operation=job.plan`. The summary query does not return the
  complete large plan to cREXX. No stored plan is truncated or modified.
- `job plan JOB_ID --cursor OFFSET --limit N` and MCP `rag_job_plan` expose
  exact text in at most 8,192 Unicode characters per page. The read includes
  original plan digest, offset, total characters and the next cursor. SQLite
  returns only the requested slice. Concatenating JSON/MCP pages reconstructs
  the original; human rendering retains its ordinary preview limits.
- `ragquery` preserves non-ASCII characters and combining marks for SQLite's
  existing Unicode tokenizer. ASCII query punctuation remains separated and
  generated terms are lowercased. This repairs the query/index mismatch without
  rewriting source text, citation offsets, embeddings or stored profiles.

There is no schema migration, new executable, provider integration change,
provider call or real-library operation. The installed CREXX SQLite provider
remains the sole implementation. These result/query owners do not acquire
admission, recovery or publication policy.

## Acceptance and review

The original three failure tests remain in the required gate. Additional
`regression_plan_detail` checks a 1,500,014-character plan, mixed small/large
listings, exact multi-byte reconstruction through JSON/MCP, human/NDJSON
availability, invalid limits/cursors, end-of-text, missing IDs, strict MCP
arguments, unchanged SQLite state and zero provider calls.

`regression_result_contract` runs on both optimized VMs through ADDRESS and
also checks the result validator directly, maximum event pages, exact plan
reconstruction, read-access denial and planner terms. The scratch installed
product repeats maximum-page, plan-detail and Unicode public tests. The frozen
retrieval questions retain independent direct-index and source/citation oracles,
including uppercase/decomposed names, Unicode punctuation and absent terms.

The first repaired build passed all three original failure tests. The added
plan-detail tests caught a missing CLI operation registration, which was fixed
before full qualification. The unchanged `native_surfaces` test also caught
an overly broad metadata check rejecting existing empty task pages; a focused
control was added and the stricter check was confined to the extra-record
allowance. This is direct evidence for consolidating the
command vocabulary and transport metadata in a later characterized refactor.

Final `cmake --workflow --preset regression`: **50/50 passed in 654.74
seconds**, including all three former failures and both new tests. Configure
succeeded and the unchanged build reported no work. The installed CREXX package
is `crexx-1.0.0-beta.3+local.g5ccf057a1633`.

Native SHA-256:
`a571e3d7c90fc115c43e236094101a527b8f5128282d865eab5479c08473b6a8`.
The full log is `/tmp/crexx-rag-results-full.log` and
`cmake-build-debug/regression.log`; the matched test inventory and artifact
check are in `/tmp/crexx-rag-results-verification.json`. Source and test inputs
were fingerprinted and verified unchanged through the full run. Local link,
documentation-contract and whitespace checks also pass. No hosted provider
calls, global installation or user-library changes were made.

Broader OPS-003
operator diagnostics, other large-result shapes, QE-06 ranking/OCR/alias work,
QE-09 comparative retrieval quality and long-running/platform qualification
remain separate. A passing contract corpus does not establish multilingual
retrieval quality in general.
