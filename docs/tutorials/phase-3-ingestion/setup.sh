#!/bin/sh

set -eu

usage() {
  printf '%s\n' "usage: $0 [--no-build] [--google] [WORK_DIR]" >&2
}

build=1
provider=codex
work_arg=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-build) build=0 ;;
    --google) provider=google ;;
    -h|--help) usage; exit 0 ;;
    -*) usage; exit 2 ;;
    *)
      if [ -n "$work_arg" ]; then usage; exit 2; fi
      work_arg=$1
      ;;
  esac
  shift
done

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../../.." && pwd)

if [ -n "$work_arg" ]; then
  work_dir=$work_arg
  if [ -e "$work_dir" ]; then
    printf 'setup refused: work directory already exists: %s\n' "$work_dir" >&2
    exit 2
  fi
  mkdir -p "$work_dir"
  work_dir=$(CDPATH= cd -- "$work_dir" && pwd)
else
  work_dir=$(mktemp -d "${TMPDIR:-/tmp}/crexxrag-phase3.XXXXXX")
fi

if [ "$build" -eq 1 ]; then
  printf '%s\n' '+ cmake --preset debug' >&2
  (cd "$repo_root" && cmake --preset debug) 1>&2
  printf '%s\n' '+ cmake --build --preset debug --target crexx_rag_native_attempt' >&2
  (cd "$repo_root" && cmake --build --preset debug --target crexx_rag_native_attempt) 1>&2
fi

crexxrag=${CPRAG_CREXXRAG:-"$repo_root/cmake-build-debug/crexx-native-attempt/package/crexxrag"}
if [ ! -x "$crexxrag" ]; then
  printf 'setup failed: native crexxrag is unavailable: %s\n' "$crexxrag" >&2
  exit 3
fi

mkdir -p "$work_dir/source-docs"
if [ "$provider" = codex ]; then
  cp "$script_dir/crexx-rag.conf" "$work_dir/crexx-rag.conf"
else
  cp "$script_dir/google-gemini.conf" "$work_dir/crexx-rag.conf"
fi
cp "$script_dir/source-docs/architecture.txt" "$work_dir/source-docs/architecture.txt"
cp "$crexxrag" "$work_dir/crexxrag"
cp "$repo_root/scripts/stop_local_llama_servers.sh" "$work_dir/stop-local-embedding.sh"

if [ "$provider" = codex ]; then
  if ! command -v llama-server >/dev/null 2>&1; then
    printf '%s\n' 'setup failed: llama-server is required; run scripts/setup_llama_cpp_embedder.sh --install' >&2
    exit 3
  fi
  printf '%s\n' '+ starting the local Nomic llama.cpp embedding server' >&2
  CPRAG_LLAMA_STATE_DIR="$work_dir/.llama-servers" CPRAG_LLAMA_START_MODE=fork \
    "$repo_root/scripts/start_local_llama_servers.sh" --embedding-only 1>&2
  ready=0
  attempt=0
  while [ "$attempt" -lt 30 ]; do
    if CPRAG_LLAMA_STATE_DIR="$work_dir/.llama-servers" \
        "$repo_root/scripts/status_local_llama_servers.sh" --smoke --require embedding >/dev/null 2>&1; then
      ready=1
      break
    fi
    attempt=$((attempt + 1))
    sleep 1
  done
  if [ "$ready" -ne 1 ]; then
    printf 'setup failed: local embedding server did not become ready; inspect %s\n' "$work_dir/.llama-servers/embedding.log" >&2
    exit 3
  fi
fi

printf 'Tutorial workspace created: %s\n' "$work_dir" >&2
printf 'Provider route: %s\n' "$provider" >&2
printf 'Next:\n' >&2
printf '  cd %s\n' "$work_dir" >&2
if [ "$provider" = google ]; then
  printf "  export GEMINI_API_KEY='<Google AI Studio key>'\n" >&2
fi
printf '  ./crexxrag provider status\n' >&2
printf '  ./crexxrag init\n' >&2
printf '  ./crexxrag ingest\n' >&2
printf '  ./crexxrag query "What does BillingService depend on?"\n' >&2
if [ "$provider" = codex ]; then
  printf '  CPRAG_LLAMA_STATE_DIR=.llama-servers ./stop-local-embedding.sh\n' >&2
fi

# Stdout contains only the path so command substitution is safe.
printf '%s\n' "$work_dir"
