# Scottish vector group comparison — 18 September 2026

## Approved scope and acceptance

Adrian approved comparing the existing 16 groups/four probes with 64/eight and
128/eight on the migrated Scottish test copy. This is a configuration experiment,
not an automatic sizing implementation or a production installation. The
qualified retrieval-repair executable is retained without rebuilding.

1. Retain the original configuration and baseline results. Use public
   `config set`, `config plan`/`config apply` and `vector rebuild` operations.
   Only vector group/probe settings change; existing embeddings are reused.
2. Use the 20 positive questions and reference citations frozen in the
   17 September Scottish evaluation. Keep hybrid mode, two graph hops and
   twelve returned passages. Include a 16/16 all-groups reference to distinguish
   approximate retrieval changes from the existing hybrid ranking behavior.
3. Record whole-command wall/CPU time, scanned vectors, passage IDs, exact
   reference-citation rank and overlap with the exhaustive-search output.
   All-groups hybrid output is a comparison reference, not semantic ground truth
   or a pure vector recall benchmark. The 20 citations are positive examples,
   not an exhaustive annotation of every relevant corpus passage.
4. Run query timing serially, one fresh process per question and setting, with
   outbound networking denied. Each query embeds locally; no generation,
   ingestion or maintenance is requested. Report index rebuild time separately.
5. Verify generation and index integrity, restore the test copy's original
   configuration/index, and recommend a setting only if its quality/speed
   tradeoff warrants it. Preserve the live corpus and normal installation.

## Inputs and retained evidence

- Test library/configuration: `/Users/adrian/Documents/ScottishHistory/reports/bge-migration-20260918/`.
- Evidence: `group-comparison-20260918/` beneath that directory.
- Initial status: schema 19, generation 29748, aligned, zero reported issues.
- 36,328 embedding windows; BGE-small-en-v1.5, 384 dimensions; two training
  iterations. Retrieval scan ceiling 100,000 permits the all-groups reference.
- Executable: `cmake-build-retrieval-profile/crexxrag-native/package/crexxrag`;
  SHA-256 `6a9f6930ac61c3c9cada2388ddfebb29e437358e722212b62d2ebb824900e951`.
- Original configuration SHA-256:
  `05e013e12a5445e6917c6f1e705e0263818a3912acda79b7537954386530ab52`.
- Existing 127-case qualification is retained; this experiment does not change
  product, test or build inputs. No repeat of the complete suite is required.

## Results and decision

Retain **16 groups/four probes**. Neither tested replacement earns its small
speed gain: both lose known supporting passages. Automatic corpus-scaled
grouping is not justified by this experiment. A further performance change
should start with profiling the remaining work in the repaired query path.

| Groups / probes | Median query wall time | Median vectors scanned | Frozen reference citations returned / 20 | Mean passage overlap with all-groups output | Rebuild wall time |
| --- | ---: | ---: | ---: | ---: | ---: |
| 16 / 4, baseline | 1.61 s | 11,529.5 | 12 | 96.25% | Restoration attempt failed; see below |
| 64 / 8 | 1.53 s | 5,639 | 9 | 94.17% | 25.15 s |
| 128 / 8 | 1.54 s | 3,272 | 10 | 94.17% | 26.64 s |
| 16 / 16, exhaustive reference | 2.25 s | 36,328 | 12 | 100% | 27.38 s |

These are medians across 20 different questions, one command per question per
setting, with normal warm filesystem caches. They are not repeated-sample
confidence estimates. First-command effects are retained: baseline range
1.49–3.20 s, 64/8 range 1.45–1.86 s, 128/8 range 1.48–1.89 s, all-groups
range 2.19–2.38 s. Each successful command makes one local query-embedding call,
uses generation 29748 and reports the active ANN route with no generated answer.
All four index builds make zero provider calls; the failed restoration is
counted as a failure, not a passing build.

The 64/8 setting loses the frozen support for questions 1 (Culloden hunger),
9 (goats' milk replacing oatmeal in spring) and 11 (harvest singing timing
sickle strokes). The 128/8 setting loses questions 1 and 9. No previously
missing frozen reference citation is gained. The missing support text does
not reappear verbatim under another returned citation. The baseline's rank-one
Culloden passage is an especially clear regression. Passage overlap alone
would conceal these losses: most of each packet remains the same.

All-groups searching returns the same 12 frozen references as the baseline;
eight references are outside the final twelve even with every vector searched.
This is not evidence that those questions are unanswerable, or a 60% answer
accuracy score: other useful corpus passages may exist and the final ranking
also includes lexical retrieval, graph expansion and source diversity.

The observed vector reduction is substantial (about 51% and 72% of the
baseline median), but complete query latency falls only about 5% and 4%.
This points to other work dominating the repaired command; this experiment
does not establish which remaining phase is responsible. Group sizes are
uneven: 16 groups span 499–4,783 members, 64 span 31–1,553 and 128 span 4–1,084.
The sidecar also grows from 6.92 MB to 7.06/7.26 MB. No training-iteration,
model, ranking or automatic-sizing change was tested.

## Reference output ceiling

The first all-groups question failed with `serialized evidence exceeds the
configured byte ceiling` at the normal 262,144-byte limit. Its output/log is
retained as `g16-p16-q01-byte-ceiling-failure.*`. For the exhaustive reference
only, public configuration controls raised `retrieval.maximum_evidence_bytes`
to 1,048,576. Maximum successful reference evidence is 351,499 UTF-8 bytes.
The original limit was restored before 64/8 and 128/8; all ordinary candidate
outputs fit the original limit. This changes serialization admission, not
ranking or returned passage count. It is an operational constraint on using
all-groups queries, not a recommendation to change the normal limit.

## RAG-VEC-02 — superseded index reactivation fails

Returning the configuration to 16/4 and calling public `vector rebuild` fails
after 23.79 s with exit 7: `immutable sidecar target already exists or aliases
the source`. The original configuration replacement and its operational
plan/application succeeded. No provider calls or semantic generation changes
were involved.

The owning path is `ragembedding.buildannvectorgeneration` to
`ragbackup.prepareannvectorsidecar`/`commitsidecar`. Deterministic rebuilding
recreates the original index identity. The reuse/replay query only selects
`state='published'`; the earlier index is now superseded, so the path attempts
to publish it as new and the immutable-file guard correctly refuses. Removing
the file alone is insufficient: the retained vector-generation identity would
also conflict with the unconditional insert. This needs explicit, validated
reactivation of an existing derived index, preserving publication and manifest
transaction ownership, not weakened immutable-file checks or ad hoc SQL.

Required future regression: A → B → A at one semantic generation, with exact
membership/checksum/probe assertions, one selected published profile, intact
embeddings/provenance, zero provider calls, manifest alignment, and positive
controls for fresh publication and identical-current replay. Include missing
or corrupt old sidecars and failure preservation. The existing 127-case green
gate does not cover or close this observed defect.

The complete experiment library, including its configuration transition and
query receipts, is preserved at `group-comparison-20260918/trial-library/`.
Recovery uses public `library restore` from the existing, previously verified
`library-migrated-clean` backup, which contains generation 29748 and the original
16/4 index. This restores the corpus/index baseline while retaining diagnostic
history separately. Public restoration completed in 176.85 s; independent
`library verify` passed in 15.54 s with zero storage/repository issues,
generation 29748 and an aligned manifest. Both original sidecars, including the
36,328-row BGE index at 16/4, are restored. The selected configuration is
byte-identical to `original.conf` (SHA-256 recorded above). The live Scottish
corpus is untouched. Receipts are `backup-restore.*` and `after-verify.*`.

## Reproduction and evidence

`questions.json`, `original.conf`, each lane's configuration, public change
plans/application receipts, rebuild outputs/timings and all 80 successful
query outputs/timings are retained in the evidence directory. `analyse.py`
only reads these files: it never runs product operations, inference or SQLite
queries. `results.json`/`results.txt` contain every question's ranks, complete
passage IDs, timing, overlap and lane summary. `group-distributions.json` retains
every group size; `lost-support-review.json` retains the lost reference texts
and replacement packets. No broad QA or inference-model tests were repeated.
