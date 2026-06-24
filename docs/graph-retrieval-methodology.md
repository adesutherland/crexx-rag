# Graph Retrieval Methodology

The graph should not be another search index. It should store typed,
evidence-backed jumps that keyword and vector search do not explicitly know.

Keyword search answers:

```text
Which chunks contain these words?
```

Vector search answers:

```text
Which chunks sound like this query?
```

Graph search should answer:

```text
Which chunks are connected through meaningful typed paths?
```

## Retrieval Model

Use four sets:

```text
C = chunks
V = concepts/entities
E = typed relationships between concepts
M = mention/evidence links between chunks and concepts
```

A graph retrieval path is:

```text
query -> anchor concept -> related concept(s) -> evidence chunks
```

For example:

```text
Clan Sutherland --conflicted-with--> Clan Mackay --mentioned-in--> chunk
```

That chunk may not contain the user's exact words, and may not be close enough
for vector search, but it is reachable because the source created a meaningful
relationship.

## Graph Score

A first graph score can be:

```text
G(query, chunk) =
  max over paths:
    anchor_score
  * path_confidence
  * relation_type_weight
  * evidence_confidence
  * path_decay
```

Where:

```text
path_decay = 0.7 ^ hop_count
```

Useful graph paths are typed, evidence-backed, short enough, profile-relevant,
and not generic.

## Edge Utility

Extraction should prefer edges that add graph structure, not just labels. A
candidate relationship has utility when it connects useful concepts, bridges
clusters, or preserves an evidence-backed relationship that plain search does
not explicitly represent.

```text
edge_utility =
  extraction_confidence
* relation_type_weight
* source_confidence
* support_count
* (relationship_information_value + retrieval_novelty + bridge_value + alias_value)
- generic_penalty
```

`bridge_value` is high when an edge connects otherwise separate concept
clusters. `relationship_information_value` is high when the relationship type
itself carries useful information, such as `held-land-in`, `killed`,
`succeeded-by`, `married`, `served`, `treasury-at`, or `claimed-descent-from`.
It is low for plain co-occurrence or untyped `mentioned-in` edges.

`retrieval_novelty` is high when the edge creates a path that keyword or vector
search would not naturally surface. This does not require proving that other
search modes fail. Use testable proxies:

```text
one endpoint is only named in one chunk or source
the query concept and evidence chunk do not share obvious query words
the relationship depends on an alias or old spelling
the endpoints rarely co-occur across chunks
the relation connects two otherwise separate clusters
the relationship phrase is more specific than semantic similarity
```

`alias_value` is high when the edge records an alternate spelling, old name,
origin name, translation, or "also known as" form. `generic_penalty` suppresses
low-value abstractions such as `war`, `humanity`, or `people` in an
entity-relationship profile.

This changes the core usefulness question from:

```text
Is this chunk important in general?
```

to:

```text
Will this edge or chunk add relationship information or retrieval novelty?
```

## Extraction Scope

The triage question is:

```text
Is this chunk likely to create useful graph structure?
```

It is not:

```text
Will keyword or vector search fail?
```

We do not need to predict failures in other search modes exactly. Retrieval can
fuse lexical, vector, and graph candidates later. The graph earns its keep by
adding unique, explainable candidates and typed paths.

A chunk is inside the extraction scope when it has one or more of:

```text
adjudicated good concepts appear together
unknown candidate names appear near known concepts
relation_cue_count is high
multiple concept types appear together
it links different graph communities
it proposes aliases or older spellings for known concepts
it contains one-sided evidence that would be hard to find from the other endpoint
it states a specific relationship that is more valuable than co-occurrence
```

Examples:

```text
known clan + known place + "held lands"
=> deterministic graph write

known clan + unknown person + "killed" + known place
=> in scope, probably model-assisted

many unknown names + conflict/governance cues
=> in scope, model-assisted

abstract prose with no known concepts
=> low value for an entity graph
```

## CREXX Gate Shape

CREXX should own the policy gate:

```text
1. match known concepts through the native API
2. find proper nouns or candidate names
3. find cue verbs and noun phrases
4. compute extraction_scope_score
5. compute deterministic_relation_score
6. decide: skip, deterministic write, small model, medium model, or Gemma
```

A starting score can be:

```text
extraction_scope =
  3 * known_concepts
+ 4 * relation_cues
+ 2 * unknown_proper_names
+ 5 * type_diversity
+ 6 * bridge_potential
- 5 * generic_only
```

Then:

```text
extraction_scope < 5
=> skip

known endpoints + strong cue
=> deterministic write

extraction_scope >= 10 and uncertainty low
=> deterministic write plus review metadata

extraction_scope >= 10 and uncertainty high
=> small or medium model

extraction_scope >= 18 and complex
=> Gemma
```

The model question should therefore be narrow:

```text
Given known matches, cue hits, and unknown names, is this chunk useful for
typed graph construction, and what is the cheapest next step?
```

The model is advisory. CREXX remains the final judge.

## LLM Assist

Deterministic does not mean "no LLM". The profile should use deterministic
work to frame small, cheap questions for a model, then apply CREXX policy to the
answer.

Use the term `llm_assist` for this middle ground:

```text
deterministic input -> narrow model question -> CREXX validation/routing
```

Good assist targets:

```text
relation_cue_assist
  Ask whether cue words imply land-holding, conflict, kinship, succession,
  governance, movement, source-claim, or no useful relation.

alias_cue_assist
  Ask whether old spellings, "called", "ancient name", "rendered",
  "sons of", or parenthesized names imply an alias/origin relationship.

bridge_assist
  Ask whether this chunk is likely to connect graph neighborhoods. Early in a
  corpus, use a neutral average because cluster statistics are not mature yet.

complexity_assist
  Ask whether the chunk has too many events, pronouns, unknown names, or
  relationship directions for a deterministic write.
```

The important rule is that the model is not asked to own the graph. It returns
advice. CREXX checks the advice against the profile vocabulary, confidence
policy, and native concept matches.

## Candidate Census

Stage 1 should be treated as a corpus census, not as final extraction. The goal
is to learn the vocabulary and shape of the corpus cheaply enough that later
model calls can be targeted.

The useful raw output is not just a per-chunk score. It is an aggregated
candidate table:

```text
normalized_name
display_name
mention_count
first_chunk
last_chunk
chunks_seen
max_priority
known_concept_hits
relation_cue_hits
cooccurring_candidates
spelling_variants
```

That table can then be adjudicated in batches. A local LLM should see the
candidate list and classify each candidate as:

```text
keep | junk | ambiguous
likely type: clan, person, place, event, office, military-unit, work, generic
canonical label
alias/spelling hints
disambiguation requirement
```

This is cheaper and usually higher quality than asking the model to understand
every chunk independently. It also turns noisy Stage 1 output into reusable
library intelligence. For example, frequent good candidates become seed
concepts; frequent junk becomes an ignore list; ambiguous candidates such as
`Sutherland` become explicit ambiguity work items.

Once candidates are adjudicated, chunk scores should be recomputed from the
classified registry:

```text
chunk_value =
  good_concept_mentions
+ relation_cues
+ rare_or_new_concepts
+ ambiguity_need
+ graph_bridge_score
+ vector_bridge_score
+ vector_novelty_score
- junk_candidate_mentions
- semantic_redundancy
```

The difference between good and bad extracted information is itself a useful
complexity proxy. A chunk with many junk candidates should not be promoted just
because the raw proper-noun count is high. A chunk with a few strong concepts,
rare aliases, or relationship cues can be much more valuable.

The Scottish corpus Stage 1 experiment is the current reference scale: 5,977
chunks took about 96.6 minutes with Qwen2.5 3B and produced 6,358 distinct
candidate strings from 20,697 mentions. Most candidates were rare: 3,854 appeared
once, while 344 appeared at least ten times. That distribution supports the
two-step design: census first, adjudicate and rank second, then spend expensive
extraction only on the shortlist.

## Vector Signals

Vector relationships between chunks should influence the process, but they
should not directly create typed facts. Treat vectors as ranking and coverage
evidence:

```text
chunk --similar-to--> chunk
```

is not the same kind of edge as:

```text
Clan Mackay --conflicted-with--> Clan Sutherland
```

Vector neighbors are useful for:

```text
redundancy control
  If many chunks are semantically near-duplicates, extract only the best few
  unless their concept sets differ.

coverage
  A concept named in one chunk may have useful context in vector-near chunks
  where the exact name is absent.

bridge detection
  A chunk that is vector-close to two different graph communities can be
  important even when keyword search would not flag it.

missing-link candidates
  Concepts that rarely co-occur lexically but appear in semantically adjacent
  chunk neighborhoods can be queued for relationship extraction.
```

The guardrail is simple: vector similarity may queue inspection or create a
low-confidence `similar-context`/`candidate-evidence` link, but deterministic
rules or LLM extraction must earn typed relationship edges.

## Target Pipeline

The target repeatable pipeline follows this gate:

```text
native ingest/chunk/store
  -> CREXX seed vocabulary for the profile
  -> Stage 1 candidate census
  -> batch candidate adjudication into keep/junk/ambiguous/types/aliases
  -> recompute chunk value from adjudicated candidates
  -> optional chunk-vector neighborhoods for coverage and redundancy
  -> seed mention graph and concept co-occurrence graph
  -> graph-rank chunks and concepts
  -> cprag_match_concepts over each chunk
  -> deterministic mention/evidence links
  -> deterministic typed relationships when endpoints and cues are strong
  -> Qwen2.5 advice using short scalar/word outputs
  -> Gemma advice when Qwen/deterministic gates say the chunk is costly enough
  -> Gemma JSON extraction only for final gated chunks
  -> CREXX validation
  -> native graph writes
```

This is deliberately not a "throw every chunk at Gemma" design. The first
Qwen2.5 step is allowed to be rough because it only influences routing. The
Gemma advisory step is still cheap compared with extraction because it returns
one route word. The expensive JSON extraction step is reserved for chunks whose
expected edge utility comes from relationship information or retrieval novelty.

The cheap advisory questions avoid JSON:

```text
proper-nouns -> comma-separated proper names or none
value       -> 0..5
route       -> skip|deterministic|medium|gemma-advice|gemma-extract
relation    -> allowed relationship type or none
alias       -> yes|no
complexity  -> low|medium|high
```

The current proof implements the front of this shape in
`crexx/profiles/history/hybrid_ingest_extract.crexx`, covered by
`crexx_hybrid_extractor_smoke`. It can ingest/chunk, run Stage 1, write
deterministic mention/evidence links, detect ambiguity nodes, accumulate support
for repeated typed edges, and call local llama.cpp advisors when online. Batch
candidate adjudication, graph ranking, vector-neighborhood scoring, persistent
queues, and external extractor push are the next pieces to make first-class.

The ingestion shape is staged. Stage 1 is a prioritiser and corpus
census, not a final extractor: CREXX counts proper nouns, known concepts, and
relation cues, and may ask a fast model for `proper-nouns` when online. If the
fast model returns no usable names, deterministic CREXX extraction supplies the
fallback score. The Stage 1 output should be collated into a candidate registry
before the expensive extraction queue is chosen. Stage 2 performs the initial
graph write. Stage 3 revisits explicit ambiguity/fixup nodes once more context
exists.

Ambiguity is kept as graph structure. A name such as `Sutherland` can be both a
clan and a place, so the profile should create an `ambiguity` node with
`candidate-for` edges rather than prematurely choosing one. Later fixup can
resolve or score those candidates using adjacent evidence, vector/lexical
search, or a stronger LLM.

The final acceptance gate should reject candidates unless they satisfy:

```text
supported endpoints
allowed node and relationship types
confidence above the profile threshold
evidence tied to the current chunk
relationship_information_value > 0 or retrieval_novelty > 0
generic_penalty below threshold
```

## Scope Questions

A first scope vector can be:

```text
known_concepts
known_type_diversity
unknown_proper_names
relation_cues
endpoint_pairs
alias_cues
bridge_potential
relationship_complexity
generic_noise
evidence_value
```

Some fields are primarily deterministic:

```text
known_concepts
known_type_diversity
endpoint_pairs
generic_noise
evidence_value
```

Some fields are deterministic plus `llm_assist`:

```text
relation_cues
alias_cues
bridge_potential
relationship_complexity
unknown_proper_names
```

Do not wait for a perfect graph before estimating `bridge_potential`. During
early corpus construction, use a neutral average value plus obvious signals such
as known concepts from multiple types, unknown proper names near known anchors,
and strong relationship cues.

## Reprocessing

Early ingestion happens before the concept pool is mature. The library should
therefore be able to mark chunks for later graph reprocessing.

Suggested metadata:

```json
{
  "graph_processing": {
    "status": "pending|processed|needs-reprocess|skipped",
    "profile_id": "history.scotland.v1",
    "profile_version": 1,
    "concept_pool_version": 12,
    "reason": "new aliases or concepts learned after first pass"
  }
}
```

Useful triggers:

```text
new concept accepted
new alias accepted
profile cue table changed
relationship vocabulary changed
model/prompt version changed
previous run had medium/high graph gain but low confidence
```

This lets the first pass stay lightweight. Chunks that looked unimportant before
the graph knew enough can be revisited once the corpus has a better vocabulary.

## Background Enhancement

Long-running improvement should be queue driven. The enhancer should not wander
through the corpus forever without a reason. It should consume work items such
as:

```text
ambiguous concept needs resolution
edge has weak support but high retrieval value
concept community has many mentions and few typed edges
new alias changed older chunk matches
vector-near chunk may bridge two graph communities
external extractor pushed a low-confidence proposal
```

Each work item should carry a budget, profile version, reason, and provenance.
That makes background processing resumable, explainable, and locally controllable
instead of an invisible model loop. The enhancer can use deterministic rules,
fast advisory models, or Gemma-class extraction according to the same routing
policy as foreground ingestion.

## Incremental Libraries

The pipeline must work when a library starts small and grows over time. A mature
`.cprag` library should make later documents cheaper:

```text
new chunks
  -> match against existing concepts and aliases
  -> collect only new or changed candidates
  -> adjudicate deltas
  -> score whether the document adds evidence, new relationships, or bridges
  -> extract only the chunks that can change the graph
```

Known concept matches are deterministic and cheap. Unknown candidates become
proposed concepts. New aliases, relationship vocabulary changes, or model/prompt
changes can mark older chunks for reprocessing. The concept registry therefore
has versions, and chunk processing records which registry/profile version was
used.

## External Extractor Push

Some workflows will already run an LLM over a document for summarisation,
review, or domain analysis. Graph extraction should be able to arrive as a side
effect of that work.

An external extractor push should submit proposed concepts, relationships, and
evidence into the same native graph/evidence model. It must include provenance:

```text
source document
chunk id or span when known
extractor id
model and prompt/profile version when known
confidence
timestamp
evidence text
```

External pushes should not overwrite truth. They create proposed or supported
facts that pass through the same de-duplication, ambiguity handling, support
accumulation, and profile validation as internally extracted candidates.

## Operation Surfaces

The project should avoid duplicating logic between API calls, CLI commands, and
CREXX profile conveniences. Prefer one semantic operation vocabulary with
multiple bindings:

```text
native C/C++ implementation
  -> CLI command for humans and scripts
  -> CREXX direct function for profile code
  -> CREXX address environment command for command-style orchestration
  -> MCP adapter when needed
```

For example, `collate-candidates`, `adjudicate-candidates`, `rank-chunks`,
`embed-chunks`, `export-dot`, and `push-extraction` should mean the same thing
across surfaces. The CREXX address environment is a programmer-experience layer,
not a second implementation. It should make profile scripts pleasant to read
while still calling the same native/CLI operations that humans can inspect.
