# Scottish corpus development and graph evaluation

This preserves the acquisition and evaluation proposal at its recorded date.
For implemented metadata defaults, use [the current time and provenance
contract](time-and-provenance.md); later source additions do not rewrite the
baseline comparisons below.

Recorded 8 September 2026. This is a research and acquisition plan, not a claim
that the additional works have been ingested or that the proposed metadata is
implemented. Keltie's two volumes remain the experimental corpus. The supplied
source proposal is retained verbatim at
`/Users/adrian/testrag/corpus-development-20260908/user-source-proposal.md`, with
its attachment path and SHA-256 in `proposal-provenance.json` beside it.

## Priority and purpose

The next priority is to measure what the graph contributes and introduce one
carefully chosen source. Another undirected maintenance run has less immediate
research value: the latest two-hour run increased claims from 1,314 to 1,650,
but 70 of 72 initial passages were shared in the six-question before/after test,
with no demonstrated improvement in answer completeness. This is a small test,
not proof that the remaining backlog is worthless. Integrity, missing embeddings
and reproducible query failures still take priority over enrichment.

Treat Keltie as one point in a history of competing accounts. Earlier
observations, antiquarian reconstruction, literary invention, official testimony
and later criticism can address the same people and places for different
purposes. Chronology should help us investigate changing interpretation; it
should not impose a progression in which each newer source is automatically
more truthful.

**Browne is the preferred first addition.** The prospectus already stored in
Keltie volume I explicitly identifies Browne as its basis and advertises major
rewriting. [Wellcome's catalogue](https://wellcomecollection.org/works/emyravt6)
lists the 1836–1838 work, four online volumes, with a Public Domain Mark.
This supports a focused experiment in retention, revision and source dependence.
Agreement between Browne and Keltie must not be counted as two independent
confirmations. A shared passage alone does not establish the direction of copying.

The Old and New Statistical Accounts are the next priority for a different
kind of evidence. Edinburgh describes parish reports from 1791–1799 and
1834–1845 on social and economic conditions, including language use.
Start with a declared set of complete, matched parish accounts, selected for
overlap with Keltie and document quality before seeing graph results. Match
boundaries and reporting periods, not just names. Ministers are situated
observers; their accounts are not an automatic ground-truth layer.
[Collection description](https://digitalresearchservices.ed.ac.uk/resources/statistical-accounts-of-scotland).

If Browne needs substantial transcription work, Johnson offers a quicker
single-work pilot: [Gutenberg provides readable text](https://www.gutenberg.org/ebooks/2064),
and its opening dates the journey to 1773. It can test attribution and competing
views alongside Keltie while Browne is prepared. This is a practical fallback,
not a reason to substitute a tiny sample for an agreed full-volume qualification.

## What we can investigate now, and what another source enables

| Corpus | Investigation | Evidence needed to credit the graph |
|---|---|---|
| Keltie only | Compare standards of evidence in Picts, Ossian and clan-origin discussions | Useful passages from separate sections; distinguish the narrator, quoted authorities and qualifying footnotes |
| Keltie only | Follow a person, clan or regiment through different names, roles and periods | Correct identity and chronology; no merging of namesakes or conversion of association into causation |
| Keltie only | Compare accounts of dispossession, violence, loyalty and recruitment | Multiple supported cases and counterexamples, with uncertainty retained |
| Keltie + Browne | What did Keltie retain, alter, reject or newly introduce on the same subjects? | Paired source spans and edition dates; explicit distinction between textual difference and inferred explanation |
| Keltie + Johnson | Where do their accounts of Gaelic tradition and Highland society agree or diverge? | Attribute each position, separate observation from hearsay, and avoid silently choosing the later author |
| Keltie + Old/New Statistical Accounts | Does a parish's reported language, livelihood or population change, and how does that relate to the general narrative? | Comparable units, periods and measurements; local evidence may qualify rather than refute a broad account |
| Keltie + Napier evidence | How do testimony, estate returns and official conclusions differ on a place or issue? | Speaker and role, hearing/return date, question and answer boundaries; preserve conflicting testimony |
| Keltie + a controversy cluster | How did a particular historical claim spread, change or become disputed? | Evidence for each author's assertion and any source dependence; repeated claims are not independent corroboration |

The first three can begin with the existing corpus and public query/citation
commands. Questions involving the additional works remain proposed until those
specific texts and editions are available. New sources may add answerable facts
without demonstrating any benefit from the graph; those effects must be measured
separately.

## Validation: time, authorship and source relationships

Checked against commit `b8dfd0ea7261dba30b6598ed200039d5d2ef6490` and the
preserved post-maintenance corpus at generation 8910 on 8 September 2026.
The core claim/evidence graph exists; the full historical provenance workflow
is only partly implemented. Empty metadata alone is not a failed extraction:
many claims are undated, and an author's own narrative need not repeat the
author's name on every supporting span. The user correctly distinguished books
from meeting transcripts when reviewing this finding.

There are several different meanings of time and attribution:

| Meaning | Appropriate scope | Current implementation |
|---|---|---|
| Author/editor, exact edition, written and published dates | Work, edition or separately authored section | Source records retain an observed title/URI and revisions, but have no dedicated bibliographic author or publication-date fields. These facts may be readable in the text; automatic inheritance into evidence is not implemented by the folder route. |
| Who is making this particular assertion | Supporting source span; default to a known narrative author only when justified | `claim_support.attribution` exists. It can distinguish a quoted witness or authority from the narrator through the lower-level proposal route. The normal provider adapter always supplies an empty value. |
| When the described relationship held or event occurred | Claim, with uncertainty retained | `claims.effective_from/effective_to` and qualifiers exist and are validated/stored. The normal provider adapter always supplies empty dates and `{}` qualifiers. Explicit maintenance qualification can set them. |
| When a source was captured by this RAG | Source revision | `captured_at` exists, but public folder ingestion currently passes the literal `surface-apply`; both current volumes contain that placeholder. This is not a publication or writing date. |
| Source event interval | Source revision, where a document has a meaningful event period | `event_start_at/event_end_at` exist, but folder ingestion does not populate them. A historical book's publication date must not automatically become the date of everything it describes. |
| When the RAG accepted or superseded data | Published database generation | Versioned source revisions, claims and support are implemented. This records database history, independently of historical event time. |
| One work borrowing from another | Evidenced source/work relationship | Exact claim-to-source-span links and support across sources exist. Current support lineage is derived from chunk identity; it does not encode bibliographic dependence such as Keltie's use of Browne. |

For example, a hypothetical book published in 1880 describing a battle in 1745
has at least two relevant dates. A witness quoted in that book adds another
attribution and potentially a date for the original testimony. Unknown dates
should stay unknown; neither publication date nor ingestion time should fill
the claim's historical interval by default.

The read-only census found **1,650 active claims**, none with an effective date
or nonempty qualifiers, and **1,773 active supports**, none with attribution.
Forty-eight claims have support from both current source IDs, which are two
volumes of the same work, not two independent books. These totals demonstrate
that richer fields are unused in this corpus; they do not imply that all claims
ought to have dates or all supports need explicit speaker overrides.
The census is retained at
`/Users/adrian/testrag/corpus-development-20260908/temporal-provenance-census.json`.

The cause is visible in the producer contract, not inferred from model quality:
[the provider mapper](../crexx/application/ragapplicationprovider.crexx) accepts
five relationship fields and constructs every normal proposal with empty
effective dates, empty attribution and empty qualifiers. More workers or a
prompt-only change cannot fill fields that this contract does not carry.
[The schema](../crexx/application/ragschema.crexx),
[proposal input](../crexx/application/ragproposalio.crexx),
[claim validation/storage](../crexx/application/ragclaims.crexx), and
[maintenance qualification](../crexx/application/ragbacklog.crexx) establish
that part of the infrastructure already exists.
[Folder ingestion](../crexx/application/ragfolder.crexx) retains path/size
metadata rather than extracting bibliographic fields;
[source revision insertion](../crexx/application/ragingest.crexx) does not
populate event dates.

The public timeline also needs careful interpretation:
[its projection](../crexx/application/ragevidencejson.crexx) combines source
event intervals, four-digit year mentions in retrieved text and dated claims.
It does not sort those entries chronologically or establish that every mentioned
year dates the associated claim. [Claim retrieval](../crexx/application/ragretrieval.crexx)
currently derives `asserted_at` from the earliest supporting source capture
value, so it cannot be treated as the historical author's assertion date.
Graph traversal filters database generations, not historical claim intervals.

Before relying on automatic chronological or author-to-author comparisons,
agree the meaning and inheritance of these fields, then implement and qualify
the missing producer/consumer behavior as a bounded product change. Test a
narrator's assertion, a quotation, an undated claim, and publication/event dates
that differ. Existing retrieval and manually checked comparisons can proceed
now. No schema, extractor or stored corpus has been changed by this review.

## Candidate source register

The dates below distinguish the proposed work from the particular linked
edition where checked. A catalogue page is a discovery lead, not proof of
complete, correctly ordered OCR. Reasons for inclusion are research hypotheses.
No entry is a blanket reliability rating.

| ID | Proposed work / date | Why add it; distinctive test | Access and preparation status |
|---|---|---|---|
| S01 | Martin Martin, *A Description of the Western Islands of Scotland* (1703) | Earlier descriptions of customs, religion, economy and reported beliefs; compare observation with later retelling | [Catalogue](https://openlibrary.org/books/OL24829665M/A_description_of_the_Western_Islands_of_Scotland) opened; select and verify the exact edition and scan |
| S02 | Edward Burt, *Letters from a Gentleman in the North of Scotland* (1754 work) | Outsider's account of society and roads; distinguish letter date, observation and later publication | [Supplied catalogue](https://books.google.com/books/about/Letters_from_a_Gentleman_in_the_North_of.html?id=6a0T0QEACAAJ) opened; historical edition and usable full text still to qualify |
| S03 | James Macpherson, *Fragments of Ancient Poetry* / subsequent Ossian publications (1760 onwards) | The literary texts and their claims, rather than only later commentary on authenticity | [Readable Fragments](https://www.gutenberg.org/ebooks/8161) verified; the file includes John J. Dunn's later introduction, which must have separate authorship and date. Other Ossian editions remain to select |
| S04 | Hugh Blair, *Critical Dissertation on the Poems of Ossian* (1763/1765 editions proposed) | Contemporary defence; distinguish evidence from critical judgement and quotations | [Supplied Folger record](https://catalog.folger.edu/record/742185) could not be fetched; exact edition and text remain unverified |
| S05 | Samuel Johnson, *A Journey to the Western Islands of Scotland* (1775 work; 1773 journey) | Contrasting observer and sceptical discussion; separate publication and observation dates | [Readable text](https://www.gutenberg.org/ebooks/2064) verified; quickest single-work alternative to Browne |
| S06 | James Boswell, *Journal of a Tour to the Hebrides* (1785) | Another account of the same journey; test perspective and dependence rather than treating two accounts as identical | [Supplied Gutenberg subject list](https://www.gutenberg.org/ebooks/subject/812) is a discovery lead, not an edition selection |
| S07 | *Old Statistical Account of Scotland* (1791–1799) | Parish-level language, work, agriculture and social conditions; local counterexamples to broad narratives | [Edinburgh collection](https://digitalresearchservices.ed.ac.uk/resources/statistical-accounts-of-scotland) verified; choose complete parish reports and preserve their dates and boundaries |
| S08 | David Stewart of Garth, *Sketches of the Character, Manners and Present State of the Highlanders* (1822 work) | Clanship, dress, social change and military interpretation; trace what Keltie borrows or qualifies | [Catalogue](https://openlibrary.org/books/OL21556886M/Sketches_of_the_character_manners_and_present_state_of_the_Highlanders_of_Scotland) opened; edition and OCR need checking |
| S09 | *New Statistical Account of Scotland* (1834–1845) | Later reports for comparison with S07; test change with consistent units | [Wellcome](https://wellcomecollection.org/works/qqycs6g9) lists 15 online volumes, 1845 collected edition, Public Domain Mark; it notes earlier serial publication and differing parish dates |
| S10 | James Browne, *A History of the Highlands and of the Highland Clans* (1836–1838) | First choice: explicit predecessor to Keltie; compare revisions and dependence | [Wellcome](https://wellcomecollection.org/works/emyravt6) catalogue verified; four volumes. Viewer required JavaScript in this check, so OCR completeness and download route are not yet qualified |
| S11 | W. F. Skene, *The Highlanders of Scotland* (1837 work) | Genealogical and origin theories; follow an attributed argument into later accounts | [Catalogue](https://openlibrary.org/books/OL17978806M/The_Highlanders_of_Scotland) opened; select edition and preserve editorial layers |
| S12 | Sobieski Stuarts, *Vestiarium Scoticum* (1842) | Proposed contested-source test: distinguish publication, claims of earlier manuscript authority and subsequent influence | [Catalogue](https://books.google.com/books/about/Vestiarium_Scoticum.html?id=K44xAQAAMAAJ) opened; corroborating critical account and readable plates/text still needed. Never date its assertions by its claimed ancient origin |
| S13 | R. R. McIan / James Logan, *The Clans of the Scottish Highlands* (1845–1847) | Clan narratives and illustrated identity; compare textual assertions with what plates actually show | [Supplied catalogue](https://books.google.com/books/about/The_Clans_of_the_Scottish_Highlands_Illu.html?id=zkLZ-mG5MHEC) failed to fetch. Text ingestion alone will not establish visual tartan patterns |
| S14 | *The Book of the Dean of Lismore*, edited by Thomas McLauchlan (1862 edition) | Earlier Gaelic material through a later editorial/translation layer; attribution and temporal provenance | [Supplied catalogue](https://openlibrary.org/books/OL23293129M/The_Dean_of_Lismore%27s_book) failed to fetch; manuscript date, edition contributors and transcription require verification |
| S15 | Skene, *Celtic Scotland* (1876–1880 work) | Near-contemporary alternative synthesis of history, religion, land and people | [Catalogue](https://openlibrary.org/books/OL24872903M/Celtic_Scotland) opened; select all required volumes and exact editions |
| S16 | Alexander Mackenzie, *History of the Highland Clearances* (1883 first edition) | Land, displacement and competing explanations; broaden beyond chiefs and military narratives | [Linked Gutenberg text](https://www.gutenberg.org/cache/epub/51271/pg51271-images.html) is explicitly the altered and revised **1914 second edition**, with a new introduction; retain that identity if used |
| S17 | Napier Commission evidence (1883) and report (1884) | Compare witnesses, estate returns and official conclusions; expose disagreement and institutional perspective | [UHI report host](https://www.uhi.ac.uk/en/research-enterprise/cultural/centre-for-history/news/archive/2018-2021/napier-commission.html) and [NRS returns guide](https://www.scotlandspeople.gov.uk/help-and-support/guides/napier-commission) verified; returns, hearings and final report are separate record types, with distinct acquisition work |
| S18 | Alexander Carmichael, *Carmina Gadelica* (1900 onwards) | Gaelic/English oral material; test collector, informant, translation and editorial intervention | [Catalogue](https://openlibrary.org/books/OL13439752M/Carmina_gadelica) opened; select specific volumes/edition and preserve parallel languages |
| S19 | Early *Scottish Historical Review* (1903–1928 proposed range) | Later criticism and changing scholarly arguments; evaluate articles individually | [Supplied serial index](https://onlinebooks.library.upenn.edu/webbin/serial?id=scothistrev) failed to fetch; select articles with a specific comparative purpose and verify text/rights per item |
| S20 | J. R. N. MacPhail, *Highland Papers* (1914 onwards) | Edited underlying documents; distinguish historical document, later transcription and editor's interpretation | [Catalogue](https://openlibrary.org/books/OL24828794M/Highland_papers) opened; select volume and retain document-level dates and authors |
| S21 | Highland Society investigation of Ossian (1805) | Add an investigation between advocates, critics and later synthesis | Suggested in the supplied controversy cluster; a specific edition, catalogue and accessible text are still to locate |
| S22 | Rev. John M'Pherson, *Ossianic Controversy* (1873) | Later defence near Keltie's publication; another attributed position on the same disputed material | Correct [Gutenberg edition 77301](https://www.gutenberg.org/ebooks/77301) located. The supplied link to ebook 40784 actually identifies Rudolf Tombo's *Ossian in Germany*, a different work |

The source list supplied by the user also proposed three clusters. Retain all
three as research routes, rather than ingesting twenty-two works at once:

- **Ossian:** S03, S04, S05, S21 and S22 alongside Keltie. Ask how the argument
  changes, what each author means by authenticity, and whether a shared quotation
  supplies independent evidence. S14 can later add a different textual witness.
- **Clan tartans:** S12 and S13 alongside Keltie and a verified critical source.
  Ask who first asserts a particular attribution in the available corpus, who
  repeats it, and what supports or challenges its claimed antiquity. The original
  [NMS blog link](https://blog.nms.ac.uk/2023/08/16/tartan-trendsetting-in-our-library-catalogue/)
  currently redirects to a general page; it is not retained as a verified full
  critical article. Avoid presenting a corpus-earliest occurrence as the earliest
  occurrence anywhere.
- **Clanship, land and displacement:** S08, S07/S09, S16 and S17 alongside
  Keltie. Compare the treatment of loyalty and leadership with accounts of
  livelihood, tenancy and displacement. Test whether disagreement is about facts,
  time, locality or interpretation.

The original suggested first wave is preserved as S01, S02, S03, S05, S07, S08,
S10, S12, S09 and the S16/S17 group. This is an acquisition menu: it contains
multiple works and multi-volume collections, not a ten-file ingestion budget.
S20 and selected S19 articles remain later extensions. Early twentieth-century
criticism should not be labelled current scholarly consensus.

## Source provenance and interpretation

Keep the following in the acquisition register before attempting product
integration. These are proposed descriptive fields, not new configuration keys:

| Field group | Record and use |
|---|---|
| Identity | Work title, author/editor/translator, edition and volume, repository URL, acquisition date, raw-file checksum, page/section mapping, OCR corrections |
| Dates | Original publication; date of the actual edition; observation/hearing period; historical period asserted by a passage; digitisation/acquisition date. Unknown is distinct from inferred |
| Document type | Observation, official return/testimony, oral collection, antiquarian history, genealogy, literary work, scholarly argument or polemic; allow mixed sections |
| Voice and perspective | Named speaker/author, quoted authority, editor, translator and role. Perspective can vary within one book; do not assign every Napier passage to a government voice |
| Assessment | What a passage is evidence **of**, disputed assertion, supporting/challenging source, reason and reviewer/date. Avoid a global trusted/untrusted flag masquerading as historical judgement |
| Language and geography | Original/translation language, named places and historical boundaries, date-qualified identities and alternative names; keep uncertain matches unresolved |
| Dependence | Quoted, copied, adapted or reportedly derived from another work, with supporting spans and uncertainty. An identified relationship between works does not prove every claim was borrowed |

The proposal's `primary_evidence`, `interpretation`, `contested` and
`known_problematic` labels are useful prompts for review, but mix genre and
reliability. A contested work can be excellent primary evidence of what its
publisher claimed. Official testimony can be inaccurate. A late edition can
contain earlier material and a new editorial introduction. Preserve those
distinctions at the passage/claim level where possible.

Current citation resolution exposes the connector type, capture timestamp and
optional event bounds. The connector type is not the historical genre, and the
capture timestamp is not the book's publication date. No assumption is made that
the current file ingest route accepts all the fields above. Mapping them to
supported contracts, or identifying a bounded product gap, precedes any schema
proposal. Preserve source text and quotation attribution rather than silently
rewriting historical assertions into curator-approved facts.

## Establishing whether the graph adds value

Keep three questions separate: whether more source material helps; whether
maintenance improves the existing catalogue; and whether graph traversal helps
the answerer. Adding a book and increasing graph enrichment in one uncontrolled
run cannot answer all three.

For a fixed source set, compare the same questions, executable, model, prompt,
context allowance and research budget across earlier/later snapshots and
traversal disabled/enabled. Freeze source-only question selection and assessment
criteria before viewing graph results. Independently adjudicate unexpected valid
answers; the question writer need not know the conclusion. Blind the reviewer
to condition labels and repeat close cases with an equal allowance.

**Current public-control limit:** `query evidence --mode hybrid --hops 0` skips
edge traversal, while retaining learned alias/spelling expansion, retrieved
ambiguities, co-mention leads and analysis notes. This follows the owning code
in [query planning](../crexx/application/ragquery.crexx) and
[retrieval](../crexx/application/ragretrieval.crexx). Consequently the immediate
comparison can honestly measure the added value of **traversal and its resulting
evidence packet**. It must not be called a complete graph-free baseline.
A strict lexical/vector-only comparison needs a separate, bounded control that
also excludes catalogue-derived expansion and auxiliary evidence; no such
product change is included in this record.

In the initial existing-control trial, preselect one graph depth (for example
two hops) rather than tuning depth per question after seeing the answer.
Record selected passage IDs, graph contributions to ranking, accepted claims,
leads, notes, citations, follow-up requests, tokens, latency and failures. Equal
passage counts alone do not guarantee equal input size; control total evidence
tokens and research calls too. Use separate sessions to avoid one answerer seeing
another condition's evidence. New query gaps belong to the evaluation copies.

When Browne is added, first compare Keltie against Keltie+Browne with traversal
disabled, then compare traversal enabled/disabled within Keltie+Browne. Retain
the same Keltie snapshot and record any unavoidable identity migrations. Include
unchanged Keltie questions alongside new cross-work questions: unavailable
Browne evidence in the original corpus is an expected source gap, not an error.

Score concrete supported contributions, counterevidence, correct attribution
and chronology, remaining gaps, unsupported inferences and effort. A graph win
requires useful evidence or a justified connection that improves the answer,
or the same supported answer with less effort. More graph hits or a longer
answer earns no credit. Identify loss cases where graph candidates displace
better text evidence. A path through A–B–C is a research lead; it does not by
itself establish a new A–C historical claim.

Eight candidate fixed questions for review, not yet a frozen or scored benchmark:

1. Does Keltie use place-name evidence consistently in the Picts and Ossian
   discussions? What qualifications or differences in the claims matter?
2. Which criteria for accepting a clan-origin story recur across three clan
   accounts, and what is the strongest counterexample?
3. Where is violence described as a cause of repression, and where as a
   consequence? Compare chronology and attribution in at least two cases.
4. How does the work explain Highland military recruitment alongside earlier
   suppression of Highland organisation? What does it leave unexplained?
5. Find a conclusion in the main narrative qualified by a footnote or later
   discussion. Does the qualification change the answer or only its confidence?
6. Follow one person through a changed surname or title and distinguish them
   from a plausible namesake. Which passages justify the identity?
7. Compare a landlord/chief's stated justification with the account of effects
   on inhabitants. Do time and locality explain any apparent contradiction?
8. Does agreement among quoted authorities on a selected question rest on
   independent evidence or a common source? Report what cannot be established.

Four open investigations can discover questions beyond those examples:
survey underused chapters for competing explanations; trace an unresolved
identity across sections; find a pattern across three cases and actively seek
its counterexample; and review where editorial footnotes change the narrative.
Record the starting expectation, evidence that changed it, rival explanation,
remaining uncertainty and the graph's actual contribution. Keep these discovery
outcomes separate from the frozen benchmark scores.

## Immediate sequence and maintenance experiment

### Requested next phase, pending design approval

The user has requested this sequence **after the current eight-worker Luna
job finishes**:

1. Report the current run, then propose the data design for approval. Cover
   essential claim periods; source authorship, writing and publication dates;
   passage attribution; and draft, primary, derived and related classifications.
   Distinguish lifecycle/review status from evidence origin and derivation.
   Explain scope, defaults, overrides, unknown/approximate dates, source
   relationships and retrieval behavior with concrete examples. Identify which
   existing fields can be reused and which changes need a schema migration.
2. After approval, implement the agreed code changes and complete appropriate
   QA, including provider validation and migration compatibility.
3. Update existing corpus records using the approved migration or reprocessing
   procedure, qualified on a preserved copy first. Preserve citations, audit
   history and vectors where still valid. Do not invent missing dates or
   silently reinterpret capture time as publication or historical validity.
4. Validate the resulting behavior with another bounded Luna run. Include a
   small, declared input with only a few records if it improves the test; the
   design proposal must state the fixture/source, call ceiling and acceptance
   checks. Measure correctly populated and retrieved metadata, not just job
   success or the number of extracted claims.

The sequence is authorised; approval of the concrete design remains pending.
The [concrete design proposal](claim-time-provenance-proposal.md) is now ready
for approval. It covers independent status/origin/modality classifications,
temporal semantics, three versioned metadata tables, existing-data enrichment
and explicit live-call limits. Product code and existing corpus records await
that approval.

### Research sequence and current trial

1. Preserve the measured Keltie snapshots and review the harder question set.
2. Run the existing-control traversal comparison, labelled with its limits.
3. Resolve the time/authorship semantics and qualify the missing metadata path
   before relying on automatic historical comparison; the validation above is
   a finding and proposed next change, not an implemented repair.
4. Prepare Browne's exact four-volume edition: acquire files, inspect ordering,
   OCR and citations, record measured size, and produce a bounded ingestion plan
   for an experimental copy. Use the existing provider/configuration controls.
5. Add and evaluate Browne before selecting the next collection. Prefer matched
   Statistical Accounts for temporal/local evidence; use Johnson for a quicker
   contrasting account if acquisition effort dominates.
6. Let observed answer failures guide subsequent maintenance priorities. Keep
   essential integrity/recovery work separate from discretionary enrichment.

An eight-worker Luna experiment addresses **throughput and operating cost**,
not the graph-value question. It should use a separate copy of the same starting
snapshot, the same Luna model and low reasoning. For a controlled comparison,
only concurrency should change; differences in the historical run are recorded
below.
Measure completed acceptable items per minute, correction attempts and final
rejections by task type, worker stability, contention, token totals and allowance
readings. Compare against the retained four-worker run with its different task
mix and timing made explicit; a stronger scaling result would use matched-start
four/eight-worker runs. Higher throughput is not evidence of better historical
answers. A flat rounded allowance counter does not measure zero cost.

The eight-worker trial was started as a 30-minute scaling check, the stated
working default after an optional duration question received no response.
It starts from generation 8116, matching the historical four-worker test, in
`/Users/adrian/testrag/nightly-test-codex-luna-8w-30m-20260908`.
The current executable includes the committed deadline-reconciliation fix and
uses the corrected 32,768-token extractor reservation; the historical run used
8,192. Eight workers yield 96 work attempts per nominal 100-item batch, versus
100 with four. Keep these limits explicit when comparing the first 30 minutes
and the historical two-hour total. The experiment preserves the source-expansion
and graph-evaluation baselines. All eight worker processes and eight simultaneous
Luna admissions were observed at startup. The run finished at approximately
16:24:23 Europe/London, before its 16:26:13 deadline, with exit 0 and clean worker
shutdown. It made 517 calls in 28m 11s, with 424 processed/safely skipped items
out of 456 provider-called items and 32 final provider-called failures (7.0%).
Two additional zero-call deadline refusals were classified as dead letters;
this is a remaining budget-stop classification follow-up, not a worker crash.
The eight-worker rate was 18.34 calls/minute versus 11.07 in the historical
four-worker first 30 minutes (1.66x); the comparison limits above still apply.
Allowance stayed at 5%, which does not resolve exact cost. Integrity, source,
vector, reservation and dispatched-task checks passed. The trial ended at
generation 8454 with 1,451 claims; the richer post-four-worker generation 8910
remains the recommended baseline for the proposed data update.

Full results:
`/Users/adrian/testrag/nightly-test-codex-luna-8w-30m-20260908/QUALITY-REPORT.md`.

Local evidence for the current decision is retained in
`/Users/adrian/testrag/corpus-qa-20260908/QUALITY-REPORT.md` and
`/Users/adrian/testrag/nightly-test-codex-luna-4w-2h-20260908/QUALITY-REPORT.md`.
