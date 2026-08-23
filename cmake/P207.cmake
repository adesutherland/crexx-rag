foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_MODEL CPRAG_COMMAND CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(SHA256 "${CPRAG_MODEL}" model_before)
file(SHA256 "${CPRAG_COMMAND}" command_before)
file(SHA256 "${CPRAG_SOURCE}" source_before)
file(WRITE "${report}"
    "item=P2-07\nlevel=G\noperations=40\nexit_codes=11\n"
    "formats=human,json,ndjson\njson_schema=crexx-rag.command-result/1\n"
    "library_writes=0\nprovider_calls=0\n")

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
    compile_crexx("${CPRAG_MODEL}" "${CPRAG_WORK_DIR}/ragmodel"
        "${base_import}" "${mode_flag}" "${mode} ragmodel")
    compile_crexx("${CPRAG_COMMAND}" "${CPRAG_WORK_DIR}/ragcommand"
        "${program_import}" "${mode_flag}" "${mode} ragcommand")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} command contract")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/program-${mode}" ragmodel ragcommand library
            -a "${cell}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result TIMEOUT 30)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P2_07_COMMAND_OK cell=${cell} operations=40 exit_codes=11 formats=human,json,ndjson json_schema=crexx-rag.command-result/1 parser_writes=0 provider_calls=0")
            message(FATAL_ERROR "${cell} command contract failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

file(SHA256 "${CPRAG_MODEL}" model_after)
file(SHA256 "${CPRAG_COMMAND}" command_after)
file(SHA256 "${CPRAG_SOURCE}" source_after)
if(NOT model_before STREQUAL model_after OR
   NOT command_before STREQUAL command_after OR
   NOT source_before STREQUAL source_after)
    message(FATAL_ERROR "P2-07 changed a source input during parser/render execution")
endif()

message(STATUS
    "P2-07 passed: 40-operation argv parser, 11 stable exits, bounded versioned human/JSON/NDJSON rendering, negative syntax/result cases, and zero-write source fingerprints across noopt/opt x rxvme/rxbvm")
