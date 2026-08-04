# cREXX Application System Notes

## Boundary

The directory owns product-facing Level G contracts and, as Phase 2 proceeds,
the cREXX implementations behind them. It may consume installed CREXX
foundation modules and separately qualified generic plugins. It must not call
the native-v1 RAG bridge, shell through the CLI, or import product behavior from
the incubation tree.

The current dependency direction is:

```text
ragmodel <- ragevidence
ragmodel <- ragjob
ragmodel + ragevidence + ragjob <- raglibrary
```

`raglibrary` coordinates public operations. `ragjob` is a returned durable-work
handle. `ragevidence` is the stable evidence packet object; passages, accepted
claims, support, ambiguity, leads, and gaps remain distinct.

## Contract Discipline

- All modules and their consumers use Level G.
- Public methods return nominal records or interfaces, not JSON strings.
- JSON belongs at later CLI/MCP transport adapters.
- Evidence claims remain directional and independently supported.
- Vector or graph proximity remains a lead, never accepted support.
- Later implementations must preserve truthful unsupported/error states.
- A facade is added only for a real public or transport contract, never for a
  language-level crossing.

## Verification

CTest `p2_01_application_contract` compiles every module and the consumer in
optimized and non-optimized modes, then runs the contract on `rxvme` and
`rxbvm`. The language-level housekeeping audit also covers this directory.
