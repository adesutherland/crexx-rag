foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXLINK CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION_DIR CPRAG_SCENARIO CPRAG_MARKER CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(imports "${CPRAG_APPLICATION_DIR}/project;${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}" -o "${CPRAG_WORK_DIR}/contract" "${CPRAG_SCENARIO}"
    RESULT_VARIABLE result OUTPUT_VARIABLE out ERROR_VARIABLE err)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "Contract compile failed:\n${out}${err}")
endif()
execute_process(COMMAND "${CPRAG_RXAS}" -o "${CPRAG_WORK_DIR}/contract" "${CPRAG_WORK_DIR}/contract"
    RESULT_VARIABLE result OUTPUT_VARIABLE out ERROR_VARIABLE err)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "Contract assembly failed:\n${out}${err}")
endif()
execute_process(COMMAND "${CPRAG_RXLINK}" -s -r contract
    -p "${CPRAG_WORK_DIR}/contract_linked.rxproviders" -o "${CPRAG_WORK_DIR}/contract_linked"
    "${CPRAG_WORK_DIR}/contract.rxbin" "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.rxbin"
    "${CPRAG_CREXX_BIN_DIR}/rxfnsg.rxbin" "${CPRAG_CREXX_BIN_DIR}/classlib.rxbin" "${CPRAG_CREXX_BIN_DIR}/library.rxbin"
    RESULT_VARIABLE result OUTPUT_VARIABLE out ERROR_VARIABLE err)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "Contract link failed:\n${out}${err}")
endif()
foreach(runtime IN ITEMS "${CPRAG_RXVME}" "${CPRAG_RXBVM}")
    execute_process(COMMAND "${runtime}" --provider-path "${CPRAG_CREXX_BIN_DIR}/providers"
        -l "${CPRAG_WORK_DIR}" "${CPRAG_WORK_DIR}/contract_linked" -a "${CPRAG_WORK_DIR}"
        RESULT_VARIABLE result OUTPUT_VARIABLE out ERROR_VARIABLE err TIMEOUT 120)
    if(NOT result EQUAL 0 OR NOT out MATCHES "${CPRAG_MARKER}")
        message(FATAL_ERROR "${runtime} contract failed:\n${out}${err}")
    endif()
endforeach()
message(STATUS "${CPRAG_MARKER}: passed on both VMs")
