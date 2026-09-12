# MCP trials on a copy of the soak corpus

The [consolidated roadmap](ROADMAP.md#agent-and-public-surface-findings-outside-the-numbered-backlogs)
indexes the outstanding discovery, pagination, preview and workflow-completion
findings below. This report retains the original trial evidence. The subsequent
[UX-03 repair](connection-effect-previews.md) has separate local synthetic
regression evidence; it does not claim a rerun of this copied-corpus trial.

9 September 2026. These trials extend the [synthetic fresh-agent
tests](mcp-codex-trials.md). The interface supports useful grounded questions
and real evidence refresh. A known connection task also passed exact submission
and review. Large-backlog discovery, effect previews and the final external
retirement step still need work. This is bounded acceptance evidence, not
complete corpus or unattended-operation qualification.

## Corpus and executable

The tested product baseline is commit
`62e3806c39ba330059477ba9210d7a3f6fe3597c`, on
`temp/mcp-codex-integration`. Native executable SHA-256:
`7db85065ce9a6d1f7fbb40096b99ff44af923710333861197c715b0414477ca5`.

The overnight Browne/Keltie run had stopped, with no workers running and a
passing final library verification. Its terminal job retained
`completed_with_errors`; orderly controller/worker exit does not erase content
validation failures. Public `library backup` and `library restore` produced a
generation-pinned test copy at generation **11964**. Only that copy was migrated
from schema 11 to 12. Existing table content was preserved except the expected
library/schema migration metadata. Repository verification and foreign keys
passed.

The corpus contains Browne volume I and Keltie volumes I–II: three source
revisions, 19,116 chunks, 49,261 historic provider-run records and 16,678
maintenance tasks. Physical tables retain 10,349 concepts and 3,430 claims;
the overview counts 10,336 active concepts and 3,427 active claims. These are
different scopes, not conflicting measurements. There were 1,667 pending claim
reviews and 14 migrating workflows.

The original soak library, source files, main checkout and global installation
were not changed. Trials did not start maintenance workers, replay old jobs,
change the copied configuration or call a RAG provider. Fresh Codex inference
used managed authentication and subscription allowance separately.

Raw evidence is retained under
`/Users/adrian/testrag/mcp-soak-62e3806-20260909`: public backup/restore/migration
results, fixed prompts, launch settings, installed skill hashes, Codex events,
MCP traffic, answers, database hashes and application probes. These are local
acceptance artifacts, not a portable checked-in fixture runner.

## Fresh-agent results

Each session started with the installed skills and actual stdio MCP server,
`read,plan` access and a separate unchanged corpus copy. It had no prior
conversation, repository source, shell, SQL, corpus-file, web or memory access.
The client was Codex 0.153.4 with the user's configured `gpt-6-astra` / `xhigh`.
All three sessions left **all 70 SQLite table-content hashes unchanged**.

| Trial | Outcome | Product MCP calls | Measured seconds |
| --- | --- | ---: | ---: |
| Corpus questions | Grounded Glencoe account, source dependence and explicit unknowns; direct Browne comparison remained unestablished | 20 | 340.06 |
| Backlog discovery | Could not find the named Turray migration; independently found an oversized Highlands task and prepared a complete refresh | 30 | 493.00 |
| Known Turray task | Given its task ID, inspected all three children and proposed retraction of the redundant claim; reported an unclear impact preview | 16 | 223.94 |

The question and known-task trials had 20-call/eight-minute ceilings. Discovery
had 30 calls/twelve minutes. The known-task agent additionally attempted MCP
resource discovery, which returned method-not-found; its reported 17-call
total includes that non-product request. Harness timing is authoritative where
an agent's prose estimated its duration differently. Single observations do
not establish a latency benchmark.

The question agent separated source narrative from accepted graph edges and
inferred paths. It treated publication dates separately from event dates,
labelled its reconstructed event date, and declined to establish private intent.
It recognized Keltie's stated use of Browne as a source-dependence concern.
All six answer citations were independently resolved against stored revision
UTF-8 ranges and checked against the cited claims. The agent directly called
`rag_citation_show` for three; the other three came from query evidence.

Retrieval often selected index entries, neighbouring fragments and generic name
matches. Only Browne volume I was present. Failure to retrieve a comparative
account was reported as a coverage/retrieval limit, not proof that the author's
whole work lacks it. The evidence did not validate historical truth or source
authenticity.

## Independent protocol and application checks

- **Pagination:** all 1,667 pending reviews were retrieved exactly once in 84
  pages of 20 and compared with SQLite. An advertised full page of 100 failed
  because its cursor made the result exceed the 100-record renderer.
- **Job discovery:** two retained job plans exceed the generic 65,535-character
  string field. One 1,468,714-character plan reproduced the error on a
  single-item page. Smaller page counts cannot expose that row.
- **Direction and time:** outbound and inbound Glencoe inspection retained each
  returned claim's stored subject, relation, object and direction. Unknown
  temporal claims remained explicitly unknown; excluding unknown time removed
  them. Source passages remained available as passages.
- **Real evidence refresh:** the discovery agent's exact Highlands plan was
  applied on another copy. It retained 182 passages and 148 catalogue concepts
  in 190,079 bytes, preserved the old task/packet/question and created an
  advanced-reasoning successor. All stored inventory pages matched the plan.
  Exact replay was a no-op; tampered completeness/digest and changed-generation
  inventory requests were rejected. Only the task table changed; generation
  remained 11964 and provider accounting was unchanged.
- **Real connection correction:** the known-task agent's exact claim-targeted
  Turray retraction plan passed submission, exact replay, preview and mandatory
  review acceptance. A wrong digest and refresh during the pending review were
  rejected without writes. Acceptance closed the selected claim/support and
  resolved the connection task at generation 11965. A competing earlier plan
  was then rejected. Source text, revisions, chunks, configuration and provider
  runs were unchanged; foreign keys passed.

Public `library verify` subsequently passed with zero repository issues on
both modified copies, at generations 11964 and 11965 respectively.

The Turray source says that Turray is the old name of Turriff. Retraction removed
the redundant `Turray → related-to → Turriff` representation after the alias and
mention had already migrated; moving it would instead create a self-edge.
The original source and historical claim/support rows remain available.

The workflow still reports `migrating`, with all three connection tasks resolved.
An independent census found zero remaining active aliases, mentions, claims,
notes, ambiguity candidates or conflicts on the parent, but **no retirement task
exists yet**. The current engine creates that task in a later maintenance
census; external acceptance does not advance the workflow to that step. No
worker window or configuration change was introduced to force the test through.
This trial therefore does not claim completed retirement.

## Recommended next changes and repeat tests

1. **Make backlog discovery usable at corpus scale.** Add bounded task lookup by
   subject/concept and an addressable workflow inventory. Keep job list rows
   bounded, exposing large retained plans through a separate paged detail path.
   Align advertised page sizes with cursor overhead. Repeat the identical
   Turray discovery prompt and complete review/job pagination without evaluator
   IDs or inaccessible rows.
2. **Finish the external correction loop.** Expose a bounded, reviewed way to
   advance a known workflow's census and prepare retirement without starting an
   unrelated worker batch. Include the affected support/claim and proposed effect
   in connection previews: both Turray retraction candidates returned
   `impact: []` despite a real later retraction. Repeat known-task planning,
   exact apply/review, connection accounting and retirement; require the parent
   to be retired and the workflow complete, with retained history and verified
   source/provider invariants.
3. **Improve focused evidence exploration.** Evaluate source-scoped query
   inspection and navigation from a citation to adjacent context. Repeat fixed
   historical questions against the same frozen copy and score source coverage,
   faithful qualification, citations and calls needed. Do not substitute answer
   fluency or a higher claim count for better evidence.

The existing escalation tests already distinguish repeated semantic failures,
worker assertions and transport/storage failures. The migrated real backlog had
zero advanced-reasoning flags: historic attempt counts were not retrospectively
classified as semantic failures. Repeating failures indiscriminately would not
be a valid escalation test.

The README, current guides and skill pagination advice were updated after these
observations. The measured trials retain their original installed skills;
the manual workspace uses a separate prefix containing the updated guidance.
No product implementation was changed for these wider trials.
