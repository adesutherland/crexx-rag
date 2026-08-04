# cREXX Application Modules

Status: Phase 2 product implementation. These modules are application code,
not generic CREXX donation candidates.

## Use

Import the public contract modules from a Level G cREXX application:

```text
options levelg
import ragmodel
import ragevidence
import ragjob
import raglibrary
import ragconfig
import ragprofile
import ragregistry
```

`raglibrary` defines the library and factory interfaces. `ragjob` defines the
durable-job handle contract. `ragevidence` defines immutable evidence records.
`ragmodel` contains records shared by those contracts. `ragconfig` and
`ragprofile` define typed operational configuration and domain profiles;
`ragregistry` exposes only operator-registered ids.

The example operator registry is constructed in
`config/operator_registry.crexx`. It registers `architecture-local`,
`generic-profile`, and `it-architecture-profile` from independent modules.
Applications receive the constructed registry and select ids; there is no
runtime module-path argument.

The compiled consumers are
`crexx/application/tests/p2_01_contract_consumer.crexx` and
`crexx/application/tests/p2_02_config_consumer.crexx`.

## Current Limits

`P2-01` freezes the Level G object vocabulary and record boundaries only. It
does not implement schema v2, library opening, command adapters, provider
execution, plan validation, or durable job behavior. `P2-02` configuration
loading is side-effect free and retains only symbolic `env:NAME` references;
it does not resolve credentials. The fixture consumers are explicitly
in-memory and do not claim later-phase capabilities.
