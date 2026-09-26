# Recommended corpus prompts

Use these objectives as the recommended starting point when configuring extraction or maintenance for a corpus. They are editable operator policy, selected explicitly. Compiled defaults, schemas, validation, model choices and budgets are unchanged. The files are included in the normal `crexxrag-maintain` skill installation.

| Objective | File | Configuration setting |
| --- | --- | --- |
| Extraction | [extractor-objective.txt](extractor-objective.txt) | `role.extractor.system_prompt_file` |
| Ordinary maintenance | [maintenance-objective.txt](maintenance-objective.txt) | `maintenance.resolution_prompt`, unless an explicit resolver objective is selected |
| Advanced resolution | [advanced-objective.txt](advanced-objective.txt) | `role.advanced-resolver.system_prompt_file` |

The ordinary-maintenance file is one line: pass its complete text as the value of `maintenance.resolution_prompt`, not its filename. If the corpus already selects `role.resolver.system_prompt` or `role.resolver.system_prompt_file`, update that objective instead. Changing the fallback does not replace an explicit resolver objective. Keep existing provider bindings and limits.

## Changes in these objectives

**Extraction** retains discovery and lifecycle-note instructions and adds a final batch check:

- Respect each array ceiling. Limits are not targets; preserve useful supported content.
- Copy continuous quotations, preserving OCR, punctuation and line breaks, including line-end hyphens. Do not paraphrase or join fragments.
- Choose relationship evidence first. Check both final endpoint labels, zero-based indexes, permitted semantics and direction. Account for negation, conditions, recommendations, attribution and scope; co-occurrence does not justify an edge.
- Require aliases to identify the same referent. An organisation and its publication remain distinct even when the title names the publisher. Honour reviewed glossary identities.
- Keep page markers and locators as provenance metadata; a useful isolated domain concept needs no invented relationship. Keep informational annotations separate from actionable leads.
- On correction, reassess meaning across the result, remove unsupported components and repair dependent indexes. Empty output is appropriate only when nothing is supported, not as a substitute for examining the passage.

**Ordinary maintenance** incorporates the improved Scottish guidance:

- Prove the specific identity as well as its type; compare actual candidates and passage context. Stored names and classifications are hypotheses.
- Require affirmative support for `retain`, not merely lack of contradiction. It is not a universal empty decision.
- Match actions to the supplied subject and workflow. Lifecycle actions select an eligible catalogue concept; `restore` requires a retired concept, `merge` evidence of referent equivalence and a different target, `split` supported successors, and `retire` a reviewed disposition for every active owned impact item.
- Preserve quotation context that justifies the decision and overlaps the selected occurrence. Reassess the decision when correcting evidence.
- Return a supported permitted decision or focused `escalate` handoff, rather than repeatedly returning unresolved work.

**Advanced resolution** retains evidence-based final decisions, bounded inspect/search/read, affirmative `retain`, and reasoned `no-change`. It adds explicit control-field rules so generic S/C/E reference instructions do not cause actions to select an object when prohibited:

| Control | `object_id` | `question` | Additional condition |
| --- | --- | --- | --- |
| `extract` | Empty | Empty | Advanced chunk only; another call remains |
| `search` | Empty | New lexical query, at most 256 characters | Evidence/call allowances permit follow-up |
| `inspect` | Empty or prior page `next_cursor`; exact concept ID for `catalogue-target` | `passages`, `catalogue` or `catalogue-target` | Pages current inventory or binds a previously inspected candidate |
| `read` | Exact corpus citation from search | Empty | Not an S/C/E reference; allowance permits follow-up |
| `acquisition-wait` | Empty | Specific remaining acquisition | Incomplete packet with exhausted call/read allowance; describe inspected scope in `resolution_text` |
| `no-change` | Empty | Empty | Explain why evidence does not justify a change |
| `insufficient-evidence` | Empty | Specific material reopening trigger | Explain current uncertainty without affirming the graph |

For these controls, keep `target_concept_id`, `canonical_label`, `concept_type`, `effective_from` and `effective_to` empty, `successors` as `[]`, and `qualifiers_json` as the string `"{}"`. Evidence is optional for these controls, but any supplied citation must ground its selected occurrence. The advanced file includes a complete `extract` example. `defer` has separate policy/date requirements and is forbidden when `evidence_expected` is false. A valid `extract` or evidence step is an intermediate decision, not completed maintenance. Incomplete task packets expose omitted counts and `maintain.evidence-index` for bounded continuation; omitted evidence cannot support a whole-subject negative or affirmative retention finding. The prompt exposes how many earlier decisions are absent from the bounded history projection; use task inspection for their retained records.

## Adapt and select

1. Copy the needed files into the destination corpus's prompt directory. Replace `{{CORPUS_LABEL}}` in the ordinary and advanced objectives. Adapt identity examples to the corpus's allowed types while preserving evidence rules. Use the supplied profile, glossary, bounds and task schema; do not copy another corpus's IDs, model choices or budgets.
2. Inspect `config show` and `config prompt --role extractor`, `--role resolution`, and `--role advanced-resolver`. Use the public configuration controls to select the copied objectives. Prompt paths resolve relative to `crexxrag.conf`; bind a running corpus to its own copies rather than this repository's evolving templates.
3. Run `config check`, read back effective objectives, review `config diff`, and apply the exact `config plan`/`config apply` transition within existing user authority. Record selected files and effective hashes. This changes future planning policy; retained jobs keep their snapshots. It does not reset retries or start processing.
4. When a smoke test is authorised, keep it small and bounded. Record error counts/rates, corrections, useful content retained, latency and tokens. Separate quotation/schema rejection from semantic mistakes. Do not turn a smoke test into an error-free-output requirement or an unrequested extended evaluation. Keep baseline retrieval results separate.

The application appends its shared quotation, response and task-specific contracts. Copy these objective files only, not an assembled system prompt containing another task's evidence or correction history. Check the effective action schema and field rules when using another product version. An objective cannot change those contracts.

## Evidence and status

The ordinary/advanced foundation comes from the [19 September Scottish comparison](https://github.com/adesutherland/crexx-rag/blob/main/docs/maintenance-prompt-comparison-20260919.md): eight selected cases, a repeat, and no demonstrated benefit from stronger models in that sample. It did not establish a revised extractor objective.

The extraction audit and advanced control examples were prepared on 22 September from a second corpus's retained failures. Its smoke comparison stopped at the operator's request after eight calls covering four paired cases; results were mixed and do not establish comparative improvement. Three domain-adapted objectives were subsequently installed on explicit instruction. These neutral templates are recommended starting points, not a claim of general accuracy or completed end-to-end qualification. No private documents, correspondence or model-response packets are included.
