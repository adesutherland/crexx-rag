foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_CONTRACT CPRAG_FACADE CPRAG_SOURCE
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "contract=${CPRAG_CONTRACT}\nfacade=${CPRAG_FACADE}\nsource=${CPRAG_SOURCE}\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}"
        "${label} compile:\n${compile_out}${compile_err}"
        "${label} assemble:\n${assemble_out}${assemble_err}\n")
endfunction()

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_CONTRACT}" "${CPRAG_WORK_DIR}/provider_contract"
        "${base_import}" "${mode_flag}" "${mode} Level-B contract")
    compile_crexx("${CPRAG_FACADE}" "${CPRAG_WORK_DIR}/provider_facade"
        "${program_import}" "${mode_flag}" "${mode} Level-G facade")
    set(program "${CPRAG_WORK_DIR}/program-${mode}")
    compile_crexx("${CPRAG_SOURCE}" "${program}" "${program_import}"
        "${mode_flag}" "${mode} contract test")
    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
            provider_contract provider_facade library
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err RESULT_VARIABLE vm_result)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "P1_LLM_01_OK")
            message(FATAL_ERROR
                "${mode}/${runtime_name} failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}" "${mode}/${runtime_name}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

message(STATUS "P1-LLM-01 passed provider-neutral contract on rxvme/rxbvm")
