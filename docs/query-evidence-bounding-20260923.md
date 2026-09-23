# Graph-enabled evidence packet bounding — 23 September 2026

The generation-3194 heart-failure Q03 receipts show lexical and hybrid
`query evidence --hops 1 --limit 12` failing at the intentional 262,144-byte
ceiling, while traversal-off queries return about 98 KB. The source report
records zero repository verification issues. This is a public encoding gap,
not evidence of library corruption. The private corpus was not modified or
replayed during this local repair.

`ragevidencejson.encodeevidence` now keeps its byte-identical fitting path and
uses a bounded fallback only on overflow. The fallback removes complete
lower-priority notes, leads, gap and ambiguity diagnostics, then claims and
extra passages as needed. It
retains the highest-ranked source passage and first claim where they fit;
citations, source metadata, support provenance and claim qualifications are
never sliced. The returned `crexx-rag.evidence/2` packet adds
`truncation.incomplete=true` and exact omitted counts for passages, claims,
leads, analysis notes, ambiguities and gaps. Guidance warns that absence from an incomplete
packet is not negative evidence. `ragqueryservice` mirrors the flag and counts
in command fields, visible in human, JSON and MCP results. The configured byte
ceiling is unchanged. Mandatory metadata overflow still refuses; a generated
answer still refuses an oversized public packet to avoid omitting its cited
record.

Baseline before implementation: `evidence_methodology` failed its new
graph-fanout assertion with `serialized evidence exceeds the configured byte
ceiling`; the fitting source/graph and answer-context controls passed. The
implemented `evidence_methodology` case passes on rxvme and rxbvm with the
normal 262,144-byte ceiling, whole retained records, exact counts, valid
citations/qualifications, unchanged fitting packets and refusal controls.
`gemini_query` passes a public scratch-library test for lexical and hybrid
graph-enabled queries, each reporting one omitted oversized claim and a
retained source citation; traversal-off remains complete. The case also
retains its earlier answer, privacy and integrity controls. A first placement
of the new public calls before snapshot assertions caused the test's own
query-gap observations to change snapshot health; moving the calls after
snapshot acceptance resolved that fixture interaction. This was a test-order
interaction, not a product failure.

The original targeted selection was 6/6 passing: `evidence_methodology`,
`gemini_query`, `regression_result_contract`, `regression_retrieval`,
`native_vector_public` and `regression_command_catalogue`. The QA report recorded
six passes and 129 not-run cases for that deliberately narrow selection. A
subsequent fail-first diagnostic-string overflow case also passes. The combined
required local gate accounts for 135/135 exact-input passing cases (72 executed
in the final selection, 63 retained passes), with no failed, disabled,
interrupted or not-run receipts. The installed generation-3194 Q03 replay,
cross-platform build for the combined SHA and publication remain pending. The earlier published
`d6b644aa4f8e930502b0a88eb5e679de6ba231d1` hosted build has separately
passed on macOS ARM/Intel and Windows; it does not contain this repair.
