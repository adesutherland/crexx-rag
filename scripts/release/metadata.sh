#!/usr/bin/env bash
# Freeze product/dependency identities before platform SDK builds.
set -euo pipefail
base="$(sed -nE 's/.*VERSION[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' CMakeLists.txt | head -n1)"
[[ -n "$base" ]] || { echo 'CMake product version not found' >&2; exit 1; }
version="$base-dev.$GITHUB_RUN_NUMBER"
if [[ "$GITHUB_REF" == refs/tags/v* ]]; then version="${GITHUB_REF_NAME#v}"; fi
escaped="${base//./\\.}"
[[ "$version" =~ ^${escaped}([-+][A-Za-z0-9.-]+)?$ ]] || { echo 'Release tag must match the CMake product version' >&2; exit 1; }
crexx="$(tr -d '\r\n' < .github/crexx-revision.txt)"
[[ "$crexx" =~ ^[0-9a-f]{40}$ ]] || { echo 'CREXX dependency must use a full commit' >&2; exit 1; }
commit="$(git rev-parse HEAD)"
printf 'version=%s\ncommit=%s\ncrexx=%s\n' "$version" "$commit" "$crexx" >> "$GITHUB_OUTPUT"
