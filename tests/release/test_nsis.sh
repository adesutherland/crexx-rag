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

# Exercise the Git Bash to native NSIS path boundary on every development host.
mkdir -p "$work/tools"
cat > "$work/tools/cygpath" <<'STUB'
#!/usr/bin/env bash
[[ "$1" == -w && "$2" == /* ]] || exit 41
printf 'C:\\fixture\\%s\n' "$(basename "$2")"
STUB
cat > "$work/tools/makensis" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
[[ "$1" == '/DRAG_PAYLOAD=C:\fixture\payload with spaces' ]]
[[ "$2" == '/DRAG_OUTPUT=C:\fixture\setup.exe' ]]
[[ "$5" == '/DRAG_UNINSTALL_FILES=C:\fixture\owned-files.nsh' ]]
[[ "$6" == 'C:\fixture\crexxrag.nsi' ]]
[[ -s "$NSIS_FIXTURE_INCLUDE" ]]
grep -Fq 'Delete "$INSTDIR\bin\crexxrag.exe"' "$NSIS_FIXTURE_INCLUDE"
STUB
chmod +x "$work/tools/cygpath" "$work/tools/makensis"
NSIS_FIXTURE_INCLUDE="$work/owned-files.nsh" OSTYPE=msys PATH="$work/tools:$PATH" \
  bash "$ROOT/scripts/release/host-tools.sh" windows_installer "$payload" "$work/setup.exe" 0.1.0-dev.1 "$work"
echo 'Git Bash NSIS path contract passed.'

bash "$ROOT/scripts/release/host-tools.sh" windows_installer "$payload" "$work/setup.exe" 0.1.0-dev.1 "$work"
[[ "$(od -An -tx1 -N2 "$work/setup.exe" | tr -d ' \n')" == 4d5a ]]
echo 'NSIS fixture compilation passed.'
