# Retrieval tightening and native dependency comparison — 19 September 2026

Adrian requested a phase comparison with the existing CREXX route, tightening
both implementations, and evidence to judge the additional plugin. The bounded
RAG changes and corpus comparison are complete, with 131/131 required local
cases passing and the exact-input receipts audited before delivery.

## Outcomes and acceptance

1. Preserve both public retrieval routes, evidence/ranking, visibility, window
   aggregation, byte ceilings, early rejection before provider work and
   publication recovery. Keep schema, model, defaults and corpus semantics fixed.
2. Replace quadratic binary accumulation and reuse verified sidecar bytes only
   within one query. Re-read SQLite's selected publication after provider work;
   a changed identity reloads and validates, while verified bytes remain safe
   even if their file disappears after reading. No cross-request cache.
3. Profile the existing IVF/cREXX route and native exact route on the same frozen
   corpus/questions. Separate native math, index representation/loading and the
   rest of the query. Also compare existing native `rxvector` and USearch kernels
   on identical packed matrices and question vectors.
4. Apply any additional bounded, measured route-specific tightening with
   characterization first. Report exact versus approximate results honestly.
5. Complete focused acceptance, compare the uninstrumented Release candidate,
   then account for the full required local gate once, reusing unchanged passes.
   Preserve all failed attempts and remaining limitations. No commit, global
   installation, master-corpus change, publication or CREXX donation is included.

## Baseline and coverage

Baseline native executable SHA-256:
`95e816a8656523e089d61003c57c2e547a0a43c3da030d84f7a847e6d64fac2b`.
Sources are the existing uncommitted working tree on `e949884` with its unrelated
changes preserved. The candidate continues using the same private installed
CREXX cohort, without modifying a sibling checkout.

The current `ann_methodology`, `native_vector`, `native_vector_public` and
`gemini_query` passing receipts were selected and reused before product changes.
Inspection confirmed corruption/missing-file, source visibility, duplicate-window,
publication, citation and provider-history assertions. `gemini_query` explicitly
requires missing/corrupt hybrid preflight to leave provider history unchanged.

New byte-for-byte reader characterization covers empty, one-byte, 65,535-byte,
65,536-byte, 65,537-byte and 131,073-byte files, arbitrary binary values, exact
ceilings, one-byte-too-small ceilings, subsequent successful reads, missing files,
zero ceilings and agreement with the independent bounded hash. It passed on both
VMs against unchanged product code in 5.86 s. An initial test-scope compile error
was corrected before recording this baseline; its failed receipt is retained.

New request-payload boundary tests additionally cover independent returned bytes,
path/checksum/ceiling invalidation, in-flight use after file damage, fresh-request
rejection, changed publication selection and current visibility after removal.

## Ownership

`ragfile` owns byte accumulation. `ragretrieval` owns the verified request payload,
sidecar preparation and current publication checks; `ragqueryservice` composes
them with provider preflight. The existing six-argument retrieval entry point
remains for workers and other callers; the prepared entry point shares its
implementation. No product rules enter C/C++, no persistent state is added and
the optional native plugin remains generic.

## Evidence

All scratch data, frozen baseline executable and runtime dependencies, build
logs, profiler variants, benchmark sources/results and final audit belong under
`/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/retrieval-tightening-20260919/`.
The IVF comparison library is an APFS copy of the previous native integration
test library. Configuration changes and vector reactivation use public commands.
No document embeddings are regenerated. All corpus-query/kernel measurements
deny network access and run serially when no build or test is running.

## Implemented changes

- `ragfile.readbinaryfilebounded` appends each block with `binappend`, retaining
  the same error and byte-ceiling contract.
- `ragqueryservice` asks `ragretrieval.preparevectorsidecar` to verify and retain
  the selected bytes before provider work. Retrieval rechecks the current
  SQLite publication and reuses the payload only when path/checksum/ceiling
  still agree. Changed publication reloads normally. The unchanged six-argument
  entry point serves workers and other callers through the same implementation.
- IVF page scoring relies on the native `rxvector` kernel's norm validation,
  removing a measured 54.5 ms duplicate component scan on the example question.
  Its zero-norm signal becomes the existing controlled retrieval error. Shape,
  finite decoding, distinct-parent limits, visibility and ranking remain intact.

The zero-norm fixture passed before this last change. Final targeted acceptance
passes `ann_methodology`, `native_vector`, `native_vector_public` and
`gemini_query` in 13.31 s. They cover both VMs where applicable; the public
native test now also proves missing/corrupt preflight makes no provider call.

## Complete-query comparison

The final uninstrumented native executable is
`d4fcf1ebf547c4c91fd11367a780e9b896d54508bed5750dd0a2b9d0254efbf4`;
linked application is
`1407c84e3e1b451844d3daff08092498ae9f25890afcd5454b8b3c9b33af24d0`.
Forty serial offline public queries alternate route order on the twenty frozen
questions. Both use BGE, generation 29748, three graph hops and twelve passages.
All forty **complete evidence objects** match their respective retained baseline,
including scores, claims, trace and ordered citations. Both retain 12/20 known
reference passages; native also retains the previously proven exhaustive-IVF
passage order. Retrieval quality has not improved merely because it is faster.

| Route | Previous recorded median | Final median | Final range | Median peak RSS |
| --- | ---: | ---: | ---: | ---: |
| Existing IVF 16 groups / 4 probes | 1.610 s | **1.535 s** | 1.43–3.55 s | 294 MiB |
| Binary native exact | 1.565 s | **0.905 s** | 0.86–1.57 s | 459 MiB |

Previous twenty-question medians are historical controls, not fresh interleaved
runs. Three fresh interleaved baseline/final pairs of the representative question
provide a direct control: **1.54 s → 0.88 s** median, about 43% faster. Samples
are 14.58/1.53/1.54 s versus 0.88/0.88/0.88 s; the first very slow baseline
launch remains recorded and unexplained. Filesystem caches were not cleared.
These are local latency measurements, not cold-start guarantees or an SLA.

Holding verified bytes across embedding increases their lifetime. In those
same pairs, baseline median peak RSS is about 426 MiB versus 458 MiB final.
The native route uses more memory than IVF; reuse deliberately trades bounded
request memory for lower latency. Existing file ceilings still apply.

## Where the time goes

Copied, instrumented sources measured the shared fixes before removal of the
IVF duplicate norm scan. Two warmed repetitions of the representative question
are below; first-use runs are retained separately (5.31 s IVF, 1.60 s native).
These figures isolate costs and are not substituted for final uninstrumented
whole-command timings.

| Phase | IVF | Binary native exact |
| --- | ---: | ---: |
| Preflight selection, file read and checksum | 57.9 ms | 190.5 ms |
| Local model lifecycle and query embedding | 231.2 ms | 233.6 ms |
| Lexical retrieval | 10.4 ms | 11.0 ms |
| Reuse verified bytes | 0.4 ms | 5.4 ms |
| Parse complete JSON index | **591.5 ms** | — |
| Select and deduplicate IVF members | 30.6 ms | — |
| Fetch member vectors from SQLite | 68.8 ms | — |
| Decode page float32 to packed doubles | 1.9 ms | — |
| Duplicate norm scan, now removed | 54.5 ms | — |
| Scoring kernels for selected IVF pages | 4.3 ms | — |
| Merge page candidates | 13.3 ms | — |
| Decode and validate native index | — | 24.5 ms |
| Exact native search over all vectors | — | **1.44 ms** |
| Graph traversal, ranking and evidence assembly | 22.0 ms | 4.4 ms |

Startup, configuration, query planning, other checks, output and shutdown are
outside these selected intervals. IVF scores a subset; native scores all 36,328
windows. The native file is larger, so its checksum costs more, but it avoids
parsing the complete JSON member catalogue and loading every selected vector
through SQL. Neither route's serial measurements diagnose migration contention.

## Existing rxvector versus USearch versus a C float32 bridge

`rxvector` already performs cosine/top-k in C; it is not interpreted Rexx math.
A packaged cREXX harness compares the installed provider and USearch on the
identical full matrix and twenty frozen query vectors, five repeats each:

| Kernel through the cREXX interface | Median search, top 64 |
| --- | ---: |
| Existing `rxvector.topkcosine`, packed doubles | **12.008 ms** |
| USearch plugin, float32 | **1.425 ms** |

All 100 comparisons pass sorted-score agreement within 1e-6 and tie-aware
reference-cutoff membership checks. Matrix conversion to doubles takes 20.8 ms;
native index decode takes 24.3 ms. Neither includes file reading, hashing or BGE.

The authorized bridge investigation is a disposable generic C prototype, with
no installed API or sibling-checkout change. It reads float32 little-endian
values directly, accumulates cosine in doubles, and reuses CREXX's deterministic
heap/order code. The same twenty questions/five repeats give **10.015 ms** for
the bridge versus **9.744 ms** for the direct-C existing kernel control. These
C builds are a distinct compilation context from the packaged table above;
the difference must not be labelled provider-call overhead. All top-64 identities
match and scores agree within 1e-12. Controls cover ties, malformed shape, zero,
nonfinite and extreme finite float32 values. This is feasibility evidence, not
RXPA/lifetime/platform qualification.

The bridge avoids widening the 55,799,808-byte matrix to 111,599,616 bytes of
doubles. Direct float32 does not by itself make this scalar kernel as fast as
USearch. Its roughly 9 ms search disadvantage is nevertheless small beside a
0.9-second CLI query. Merely adding float32 arithmetic to the existing IVF route
would leave its 591 ms JSON parse in place.

**Recommendation:** retain the measured RAG improvements and the existing opt-in
native integration while reviewing consolidation before donation. A generic
float32 matrix owner and binary import/search capability in `rxvector` is a
credible smaller dependency choice for this corpus, provided it also supports
the compact loading path. An almost-as-fast full query is an inference from the
phase split; a complete `rxvector` binary route has not been implemented or timed.
Do not add another user-facing algorithm/configuration solely for comparison.
Preserve generic numeric/lifetime validation and RAG-owned visibility, labels'
meaning and parent aggregation. USearch remains valuable for its optimized
kernel and possible future ANN scale, but a separate dependency is difficult to
justify solely by saving roughly 9–11 ms here. HNSW is not part of this delivery.

## Final qualification and limitations

The required local selection passed in **528.38 s (8m 48s)** with eight process
slots: 127 fresh executions and four exact-input targeted passes reused without
product re-execution. Closing documentation is checked separately after edits.
The final `report.py --require-complete` audit accounts for **131/131 required
cases**, with no disabled, failed, interrupted or missing cases. Receipts are in
`qa-final.json`; `regression-final.log` retains the entire selection. Both VMs,
public/native packaging, scratch installation, Gemini fixtures, malformed output,
privacy and recovery remain covered. The separate scale lane and hosted calls
are outside this functional gate. No product rebuild overlaps QA.

This qualifies the recorded private installed CREXX cohort and this local
candidate. Migration contention, the earlier native-model timeout, broader
retrieval quality (12/20 known references here), other-platform qualification and
actual CREXX consolidation/donation remain open in the master register.

Retained unsuccessful development attempts include optional-class-argument
binding, missing factory initialization, and a test which reused a payload owner
after deliberately changing its publication. The test now prepares a new native
request after reactivation; publication-switch assertions remain. Scratch kernel
packaging failures were corrected with isolated source inputs and a complete
project link. All failed logs/receipts remain available. No assertion was disabled.
The master corpus, global install, Git publication and CREXX source remain unchanged.
