# Installed rxjson And Typed Record Usage

Status: Phase-1B consumption and boundary qualification. This directory does
not implement a JSON package for donation. It consumes the installed CREXX
`rxjson` facility and proves how Level-G application-owned nominal records cross
plugin and public API boundaries without JSON reserialization.

See [SYSTEM.md](SYSTEM.md) for the package classification and module boundary.

## Parse Once

Create one immutable `.jsondocument` for each input and retain it while
traversing document-local node identifiers:

```rexx
options levelg

import rxjson

document = .jsondocument('{"items":["alpha",7,null]}')
if document.valid() = 0 then do
  say document.error()
  return 1
end

items = document.member(document.root(), "items")
nodes = .int[]
count = document.children(items, nodes)
if count \= 3 then return 1

text = ""
number = 0
if document.node_string(nodes[1], text) \= 0 then return 1
if document.node_int(nodes[2], number) \= 0 then return 1
say text number document.node_type(nodes[3])
return 0
```

Use `member` for exact object-member names and `element`/`children` for arrays.
Typed getters preserve string, signed integer, float, boolean, null, missing,
empty string, empty array, and empty object distinctions. A node identifier is
valid only for the document that created it.

Encoding helpers should delegate string escaping to `jsonquote` and apply an
explicit UTF-8 byte ceiling to the complete encoded payload. Limits and payload
schemas remain caller owned.

## Typed Application Records

[`record_boundary.crexx`](record_boundary.crexx) demonstrates a nominal
`.typedrow` loaded directly from typed SQLite columns. The Level-G
[`record_facade.crexx`](record_facade.crexx) returns `.typedrow[]` without
turning it into corpus JSON. This is an application boundary pattern, not a
generic row model proposed for donation.

## Tests

```bash
ctest --preset debug -R '^(p1_json_0[1-2]|p1_rec_01)$' --output-on-failure
```

The tests cover Unicode, malformed/truncated input, missing/null/empty values,
typed traversal, bounded encoding, parse-once profiling, paged SQLite records,
null-kind preservation, owning binary values, and direct Level-G record and
plugin crossings on both CREXX VMs and compiler modes.

## Current Limits

- `rxjson` system and API ownership lives in the CREXX package, not this
  repository.
- The local bounded encoder is qualification code, not a general JSON writer.
- `typedrow`, its SQL, and its checksum are fixture-specific examples and must
  not be donated as a supposedly generic database abstraction.
