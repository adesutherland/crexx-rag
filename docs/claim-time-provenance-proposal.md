# Claim time and evidence provenance: proposal for approval

8 September 2026. **Original approved design; default simplified after the trial.** Based on commit
`b8dfd0ea7261dba30b6598ed200039d5d2ef6490`, schema 10, the
[corpus validation](scottish-corpus-development.md#validation-time-authorship-and-source-relationships),
and the completed eight-worker Luna scaling experiment.

The user subsequently requested rollback of the per-claim assessment experiment.
The working corpus returns to the metadata-only baseline: document dates and
status linked through source revisions, with no blanket claim reassessment.
Ordinary ingestion and maintenance no longer request the assessment contract.
The broader design below remains a record of the experiment and optional future
work, not the default workflow. See [the current contract](time-and-provenance.md).

## Recommended decision

Implement one coherent extension of the existing claim/evidence model. A claim
must be able to say **when a relationship held**; its support must say **who
asserted it, in what document, and on what basis**. Keep document maturity,
evidence origin, assertion stance and RAG acceptance independent. Preserve
unknowns and qualifications through storage, retrieval and answer generation.

Reuse the existing source revisions, claims, support, review/decision history
and maintenance jobs. Add three small, versioned metadata tables and a shared
validated period value. Do not introduce a second graph engine or workflow
framework. All product behavior remains Level-G cREXX with installed `rxsqlite`.

Approval of this proposal would authorise implementation, QA and the bounded
existing-data and validation work described below. It would not authorise a
commit, push, installation, or replacement of the original live library.

## 1. Meanings and defaults

| Dimension | Meaning and proposed values | Scope and rules |
|---|---|---|
| Document status | `unknown`, `draft`, `final`, `published`, `withdrawn` | Describes the document or edition. Published does not mean correct; an unpublished final letter is not necessarily a draft. Preserve version/revision links. |
| Evidence origin | `unknown`, `primary`, `secondary`, `derived`, `mixed` | Describes this support **in relation to this claim**. Primary means a first-hand record of the matter asserted; secondary is an account based on others; derived explicitly reuses identified upstream evidence. Mixed support should be split where practical. |
| Stance | Existing assertion, quotation, report and profile-defined stances | A quotation is not automatically the narrator's endorsement. Add an explicit proposal stance if the current profile lacks it, rather than expressing a proposed relationship as established reality. |
| Directness and polarity | Existing direct/indirect and support/contradiction | A direct quotation can be secondary evidence. A primary document can contradict a claim. These are separate axes. |
| RAG disposition | Existing pending review, accepted, rejected and superseded history | Acceptance means the proposal passed the product's validation/policy, not that a historian independently established truth. Retain the existing provider confidence and validation marker meanings. |
| Claim modality | `asserted`, `proposed`, `hypothetical` | Part of claim meaning, independent of source maturity. A draft may assert an actual observation; a published document may describe a proposal. |
| Historical validity | Event occurrence or period during which a relationship is asserted to hold | Does not inherit publication or capture dates. Unknown is legitimate; missing end date does not imply that the relationship is still current. |
| Assertion time | When the source voice made the assertion, if known | A dated letter can supply it. Publication can establish that the assertion was in print by that date, but is not silently treated as the exact original assertion time. |
| Writing/publication time | Separate dates or periods for the exact work, edition or contributed section | Source-level defaults with evidence and explicit passage/section overrides. Reprints and later introductions retain their own dates. |
| Capture/acceptance time | When the system obtained the source and accepted the data | Real UTC system timestamps and existing publication generations. Never substitute these for historical time. |

Primary evidence is not a universal reliability rating. A later history is
secondary evidence about a battle, but primary evidence of what its author
argued. An original letter may contain hearsay. A draft can be primary evidence
of a proposed policy while providing no evidence that the policy took effect.
`derived` describes dependence, not poor quality.

There is no blanket default that every book is secondary or every meeting
note is primary. For ordinary narrative, inherit a known source/section author.
For a quotation or report, require an attributed voice or route the uncertain
assertion to review. Do not fall back to the narrator when the quoted speaker
is unknown. Source author/editor roles are distinct, and collective or unknown
authorship is supported without inventing a person.

## 2. Period representation and behavior

Introduce one versioned `period/1` value used consistently for historical
validity, assertion, writing and publication. It has:

- `kind`: `point`, `interval`, `unknown`, or `not-applicable`.
- Start/end date expressions with precision (`day`, `month`, `year`, or
  `unresolved`), certainty (`stated` or `approximate`), and a declared calendar.
- A separately stated end condition: `bounded`, `open`, or `unknown`.
  Explicitly ongoing is different from an omitted end.
- Optional earliest/latest bounds for each endpoint, only where justified.
  Preserve `before`/`after` constraints without inventing the missing bound.
- Original wording, evidence reference and normalization rule in the support's
  provenance, separately from the canonical meaning used for claim identity.

`point` means an occurrence somewhere within the date's precision: an event
dated only to 1745 did not necessarily last the whole year. An interval records
the relationship's duration, with uncertainty about either endpoint retained.
Unknown and not-applicable require explicit meanings; neither means all time.

For comparable dates, normalization uses inclusive civil-date bounds. A stated
year may have a search envelope from its first to last day, explicitly labelled
as a year envelope, not an exact duration. Interval endpoint envelopes remain
separate so possible overlap is not mistaken for definite overlap. No default
plus/minus interval is invented for “circa”: retain the approximate label and
return an uncertain comparison unless explicit bounds are supported.

Preserve Julian/Old Style, Gregorian, uncertain-calendar and unparsed date
wording. Normalize only supported, unambiguous forms. This change does not
require a comprehensive calendar-conversion engine: unresolved calendar/BCE or
relative expressions remain inspectable with unknown precise comparisons.
Do not silently compare them as exact Gregorian dates. A timestamped modern
meeting may retain its explicit offset; a year-only historical date gains no
fabricated time of day.

Examples below are **synthetic**, not assertions about the current corpus:

| Input | Stored interpretation |
|---|---|
| A history published in 1880 says “The battle occurred in 1745.” | Source publication 1880; historical point 1745 with year precision; narrator attribution. Original assertion time remains unknown unless separately evidenced. |
| That history quotes a soldier's letter dated 20 July 1745: “I saw the crossing yesterday.” | Narrator and quoted soldier distinguished; original letter is the stated upstream source. Preserve the relative event expression; do not invent an exact crossing date unless an explicitly supported normalization rule proves it. |
| “X commanded Y from 1745 to 1746.” | Historical interval with year-precision endpoints; evidence for both bounds. |
| “X commanded Y around 1745.” | Approximate time expression; no fabricated exact start, finish or arbitrary uncertainty margin. |
| “X commanded Y” with no time evidence | Unknown historical period, not indefinitely current. |
| A 2024 draft proposes “A reports to B from January 2025.” | Draft document, proposal stance, proposed effective period; excluded from an unqualified answer about an enacted reporting line. |
| A 1900 account explicitly repeats an 1880 account | Separate source identity, an evidenced derivation link and a shared known evidence family; not two independent confirmations. |

## 3. Storage and identity

Retain source bytes, revisions, chunks and citation IDs. Extend schema 10 with
one ordered, checksum-verified migration (proposed schema 11). The logical
tables below use foreign keys, bounded validated JSON, generation visibility
and existing review/decision/provider provenance. Names are part of this
proposal; the SQL is not yet implemented.

| Table / existing owner | Fields and responsibility |
|---|---|
| New `source_descriptions` | Description ID; source revision ID; optional normalized byte scope for a separately authored section; parent scope; title, work/edition reference, author/editor roles, document status, writing/publication periods, optional assertion context and corrected capture observation; per-field provenance; review/decision linkage; visible generations. Whole-revision descriptions supply defaults. |
| New `source_relations` | Relation ID; originating source/revision and optional scope; target source/revision **or** a stable external work reference; relation (`quotes`, `reports`, `derived-from`, `revises`, `edition-of`); grounding; review/decision linkage; visible generations. Exactly one target form is required. External references are not ingested evidence. |
| New `support_descriptions` | Description ID; existing support ID; resolved voice and origin, declaration/inheritance references, assertion period, field-specific evidence spans, optional derivation relation IDs, assessment state and provenance; visible generations. This preserves historical support identity while enriching its interpretation. |
| Existing `claims` | Keep directional endpoints and `effective_from/effective_to`; reserve a validated `qualifiers.temporal` object for canonical period meaning, precision, uncertainty and endpoint bounds. Existing scalar dates become compatible bounds, not the complete meaning of an approximate period. Other qualifiers remain intact. |
| Existing `claim_support`, reviews and decisions | Retain exact supporting spans, polarity, stance, directness and legacy attribution/lineage. Use existing review and maintenance decisions for promotion and supersession; expose resolved descriptions in retrieval. Raw legacy values remain auditable. |

Metadata is evidence-bearing data, not an unvalidated key/value bag. Every
asserted field records whether it was operator-declared, deterministically
parsed, LLM-proposed or inherited, and its source span or reviewed declaration
reference. Record method and review separately: machine-validated is not
human-reviewed. Contradictory metadata creates a reviewable conflict rather
than last-write-wins replacement. An external catalogue declaration retains
the URL, captured declaration/digest, and review provenance; it does not become
a quotation from the book.

Scopes must be properly nested or disjoint, with exact byte boundaries.
Resolve defaults from the nearest reviewed/accepted enclosing scope, then
apply an explicit support-level override. Reject ambiguous overlaps. Defaults
are pinned to description versions in the published generation. Updating an
author or edition description does not silently rewrite the interpretation of
old generations.

Support descriptions are unique for a support at any generation. Description
and relation edits append new versions and close the prior version atomically.
They do not alter source text or imply a newly captured source revision.

If enrichment changes the support's stance, directness or polarity, publish a
replacement through the existing support validation/publication path under
the new contract identity and close the superseded support version. Keep those
semantics owned by `claim_support`; descriptions must not hold a contradictory
second truth. Preserve the old support and its provenance for historic readers,
and preserve the underlying source-span citation in the replacement. Ordinary
author/origin/date annotation can retain the same support ID.

Claim identity already includes qualifiers and effective dates. Changing
historical meaning therefore creates/reuses a new claim identity and records
the old-to-new qualification in existing maintenance decision history. Move
only the supports that justify the new period; an undated or differently dated
support cannot automatically inherit another source's date. Preserve the old
claim while any of its active support remains. Conflicting dates remain
competing qualified claims, not a forced union of periods.

Keep support-specific quotation wording and provenance out of canonical claim
meaning so two independently phrased sources can support the same dated claim.
Reserve `qualifiers.modality` for asserted/proposed/hypothetical meaning: a
proposed reporting line and an adopted reporting line must not coalesce merely
because their endpoints and dates match. Existing unclassified assertions
retain their historical identity until assessed; do not rewrite all claim IDs
merely to attach a new schema default. Canonicalization must be deterministic
and tested before hashing.

Known derivation relations provide evidence families at retrieval time.
Report raw support count, known dependent families and unknown independence
separately. The existing chunk-derived `lineage_group` is legacy extraction
grouping, not proof of independent origin. Do not simply collapse everything
in one book: a book can quote independent witnesses. Do not treat absence of a
known link as proof of independence, and do not introduce an automatic truth
score based on primary/secondary labels.

## 4. Producer and public controls

The owning changes are in schema/repositories, folder ingestion, the shared
application provider mapper and claim validator, maintenance qualification,
retrieval/evidence serialization and their public adapters. Gemini, Codex and
local generation use the same enriched proposal contract.

Extend the existing plan/apply vocabulary with two bounded inputs:

1. `ingest plan --metadata-input FILE`: an optional versioned metadata manifest
   bound to exact source IDs/revision digests or selected folder files and
   content digests. `ingest apply` applies its frozen metadata together with
   ordinary new-source work. For unchanged text, classify metadata-only work
   explicitly, retain revisions/chunks/vectors and queue no extraction unless
   the plan requests it. Reapplying identical metadata must be a zero-call no-op.
2. `maintain plan --enrich-provenance --input FILE`: an explicit bounded list
   of existing claims/support chunks and metadata versions to assess under
   the new contract. The existing `maintain apply`, configured worker group,
   call/token/deadline controls and citation-repair loop execute it. The plan
   reports assessment coverage and its maximum initial/correction calls.

These proposed flags are **new**, not commands that can be run today. CLI,
JSON/NDJSON, MCP and ADDRESS expose the same operation fields. This keeps
metadata capture and reprocessing in the existing application workflows.

The extractor receives applicable source/section metadata with identifiers,
and requests period expressions, stance, voice, evidence origin and derivation
alongside each proposed relationship. Each new value must cite its supporting
text or an allowed metadata declaration. The application locates quotations
and validates identities, enums, periods, inheritance and referenced evidence;
providers never supply trusted byte offsets or SQL writes.

The LLM selects date expressions and their role; deterministic parsing handles
supported literal forms. An unrelated year elsewhere in a chunk is not enough
to date a claim. Require evidence connecting the date to that relationship.
Inferred, ambiguous or ungrounded values remain unknown or go to review.
Changing only the prompt cannot solve the current mapper's empty-field issue.

Continue the existing one-shot citation correction and whole-response
validation policy. Do not add fuzzy matching, recursive retries or partial
acceptance as part of this change. A valid `unknown` is an acceptable result;
malformed or fabricated precision is not silently discarded to make a response
pass. Persisted receipts bind the proposal contract version; older receipts
are decoded under their original version, never reinterpreted as new output.

For new captures, replace the public folder route's `surface-apply` placeholder
with a real UTC observation timestamp. For legacy captures, preserve the raw
value. A metadata record may state a recovered time only if an audit record
actually establishes it, with its provenance; otherwise public capture time
is unknown and the raw marker remains inspectable.

## 5. Retrieval, timelines and answers

Return source description, resolved voice, origin, document status, stance and
qualified time with each support. Stop deriving historical `asserted_at` from
capture time. Return assertion time per support, since different sources can
assert the same claim at different times. Expose system capture separately.

Version the affected evidence, answer-context and timeline payloads to `/2`
where semantics change, while retaining command-result envelopes and command
names. Update first-party consumers together. Old libraries are migrated on
copies and old `/1` proposals/receipts remain readable with unknown new fields;
do not quietly emit a new meaning under an unchanged schema identifier.
No claim of transparent compatibility with unmodified strict external `/1`
consumers is made. This is an explicit API change to approve.

Add optional `query ... --at DATE` and `--during START/END` using the same period
parser, with `--time-unknown include|exclude` (default include, separately
labelled). Filtering applies to historical validity, not publication dates.
The existing `--generation`/generation binding, where supported, remains
database history and must not be overloaded with historical time.

Exclude definitely incompatible graph edges during temporal traversal.
Distinguish definite, possible and unknown temporal compatibility. A path
claimed to be contemporaneous needs a common compatible period across the
whole path, not merely pairwise overlap. Unknown edges remain labelled leads
when included. Without a time filter, retain historical paths with their dates;
do not pretend that a sequence of events happened simultaneously or infer a
new factual A-to-C relationship from an A–B–C path.

Timeline output separates historical claim periods, assertion/publication
dates and raw text-year mentions. Sort comparable entries chronologically with
stable tie-breaking; group unresolved dates separately. Text-year mentions
remain research leads, not extracted historical events.

Answer context must retain these distinctions even under truncation. A draft
proposal must not answer “what was in force?” as an enacted fact; primary does
not automatically outrank a supported correction; quotation does not imply
endorsement; two dependent accounts do not imply independent corroboration.
Use the existing notes/gaps and citation machinery to surface what is unknown.

## 6. Existing-data update and preservation

Recommended working baseline: a new update copy of the preserved **post-four-
worker generation 8910**, with 1,650 claims and 1,773 supports. The shorter
eight-worker run ended at generation 8454 with 1,451 claims; it remains scaling
evidence and is not merged into or substituted for the richer baseline.
The original live library and all measured before/after copies stay preserved.

1. Verify and back up the selected copy, record schema/semantic/config/vector
   identities and the exact executable SHA. Apply schema migration first with
   no provider calls and no reinterpretation of existing dates or support.
2. Prepare two reviewed source descriptions from the actual volume title pages
   and edition evidence. Record author/editor roles, work/edition linkage and
   publication dates only where verified. Do not guess the edition from a
   Gutenberg release date. Mark unsupported fields unknown.
3. Apply that metadata as a graph/metadata generation, preserving source and
   chunk IDs and every existing citation. Mark legacy support provenance as
   unassessed; do not label all blank attribution as a failed extraction.
4. Assess the existing claims' supporting text through the new bounded
   provenance task. The current census has **1,180 distinct supporting chunks**;
   review each once, considering all its supported claims, and allow at most
   one correction. Pin the complete worklist and relevant metadata to the plan.
   This is enrichment of existing assertions, not whole-book reingestion or
   unrestricted discovery of new concepts.
5. Publish accepted descriptions and qualified claims incrementally under the
   existing transactional and worker-fencing rules. Stale inputs must be
   replanned explicitly; failed/ambiguous items remain visible as unassessed or
   pending review. An undated conclusion can be a successful assessment.
6. Verify old citations, byte-identical source/chunk/vector rows, graph support,
   metadata coverage, temporal invariants, backup/restore and repeated no-op
   behavior. Produce a coverage ledger: assessed-dated, assessed-undated,
   disputed/review and not-yet-assessed. Do not call a partial pass complete.

Proposed backfill bound for approval: **1,180 initial Luna-low calls plus at
most 1,180 corrections (2,360 total), four configured workers, and four hours
elapsed**, with aggregate caps of 80 million input and 20 million output
tokens and at least 10% subscription allowance remaining. No embedding calls
are needed when text and embedding inputs are unchanged. The exact reviewed
census can lower these ceilings. If it grows or the bounds leave unfinished
work, report the gap and a bounded continuation rather than silently extending
the run. Actual usage and assessment coverage remain the acceptance evidence.

Use current source descriptions to supply bibliography, but do not overwrite
old historical generations with new interpretations. Metadata-only changes
reuse a compatible published vector generation. Future metadata must not be
prepended to embedding text under this proposal; doing that would require a
separate reviewed embedding-input change and rebuild.

Rollback is restoration of the verified pre-migration copy with its matching
executable, not a destructive in-place down-migration. Metadata mutations
require generation/config/content-digest checks; stale proposals cannot apply
across changed sources or descriptions. Resume uses durable receipts and the
same worklist, avoiding duplicate provider calls.

## 7. QA and the small Luna validation

Before applying to the corpus, run focused deterministic tests, then the full
Debug suite for schema/provider/worker/retrieval changes. Include the Gemini
fixture route, malformed-output and secret-redaction negative cases, and both
supported VM paths. These fixture tests make no hosted calls.

Required checks include unknown versus explicitly open periods; approximate
and year-only dates; invalid/reversed dates; calendar uncertainty; unrelated
date quotations; narrator and quoted-voice inheritance; draft versus accepted
claim status; primary evidence about an author's opinion versus secondary
evidence about an event; dependent sources; temporal claim splits with only
the appropriate supports moved; concurrent stale metadata rejection;
zero-call idempotency; receipt recovery; snapshot/backup and old citation
preservation; and temporal paths with no common period.

After implementation and the existing-data update, run the requested small
end-to-end Luna check in a **separate library** with one new synthetic test
source containing eight short, explicitly labelled records. They cover:

1. Published narrator account with publication and event years differing.
2. A dated primary letter and a quotation of it by another author.
3. An explicitly derived account identifying that upstream letter.
4. A draft proposing a future relationship.
5. A later final document explicitly adopting that relationship for a period.
6. An approximate event date and an unknown interval endpoint.
7. An undated assertion that must stay undated.
8. Two grounded relationships whose periods cannot form a contemporaneous path.

Freeze the text, expected meanings and query questions before the live run.
Keep each record within one chunk; no automatic expansion beyond eight.
This fixture proves behavior against known answers; it is not a historical
accuracy assessment. The existing-data coverage review supplies real-corpus
evidence. A small real new source can replace a fixture only after its exact
edition, spans and expected interpretations are documented, without increasing
the approved bound.

Proposed live validation budget: Luna with low reasoning, **eight initial
extractions plus at most eight corrections**, two configured workers, ten
minutes elapsed, 600,000 input and 140,000 output tokens, with at least 10%
allowance remaining. If normal new-source ingestion requires vectors, allow
one Gemini embedding batch for these eight chunks at 768 dimensions, capped
at $0.01. Total provider-call ceiling is 17. Read-only lexical evidence, path
and timeline checks then make no additional hosted calls. Hosted answer
generation is excluded from this small call budget; its context/negative cases
are covered deterministically.

Pass requires all eight records to be accounted for; correct supported time,
voice, status and origin; expected unknowns retained; derivation not counted
as independence; drafts and incompatible periods handled correctly by the
queries; exact citations; and clean worker, reservation and usage settlement.
A schema-valid but wrongly attributed or wrongly dated result is a failure.
Record initial failures, corrections, final results, per-field accuracy against
the frozen expectations and subscription counters. Do not repair the expected
answers to match model output or declare success from a zero exit code alone.

## Approval recorded

The user approved this proposal on 8 September 2026: the recommended semantics
and three-table extension, the explicit versioned evidence API change, the
preserved-copy update of the 1,650-claim baseline within its stated backfill
ceilings, and the bounded eight-record Luna validation. This approval does not
declare implementation or live validation complete. Any materially different
source target, schema scope or call budget requires a separate proposal.
