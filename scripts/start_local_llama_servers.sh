#!/usr/bin/env bash
set -euo pipefail

state_dir="${CPRAG_LLAMA_STATE_DIR:-.local/llama-servers}"
mkdir -p "${state_dir}"
state_dir="$(cd "${state_dir}" && pwd)"

start_mode="${CPRAG_LLAMA_START_MODE:-}"
if [[ -z "${start_mode}" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]] && command -v launchctl >/dev/null 2>&1; then
    start_mode="launchctl"
  else
    start_mode="fork"
  fi
fi

embedding_model="${CPRAG_EMBEDDING_MODEL_REF:-nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M}"
embedding_host="${CPRAG_EMBEDDING_HOST:-127.0.0.1}"
embedding_port="${CPRAG_EMBEDDING_PORT:-8081}"
embedding_ctx="${CPRAG_EMBEDDING_CTX_SIZE:-2048}"
embedding_batch="${CPRAG_EMBEDDING_BATCH_SIZE:-2048}"
embedding_ubatch="${CPRAG_EMBEDDING_UBATCH_SIZE:-1024}"
embedding_parallel="${CPRAG_EMBEDDING_PARALLEL:-1}"
embedding_cache_ram="${CPRAG_EMBEDDING_CACHE_RAM:-0}"

chat_model="${CPRAG_CHAT_MODEL_REF:-ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M}"
chat_host="${CPRAG_CHAT_HOST:-127.0.0.1}"
chat_port="${CPRAG_CHAT_PORT:-8080}"
chat_ctx="${CPRAG_CHAT_CTX_SIZE:-2048}"
chat_parallel="${CPRAG_CHAT_PARALLEL:-1}"
chat_cache_ram="${CPRAG_CHAT_CACHE_RAM:-0}"

advisor_model="${CPRAG_ADVISOR_MODEL_REF:-Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M}"
advisor_host="${CPRAG_ADVISOR_HOST:-127.0.0.1}"
advisor_port="${CPRAG_ADVISOR_PORT:-8084}"
advisor_ctx="${CPRAG_ADVISOR_CTX_SIZE:-2048}"
advisor_parallel="${CPRAG_ADVISOR_PARALLEL:-1}"
advisor_cache_ram="${CPRAG_ADVISOR_CACHE_RAM:-0}"

start_embedding=1
start_chat=1
start_advisor=1

usage() {
  cat <<'USAGE'
Usage: scripts/start_local_llama_servers.sh [--embedding-only|--chat-only|--advisor-only]

Starts local llama.cpp servers in the background:
  - embeddings: Nomic on 127.0.0.1:8081
  - chat: Gemma on 127.0.0.1:8080
  - advisor: Qwen on 127.0.0.1:8084

Environment overrides:
  CPRAG_LLAMA_STATE_DIR       PID/log directory, default .local/llama-servers
  CPRAG_LLAMA_START_MODE      launchctl or fork; default launchctl on macOS
  CPRAG_EMBEDDING_MODEL_REF   default nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M
  CPRAG_EMBEDDING_HOST        default 127.0.0.1
  CPRAG_EMBEDDING_PORT        default 8081
  CPRAG_EMBEDDING_CTX_SIZE    default 2048
  CPRAG_EMBEDDING_BATCH_SIZE  default 2048
  CPRAG_EMBEDDING_UBATCH_SIZE default 1024
  CPRAG_EMBEDDING_PARALLEL    default 1
  CPRAG_EMBEDDING_CACHE_RAM   default 0
  CPRAG_CHAT_MODEL_REF        default ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M
  CPRAG_CHAT_HOST             default 127.0.0.1
  CPRAG_CHAT_PORT             default 8080
  CPRAG_CHAT_CTX_SIZE         default 2048
  CPRAG_CHAT_PARALLEL         default 1
  CPRAG_CHAT_CACHE_RAM        default 0
  CPRAG_ADVISOR_MODEL_REF     default Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M
  CPRAG_ADVISOR_HOST          default 127.0.0.1
  CPRAG_ADVISOR_PORT          default 8084
  CPRAG_ADVISOR_CTX_SIZE      default 2048
  CPRAG_ADVISOR_PARALLEL      default 1
  CPRAG_ADVISOR_CACHE_RAM     default 0
USAGE
}

while (($#)); do
  case "$1" in
    --embedding-only)
      start_chat=0
      start_advisor=0
      ;;
    --chat-only)
      start_embedding=0
      start_advisor=0
      ;;
    --advisor-only)
      start_embedding=0
      start_chat=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! command -v llama-server >/dev/null 2>&1; then
  echo "llama-server not found on PATH" >&2
  exit 1
fi

port_in_use() {
  local port="$1"
  lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1
}

shell_quote() {
  printf '%q' "$1"
}

start_server() {
  local name="$1"
  local pid_file="$2"
  local log_file="$3"
  local label_file="${pid_file%.pid}.label"
  local label_suffix
  label_suffix="$(basename "${pid_file}" .pid)"
  local label="local.crexx-rag.${label_suffix}"
  shift 3

  if [[ -f "${pid_file}" ]] && kill -0 "$(cat "${pid_file}")" >/dev/null 2>&1; then
    echo "${name} already running with pid $(cat "${pid_file}")"
    return
  fi

  echo "starting ${name}; mode=${start_mode}; log: ${log_file}"
  if [[ "${start_mode}" == "launchctl" ]]; then
    local program="$1"
    if [[ "${program}" != */* ]]; then
      program="$(command -v "${program}")"
    fi
    shift
    local shell_command="exec tail -f /dev/null | $(shell_quote "${program}")"
    local arg
    for arg in "$@"; do
      shell_command="${shell_command} $(shell_quote "${arg}")"
    done
    launchctl remove "${label}" >/dev/null 2>&1 || true
    launchctl submit -l "${label}" -o "${log_file}" -e "${log_file}" -- /bin/sh -c "${shell_command}"
    echo "${label}" >"${label_file}"
    local launched_pid=""
    launched_pid="$(launchctl list "${label}" 2>/dev/null | awk -F' = ' '/"PID"/ {gsub(";", "", $2); print $2; exit}')"
    if [[ -n "${launched_pid}" ]]; then
      echo "${launched_pid}" >"${pid_file}"
    else
      rm -f "${pid_file}"
    fi
  else
    nohup "$@" >"${log_file}" 2>&1 </dev/null &
    echo $! >"${pid_file}"
    rm -f "${label_file}"
  fi
  sleep 1
  if [[ -f "${pid_file}" ]] && kill -0 "$(cat "${pid_file}")" >/dev/null 2>&1; then
    echo "${name} pid $(cat "${pid_file}")"
  else
    echo "${name} exited during startup; see ${log_file}" >&2
    exit 1
  fi
}

if [[ "${start_embedding}" -eq 1 ]]; then
  if port_in_use "${embedding_port}"; then
    echo "embedding port ${embedding_port} already has a listener"
  else
    start_server \
      "embedding llama-server" \
      "${state_dir}/embedding.pid" \
      "${state_dir}/embedding.log" \
      llama-server \
        -hf "${embedding_model}" \
        --embedding \
        --pooling mean \
        -c "${embedding_ctx}" \
        -np "${embedding_parallel}" \
        --cache-ram "${embedding_cache_ram}" \
        --batch-size "${embedding_batch}" \
        --ubatch-size "${embedding_ubatch}" \
        --host "${embedding_host}" \
        --port "${embedding_port}"
  fi
fi

if [[ "${start_chat}" -eq 1 ]]; then
  if port_in_use "${chat_port}"; then
    echo "chat port ${chat_port} already has a listener"
  else
    start_server \
      "chat llama-server" \
      "${state_dir}/chat.pid" \
      "${state_dir}/chat.log" \
      llama-server \
        -hf "${chat_model}" \
        -fit off \
        --no-mmproj \
        -c "${chat_ctx}" \
        -np "${chat_parallel}" \
        --cache-ram "${chat_cache_ram}" \
        --reasoning off \
        --host "${chat_host}" \
        --port "${chat_port}"
  fi
fi

if [[ "${start_advisor}" -eq 1 ]]; then
  if port_in_use "${advisor_port}"; then
    echo "advisor port ${advisor_port} already has a listener"
  else
    start_server \
      "advisor llama-server" \
      "${state_dir}/advisor.pid" \
      "${state_dir}/advisor.log" \
      llama-server \
        -hf "${advisor_model}" \
        -fit off \
        -c "${advisor_ctx}" \
        -np "${advisor_parallel}" \
        --cache-ram "${advisor_cache_ram}" \
        --reasoning off \
        --host "${advisor_host}" \
        --port "${advisor_port}"
  fi
fi

echo
echo "models cached by llama.cpp:"
llama-server --cache-list || true
