#!/usr/bin/env bash
# Compile the real NSIS installer against private, inert files.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/rag-nsis-test.XXXXXX")"
trap 'rm -rf "$work"' EXIT
payload="$work/payload with spaces"
mkdir -p "$payload/bin" "$payload/share/crexxrag/installer"
printf 'MZ compile fixture' > "$payload/bin/crexxrag.exe"
cp "$ROOT/packaging/windows/update-user-path.ps1" "$payload/share/crexxrag/installer/"
bash "$ROOT/scripts/release/host-tools.sh" windows_installer "$payload" "$work/setup.exe" 0.1.0-dev.1 "$work"
[[ "$(od -An -tx1 -N2 "$work/setup.exe" | tr -d ' \n')" == 4d5a ]]
echo 'NSIS fixture compilation passed.'
