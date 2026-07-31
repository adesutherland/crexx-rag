# crexx-rag

`crexx-rag` is an LLM-first local RAG and typed-graph knowledge store whose
approved target is a cREXX application. It is also a deliberately non-trivial
cREXX reference workload: the project should expose language, runtime, library,
plugin, packaging, and performance weaknesses with reproducible evidence.

## Approved Direction

Product algorithms, SQL repositories and migrations, orchestration, policy,
configuration, commands, jobs, retrieval, and evidence assembly belong in
cREXX. Native code is limited to reusable mechanisms such as SQLite access and
only measurement-justified accelerators. Generic facilities may be incubated
here, tested independently of RAG concepts, and later donated to CREXX.

The existing C++ implementation remains an executable oracle during migration;
it is not the target architecture. It must not be removed, dual-written, or
changed incompatibly without the roadmap's later cutover decision.

The approved immediate execution unit is:

1. Phase 0: freeze the oracle, fixtures, judgements, defects, and measurement
   protocol.
2. If Gate 0 is fully evidenced, Phase 1A: run bounded cREXX capability and
   boundary-selection slices.
3. Stop unconditionally at Gate 1A for the user's boundary decision.

Phase 1B, production hardening, donation, schema-v2 implementation, cutover,
and native retirement are not authorized by this decision.

## Start Here

- [documentation map](docs/README.md)
- [vision and product specification](docs/crexx-only-vision-and-specification.md)
- [review findings](docs/crexx-only-review-findings.md)
- [target architecture](docs/crexx-only-architecture.md)
- [implementation roadmap](docs/crexx-only-implementation-roadmap.md)
- [target user guide](docs/crexx-only-user-guide.md)
- [test strategy](docs/test-strategy.md)
- [programme status](docs/pipeline-status.md)
- [next-agent implementation handoff](prompts/phase0-phase1a-implementation-handoff.md)
- [knowledge-agent instructions](prompts/crexx-rag-agent-AGENTS.md)

The former native-v1 architecture, tutorials, command reference, pipeline
status, engineering notes, and QA prompts are retained as [archived oracle
evidence](docs/archive/README.md). They describe reproducible historical/shipped
behavior, not the selected product direction.

## Current Oracle Build

The native-v1 oracle remains buildable while Phase 0 captures its behavior:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

Use the installed CREXX toolchain as the compatibility target. The sister
`../CREXX` checkout is read-only reference material for this programme: assume
its PERF2 work succeeds for planning, and do not edit or interfere with it.

Target commands shown in the user guide are interface specifications until
their roadmap gates are accepted; do not infer that they are already shipped.
