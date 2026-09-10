#!/bin/sh

set -eu

# Deterministic Codex App Server JSONL fixture. The first argument is the
# literal `app-server` subcommand supplied by the adapter.
if [ "${1:-}" != "app-server" ]; then
  exit 2
fi

rate_limit_reads=0

log_method()
{
  if [ -n "${CREXXRAG_CODEX_FIXTURE_LOG:-}" ]; then
    printf '%s\n' "$1" >>"$CREXXRAG_CODEX_FIXTURE_LOG"
  fi
}

while IFS= read -r line; do
  # Compact adapter envelopes have a numeric top-level id. Avoid a subprocess
  # for each message in the long-lived request-reclamation regression.
  id=${line#*'"id":'}
  id=${id%%[!0-9]*}
  case "$line" in
    *'"method":"initialize"'*)
      log_method initialize
      printf '{"id":%s,"result":{"userAgent":"crexx-fixture"}}\n' "$id"
      ;;
    *'"method":"initialized"'*)
      ;;
    *'"method":"account/read"'*)
      log_method account/read
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "account-fragments" ]; then
        printf '{"id":%s,"result":{"padding":"' "$id"
        n=0
        while [ "$n" -lt 80 ]; do
          printf x
          sleep 0.05
          n=$((n + 1))
        done
        printf '%s\n' '","account":{"type":"chatgpt","planType":"pro"}}}'
        continue
      fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "account-noise" ]; then
        n=0
        while [ "$n" -lt 80 ]; do
          printf '%s\n' '{"method":"unrelated/notification","params":{}}'
          sleep 0.05
          n=$((n + 1))
        done
      fi
      case "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" in
        preflight-always) exit 70 ;;
        preflight-once)
          if mkdir "${CREXXRAG_CODEX_FIXTURE_ONCE:?}" 2>/dev/null; then exit 70; fi
          ;;
      esac
      printf '{"id":%s,"result":{"account":{"type":"chatgpt","planType":"pro"}}}\n' "$id"
      ;;
    *'"method":"account/rateLimits/read"'*)
      rate_limit_reads=$((rate_limit_reads + 1))
      log_method account/rateLimits/read
      if [ "${CREXXRAG_CODEX_FIXTURE_PAUSE_AFTER_TURN:-}" = "1" ] && [ "$rate_limit_reads" -gt 1 ]; then
        sleep 5
      fi
      printf '{"id":%s,"result":{"rateLimits":{"primary":{"usedPercent":12}}}}\n' "$id"
      ;;
    *'"method":"thread/read"'*)
      log_method thread/read
      state=interrupted
      if [ -n "${CREXXRAG_CODEX_FIXTURE_STATE_FILE:-}" ]; then
        IFS= read -r state < "$CREXXRAG_CODEX_FIXTURE_STATE_FILE"
      fi
      case "$state" in
        unavailable)
          printf '{"id":%s,"error":{"message":"thread history unavailable"}}\n' "$id"
          ;;
        wrong-thread)
          printf '{"id":%s,"result":{"thread":{"id":"another-thread","turns":[]}}}\n' "$id"
          ;;
        missing)
          printf '{"id":%s,"result":{"thread":{"id":"fixture-thread","turns":[{"id":"other-turn","status":"completed","items":[]}]}}}\n' "$id"
          ;;
        completed)
          printf '{"id":%s,"result":{"thread":{"id":"fixture-thread","turns":[{"id":"fixture-turn","status":"completed","items":[{"type":"agentMessage","phase":"final_answer","text":"{\\"mentions\\":[],\\"relationships\\":[],\\"notes\\":[]}"},{"type":"agentMessage","phase":"commentary","text":"This is commentary, not the final JSON."}]}]}}}\n' "$id"
          ;;
        *)
          printf '{"id":%s,"result":{"thread":{"id":"fixture-thread","turns":[{"id":"fixture-turn","status":"%s","items":[]}]}}}\n' "$id" "$state"
          ;;
      esac
      ;;
    *'"method":"thread/start"'*)
      log_method thread/start
      printf '{"id":%s,"result":{"thread":{"id":"fixture-thread"}}}\n' "$id"
      ;;
    *'"method":"turn/start"'*)
      log_method turn/start
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "citation-feedback" ] && [ -d "${CREXXRAG_CODEX_FIXTURE_ONCE:?}" ]; then
        case "$line" in
          *'field=mentions[0].evidence_quote'*'field=relationships[0].evidence_quote'*) log_method correction-feedback-checked ;;
          *) exit 71 ;;
        esac
      fi
      case "$line" in
        *'"effort":"low"'*) ;;
        *)
          printf '{"id":%s,"error":{"message":"configured low reasoning effort was not supplied"}}\n' "$id"
          continue
          ;;
      esac
      printf '{"id":%s,"result":{"turn":{"id":"fixture-turn"}}}\n' "$id"
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "turn-noise" ]; then
        n=0
        while [ "$n" -lt 80 ]; do
          printf '%s\n' '{"method":"unrelated/notification","params":{}}'
          sleep 0.05
          n=$((n + 1))
        done
      fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "turn-disconnect" ]; then
        printf '%s\n' '{"method":"thread/tokenUsage/updated","params":{"threadId":"fixture-thread","turnId":"fixture-turn","tokenUsage":{"last":{"inputTokens":7,"outputTokens":2}}}}'
        exit 70
      fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "citation-exhausted" ]; then
        printf '%s\n' '{"method":"item/completed","params":{"threadId":"fixture-thread","turnId":"fixture-turn","item":{"type":"agentMessage","text":"{\"mentions\":[{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"application-component\",\"evidence_quote\":\"Bill-\\ningService\",\"aliases\":[]},{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"CustomerDatabase\",\"aliases\":[]}],\"relationships\":[{\"source_mention\":0,\"relationship_type\":\"depends-on\",\"target_mention\":1,\"evidence_quote\":\"depends on CustomerDatabase.\",\"confidence_millionths\":940000}],\"notes\":[]}"}}}'
      elif [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "citation-feedback" ] && mkdir "${CREXXRAG_CODEX_FIXTURE_ONCE:?}" 2>/dev/null; then
        printf '%s\n' '{"method":"item/completed","params":{"threadId":"fixture-thread","turnId":"fixture-turn","item":{"type":"agentMessage","text":"{\"mentions\":[{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"application-component\",\"evidence_quote\":\"Bill-\\ningService\",\"aliases\":[]},{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"CustomerDatabase\",\"aliases\":[]}],\"relationships\":[{\"source_mention\":0,\"relationship_type\":\"depends-on\",\"target_mention\":1,\"evidence_quote\":\"depends on CustomerDatabase.\",\"confidence_millionths\":940000}],\"notes\":[]}"}}}'
      elif [ "${CREXXRAG_CODEX_FIXTURE_MODE:-}" = "extraction" ]; then
        printf '%s\n' '{"method":"item/completed","params":{"threadId":"fixture-thread","turnId":"fixture-turn","item":{"type":"agentMessage","text":"{\"mentions\":[{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"application-component\",\"evidence_quote\":\"BillingService\",\"aliases\":[]},{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"CustomerDatabase\",\"aliases\":[]},{\"label\":\"BillingService\",\"canonical_label\":\"BillingService\",\"concept_type\":\"application-component\",\"evidence_quote\":\"Again, BillingService depends on CustomerDatabase.\",\"aliases\":[]},{\"label\":\"CustomerDatabase\",\"canonical_label\":\"CustomerDatabase\",\"concept_type\":\"data-store\",\"evidence_quote\":\"Again, BillingService depends on CustomerDatabase.\",\"aliases\":[]}],\"relationships\":[{\"source_mention\":0,\"relationship_type\":\"depends-on\",\"target_mention\":1,\"evidence_quote\":\"BillingService depends on CustomerDatabase.\",\"confidence_millionths\":940000},{\"source_mention\":2,\"relationship_type\":\"depends-on\",\"target_mention\":3,\"evidence_quote\":\"Again, BillingService depends on CustomerDatabase.\",\"confidence_millionths\":930000}],\"notes\":[]}"}}}'
      else
        printf '%s\n' '{"method":"item/completed","params":{"threadId":"fixture-thread","turnId":"fixture-turn","item":{"type":"agentMessage","text":"{\"ok\":true}"}}}'
      fi
      input_tokens=7
      if [ "${CREXXRAG_CODEX_FIXTURE_MODE:-}" = "extraction" ]; then
        input_tokens=20000
      fi
      printf '{"method":"thread/tokenUsage/updated","params":{"threadId":"fixture-thread","turnId":"fixture-turn","tokenUsage":{"last":{"inputTokens":%s,"outputTokens":4}}}}\n' "$input_tokens"
      printf '%s\n' '{"method":"turn/completed","params":{"threadId":"fixture-thread","turn":{"id":"fixture-turn","status":"completed"}}}'
      ;;
    *'"method":"thread/delete"'*)
      log_method thread/delete
      printf '{"id":%s,"result":{}}\n' "$id"
      ;;
    *)
      if [ -n "$id" ]; then
        printf '{"id":%s,"error":{"message":"unsupported fixture method"}}\n' "$id"
      fi
      ;;
  esac
done
