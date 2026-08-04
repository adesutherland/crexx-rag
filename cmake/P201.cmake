foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_MODEL CPRAG_EVIDENCE CPRAG_JOB CPRAG_LIBRARY
        CPRAG_SOURCE CPRAG_WORK_DIR)
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
    "item=P2-01\nlevel=G\nmodules=ragmodel,ragevidence,ragjob,raglibrary\n"
    "storage=none\nprovider_calls=0\nproduction_schema=0\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR
            "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR
            "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
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
    compile_crexx("${CPRAG_EVIDENCE}" "${CPRAG_WORK_DIR}/ragevidence"
        "${program_import}" "${mode_flag}" "${mode} ragevidence")
    compile_crexx("${CPRAG_JOB}" "${CPRAG_WORK_DIR}/ragjob"
        "${program_import}" "${mode_flag}" "${mode} ragjob")
    compile_crexx("${CPRAG_LIBRARY}" "${CPRAG_WORK_DIR}/raglibrary"
        "${program_import}" "${mode_flag}" "${mode} raglibrary")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} contract consumer")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/program-${mode}"
            ragmodel ragevidence ragjob raglibrary library -a "${cell}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P2_01_OK cell=${cell} levelg=1 modules=4 library_contract=1 job_contract=1 evidence_contract=1 typed_pages=1 directional_support=1")
            message(FATAL_ERROR
                "${cell} failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

message(STATUS
    "P2-01 passed Level-G application contracts in optimized/non-optimized modes on rxvme/rxbvm")
