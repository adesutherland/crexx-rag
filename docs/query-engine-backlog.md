# Query engine and local embedding requirements backlog

Status: open requirements captured from the 10–11 September 2026 design
discussion. This records future product work, not implemented behavior or an
implementation approval. It is additive to the existing
[operational recovery backlog](recovery-defects.md); it does not reprioritize
that work or reopen the dated [methodology closure](methodology-closure.md).

## Intended experience and ownership

A person or an LLM searches a prepared evidence library, reads relevant
passages, chooses associated concepts and follows their graph connections.
The searcher can repeat this process and produce a cited answer. A small local
embedding component should make semantic search usable on a CPU without an
API key or a separately administered model server. A hosted LLM may direct the
investigation or write the answer, independently of the ingestion provider.

Keep one `crexxrag` application and its shared CLI, JSON/NDJSON, ADDRESS and MCP
operation vocabulary. Level-G cREXX owns configuration, retrieval, ranking,
graph traversal, evidence, provider policy and scheduling. SQLite remains
authoritative and vector sidecars remain rebuildable. CREXX owns the generic
native component described by
[CREXX-NI-01 through NI-07](https://github.com/adesutherland/CREXX/blob/develop/docs/planning/native-inference-backlog.md).
No inference implementation is copied into this repository.

At publication, the baseline already includes text/vector/graph retrieval,
provider-free and zero-write `query inspect`, cited evidence, MCP access,
long-lived process workers, embedding-only maintenance and vector rebuild.
Graph anchors are currently inferred from labels/aliases in the question;
general query calls do not accept an explicit list of starting concept IDs.
Use those existing facilities as the starting point. Maintenance-task evidence
and resolution tools are not a replacement for a general query interface.

IDs below identify requirements, not GitHub issue numbers. All entries are open;
the acceptance conditions are future proof obligations.

## RAG-QE-01 — Selectable graph entry points in search results

Expose existing concepts associated with retrieved text/vector passages as
candidate graph entry points. Return stable concept IDs, labels, types,
supporting mention citations, ambiguity/lifecycle state and library-generation
identity. Explain which passage led to each candidate. A searcher must be able
to inspect the passage and choose a subset without guessing labels from prose.

Acceptance: text and vector hits can each expose independently resolvable
concept candidates. A passage without an extracted concept remains useful
evidence but does not acquire an invented graph node. Ambiguous names and
retired or migrating concepts remain explicit. Bound or page the candidate
list and expose truncation.

## RAG-QE-02 — Curated and bounded graph expansion

Allow a subsequent query to start from selected concept IDs, with direction,
hop, result and temporal controls. Validate IDs against the selected library
generation and define stale-generation behavior. Return supported claims,
their stored direction and citations, with a trace of the selected roots and
paths. Preserve existing question-derived anchors for ordinary searches.

Acceptance: a first text/vector search followed by a user-selected expansion
finds evidence that the initial question could not anchor directly. Excluded
roots are not silently expanded. Cycles, highly connected nodes, duplicate
paths, missing IDs and generation changes have bounded, visible outcomes.
Similarity and co-mentions remain leads; selecting a root does not promote a
new factual claim.

Automatic expansion from search hits may be evaluated as an explicit optional
policy with candidate and traversal limits. It must not become an unannounced
default that follows every concept. Compare its noise and useful-evidence gain
against curated expansion under QE-09 before selecting it.

## RAG-QE-03 — Standalone querying with an optional LLM searcher

Make a prepared library useful through human-directed search, a bounded cREXX
retrieval workflow, or an external/hosted LLM using the same operations. Query
setup must not require extraction credentials or launch ingestion. Preserve
the zero-write, zero-provider-call `query inspect` contract and distinguish it
from modes that record observations, compute embeddings or call an answerer.

Acceptance: an installed reader can inspect passages, follow selected graph
roots and resolve citations without a generation model. A configured hosted
searcher can reformulate questions, select roots and request further evidence
without being the ingestion provider. Its calls obey the existing privacy,
access and aggregate budget policy. Candidate IDs and generated citations are
validated; query activity cannot mutate claims through an implicit path.
Changing the answerer does not invalidate document embeddings.

## RAG-QE-04 — Local embeddings through persistent CREXX ownership

Consume the installed CREXX native embedding provider through the existing
application provider abstraction. Keep a model loaded in an application-owned
long-lived worker/session and send it bounded requests. Choose worker counts,
threading, batching and memory limits through product configuration. Support
CPU querying and optional Mac GPU ingestion without requiring a model server.

Acceptance: after model provisioning, an installed reader performs local hybrid
queries offline without credentials; repeated queries reuse the loaded model.
Report cold versus warm latency, actual backend and memory per owner. Ingestion
uses bounded batches and ordinary durable work/recovery. Separate process
workers do not transfer native handles or assume shared model allocations.
Retain the existing HTTP embedding route and truthful auto/required-mode failure
behavior. Gemini, Codex, privacy, charging and malformed-output regressions
remain applicable to their existing routes.

Dependency: CREXX-NI-01 through NI-06. Moving RAG workers to attached VMs is a
separate decision and is not required by this item.

## RAG-QE-05 — A deliberate lifecycle without embeddings

Support a reviewed library policy that disables embeddings across ingestion,
maintenance, health reporting and querying. Text and the available graph remain
usable; graph extraction may still use a separately configured LLM. Distinguish
intentionally disabled embeddings from missing, stale or failed required
coverage. Retain an explicit route to enable embeddings later.

Acceptance: an embedding-disabled scratch library ingests and maintains without
embedding calls or endless missing-vector repair work. An existing prepared
library can be queried without its original providers. Enabling embeddings
creates only the necessary embedding/index work and preserves sources, claims
and citations. Text-and-graph-only retrieval remains an evaluated product mode,
not just an accidental provider failure fallback.

## RAG-QE-06 — Establish and improve the lexical baseline

Audit the current SQLite FTS5/BM25 search, phrase/original/focused variants,
corpus-frequency ordering, aliases, bounded spelling correction, prefix search
and neighbouring-passage selection. Correct the mismatch between ASCII-only
query word splitting and Unicode-capable indexing. Evaluate stemming, spelling
and OCR handling, alias coverage and variant-budget/ranking behavior against
representative queries before selecting changes.

Acceptance: a frozen question set includes accented and historical names,
inflected words, quoted phrases, OCR line breaks, typos and ambiguous aliases.
Report evidence gained and precision lost by each selected change. Search
normalisation must preserve citations to the original source text. A larger
embedding model must not be used to conceal a demonstrated lexical defect.

## RAG-QE-07 — Stable, reproducible embedding profiles

Extend existing immutable embedding identity to bind exact model weights and
revision/checksum, tokenizer/configuration, input preparation, query/document
instructions, pooling/normalisation, truncation policy, dimensions and weight
precision. Retain the runtime/backend qualification record. Keep the model
artifact available locally with its licence and notices so an existing library
does not depend on a mutable download alias or hosted model lifetime.

Acceptance: a compatible query model is selected from the library's profile;
matching vector dimensions alone never permit a different embedding space.
Changed model bytes or preprocessing under the same display name are detected.
CPU/Metal or precision/runtime changes require compatibility evidence before
reusing stored vectors. Model upgrades remain deliberate choices; an available
new model does not force an otherwise satisfactory library to migrate.

Dependency: CREXX-NI-05 supplies generic artifact/capability information; RAG
owns the persisted profile and its compatibility policy.

## RAG-QE-08 — Resumable model migration without repeated extraction

Build on embedding-only maintenance and vector publication to make an embedding
model change a supported operator workflow. Preserve the working model/index
while creating an isolated replacement, reusing identical inputs within a
compatible profile. Resume interrupted work and publish only after required
coverage and validation pass. Retain a rollback path and inspectable progress,
compute usage and model identity through ordinary commands.

Acceptance: a model change recomputes the affected document vectors but does
not reimport unchanged sources or repeat graph extraction. Queries continue
using the complete old collection during preparation. Interruption/replay,
incomplete replacement rejection, atomic publication and rollback preserve
existing claims, source spans and citations. Vectors from different models are
never mixed in one similarity search. Rebuilding a sidecar alone uses stored
SQLite vectors with zero embedding calls.

## RAG-QE-09 — Measure contribution, speed and model longevity together

Create a bounded retrieval evaluation, initially around 60–100 representative
questions with independently identified supporting passages/claims. Compare
text alone, text plus graph, and that combination with a small and a stronger
embedding model. Freeze corpus, graph, candidate limits and ranking settings
for model comparisons. Separately compare graph coverage/maturity so its
benefit is measured rather than assumed.

Include exact names/quotes, relationships, paraphrases, vague descriptions,
rare terminology, OCR/spelling variants and relevant passages absent from the
graph. Measure supporting evidence in the final bounded packet, evidence unique
to each route, irrelevant displacement and missed evidence. Also evaluate
multi-round curated exploration: success, total latency, number of calls and
misleading starting points under the same investigation budget. Separate ANN
approximation loss from embedding quality using the existing exact QA oracle.

Acceptance: publish the question/evidence set, artifact identities, settings,
results and limitations; agree acceptance thresholds before choosing the
default. Measure CPU cold load and warm query latency (including tail latency),
memory, Mac GPU batch throughput and full embedding-rebuild time separately
from LLM extraction and database/orchestration overhead. State input lengths,
token limits, hardware, batch size and quantization. A speed gain over hosted
embeddings must be measured; embedding-free search adds no model inference.

Use Nomic v1.5 as the retained comparison; evaluate BGE-small and EmbeddingGemma
as candidates, checking actual chunk lengths, licences and native support.
Larger models are optional comparisons. Select a small stable default based on
whole-system evidence recovery, CPU usability and reproducible availability,
not a universal leaderboard claim. Smaller output dimensions mainly reduce
vector storage/search work; they do not imply proportionally cheaper encoding.

The old Nomic prototype's 11,684 rows have a 6m37s final-write timestamp window,
and a later server log contains short-request timings. Neither is a full
current-product or CPU-only benchmark. Retain their provenance if reused;
do not extrapolate total ingestion time into embedding time or promise those
historical rates on a new package.

## Options retained for evaluation

- **Ingestion-only vectors:** a new natural-language query normally needs a
  compatible query vector for semantic matching. A separate experiment could
  use text-selected passages' stored vectors to find neighbours, or build
  derived similarity links during ingestion. Report these as search leads,
  preserve provenance and measure noise; do not turn them into factual edges.
- **Static embeddings:** learned token lookup/pooling models may offer much
  lower CPU cost with reduced contextual discrimination. They are an optional
  QE-09 comparator and may need a different native backend. They still require
  compatible learned weights and an embedding migration when switching models.
- **Local generation:** CREXX-NI-07 could later provide an additional answerer
  or searcher. It is not a prerequisite for the standalone query experience.

## Suggested order and references

Begin QE-09's baseline and QE-01/02's interaction contract while CREXX reviews
NI-01/03/05. Review QE-06 and QE-07 before freezing the default model. Deliver
QE-04 with reproducible profiles and QE-08's migration path, then qualify QE-03
and QE-05 as complete installed user workflows. This is dependency guidance,
not a dated delivery commitment or authority to run a hosted experiment.

Current product references: [algorithm](algorithm.md),
[agent integration](agent-integration.md), [user guide](user-guide.md),
[test strategy](test-strategy.md) and
[Scottish corpus experiments](scottish-corpus-development.md).
Primary design inputs:
[SQLite FTS5](https://www.sqlite.org/fts5.html),
[Nomic v1.5](https://huggingface.co/nomic-ai/nomic-embed-text-v1.5),
[BGE-small](https://huggingface.co/BAAI/bge-small-en-v1.5),
[EmbeddingGemma](https://huggingface.co/google/embeddinggemma-300m) and
[static embedding experiments](https://huggingface.co/blog/static-embeddings).
Published model results are selection inputs, not qualification of this product.
