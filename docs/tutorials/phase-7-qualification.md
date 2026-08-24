# Phase 7 tutorial: qualify the product and make the cutover decision

Phase 7 is a qualification exercise, not another feature demo. This walkthrough
replays the generic IT and Scotland-shaped corpus gates, lifecycle/failure
injection, public surfaces, installed-package checks, and the explicit hosted
generation/embedding canary. It finishes by reading the retained cutover
decision rather than changing the default executable.

The current decision is to **reject/defer cutover**. Native-v1 remains the
default oracle. No command in this tutorial renames or deletes it.

## 1. Configure against an installed CREXX package

Use a scratch-installed CREXX prefix and keep both source fallbacks off:

```bash
export CREXX_PREFIX=/path/to/installed-crexx
cmake -S . -B cmake-build-debug \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH="$CREXX_PREFIX" \
  -DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF \
  -DCPRAG_ALLOW_VENDORED_CREXXPA=OFF
cmake --build cmake-build-debug --parallel 10
```

## 2. Run the recurring qualification

The aggregate target depends on the permanent Phase 3–6 gates, then audits the
Phase-7 record:

```bash
cmake --build cmake-build-debug --target phase7_qualification --parallel 10
ctest --test-dir cmake-build-debug \
  -R '^(phase3_ingestion|phase4_improvement|phase5_retrieval|phase6_surfaces|phase7_qualification)$' \
  --output-on-failure
```

This is credential-free. It covers optimized and non-optimized cREXX on
`rxvme` and `rxbvm`, generic IT and Scotland-shaped judgements, source
lifecycle and crash recovery, worker fencing/concurrency, generation
visibility, backup/restore, zero-write planning, CLI/ADDRESS/MCP equality,
capability denial, and the native-v1 comparison points.

The result must end with:

```text
Phase 7 qualification record passed: P7-01 through P7-08 are evidenced and cutover is explicitly deferred
```

## 3. Run the explicit hosted generation and embedding qualification

Hosted credentials are assumed available for this non-recurring step, but only
the symbolic reference is retained. Export the key in the operator environment:

```bash
export OPENAI_API_KEY='...'
cmake --build cmake-build-debug --target phase7_hosted
```

The target refuses to run without `env:OPENAI_API_KEY`. Its secret-safe
external harness makes exactly one structured generation and one two-input,
128-dimensional batch-embedding request: two calls total, one attempt per
call. Request headers, response bodies, and credential values are not written
to the retained output.

Inspect the secret-safe result:

```bash
cat cmake-build-debug/phase7-hosted-external/summary.json
```

A pass ends with:

```text
P7_HOSTED_OK provider=openai generation_model=gpt-5.6-luna embedding_model=text-embedding-3-small credential_reference=env:OPENAI_API_KEY public_fixtures=1 calls=2 max_attempts=1 generation=ok embedding_batch=2x128
```

Now reproduce the cREXX provider-path blocker separately:

```bash
cmake --build cmake-build-debug --target phase7_crexx_hosted_probe
```

At the retained revision this target exits nonzero after recording a
`category=timeout code=-5` response-completion failure in
`cmake-build-debug/phase7-hosted/hosted-output.txt`. That failure is expected
evidence for the reject/defer decision, not a passing QA command. Local and
synthetic provider tests remain green, and the external two-call qualification
proves that the credential, provider availability, request shapes, and account
permissions are valid; it does not qualify the cREXX adapter.

## 4. Inspect the comparison and safety evidence

The recurring work directories contain the exact source/results for the
comparison:

```bash
sed -n '1,160p' cmake-build-debug/phase3-ingestion/commands-and-output.txt
sed -n '1,200p' cmake-build-debug/phase4-improvement/commands-and-output.txt
cat cmake-build-debug/phase5-retrieval/baseline-metrics.txt
sed -n '1,200p' cmake-build-debug/phase6-surfaces/commands-and-output.txt
```

Check the installed-package boundary using the Phase-6 tutorial. Also inspect
the configured registry rather than trusting an arbitrary module or provider
name:

```bash
rg -n 'operatorregistry|architecture-local|it-architecture-profile' \
  crexx/application/config
```

The permanent privacy tests deny forbidden routes before client construction.
Read/plan tests compare the SQLite database and manifest hashes before and
after the operation.

## 5. Audit retained files without printing secrets

Do not dump the environment. Scan only versioned files for forbidden credential
forms:

```bash
git grep -nE '(sk-[A-Za-z0-9_-]{20,}|AIza[A-Za-z0-9_-]{20,}|Bearer[[:space:]]+[A-Za-z0-9_-]{20,})' -- . \
  ':!docs/archive/**'
git diff --check
```

The expected secret scan has zero matches. Symbolic references such as
`env:OPENAI_API_KEY` are intentional.

## 6. Read and challenge the cutover decision

Open the [cutover decision](../evidence/2026-08-24-phase7/cutover-decision.md)
and verify each blocker against the implementation. The important distinction
is that the language/runtime and public read/plan surfaces qualify well, while
the cREXX hosted provider still loses response completion, the public worker
path does not yet bind a production provider adapter, and it does not drain
embedding work. Several requested same-session production-scale comparisons
also remain incomplete, and exact downstream Linux is open.

Therefore Phase 7 completes by selecting the roadmap's third outcome:
**reject/defer cutover and keep the oracle default while addressing evidence**.
That is a valid, evidence-led gate result—not permission to weaken the checks.
