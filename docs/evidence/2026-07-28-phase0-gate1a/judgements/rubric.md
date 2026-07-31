# Evidence Judgement Rubric

Judgements score evidence selection and use, never exact generated prose. Each
case is fixed before Phase 1A and identifies source passages by stable fixture
URI plus a semantic passage key; volatile database row and chunk IDs are
forbidden.

| Dimension | Points | Acceptance meaning |
| --- | ---: | --- |
| passage relevance | 0-2 | retrieves the necessary narrative passage(s), not merely a locator |
| keyword/alias expansion | 0-2 | uses required exact, variant, translation, or alias terms without inventing a match |
| claim support/stance/time | 0-4 | separates supported claims, attribution/stance, and relevant chronology |
| graph lead versus claim | 0-2 | accepted typed support may back a claim; mention/adjacency stays a lead |
| citation resolution/entailment | 0-2 | each citation resolves to the named fixture passage and entails the attached claim |
| ambiguity/conflict | 0-2 | competing senses or source positions stay explicit |
| expected evidence gaps | 0-2 | states the specified returned-evidence gap without converting it to corpus-wide absence |

Maximum is 16. A case passes at 13/16 only when citation entailment is at least
1, no graph lead is asserted as a supported relationship, and no expected gap
is fabricated away. The suite threshold is stated separately in the Gate-0
protocol; this rubric does not tune itself to Phase-1A output.

Evidence status labels:

- `supported`: directly stated by one or more identified narrative passages;
- `supported-attributed`: stated as a named source's position, not neutral fact;
- `conflicted`: supported source positions disagree or qualify one another;
- `lead-only`: useful mention, locator, or adjacency that cannot support the
  proposed relationship;
- `inferred-limited`: a cautious synthesis allowed only with an explicit limit;
- `gap`: the returned fixtures do not establish the requested fact.

An answer may be shorter or differently worded than the answer key. It passes
when its propositions map to the fixed labels and its citations entail them.
