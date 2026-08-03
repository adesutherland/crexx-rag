foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_CREXX_BIN_DIR
        CPRAG_CONTRACT CPRAG_CATALOG CPRAG_HTTP CPRAG_ADAPTER CPRAG_SOURCE
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()
foreach(required_key OPENAI_API_KEY ANTHROPIC_API_KEY GEMINI_API_KEY)
    if("$ENV{${required_key}}" STREQUAL "")
        message(FATAL_ERROR "Required hosted qualification credential is unavailable")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/hosted-output.txt")

function(compile_crexx source output imports label)
    execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}"
        -o "${output}" "${source}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" -o "${output}" "${output}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
endfunction()

compile_crexx("${CPRAG_CONTRACT}" "${CPRAG_WORK_DIR}/provider_contract"
    "${base_import}" "contract")
compile_crexx("${CPRAG_CATALOG}" "${CPRAG_WORK_DIR}/provider_catalog"
    "${program_import}" "catalog")
compile_crexx("${CPRAG_HTTP}" "${CPRAG_WORK_DIR}/provider_http"
    "${program_import}" "HTTP")
compile_crexx("${CPRAG_ADAPTER}" "${CPRAG_WORK_DIR}/industrial_provider"
    "${program_import}" "adapter")
compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program"
    "${program_import}" "hosted canary")

execute_process(COMMAND "${CPRAG_RXVME}" -l "${program_import}"
    "${CPRAG_WORK_DIR}/program" provider_contract provider_catalog provider_http
    industrial_provider library
    OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err RESULT_VARIABLE vm_result)
file(WRITE "${report}" "${vm_out}${vm_err}")
if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "P1_LLM_04_HOSTED_SUMMARY status=ok")
    message(FATAL_ERROR "Hosted provider qualification failed; inspect secret-free hosted-output.txt")
endif()
message(STATUS "P1-LLM-04 hosted low-cost qualification passed for three providers")
