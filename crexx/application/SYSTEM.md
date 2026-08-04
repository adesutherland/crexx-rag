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
ragmodel <- ragconfig + ragprofile <- ragregistry
ragconfig + ragprofile + ragregistry <- operator registry
```

`raglibrary` coordinates public operations. `ragjob` is a returned durable-work
handle. `ragevidence` is the stable evidence packet object; passages, accepted
claims, support, ambiguity, leads, and gaps remain distinct.

`ragconfig` validates source sets, provider routes, symbolic secret references,
budgets, and the currently qualified single-worker scope. `ragprofile` validates
domain types, relationships, aliases, chunk policy, ranking weights, prompt
identities, and validator identities. `ragregistry` receives already
constructed operator modules and exposes typed id lookup only. Dynamic module
loading is intentionally absent from the agent-facing boundary.

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
`rxbvm`. CTest `p2_02_config_contract` applies the same four-cell matrix to
config/profile validation, registry security, symbolic secrets, zero retained
secret values, and structural zero-side-effect checks. The language-level
housekeeping audit also covers this directory.
