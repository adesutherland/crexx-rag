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
    "${CPRAG_WORK_DIR}/crexxrag.conf" @ONLY)

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
        if(current_server_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT ready)
    message(FATAL_ERROR "Gemini query loopback did not become ready")
endif()

execute_process(COMMAND ${cli} init
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err
    RESULT_VARIABLE init_result TIMEOUT 30)
if(NOT init_result EQUAL 0 OR NOT init_out MATCHES "schema version: 8")
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
execute_process(COMMAND ${cli} query "What does BillingService depend on?"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE query_out ERROR_VARIABLE query_err
    RESULT_VARIABLE query_result TIMEOUT 60)
if(NOT query_result EQUAL 0 OR
   NOT query_out MATCHES "OK: evidence-backed answer generated with validated citations" OR
   NOT query_out MATCHES "vector state: active-ann-ivf-rxvector" OR
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
   NOT report_out MATCHES "crexx-rag:.*utf8-0-87")
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
    "SELECT count(*) FROM provider_runs WHERE purpose='query-answer' AND outcome='rejected' AND cost_microunits>=0;"
    OUTPUT_VARIABLE rejected_answer_history_out ERROR_VARIABLE rejected_answer_history_err
    RESULT_VARIABLE rejected_answer_history_result OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT rejected_answer_history_result EQUAL 0 OR NOT rejected_answer_history_out STREQUAL "4")
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
if(NOT insufficient_query_result EQUAL 0 OR
   NOT insufficient_query_out MATCHES "\"status\":\"ok\"" OR
   NOT insufficient_query_out MATCHES "\"generated_answer\":\"The available evidence is insufficient to answer this question\.\"" OR
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
