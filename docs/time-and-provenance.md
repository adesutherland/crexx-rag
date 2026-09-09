# Time and provenance

Schema 11 adds versioned source descriptions, source relationships and support
descriptions. SQLite remains authoritative. Source bytes, chunk boundaries,
existing citation IDs and compatible vector sidecars are preserved when only
metadata changes. The original design and experiment history are recorded in
[the proposal](claim-time-provenance-proposal.md).

## Default: document metadata

The ingestion UI sets `document_date` to today's local date when no document
date or writing/publication period is supplied. Use `ingest --document-date
YYYY-MM-DD` to supply a date. It is saved once in document metadata and reused
on unchanged ingestion. This default is a general document date, not an inferred
historical event or publication date.

Record a document's writing or publication date once against its source
revision, with its date kind and supporting evidence. Chunks and citations
resolve that metadata through their existing source links. Ordinary ingestion,
improvement and maintenance do not ask the LLM to assess each claim's date,
voice or evidence origin. Adding or correcting document metadata alone queues
no provider calls and does not change claims or vectors.

For fresh files, supply known bibliographic information with `--metadata-input`
in the same ingest plan. Automatic title-page or catalogue date discovery is
not implemented. Missing dates remain unknown. A publication date describes
the document; it never becomes the date of every event described in it.

Per-support historical and provenance assessment is a separate, explicitly
requested experiment. It is not required to link document dates. Previously
frozen assessment inputs and receipts retain their original validation contract;
changing the default does not silently rewrite queued work.

## Separate meanings

A claim's `qualifiers.temporal` describes when its relationship held;
`qualifiers.modality` is `asserted`, `proposed` or `hypothetical`. Each support
can separately record its voice, assertion period and evidence origin. Source descriptions
separately record contributors, writing/publication periods and document status
(`unknown`, `draft`, `final`, `published`, `withdrawn`). Capture is a system
observation. Neither capture nor publication supplies an otherwise unknown
historical or assertion date.

Evidence origin is claim-relative: `unknown`, `primary`, `secondary`, `derived`
or `mixed`. Acceptance means application validation, not historical truth.
Explicit upstream relations identify known evidence families. Missing links
mean unknown independence; chunk lineage does not prove independence.

## Metadata manifest

`ingest plan --metadata-input FILE` reads a bounded JSON manifest. Its root is
`{"schema":"crexx-rag.source-metadata/1","descriptions":[],"relations":[]}`.
It is frozen in the normal reviewed ingest plan. Apply with `ingest apply`.
An unchanged source revision yields `metadata-only`, or `identical-no-op` when
the same metadata is already present, and queues no provider work. Source
identity includes location and extraction policy as well as text. For older
libraries retaining `file:./` paths, run from the original source directory so
those paths resolve to the same files. Planning rejects metadata that targets
a revision the source plan would replace or delete.

Every description has these required members:

| Member | Value |
|---|---|
| `revision_id` | Exact revision ID, or `file:relative/path.txt` for a file in the selected source set |
| `text_digest` | SHA-256 of the exact normalized UTF-8 source text |
| `scope_start`, `scope_end` | Zero-based UTF-8 byte boundaries; both `-1` for the whole revision |
| `expected_description_id` | Empty for creation; active description ID for an explicit correction |
| `description` | Nonempty subset of the fields below |
| `provenance` | One grounding record for every description field |

Description fields are `title`, `work_ref`, `edition_ref`, `contributors`,
`document_status`, `written_period`, `published_period`, `asserted_period` and
`captured_at`. A contributor has `label`, `role` and `concept_id` (empty when no
catalogue identity is established). Roles are `author`, `editor`, `translator`,
`compiler` and `collective`. Capture corrections require an explicit UTC
`YYYY-MM-DDTHH:MM:SSZ` observation with evidence; legacy raw markers remain.

Grounding records have `method`, `actor`, `review`, `reference` and `quote`.
Methods are `operator-declared` or `deterministically-parsed`; review is
`reviewed` or `machine-validated`. A reference or quotation is required.
Quotations must match the exact source scope through the normal grounding
validator. A declaration reference identifies retained evidence, for example a
local captured catalogue record plus its digest and original URL. It does not
become quoted book text. The manifest's actor and review labels record the
submitter's declaration; they do not authenticate a human reviewer.

Scopes must nest or be disjoint. The nearest enclosing description supplies
field defaults, with description-version IDs retained in resolved provenance.
A quote or report with no identified speaker does not inherit the narrator.
Its assessment goes to review. A normal narrative can inherit a single known
author. Publication and writing periods do not imply assertion time.

A relation has `revision_id`, `text_digest`, `scope_start`, `scope_end`,
`target_revision_id`, `external_work_ref`, `relation_type`,
`expected_relation_id` and `provenance`. Exactly one target form is nonempty.
Types are `quotes`, `reports`, `derived-from`, `revises`, `edition-of`.
External works remain references, not ingested evidence. An empty expected ID
adds a relation; an active expected ID replaces that relation atomically.
Conflicting stale descriptions or relations require a fresh reviewed plan.

## Period values

Every period is a `period/1` object with exactly `schema`, `kind`, `start`,
`end`, `end_condition`. Kind is `point`, `interval`, `unknown` or
`not-applicable`; end condition is `bounded`, `open` or `unknown`. Each endpoint
has exactly seven string members:

```json
{"value":"1745","precision":"year","certainty":"stated","calendar":"unspecified","constraint":"on","earliest":"","latest":""}
```

Precision is `day`, `month`, `year` or `unresolved`; certainty is `stated` or
`approximate`; calendar is `gregorian`, `julian`, `old-style` or `unspecified`;
constraint is `on`, `before` or `after`. Empty endpoints use empty value/bounds,
`unresolved`, `stated`, `unspecified`, `on`. Unknown periods use two empty
endpoints and an `unknown` end condition.

Supported ISO and English literal dates normalize deterministically. The
application does not convert historical calendars or infer dates from relative
wording. A year is an occurrence envelope, not a year-long event. Approximate
dates gain no invented margin. Unstated calendars stay unspecified and yield
unknown exact comparison. Gregorian inference is permitted for an explicit ISO
day expression; otherwise its calendar must be stated in the quotation.

## Optional experiment: assess existing support

The first corpus trial had a high validation failure rate. Keep this workflow
separate from normal ingestion and require a small qualified trial before
another corpus-wide run.

Prepare a file containing only the selected supporting chunk IDs:

```json
{"schema":"crexx-rag.provenance-worklist/1","chunks":["revision-chunk-sha256:…"]}
```

Run `maintain plan --enrich-provenance --input FILE` with the normal configured
library, source/profile and maintenance timing controls, then `maintain apply`
and the configured worker group. The plan freezes the existing supports and
applicable metadata, with maximum initial and one-shot correction counts.
Already assessed chunks disappear from the census; repeating a completed
worklist performs no calls. No new discovery or embedding tasks are added.

Each response must account for every support in its packet. Malformed or
ungrounded fields reject the whole response; the existing one-shot citation
correction can retry supported grounding failures. Unknown voices, low
confidence and policy conflicts retain the whole packet for review. Stale
metadata fails before a new call or publication. Pending/failed/review records
remain visible and do not count as completed assessment coverage.

Historical qualification creates a new claim identity. Only the supports that
ground that qualification move; independent undated support stays attached to
its original claim. Stance, directness or polarity changes use the normal
replacement-support validator. Author/origin annotations can retain support
identity. Durable receipts prevent a settled assessment from being paid again
after worker recovery.

## Queries and compatibility

Queries accept `--at DATE` or `--during START/END`, plus
`--time-unknown include|exclude` (default `include`). These select historical
validity, separately from database generation. Graph expansion excludes
incompatible edges and rejects filtered paths without a common possible
period. Unknown and possible compatibility remain labelled; graph paths do
not establish an additional factual relationship between their endpoints.
Proposed/hypothetical edges remain qualified results and do not expand a
factual chain.

Evidence, retrieval results, answer context, paths and timelines now use `/2`.
Old `/1` extraction proposals and receipts remain readable under their original
contract. Command-result envelopes stay `/1`; JSON-valued command fields remain
JSON strings, as before. Strict external evidence `/1` consumers must update.

Timelines separate historical validity, support assertion time, writing and
publication. Comparable Gregorian envelopes sort separately from unresolved
periods. Raw textual years are labelled research leads. Answer context retains
all qualifications of each included record. Under its byte ceiling it can omit
whole records, reporting counts and an incomplete-context warning; mandatory
ambiguities, gaps and guidance are retained or encoding fails explicitly.

Source inspection and citation resolution return current source metadata;
evidence pins metadata to its retrieval generation. New capture observations
use UTC. Legacy raw capture values remain inspectable and unsupported actual
capture times are empty.
