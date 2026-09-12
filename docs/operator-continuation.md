# Continue interrupted processing

Delivery status: implementation passed the complete **63/63** automated gate
in **848.41 seconds**, plus the scratch-installed recovery journey. The
[handoff](operator-continuation-handoff.md) contains the commit and real Scottish
run state. Remaining ingestion and the requested 60-minute maintenance are
required live evidence; the whole outcome is not yet declared complete. An empty
runnable queue alone does not prove corpus coverage.

## Ordinary command journey

Select the processing library and its existing `crexxrag.conf`. A relocated
query copy is a different library. Do not reimport completed sources to restart
processing. Use `job list` and `source list` to identify the retained work;
`job plan JOB` reads its exact original plan in bounded pages.

```sh
crexxrag job status JOB --seconds 300
crexxrag job progress JOB --limit 50
crexxrag job items JOB --state dead_letter --limit 50
crexxrag worker list --state running
crexxrag job continue JOB
```

`job continue` composes the existing worker launcher and configured worker
count, job claims, maintenance dispatcher, receipt recovery and publication.
It preserves the job, task identities, original plans, attempts, cumulative
usage and held outcomes. It does not retry an uncertain paid call. A compatible
worker-count change is registered through the configuration owner's existing
plan/apply transition. Other configuration changes retain the original job's
compatibility checks. Other active work can require a separate drain; the
command reports that condition rather than rewriting its policy.

Use `worker status PROCESS` to inspect a discovered process, `worker drain`
with its documented selector to stop owned work, and `worker prune` for stale
ownership. Then repeat the same continuation. Ordinary continuation keeps the
existing allowance and deadline. `--prepare` performs the durable preparation
without launching workers; `job run JOB` subsequently uses that preparation.

## Explicit renewal

When aggregate allowance is exhausted or a maintenance deadline has passed:

```sh
crexxrag job continue INGEST_JOB --renew scottish-ingestion-20260912
crexxrag job continue MAINTENANCE_JOB --renew scottish-maintenance-20260912 --minutes 60
```

Choose one stable name per explicitly authorized period. Repeating the same
name cannot add allowance or move the deadline, including after interruption.
Reusing it with different minutes is an error. A new name grants another
original allocation across the job's item, call, token, monetary, subscription
and aggregate provider-time ceilings. The original `budget-policy` and plan
remain immutable; cumulative consumed and reserved amounts are never reset.
The named period retains before/original allowances and its maintenance
deadline in immutable history. Unlimited/disabled aggregate provider time (0)
remains disabled. `--minutes` is a maintenance wall-clock duration; it is not an
ordinary ingestion provider-time override.

Renewal does **not** raise a per-task or per-call limit, change prompts/models,
resolve a review, waive missing coverage, or make an uncertain outcome safe.
An explicitly reviewed new maintenance policy can provide a greater cumulative
attempt ceiling while counting all historic calls. The shipped Gemini policy
examples use three attempts. An embedding-only window uses its explicit embedding
provider ceiling rather than the separate reasoning ceiling. Existing policies, including one or six,
are not rewritten by installing this version.

## Explain and handle holds

`job status` distinguishes actual materialized items from allowances, recorded
provider usage from reservations, and incomplete/unknown usage. It includes
aggregate provider time, retry and worker waiting reasons, and a selectable
observation interval. `job progress` partitions each actual item into exactly
one operation/source group and one state; queued excludes deferred. Its totals
are task counts, not percentages of source coverage or counts of provider
attempts. Questions without one immutable input source are explicitly grouped
as library/unresolved-source work. Use `library report` for unique corpus
coverage, reviews, missing embeddings and graph/backlog dispositions.

`job items` exposes source identity, last attempt reason, retry request,
original attempt ceiling, current maintenance eligibility and a next action.
Use `job attempts`, `job events` and `maintain inspect TASK` for details, following
all `next_cursor` values. The command itself never returns raw input payloads.

| Hold | Ordinary next action |
| --- | --- |
| Queued or paused job | `job continue JOB`; add a new explicit named period only when allowance/deadline renewal is authorized. |
| Deferred quota/capacity | Inspect `provider status` and retry time; let the shared cooldown/probe recover. Deferral is not a paid attempt. |
| Retained failed task | `job retry JOB --item ITEM --reason REASON` or `maintain retry TASK --reason REASON`; repeat is deduplicated. Then continue the eligible job/window. |
| Closed maintenance window | Continue while its original deadline remains valid, or explicitly renew it. Existing tasks and paid history remain. |
| Attempt ceiling | Inspect recorded calls and current policy. Renewal does not reset attempts; a reviewed new maintenance policy may authorize a different cumulative ceiling. |
| Unknown provider outcome | Inspect `job reconcile JOB --item ITEM`; only apply the returned digest when a terminal saved outcome is actually observed. Do not resubmit an unknown call. |
| Evidence, advanced reasoning or pending review | Follow `maintain inspect`, bounded evidence/resolve tools and public review preview/decision. Missing evidence is not successful maintenance. |
| Deliberately unfinished question | An explicitly authorized `maintain waive TASK --reason REASON` records the decision. It does not improve missing coverage or erase uncertainty. |
| Stale/live process ownership | Inspect `worker list`, then `worker status PROCESS`; drain or prune through public controls and repeat continuation. |
| Configuration mismatch | Use `config diff`, `config show` and the original job policy. Semantic/prompt changes require the existing reviewed new-work path. |
| Sidecar/projection repair | With writers drained, use `vector rebuild --reconcile`; it reuses stored embeddings and never calls a provider. |
| Unavailable SQLite/environment | Preserve the exact diagnostic, restore environment availability, then repeat the ordinary command. A generic process failure is not proof that a paid call was uncalled. |

## Qualification and closure

Acceptance includes stopped ingestion, same-job maintenance renewal, repeated
and conflicting period requests, compatible configuration registration,
CLI/MCP parity, unknown outcomes, immutable usage/history and final coverage.
The original one-attempt quota case is separate from the equal-ceiling retry
fixture. Status must stay bounded at Scottish corpus scale. Both VMs, native
packaging, installed guidance and the full automated suite must pass before
the implementation commit. Record the exact artifact for the subsequent real
remaining-ingestion and 60-minute maintenance run.

An item is closed only when its promised behavior is implemented and the
required validation passes. Record known functional remainder explicitly;
“smoke pending” describes missing evidence, not missing implementation. Reviews,
missing evidence, accepted limitations and uncertain paid outcomes must remain
visible even if the run has no further eligible work.
