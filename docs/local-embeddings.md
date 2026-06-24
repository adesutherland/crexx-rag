# Local Embeddings

`crexx-rag` keeps embedding providers outside the native core. The core stores
caller-provided vectors and can use FAISS as an optional vector index, but it
does not download models or call provider APIs itself.

The first open local provider path is `llama-server`, using llama.cpp's
OpenAI-compatible `/v1/embeddings` endpoint. Ollama remains supported through
the same external embedding-command contract.

## Provider IDs

Use provider ids in profiles and notes so configuration stays explicit:

- `llama-server`: local llama.cpp `llama-server` embedding endpoint
- `ollama`: local Ollama embedding endpoint or wrapper script

For `llama-server`, the default base URL is:

```text
http://127.0.0.1:8081/v1
```

Override it with:

```bash
export CPRAG_LLAMA_SERVER_BASE_URL=http://127.0.0.1:8081/v1
```

## llama.cpp on macOS Apple Silicon

Prefer Homebrew when it is available:

```bash
brew install llama.cpp
llama-server --version
llama-cli --version
```

Do not assume Homebrew exists on a machine. If it is missing, use a manual
source build only as a fallback:

```bash
git clone https://github.com/ggml-org/llama.cpp
cmake -S llama.cpp -B llama.cpp/build -G Ninja -DGGML_METAL=ON
cmake --build llama.cpp/build --config Release
```

Put `llama-server` and `llama-cli` on `PATH` after a manual build.

## Model Cache

Yes, llama.cpp caches models downloaded with `-hf`. On this machine the
Hugging Face cache is under:

```text
~/.cache/huggingface/hub/
```

Useful commands:

```bash
llama-server --cache-list
llama-server --offline -hf ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M
```

`--offline` forces llama.cpp to use the local cache and fail rather than
download. This is a good smoke test after a model has downloaded.

This repository provides a non-daemonizing setup helper:

```bash
scripts/setup_llama_cpp_embedder.sh --check
scripts/setup_llama_cpp_embedder.sh --install
```

`--check` verifies local commands and prints the server command. `--install`
uses `brew install llama.cpp` when Homebrew is present and llama.cpp commands
are missing.

## Starting Local Servers

During development, prefer explicit start/stop scripts over a login daemon. The
scripts keep logs and pid files in `.local/llama-servers/`, which is ignored by
Git:

```bash
scripts/start_local_llama_servers.sh
scripts/stop_local_llama_servers.sh
```

By default this starts:

- Nomic embeddings on `127.0.0.1:8081`
- Gemma chat extraction on `127.0.0.1:8080`

Start only one side when needed:

```bash
scripts/start_local_llama_servers.sh --embedding-only
scripts/start_local_llama_servers.sh --chat-only
```

Use environment variables to pick the model and ports:

```bash
CPRAG_CHAT_MODEL_REF=ggml-org/gemma-4-12B-it-GGUF:Q4_K_M \
CPRAG_CHAT_CTX_SIZE=8192 \
scripts/start_local_llama_servers.sh --chat-only
```

If you later want automatic startup on login, wrap the same script in a macOS
`launchd` LaunchAgent. Keeping the script as the single start path avoids
debugging two different sets of flags.

## Default Model

The default local embedder is:

```text
nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M
```

It is small, fast, GGUF-compatible, and suitable for local RAG embeddings.

Start the server in embedding mode:

```bash
llama-server \
  -hf nomic-ai/nomic-embed-text-v1.5-GGUF:Q4_K_M \
  --embedding \
  --pooling mean \
  -c 2048 \
  --host 127.0.0.1 \
  --port 8081
```

The explicit context size leaves room for the default `semantic-context-v1`
embedding envelope. If a server was started with a smaller effective context,
large chunks may fail with an HTTP 500 even though the JSON request is valid.

Smoke-test the OpenAI-compatible endpoint:

```bash
curl http://127.0.0.1:8081/v1/embeddings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer no-key" \
  -d '{
    "model": "nomic-embed-text-v1.5",
    "input": ["search_query: authentication database"],
    "encoding_format": "float"
  }'
```

Nomic embedding models expect task prefixes:

- documents/chunks: `search_document: ...`
- queries: `search_query: ...`

## Using llama-server with crexx-rag

The existing CLI and MCP embedding hook invokes a command as:

```text
<embedding-command> <text> <embedding-model>
```

The command must print either a JSON number array or an object with an
`embedding` array. `crexx-rag embed-llama-server` adapts the OpenAI-compatible
llama-server response to that contract in C++. When CMake finds libcurl, the
CLI helper uses it directly; otherwise it falls back to the `curl` executable.

For chunk/document embeddings:

```bash
./cmake-build-faiss/crexx-rag embed-chunks \
  ./example.cprag \
  nomic-embed-text-v1.5 \
  llama-server
```

For `embed-chunks`, `llama-server` is a provider id handled directly by the C++
CLI, so chunk batching does not shell through a provider wrapper per chunk.
Embedding requests are retried by default with `CPRAG_EMBEDDING_RETRIES=3` and
`CPRAG_EMBEDDING_RETRY_DELAY_MS=500`.

Large plain-text corpora can also use the smaller `raw-text-v1` profile when
the source metadata envelope is not needed for the first pass:

```bash
./cmake-build-faiss/crexx-rag embed-chunks \
  ./history-sample.cprag \
  nomic-embed-text-v1.5 \
  llama-server \
  examples/corpora/history/gutenberg-6156-athens-its-rise-and-fall.txt \
  raw-text-v1
```

For MCP query embeddings:

```bash
./cmake-build-faiss/crexx-rag-mcp \
  --library ./example.cprag \
  --embedding-command "./cmake-build-faiss/crexx-rag embed-llama-server --role query" \
  --embedding-model nomic-embed-text-v1.5
```

The helper uses `CPRAG_LLAMA_SERVER_BASE_URL` and defaults to
`http://127.0.0.1:8081/v1`. It also accepts `CPRAG_LLAMA_SERVER_INPUT_ROLE`,
`CPRAG_LLAMA_SERVER_INPUT_PREFIX`, `CPRAG_LLAMA_SERVER_API_KEY`, and
`CPRAG_LLAMA_SERVER_TIMEOUT` for profile-level tuning. The setup script also
honors `CPRAG_LLAMA_SERVER_CTX_SIZE` when printing the server command.

Ollama remains a valid provider behind the same command contract. Use an
embedding-capable Ollama model and a wrapper that emits the `embedding` array;
general chat models are not a substitute for stable embedding vectors unless
they expose a consistent embedding API.
