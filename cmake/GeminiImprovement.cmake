foreach(required_var CPRAG_NATIVE_APPLICATION CPRAG_LOOPBACK
        CPRAG_CONFIG_TEMPLATE CPRAG_PROPOSAL_FIXTURE CPRAG_WORK_DIR)
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
    "${CPRAG_WORK_DIR}/crexxrag.conf" @ONLY)

set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 3 product-ingestion; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p4r-01 "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start Gemini improvement loopback")
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
    message(FATAL_ERROR "Gemini improvement loopback did not become ready")
endif()

if(NOT EXISTS "${CPRAG_NATIVE_APPLICATION}")
    message(FATAL_ERROR "native crexxrag application is required")
endif()
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
    "${CPRAG_NATIVE_APPLICATION}")

execute_process(COMMAND ${cli} init
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err
    RESULT_VARIABLE init_result TIMEOUT 30)
if(NOT init_result EQUAL 0 OR NOT init_out MATCHES "schema version: 1")
    message(FATAL_ERROR "Improvement test human init failed:\n${init_out}${init_err}")
endif()

execute_process(COMMAND ${cli} ingest --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE ingest_out ERROR_VARIABLE ingest_err
    RESULT_VARIABLE ingest_result TIMEOUT 60)
if(NOT ingest_result EQUAL 0 OR
   NOT ingest_out MATCHES "items queued: 2" OR
   NOT ingest_out MATCHES "state: completed" OR
   NOT ingest_out MATCHES "planned total: 2")
    message(FATAL_ERROR "Improvement prerequisite ingestion failed:\n${ingest_out}${ingest_err}")
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
    message(FATAL_ERROR "Machine improvement preview failed:\n${plan_out}${plan_err}")
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
    message(FATAL_ERROR "Guided improvement failed:\n${improve_out}${improve_err}")
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
    message(FATAL_ERROR "Improvement replay was not a zero-call no-op:\n${replay_out}${replay_err}")
endif()

# Exercise the enduring discovery and external-proposal surfaces against the
# same real, Gemini-ingested library. These operations make no provider calls.
find_program(CREXXRAG_SQLITE3 sqlite3 REQUIRED)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
        "SELECT revision_chunk_id FROM revision_chunks WHERE visible_to_generation IS NULL ORDER BY revision_chunk_id LIMIT 1"
    OUTPUT_VARIABLE CREXXRAG_PROPOSAL_CHUNK
    ERROR_VARIABLE proposal_chunk_err RESULT_VARIABLE proposal_chunk_result
    OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT proposal_chunk_result EQUAL 0 OR CREXXRAG_PROPOSAL_CHUNK STREQUAL "")
    message(FATAL_ERROR "could not select the active evidence chunk: ${proposal_chunk_err}")
endif()
configure_file("${CPRAG_PROPOSAL_FIXTURE}"
    "${CPRAG_WORK_DIR}/external-proposal.ndjson" @ONLY)
execute_process(COMMAND ${cli} --format json provider list
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE provider_list_out ERROR_VARIABLE provider_list_err
    RESULT_VARIABLE provider_list_result TIMEOUT 30)
execute_process(COMMAND ${cli} --format json profile list
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE profile_list_out ERROR_VARIABLE profile_list_err
    RESULT_VARIABLE profile_list_result TIMEOUT 30)
execute_process(COMMAND ${cli} --format json profile show it-architecture-profile
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE profile_show_out ERROR_VARIABLE profile_show_err
    RESULT_VARIABLE profile_show_result TIMEOUT 30)
if(NOT provider_list_result EQUAL 0 OR
   NOT provider_list_out MATCHES "\"provider_id\":\"gemini-generate\"" OR
   NOT provider_list_out MATCHES "\"provider_id\":\"gemini-embed\"" OR
   NOT profile_list_result EQUAL 0 OR
   NOT profile_list_out MATCHES "\"profile_id\":\"it-architecture-profile\"" OR
   NOT profile_show_result EQUAL 0 OR
   NOT profile_show_out MATCHES "\"relationship_type\":\"depends-on\"")
    message(FATAL_ERROR "provider/profile discovery failed:\n${provider_list_out}${provider_list_err}${profile_list_out}${profile_list_err}${profile_show_out}${profile_show_err}")
endif()

execute_process(COMMAND ${cli} --profile it-architecture-profile --access plan
        --format json proposal plan --input "${CPRAG_WORK_DIR}/external-proposal.ndjson"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE proposal_plan_out ERROR_VARIABLE proposal_plan_err
    RESULT_VARIABLE proposal_plan_result TIMEOUT 30)
string(JSON proposal_plan ERROR_VARIABLE proposal_plan_json_error GET
    "${proposal_plan_out}" records 0 fields canonical_plan)
string(JSON proposal_digest ERROR_VARIABLE proposal_digest_json_error GET
    "${proposal_plan_out}" records 0 fields digest)
if(NOT proposal_plan_result EQUAL 0 OR proposal_plan_json_error OR
   proposal_digest_json_error OR
   NOT proposal_plan_out MATCHES "\"library_writes\":0")
    message(FATAL_ERROR "external proposal planning failed:\n${proposal_plan_out}${proposal_plan_err}")
endif()
execute_process(COMMAND ${cli} --profile it-architecture-profile --access curate
        --format json proposal apply --plan-json "${proposal_plan}"
        --expect-digest "${proposal_digest}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE proposal_apply_out ERROR_VARIABLE proposal_apply_err
    RESULT_VARIABLE proposal_apply_result TIMEOUT 30)
if(NOT proposal_apply_result EQUAL 0 OR
   NOT proposal_apply_out MATCHES "\"reviews_created\":1")
    message(FATAL_ERROR "external proposal apply failed:\n${proposal_apply_out}${proposal_apply_err}")
endif()
execute_process(COMMAND ${cli} --format json review list
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE review_list_out ERROR_VARIABLE review_list_err
    RESULT_VARIABLE review_list_result TIMEOUT 30)
string(JSON review_count ERROR_VARIABLE review_count_error LENGTH
    "${review_list_out}" records)
set(external_review_id "")
if(NOT review_count_error)
    math(EXPR review_last "${review_count} - 1")
    foreach(index RANGE 0 ${review_last})
        string(JSON review_name ERROR_VARIABLE review_name_error GET
            "${review_list_out}" records ${index} fields name)
        if(NOT review_name_error AND review_name STREQUAL "external-proposal")
            string(JSON external_review_id GET
                "${review_list_out}" records ${index} fields identity)
        endif()
    endforeach()
endif()
if(NOT review_list_result EQUAL 0 OR external_review_id STREQUAL "")
    message(FATAL_ERROR "external proposal review was not visible:\n${review_list_out}${review_list_err}")
endif()
execute_process(COMMAND ${cli} --profile it-architecture-profile --access curate
        --format json review decide "${external_review_id}"
        --decision accept --apply
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE review_decide_out ERROR_VARIABLE review_decide_err
    RESULT_VARIABLE review_decide_result TIMEOUT 30)
if(NOT review_decide_result EQUAL 0 OR
   NOT review_decide_out MATCHES "\"state\":\"accepted\"" OR
   NOT review_decide_out MATCHES "\"promotion_disposition\":\"accepted\"")
    message(FATAL_ERROR "external proposal review promotion failed:\n${review_decide_out}${review_decide_err}")
endif()

execute_process(COMMAND ${cli} --access diagnose library verify
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
    RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "state: verified" OR
   NOT verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "Improved library verification failed:\n${verify_out}${verify_err}")
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
    message(FATAL_ERROR "Gemini improvement loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=product-ingestion connections=3")
    message(FATAL_ERROR "Gemini improvement loopback failed:\n${final_server_out}${final_server_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "test=gemini-improvement\nprovider=gemini\nrequests=3\n"
    "ingest_calls=2\nimprovement_calls=1\nreplay_calls=0\n"
    "surface=crexxrag-improve\nprovider_input=durable\nvector_output=not-applicable-hidden\n"
    "${init_out}${ingest_out}${ingest_err}${plan_out}${plan_err}${improve_out}${improve_err}${replay_out}${replay_err}${provider_list_out}${profile_list_out}${profile_show_out}${proposal_plan_out}${proposal_apply_out}${review_list_out}${review_decide_out}${verify_out}${verify_err}")
message(STATUS "Gemini improvement and the public provider, profile, proposal, and review surfaces passed with integrity verification and zero-call replay")
