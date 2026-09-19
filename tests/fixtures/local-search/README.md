# Retained local-search evaluation cases

`cases.json` freezes eight real retrieved Scottish contexts and three genuine
two-part partial-answer controls from the 19 September experiment. It excludes
the failed experimental prompt clarification. Use the current answer contract
and compare evidence, answer correctness, identity/direction, grounding label,
citation membership and output completion separately. Do not turn exact prose
matching or valid JSON into a semantic quality pass.

The three deliberately restricted public-query misses (Cameron manuscript,
Kennedy founder, Carryl expertise) and their exact provider replies remain at
`ScottishHistory/reports/local-generation-20260919/rag-public/summary.json`.
Their one-passage/no-graph setup is not the product retrieval baseline.
The independent identity case is Philip Miller (informant) versus Philips
(poet). A model must preserve that distinction without treating names as IDs.

These are bounded evaluation inputs, not a performance lane or a live model
dependency in ordinary CTest. Loopback public-command tests cover transport,
strict citation validation, privacy, token budgets and malformed responses;
the delivery record reports actual local model outcomes separately.
