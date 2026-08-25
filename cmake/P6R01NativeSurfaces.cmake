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
set(CPRAG_FIXTURE_PORT 19000)
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

set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 4 product-query; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p6r-01 "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start Phase-6 Gemini loopback")
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
    message(FATAL_ERROR "Phase-6 Gemini loopback did not become ready")
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
    message(FATAL_ERROR "Phase-6 native prerequisite failed:\n${init_out}${init_err}${ingest_out}${ingest_err}")
endif()

set(requests "${CPRAG_WORK_DIR}/mcp-requests.jsonl")
file(WRITE "${requests}"
    "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_answer\",\"arguments\":{\"question\":\"What does BillingService depend on?\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":4,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_query_evidence\",\"arguments\":{\"question\":\"What does BillingService depend on?\",\"mode\":\"lexical\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_library_status\",\"arguments\":{\"surprise\":1}}}\n")
execute_process(COMMAND ${cli} serve mcp
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" INPUT_FILE "${requests}"
    OUTPUT_VARIABLE mcp_out ERROR_VARIABLE mcp_err
    RESULT_VARIABLE mcp_result TIMEOUT 90)
if(NOT mcp_result EQUAL 0 OR
   NOT mcp_out MATCHES "\"serverInfo\":{\"name\":\"crexx-rag-mcp\"" OR
   NOT mcp_out MATCHES "\"name\":\"rag_query_answer\".*\"readOnlyHint\":true,\"destructiveHint\":false,\"idempotentHint\":false,\"openWorldHint\":true" OR
   NOT mcp_out MATCHES "\"operation\":\"query.answer\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"generated_answer\":\"BillingService depends on CustomerDatabase\\.\"" OR
   NOT mcp_out MATCHES "\"citation\":\"crexx-rag:.*utf8-0-87\"" OR
   NOT mcp_out MATCHES "\"operation\":\"query.evidence\",\"status\":\"ok\"" OR
   NOT mcp_out MATCHES "\"retrieval_mode\":\"lexical\"" OR
   NOT mcp_out MATCHES "\"provider_calls\":0" OR
   NOT mcp_out MATCHES "\"code\":-32602,\"message\":\"unknown object member surprise\"" OR
   mcp_out MATCHES "synthetic-product-gemini-key" OR
   mcp_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "Phase-6 unified native MCP surface failed:\n${mcp_out}${mcp_err}")
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
    message(FATAL_ERROR "Phase-6 Gemini loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=product-query connections=4")
    message(FATAL_ERROR "Phase-6 Gemini loopback failed:\n${final_server_out}${final_server_err}")
endif()

execute_process(COMMAND ${cli} --access diagnose library verify
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
    RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "Phase-6 unified-surface library verification failed:\n${verify_out}${verify_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "item=P6R-01\nsurface=crexxrag-serve-mcp\nconfig=local-default\n"
    "structured_answer=validated\nlexical_provider_calls=0\n"
    "annotations=truthful\nunknown_arguments=rejected\nsecret_values_logged=0\n"
    "${init_out}${ingest_out}${ingest_err}${mcp_out}${mcp_err}${verify_out}${verify_err}")
message(STATUS "P6R-01 passed unified native crexxrag MCP serving, discovered config, provider-backed structured answer, lexical zero-call route, truthful annotations, strict arguments, and clean integrity")
