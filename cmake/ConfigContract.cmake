foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_MODEL CPRAG_CONFIG
        CPRAG_FILE CPRAG_CONFIG_FILE_MODULE CPRAG_SCENARIO CPRAG_FIXTURE
        CPRAG_SUBSCRIPTION_FIXTURE CPRAG_APPLICATION CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/result.txt")
file(WRITE "${report}"
    "test=configuration-contract\nformat=crexx-rag.config/1\nprovider_calls=0\ncredential_reads=0\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${compile_out}${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${assemble_out}${assemble_err}")
    endif()
endfunction()

set(secret_marker "CONFIG_SECRET_MUST_NOT_APPEAR_8A21")
foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_MODEL}" "${CPRAG_WORK_DIR}/ragmodel"
        "${base_import}" "${mode_flag}" "${mode} ragmodel")
    compile_crexx("${CPRAG_CONFIG}" "${CPRAG_WORK_DIR}/ragconfig"
        "${program_import}" "${mode_flag}" "${mode} ragconfig")
    compile_crexx("${CPRAG_FILE}" "${CPRAG_WORK_DIR}/ragfile"
        "${program_import}" "${mode_flag}" "${mode} ragfile")
    compile_crexx("${CPRAG_CONFIG_FILE_MODULE}" "${CPRAG_WORK_DIR}/ragconfigfile"
        "${program_import}" "${mode_flag}" "${mode} ragconfigfile")
    compile_crexx("${CPRAG_SCENARIO}" "${CPRAG_WORK_DIR}/scenario-${mode}"
        "${program_import}" "${mode_flag}" "${mode} config scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        execute_process(COMMAND "${CMAKE_COMMAND}" -E env
            "GEMINI_API_KEY=${secret_marker}"
            "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/scenario-${mode}"
            ragconfigfile ragconfig ragmodel ragfile rx_hash rx_system library
            -a "${cell}" "${CPRAG_FIXTURE}"
            RESULT_VARIABLE vm_result OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            TIMEOUT 30)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "CONFIG_CONTRACT_OK cell=${cell} format=1 settings=bounded providers=2 gemini=2 env_refs=2 literal_secrets=0 executable_modules=0 provider_calls=0")
            message(FATAL_ERROR "${cell} config scenario failed:\n${vm_out}${vm_err}")
        endif()
        if(vm_out MATCHES "${secret_marker}" OR vm_err MATCHES "${secret_marker}")
            message(FATAL_ERROR "${cell} exposed a resolved credential")
        endif()
        file(APPEND "${report}" "${cell}: ${vm_out}${vm_err}")
    endforeach()
endforeach()

execute_process(COMMAND "${CMAKE_COMMAND}" -E env
    "GEMINI_API_KEY=${secret_marker}"
    "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a
    --config-file "${CPRAG_FIXTURE}"
    --profile generic-profile --format json doctor
    RESULT_VARIABLE cli_result OUTPUT_VARIABLE cli_out ERROR_VARIABLE cli_err
    TIMEOUT 30)
if(NOT cli_result EQUAL 0 OR NOT cli_out MATCHES
        "\"operation\":\"doctor\",\"status\":\"ok\"" OR
   NOT cli_out MATCHES "\"config_count\":1" OR
   NOT cli_out MATCHES "\"provider_id\":\"gemini-generate\"")
    message(FATAL_ERROR "linked CLI config-file smoke failed:\n${cli_out}${cli_err}")
endif()
if(cli_out MATCHES "${secret_marker}" OR cli_err MATCHES "${secret_marker}")
    message(FATAL_ERROR "linked CLI exposed a resolved credential")
endif()

execute_process(COMMAND "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a
    --config-file "${CPRAG_SUBSCRIPTION_FIXTURE}"
    --format json provider list
    RESULT_VARIABLE subscription_result
    OUTPUT_VARIABLE subscription_out ERROR_VARIABLE subscription_err
    TIMEOUT 30)
if(NOT subscription_result EQUAL 0 OR NOT subscription_out MATCHES
        "\"provider_id\":\"codex-extract\"" OR
   NOT subscription_out MATCHES "\"kind\":\"codex\"" OR
   NOT subscription_out MATCHES "\"charging_basis\":\"subscription-allowance\"" OR
   NOT subscription_out MATCHES "\"provider_id\":\"local-embed\"" OR
   NOT subscription_out MATCHES "\"kind\":\"openai-compatible\"" OR
   NOT subscription_out MATCHES "\"charging_basis\":\"local-compute\"")
    message(FATAL_ERROR
        "Codex/local tutorial configuration failed zero-call provider discovery:\n${subscription_out}${subscription_err}")
endif()

execute_process(COMMAND "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a
    --config-file "${CPRAG_FIXTURE}" --config architecture-local
    --profile generic-profile --format json doctor
    RESULT_VARIABLE mismatch_result OUTPUT_VARIABLE mismatch_out ERROR_VARIABLE mismatch_err
    TIMEOUT 30)
if(NOT mismatch_result EQUAL 3 OR NOT mismatch_out MATCHES
        "--config does not match --config-file")
    message(FATAL_ERROR
        "linked CLI did not reject a mismatched config id:\n${mismatch_out}${mismatch_err}")
endif()

file(APPEND "${report}" "linked-cli:\n${cli_out}${cli_err}${subscription_out}${subscription_err}")
file(READ "${report}" retained)
if(retained MATCHES "${secret_marker}")
    message(FATAL_ERROR "retained config evidence contains a resolved credential")
endif()
message(STATUS
    "Configuration contract passed bounded text projection in four compiler/VM cells and the linked CLI")
