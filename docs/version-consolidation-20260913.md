# Version consolidation — 13 September 2026

The primary working checkout is now **`/Users/adrian/CLionProjects/crexx-rag`
on `main`**. It contains the complete review branch and all other available
local and fetched remote branch histories. The normal executable at
`/Users/adrian/.local/bin/crexxrag` was rebuilt and installed from this checkout.

## What was brought together

`git fetch --all` found no remote commits missing from `temp/project-review`.
Every other local branch was also an ancestor of that branch. All seven
worktrees were checked for outstanding tracked/untracked changes; the only
pending work was this task's smoke results and performance review, which were
committed as `207a2a4bc01098abadebcd00c587ae79fe99e3e6`.

Local `main` was fast-forwarded to that complete history without conflicts or
selective copying. Its old worktree at `crexx-rag-mcp` was retained at that
commit with detached HEAD, freeing `main` for the primary `crexx-rag` checkout.
Historical feature branches and their worktrees remain available.

The substantial refactoring is included in full:

| Commit | Included work |
| --- | --- |
| `b038495` | Shared effective claim-policy owner |
| `f62158f` | Domain prompt and response-contract owners |
| `e792f1d` | Report, observation and query services; operator diagnostics |
| `14677d1` | Shared command catalogue and capability ownership |
| `643bf55` | Shared worker defaults and policy-file editing |
| `ab620e5` | Shared recovery/lifecycle rules and smoke baseline |

Earlier ingestion/embedding optimizations, schema-17 review indexing and all
intervening recovery repairs are also in the merged history. The Test 2 and
Test 3 results and performance investigation are now committed documentation.

## Build and verification

The `crexx`, `cmake` and `tests` Git trees are identical to `ab620e5`, whose full
suite passed **69/69 in 901.87 seconds**. No product code, migration, test or build
logic changed during consolidation, so that full-suite evidence is retained.

Fresh checks from the primary checkout:

- `cmake --preset debug` and `cmake --build --preset debug` passed using installed
  CREXX `crexx-1.0.0-beta.3+local.g037e7939bc29`.
- Native packaging passed library initialization and two-worker supervision.
- Seven focused checks passed **7/7 in 76.66 seconds**: policy files, operator
  diagnostics, rule simplification, prompt contracts, command catalogue, claim
  policy and installed product.
- The documentation check also passed. These checks use local fixtures and do
  not make hosted provider calls.
- `cmake --build --preset debug --target install-local` updated the normal
  per-user installation. Its executable matches the new build byte-for-byte;
  all **103** checked application/provider/skill files match the primary source.
- The normal installed executable successfully ran `config explain` against
  its installed editable configuration. `command -v crexxrag` resolves to
  `/Users/adrian/.local/bin/crexxrag`.

Installed native SHA-256:
`ba35a980f1a4bcc06ea7cae5e6011bd4aeb0e123cbac3a7bf705d23b68737816`.

Linked VM image SHA-256:
`ad7dbac81f157b52c9e97ef932516cf940522e6c26a4c37e66837d29904ff1d5`.

The earlier frozen review executable remains historical Test 2/Test 3 evidence;
the new build above is the normal installation. Retained consolidation evidence
is in [`qa/version-consolidation-20260913/`](qa/version-consolidation-20260913/).
The previous normal executable is retained at
`/private/tmp/crexxrag-consolidation-20260913/crexxrag-before-install`.

## Remaining work

The [maintenance performance findings](maintenance-planning-performance-20260913.md)
remain open. The three experimental indexes have not been added to product
migrations, and maintenance preparation still consumes the requested duration.
Consolidation establishes one current source/install baseline; it does not
claim those pending performance repairs are implemented.

This was a local merge and installation. No push or release was performed.
The user libraries and completed hosted run windows were unchanged.
