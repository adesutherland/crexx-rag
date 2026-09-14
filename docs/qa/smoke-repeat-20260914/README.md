# Tests 1–4 repeat evidence

See [the report](../../smoke-repeat-20260914.md). `identity.json` names the exact
committed baseline, frozen native artifact, disposable library and source backup.
The three retained configurations contain symbolic credential references only.

- `restore.json`, `migrate.json`, `before.json`: the fresh pre-Test-1 state.
- `test1-*`: exact five-item selection, bounded plan, run, usage, preserved
  original attempts and successful automatic publication.
- `test2-*`: one new source, failed controller, completed item status,
  provider-free vector recovery, repeat-import no-op and resolved citation.
- `test3-*`: bounded plan/apply timings, selected tasks, clean run and decisions.
- `test4-*`: compatibility rejection, temporary/restored configuration,
  Fiers success, Nairn rejection, original grounding replay and draft checks.
- `test4-nairn-grounding-failures.json`: exact missing endpoint in both responses.
- `repeat/`, `followups/`: actual MCP wire responses and timing metrics;
  `measure_mcp.py` and `measure_followups.py` are diagnostic capture clients.
- `assistant-answer.md`: answer composed by the current assistant from the
  resolved MCP source span, without invoking the product answerer.
- `final-verify.json`, `final-accounting.json`, `runtime-final.json`: integrity,
  complete call/spend accounting, lineage, preservation and stopped processes.

Public commands own restore, migration, configuration, planning, job execution,
replay and vector publication. Read-only SQLite extracts provide independent
accounting and preservation checks; no direct SQL writes were made.
`grounding_check.crexx` composes the existing product grounding and file owners.
The 122 original sample cases and 45 existing draft cases reference the retained
13 September inputs; all were rerun with the current installed CREXX toolchain.

For another run, create a new disposable restore and fresh bounded plans.
The saved plans and windows document this completed run and are not reusable
execution authority. `SHA256SUMS` covers the retained files.
