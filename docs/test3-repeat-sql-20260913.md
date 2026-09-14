# Test 3 repeat after SQL repair — 13 September 2026

**Passed.** The installed repair prepares maintenance in **0.913 seconds** and
completes its bounded execution in **55 seconds**. This closes the earlier
six-minute-eighteen-second preparation finding for this eight-item corpus smoke.
It does not measure an exhaustive whole-corpus maintenance run.

## Build and scope

- Local `main`: `7febbca54fefa33ec90cc775f1b9ab01045fcad9`.
- Installed using `cmake --build --preset debug --target install-local`, exit 0.
- Installed native SHA-256: `e3967d87a24df035fa43373719bc5ed611592c7cf49433326dca85115cc762ab`.
- The qualified product/build/test inputs remained unchanged from the 70/70 acceptance.
- Disposable library: `/private/tmp/crexxrag-test3-repeat-tadMRjFu/library`.
- Source backup: `/private/tmp/crexxrag-smk006-V6YatF/smoke-library`, copied through public `library backup`.
- Unchanged configuration: `/private/tmp/crexxrag-smk006-V6YatF/test2.conf`, SHA-256 `0541ed3efa5cfc78f07e39ea3e9fed50fb5547d1e5b82e8214fc92956be15dcb`.
- Job: `job-maintenance:cfcba0821170d7acdab3fd8645b0787a753d409d6cb1146a1a887ae18d34ed00`.

The user approved installation and one fresh five-minute smoke: eight items,
eight model calls maximum, four managed Codex turns maximum, $0.005 monetary
API maximum and the configured two workers. Inputs were public historical
passages and their derived catalogue context. No window was renewed.

## Timing and terminal result

| Stage | Result |
| --- | --- |
| `maintain plan --minutes 5` | 0.207435 seconds; selection deferred to the durable owner |
| `maintain apply` | 0.705448 seconds; eight items; full 300 seconds from activation |
| `job run` | 20:12:53–20:13:48 UTC; 55 seconds; exit 0 |
| Final job/window | completed / budget-exhausted at four Codex turns |
| Items | four processed, four cancelled, zero queued/running/dead letters |
| Workers | two completed, zero failed, one automatic replacement; controller stopped |
| Calls | four successful `codex-extract` / `gpt-5.6-luna`; zero Gemini |
| Recorded usage | 75,960 input tokens, 1,654 output tokens; $0 monetary API cost |
| Uncertainty | zero uncertain, unsettled or incomplete-usage items in this job |

One worker encountered `Codex App Server response timed out` after processing
one item. The controller replaced it successfully. No additional provider run
was recorded for that preflight failure. This is a recovered provider transport
event, separate from the repaired SQL preparation path. The history also retains
38 cancelled `provider-deferred` attempts; these were uncalled deferrals, not
38 model failures. Four attempts succeeded with validated maintenance decisions.

## Retained decisions

| Subject | Result | Generation |
| --- | --- | --- |
| Rothiemay | Retain existing person classification; resolved | 24,929 |
| Dunrobin castle | Retain existing place classification; resolved | 24,930 |
| COLLECTION OF GAELIC POETRY | Reuse existing artefact identity; resolved | 24,931 |
| Welsh | Unresolved: the selected passage does not establish a confident classification change | unchanged |

All four responses passed normal cREXX validation and retain their response and
grounding spans. Four processed items therefore mean **three resolved tasks and
one valid unresolved decision**. Spalding, Campbell of Argyll, HISTORY OF THE
HIGHLAND CLANS. and the Chevalier were unstarted; their durable tasks remain pending.

## Preservation and evidence

Public `library verify` passes at schema 18, generation 24,931: aligned manifest
and zero storage/repository issues. Source revisions, nine sources, 34,907 chunks
and 7,969 claims are unchanged. Published vectors retain 34,907 rows, and the
complete Test 2 citation response is identical. Provider runs increased exactly
82,557 → 82,561. Only the disposable copy was mutated.

[Evidence](qa/test3-repeat-sql-20260913/README.md) retains installation, plan,
activation, terminal status, decisions, usage and preservation checks. The
earlier full 70/70 suite remains the product acceptance; it was not rerun for
these smoke-only documentation changes. No push or new commit occurred.

Next completed action: [Test 4 extraction-hold inspection](test4-extraction-holds-20260913.md).
