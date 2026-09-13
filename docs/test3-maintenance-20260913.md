# Test 3: bounded maintenance smoke — 13 September 2026

The operational smoke passed: **62 seconds, exit 0**, with four managed Codex
turns, three accepted resolutions and one correctly rejected split proposal.
The whole selected batch is not resolved. Slow preparation remains a finding:
a literal five-minute plan does not leave enough time for this corpus's plan
and apply stages. No product code or installed configuration was changed.

## Scope and execution

The user requested Test 3 from the agreed sequence: a small maintenance batch
on the disposable corpus, checking supported decisions, preserved uncertainty,
history/citations, bounded usage and worker shutdown. The same baseline
`ab620e5f303696ba477d6b91845f075789b779c9` and scratch-installed native executable
from Test 2 were used. Its full product QA was 69/69; no rebuild was needed.

The selected policy retained two workers, eight items, eight model calls,
four managed Codex turns and a $0.005 monetary API ceiling. Actual worker
execution was capped at five minutes. A 15-minute plan deadline accommodated
provider-free preparation; actual execution was **16:27:29–16:28:31 UTC**.
It stopped normally at the four-turn allowance, without a manual stop or renewal.

Plan preview listed eight analysis notes. Automatic dispatch then prioritised
existing durable work: seven concept-classification questions and one alias
question. The actual tasks were inspected before execution: Ogilvie, Iter,
Comgal, Borodale, Dunrobin castle, Rothiemay, Welsh and Celtic. Their 22 passages
map to five public historical books. The plan explicitly covers the durable
backlog and follow-up tasks within its shared budgets; its preview is not the
final dispatched list.

Automatic approval review initially rejected launch because it classified the
context as internal data. A read-only payload check mapped every passage to the
public source books and identified the derived historical catalogue context.
The same launch was accepted with that evidence. The rejected launch made no
calls; no credential was extracted and no alternative execution route was used.

## Results

| Check | Result |
| --- | --- |
| Accepted work | **3 retained/resolved**: Iter, Ogilvie and Comgal |
| Rejected work | **1 failed task**, Borodale; proposed split was not applied |
| Other selected tasks | **3 pending**, with zero provider calls; **1 superseded** alias task skipped as stale evidence |
| Item accounting | 3 processed, 1 skipped, 4 cancelled at window closure; cancellation does not mean all four tasks succeeded |
| Window and job | Window `budget-exhausted`; job `completed`; zero queued/running/unsettled items |
| Calls and usage | **4 `gpt-5.6-luna` turns**, 78,573 input tokens, 2,007 output tokens, 53,023 aggregate provider milliseconds |
| Charging | Subscription allowance; **zero Gemini calls** and zero monetary API cost |
| Publication | Automatic `identical-no-op`; unchanged vectors cover **34,907/34,907** chunks |
| Library verification | Generation **24,928**, aligned manifest, zero storage/repository issues |
| Source preservation | Source revisions unchanged; 9 sources, 34,907 chunks and 7,969 claims retained |
| Citation | Test 2's resolved source citation remains identical |
| Workers | Two completed, zero failed/restarted; controller and workers confirmed stopped |

There were 41 local attempt records: four provider calls, one stale-evidence
skip and 36 uncalled budget deferrals while the final call settled. The three
unstarted tasks remain pending with no charged call or used provider attempt.
This polling creates avoidable history noise but did not exceed the budget.

The provider ledger records three succeeded runs and one failed validation.
The rejected provider response and its usage receipt remain in job events.
The product requested a citation correction, but the exhausted four-turn
allowance prevented another call. No retry, waiver or data repair was performed.
The failed task remains inspectable; it is not counted as completed content.

## Grounding result

All six accepted evidence spans map to contiguous source bytes and overlap the
selected mentions. Three provider quotations used the existing matcher's
case/ASCII-whitespace tolerance; stored grounding still points to the original
source text. The independent check follows that existing contract rather than
requiring provider strings themselves to be byte-identical.

Borodale's second quotation is present in its paragraph, after supported
whitespace normalization, at bytes **322–490**. It cites a different selected
mention at bytes **68–76**. The remaining three quotations overlap their selected
mentions, but this one does not. The validator correctly rejected the complete
split; no decision or split workflow was applied to the concept. The test does
not establish whether a corrected split proposal would be substantively valid.

## Preparation finding

The initial five-minute plan took **167 seconds** to prepare without writes or
calls. Its clock started before the census. Apply also rebuilds the census, so
that plan was not applied with insufficient remaining execution time.

A fresh `maintain plan --minutes 15` took **160 seconds**. Applying that exact
reviewed plan took **218 seconds**, still with zero calls. Only after inspecting
the dispatched tasks did the 62-second worker run begin. Thus this qualifies
the bounded live maintenance operation with preparation allowance, not the
unmodified five-minute end-to-end launch experience.

The owning paths are `_maintainplan`, `_maintainapply` and `_preparemaintenance`
in `ragproduct`, with census construction in `ragmaintain`. A future repair
should address repeated preparation and when a relative duration starts, while
preserving explicit absolute deadlines. No timing guard was removed for this test.

## Identities and evidence

- Library: `/private/tmp/crexxrag-smk006-V6YatF/smoke-library`
- Policy: `/private/tmp/crexxrag-smk006-V6YatF/test2.conf`, unchanged from Test 2
- Policy SHA-256: `0541ed3efa5cfc78f07e39ea3e9fed50fb5547d1e5b82e8214fc92956be15dcb`
- Job: `job-maintenance:81783cb8c58537318d1efdea1e45d2f987c0f8c91a77348d9ed65ddca0eb3510`
- Plan digest: `81783cb8c58537318d1efdea1e45d2f987c0f8c91a77348d9ed65ddca0eb3510`
- Executable: `/private/tmp/crexxrag-simplify-20260913/installed/bin/crexxrag`
- Native SHA-256: `751e3ca283c036f524feee93d5eb6b7565ec424bd4cd18fce038bc419fae0da3`

[Acceptance](qa/test3-maintenance-20260913/acceptance.json),
[accounting](qa/test3-maintenance-20260913/accounting.json),
[rejected quotation check](qa/test3-maintenance-20260913/rejected-grounding-check.json),
[verification](qa/test3-maintenance-20260913/verify.json) and the complete
[retained evidence](qa/test3-maintenance-20260913/) record the result.

The master corpus, permanent query copy and normal installation were untouched.
No commit or push occurred in Test 3. These results and the handoff remain
uncommitted alongside Test 2's documentation. No further hosted work is running.
