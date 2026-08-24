# Phase 7 corpus qualification and cutover evidence

Date: 2026-08-24

Scope: macOS ARM64, installed CREXX consumer, optimized/non-optimized cREXX,
`rxvme` and `rxbvm`, native-v1 oracle, deterministic local/synthetic provider
fixtures, and an explicit bounded external OpenAI qualification. Exact downstream
Linux: open.

Status: qualification completed; Gate 7 decision is **reject/defer cutover**.
The native-v1 remains the default oracle. This record does not authorize
cutover, deletion, a release, a tag, or a push.

Credential values logged: zero. Hosted evidence records only
`env:OPENAI_API_KEY`.

## Checklist outcome

| Item | Result |
| --- | --- |
| P7-01 | Generic IT-architecture ingestion/retrieval passed in the permanent four-cell Phase-3/5 matrices: four IT questions, stable citations, aliases, ambiguity, negative claims, exact source/revision identity, incremental lifecycle, and zero critical failures. |
| P7-02 | Five Scotland-shaped questions passed at 80/80 inside the nine-question 144/144 deterministic matrix, covering agency/stance, epithet evidence, lineage, alliance/directness, and legal ambiguity. |
| P7-03 | Deterministic local and synthetic OpenAI/Anthropic/Gemini shapes passed. The retained Gemini quality run scored 143/144 with zero critical failures. A secret-safe external OpenAI harness completed structured generation plus a two-input 128-dimensional batch embedding in two calls. The current cREXX provider probe still failed response completion, which is a failed selection criterion. |
| P7-04 | Phase 3–6 gates exercised add/change/delete/rename/reorder, real `SIGKILL` rollback/resume, two-process fenced workers, retries/dead letter/cancellation, generation visibility, pinned backup during later writes, fresh restore, migration/idempotency, and hostile stale-plan zero writes. |
| P7-05 | Available same-invocation comparisons passed for ingestion counts, chunk identity, work-queue behavior, vector semantics, and evidence bytes. The audit found no exact production-scale same-session graph-promotion, evidence-latency/RSS, or model-bound overhead comparison; this is a failed production-selection criterion, not silently omitted evidence. |
| P7-06 | Scratch install/source-fallback-off proof passed in four compiler/VM cells. Symbolic-secret and credential-value scans were clean; denied routes create zero clients; registered config/profile/provider ids are explicit; read/plan database and manifest hashes are stable. Full product-native static packaging remains unavailable because the product owns a namespaced dynamic SQLite boundary. |
| P7-07 | Maintained roadmap, architecture, user guide, pipeline status, test strategy, tutorials, application docs, and known limitations were reconciled. Frozen historical evidence was not rewritten. |
| P7-08 | This bundle and the separate [cutover decision](cutover-decision.md) select reject/defer. No default, executable name, live library, native code, tag, remote branch, or release state changed. |

## Hosted qualification and cREXX provider finding

The cREXX provider wrapper still reports `HTTP total deadline exceeded before
response completion` on the current hosted POST path. A proposed downstream
per-phase timeout adjustment improved individual runs but did not make fresh
four-cell execution reliable, so it was not retained. The minimized cREXX
probe remains checked in and the explicit probe target records the failure
without printing a credential or response body.

The passing external hosted target's bounded contract is:

- provider/model: OpenAI `gpt-5.6-luna` generation and
  `text-embedding-3-small` embedding;
- public synthetic strings only;
- credential reference: `env:OPENAI_API_KEY`;
- provider-default generation temperature because this model rejects the
  `temperature` parameter;
- one attempt, 32 output tokens, two embedding inputs, 128 dimensions;
- two calls total, with no retained request/response body or header.

Result:

```text
P7_HOSTED_OK provider=openai generation_model=gpt-5.6-luna embedding_model=text-embedding-3-small credential_reference=env:OPENAI_API_KEY public_fixtures=1 calls=2 max_attempts=1 generation=ok embedding_batch=2x128 generation_input_tokens=48 generation_output_tokens=17 embedding_input_tokens=6
```

This proves hosted service/key/request availability and the generation plus
embedding shapes. It does not substitute for the failed cREXX transport path.

The separate retained Phase-5 Gemini result remains the answer-quality
authority:

```text
P5_HOSTED_OK provider=gemini model=gemini-3.5-flash credential_reference=env:GEMINI_API_KEY temperature_millionths=0 thinking_level=minimal max_attempts=1 public_fixtures=1 passing=9/9 score=143/144 control_score=130/144 critical_failures=0 calls=36 adjudications=0 input_tokens=183033 output_tokens=7335
```

## Comparison boundary

The matched tests establish that cREXX and native-v1 agree on the declared
source/chunk projection, queue consumer behavior, exact vector ordering, and
the frozen evidence questions. Phase 5 retained 69,295 bytes of typed answer
contexts versus 92,385 bytes of native-v1 MCP output for nine questions; the
typed path retained provenance/stance/time/gaps that the tiny full-text control
did not.

This is not the full P7-05 production selection proof. In particular, there is
not yet one production-shaped same-session harness covering final graph
promotion counts, evidence latency and RSS, model-bound overhead, and final
library counts across both implementations. The gate treats that absence as a
negative result.

## QA result

- recurring Phase 3–6 aggregate: pass;
- Phase-7 evidence/decision audit: pass;
- external OpenAI structured generation plus embedding, two calls: pass;
- cREXX hosted provider completion probe: fail, retained cutover blocker;
- scratch install, optimized/non-optimized external consumer, both VMs: pass;
- ordinary Debug and fresh Release focused gates: pass;
- focused Apple ASan through the CREXX runner: the complete recurring Phase-7
  aggregate passed with the coherent ASan-installed CREXX product and
  downstream build; retained log
  `/tmp/crexx-rag-asan-logs/phase7/20260824-015252-build/build.log`;
- Apple LeakSanitizer: unsupported, explicitly disabled, and not claimed;
- full ordinary Debug CTest: 74/74 passed in 207.08 seconds;
- credential-value/forbidden-form scan: zero matches;
- `git diff --check`: pass; and
- exact downstream Linux: open and not claimed.

## Gate result

Gate 7 chooses **reject/defer cutover and keep the oracle default while
addressing evidence**. Read/query/plan, ingestion/retrieval algorithms, hosted
generation/embedding protocol, and public transports are useful and qualified
within the recorded scope. The unresolved cREXX hosted response-completion
failure, public worker/provider and embedding-work gaps, incomplete production-
shaped comparison, and Linux replay prevent production selection.
