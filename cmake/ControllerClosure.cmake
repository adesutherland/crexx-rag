find_program(CPRAG_PYTHON python3 REQUIRED)
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
execute_process(COMMAND "${CPRAG_PYTHON}" "${CPRAG_FIXTURE}"
    --application "${CPRAG_NATIVE_APPLICATION}" --work-dir "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE status OUTPUT_VARIABLE result ERROR_VARIABLE detail TIMEOUT 100)
file(WRITE "${CPRAG_WORK_DIR}/acceptance.log" "${result}${detail}")
if(NOT status EQUAL 0)
    message(FATAL_ERROR "Controller closure acceptance failed: ${result}${detail}")
endif()
message(STATUS "Controller output-pipe and signal acceptance passed")
