foreach(required_var
        CPRAG_RXC
        CPRAG_RXAS
        CPRAG_RXVME
        CPRAG_PROFILE
        CPRAG_PROFILE_MODULE
        CPRAG_STAGE1B_PROFILE
        CPRAG_PLUGIN_DIR
        CPRAG_CREXX_BIN_DIR
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

set(output_base "${CPRAG_WORK_DIR}/hybrid-extractor")
set(profile_module_base "${CPRAG_WORK_DIR}/pipeline_profile")
set(stage1b_base "${CPRAG_WORK_DIR}/stage1b-adjudicate")
set(import_path "${CPRAG_WORK_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")

file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(REMOVE
    "${profile_module_base}.rxas" "${profile_module_base}.rxbin"
    "${output_base}.rxas" "${output_base}.rxbin"
    "${stage1b_base}.rxas" "${stage1b_base}.rxbin")
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}/history-hybrid.cprag")

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${import_path}" -o "${profile_module_base}" "${CPRAG_PROFILE_MODULE}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE profile_module_rxc_result
    OUTPUT_VARIABLE profile_module_rxc_output
    ERROR_VARIABLE profile_module_rxc_error)
if(NOT profile_module_rxc_result EQUAL 0)
    message(FATAL_ERROR "rxc profile module failed (${profile_module_rxc_result})\n${profile_module_rxc_output}\n${profile_module_rxc_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${profile_module_base}" "${profile_module_base}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE profile_module_rxas_result
    OUTPUT_VARIABLE profile_module_rxas_output
    ERROR_VARIABLE profile_module_rxas_error)
if(NOT profile_module_rxas_result EQUAL 0)
    message(FATAL_ERROR "rxas profile module failed (${profile_module_rxas_result})\n${profile_module_rxas_output}\n${profile_module_rxas_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${import_path}" -o "${output_base}" "${CPRAG_PROFILE}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxc_result
    OUTPUT_VARIABLE rxc_output
    ERROR_VARIABLE rxc_error)
if(NOT rxc_result EQUAL 0)
    message(FATAL_ERROR "rxc hybrid extractor failed (${rxc_result})\n${rxc_output}\n${rxc_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${output_base}" "${output_base}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxas_result
    OUTPUT_VARIABLE rxas_output
    ERROR_VARIABLE rxas_error)
if(NOT rxas_result EQUAL 0)
    message(FATAL_ERROR "rxas hybrid extractor failed (${rxas_result})\n${rxas_output}\n${rxas_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXVME}" -l "${CPRAG_PLUGIN_DIR}" "${output_base}" pipeline_profile rx_rag
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE rxvme_result
    OUTPUT_VARIABLE rxvme_output
    ERROR_VARIABLE rxvme_error)
if(NOT rxvme_result EQUAL 0)
    message(FATAL_ERROR "rxvme hybrid extractor failed (${rxvme_result})\n${rxvme_output}\n${rxvme_error}")
endif()

foreach(expected
        "history.scotland.hybrid.v1"
        "stage1 start mode=deterministic"
        "stage2 start chunk=1"
        "pipeline processed=1 offset=0 mode=offline profile=scotland"
        "stage3 start profile=scotland ambiguity_nodes=1"
        "route=deterministic"
        "\"entities\":10"
        "\"edges\":17"
        "ambiguity:chunk:1:Sutherland"
        "candidate-for"
        "mentioned-in"
        "held-land-in"
        "associated-with"
        "conflicted-with"
        "digraph cprag")
    if(NOT rxvme_output MATCHES "${expected}")
        message(FATAL_ERROR "hybrid extractor output missed ${expected}\n${rxvme_output}\n${rxvme_error}")
    endif()
endforeach()

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${import_path}" -o "${stage1b_base}" "${CPRAG_STAGE1B_PROFILE}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE stage1b_rxc_result
    OUTPUT_VARIABLE stage1b_rxc_output
    ERROR_VARIABLE stage1b_rxc_error)
if(NOT stage1b_rxc_result EQUAL 0)
    message(FATAL_ERROR "rxc stage1b adjudicator failed (${stage1b_rxc_result})\n${stage1b_rxc_output}\n${stage1b_rxc_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${stage1b_base}" "${stage1b_base}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE stage1b_rxas_result
    OUTPUT_VARIABLE stage1b_rxas_output
    ERROR_VARIABLE stage1b_rxas_error)
if(NOT stage1b_rxas_result EQUAL 0)
    message(FATAL_ERROR "rxas stage1b adjudicator failed (${stage1b_rxas_result})\n${stage1b_rxas_output}\n${stage1b_rxas_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXVME}" -l "${CPRAG_PLUGIN_DIR}" "${stage1b_base}" pipeline_profile rx_rag -a
        --library "${CPRAG_WORK_DIR}/history-hybrid.cprag"
        --profile scotland
        --mode offline
        --limit 10
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE stage1b_rxvme_result
    OUTPUT_VARIABLE stage1b_rxvme_output
    ERROR_VARIABLE stage1b_rxvme_error)
if(NOT stage1b_rxvme_result EQUAL 0)
    message(FATAL_ERROR "rxvme stage1b adjudicator failed (${stage1b_rxvme_result})\n${stage1b_rxvme_output}\n${stage1b_rxvme_error}")
endif()

foreach(expected
        "stage1b start profile=scotland"
        "stage1b complete adjudicated="
        "\"adjudications\""
        "SUTHERLAND"
        "ambiguous")
    if(NOT stage1b_rxvme_output MATCHES "${expected}")
        message(FATAL_ERROR "stage1b adjudicator output missed ${expected}\n${stage1b_rxvme_output}\n${stage1b_rxvme_error}")
    endif()
endforeach()

message(STATUS "CREXX hybrid extractor smoke passed")
