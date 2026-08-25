#!/bin/sh

set -eu

# Deterministic Codex App Server JSONL fixture. The first argument is the
# literal `app-server` subcommand supplied by the adapter.
if [ "${1:-}" != "app-server" ]; then
  exit 2
fi

while IFS= read -r line; do
  id=$(printf '%s\n' "$line" | sed -n 's/.*"id":\([0-9][0-9]*\).*/\1/p')
  case "$line" in
    *'"method":"initialize"'*)
      printf '{"id":%s,"result":{"userAgent":"crexx-fixture"}}\n' "$id"
      ;;
    *'"method":"initialized"'*)
      ;;
    *'"method":"account/read"'*)
      printf '{"id":%s,"result":{"account":{"type":"chatgpt","planType":"pro"}}}\n' "$id"
      ;;
    *'"method":"account/rateLimits/read"'*)
      printf '{"id":%s,"result":{"rateLimits":{"primary":{"usedPercent":12}}}}\n' "$id"
      ;;
    *'"method":"thread/start"'*)
      printf '{"id":%s,"result":{"thread":{"id":"fixture-thread"}}}\n' "$id"
      ;;
    *'"method":"turn/start"'*)
      printf '{"id":%s,"result":{"turn":{"id":"fixture-turn"}}}\n' "$id"
      printf '%s\n' '{"method":"item/completed","params":{"threadId":"fixture-thread","turnId":"fixture-turn","item":{"type":"agentMessage","text":"{\"ok\":true}"}}}'
      printf '%s\n' '{"method":"thread/tokenUsage/updated","params":{"threadId":"fixture-thread","turnId":"fixture-turn","tokenUsage":{"last":{"inputTokens":7,"outputTokens":4}}}}'
      printf '%s\n' '{"method":"turn/completed","params":{"threadId":"fixture-thread","turn":{"id":"fixture-turn","status":"completed"}}}'
      ;;
    *'"method":"thread/delete"'*)
      printf '{"id":%s,"result":{}}\n' "$id"
      ;;
    *)
      if [ -n "$id" ]; then
        printf '{"id":%s,"error":{"message":"unsupported fixture method"}}\n' "$id"
      fi
      ;;
  esac
done
