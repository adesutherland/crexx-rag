foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_CREXX_BIN_DIR CPRAG_CONTRACT CPRAG_FACADE CPRAG_CLI CPRAG_SOURCE CPRAG_OPERATION_CONTRACT CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(native_import "${CPRAG_CREXX_BIN_DIR}")
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

build_crexx(surface_contract "${CPRAG_CONTRACT}" "${native_import}")
build_crexx(surface_facade "${CPRAG_FACADE}" "${program_import}")
build_crexx(surface-cli "${CPRAG_CLI}" "${program_import}")
build_crexx(surface-boundary-test "${CPRAG_SOURCE}" "${program_import}")

execute_process(COMMAND "${CPRAG_RXVME}" -l "${program_import}" "${CPRAG_WORK_DIR}/surface-cli" surface_facade surface_contract library
    OUTPUT_VARIABLE cli_out ERROR_VARIABLE cli_err RESULT_VARIABLE cli_result)
string(STRIP "${cli_out}" cli_json)
if(NOT cli_result EQUAL 0 OR cli_json STREQUAL "")
    message(FATAL_ERROR "Surface CLI failed (${cli_result}):\n${cli_out}\n${cli_err}")
endif()
execute_process(COMMAND "${CPRAG_RXVME}" -l "${program_import}" "${CPRAG_WORK_DIR}/surface-boundary-test"
        surface_facade surface_contract library -a "${cli_json}"
    OUTPUT_VARIABLE output ERROR_VARIABLE error RESULT_VARIABLE result)
file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt" "cli:\n${cli_out}${cli_err}result=${cli_result}\ntest:\n${output}${error}result=${result}\n")
if(NOT result EQUAL 0 OR NOT output MATCHES "P1A_SUR_OK")
    message(FATAL_ERROR "Surface boundary failed (${result}):\n${output}\n${error}")
endif()
file(READ "${CPRAG_OPERATION_CONTRACT}" operation_contract)
if(NOT operation_contract MATCHES "\"format\"[ \t\r\n]*:[ \t\r\n]*\"crexx.operation-contract\""
        OR NOT operation_contract MATCHES "\"formatVersion\"[ \t\r\n]*:[ \t\r\n]*1"
        OR NOT operation_contract MATCHES "\"operation\"[ \t\r\n]*:[ \t\r\n]*\"surface_operation.statusoperation.status_evidence\"")
    message(FATAL_ERROR "Installed-helper operation contract is malformed:\n${operation_contract}")
endif()
file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt"
    "operation contract (${CPRAG_OPERATION_CONTRACT}):\n${operation_contract}\n")
message(STATUS "${output}")
