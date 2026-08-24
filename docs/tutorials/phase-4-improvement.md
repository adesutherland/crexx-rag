# Phase 4 Tutorial: Claims, Reviews, Improvement, And Workers

Status: executable development tutorial for the implemented Phase-4 algorithm.
The Level-G modules and durable schema-v2 behavior are implemented and tested.
The later Phase-6 tutorial now carries the public CLI, ADDRESS RAG, MCP,
installed-package, and narrow-skill walkthrough. This is not a release or
cutover claim.

CTest executes crexx/tutorials/phase4_improvement_scenario.crexx and compares
every line with tests/expected/tutorial-phase4.jsonl. The tutorial uses a
deterministic provider, so the recurring test spends nothing and retains no
secret. Its reviewed plan nevertheless carries the real symbolic credential
reference env:OPENAI_API_KEY.

## 1. Run The Scenario

    cmake --build cmake-build-debug --target phase4_improvement --parallel 10
    ctest --test-dir cmake-build-debug -R '^phase4_improvement$' --output-on-failure

The target compiles optimized and non-optimized Level G, runs rxvme and rxbvm,
checks exact tutorial output, runs the native-v1 work-queue oracle, kills a
claimed worker, waits for its database-clock lease to expire, starts two
competing OS-process workers, rejects the late fence, and exercises pause,
resume, drain, cancellation, retry, dead letter, heartbeat, reservations, and
the in-flight ceiling.

## 2. Promote Mentions Into Canonical Concepts

Phase 3 records candidate mentions and versioned decisions. Phase 4 promotes an
accepted candidate through:

    ragclaims.promotemention(
      store, candidate_id, canonical_label, concept_type,
      aliases, ambiguity_concept_ids, policy, config_snapshot_id,
      expose concept_or_ambiguity_id, expose error) = .int

An empty or one-element ambiguity_concept_ids value creates one canonical
concept, aliases, and a mention in a new semantic generation. Two or more
active concept ids create an explicit ambiguity set. The provider never
chooses or overwrites a canonical label.

Concept and ambiguity identity is SHA-256 over canonical, versioned policy
inputs. Mentions retain the accepted candidate decision and exact revision
chunk byte span. Promotion is transactional; a type, alias, candidate, or
identity collision aborts the generation.

## 3. Validate And Apply A Provider-Neutral Proposal

The immutable .ragextractionproposal records canonical endpoints and types,
directed relationship, qualifiers, effective time, exact evidence byte span,
support or contradiction polarity, stance, directness, attribution,
independent lineage, confidence, provider/model/request/prompt/extractor
identity, source scope, profile, and external-origin flag.

    ragclaims.validateproposal(
      store, proposal, policy,
      expose validation, expose error) = .int

Validation rejects malformed direction, polarity, stance, attribution,
effective time, confidence range, provenance, or bounded shape. Confidence
below 500,000 millionths, unknown types/relationships, unresolved endpoints,
canonical-label/type differences, unavailable evidence spans, self-links,
ambiguity, competing targets, and external proposals route to a typed pending
review. Only an accepted result can enter graph state.

    ragclaims.applyproposal(
      store, proposal, policy, expected_generation, config_snapshot_id,
      expose result, expose error) = .int

The transaction creates or reuses the directional/time-scoped claim and adds
independently addressable support. Reapplying identical support returns
identical-no-op with the same generation and zero SQLite changes. A second
span, polarity, stance, attribution, lineage, or extractor identity creates
independent strengthening or contradicting support.

    ragclaims.retractsupport(
      store, support_id, expected_generation, config_snapshot_id,
      expose error) = .int

Graph inspection is bounded and directed:

    ragclaims.traverseclaims(
      store, start_concept_id, relationship_filter, direction, maximum_hops,
      expose steps, expose error) = .int

Direction is outbound or inbound and maximum_hops is one through eight. The
return value is the number of ordered .ragtraversalstep records, or a negative
failure.

## 4. Rank And Plan Explicit Improvement

    ragclaims.rankchunk(
      store, revision_chunk_id, policy_version,
      expose rank, expose error) = .int

The rank exposes concept density, relationship cues, novelty, redundancy,
bridge value, source quality, unresolved risk, total score, and a versioned
SHA-256 input fingerprint.

Create an immutable improvement plan with all ceilings in one call:

    ragimprove.createimproveplan(
      store, config_snapshot_id, policy_version, prompt_version, triggers,
      maximum_items, model_call_budget,
      input_token_budget, output_token_budget, cost_budget, time_budget_ms,
      maximum_call_input_tokens, maximum_call_output_tokens,
      maximum_call_cost, maximum_call_time_ms,
      maximum_inflight_calls, maximum_attempts,
      privacy_class, route_id, secret_reference,
      expose plan, expose error) = .int

Triggers are sorted unique values from bridge, conflict, operator-review,
profile-change, unprocessed-extraction, unresolved, and weak-support.
Selection deduplicates identical content, then orders score descending and
chunk id ascending. The call budget may cover retries but cannot exceed
maximum_items multiplied by maximum_attempts.

secret_reference is empty or starts with env:. The key value is never part of
a plan, database row, test output, evidence file, or command transcript. For a
hosted OpenAI route, export the key only in the worker environment:

    export OPENAI_API_KEY='...'

Do not paste the value into cREXX source or a plan. Provider/model access is
assumed for the hosted qualification in Phase 7; recurring Phase-4 QA makes no
outbound connection.

    ragimprove.applyimproveplan(
      store, plan, expose result, expose error) = .int

Apply re-plans from current state and requires byte-identical canonical
content. It inserts the job, unique work items, and immutable budget/route
policy in one transaction. Reapplying the same plan is a zero-write no-op.

External normalized proposals use the same validation and review path:

    ragimprove.createexternalproposalplan(
      store, config_snapshot_id, policy, proposals,
      expose plan, expose error) = .int

    ragimprove.applyexternalproposalplan(
      store, plan, policy, proposals,
      expose reviews_created, expose error) = .int

External proposals must be in unique canonical-hash order and always become
pending external-proposal reviews; they cannot bypass review into graph state.

## 5. Run A Durable Worker

The provider boundary is the Level-G .ragworkprovider interface:

    extract(claim = .ragworkclaim) = .ragworkproviderresult

The result carries provider/model/request identity, actual tokens/cost/time,
retryability, one typed proposal, and a safe error. The worker reserves
worst-case usage before calling the provider, settles actual usage afterward,
validates the proposal, and promotes it through the same fenced path.

    ragwork.runworkeronce(
      store, job_filter, worker_id, lease_seconds, maximum_attempts,
      policy, provider, expose disposition, expose error) = .int

    ragwork.runworkerfollow(
      store, job_filter, worker_id, lease_seconds, maximum_attempts,
      maximum_items, idle_polls, poll_seconds,
      policy, provider, expose processed, expose error) = .int

runworkerfollow exits at the item bound or after the configured idle polls; an
operator-owned launchd/systemd supervisor decides whether to restart it. The
database owns work, leases, attempts, monotonic fences, and events. A killed
worker cannot late-promote after another worker reclaims the item.

The exact control procedures are:

    ragwork.claimnext(store, job_filter, worker_id, lease_seconds,
                      maximum_attempts, expose claim, expose error) = .int
    ragwork.heartbeat(store, claim, lease_seconds,
                      expose lease_until, expose error) = .int
    ragwork.reservecall(store, claim, maximum_input_tokens,
                        maximum_output_tokens, maximum_cost, maximum_time_ms,
                        expose reservation, expose error) = .int
    ragwork.settlecall(store, reservation, provider_id, model, request_id,
                       outcome, actual_input_tokens, actual_output_tokens,
                       actual_cost, actual_time_ms,
                       expose provider_run_id, expose error) = .int
    ragwork.failattempt(store, claim, retryable, backoff_seconds,
                        maximum_attempts, reason, expose error) = .int
    ragwork.skipitem(store, claim, reason, expose error) = .int
    ragwork.requestcancel(store, job_id, reason, expose error) = .int
    ragwork.acknowledgecancel(store, claim, expose error) = .int
    ragwork.pausejob(store, job_id, expose error) = .int
    ragwork.resumejob(store, job_id, expose error) = .int
    ragwork.drainjob(store, job_id, expose running, expose error) = .int
    ragwork.readjobstatus(store, job_id, expose status, expose error) = .int

claimnext returns 0 with a claim, 1 when idle, or a negative failure. Status is
a bounded snapshot and never waits for completion. Drain pauses new claims and
reports running/cancel-requested items. Cancellation closes queued items and
asks each running worker to acknowledge at its current fence. Failed attempts
retry after the database-epoch backoff or enter dead_letter at the bound.

## 6. Read The Seven Tutorial Records

The output shows:

1. three sources and five chunks ingested without a provider;
2. two canonical concepts promoted;
3. one evidence-backed directional claim validated;
4. a five-item retry-budgeted symbolic-secret plan created;
5. the plan enqueued without calling a provider;
6. five deterministic provider attempts converging to one graph effect; and
7. the same proposal replaying with zero writes.

The permanent claim scenario additionally covers every stance, contradiction
polarity, valid and reversed effective time, low confidence, canonical
overwrite, unresolved endpoint, ambiguity, conflict, external review,
independent strengthening/retraction, ranking, traversal, and plan replay.

## Current Limits

- Phase 4 supplies Level-G algorithms and development APIs, not the public
  CLI, ADDRESS, MCP, skill adapters, or installed application package.
- Recurring QA is deterministic and zero-outbound. Hosted credentials are
  assumed available but are exercised only by the explicit secret-gated
  Phase-7 qualification.
- CRI-16 still withholds cross-operation pool reuse, streaming, and provider
  cancellation claims.
- Gate 4 is accepted for the recorded macOS scope. The permanent target
  provides bounded crash, two-process, fencing, cancellation, and budget
  regression, while the retained one-run 28,800-poll soak supplies the separate
  long-duration evidence. Exact downstream Linux remains open.
- Native-v1 remains the executable oracle. There is no dual-write, cutover,
  removal, push, release, or Linux-completion claim here.
