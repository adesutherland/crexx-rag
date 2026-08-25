foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION_DIR CPRAG_PROBE CPRAG_FIXTURE
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/empty-cwd")
file(COPY "${CPRAG_FIXTURE}" DESTINATION "${CPRAG_WORK_DIR}")
get_filename_component(fixture_name "${CPRAG_FIXTURE}" NAME)
set(fixture "${CPRAG_WORK_DIR}/${fixture_name}")
file(CHMOD "${fixture}"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

set(imports "${CPRAG_APPLICATION_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules
    provider_contract codex_provider rx_system rxfs rxfnsg classlib library)

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/codex-protocol-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
            -o "${program}" "${CPRAG_PROBE}"
        RESULT_VARIABLE compile_result
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${mode} Codex protocol compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        RESULT_VARIABLE assemble_result
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${mode} Codex protocol assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(
            COMMAND "${runtime}" -l "${imports}" "${program}" ${modules}
                -a "${fixture}" "${CPRAG_WORK_DIR}/empty-cwd"
            RESULT_VARIABLE run_result
            OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err
            TIMEOUT 30)
        if(NOT run_result EQUAL 0 OR NOT run_out MATCHES
                "PASS: Codex App Server returned managed account status and schema-validated structured output")
            message(FATAL_ERROR
                "${mode}-${runtime_name} Codex protocol fixture failed (${run_result}):\n${run_out}\n${run_err}")
        endif()
    endforeach()
endforeach()

message(STATUS
    "Codex protocol passed App Server initialize, managed-account, structured-turn, usage, schema-validation and cleanup on both VMs")
