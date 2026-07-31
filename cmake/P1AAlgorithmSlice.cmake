foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_MODULE CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(native_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${native_import}")

function(build_crexx name source imports)
    execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}" -o "${CPRAG_WORK_DIR}/${name}" "${source}"
        OUTPUT_VARIABLE rxc_out ERROR_VARIABLE rxc_err RESULT_VARIABLE rxc_result)
    if(NOT rxc_result EQUAL 0)
        message(FATAL_ERROR "${name} compile failed:\n${rxc_out}\n${rxc_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" -o "${CPRAG_WORK_DIR}/${name}" "${CPRAG_WORK_DIR}/${name}"
        OUTPUT_VARIABLE rxas_out ERROR_VARIABLE rxas_err RESULT_VARIABLE rxas_result)
    if(NOT rxas_result EQUAL 0)
        message(FATAL_ERROR "${name} assembly failed:\n${rxas_out}\n${rxas_err}")
    endif()
    file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt" "${name} rxc:\n${rxc_out}${rxc_err}\n${name} rxas:\n${rxas_out}${rxas_err}\n")
endfunction()

build_crexx(algorithm_slice "${CPRAG_MODULE}" "${native_import}")
build_crexx(algorithm-slice-test "${CPRAG_SOURCE}" "${program_import}")
execute_process(COMMAND "${CPRAG_RXVME}" -l "${program_import}" "${CPRAG_WORK_DIR}/algorithm-slice-test"
        algorithm_slice rx_sqlite_boundary library
    OUTPUT_VARIABLE output ERROR_VARIABLE error RESULT_VARIABLE result)
file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt" "rxvme:\n${output}${error}\nresult=${result}\n")
if(NOT result EQUAL 0 OR NOT output MATCHES "P1A_ALG_OK")
    message(FATAL_ERROR "Algorithm slice failed (${result}):\n${output}\n${error}")
endif()
message(STATUS "${output}")
