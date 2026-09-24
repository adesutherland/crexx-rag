include("${CMAKE_CURRENT_LIST_DIR}/FixtureEndpoint.cmake")
foreach(required_var CPRAG_NATIVE_APPLICATION CPRAG_LOOPBACK
        CPRAG_CODEX_FIXTURE CPRAG_CONFIG_TEMPLATE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/source")
file(WRITE "${CPRAG_WORK_DIR}/source/architecture.txt"
    "BillingService depends on CustomerDatabase.\n"
    "Again, BillingService depends on CustomerDatabase.\n")
set(CPRAG_FIXTURE_GLOSSARY "${CPRAG_WORK_DIR}/architecture.glossary.tsv")
file(WRITE "${CPRAG_FIXTURE_GLOSSARY}"
    "format\tcrexx-rag.glossary/1\n"
    "concept\tBillingService\tapplication-component\tBilling Service\n"
    "concept\tCustomerDatabase\tdata-store\tCustomer DB\n")
set(CPRAG_FIXTURE_PORT 0)
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source")
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/crexxrag.conf" @ONLY)

set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 1 product-ingestion; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    codex-application "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}"
    "${server_out}" "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start Codex application embedding loopback")
endif()
set(ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${server_out}")
        file(READ "${server_out}" current_server_out)
        if(current_server_out MATCHES "READY [0-9]+")
            set(ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT ready)
    message(FATAL_ERROR "Codex application embedding loopback did not become ready")
endif()

crexxrag_fixture_endpoint("${server_out}" "${CPRAG_WORK_DIR}/crexxrag.conf")
set(library "${CPRAG_WORK_DIR}/library")
set(codex_log "${CPRAG_WORK_DIR}/codex-methods.log")
set(codex_wrapper "${CPRAG_WORK_DIR}/codex-extraction-fixture.sh")
file(WRITE "${codex_wrapper}"
    "#!/bin/sh\n"
    "export CREXXRAG_CODEX_FIXTURE_MODE=extraction\n"
    "export CREXXRAG_CODEX_FIXTURE_FAILURE='${CPRAG_TERMINAL_FAILURE}'\n"
    "export CREXXRAG_CODEX_FIXTURE_LOG='${codex_log}'\n"
    "export CREXXRAG_CODEX_FIXTURE_PAUSE_AFTER_TURN=1\n"
    "exec /bin/sh '${CPRAG_CODEX_FIXTURE}' \"\$@\"\n")
file(CHMOD "${codex_wrapper}"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
    GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXXRAG_CODEX=${codex_wrapper}"
    "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
    "NO_COLOR=1"
    "${CPRAG_NATIVE_APPLICATION}")

execute_process(COMMAND ${cli} --library "${library}"
    --config-file "${CPRAG_WORK_DIR}/crexxrag.conf"
    --profile it-architecture-profile --access admin --format json library init
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err
    RESULT_VARIABLE init_result TIMEOUT 30)
if(NOT init_result EQUAL 0 OR NOT init_out MATCHES "\"schema_version\":20")
    message(FATAL_ERROR "Codex application init failed:\n${init_out}${init_err}")
endif()

execute_process(COMMAND ${cli} --library "${library}"
    --config-file "${CPRAG_WORK_DIR}/crexxrag.conf"
    --profile it-architecture-profile --access plan --format json
    ingest plan --source-set architecture-docs
    OUTPUT_VARIABLE plan_out ERROR_VARIABLE plan_err
    RESULT_VARIABLE plan_result TIMEOUT 30)
if(NOT plan_result EQUAL 0)
    message(FATAL_ERROR "Codex application plan failed:\n${plan_out}${plan_err}")
endif()
string(JSON plan_json ERROR_VARIABLE plan_json_error GET "${plan_out}" records 0 fields canonical_plan)
string(JSON plan_digest ERROR_VARIABLE plan_digest_error GET "${plan_out}" records 0 fields digest)
if(plan_json_error OR plan_digest_error)
    message(FATAL_ERROR "Codex application plan was not reviewable: ${plan_out}")
endif()

execute_process(COMMAND ${cli} --library "${library}"
    --config-file "${CPRAG_WORK_DIR}/crexxrag.conf"
    --profile it-architecture-profile --access ingest --format json --progress plain
    ingest apply --plan-json "${plan_json}" --expect-digest "${plan_digest}"
    OUTPUT_VARIABLE apply_out ERROR_VARIABLE apply_err
    RESULT_VARIABLE apply_result TIMEOUT 30)
if(NOT apply_result EQUAL 0 OR NOT apply_out MATCHES "\"items_queued\":2")
    message(FATAL_ERROR "Codex application apply failed:\n${apply_out}${apply_err}")
endif()
string(JSON job_id ERROR_VARIABLE job_error GET "${apply_out}" records 0 fields job_id)
if(job_error OR job_id STREQUAL "")
    message(FATAL_ERROR "Codex application apply did not expose a job id")
endif()

find_program(CREXXRAG_SQLITE3 sqlite3 REQUIRED)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
    "SELECT json_extract(message,'$.maximum_call_input_tokens') FROM job_events WHERE job_id='${job_id}' AND event_type='budget-policy';"
    OUTPUT_VARIABLE input_reservation OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE input_reservation_result)
if(NOT input_reservation_result EQUAL 0 OR NOT input_reservation STREQUAL "32768")
    message(FATAL_ERROR "Codex input reservation must cover managed context: ${input_reservation}")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
    "UPDATE job_items SET priority=CASE item_type WHEN 'claim-extraction' THEN 200 ELSE 100 END WHERE job_id='${job_id}';"
    RESULT_VARIABLE priority_result ERROR_VARIABLE priority_err)
if(NOT priority_result EQUAL 0)
    message(FATAL_ERROR "could not prioritize Codex extraction: ${priority_err}")
endif()

if(DEFINED CPRAG_TERMINAL_FAILURE AND NOT CPRAG_TERMINAL_FAILURE STREQUAL "")
    foreach(pass RANGE 1 2)
        execute_process(COMMAND ${cli} --library "${library}"
            --config-file "${CPRAG_WORK_DIR}/crexxrag.conf"
            --profile it-architecture-profile --access control --format json --progress plain
            worker run --once --poll-ms 20 --max-polls 2 --job "${job_id}"
            OUTPUT_VARIABLE failure_out ERROR_VARIABLE failure_err
            RESULT_VARIABLE failure_result TIMEOUT 30)
        if(NOT failure_result EQUAL 0)
            message(FATAL_ERROR "Codex terminal failure worker did not finish: ${failure_out}${failure_err}")
        endif()
    endforeach()
    execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
        "SELECT (SELECT count(*) FROM job_events WHERE event_type='provider-response' AND json_extract(message,'$.error_code')=-101 AND json_extract(message,'$.http_status')=400 AND json_extract(message,'$.retryable')=0 AND json_extract(message,'$.error_message') LIKE '%invalid_json_schema%')||':'||(SELECT count(*) FROM provider_runs WHERE provider_id='codex-extract' AND outcome='failed' AND json_extract(recovery_json,'$.error_code')=-101)||':'||(SELECT count(*) FROM job_items WHERE item_type='claim-extraction' AND state='dead_letter');"
        OUTPUT_VARIABLE failure_state OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE failure_state_err RESULT_VARIABLE failure_state_result)
    if(NOT failure_state_result EQUAL 0 OR NOT failure_state STREQUAL "1:1:1")
        message(FATAL_ERROR "Codex terminal rejection did not settle once with a public receipt: ${failure_state} ${failure_state_err}")
    endif()
    file(READ "${codex_log}" codex_methods)
    string(REGEX MATCHALL "turn/start" turn_starts "${codex_methods}")
    list(LENGTH turn_starts turn_start_count)
    if(NOT turn_start_count EQUAL 1)
        message(FATAL_ERROR "Codex terminal rejection was blindly resubmitted: ${codex_methods}")
    endif()
    return()
endif()

# Simulate a process crash after the external turn and usage are durable but
# before application validation and reservation settlement. The second worker
# must reuse the completed turn and must not create another Codex turn.
set(crash_script "${CPRAG_WORK_DIR}/crash-after-codex-persisted.sh")
file(WRITE "${crash_script}" [=[#!/bin/sh
set -eu
out=$1
err=$2
shift 2
"$@" >"$out" 2>"$err" &
worker=$!
poll=0
while kill -0 "$worker" 2>/dev/null; do
  if grep -q 'crexxrag codex persisted' "$err" 2>/dev/null; then
    kill -KILL "$worker" 2>/dev/null || true
    wait "$worker" 2>/dev/null || true
    exit 0
  fi
  poll=$((poll + 1))
  if [ "$poll" -ge 1000 ]; then
    kill -KILL "$worker" 2>/dev/null || true
    wait "$worker" 2>/dev/null || true
    exit 3
  fi
  sleep 0.01
done
wait "$worker"
exit 4
]=])
file(CHMOD "${crash_script}"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
    GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
set(crash_out "${CPRAG_WORK_DIR}/crash-worker.out")
set(crash_err "${CPRAG_WORK_DIR}/crash-worker.err")
execute_process(COMMAND "${crash_script}" "${crash_out}" "${crash_err}"
    ${cli} --library "${library}" --config-file "${CPRAG_WORK_DIR}/crexxrag.conf"
    --profile it-architecture-profile --access control --format json --progress plain
    worker run --once --poll-ms 20 --max-polls 2 --job "${job_id}"
    RESULT_VARIABLE crash_result TIMEOUT 30)
file(READ "${crash_err}" crash_trace)
if(NOT crash_result EQUAL 0 OR
   NOT crash_trace MATCHES "crexxrag codex persisted" OR
   crash_trace MATCHES "SIGNAL OUT_OF_RANGE")
    message(FATAL_ERROR "Codex crash-boundary setup failed (${crash_result}):\n${crash_trace}")
endif()

execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
    "SELECT (SELECT count(*) FROM provider_runs WHERE provider_id='codex-extract' AND outcome='completed-unsettled') || ':' || (SELECT count(*) FROM job_items WHERE item_type='claim-extraction' AND state='running');"
    OUTPUT_VARIABLE crash_state OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE crash_state_err RESULT_VARIABLE crash_state_result)
if(NOT crash_state_result EQUAL 0 OR NOT crash_state STREQUAL "1:1")
    message(FATAL_ERROR "Codex completed turn was not durable at the crash boundary: ${crash_state} ${crash_state_err}")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
    "UPDATE job_items SET lease_until=0 WHERE item_type='claim-extraction' AND state='running';"
    RESULT_VARIABLE expiry_result ERROR_VARIABLE expiry_err)
if(NOT expiry_result EQUAL 0)
    message(FATAL_ERROR "could not expire the simulated crashed lease: ${expiry_err}")
endif()

execute_process(COMMAND ${cli} --library "${library}"
    --config-file "${CPRAG_WORK_DIR}/crexxrag.conf"
    --profile it-architecture-profile --access control --format json --progress plain
    worker run --once --poll-ms 20 --max-polls 2 --job "${job_id}"
    OUTPUT_VARIABLE recovery_out ERROR_VARIABLE recovery_err
    RESULT_VARIABLE recovery_result TIMEOUT 30)
if(NOT recovery_result EQUAL 0 OR
   NOT recovery_out MATCHES "\"items_processed\":1" OR
   recovery_out MATCHES "SIGNAL OUT_OF_RANGE" OR
   recovery_err MATCHES "SIGNAL OUT_OF_RANGE")
    message(FATAL_ERROR "Codex application recovery failed:\n${recovery_out}${recovery_err}")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
    "SELECT count(*) FROM job_events WHERE event_type='provider-receipt-reused';"
    OUTPUT_VARIABLE receipt_reuse OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT receipt_reuse STREQUAL "1")
    message(FATAL_ERROR "Completed response was not durably reused exactly once: ${receipt_reuse}")
endif()

execute_process(COMMAND ${cli} --library "${library}"
    --config-file "${CPRAG_WORK_DIR}/crexxrag.conf"
    --profile it-architecture-profile --access control --format json --progress plain
    worker run --once --poll-ms 20 --max-polls 2 --job "${job_id}"
    OUTPUT_VARIABLE embedding_out ERROR_VARIABLE embedding_err
    RESULT_VARIABLE embedding_result TIMEOUT 30)
if(NOT embedding_result EQUAL 0 OR NOT embedding_out MATCHES "\"items_processed\":1")
    message(FATAL_ERROR "Codex application embedding completion failed:\n${embedding_out}${embedding_err}")
endif()

file(READ "${codex_log}" codex_methods)
string(REGEX MATCHALL "turn/start" turn_starts "${codex_methods}")
list(LENGTH turn_starts turn_start_count)
string(REGEX MATCHALL "thread/start" thread_starts "${codex_methods}")
list(LENGTH thread_starts thread_start_count)
if(NOT turn_start_count EQUAL 1 OR NOT thread_start_count EQUAL 1)
    message(FATAL_ERROR "Codex recovery created duplicate external work:\n${codex_methods}")
endif()

execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
    "SELECT (SELECT count(*) FROM provider_runs WHERE provider_id='codex-extract' AND outcome='succeeded' AND charging_basis='subscription-allowance') || ':' || (SELECT count(*) FROM candidate_mentions WHERE extractor_version='provider-discovery-v2') || ':' || (SELECT count(*) FROM claims WHERE visible_to_generation IS NULL) || ':' || (SELECT count(*) FROM claim_support WHERE visible_to_generation IS NULL) || ':' || (SELECT count(*) FROM job_items WHERE state='dead_letter');"
    OUTPUT_VARIABLE final_state OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE final_state_err RESULT_VARIABLE final_state_result)
if(NOT final_state_result EQUAL 0 OR NOT final_state STREQUAL "1:4:1:2:0")
    message(FATAL_ERROR "Codex application result was not validated and promoted exactly once: ${final_state} ${final_state_err}")
endif()

execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
    "SELECT input_tokens FROM provider_runs WHERE provider_id='codex-extract' AND outcome='succeeded';"
    OUTPUT_VARIABLE retained_input OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE retained_input_result)
if(NOT retained_input_result EQUAL 0 OR NOT retained_input STREQUAL "20000")
    message(FATAL_ERROR "Codex recovery must retain full managed-context usage: ${retained_input}")
endif()

execute_process(COMMAND ${cli} --library "${library}" --access diagnose
    --format json library verify
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
    RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "\"state\":\"verified\"" OR
   verify_out MATCHES "\"issue_count\":[1-9]")
    message(FATAL_ERROR "Codex application library verification failed:\n${verify_out}${verify_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/summary.txt"
    "Codex application extraction passed through the public worker surface; a persisted completed turn survived a simulated worker crash, recovered without a second turn, validated four mentions/two supports, settled subscription allowance, and verified the library.\n")
