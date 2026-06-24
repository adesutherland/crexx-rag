# Domain Profiles

Domain profiles are executable policy. They say which concepts and
relationships matter for a workload, how mentions should be normalized, and
which evidence is strong enough to write into the graph.

The split is deliberate:

- `cprag_core`: stores chunks, nodes, edges, provenance, vectors, traversal, and
  DOT export
- CREXX profile code: chooses candidate concepts and relationships from chunks
- CLI/MCP: adapters for applying and inspecting the same native core operations

That means CREXX does not own the graph. CREXX identifies candidates such as
`Clan Macnicol`, `Assynt`, and `held-land-in`; the native engine adds or updates
nodes and relationships, avoids duplicate ids/connections, and later searches,
walks, or exports the stored graph.

## Current Example

[`../crexx/profiles/history/deterministic_extract.crexx`](../crexx/profiles/history/deterministic_extract.crexx)
is the first executable history profile. It is intentionally deterministic and
hand-tunable. It is not meant to be a good historian; it is meant to expose the
shape of extraction, evidence, and failure so a later LLM-assisted extractor can
be compared against it.

The profile proves the flow with two small corpora:

- Scotland: clans and places such as Macnicol, Sutherland, Mackay, Gunn, and
  Assynt
- Athens: people, places, polities, and institutions such as Themistocles,
  Athens, Piraeus, the Ionian League, Delos, Aristides, and Cimon

The CTest proof is `crexx_deterministic_extractor_smoke`. It compiles the CREXX
profile, runs it through the installed CREXX VM and `rx_rag` plugin, and checks
that typed relationships, shortest paths, and engine-generated DOT output are
present.

```bash
ctest --preset debug -R crexx_deterministic_extractor_smoke --output-on-failure
```

## Extraction Shape

A deterministic profile normally follows this order:

```text
stored chunks
   -> chunk ids from the native engine
   -> chunk text
   -> mention detection
   -> canonical node ids
   -> typed relationship candidates
   -> native graph insertion/update
```

The current profile has two layers:

- generic: detect configured aliases, create canonical concept nodes, create an
  `evidence-chunk` node, and link each concept to its source with `mentioned-in`
- domain-specific: use Scotland or Athens cue tables to add a small number of
  typed relationships such as `held-land-in`, `conflicted-with`,
  `built-or-improved`, or `treasury-at`

For example, a Scotland rule can say:

```text
Macnicol + Assynt + held/lands -> held-land-in
Macnicol + Sutherland          -> associated-with
```

Each mention and relationship carries evidence metadata such as the profile id,
chunk id, extractor kind, and the textual cue that triggered the rule. This
means even a plain list of clans has value: each clan can be walked back to the
chunk where the source mentions it.

## Why Concepts First

Relationships need stable endpoints. The text may say `Macnicols`,
`Nicholsons`, `Sutherlands`, or `the Mackays`; the graph should use canonical
ids such as:

```text
history:scotland:clan:macnicol
history:scotland:clan:sutherland
history:scotland:clan:mackay
```

The profile can keep aliases and domain rules close to the workload, while the
native core stays domain-neutral.

## Separate Or Combined Libraries

Scotland and Athens usually belong in separate `.cprag` libraries because they
are different corpora and profiles. A combined library is still useful for
testing namespace separation and future cross-domain links.

The namespace makes accidental overlap visible:

```text
history:scotland:clan:sutherland
history:athens:person:themistocles
```

If the project later finds a real relationship between domains, that should be
an intentional evidence-backed edge, not a side effect of similar labels.

## Hybrid Extractor Shape

The target extractor is hybrid, not a hard choice between deterministic rules
and an LLM. CREXX rules can cheaply handle obvious terms, enforce the domain
vocabulary, reject bad candidates, and preserve evidence policy. A local LLM can
be called when the rule layer needs help with ambiguous entities, relationship
direction, evidence spans, candidate classification, or candidate relationship
labels.

The hybrid path should use the same graph insertion/update route:

```text
chunk text
   -> deterministic mention/cue pass
   -> optional local LLM extraction prompt for support
   -> candidate nodes/relationships JSON
   -> CREXX/profile validation and normalization
   -> native graph insertion/update
```

In practice the CREXX profile also needs a profile context object. That context
is the in-run working memory passed between chunk calls. It can remember facts
that have already been accepted, such as:

```text
alias "Sutherland" -> history:scotland:clan:sutherland, type clan
```

Once that fact is in context, later deterministic passes do not need to ask the
LLM again just to recognize `Sutherland` or `Sutherlands`. They can emit the
same canonical node id and link each mention back to the current evidence chunk.
The current deterministic smoke demonstrates this with a small string-backed
context table in CREXX: `scotland_accept_llm_candidates` stands in for an
accepted LLM candidate, and `mention_context_concepts` makes the learned concept
available to the normal rule pass.

The native core also exposes the cheaper persisted version of that loop:

```bash
./cmake-build-debug/crexx-rag list-concepts ./history.cprag clan,place
./cmake-build-debug/crexx-rag match-concepts ./history.cprag \
  "The Sudrland men were near Assynt." \
  clan,place
```

The CREXX plugin exposes the same calls as `rxrag.listconcepts(...)` and
`rxrag.matchconcepts(...)`, with wrapper methods `conceptsJson(...)` and
`matchConceptsJson(...)`. The matcher uses stored concept labels plus aliases
from node metadata, for example:

```json
{"aliases":"Sutherland|Sutherlands|Sudrland"}
```

This makes the stored graph a reusable vocabulary. A profile can first ask the
engine which known concepts appear in a chunk, then apply CREXX triage rules:

```text
matched clan + matched place + land cue -> write held-land-in
matched clan + battle cue + unknown opponent -> ask LLM
no useful matched concepts -> skip or lexical-only review
```

The intended production shape is:

```text
profile context
   -> known aliases and canonical ids
   -> accepted node/relationship candidates
   -> rejected candidates and reasons
   -> confidence/evidence thresholds
   -> optional LLM call budget
```

The first provider command for the optional LLM step is:

```bash
./cmake-build-debug/crexx-rag extract-llama-server \
  --profile scotland \
  --model ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M \
  "The Macnicols held lands in Assynt and were connected with Sutherland."
```

It returns candidate JSON only. It does not write graph data. A CREXX profile
can therefore expose a simple user policy:

```text
llm_mode = off     -> deterministic rules only
llm_mode = assist  -> call the LLM only when a cue is ambiguous or incomplete
llm_mode = always  -> ask the LLM for every chunk, then validate candidates
```

The native engine should still be the only place that stores and de-duplicates
accepted nodes and relationships.

The first executable hybrid pipeline is
[`../crexx/profiles/history/hybrid_ingest_extract.crexx`](../crexx/profiles/history/hybrid_ingest_extract.crexx).
It proves the first useful slice, but the intended corpus-scale shape is broader
than the current smoke:

```text
Stage 0:
  ingest text/file, chunk through the native engine, and store provenance

Stage 1:
  run a cheap candidate census over chunks, normally using CREXX plus a fast
  advisory model for proper nouns or short scalar answers

Stage 1b:
  collate candidates by normalized name, count support, classify keep/junk/
  ambiguous/type/aliases in LLM-assisted batches, and update the concept
  registry and ignore lists

Stage 2:
  build mention/evidence links, seed a concept/chunk mention graph, derive
  co-occurrence evidence, and rank chunks/concepts using graph and optional
  vector-neighborhood signals

Stage 3:
  run deterministic or gated LLM extraction on the ranked shortlist and write
  accepted typed edges through the native graph APIs

Stage 4:
  revisit ambiguity nodes, thin graph areas, and contested edges with broader
  graph context
```

The repeatable smoke uses `--mode offline`, so it never depends on local model
servers:

```bash
ctest --preset debug -R crexx_hybrid_extractor_smoke --output-on-failure
```

Online mode keeps the same graph-writing policy but enables the local model
advisors:

```bash
rxvme -l cmake-build-debug/bin <compiled-profile> rx_rag -a --mode online \
  --cli ./cmake-build-debug/crexx-rag \
  --offset 650 \
  --limit 20 \
  --qwen-base-url http://127.0.0.1:8084/v1 \
  --gemma-base-url http://127.0.0.1:8080/v1
```

Use `--offset` and `--limit` for bounded corpus windows. This is currently the
practical resume/debug control; persistent per-chunk processing status is still
future work.

Stage 1 supports `--stage1 auto|off|deterministic|llm` and
`--stage1-limit N`. `auto` uses deterministic ranking in offline mode and the
fast advisory model in online mode. The LLM Stage 1 asks for `proper-nouns`; if
the response has no usable names, the CREXX deterministic extractor is used as
the fallback. Stage 3 can be disabled with `--stage3 off`.

The Stage 1 output should not be treated as truth. It is a census. The useful
artifact is an aggregated candidate table with counts, first/last chunk,
priority, relation-cue exposure, co-occurring candidates, and spelling variants.
A profile should then batch-adjudicate that table into:

```text
keep | junk | ambiguous
likely type: clan, person, place, event, office, military-unit, work, generic
canonical label
aliases or spelling variants
needs disambiguation
```

This adjudicated registry feeds back into chunk ranking. Frequent junk becomes
an ignore list. Frequent good candidates become seed concepts. Ambiguous names
become fixup work items. The extraction queue should be selected after this
feedback loop, not only from the raw proper-name count.

Chunk vectors can participate in this ranking loop when embeddings are
available. Vector-near chunks are evidence of similar context and can help with
coverage, redundancy, and bridge detection, but they should not directly create
typed facts. Typed edges still need deterministic evidence or accepted LLM
extraction.

Ambiguous alias matches are represented explicitly. For example, `Sutherland`
can match both `Clan Sutherland` and the place `Sutherland`; the profile writes
an `ambiguity` node plus `candidate-for` edges to both concepts. Clear aliases
still write normal `mentioned-in` edges. Repeated evidence for the same typed
edge is accumulated by the native engine as `support_count`,
`support_evidence`, and `last_support` metadata instead of overwriting the
previous support.

The cheap advisory adapter deliberately avoids JSON. `advise-llama-server`
normalizes model output to small values:

```text
value       -> 0..5
route       -> skip|deterministic|medium|gemma-advice|gemma-extract
relation    -> one allowed relationship type or none
alias       -> yes|no
complexity  -> low|medium|high
proper-nouns -> comma-separated proper names or none
```

Only `extract-llama-server` returns candidate JSON, and only for chunks that the
CREXX gate has already decided are worth the cost. The profile then checks
allowed node types, allowed relationship types, confidence, and evidence before
writing anything to the graph.

Gemma E4B may spend substantial output budget on internal reasoning before it
emits final JSON. The CLI default is therefore `CPRAG_LLM_MAX_TOKENS=2048`; if a
run reports reasoning without final JSON, increase `--max-tokens` or use a less
reasoning-heavy model.

When running profiles through CREXXSAA, clear stale cached binaries with:

```bash
crexxsaa --clear
```

For corpus experiments, use the batch command. It processes stored chunks,
prints progress and elapsed time to stderr, and writes one JSON result object to
stdout:

```bash
./cmake-build-debug/crexx-rag extract-chunks-llama-server ./athens.cprag \
  --source-uri examples/corpora/history/gutenberg-6156-athens-its-rise-and-fall.txt \
  --offset 1149 \
  --limit 2 \
  --profile athens \
  --model ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M
```

The batch command is still an adapter. It does not apply candidates to the
graph; CREXX/profile code should validate and normalize accepted candidates
before calling the native graph APIs.

The profile should configure:

- provider id and model, such as a local `llama-server` Gemma model
- prompts and allowed node/relationship vocabulary
- temperature and output limits
- confidence policy and evidence requirements
- whether low-confidence candidates are ignored, stored, or queued for review
- which deterministic rule, if any, asked for LLM support

## Repeatable Operation Surface

Avoid building separate implementations for API calls, CLI commands, and CREXX
profile conveniences. Prefer one operation vocabulary with multiple bindings:

```text
native C/C++ helper
  -> CLI command for humans and scripts
  -> CREXX function for direct profile calls
  -> CREXX address environment command for command-style orchestration
  -> MCP adapter when appropriate
```

For example, `collate-candidates`, `adjudicate-candidates`, `rank-chunks`,
`push-extraction`, `embed-chunks`, and `export-dot` should mean the same thing
wherever they are exposed. A CREXX address environment should be a programmer
experience layer over the same operations, not a duplicated shell-script
pipeline. Humans still need a CLI; profile authors need a pleasant CREXX surface.

## Incremental And External Extraction

Profiles must support incremental libraries. When new sources arrive, the
profile should first match chunks against existing concepts and aliases, then
collect only new or changed candidates for adjudication. Existing graph structure
should make later imports cheaper and more accurate.

External LLM workflows should also be able to push extracted concepts and
relationships into the library. A pushed extraction must carry provenance:
source, chunk/span if known, extractor id, model/prompt/profile version,
confidence, timestamp, and evidence text. The native engine should then apply
the same de-duplication, ambiguity handling, and support accumulation used by
internal extraction. External pushes seed the graph; they do not bypass the
profile's evidence policy.

Background enhancement should be a budgeted queue over known work items, not an
unbounded daemon. Good queue reasons include unresolved ambiguity, weak but
valuable edges, concept communities with many mentions and few typed
relationships, new aliases that affect older chunks, vector-near bridge
candidates, and low-confidence external pushes. The same CREXX routing policy
decides whether a work item is handled deterministically, with fast LLM assist,
or with Gemma-class extraction.

The embedder should not be used for this. Embedding models create vectors for
semantic similarity; they do not reliably emit structured entities and
relationships. A small local instruction model is the right tool for the
LLM-assisted part, with deterministic CREXX rules acting as guardrails and the
baseline for comparison.

## DOT Export

DOT is an inspection view over the graph stored by the native engine:

```bash
./cmake-build-debug/crexx-rag export-dot ./history.cprag clan,place associated-with,held-land-in 30 > history.dot
```

Install Graphviz on macOS with:

```bash
brew install graphviz
```

Render to SVG or PNG:

```bash
dot -Tsvg history.dot -o history.svg
dot -Tpng history.dot -o history.png
```

CREXX may call `rxrag.exportdot(...)` or the wrapper's `graphDot(...)`, but the
engine emits DOT. The profile's real job is to decide which nodes and
relationships should exist.
