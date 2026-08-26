# Algorithm

This document describes the maintained implementation, not an aspirational RAG
design. The central rule is that retrieval can discover passages and leads, but
only a validated, directional, source-supported proposal can become a graph
claim.

## End-to-end shape

```text
source bytes
    |
    v
normalize -> immutable revisions -> deterministic chunks
                                      |
                         capitalized candidate census
                                      |
                                      v
                       bounded structured extraction
                                      |
                       normal cREXX validation/review
                                      |
                                      v
                 concepts + aliases + typed claims + support
                                      |
            +-------------------------+-------------------------+
            |                         |                         |
       lexical route             vector route              graph route
            +-------------------------+-------------------------+
                                      |
                       weighted rank fusion and diversity
                                      |
                                      v
             passages + claims + ambiguities + leads + gaps
                                      |
                         human or agent analysis
```

SQLite is authoritative at every stage. The `.rxvec` generation is a
rebuildable vector publication, never an independent source of claims.

## Ingestion and concept discovery

### 1. Observe, normalize, and identify

A source connector supplies a stable key, URI, title, media/encoding data,
captured bytes, privacy class, and retention policy. The current folder route
accepts UTF-8. Normalization validates UTF-8, converts CRLF/CR to LF, and keeps
a byte-offset map from normalized text back to the original artifact.

Source, revision, text, chunk-content, and chunk-occurrence identities are
content derived. A changed source creates a new immutable revision and a new
published semantic generation. Unchanged content can be reused and existing
support can be re-anchored. An unchanged complete source set produces an
`identical-no-op`.

### 2. Make deterministic chunks

The selected profile defines format and maximum chunk size. The chunker first
uses format-aware block boundaries, then a bounded whitespace break when a
block is too large. It records normalized UTF-8 start/end offsets, an evidence
class, content digest, parser/policy fingerprint, and occurrence identity.

The same chunk body can occur in more than one revision. `content_id`
identifies reusable content; `revision_chunk_id` identifies its position in one
immutable revision. Citations always use the revision occurrence and absolute
UTF-8 byte span.

### 3. Find candidate mentions without an LLM

The first concept-discovery pass is deterministic. It records word-like tokens
of at least three characters whose first character is uppercase. Letters,
digits, hyphens, and underscores can remain within the token. Each occurrence
gets a stable candidate id and exact span.

A candidate is admitted to the extraction catalog when its normalized label
appears at least twice in the active generation or in at least two distinct
sources. Otherwise it is retained in `review` state. This census is deliberately
conservative: a one-off proper name is not silently presented to the extractor
as a canonical endpoint.

### 4. Ask for one bounded relationship

For each new chunk, ingestion queues two independent durable items:

- embedding generation for the chunk; and
- claim extraction from the chunk.

The extraction request contains the chunk, accepted candidate ids and spans,
profile-permitted concept types, and profile-permitted relationship types. The
provider must return a strict structured object containing either no supported
claim or one directional relationship between two supplied candidates.

The application rejects malformed JSON, unknown candidate ids, invented types
or relationships, self-pairs, invalid confidence, mismatched provider/model
identity, and incomplete provenance before normal claim validation runs. The
current adapter binds the proposed support span to the full supplied chunk;
normal validation still verifies that exact UTF-8 span against the active
revision.

### 5. Promote mentions to concepts

Only candidate ids selected by a validated provider result are promoted.
A canonical concept id is derived from the lower-cased canonical label plus its
profile type. Promotion creates or verifies:

- the canonical concept and type;
- normalized aliases;
- a mention tied to the candidate's source span; and
- an explicit ambiguity record rather than a guessed resolution when multiple
  active concepts are supplied as possible targets.

An alias collision cannot overwrite an existing canonical mapping. It requires
review. Concepts therefore emerge from the combination of deterministic
candidate evidence, bounded provider classification, and deterministic cREXX
promotion—not from embeddings or free-form model memory.

### 6. Validate and publish the claim

The claim validator checks:

- schema, stable identity, provider/model/request and prompt provenance;
- the deterministic confidence threshold of 0.5;
- profile concept and relationship registries;
- outbound/inbound direction, support/contradiction polarity, stance,
  directness, attribution, lineage, and effective time;
- the active chunk and UTF-8 evidence span;
- immutable canonical labels and endpoint types;
- self-relationships, endpoint ambiguity, and competing claims; and
- whether the proposal came from an external agent.

A clean internal proposal creates a content-derived directional claim and a
separately addressable support row in a new generation. Low confidence,
unresolved endpoints, ambiguity, conflict, type mismatch, or external origin
goes to review where applicable. Provider output never writes graph tables
directly.

## Query planning

The query planner lower-cases and whitespace-normalizes a question, binds it to
the current generation and retrieval policy, and creates a fingerprinted set
of variants:

- normalized original words;
- quoted or explicitly requested exact phrases;
- profile aliases;
- active library aliases;
- focused non-stopwords;
- a spelling candidate with edit distance at most two; and
- a prefix variant for the final focused term.

It also records per-term occurrence/chunk/source-diversity statistics,
unresolved aliases, and simple intent flags for time, comparison, relationship,
and focused questions. The three retrieval routes consume the same immutable
query plan.

## The three search routes

### Lexical route

Each query variant runs against SQLite FTS using BM25 order. Results are
converted to stable ranks; raw BM25 values are not compared across variants.
The route keeps candidates within the lexical ceiling, then adds immediately
adjacent chunks from the same revision while capacity remains. Adjacency adds
reading context but is not evidence of a graph relationship.

Lexical search is always available for a valid library and makes no provider
call. `mode: lexical` is therefore the deterministic zero-outbound-call route.

### Vector route

The vector route is optional. A query embedding must match the configured
embedding profile and dimension. Retrieval also requires an aligned manifest
and exactly one published `.rxvec` generation for the current semantic
generation, model profile, and dimension.

The present implementation is exact, not approximate. It pages active
embedding blobs from SQLite, computes cosine similarity with `rxvector`, and
ranks the global top results. The published `.rxvec` sidecar is the compatible
generation/publication gate; the exact search currently reads the authoritative
SQLite embedding rows rather than an ANN structure in the sidecar.

If the query dimension, manifest, vector generation, or configured scan ceiling
is incompatible, automatic retrieval reports an explicit vector fallback and
continues with lexical and graph routes. Explicit hybrid mode requires its
configured embedding call to succeed. The returned `vector_state` records what
actually happened.

### Graph route

Graph retrieval begins with concept anchors. An active canonical label can
anchor directly when it occurs as a bounded phrase in the normalized question.
Concept mentions found in lexical or vector candidate chunks add further
anchors.

From those anchors the current evidence retriever follows supported outbound
claims for up to the configured hop limit, currently zero to four. Every graph
hit comes from an active claim with active support. Its supporting chunk is
added as a passage candidate, the hop is recorded, and direct support receives
a directness signal. Direction is preserved; a reverse relationship is not
inferred.

Graph traversal discovers typed paths and support that ordinary text matching
may miss. It does not turn co-occurrence, vector similarity, or adjacency into
a claim.

## Fusion, diversity, and evidence assembly

The route ranks are combined with weighted reciprocal-rank fusion:

```text
route contribution = profile route weight / (rrf_k + route rank)
```

The default `rrf_k` is 60. Profile weights are used for lexical, semantic, and
graph routes. The fused score then receives:

- a graph-hop boost of `0.04 * 0.75^(hop - 1)`;
- `0.02` for direct support;
- `0.01` temporal relevance when a time question meets dated evidence;
- `0.02` for narrative source quality or `-0.02` for index/caption material;
  and
- `-0.05` for repeated content already selected.

Selection is deterministic, with chunk id as the final tie-break. At most three
passages from one source are selected, and the current passage ceiling is 12.
The evidence packet retains route channels and score components so an agent can
inspect why a passage appeared.

Accepted claims are returned only when they have active support and at least
one supporting chunk survived passage selection. Their support citations retain
polarity, stance, attribution, lineage, and time. Claim conflicts remain
visible. The evidence confidence field for an accepted claim is currently a
validation marker of `1.0`, not a calibrated probability; provider confidence
was already used at the promotion gate.

## Leads, gaps, and important notes

The evidence packet intentionally separates three levels of material:

| Output | Meaning | May an agent state it as fact? |
| --- | --- | --- |
| Accepted claim plus support | Directional graph assertion that passed validation | Yes, with its support citation and qualifications |
| Ranked passage | Relevant source text selected by one or more routes | Only what the cited passage itself supports |
| Ambiguity, graph lead, or gap | A warning or a promising next question | No; it requires further evidence or review |

A graph lead is currently created when a selected passage contains at least two
promoted concept mentions. It records up to three concept labels and mention
ids and says explicitly that co-mention and adjacency do not establish a typed
relationship.

General gaps are emitted when no passage matched, a relationship question has
no supported directed claim, a name remains ambiguous, or vector retrieval
fell back. The current policy also has a small set of deterministic
explicit-negative recognizers for exact phrases, relationships, datastore
evidence, replica freshness, collective attribution, and unresolved verdicts.
These prevent a returned denial or limitation from being turned into a broader
positive claim.

These fields are the current form of “important notes” for a high-capability
agent. There is no durable free-form autonomous notebook and no model-generated
hypothesis is promoted merely because it sounds important. The evidence packet
provides cited passages, typed facts, unresolved leads, and explicit gaps as
separate inputs for deeper analysis.

## Improvement selection

`crexxrag improve` is bounded re-extraction, not model self-training. It scans
one active occurrence of each distinct chunk content and computes a stable
priority score:

```text
100  * candidate-mention count
+ 350 * relationship-cue count
+ 1000 when the chunk has no extracted support
- 100  * repeated-content count
+ 200  * (candidate count - 1) when candidate count is at least two
+ 500 for ordinary evidence, or 300 for code
+ 50   * unresolved-candidate count
```

Relationship cues currently include “depends on”, “uses”, “calls”, “owns”, and
“reports”. Selection is controlled by explicit sorted triggers:

- `bridge`: at least two candidate mentions could connect concepts;
- `conflict`: a pending conflict review points to the chunk;
- `operator-review`: any pending review points to the chunk;
- `profile-change`: reconsider every eligible distinct content item;
- `unprocessed-extraction`: no claim support has been extracted;
- `unresolved`: candidate mentions have not reached accepted state; and
- `weak-support`: support is negation or speculation.

The highest-scoring items are selected within item, call, token, cost or
allowance, time, concurrency, and attempt ceilings. Ties are resolved by stable
chunk id. Apply revalidates the exact plan, generation, config, route, privacy,
and budgets before it queues durable `improve-extraction` work.

The extractor receives the same bounded chunk and accepted candidate catalog
as ingestion. It may find one new supported relationship, return no claim, or
create a review. Improvement does not ask a model to rewrite source material,
invent concepts, or create unconstrained research notes.

## Workflow for deeper agent analysis

A high-capability agent should use the library as an evidence substrate:

1. Request `query evidence`, preferably lexical first when privacy or provider
   availability is uncertain.
2. Separate accepted claims from passage-only observations, ambiguities,
   leads, and gaps.
3. Use `query trace` to inspect variants, route states, candidate/selection
   counts, and the generation-bound trace identity.
4. Use `query path` for typed relationships or `query timeline` for temporal
   evidence instead of inferring those views from prose.
5. Follow promising leads into cited source spans or additional sources and
   state what remains absent.
6. If deeper analysis proposes a new normalized claim, submit it through
   `proposal plan`; apply can only create a mandatory pending review, and a
   human must explicitly decide promotion.

This handoff lets a stronger agent reason across evidence without confusing its
analysis with the library's accepted graph state.

## Current deliberate limits

- Candidate census is a conservative capitalized-token heuristic, not general
  named-entity recognition.
- One extraction turn proposes at most one relationship for a chunk.
- The current application adapter cites the full chunk for extracted support.
- Vector retrieval is an exact bounded scan, not an approximate nearest-neighbor
  index.
- The evidence graph route follows outbound supported claims; it does not infer
  inverse edges.
- Co-mentions and gaps are analysis leads, not claims.
- Free-form agent notes are not a durable product object today; important
  analysis must remain in evidence packets or enter through reviewed external
  proposals.

These limits are useful when judging future changes: improving recall or agent
analysis must not weaken citation identity, directional claims, deterministic
review, privacy classification, or plan-bound authority.
