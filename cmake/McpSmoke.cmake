if(NOT DEFINED CPRAG_MCP)
    message(FATAL_ERROR "CPRAG_MCP is required")
endif()

if(NOT DEFINED CPRAG_WORK_DIR)
    message(FATAL_ERROR "CPRAG_WORK_DIR is required")
endif()

function(assert_contains text needle context)
    string(FIND "${text}" "${needle}" found_pos)
    if(found_pos EQUAL -1)
        message(FATAL_ERROR "${context} did not contain '${needle}':\n${text}")
    endif()
endfunction()

function(assert_not_contains text needle context)
    string(FIND "${text}" "${needle}" found_pos)
    if(NOT found_pos EQUAL -1)
        message(FATAL_ERROR "${context} contained '${needle}':\n${text}")
    endif()
endfunction()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(library "${CPRAG_WORK_DIR}/library.cprag")

string(CONCAT positive_requests
    "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"library_vocabulary\",\"arguments\":{}}}\n"
    "{\"id\":4,\"params\":{\"arguments\":{\"id\":\"entity:api\",\"node_type\":\"service\",\"label\":\"API\",\"description\":\"API service\"},\"name\":\"library_add_entity_typed\"},\"method\":\"tools/call\",\"jsonrpc\":\"2.0\"}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"tools/call\",\"params\":{\"name\":\"library_add_entity_typed\",\"arguments\":{\"id\":\"entity:db\",\"node_type\":\"data-object\",\"label\":\"DB\",\"description\":\"Database\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":6,\"method\":\"tools/call\",\"params\":{\"name\":\"library_add_edge_typed\",\"arguments\":{\"source_id\":\"entity:api\",\"target_id\":\"entity:db\",\"relationship_type\":\"accesses\",\"label\":\"Reads data\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"tools/call\",\"params\":{\"name\":\"library_shortest_path\",\"arguments\":{\"source_id\":\"entity:api\",\"target_id\":\"entity:db\"}}}\n")
file(WRITE "${CPRAG_WORK_DIR}/positive.jsonl" "${positive_requests}")

execute_process(
    COMMAND "${CPRAG_MCP}" --allow-writes --library "${library}"
    INPUT_FILE "${CPRAG_WORK_DIR}/positive.jsonl"
    OUTPUT_VARIABLE positive_output
    ERROR_VARIABLE positive_error
    RESULT_VARIABLE positive_result)

if(NOT positive_result EQUAL 0)
    message(FATAL_ERROR "MCP write-enabled smoke failed with ${positive_result}: ${positive_error}")
endif()

foreach(required library_vocabulary library_add_entity_typed entity:api accesses "\\\"found\\\":true")
    assert_contains("${positive_output}" "${required}" "MCP write-enabled smoke output")
endforeach()

foreach(forbidden "FOREIGN KEY" "\"found\":false" "\"error\"")
    assert_not_contains("${positive_output}" "${forbidden}" "MCP write-enabled smoke output")
endforeach()

string(CONCAT read_only_requests
    "{\"jsonrpc\":\"2.0\",\"id\":20,\"method\":\"tools/list\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":21,\"method\":\"tools/call\",\"params\":{\"name\":\"library_status\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":22,\"method\":\"tools/call\",\"params\":{\"name\":\"library_add_entity_typed\",\"arguments\":{\"id\":\"entity:blocked\",\"node_type\":\"service\",\"label\":\"Blocked\",\"description\":\"Should not write\"}}}\n")
file(WRITE "${CPRAG_WORK_DIR}/read-only.jsonl" "${read_only_requests}")

execute_process(
    COMMAND "${CPRAG_MCP}" --library "${library}"
    INPUT_FILE "${CPRAG_WORK_DIR}/read-only.jsonl"
    OUTPUT_VARIABLE read_only_output
    ERROR_VARIABLE read_only_error
    RESULT_VARIABLE read_only_result)

if(NOT read_only_result EQUAL 0)
    message(FATAL_ERROR "MCP read-only smoke failed with ${read_only_result}: ${read_only_error}")
endif()

assert_contains("${read_only_output}" "write tools are disabled" "MCP read-only smoke output")
assert_contains("${read_only_output}" "\\\"entities\\\":2" "MCP read-only smoke output")
assert_not_contains("${read_only_output}" "library_add_entity_typed" "MCP read-only tools/list output")

string(CONCAT validation_requests
    "{\n"
    "{\"jsonrpc\":\"2.0\",\"id\":30,\"method\":\"tools/call\",\"params\":{\"name\":\"library_search\",\"arguments\":{\"query\":\"api\",\"top_k\":\"bad\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":31,\"method\":\"tools/call\",\"params\":{\"name\":\"library_add_entity_typed\",\"arguments\":{\"node_type\":\"service\",\"label\":\"No id\",\"description\":\"Missing id\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":32,\"method\":\"tools/call\",\"params\":{\"name\":\"library_search\",\"arguments\":[]}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":33,\"method\":\"tools/call\",\"params\":{\"name\":\"library_nope\",\"arguments\":{}}}\n")
file(WRITE "${CPRAG_WORK_DIR}/validation.jsonl" "${validation_requests}")

execute_process(
    COMMAND "${CPRAG_MCP}" --allow-writes --library "${library}"
    INPUT_FILE "${CPRAG_WORK_DIR}/validation.jsonl"
    OUTPUT_VARIABLE validation_output
    ERROR_VARIABLE validation_error
    RESULT_VARIABLE validation_result)

if(NOT validation_result EQUAL 0)
    message(FATAL_ERROR "MCP validation smoke failed with ${validation_result}: ${validation_error}")
endif()

foreach(required "\"code\":-32700" "\"code\":-32602" "argument must be an integer: top_k" "missing required string argument: id" "params.arguments must be an object" "unknown tool: library_nope")
    assert_contains("${validation_output}" "${required}" "MCP validation smoke output")
endforeach()

message(STATUS "MCP smoke passed")
