foreach(required_var CPRAG_RXVME CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION
        CPRAG_NATIVE_APPLICATION CPRAG_LOOPBACK CPRAG_CONFIG_TEMPLATE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/source")
file(WRITE "${CPRAG_WORK_DIR}/source/architecture.txt"
    "BillingService depends on CustomerDatabase.\n"
    "BillingService depends on CustomerDatabase.\n")
set(CPRAG_FIXTURE_PORT 18997)
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source")
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/gemini-loopback.conf" @ONLY)

get_filename_component(application_dir "${CPRAG_APPLICATION}" DIRECTORY)
set(load_path
    "${application_dir}/providers;${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
string(REPLACE ";" "\\;" escaped_load_path "${load_path}")
set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 4 product-ingestion; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p3r-02 "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start product Gemini loopback")
endif()
set(ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${server_out}")
        file(READ "${server_out}" current_server_out)
        if(current_server_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT ready)
    message(FATAL_ERROR "product Gemini loopback did not become ready")
endif()

set(config "${CPRAG_WORK_DIR}/gemini-loopback.conf")
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/crexx-rag.conf" @ONLY)
set(library "${CPRAG_WORK_DIR}/machine-library")
if(NOT EXISTS "${CPRAG_NATIVE_APPLICATION}")
    message(FATAL_ERROR "native crexx-rag application is required for CRI-17-safe provider execution")
endif()
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXX_RAG_SELF=${CPRAG_NATIVE_APPLICATION}"
    "${CPRAG_NATIVE_APPLICATION}")

execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access admin --format json library init
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err RESULT_VARIABLE init_result TIMEOUT 30)
if(NOT init_result EQUAL 0 OR NOT init_out MATCHES "\"schema_version\":5")
    message(FATAL_ERROR "Gemini product library init failed:\n${init_out}${init_err}")
endif()

execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access plan --format json
    ingest plan --source-set architecture-docs
    OUTPUT_VARIABLE plan_out ERROR_VARIABLE plan_err RESULT_VARIABLE plan_result TIMEOUT 30)
if(NOT plan_result EQUAL 0)
    message(FATAL_ERROR "Gemini product ingest plan failed:\n${plan_out}${plan_err}")
endif()
string(JSON plan_json ERROR_VARIABLE plan_json_error GET "${plan_out}" records 0 fields canonical_plan)
string(JSON plan_digest ERROR_VARIABLE plan_digest_error GET "${plan_out}" records 0 fields digest)
if(plan_json_error OR plan_digest_error)
    message(FATAL_ERROR "Gemini product plan was not reviewable: ${plan_out}")
endif()

execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access ingest --format json --progress plain
    ingest apply --plan-json "${plan_json}" --expect-digest "${plan_digest}"
    OUTPUT_VARIABLE apply_out ERROR_VARIABLE apply_err RESULT_VARIABLE apply_result TIMEOUT 30)
if(NOT apply_result EQUAL 0 OR NOT apply_out MATCHES "\"items_queued\":2" OR
   NOT apply_err MATCHES "crexxrag ingest start" OR
   NOT apply_err MATCHES "crexxrag ingest complete")
    message(FATAL_ERROR "Gemini product ingest apply/trace failed:\n${apply_out}${apply_err}")
endif()
string(JSON job_id ERROR_VARIABLE job_error GET "${apply_out}" records 0 fields job_id)
if(job_error OR job_id STREQUAL "")
    message(FATAL_ERROR "Gemini product apply did not expose a job id")
endif()

execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access control --format json --progress plain
    worker run --once --poll-ms 20 --max-polls 4 --job "${job_id}"
    OUTPUT_VARIABLE worker_out ERROR_VARIABLE worker_err RESULT_VARIABLE worker_result TIMEOUT 60)
if(NOT worker_result EQUAL 0 OR
   NOT worker_out MATCHES "\"processor\":\"application-ingestion-v1\"" OR
   NOT worker_out MATCHES "\"items_processed\":1" OR
   NOT worker_err MATCHES "crexxrag provider start" OR
   NOT worker_err MATCHES "crexxrag provider complete" OR
   NOT worker_err MATCHES "crexxrag work processed" OR
   worker_out MATCHES "synthetic-product-gemini-key" OR
   worker_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "Gemini product worker/trace failed:\n${worker_out}${worker_err}")
endif()

execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access control --format json --progress plain
    worker start --count 2 --poll-ms 20 --max-polls 4 --job "${job_id}"
    OUTPUT_VARIABLE controller_out ERROR_VARIABLE controller_err RESULT_VARIABLE controller_result TIMEOUT 60)
if(NOT controller_result EQUAL 0 OR
   NOT controller_out MATCHES "\"workers_requested\":2" OR
   NOT controller_out MATCHES "\"workers_completed\":2" OR
   NOT controller_out MATCHES "\"workers_failed\":0" OR
   NOT controller_out MATCHES "\"vector_generations\":1" OR
   NOT controller_out MATCHES "\"vector_state\":\"published\"" OR
   NOT controller_err MATCHES "crexxrag controller start" OR
   NOT controller_err MATCHES "crexxrag controller complete" OR
   controller_out MATCHES "synthetic-product-gemini-key" OR
   controller_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "Gemini product process group failed:\n${controller_out}${controller_err}")
endif()
file(GLOB machine_vectors "${library}/vectors.*.rxvec")
list(LENGTH machine_vectors machine_vector_count)
if(NOT machine_vector_count EQUAL 1)
    message(FATAL_ERROR "completed machine ingestion did not publish exactly one immutable vector sidecar")
endif()

# A failing child process must survive supervision as a useful product error,
# never the blank `ERROR:` that originally hid the worker runtime detail.
set(failed_child "${CPRAG_WORK_DIR}/missing-crexx-rag-child")
set(failing_cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXX_RAG_SELF=${failed_child}"
    "NO_COLOR=1"
    "${CPRAG_NATIVE_APPLICATION}")
execute_process(COMMAND ${failing_cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access control --progress off
    worker start --count 1 --poll-ms 20 --max-polls 2 --job "${job_id}"
    OUTPUT_VARIABLE failed_child_out ERROR_VARIABLE failed_child_err
    RESULT_VARIABLE failed_child_result TIMEOUT 30)
if(failed_child_result EQUAL 0 OR
   NOT failed_child_out MATCHES "ERROR: one or more worker processes failed:" OR
   failed_child_out MATCHES "ERROR:[ \r\n]*$" OR
   failed_child_out MATCHES "synthetic-product-gemini-key" OR
   failed_child_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "failed child did not expose a meaningful controller error:\n${failed_child_out}${failed_child_err}")
endif()

# A child that dies after registering must be made terminal by the controller;
# otherwise it remains an apparently live idle/running row until stale pruning.
set(abrupt_child "${CPRAG_WORK_DIR}/abrupt-crexxrag-child.sh")
file(WRITE "${abrupt_child}" [=[#!/bin/sh
"$CPRAG_REAL_NATIVE" "$@" &
child=$!
sleep 0.2
kill -KILL "$child" 2>/dev/null || true
wait "$child" 2>/dev/null || true
exit 99
]=])
file(CHMOD "${abrupt_child}"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
set(abrupt_cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CPRAG_REAL_NATIVE=${CPRAG_NATIVE_APPLICATION}"
    "CREXX_RAG_SELF=${abrupt_child}"
    "NO_COLOR=1"
    "${CPRAG_NATIVE_APPLICATION}")
execute_process(COMMAND ${abrupt_cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access control --progress off
    worker start --count 1 --poll-ms 20 --max-polls 200
    OUTPUT_VARIABLE abrupt_child_out ERROR_VARIABLE abrupt_child_err
    RESULT_VARIABLE abrupt_child_result TIMEOUT 30)
if(abrupt_child_result EQUAL 0 OR
   NOT abrupt_child_out MATCHES "ERROR: one or more worker processes failed: child process exited with code 99 after worker registration" OR
   abrupt_child_out MATCHES "synthetic-product-gemini-key" OR
   abrupt_child_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "abrupt registered child did not become a useful terminal failure:\n${abrupt_child_out}${abrupt_child_err}")
endif()
execute_process(COMMAND ${cli} --library "${library}" --access read --format json
    worker list --state failed --stale-seconds 5
    OUTPUT_VARIABLE abrupt_list_out ERROR_VARIABLE abrupt_list_err
    RESULT_VARIABLE abrupt_list_result TIMEOUT 30)
if(NOT abrupt_list_result EQUAL 0 OR
   NOT abrupt_list_out MATCHES "\"state\":\"failed\"" OR
   NOT abrupt_list_out MATCHES "child process exited with code 99 after worker registration")
    message(FATAL_ERROR "abrupt registered child row was not terminal:\n${abrupt_list_out}${abrupt_list_err}")
endif()

execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access read --format json
    job status "${job_id}"
    OUTPUT_VARIABLE status_out ERROR_VARIABLE status_err RESULT_VARIABLE status_result TIMEOUT 30)
if(NOT status_result EQUAL 0 OR NOT status_out MATCHES "\"state\":\"completed\"" OR
   NOT status_out MATCHES "\"processed\":2" OR
   NOT status_out MATCHES "\"dead_letter\":0")
    message(FATAL_ERROR "Gemini product job did not complete:\n${status_out}${status_err}")
endif()

execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
    --profile it-architecture-profile --access read --format json
    query evidence "What does BillingService depend on?" --limit 5
    OUTPUT_VARIABLE query_out ERROR_VARIABLE query_err RESULT_VARIABLE query_result TIMEOUT 30)
if(NOT query_result EQUAL 0 OR NOT query_out MATCHES "\"candidate_count\":1" OR
   NOT query_out MATCHES "depends-on" OR NOT query_out MATCHES "claim-sha256:" OR
   NOT query_out MATCHES "utf8-0-87")
    message(FATAL_ERROR "Gemini product evidence query failed:\n${query_out}${query_err}")
endif()

execute_process(COMMAND ${cli} --library "${library}" --access diagnose
    --format json library verify
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "\"state\":\"verified\"" OR
   verify_out MATCHES "\"issue_count\":[1-9]")
    message(FATAL_ERROR "Gemini product library verification failed:\n${verify_out}${verify_err}")
endif()

# The enduring human surface discovers ./crexx-rag.conf and ./library, binds
# its only profile, preserves plan/apply confirmation, and supervises the
# configured native workers without shell orchestration or CREXX_RAG_SELF.
file(COPY "${CPRAG_NATIVE_APPLICATION}" DESTINATION "${CPRAG_WORK_DIR}"
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
    GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
set(human_application "${CPRAG_WORK_DIR}/crexxrag")
set(human_cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "NO_COLOR=1"
    "${human_application}")
execute_process(COMMAND ${human_cli} --help
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE human_help_out ERROR_VARIABLE human_help_err
    RESULT_VARIABLE human_help_result TIMEOUT 30)
if(NOT human_help_result EQUAL 0 OR
   NOT human_help_out MATCHES "crexxrag init" OR
   NOT human_help_out MATCHES "crexxrag ingest" OR
   NOT human_help_out MATCHES "crexxrag query" OR
   human_help_out MATCHES "\\{\"schema\"")
    message(FATAL_ERROR "Human help failed:\n${human_help_out}${human_help_err}")
endif()

execute_process(COMMAND ${human_cli} init
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE human_init_out ERROR_VARIABLE human_init_err
    RESULT_VARIABLE human_init_result TIMEOUT 30)
if(NOT human_init_result EQUAL 0 OR
   NOT human_init_out MATCHES "OK: library initialized" OR
   human_init_out MATCHES "canonical_plan|\\{\"schema\"")
    message(FATAL_ERROR "Human default init failed:\n${human_init_out}${human_init_err}")
endif()

execute_process(COMMAND ${human_cli} ingest --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE human_ingest_out ERROR_VARIABLE human_ingest_err
    RESULT_VARIABLE human_ingest_result TIMEOUT 120)
if(NOT human_ingest_result EQUAL 0 OR
   NOT human_ingest_out MATCHES "Ingestion plan" OR
   NOT human_ingest_out MATCHES "Monetary API cost: Not applicable" OR
   NOT human_ingest_out MATCHES "Worker processes: 2" OR
   NOT human_ingest_out MATCHES "state: completed" OR
   NOT human_ingest_out MATCHES "processed: 2" OR
   NOT human_ingest_out MATCHES "vector generations: 1" OR
   NOT human_ingest_out MATCHES "vector state: published" OR
   human_ingest_out MATCHES "canonical_plan|\\{\"schema\"" OR
   NOT human_ingest_err MATCHES "crexxrag controller start" OR
   NOT human_ingest_err MATCHES "crexxrag worker complete" OR
   human_ingest_out MATCHES "synthetic-product-gemini-key" OR
   human_ingest_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "Human guided ingest failed:\n${human_ingest_out}${human_ingest_err}")
endif()
file(GLOB human_vectors "${CPRAG_WORK_DIR}/library/vectors.*.rxvec")
list(LENGTH human_vectors human_vector_count)
if(NOT human_vector_count EQUAL 1)
    message(FATAL_ERROR "completed human ingestion did not publish exactly one immutable vector sidecar")
endif()

# Re-applying an unchanged source set is a successful, truthful no-op.  It
# must not synthesize a job identity or launch workers/provider calls.
execute_process(COMMAND ${human_cli} ingest --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE human_noop_out ERROR_VARIABLE human_noop_err
    RESULT_VARIABLE human_noop_result TIMEOUT 30)
if(NOT human_noop_result EQUAL 0 OR
   NOT human_noop_out MATCHES "source set is already current" OR
   NOT human_noop_out MATCHES "disposition: identical-no-op" OR
   NOT human_noop_out MATCHES "items queued: 0" OR
   human_noop_out MATCHES "job id:" OR
   human_noop_err MATCHES "crexxrag (controller|worker|provider)" OR
   human_noop_out MATCHES "canonical_plan|\\{\"schema\"" OR
   human_noop_out MATCHES "synthetic-product-gemini-key" OR
   human_noop_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "Human unchanged ingest was not a clean zero-work success:\n${human_noop_out}${human_noop_err}")
endif()

execute_process(COMMAND ${human_cli} query
    "What does BillingService depend on?"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE human_query_out ERROR_VARIABLE human_query_err
    RESULT_VARIABLE human_query_result TIMEOUT 30)
if(NOT human_query_result EQUAL 0 OR
   NOT human_query_out MATCHES "candidate count: 1" OR
   NOT human_query_out MATCHES "BillingService --depends-on--> CustomerDatabase" OR
   NOT human_query_out MATCHES "citation: .*utf8-0-87" OR
   human_query_out MATCHES "evidence_json|\\{\"schema\"")
    message(FATAL_ERROR "Human query shorthand failed:\n${human_query_out}${human_query_err}")
endif()

set(exited FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${server_status}")
        set(exited TRUE)
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT exited)
    message(FATAL_ERROR "product Gemini loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=product-ingestion connections=4")
    message(FATAL_ERROR "product Gemini loopback failed:\n${final_server_out}${final_server_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "item=P3R-02\nprovider=gemini\nrequests=4\nitems=4\n"
    "trace=stderr-plain\nstdout=json-stable\ncredentials=not-retained\n"
    "human_ui=help+local-defaults+guided-ingest+zero-work-replay+query-summary\n"
    "vector_publication=machine+human\ncontroller_error=pre-registration+post-registration\n"
    "${apply_out}${apply_err}${worker_out}${worker_err}${controller_out}${controller_err}${failed_child_out}${failed_child_err}${abrupt_child_out}${abrupt_child_err}${abrupt_list_out}${status_out}${query_out}${verify_out}${human_init_out}${human_ingest_out}${human_ingest_err}${human_noop_out}${human_noop_err}${human_query_out}")
message(STATUS "P3R-02 passed canonical JSON and human-default Gemini ingestion through native workers, truthful replay, vector publication, meaningful pre/post-registration child failure, evidence retrieval, integrity verification, and sanitized progress")
