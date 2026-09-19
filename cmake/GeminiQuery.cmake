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
    "Again, BillingService depends on CustomerDatabase.\n")
set(CPRAG_FIXTURE_PORT 18999)
if(CPRAG_NATIVE_VECTOR_ONLY)
    set(CPRAG_FIXTURE_PORT 0)
endif()
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source")
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/crexxrag.conf" @ONLY)

if(CPRAG_NATIVE_VECTOR_ONLY)
    file(APPEND "${CPRAG_WORK_DIR}/crexxrag.conf" "\nvector.algorithm = exact-native-v1\n")
    set(expected_vector_state "active-exact-native")
else()
    set(expected_vector_state "active-ann-ivf-rxvector")
endif()

if(NOT EXISTS "${CPRAG_NATIVE_APPLICATION}")
    message(FATAL_ERROR "native crexxrag application is required")
endif()
find_program(CREXXRAG_SQLITE3 sqlite3 REQUIRED)
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
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
    message(FATAL_ERROR "could not start Gemini query loopback")
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
    message(FATAL_ERROR "Gemini query loopback did not become ready")
endif()

if(CPRAG_NATIVE_VECTOR_ONLY)
    include("${CMAKE_CURRENT_LIST_DIR}/FixtureEndpoint.cmake")
    crexxrag_fixture_endpoint("${server_out}" "${CPRAG_WORK_DIR}/crexxrag.conf")
endif()

execute_process(COMMAND ${cli} init
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err
    RESULT_VARIABLE init_result TIMEOUT 30)
if(NOT init_result EQUAL 0 OR NOT init_out MATCHES "schema version: 20")
    message(FATAL_ERROR "Query test human init failed:\n${init_out}${init_err}")
endif()

execute_process(COMMAND ${cli} ingest --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE ingest_out ERROR_VARIABLE ingest_err
    RESULT_VARIABLE ingest_result TIMEOUT 90)
if(NOT ingest_result EQUAL 0 OR
   NOT ingest_out MATCHES "state: completed" OR
   NOT ingest_out MATCHES "processed: 2" OR
   NOT ingest_out MATCHES "vector state: published")
    message(FATAL_ERROR "Query prerequisite ingestion failed:\n${ingest_out}${ingest_err}")
endif()

# With an answerer in the local config, the enduring shorthand performs one
# compatible query embedding and one schema-constrained answer call.
execute_process(COMMAND ${cli} query "What does BillingService depend on?" --mode hybrid
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE query_out ERROR_VARIABLE query_err
    RESULT_VARIABLE query_result TIMEOUT 60)
if(NOT query_result EQUAL 0 OR
   NOT query_out MATCHES "OK: evidence-backed answer generated with validated citations" OR
   NOT query_out MATCHES "vector state: ${expected_vector_state}" OR
   NOT query_out MATCHES "generated answer: BillingService depends on CustomerDatabase" OR
   NOT query_out MATCHES "retrieval mode: hybrid" OR
   NOT query_out MATCHES "query embedding state: generated" OR
   NOT query_out MATCHES "provider calls: 2" OR
   NOT query_out MATCHES "citation: .*utf8-0-94" OR
   NOT query_out MATCHES "role: embedding" OR
   NOT query_out MATCHES "role: answerer" OR
   NOT query_out MATCHES "charging basis: local-compute" OR
   query_out MATCHES "evidence_json|canonical_plan|synthetic-product-gemini-key" OR
   NOT query_err MATCHES "crexxrag query-embedding complete" OR
   NOT query_err MATCHES "crexxrag answer complete" OR
   query_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "Human hybrid answer failed:\n${query_out}${query_err}")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) || ':' || count(DISTINCT purpose) || ':' || min(cost_microunits>=0) || ':' || count(DISTINCT request_hash) FROM provider_runs WHERE purpose IN('query-embedding','query-answer');"
    OUTPUT_VARIABLE query_history_out ERROR_VARIABLE query_history_err
    RESULT_VARIABLE query_history_result OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT query_history_result EQUAL 0 OR NOT query_history_out STREQUAL "2:2:1:2")
    message(FATAL_ERROR "Successful direct provider history was not durable and costed:\n${query_history_out}${query_history_err}")
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
    message(FATAL_ERROR "Positive Gemini query loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=product-query connections=4")
    message(FATAL_ERROR "Positive Gemini query loopback failed:\n${final_server_out}${final_server_err}")
endif()

if(CPRAG_NATIVE_VECTOR_ONLY)
    set(native_db "${CPRAG_WORK_DIR}/library/library.sqlite")
    execute_process(COMMAND "${CREXXRAG_SQLITE3}" -readonly "${native_db}"
        "SELECT sidecar_name FROM vector_generations WHERE state='published' AND algorithm='exact-native-v1'"
        OUTPUT_VARIABLE native_sidecar OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    execute_process(COMMAND "${CREXXRAG_SQLITE3}" -readonly "${native_db}"
        "SELECT count(*) FROM provider_runs"
        OUTPUT_VARIABLE native_calls_before OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    set(native_path "${CPRAG_WORK_DIR}/library/${native_sidecar}")
    file(COPY_FILE "${native_path}" "${CPRAG_WORK_DIR}/native-index.saved")
    foreach(damage IN ITEMS missing corrupt)
        if(damage STREQUAL "missing")
            file(REMOVE "${native_path}")
        else()
            file(WRITE "${native_path}" "corrupt native index")
        endif()
        execute_process(COMMAND ${cli} --format json query evidence BillingService --mode hybrid
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" RESULT_VARIABLE native_reject
            OUTPUT_VARIABLE native_reject_out ERROR_VARIABLE native_reject_err TIMEOUT 30)
        if(NOT native_reject EQUAL 8)
            message(FATAL_ERROR "Native ${damage} index did not reject before provider work: ${native_reject_out}${native_reject_err}")
        endif()
        file(COPY_FILE "${CPRAG_WORK_DIR}/native-index.saved" "${native_path}")
    endforeach()
    execute_process(COMMAND "${CREXXRAG_SQLITE3}" -readonly "${native_db}"
        "SELECT count(*) FROM provider_runs"
        OUTPUT_VARIABLE native_calls_after OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    if(NOT native_calls_before STREQUAL native_calls_after)
        message(FATAL_ERROR "Native preflight rejection changed provider history")
    endif()
    message(STATUS "Native exact public ingest, grounded answer and zero-call missing/corrupt preflight passed")
    return()
endif()

# The deterministic report is a zero-provider, generation-bound view of corpus,
# graph, vector, provenance and maintenance state. The optional advisory layer
# makes exactly one separately visible call and caches only validated citations.
execute_process(COMMAND ${cli} --format json library report --top 10
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE report_out ERROR_VARIABLE report_err
    RESULT_VARIABLE report_result TIMEOUT 30)
if(NOT report_result EQUAL 0 OR
   NOT report_out MATCHES "\"schema\":\"crexx-rag.library-report/1\"" OR
   NOT report_out MATCHES "\"chunks\":1" OR
   NOT report_out MATCHES "\"concepts\":2" OR
   NOT report_out MATCHES "\"claims\":1" OR
   NOT report_out MATCHES "\"state\":\"ready\"" OR
   NOT report_out MATCHES "\"coverage_millionths\":1000000" OR
   NOT report_out MATCHES "\"narrative_state\":\"off\"" OR
   NOT report_out MATCHES "\"provider_calls\":0" OR
   NOT report_out MATCHES "crexx-rag:.*utf8-0-94")
    message(FATAL_ERROR "Deterministic library report failed:\n${report_out}${report_err}")
endif()

execute_process(COMMAND ${cli} library report --top 10 --narrative refresh
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE unconfirmed_report_out ERROR_VARIABLE unconfirmed_report_err
    RESULT_VARIABLE unconfirmed_report_result TIMEOUT 30)
if(unconfirmed_report_result EQUAL 0 OR
   NOT "${unconfirmed_report_out}${unconfirmed_report_err}" MATCHES "human narrative refresh requires --yes")
    message(FATAL_ERROR "Human report refresh did not require confirmation:\n${unconfirmed_report_out}${unconfirmed_report_err}")
endif()

set(report_server_out "${CPRAG_WORK_DIR}/report-loopback.out")
set(report_server_err "${CPRAG_WORK_DIR}/report-loopback.err")
set(report_server_status "${CPRAG_WORK_DIR}/report-loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 1 product-report; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p5r-report "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${report_server_out}"
    "${report_server_err}" "${report_server_status}"
    RESULT_VARIABLE report_launch_result)
if(NOT report_launch_result EQUAL 0)
    message(FATAL_ERROR "could not start report narrative loopback")
endif()
set(report_ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${report_server_out}")
        file(READ "${report_server_out}" current_report_server_out)
        if(current_report_server_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(report_ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT report_ready)
    message(FATAL_ERROR "Report narrative loopback did not become ready")
endif()
execute_process(COMMAND ${cli} --format json library report --top 10 --narrative refresh
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE report_refresh_out ERROR_VARIABLE report_refresh_err
    RESULT_VARIABLE report_refresh_result TIMEOUT 60)
if(NOT report_refresh_result EQUAL 0 OR
   NOT report_refresh_out MATCHES "\"narrative_state\":\"generated\"" OR
   NOT report_refresh_out MATCHES "\"provider_calls\":1" OR
   NOT report_refresh_out MATCHES "\"overview\":\"The library covers a documented service dependency\.\"" OR
   NOT report_refresh_out MATCHES "\"kind\":\"report-subject\"" OR
   NOT report_refresh_out MATCHES "\"provider_id\":\"gemini-generate\"" OR
   NOT report_refresh_out MATCHES "\"model\":\"gemini-3.5-flash-lite\"")
    message(FATAL_ERROR "Validated report narrative refresh failed:\n${report_refresh_out}${report_refresh_err}")
endif()
foreach(poll RANGE 1 200)
    if(EXISTS "${report_server_status}")
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT EXISTS "${report_server_status}")
    message(FATAL_ERROR "Report narrative loopback did not exit")
endif()
file(READ "${report_server_status}" report_server_result)
file(READ "${report_server_out}" final_report_server_out)
if(NOT report_server_result STREQUAL "0" OR
   NOT final_report_server_out MATCHES "SUMMARY scenario=product-report connections=1")
    message(FATAL_ERROR "Report narrative loopback failed:\n${final_report_server_out}")
endif()

execute_process(COMMAND ${cli} --format json library report --top 10 --narrative cached
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE report_cached_out ERROR_VARIABLE report_cached_err
    RESULT_VARIABLE report_cached_result TIMEOUT 30)
if(NOT report_cached_result EQUAL 0 OR
   NOT report_cached_out MATCHES "\"narrative_state\":\"cached\"" OR
   NOT report_cached_out MATCHES "\"provider_calls\":0" OR
   NOT report_cached_out MATCHES "\"overview\":\"The library covers a documented service dependency\.\"")
    message(FATAL_ERROR "Cached report narrative failed:\n${report_cached_out}${report_cached_err}")
endif()

# Guided ingestion has already captured the first fixed-top-10 observation.
# After narrative generation, an identical evaluation is audited but suppressed;
# the immutable point discovers the matching narrative by its report digests.
execute_process(COMMAND ${cli} --access control --format json library snapshot
    --trigger scheduled --reason "fixture repeated observation"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE snapshot_out ERROR_VARIABLE snapshot_err
    RESULT_VARIABLE snapshot_result TIMEOUT 30)
if(NOT snapshot_result EQUAL 0 OR
   NOT snapshot_out MATCHES "\"outcome\":\"skipped-identical\"" OR
   NOT snapshot_out MATCHES "\"snapshot_count\":1" OR
   NOT snapshot_out MATCHES "\"narrative_attached\":true" OR
   NOT snapshot_out MATCHES "\"provider_calls\":0")
    message(FATAL_ERROR "Identical post-narrative observation was not suppressed:\n${snapshot_out}${snapshot_err}")
endif()
execute_process(COMMAND ${cli} --access control --format json library snapshot
    --trigger scheduled --reason "fixture repeated observation"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE duplicate_snapshot_out ERROR_VARIABLE duplicate_snapshot_err
    RESULT_VARIABLE duplicate_snapshot_result TIMEOUT 30)
if(NOT duplicate_snapshot_result EQUAL 0 OR
   NOT duplicate_snapshot_out MATCHES "\"outcome\":\"skipped-identical\"" OR
   NOT duplicate_snapshot_out MATCHES "\"snapshot_count\":1" OR
   NOT duplicate_snapshot_out MATCHES "\"evaluation_count\":2" OR
   NOT duplicate_snapshot_out MATCHES "\"provider_calls\":0")
    message(FATAL_ERROR "Identical historic observation was not suppressed:\n${duplicate_snapshot_out}${duplicate_snapshot_err}")
endif()
execute_process(COMMAND ${cli} --format json library trend --limit 20
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE trend_out ERROR_VARIABLE trend_err
    RESULT_VARIABLE trend_result TIMEOUT 30)
if(NOT trend_result EQUAL 0 OR
   NOT trend_out MATCHES "\"schema\":\"crexx-rag.historic-trend/1\"" OR
   NOT trend_out MATCHES "\"state\":\"baseline-only\"" OR
   NOT trend_out MATCHES "\"point_count\":1" OR
   NOT trend_out MATCHES "\"suppressed_evaluations\":2" OR
   NOT trend_out MATCHES "\"direction_available\":false" OR
   NOT trend_out MATCHES "\"baseline\":true" OR
   NOT trend_out MATCHES "\"kind\":\"trend-narrative\"" OR
   NOT trend_out MATCHES "The library covers a documented service dependency")
    message(FATAL_ERROR "One-point historic trend report failed:\n${trend_out}${trend_err}")
endif()

set(invalid_report_out "${CPRAG_WORK_DIR}/invalid-report-loopback.out")
set(invalid_report_err "${CPRAG_WORK_DIR}/invalid-report-loopback.err")
set(invalid_report_status "${CPRAG_WORK_DIR}/invalid-report-loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 1 product-report-invalid; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p5r-report-invalid "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${invalid_report_out}"
    "${invalid_report_err}" "${invalid_report_status}"
    RESULT_VARIABLE invalid_report_launch_result)
if(NOT invalid_report_launch_result EQUAL 0)
    message(FATAL_ERROR "could not start invalid report narrative loopback")
endif()
set(invalid_report_ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${invalid_report_out}")
        file(READ "${invalid_report_out}" current_invalid_report_out)
        if(current_invalid_report_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(invalid_report_ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT invalid_report_ready)
    message(FATAL_ERROR "Invalid report narrative loopback did not become ready")
endif()
execute_process(COMMAND ${cli} --format json library report --top 10 --narrative refresh
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE invalid_report_refresh_out ERROR_VARIABLE invalid_report_refresh_err
    RESULT_VARIABLE invalid_report_refresh_result TIMEOUT 60)
if(invalid_report_refresh_result EQUAL 0 OR
   NOT invalid_report_refresh_out MATCHES "unknown or duplicate citation" OR
   invalid_report_refresh_out MATCHES "\"status\":\"ok\"")
    message(FATAL_ERROR "Invalid report narrative was accepted:\n${invalid_report_refresh_out}${invalid_report_refresh_err}")
endif()
foreach(poll RANGE 1 200)
    if(EXISTS "${invalid_report_status}")
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT EXISTS "${invalid_report_status}")
    message(FATAL_ERROR "Invalid report narrative loopback did not exit")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) FROM provider_runs WHERE purpose='report-narrative' AND outcome='rejected' AND cost_microunits>=0;"
    OUTPUT_VARIABLE rejected_report_history_out ERROR_VARIABLE rejected_report_history_err
    RESULT_VARIABLE rejected_report_history_result OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT rejected_report_history_result EQUAL 0 OR NOT rejected_report_history_out STREQUAL "1")
    message(FATAL_ERROR "Rejected report narrative history was not durable:\n${rejected_report_history_out}${rejected_report_history_err}")
endif()

execute_process(COMMAND ${cli} --format json library report --top 10 --narrative cached
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE report_cached_after_invalid_out ERROR_VARIABLE report_cached_after_invalid_err
    RESULT_VARIABLE report_cached_after_invalid_result TIMEOUT 30)
if(NOT report_cached_after_invalid_result EQUAL 0 OR
   NOT report_cached_after_invalid_out MATCHES "\"narrative_state\":\"cached\"" OR
   NOT report_cached_after_invalid_out MATCHES "The library covers a documented service dependency")
    message(FATAL_ERROR "Invalid refresh damaged the prior report cache:\n${report_cached_after_invalid_out}${report_cached_after_invalid_err}")
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
    message(FATAL_ERROR "could not start query zero-outbound observer")
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
    message(FATAL_ERROR "Query zero-outbound observer did not become ready")
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
    message(FATAL_ERROR "Explicit lexical query was not a clean zero-call route:\n${lexical_out}${lexical_err}")
endif()
foreach(poll RANGE 1 200)
    if(EXISTS "${zero_status}")
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT EXISTS "${zero_status}")
    message(FATAL_ERROR "Query zero-outbound observer did not exit")
endif()
file(READ "${zero_status}" zero_result)
file(READ "${zero_out}" final_zero_out)
if(NOT zero_result STREQUAL "0" OR
   NOT final_zero_out MATCHES "SUMMARY scenario=zero-outbound connections=0")
    message(FATAL_ERROR "Lexical query made an outbound request:\n${final_zero_out}")
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
    message(FATAL_ERROR "Auto query did not expose its attempted-provider lexical fallback:\n${auto_fallback_out}${auto_fallback_err}")
endif()
execute_process(COMMAND ${cli} --format json query evidence
    "What does BillingService depend on?" --mode hybrid
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE hybrid_fail_out ERROR_VARIABLE hybrid_fail_err
    RESULT_VARIABLE hybrid_fail_result TIMEOUT 30)
if(hybrid_fail_result EQUAL 0 OR
   NOT hybrid_fail_out MATCHES "query embedding provider failed" OR
   hybrid_fail_out MATCHES "\"status\":\"ok\"")
    message(FATAL_ERROR "Required hybrid query silently fell back:\n${hybrid_fail_out}${hybrid_fail_err}")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) FROM provider_runs WHERE purpose='query-embedding' AND outcome='failed' AND cost_microunits>=0;"
    OUTPUT_VARIABLE failed_embedding_history_out ERROR_VARIABLE failed_embedding_history_err
    RESULT_VARIABLE failed_embedding_history_result OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT failed_embedding_history_result EQUAL 0 OR NOT failed_embedding_history_out STREQUAL "2")
    message(FATAL_ERROR "Failed direct embedding history was not durable:\n${failed_embedding_history_out}${failed_embedding_history_err}")
endif()

# Provider JSON is untrusted. Unknown and duplicate citations, a supported
# answer without citations, and extra fields are rejected before display.
set(invalid_out "${CPRAG_WORK_DIR}/invalid-loopback.out")
set(invalid_err "${CPRAG_WORK_DIR}/invalid-loopback.err")
set(invalid_status "${CPRAG_WORK_DIR}/invalid-loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 4 product-query-invalid; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p5r-01-invalid "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${invalid_out}"
    "${invalid_err}" "${invalid_status}"
    RESULT_VARIABLE invalid_launch_result)
if(NOT invalid_launch_result EQUAL 0)
    message(FATAL_ERROR "could not start invalid-answer loopback")
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
    message(FATAL_ERROR "Invalid-answer loopback did not become ready")
endif()
foreach(expected_error IN ITEMS
        "unknown or duplicate citation"
        "unknown or duplicate citation"
        "supported query answer omitted citations"
        "fields outside the exact schema")
    execute_process(COMMAND ${cli} --format json query answer
        "What does BillingService depend on?" --mode lexical
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
        OUTPUT_VARIABLE invalid_query_out ERROR_VARIABLE invalid_query_err
        RESULT_VARIABLE invalid_query_result TIMEOUT 30)
    if(invalid_query_result EQUAL 0 OR
       NOT invalid_query_out MATCHES "${expected_error}" OR
       invalid_query_out MATCHES "\"status\":\"ok\"")
        message(FATAL_ERROR "Invalid citation was accepted:\n${invalid_query_out}${invalid_query_err}")
    endif()
endforeach()
foreach(poll RANGE 1 200)
    if(EXISTS "${invalid_status}")
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT EXISTS "${invalid_status}")
    message(FATAL_ERROR "Invalid-answer loopback did not exit")
endif()
file(READ "${invalid_status}" invalid_result)
file(READ "${invalid_out}" final_invalid_out)
file(READ "${invalid_err}" final_invalid_err)
if(NOT invalid_result STREQUAL "0" OR
   NOT final_invalid_out MATCHES "SUMMARY scenario=product-query-invalid connections=4")
    message(FATAL_ERROR "Invalid-answer loopback failed:\n${final_invalid_out}${final_invalid_err}")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) || ':' || count(CASE WHEN recovery_json<>'' THEN 1 END) FROM provider_runs WHERE purpose='query-answer' AND outcome='rejected' AND cost_microunits>=0;"
    OUTPUT_VARIABLE rejected_answer_history_out ERROR_VARIABLE rejected_answer_history_err
    RESULT_VARIABLE rejected_answer_history_result OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT rejected_answer_history_result EQUAL 0 OR NOT rejected_answer_history_out STREQUAL "4:4")
    message(FATAL_ERROR "Rejected direct answer history was not durable:\n${rejected_answer_history_out}${rejected_answer_history_err}")
endif()

# Irrelevant retrieved material is not a command failure. The provider declares
# insufficient grounding without citations and the product emits a stable,
# non-hallucinatory answer instead of exposing arbitrary provider wording.
set(insufficient_out "${CPRAG_WORK_DIR}/insufficient-loopback.out")
set(insufficient_err "${CPRAG_WORK_DIR}/insufficient-loopback.err")
set(insufficient_status "${CPRAG_WORK_DIR}/insufficient-loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 1 product-query-insufficient; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p5r-01-insufficient "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}"
    "${insufficient_out}" "${insufficient_err}" "${insufficient_status}"
    RESULT_VARIABLE insufficient_launch_result)
if(NOT insufficient_launch_result EQUAL 0)
    message(FATAL_ERROR "could not start insufficient-answer loopback")
endif()
set(insufficient_ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${insufficient_out}")
        file(READ "${insufficient_out}" current_insufficient_out)
        if(current_insufficient_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(insufficient_ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT insufficient_ready)
    message(FATAL_ERROR "Insufficient-answer loopback did not become ready")
endif()
execute_process(COMMAND ${cli} --format json query answer
    "What does BillingService depend on?" --mode lexical
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE insufficient_query_out ERROR_VARIABLE insufficient_query_err
    RESULT_VARIABLE insufficient_query_result TIMEOUT 30)
string(FIND "${insufficient_query_out}" "\"answer_citations_json\":\"[]\"" insufficient_citations_marker)
if(NOT insufficient_query_result EQUAL 0 OR
   NOT insufficient_query_out MATCHES "\"status\":\"ok\"" OR
   NOT insufficient_query_out MATCHES "\"generated_answer\":\"The available evidence is insufficient to answer this question\.\"" OR
   NOT insufficient_query_out MATCHES "\"answer_grounding\":\"insufficient\"" OR
   insufficient_citations_marker EQUAL -1 OR
   NOT insufficient_query_out MATCHES "\"citation\":\"\"" OR
   NOT insufficient_query_out MATCHES "\"evidence_citation\":\"crexx-rag:" OR
   NOT insufficient_query_out MATCHES "\"provider_calls\":1")
    message(FATAL_ERROR "Insufficient evidence was not returned as a valid answer:\n${insufficient_query_out}${insufficient_query_err}")
endif()
foreach(poll RANGE 1 200)
    if(EXISTS "${insufficient_status}")
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT EXISTS "${insufficient_status}")
    message(FATAL_ERROR "Insufficient-answer loopback did not exit")
endif()
file(READ "${insufficient_status}" insufficient_result)
file(READ "${insufficient_out}" final_insufficient_out)
file(READ "${insufficient_err}" final_insufficient_err)
if(NOT insufficient_result STREQUAL "0" OR
   NOT final_insufficient_out MATCHES "SUMMARY scenario=product-query-insufficient connections=1")
    message(FATAL_ERROR "Insufficient-answer loopback failed:\n${final_insufficient_out}${final_insufficient_err}")
endif()

# Useful but incomplete evidence remains visible as a cited partial answer.
set(partial_out "${CPRAG_WORK_DIR}/partial-loopback.out")
set(partial_err "${CPRAG_WORK_DIR}/partial-loopback.err")
set(partial_status "${CPRAG_WORK_DIR}/partial-loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 1 product-query-partial; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p5r-01-partial "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}"
    "${partial_out}" "${partial_err}" "${partial_status}"
    RESULT_VARIABLE partial_launch_result)
if(NOT partial_launch_result EQUAL 0)
    message(FATAL_ERROR "could not start partial-answer loopback")
endif()
set(partial_ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${partial_out}")
        file(READ "${partial_out}" current_partial_out)
        if(current_partial_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(partial_ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT partial_ready)
    message(FATAL_ERROR "Partial-answer loopback did not become ready")
endif()
execute_process(COMMAND ${cli} --format json query answer
    "What does BillingService depend on, and what is its operational impact?" --mode lexical
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE partial_query_out ERROR_VARIABLE partial_query_err
    RESULT_VARIABLE partial_query_result TIMEOUT 30)
if(NOT partial_query_result EQUAL 0 OR
   NOT partial_query_out MATCHES "\"status\":\"ok\"" OR
   NOT partial_query_out MATCHES "\"answer_grounding\":\"partial\"" OR
   NOT partial_query_out MATCHES "\"generated_answer\":\"The evidence establishes the documented dependency, but does not establish its operational impact\.\"" OR
   NOT partial_query_out MATCHES "\"answer_citations_json\":" OR
   NOT partial_query_out MATCHES "\"citation\":\"crexx-rag:")
    message(FATAL_ERROR "Partial evidence was not preserved as a cited answer:\n${partial_query_out}${partial_query_err}")
endif()
foreach(poll RANGE 1 200)
    if(EXISTS "${partial_status}")
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT EXISTS "${partial_status}")
    message(FATAL_ERROR "Partial-answer loopback did not exit")
endif()
file(READ "${partial_status}" partial_result)
file(READ "${partial_out}" final_partial_out)
file(READ "${partial_err}" final_partial_err)
if(NOT partial_result STREQUAL "0" OR
   NOT final_partial_out MATCHES "SUMMARY scenario=product-query-partial connections=1")
    message(FATAL_ERROR "Partial-answer loopback failed:\n${final_partial_out}${final_partial_err}")
endif()

execute_process(COMMAND ${cli} --access diagnose library verify
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
    RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "state: verified" OR
   NOT verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "Queried library verification failed:\n${verify_out}${verify_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "test=gemini-query\nprovider=gemini\ningest_requests=2\nquery_requests=2\n"
    "retrieval=hybrid\nanswer=structured-and-cited\nlexical_outbound=0\n"
    "invalid_answers=unknown+duplicate+supported-omitted+extra-field\ninsufficient_answer=accepted-without-citations\nauto_fallback=attempt-reported\nhybrid_required=no-silent-fallback\n"
    "surface=crexxrag-query\n${init_out}${ingest_out}${ingest_err}${query_out}${query_err}"
    "${lexical_out}${lexical_err}${hybrid_fail_out}${hybrid_fail_err}${verify_out}${verify_err}")
message(STATUS "Gemini query passed human hybrid retrieval and cited answer generation, explicit zero-outbound lexical mode, required-hybrid failure, citation rejection, valid insufficient-evidence handling, and post-query integrity")

# A derived-index failure must be recoverable using only stored SQLite data.
# All loopback providers have stopped before this section.
find_program(CREXXRAG_SQLITE3 sqlite3 REQUIRED)
set(recovery_db "${CPRAG_WORK_DIR}/library/library.sqlite")
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${recovery_db}"
    "SELECT sidecar_name FROM vector_generations WHERE state='published' AND semantic_generation=(SELECT published_generation FROM library_meta WHERE singleton=1) AND algorithm='ivf-flat-v1' LIMIT 1"
    OUTPUT_VARIABLE recovery_sidecar OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE recovery_sql_result)
if(NOT recovery_sql_result EQUAL 0 OR recovery_sidecar STREQUAL "")
    message(FATAL_ERROR "missing vector recovery fixture")
endif()
set(recovery_path "${CPRAG_WORK_DIR}/library/${recovery_sidecar}")
# A malformed vector profile is irrelevant to lexical search but must still
# prevent hybrid provider work. Damage only a separate fixture copy.
set(lexical_library "${CPRAG_WORK_DIR}/lexical-profile-library")
file(COPY "${CPRAG_WORK_DIR}/library/" DESTINATION "${lexical_library}")
execute_process(COMMAND ${cli} --library "${lexical_library}" --format json query inspect BillingService
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE lexical_before RESULT_VARIABLE lexical_before_rc)
if(NOT lexical_before_rc EQUAL 0)
    message(FATAL_ERROR "Lexical independence positive control failed: ${lexical_before}")
endif()
string(JSON lexical_evidence_before GET "${lexical_before}" records 0 fields evidence_json)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${lexical_library}/library.sqlite"
    "UPDATE embedding_profiles SET input_envelope_fingerprint='invalid-profile-fixture';"
    COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" -readonly "${lexical_library}/library.sqlite" .dump
    OUTPUT_VARIABLE profile_rows_before COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND ${cli} --library "${lexical_library}" --format json query evidence BillingService --mode hybrid
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE profile_hybrid_out RESULT_VARIABLE profile_hybrid_rc)
if(NOT profile_hybrid_rc EQUAL 7)
    message(FATAL_ERROR "Hybrid accepted malformed profile: ${profile_hybrid_out}")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" -readonly "${lexical_library}/library.sqlite" .dump
    OUTPUT_VARIABLE profile_rows_after COMMAND_ERROR_IS_FATAL ANY)
if(NOT profile_rows_before STREQUAL profile_rows_after)
    message(FATAL_ERROR "Hybrid profile rejection changed logical database state")
endif()
# Hybrid opens readwrite and may checkpoint WAL; the following strict file
# comparison applies specifically to the ordinary read-only inspection.
file(SHA256 "${lexical_library}/library.sqlite" lexical_database_before)
execute_process(COMMAND ${cli} --library "${lexical_library}" --format json query inspect BillingService
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE lexical_after RESULT_VARIABLE lexical_after_rc)
if(NOT lexical_after_rc EQUAL 0)
    message(FATAL_ERROR "Lexical search depends on unused vector profile: ${lexical_after}")
endif()
string(JSON lexical_evidence_after GET "${lexical_after}" records 0 fields evidence_json)
file(SHA256 "${lexical_library}/library.sqlite" lexical_database_after)
if(NOT lexical_evidence_before STREQUAL lexical_evidence_after OR NOT lexical_database_before STREQUAL lexical_database_after)
    file(WRITE "${CPRAG_WORK_DIR}/lexical-before.json" "${lexical_before}")
    file(WRITE "${CPRAG_WORK_DIR}/lexical-after.json" "${lexical_after}")
    message(STATUS "Lexical database hashes: ${lexical_database_before} -> ${lexical_database_after}")
    message(FATAL_ERROR "Lexical profile independence changed evidence or made database writes")
endif()
file(SHA256 "${recovery_path}" recovery_checksum)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${recovery_db}"
    "SELECT published_generation||':'||(SELECT count(*) FROM embeddings)||':'||(SELECT count(*) FROM provider_runs) FROM library_meta WHERE singleton=1"
    OUTPUT_VARIABLE recovery_before OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
foreach(damage IN ITEMS missing corrupt)
    if(damage STREQUAL "missing")
        file(REMOVE "${recovery_path}")
    else()
        file(WRITE "${recovery_path}" "corrupt derived index")
    endif()
    execute_process(COMMAND ${cli} --format json query evidence "BillingService" --mode hybrid
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}" RESULT_VARIABLE damaged_query_result
        OUTPUT_VARIABLE damaged_query_out ERROR_VARIABLE damaged_query_err TIMEOUT 30)
    if(NOT damaged_query_result EQUAL 8)
        message(FATAL_ERROR "invalid hybrid index did not fail before provider use: ${damaged_query_out}${damaged_query_err}")
    endif()
    execute_process(COMMAND ${cli} --format json query inspect "BillingService" --mode lexical
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}" RESULT_VARIABLE lexical_damage_rc
        OUTPUT_VARIABLE lexical_damage_out ERROR_VARIABLE lexical_damage_err)
    if(NOT lexical_damage_rc EQUAL 0 OR NOT lexical_damage_out MATCHES "\"provider_calls\":0")
        message(FATAL_ERROR "Lexical search depends on a ${damage} sidecar: ${lexical_damage_out}${lexical_damage_err}")
    endif()
    execute_process(COMMAND ${cli} --format json --access read vector rebuild
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}" RESULT_VARIABLE denied_rebuild_result
        OUTPUT_VARIABLE denied_rebuild_out ERROR_VARIABLE denied_rebuild_err TIMEOUT 30)
    if(NOT denied_rebuild_result EQUAL 4)
        message(FATAL_ERROR "vector rebuild accepted read-only capability: ${denied_rebuild_out}${denied_rebuild_err}")
    endif()
    execute_process(COMMAND ${cli} --format json --access control vector rebuild
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}" RESULT_VARIABLE recovery_result
        OUTPUT_VARIABLE recovery_out ERROR_VARIABLE recovery_err TIMEOUT 30)
    if(NOT recovery_result EQUAL 0 OR NOT recovery_out MATCHES "rebuilt-from-sqlite" OR
       NOT recovery_out MATCHES "\"provider_calls\":0")
        message(FATAL_ERROR "${damage} sidecar recovery failed: ${recovery_out}${recovery_err}")
    endif()
    file(SHA256 "${recovery_path}" restored_checksum)
    if(NOT restored_checksum STREQUAL recovery_checksum)
        message(FATAL_ERROR "restored sidecar differs from original SQLite-derived bytes")
    endif()
endforeach()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${recovery_db}"
    "SELECT published_generation||':'||(SELECT count(*) FROM embeddings)||':'||(SELECT count(*) FROM provider_runs) FROM library_meta WHERE singleton=1"
    OUTPUT_VARIABLE recovery_after OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
if(NOT recovery_after STREQUAL recovery_before)
    message(FATAL_ERROR "sidecar recovery or invalid hybrid preflight changed generation, embeddings, or provider history")
endif()
execute_process(COMMAND ${cli} --format json --access control vector rebuild
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" RESULT_VARIABLE recovery_noop_result
    OUTPUT_VARIABLE recovery_noop_out ERROR_VARIABLE recovery_noop_err TIMEOUT 30)
if(NOT recovery_noop_result EQUAL 0 OR NOT recovery_noop_out MATCHES "identical-no-op")
    message(FATAL_ERROR "intact vector rebuild was not idempotent: ${recovery_noop_out}${recovery_noop_err}")
endif()
execute_process(COMMAND ${cli} --access diagnose library verify WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE recovery_verify_out ERROR_VARIABLE recovery_verify_err RESULT_VARIABLE recovery_verify_result TIMEOUT 30)
if(NOT recovery_verify_result EQUAL 0 OR NOT recovery_verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "recovered sidecar bundle failed verification: ${recovery_verify_out}${recovery_verify_err}")
endif()
file(APPEND "${CPRAG_WORK_DIR}/result.txt" "vector_rebuild=missing+corrupt+idempotent\nvector_rebuild_provider_calls=0\nhybrid_invalid_sidecar_provider_calls=0\n")

# Changing the interpretation policy does not invalidate or rewrite the corpus.
# Compare every stored table except the three intended configuration-history
# tables, including the exact SQLite BLOB encodings and original generations.
function(corpus_state output_name)
    execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${recovery_db}"
        "SELECT name FROM sqlite_schema WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT IN('config_snapshots','config_change_events','library_config_state') ORDER BY name"
        OUTPUT_VARIABLE table_names OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    string(REPLACE "\n" ";" table_names "${table_names}")
    set(state "")
    foreach(table_name IN LISTS table_names)
        execute_process(COMMAND "${CREXXRAG_SQLITE3}" -quote "${recovery_db}" "SELECT * FROM \"${table_name}\""
            OUTPUT_VARIABLE table_rows COMMAND_ERROR_IS_FATAL ANY)
        string(SHA256 table_digest "${table_rows}")
        string(APPEND state "${table_name}=${table_digest}\n")
    endforeach()
    set(${output_name} "${state}" PARENT_SCOPE)
endfunction()
corpus_state(preserved_before)
file(READ "${CPRAG_WORK_DIR}/crexxrag.conf" replacement_config)
string(REPLACE "model = gemini-embedding-2" "model = prospective-embedding-model" replacement_config "${replacement_config}")
if(NOT CPRAG_ARCHITECTURE_PROFILE)
    set(CPRAG_ARCHITECTURE_PROFILE "${CMAKE_CURRENT_LIST_DIR}/../crexx/application/config/profiles/it-architecture.profile.tsv")
endif()
file(READ "${CPRAG_ARCHITECTURE_PROFILE}" replacement_profile)
string(REPLACE "chunk\t1400\t180" "chunk\t2048\t192" replacement_profile "${replacement_profile}")
file(WRITE "${CPRAG_WORK_DIR}/edited-profile.tsv" "${replacement_profile}")
string(APPEND replacement_config "\nprofile.it-architecture-profile.file = edited-profile.tsv\nplan.ttl_seconds = 7200\n")
file(WRITE "${CPRAG_WORK_DIR}/crexxrag.conf" "${replacement_config}")
execute_process(COMMAND ${cli} --format json --access plan config plan --reason "preserve corpus across model and profile edits"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE replacement_plan_out ERROR_VARIABLE replacement_plan_err RESULT_VARIABLE replacement_plan_result TIMEOUT 30)
string(JSON replacement_plan ERROR_VARIABLE replacement_plan_error GET "${replacement_plan_out}" records 0 fields canonical_plan)
string(JSON replacement_digest ERROR_VARIABLE replacement_digest_error GET "${replacement_plan_out}" records 0 fields digest)
if(NOT replacement_plan_result EQUAL 0 OR replacement_plan_error OR replacement_digest_error)
    message(FATAL_ERROR "prospective profile/model plan failed: ${replacement_plan_out}${replacement_plan_err}")
endif()
execute_process(COMMAND ${cli} --format json --access admin config apply --plan-json "${replacement_plan}" --expect-digest "${replacement_digest}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE replacement_out ERROR_VARIABLE replacement_err RESULT_VARIABLE replacement_result TIMEOUT 30)
if(NOT replacement_result EQUAL 0 OR NOT replacement_out MATCHES "\"classification\":\"prospective\"")
    message(FATAL_ERROR "prospective profile/model apply failed: ${replacement_out}${replacement_err}")
endif()
corpus_state(preserved_after)
if(NOT preserved_before STREQUAL preserved_after)
    message(FATAL_ERROR "configuration changed existing corpus rows, vectors, provenance, or generation:\nBEFORE\n${preserved_before}\nAFTER\n${preserved_after}")
endif()
file(SHA256 "${recovery_path}" preserved_sidecar_checksum)
if(NOT preserved_sidecar_checksum STREQUAL recovery_checksum)
    message(FATAL_ERROR "configuration changed the prior vector sidecar")
endif()
execute_process(COMMAND ${cli} --format json query evidence "What does BillingService depend on?" --mode lexical
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE preserved_query_out ERROR_VARIABLE preserved_query_err RESULT_VARIABLE preserved_query_result TIMEOUT 30)
if(NOT preserved_query_result EQUAL 0 OR NOT preserved_query_out MATCHES "crexx-rag:" OR NOT preserved_query_out MATCHES "\"provider_calls\":0")
    message(FATAL_ERROR "historical evidence became unavailable after config change: ${preserved_query_out}${preserved_query_err}")
endif()
execute_process(COMMAND ${cli} --access diagnose library verify WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE preserved_verify_out ERROR_VARIABLE preserved_verify_err RESULT_VARIABLE preserved_verify_result TIMEOUT 30)
if(NOT preserved_verify_result EQUAL 0 OR NOT preserved_verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "configuration invalidated corpus verification: ${preserved_verify_out}${preserved_verify_err}")
endif()
file(APPEND "${CPRAG_WORK_DIR}/result.txt" "config_profile_model_change=prospective\nall_existing_tables=identical\nexisting_vectors=byte-identical\nexisting_citations=valid\n")
