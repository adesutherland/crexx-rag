# Structured Data Boundary System Design

## Classification

This directory is a consumer and application-boundary qualification, not a
locally implemented donation package.

- Parse-once JSON is provided by the installed CREXX `rxjson` package.
- Nominal typed records are ordinary cREXX application classes.
- `sqlite_boundary` supplies generic typed columns but does not know the record
  type or SQL schema.

The directory is included in the incubation audit because parse-once `rxjson`
was an original candidate. Gate-1A/Phase-1B evidence established that the
installed facility now satisfies the required boundary, so a competing local
parser must not be created or proposed for donation.

## Modules

| Module | Classification | Responsibility |
| --- | --- | --- |
| `p1_json_01.crexx` | Consumer qualification | Parse-once traversal, typed values, Unicode/error distinctions, bounded encoding example |
| `p1_json_02.crexx` | Consumer benchmark | Compare parse-once traversal with repeated path-based access |
| `record_boundary.crexx` | Application example | Load fixture-specific nominal records from typed SQLite columns |
| `record_facade.crexx` | Application facade example | Return the Level-G nominal records through a stable object API |
| `p1_rec_01.crexx` | Boundary qualification | Prove paging, ownership, null-kind, binary, and direct record crossings |

## Ownership And Data Flow

One `.jsondocument` owns the source and structural index. Node identifiers are
document-local integers and must not escape without their document owner. Typed
getters copy the requested scalar into caller-owned values. The application
does not use JSON as an internal record transport.

For database rows, `record_boundary` owns the SQL and constructs `.typedrow`
objects from `sqlite_boundary` column getters. The facade returns the same
nominal objects. JSON encoding occurs only at a genuine external protocol
boundary.

## Errors And Limits

`rxjson` owns parse diagnostics and typed getter statuses. Application encoding
adds explicit byte limits and must return a typed failure rather than truncate.
The fixture record loader currently returns an empty array on database/read
failure; that behavior is evidence for improving the Phase-2 repository result
contract, not a generic API to preserve.

## Donation Consequence

No source in this directory should be packaged as a new `rxjson`, ORM, or
generic record library. Any future enhancement to installed `rxjson` belongs in
the CREXX package with its own source-adjacent usage/system documentation. Any
reusable typed-record helper must first demonstrate a second consumer and a
contract independent of this fixture schema.
