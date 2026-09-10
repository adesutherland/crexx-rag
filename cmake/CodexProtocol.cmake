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

get_filename_component(provider_source_dir "${CPRAG_PROBE}" DIRECTORY)
get_filename_component(provider_source_dir "${provider_source_dir}" DIRECTORY)
set(imports "${CPRAG_WORK_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules provider_contract codex_provider rx_system rxfs rxfnsg classlib library)

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    # Compile these sources for this test; the product project no longer
    # refreshes legacy flat module artifacts in CPRAG_APPLICATION_DIR.
    foreach(module IN ITEMS provider_contract codex_provider)
        execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
            -o "${CPRAG_WORK_DIR}/${module}" "${provider_source_dir}/${module}.crexx"
            RESULT_VARIABLE module_result OUTPUT_VARIABLE module_out ERROR_VARIABLE module_err)
        if(NOT module_result EQUAL 0)
            message(FATAL_ERROR "${mode} ${module} compile failed:\n${module_out}${module_err}")
        endif()
        execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag}
            -o "${CPRAG_WORK_DIR}/${module}" "${CPRAG_WORK_DIR}/${module}"
            RESULT_VARIABLE module_result OUTPUT_VARIABLE module_out ERROR_VARIABLE module_err)
        if(NOT module_result EQUAL 0)
            message(FATAL_ERROR "${mode} ${module} assembly failed:\n${module_out}${module_err}")
        endif()
    endforeach()
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
        foreach(noisy_stage IN ITEMS account-noise account-fragments turn-noise)
            execute_process(COMMAND "${CMAKE_COMMAND}" -E env
                "CREXXRAG_CODEX_FIXTURE_FAILURE=${noisy_stage}"
                "${runtime}" -l "${imports}" "${program}" ${modules}
                -a "${fixture}" "${CPRAG_WORK_DIR}/empty-cwd" 1 "${noisy_stage}"
                RESULT_VARIABLE noisy_status OUTPUT_VARIABLE noisy_out ERROR_VARIABLE noisy_err TIMEOUT 15)
            if(NOT noisy_status EQUAL 0 OR NOT noisy_out MATCHES "PASS: noisy")
                message(FATAL_ERROR "${mode}-${runtime_name} deadline fixture failed: ${noisy_out}${noisy_err}")
            endif()
        endforeach()
    endforeach()
endforeach()

# Each account cycle needs two write/read pairs on the same persistent adapter.
# 17,000 cycles exceed the old context-wide 65,535 unreleased-ticket ceiling.
execute_process(
    COMMAND "${CPRAG_RXBVM}" -l "${imports}" "${program}" ${modules}
        -a "${fixture}" "${CPRAG_WORK_DIR}/empty-cwd" 17000
    RESULT_VARIABLE turnover_result OUTPUT_VARIABLE turnover_out ERROR_VARIABLE turnover_err
    TIMEOUT 120)
if(NOT turnover_result EQUAL 0 OR NOT turnover_out MATCHES
        "PASS: Codex App Server returned managed account status and schema-validated structured output")
    message(FATAL_ERROR "Persistent Codex request turnover failed (${turnover_result}):\n${turnover_out}\n${turnover_err}")
endif()

message(STATUS
    "Codex protocol passed on both VMs, including 17,000 persistent account cycles beyond the old ticket ceiling")
