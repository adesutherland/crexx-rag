# Public capability coverage map

Every shipping catalogue operation appears below. Tool discovery was executed
through the actual MCP server; functional evidence is assigned by journey and
capability family, not by calling every interface alias. The active checklist
is [Test 6](../../test6-agent-functional-20260914.md).

| Operation | Public MCP tool(s) | Functional journeys |
| --- | --- | --- |
| `job.items` | `rag_job_items` | F6-03, F6-07 |
| `job.attempts` | `rag_job_attempts` | F6-03, F6-07 |
| `maintain.workflows` | `rag_workflow_list` | F6-03, F6-04, F6-05, F6-11 |
| `config.prompt` | `rag_config_prompt` | F6-01, F6-10 |
| `library.status` | `rag_library_status` | F6-01, F6-08 |
| `library.report` | `rag_library_overview`, `rag_library_report` | F6-01, F6-08 |
| `profile.show` | `rag_profile_show` | F6-01 |
| `library.trend` | `rag_library_trend` | F6-01, F6-08 |
| `source.list` | `rag_source_list` | F6-01, F6-06 |
| `citation.show` | `rag_citation_show` | F6-02 |
| `schedule.list` | `rag_schedule_list` | F6-01 |
| `schedule.show` | `rag_schedule_show` | F6-01 |
| `query.search` | `rag_query_search` | F6-02, F6-09 |
| `query.evidence` | `rag_query_evidence` | F6-02, F6-09 |
| `query.inspect` | `rag_query_inspect` | F6-02, F6-09 |
| `query.answer` | `rag_query_answer` | F6-02, F6-09 |
| `query.trace` | `rag_query_trace` | F6-02, F6-09 |
| `query.path` | `rag_query_path` | F6-02, F6-09 |
| `query.timeline` | `rag_query_timeline` | F6-02, F6-09 |
| `job.progress` | `rag_job_progress` | F6-03, F6-07 |
| `job.status` | `rag_job_status` | F6-03, F6-07 |
| `job.list` | `rag_job_list` | F6-03, F6-07 |
| `job.plan` | `rag_job_plan` | F6-03, F6-07 |
| `job.events` | `rag_job_events` | F6-03, F6-07 |
| `config.check` | `rag_config_check` | F6-01, F6-10 |
| `config.explain` | `rag_config_explain` | F6-01, F6-10 |
| `config.diff` | `rag_config_diff` | F6-01, F6-10 |
| `maintain.status` | `rag_maintain_status` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.inspect` | `rag_maintain_inspect` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.tasks` | `rag_task_list` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.evidence` | `rag_task_evidence` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.evidence-index` | `rag_task_evidence_inventory` | F6-03, F6-04, F6-05, F6-11 |
| `job.reconcile` | `rag_job_reconcile_inspect`, `rag_job_reconcile_apply` | F6-03, F6-07 |
| `library.verify` | `rag_library_verify` | F6-01, F6-08 |
| `provider.status` | `rag_provider_diagnostics` | F6-09 |
| `provider.test` | `rag_provider_test` | F6-09 |
| `maintain.refresh-plan` | `rag_task_refresh_plan` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.resolve-plan` | `rag_task_resolve_plan` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.escalate-plan` | `rag_task_escalate_plan` | F6-03, F6-04, F6-05, F6-11 |
| `ingest.plan` | `rag_ingest_plan` | F6-06 |
| `maintain.plan` | `rag_maintain_plan` | F6-03, F6-04, F6-05, F6-11 |
| `proposal.plan` | `rag_proposal_plan` | F6-04 |
| `review.list` | `rag_review_list` | F6-04 |
| `review.decide` | `rag_review_decide_preview`, `rag_review_decide` | F6-04 |
| `config.plan` | `rag_config_plan` | F6-01, F6-10 |
| `maintain.reconcile` | `rag_workflow_reconcile_preview`, `rag_workflow_reconcile` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.waive` | `rag_task_waive` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.retry` | `rag_task_retry` | F6-03, F6-04, F6-05, F6-11 |
| `job.retry` | `rag_job_retry` | F6-03, F6-07 |
| `vector.rebuild` | `rag_vector_rebuild` | F6-06, F6-08 |
| `library.snapshot` | `rag_library_snapshot` | F6-01, F6-08 |
| `job.pause` | `rag_job_pause` | F6-03, F6-07 |
| `job.continue` | `rag_job_continue` | F6-03, F6-07 |
| `job.resume` | `rag_job_resume` | F6-03, F6-07 |
| `job.cancel` | `rag_job_cancel` | F6-03, F6-07 |
| `job.replay` | `rag_job_replay` | F6-03, F6-07 |
| `worker.drain` | `rag_worker_drain` | F6-07 |
| `ingest.apply` | `rag_ingest_apply` | F6-06 |
| `maintain.refresh-apply` | `rag_task_refresh_apply` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.resolve-apply` | `rag_task_resolve_apply` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.escalate-apply` | `rag_task_escalate_apply` | F6-03, F6-04, F6-05, F6-11 |
| `maintain.apply` | `rag_maintain_apply` | F6-03, F6-04, F6-05, F6-11 |
| `proposal.apply` | `rag_proposal_apply` | F6-04 |
| `config.apply` | `rag_config_apply` | F6-01, F6-10 |
| `config.show` | `rag_config_show` | F6-01, F6-10 |
| `config.set` | `rag_config_set` | F6-01, F6-10 |
| `config.replace` | `rag_config_replace` | F6-01, F6-10 |
| `doctor` | CLI / ADDRESS | F6-01 |
| `library.init` | CLI / ADDRESS | F6-01, F6-08 |
| `library.backup` | CLI / ADDRESS | F6-01, F6-08 |
| `library.restore` | CLI / ADDRESS | F6-01, F6-08 |
| `library.migrate` | CLI / ADDRESS | F6-01, F6-08 |
| `provider.list` | CLI / ADDRESS | F6-09 |
| `profile.list` | CLI / ADDRESS | F6-01 |
| `profile.validate` | CLI / ADDRESS | F6-01 |
| `source.show` | CLI / ADDRESS | F6-01, F6-06 |
| `review.show` | CLI / ADDRESS | F6-04 |
| `job.run` | CLI / ADDRESS | F6-03, F6-07 |
| `worker.start` | CLI / ADDRESS | F6-07 |
| `worker.run` | CLI / ADDRESS | F6-07 |
| `worker.list` | CLI / ADDRESS | F6-07 |
| `worker.status` | CLI / ADDRESS | F6-07 |
| `worker.prune` | CLI / ADDRESS | F6-07 |
| `serve.mcp` | CLI / ADDRESS | F6-01, F6-02 |

The human aliases `init`, `ingest`, `maintain` and `query` compose these same
operations. `provider login codex` delegates managed authentication; login was
not repeated or altered for this functional test. `cli-help.txt` retains the
installed command guidance. The optional answerer/advisory and provider smoke
routes use deterministic fixture evidence here; the actual configured-Luna
pilot is separately bounded in the corpus report.
