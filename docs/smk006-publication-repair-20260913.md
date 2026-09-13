# RAG-SMK-006: automatic vector publication repair

Status: repaired and locally qualified. Focused QA passes **5/5 in 52.41 seconds**;
the full suite passes **68/68 in 944.08 seconds**, exit 0. The matching
scratch-installed executable also passes the new publication/recovery fixture.
No hosted repeat or cross-platform qualification is claimed.

The user approved fixing this defect before the next document-import smoke.
Work paused while the user updated installed CREXX, then resumed with the
requested rebuild. Installed package is **crexx-1.0.0-beta.3+local.g037e7939bc29**
from `/Users/adrian/.local`. The authoritative checkout remains
`/Users/adrian/CLionProjects/crexx-rag-review`, `temp/project-review`, with
uncommitted work on `9292c8d8d724b52fce34047c868f15531348faca`. No sibling CREXX,
original checkout, processing-master or permanent query-copy change was made.

## Reproduction and historical escape

Test 1 completed all five missing embeddings but returned exit 8 at automatic
sidecar publication; explicit `vector rebuild --reconcile` recovered it. The
new `embedding_publication` fixture reproduces this using two local synthetic
embedding calls. It imports two chunks, pauses extraction, processes one
embedding, and publishes a partial index through ordinary commands. Test SQL
adds only a retained graph-only generation. Public migration/verification
confirm an aligned manifest and a still-compatible ancestral partial index.

The ordinary job command then completes the missing embedding. Its membership
at the newer generation makes the ancestral vector index incompatible. The
manifest still names that old index. Before the fix, automatic publication
fails the manifest guard despite two successful calls and two committed
embeddings. The verified baseline fails exactly three assertions: job exit
**8 instead of 0**, integrity exit **7 instead of 0**, and **zero instead of one**
complete vector publication. Partial-index, explicit recovery, rejected
manifest replacement, unchanged receipt/history and stopped-worker controls pass.
Existing ANN, embedding recovery and interruption controls passed **3/3 in
36.25 seconds** against the rebuilt unchanged product before implementation.

Earlier tests covered first-index recovery and explicit vector rebuild but did
not finish a partial ancestral index through automatic job publication. No
assertion was disabled, inverted or weakened. During fixture preparation,
terminal `job run` correctly refused rerunning a completed job; the no-op/fault
controls therefore use public `worker start --job`, which reaches the same
publication path. The fault control removes the derived manifest and blocks
its replacement, ensuring it tests an actual write rather than an aligned no-op.

## Owning fix

`ragembedding.buildannvectorgeneration` now checks and recovers the manifest
before either a new or replayed vector publication, after input, dimension,
coverage and replacement checks. It composes the existing transactional
`ragstore.recovermanifest` operation. The former replay-only branch and the
unconditional `ragproduct._vectorrebuild` recovery are removed, giving both
entry points one owner for the rule. Existing command writer checks and
`ragbackup` sidecar publication/fencing guards remain. Provider calls, source
bytes, immutable receipts, embedding BLOBs and schema are unchanged by recovery.

The new regression also rejects manifest replacement after results commit,
requires that error to remain visible, and proves recovery/repeated publication
preserve complete attempt, provider-run and embedding-link rows without a call.
The original mixed job stays paused with extraction queued and all workers stop.

## Exact artifacts and qualification

| Artifact | SHA-256 |
| --- | --- |
| Rebuilt baseline native | `72f7ec6ef88cf286b978dfebdf85305347febc4cd3e5197a6bfe2908913e9aba` |
| Rebuilt baseline linked | `36e7c718868e35b049d0e4f9948592c129f11512640b713f778db01f6d99d7b8` |
| Fixed candidate native | `1572df54e58261d6300bbdf44903edfb3b36a07f6cd164ad3357b7d95377a7a5` |
| Fixed candidate linked | `c1da0015c6ff6bf99f44e2ca5750cfc9cc7ec9e7510fb160e7d91cb2c0e5a5af` |

Focused tests: `embedding_publication`, `embedding_recovery`, `ann_methodology`,
`native_publication`, `native_interruption`: **5/5**, 52.41 seconds. Full QA:
**68/68 in 944.08 seconds**, exit 0, on the updated installed CREXX. The
scratch-installed replay passes both publication and fault/history controls,
with exactly two synthetic calls and the same native hash. [Evidence](qa/smk006-20260913/) retains
baseline failures, passing controls, configure/build logs and the bounded patch.
No new hosted provider run, commit or push has occurred in this repair.

## Next smoke preparation

A public backup of the repaired generation-24,922 master was created and
verified at `/private/tmp/crexxrag-smk006-V6YatF/smoke-library`. A 952-byte
Bannockburn excerpt from the 1911 Encyclopaedia Britannica is staged beside it,
with provenance. It has not been ingested or sent to a provider.

The copy's prospective source/budget configuration is blocked by inherited
paused jobs, including a retained uncertain outcome. A public cancellation
request in the disposable copy did not settle that hold; no waiver, SQL repair
or provider replay was used. The master remains unchanged. A preference question
is pending: investigate that configuration/hold boundary first, or perform the
new-document smoke in a fresh empty scratch library. Exact hosted selections
and limits must be concrete before live execution. The Test 1 paid window is
expired and is not reused.

Final evidence inventory: **30 files**, each covered by `SHA256SUMS`.
The normal per-user RAG installation was not replaced; the rebuilt executable
and matching scratch installation are identified above.
