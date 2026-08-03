foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_DIR CPRAG_SOURCE CPRAG_MODULES CPRAG_EXPECTED CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(import_path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}" "source=${CPRAG_SOURCE}\nmodules=${CPRAG_MODULES}\n")

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/program-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${import_path}"
            -o "${program}" "${CPRAG_SOURCE}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} assembly failed:\n${assemble_out}\n${assemble_err}")
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
        set(runtime_arguments)
        if(DEFINED CPRAG_DATABASE_ARGUMENT AND CPRAG_DATABASE_ARGUMENT)
            set(database_path
                "${CPRAG_WORK_DIR}/${mode}-${runtime_name}.sqlite")
            set(runtime_arguments -a "${database_path}")
        endif()
        execute_process(
            COMMAND "${runtime}" -l "${import_path}" "${program}"
                ${CPRAG_MODULES} library ${runtime_arguments}
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result)
        string(FIND "${vm_out}" "${CPRAG_EXPECTED}" expected_position)
        if(NOT vm_result EQUAL 0 OR expected_position EQUAL -1)
            message(FATAL_ERROR
                "${mode}/${runtime_name} failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}"
            "${mode}/${runtime_name}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

message(STATUS "${CPRAG_EXPECTED} passed noopt/opt on rxvme/rxbvm")
