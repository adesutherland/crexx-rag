# Bounded baseline acceptance and publication — 16 September 2026

Adrian approved: one master register, small low-risk fixes with targeted tests,
then baseline operational acceptance, publication and a fresh status review.
This record preserves execution evidence; [ROADMAP.md](ROADMAP.md) is the sole
current-status authority. Starting baseline is `549887f` on `main`, clean.

## Outcomes and numbered acceptance

1. [x] Reconcile configuration (53 HC IDs), operational, query, reliability,
   recovery, escalation and Test 7 findings into the master, retaining original
   IDs, requirements and evidence. Archive the previous narrative explicitly.
2. [x] Reproduce the small typed lease-validation gap with valid controls before
   repair. Keep bounds in the existing owner; no new configuration or schema.
3. [x] Pass targeted configuration and recovery checks. Correct current
   escalation routing, source-format and qualification guidance.
4. [x] Complete isolated baseline operational acceptance: installed package
   doctor/configuration, ingestion, maintenance, query/citations, repeat/no-op,
   ordinary/advanced route and final-decision controls. Use synthetic local
   providers and private scratch libraries; no user corpus or hosted calls.
5. [x] Qualify the complete local functional gate once for the final product
   candidate; reuse exact-input passes, audit receipts and include #701. Run the
   separate scale lane for the updated runtime. Check whitespace and package.
6. [x] Commit, publish main and install the exact qualified revision to the
   normal user prefix. Verify artifact hashes and fresh installed CLI/MCP
   behavior, preserve prior RAG artifacts and record rollback information.
7. [x] Review remaining status, explicitly retaining hosted, endurance, platform
   and content-quality work. No tagged release or corpus processing is implied.

## Selected quick fixes and baseline evidence

HC-31: `configuration_contract` adds file and typed lease cases at 1, 86,400,
0 and 86,401 seconds. Before repair it failed **only** `typed lease boundary
86401`; valid endpoints and invalid-file controls passed. CTest failed normally
in 0.54 seconds. Baseline source was `549887f` with only these new assertions.
`ragworkerdefaults` now owns the existing 1–86,400 range; typed config, file
parsing, work claim and heartbeat consume it. Valid canonical bytes, required
file setting, persisted policy and schema remain unchanged.

Source-format guidance (HC-46 documentation portion) now states supported UTF-8
extensions/MIME mapping, case rules and skipped unsupported formats. Per-file
skip diagnostics remain proposed; no ingestion behavior changed. Architecture
and MCP guidance now describe the already-delivered advanced worker route and
completed batch, removing two pre-implementation escalation statements.

The master restores HC-52/53, records individual escalation/Test 7/smoke IDs,
removes the stale #701 exclusion and makes historical registers subordinate.
HC priorities retain their original meanings; this is not 53 confirmed defects
or a decision to expose every constant as a new setting.

## Qualification and publication evidence

Targeted post-repair checks passed 4/4 in 17.56 seconds: configuration contract
(17.55s, all four compiler/VM cells), policy-file VM (1.10s), lifecycle (3.41s)
and documentation (1.06s), scheduled in parallel. Original typed/file identity
and invalid-value controls remain intact.

Operational acceptance passed 3/3 in 32.84 seconds: `installed_product`
(32.84s), `durable_backlog_escalation` (3.45s) and
`durable_backlog_provider_advanced` (3.53s). The scratch install performs doctor,
policy editing, Gemini protocol smoke, init/ingest/maintenance/hybrid query,
exact citations, page limits, plan detail and Unicode checks. The escalation
cases assert search/read binding, deferral, advanced routing, final no-change
and cumulative history independently. All provider traffic is synthetic loopback.

The final functional selection passed in **414.10 seconds (6m54s)**: 115 new
executions plus seven retained exact-input passes, 122 selected, zero failures
or disabled cases. The seven retained cases are the four targeted and three
operational cases above. The independent 17,000-request turnover scale case
passed in **4.81 seconds**. New #701 fault acceptance passed in 5.80 seconds.
A fresh documentation check follows the final register/evidence updates; only
that changed-input case needs rerunning, not the product panel.

Raw logs and the compressed exact-input audit are retained under
`docs/qa-evidence/20260916-baseline-publication/`. The current receipt audit must
show all 122 functional cases plus one scale case passed. The previous full
qualification and #701 retest are historical inputs, not substituted results.

Qualified native SHA-256:
`d9bd6040b99f83bc9bac6ca4f8ff0240445853e5e27c1b1838aab3bc158d54d9`.
Qualified linked SHA-256:
`bde3333aa25cc407d2393e5050c2a5ed1595d6a180c9f8f8a31cf715b73cfc8f`.
No product change followed these executions. All 53 HC rows are present exactly
once; no ID from the previous master was lost. GitHub #701 closed upstream at
14:30:48 UTC on 16 September; #699 remains open. The final source review and
whitespace check accompany the commit.

The installed CREXX package is clean `17e844441ed87e1f6e0d5f1f0d3bb4bee8db6187`.
The sibling CREXX checkout remains read-only. Publication means updating this
project's `origin/main` and normal `$HOME/.local` RAG installation; it does not
replace tools/configuration in ScottishHistory or restart its closed jobs.

## Deferred scope

T7-10 historical host attribution / fresh endurance, QA-02 bounded hosted and
fresh-agent content acceptance, QA-03 non-macOS qualification, QA-04 malicious
source assurance, HC-07 vector memory redesign, OPS-007 commented job files and
the QE implementation/evaluation backlog remain separate. No new paid-call
allowance, user-library authority or unrestricted production claim is created.

## Installation rollback preparation

Previous RAG executable, linked/address modules, data/templates and docs are
retained in `/Users/adrian/.local/state/crexxrag/publications/20260916T143845Z/previous-rag.tar.gz`.
Its `before.json` records the prior native hash and installed CREXX identity.
To roll back, stop the affected RAG sessions and restore those RAG paths from
the archive into `/Users/adrian/.local`; no CREXX runtime, policy or library
rollback is included. New source-only package files can remain unused.

## Completed publication and status review

Implementation commit `858c67f42dbb76d77ccff0a0b53012f300bfcf18` is installed in
`/Users/adrian/.local` and published to `origin/main`; the remote SHA was checked
independently. Both native and linked installed hashes match the qualified
artifacts above. This closeout changes documentation/evidence only; final
publication HEAD is recorded beside the rollback archive in `installed.json`.

Five fresh installed CLI checks passed (doctor, status, verify, lexical inspect
and citation resolution), followed by nine MCP requests covering discovery,
status, verification, query/citation, queue, prompt and session stop. Two further
MCP requests verified control-permission discovery. All eleven succeeded;
read/diagnose correctly hides the control-only deferral tool, and read/control
exposes it. The initial harness postcheck incorrectly expected that tool in the
read-only catalogue. Retained responses proved the functional calls had passed;
correcting that assertion required no product edit or repeated functional calls.
The copied fixture database and manifest remain byte-identical. No hosted calls,
user library writes or Scottish installation changes occurred.

The final receipt audit accounts for **123 passed cases** (122 functional and
one scale), with no disabled, failed or missing case. Documentation changes after
functional QA receive only a fresh documentation-contract check; the unchanged
product receipts remain valid. `git diff --check` passes. No tagged release or
hosted/cross-platform/endurance qualification is claimed.

Closed in this batch: master-register omissions/stale #701 status, HC-31's typed
lease-range mismatch and outdated escalation guidance. HC-46's format guidance
is delivered; per-file unsupported-format reporting stays proposed. #701 is
closed upstream and qualified downstream. #699, T7-10 and broader OPS/QA/QE work
retain their explicit scope in the master. Recommended next choices are a small
T7-10 host-lifetime experiment, OPS-007 job files, then measured QE-09 retrieval
baselining before larger query/model changes. No such work is started here.
