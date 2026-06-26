#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "${script_dir}/.." && pwd)"

library="${CPRAG_IMPROVE_LIBRARY:-${repo_dir}/cmake-build-debug/history-pipeline.cprag}"
profile="${CPRAG_IMPROVE_PROFILE:-generic}"
profile_id="${CPRAG_IMPROVE_PROFILE_ID:-}"
queue_id="${CPRAG_IMPROVE_QUEUE_ID:-}"
mode="${CPRAG_IMPROVE_MODE:-offline}"
stage2b_limit="${CPRAG_IMPROVE_STAGE2B_LIMIT:-100}"
stage2b_preview="${CPRAG_IMPROVE_STAGE2B_PREVIEW:-10}"
stage3_limit="${CPRAG_IMPROVE_STAGE3_LIMIT:-10}"
stage3_mode="${CPRAG_IMPROVE_STAGE3_MODE:-dry-run}"
stage3_format="${CPRAG_IMPROVE_STAGE3_FORMAT:-tagged}"
stage3_max_tokens="${CPRAG_IMPROVE_STAGE3_MAX_TOKENS:-2048}"
max_cycles="${CPRAG_IMPROVE_MAX_CYCLES:-1}"
sleep_seconds="${CPRAG_IMPROVE_SLEEP_SECONDS:-0}"
run_root="${CPRAG_IMPROVE_RUN_ROOT:-${repo_dir}/.local/background-improvement}"
run_id="${CPRAG_IMPROVE_RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
lock_dir="${CPRAG_IMPROVE_LOCK_DIR:-${repo_dir}/.local/locks/background-improvement.lock}"
require_models=1

usage() {
  cat <<'USAGE'
Usage: scripts/run_background_improvement.sh [options]

Runs a budgeted single-worker graph improvement loop over the staged pipeline.
It is a foreground worker by design; use Terminal, launchctl, or a scheduler to
detach it once the command is proven for the target host.

Common options:
  --library PATH
  --profile generic|scotland|athens
  --profile-id ID
  --queue-id ID
  --mode online|offline
  --stage2b-limit N
  --stage3-limit N
  --stage3-mode online|dry-run
  --max-cycles N
  --sleep-seconds N
  --run-root PATH
  --run-id ID
  --lock-dir PATH
  --no-require-models

Example:
  scripts/run_background_improvement.sh \
    --library ./demo.cprag \
    --profile generic \
    --queue-id improve-generic \
    --stage2b-limit 20 \
    --stage3-limit 5 \
    --stage3-mode dry-run \
    --no-require-models
USAGE
}

while (($#)); do
  case "$1" in
    --library) library="$2"; shift ;;
    --profile) profile="$2"; shift ;;
    --profile-id) profile_id="$2"; shift ;;
    --queue-id) queue_id="$2"; shift ;;
    --mode) mode="$2"; shift ;;
    --stage2b-limit) stage2b_limit="$2"; shift ;;
    --stage2b-preview) stage2b_preview="$2"; shift ;;
    --stage3-limit) stage3_limit="$2"; shift ;;
    --stage3-mode) stage3_mode="$2"; shift ;;
    --stage3-format) stage3_format="$2"; shift ;;
    --stage3-max-tokens) stage3_max_tokens="$2"; shift ;;
    --max-cycles) max_cycles="$2"; shift ;;
    --sleep-seconds) sleep_seconds="$2"; shift ;;
    --run-root) run_root="$2"; shift ;;
    --run-id) run_id="$2"; shift ;;
    --lock-dir) lock_dir="$2"; shift ;;
    --no-require-models) require_models=0 ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "run_background_improvement: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

case "${profile}" in
  generic|scotland|athens) ;;
  *) echo "run_background_improvement: --profile must be generic, scotland, or athens" >&2; exit 2 ;;
esac
case "${mode}" in online|offline) ;; *) echo "run_background_improvement: --mode must be online or offline" >&2; exit 2 ;; esac
case "${stage3_mode}" in online|dry-run) ;; *) echo "run_background_improvement: --stage3-mode must be online or dry-run" >&2; exit 2 ;; esac

if [[ "${max_cycles}" -lt 1 ]]; then
  echo "run_background_improvement: --max-cycles must be at least 1" >&2
  exit 2
fi
if [[ "${stage2b_limit}" -lt 1 || "${stage3_limit}" -lt 1 ]]; then
  echo "run_background_improvement: stage limits must be at least 1" >&2
  exit 2
fi
if [[ -z "${queue_id}" ]]; then
  queue_id="improve-${profile}-$(date +%Y%m%d)"
fi

mkdir -p "$(dirname "${lock_dir}")"
if ! mkdir "${lock_dir}" 2>/dev/null; then
  echo "run_background_improvement: another worker holds ${lock_dir}" >&2
  exit 75
fi
cleanup() {
  rmdir "${lock_dir}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

run_dir="${run_root}/${run_id}"
mkdir -p "${run_dir}"
log_file="${run_dir}/improvement.log"

{
  echo "run_id=${run_id}"
  echo "library=${library}"
  echo "profile=${profile}"
  echo "profile_id=${profile_id}"
  echo "queue_id=${queue_id}"
  echo "mode=${mode}"
  echo "stage2b_limit=${stage2b_limit}"
  echo "stage3_limit=${stage3_limit}"
  echo "stage3_mode=${stage3_mode}"
  echo "max_cycles=${max_cycles}"
  echo "lock_dir=${lock_dir}"

  cycle=1
  while [[ "${cycle}" -le "${max_cycles}" ]]; do
    cycle_run_id="${run_id}-cycle-${cycle}"
    echo
    echo "## cycle ${cycle}/${max_cycles} run_id=${cycle_run_id}"

    args=(
      --library "${library}"
      --profile "${profile}"
      --stages stage2b,stage3,status
      --mode "${mode}"
      --queue-id "${queue_id}"
      --stage2b-limit "${stage2b_limit}"
      --stage2b-preview "${stage2b_preview}"
      --stage3-limit "${stage3_limit}"
      --stage3-mode "${stage3_mode}"
      --stage3-format "${stage3_format}"
      --stage3-max-tokens "${stage3_max_tokens}"
      --run-root "${run_dir}"
      --run-id "${cycle_run_id}"
    )
    if [[ -n "${profile_id}" ]]; then args+=(--profile-id "${profile_id}"); fi
    if [[ "${require_models}" -eq 0 ]]; then args+=(--no-require-models); fi

    "${script_dir}/run_history_pipeline.sh" "${args[@]}"

    if [[ "${cycle}" -lt "${max_cycles}" && "${sleep_seconds}" -gt 0 ]]; then
      echo "sleep ${sleep_seconds}s"
      sleep "${sleep_seconds}"
    fi
    cycle=$((cycle + 1))
  done

  echo
  echo "background improvement complete cycles=${max_cycles}"
} 2>&1 | tee -a "${log_file}"

echo
echo "background improvement log: ${log_file}"
