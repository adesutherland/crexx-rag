#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./cmake-build-debug/crexx-rag}"
LIB="${2:-./example.cprag}"

rm -rf -- "${LIB}"
"${BIN}" init "${LIB}"
"${BIN}" add-entity-typed "${LIB}" entity:auth service Authentication "Authentication service handling login and sessions"
"${BIN}" add-entity-typed "${LIB}" entity:postgres data-object PostgreSQL "PostgreSQL database storing user profiles"
"${BIN}" add-entity-typed "${LIB}" entity:backup service Backup "Nightly backup service for PostgreSQL"
"${BIN}" add-edge-typed "${LIB}" entity:auth entity:postgres accesses "Reads user profiles" 1.0
"${BIN}" add-edge-typed "${LIB}" entity:postgres entity:backup depends-on "Backed up by" 0.8
"${BIN}" ingest-text "${LIB}" docs/auth.md "Auth architecture notes" markdown 120 20 \
  $'# Auth\n\nAuthentication depends on PostgreSQL and the backup service protects the user profile data.'
"${BIN}" list-sources "${LIB}"
"${BIN}" list-chunks "${LIB}" docs/auth.md
"${BIN}" shortest-path "${LIB}" entity:auth entity:backup
"${BIN}" search "${LIB}" "what database does auth use" 3 2
