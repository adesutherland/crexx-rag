foreach(required_var
        CPRAG_USE_CASE
        CPRAG_CLI
        CPRAG_MCP
        CPRAG_PLUGIN_DIR
        CPRAG_CREXX_BIN_DIR
        CPRAG_WORK_DIR
        CPRAG_SOURCE_FILE
        CPRAG_INCREMENTAL_SOURCE_FILE)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

function(assert_contains text needle context)
    string(FIND "${text}" "${needle}" found_pos)
    if(found_pos EQUAL -1)
        message(FATAL_ERROR "${context} did not contain '${needle}':\n${text}")
    endif()
endfunction()

function(run_checked label)
    execute_process(
        COMMAND ${ARGN}
        RESULT_VARIABLE command_result
        OUTPUT_VARIABLE command_output
        ERROR_VARIABLE command_error)
    if(NOT command_result EQUAL 0)
        message(FATAL_ERROR "${label} failed (${command_result})\n${command_output}\n${command_error}")
    endif()
    set(RUN_CHECKED_OUTPUT "${command_output}" PARENT_SCOPE)
    set(RUN_CHECKED_ERROR "${command_error}" PARENT_SCOPE)
endfunction()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")

set(ENV{PATH} "${CPRAG_CREXX_BIN_DIR}:$ENV{PATH}")
set(library "${CPRAG_WORK_DIR}/tutorial.cprag")

run_checked("initial-load use case"
    "${CPRAG_USE_CASE}" initial-load
        --library "${library}"
        --profile generic
        --mode offline
        --source-file "${CPRAG_SOURCE_FILE}"
        --source-uri "test:generic:initial"
        --title "Generic IT use-case smoke"
        --stage1-chunk-limit 2
        --stage1-limit 2
        --stage1b-min-count 1
        --stage1b-limit 20
        --stage2-page-size 20
        --stage2b-limit 5
        --stage2b-preview 3
        --stage3-limit 2
        --stage3-mode dry-run
        --no-require-models
        --cli "${CPRAG_CLI}"
        --plugin-dir "${CPRAG_PLUGIN_DIR}"
        --run-root "${CPRAG_WORK_DIR}/runs"
        --run-id "use-case-initial")
set(initial_output "${RUN_CHECKED_OUTPUT}")
foreach(expected
        "profile_id=generic.hybrid.v1"
        "stage1 start"
        "stage1b complete adjudicated=4"
        "stage2b complete ranked=1 queued=1"
        "status=dry-run"
        "\"documents\":1")
    assert_contains("${initial_output}" "${expected}" "initial-load output")
endforeach()

run_checked("search use case"
    "${CPRAG_USE_CASE}" search
        --library "${library}"
        --query "authentication database"
        --top-k 8
        --hops 2
        --bin "${CPRAG_CLI}")
set(search_output "${RUN_CHECKED_OUTPUT}")
foreach(expected
        "\"success\":true"
        "Authentication Service"
        "PostgreSQL"
        "associated-with"
        "generic:data-object:postgresql")
    assert_contains("${search_output}" "${expected}" "search output")
endforeach()

run_checked("qa-evidence use case"
    "${CPRAG_USE_CASE}" qa-evidence
        --library "${library}"
        --question "What evidence connects authentication to PostgreSQL?"
        --top-k 8
        --hops 2
        --mcp "${CPRAG_MCP}")
set(qa_output "${RUN_CHECKED_OUTPUT}")
foreach(expected
        "source_bound"
        "retrieval_plan"
        "narrative_chunks"
        "graph_claims"
        "graph_leads"
        "accepted-typed-edge"
        "mention-only")
    assert_contains("${qa_output}" "${expected}" "qa-evidence output")
endforeach()

run_checked("add-documents use case"
    "${CPRAG_USE_CASE}" add-documents
        --library "${library}"
        --profile generic
        --mode offline
        --source-file "${CPRAG_INCREMENTAL_SOURCE_FILE}"
        --source-uri "test:generic:incremental"
        --title "Reporting note"
        --stage1-chunk-limit 2
        --stage1-limit 2
        --stage1b-min-count 1
        --stage1b-limit 20
        --stage2-page-size 20
        --stage2b-limit 10
        --stage2b-preview 5
        --no-require-models
        --cli "${CPRAG_CLI}"
        --plugin-dir "${CPRAG_PLUGIN_DIR}"
        --run-root "${CPRAG_WORK_DIR}/runs"
        --run-id "use-case-add-documents")
set(add_output "${RUN_CHECKED_OUTPUT}")
foreach(expected
        "Reporting Component"
        "stage1b candidate=1 normalized=REPORTING COMPONENT"
        "stage2b complete ranked=2 queued=2"
        "\"documents\":2")
    assert_contains("${add_output}" "${expected}" "add-documents output")
endforeach()

run_checked("background-improve use case"
    "${CPRAG_USE_CASE}" background-improve
        --library "${library}"
        --profile generic
        --queue-id "improve-use-case-smoke"
        --mode offline
        --stage2b-limit 5
        --stage2b-preview 5
        --stage3-limit 2
        --stage3-mode dry-run
        --max-cycles 1
        --no-require-models
        --run-root "${CPRAG_WORK_DIR}/improve"
        --run-id "use-case-improve"
        --lock-dir "${CPRAG_WORK_DIR}/locks/improve.lock")
set(improve_output "${RUN_CHECKED_OUTPUT}")
foreach(expected
        "background improvement complete cycles=1"
        "queue_id=improve-use-case-smoke"
        "stage2b complete"
        "stage3 start profile=generic")
    assert_contains("${improve_output}" "${expected}" "background-improve output")
endforeach()

run_checked("type-review tutorial preview"
    "${CPRAG_CLI}" upsert-work-item
        "${library}"
        generic.hybrid.v1
        review
        type-review
        type:postgres
        0
        8
        pending
        "Accept PostgreSQL as a data object"
        "{\"entity_id\":\"generic:data-object:postgresql\",\"accepted_type\":\"data-object\",\"evidence\":\"tutorial review\"}")
run_checked("type-review tutorial resolve"
    "${CPRAG_CLI}" resolve-work-queue
        "${library}"
        generic.hybrid.v1
        review
        type-review
        10
        dry-run)
assert_contains("${RUN_CHECKED_OUTPUT}" "\"dry_run\":true" "type-review resolve output")
assert_contains("${RUN_CHECKED_OUTPUT}" "\"accepted_nodes\":1" "type-review resolve output")

run_checked("external-review tutorial preview"
    "${CPRAG_CLI}" upsert-work-item
        "${library}"
        generic.hybrid.v1
        review
        external-extraction-review
        external:redis
        0
        7
        pending
        "Promote reviewed external Redis proposal"
        "{\"node_id\":\"generic:data-object:redis\",\"node_type\":\"data-object\",\"node_label\":\"Redis\",\"description\":\"Reviewed cache concept\",\"source_id\":\"generic:service:authentication-service\",\"target_id\":\"generic:data-object:redis\",\"relationship_type\":\"associated-with\",\"edge_label\":\"Authentication Service associated with Redis\",\"confidence\":0.8,\"evidence\":\"tutorial external review\"}")
run_checked("external-review tutorial resolve"
    "${CPRAG_CLI}" resolve-work-queue
        "${library}"
        generic.hybrid.v1
        review
        external-extraction-review
        10
        dry-run)
assert_contains("${RUN_CHECKED_OUTPUT}" "\"dry_run\":true" "external-review resolve output")
assert_contains("${RUN_CHECKED_OUTPUT}" "\"accepted_nodes\":1" "external-review resolve output")
assert_contains("${RUN_CHECKED_OUTPUT}" "\"accepted_relationships\":1" "external-review resolve output")

message(STATUS "use-case wrapper smoke passed")
