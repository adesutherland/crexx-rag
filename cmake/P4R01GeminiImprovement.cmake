foreach(required_var CPRAG_NATIVE_APPLICATION CPRAG_LOOPBACK
        CPRAG_CONFIG_TEMPLATE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/source")
file(WRITE "${CPRAG_WORK_DIR}/source/architecture.txt"
    "BillingService depends on CustomerDatabase.\n"
    "BillingService depends on CustomerDatabase.\n")
set(CPRAG_FIXTURE_PORT 18998)
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source")
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/crexx-rag.conf" @ONLY)

set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 3 product-ingestion; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p4r-01 "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start Phase-4 Gemini loopback")
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
    message(FATAL_ERROR "Phase-4 Gemini loopback did not become ready")
endif()

if(NOT EXISTS "${CPRAG_NATIVE_APPLICATION}")
    message(FATAL_ERROR "native crexxrag application is required")
endif()
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXX_RAG_SELF=${CPRAG_NATIVE_APPLICATION}"
    "${CPRAG_NATIVE_APPLICATION}")

execute_process(COMMAND ${cli} init
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err
    RESULT_VARIABLE init_result TIMEOUT 30)
if(NOT init_result EQUAL 0 OR NOT init_out MATCHES "schema version: 5")
    message(FATAL_ERROR "Phase-4 human init failed:\n${init_out}${init_err}")
endif()

execute_process(COMMAND ${cli} ingest --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE ingest_out ERROR_VARIABLE ingest_err
    RESULT_VARIABLE ingest_result TIMEOUT 60)
if(NOT ingest_result EQUAL 0 OR
   NOT ingest_out MATCHES "items queued: 2" OR
   NOT ingest_out MATCHES "state: completed" OR
   NOT ingest_out MATCHES "planned total: 2")
    message(FATAL_ERROR "Phase-4 prerequisite ingestion failed:\n${ingest_out}${ingest_err}")
endif()

execute_process(COMMAND ${cli} --format json --access plan improve plan
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE plan_out ERROR_VARIABLE plan_err
    RESULT_VARIABLE plan_result TIMEOUT 30)
if(NOT plan_result EQUAL 0 OR
   NOT plan_out MATCHES "\"items_planned\":1" OR
   NOT plan_out MATCHES "\"provider_id\":\"gemini-generate\"" OR
   NOT plan_out MATCHES "\"charging_basis\":\"local-compute\"" OR
   NOT plan_out MATCHES "\"worker_processes\":2")
    message(FATAL_ERROR "Phase-4 machine improvement preview failed:\n${plan_out}${plan_err}")
endif()

execute_process(COMMAND ${cli} improve --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE improve_out ERROR_VARIABLE improve_err
    RESULT_VARIABLE improve_result TIMEOUT 60)
if(NOT improve_result EQUAL 0 OR
   NOT improve_out MATCHES "Improvement plan" OR
   NOT improve_out MATCHES "Items selected:   1" OR
   NOT improve_out MATCHES "Extraction:       gemini / gemini-3.5-flash-lite" OR
   NOT improve_out MATCHES "Monetary API cost: Not applicable" OR
   NOT improve_out MATCHES "disposition: queued" OR
   NOT improve_out MATCHES "items: 1" OR
   NOT improve_out MATCHES "state: completed" OR
   NOT improve_out MATCHES "planned total: 1" OR
   improve_out MATCHES "canonical_plan|\{\"schema\"|vector state" OR
   NOT improve_err MATCHES "crexxrag controller complete")
    message(FATAL_ERROR "Phase-4 guided improvement failed:\n${improve_out}${improve_err}")
endif()

execute_process(COMMAND ${cli} improve --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE replay_out ERROR_VARIABLE replay_err
    RESULT_VARIABLE replay_result TIMEOUT 30)
if(NOT replay_result EQUAL 0 OR
   NOT replay_out MATCHES "Items selected:   1" OR
   NOT replay_out MATCHES "disposition: identical-no-op" OR
   NOT replay_out MATCHES "items: 0" OR
   replay_err MATCHES "crexxrag (controller|worker|provider)")
    message(FATAL_ERROR "Phase-4 improvement replay was not a zero-call no-op:\n${replay_out}${replay_err}")
endif()

execute_process(COMMAND ${cli} --access diagnose library verify
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
    RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "state: verified" OR
   NOT verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "Phase-4 improved library verification failed:\n${verify_out}${verify_err}")
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
    message(FATAL_ERROR "Phase-4 Gemini loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=product-ingestion connections=3")
    message(FATAL_ERROR "Phase-4 Gemini loopback failed:\n${final_server_out}${final_server_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "item=P4R-01\nprovider=gemini\nrequests=3\n"
    "ingest_calls=2\nimprovement_calls=1\nreplay_calls=0\n"
    "surface=crexxrag-improve\nprovider_input=durable\nvector_output=not-applicable-hidden\n"
    "${init_out}${ingest_out}${ingest_err}${plan_out}${plan_err}${improve_out}${improve_err}${replay_out}${replay_err}${verify_out}${verify_err}")
message(STATUS "P4R-01 passed reviewed human improvement through a configured Gemini worker with durable inputs, clean output, integrity verification, and zero-call replay")
