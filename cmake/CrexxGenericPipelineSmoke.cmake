foreach(required_var
        CPRAG_RUNNER
        CPRAG_IMPROVER
        CPRAG_CLI
        CPRAG_PLUGIN_DIR
        CPRAG_CREXX_BIN_DIR
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(source_file "${CPRAG_WORK_DIR}/generic-source.txt")
file(WRITE "${source_file}"
    "The Authentication Service uses PostgreSQL to read User Profile Data.\n"
    "The Backup Service protects User Profile Data and depends on PostgreSQL availability.\n")

set(ENV{PATH} "${CPRAG_CREXX_BIN_DIR}:$ENV{PATH}")

set(library "${CPRAG_WORK_DIR}/generic-smoke.cprag")
execute_process(
    COMMAND "${CPRAG_RUNNER}"
        --library "${library}"
        --profile generic
        --stages stage1,stage1b,stage2,stage2b,stage3,status
        --mode offline
        --source-file "${source_file}"
        --source-uri "test:generic:pipeline-smoke"
        --title "Generic pipeline smoke"
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
        --run-id "generic-pipeline-smoke"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE pipeline_result
    OUTPUT_VARIABLE pipeline_output
    ERROR_VARIABLE pipeline_error)
if(NOT pipeline_result EQUAL 0)
    message(FATAL_ERROR "generic pipeline smoke failed (${pipeline_result})\n${pipeline_output}\n${pipeline_error}")
endif()

foreach(expected
        "profile=generic"
        "profile_id=generic.hybrid.v1"
        "stage1 start"
        "stage1b start profile=generic"
        "stage2 start profile=generic"
        "stage2b complete"
        "stage3 start profile=generic"
        "status=dry-run"
        "\"queue_id\":\"stage3-generic-default\"")
    if(NOT pipeline_output MATCHES "${expected}")
        message(FATAL_ERROR "generic pipeline output missed ${expected}\n${pipeline_output}\n${pipeline_error}")
    endif()
endforeach()

execute_process(
    COMMAND "${CPRAG_IMPROVER}"
        --library "${library}"
        --profile generic
        --queue-id improve-generic-smoke
        --mode offline
        --stage2b-limit 5
        --stage2b-preview 2
        --stage3-limit 1
        --stage3-mode dry-run
        --max-cycles 1
        --no-require-models
        --run-root "${CPRAG_WORK_DIR}/improve"
        --run-id "generic-improve-smoke"
        --lock-dir "${CPRAG_WORK_DIR}/locks/improve.lock"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE improve_result
    OUTPUT_VARIABLE improve_output
    ERROR_VARIABLE improve_error)
if(NOT improve_result EQUAL 0)
    message(FATAL_ERROR "generic improvement smoke failed (${improve_result})\n${improve_output}\n${improve_error}")
endif()

foreach(expected
        "background improvement complete cycles=1"
        "queue_id=improve-generic-smoke"
        "stage2b complete"
        "stage3 start profile=generic")
    if(NOT improve_output MATCHES "${expected}")
        message(FATAL_ERROR "generic improvement output missed ${expected}\n${improve_output}\n${improve_error}")
    endif()
endforeach()

message(STATUS "CREXX generic pipeline smoke passed")
