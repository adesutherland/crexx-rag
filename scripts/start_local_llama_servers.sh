#!/usr/bin/env bash
set -euo pipefail

state_dir="${CPRAG_LLAMA_STATE_DIR:-.local/llama-servers}"
mkdir -p "${state_dir}"

embedding_model="${CPRAG_EMBEDDING_MODEL_REF:-nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M}"
embedding_host="${CPRAG_EMBEDDING_HOST:-127.0.0.1}"
embedding_port="${CPRAG_EMBEDDING_PORT:-8081}"
embedding_ctx="${CPRAG_EMBEDDING_CTX_SIZE:-2048}"

chat_model="${CPRAG_CHAT_MODEL_REF:-ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M}"
chat_host="${CPRAG_CHAT_HOST:-127.0.0.1}"
chat_port="${CPRAG_CHAT_PORT:-8080}"
chat_ctx="${CPRAG_CHAT_CTX_SIZE:-8192}"

start_embedding=1
start_chat=1

usage() {
  cat <<'USAGE'
Usage: scripts/start_local_llama_servers.sh [--embedding-only|--chat-only]

Starts local llama.cpp servers in the background:
  - embeddings: Nomic on 127.0.0.1:8081
  - chat: Gemma on 127.0.0.1:8080

Environment overrides:
  CPRAG_LLAMA_STATE_DIR       PID/log directory, default .local/llama-servers
  CPRAG_EMBEDDING_MODEL_REF   default nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M
  CPRAG_EMBEDDING_HOST        default 127.0.0.1
  CPRAG_EMBEDDING_PORT        default 8081
  CPRAG_EMBEDDING_CTX_SIZE    default 2048
  CPRAG_CHAT_MODEL_REF        default ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M
  CPRAG_CHAT_HOST             default 127.0.0.1
  CPRAG_CHAT_PORT             default 8080
  CPRAG_CHAT_CTX_SIZE         default 8192
USAGE
}

while (($#)); do
  case "$1" in
    --embedding-only)
      start_chat=0
      ;;
    --chat-only)
      start_embedding=0
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

start_server() {
  local name="$1"
  local pid_file="$2"
  local log_file="$3"
  shift 3

  if [[ -f "${pid_file}" ]] && kill -0 "$(cat "${pid_file}")" >/dev/null 2>&1; then
    echo "${name} already running with pid $(cat "${pid_file}")"
    return
  fi

  echo "starting ${name}; log: ${log_file}"
  nohup "$@" >"${log_file}" 2>&1 &
  echo $! >"${pid_file}"
  sleep 1
  if kill -0 "$(cat "${pid_file}")" >/dev/null 2>&1; then
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
        -c "${chat_ctx}" \
        --host "${chat_host}" \
        --port "${chat_port}"
  fi
fi

echo
echo "models cached by llama.cpp:"
llama-server --cache-list || true
