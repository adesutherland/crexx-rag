foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "source=${CPRAG_SOURCE}\nprovider=rx_hash\nnamespace=rxhash\nautoload=metadata\n")

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/program-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${CPRAG_CREXX_BIN_DIR}"
            -o "${program}" "${CPRAG_SOURCE}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} hash proof compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} hash proof assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}"
        "${mode} compile:\n${compile_out}${compile_err}"
        "${mode} assemble:\n${assemble_out}${assemble_err}\n")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(
            COMMAND "${runtime}" -l "${CPRAG_CREXX_BIN_DIR}"
                "${program}" library
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P1_HASH_01_OK algorithm=sha256.*native_provider=autoloaded.*incremental=0 file=0")
            message(FATAL_ERROR
                "${mode}/${runtime_name} hash proof failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}"
            "${mode}/${runtime_name}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

message(STATUS
    "P1-HASH-01 passed installed rxhash SHA-256 vectors and provider autoload on rxvme/rxbvm")
