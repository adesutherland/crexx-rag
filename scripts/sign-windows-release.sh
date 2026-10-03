#!/usr/bin/env bash
# Local PKCS11 credentials, never CI secrets.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
exec crexx -nokeep scripts/release/package.crexx --args windows-sign "$@"
