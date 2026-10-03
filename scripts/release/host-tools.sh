#!/usr/bin/env bash
# Native archive, manifest, installer and signing interfaces for package.crexx.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fail() { printf '%s\n' "$*" >&2; exit 1; }
digest() { if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d ' ' -f 1; }
absolute() { local path="$1"; (cd "$(dirname "$path")" && printf '%s/%s\n' "$PWD" "$(basename "$path")"); }
local_file() {
  local root="$1" name="$2" parent
  case "$name" in ''|/*|*\\*|[A-Za-z]:*|..|../*|*/../*|*/..) fail "Nonlocal declared file: $name";; esac
  [[ -f "$root/$name" && ! -L "$root/$name" ]] || fail "Missing/nonlocal declared file: $name"
  parent="$(cd "$(dirname "$root/$name")" && pwd -P)"
  [[ "$parent/" == "$(cd "$root" && pwd -P)/"* ]] || fail "Nonlocal declared file: $name"
}
provider() {
  local directory="$1" refresh="${2:-verify}" native runtime name expected actual doc updated key
  native="$directory/rxllama.native.json"; runtime="$directory/rxllama.runtime.json"
  jq -e '.provider=="rxllama" and (.link_libraries|type=="array") and (.runtime_files|type=="array")' "$native" >/dev/null || fail 'Invalid native provider manifest'
  jq -e '.provider=="rxllama" and (.backends|type=="array")' "$runtime" >/dev/null || fail 'Invalid runtime provider manifest'
  [[ "$(jq -c '[.version,.provider,.platform,.arch,.engine]' "$native")" == "$(jq -c '[.version,.provider,.platform,.arch,.engine]' "$runtime")" ]] || fail 'Provider identity mismatch'
  while IFS=$'\t' read -r name expected; do
    local_file "$directory" "$name"; actual="$(digest "$directory/$name")"
    [[ "$refresh" == refresh || "$expected" == "$actual" ]] || fail "Provider hash mismatch: $name"
  done < <(jq -r '.link_libraries[],.runtime_files[] | [.path,.sha256] | @tsv' "$native"; jq -r '.backends[] | [.path,.sha256] | @tsv' "$runtime")
  [[ "$refresh" == refresh ]] || return 0
  # Refresh runtime first, then the native manifest's hash of that runtime file.
  for doc in "$runtime" "$native"; do
    updated="$doc.updated"
    while IFS= read -r name; do
      actual="$(digest "$directory/$name")"
      jq --arg name "$name" --arg hash "$actual" '(.backends[]?,.link_libraries[]?,.runtime_files[]?) |= (if .path == $name then .sha256=$hash else . end)' "$doc" > "$updated"
      mv "$updated" "$doc"
    done < <(jq -r '.backends[]?.path,.link_libraries[]?.path,.runtime_files[]?.path' "$doc")
  done
}
inventory() {
  local prefix="$1" version="$2" commit="$3" crexx="$4" platform="$5" signing="$6" path name rows
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([-+][A-Za-z0-9.-]+)?$ ]] || fail 'Invalid release version'
  [[ "$commit" =~ ^[a-f0-9]{40}$ && "$crexx" =~ ^[a-f0-9]{40}$ ]] || fail 'Release inputs must use full commits'
  case "$platform" in windows-x64|macos-arm64|macos-x86_64) ;; *) fail 'Unknown release platform';; esac
  [[ -z "$(find "$prefix" -type l -print -quit)" ]] || fail 'Payload contains symlinks'
  rows="$(mktemp)"
  while IFS= read -r -d '' path; do
    name="${path#"$prefix/"}"; [[ "$name" != release.json ]] || continue
    jq -cn --arg name "$name" --arg hash "$(digest "$path")" '{key:$name,value:$hash}' >> "$rows"
  done < <(find "$prefix" -type f -print0)
  jq -s --arg version "$version" --arg source "$commit" --arg crexx "$crexx" --arg platform "$platform" --arg signing "$signing" '{product:"crexxrag",version:$version,source_commit:$source,crexx_commit:$crexx,platform:$platform,signing:$signing,files:from_entries}' "$rows" > "$prefix/release.json"
  rm "$rows"
}
verify() {
  local prefix="$1" installed="${2:-no}" path name expected actual declared found
  jq -e '.product=="crexxrag" and (.files|type=="object")' "$prefix/release.json" >/dev/null || fail 'Invalid release inventory'
  [[ -z "$(find "$prefix" -type l -print -quit)" ]] || fail 'Payload contains symlinks'
  declared="$(jq -r '.files|keys[]' "$prefix/release.json" | LC_ALL=C sort)"
  found="$(cd "$prefix"; find . -type f ! -path ./release.json | sed 's|^./||' | LC_ALL=C sort)"
  if [[ "$installed" == installed && "$(jq -r .platform "$prefix/release.json")" == windows-x64 ]]; then
    found="$(printf '%s\n' "$found" | sed '/^Uninstall.exe$/d')"
  fi
  [[ "$found" == "$declared" ]] || fail 'Release file set differs from inventory'
  while IFS=$'\t' read -r name expected; do
    local_file "$prefix" "$name"; actual="$(digest "$prefix/$name")"
    [[ "$actual" == "$expected" ]] || fail "Release hash mismatch: $name"
  done < <(jq -r '.files|to_entries[]|[.key,.value]|@tsv' "$prefix/release.json")
  provider "$prefix/bin"
}
archive_payload() { verify "$1"; local target; target="$(absolute "$2")"; (cd "$1" && cmake -E tar cf "$target" --format=zip .); }
unpack() {
  local source="$1" destination="$2" member list
  source="$(absolute "$source")"; list="$(mktemp)"
  cmake -E tar tf "$source" > "$list"
  [[ -z "$(LC_ALL=C sort "$list" | uniq -d)" ]] || fail 'Duplicate ZIP member'
  while IFS= read -r member; do
    case "$member" in /*|*\\*|[A-Za-z]:*|..|../*|*/../*|*/..) fail 'Nonlocal ZIP member';; esac
  done < "$list"
  # Refuse link entries before extraction, including links pointing outside.
  if cmake -E tar tvf "$source" | awk 'substr($0,1,1)=="l" {bad=1} END {exit !bad}'; then fail 'ZIP contains symlinks'; fi
  rm "$list"; mkdir -p "$destination"; (cd "$destination" && cmake -E tar xf "$source")
  verify "$destination"
}
checksums() {
  local output="$1" file
  for file in "$output"/*.zip "$output"/*.pkg "$output"/*.exe; do
    [[ -f "$file" ]] || continue
    printf '%s  %s\n' "$(digest "$file")" "$(basename "$file")" > "$file.sha256"
  done
}
apple_state() {
  local missing=() key value
  for key in APPLE_DEVELOPER_ID_CERTIFICATE_BASE64 APPLE_DEVELOPER_ID_CERTIFICATE_PASSWORD APPLE_DEVELOPER_ID_IDENTITY APPLE_DEVELOPER_ID_INSTALLER_CERTIFICATE_BASE64 APPLE_DEVELOPER_ID_INSTALLER_CERTIFICATE_PASSWORD APPLE_DEVELOPER_ID_INSTALLER_IDENTITY APPLE_ID APPLE_APP_SPECIFIC_PASSWORD APPLE_TEAM_ID; do
    value="${!key:-}"; [[ -n "${value//[[:space:]]/}" ]] || missing+=("$key")
  done
  if ((${#missing[@]})); then printf 'Missing Apple settings: %s\n' "${missing[*]}" >&2; echo unsigned; else echo signed; fi
}
apple_sign() {
  local prefix="$1" work="$2" keychain="$2/signing.keychain-db" password cert kind key path
  password="$(openssl rand -hex 24)"
  security create-keychain -p "$password" "$keychain"
  security set-keychain-settings -lut 21600 "$keychain"
  security unlock-keychain -p "$password" "$keychain"
  security list-keychains -d user -s "$keychain"
  security default-keychain -d user -s "$keychain"
  for kind in '' INSTALLER_; do
    cert="$work/${kind}certificate.p12"; key="APPLE_DEVELOPER_ID_${kind}CERTIFICATE_BASE64"
    (umask 077; printf '%s' "${!key}" | base64 --decode > "$cert")
    key="APPLE_DEVELOPER_ID_${kind}CERTIFICATE_PASSWORD"
    security import "$cert" -k "$keychain" -P "${!key}" -T /usr/bin/codesign -T /usr/bin/productbuild
    rm "$cert"
  done
  security set-key-partition-list -S apple-tool:,apple: -s -k "$password" "$keychain" >/dev/null
  while IFS= read -r -d '' path; do
    if file -b "$path" | grep -q 'Mach-O'; then
      codesign --force --timestamp --options runtime --keychain "$keychain" --sign "$APPLE_DEVELOPER_ID_IDENTITY" "$path"
      codesign --verify --strict "$path"
    fi
  done < <(find "$prefix/bin" -maxdepth 1 -type f -print0)
  provider "$prefix/bin" refresh
}
macos_installer() {
  local prefix="$1" output="$2" version="$3" work="$4" state="$5" pkgroot="$4/pkg-root" keychain="$4/signing.keychain-db" command
  mkdir -p "$pkgroot/usr/local/lib" "$pkgroot/usr/local/bin"
  cp -R "$prefix" "$pkgroot/usr/local/lib/crexxrag"
  ln -s ../lib/crexxrag/bin/crexxrag "$pkgroot/usr/local/bin/crexxrag"
  pkgbuild --root "$pkgroot" --identifier org.crexx.crexxrag --version "${version%%[-+]*}" --install-location / "$work/component.pkg"
  command=(productbuild --package "$work/component.pkg")
  if [[ "$state" == signed ]]; then command+=(--sign "$APPLE_DEVELOPER_ID_INSTALLER_IDENTITY" --keychain "$keychain" --timestamp); fi
  "${command[@]}" "$output"
  if [[ "$state" == signed ]]; then
    pkgutil --check-signature "$output"
    xcrun notarytool submit "$output" --apple-id "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --team-id "$APPLE_TEAM_ID" --wait --timeout 30m
    xcrun stapler staple "$output"; xcrun stapler validate "$output"
  fi
}
nsis_path() { if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then cygpath -m "$1"; else printf '%s\n' "$1"; fi; }
nsis_escape() { local name="${1//\//\\}"; name="${name//\$/\$\$}"; printf '%s' "${name//\"/\$\\\"}"; }
# The literal $INSTDIR below is expanded by NSIS, not by this shell.
# shellcheck disable=SC2016
windows_installer() {
  local prefix output version="$3" work="$4" helper="${5:-}" define=-D path name include command
  prefix="$(absolute "$1")"; output="$(absolute "$2")"; include="$work/owned-files.nsh"
  while IFS= read -r -d '' path; do
    name="${path#"$prefix/"}"; printf 'Delete "$INSTDIR\\%s"\n' "$(nsis_escape "$name")"
  done < <(find "$prefix" -type f -print0) > "$include"
  while IFS= read -r path; do
    name="${path#"$prefix/"}"; printf 'RMDir "$INSTDIR\\%s"\n' "$(nsis_escape "$name")"
  done < <(find "$prefix" -mindepth 1 -type d | LC_ALL=C sort -r) >> "$include"
  if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then define=/D; fi
  command=(makensis "${define}RAG_PAYLOAD=$(nsis_path "$prefix")" "${define}RAG_OUTPUT=$(nsis_path "$output")" "${define}RAG_VERSION=$version" "${define}RAG_FILE_VERSION=${version%%[-+]*}.0" "${define}RAG_UNINSTALL_FILES=$(nsis_path "$include")")
  if [[ -n "$helper" ]]; then command+=("${define}RAG_SIGN_HELPER=$helper" "${define}RAG_SIGNED_PLUGINS=$work/plugins"); fi
  MSYS2_ARG_CONV_EXCL='*' "${command[@]}" "$(nsis_path "$ROOT/packaging/windows/crexxrag.nsi")"
}
sign_file() {
  if osslsigncode verify -in "$1" >/dev/null 2>&1; then return; fi
  : "${PROVIDER:?Set PROVIDER}" "${CERTUM_ALIAS:?Set CERTUM_ALIAS}"
  jsign --storetype PKCS11 --keystore "$PROVIDER" --alias "$CERTUM_ALIAS" --alg SHA-256 --tsaurl "${TSA_URL:-http://time.certum.pl}" "$1"
  osslsigncode verify -in "$1" >/dev/null
}
sign_payload() {
  local prefix="$1" file magic
  while IFS= read -r -d '' file; do
    magic="$(od -An -tx1 -N2 "$file" | tr -d ' \n')"
    if [[ "$magic" == 4d5a || "$file" == *.ps1 ]]; then sign_file "$file"; fi
  done < <(find "$prefix" -type f -print0)
  provider "$prefix/bin" refresh
}
check_source() {
  local meta="$1" repo="$2" tag="$3"
  [[ "$tag" == "v$(jq -r .version "$meta")" ]] || fail 'Release tag differs from payload version'
  [[ "$(gh api "repos/$repo/commits/$tag" --jq .sha)" == "$(jq -r .source_commit "$meta")" ]] || fail 'Release tag differs from payload source'
}
windows_upload() {
  local output="$1" repo="$2" tag="$3" work="$4" prefix="$4/upload-payload" stem unsigned file checksum release current release_id name id
  local archives=("$output"/*-windows-x64-signed.zip) assets=()
  ((${#archives[@]}==1)) && [[ -f "${archives[0]}" ]] || fail 'Expected exactly one signed Windows ZIP'
  unpack "${archives[0]}" "$prefix"
  jq -e '.product=="crexxrag" and .platform=="windows-x64" and .signing=="signed"' "$prefix/release.json" >/dev/null || fail 'Expected signed RAG Windows ZIP'
  check_source "$prefix/release.json" "$repo" "$tag"
  stem="crexxrag-$(jq -r .version "$prefix/release.json")-windows-x64-signed"
  unsigned="${stem%-signed}-unsigned"
  [[ "$(basename "${archives[0]}")" == "$stem.zip" ]] || fail 'Signed ZIP filename differs from inventory'
  assets=("$stem-setup.exe" "$stem.zip" "$stem-setup.exe.sha256" "$stem.zip.sha256")
  for file in "$stem-setup.exe" "$stem.zip"; do
    checksum="$(cat "$output/$file.sha256")"
    [[ "$checksum" == "$(digest "$output/$file")  $file" ]] || fail "Signed checksum differs: $file"
  done
  release="$(gh api "repos/$repo/releases/tags/$tag")"; release_id="$(jq -r .id <<< "$release")"
  for name in "${assets[@]}"; do
    if ! jq -e --arg name "$name" '.assets|any(.name==$name)' <<< "$release" >/dev/null; then gh release upload "$tag" "$output/$name" --repo "$repo"; fi
  done
  # Confirm the uploaded names before deleting matching unsigned downloads.
  check_source "$prefix/release.json" "$repo" "$tag"
  current="$(gh api "repos/$repo/releases/tags/$tag")"
  [[ "$(jq -r .id <<< "$current")" == "$release_id" ]] || fail 'Release changed during upload'
  for name in "${assets[@]}"; do jq -e --arg name "$name" '.assets|any(.name==$name)' <<< "$current" >/dev/null || fail "Uploaded file missing: $name"; done
  for name in "$unsigned-setup.exe" "$unsigned.zip" "$unsigned-setup.exe.sha256" "$unsigned.zip.sha256"; do
    id="$(jq -r --arg name "$name" '.assets[]|select(.name==$name)|.id' <<< "$current")"
    [[ -z "$id" ]] || gh api --method DELETE "repos/$repo/releases/assets/$id"
  done
  current="$(gh api "repos/$repo/releases/tags/$tag")"
  for name in "${assets[@]}"; do jq -e --arg name "$name" '.assets|any(.name==$name)' <<< "$current" >/dev/null || fail "Signed file missing: $name"; done
  for name in "$unsigned-setup.exe" "$unsigned.zip" "$unsigned-setup.exe.sha256" "$unsigned.zip.sha256"; do
    jq -e --arg name "$name" '.assets|all(.name!=$name)' <<< "$current" >/dev/null || fail "Unsigned file still present: $name"
  done
  echo 'Signed Windows files present; matching unsigned files removed.'
}
operation="${1:-}"; shift || true
case "$operation" in
  work) mktemp -d "${TMPDIR:-/tmp}/rag-release.XXXXXX";;
  cleanup) [[ ! -f "$1/signing.keychain-db" ]] || security delete-keychain "$1/signing.keychain-db"; rm -rf "$1";;
  prepare) mkdir -p "$2" "$4"; cp -R "$1/." "$2/"; if [[ "$3" == windows-x64 ]]; then mkdir -p "$2/share/crexxrag/installer"; cp "$ROOT/packaging/windows/update-user-path.ps1" "$2/share/crexxrag/installer/"; fi; provider "$2/bin";;
  metadata) jq -r '.version,.source_commit,.crexx_commit,.platform,.signing' "$1/release.json";;
  identity) jq -e --arg platform "$2" --arg state "$3" '.product=="crexxrag" and .platform==$platform and .signing==$state' "$1/release.json" >/dev/null;;
  signed-zip) shopt -s nullglob; matches=("$1"/*-windows-x64-signed.zip); ((${#matches[@]}==1)) || fail 'Expected one signed ZIP'; printf '%s\n' "${matches[0]}";;
  sign-helper) printf '#!/usr/bin/env bash\nexec bash %q sign-file "$@"\n' "$ROOT/scripts/release/host-tools.sh" > "$1/sign-helper.sh"; chmod 700 "$1/sign-helper.sh";;
  sign-file) if [[ "${1:-}" == --nsis-plugins ]]; then mkdir -p "$3"; for name in System.dll nsExec.dll; do cp "$2/$name" "$3/$name"; sign_file "$3/$name"; done; else sign_file "$1"; fi;;
  absolute|provider|inventory|verify|unpack|checksums|apple_state|apple_sign|macos_installer|windows_installer|sign_payload|check_source|windows_upload|archive_payload) "$operation" "$@";;
  *) fail "Unknown host operation: $operation";;
esac
