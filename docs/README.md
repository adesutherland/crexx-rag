# Documentation Map

Status: canonical navigation for the approved cREXX-only programme,
2026-08-23. Phase 1B is complete, Gate 1B is accepted, and Phase 2 has started
from its pushed entry baseline. `P2-01` through `P2-08` are accepted; `P2-09`
is next and pending.

## Current Programme Documents

| Document | Authority |
| --- | --- |
| [Vision and product specification](crexx-only-vision-and-specification.md) | Approved product purpose, requirements, ownership, and cutover rules |
| [Review findings](crexx-only-review-findings.md) | Point-in-time rationale behind the decision; reproducible Phase-0 evidence is now retained separately |
| [Architecture](crexx-only-architecture.md) | Approved target boundaries, data model, lifecycle, jobs, retrieval, and surfaces |
| [Implementation roadmap](crexx-only-implementation-roadmap.md) | Completed work, future phases, and gates; Phase 2 is active through accepted `P2-08` |
| [User guide](crexx-only-user-guide.md) | Target interface contract; clearly marks unimplemented commands |
| [Test strategy](test-strategy.md) | Living validation and acceptance policy |
| [Programme status](pipeline-status.md) | Living implemented-versus-specified status |
| [Semantic vocabulary](architecture-vocabulary.md) | Initial domain-neutral typed-graph vocabulary |
| [CREXX integration issues](crexx-integration-issues.md) | Dated installed-toolchain and capability-gap ledger |
| [Current CREXX integration replay](evidence/2026-08-23-crexx-current-integration/README.md) | Pulled-head review, fresh installed-only 62/62 downstream replay, exact current boundaries, and deferred follow-up |
| [CREXX capability-sync worklist](evidence/2026-08-22-crexx-capability-sync/WORKLIST.md) | Completed macOS/current-head items and later parallel qualification backlog |
| [Generic capability incubation audit](../incubator/README.md) | Donation-candidate inventory, implementation boundaries, colocated use/system docs, and readiness status |
| [Gate 1A decision ledger](gate1a-decision-ledger.md) | Historical approval for D1-D9, the now-completed Phase-1B worklist, exclusions, and Gate-1B stop |
| [Gate 1B decision ledger](gate1b-decision-ledger.md) | Current acceptance decision, Level-G-first amendment, Phase-2 authority, parallel-work model, exclusions, and start state |
| [Phase 2 worklist](evidence/2026-08-04-phase2/WORKLIST.md) | Active ordered `P2-01` through `P2-10` execution record, evidence rules, exclusions, and Gate-2 stop |
| [Phase 2 entry baseline](evidence/2026-08-04-phase2/ENTRY-BASELINE.md) | Pushed commit, installed toolchain, Debug/Release build, full CTest, and CRI-15 entry result |
| [P2-01 application-contract evidence](evidence/2026-08-04-phase2/P2-01.md) | Level-G module layout, public object contracts, four-cell consumer proof, full validation, and explicit limits |
| [P2-02 configuration/profile evidence](evidence/2026-08-04-phase2/P2-02.md) | Registered typed configuration and profiles, four-cell security/privacy proof, resource result, full validation, and explicit limits |
| [P2-03 storage-foundation evidence](evidence/2026-08-04-phase2/P2-03.md) | Ordered schema-v2 migrations, generations/snapshots, manifest recovery, strict read-only behavior, real crash ordering, verification, rollback, and explicit limits |
| [P2-06 repository evidence](evidence/2026-08-04-phase2/P2-06.md) | Sixteen bounded repositories, keyset cursors, typed binary payloads, pinned generation/operational snapshot isolation, and lifecycle/orphan verification |
| [P2-07 command-contract evidence](evidence/2026-08-04-phase2/P2-07.md) | Closed argv grammar, stable exit taxonomy, bounded typed result records, and versioned human/JSON/NDJSON renderers |
| [P2-08 foundation-facade evidence](evidence/2026-08-04-phase2/P2-08.md) | Shared lifecycle/diagnostic dispatch, access gates, read-only verification, backup/restore, and zero-outbound provider configuration tests |
| [Level-G migration evidence](evidence/2026-08-04-levelg-migration/LEVEL-G-MIGRATION.md) | Installed-toolchain requalification, 46-source migration, language audit, and post-migration CTest result |
| [Approved CREXX candidate closeout](evidence/2026-07-31-gate1a-crexx-candidate/CANDIDATE-INTEGRATION-CLOSEOUT.md) | Exact downstream CRI-01 through CRI-14 replay, provenance, results and Gate-1A stop |
| [Linux build review](evidence/2026-08-03-linux-build/LINUX-BUILD-REVIEW.md) | Debug/Release portability result and open CRI-15 reproducer |
| [Gate 1B decision packet](evidence/2026-08-03-phase1b/GATE-1B-DECISION-PACKET.md) | Completed Phase-1B evidence, capability limits, validation, recommendations, and mandatory production-decision stop |

Agent-facing material:

- [Completed Phase 0 and Phase 1A implementation handoff](../prompts/phase0-phase1a-implementation-handoff.md)
- [Completed Phase 1B implementation handoff](../prompts/phase1b-implementation-handoff.md)
- [Target knowledge-agent instructions](../prompts/crexx-rag-agent-AGENTS.md)

The implementation handoffs are retained execution records. Phase-2 authority
comes from the Gate-1B decision ledger, not from extending the old handoffs;
they do not authorize replay or additional hosted calls.

## Cross-Cutting Future Research

- [Public-domain LLM response assurance pattern](llm-response-assurance-pattern.md)
  describes a general maker-checker generate/evaluate/revise loop with
  runtime monitoring and independent assessment. It is deliberately not
  RAG-specific, is reusable outside this repository, and is not an implemented
  feature or authorization to advance the cREXX-only programme.

## Historical Native-v1 Evidence

The former native-core architecture, tutorials, use cases, pipeline status,
test strategy, local-provider instructions, engineering notes, and Scotland QA
material have been removed from current guidance and retained under
[the native-v1 archive](archive/README.md).

Archive material is valuable for Phase 0 oracle reproduction and migration
goldens. It is not an alternative architecture and must not be copied forward
as target design. In particular, references there to a RAG-specific native core,
fixed JSON bridge, native queue ownership, shell orchestration, and current CLI
commands are historical.

`crexx-team-briefing.md` is a dated user-owned historical briefing retained at
its original path for continuity. Its archive banner points to the approved
replacement programme.

## Documentation Rule

New documentation must be either:

1. current and linked from this page;
2. dated evidence linked from a roadmap item; or
3. explicitly archived.

Do not leave an unlabeled competing plan, tutorial, architecture, status page,
or agent prompt in the current documentation surface.
