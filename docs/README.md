# Documentation

- [Consolidated roadmap and defect register](ROADMAP.md): current operational
  P1s, query/embedding requirements, configuration findings, agent gaps and
  qualification work, with links to the detailed historical records.
- [Architecture and regression assessment](project-review-20260911.md): evidence
  for targeted modularisation, testing gaps and recommended priorities.
- [Regression coverage baseline](regression-coverage.md): the required local
  gate, executable defect cases, risk mapping and remaining acceptance.
- [First recovery refactors and fixes](recovery-implementation-plan.md): proposed
  delivery order, cohesive source owners and coverage checks before each change.
- [Public results and Unicode repair](public-result-lexical-repair.md): page bounds,
  complete retained-plan reads and Unicode regression qualification.
- [Architecture](architecture.md): enduring components, ownership, and data flow.
- [Standalone setup](standalone-setup.md): install-to-workspace setup for a
  human using the packaged executable and examples.
- [User guide](user-guide.md): human commands, automation, providers, workers,
  proposals, and recovery.
- [Agent and LLM integration](agent-integration.md): Codex provider use, MCP
  setup, skill discovery, permissions, and other agent hosts.
- [Methodology and algorithms](algorithm.md): concept discovery, retrieval,
  cognitive enrichment, maintenance worklists and gradual graph migration.
- [Autonomous maintenance](autonomous-maintenance.md): bounded windows, runtime policy,
  resolution questions and resumable split/merge task workflows.
- [Time and provenance contracts](time-and-provenance.md): current document
  metadata defaults, unknown dates and the separate per-support experiment.
- [Methodology closure checklist](methodology-closure.md): requirement-by-requirement
  implementation evidence, the dated original closure and later validation.
- [Test strategy](test-strategy.md): maintained regression matrix and live-call
  boundary.
- [Fresh Codex MCP trials](mcp-codex-trials.md): observed agent behavior,
  exact artifact identities, correction acceptance and qualification limits.
- [Copied-soak MCP trials](mcp-soak-trials.md): real-corpus questions, evidence
  refresh, connection review and the remaining scale/completion gaps.
- [Scottish corpus development](scottish-corpus-development.md): proposed source
  additions, provenance, priorities and experiments to measure graph value.
- [Claim time and provenance proposal](claim-time-provenance-proposal.md): the
  original approved design and experiment history; use the current contract
  above for implemented defaults.
- [Integration issues](integration-issues.md): current CREXX/platform limits.
- [Query engine and local embedding backlog](query-engine-backlog.md): open
  requirements for curated graph exploration, standalone querying, local
  embeddings, model longevity/migration and comparative retrieval evaluation;
  includes the dependency on CREXX's native inference backlog.
- [Operational hardening and recovery backlog](recovery-defects.md): the open
  P1 requirement for repeatable launch/resume and product-owned repair paths,
  followed by the historical recovery defects.
- [LLM processing repair plan](llm-processing-repair-plan.md): proposed recovery,
  extraction-grounding and real-corpus qualification after embedding repair.
- [Hard-coded configuration audit](configuration-audit.md): complete runtime,
  policy, provider and defensive-limit inventory plus the consolidated repair
  proposal.
- [Tutorial](tutorial/README.md): a small Gemini ingestion and query walkthrough.

Guides describe the current product contracts. Proposals and qualification
records retain their dates, tested artifacts and limits; an older run's status
is not a live operational status report. Historical phase packets and the
unreleased native prototype remain available through Git history.
