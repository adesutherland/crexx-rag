# Test 4 continuation — 13 September 2026

**Two operational holds repaired.** The approved small redo processed the Fiers
preflight-timeout item and the Nairn interrupted-turn item. Three managed Codex
turns were used, with **$0 monetary API cost** and zero Gemini calls. The Nairn
response needed the existing citation-correction turn before validation passed.

The two one-item replays ran sequentially using the configured two workers.
They took 35.59 and 85.25 seconds respectively, both exit 0, with no failed or
restarted workers. The entire launch/inspection interval was **20:40:17–20:43:20
UTC (183 seconds)**, within the approved five minutes. No further run followed.
Although each replay has its ordinary configured budget, this smoke stopped
after these two items and three calls, below the combined four-turn ceiling.

## Outcome and preservation

| Item | Original failure | Replay job | Result |
| --- | --- | --- | --- |
| Fiers passage | Codex allowance preflight timeout | `job-replay-sha256:a788c04a86a652c09d457181735490b663129ca5e4cadef94a16e69b9af4eb19` | One call; processed |
| Nairn passage | Confirmed Codex turn interrupted | `job-replay-sha256:b9f47a756ef090ffb56c2539221acf0c4f2c638cc34585b1149c98ef17cd62bf` | Two calls; processed after correction |

Generation advanced **24,931 → 24,933**, retaining 20 new mentions and two new
claims: the river related to the fall of Fiers, and the duke's advanced guard
having the Argyleshire men as members. Both have addressable source support.
The provider ledger grew **82,561 → 82,564**, recording 57,911 input tokens and
3,396 output tokens. The first Nairn response remains a failed validation
attempt; its corrected response is the successful one.

The original job and its dead-letter items remain immutable. Reconciliation now
shows **543 actionable extraction roots and two resolved**: the remaining
actionable roots comprise the original 521 content holds and 22 operational
holds. Public verification passes at schema 18, generation 24,933, with zero
storage/repository issues. Nine sources, 34,907 chunks, source revisions and
the published vector sidecar remain intact. Both jobs have no uncertain or
unsettled work and their controllers are stopped.

## RAG-SMK-010 — unrelated source addition blocks old-item replay (open)

The installed `7febbca` executable first rejected the Fiers replay with exit 6:
`replay target is not semantically compatible with the source job`. No job or
provider call was created by that rejection.

`ragwork.replaydeadletters` compares the whole source and target semantic hashes.
The target includes Test 2's additional `smoke-bannockburn` source set. Existing
source definitions, selected model, prompts and profile are unchanged; the
other differences are operational budgets, worker count and Gemini retry policy.
The old and current semantic hashes are respectively
`28d4fb3cbed506e445e25fa220e62aa51ad8144d59c97733f5f6e0122d0d75ca` and
`c04af19b25a23f985cddbc918b3090b7c54ada69acff5f6704980fd72e487a0b`.

For this smoke, a temporary configuration omitted only the additional source
set and retained the current small budgets. Public `config plan/apply` in the
disposable copy selected snapshot `config-bbac47eed961d56bd65c0a8d`, whose
semantic hash exactly matches the original job. The same explicit replay then
succeeded. After the two jobs drained, public configuration commands restored
**`config-a211c0fede4237fe77bbc797`**. The original policy file, master library
and permanent query copy were untouched. This is a demonstrated workaround,
not a product repair or a recommended permanent operator procedure.

The narrow repair should let explicitly selected old items replay when their
source/provider/profile/interpretation remains compatible despite an unrelated
new source set. Put compatibility in its shared configuration owner and retain
current-target, immutable-lineage, completed-work and uncertainty protections.
Regression coverage currently exercises compatible/stale targets and replay
lineage; it lacks this additive-source case. Add that failing acceptance and
meaningful source/privacy/profile-change controls before implementation. Do not
duplicate semantic-field rules in the command adapter or change stored hashes.

## Content correction drafts

Four complete replacement-response drafts are retained in
[content-drafts](qa/test4-operational-redo-20260913/content-drafts/README.md):

- Mackay: keep the supported pursuit relationship; remove unsupported links.
- Drummond: preserve the literal hyphenated OCR label and separate canonical label.
- Somerled: remove invented punctuation and correct the event/participant direction.
- Mar: replace the stitched note quotation with one continuous passage covering the note.

All **45 quotation/label cases pass the existing cREXX grounding owner**. Array
and endpoint bounds were also checked. These are preparation artifacts, not
accepted claims or a claim that the complete provider/catalogue contract passed.
No review was queued or content hold marked complete. The inspected historical
Mackay item has no object directly addressable by `maintain inspect ITEM_ID`;
its frozen input and retained response remain available for a proper proposal.

A separate draft patch removes the bare `Breadalbane` organisation alias. The
global glossary was not changed. Review the geographic occurrence and catalogue
identity before applying any glossary transition or publishing corrected claims.

[Retained evidence](qa/test4-operational-redo-20260913/README.md) includes the
initial rejection, temporary/restored configuration plans, terminal runs,
accounting, lineage, verification and draft checks. Product code and installation
remain unchanged; these are uncommitted smoke documents. Next engineering work
is the narrow RAG-SMK-010 regression and repair, alongside review of these drafts.
