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
    "BillingService depends on CustomerDatabase.\n")
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source")

if(NOT EXISTS "${CPRAG_NATIVE_APPLICATION}")
    message(FATAL_ERROR "native crexxrag application is required")
endif()

function(run_provider_smoke mode port expected_requests)
    set(port 0)
    set(CPRAG_FIXTURE_PORT 0)
    configure_file("${CPRAG_CONFIG_TEMPLATE}"
        "${CPRAG_WORK_DIR}/${mode}.conf" @ONLY)
    if(mode STREQUAL "aggregate")
        file(READ "${CPRAG_WORK_DIR}/${mode}.conf" aggregate_config)
        string(REPLACE "budget.input_tokens = 8192" "budget.input_tokens = 220"
            aggregate_config "${aggregate_config}")
        file(WRITE "${CPRAG_WORK_DIR}/${mode}.conf" "${aggregate_config}")
    endif()
    set(server_out "${CPRAG_WORK_DIR}/${mode}-loopback.out")
    set(server_err "${CPRAG_WORK_DIR}/${mode}-loopback.err")
    set(server_status "${CPRAG_WORK_DIR}/${mode}-loopback.status")
    set(scenario product-provider-smoke)
    if(mode STREQUAL "invalid")
        set(scenario product-provider-smoke-invalid)
    endif()
    execute_process(COMMAND /bin/sh -c
        "( \"$1\" \"$2\" ${expected_requests} \"$6\"; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
        p7r-01 "${CPRAG_LOOPBACK}" "${port}" "${server_out}"
        "${server_err}" "${server_status}" "${scenario}"
        RESULT_VARIABLE launch_result)
    if(NOT launch_result EQUAL 0)
        message(FATAL_ERROR "could not start ${mode} provider loopback")
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
        message(FATAL_ERROR "${mode} provider loopback did not become ready")
    endif()

    crexxrag_fixture_endpoint("${server_out}" "${CPRAG_WORK_DIR}/${mode}.conf")
    set(port "${CPRAG_FIXTURE_PORT}")
    set(cli "${CMAKE_COMMAND}" -E env
        "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
        "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
        "NO_COLOR=1"
        "${CPRAG_NATIVE_APPLICATION}" --config-file "${CPRAG_WORK_DIR}/${mode}.conf")
    if(mode STREQUAL "human" OR mode STREQUAL "aggregate")
        execute_process(COMMAND ${cli} provider test --yes
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
            OUTPUT_VARIABLE client_out ERROR_VARIABLE client_err
            RESULT_VARIABLE client_result TIMEOUT 90)
        if(mode STREQUAL "human")
            if(NOT client_result EQUAL 0 OR
               NOT client_out MATCHES "Provider smoke plan" OR
               NOT client_out MATCHES "Public synthetic text only" OR
               NOT client_out MATCHES "structured-generation" OR
               NOT client_out MATCHES "embedding-generation" OR
               NOT client_out MATCHES "state: validated" OR
               NOT client_out MATCHES "Monetary API cost: Not applicable" OR
               NOT client_out MATCHES "Provider smoke complete" OR
               NOT client_out MATCHES "Calls: *2")
                message(FATAL_ERROR "human provider smoke failed:\n${client_out}${client_err}")
            endif()
        else()
            if(NOT client_result EQUAL 6 OR
               (NOT client_out MATCHES "combined provider smoke usage exceeded the reviewed configuration ceiling" AND
                NOT client_err MATCHES "combined provider smoke usage exceeded the reviewed configuration ceiling"))
                message(FATAL_ERROR "aggregate provider budget rejection failed:\n${client_out}${client_err}")
            endif()
        endif()
    elseif(mode STREQUAL "json")
        execute_process(COMMAND ${cli} --format json --access diagnose
                provider test --provider gemini-embed
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
            OUTPUT_VARIABLE client_out ERROR_VARIABLE client_err
            RESULT_VARIABLE client_result TIMEOUT 90)
        if(NOT client_result EQUAL 0 OR
           NOT client_out MATCHES "\"operation\":\"provider.test\",\"status\":\"ok\"" OR
           NOT client_out MATCHES "\"operation\":\"embedding-generation\"" OR
           NOT client_out MATCHES "\"dimension\":768")
            message(FATAL_ERROR "machine provider smoke failed:\n${client_out}${client_err}")
        endif()
    elseif(mode STREQUAL "mcp")
        set(requests "${CPRAG_WORK_DIR}/mcp-requests.jsonl")
        file(WRITE "${requests}"
            "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/list\",\"params\":{}}\n"
            "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_provider_test\",\"arguments\":{}}}\n"
            "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_provider_test\",\"arguments\":{\"provider\":\"gemini-generate\"}}}\n")
        execute_process(COMMAND ${cli} --access diagnose serve mcp
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" INPUT_FILE "${requests}"
            OUTPUT_VARIABLE client_out ERROR_VARIABLE client_err
            RESULT_VARIABLE client_result TIMEOUT 90)
        if(NOT client_result EQUAL 0 OR
           NOT client_out MATCHES "\"name\":\"rag_provider_test\".*\"readOnlyHint\":true,\"destructiveHint\":false,\"idempotentHint\":false,\"openWorldHint\":true" OR
           NOT client_out MATCHES "\"code\":-32602,\"message\":\"tool requires argument provider\"" OR
           NOT client_out MATCHES "\"operation\":\"provider.test\",\"status\":\"ok\"" OR
           NOT client_out MATCHES "\"operation\":\"structured-generation\"")
            message(FATAL_ERROR "MCP provider smoke failed:\n${client_out}${client_err}")
        endif()
    elseif(mode STREQUAL "invalid")
        execute_process(COMMAND ${cli} --format json --access diagnose
                provider test --provider gemini-generate
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
            OUTPUT_VARIABLE client_out ERROR_VARIABLE client_err
            RESULT_VARIABLE client_result TIMEOUT 90)
        if(NOT client_result EQUAL 1 OR
           NOT client_out MATCHES "provider smoke answer citation is not the supplied public synthetic citation")
            message(FATAL_ERROR "invalid provider output was not rejected:\n${client_out}${client_err}")
        endif()
    else()
        message(FATAL_ERROR "unknown provider smoke mode ${mode}")
    endif()
    if(client_out MATCHES "synthetic-product-gemini-key" OR
       client_err MATCHES "synthetic-product-gemini-key")
        message(FATAL_ERROR "${mode} provider smoke disclosed its synthetic credential")
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
        message(FATAL_ERROR "${mode} provider loopback did not exit")
    endif()
    file(READ "${server_status}" server_result)
    file(READ "${server_out}" final_server_out)
    file(READ "${server_err}" final_server_err)
    if(NOT server_result STREQUAL "0" OR
       NOT final_server_out MATCHES "SUMMARY scenario=${scenario} connections=${expected_requests}")
        message(FATAL_ERROR "${mode} provider loopback failed:\n${final_server_out}${final_server_err}")
    endif()
    file(APPEND "${CPRAG_WORK_DIR}/result.txt"
        "mode=${mode} requests=${expected_requests} status=validated\n${client_out}${client_err}")
endfunction()

run_provider_smoke(human 19010 2)
run_provider_smoke(json 19011 1)
run_provider_smoke(mcp 19012 1)
run_provider_smoke(aggregate 19013 2)
run_provider_smoke(invalid 19014 1)

set(CPRAG_FIXTURE_PORT 19015)
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/no-budget-base.conf" @ONLY)
file(READ "${CPRAG_WORK_DIR}/no-budget-base.conf" no_budget)
string(REPLACE "budget.model_calls = 2" "budget.model_calls = 0"
    no_budget "${no_budget}")
file(WRITE "${CPRAG_WORK_DIR}/no-budget.conf" "${no_budget}")
execute_process(COMMAND "${CMAKE_COMMAND}" -E env
        "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
        "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
        "NO_COLOR=1"
        "${CPRAG_NATIVE_APPLICATION}"
        --config-file "${CPRAG_WORK_DIR}/no-budget.conf"
        --format json --access diagnose provider test --provider gemini-generate
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE budget_out ERROR_VARIABLE budget_err
    RESULT_VARIABLE budget_result TIMEOUT 30)
if(NOT budget_result EQUAL 6 OR
   NOT budget_out MATCHES "query provider calls exceed the configured per-command ceiling" OR
   budget_out MATCHES "synthetic-product-gemini-key" OR
   budget_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "zero-call budget rejection failed:\n${budget_out}${budget_err}")
endif()

set(CPRAG_FIXTURE_PORT 19016)
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/decline.conf" @ONLY)
file(WRITE "${CPRAG_WORK_DIR}/decline.txt" "n\n")
execute_process(COMMAND "${CMAKE_COMMAND}" -E env
        "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
        "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
        "NO_COLOR=1"
        "${CPRAG_NATIVE_APPLICATION}"
        --config-file "${CPRAG_WORK_DIR}/decline.conf" provider test
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}" INPUT_FILE "${CPRAG_WORK_DIR}/decline.txt"
    OUTPUT_VARIABLE decline_out ERROR_VARIABLE decline_err
    RESULT_VARIABLE decline_result TIMEOUT 30)
if(NOT decline_result EQUAL 9 OR
   NOT decline_out MATCHES "Cancelled: no provider calls were made" OR
   decline_out MATCHES "synthetic-product-gemini-key" OR
   decline_err MATCHES "synthetic-product-gemini-key")
    message(FATAL_ERROR "human provider-smoke cancellation failed:\n${decline_out}${decline_err}")
endif()

message(STATUS "Gemini provider smoke passed human, machine and MCP routes with exact output validation/rejection, truthful annotations, cancellation, aggregate and zero-call budget rejection, and secret-free output")
