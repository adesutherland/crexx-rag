#!/usr/bin/env bash
# Private fixtures only: no real credentials, network, application or release.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOST="$ROOT/scripts/release/host-tools.sh"
work="$(mktemp -d "${TMPDIR:-/tmp}/rag-package-test.XXXXXX")"
trap 'rm -rf "$work"' EXIT
payload="$work/payload with spaces"; mkdir -p "$payload/bin"
commit=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
crexx=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
checks=0
pass() { checks=$((checks+1)); echo "PASS: $*"; }
reject() { if "$@" > "$work/rejected.log" 2>&1; then echo 'Expected rejection' >&2; exit 1; fi; }
printf executable > "$payload/bin/crexxrag"; chmod 755 "$payload/bin/crexxrag"
printf engine > "$payload/bin/engine.so"
hash="$(bash "$HOST" checksums "$payload/bin"; shasum -a 256 "$payload/bin/engine.so" | cut -d ' ' -f1)"
jq -n --arg hash "$hash" '{version:1,provider:"rxllama",platform:"Darwin",arch:"arm64",engine:"pinned",backends:[{path:"engine.so",sha256:$hash,backend:"cpu"}]}' > "$payload/bin/rxllama.runtime.json"
runtime_hash="$(shasum -a 256 "$payload/bin/rxllama.runtime.json" | cut -d ' ' -f1)"
jq -n --arg hash "$hash" --arg runtime "$runtime_hash" '{version:1,provider:"rxllama",platform:"Darwin",arch:"arm64",engine:"pinned",link_libraries:[{path:"engine.so",sha256:$hash}],runtime_files:[{path:"engine.so",sha256:$hash},{path:"rxllama.runtime.json",sha256:$runtime}]}' > "$payload/bin/rxllama.native.json"
bash "$HOST" provider "$payload/bin"; pass 'provider positive control'
mkdir -p "$work/tools"
cat > "$work/tools/jq" <<'STUB'
#!/usr/bin/env bash
set -o pipefail
"$REAL_JQ" "$@" | awk '{printf "%s\r\n", $0}'
STUB
chmod +x "$work/tools/jq"
REAL_JQ="$(command -v jq)" PATH="$work/tools:$PATH" bash "$HOST" provider "$payload/bin"
pass 'provider accepts native Windows jq CRLF output'
rm "$work/tools/jq"
printf 'signed engine' > "$payload/bin/engine.so"
reject bash "$HOST" provider "$payload/bin"; pass 'changed provider bytes rejected'
bash "$HOST" provider "$payload/bin" refresh
bash "$HOST" provider "$payload/bin"; pass 'provider refresh tracks signed bytes and nested manifest'
cp "$payload/bin/rxllama.native.json" "$work/native.json"
jq '.runtime_files[0].path="../outside"' "$work/native.json" > "$payload/bin/rxllama.native.json"
printf outside > "$payload/outside"
reject bash "$HOST" provider "$payload/bin" refresh; pass 'provider escape rejected during refresh'
mv "$work/native.json" "$payload/bin/rxllama.native.json"; rm "$payload/outside"
bash "$HOST" inventory "$payload" 0.1.0-beta.1 "$commit" "$crexx" macos-arm64 unsigned
bash "$HOST" verify "$payload"; pass 'complete inventory positive control'
touch "$payload/extra"; reject bash "$HOST" verify "$payload"; rm "$payload/extra"; pass 'extra file rejected'
cp "$payload/bin/crexxrag" "$work/application"
printf changed > "$payload/bin/crexxrag"; reject bash "$HOST" verify "$payload"; pass 'changed file rejected'
rm "$payload/bin/crexxrag"; reject bash "$HOST" verify "$payload"; pass 'missing file rejected'
cp "$work/application" "$payload/bin/crexxrag"; chmod 755 "$payload/bin/crexxrag"
for version in ../release '0.1.0"' v0.1.0 latest; do reject bash "$HOST" inventory "$payload" "$version" "$commit" "$crexx" macos-arm64 unsigned; done
pass 'unsafe release versions rejected'
reject bash "$HOST" inventory "$payload" 0.1.0 short "$crexx" macos-arm64 unsigned
reject bash "$HOST" inventory "$payload" 0.1.0 "$commit" "$crexx" unknown unsigned; pass 'commit and platform identity validated'
bash "$HOST" archive_payload "$payload" "$work/portable.zip"
bash "$HOST" unpack "$work/portable.zip" "$work/unpacked with spaces"
[[ -x "$work/unpacked with spaces/bin/crexxrag" ]]; pass 'archive preserves spaces, bytes and executable permission'
ln -s "$work/application" "$payload/link"
reject bash "$HOST" inventory "$payload" 0.1.0 "$commit" "$crexx" macos-arm64 unsigned; rm "$payload/link"; pass 'payload symlinks rejected'
bash "$HOST" inventory "$payload" 0.1.0 "$commit" "$crexx" windows-x64 unsigned
printf uninstaller > "$payload/Uninstall.exe"
bash "$HOST" verify "$payload" installed
reject bash "$HOST" verify "$payload"; rm "$payload/Uninstall.exe"; pass 'generated uninstaller allowed only in installed Windows payload'
keys=(APPLE_DEVELOPER_ID_CERTIFICATE_BASE64 APPLE_DEVELOPER_ID_CERTIFICATE_PASSWORD APPLE_DEVELOPER_ID_IDENTITY APPLE_DEVELOPER_ID_INSTALLER_CERTIFICATE_BASE64 APPLE_DEVELOPER_ID_INSTALLER_CERTIFICATE_PASSWORD APPLE_DEVELOPER_ID_INSTALLER_IDENTITY APPLE_ID APPLE_APP_SPECIFIC_PASSWORD APPLE_TEAM_ID)
for key in "${keys[@]}"; do export "$key=fixture"; done
[[ "$(bash "$HOST" apple_state)" == signed ]]
for key in "${keys[@]}"; do export "$key="; [[ "$(bash "$HOST" apple_state 2>/dev/null)" == unsigned ]]; export "$key=fixture"; done
for key in "${keys[@]}"; do unset "$key"; done
[[ "$(bash "$HOST" apple_state 2>/dev/null)" == unsigned ]]; pass 'all nine Apple settings required; absent or partial selects unsigned'
mkdir -p "$work/tools"
cat > "$work/tools/osslsigncode" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
cat > "$work/tools/jsign" <<'STUB'
#!/usr/bin/env bash
exit 99
STUB
chmod +x "$work/tools/osslsigncode" "$work/tools/jsign"
PATH="$work/tools:$PATH" bash "$HOST" sign-file "$payload/bin/engine.so"; pass 'valid vendor signature retained without re-signing'
bash "$HOST" prepare "$payload" "$work/staged" windows-x64 "$work/prepared-assets"
[[ -f "$work/staged/share/crexxrag/installer/update-user-path.ps1" && ! -e "$payload/share" ]]; pass 'Windows path helper staged without changing input'
# Fake GitHub transport verifies cleanup ordering and retry without publication.
mkdir -p "$work/signed" "$work/remote"
bash "$HOST" inventory "$payload" 0.1.0 "$commit" "$crexx" windows-x64 signed
stem=crexxrag-0.1.0-windows-x64-signed
old=crexxrag-0.1.0-windows-x64-unsigned
bash "$HOST" archive_payload "$payload" "$work/signed/$stem.zip"
printf MZinstaller > "$work/signed/$stem-setup.exe"
bash "$HOST" checksums "$work/signed"
for name in "$old.zip" "$old-setup.exe" "$old.zip.sha256" "$old-setup.exe.sha256" macos-signed.pkg crexxrag-0.0.9-windows-x64-unsigned.zip; do printf old > "$work/remote/$name"; done
jq -n --arg root "$work/remote" '{id:73,assets:[]}' > "$work/remote.json"
cat > "$work/tools/gh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == api && "$2" == */commits/* ]]; then echo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
elif [[ "$1" == api && "$2" == --method ]]; then
  [[ -f "$FAKE_REMOTE/crexxrag-0.1.0-windows-x64-signed.zip" && -f "$FAKE_REMOTE/crexxrag-0.1.0-windows-x64-signed-setup.exe" && -f "$FAKE_REMOTE/crexxrag-0.1.0-windows-x64-signed.zip.sha256" && -f "$FAKE_REMOTE/crexxrag-0.1.0-windows-x64-signed-setup.exe.sha256" ]] || exit 77
  id="${4##*/}"
  name="$(jq -r --argjson id "$id" '.assets[]|select(.id==$id)|.name' "$FAKE_STATE")"
  rm "$FAKE_REMOTE/$name"
elif [[ "$1" == api ]]; then
  jq -n --argjson id 73 --arg dir "$FAKE_REMOTE" '[inputs]|{id:$id,assets:to_entries|map({id:(.key+1),name:.value})}' < <(find "$FAKE_REMOTE" -type f -maxdepth 1 -exec basename {} \; | LC_ALL=C sort | jq -R .) > "$FAKE_STATE"
  cat "$FAKE_STATE"
elif [[ "$1" == release && "$2" == upload ]]; then
  cp "$4" "$FAKE_REMOTE/"
  [[ "${INTERRUPT_UPLOAD:-0}" == 0 ]] || exit 23
else exit 88
fi
STUB
chmod +x "$work/tools/gh"
export FAKE_REMOTE="$work/remote" FAKE_STATE="$work/remote.json"
reject env PATH="$work/tools:$PATH" INTERRUPT_UPLOAD=1 bash "$HOST" windows_upload "$work/signed" owner/repo v0.1.0 "$work/failed-upload"
[[ -f "$work/remote/$old.zip" && -f "$work/remote/$old-setup.exe" ]]; pass 'interrupted upload retains unsigned downloads'
PATH="$work/tools:$PATH" bash "$HOST" windows_upload "$work/signed" owner/repo v0.1.0 "$work/retry-upload"
[[ ! -e "$work/remote/$old.zip" && ! -e "$work/remote/$old-setup.exe" && ! -e "$work/remote/$old.zip.sha256" && ! -e "$work/remote/$old-setup.exe.sha256" ]]; pass 'retry completes all four signed uploads before unsigned cleanup'
[[ -f "$work/remote/macos-signed.pkg" && -f "$work/remote/crexxrag-0.0.9-windows-x64-unsigned.zip" ]]; pass 'cleanup preserves unrelated and other-version assets'
reject env PATH="$work/tools:$PATH" bash "$HOST" windows_upload "$work/signed" owner/repo v0.9.0 "$work/wrong-tag"; pass 'wrong release version rejected'
printf '%s release tooling controls passed.\n' "$checks"
