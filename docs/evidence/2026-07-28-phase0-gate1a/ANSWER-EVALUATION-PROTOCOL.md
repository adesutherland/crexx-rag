# Fixed And Blinded Answer-Evaluation Protocol

Version: Gate0-v1, frozen 2026-07-28.

The unit of evaluation is an evidence-backed proposition, not exact prose. The
fixed inputs are the hashed fixtures, blinded question file, Scotland-shaped
cases, answer-key judgements, passage map, rubric, evidence-packet limits, and
thresholds in this evidence bundle.

## Separation And Blinding

1. The answer producer receives only the selected frozen source artifacts, the
   question, and the common answer instruction. It does not receive the rubric,
   answer-key judgements, expected gaps, implementation identity, or prior
   answer.
2. The answer producer must use the tested evidence packet. Temperature is zero
   where the provider supports it; provider/model/version, request options, and
   raw evidence packet are retained. The same evidence packet is used for each
   compared boundary unless the comparison is explicitly a retrieval test.
3. A coordinator assigns opaque labels `A` and `B` and randomizes answer order
   per case. The scorer sees the question, frozen sources, rubric, passage map,
   answer key, and opaque answers, but not which implementation produced them.
4. The four held-out IT questions are read from
   `it-held-out-questions.jsonl`. Their separate answer key is not loaded into
   the answer-producing context. Scotland cases use the same separation by
   projecting only each `question` field to the producer.
5. Raw generated prose is immutable after scoring begins. Formatting-only
   normalization may remove implementation labels but cannot change claims or
   citations.

## Scoring

Each answer is scored on the seven fixed rubric dimensions for 16 possible
points. A case passes at 13/16 subject to all critical constraints. The full
9-case judged suite passes at 85% or better and at least 90% recall of passages
marked required by the answer key.

Critical failure, regardless of points:

- an unresolved or non-entailing citation is used for a central claim;
- a `mentioned-in`, locator, co-mention, vector hit, or graph adjacency is
  asserted as a supported relationship;
- an explicit expected gap is replaced with invented evidence or with a
  corpus-wide absence claim;
- source stance, chronology, or named-sense ambiguity is collapsed in a way
  that changes the proposition; or
- outside knowledge is presented as fixture evidence.

Two independently reset scorer contexts score every answer. A difference over
2 points or any disagreement about a critical failure goes to a third blinded
adjudicator. Retain individual score sheets, disagreement notes, and the final
adjudication. Do not tune prompts or thresholds between cases; any changed
prompt/model/fixture starts a new versioned run.

## Result Record

For each case retain: fixture hashes, question hash, opaque answer label,
provider/model/options, evidence-packet hash and byte count, cited passage keys,
dimension scores, critical-failure flags, elapsed time, and scorer/adjudicator
IDs. Reveal implementation labels only after the score file is sealed.

This protocol judges evidence quality. It does not require exact generated
wording, and the recorded Phase-1A Gemini canary is connectivity/correctness
evidence rather than a substitute for the complete blinded suite.
