# MCP and skill trials with fresh Codex agents

Date: 9 September 2026.

Subsequent [trials on a copy of the soak corpus](mcp-soak-trials.md) extend this
synthetic evidence and record remaining discovery and workflow-completion gaps.

The baseline → implementation → fresh repeat sequence demonstrated a useful
improvement. Codex can now inspect the corpus without tool-approval failures,
answer the synthetic questions with resolved source citations, discover actual
tasks and jobs, and return a canonical task correction. The exact correction
from a fresh agent also passed submission and review acceptance on another
scratch clone. This is bounded integration evidence, not full-corpus or
production qualification.

## Method and artifact identity

The committed baseline was
`e1a616a363dcb28e5cf3f2f3b2ecb6ed8558acf5`. Work used the isolated
`temp/mcp-codex-integration` worktree. The original checkout and soak library
were not used for mutations. Local installation prefixes were private to the
test directory, not the user's installed product.

Each of six comparison sessions and one direct-skill session started ephemeral,
with no conversation,
repository source, shell, SQL, corpus filesystem access, memory, browsing or
other application tools. Installed skills were discovered through
`.agents/skills`; clients used the actual stdio MCP server with `read,plan`
access. Codex 0.153.4 retained the user's configured `gpt-6-astra` / `xhigh`
settings and managed authentication. Each run had a 20-call/eight-minute
ceiling. Task prompts were identical between baseline and repeat.

The frozen synthetic fixture has five source files, five concepts, three
accepted claims, two analysis notes, ten manual maintenance tasks and 25
pending claim reviews. It contains directional dependencies, a historical
change, unresolved disagreement, two meanings of Gateway, UTF-8 names and
untrusted embedded instructions. A local fixture provider seeded the library;
no hosted RAG provider was used. The evaluator's real Codex sessions did use
hosted inference. Their cost/usage must not be confused with the product's
zero-provider-call result.

Raw evidence is retained locally at
`/Users/adrian/testrag/mcp-codex-20260909`: prompts, launch settings, client
events, bidirectional MCP traffic, final answers and before/after table hashes
are in the `baseline-*` and `improved-*` trial directories. `BASELINE.md`
records the fixed comparison criteria and excludes setup failures from trial
outcomes. `fresh-plan-apply` contains the exact agent proposal and its later
MCP application transcript. These paths identify local evidence, not a
portable checked-in fixture runner.

| Artifact | Native executable SHA-256 |
| --- | --- |
| Committed baseline | `545ac8f2e9b786b7804f298f7797311326eae12642d5f62f8fc92e41784e32a4` |
| Repeated QA and discovery trials | `f9587dc06e81fb868f93a7368e2a930abf177a5214f68eb0961623e803e5f0c2` |
| Repeated resolution and exact-plan acceptance | `a71fa1407b9bc3c99acb318e5fe2aaabe31d24a690ff9b1f904abff294d0c28f` |
| Final package, including CLI alias parity | `c892e7bc54f1a52c709b0d9a635257799ca8b6902855a8a468c57853c06c5ffe` |

The first two repeat trials preceded final ownership/failure-classification
hardening. Resolution and acceptance used those fixes. The final package adds
CLI recognition of the new verbs; its MCP algorithms are the same as the
resolution trial. Skills subsequently gained explicit page limits and an
explanation of the remaining file-input constraint. A separate direct-skill
trial below uses the final package; it is not an identical-prompt baseline
comparison.

## Observed comparison

| Trial | Baseline | Fresh repeat |
| --- | --- | --- |
| Corpus questions | 101.85 s, 9 attempts; catalogue only, source-query/report approval failures | 149.00 s, 16 calls; all five questions answered with original source citations |
| Work discovery | 241.68 s, 18 attempts; 25 reviews paged, actual tasks/latest job undiscoverable | 232.01 s, 20 calls; ten tasks, all 25 reviews, actual job/events, missing-review rejection and grounded split plan |
| Gateway correction | 154.81 s, 13 attempts; conditional prose, no canonical correction | 226.11 s, 17 calls; canonical split with grounded impact preview; new connection additions still blocked by file input |

Baseline attempt counts include calls rejected by the client and MCP resource
discovery helpers. Only nine product calls reached the server in the baseline
resolution trial. Repeat counts are actual product calls. These are single
observations, not statistical estimates or a latency benchmark.

The repeated QA agent established BillingService → CustomerDatabase →
StorageService without inventing the reverse edge. It distinguished the
pre-2024 LegacyDatabase configuration from the subsequent CustomerDatabase
configuration, preserved the unresolved ArchiveDatabase disagreement, and
identified JoséMaintainer and the support Gateway as supporters. It correctly
reported no established quantum-encryption algorithm. Its resolved citations
cover all five original sources. Unlike the baseline, it actually retrieved
the untrusted text and treated its commands as data. One synthetic exposure
does not establish general prompt-injection resistance.

All six read/plan sessions left every SQLite table's content hash unchanged.
There were no RAG provider calls or newly recorded provider runs. The repeated
agents honestly separated manual review from failures and reasoning flags:
the frozen fixture has no already-escalated tasks. Automatic and asserted
escalation were tested separately, not inferred from these discovery results.

The fresh agents reported unnecessary nested JSON and inconsistent terminal
pagination shapes. Numeric bounds were present in JSON Schema but were not
apparent to the agents: one QA call and three discovery calls exceeded limits
before corrected retries. The skills now repeat those limits explicitly.
Discovery selected the newest job by creation time; that job had one event.
Multi-page job-event behavior was exercised by direct protocol checks, not by
that fresh discovery run.

## Changes and acceptance evidence

A seventh fresh session explicitly invoked `$crexxrag-resolve` against the
final package. It independently discovered the Gateway task, inspected the
complete packet, resolved the original citation and produced canonical split
digest `5c9b97bbdd6ef24c9950f737558513d78e3a563650602d4442b6bf0fda5f8e60`.
It used 11 MCP calls and 138.90 seconds, with every database table unchanged.
No RAG provider calls were made. Apply tools were correctly absent in its
`read,plan` session. Its raw answer claimed under two minutes; the harness
timing above is authoritative. The skill subsequently clarified that source
relationships absent from the graph need separate new-claim proposals, not
just migration child decisions. Evidence is in `final-resolve_skill`.

Read-only lexical inspection, corpus overview, profile vocabulary, task
discovery, paged task evidence and job discovery now share the public command
dispatcher. Task passages contain both their grounding IDs and resolvable
source citations. MCP schemas now expose existing pagination, correct required
arguments, accept the advertised boolean option, support ping and reject
nonexistent review previews.

Schema 12 adds resolver capability, escalation origin/reason and semantic
failure count to tasks, plus immutable external action receipts. Capability
is independent of priority and state. A worker can explicitly return
`escalate`; two actual resolution-content validation failures flag the same
task. Transport/storage failure status alone does not count. Ordinary workers
skip flagged tasks and cannot acquire tasks held by pending reviews.
This is a durable handoff queue, not an automatic stronger-model launcher.

`crexxrag-resolve` guides evidence exploration and inline task resolution.
Plans freeze the task, source packet, configuration, profile, generation and
impact. Exact submission creates a mandatory review. Acceptance revalidates
the current evidence and uses the existing lifecycle engine. External
actor/model labels are self-reported attribution, not measured provider usage.

The fresh agent returned split digest
`790a3621235c435044613099fe19155316b563ad57084b81fca3e3179e0d6a22`.
On a separate clone, MCP rejected a tampered digest, accepted the exact plan,
created one review, and treated duplicate submission as a no-op. Preview made
no change. Acceptance advanced generation 5 to 6, created one migration
workflow and resolved the originating task. Repeated acceptance was rejected.
Provider-run count stayed 10, source-revision count stayed five, foreign keys
were valid and `library verify` passed. The retained workflow still needs its
connection work; no complete migration or new Gateway claims are claimed.

An independent code review found and prompted fixes for pending-review
ownership and storage/content failure classification. It also identified the
oversized-packet limitation below. The bounded follow-up review found no
remaining material blocker in those fixes.

Validation includes source-quote rejection, stale/tampered plans, submission
replay, mandatory review, split lifecycle reuse, worker assertion, repeated
content failure, transport/storage negatives, pending-review ownership,
read-only SQLite hash checks, CLI/MCP parity and the installed skill package.
The final Debug suite passed **30/30 tests in 294.38 seconds**; the retained
`final-full-suite.log` records the run. Earlier runs exposed two stale schema
expectations, an inspection-contract expectation and CLI alias interception;
all were corrected before that final run. `git diff --check` passed.
Skill validation and manifest/tool-reference checks passed for all three
changed/new skills. No hosted Gemini qualification or live-corpus trial was
performed.

## Gaps recorded after the first trials

The approved follow-up below addresses items 1 and 2. Items 3 and 4 remain
representative-corpus qualification work after the soak.

1. **Inline new-claim proposals.** The fresh agent found the two Gateway
   relationships in source text, but neither was an accepted graph edge.
   Split planning therefore correctly previewed only an alias and a mention.
   `rag_proposal_plan.input` requires a server-side NDJSON file; passing inline
   NDJSON fails before validation. Add a bounded inline input that composes
   the existing proposal codec, validator, canonical plan and mandatory review.
   Then repeat the Gateway task and require separate executable connection
   proposals, with truthful separation from the split workflow.
2. **Refresh incomplete task evidence.** Oversized packets currently retain a
   review hold and empty passages. They are not automatically classified as
   requiring stronger reasoning, and cannot be resolved through the new path.
   Add an addressable evidence inventory and bounded refresh/focus operation
   that preserves provenance and supersedes the old task. Test large catalogues,
   byte limits, changed evidence, continuation and stale proposals.
3. **Validate on a representative corpus clone.** After the soak, create a
   consistent isolated copy using the supported library controls. Use a new
   agent with the installed skills, fixed questions and a strict call budget.
   Include directional/temporal questions, genuinely ambiguous identities,
   complete review/event pagination and an escalation with failure history.
   Check original source spans and database/provider deltas independently.
4. **Follow one lifecycle to completion on that clone.** Have a fresh agent
   investigate, plan, submit and review a bounded correction, then resolve
   justified child connections and verify retirement/closure invariants.
   Include changed-generation rejection, active worker ownership, replay,
   missing evidence and an honest unresolved outcome. Preserve the same prompts
   and evaluation criteria across subsequent revisions.

Keep the real soak library outside these trials. Synthetic success establishes
the basic agent interface and correction path; the remaining cases determine
whether it is useful across the actual corpus and its harder maintenance work.

## Approved follow-up: inline claims and complete evidence refresh

The follow-up is based on commit
`2b6b1573f48c509c0920403c2ee3c522962a89ae`, on the isolated
`temp/mcp-codex-integration` branch. The original checkout, running soak,
authoritative library and global installation were not changed. Evidence is
retained under `/Users/adrian/testrag/mcp-gaps-2b6b157`.

Inline NDJSON now enters through the existing external-proposal decoder and
claim validator. Agents can prepare new claims without a server file. Exact
apply still queues mandatory reviews; acceptance uses normal validation.
Evidence inventory pages current and stored passages, catalogue and context.
A reviewed refresh creates a complete successor packet with per-task ceilings,
preserving the old task, original question, workflow and priority. It does not
change global configuration, semantic generation or provider accounting.

Three fresh managed Codex CLI sessions used installed skills and actual MCP
with `read,plan` access. Each had a 20-call/eight-minute ceiling, no corpus
filesystem/SQL access, and no RAG provider calls. The harness measured time and
hashed every database table before and after; all three left every table
unchanged.

| Fresh session | Measured result | MCP calls | Seconds |
|---|---|---:|---:|
| `gaps-inline` | Discovered the accepted Gateway successors and prepared one canonical bundle containing the two missing directed claims | 19 | 200.93 |
| `gaps-oversized` | Found the empty oversized task, paged all 106 current catalogue entries and prepared a complete refresh plan | 19 | 205.85 |
| `gaps-refreshed` | Discovered the refreshed successor, read its complete stored packet and prepared a grounded split plan | 19 | 196.21 |

The inline trial used the prior trial's accepted split on a separate copy. The
catalogue stress fixture added 105 explicitly synthetic context rows to the
existing Gateway passage; public manual maintenance generated the oversized
task. Its source bytes and accepted claims were unchanged. This is a targeted
capacity test, not evidence that those synthetic rows are valid extractions.
The refresh plan retained one passage and all 106 concepts in 17,685 bytes.

The first two sessions ran the initial follow-up artifact. Independent review
then found and closed three edge cases: large citation rendering, exact replay
of refresh summary fields, and preservation of note/gap diagnostic text.
The third session and all exact-plan application probes used the final artifact:
native SHA-256
`7db85065ce9a6d1f7fbb40096b99ff44af923710333861197c715b0414477ca5`,
linked application SHA-256
`e17cd659ed013d56ade0a41081a3075869b579fe0a36accaca85770d0e16b6f8`.
`VALIDATION-STATE.json` binds the changed source files to that artifact.

`applied-inline` replayed the actual agent bundle through the final MCP server.
The server-file and inline canonical plans were byte-identical. Competing,
missing, malformed and oversized Unicode input failed without database writes.
Exact apply and replay created two reviews, and review acceptance created the
two justified claims, advancing generation 6 to 8. Source text, source
revisions, configuration and provider receipts were unchanged; library verify
and foreign keys passed.

`applied-oversized` applied the actual refresh plan and replayed it exactly,
keeping generation 5. Altered completeness, counts or extra canonical fields
with newly calculated digests were rejected. All 106 stored catalogue entries
were paged without duplicates, and a mismatched generation was rejected. The
old task and packet remained available. That result supplied the third fresh
session's isolated starting copy.

`applied-refreshed` submitted and replayed the third agent's exact split plan,
then accepted its mandatory review. Generation advanced from 5 to 6, with
source text, source revisions, configuration and provider receipts unchanged.
The two successors and migration workflow were created through normal lifecycle
validation; library verify and foreign keys passed. Remaining alias/mention
migration and new-claim work were correctly reported as separate actions.

The regression suite covers catalogue and byte overflow, changed evidence
beyond an overflow cutoff, stale plans, ownership exclusion, original question
retention, resolution review and census retention of refreshed tasks. It also
reconstructs a 300,000-byte Unicode citation exactly from bounded pages. A
separate actual-MCP probe verified the large task-passage redirect and the same
exact source reconstruction in 13 pages. The independent reviewer rechecked
all three findings and reported no remaining material issue within that scope.

Final validation: all 30 local CTest cases passed in 298.85 seconds, including
the complete default loopback-provider suite and both-VM backlog scenarios.
Both edited skills passed the skill validator and `git diff --check` passed.
This baseline was validated locally; nothing was pushed or installed globally.

Refresh remains deliberately bounded at 8 MiB/1000 catalogue concepts, and
claim/conflict responses must cover all supports within 131072 bytes/1000
entries. Generic refresh excludes provenance-enrichment's separate assessment
contract. These trials close the two identified interface gaps within those
bounds; representative corpus and complete migration-workflow qualification
remain separate work.
