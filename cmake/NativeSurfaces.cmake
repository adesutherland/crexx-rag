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
find_program(CPRAG_GAP_SQLITE sqlite3 REQUIRED)
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) FROM revision_chunks WHERE visible_to_generation IS NULL;" OUTPUT_VARIABLE current_chunks OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${cli} --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE closure_out ERROR_VARIABLE closure_err RESULT_VARIABLE closure_rc TIMEOUT 30)
if(NOT closure_rc EQUAL 0 OR NOT closure_out MATCHES "\"kind\":\"convergence-census\"" OR
   NOT closure_out MATCHES "\"current_chunks\":${current_chunks}" OR
   NOT closure_out MATCHES "\"incomplete_first_pass_chunks\":${current_chunks}")
    message(FATAL_ERROR "Read-only convergence census omitted current first-pass debt: ${closure_out}${closure_err}")
endif()
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/debt-report")
file(COPY "${CPRAG_WORK_DIR}/library" DESTINATION "${CPRAG_WORK_DIR}/debt-report")
set(debt_library "${CPRAG_WORK_DIR}/debt-report/library")
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${debt_library}/library.sqlite"
    "INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch,parent_task_id) VALUES('debt-open','fixture','note','open','fixture','fixture','{}','Open','pending',1,1,1,''),('debt-settled','fixture','note','settled','fixture','fixture','{}','Settled','resolved',1,1,1,''),('debt-reopened-old','fixture','note','reopened','old','fixture','{}','Old','resolved',1,1,1,''),('debt-reopened-new','fixture','note','reopened','new','fixture','{}','New','pending',1,2,2,'debt-reopened-old'),('debt-parked','fixture','note','parked','fixture','fixture','{}','Parked','pending',1,1,1,''); INSERT INTO maintenance_task_waivers(waiver_id,task_id,reason,state,created_epoch) VALUES('debt-parked-waiver','debt-parked','Reviewed exception','active',1);"
    RESULT_VARIABLE debt_seed_rc ERROR_VARIABLE debt_seed_err)
if(NOT debt_seed_rc EQUAL 0)
    message(FATAL_ERROR "Could not seed mixed logical-debt report fixture: ${debt_seed_err}")
endif()
execute_process(COMMAND ${cli} --library "${debt_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE debt_out ERROR_VARIABLE debt_err RESULT_VARIABLE debt_rc TIMEOUT 30)
if(NOT debt_rc EQUAL 0 OR NOT debt_out MATCHES "\"new_logical_questions\":4" OR
   NOT debt_out MATCHES "\"materially_reopened_questions\":1" OR
   NOT debt_out MATCHES "\"durable_settlements\":2" OR
   NOT debt_out MATCHES "\"parked_exceptions\":1" OR
   NOT debt_out MATCHES "\"closing_actionable_debt\":2" OR
   NOT debt_out MATCHES "\"reconciliation_delta\":0" OR
   NOT debt_out MATCHES "\"debt_reconciliation_available\":true")
    message(FATAL_ERROR "Mixed logical-debt ledger did not reconcile independently: ${debt_out}${debt_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${debt_library}/library.sqlite"
    "INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch,parent_task_id) VALUES('debt-unlinked-settlement','fixture','note','settled','second','fixture','{}','Unlinked settlement','resolved',1,2,2,''),('debt-orphan-version','fixture','note','orphan','fixture','fixture','{}','Orphan version','superseded',1,2,2,'');"
    RESULT_VARIABLE debt_legacy_rc ERROR_VARIABLE debt_legacy_err)
if(NOT debt_legacy_rc EQUAL 0)
    message(FATAL_ERROR "Could not seed unreconciled task-history control: ${debt_legacy_err}")
endif()
execute_process(COMMAND ${cli} --library "${debt_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE debt_legacy_out ERROR_VARIABLE debt_legacy_report_err RESULT_VARIABLE debt_legacy_report_rc TIMEOUT 30)
if(NOT debt_legacy_report_rc EQUAL 0 OR NOT debt_legacy_out MATCHES "\"reconciliation_delta\":0" OR
   NOT debt_legacy_out MATCHES "\"unreconciled_logical_questions\":2" OR
   NOT debt_legacy_out MATCHES "\"debt_reconciliation_available\":false")
    message(FATAL_ERROR "Offsetting lineage gaps must not be reported as reconciled: ${debt_legacy_out}${debt_legacy_report_err}")
endif()
# A settled assessment may later be superseded. Its durable decision is the
# historical settlement; the child is the reopening, not a new question.
# Check those facts from the source tables before inspecting the report.
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/debt-history")
file(COPY "${CPRAG_WORK_DIR}/library" DESTINATION "${CPRAG_WORK_DIR}/debt-history")
set(history_library "${CPRAG_WORK_DIR}/debt-history/library")
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" -bail "${history_library}/library.sqlite"
    "INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch,parent_task_id) VALUES('history-parent','fixture','note','history','old','fixture','{}','Old assessment','superseded',1,1,2,''),('history-child','fixture','note','history','changed','fixture','{}','Changed evidence','pending',1,2,2,'history-parent'); INSERT INTO maintenance_decisions(decision_id,task_id,item_id,provider_run_id,response_json,grounding_json,disposition,created_epoch) SELECT 'history-settlement','history-parent',(SELECT item_id FROM job_items ORDER BY item_id LIMIT 1),provider_run_id,'{\"action\":\"retain\"}','{}','retain:resolved',1 FROM provider_runs ORDER BY provider_run_id LIMIT 1;"
    RESULT_VARIABLE history_seed_rc ERROR_VARIABLE history_seed_err)
if(NOT history_seed_rc EQUAL 0)
    message(FATAL_ERROR "Could not seed superseded settlement fixture: ${history_seed_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${history_library}/library.sqlite"
    "SELECT (SELECT count(*) FROM maintenance_tasks WHERE state='pending' AND parent_task_id='history-parent')||':'||(SELECT count(*) FROM maintenance_decisions WHERE task_id='history-parent' AND disposition='retain:resolved')||':'||(SELECT count(*) FROM maintenance_tasks WHERE state='resolved' AND subject_id='history');"
    OUTPUT_VARIABLE history_facts OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT history_facts STREQUAL "1:1:0")
    message(FATAL_ERROR "Superseded-settlement source control is invalid: ${history_facts}")
endif()
# Accepted defer leaves its task unresolved. It is neither a settlement in the
# current version nor a settlement/reopening after a changed-evidence successor.
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/debt-defer")
file(COPY "${CPRAG_WORK_DIR}/library" DESTINATION "${CPRAG_WORK_DIR}/debt-defer")
set(defer_library "${CPRAG_WORK_DIR}/debt-defer/library")
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" -bail "${defer_library}/library.sqlite"
    "INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch,parent_task_id) VALUES('defer-parent','fixture','note','defer','old','fixture','{}','Deferred assessment','unresolved',1,1,1,''); INSERT INTO maintenance_decisions(decision_id,task_id,item_id,provider_run_id,response_json,grounding_json,disposition,created_epoch) SELECT 'defer-accepted','defer-parent',(SELECT item_id FROM job_items ORDER BY item_id LIMIT 1),provider_run_id,'{\"action\":\"defer\"}','{}','defer:review:accept',1 FROM provider_runs ORDER BY provider_run_id LIMIT 1;"
    RESULT_VARIABLE defer_seed_rc ERROR_VARIABLE defer_seed_err)
if(NOT defer_seed_rc EQUAL 0)
    message(FATAL_ERROR "Could not seed accepted-defer fixture: ${defer_seed_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${defer_library}/library.sqlite"
    "SELECT state||':'||(SELECT disposition FROM maintenance_decisions WHERE task_id='defer-parent')||':'||(SELECT json_extract(response_json,'$.action') FROM maintenance_decisions WHERE task_id='defer-parent') FROM maintenance_tasks WHERE task_id='defer-parent';"
    OUTPUT_VARIABLE defer_facts OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT defer_facts STREQUAL "unresolved:defer:review:accept:defer")
    message(FATAL_ERROR "Accepted-defer source control is invalid: ${defer_facts}")
endif()
execute_process(COMMAND ${cli} --library "${defer_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE defer_out ERROR_VARIABLE defer_err RESULT_VARIABLE defer_rc TIMEOUT 30)
if(NOT defer_rc EQUAL 0 OR NOT defer_out MATCHES "\"new_logical_questions\":1" OR
   NOT defer_out MATCHES "\"materially_reopened_questions\":0" OR
   NOT defer_out MATCHES "\"durable_settlements\":0" OR
   NOT defer_out MATCHES "\"closing_actionable_debt\":1" OR
   NOT defer_out MATCHES "\"reconciliation_delta\":0" OR
   NOT defer_out MATCHES "\"debt_reconciliation_available\":true")
    message(FATAL_ERROR "Accepted defer was counted as a settlement: ${defer_out}${defer_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" -bail "${defer_library}/library.sqlite"
    "UPDATE maintenance_tasks SET state='superseded' WHERE task_id='defer-parent'; INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch,parent_task_id) VALUES('defer-child','fixture','note','defer','changed','fixture','{}','Changed evidence','pending',1,2,2,'defer-parent');"
    RESULT_VARIABLE defer_child_rc ERROR_VARIABLE defer_child_err)
if(NOT defer_child_rc EQUAL 0)
    message(FATAL_ERROR "Could not seed deferred successor: ${defer_child_err}")
endif()
execute_process(COMMAND ${cli} --library "${defer_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE defer_child_out ERROR_VARIABLE defer_child_err RESULT_VARIABLE defer_child_report_rc TIMEOUT 30)
if(NOT defer_child_report_rc EQUAL 0 OR NOT defer_child_out MATCHES "\"new_logical_questions\":1" OR
   NOT defer_child_out MATCHES "\"materially_reopened_questions\":0" OR
   NOT defer_child_out MATCHES "\"materially_reopened_task_versions\":0" OR
   NOT defer_child_out MATCHES "\"durable_settlements\":0" OR
   NOT defer_child_out MATCHES "\"closing_actionable_debt\":1" OR
   NOT defer_child_out MATCHES "\"reconciliation_delta\":0" OR
   NOT defer_child_out MATCHES "\"debt_reconciliation_available\":true")
    message(FATAL_ERROR "Deferred predecessor fabricated a reopening: ${defer_child_out}${defer_child_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" -bail "${defer_library}/library.sqlite"
    "INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch,parent_task_id) VALUES('review-parent','fixture','note','reviewed','old','fixture','{}','Reviewed assessment','superseded',1,1,2,''),('review-child','fixture','note','reviewed','changed','fixture','{}','Changed evidence','pending',1,2,2,'review-parent'); INSERT INTO maintenance_decisions(decision_id,task_id,item_id,provider_run_id,response_json,grounding_json,disposition,created_epoch) SELECT 'review-accepted','review-parent',(SELECT item_id FROM job_items ORDER BY item_id LIMIT 1 OFFSET 1),provider_run_id,'{\"action\":\"retain\"}','{}','retain:review:accept',1 FROM provider_runs ORDER BY provider_run_id LIMIT 1;"
    RESULT_VARIABLE review_seed_rc ERROR_VARIABLE review_seed_err)
if(NOT review_seed_rc EQUAL 0)
    message(FATAL_ERROR "Could not seed terminal accepted-review control: ${review_seed_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${defer_library}/library.sqlite"
    "SELECT (SELECT count(*) FROM maintenance_tasks WHERE task_id='review-parent' AND state='superseded')||':'||(SELECT count(*) FROM maintenance_decisions WHERE task_id='review-parent' AND disposition='retain:review:accept' AND json_extract(response_json,'$.action')='retain')||':'||(SELECT count(*) FROM maintenance_tasks WHERE task_id='review-child' AND state='pending' AND parent_task_id='review-parent');"
    OUTPUT_VARIABLE review_facts OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT review_facts STREQUAL "1:1:1")
    message(FATAL_ERROR "Terminal accepted-review source control is invalid: ${review_facts}")
endif()
execute_process(COMMAND ${cli} --library "${defer_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE review_out ERROR_VARIABLE review_err RESULT_VARIABLE review_rc TIMEOUT 30)
if(NOT review_rc EQUAL 0 OR NOT review_out MATCHES "\"new_logical_questions\":2" OR
   NOT review_out MATCHES "\"materially_reopened_questions\":1" OR
   NOT review_out MATCHES "\"materially_reopened_task_versions\":1" OR
   NOT review_out MATCHES "\"durable_settlements\":1" OR
   NOT review_out MATCHES "\"closing_actionable_debt\":2" OR
   NOT review_out MATCHES "\"reconciliation_delta\":0" OR
   NOT review_out MATCHES "\"debt_reconciliation_available\":true")
    message(FATAL_ERROR "Terminal accepted review did not balance beside deferred review: ${review_out}${review_err}")
endif()
execute_process(COMMAND ${cli} --library "${history_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE history_out ERROR_VARIABLE history_err RESULT_VARIABLE history_rc TIMEOUT 30)
if(NOT history_rc EQUAL 0 OR NOT history_out MATCHES "\"new_logical_questions\":1" OR
   NOT history_out MATCHES "\"materially_reopened_questions\":1" OR
   NOT history_out MATCHES "\"durable_settlements\":1" OR
   NOT history_out MATCHES "\"closing_actionable_debt\":1" OR
   NOT history_out MATCHES "\"reconciliation_delta\":0" OR
   NOT history_out MATCHES "\"unreconciled_logical_questions\":0")
    message(FATAL_ERROR "Superseded settlement and changed-evidence reopening did not reconcile: ${history_out}${history_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${history_library}/library.sqlite" ".dump"
    OUTPUT_VARIABLE history_before)
execute_process(COMMAND ${cli} --library "${history_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE history_repeat ERROR_VARIABLE history_repeat_err RESULT_VARIABLE history_repeat_rc TIMEOUT 30)
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${history_library}/library.sqlite" ".dump"
    OUTPUT_VARIABLE history_after)
if(NOT history_repeat_rc EQUAL 0 OR NOT history_repeat STREQUAL history_out OR NOT history_before STREQUAL history_after)
    message(FATAL_ERROR "Repeated read-only logical-debt reporting changed state or results: ${history_repeat_err}")
endif()
# A retained settlement without a current leaf is incomplete history even if
# the arithmetic happens to cancel to zero.
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" -bail "${history_library}/library.sqlite"
    "DELETE FROM maintenance_tasks WHERE task_id='history-child';"
    RESULT_VARIABLE missing_leaf_rc ERROR_VARIABLE missing_leaf_err)
if(NOT missing_leaf_rc EQUAL 0)
    message(FATAL_ERROR "Could not seed missing-successor history: ${missing_leaf_err}")
endif()
execute_process(COMMAND ${cli} --library "${history_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE missing_leaf_out ERROR_VARIABLE missing_leaf_report_err RESULT_VARIABLE missing_leaf_report_rc TIMEOUT 30)
if(NOT missing_leaf_report_rc EQUAL 0 OR NOT missing_leaf_out MATCHES "\"reconciliation_delta\":0" OR
   NOT missing_leaf_out MATCHES "\"unreconciled_logical_questions\":1" OR
   NOT missing_leaf_out MATCHES "\"debt_reconciliation_available\":false")
    message(FATAL_ERROR "Missing current successor must remain unreconciled despite zero global delta: ${missing_leaf_out}${missing_leaf_report_err}")
endif()
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/debt-mixed")
file(COPY "${CPRAG_WORK_DIR}/library" DESTINATION "${CPRAG_WORK_DIR}/debt-mixed")
set(mixed_library "${CPRAG_WORK_DIR}/debt-mixed/library")
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" -bail "${mixed_library}/library.sqlite"
    "INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,workflow_id,parent_task_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch) VALUES('repeat-old','fixture','note','repeat','','','old','fixture','{}','Repeat old','resolved',1,1,1),('repeat-new','fixture','note','repeat','','repeat-old','new','fixture','{}','Repeat new','resolved',1,2,2),('superseded-old','fixture','note','superseded','','','old','fixture','{}','Old version','superseded',1,1,1),('superseded-new','fixture','note','superseded','','superseded-old','new','fixture','{}','New version','resolved',1,2,2),('dependent-origin','fixture','note','origin','','','origin','fixture','{}','Origin','resolved',1,1,1),('dependent-open','fixture','note','dependent','workflow:debt','','dependent','fixture','{}','Dependency','pending',1,2,2),('review-open','fixture','note','review','','','review','fixture','{}','Review','review',1,1,1),('failed-open','fixture','note','failed','','','failed','fixture','{}','Failed','failed',1,1,1),('waived-open','fixture','note','waived','','','waived','fixture','{}','Waived','pending',1,1,1); INSERT INTO maintenance_workflows(workflow_id,origin_task_id,kind,parent_concept_id,successors_json,state,created_generation,created_epoch,updated_epoch) SELECT 'workflow:debt','dependent-origin','split',concept_id,'[]','waiting',(SELECT published_generation FROM library_meta),1,1 FROM concepts LIMIT 1; INSERT INTO reviews(review_id,review_type,subject_id,state,proposal_json,created_at) VALUES('review-debt','maintenance-change','review-open','pending','{}','fixture'); INSERT INTO maintenance_task_waivers(waiver_id,task_id,reason,state,created_epoch) VALUES('waiver-debt','waived-open','Retain exception','active',1);"
    RESULT_VARIABLE mixed_seed_rc ERROR_VARIABLE mixed_seed_err)
if(NOT mixed_seed_rc EQUAL 0)
    message(FATAL_ERROR "Could not seed task-version and consequence controls: ${mixed_seed_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${mixed_library}/library.sqlite"
    "SELECT (SELECT count(DISTINCT kind||':'||subject_id||':'||workflow_id) FROM maintenance_tasks)||':'||(SELECT count(*) FROM maintenance_tasks WHERE state='resolved')||':'||(SELECT count(*) FROM reviews WHERE state='pending')||':'||(SELECT count(*) FROM maintenance_workflows WHERE state<>'complete')||':'||(SELECT count(*) FROM maintenance_tasks WHERE state='failed');"
    OUTPUT_VARIABLE mixed_facts OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT mixed_facts STREQUAL "7:4:1:1:1")
    message(FATAL_ERROR "Mixed source-state control is invalid: ${mixed_facts}")
endif()
execute_process(COMMAND ${cli} --library "${mixed_library}" --format json --access read library report --narrative off
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE mixed_out ERROR_VARIABLE mixed_err RESULT_VARIABLE mixed_rc TIMEOUT 30)
if(NOT mixed_rc EQUAL 0 OR NOT mixed_out MATCHES "\"new_logical_questions\":7" OR
   NOT mixed_out MATCHES "\"materially_reopened_questions\":1" OR
   NOT mixed_out MATCHES "\"durable_settlements\":4" OR
   NOT mixed_out MATCHES "\"parked_exceptions\":1" OR
   NOT mixed_out MATCHES "\"closing_actionable_debt\":3" OR
   NOT mixed_out MATCHES "\"unfinished_migrations\":1" OR
   NOT mixed_out MATCHES "\"pending_maintenance_reviews\":1" OR
   NOT mixed_out MATCHES "\"technically_held_or_failed_questions\":1" OR
   NOT mixed_out MATCHES "\"reconciliation_delta\":0" OR
   NOT mixed_out MATCHES "\"unreconciled_logical_questions\":0")
    message(FATAL_ERROR "Task versions, dependent work, review and technical holds did not reconcile: ${mixed_out}${mixed_err}")
endif()
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) FROM query_gaps;" OUTPUT_VARIABLE gaps_before OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${cli} --format json query evidence "unsupported quantum algorithm" --mode lexical --record-gaps false
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE quiet_out ERROR_VARIABLE quiet_err RESULT_VARIABLE quiet_rc TIMEOUT 30)
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) FROM query_gaps;" OUTPUT_VARIABLE gaps_quiet OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT quiet_rc EQUAL 0 OR NOT quiet_out MATCHES "\"query_gaps_recorded\":0" OR NOT gaps_before STREQUAL gaps_quiet)
    message(FATAL_ERROR "Evaluation evidence query changed durable gap demand: ${quiet_out}${quiet_err}")
endif()
file(WRITE "${CPRAG_WORK_DIR}/quiet-query-mcp.jsonl" "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_evidence\",\"arguments\":{\"question\":\"unsupported quantum algorithm\",\"mode\":\"lexical\",\"record_gaps\":false}}}\n")
execute_process(COMMAND ${cli} --access read serve mcp WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    INPUT_FILE "${CPRAG_WORK_DIR}/quiet-query-mcp.jsonl"
    OUTPUT_VARIABLE mcp_quiet_out ERROR_VARIABLE mcp_quiet_err RESULT_VARIABLE mcp_quiet_rc TIMEOUT 30)
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) FROM query_gaps;" OUTPUT_VARIABLE gaps_mcp_quiet OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT mcp_quiet_rc EQUAL 0 OR NOT mcp_quiet_out MATCHES "\"query_gaps_recorded\":0" OR NOT gaps_mcp_quiet STREQUAL gaps_quiet)
    message(FATAL_ERROR "MCP evaluation query changed durable gap demand: ${mcp_quiet_out}${mcp_quiet_err}")
endif()
execute_process(COMMAND ${cli} --format json query evidence "unsupported quantum algorithm" --mode lexical
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE observed_out ERROR_VARIABLE observed_err RESULT_VARIABLE observed_rc TIMEOUT 30)
execute_process(COMMAND "${CPRAG_GAP_SQLITE}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) FROM query_gaps;" OUTPUT_VARIABLE gaps_observed OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT observed_rc EQUAL 0 OR gaps_observed LESS_EQUAL gaps_quiet)
    message(FATAL_ERROR "Ordinary evidence query stopped recording durable gap demand: ${observed_out}${observed_err}")
endif()
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
