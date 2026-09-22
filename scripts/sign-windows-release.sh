#!/usr/bin/env bash
# Post-release maintainer operation: local PKCS11 credentials, never CI secrets.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$script_dir/release/package.py" windows-sign "$@"
