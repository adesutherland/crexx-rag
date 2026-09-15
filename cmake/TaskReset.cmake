find_program(python python3 REQUIRED)
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
execute_process(COMMAND "${python}" "${CMAKE_CURRENT_LIST_DIR}/../tests/fixtures/task-reset.py"
    "${CPRAG_NATIVE_APPLICATION}" "${CPRAG_CONFIG_TEMPLATE}" "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE errors TIMEOUT 120)
file(WRITE "${CPRAG_WORK_DIR}/result.log" "exit=${status}\n${output}${errors}")
if(NOT status EQUAL 0)
    message(FATAL_ERROR "Task reset acceptance failed: ${output}${errors}")
endif()
message(STATUS "Task reset -> resolution/closure passed: ${output}")
