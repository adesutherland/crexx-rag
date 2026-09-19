# Methodology and algorithms

This document defines the required completed methodology for `crexxrag`. It is
the acceptance contract for the implementation work. Temporary implementation
gaps belong in the approved work plan and test evidence, not as permanent
exceptions in this methodology.

The central rule applies to both: retrieval and an LLM may discover passages,
concepts and leads, but only a validated, directional, source-supported
proposal can become a graph claim. SQLite owns the canonical state; provider
output never owns it.

## End-to-end shape

```text
source bytes
    |
    v
normalize -> immutable revisions -> deterministic chunks
                 |                    |
                 |       glossary + lexical seeds + LLM discovery
                 |                    |
                 v                    v
       embedding generation    bounded semantic extraction
                 |                    |
                 |          normal cREXX validation/review
                 |                    |
                 |                    v
                 |      concepts + aliases + typed claims + support
                 |                    |
                 +--------------------+
                                      |
                         publish vector generation
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

The deterministic ingest apply transaction queues work but makes no provider
call itself. The guided human command then supervises the embedding and
extraction workers and publishes the compatible vector generation. A displayed
apply-stage count of zero provider calls must not be interpreted as a
deterministic-only completed ingestion.

## Enrichment and readiness methodology

The product lifecycle makes the transition from captured text to a query-ready
library explicit:

```text
capture -> enrich -> validate -> consolidate -> publish ready
              |          |            |
              |          |            +-> catalogue/graph proposals
              |          +-> deterministic checks and bounded LLM critique
              +-> embeddings plus concept/claim extraction

query gaps, reviews and profile changes -> targeted maintenance -> validate
```

The stages are:

1. **Capture:** deterministically observe, normalize, identify, chunk and build
   lexical projections.
2. **Enrich:** generate embeddings and ask a bounded extractor for zero or more
   exact-span concept mentions and directional claim proposals. Deterministic
   candidates are seeds, not the provider's complete vocabulary.
3. **Validate:** check schemas, exact UTF-8 spans, permitted types and
   relationships, provenance, privacy, budgets, canonical conflicts and
   generation identity. A separately prompted cognitive critic may recommend
   accept, reject or review for ambiguous or high-value material, but cannot
   write canonical state.
4. **Consolidate:** review cross-chunk aliases, duplicate concepts, possible
   splits, conflicts, omissions and important evidence-backed leads.
5. **Publish usable:** publish independently valid extraction and embedding
   results even when other work is in dead letter. A vector generation may
   cover the compatible embeddings already available; its row count and the
   active-chunk census expose the remaining gap for maintenance.
6. **Maintain:** use current claims, previous attempts, pending reviews,
   retrieval gaps, neighbouring evidence and model/profile changes to select a
   genuinely new review task rather than repeat the initial prompt blindly.

Embedding generation is therefore part of initial enrichment, not a later
maintenance repair. It is operationally essential for broad semantic recall, while
lexical retrieval remains necessary for exact names and graph retrieval remains
necessary for validated direction. Similarity never validates truth.

## Historic observation methodology

Raw history and summary history have different jobs. Publication events, jobs,
items, attempts, provider runs, reviews and maintenance records remain the
addressable source history. An observation snapshot is a derived, immutable
checkpoint used to compare corpus condition over time; it never replaces those
facts or makes an LLM summary authoritative.

Snapshot requests use a fixed top-10 deterministic census and compare its
semantic and operational digests with the newest retained point. The
`churn-matrix/2` decision is:

1. capture the first point;
2. suppress an exact digest duplicate;
3. score semantic change (100), vector publication/coverage change (70), health
   transition (100), active-to-settled jobs (60), material work backlog (50),
   material historical dead-letter change (40), material review/gap change
   (30), and maximum staleness (50);
4. allow semantic, vector, health and settlement changes through the 900-second
   cooldown; and
5. otherwise capture at score 50 or suppress with the exact reason.

Work and dead-letter materiality is the larger of 25 items or five percent of
the prior value. Review/gap materiality is the larger of 10 or five percent.
A non-identical point reaches maximum staleness after 86,400 seconds. Repeated
equivalent suppression decisions increment a count on one content-addressed
row. This makes frequent evaluation cheap without erasing evidence that the
policy was applied.

Each captured point binds generation, profile/configuration, vector
publication, deterministic report, work backlog, historical dead letters,
reviews/gaps, health attention and a matching validated narrative if present.
Trend deltas are deterministic signed arithmetic over those points. With fewer
than two points the trend state is `baseline-only` and no direction is claimed.

## Ingestion and concept discovery

### 1. Observe, normalize, and identify

A source connector supplies a stable key, URI, title, media/encoding data,
captured bytes, privacy class, and retention policy. The current folder route
accepts UTF-8. Normalization validates UTF-8, converts CRLF/CR to LF, and keeps
a byte-offset map from normalized text back to the original artifact. Planning
keeps only the normalized text needed for identity; it does not materialize a
per-character coordinate matrix. When a changed revision is applied, the map
is streamed directly into SQLite as coalesced line spans plus explicit
line-ending contractions. The version-1 contract does not perform NFC, NFD, or
other Unicode normalization, because that would change digests, offsets, and
content identities.

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

### 3. Discover candidate mentions and concepts

Concept discovery combines three inputs:

1. An optional operator-supplied UTF-8 glossary provides canonical labels,
   permitted types, aliases and deliberately excluded terms. Its path is
   selected by configuration; its content digest and interpretation policy are
   frozen into the reviewed ingest or maintenance plan. Glossary entries seed
   catalogue identity but do not constitute evidence for a graph claim.
2. A deterministic scanner records exact-span lexical candidates. Capitalized
   tokens, repetition, source diversity and similar bounded rules are useful
   cheap signals, but this scanner is a weak fallback and ranking aid rather
   than the complete concept-discovery method.
3. A structured LLM review can propose additional exact-span mentions,
   multiword concepts, lowercase concepts, canonical labels, aliases and types
   even when the deterministic scanner did not seed them.

The selected profile/configuration controls whether ingestion reviews all
changed chunks, only deterministically ranked chunks, or explicitly assigns
cognitive review to the maintenance census. It may disable LLM review only as a
reported degraded fallback. The reviewed plan must display and bind the
discovery mode, glossary identity, selected chunks, privacy route and provider
budgets. Maintenance always includes unresolved and previously unreviewed
concept work in its census and performs bounded LLM discovery for the selected
work when apply is authorized.

Every proposed mention must identify an exact UTF-8 source span. cREXX verifies
the span, source generation, glossary constraints, profile type and alias
conflicts before the proposal can affect canonical catalogue state.

### 4. Ask for bounded concepts and relationships

For each new chunk, ingestion queues two independent durable items:

- embedding generation for the chunk; and
- claim extraction from the chunk.

The extraction request contains the chunk, glossary and deterministic seeds,
existing relevant catalogue state, profile-permitted concept types, and
profile-permitted relationship types. The provider returns a bounded structured
object containing zero or more exact-span concept/alias proposals and zero or
more directional relationship proposals. Per-chunk mention, relationship,
response-byte and token ceilings are fixed in the reviewed plan; one provider
turn is not restricted to one relationship.

The application rejects malformed JSON, nonexistent spans or object identities,
invented types or relationships, self-pairs, invalid confidence, mismatched
provider/model identity, and incomplete provenance before normal claim
validation runs. Each relationship identifies the smallest exact source span
that supports it. cREXX verifies that span against the immutable revision. A
full-chunk span is valid only when the whole chunk is genuinely required as
support; it is never substituted merely because an adapter omitted a precise
span.

### 5. Promote mentions to concepts

Only exact-span glossary, deterministic or LLM proposals that pass validation
are promoted. A canonical concept id is derived from the lower-cased canonical
label plus its profile type. Promotion creates or verifies:

- the canonical concept and type;
- normalized aliases;
- a mention tied to the candidate's source span; and
- an explicit ambiguity record rather than a guessed resolution when multiple
  active concepts are supplied as possible targets.

An alias collision cannot overwrite an existing canonical mapping. It requires
review. Concepts therefore emerge from the combination of glossary and source
evidence, bounded provider classification, and deterministic cREXX
promotion—not from embeddings or ungrounded model memory.

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
- double- or natural single-quoted phrases, plus explicitly requested exact
  phrases;
- profile aliases;
- active library aliases;
- focused non-stopwords;
- a spelling candidate with edit distance at most two when the original term is
  absent from the active corpus; and
- a prefix variant for the final focused term.

It also records per-term occurrence/chunk/source-diversity statistics,
unresolved aliases, and simple intent flags for time, comparison, relationship,
and focused questions. The three retrieval routes consume the same immutable
query plan.

## The three search routes

### Lexical route

Each query variant runs against SQLite FTS using BM25 order. Exact phrases are
attempted first, and independent terms are attempted in ascending corpus
frequency so a broad early word cannot exhaust the lexical ceiling before a
rare discriminating word is considered. Results are converted to stable ranks;
raw BM25 values are not compared across variants. Multi-variant plans reserve
an equal bounded first-pass allowance for every variant. The route keeps
candidates within the lexical ceiling, then adds immediately adjacent chunks
from the same revision while capacity remains. An adjacent context chunk
inherits the direct hit's lexical rank so it is not stranded behind every
unrelated direct hit. Adjacency adds reading context but is not evidence of a
graph relationship.

Lexical search is always available for a valid library and makes no provider
call. `mode: lexical` is therefore the deterministic zero-outbound-call route.

### Vector route

The vector route is required for a profile to report hybrid-ready semantic
retrieval. A query embedding must match the configured embedding profile and
dimension. Retrieval also requires an aligned manifest and exactly one
published `.rxvec` generation for the current semantic generation, model
profile, and dimension.

Production vector execution supports the existing `ivf-flat-v1` approximate
index and the opt-in `exact-native-v1` backend. IVF remains the compatibility
default, with configured centroids, probes and training iterations. Exact native
search scans every float32 window in its binary sidecar using CREXX `rxvector`,
then checks only returned identities against SQLite visibility. It widens the
request until enough distinct visible parents exist and selects the highest
scoring window per parent. Exact-score ties use original row order (publication
orders by parent identity and embedding identity). The existing double `rxvector`
kernel and independently constructed wire/numeric controls remain in provider QA. Exact scanning is linear in index size, not an
approximate scale claim.

Both routes validate the profile, dimension, generation, membership and checksum.
The exact file stores vectors, opaque window labels and a small generation/profile
header, avoiding the IVF route's JSON membership traversal and per-window vector
reads. SQLite remains authoritative; native files are rebuilt from stored vectors.

Approximate search must meet a documented recall target against the exact oracle
on the same frozen inputs. Backend selection, rows searched, candidate count,
latency and any fallback are exposed in the query trace; the product must not
call an exact bounded scan a scalable index.

If the query dimension, manifest, vector generation, or ANN policy
is incompatible, automatic retrieval reports an explicit vector fallback and
continues with lexical and graph routes. Explicit hybrid mode requires its
configured embedding call to succeed. The returned `vector_state` records what
actually happened.

### Graph route

Graph retrieval begins with concept anchors. An active canonical label can
anchor directly when it occurs as a bounded phrase in the normalized question.
Concept mentions found in lexical or vector candidate chunks add further
anchors.

From those anchors the evidence retriever may traverse supported outbound
edges, inbound edges, or both according to explicit query intent/profile
policy, for up to the configured hop limit. Every graph hit comes from an active
claim with active support. Its supporting chunk is added as a passage candidate,
the hop is recorded, and direct support receives a directness signal.

Traversal direction and claim direction are separate. Following an incoming
edge is permitted, but the returned claim always retains its stored subject,
relationship and object. The retriever never manufactures an inverse claim
unless the profile contains a separately defined, evidence-valid inverse
relationship rule.

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

- a graph-hop boost of `0.002 * 0.75^(hop - 1)`;
- `0.001` for direct support;
- `0.001` temporal relevance when a time question meets dated evidence;
- `0.002` for narrative source quality or `-0.002` for index/caption material;
  and
- `-0.05` for repeated content already selected.

Selection is deterministic, with chunk id as the final tie-break. The baseline
passage ceiling is 12. The per-source diversity cap is at least three and is
raised when fewer sources are available, so a one-source library can fill the
requested passage limit rather than being made artificially unanswerable.
The evidence packet retains route channels and score components so an agent can
inspect why a passage appeared.

Accepted claims are returned only when they have active support and at least
one supporting chunk survived passage selection. Their support citations retain
polarity, stance, attribution, lineage, and time. Claim conflicts remain
visible. The evidence confidence field for an accepted claim is a validation
marker of `1.0`, not a calibrated probability; provider confidence
was already used at the promotion gate.

## Leads, gaps, and important notes

The evidence packet intentionally separates four levels of material:

| Output | Meaning | May an agent state it as fact? |
| --- | --- | --- |
| Accepted claim plus support | Directional graph assertion that passed validation | Yes, with its support citation and qualifications |
| Ranked passage | Relevant source text selected by one or more routes | Only what the cited passage itself supports |
| Ambiguity, graph lead, or gap | A warning or a promising next question | No; it requires further evidence or review |
| Analysis note | Durable observation, hypothesis, question or follow-up | No, unless separately promoted through the claim path |

A graph lead is created when a selected passage contains at least two promoted
concept mentions. It records up to three concept labels and mention
ids and says explicitly that co-mention and adjacency do not establish a typed
relationship.

General gaps are emitted when no passage matched, a relationship question has
no supported directed claim, a name remains ambiguous, or vector retrieval
fell back. The policy also has a small set of deterministic explicit-negative
recognizers for exact phrases, relationships, datastore
evidence, replica freshness, collective attribution, and unresolved verdicts.
These prevent a returned denial or limitation from being turned into a broader
positive claim.

Important notes are stored durably in SQLite as bounded analysis objects. A note
records its kind (`observation`, `hypothesis`, `question`, `lead` or
`follow-up`), text, importance rationale, uncertainty, suggested next action,
status, author/provider provenance, creation generation, and links to relevant
chunks, concepts, claims or reviews. Evidence-grounded notes retain exact source
citations. An uncited note is permitted only with an explicit `ungrounded`
state and can never be presented as evidence.

Suitable lead categories include ambiguity, possible missing relationship,
cross-source pattern, surprising evidence, conflict and repeated query gap.
Notes can be ranked and retrieved for human or high-capability-agent analysis,
but they occupy a separate evidence channel and are never graph claims. A note
becomes a claim only by generating a normal exact-span proposal that passes the
same deterministic validation and review path as every other claim.

## Chunk maintenance-priority signal

Maintenance scans one active occurrence of each distinct chunk content and
computes a stable initial priority score:

```text
100  * candidate-mention count
+ 350 * relationship-cue count
+ 1000 when the chunk has no extracted support
- 100  * repeated-content count
+ 200  * (candidate count - 1) when candidate count is at least two
+ 500 for ordinary evidence, or 300 for code
+ 50   * unresolved-candidate count
```

The relationship-cue vocabulary is profile-configurable; its baseline includes
“depends on”, “uses”, “calls”, “owns”, and “reports”. Selection is controlled by
explicit sorted triggers:

- `bridge`: at least two candidate mentions could connect concepts;
- `conflict`: a pending conflict review points to the chunk;
- `operator-review`: any pending review points to the chunk;
- `profile-change`: reconsider every eligible distinct content item;
- `unprocessed-extraction`: no claim support has been extracted;
- `unresolved`: candidate mentions have not reached accepted state; and
- `weak-support`: support is negation or speculation.

The highest-scoring items are selected within item, call, token, cost or
allowance, time, concurrency, and attempt ceilings. Ties are resolved by stable
chunk id. The score is one transparent maintenance signal, not the only source
of work.

A selected chunk review receives the selection reason, glossary, lexical seeds,
existing concepts and claims, prior provider outcome, pending reviews, relevant
neighbouring evidence and query-gap signals. The provider can propose zero or
more new exact-span concepts, aliases, relationships and analysis notes. Apply
revalidates the exact plan, generation, config, route, privacy and budgets
before it queues or promotes any result.

## Catalogue and graph maintenance methodology

Concepts are graph nodes and claims are directional graph edges. Catalogue
maintenance and graph maintenance must therefore be one canonical plan and one
atomic generation, not two maintenance systems. The same plan covers concepts,
aliases, mentions, claims, support, conflicts and reviews. FTS and vector
artifacts remain derived projections.

Maintenance is also the mechanism for finding work. It does not begin with an
operator already knowing which concept to edit. A maintenance cycle inventories
chunks, nodes, edges, reviews, query gaps, failed work and embedding/vector
coverage; ranks the most useful next analysis; optionally asks an LLM to
diagnose the selected items; and produces an executable, bounded worklist.

The worklist is an incremental batch, not a request to drain the complete
backlog. Its configured item ceiling is applied after ranking, so critical
projection repairs and conflict work displace lower-ranked enrichment. Later
runs recalculate current state and select the next eligible batch. Content
already assigned under the same improvement policy and prompt is excluded:
active work completes through its owning job and failed work advances only
through explicit dead-letter replay with preserved lineage.

### Discovery, ranking and the worklist

The deterministic chunk-priority score is one input to maintenance. It is
extended into typed inventories rather than used as one
undifferentiated score:

| Inventory | Examples of prioritisation signals |
| --- | --- |
| Chunks | current concept/cue/novelty/bridge/quality/unresolved score, no-claim outcome, repeated query gap, previous failed or no-claim extraction |
| Concept nodes | unresolved or ambiguous mentions, alias collision, possible synonym, inconsistent proposed type, high graph degree, bridge position, migration-parent backlog |
| Claim edges | conflict, weak or single-source support, ambiguous endpoint, affected migration parent, repeated query demand without a decisive answer |
| Reviews and leads | impact, age, source diversity, uncertainty, repeated appearance in evidence packets |
| Embeddings and derived indexes | missing compatible embedding, incomplete active-chunk coverage, stale/missing vector generation, failed publication |

Every selected item records its component scores, trigger, evidence identities,
expected generation and selection policy. A bounded LLM triage may add a
diagnosis, importance rationale and suggested action, but it cannot hide the
deterministic selection evidence or write canonical state.

The resulting worklist is typed. An entry may request chunk reanalysis,
concept discovery, connection review, synonym review, split/merge analysis,
retirement-gate inspection, conflict review, lead investigation, missing
embedding generation or vector republication. Dependencies are explicit: for
example a split connection review depends on the split proposal and its frozen
incident-edge inventory.

A maintenance run follows a convergence loop:

```text
census -> rank -> diagnose -> canonical worklist -> authorize -> execute
   ^                                                         |
   +---------------- re-census and verify -------------------+
```

The loop stops when the reviewed worklist is complete, its budgets or item
ceiling are reached, or the re-census finds no eligible work. It must never
continue merely because an LLM can generate another suggestion.

### Reporting and measurement

`library report` makes the maintenance census usable as a repeatable baseline
without starting another maintenance run. Generation-bound measures cover
source/revision/chunk volume, concepts, aliases, mentions, claims, support,
connected and isolated concepts, degree, relationship-type concentration and
support-span lengths. A live operational overlay covers FTS parity, embedding
and published-vector coverage, maintenance item states, terminal jobs, dead
letters, reviews and query gaps.

The semantic packet and operational overlay have separate SHA-256 digests.
This permits like-for-like comparison while avoiding a false claim that job
or sidecar state is an immutable semantic fact. Top-N output is stably ordered
and bounded. Exact all-pairs path distributions, graph communities, trends and
cross-generation deltas remain a later analytical layer rather than hidden
work in the basic report.

An optional advisory narrative is an interpretation of the report, not a
replacement for its measures. The configured advisory model sees the bounded
packet and representative passages, returns an exact overview/subjects schema,
and must use only supplied citations. Cache identity includes both report
digests plus provider, model and prompt version. Invalid output is discarded
and cannot alter the catalogue or graph.

### Human and automated operation

The same public operations support human, scheduled and agent operation:

- **plan-only:** discover, rank and explain work without provider calls or
  library mutation;
- **supervised:** execute bounded analysis/provider tasks, then require a human
  to approve the canonical graph/catalogue apply;
- **automated caller:** an explicitly authorized automation identity invokes
  the same plan/apply/workers/status/verify sequence within configured impact,
  privacy, call/token/cost or allowance, time and retry limits.

Automation never means direct LLM writes. Every caller uses an immutable
plan and digest, deterministic validation, durable worker attempts and a final
verification. Structural actions such as split, merge, type change, retirement,
restoration and claim retraction enter mandatory review; lower-impact analysis
and index repair complete within the reviewed worklist. There is no separate
automatic graph-write path.

### LLM proposals and deterministic authority

A bounded catalogue review may propose:

- a new concept and its exact-span mentions;
- a synonym or other alias;
- a possible ambiguity;
- a type correction;
- a merge of duplicate concepts;
- a split of an overloaded concept;
- retirement or later restoration;
- dispositions for affected claims; and
- evidence-backed analysis leads.

Every proposal records evidence, rationale, confidence, provider/model/prompt
provenance and its expected generation. The LLM cannot apply a proposal.
cREXX expands the proposal into its complete impact set, validates that every
affected active object has a disposition, creates the canonical plan and
requires the applicable review authority before apply.

### The old concept is a mandatory migration parent

A split never replaces or retires the old concept in the same operation. The
old concept remains active as the stable migration parent and the new concepts
are introduced as more specific successors. This is a required part of the
process, not an optional fallback.

The first split generation:

1. preserves the old concept id and its historical citations;
2. creates the proposed successor concepts;
3. records administrative `split-from` lineage;
4. moves only aliases, mentions and edges whose evidence supports an exact
   successor;
5. leaves uncertain connections on the migration parent or records an explicit
   ambiguity/review; and
6. reports the remaining migration inventory.

Keeping both when uncertain means retaining the accepted connection on the old
migration parent while the possible successor disposition remains under
review. It does **not** mean cloning an accepted edge onto every successor,
because that would create unsupported facts. A new child edge is accepted only
when its own cited evidence supports that child.

Retiring the migration parent is always a later, separately planned and
approved operation. Its deterministic retirement gate requires:

- every active alias and mention to be retained intentionally, migrated to one
  successor, or represented as an ambiguity;
- every incident active claim and support row to have an explicit retain,
  redirect, retract or review disposition;
- no unresolved mandatory maintenance review;
- no active canonical object that would be left dangling; and
- a successful graph, manifest and derived-index verification of the proposed
  generation.

If the gate is not satisfied, the old concept remains active. Retirement closes
its current visibility/lifecycle state; it does not physically delete the
concept, its history, its citations or its maintenance provenance. Restoration
requires a new reviewed lifecycle version rather than erasing the retirement.

### Other maintenance operations

| Proposal | Canonical treatment |
| --- | --- |
| Synonym | Add an alias to the existing concept; do not create a duplicate node |
| Merge | Choose a survivor, mark the other concept as a migration source, gradually redirect evidence-backed aliases, mentions and edges, then retire it in a later plan |
| Type change | Create a reviewed concept-state version and revalidate every incident claim whose policy depends on the type |
| Retirement | Preserve history and close only the active state after the retirement gate passes |
| Restoration | Publish a new active lifecycle version and restore claims only where current evidence still supports them |

Administrative lineage such as `split-from`, `merged-into`, `supersedes` and
retirement reason belongs in a versioned maintenance-lineage repository. It is
not a source-supported domain edge and must not be mixed into ordinary graph
answers.

### Split connection review

For a split, cREXX first enumerates every incident edge, alias, mention, support
row, ambiguity and conflict. A durable bounded LLM task may then propose a
disposition for each enumerated object. Apply is rejected unless the returned
identities exactly match that impact set and every proposal passes normal span,
type, relationship, provenance and generation checks. Uncertain dispositions
become reviews; absence from the provider response never means deletion.

Graph traversal immediately consumes the newly published canonical node and
edge state. Source text embeddings usually remain reusable because catalogue
maintenance does not alter chunk text, but the current vector publication is
generation-bound. Finalisation must therefore publish or reuse a compatible
vector generation for the new semantic generation so catalogue maintenance
does not silently disable hybrid retrieval.

## Workflow for deeper agent analysis

A high-capability agent should use the library as an evidence substrate:

1. Start with `library overview`, the profile vocabulary and `query inspect`.
   These inspect the corpus without writes or provider calls. Ordinary lexical
   `query evidence` also avoids providers but records query-gap observations.
2. Separate accepted claims from passage-only observations, ambiguities,
   leads, and gaps.
3. Use `query trace` to inspect variants, route states, candidate/selection
   counts, and the generation-bound trace identity.
4. Use `query path` for typed relationships or `query timeline` for temporal
   evidence instead of inferring those views from prose.
5. Follow promising leads into cited source spans or additional sources and
   state what remains absent.
6. If deeper analysis proposes a new normalized claim, use `proposal plan`
   with inline NDJSON or a server file. Apply creates mandatory pending reviews;
   promotion requires explicit operator authority and normal claim validation.
7. For a durable maintenance question, inspect its history and frozen evidence
   before using `maintain resolve-plan`. A complete, bounded evidence refresh
   can supersede an insufficient packet while preserving its original question.
   Exact resolution submission queues a review; acceptance uses the existing
   lifecycle engine. Finish justified connection work before retiring a
   migration parent.

This handoff lets a stronger agent reason across evidence without confusing its
analysis with the library's accepted graph state. Tasks can be flagged for
advanced reasoning independently of priority, either explicitly or after
repeated resolution-content validation failures. The flag prevents ordinary
worker dispatch; it does not schedule a stronger model or supply missing
evidence. See the [agent guide](agent-integration.md#difficult-maintenance-tasks)
and [fresh trials](mcp-codex-trials.md) for the interface and observed coverage.

## Non-negotiable invariants

- SQLite is the authoritative catalogue, graph, worklist and analysis-note
  store. Sidecars are rebuildable derived indexes.
- Glossary, deterministic and LLM discovery routes may propose catalogue work;
  no provider writes canonical state directly. Deterministic-only discovery is
  an explicit degraded fallback, not the normal completeness claim.
- Every promoted concept mention and claim support has an independently
  verifiable exact source span. A provider cannot replace missing precision
  with a whole-chunk citation.
- Claims retain their stored direction. Graph retrieval can traverse outbound,
  inbound or both directions without manufacturing inverse facts.
- Co-mentions, similarity, gaps, analysis leads and free-form notes remain
  distinct from accepted claims. Their persistence and usefulness do not grant
  them factual status.
- A split retains the old concept as its migration parent. Retirement and
  restoration are separately planned lifecycle operations; neither deletes
  historical evidence or provenance.
- Hybrid retrieval requires a verified IVF-flat ANN vector generation with at
  least one compatible embedding. Coverage may be partial; the vector row
  count and active-chunk census remain explicit so maintenance can close the
  gap without suppressing usable search.
- Every provider call and mutation remains generation-bound, privacy-classified,
  budgeted, durably recoverable, idempotent and subject to normal cREXX
  validation and review policy.
