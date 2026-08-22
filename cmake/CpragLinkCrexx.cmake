function(cprag_link_crexx output_base label)
    if(NOT DEFINED CPRAG_RXLINK OR CPRAG_RXLINK STREQUAL "")
        message(FATAL_ERROR "CPRAG_RXLINK is required to link ${label}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXLINK}" -s -o "${output_base}" ${ARGN}
        OUTPUT_VARIABLE link_out
        ERROR_VARIABLE link_err
        RESULT_VARIABLE link_result)
    if(NOT link_result EQUAL 0)
        message(FATAL_ERROR
            "${label} link failed (${link_result}):\n${link_out}\n${link_err}")
    endif()
endfunction()
