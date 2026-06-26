#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "${script_dir}/.." && pwd)"

library="${CPRAG_HISTORY_LIBRARY:-${repo_dir}/cmake-build-debug/history-pipeline.cprag}"
profile="${CPRAG_HISTORY_PROFILE:-scotland}"
profile_id=""
graph_namespace=""
queue_id=""
stages="${CPRAG_HISTORY_STAGES:-stage1b,stage2,stage2b,status}"
mode="${CPRAG_HISTORY_MODE:-offline}"
source_file=""
source_uri=""
title=""
stage1_mode="${CPRAG_STAGE1_MODE:-auto}"
stage1_limit="${CPRAG_STAGE1_LIMIT:-0}"
stage1_chunk_limit="${CPRAG_STAGE1_CHUNK_LIMIT:-0}"
stage1b_min_count="${CPRAG_STAGE1B_MIN_COUNT:-5}"
stage1b_limit="${CPRAG_STAGE1B_LIMIT:-256}"
stage1b_batch_size="${CPRAG_STAGE1B_BATCH_SIZE:-8}"
stage2_page_size="${CPRAG_STAGE2_PAGE_SIZE:-512}"
stage2_limit_mentions="${CPRAG_STAGE2_LIMIT_MENTIONS:-0}"
stage2_after_id="${CPRAG_STAGE2_AFTER_ID:-0}"
stage2b_limit="${CPRAG_STAGE2B_LIMIT:-100}"
stage2b_preview="${CPRAG_STAGE2B_PREVIEW:-20}"
stage3_limit="${CPRAG_STAGE3_LIMIT:-10}"
stage3_mode="${CPRAG_STAGE3_MODE:-online}"
stage3_format="${CPRAG_STAGE3_FORMAT:-tagged}"
stage3_max_tokens="${CPRAG_STAGE3_MAX_TOKENS:-2048}"
embed_model="${CPRAG_EMBEDDING_MODEL:-nomic-embed-text-v1.5}"
embed_profile="${CPRAG_EMBEDDING_PROFILE:-semantic-context-v1}"
embed_source_uri="${CPRAG_EMBEDDING_SOURCE_URI:-}"
cli="${CPRAG_CLI:-${repo_dir}/cmake-build-debug/crexx-rag}"
faiss_cli="${CPRAG_FAISS_CLI:-${repo_dir}/cmake-build-faiss/crexx-rag}"
plugin_dir="${CPRAG_PLUGIN_DIR:-${repo_dir}/cmake-build-debug/bin}"
run_root="${CPRAG_HISTORY_RUN_ROOT:-${repo_dir}/.local/history-pipeline}"
run_id="${CPRAG_HISTORY_RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
advisor_base_url="${CPRAG_LLAMA_SERVER_ADVICE_BASE_URL:-http://127.0.0.1:8084/v1}"
advisor_model="${CPRAG_LLM_ADVICE_MODEL:-${CPRAG_ADVISOR_MODEL_REF:-Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M}}"
chat_base_url="${CPRAG_CHAT_BASE_URL:-http://127.0.0.1:8080/v1}"
chat_model="${CPRAG_CHAT_MODEL_REF:-ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M}"
require_models=1

usage() {
  cat <<'USAGE'
Usage: scripts/run_history_pipeline.sh [options]

Runs the history GraphRAG lifecycle through existing CREXX controllers.

Common options:
  --library PATH           Target .cprag library
  --profile NAME           generic, scotland, or athens; default scotland
  --stages CSV             stage1,embed,stage1b,stage2,stage2b,stage3,status
  --mode online|offline    Stage 1/1b mode; default offline
  --source-file PATH       Required when running stage1
  --source-uri URI         Source URI for stage1
  --title TITLE            Source title for stage1
  --queue-id ID            Queue id; default stage3-<profile>-default
  --cli PATH               Non-FAISS crexx-rag CLI, default cmake-build-debug/crexx-rag
  --faiss-cli PATH         FAISS-enabled CLI, default cmake-build-faiss/crexx-rag

Stage knobs:
  --stage1-mode auto|deterministic|llm
  --stage1-limit N         Stage 1 scan limit; 0 means all chunks
  --stage1b-limit N
  --stage1b-min-count N
  --stage1b-batch-size N
  --stage2-page-size N
  --stage2-limit-mentions N
  --stage2b-limit N
  --stage3-limit N
  --stage3-mode online|dry-run

Model checks:
  --no-require-models      Do not fail early if local model smokes fail

Examples:
  scripts/run_history_pipeline.sh --library ./scotland.cprag --stages status
  scripts/run_history_pipeline.sh --library ./scotland.cprag --stages stage2b,stage3,status --mode online --stage3-limit 100
USAGE
}

while (($#)); do
  case "$1" in
    --library) library="$2"; shift ;;
    --profile) profile="$2"; shift ;;
    --profile-id) profile_id="$2"; shift ;;
    --graph-namespace) graph_namespace="$2"; shift ;;
    --queue-id) queue_id="$2"; shift ;;
    --stages) stages="$2"; shift ;;
    --mode) mode="$2"; shift ;;
    --source-file) source_file="$2"; shift ;;
    --source-uri) source_uri="$2"; shift ;;
    --title) title="$2"; shift ;;
    --stage1-mode) stage1_mode="$2"; shift ;;
    --stage1-limit) stage1_limit="$2"; shift ;;
    --stage1-chunk-limit) stage1_chunk_limit="$2"; shift ;;
    --stage1b-min-count) stage1b_min_count="$2"; shift ;;
    --stage1b-limit) stage1b_limit="$2"; shift ;;
    --stage1b-batch-size) stage1b_batch_size="$2"; shift ;;
    --stage2-page-size) stage2_page_size="$2"; shift ;;
    --stage2-limit-mentions) stage2_limit_mentions="$2"; shift ;;
    --stage2-after-id) stage2_after_id="$2"; shift ;;
    --stage2b-limit) stage2b_limit="$2"; shift ;;
    --stage2b-preview) stage2b_preview="$2"; shift ;;
    --stage3-limit) stage3_limit="$2"; shift ;;
    --stage3-mode) stage3_mode="$2"; shift ;;
    --stage3-format) stage3_format="$2"; shift ;;
    --stage3-max-tokens) stage3_max_tokens="$2"; shift ;;
    --embed-model) embed_model="$2"; shift ;;
    --embed-profile) embed_profile="$2"; shift ;;
    --embed-source-uri) embed_source_uri="$2"; shift ;;
    --cli) cli="$2"; shift ;;
    --faiss-cli) faiss_cli="$2"; shift ;;
    --plugin-dir) plugin_dir="$2"; shift ;;
    --run-root) run_root="$2"; shift ;;
    --run-id) run_id="$2"; shift ;;
    --advisor-base-url) advisor_base_url="$2"; shift ;;
    --advisor-model) advisor_model="$2"; shift ;;
    --chat-base-url) chat_base_url="$2"; shift ;;
    --chat-model) chat_model="$2"; shift ;;
    --no-require-models) require_models=0 ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "run_history_pipeline: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

case "${profile}" in
  generic|scotland|athens) ;;
  *)
    echo "run_history_pipeline: --profile must be generic, scotland, or athens for the current controllers" >&2
    exit 2
    ;;
esac
case "${mode}" in online|offline) ;; *) echo "run_history_pipeline: --mode must be online or offline" >&2; exit 2 ;; esac
case "${stage3_mode}" in online|dry-run) ;; *) echo "run_history_pipeline: --stage3-mode must be online or dry-run" >&2; exit 2 ;; esac

if [[ -z "${profile_id}" ]]; then
  if [[ "${profile}" == "generic" ]]; then
    profile_id="generic.hybrid.v1"
  else
    profile_id="history.${profile}.hybrid.v1"
  fi
fi
if [[ -z "${graph_namespace}" ]]; then
  if [[ "${profile}" == "generic" ]]; then
    graph_namespace="generic"
  else
    graph_namespace="history:${profile}"
  fi
fi
if [[ -z "${queue_id}" ]]; then
  queue_id="stage3-${profile}-default"
fi

has_stage() {
  case ",${stages}," in
    *,"$1",*) return 0 ;;
    *) return 1 ;;
  esac
}

need_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "run_history_pipeline: required command not found: $1" >&2
    exit 1
  fi
}

need_file() {
  if [[ ! -e "$1" ]]; then
    echo "run_history_pipeline: required path not found: $1" >&2
    exit 1
  fi
}

need_command rxc
need_command rxas
need_command rxvme
need_file "${plugin_dir}"

if has_stage embed; then
  need_file "${faiss_cli}"
fi
if has_stage stage1 || has_stage stage1b || has_stage stage3; then
  need_file "${cli}"
fi
if has_stage stage1 && [[ -z "${source_file}" ]]; then
  echo "run_history_pipeline: --source-file is required when stage1 is selected" >&2
  exit 2
fi

run_dir="${run_root}/${run_id}"
mkdir -p "${run_dir}"
log_file="${run_dir}/pipeline.log"
compile_dir="${run_dir}/compiled"
mkdir -p "${compile_dir}"

crexx_bin_dir="$(cd "$(dirname "$(command -v rxc)")" && pwd)"
import_path="${compile_dir};${plugin_dir};${crexx_bin_dir}"

compile_profile() {
  local source="$1"
  local name="$2"
  local output_base="${compile_dir}/${name}"
  rm -f "${output_base}.rxas" "${output_base}.rxbin"
  rxc -i "${import_path}" -o "${output_base}" "${source}" >&2
  rxas -o "${output_base}" "${output_base}" >&2
  printf '%s\n' "${output_base}"
}

run_logged() {
  echo
  echo "## $*"
  "$@"
}

run_crexx() {
  local compiled="$1"
  shift
  rxvme -l "${compile_dir};${plugin_dir}" "${compiled}" pipeline_profile rx_rag -a "$@"
}

history_types() {
  if [[ "${profile}" == "scotland" ]]; then
    printf '%s\n' "clan,person,place,event,office,military-unit,institution,polity,source-work"
  elif [[ "${profile}" == "athens" ]]; then
    printf '%s\n' "person,polity,place,institution,event,office,military-unit,source-work"
  else
    printf '%s\n' "service,data-object,component,person,place,institution,source-work"
  fi
}

check_models() {
  if [[ "${require_models}" -ne 1 ]]; then
    return
  fi
  local args=(--smoke)
  if has_stage embed; then args+=(--require embedding); fi
  if has_stage stage1 && [[ "${mode}" == "online" ]]; then args+=(--require advisor); fi
  if has_stage stage1b && [[ "${mode}" == "online" ]]; then args+=(--require advisor); fi
  if has_stage stage3 && [[ "${stage3_mode}" == "online" ]]; then args+=(--require chat); fi
  if ((${#args[@]} > 1)); then
    "${script_dir}/status_local_llama_servers.sh" "${args[@]}"
  fi
}

{
  echo "run_id=${run_id}"
  echo "library=${library}"
  echo "profile=${profile}"
  echo "profile_id=${profile_id}"
  echo "graph_namespace=${graph_namespace}"
  echo "queue_id=${queue_id}"
  echo "stages=${stages}"
  echo "mode=${mode}"
  echo "run_dir=${run_dir}"

  compile_profile "${repo_dir}/crexx/profiles/pipeline_profile.crexx" "pipeline_profile" >/dev/null

  check_models

  if has_stage stage1; then
    hybrid_profile="$(compile_profile "${repo_dir}/crexx/profiles/history/hybrid_ingest_extract.crexx" "hybrid_ingest_extract")"
    stage1_args=(
      --library "${library}"
      --profile "${profile}"
      --mode "${mode}"
      --source-file "${source_file}"
      --limit "${stage1_chunk_limit}"
      --stage1 "${stage1_mode}"
      --stage1-limit "${stage1_limit}"
      --stage3 off
      --cli "${cli}"
      --qwen-base-url "${advisor_base_url}"
      --qwen-model "${advisor_model}"
      --gemma-base-url "${chat_base_url}"
      --gemma-model "${chat_model}"
    )
    if [[ -n "${source_uri}" ]]; then stage1_args+=(--source-uri "${source_uri}"); fi
    if [[ -n "${title}" ]]; then stage1_args+=(--title "${title}"); fi
    run_logged run_crexx "${hybrid_profile}" "${stage1_args[@]}"
  fi

  if has_stage embed; then
    embed_args=("${library}" "${embed_model}" "llama-server")
    if [[ -n "${embed_source_uri}" ]]; then
      embed_args+=("${embed_source_uri}" "${embed_profile}")
    else
      embed_args+=("" "${embed_profile}")
    fi
    run_logged "${faiss_cli}" embed-chunks "${embed_args[@]}"
  fi

  if has_stage stage1b; then
    stage1b_profile="$(compile_profile "${repo_dir}/crexx/profiles/history/stage1b_adjudicate_candidates.crexx" "stage1b_adjudicate_candidates")"
    run_logged run_crexx "${stage1b_profile}" \
      --library "${library}" \
      --profile "${profile}" \
      --profile-id "${profile_id}" \
      --mode "${mode}" \
      --min-count "${stage1b_min_count}" \
      --limit "${stage1b_limit}" \
      --batch-size "${stage1b_batch_size}" \
      --cli "${cli}" \
      --base-url "${advisor_base_url}" \
      --model "${advisor_model}"
  fi

  if has_stage stage2; then
    stage2_profile="$(compile_profile "${repo_dir}/crexx/profiles/history/stage2_seed_graph.crexx" "stage2_seed_graph")"
    run_logged run_crexx "${stage2_profile}" \
      --library "${library}" \
      --profile "${profile}" \
      --profile-id "${profile_id}" \
      --graph-namespace "${graph_namespace}" \
      --status keep \
      --types "$(history_types)" \
      --min-count "${stage1b_min_count}" \
      --page-size "${stage2_page_size}" \
      --limit-mentions "${stage2_limit_mentions}" \
      --after-id "${stage2_after_id}"
  fi

  if has_stage stage2b; then
    stage2b_profile="$(compile_profile "${repo_dir}/crexx/profiles/history/stage2b_rank_queue.crexx" "stage2b_rank_queue")"
    run_logged run_crexx "${stage2b_profile}" \
      --library "${library}" \
      --profile "${profile}" \
      --profile-id "${profile_id}" \
      --queue-id "${queue_id}" \
      --graph-namespace "${graph_namespace}" \
      --types "$(history_types)" \
      --limit "${stage2b_limit}" \
      --preview "${stage2b_preview}"
  fi

  if has_stage stage3; then
    stage3_profile="$(compile_profile "${repo_dir}/crexx/profiles/history/stage3_extract_queue.crexx" "stage3_extract_queue")"
    run_logged run_crexx "${stage3_profile}" \
      --library "${library}" \
      --profile "${profile}" \
      --profile-id "${profile_id}" \
      --queue-id "${queue_id}" \
      --mode "${stage3_mode}" \
      --limit "${stage3_limit}" \
      --cli "${cli}" \
      --base-url "${chat_base_url}" \
      --model "${chat_model}" \
      --format "${stage3_format}" \
      --max-tokens "${stage3_max_tokens}"
  fi

  if has_stage status; then
    run_logged "${cli}" queue-status "${library}" "${profile_id}" "${queue_id}"
    run_logged "${cli}" vector-status "${library}" || true
    run_logged "${cli}" stats "${library}"
  fi
} 2>&1 | tee -a "${log_file}"

echo
echo "history pipeline log: ${log_file}"
