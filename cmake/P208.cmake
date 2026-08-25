foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_APP_DIR CPRAG_SOURCE
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
set(module_sources
    "${CPRAG_APP_DIR}/ragmodel.crexx"
    "${CPRAG_APP_DIR}/ragconfig.crexx"
    "${CPRAG_APP_DIR}/ragprofile.crexx"
    "${CPRAG_APP_DIR}/ragregistry.crexx"
    "${CPRAG_APP_DIR}/config/architecture_local_config.crexx"
    "${CPRAG_APP_DIR}/config/profiles/generic_profile.crexx"
    "${CPRAG_APP_DIR}/config/profiles/it_architecture_profile.crexx"
    "${CPRAG_APP_DIR}/config/operator_registry.crexx"
    "${CPRAG_APP_DIR}/ragschema.crexx"
    "${CPRAG_APP_DIR}/ragfile.crexx"
    "${CPRAG_APP_DIR}/ragstore.crexx"
    "${CPRAG_APP_DIR}/ragbackup.crexx"
    "${CPRAG_APP_DIR}/ragrepository.crexx"
    "${CPRAG_APP_DIR}/ragcanonical.crexx"
    "${CPRAG_APP_DIR}/ragplanning.crexx"
    "${CPRAG_APP_DIR}/ragtrace.crexx"
    "${CPRAG_APP_DIR}/ragcommand.crexx"
    "${CPRAG_APP_DIR}/ragfoundation.crexx"
    "${CPRAG_SOURCE}")
file(WRITE "${report}"
    "item=P2-08\nlevel=G\ncommands=10\nlifecycle=7\n"
    "provider_test=configuration-only\nprovider_calls=0\ncredential_resolutions=0\n")

set(source_index 0)
foreach(source IN LISTS module_sources)
    file(SHA256 "${source}" source_hash)
    set("source_hash_${source_index}" "${source_hash}")
    math(EXPR source_index "${source_index} + 1")
endforeach()

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
    compile_crexx("${CPRAG_APP_DIR}/ragmodel.crexx" "${CPRAG_WORK_DIR}/ragmodel"
        "${base_import}" "${mode_flag}" "${mode} ragmodel")
    compile_crexx("${CPRAG_APP_DIR}/ragconfig.crexx" "${CPRAG_WORK_DIR}/ragconfig"
        "${program_import}" "${mode_flag}" "${mode} ragconfig")
    compile_crexx("${CPRAG_APP_DIR}/ragprofile.crexx" "${CPRAG_WORK_DIR}/ragprofile"
        "${program_import}" "${mode_flag}" "${mode} ragprofile")
    compile_crexx("${CPRAG_APP_DIR}/ragregistry.crexx" "${CPRAG_WORK_DIR}/ragregistry"
        "${program_import}" "${mode_flag}" "${mode} ragregistry")
    compile_crexx("${CPRAG_APP_DIR}/config/architecture_local_config.crexx" "${CPRAG_WORK_DIR}/architecture_local_config"
        "${program_import}" "${mode_flag}" "${mode} architecture config")
    compile_crexx("${CPRAG_APP_DIR}/config/profiles/generic_profile.crexx" "${CPRAG_WORK_DIR}/generic_profile"
        "${program_import}" "${mode_flag}" "${mode} generic profile")
    compile_crexx("${CPRAG_APP_DIR}/config/profiles/it_architecture_profile.crexx" "${CPRAG_WORK_DIR}/it_architecture_profile"
        "${program_import}" "${mode_flag}" "${mode} architecture profile")
    compile_crexx("${CPRAG_APP_DIR}/config/operator_registry.crexx" "${CPRAG_WORK_DIR}/operator_registry"
        "${program_import}" "${mode_flag}" "${mode} operator registry")
    compile_crexx("${CPRAG_APP_DIR}/ragschema.crexx" "${CPRAG_WORK_DIR}/ragschema"
        "${base_import}" "${mode_flag}" "${mode} ragschema")
    compile_crexx("${CPRAG_APP_DIR}/ragfile.crexx" "${CPRAG_WORK_DIR}/ragfile"
        "${base_import}" "${mode_flag}" "${mode} ragfile")
    compile_crexx("${CPRAG_APP_DIR}/ragstore.crexx" "${CPRAG_WORK_DIR}/ragstore"
        "${program_import}" "${mode_flag}" "${mode} ragstore")
    compile_crexx("${CPRAG_APP_DIR}/ragbackup.crexx" "${CPRAG_WORK_DIR}/ragbackup"
        "${program_import}" "${mode_flag}" "${mode} ragbackup")
    compile_crexx("${CPRAG_APP_DIR}/ragrepository.crexx" "${CPRAG_WORK_DIR}/ragrepository"
        "${program_import}" "${mode_flag}" "${mode} ragrepository")
    compile_crexx("${CPRAG_APP_DIR}/ragcanonical.crexx" "${CPRAG_WORK_DIR}/ragcanonical"
        "${program_import}" "${mode_flag}" "${mode} ragcanonical")
    compile_crexx("${CPRAG_APP_DIR}/ragplanning.crexx" "${CPRAG_WORK_DIR}/ragplanning"
        "${program_import}" "${mode_flag}" "${mode} ragplanning")
    compile_crexx("${CPRAG_APP_DIR}/ragtrace.crexx" "${CPRAG_WORK_DIR}/ragtrace"
        "${program_import}" "${mode_flag}" "${mode} ragtrace")
    compile_crexx("${CPRAG_APP_DIR}/ragcommand.crexx" "${CPRAG_WORK_DIR}/ragcommand"
        "${program_import}" "${mode_flag}" "${mode} ragcommand")
    compile_crexx("${CPRAG_APP_DIR}/ragfoundation.crexx" "${CPRAG_WORK_DIR}/ragfoundation"
        "${program_import}" "${mode_flag}" "${mode} foundation facade")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} foundation scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(cell_root "${CPRAG_WORK_DIR}/${cell}")
        file(MAKE_DIRECTORY "${cell_root}")
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/program-${mode}"
            ragmodel ragconfig ragprofile ragregistry
            architecture_local_config generic_profile it_architecture_profile
            operator_registry ragschema ragfile ragstore ragbackup ragrepository
            ragcanonical ragplanning ragtrace ragcommand ragfoundation
            rx_sqlite_boundary rx_hash rx_system library
            -a "${cell}" "${cell_root}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result TIMEOUT 90)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P2_08_FOUNDATION_OK cell=${cell} commands=10 lifecycle=7 providers=3 provider_calls=0 credential_resolutions=0 read_command_writes=0 restored_verified=1")
            message(FATAL_ERROR "${cell} foundation scenario failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        foreach(bundle IN ITEMS library.cprag backup.cprag restored.cprag)
            if(NOT EXISTS "${cell_root}/${bundle}/library.sqlite" OR
               NOT EXISTS "${cell_root}/${bundle}/manifest.json")
                message(FATAL_ERROR "${cell} did not retain complete ${bundle}")
            endif()
        endforeach()
        file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

set(source_index 0)
foreach(source IN LISTS module_sources)
    file(SHA256 "${source}" source_hash_after)
    if(NOT source_hash_after STREQUAL "${source_hash_${source_index}}")
        message(FATAL_ERROR "P2-08 changed source input during facade execution: ${source}")
    endif()
    math(EXPR source_index "${source_index} + 1")
endforeach()

message(STATUS
    "P2-08 passed: shared foundation dispatch for doctor, seven library lifecycle commands, provider status/configuration-only test, and profile validation across noopt/opt x rxvme/rxbvm with access, zero-write, no-secret, and no-outbound proofs")
