if(NOT DEFINED CPRAG_ORACLE_CAPTURE)
    message(FATAL_ERROR "CPRAG_ORACLE_CAPTURE is required")
endif()
if(NOT DEFINED CPRAG_GOLDEN)
    message(FATAL_ERROR "CPRAG_GOLDEN is required")
endif()
if(NOT DEFINED CPRAG_WORK_DIR)
    message(FATAL_ERROR "CPRAG_WORK_DIR is required")
endif()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
execute_process(
    COMMAND "${CPRAG_ORACLE_CAPTURE}"
    OUTPUT_VARIABLE actual
    ERROR_VARIABLE capture_error
    RESULT_VARIABLE capture_result)
if(NOT capture_result EQUAL 0)
    message(FATAL_ERROR "Phase-0 semantic oracle failed (${capture_result}):\n${capture_error}")
endif()

file(READ "${CPRAG_GOLDEN}" expected)
if(NOT actual STREQUAL expected)
    file(WRITE "${CPRAG_WORK_DIR}/actual.jsonl" "${actual}")
    message(FATAL_ERROR
        "Phase-0 semantic golden mismatch. Actual retained at ${CPRAG_WORK_DIR}/actual.jsonl\n"
        "EXPECTED:\n${expected}\nACTUAL:\n${actual}")
endif()
file(WRITE "${CPRAG_WORK_DIR}/actual.jsonl" "${actual}")
message(STATUS "Phase-0 semantic golden matched exactly")
