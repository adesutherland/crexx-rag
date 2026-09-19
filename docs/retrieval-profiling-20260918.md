# Full-corpus retrieval profiling — 18 September 2026

The observed search delay is dominated by avoidable in-memory index handling.
The same 5,285,195,776-byte test database answers the lexical control quickly;
the slow vector path spends much of its sampled main-thread time copying values.
Accumulated history has not been independently varied, so this is not a claim
that history can never affect performance. Migration write contention remains
a separate RAG-PERF-01 investigation.

## Scope and measurements

Five serial public commands used the existing migrated **test copy**, generation
29748, and the installed candidate's frozen identical executable. They asked
the same question, returned at most twelve passages and generated no answer.
Three calls made one local embedding each; two lexical controls made none.
Network access was denied. No maintenance job, full regression suite, production
build or master-corpus operation was started.

| Command | Elapsed seconds | Notes |
| --- | ---: | --- |
| Lexical inspection, graph depth 2 | 1.004 | Read-only, 52 candidates |
| Lexical evidence, graph depth 2 | 0.402 | Normal query bookkeeping, 52 candidates |
| Hybrid, graph depth 2, OS sampled | 10.954 | 1,083 combined candidates |
| Hybrid, graph depth 0, OS sampled | 9.598 | 1,079 combined candidates |
| Hybrid, graph depth 2, unsampled control | 9.429 | 1,083 candidates; identical ordered citation IDs to sampled query |

These are diagnostic single observations, not medians or a concurrency capacity
test. All commands start a fresh process; OS caches were not flushed. OS sampling
can perturb timing. Disabling graph traversal does not remove the vector delay;
the sampled/unsampled difference must not be attributed entirely to graph work.

For the unsampled hybrid call, progress timestamps are 0.628 s at embedding
start and 0.894 s at embedding completion. **0.266 s** covers model startup,
embedding, model close and the recorded provider result. Approximately **8.535 s**
remains after that point. The sampled calls report 0.405 and 0.491 s for the same
embedding interval. The model is not the main cost in this example.

Each hybrid query probes four of sixteen vector clusters, fetching/scoring
11,006 of the 36,328 index members. Two six-second OS samples show
**4,036/5,094 (79.2%)** and **3,572/4,967 (71.9%)** main-thread samples in
`copy_value`, largely `memmove`. These are percentages of sampled stacks, not
an exact partition of complete-query time. They do not reproduce the migration's
SQLite transaction-start waits.

## Reduced reproductions and ownership

The JSON sidecar is 6,915,868 bytes with 109,045 indexed JSON nodes. Small
standalone cREXX probes read that sidecar without opening SQLite or a model.
They use installed CREXX `15c8a3ba42009ab8b5a9b447aa8c06ce86b9b392`.
The original `rxjson.crexx` and `copy_value` source are unchanged between the
migration's e457f5ec runtime lineage and this installed revision. The probes are
separate diagnostics, not end-to-end product qualification of the newer runtime.

The first four stored clusters contain 13,674 members; these are a fixed
reproduction set, not necessarily the four selected by the live question.

| Operation over those 13,674 members | Existing behavior | Diagnostic variant |
| --- | ---: | ---: |
| Parse full sidecar | 0.608 s | 0.614 s |
| Read members using repeated `element()` | 4.008 s | 0.365 s with borrowed internal buffers |
| Read members using `children()` | 3.667 s | 0.028 s with borrowed internal buffers |
| Duplicate checking with a growing string array | 3.037 s by value | 1.981 s by exposed argument |

The JSON comparison has an independently compiled, namespace-renamed copy of
the **unchanged** library as its control. The alternative differs only by using
`arg expose` for read-only binary inputs to `_json_node_u8`, `_json_node_u32`,
`_json_node_get`, `_json_member_node` and `_json_element_node`. Both selector paths
assert equal complete ordered results within each run. This is a reduced
reproduction and prototype, not complete JSON correctness/aliasing qualification.
The installed library and sibling CREXX checkout were not modified.

The generic JSON accessors pass large source/node/key buffers by value to their
helpers. Small-field reads therefore repeatedly copy large buffers. **CREXX's
`lib/rxfnsb/rexx/rxjson.crexx` owns this repair.** Using bulk traversal alone makes
only a modest difference until those copies are removed. After borrowing, the
remaining repeated `element()` traversal is visible: it walks from the first
sibling to the requested array position. Existing `children()` avoids that
repeated walk.

**RAG's `ragretrieval._vector` owns the other changes.** It currently iterates
members via repeated `document.element(members_node,m)` and calls
`_contains(member_keys,member_key)` for each member. `_contains` takes its array
by value and performs a linear search. Avoiding its copy helps but leaves the
quadratic comparison count. A future replacement must retain the full
parent-plus-input identity, so multiple windows of one parent remain distinct.
Do not solve this by discarding history, truncating evidence, reducing recall
or changing the model.

## Bounded next work

### Approved repair — 18 September

Adrian selected repairing the existing implementation before choosing a different
vector backend. The intended outcome is faster full-corpus hybrid retrieval
with the same model, index parameters, visibility, window identities, scores
and citations. No FAISS/USearch integration, index-format change, corpus
migration, history deletion or production installation is included.

Acceptance and sequence (candidate remains provisional until its speed verdict):

1. **AC-01 / STEP-01:** Retain the pre-edit tree and run the existing ANN/window
   behavior plus added duplicate-membership and ordering characterization before
   product edits. Retain the JSON public-contract baseline and add independent
   source/returned-value immutability checks before changing the private helpers.
2. **AC-02 / STEP-02:** In CREXX, borrow read-only JSON buffers through the five
   profiled helpers. Preserve public signatures, malformed-input behavior and
   independent document/value ownership on both concrete VMs and optimization
   modes. The owning record is CREXX
   `docs/planning/rxjson-accessor-repair-20260918.md`.
3. **AC-03 / STEP-03:** In `ragretrieval`, enumerate member nodes once with
   `children()` and replace the growing-array membership scan with the existing
   `.stem` dictionary. Keep the full parent-plus-input-digest key and first-seen
   ordering. Preserve all current candidate ceilings and ranking behavior.
4. **AC-04 / STEP-04:** After minimum focused correctness checks, measure the
   profiling-off Release candidate on the same migrated test copy and question.
   Compare complete ordered passage/citation IDs and scores with retained
   baseline evidence; record full-command and embedding intervals separately.
   CREXX's first-Release-verdict rule requires reporting this result before
   broader qualification or installation. No speed threshold is a functional
   test assertion.
5. **AC-05 / STEP-05:** After the speed verdict is accepted, account for the full
   required RAG gate once, reusing exact-input passing receipts; update the
   coverage/register evidence. Commit, publication and master installation are
   separate actions and have not been requested for this repair.

Design selection: borrowing the existing buffers is the measured minimal fix;
adding caches or changing JSON storage is unnecessary. RAG already has bulk
enumeration and a native-backed `.stem`; a new collection implementation or
sorting the candidate stream would add work or alter ordering. The existing
`StringHashSet` implementation was inspected and still uses a linear search,
so it is not suitable for removing this particular quadratic scan.

Adrian also proposed growing the group count with corpus size. A target number
of vectors per group is a candidate for that later investigation; group count
and probe count must be evaluated together against recall. This first repair
comparison retains the published 16 groups and four probes so it measures only
the code change, with no index rebuild or altered search allowance.

Subsequent approved [group comparison](vector-group-comparison-20260918.md)
completed 20 frozen questions across 16/4, 64/8, 128/8 and exhaustive 16/16.
The larger-group candidates save only about 4–5% in complete-query median time
and lose two or three known supporting passages. Retain 16/4; do not implement
automatic sizing from these results. The experiment also exposes RAG-VEC-02,
failure to reactivate a superseded index when returning to the original setting.

Repair checkpoint: the expanded ANN/window/duplicate characterization passed
before the RAG production edit (both VMs, 5.91 seconds). CREXX's four focused
JSON cases passed before and after its repair in both optimization modes and
both VMs (16 executions per side). The matching frozen-runtime native baseline
query took 10.47 seconds, with full passage objects identical to the earlier
9.429-second control. Evidence is in the sibling Scottish report directory
`retrieval-repair-20260918/`. Early copied-package launch failures are retained as setup failures,
not successful timing results.

### First Release repair verdict — accepted

The profiling-off native candidate uses the frozen installed CREXX 15c8a3ba4200
tools, with only the rebuilt JSON module substituted into its private Level-B
library, plus the RAG traversal/dictionary changes. The normal CREXX install
and Scottish master executable are unchanged. Candidate native SHA-256 is
`6a9f6930ac61c3c9cada2388ddfebb29e437358e722212b62d2ebb824900e951`.

Same question, migrated test library, generation 29748, model, hybrid mode,
two graph hops, twelve passages and 16/4 index parameters:

| Execution | Whole-command wall time | User CPU time |
|---|---:|---:|
| Matching baseline | 10.47 s | 8.51 s |
| Candidate 1 | 3.41 s | 1.51 s |
| Candidate 2 | 1.64 s | 1.48 s |
| Candidate 3 | 1.63 s | 1.47 s |

The three-run candidate median is 1.64 seconds (84.3% lower than this baseline,
6.38x ratio). This is a bounded diagnostic, not a statistical or broad-query
performance claim; the slower first candidate is retained. Every candidate
returns the identical full ordered passage objects (including citations and
all scores), claims and retrieval counts. All scan the same 11,006 of 36,328
vectors. Each command includes one local embedding call, with outbound network
denied and no generated answer. The embedding interval was not separately
instrumented in these trials; the earlier 0.266-second phase measurement
remains historical baseline evidence, not a fresh candidate measurement.

Focused candidate ANN acceptance passes on both VMs (6.55 seconds). The native
window/recovery case initially failed: one task entered dead letter with
`local embedding model load timed out`. An unchanged replay passed in 11.45
seconds. Preserve that intermittent failure; its cause is not established and
this is not a clean formal qualification. The JSON focused candidate remains
16/16 passing. Adrian accepted this verdict, authorized the CREXX hotfix-to-develop
publication, and then asked to continue RAG qualification while hosted checks
run. Package installation and the separate migration contention investigation
remain pending; no group/probe change is part of this candidate.

Retained evidence: `comparison.json`, query outputs/logs, both window-test
results, `native-window-first-failure.json`, `repair-artifact-hashes.txt`,
original/candidate JSON libraries and native baseline in the repair directory.

### Accepted RAG qualification — passed

AC-01 through AC-05 are complete for this bounded repair. The full required
fast/component/integration union in `cmake-build-retrieval-profile` passed in
763.96 seconds (12m43.96s), using eight declared execution slots. It executed
125 cases and reused the two exact-input passing ANN/native-window receipts.
The independent `report.py --require-complete` audit reports **127 passed**,
with no disabled, missing, failed or unrun case. CTest's two skipped entries are
verified retained passes, not exclusions. Scratch-installed product acceptance
also passed. The full build refreshed ADDRESS and test prerequisites without
changing the measured native executable. Tests use
private directories and synthetic loopback providers, plus the explicitly pinned
offline BGE fixture; no new Scottish corpus processing or hosted calls occur.

CREXX repair `65275452d90dd1d9ed8146650f7059b27ff9c56c` is published on both
origin/hotfix and origin/develop after 451 unique local passing checks. Its
automatic hosted checks remain separate. This RAG candidate intentionally
retains the already measured private installed-package copy: tools/runtime
15c8a3ba4200 plus the byte-identical repaired JSON module. A source-only upstream
push does not replace the normal installed library or an existing RAG native
executable. Global CREXX installation and Scottish master installation have
not been requested for this repair. RAG source changes remain uncommitted and
unpublished. Adaptive grouping and migration write contention remain separate
open work; the earlier native-model timeout and passing replay remain retained.

Commands and retained final evidence:

```sh
cmake --build cmake-build-retrieval-profile --parallel 8
ctest --test-dir cmake-build-retrieval-profile -L '^tier-(fast|component|integration)$' --parallel 8 --stop-on-failure --output-on-failure
python3 tests/qa/report.py --build cmake-build-retrieval-profile --require-complete --json <repair-directory>/qa-full-gate.json
```

`rag-full-build.log`, `rag-regression.log`, `qa-full-gate.json` and its text
report retain that gate. Closing these documentation records changes only
documentation inputs, so refresh `documentation_contract` once and audit the
final selection as `qa-final.json`; do not repeat unchanged product cases.

### Original profiling proposal (historical)

1. Transfer the reduced JSON accessor case to CREXX. Qualify a buffer-borrowing
   repair there, including public JSON behavior, aliasing, immutability and
   the same large-document control; retain the direct APIs.
2. In RAG, use existing bulk JSON traversal and remove avoidable list copies.
   Measure the remaining duplicate scan before choosing its simplest bounded
   replacement. Preserve index validation, distinct parent/window identity,
   ranking, source visibility and corruption handling.
3. Run affected ANN characterization/acceptance first, then repeat this same
   query comparison and compare ordered parent/citation results. Report new
   complete-query latency separately from isolated phase speedups. Account for
   the full required suite once at formal qualification, without rerunning
   unchanged passing work while exploring.
4. Profile maintenance separately with a short controlled scratch workload:
   transaction duration, admission/usage queries and database waiting at low
   versus higher worker counts. Existing worker samples prove contention, but
   do not yet separate long-ledger scans, write-lock scope and scheduling.

The initial profiling pass performed no product repair, installed-runtime
replacement, history deletion or fresh migration. The accepted private repair
and its later qualification are recorded above.

## Evidence

The private directory is
[`profiling-20260918`](/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/profiling-20260918).
It retains `results.json`, `profile-summary.json`, both OS samples, timed progress
events, all public outputs, the standalone probe sources and their hashes, and
unchanged-versus-borrowed JSON logs. The initial invalid progress-option attempt
was rejected before any query/provider execution. Early probe compile/link
attempts are setup failures, not corpus-query results or measured passes.

No messages were sent to another agent and no upstream issue was filed.
