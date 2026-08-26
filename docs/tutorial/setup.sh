#!/bin/sh
set -eu

build=1
work_dir=
provider=gemini
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-build) build=0 ;;
    --provider)
      shift
      if [ "$#" -eq 0 ]; then echo "--provider requires gemini or codex-local" >&2; exit 2; fi
      provider=$1
      ;;
    -h|--help)
      echo "usage: $0 [--no-build] [--provider gemini|codex-local] [WORK_DIR]" >&2
      exit 0
      ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *)
      if [ -n "$work_dir" ]; then echo "one work directory may be supplied" >&2; exit 2; fi
      work_dir=$1
      ;;
  esac
  shift
done

case "$provider" in
  gemini) config_name=crexxrag.conf ;;
  codex-local) config_name=crexxrag-codex-local.conf ;;
  *) echo "unknown provider setup: $provider" >&2; exit 2 ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)
build_dir=${CREXXRAG_TUTORIAL_BUILD_DIR:-"$repo_root/cmake-build-debug"}

if [ "$build" -eq 1 ]; then
  cmake --preset debug -S "$repo_root"
  cmake --build "$build_dir" --target crexxrag_native
fi

binary=${CREXXRAG_EXECUTABLE:-"$build_dir/crexxrag-native/package/crexxrag"}
if [ ! -x "$binary" ]; then
  echo "crexxrag is unavailable: $binary" >&2
  exit 3
fi

if [ -z "$work_dir" ]; then
  work_dir=$(mktemp -d "${TMPDIR:-/tmp}/crexxrag-tutorial.XXXXXX")
else
  if [ -e "$work_dir" ]; then echo "work directory already exists: $work_dir" >&2; exit 2; fi
  mkdir -p "$work_dir"
  work_dir=$(CDPATH= cd -- "$work_dir" && pwd)
fi

mkdir -p "$work_dir/source-docs"
cp "$binary" "$work_dir/crexxrag"
cp "$script_dir/$config_name" "$work_dir/crexxrag.conf"
cp "$script_dir/architecture.glossary.tsv" "$work_dir/architecture.glossary.tsv"
cp "$script_dir/source-docs/architecture.txt" "$work_dir/source-docs/architecture.txt"

echo "Tutorial workspace: $work_dir" >&2
if [ "$provider" = gemini ]; then
  echo "Next: cd '$work_dir'; export GEMINI_API_KEY='<key>'; ./crexxrag init; ./crexxrag ingest" >&2
else
  echo "Next: start local embeddings, then cd '$work_dir'; ./crexxrag provider login codex; ./crexxrag init; ./crexxrag ingest" >&2
fi
printf '%s\n' "$work_dir"
