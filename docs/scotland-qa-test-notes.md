# Scotland QA Test Notes

These notes track prompt/search quality for source-bound QA over the Scotland
corpus. The goal is to learn whether the QA agent asks the corpus useful
questions, separates ambiguity, cites evidence, and finds relationships that a
single simple search may miss.

## Test 1: Sutherlands and the Clearances

Question:

```text
What was the role of the Sutherlands in the clearances?
```

Observed search focus:

- Sutherland as county/estate versus clan/family/title
- Marquis of Stafford, Duchess/heiress of Sutherland estate
- Sellar as factor and executor of removals
- Tenant consequences: removal to coast and conversion to sheep farms

Good:

- The agent followed the narrow QA-agent prompt and produced a visible search
  focus before answering.
- It treated `Sutherland` as ambiguous rather than assuming one sense.
- It separated county/estate/title evidence from Clan Sutherland.
- It identified the key agency chain from the corpus: Sutherland estate,
  Marquis of Stafford, and Sellar as factor.
- It cited chunks and included a graph path for Clan Sutherland evidence.
- It avoided outside historical claims and framed the answer as corpus evidence.
- It found a relationship-oriented answer, not just a list of keyword hits.

Bad / Weak:

- The search focus did not explicitly include spelling variants from the user
  question (`clearences` -> `clearances`) or plural/possessive variants
  (`Sutherlands`, `Sutherland's`, `Sutherland`).
- It cited the genealogical connection through chunk 1996, but should be
  cautious about whether the exact named identity is fully supported by that
  returned chunk or by nearby context.
- It did not mention the source's legal/mitigating framing: tenants being
  warned, Sellar's legal acquittal, and the author's claim that officials acted
  according to law.
- It did not include the tenant hardship detail from adjacent evidence in this
  answer, despite listing consequences in the search focus.
- The graph evidence cited `Clan Sutherland -> evidence:chunk:5648`, but the
  answer did not explain what that graph path proves beyond "Clan Sutherland is
  a separate concept." That is acceptable, but should be clearer.

Lessons:

- The fake-agent prompt is directionally right: it made the agent query the
  corpus before answering and kept it away from unsupported outside knowledge.
- The retrieval trace should include spelling normalization and variant
  handling when the user question is noisy.
- Answers should distinguish "absence of returned evidence" from "absence in
  the corpus." Preferred wording: "I did not find returned evidence that..."
- Relationship answers should include both agency and source stance where the
  source itself frames legality, blame, or mitigation.
- Graph paths need a short explanation of what the path supports; otherwise
  they can look like decorative evidence.

## Test 2: MacGregors and "Children of the Mist"

Question:

```text
According to Keltie, why were the MacGregors known as the "Children of the Mist," and what was the nature of their proscription?
```

Observed search focus:

- Exact "Children of the Mist" phrase with MacGregor
- MacGregors as outlawed, landless, mountain-fugitive clan
- Privy Council proscription after Glenfruin
- Penalties: name, shelter, weapons, executions, later rescission

Good:

- The agent explicitly reported that returned evidence did not surface the exact
  phrase `Children of the Mist`, instead of pretending it had a direct quote.
- It gave a cautious inferred explanation: the nickname is consistent with the
  returned evidence describing the MacGregors as dispossessed, outlawed,
  landless, hunted, and taking refuge in mountain fastnesses.
- It found the concrete legal content of the proscription: abolition of the
  names Gregor/Macgregor, compulsory surname change, death penalties, penalties
  for sheltering the clan, weapon restrictions, group-meeting restrictions, and
  executions.
- It tied the answer to strong chunks: 1784, 1789, 1795, 2063, and 2064.
- It used graph evidence only as secondary support for the clan-to-evidence
  connection.

Bad / Weak:

- The user's wording says "According to Keltie"; the answer should explicitly
  say whether the returned evidence is Keltie's own narrative, quoted from
  another authority, or an index/secondary passage inside the Keltie volumes.
- The answer says "reason implied by that label"; that is good caution, but it
  should be even more explicit that this is not direct phrase evidence.
- The observed search focus mentions "later rescission", but the final answer
  does not discuss it. Either the focus should omit it, or the answer should
  say returned evidence did not support it in the searched chunks.
- Chunk 11580 appears to be index-like evidence; when graph evidence points to
  an index chunk, the agent should prefer narrative chunks for factual claims.

Lessons:

- Exact-phrase questions need two evidence categories: "direct phrase found" and
  "nearby/implicit explanation." The answer should label which one is being
  used.
- The QA agent should distinguish narrative chunks from index chunks and avoid
  leaning on index chunks for explanation.
- If the search plan includes a line item such as rescission or repeal, the
  final answer should either answer it or report that the returned evidence did
  not establish it.
- "According to Keltie" questions need provenance care: Keltie sometimes quotes
  or summarizes other named sources inside the corpus.

## Test 3: Black Watch / 42nd Royal Highlanders

Question:

```text
Trace the origin of the "Black Watch" (42nd Royal Highlanders) as described in the text. What does the Gaelic name "Am Freiceadan Dubh" signify?
```

Observed search focus:

- 42nd Royal Highlanders / Black Watch origin
- Six independent Highland companies raised about 1729
- Duties of the companies in the Highlands
- 1739 formation into a regiment of the line
- Meaning of Am Freiceadan Dubh

Good:

- The agent produced a clear chronological trace: six independent companies
  around 1729, internal Highland security duties, four more companies added in
  1739, first muster in May 1740, and later identity as the 42nd Royal
  Highlanders.
- It correctly explained the function of the companies: enforcing the Disarming
  Act, overawing disaffected groups, watching movements, and checking
  depredations.
- It correctly explained the Gaelic name by contrast with the red-coated
  `Saighdearan Dearg`; the independent companies' dark tartan gave rise to
  `Am Freiceadan Dubh`, the Black Watch.
- It used strong narrative chunks: 2275, 2276, 2277, 2281, and 2282.
- It used supporting corroboration from chunk 2965, a monument inscription, and
  chunk 1722, a related genealogical/military note.
- This answer genuinely goes beyond a simple keyword match by integrating
  naming, chronology, duties, and later regiment numbering.

Bad / Weak:

- It cited chunk 11 and graph chunk 5537 for the Gaelic name; both are
  table-of-contents/index-like evidence. They are useful pointers, but the
  narrative explanation should rest primarily on chunks 2276 and 2277.
- The graph path uses `history:scotland:clan:black_watch`, which is probably a
  type-quality issue: Black Watch is a military unit, not a clan. The answer
  also cited the better `history:scotland:military-unit:black-watch` path.
- It did not explicitly mention that the regiment initially became the 43rd
  before later being known as the 42nd, though it did include the 43rd detail.

Lessons:

- The QA answer quality is strongest when the agent assembles a small timeline
  from several narrative chunks.
- Index/table-of-contents chunks should be demoted to locator evidence unless
  no narrative evidence exists.
- This test exposed a graph typing cleanup need: `Black Watch` should not appear
  as a clan node.
- Good evidence bundles should separate "narrative evidence", "index evidence",
  and "graph evidence" to help the agent weigh citations.

## Test 4: Mackay, Sutherland, Strathnaver, Caithness, and Graph Adjacency

Question:

```text
Compare how the source treats Clan Mackay and Clan Sutherland in relation to Strathnaver, Caithness, and conflict in the north. Which claims are directly stated, and which are only graph-adjacent?
```

Observed search focus:

- Mackay plus Strathnaver/Caithness identity and possession
- Sutherland clan origin/name versus Earl/place usage
- Northern conflict passages involving Mackay, Caithness, Strathnaver, and the
  Earl of Sutherland
- Graph co-mentions checked as adjacency, not treated as direct claims

Good:

- The answer directly engaged with the method question: what is stated in text
  versus what is graph-adjacent.
- It strongly distinguished Mackay evidence from Sutherland evidence. Mackay is
  directly tied to Strathnaver/ancient Caithness and northern conflicts in the
  cited chunks; Sutherland is often represented as district, earldom, Earl, or
  political house rather than directly as `Clan Sutherland`.
- It avoided turning co-mentions into claims. This is an important success for
  the graph-search methodology.
- It gave useful direct Mackay examples: ancient Caithness including
  Strathnaver, Siol Mhorgan/Mackay, church lands in Strathnaver, Mackay branches,
  Angus Mackay assisting the Keiths in Caithness, Mackay factional disputes in
  Strathnaver, and Mackay's shifting relations with the Earls of Sutherland and
  Caithness.
- It gave useful direct Sutherland examples: clan name from the district,
  Sutherland south of Caithness from the Norse viewpoint, Earl as chief, fighting
  strength, Hanoverian loyalty, and earldom/Freskin lineage.
- It properly treated `Earl of Sutherland` evidence as not automatically equal
  to collective Clan Sutherland agency.

Bad / Weak:

- Several Mackay/Sutherland origin claims are presented by Keltie through named
  authorities such as Skene, Sir Robert Gordon, or Robert Mackay. The answer
  should preserve that source layering when the user asks "the source treats."
- The answer lists many chunks and claims; it is accurate but dense. A small
  direct-vs-adjacent table would make this kind of answer easier to audit.
- `Reay Country was Strathnaver` may be a compressed inference from the
  returned passages. It should be phrased carefully unless the exact wording is
  present in returned evidence.
- The graph-adjacent section is good, but it should include one concrete example
  of a co-mention path that is not accepted as a claim, if the evidence bundle
  returns one.

Lessons:

- This is a high-value test for the graph layer because it asks the agent to
  avoid a common graph-RAG failure: mistaking adjacency for assertion.
- The prompt should prefer a compact claim table for comparison questions:
  `claim`, `status`, `evidence`, `confidence`.
- The search/evidence layer should expose edge type and evidence quality clearly
  enough that the agent can distinguish `mentioned-in`, direct relationship
  extraction, index evidence, and narrative assertions.
- Provenance layering matters: "Keltie says", "Keltie quotes Skene", and "the
  index points to" are different strengths of evidence.

## Test 5: Ossian, Macpherson, Authenticity, and Forgery

Question:

```text
What does the source say about Ossian/Macpherson, and what is the most nuanced answer possible without calling the poems simply authentic or simply forged?
```

Observed search focus:

- Macpherson's publications: `Fragments`, `Fingal`, `Temora`, Gaelic originals
- Evidence for older Ossianic tradition: Dean of Lismore, oral recitation, later
  collectors
- Source cautions: missing originals, poor Gaelic orthography, expanded versions
- Graph paths checked: Ossian source-work/person mentions; Macpherson graph
  matches are noisy because some resolve to Clan Macpherson

Good:

- The answer met the user's request for nuance and did not collapse the issue
  into either "authentic" or "forged."
- It captured the source's stated method: the text declines to settle
  authenticity in simple terms and instead sketches publication history and
  specimens.
- It separated two strong strands of evidence:
  - against simple forgery: Ossianic names, heroes, poetry, oral/topographic
    tradition, Dean of Lismore, later independent collectors, and the source's
    claim that Ossian was not Macpherson's creation;
  - against simple authenticity: missing or unpublished originals, expansions
    between the 1760 fragments and later epics, uncertain sources, and poor or
    non-standard Gaelic orthography.
- It used strong narrative chunks: 671, 672, 675, 680, 681, 682, 690, 692, 695,
  697, 704, 707, and 725.
- It noticed a graph ambiguity: `Macpherson` can resolve to Clan Macpherson as
  well as James Macpherson, so graph evidence needs disambiguation.
- The final synthesis is excellent: Macpherson as editor/translator/poetic
  shaper of a real Gaelic Ossianic tradition, with published texts not securely
  traceable to clean surviving originals.

Bad / Weak:

- The answer says "the source is very strong" on the anti-forgery side; this is
  fair, but it should avoid sounding more certain than the source's own
  carefully qualified position.
- It could explicitly distinguish `Macpherson's Ossian` from the broader
  Ossianic tradition in the final sentence.
- It did not cite chunk 698, which directly continues the point that
  Macpherson's sources were not rediscovered while Ossianic poetry remained
  known in the Highlands; chunk 697 mostly covers this, so this is minor.
- Graph paths are correctly treated as noisy, but the answer does not need graph
  evidence here; the narrative chunks are enough.

Lessons:

- This is a strong example of the QA layer using retrieval to support a nuanced
  answer rather than a binary answer.
- Ambiguity is not only person/place/clan; it can also be
  tradition/work/editor/source-version ambiguity.
- Name collision handling should improve for `Macpherson`: when co-query terms
  include Ossian/Fingal/Temora/Gaelic originals, the person James Macpherson
  should rank above Clan Macpherson nodes.
- Some questions should intentionally prefer narrative evidence and ignore graph
  evidence unless the graph adds a relationship not already clear from text.

## Cross-Test Lessons

The QA wrapper and fake-agent instructions helped because they gave a capable
agent a small, dependable working contract:

- ask the corpus first;
- decompose the question into focused searches;
- show the search focus;
- distinguish ambiguity;
- cite chunks and graph paths;
- treat graph adjacency as weaker than direct textual assertion.

The wrapper is therefore part of the product surface, not just a testing
convenience. A fresh agent should not need to know how the library is stored,
which vector backend is active, or how MCP is wired. It should see a stable
question-answer surface that returns enough evidence classes to reason well.

Useful wrapper hints:

- suggest variant spellings and possessive/plural forms for noisy user input;
- include query decompositions for common intent shapes: origin, agency,
  chronology, comparison, legal status, source stance, alias/translation, and
  direct-versus-adjacent claims;
- return narrative chunks separately from index/table-of-contents chunks;
- expose graph paths with edge types and a plain statement of what the path can
  and cannot prove;
- include provenance hints such as "Keltie narrative", "Keltie quoting Skene",
  "index entry", "monument inscription", or "later collector";
- report when vector search is unavailable, but do not make the agent debug the
  system during QA.

## Ingestion Lessons

The QA tests surfaced ingestion issues that matter before answer generation:

- Entity typing needs more cleanup. `Black Watch` appeared as a clan node even
  though the useful concept is a military unit.
- Name collision handling needs to become first-class. `Sutherland`,
  `Macpherson`, `Donald`, titles, places, clans, and families can all collide.
- Stage 3 should record evidence quality on nodes and edges, not only text and
  labels. Suggested evidence classes: `narrative`, `index`, `toc`, `caption`,
  `genealogy`, `quoted-source`, `inscription`, and `model-extracted`.
- Mention edges are useful leads but must stay visibly weaker than accepted
  typed relationships. A `mentioned-in` path should never be presented as a
  relationship claim by itself.
- Extracted relationships need support/evidence accumulation with direct source
  spans where possible. Repeated support should strengthen confidence; duplicate
  extraction should not create duplicate facts.
- Ambiguity nodes should persist until resolved. For example, `Sutherland`
  should remain able to point to place, clan, estate, title, family, and
  regiment senses.
- Ingestion should preserve source layering. Keltie quoting Skene is not the
  same as Keltie stating something directly, and an index entry is not the same
  as a narrative passage.
- Chunk shape should influence ranking. Heading lists, tables of contents,
  indexes, captions, and footnote-heavy chunks are useful locators but should
  not outrank narrative chunks for explanatory answers.
- Alias/translation extraction is high value. Examples include `Am Freiceadan
  Dubh` / `Black Watch`, old Gaelic clan names, alternate spellings, and
  title/person variants.
- Some graph nodes should be created from non-technical source-critical
  concepts too: source work, publication, manuscript, collector, quoted author,
  tradition, translation, and version.

## Hardening Backlog

1. Evidence-class scoring: add source/chunk/edge evidence class metadata and
   rank narrative assertions above index and table-of-contents evidence for QA.
2. Directness labels: expose whether a result is a direct textual claim, an
   accepted extracted relationship, a mention/co-mention, or an inferred search
   lead.
3. Claim-table mode: for comparison or "which claims are direct" questions,
   encourage a compact `claim | status | evidence | notes` answer shape.
4. Search-plan templates: teach the wrapper/prompt intent-specific search
   paths: exact phrase, variant spellings, actor/agency, timeline, legal
   status, alias/translation, and source stance.
5. Graph typing cleanup: add review jobs for suspicious type assignments such
   as military units under clan nodes.
6. Ambiguity review queue: create or reuse work-queue items for high-frequency
   ambiguous labels and name collisions.
7. Provenance layering: store and expose quoted authority/source attribution
   when chunks contain phrases such as "Skene says" or "according to".
8. Citation quality: prefer narrative chunks in final citations; use index
   chunks only as locator evidence unless no narrative evidence exists.
9. Wrapper contract: make the QA wrapper return a compact evidence bundle that
   already groups lexical, vector, graph, narrative, index, and direct
   relationship evidence.
10. Regression suite: keep these five QA questions as a repeatable prompt/tool
   smoke, with expected behaviors rather than exact model wording.
