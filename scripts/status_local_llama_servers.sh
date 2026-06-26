#!/usr/bin/env bash
set -euo pipefail

state_dir="${CPRAG_LLAMA_STATE_DIR:-.local/llama-servers}"
if [[ -d "${state_dir}" ]]; then
  state_dir="$(cd "${state_dir}" && pwd)"
fi

embedding_host="${CPRAG_EMBEDDING_HOST:-127.0.0.1}"
embedding_port="${CPRAG_EMBEDDING_PORT:-8081}"
embedding_base_url="${CPRAG_LLAMA_SERVER_BASE_URL:-http://${embedding_host}:${embedding_port}/v1}"
embedding_model="${CPRAG_EMBEDDING_MODEL:-nomic-embed-text-v1.5}"

chat_host="${CPRAG_CHAT_HOST:-127.0.0.1}"
chat_port="${CPRAG_CHAT_PORT:-8080}"
chat_base_url="${CPRAG_CHAT_BASE_URL:-http://${chat_host}:${chat_port}/v1}"
chat_model="${CPRAG_CHAT_MODEL_REF:-ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M}"

advisor_host="${CPRAG_ADVISOR_HOST:-127.0.0.1}"
advisor_port="${CPRAG_ADVISOR_PORT:-8084}"
advisor_base_url="${CPRAG_LLAMA_SERVER_ADVICE_BASE_URL:-http://${advisor_host}:${advisor_port}/v1}"
advisor_model="${CPRAG_LLM_ADVICE_MODEL:-${CPRAG_ADVISOR_MODEL_REF:-Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M}}"

smoke=0
required=""

usage() {
  cat <<'USAGE'
Usage: scripts/status_local_llama_servers.sh [--smoke] [--require NAME]

Checks local llama.cpp servers used by crexx-rag.

Names for --require:
  embedding
  chat
  advisor

Examples:
  scripts/status_local_llama_servers.sh
  scripts/status_local_llama_servers.sh --smoke --require embedding --require chat
USAGE
}

append_required() {
  if [[ -z "${required}" ]]; then
    required="$1"
  else
    required="${required},$1"
  fi
}

while (($#)); do
  case "$1" in
    --smoke)
      smoke=1
      ;;
    --require)
      if (($# < 2)); then
        echo "status_local_llama_servers: --require needs a value" >&2
        exit 2
      fi
      case "$2" in
        embedding|chat|advisor) append_required "$2" ;;
        *)
          echo "status_local_llama_servers: unknown service for --require: $2" >&2
          exit 2
          ;;
      esac
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "status_local_llama_servers: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

pid_alive() {
  local pid_file="$1"
  [[ -f "${pid_file}" ]] && kill -0 "$(cat "${pid_file}")" >/dev/null 2>&1
}

pid_text() {
  local pid_file="$1"
  if [[ -f "${pid_file}" ]]; then
    cat "${pid_file}"
  else
    printf '-'
  fi
}

port_listening() {
  local port="$1"
  lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1
}

models_ok() {
  local base_url="$1"
  curl -fsS --max-time 3 "${base_url%/}/models" >/dev/null 2>&1
}

embedding_smoke() {
  local base_url="$1"
  local model="$2"
  curl -fsS --max-time 20 "${base_url%/}/embeddings" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer no-key" \
    -d "{\"model\":\"${model}\",\"input\":[\"search_query: status smoke\"],\"encoding_format\":\"float\"}" |
    grep -q '"embedding"'
}

chat_smoke() {
  local base_url="$1"
  local model="$2"
  curl -fsS --max-time 30 "${base_url%/}/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer no-key" \
    -d "{\"model\":\"${model}\",\"messages\":[{\"role\":\"user\",\"content\":\"Reply with OK only.\"}],\"temperature\":0,\"max_tokens\":8}" |
    grep -q '"choices"'
}

is_required() {
  local name="$1"
  case ",${required}," in
    *,"${name}",*) return 0 ;;
    *) return 1 ;;
  esac
}

check_service() {
  local name="$1"
  local pid_file="$2"
  local host="$3"
  local port="$4"
  local base_url="$5"
  local model="$6"
  local kind="$7"

  local pid_status="stale-or-missing"
  local port_status="closed"
  local http_status="down"
  local smoke_status="not-run"
  local ok=1

  if pid_alive "${pid_file}"; then
    pid_status="alive"
  fi
  if port_listening "${port}"; then
    port_status="listening"
  fi
  if models_ok "${base_url}"; then
    http_status="ok"
  else
    ok=0
  fi
  if [[ "${smoke}" -eq 1 ]]; then
    if [[ "${kind}" == "embedding" ]]; then
      if embedding_smoke "${base_url}" "${model}"; then smoke_status="ok"; else smoke_status="failed"; ok=0; fi
    else
      if chat_smoke "${base_url}" "${model}"; then smoke_status="ok"; else smoke_status="failed"; ok=0; fi
    fi
  fi

  printf '%-9s pid=%s pid_status=%s port=%s:%s port_status=%s http=%s smoke=%s base=%s model=%s\n' \
    "${name}" "$(pid_text "${pid_file}")" "${pid_status}" "${host}" "${port}" "${port_status}" "${http_status}" "${smoke_status}" "${base_url}" "${model}"

  if is_required "${name}" && [[ "${ok}" -ne 1 ]]; then
    return 1
  fi
  return 0
}

failed=0
check_service "embedding" "${state_dir}/embedding.pid" "${embedding_host}" "${embedding_port}" "${embedding_base_url}" "${embedding_model}" "embedding" || failed=1
check_service "chat" "${state_dir}/chat.pid" "${chat_host}" "${chat_port}" "${chat_base_url}" "${chat_model}" "chat" || failed=1
check_service "advisor" "${state_dir}/advisor.pid" "${advisor_host}" "${advisor_port}" "${advisor_base_url}" "${advisor_model}" "chat" || failed=1

exit "${failed}"
