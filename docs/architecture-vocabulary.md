# Initial Semantic Vocabulary

`crexx-rag` starts with a small ArchiMate-inspired vocabulary for the typed
relationship map. The storage remains domain-neutral: callers may use other
types when a workload needs them, but these names are the first shared profile
for IT architecture. The same vocabulary API also exposes the first shared
provenance, timeline, confidence, and embedding profile terms.

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

## Source Types

- `primary-source`: original authoritative material, document, export, or record.
- `client-stated`: information stated directly by a client or stakeholder.
- `meeting-note`: information captured during or from a meeting.
- `decision-record`: a recorded decision, rationale, or accepted outcome.
- `derived`: information derived from analysis, transformation, or summarization.
- `inferred`: information inferred by a person, agent, rule, or model.
- `external-reference`: information from an outside reference or third-party source.
- `unknown`: source type was not supplied or has not been assessed.

## Temporal Roles

- `captured-at`: when this information was gathered or entered into the library.
- `event-start-at`: when the represented event, meeting, decision, or validity period starts.
- `event-end-at`: when the represented event, meeting, decision, or validity period ends.
- `created-at`: when the library record was first created.
- `updated-at`: when the library record was last updated.

## Confidence Scale

Confidence is stored as a numeric value from `0.0` to `1.0`.

- `1.0`: high confidence; authoritative, directly observed, or strongly trusted.
- `0.7`: medium confidence; plausible but indirect or somewhat uncertain.
- `0.4`: low confidence; tentative, weakly supported, or partially conflicting.
- `0.0`: rejected confidence; retained for traceability but should not influence retrieval.

## Embedding Profiles

- `raw-text-v1`: embed the chunk text as supplied; retained for compatibility and manual vector loading.
- `semantic-context-v1`: embed a stable text envelope containing vocabulary profile, source type, confidence, timeline fields, title, and chunk text.

The native `cprag_vocabulary` API, CLI `vocabulary` command, MCP
`library_vocabulary` tool, raw CREXX `rxrag.vocabulary()` function, and
`cprag.raglibrary.vocabularyJson()` wrapper method expose the same list as JSON.
