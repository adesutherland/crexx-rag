if(NOT DEFINED CPRAG_MCP)
    message(FATAL_ERROR "CPRAG_MCP is required")
endif()

if(NOT DEFINED CPRAG_WORK_DIR)
    message(FATAL_ERROR "CPRAG_WORK_DIR is required")
endif()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")

set(requests
    "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\",\"params\":{}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"library_vocabulary\",\"arguments\":{}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":4,\"method\":\"tools/call\",\"params\":{\"name\":\"library_add_entity_typed\",\"arguments\":{\"id\":\"entity:api\",\"node_type\":\"service\",\"label\":\"API\",\"description\":\"API service\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"tools/call\",\"params\":{\"name\":\"library_add_entity_typed\",\"arguments\":{\"id\":\"entity:db\",\"node_type\":\"data-object\",\"label\":\"DB\",\"description\":\"Database\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":6,\"method\":\"tools/call\",\"params\":{\"name\":\"library_add_edge_typed\",\"arguments\":{\"source_id\":\"entity:api\",\"target_id\":\"entity:db\",\"relationship_type\":\"accesses\",\"label\":\"Reads data\"}}}\n"
    "{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"tools/call\",\"params\":{\"name\":\"library_shortest_path\",\"arguments\":{\"source_id\":\"entity:api\",\"target_id\":\"entity:db\"}}}\n")
file(WRITE "${CPRAG_WORK_DIR}/requests.jsonl" "${requests}")

execute_process(
    COMMAND "${CPRAG_MCP}" --library "${CPRAG_WORK_DIR}/library.cprag"
    INPUT_FILE "${CPRAG_WORK_DIR}/requests.jsonl"
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
    RESULT_VARIABLE result)

if(NOT result EQUAL 0)
    message(FATAL_ERROR "MCP smoke failed with ${result}: ${error}")
endif()

foreach(required library_vocabulary library_add_entity_typed entity:api accesses)
    string(FIND "${output}" "${required}" required_pos)
    if(required_pos EQUAL -1)
        message(FATAL_ERROR "MCP smoke output did not contain '${required}':\n${output}")
    endif()
endforeach()

foreach(forbidden "FOREIGN KEY" "\"found\":false")
    string(FIND "${output}" "${forbidden}" forbidden_pos)
    if(NOT forbidden_pos EQUAL -1)
        message(FATAL_ERROR "MCP smoke output contained '${forbidden}':\n${output}")
    endif()
endforeach()
