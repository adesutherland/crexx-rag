# Initial Architecture Vocabulary

`crexx-rag` starts with a small ArchiMate-inspired vocabulary for the typed
relationship map. The storage remains domain-neutral: callers may use other
types when a workload needs them, but these names are the first shared profile
for IT architecture.

## Node Types

- `component`: deployable or logical software component.
- `service`: externally meaningful application, business, or platform service.
- `capability`: ability or outcome provided by people, process, or technology.
- `data-object`: structured information used or produced by the architecture.
- `technology-node`: runtime, host, platform, or infrastructure node.
- `deployment-target`: environment or target where components run.
- `process`: operational or business process.
- `material`: domain material, resource, or physical thing.

## Relationship Types

- `depends-on`: source requires target to function.
- `realizes`: source implements or fulfills target.
- `serves`: source provides behavior or value to target.
- `accesses`: source reads, writes, or otherwise uses target data.
- `flows-to`: information, control, or material flows from source to target.
- `composed-of`: source is structurally composed of target.
- `deployed-on`: source runs on or is installed on target.
- `associated-with`: general intentionally weak relationship.

The native `cprag_vocabulary` API, CLI `vocabulary` command, MCP
`library_vocabulary` tool, and CREXX `rxrag.vocabulary()` function expose the
same list as JSON.
