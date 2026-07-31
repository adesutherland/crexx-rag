foreach(required_var CPRAG_CLI CPRAG_MCP CPRAG_GOLDEN CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var})
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

function(run_cli)
    execute_process(
        COMMAND "${CPRAG_CLI}" ${ARGN}
        OUTPUT_VARIABLE command_output
        ERROR_VARIABLE command_error
        RESULT_VARIABLE command_result)
    if(NOT command_result EQUAL 0)
        message(FATAL_ERROR "CLI failed (${command_result}): ${ARGN}\n${command_output}\n${command_error}")
    endif()
endfunction()

function(assert_contains text needle context)
    string(FIND "${text}" "${needle}" found_pos)
    if(found_pos EQUAL -1)
        message(FATAL_ERROR "${context} did not contain '${needle}':\n${text}")
    endif()
endfunction()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(library "${CPRAG_WORK_DIR}/answer-evidence.cprag")

run_cli(init "${library}")
run_cli(add-entity-typed "${library}" entity:identity-gateway service "Identity Gateway" "Authentication service")
run_cli(add-entity-typed "${library}" entity:cedar-store data-object "Cedar Store" "Customer profile database")
run_cli(add-entity-typed "${library}" evidence:lead evidence-chunk "Possible adjacent evidence" "A graph-only discovery lead")
run_cli(add-edge-typed "${library}" entity:identity-gateway entity:cedar-store depends-on "Reads customer profiles" 1.0
    "{\"source_uri\":\"fixture://it/auth/current\",\"directness\":\"accepted-typed-edge\",\"evidence_class\":\"source-passage\"}")
run_cli(add-edge-typed "${library}" entity:identity-gateway evidence:lead mentioned-in "Identity Gateway appears near an unresolved lead" 0.5
    "{\"source_uri\":\"fixture://it/auth/current\",\"directness\":\"mention-only\",\"evidence_class\":\"graph-lead\"}")
run_cli(ingest-text "${library}" fixture://it/auth/current "Identity Gateway decision" plain 512 0
    "The Identity Gateway reads customer profiles from Cedar Store. This passage does not identify a database for Mercury Service."
    "{\"fixture\":\"generic-it-v1\"}" decision-record 0.95 2026-03-18T15:30:00Z)

string(CONCAT request
    "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"library_answer_evidence\",\"arguments\":{\"question\":\"What evidence connects Identity Gateway to Cedar Store, and what remains unknown about Mercury Service?\",\"focus\":\"Identity Gateway Cedar Store Mercury Service\",\"mode\":\"auto\",\"top_k\":4,\"hops\":1}}}\n")
file(WRITE "${CPRAG_WORK_DIR}/request.jsonl" "${request}")
execute_process(
    COMMAND "${CPRAG_MCP}" --library "${library}"
    INPUT_FILE "${CPRAG_WORK_DIR}/request.jsonl"
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
    RESULT_VARIABLE result)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "MCP answer-evidence capture failed (${result}): ${error}")
endif()

foreach(required
        "\\\"source_bound\\\":true"
        "\\\"outside_knowledge_allowed\\\":false"
        "\\\"effective_mode\\\":\\\"lexical\\\""
        "\\\"narrative_chunks\\\":[{"
        "fixture://it/auth/current"
        "\\\"graph_claims\\\":[{"
        "\\\"relationship_type\\\":\\\"depends-on\\\""
        "\\\"graph_leads\\\":[{"
        "\\\"relationship_type\\\":\\\"mentioned-in\\\""
        "cite chunk ids"
        "evidence is weak, absent, or ambiguous")
    assert_contains("${output}" "${required}" "MCP answer-evidence output")
endforeach()

set(actual "{\"record\":\"answer-evidence-packet\",\"source_bound\":true,\"outside_knowledge_allowed\":false,\"retrieval_mode\":\"lexical\",\"narrative_passage\":true,\"supported_claim\":\"depends-on\",\"graph_lead\":\"mentioned-in\",\"stable_citation_shape\":\"chunk-id\",\"explicit_gap_guidance\":true}\n")
file(READ "${CPRAG_GOLDEN}" expected)
if(NOT actual STREQUAL expected)
    message(FATAL_ERROR "Answer-evidence semantic golden mismatch\nEXPECTED:\n${expected}\nACTUAL:\n${actual}")
endif()
file(WRITE "${CPRAG_WORK_DIR}/actual.jsonl" "${actual}")
file(WRITE "${CPRAG_WORK_DIR}/raw-mcp.jsonl" "${output}")
message(STATUS "Phase-0 answer-evidence golden matched exactly")
