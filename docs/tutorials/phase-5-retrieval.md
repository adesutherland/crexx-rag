# Phase 5 Tutorial: Retrieval And Evidence

This tutorial exercises the real Level-G Phase-5 path after the Phase-3
folder ingest and before any Phase-6 transport adapter. It creates a scratch
library, plans one focused question, embeds only missing chunks through a
deterministic provider, publishes an exact `rxvector` generation, retrieves
through lexical/vector/graph channels, encodes a bounded answer context, and
resolves one stable citation back to its immutable revision bytes.

No hosted credential is required for the repeatable tutorial. The hosted
quality qualification is a separate, explicit, public-fixture-only step at the
end.

## 1. Configure A Development Build

Use an installed CREXX package and keep source fallback disabled:

```bash
cmake --preset debug \
  -DCPRAG_USE_INSTALLED_CREXX=ON \
  -DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF \
  -DCPRAG_ALLOW_SDK_SOURCE_FALLBACK=OFF
cmake --build --preset debug --target phase5_retrieval
```

The target compiles every Phase-5 source both optimized and non-optimized and
runs both concrete VMs. It also runs the frozen nine-question judgement set and
the preserved native-v1 MCP oracle. A passing target ends with:

```text
Phase 5 passed: four optimized/non-optimized dual-VM retrieval/tutorial cells, exact rxvector generation, 9/9 frozen deterministic judgements, stable evidence packets, and native-v1/full-context baselines
```

## 2. Read The Executable Scenario

The executable source is
`crexx/tutorials/phase5_retrieval_scenario.crexx`. Its six exact NDJSON records
are frozen in `tests/expected/tutorial-phase5.jsonl`.

The first operation constructs a `crexx-rag.query-plan/1` value:

```text
planquery(store, profile, question, "tutorial-retrieval-v1",
          expose query_plan, expose error)
```

The plan normalizes the question, preserves exact phrases, expands registered
aliases and bounded spelling candidates, records intent and ambiguity, reads
versioned term statistics, and hashes the canonical plan. It performs no
provider call.

The tutorial then registers an immutable embedding profile and embeds only the
five missing live chunks in batches of two:

```text
registerembeddingprofile(store, "tutorial-embedding", "fixture",
                         "tutorial-embedding", 4,
                         envelope_sha256, expose error)
embedmissing(store, "tutorial-embedding", provider,
             "local", "local", 100, 2, 1000,
             expose embedding, expose error)
```

Privacy and route policy are checked before invoking the provider. Each stored
embedding binds provider, model, input, profile and dimension. Replays attach
compatible reusable values and resume incomplete batches instead of replacing
published state.

Next, publish the selected exact sidecar:

```text
buildexactvectorgeneration(store, "tutorial-embedding", 1000,
                           expose vector_generation, expose error)
```

The provider writes canonical `f32le-v1` data to an immutable `.rxvec` sidecar,
checks its SHA-256 identity, and publishes a
`crexx-rag.rxvector-generation/1` record atomically. SQLite remains
authoritative; the sidecar is rebuildable.

## 3. Retrieve A Typed Evidence Packet

The query embedding is supplied as binary `f32le-v1` and all result ceilings
are explicit:

```text
options = .ragretrievaloptions(
    "tutorial-retrieval-v1", "tutorial-embedding", query_vector,
    24, 12, 1000, 2, 6, 4, 4, 60)
retrieveevidence(store, profile, question, options,
                 expose retrieval, expose error)
```

`retrieveevidence` combines:

- focused SQLite FTS5 variants and bounded adjacent context;
- installed exact packed `rxvector` search over fixed-size pages;
- directed typed-graph paths resolved back to supporting passages; and
- reciprocal-rank fusion with directness, source diversity, hop decay,
  temporal relevance and deterministic tie ordering.

If the vector generation, dimension or scan ceiling is incompatible, the
result declares its exact fallback state and continues lexically. Vector or
graph proximity is exposed only as a lead; neither becomes accepted support.

The primary result is `crexx-rag.evidence/1`. It keeps passages, accepted
claims and their independently typed support, contradiction polarity, source
stance and attribution, effective time, ambiguities, conflicts, graph leads,
gaps and a trace separate.

For a model-facing prompt, encode the smaller typed projection with a byte
ceiling:

```text
encodeanswercontext(retrieval.evidence(), 65536,
                    expose context, expose error)
```

The resulting schema is `crexx-rag.answer-context/1`. Every passage/support
citation has this stable form:

```text
crexx-rag:<library-id>:<source-id>:<revision-id>:utf8-<start>-<end>
```

Resolve it against the immutable revision rather than the current source:

```text
resolvecitation(store, passage.citation(),
                expose resolved_passage, expose error)
```

This makes a citation continue to resolve after a later source revision is
published.

## 4. Inspect The Expected Records

A successful tutorial emits exactly:

```jsonl
{"step":"plan","schema":"crexx-rag.query-plan/1","fingerprint":"sha256","provider_calls":0}
{"step":"embed","state":"complete","embedded":5,"provider_calls":3,"credentials_used":0}
{"step":"publish-vector","state":"published","dimension":4,"rows":5,"format":"rxvec"}
{"step":"retrieve","state":"complete","vector_state":"active-exact-rxvector","passages":5,"candidate_ceiling":24}
{"step":"answer-context","schema":"crexx-rag.answer-context/1","bounded_bytes":65536,"stable_citations":true}
{"step":"resolve","immutable_revision":true,"utf8_byte_span":true,"same_library":true}
```

## 5. Run The Explicit Hosted Quality Qualification

Only use this bounded step when the six checked-in fixtures are approved for
the selected hosted provider. The tool refuses to run without the explicit
confirmation flag, reads the credential from the environment, and records only
the symbolic reference `env:GEMINI_API_KEY`:

```bash
GEMINI_API_KEY='<provider key>' \
python3 tools/qualify_phase5_hosted.py \
  --packet-dir cmake-build-debug/phase5-retrieval/packets \
  --fixture-dir tests/fixtures/phase0 \
  --judgement-dir docs/evidence/2026-07-28-phase0-gate1a/judgements \
  --output-dir /tmp/crexx-rag-phase5-hosted \
  --confirm-hosted-public-fixtures
```

The fixed protocol uses nine questions, one typed-context answer and one
full-source control answer per question, plus two blinded independent scorer
resets. A third scorer is permitted only for the declared disagreement rule.
Temperature is zero, Gemini thinking is minimal, there is one attempt per
call, and no secret value, request header, or raw credential is written to the
repository.

The retained 2026-08-23 run used Gemini 3.5 Flash: 36 calls, 183,033 input
tokens, 7,335 output tokens, no adjudications, 9/9 passing typed cases,
143/144 typed score, 130/144 full-context control score and zero critical
failures. Hosted output is non-repeatable qualification evidence, not the
ordinary regression oracle.

## Current Limits

- These are Level-G development contracts. The installed CLI, `ADDRESS RAG`,
  MCP and agent-skill adapters arrive in Phase 6.
- The repeatable target uses a deterministic embedding provider and makes zero
  outbound calls.
- The retained micro-corpus full-source text is smaller than the typed answer
  contexts because it is only 5,099 bytes per question; the typed contexts
  carry stable provenance and semantics. Do not infer a universal context-size
  win from this fixture.
- The incubated cREXX hosted adapter still loses completion on the tested
  hosted POST responses even though direct HTTP/1.1 calls and CREXX TLS tests
  succeed. Phase 7 owns that provider-surface qualification gap.
- Native-v1 remains an oracle. There is no cutover, native retirement, push, or
  Linux-completion claim in this phase.
