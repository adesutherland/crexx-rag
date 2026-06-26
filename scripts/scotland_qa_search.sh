#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/scotland_qa_search.sh [--top-k N] [--hops N] <question>

Runs a source-bound Scotland corpus search bundle for QA sessions.
It prints JSON with lexical/graph evidence and, when the local Nomic
embedding server is reachable, direct FAISS vector evidence.

The script intentionally hides build/library paths from the prompt layer.
USAGE
}

top_k=8
hops=2

while (($#)); do
  case "$1" in
    --top-k)
      if (($# < 2)); then
        echo "scotland_qa_search: --top-k requires a value" >&2
        exit 2
      fi
      top_k="$2"
      shift 2
      ;;
    --hops)
      if (($# < 2)); then
        echo "scotland_qa_search: --hops requires a value" >&2
        exit 2
      fi
      hops="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "scotland_qa_search: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

if (($# == 0)); then
  echo "scotland_qa_search: question is required" >&2
  usage >&2
  exit 2
fi

question="$*"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "${script_dir}/.." && pwd)"

bin="${CPRAG_SCOTLAND_QA_BIN:-${repo_dir}/cmake-build-faiss/crexx-rag}"
library="${CPRAG_SCOTLAND_QA_LIBRARY:-${repo_dir}/cmake-build-debug/scotland-combined-stage2.cprag}"
embedding_model="${CPRAG_SCOTLAND_QA_EMBEDDING_MODEL:-nomic-embed-text-v1.5}"

if [[ ! -x "${bin}" ]]; then
  echo "scotland_qa_search: FAISS-enabled crexx-rag binary not found: ${bin}" >&2
  exit 1
fi

if [[ ! -d "${library}" ]]; then
  echo "scotland_qa_search: Scotland corpus library not found: ${library}" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "scotland_qa_search: jq is required for evidence bundling" >&2
  exit 1
fi

lexical_json="$("${bin}" search "${library}" "${question}" "${top_k}" "${hops}")"
vector_status_json="$("${bin}" vector-status "${library}")"

vector_json='null'
vector_error=''
if "${bin}" embed-llama-server --role query "${question}" "${embedding_model}" >/tmp/scotland_qa_vector_$$.json 2>/tmp/scotland_qa_vector_$$.err; then
  query_vector="$(jq -r '.embedding | join(",")' "/tmp/scotland_qa_vector_$$.json")"
  if [[ -n "${query_vector}" && "${query_vector}" != "null" ]]; then
    if "${bin}" vector-search "${library}" "${embedding_model}" "${query_vector}" "${top_k}" >/tmp/scotland_qa_vector_search_$$.json 2>/tmp/scotland_qa_vector_search_$$.err; then
      vector_json="$(cat "/tmp/scotland_qa_vector_search_$$.json")"
    else
      vector_error="$(cat "/tmp/scotland_qa_vector_search_$$.err")"
    fi
  else
    vector_error="query embedding did not contain an embedding array"
  fi
else
  vector_error="$(cat "/tmp/scotland_qa_vector_$$.err")"
fi
rm -f "/tmp/scotland_qa_vector_$$.json" "/tmp/scotland_qa_vector_$$.err" \
      "/tmp/scotland_qa_vector_search_$$.json" "/tmp/scotland_qa_vector_search_$$.err"

jq -n \
  --arg question "${question}" \
  --arg corpus "scotland-combined-stage2" \
  --arg embedding_model "${embedding_model}" \
  --arg vector_error "${vector_error}" \
  --argjson lexical "${lexical_json}" \
  --argjson vector_status "${vector_status_json}" \
  --argjson vector "${vector_json}" \
  '{
    corpus: $corpus,
    question: $question,
    policy: {
      source_bound: true,
      outside_knowledge_allowed: false,
      answer_should_cite_chunks_or_graph_paths: true
    },
    lexical_graph: {
      success: $lexical.success,
      anchors: ($lexical.anchors // []),
      chunks: ($lexical.chunks // []),
      subgraph: ($lexical.subgraph // {nodes: [], edges: []})
    },
    vector: {
      embedding_model: $embedding_model,
      index_status: $vector_status,
      success: (($vector != null) and ($vector.success == true)),
      error: (if $vector_error == "" then null else $vector_error end),
      results: (if $vector == null then [] else ($vector.results // []) end)
    }
  }'
