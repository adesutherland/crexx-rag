# Test 1: five missing embeddings — 13 September 2026

The five missing Scottish-history embeddings are repaired. Final coverage is
**34,905/34,905**, the published 768-dimensional Gemini vector index is ready,
and library/repository verification passes with zero issues at generation
**24,922**, schema 17. This is a successful corpus repair using the documented
provider-free publication recovery. The initial `job run` returned exit 8 at
automatic vector publication; that product defect remains open as RAG-SMK-006.

## Authority and artifact

The user explicitly approved only these five public-history chunks to Google's
`generativelanguage.googleapis.com`, model `gemini-embedding-2`, at most five
additional calls in a fresh five-minute window, and a combined configured
per-call cost cap of **$0.005**. No reasoning calls were included. Initial
automatic approval review rejected apply; the subsequent explicit approval
preceded both successful apply and run. The old overnight window was not renewed.

- Checkout: `/Users/adrian/CLionProjects/crexx-rag-review`, branch
  `temp/project-review`, uncommitted candidate on `9292c8d8d724b52fce34047c868f15531348faca`.
- Processing master: `/Users/adrian/testrag/overnight-scottish-20260909/library`.
- Frozen executable: `/Users/adrian/testrag/overnight-scottish-20260909/test1-embeddings-20260913/artifact/bin/crexxrag`.
- Native SHA-256: `62eaaa2292e210b0c468d2de58ed126ca92557a1a24760109d863c764b85fa81`.
- No product source changes for Test 1. The artifact retains the preceding
  **67/67 full-suite**, **9/9 focused**, **5/5 scratch-installed** qualification
  in [the four-fix record](four-smoke-fixes-20260913.md). This does not cover the
  newly observed automatic publication defect.
- A public backup was created and verified before policy/run changes, then
  moved to `/Users/adrian/testrag/overnight-scottish-20260909/test1-embeddings-20260913/before-backup`.
  The retained backup output names its original temporary location. Backup
  generation 24,922, schema 17, manifest aligned, zero repository issues.

## Repair and execution

All five original failures were confirmed Gemini quota errors, with one
recorded call each and pending deduplicated retry requests. None had an unknown
provider outcome or reusable output. The selected policy changed only
`provider.gemini-embed.max_attempts` from **1 to 2**, using public hash-checked
`config set`, reviewed `config plan/diff`, then `config apply`. Reasoning and
general maintenance ceilings remain **1**. No task/attempt history was reset.

Policy SHA-256 changed from
`e2d82f0fe11043986f25c03e917b9897ab11a47f5b10ff833db906902d516bb0` to
`9a180b6121e8cdbcb663817a5613a513d87aeb78e175b8ad3abc1aae37039c6d`.
Current snapshot is `config-bd4ae91b6a019ac3453baeba`; the change is operational,
with unchanged semantic hash and generation. The embedding ceiling remains 2
after this completed test; it is not authority for another paid run.

Public `maintain plan --embeddings-only --minutes 5` selected exactly the five
occurrences in [targets.json](qa/test1-embeddings-20260913/targets.json), with
zero cognitive items. Its exact reviewed digest was
`e41308a080c08e240a78d0f513c5fac206c4d36c9ab78ddf8651ebeee7f36b40`.
The new job is `job-maintenance:e41308a080c08e240a78d0f513c5fac206c4d36c9ab78ddf8651ebeee7f36b40`.
Its window was **12:23:19–12:28:19 UTC**. Public `maintain apply` queued five
items with zero calls; ordinary `job run` used eight configured workers and the
frozen executable through `CREXXRAG_SELF`.

All five provider runs succeeded between **12:24:23 and 12:24:28 UTC**.
There were **1,051 input tokens**, zero output tokens, **2,732 ms** recorded
provider time and **208 microunits ($0.000208)** recorded cost. The fifteen
worker attempt records comprise five successful calls and ten admission
deferrals with no provider-run ID; deferrals are not additional API calls.
All eight workers and their controller stopped. No unsettled or uncertain
provider outcome remains in this job.

## Publication recovery and final acceptance

Automatic post-job publication returned `unavailable`, exit 8:
`library manifest must be aligned before sidecar publication`.
The job itself had five processed items and five successful provider runs.
The intervening report showed 34,905 active embeddings but no compatible
published rows; verification reported an invalid manifest with zero repository
issues. Those failed outputs are retained, not counted as successful checks.

After workers drained, ordinary `vector rebuild --reconcile` recovered the
manifest, published all **34,905** stored vectors with **zero provider calls**,
and reconciled **ten** already-covered historical embedding items. No duplicate
links needed closing. It retained the previous failed attempts and receipts;
the five original failed-attempt responses compare exactly with the verified
pre-test backup through public `job attempts --item` reads.

| Acceptance | Result |
| --- | --- |
| Exactly five selected tasks | All processed; durable states resolved; pending retry requests completed |
| Embedding coverage and published index | 34,905/34,905; zero missing; ready; dimension 768 |
| Paid scope | Five successful Gemini embedding calls; zero reasoning calls; $0.000208 |
| History | All five original failed attempts and receipt references unchanged |
| Original ingestion | Zero embedding dead letters; **545 extraction holds remain** |
| Knowledge preservation | Source, corpus, catalogue and graph counts unchanged |
| Final integrity | Manifest aligned; storage/repository/lexical/provenance checks pass |
| Worker cleanup | Controller stopped; zero live/registered workers or uncertain items in Test 1 |
| Automatic publication | Failed initially; public provider-free recovery succeeded; RAG-SMK-006 open |

The repair does not close the extraction/maintenance backlog or authorize the
previous proposed 3/6/3 policy. No further provider calls, commits or pushes
were made. The permanent ScottishHistory query copy and original checkout were
not modified. Test 1 evidence is in [this directory](qa/test1-embeddings-20260913/),
with [machine acceptance](qa/test1-embeddings-20260913/test1-acceptance.json) and
[SHA-256 inventory](qa/test1-embeddings-20260913/SHA256SUMS). A second copy is
retained under the Test 1 run directory's `evidence/`.

Documentation follow-up: `documentation_contract` passed **1/1 in 0.07s**;
`git diff --check` passed; all **43** retained evidence hashes verified.
No product code changed in Test 1, so the prior full-suite gate was not repeated.
