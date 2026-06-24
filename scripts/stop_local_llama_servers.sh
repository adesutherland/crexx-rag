#!/usr/bin/env bash
set -euo pipefail

state_dir="${CPRAG_LLAMA_STATE_DIR:-.local/llama-servers}"
kill_all=0

usage() {
  cat <<'USAGE'
Usage: scripts/stop_local_llama_servers.sh [--all]

Stops llama-server processes started by scripts/start_local_llama_servers.sh.

Options:
  --all   Stop every local llama-server process visible to this user
USAGE
}

while (($#)); do
  case "$1" in
    --all)
      kill_all=1
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

stop_pid_file() {
  local pid_file="$1"
  local name="$2"
  if [[ ! -f "${pid_file}" ]]; then
    echo "${name}: no pid file"
    return
  fi

  local pid
  pid="$(cat "${pid_file}")"
  if [[ -z "${pid}" ]] || ! kill -0 "${pid}" >/dev/null 2>&1; then
    echo "${name}: not running"
    rm -f "${pid_file}"
    return
  fi

  echo "stopping ${name} pid ${pid}"
  kill "${pid}" >/dev/null 2>&1 || true
  for _ in 1 2 3 4 5; do
    if ! kill -0 "${pid}" >/dev/null 2>&1; then
      rm -f "${pid_file}"
      return
    fi
    sleep 1
  done

  echo "${name}: still running, sending TERM again"
  kill "${pid}" >/dev/null 2>&1 || true
  rm -f "${pid_file}"
}

if [[ "${kill_all}" -eq 1 ]]; then
  pids="$(pgrep -x llama-server || true)"
  if [[ -z "${pids}" ]]; then
    echo "no llama-server processes found"
    exit 0
  fi
  echo "stopping all llama-server processes:"
  echo "${pids}"
  kill ${pids} >/dev/null 2>&1 || true
  exit 0
fi

stop_pid_file "${state_dir}/embedding.pid" "embedding llama-server"
stop_pid_file "${state_dir}/chat.pid" "chat llama-server"
