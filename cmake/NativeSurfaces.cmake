include("${CMAKE_CURRENT_LIST_DIR}/FixtureEndpoint.cmake")
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
set(CPRAG_FIXTURE_PORT 0)
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
        if(current_server_out MATCHES "READY [0-9]+")
            set(ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT ready)
    message(FATAL_ERROR "Native-surface Gemini loopback did not become ready")
endif()

# Exercise slow preparation after readiness; product call timeouts are separate.
if(CPRAG_SLOW_PREPARATION)
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 11)
endif()
crexxrag_fixture_endpoint("${server_out}" "${CPRAG_WORK_DIR}/crexxrag.conf")
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
file(APPEND "${requests}"
    "{\"jsonrpc\":\"2.0\",\"id\":22,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_job_reconcile_inspect\",\"arguments\":{\"id\":\"job-not-present\",\"item\":\"item-not-present\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":23,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_job_reconcile_apply\",\"arguments\":{\"id\":\"job-not-present\",\"item\":\"item-not-present\",\"expect_digest\":\"0000000000000000000000000000000000000000000000000000000000000000\"}}}\n")
execute_process(COMMAND ${cli} --access read,diagnose,plan,curate,control,admin serve mcp
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" INPUT_FILE "${requests}"
    OUTPUT_VARIABLE mcp_out ERROR_VARIABLE mcp_err
    RESULT_VARIABLE mcp_result TIMEOUT 90)
file(WRITE "${CPRAG_WORK_DIR}/mcp-out.jsonl" "${mcp_out}")
if(NOT mcp_result EQUAL 0 OR
   NOT mcp_out MATCHES "\"operation\":\"job.reconcile\",\"status\":\"error\"" OR
   NOT mcp_out MATCHES "\"name\":\"rag_job_reconcile_inspect\"" OR
   NOT mcp_out MATCHES "\"name\":\"rag_job_reconcile_apply\"" OR
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
   NOT mcp_out MATCHES "crexx-rag.query-paths/2" OR
   NOT mcp_out MATCHES "\"operation\":\"query.timeline\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "crexx-rag.query-timeline/2" OR
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

# Keep provider-free numeric checks outside the live fixture request interval.
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
    if(NOT range_result EQUAL 5 OR NOT range_out MATCHES "\"exit_code\":5")
        message(FATAL_ERROR "Valid numeric boundary did not reach missing-job validation:\n${range_out}${range_err}")
    endif()
endforeach()

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

# Historical filters validate before any provider request and keep unknowns explicit.
execute_process(COMMAND ${cli} --format json query evidence
    "What does BillingService depend on?" --mode lexical --at 2026 --time-unknown exclude
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE temporal_out ERROR_VARIABLE temporal_err RESULT_VARIABLE temporal_rc TIMEOUT 30)
if(NOT temporal_rc EQUAL 0 OR NOT temporal_out MATCHES "crexx-rag.evidence/2")
    message(FATAL_ERROR "Temporal query surface failed: ${temporal_out}${temporal_err}")
endif()
execute_process(COMMAND ${cli} --format json query evidence
    "BillingService" --at 2026-02-30
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE temporal_bad ERROR_VARIABLE temporal_bad_err RESULT_VARIABLE temporal_bad_rc TIMEOUT 30)
if(NOT temporal_bad_rc EQUAL 2)
    message(FATAL_ERROR "Invalid historical date did not fail before provider work: ${temporal_bad}${temporal_bad_err}")
endif()
file(WRITE "${CPRAG_WORK_DIR}/metadata-empty.json" "{\"schema\":\"crexx-rag.source-metadata/1\",\"descriptions\":[],\"relations\":[]}")
execute_process(COMMAND ${cli} --format json --access plan ingest plan
    --source-set architecture-docs --metadata-input "${CPRAG_WORK_DIR}/metadata-empty.json"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE metadata_out ERROR_VARIABLE metadata_err RESULT_VARIABLE metadata_rc TIMEOUT 30)
if(NOT metadata_rc EQUAL 0 OR NOT metadata_out MATCHES "canonical_plan")
    message(FATAL_ERROR "Metadata plan surface failed: ${metadata_out}${metadata_err}")
endif()

# Actual no-write paths must work under a client that only approves read tools.
file(SHA256 "${CPRAG_WORK_DIR}/library/library.sqlite" read_database_before)
execute_process(COMMAND ${cli} --format json --access read query inspect "unsupported quantum algorithm" --mode lexical
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE inspect_out ERROR_VARIABLE inspect_err RESULT_VARIABLE inspect_rc TIMEOUT 30)
if(NOT inspect_rc EQUAL 0 OR NOT inspect_out MATCHES "\"operation\":\"query.inspect\"")
    message(FATAL_ERROR "Read-only query was intercepted by the guided CLI alias: ${inspect_out}${inspect_err}")
endif()
execute_process(COMMAND ${cli} --format json --access read maintain tasks --limit 5
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE tasks_out ERROR_VARIABLE tasks_err RESULT_VARIABLE tasks_rc TIMEOUT 30)
if(NOT tasks_rc EQUAL 0 OR NOT tasks_out MATCHES "\"operation\":\"maintain.tasks\"")
    message(FATAL_ERROR "Task discovery was intercepted by the guided CLI alias: ${tasks_out}${tasks_err}")
endif()
file(WRITE "${requests}"
    "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"ping\"}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_task_list\",\"arguments\":{\"limit\":5}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_inspect\",\"arguments\":{\"question\":\"unsupported quantum algorithm\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":4,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_library_overview\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_job_list\",\"arguments\":{\"limit\":5}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":6,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_review_decide_preview\",\"arguments\":{\"id\":\"review-not-present\",\"decision\":\"reject\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_maintain_plan\",\"arguments\":{\"enrich_provenance\":false}}}\n")
file(APPEND "${requests}"
    "{\"jsonrpc\":\"2.0\",\"id\":8,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_proposal_plan\",\"arguments\":{\"input\":\"unused\",\"proposals_ndjson\":\"{}\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":9,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_proposal_plan\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":10,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_proposal_plan\",\"arguments\":{\"proposals_ndjson\":\"{}\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":11,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_task_evidence_inventory\",\"arguments\":{\"id\":\"task:not-present\",\"scope\":\"current\",\"kind\":\"catalogue\",\"limit\":1}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":12,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_task_refresh_plan\",\"arguments\":{\"id\":\"task:not-present\",\"reason\":\"fixture\",\"maximum_bytes\":1048576,\"maximum_concepts\":1000}}}\n")
execute_process(COMMAND ${cli} --access read,plan serve mcp
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" INPUT_FILE "${requests}"
    OUTPUT_FILE "${CPRAG_WORK_DIR}/mcp-read-only.jsonl"
    ERROR_VARIABLE read_err RESULT_VARIABLE read_rc TIMEOUT 60)
if(NOT read_rc EQUAL 0)
    message(FATAL_ERROR "Read MCP process failed: ${read_err}")
endif()
file(STRINGS "${CPRAG_WORK_DIR}/mcp-read-only.jsonl" read_responses)
list(LENGTH read_responses response_count)
if(NOT response_count EQUAL 12)
    message(FATAL_ERROR "Read MCP lost responses: ${response_count}")
endif()
foreach(response IN LISTS read_responses)
    string(JSON response_id GET "${response}" id)
    if(response_id EQUAL 1)
        string(JSON ping_type TYPE "${response}" result)
        if(NOT ping_type STREQUAL "OBJECT")
            message(FATAL_ERROR "MCP ping did not return an object")
        endif()
    elseif(response_id EQUAL 8 OR response_id EQUAL 9)
        string(JSON argument_error GET "${response}" error code)
        if(NOT argument_error EQUAL -32602)
            message(FATAL_ERROR "MCP accepted competing or absent proposal input: ${response}")
        endif()
    else()
        set(expected_code 0)
        if(response_id EQUAL 6 OR response_id EQUAL 11)
            set(expected_code 5)
        elseif(response_id EQUAL 10)
            set(expected_code 2)
        elseif(response_id EQUAL 12)
            set(expected_code 3)
        endif()
        string(JSON response_code GET "${response}" result structuredContent exit_code)
        if(NOT response_code EQUAL expected_code)
            message(FATAL_ERROR "Read MCP contract failed: ${response}")
        endif()
    endif()
endforeach()
file(SHA256 "${CPRAG_WORK_DIR}/library/library.sqlite" read_database_after)
if(NOT read_database_before STREQUAL read_database_after)
    message(FATAL_ERROR "Read-only MCP batch changed the SQLite database")
endif()
file(APPEND "${CPRAG_WORK_DIR}/result.txt" "read_only_mcp=zero-database-writes\nmissing_review_preview=rejected\nping=supported\n")

# Session stop acknowledges before EOF and never touches corpus/job state.
# Each invocation starts a fresh connection, including after a previous stop.
foreach(stop_case valid invalid_arguments unavailable_policy)
    set(stop_config "${CPRAG_WORK_DIR}/crexxrag.conf")
    if(stop_case STREQUAL unavailable_policy)
        set(stop_config "${CPRAG_WORK_DIR}/missing-session-policy.conf")
    endif()
    set(stop_arguments "{}")
    if(stop_case STREQUAL invalid_arguments)
        set(stop_arguments "{\"all\":true}")
    endif()
    file(WRITE "${requests}"
        "{\"jsonrpc\":\"2.0\",\"id\":0,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-06-18\",\"capabilities\":{},\"clientInfo\":{\"name\":\"session-stop-fixture\",\"version\":\"1\"}}}\n"
        "{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}\n"
        "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_mcp_stop\",\"arguments\":${stop_arguments}}}\n"
        "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"ping\"}\n")
    execute_process(COMMAND "${CPRAG_NATIVE_APPLICATION}" --config-file "${stop_config}"
        --library "${CPRAG_WORK_DIR}/library" --access read serve mcp
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}" INPUT_FILE "${requests}"
        OUTPUT_FILE "${CPRAG_WORK_DIR}/mcp-stop-${stop_case}.jsonl"
        ERROR_VARIABLE stop_err RESULT_VARIABLE stop_rc TIMEOUT 10)
    if(NOT stop_rc EQUAL 0)
        message(FATAL_ERROR "MCP stop failed: ${stop_case}: ${stop_rc}: ${stop_err}")
    endif()
    file(STRINGS "${CPRAG_WORK_DIR}/mcp-stop-${stop_case}.jsonl" stop_responses)
    list(LENGTH stop_responses stop_count)
    list(GET stop_responses 0 initialized_response)
    string(JSON initialized_id GET "${initialized_response}" id)
    string(JSON server_name GET "${initialized_response}" result serverInfo name)
    if(NOT initialized_id EQUAL 0 OR NOT server_name STREQUAL "crexxrag-mcp")
        message(FATAL_ERROR "Fresh MCP connection did not initialize after the prior stop")
    endif()
    list(GET stop_responses 1 stop_response)
    if(stop_case STREQUAL invalid_arguments)
        string(JSON stop_code GET "${stop_response}" error code)
        if(NOT stop_count EQUAL 3 OR NOT stop_code EQUAL -32602)
            message(FATAL_ERROR "Invalid stop request closed the MCP connection")
        endif()
        list(GET stop_responses 2 ping_response)
        string(JSON ping_id GET "${ping_response}" id)
        string(JSON ping_type TYPE "${ping_response}" result)
        if(NOT ping_id EQUAL 2 OR NOT ping_type STREQUAL "OBJECT")
            message(FATAL_ERROR "MCP did not remain usable after rejected stop")
        endif()
    else()
        string(JSON stop_code GET "${stop_response}" result structuredContent exit_code)
        string(JSON stop_operation GET "${stop_response}" result structuredContent operation)
        if(NOT stop_count EQUAL 2 OR NOT stop_code EQUAL 0 OR NOT stop_operation STREQUAL "mcp.stop")
            message(FATAL_ERROR "MCP stop did not acknowledge and stop before the next request")
        endif()
    endif()
endforeach()
file(SHA256 "${CPRAG_WORK_DIR}/library/library.sqlite" stop_database_after)
if(NOT read_database_after STREQUAL stop_database_after)
    message(FATAL_ERROR "MCP session stop changed corpus or job state")
endif()
file(APPEND "${CPRAG_WORK_DIR}/result.txt" "mcp_stop=acknowledge-then-exit\nstop_invalid_arguments=connection-retained\nstop_missing_policy=allowed\nstop_corpus=unchanged\n")

# Independent oversized immutable-text fixture: exercise Unicode paging through
# the public citation command without provider calls or changing the main case.
find_program(CPRAG_CITATION_SQLITE sqlite3 REQUIRED)
set(citation_library "${CPRAG_WORK_DIR}/citation-library")
file(COPY "${CPRAG_WORK_DIR}/library/" DESTINATION "${citation_library}")
execute_process(COMMAND "${CPRAG_CITATION_SQLITE}" "${citation_library}/library.sqlite"
    "UPDATE source_revision_texts SET normalized_utf8=replace(hex(zeroblob(50000)),'00','é🙂');"
    COMMAND_ERROR_IS_FATAL ANY)
string(REPEAT "é🙂" 50000 expected_text)
string(REGEX REPLACE ":utf8-[0-9]+-[0-9]+$" ":utf8-0-300000" large_citation "${stable_citation}")
set(citation_cursor "0")
set(reconstructed "")
foreach(page RANGE 1 20)
    execute_process(COMMAND ${cli} --library "${citation_library}" --access read --format json
            citation show "${large_citation}" --cursor "${citation_cursor}"
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE page_out
        ERROR_VARIABLE page_err RESULT_VARIABLE page_rc TIMEOUT 30)
    if(NOT page_rc EQUAL 0)
        message(FATAL_ERROR "Large citation page failed: ${page_out}${page_err}")
    endif()
    string(JSON page_text GET "${page_out}" records 0 fields text)
    string(JSON next_cursor GET "${page_out}" records 0 fields next_cursor)
    string(JSON text_complete GET "${page_out}" records 0 fields text_complete)
    if(text_complete OR (NOT next_cursor STREQUAL "" AND NOT next_cursor GREATER citation_cursor))
        message(FATAL_ERROR "Large citation page made a false completeness claim or did not advance")
    endif()
    string(APPEND reconstructed "${page_text}")
    if(next_cursor STREQUAL "")
        break()
    endif()
    set(citation_cursor "${next_cursor}")
endforeach()
if(NOT next_cursor STREQUAL "" OR NOT reconstructed STREQUAL expected_text)
    message(FATAL_ERROR "Large citation pages omitted, padded, duplicated or split Unicode source characters")
endif()
file(APPEND "${CPRAG_WORK_DIR}/result.txt" "large_citation=300000-utf8-bytes-exact-unicode-pagination\n")
