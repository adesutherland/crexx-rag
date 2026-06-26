#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/run_use_case.sh list
  scripts/run_use_case.sh initial-load [pipeline args...]
  scripts/run_use_case.sh add-documents [pipeline args...]
  scripts/run_use_case.sh background-improve [background args...]
  scripts/run_use_case.sh search --library PATH --query TEXT [--top-k N] [--hops N] [--bin PATH]
  scripts/run_use_case.sh qa-evidence --library PATH --question TEXT [--top-k N] [--hops N] [--mode auto|lexical|vector|hybrid] [--mcp PATH]

Use cases:
  initial-load       Ingest/chunk, Stage 1, Stage 1b, Stage 2, Stage 2b, Stage 3, status.
  add-documents      Ingest/chunk new source, census/adjudicate deltas, seed graph, rank queue, status.
  background-improve Re-run bounded Stage 2b/Stage 3 improvement cycles through the worker.
  search             Human CLI lexical/graph search.
  qa-evidence        MCP LLM-ready source-bound evidence bundle.

This wrapper is intentionally thin. Pipeline mechanics live in the staged CREXX
controllers and native core; this script names common operator workflows.
USAGE
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "${script_dir}/.." && pwd)"

if (($# == 0)); then
  usage >&2
  exit 2
fi

use_case="$1"
shift

run_pipeline() {
  "${script_dir}/run_history_pipeline.sh" "$@"
}

case "${use_case}" in
  list)
    usage
    ;;
  initial-load)
    run_pipeline \
      --stages "${CPRAG_INITIAL_LOAD_STAGES:-stage1,stage1b,stage2,stage2b,stage3,status}" \
      "$@"
    ;;
  add-documents)
    run_pipeline \
      --stages "${CPRAG_ADD_DOCUMENTS_STAGES:-stage1,stage1b,stage2,stage2b,status}" \
      "$@"
    ;;
  background-improve)
    "${script_dir}/run_background_improvement.sh" "$@"
    ;;
  search)
    library=""
    query=""
    top_k=8
    hops=2
    bin="${CPRAG_CLI:-${repo_dir}/cmake-build-debug/crexx-rag}"
    while (($#)); do
      case "$1" in
        --library)
          library="${2:-}"
          shift 2
          ;;
        --query)
          query="${2:-}"
          shift 2
          ;;
        --top-k)
          top_k="${2:-}"
          shift 2
          ;;
        --hops)
          hops="${2:-}"
          shift 2
          ;;
        --bin)
          bin="${2:-}"
          shift 2
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          echo "run_use_case search: unexpected argument: $1" >&2
          usage >&2
          exit 2
          ;;
      esac
    done
    if [[ -z "${library}" || -z "${query}" ]]; then
      echo "run_use_case search: --library and --query are required" >&2
      usage >&2
      exit 2
    fi
    "${bin}" search "${library}" "${query}" "${top_k}" "${hops}"
    ;;
  qa-evidence)
    library=""
    question=""
    top_k=8
    hops=2
    mode="auto"
    mcp="${CPRAG_MCP:-${repo_dir}/cmake-build-debug/crexx-rag-mcp}"
    while (($#)); do
      case "$1" in
        --library)
          library="${2:-}"
          shift 2
          ;;
        --question)
          question="${2:-}"
          shift 2
          ;;
        --top-k)
          top_k="${2:-}"
          shift 2
          ;;
        --hops)
          hops="${2:-}"
          shift 2
          ;;
        --mode)
          mode="${2:-}"
          shift 2
          ;;
        --mcp)
          mcp="${2:-}"
          shift 2
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          echo "run_use_case qa-evidence: unexpected argument: $1" >&2
          usage >&2
          exit 2
          ;;
      esac
    done
    if [[ -z "${library}" || -z "${question}" ]]; then
      echo "run_use_case qa-evidence: --library and --question are required" >&2
      usage >&2
      exit 2
    fi
    printf '{"jsonrpc":"2.0","id":"qa","method":"tools/call","params":{"name":"library_answer_evidence","arguments":{"question":%s,"top_k":%s,"hops":%s,"mode":%s}}}\n' \
      "$(printf '%s' "${question}" | sed 's/\\/\\\\/g; s/"/\\"/g; s/^/"/; s/$/"/')" \
      "${top_k}" \
      "${hops}" \
      "$(printf '%s' "${mode}" | sed 's/\\/\\\\/g; s/"/\\"/g; s/^/"/; s/$/"/')" |
      "${mcp}" --library "${library}"
    ;;
  -h|--help)
    usage
    ;;
  *)
    echo "run_use_case: unknown use case: ${use_case}" >&2
    usage >&2
    exit 2
    ;;
esac
