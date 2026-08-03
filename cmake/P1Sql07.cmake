foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_DIR CPRAG_MODULE CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}" "module=${CPRAG_MODULE}\nsource=${CPRAG_SOURCE}\n")

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(module_output "${CPRAG_WORK_DIR}/rxsqlite_address-${mode}")
    set(program "${CPRAG_WORK_DIR}/program-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${base_import}"
            -o "${module_output}" "${CPRAG_MODULE}"
        OUTPUT_VARIABLE module_compile_out ERROR_VARIABLE module_compile_err
        RESULT_VARIABLE module_compile_result)
    if(NOT module_compile_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} module compile failed:\n${module_compile_out}\n${module_compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${module_output}" "${module_output}"
        OUTPUT_VARIABLE module_assemble_out ERROR_VARIABLE module_assemble_err
        RESULT_VARIABLE module_assemble_result)
    if(NOT module_assemble_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} module assembly failed:\n${module_assemble_out}\n${module_assemble_err}")
    endif()
    file(RENAME "${module_output}.rxbin"
        "${CPRAG_WORK_DIR}/rxsqlite_address.rxbin")

    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${program_import}"
            -o "${program}" "${CPRAG_SOURCE}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} test compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} test assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}"
        "${mode} module compile:\n${module_compile_out}${module_compile_err}"
        "${mode} module assemble:\n${module_assemble_out}${module_assemble_err}"
        "${mode} test compile:\n${compile_out}${compile_err}"
        "${mode} test assemble:\n${assemble_out}${assemble_err}\n")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(database "${CPRAG_WORK_DIR}/${cell}.sqlite")
        execute_process(
            COMMAND "${runtime}" -l "${program_import}" "${program}"
                rx_sqlite_boundary rxsqlite_address library -a "${database}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P1_SQL_07_OK address_sqlite=1 explicit_syntax=1 integer_output=2 text_output=runtime null_output=NULL failure_rc=8")
            message(FATAL_ERROR
                "${cell} failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

message(STATUS
    "P1-SQL-07 passed explicit ADDRESS SQLITE syntax and output assertions on rxvme/rxbvm")
