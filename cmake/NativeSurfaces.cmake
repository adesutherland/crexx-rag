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
set(CPRAG_FIXTURE_PORT 19000)
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source")
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/crexxrag.conf" @ONLY)

if(NOT EXISTS "${CPRAG_NATIVE_APPLICATION}")
    message(FATAL_ERROR "native crexxrag application is required")
endif()
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
    "NO_COLOR=1"
    "${CPRAG_NATIVE_APPLICATION}")

set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 4 product-query; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p6r-01 "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start native-surface Gemini loopback")
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
    message(FATAL_ERROR "Native-surface Gemini loopback did not become ready")
endif()

execute_process(COMMAND ${cli} init
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err
    RESULT_VARIABLE init_result TIMEOUT 30)
execute_process(COMMAND ${cli} ingest --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE ingest_out ERROR_VARIABLE ingest_err
    RESULT_VARIABLE ingest_result TIMEOUT 90)
if(NOT init_result EQUAL 0 OR NOT ingest_result EQUAL 0 OR
   NOT ingest_out MATCHES "state: completed" OR
   NOT ingest_out MATCHES "vector state: published")
    message(FATAL_ERROR "Native-surface prerequisite failed:\n${init_out}${init_err}${ingest_out}${ingest_err}")
endif()

execute_process(COMMAND ${cli} --format json query evidence
    "What does BillingService depend on?" --mode lexical
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE citation_query_out ERROR_VARIABLE citation_query_err
    RESULT_VARIABLE citation_query_result TIMEOUT 30)
string(REGEX MATCH "crexx-rag:[^\"\\\\]+" stable_citation "${citation_query_out}")
if(NOT citation_query_result EQUAL 0 OR stable_citation STREQUAL "")
    message(FATAL_ERROR "Could not obtain a stable citation for surface resolution:\n${citation_query_out}${citation_query_err}")
endif()

set(requests "${CPRAG_WORK_DIR}/mcp-requests.jsonl")
foreach(oversized 9223372036854775808 9999999999999999999999999999999999999999)
    foreach(option cursor limit)
        execute_process(COMMAND ${cli} --format json job events job-not-present
            "--${option}" "${oversized}"
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
            OUTPUT_VARIABLE range_out ERROR_VARIABLE range_err
            RESULT_VARIABLE range_result TIMEOUT 30)
        if(NOT range_result EQUAL 2 OR NOT range_out MATCHES "\"exit_code\":2" OR
           range_err MATCHES "PANIC")
            message(FATAL_ERROR "Numeric ${option} overflow did not return a validation error:\n${range_out}${range_err}")
        endif()
    endforeach()
endforeach()
foreach(cursor 0 0000000000000000000000000000000000000000 9223372036854775807)
    execute_process(COMMAND ${cli} --format json job events job-not-present
        --cursor "${cursor}" --limit 0001
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
        OUTPUT_VARIABLE range_out ERROR_VARIABLE range_err
        RESULT_VARIABLE range_result TIMEOUT 30)
    if(NOT range_result EQUAL 0 OR NOT range_out MATCHES "\"exit_code\":0")
        message(FATAL_ERROR "Valid numeric boundary rejected:\n${range_out}${range_err}")
    endif()
endforeach()

file(WRITE "${requests}"
    "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_answer\",\"arguments\":{\"question\":\"What does BillingService depend on?\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":4,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_evidence\",\"arguments\":{\"question\":\"What does BillingService depend on?\",\"mode\":\"lexical\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_library_status\",\"arguments\":{\"surprise\":1}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":6,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_maintain_plan\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_library_report\",\"arguments\":{\"top\":2,\"narrative\":\"off\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":8,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_library_snapshot\",\"arguments\":{\"trigger\":\"scheduled\",\"reason\":\"MCP surface observation\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":9,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_library_trend\",\"arguments\":{\"limit\":10}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":10,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_config_check\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":11,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_config_explain\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":12,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_config_diff\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":13,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_config_plan\",\"arguments\":{\"reason\":\"MCP configuration surface regression\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":14,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_job_replay\",\"arguments\":{\"id\":\"job-not-present\",\"reason\":\"MCP replay mapping regression\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":15,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_schedule_list\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":16,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_schedule_show\",\"arguments\":{\"id\":\"manual-maintenance\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":17,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_citation_show\",\"arguments\":{\"citation\":\"${stable_citation}\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":18,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_trace\",\"arguments\":{\"question\":\"What does BillingService depend on?\",\"mode\":\"lexical\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":19,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_path\",\"arguments\":{\"question\":\"What does BillingService depend on?\",\"mode\":\"lexical\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":20,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_timeline\",\"arguments\":{\"question\":\"What does BillingService depend on?\",\"mode\":\"lexical\"}}}\n")
file(APPEND "${requests}" "{\"jsonrpc\":\"2.0\",\"id\":21,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_vector_rebuild\",\"arguments\":{}}}\n")
execute_process(COMMAND ${cli} --access read,plan,curate,control,admin serve mcp
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" INPUT_FILE "${requests}"
    OUTPUT_VARIABLE mcp_out ERROR_VARIABLE mcp_err
    RESULT_VARIABLE mcp_result TIMEOUT 90)
if(NOT mcp_result EQUAL 0 OR
   NOT mcp_out MATCHES "\"operation\":\"vector.rebuild\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"serverInfo\":{\"name\":\"crexxrag-mcp\"" OR
   NOT mcp_out MATCHES "\"name\":\"rag_query_answer\".*\"readOnlyHint\":false,\"destructiveHint\":true,\"idempotentHint\":false,\"openWorldHint\":true" OR
   NOT mcp_out MATCHES "\"name\":\"rag_library_report\".*\"readOnlyHint\":false,\"destructiveHint\":true,\"idempotentHint\":false,\"openWorldHint\":true" OR
   NOT mcp_out MATCHES "\"name\":\"rag_library_snapshot\".*\"readOnlyHint\":false,\"destructiveHint\":true,\"idempotentHint\":false,\"openWorldHint\":false" OR
   NOT mcp_out MATCHES "\"name\":\"rag_library_trend\".*\"readOnlyHint\":true,\"destructiveHint\":false,\"idempotentHint\":true,\"openWorldHint\":false" OR
   NOT mcp_out MATCHES "\"name\":\"rag_config_check\".*\"readOnlyHint\":true" OR
   NOT mcp_out MATCHES "\"name\":\"rag_config_explain\".*\"readOnlyHint\":true" OR
   NOT mcp_out MATCHES "\"name\":\"rag_config_diff\".*\"readOnlyHint\":true" OR
   NOT mcp_out MATCHES "\"name\":\"rag_config_plan\".*\"readOnlyHint\":true" OR
   NOT mcp_out MATCHES "\"name\":\"rag_config_apply\".*\"readOnlyHint\":false" OR
   NOT mcp_out MATCHES "\"name\":\"rag_job_replay\".*\"readOnlyHint\":false" OR
   NOT mcp_out MATCHES "\"name\":\"rag_schedule_list\".*\"readOnlyHint\":true" OR
   NOT mcp_out MATCHES "\"name\":\"rag_schedule_show\".*\"readOnlyHint\":true" OR
   NOT mcp_out MATCHES "\"name\":\"rag_citation_show\".*\"readOnlyHint\":true" OR
   NOT mcp_out MATCHES "\"operation\":\"query.answer\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"generated_answer\":\"BillingService depends on CustomerDatabase\\.\"" OR
   NOT mcp_out MATCHES "\"citation\":\"crexx-rag:.*utf8-0-94\"" OR
   NOT mcp_out MATCHES "\"operation\":\"query.evidence\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"retrieval_mode\":\"lexical\"" OR
   NOT mcp_out MATCHES "\"lexical_candidates\":[1-9][0-9]*" OR
   NOT mcp_out MATCHES "\"lexical_passages\":[1-9][0-9]*" OR
   NOT mcp_out MATCHES "\"effective_lexical_limit\":48" OR
   NOT mcp_out MATCHES "\"effective_graph_hops\":3" OR
   NOT mcp_out MATCHES "\"provider_calls\":0" OR
   NOT mcp_out MATCHES "\"name\":\"rag_maintain_plan\"" OR
   NOT mcp_out MATCHES "\"name\":\"rag_maintain_apply\"" OR
   NOT mcp_out MATCHES "\"name\":\"rag_maintain_status\"" OR
   NOT mcp_out MATCHES "\"name\":\"rag_maintain_inspect\"" OR
   NOT mcp_out MATCHES "\"operation\":\"maintain.plan\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"operation\":\"library.report\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"operation\":\"library.snapshot\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"outcome\":\"skipped-identical\"" OR
   NOT mcp_out MATCHES "\"operation\":\"library.trend\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"state\":\"baseline-only\"" OR
   NOT mcp_out MATCHES "\"schema\":\"crexx-rag.library-report/1\"" OR
   NOT mcp_out MATCHES "\"actionable_dead_letters\":[0-9]+" OR
   NOT mcp_out MATCHES "\"replaying_dead_letters\":[0-9]+" OR
   NOT mcp_out MATCHES "\"resolved_dead_letters\":[0-9]+" OR
   NOT mcp_out MATCHES "\"coverage_millionths\":1000000" OR
   NOT mcp_out MATCHES "\"maintenance_digest\":\"[0-9a-f]+\"" OR
   NOT mcp_out MATCHES "\"operation\":\"config.check\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"operation\":\"config.explain\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"requests_per_minute\":[1-9][0-9]*" OR
   NOT mcp_out MATCHES "\"operation\":\"config.diff\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"classification\":\"identical\"" OR
   NOT mcp_out MATCHES "\"operation\":\"config.plan\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "crexx-rag.reconfigure-plan/1" OR
   NOT mcp_out MATCHES "\"operation\":\"job.replay\",\"status\":\"error\"" OR
   NOT mcp_out MATCHES "source job must be terminal with explicit dead letters" OR
   NOT mcp_out MATCHES "\"operation\":\"schedule.list\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"operation\":\"schedule.show\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"operation\":\"citation.show\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"kind\":\"citation-resolution\"" OR
   NOT mcp_out MATCHES "\"operation\":\"query.trace\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "crexx-rag.query-trace/1" OR
   NOT mcp_out MATCHES "\"operation\":\"query.path\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "crexx-rag.query-paths/1" OR
   NOT mcp_out MATCHES "\"operation\":\"query.timeline\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "crexx-rag.query-timeline/1" OR
   NOT mcp_out MATCHES "\"operation\":\"maintain.plan\"" OR
   NOT mcp_out MATCHES "\"recurrence_owner\":\"external\"" OR
   NOT mcp_out MATCHES "\"code\":-32602,\"message\":\"unknown object member surprise\"" OR
   mcp_out MATCHES "synthetic-product-gemini-key" OR
   mcp_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "Unified native MCP surface failed:\n${mcp_out}${mcp_err}")
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
    message(FATAL_ERROR "Native-surface Gemini loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=product-query connections=4")
    message(FATAL_ERROR "Native-surface Gemini loopback failed:\n${final_server_out}${final_server_err}")
endif()

execute_process(COMMAND ${cli} --access diagnose library verify
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
    RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "Unified-surface library verification failed:\n${verify_out}${verify_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "test=native-surfaces\nsurface=crexxrag-serve-mcp\nconfig=local-default\n"
    "structured_answer=validated\nlexical_provider_calls=0\ncitation_resolution=exact\nquery_projections=trace+path+timeline\n"
    "annotations=truthful\nreport=deterministic-mcp\nmaintenance=plan+apply+status+inspect-advertised\nmaintenance_plan=called\nunknown_arguments=rejected\nsecret_values_logged=0\n"
    "${init_out}${ingest_out}${ingest_err}${mcp_out}${mcp_err}${verify_out}${verify_err}")
message(STATUS "Native surfaces passed unified crexxrag MCP serving, stable citation resolution, dedicated trace/path/timeline projections, deterministic reporting, churn-governed snapshots, historic trends, maintenance vocabulary, discovered config, provider-backed structured answer, lexical zero-call route, truthful annotations, strict arguments, and clean integrity")
