# Test 2: new-document live smoke — 13 September 2026

**Passed in 53 seconds, exit 0.** The requested baseline was committed first as
`ab620e5f303696ba477d6b91845f075789b779c9` on `temp/project-review`.
Its full suite passed 69/69; the tested source and installed artifact were
unchanged when this run started. The checkout was clean after that commit.

## Scope and result

The user approved this run by requesting “commit the baseline then run test 2”,
following the concrete bounded Test 2 proposal. Only the new Bannockburn source
job ran on the disposable full-corpus copy. The approved ceiling was five minutes,
eight model calls including at most four managed Codex turns, and $0.005 Gemini
cost, using two workers. The actual run was **16:06:03–16:06:56 UTC**.

| Check | Result |
| --- | --- |
| New source | One 952-byte public-domain 1911 Bannockburn excerpt, two chunks |
| Processing | Four of four items processed: two embeddings and two claim extractions |
| Codex | Two successful managed `gpt-5.6-luna` turns; 37,555 input and 2,001 output tokens; subscription allowance |
| Gemini | Two successful `gemini-embedding-2` calls; 248 input tokens; **$0.000049** recorded cost |
| Remaining work in this job | Zero queued, running, dead-letter or uncertain items |
| Automatic vector publication | Published generation 24,925, covering **34,907/34,907** chunks |
| Storage and repository verification | Passed; zero issues; manifest aligned |
| Retrieval and citation | New source retrieved lexically; resolved citation exactly matches source bytes 502–951 |
| Shutdown | Both workers and their controller stopped; all three PIDs confirmed not running |
| Repeat import | Already passed as `identical-no-op` during the provider-free preparation |

One embedding attempt was deferred by ordinary provider admission before making
a call; it then succeeded automatically. There were five local attempt records
and exactly four provider calls. No provider failure, manual redo, budget renewal,
worker replacement or manual vector repair was needed. Aggregate provider time
was 45,591 milliseconds across parallel calls; wall runtime was 53 seconds.
The zero monetary Codex entry represents subscription charging, not free usage.

Total provider runs rose from 82,549 to 82,553 and attempts from 116,184 to
116,189. The four new provider runs belong to this job. Embedding payloads are
deduplicated: 30,477 stored payloads cover all 34,907 published chunk occurrences.
Query inspection used lexical retrieval and made no provider call; a hosted
reasoning-answer smoke was not part of Test 2.

## Reproduction identities

- Library: `/private/tmp/crexxrag-smk006-V6YatF/smoke-library`
- Policy: `/private/tmp/crexxrag-smk006-V6YatF/test2.conf`
- Policy SHA-256: `0541ed3efa5cfc78f07e39ea3e9fed50fb5547d1e5b82e8214fc92956be15dcb`
- Snapshot: `config-a211c0fede4237fe77bbc797`
- Job: `job-sha256:0916c52c55fea9da892cd37de730e5abc2af5c17e882fb5cd0bf8444e2f38095`
- Executable: `/private/tmp/crexxrag-simplify-20260913/installed/bin/crexxrag`
- Native SHA-256: `751e3ca283c036f524feee93d5eb6b7565ec424bd4cd18fce038bc419fae0da3`
- Installed CREXX: `crexx-1.0.0-beta.3+local.g037e7939bc29`

The run used the public `job run JOB --count 2` command with the listed library,
policy, `scottish-history-profile`, JSON format and control access. Verification
used public job/item/worker inspection, `library verify`, `query inspect` and
`citation show`, plus read-only accounting of the selected job's attempts/runs.

Evidence: [acceptance](qa/test2-new-document-20260913/acceptance.json),
[run](qa/test2-new-document-20260913/run.json),
[final status](qa/test2-new-document-20260913/completed-status.json),
[verification](qa/test2-new-document-20260913/verify.json), and
[accounting](qa/test2-new-document-20260913/accounting.json).
The directory includes source provenance and evidence checksums.

The master corpus, permanent ScottishHistory query copy and normal installation
were not changed. No push occurred. This result and handoff are follow-up working
tree documentation after the baseline commit. Test 2 is complete; its authority
does not launch maintenance or further hosted smoke tests.
