#!/usr/bin/env bash
set -euo pipefail

model_ref="${CPRAG_LLAMA_SERVER_MODEL_REF:-nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M}"
host="${CPRAG_LLAMA_SERVER_HOST:-127.0.0.1}"
port="${CPRAG_LLAMA_SERVER_PORT:-8081}"
ctx_size="${CPRAG_LLAMA_SERVER_CTX_SIZE:-2048}"
batch_size="${CPRAG_LLAMA_SERVER_BATCH_SIZE:-2048}"
ubatch_size="${CPRAG_LLAMA_SERVER_UBATCH_SIZE:-1024}"

install=0

usage() {
  cat <<'USAGE'
Usage: scripts/setup_llama_cpp_embedder.sh [--check] [--install]

Checks the local llama.cpp embedding setup and prints the llama-server command.

Options:
  --check     Verify commands and print next steps without installing (default)
  --install   Install llama.cpp with Homebrew when it is missing
  -h, --help  Show this help

Environment:
  CPRAG_LLAMA_SERVER_MODEL_REF  Hugging Face GGUF model ref
  CPRAG_LLAMA_SERVER_HOST       Server host, default 127.0.0.1
  CPRAG_LLAMA_SERVER_PORT       Server port, default 8081
  CPRAG_LLAMA_SERVER_CTX_SIZE   Context size, default 2048
  CPRAG_LLAMA_SERVER_BATCH_SIZE Logical batch size, default 2048
  CPRAG_LLAMA_SERVER_UBATCH_SIZE Physical batch size, default 1024
USAGE
}

while (($#)); do
  case "$1" in
    --check)
      install=0
      ;;
    --install)
      install=1
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

echo "Checking Homebrew..."
if command -v brew >/dev/null 2>&1; then
  brew_cmd="$(command -v brew)"
  echo "  found: ${brew_cmd}"
else
  cat >&2 <<'EOF'
  Homebrew was not found.

  Preferred macOS Apple Silicon setup:
    brew install llama.cpp

  Manual fallback, when Homebrew is unavailable:
    git clone https://github.com/ggml-org/llama.cpp
    cmake -S llama.cpp -B llama.cpp/build -G Ninja -DGGML_METAL=ON
    cmake --build llama.cpp/build --config Release

  Put the resulting llama-server and llama-cli commands on PATH, then rerun this script.
EOF
  exit 1
fi

if ! command -v llama-server >/dev/null 2>&1 || ! command -v llama-cli >/dev/null 2>&1; then
  if [[ "${install}" -eq 1 ]]; then
    echo "Installing llama.cpp with Homebrew..."
    brew install llama.cpp
  else
    cat >&2 <<'EOF'
  llama-server and/or llama-cli were not found on PATH.

  Install with:
    brew install llama.cpp

  Or run this script with:
    scripts/setup_llama_cpp_embedder.sh --install
EOF
    exit 1
  fi
fi

echo "Verifying llama.cpp commands..."
echo "  llama-server: $(command -v llama-server)"
llama-server --version
echo "  llama-cli: $(command -v llama-cli)"
llama-cli --version

cat <<EOF

Start the local embedding server with:

llama-server \\
  -hf ${model_ref} \\
  --embedding \\
  --pooling mean \\
  -c ${ctx_size} \\
  --batch-size ${batch_size} \\
  --ubatch-size ${ubatch_size} \\
  --host ${host} \\
  --port ${port}

Then smoke-test the OpenAI-compatible embeddings endpoint with:

curl http://${host}:${port}/v1/embeddings \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Bearer no-key" \\
  -d '{
    "model": "nomic-embed-text-v1.5",
    "input": ["search_query: authentication database"],
    "encoding_format": "float"
  }'

For crexx-rag chunk embeddings:
  ./cmake-build-faiss/crexx-rag embed-chunks ./example.cprag nomic-embed-text-v1.5 llama-server

For MCP query embeddings:
  ./cmake-build-faiss/crexx-rag embed-llama-server --role query
EOF
