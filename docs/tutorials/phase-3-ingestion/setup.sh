#!/bin/sh

set -eu

usage() {
  printf '%s\n' "usage: $0 [--no-build] [WORK_DIR]" >&2
}

build=1
if [ "${1:-}" = "--no-build" ]; then
  build=0
  shift
fi
if [ "$#" -gt 1 ]; then
  usage
  exit 2
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../../.." && pwd)

if [ "$#" -eq 1 ]; then
  work_dir=$1
  if [ -e "$work_dir" ]; then
    printf 'setup refused: work directory already exists: %s\n' "$work_dir" >&2
    exit 2
  fi
  mkdir -p "$work_dir"
  work_dir=$(CDPATH= cd -- "$work_dir" && pwd)
else
  work_dir=$(mktemp -d "${TMPDIR:-/tmp}/crexx-rag-phase3.XXXXXX")
fi

if [ "$build" -eq 1 ]; then
  printf '%s\n' '+ cmake --preset debug' >&2
  (cd "$repo_root" && cmake --preset debug) 1>&2
  printf '%s\n' '+ cmake --build --preset debug --target crexx_rag_native_attempt' >&2
  (cd "$repo_root" && cmake --build --preset debug --target crexx_rag_native_attempt) 1>&2
fi

crexx_rag="$repo_root/cmake-build-debug/crexx-native-attempt/package/crexx-rag"
if [ ! -x "$crexx_rag" ]; then
  printf 'setup failed: native crexx-rag is unavailable: %s\n' "$crexx_rag" >&2
  exit 3
fi

mkdir -p "$work_dir/source-docs"
cp "$script_dir/crexx-rag.conf" "$work_dir/crexx-rag.conf"
cp "$script_dir/source-docs/architecture.txt" "$work_dir/source-docs/architecture.txt"
cp "$crexx_rag" "$work_dir/crexx-rag"

printf 'Tutorial workspace created: %s\n' "$work_dir" >&2
printf 'Next:\n' >&2
printf '  cd %s\n' "$work_dir" >&2
printf "  export GEMINI_API_KEY='<Google AI Studio key>'\n" >&2
printf '  ./crexx-rag init\n' >&2
printf '  ./crexx-rag ingest\n' >&2
printf '  ./crexx-rag query "What does BillingService depend on?"\n' >&2

# Stdout contains only the path so command substitution is safe.
printf '%s\n' "$work_dir"
