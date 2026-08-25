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
set(CPRAG_FIXTURE_PORT 18999)
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source")
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/crexx-rag.conf" @ONLY)

if(NOT EXISTS "${CPRAG_NATIVE_APPLICATION}")
    message(FATAL_ERROR "native crexxrag application is required")
endif()
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXX_RAG_SELF=${CPRAG_NATIVE_APPLICATION}"
    "NO_COLOR=1"
    "${CPRAG_NATIVE_APPLICATION}")

set(server_out "${CPRAG_WORK_DIR}/positive-loopback.out")
set(server_err "${CPRAG_WORK_DIR}/positive-loopback.err")
set(server_status "${CPRAG_WORK_DIR}/positive-loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 4 product-query; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p5r-01 "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start Phase-5 Gemini loopback")
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
    message(FATAL_ERROR "Phase-5 Gemini loopback did not become ready")
endif()

execute_process(COMMAND ${cli} init
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err
    RESULT_VARIABLE init_result TIMEOUT 30)
if(NOT init_result EQUAL 0 OR NOT init_out MATCHES "schema version: 5")
    message(FATAL_ERROR "Phase-5 human init failed:\n${init_out}${init_err}")
endif()

execute_process(COMMAND ${cli} ingest --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE ingest_out ERROR_VARIABLE ingest_err
    RESULT_VARIABLE ingest_result TIMEOUT 90)
if(NOT ingest_result EQUAL 0 OR
   NOT ingest_out MATCHES "state: completed" OR
   NOT ingest_out MATCHES "processed: 2" OR
   NOT ingest_out MATCHES "vector state: published")
    message(FATAL_ERROR "Phase-5 prerequisite ingestion failed:\n${ingest_out}${ingest_err}")
endif()

# With an answerer in the local config, the enduring shorthand performs one
# compatible query embedding and one schema-constrained answer call.
execute_process(COMMAND ${cli} query "What does BillingService depend on?"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE query_out ERROR_VARIABLE query_err
    RESULT_VARIABLE query_result TIMEOUT 60)
if(NOT query_result EQUAL 0 OR
   NOT query_out MATCHES "OK: evidence-backed answer generated with validated citations" OR
   NOT query_out MATCHES "vector state: active-exact-rxvector" OR
   NOT query_out MATCHES "generated answer: BillingService depends on CustomerDatabase" OR
   NOT query_out MATCHES "retrieval mode: hybrid" OR
   NOT query_out MATCHES "query embedding state: generated" OR
   NOT query_out MATCHES "provider calls: 2" OR
   NOT query_out MATCHES "citation: .*utf8-0-87" OR
   NOT query_out MATCHES "role: embedding" OR
   NOT query_out MATCHES "role: answerer" OR
   NOT query_out MATCHES "charging basis: local-compute" OR
   query_out MATCHES "evidence_json|canonical_plan|synthetic-product-gemini-key" OR
   NOT query_err MATCHES "crexxrag query-embedding complete" OR
   NOT query_err MATCHES "crexxrag answer complete" OR
   query_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "Phase-5 human hybrid answer failed:\n${query_out}${query_err}")
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
    message(FATAL_ERROR "Phase-5 positive Gemini loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=product-query connections=4")
    message(FATAL_ERROR "Phase-5 positive Gemini loopback failed:\n${final_server_out}${final_server_err}")
endif()

# Lexical evidence is an explicit zero-outbound route even when embedding and
# answer providers are configured and a vector sidecar is active.
set(zero_out "${CPRAG_WORK_DIR}/zero-loopback.out")
set(zero_err "${CPRAG_WORK_DIR}/zero-loopback.err")
set(zero_status "${CPRAG_WORK_DIR}/zero-loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 0 zero-outbound; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p5r-01-zero "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${zero_out}"
    "${zero_err}" "${zero_status}"
    RESULT_VARIABLE zero_launch_result)
if(NOT zero_launch_result EQUAL 0)
    message(FATAL_ERROR "could not start Phase-5 zero-outbound observer")
endif()
set(zero_ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${zero_out}")
        file(READ "${zero_out}" current_zero_out)
        if(current_zero_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(zero_ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT zero_ready)
    message(FATAL_ERROR "Phase-5 zero-outbound observer did not become ready")
endif()
execute_process(COMMAND ${cli} --format json --progress plain query evidence
    "What does BillingService depend on?" --mode lexical
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE lexical_out ERROR_VARIABLE lexical_err
    RESULT_VARIABLE lexical_result TIMEOUT 30)
if(NOT lexical_result EQUAL 0 OR
   NOT lexical_out MATCHES "\"vector_state\":\"disabled\"" OR
   NOT lexical_out MATCHES "\"retrieval_mode\":\"lexical\"" OR
   NOT lexical_out MATCHES "\"query_embedding_state\":\"not-requested\"" OR
   NOT lexical_out MATCHES "\"provider_calls\":0" OR
   NOT lexical_out MATCHES "\"generated_answer\":null" OR
   lexical_err MATCHES "crexxrag (query-embedding|answer)")
    message(FATAL_ERROR "Phase-5 explicit lexical query was not a clean zero-call route:\n${lexical_out}${lexical_err}")
endif()
foreach(poll RANGE 1 200)
    if(EXISTS "${zero_status}")
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT EXISTS "${zero_status}")
    message(FATAL_ERROR "Phase-5 zero-outbound observer did not exit")
endif()
file(READ "${zero_status}" zero_result)
file(READ "${zero_out}" final_zero_out)
if(NOT zero_result STREQUAL "0" OR
   NOT final_zero_out MATCHES "SUMMARY scenario=zero-outbound connections=0")
    message(FATAL_ERROR "Phase-5 lexical query made an outbound request:\n${final_zero_out}")
endif()

# Hybrid is required, not advisory: with the compatible endpoint unavailable
# the command must fail instead of silently claiming hybrid retrieval.
execute_process(COMMAND ${cli} --format json --progress plain query evidence
    "What does BillingService depend on?"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE auto_fallback_out ERROR_VARIABLE auto_fallback_err
    RESULT_VARIABLE auto_fallback_result TIMEOUT 30)
if(NOT auto_fallback_result EQUAL 0 OR
   NOT auto_fallback_out MATCHES "\"vector_state\":\"disabled\"" OR
   NOT auto_fallback_out MATCHES "\"query_embedding_state\":\"provider-fallback\"" OR
   NOT auto_fallback_out MATCHES "\"provider_calls\":1" OR
   NOT auto_fallback_out MATCHES "\"outcome\":\"failed\"" OR
   NOT auto_fallback_err MATCHES "crexxrag query-embedding failed")
    message(FATAL_ERROR "Phase-5 auto query did not expose its attempted-provider lexical fallback:\n${auto_fallback_out}${auto_fallback_err}")
endif()
execute_process(COMMAND ${cli} --format json query evidence
    "What does BillingService depend on?" --mode hybrid
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE hybrid_fail_out ERROR_VARIABLE hybrid_fail_err
    RESULT_VARIABLE hybrid_fail_result TIMEOUT 30)
if(hybrid_fail_result EQUAL 0 OR
   NOT hybrid_fail_out MATCHES "query embedding provider failed" OR
   hybrid_fail_out MATCHES "\"status\":\"ok\"")
    message(FATAL_ERROR "Phase-5 required hybrid query silently fell back:\n${hybrid_fail_out}${hybrid_fail_err}")
endif()

# Provider JSON is untrusted. Unknown, duplicate and omitted citations are all
# rejected after structured-schema validation and before any answer is shown.
set(invalid_out "${CPRAG_WORK_DIR}/invalid-loopback.out")
set(invalid_err "${CPRAG_WORK_DIR}/invalid-loopback.err")
set(invalid_status "${CPRAG_WORK_DIR}/invalid-loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 4 product-query-invalid; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p5r-01-invalid "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${invalid_out}"
    "${invalid_err}" "${invalid_status}"
    RESULT_VARIABLE invalid_launch_result)
if(NOT invalid_launch_result EQUAL 0)
    message(FATAL_ERROR "could not start Phase-5 invalid-answer loopback")
endif()
set(invalid_ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${invalid_out}")
        file(READ "${invalid_out}" current_invalid_out)
        if(current_invalid_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(invalid_ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT invalid_ready)
    message(FATAL_ERROR "Phase-5 invalid-answer loopback did not become ready")
endif()
foreach(expected_error IN ITEMS
        "unknown or duplicate citation"
        "unknown or duplicate citation"
        "omitted citations for available evidence"
        "fields outside the exact schema")
    execute_process(COMMAND ${cli} --format json query answer
        "What does BillingService depend on?" --mode lexical
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
        OUTPUT_VARIABLE invalid_query_out ERROR_VARIABLE invalid_query_err
        RESULT_VARIABLE invalid_query_result TIMEOUT 30)
    if(invalid_query_result EQUAL 0 OR
       NOT invalid_query_out MATCHES "${expected_error}" OR
       invalid_query_out MATCHES "\"status\":\"ok\"")
        message(FATAL_ERROR "Phase-5 invalid citation was accepted:\n${invalid_query_out}${invalid_query_err}")
    endif()
endforeach()
foreach(poll RANGE 1 200)
    if(EXISTS "${invalid_status}")
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT EXISTS "${invalid_status}")
    message(FATAL_ERROR "Phase-5 invalid-answer loopback did not exit")
endif()
file(READ "${invalid_status}" invalid_result)
file(READ "${invalid_out}" final_invalid_out)
file(READ "${invalid_err}" final_invalid_err)
if(NOT invalid_result STREQUAL "0" OR
   NOT final_invalid_out MATCHES "SUMMARY scenario=product-query-invalid connections=4")
    message(FATAL_ERROR "Phase-5 invalid-answer loopback failed:\n${final_invalid_out}${final_invalid_err}")
endif()

execute_process(COMMAND ${cli} --access diagnose library verify
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
    RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "state: verified" OR
   NOT verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "Phase-5 queried library verification failed:\n${verify_out}${verify_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "item=P5R-01\nprovider=gemini\ningest_requests=2\nquery_requests=2\n"
    "retrieval=hybrid\nanswer=structured-and-cited\nlexical_outbound=0\n"
    "invalid_answers=unknown+duplicate+omitted+extra-field\nauto_fallback=attempt-reported\nhybrid_required=no-silent-fallback\n"
    "surface=crexxrag-query\n${init_out}${ingest_out}${ingest_err}${query_out}${query_err}"
    "${lexical_out}${lexical_err}${hybrid_fail_out}${hybrid_fail_err}${verify_out}${verify_err}")
message(STATUS "P5R-01 passed human hybrid retrieval and cited answer generation, explicit zero-outbound lexical mode, required-hybrid failure, three citation rejection cases, and post-query integrity")
