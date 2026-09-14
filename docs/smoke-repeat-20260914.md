# Tests 1–4 repeat — 14 September 2026

The requested baseline was committed first as **`0a85f9d5f7b2db5acd6699444c70b813b9b2fb4d`**
on `main`. All four tests were rerun. Tests 1 and 3 passed; Test 2 required
publication recovery after a controller failure, and Test 4 repaired one of
its two selected holds. This is not an all-green smoke result.

| Test | Result | Execution and usage |
| --- | --- | --- |
| 1 — five missing embeddings | **Pass.** All five repaired; automatic publication and verification passed. Original failed-attempt histories unchanged. | 27.65 s; five Gemini calls; $0.000208; no reasoning calls |
| 2 — new Bannockburn document | **Controller failure; data recovered.** All four items processed, but a worker stream timeout prevented automatic publication. Public vector rebuild recovered it with zero calls. Retrieval, citation and repeat-import checks passed. | Initial run 47.43 s, exit 8; two Gemini calls and four Codex turns, including two successful corrections; $0.000049 |
| 3 — bounded maintenance | **Operational pass.** Four validated decisions: two resolved and two unresolved. Two other items skipped as stale; two remained pending after cancellation at the allowance limit. | Plan 0.19 s, apply 0.54 s, run 51.01 s; four successful Codex turns; no Gemini or monetary API cost |
| 4 — extraction holds and operational redo | **Partial.** Fiers repaired; Nairn's initial and correction responses both failed grounding. Known RAG-SMK-010 reproduced; temporary configuration workaround required. | Fiers 36.87 s / one turn; Nairn 101.21 s / two turns; enclosing interval 249 s; no Gemini or monetary API cost |

All new work used a fresh disposable library restored from the retained
pre-Test-1 backup. It therefore really began with five missing embeddings and
without the Bannockburn source, rather than testing no-ops on the repaired copy.
The master and permanent ScottishHistory libraries were untouched. No installed
executable, product source or persisted operator policy outside the disposable
copy changed during these tests. No push occurred.

## Artifact and bounds

- Native SHA-256: `4b5937a14302b4f1e8f121c0de78e60992a30db15f6157673e27fdf2db3baba5`.
- Frozen installation: `/private/tmp/crexxrag-smoke-repeat-20260914-718axbnf/artifact`.
- Library: `/private/tmp/crexxrag-smoke-repeat-20260914-718axbnf/library`.
- Backup: `/Users/adrian/testrag/overnight-scottish-20260909/test1-embeddings-20260913/before-backup`.
- Public restore succeeded; public migration brought the new copy to schema 18.
- Installed CREXX: `crexx-1.0.0-beta.3+local.g037e7939bc29`.

The user's new instruction to rerun Tests 1–4 authorized this repeat of their
documented bounded scopes. Test 1 selected exactly the same five public-history
occurrences, only `gemini-embedding-2`, five calls and $0.005 maximum in a fresh
five-minute window. Test 2 used the same 952-byte public Bannockburn excerpt.
Tests 2 and 3 retained eight items/calls maximum, at most four managed
`gpt-5.6-luna` turns, $0.005 monetary cost and two workers per five-minute stage.
Test 4 selected only the original Fiers and Nairn operational holds and stopped
after three combined turns. Its interval was **06:39:50–06:43:59 UTC**.
No historical window was renewed or unfinished broad ingestion restarted.

## RAG-SMK-011 — completed work loses publication after worker failure

Test 2's job processed all four items and had no queued, running, dead-letter,
uncertain or unsettled items. Both extraction responses needed the normal
correction turn, and both corrected responses passed. The worker with PID 59367
then exited 75 with:

```text
Codex App Server stdout failed: byte operation deadline exceeded;processed=3;polls=3
```

The other worker stopped cleanly. The controller recorded `failed` and public
`job run` returned exit 8. The library manifest was aligned but had no published
sidecar; integrity verification alone did not establish vector coverage.

The product control flow explains the missing publication: `ragprocess` returns
failure when any child failed, and `ragproduct._workerstart` returns immediately
on that status, before `_publishjobvectors`, without considering that the
selected job has already completed. The precise cause of the App Server byte
timeout is not established by this smoke. A terminal job cannot simply be run
again through the current `job run` preflight.

Public `vector rebuild --reconcile` published **34,907 rows** with zero provider
calls. It also reconciled ten already-covered historical embedding items.
The completed source, source bytes and provider receipts were preserved.
Reimport returned `identical-no-op`, and the new battle citation resolved to
the exact original UTF-8 bytes **502–951**.

**P1 repair needed:** complete publication for a drained, completed job even
when a worker exits unsuccessfully, while retaining the failed worker's history
and truthful health information. Add a regression for that exact completion/
failure ordering and preserve the guard against publishing unsettled work.
Investigate avoidable provider preflight after eligible work is exhausted.
No product repair is claimed here.

## Test 4 content and replay findings

The 14 retained representative inputs and their events are unchanged. Rebuilding
the diagnostic from the existing cREXX grounding owner reproduced all **122**
previous quotation/label outcomes. The four existing correction drafts also
retain **45/45** passing grounding checks. They remain unpublished; those checks
do not establish full provider/catalogue validation or resolve their holds.

RAG-SMK-010 still rejects Fiers replay under the configuration containing the
unrelated Bannockburn source. As in the prior smoke, public configuration
plan/apply temporarily selected the original source scope, then restored
`config-a211c0fede4237fe77bbc797` after both replays stopped. This remains a
workaround, not a compatibility fix.

Fiers completed and resolved its original hold. Nairn completed with one dead
letter after two rejected responses. Both contain the same invalid relationship:
the source label is **“the duke’s advanced guard”**, but its quotation names
**“the duke’s cavalry”** and **“the French horse”**. The quotation is present in
the source; the required first endpoint is absent. The current grounding owner
independently reproduced this failure in both responses. Correct the endpoint
and supporting span, or omit the unsupported relationship, before another
submission. Do not remove the grounding check to make this result pass.

The original ingestion now has **544 actionable extraction roots and one
resolved root**. Its original item/attempt history remains unchanged; replay
lineage carries the new outcomes. No waiver or manual claim publication occurred.

## Ordinary MCP Q&A and performance

The rebuilt MCP server completed **21 JSON-RPC requests**, including discovery,
status, inventory, ten searches, following a returned lead and citation reads.
No `rag_query_answer`, query embedding or other cREXX-RAG provider call was used.
The current assistant composed the retained [cited answer](qa/smoke-repeat-20260914/assistant-answer.md)
from inspected evidence and an independently resolved source span.

| Operation | Time |
| --- | ---: |
| Ten evidence searches, median | 0.477 s |
| Follow returned Alaster Macdonald/Dundee lead | 0.514 s |
| Full Bannockburn evidence, twelve passages | 0.492 s |
| Citation resolution | 0.008–0.012 s |
| Source listing | 0.014 s |
| Full library overview | 9.547 s |

These are measured samples, not guarantees or the outer assistant's full answer
time. The full overview remains expensive. The battle excerpt again ranks
fourth, so shrinking to three passages would discard the needed evidence.
The previously identified setup, lexical-vector preparation and ranking work
remains outstanding.

## Final integrity and evidence

Public verification passed at **schema 18, generation 24,928**, with an aligned
manifest and zero repository issues. The copy has nine sources, 34,907 chunks,
7,974 claims and complete 34,907-chunk embedding coverage. All eight original
source/revision identities are preserved.

The ledger increased exactly **82,544 → 82,562**: seven Gemini embedding calls
and eleven managed Codex turns. Total monetary API cost was **$0.000257**, plus
subscription usage. All 18 new runs are accounted for by the five test jobs;
the MCP checks added none. All test controllers and workers have stopped, with
no uncertain or unsettled work in these jobs. The failed Test 2 controller
remains recorded as failed.

See [retained evidence](qa/smoke-repeat-20260914/README.md), including original
failures, recovery, terminal accounting, grounding outcomes and timings. These
are follow-up results after the requested baseline commit. The prior 70/70
product suite and 2/2 guidance checks remain their stated qualification scopes;
no new full-suite or hosted cross-platform qualification is claimed.
