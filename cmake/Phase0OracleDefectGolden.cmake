foreach(required_var CPRAG_DEFECT_CAPTURE CPRAG_GOLDEN CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var})
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
execute_process(
    COMMAND "${CPRAG_DEFECT_CAPTURE}"
    OUTPUT_VARIABLE actual
    ERROR_VARIABLE capture_error
    RESULT_VARIABLE capture_result)
if(NOT capture_result EQUAL 0)
    message(FATAL_ERROR "Phase-0 defect capture failed (${capture_result}):\n${capture_error}")
endif()
file(READ "${CPRAG_GOLDEN}" expected)
if(NOT actual STREQUAL expected)
    file(WRITE "${CPRAG_WORK_DIR}/actual.jsonl" "${actual}")
    message(FATAL_ERROR "Phase-0 defect golden mismatch\nEXPECTED:\n${expected}\nACTUAL:\n${actual}")
endif()
file(WRITE "${CPRAG_WORK_DIR}/actual.jsonl" "${actual}")
message(STATUS "Phase-0 negative defect golden matched exactly")
