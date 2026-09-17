#!/bin/sh

set -eu

# Deterministic Codex App Server JSONL fixture. The first argument is the
# literal `app-server` subcommand supplied by the adapter.
if [ "${1:-}" != "app-server" ]; then
  exit 2
fi

rate_limit_reads=0
controller_case=0
thread_id=fixture-thread
case "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" in
  controller-*) controller_case=1; thread_id=fixture-thread-$$ ;;
esac
cleanup_fault=0

hold_worker_loss() {
  sync=${CREXXRAG_CODEX_FIXTURE_SYNC:?}
  : > "$sync/$$.ready"
  polls=0
  while [ ! -f "$sync/released" ]; do
    polls=$((polls + 1))
    [ "$polls" -lt 3000 ] || exit 72
    sleep 0.01
  done
}

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
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "observation-auth" ]; then
        printf '{"id":%s,"error":{"message":"authentication session expired"}}\n' "$id"
        continue
      fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "optional-refresh" ] && [ "${finished_turn:-0}" = 1 ]; then sleep 4; exit 70; fi
      if [ "$cleanup_fault" = 1 ]; then sleep 4; exit 70; fi
      case "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" in
        utf8-fragments)
          printf '{"id":%s,"result":{"account":{"type":"chatgpt","planType":"pro-' "$id"
          # Split valid 2-, 3- and 4-byte code points between stdout writes.
          # The consumer has already submitted account/read and is waiting.
          printf '\303'; sleep 0.05; printf '\251'
          printf '\346'; sleep 0.05; printf '\274'; sleep 0.05; printf '\242'
          printf '\360'; sleep 0.05; printf '\237'; sleep 0.05; printf '\246'; sleep 0.05; printf '\204'
          printf '"}}}\n'
          continue
          ;;
        utf8-invalid)
          printf '{"id":%s,"result":{"account":{"type":"chatgpt","planType":"bad-\377"}}}\n' "$id"
          continue
          ;;
      esac
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
        worker-kill|worker-write-error) hold_worker_loss ;;
        supervision-outage|supervision-outage24)
          n=1
          while [ "$n" -le 8 ]; do
            if mkdir "${CREXXRAG_CODEX_FIXTURE_SYNC:?}/initial-$n" 2>/dev/null; then
              tries=0
              while [ ! -d "$CREXXRAG_CODEX_FIXTURE_SYNC/initial-8" ]; do
                tries=$((tries + 1))
                if [ "$tries" -ge 400 ]; then exit 71; fi
                sleep 0.025
              done
              if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = supervision-outage24 ] && [ "$n" -gt 5 ]; then break; fi
              log_method outage-preflight-failed
              exit 70
            fi
            n=$((n + 1))
          done
          ;;
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
      if [ "$controller_case" = 1 ]; then
        thread_id=${line#*'"threadId":"'}
        thread_id=${thread_id%%\"*}
      fi
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
          printf '{"id":%s,"result":{"thread":{"id":"%s","turns":[{"id":"fixture-turn","status":"completed","items":[{"type":"agentMessage","phase":"final_answer","text":"{\\"mentions\\":[],\\"relationships\\":[],\\"notes\\":[]}"},{"type":"agentMessage","phase":"commentary","text":"This is commentary, not the final JSON."}]}]}}}\n' "$id" "$thread_id"
          ;;
        *)
          printf '{"id":%s,"result":{"thread":{"id":"%s","turns":[{"id":"fixture-turn","status":"%s","items":[]}]}}}\n' "$id" "$thread_id" "$state"
          ;;
      esac
      ;;
    *'"method":"thread/start"'*)
      log_method thread/start
      printf '{"id":%s,"result":{"thread":{"id":"%s"}}}\n' "$id" "$thread_id"
      ;;
    *'"method":"turn/start"'*)
      log_method turn/start
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = worker-unknown ]; then hold_worker_loss; fi
      finished_turn=1
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "optional-refresh" ]; then rate_limit_reads=0; fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = supervision-task ]; then
        case "$line" in
          *BAD_TASK*)
            printf '{"id":%s,"result":{"turn":{"id":"fixture-turn"}}}\n' "$id"
            printf '%s\n' '{"method":"item/completed","params":{"threadId":"fixture-thread","turnId":"fixture-turn","item":{"type":"agentMessage","text":"{\"mentions\":[{\"label\":\"Unsupported\",\"canonical_label\":\"Unsupported\",\"concept_type\":\"application-component\",\"evidence_quote\":\"Not in this source\",\"aliases\":[]}],\"relationships\":[],\"notes\":[]}"}}}'
            printf '%s\n' '{"method":"thread/tokenUsage/updated","params":{"threadId":"fixture-thread","turnId":"fixture-turn","tokenUsage":{"last":{"inputTokens":7,"outputTokens":2}}}}'
            printf '%s\n' '{"method":"turn/completed","params":{"threadId":"fixture-thread","turn":{"id":"fixture-turn","status":"completed"}}}'
            continue
            ;;
        esac
      fi
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
      if [ "$controller_case" = 1 ]; then
        # All eight first requests must overlap before any response is released.
        sync=${CREXXRAG_CODEX_FIXTURE_SYNC:?}
        if [ ! -e "$sync/released" ]; then
          : > "$sync/$$.ready"
          polls=0
          while [ ! -e "$sync/released" ]; do
            set -- "$sync"/*.ready
            if [ "$#" -ge 8 ]; then : > "$sync/released"; break; fi
            polls=$((polls + 1))
            if [ "$polls" -ge 1000 ]; then exit 72; fi
            sleep 0.01
          done
        fi
        fault=0
        if [ "$CREXXRAG_CODEX_FIXTURE_FAILURE" = controller-exhausted ]; then
          for slot in 1 2 3; do
            if mkdir "${CREXXRAG_CODEX_FIXTURE_ONCE:?}-$slot" 2>/dev/null; then fault=1; break; fi
          done
        elif mkdir "${CREXXRAG_CODEX_FIXTURE_ONCE:?}" 2>/dev/null; then
          fault=1
        fi
        if [ "$fault" = 1 ]; then
          case "$CREXXRAG_CODEX_FIXTURE_FAILURE" in
            controller-cleanup) cleanup_fault=1 ;;
            *)
              printf '{"method":"thread/tokenUsage/updated","params":{"threadId":"%s","turnId":"fixture-turn","tokenUsage":{"last":{"inputTokens":7,"outputTokens":2}}}}\n' "$thread_id"
              log_method fault-submitted
              exit 70
              ;;
          esac
        fi
        printf '{"method":"item/completed","params":{"threadId":"%s","turnId":"fixture-turn","item":{"type":"agentMessage","text":"{\\"mentions\\":[],\\"relationships\\":[],\\"notes\\":[]}"}}}\n' "$thread_id"
        printf '{"method":"thread/tokenUsage/updated","params":{"threadId":"%s","turnId":"fixture-turn","tokenUsage":{"last":{"inputTokens":7,"outputTokens":4}}}}\n' "$thread_id"
        printf '{"method":"turn/completed","params":{"threadId":"%s","turn":{"id":"fixture-turn","status":"completed"}}}\n' "$thread_id"
        continue
      fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "observation-slow" ]; then sleep 0.25; fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "observation-timeout" ]; then sleep 2; continue; fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "observation-disconnect" ]; then sleep 0.25; exit 70; fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "observation-malformed" ]; then
        printf '%s\n' '{"method":"item/completed","params":{"threadId":"fixture-thread","turnId":"fixture-turn","item":{"type":"agentMessage","text":"{broken original output"}}}'
        printf '%s\n' '{"method":"turn/completed","params":{"threadId":"fixture-thread","turn":{"id":"fixture-turn","status":"completed"}}}'
        continue
      fi
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
      finished_turn=0
      if [ "${CREXXRAG_CODEX_FIXTURE_PAUSE_AFTER_TURN:-}" = "1" ]; then sleep 5; fi
      if [ "$cleanup_fault" = 1 ]; then sleep 4; exit 70; fi
      if [ "${CREXXRAG_CODEX_FIXTURE_FAILURE:-}" = "optional-delete" ]; then sleep 4; exit 70; fi
      printf '{"id":%s,"result":{}}\n' "$id"
      ;;
    *)
      if [ -n "$id" ]; then
        printf '{"id":%s,"error":{"message":"unsupported fixture method"}}\n' "$id"
      fi
      ;;
  esac
done
