#!/usr/bin/env bash
set -euo pipefail

install=0
case "${1:-}" in
  ""|--check) ;;
  --install) install=1 ;;
  -h|--help)
    echo "usage: scripts/setup_llama_cpp_embedder.sh [--check|--install]"
    exit 0
    ;;
  *) echo "unknown option: $1" >&2; exit 2 ;;
esac

if ! command -v llama-server >/dev/null 2>&1; then
  if [[ "$install" -eq 1 ]] && command -v brew >/dev/null 2>&1; then
    brew install llama.cpp
  else
    echo "llama-server is missing; on macOS run: brew install llama.cpp" >&2
    exit 1
  fi
fi

echo "llama-server: $(command -v llama-server)"
llama-server --version
cat <<'EOF'

Start and test the local embedding endpoint:
  scripts/start_local_llama_servers.sh --embedding-only
  scripts/status_local_llama_servers.sh --smoke --require embedding

Configure crexxrag with an openai-compatible embedding provider at:
  http://127.0.0.1:8081/v1

Default model identity:
  nomic-embed-text-v1.5
EOF
