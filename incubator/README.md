# Generic Capability Incubation

This tree contains capability probes, generic package candidates, application
vertical slices, and qualification harnesses. Being under `incubator/` does not
by itself make code a CREXX donation candidate.

## Documentation Rule

Every locally implemented package under active consideration for donation must
keep these files beside its implementation:

- `README.md`: user documentation covering status, prerequisites, supported
  operations, a minimal example, tests, and current limitations;
- `SYSTEM.md`: maintainer documentation covering boundaries, module layout,
  dependencies, ownership, errors, invariants, performance evidence, and the
  remaining donation-readiness work;
- `PACKAGE.toml`: explicitly non-released candidate identity, dependencies,
  compatibility status, and submission authority; and
- `BUNDLE.tsv`: source-root-relative, role-labelled review-bundle contents.

Documentation completeness is necessary but does not imply that a package is
approved for donation. Donation still requires the roadmap's independent API,
dual-VM tests, installed-consumer test where relevant, example, representative
benchmark, packaging metadata, minimized non-RAG reproducer, and explicit
approval.

Advanced reusable cREXX libraries and application code in this tree use Level
G, including their examples and qualification consumers. Importing an installed
Level-B foundation library does not lower that source to Level B. Level B is
reserved for a CREXX bootstrap/foundation implementation or a minimized
low-level capability probe with an explicit reason; it is not a performance
tier for advanced libraries. Completed Gate-1A probes and dated evidence retain
their historical language levels.

## Candidate Audit

Status date: 2026-08-23.

| Capability | Implementation boundary | Colocated documentation | Disposition |
| --- | --- | --- | --- |
| SQLite (`rxsqlite` candidate) | [`p1a/sqlite_boundary/`](p1a/sqlite_boundary/) | [use](p1a/sqlite_boundary/README.md), [system](p1a/sqlite_boundary/SYSTEM.md), [package](p1a/sqlite_boundary/PACKAGE.toml), [bundle](p1a/sqlite_boundary/BUNDLE.tsv), [retained contract](phase1b/rxsqlite/CONTRACT.md) | Implemented generic candidate; P2-09 review bundle prepared and four-cell probe green, but final name/version, independent release packaging and donation approval remain open |
| Provider-neutral LLM/embedding (`rxllm` candidate) | [`phase1b/provider/`](phase1b/provider/) | [use](phase1b/provider/README.md), [system](phase1b/provider/SYSTEM.md), [package](phase1b/provider/PACKAGE.toml), [bundle](phase1b/provider/BUNDLE.tsv) | Implemented cREXX incubation with a P2-09 review bundle and zero-call four-cell probe; provider-lifetime scope, selected downstream Linux/package replay, catalogue release policy and donation approval remain open |
| Float32 codec and exact vector primitives | [`phase1b/vector/`](phase1b/vector/) | [use](phase1b/vector/README.md), [system](phase1b/vector/SYSTEM.md), [package](phase1b/vector/PACKAGE.toml), [bundle](phase1b/vector/BUNDLE.tsv) | Portable codec plus pure exact oracle/fallback have a P2-09 review bundle and four-cell probe; the installed CREXX `rxvector` provider remains selected acceleration, while final package split/policy and donation approval remain open |
| Parse-once JSON (`rxjson`) | Installed CREXX package; local consumers in [`phase1b/structured_data/`](phase1b/structured_data/) | [use](phase1b/structured_data/README.md), [system](phase1b/structured_data/SYSTEM.md) | Consumed upstream capability, not a locally implemented donation package |
| Industrial HTTP/TLS | Installed Level-G `rxfnsg`; local consumer in [`phase1b/provider/provider_http.crexx`](phase1b/provider/provider_http.crexx) | Provider [system documentation](phase1b/provider/SYSTEM.md) records the dependency and remaining downstream gates | Upstream public substrate has cross-platform build and supported Linux sanitizer evidence; the current macOS inventory passes 69/69. Exact downstream Linux confirmation and provider-lifetime reuse/stream/cancel decisions remain open |
| Binary SHA-256 | Complete installed native `rxhash` SHA-256 family; local proof in [`phase1b/hash/`](phase1b/hash/) and application use in [`../crexx/application/ragfile.crexx`](../crexx/application/ragfile.crexx) | [qualification notes](phase1b/hash/README.md) | One-shot raw/hex, immutable incremental state, and bounded-memory file hashing are consumed directly; dynamic autoload, optimized/non-optimized dual-VM use, and installed static/native packaging pass |
| Typed configuration/command helpers | None | None required until an implementation boundary is created | Future candidate; not implemented |
| MCP transport helpers | None | None required until an implementation boundary is created | Future candidate; not implemented |

## Explicit Non-Candidates

- `phase1b/algorithm/` contains application source, claim, lifecycle, and
  evidence behavior. It remains cREXX product code.
- `phase1b/job/` contains application queue, lease, promotion, and budget
  behavior. It remains cREXX product code until a credible broader contract is
  separately demonstrated.
- `phase1b/rxpa_consumer/` is an installed-package qualification harness, not a
  runtime package proposed for donation.
- `p1a/` directories other than the SQLite implementation are bounded Gate-1A
  probes or historical precursors, not current package boundaries.

## Adding A Candidate

Create the package boundary first, add `README.md`, `SYSTEM.md`, `PACKAGE.toml`,
and `BUNDLE.tsv` in the same directory, and then add one row to this audit. The
system document must state
which APIs are stable, experimental, or application-owned and must link the
tests and measurements that justify the proposed generic boundary.
