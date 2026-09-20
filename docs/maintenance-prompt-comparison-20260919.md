# Scottish maintenance prompt comparison — 19 September 2026

The revised Scottish objectives correct the five identified problem decisions
on the eight frozen tuning cases. Three existing positive controls retain their
supported outcomes. A second run at Luna Low / Sol Medium agrees on all eight
actions and selected identities. This is a small, deliberately selected tuning
screen, not an estimate of corpus accuracy or a new maintenance soak.

Adrian approved the comparison and asked that stronger models be considered.
The installed product remains the already qualified baseline; no RAG or CREXX
implementation, schema, type vocabulary, validator or worker change was needed.

## Changes and model decision

The Scottish selected policy now uses objectives that:

- Require evidence for the specific identity, beyond evidence for its type;
  canonical labels and stored classifications remain hypotheses.
- Require affirmative source support for retain, including its required evidence.
- Reassess the decision during quotation correction and preserve the surrounding
  context that supports it, rather than reducing unsupported evidence to a name.

Routine work still escalates a concrete evidence gap. Advanced work still ends
with a supported permitted change or reasoned no-change, with the existing
bounded search/read and exceptional deferral controls. No additional route,
task type, retry allowance or prompt framework was added.

The comparison tested the revised prompts with the original **Luna Low / Sol
Medium** pair, and then **Sol Medium / Sol High**. Both produced the same eight
appropriate action/identity outcomes. Keep the original pair: this sample does
not demonstrate a decision-quality benefit from increasing the models. The
stronger pair remains a measured candidate for harder, previously unseen cases.

| Route | Revised original pair, first run | Stronger pair | Revised original pair, repeat |
| --- | ---: | ---: | ---: |
| Routine, five cases: median seconds | 9.89 | 13.04 | 11.84 |
| Advanced, three cases: median seconds | 23.79 | 18.05 | 16.45 |
| Appropriate action/identity outcomes | 8/8 | 8/8 | 8/8 |
| Returned quotations matching selected occurrences | 11/11 | 11/11 | 11/11 |

These small live latency samples vary substantially; they do not establish
that higher effort is faster or slower in general. The recommendation follows
the [official reasoning-effort guidance](https://developers.openai.com/api/docs/guides/deployment-checklist#set-up-reasoningeffort)
to compare representative quality and resource results. More reasoning cannot
supply historical evidence absent from the packet.

## Case results

| Frozen case | Earlier result or concern | Revised result, both model settings and repeat |
| --- | --- | --- |
| 02, Cope's Trial | Retain lacked required source evidence; product rejected it | Focused escalation with all three available bibliographic quotations |
| 04, Maclean correction | Selected one of two person candidates without distinguishing evidence; corrected to a bare name | Abandons the unsupported choice and escalates with contextual quotation |
| 07, Balfour | Defensible advanced no-change | Preserved, with the source reference quoted |
| 13, Kingsburgh | Defensible no-change because the supported distinction cannot be expressed by the supplied actions | Preserved; cites contrasting occurrence contexts |
| 21, Cluny | Supported person-candidate selection | Preserved C2; retains the explicit chief context |
| 26, Scottish | Confident retention of a questionable event classification | Escalates the vocabulary/representation limitation |
| 28, Her Majesty | Specific candidate identity lacked packet support | Escalates for candidate-specific evidence |
| 32, William | Advanced candidate choice needed corpus corroboration | Reasoned final no-change with contextual evidence |

The repeat agrees on action and target identity, not identical prose. Luna's
reuse responses redundantly supply the already-selected label/type, which the
existing identity owner replaces with the selected active candidate values;
this did not alter the decision. Some quotation boundaries remain untidy while
retaining the necessary context. Prompt/style tuning remains ongoing.

## Validation and limits

Twenty-four new calls completed: 469,035 input tokens and 11,162 output tokens.
Every response passed the existing structured-response check and independent
shape/action inspection. All 33 returned quotations passed the unchanged
`raggrounding.findoverlap` owner with their original selected source offsets.
Known positive and wrong-quotation/missing-field negative controls were checked
before inference. Four initial scratch-consumer privacy-value refusals made no
transport calls and used no tokens; their artifacts remain separate.

The standalone experimental cREXX consumer uses the existing RAG Codex adapter
and grounding module from the qualified application library. Original frozen
request/response files were hash-verified. Source text, candidates, selected
spans, reference maps, response schemas, call allowances and correction history
were preserved. Fresh request artifacts identify the revised objective and
requested model/effort while retaining the old packet's provenance.

This screen does **not** execute task database transitions or full lifecycle
validation. No search/read was requested; their execution is not newly qualified
here. Advanced cases concluded in one call. The ordinary escalation handoffs
were inspected but not run through subsequent advanced tasks. Wider convergence,
unseen-case performance, and health/social-care qualification remain open under
RAG-QA-02. The completed soak's operational evidence remains separate.

## Installation and evidence

Two Scottish policy settings changed through public `config set` with expected
file hashes: `maintenance.resolution_prompt` and the selected advanced prompt
file. Models, effort, budgets, worker counts and all other policy entries are
unchanged. Public `config check` and both `config prompt` readbacks pass; the
effective objectives exactly match the evaluated objectives. Master library
status is identical before/after: schema 19, generation 29,748. No worker or
maintenance job was started and the old soak remains closed.

Policy SHA-256: `144f48fade22ab37ab2dbb04bbbe150c7590ef9ba7a8c6ade8bf69fb3f5c3869`.
The previous policy and prompt files are retained for rollback. Existing frozen
tasks keep their old prompt identity; use the normal current-policy reset/plan
path at the next authorized maintenance window, rather than resuming the old job.

Full local evidence:
`/Users/adrian/Documents/ScottishHistory/reports/prompt-comparison-20260919/`
contains `RUN.md`, `REPORT.md`, `manifest.json`, `assessment.json`, `policy.diff`,
all requests/results, the scratch consumer and installation/readback receipts.
The original eight pairs remain in `maintenance-quality-20260919/review/`.

No full software suite was repeated: the product baseline retains its 132/132
passing receipts. The documentation check and receipt audit cover this repository
documentation update. No new commit, push, corpus copy-back or soak is implied.
