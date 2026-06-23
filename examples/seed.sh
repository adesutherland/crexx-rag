#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./cmake-build-debug/crexx-rag}"
LIB="${2:-./example.cprag}"

"${BIN}" init "${LIB}"
"${BIN}" add-entity "${LIB}" entity:auth Service "Authentication service handling login and sessions"
"${BIN}" add-entity "${LIB}" entity:postgres Database "PostgreSQL database storing user profiles"
"${BIN}" add-entity "${LIB}" entity:backup Service "Nightly backup service for PostgreSQL"
"${BIN}" add-edge "${LIB}" entity:auth entity:postgres CONNECTS_TO 1.0
"${BIN}" add-edge "${LIB}" entity:postgres entity:backup BACKED_UP_BY 0.8
"${BIN}" ingest-text "${LIB}" docs/auth.md "Auth architecture notes" markdown 120 20 \
  $'# Auth\n\nAuthentication depends on PostgreSQL and the backup service protects the user profile data.'
"${BIN}" list-sources "${LIB}"
"${BIN}" search "${LIB}" "what database does auth use" 3 2
