file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
get_filename_component(crexx_prefix "${CPRAG_BIN}" DIRECTORY)
execute_process(COMMAND "${CMAKE_COMMAND}" -E env "CREXX_HOME=${crexx_prefix}" "${CPRAG_CREXX}" --program "${CPRAG_WORK_DIR}/interface"
    "${CPRAG_SCENARIO}" --noexec --jobs 1 -i "${CPRAG_BIN}/providers" --native
    RESULT_VARIABLE result OUTPUT_VARIABLE out ERROR_VARIABLE err)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "Vector interface build failed: ${out}${err}")
endif()
foreach(vm rxvme rxbvm)
    execute_process(COMMAND "${CPRAG_BIN}/${vm}" --provider-path "${CPRAG_BIN}/providers"
        -l "${CPRAG_BIN}" "${CPRAG_WORK_DIR}/interface" rxfnsg classlib library
        RESULT_VARIABLE result OUTPUT_VARIABLE out ERROR_VARIABLE err)
    if(NOT result EQUAL 0 OR NOT out MATCHES "VECTOR_PROVIDER_OK")
        message(FATAL_ERROR "${vm} vector interface failed: ${out}${err}")
    endif()
endforeach()
execute_process(COMMAND "${CPRAG_WORK_DIR}/interface"
    RESULT_VARIABLE result OUTPUT_VARIABLE out ERROR_VARIABLE err)
if(NOT result EQUAL 0 OR NOT out MATCHES "VECTOR_PROVIDER_OK")
    message(FATAL_ERROR "Native vector interface failed: ${out}${err}")
endif()
message(STATUS "Vector interface passed on rxvme, rxbvm and native")
