if(NOT CPRAG_CLI)
    message(FATAL_ERROR "CPRAG_CLI is required")
endif()
if(NOT CPRAG_WORK_DIR)
    message(FATAL_ERROR "CPRAG_WORK_DIR is required")
endif()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(LIB "${CPRAG_WORK_DIR}/cli-work-queue.cprag")

function(run_cli)
    execute_process(
        COMMAND "${CPRAG_CLI}" ${ARGN}
        RESULT_VARIABLE rc
        OUTPUT_VARIABLE out
        ERROR_VARIABLE err
        COMMAND_ECHO STDOUT)
    if(NOT rc EQUAL 0)
        message(FATAL_ERROR "command failed (${rc}): ${CPRAG_CLI} ${ARGN}\nstdout:\n${out}\nstderr:\n${err}")
    endif()
    set(RUN_CLI_OUTPUT "${out}" PARENT_SCOPE)
endfunction()

run_cli(init "${LIB}")
run_cli(add-entity-typed "${LIB}" entity:auth unknown Authentication "Auth service" "{}")
run_cli(add-entity-typed "${LIB}" entity:postgres data-object PostgreSQL "Database" "{}")

run_cli(
    upsert-work-item
    "${LIB}"
    generic.hybrid.v1
    review
    type-review
    type:auth
    0
    8
    pending
    "accept service type"
    "{\"entity_id\":\"entity:auth\",\"accepted_type\":\"service\",\"evidence\":\"cli accepted type\"}")
run_cli(resolve-work-queue "${LIB}" generic.hybrid.v1 review type-review 10 apply)
if(NOT RUN_CLI_OUTPUT MATCHES "\"processed\":1")
    message(FATAL_ERROR "type-review did not process:\n${RUN_CLI_OUTPUT}")
endif()

run_cli(
    upsert-work-item
    "${LIB}"
    generic.hybrid.v1
    review
    external-extraction-review
    external:redis
    0
    7
    pending
    "promote external extraction"
    "{\"node_id\":\"entity:redis\",\"node_type\":\"data-object\",\"node_label\":\"Redis\",\"description\":\"Redis cache\",\"source_id\":\"entity:auth\",\"target_id\":\"entity:redis\",\"relationship_type\":\"uses\",\"edge_label\":\"Authentication uses Redis\",\"confidence\":0.8}")
run_cli(resolve-work-queue "${LIB}" generic.hybrid.v1 review external-extraction-review 10 apply)
if(NOT RUN_CLI_OUTPUT MATCHES "\"accepted_nodes\":1")
    message(FATAL_ERROR "external extraction review did not accept node:\n${RUN_CLI_OUTPUT}")
endif()
if(NOT RUN_CLI_OUTPUT MATCHES "\"accepted_relationships\":1")
    message(FATAL_ERROR "external extraction review did not accept relationship:\n${RUN_CLI_OUTPUT}")
endif()

run_cli(subgraph "${LIB}" service,data-object uses 10)
if(NOT RUN_CLI_OUTPUT MATCHES "\"id\":\"entity:redis\"")
    message(FATAL_ERROR "external node missing from CLI subgraph:\n${RUN_CLI_OUTPUT}")
endif()
if(NOT RUN_CLI_OUTPUT MATCHES "\"relationship_type\":\"uses\"")
    message(FATAL_ERROR "external edge missing from CLI subgraph:\n${RUN_CLI_OUTPUT}")
endif()

run_cli(queue-status "${LIB}" generic.hybrid.v1 review)
if(NOT RUN_CLI_OUTPUT MATCHES "\"item_type\":\"type-review\"")
    message(FATAL_ERROR "type-review missing from CLI queue status:\n${RUN_CLI_OUTPUT}")
endif()
if(NOT RUN_CLI_OUTPUT MATCHES "\"item_type\":\"external-extraction-review\"")
    message(FATAL_ERROR "external review missing from CLI queue status:\n${RUN_CLI_OUTPUT}")
endif()
