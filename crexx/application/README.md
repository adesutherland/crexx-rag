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
```

`raglibrary` defines the library and factory interfaces. `ragjob` defines the
durable-job handle contract. `ragevidence` defines immutable evidence records.
`ragmodel` contains records shared by those contracts. Concrete storage and
configuration implementations arrive in later ordered Phase-2 items.

The compiled usage contract is
`crexx/application/tests/p2_01_contract_consumer.crexx`.

## Current Limits

`P2-01` freezes the Level G object vocabulary and record boundaries only. It
does not implement schema v2, library opening, command adapters, providers,
plan validation, or durable job behavior. The fixture consumer is explicitly
in-memory and does not claim those capabilities.
