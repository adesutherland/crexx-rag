foreach(required_var
        CPRAG_RXC
        CPRAG_RXAS
        CPRAG_RXVME
        CPRAG_PROFILE
        CPRAG_PLUGIN_DIR
        CPRAG_CREXX_BIN_DIR
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

set(output_base "${CPRAG_WORK_DIR}/balanced-profile")
set(import_path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")

file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(REMOVE "${output_base}.rxas" "${output_base}.rxbin")
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}/example.cprag")

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${import_path}" -o "${output_base}" "${CPRAG_PROFILE}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxc_result
    OUTPUT_VARIABLE rxc_output
    ERROR_VARIABLE rxc_error)
if(NOT rxc_result EQUAL 0)
    message(FATAL_ERROR "rxc failed (${rxc_result})\n${rxc_output}\n${rxc_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${output_base}" "${output_base}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxas_result
    OUTPUT_VARIABLE rxas_output
    ERROR_VARIABLE rxas_error)
if(NOT rxas_result EQUAL 0)
    message(FATAL_ERROR "rxas failed (${rxas_result})\n${rxas_output}\n${rxas_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXVME}" -l "${CPRAG_PLUGIN_DIR}" "${output_base}" rx_rag
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxvme_result
    OUTPUT_VARIABLE rxvme_output
    ERROR_VARIABLE rxvme_error)
if(NOT rxvme_result EQUAL 0)
    message(FATAL_ERROR "rxvme failed (${rxvme_result})\n${rxvme_output}\n${rxvme_error}")
endif()

if(NOT rxvme_output MATCHES "\"sources\"")
    message(FATAL_ERROR "rxvme output did not include source listing\n${rxvme_output}\n${rxvme_error}")
endif()
if(NOT rxvme_output MATCHES "\"chunks\"")
    message(FATAL_ERROR "rxvme output did not include search chunks\n${rxvme_output}\n${rxvme_error}")
endif()

message(STATUS "CREXX profile smoke passed")
