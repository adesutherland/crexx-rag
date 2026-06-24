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

set(output_base "${CPRAG_WORK_DIR}/deterministic-extractor")
set(import_path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")

file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(REMOVE "${output_base}.rxas" "${output_base}.rxbin")
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}/history-deterministic.cprag")

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${import_path}" -o "${output_base}" "${CPRAG_PROFILE}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxc_result
    OUTPUT_VARIABLE rxc_output
    ERROR_VARIABLE rxc_error)
if(NOT rxc_result EQUAL 0)
    message(FATAL_ERROR "rxc deterministic extractor failed (${rxc_result})\n${rxc_output}\n${rxc_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${output_base}" "${output_base}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxas_result
    OUTPUT_VARIABLE rxas_output
    ERROR_VARIABLE rxas_error)
if(NOT rxas_result EQUAL 0)
    message(FATAL_ERROR "rxas deterministic extractor failed (${rxas_result})\n${rxas_output}\n${rxas_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXVME}" -l "${CPRAG_PLUGIN_DIR}" "${output_base}" rx_rag
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxvme_result
    OUTPUT_VARIABLE rxvme_output
    ERROR_VARIABLE rxvme_error)
if(NOT rxvme_result EQUAL 0)
    message(FATAL_ERROR "rxvme deterministic extractor failed (${rxvme_result})\n${rxvme_output}\n${rxvme_error}")
endif()

foreach(expected
        "\"entities\":15"
        "\"edges\":24"
        "history.scotland.deterministic.v2"
        "history.athens.deterministic.v2"
        "evidence-chunk"
        "\"matched_alias\":\"Sudrland\""
        "mentioned-in"
        "held-land-in"
        "associated-with"
        "conflicted-with"
        "built-or-improved"
        "treasury-at"
        "\"found\":true"
        "digraph cprag")
    if(NOT rxvme_output MATCHES "${expected}")
        message(FATAL_ERROR "deterministic extractor output missed ${expected}\n${rxvme_output}\n${rxvme_error}")
    endif()
endforeach()

message(STATUS "CREXX deterministic extractor smoke passed")
