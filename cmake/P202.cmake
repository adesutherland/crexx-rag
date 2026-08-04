foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_MODEL CPRAG_CONFIG CPRAG_PROFILE CPRAG_REGISTRY
        CPRAG_SAMPLE_CONFIG CPRAG_GENERIC_PROFILE CPRAG_IT_PROFILE
        CPRAG_OPERATOR_REGISTRY CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

set(production_sources
    "${CPRAG_CONFIG}"
    "${CPRAG_PROFILE}"
    "${CPRAG_REGISTRY}"
    "${CPRAG_SAMPLE_CONFIG}"
    "${CPRAG_GENERIC_PROFILE}"
    "${CPRAG_IT_PROFILE}"
    "${CPRAG_OPERATOR_REGISTRY}")
foreach(source IN LISTS production_sources)
    file(READ "${source}" source_text)
    if(source_text MATCHES "(^|\n)[ \t]*import[ \t]+(rxhttp|rxrag|sqlite_boundary|rxsqlite_address|_rxsys)")
        message(FATAL_ERROR
            "P2-02 config/profile loading must not import provider, storage, native-RAG, or system side-effect modules: ${source}")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
set(secret_marker "P2_02_SECRET_VALUE_MUST_NOT_APPEAR_7F31")
file(WRITE "${report}"
    "item=P2-02\nlevel=G\nregistry=operator-owned-id-only\n"
    "secret_contract=env-reference-only\nprovider_calls=0\nsource_reads=0\n"
    "library_writes=0\nproduction_schema=0\n")

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
    compile_crexx("${CPRAG_CONFIG}" "${CPRAG_WORK_DIR}/ragconfig"
        "${program_import}" "${mode_flag}" "${mode} ragconfig")
    compile_crexx("${CPRAG_PROFILE}" "${CPRAG_WORK_DIR}/ragprofile"
        "${program_import}" "${mode_flag}" "${mode} ragprofile")
    compile_crexx("${CPRAG_REGISTRY}" "${CPRAG_WORK_DIR}/ragregistry"
        "${program_import}" "${mode_flag}" "${mode} ragregistry")
    compile_crexx("${CPRAG_SAMPLE_CONFIG}" "${CPRAG_WORK_DIR}/architecture_local_config"
        "${program_import}" "${mode_flag}" "${mode} sample config")
    compile_crexx("${CPRAG_GENERIC_PROFILE}" "${CPRAG_WORK_DIR}/generic_profile"
        "${program_import}" "${mode_flag}" "${mode} generic profile")
    compile_crexx("${CPRAG_IT_PROFILE}" "${CPRAG_WORK_DIR}/it_architecture_profile"
        "${program_import}" "${mode_flag}" "${mode} IT architecture profile")
    compile_crexx("${CPRAG_OPERATOR_REGISTRY}" "${CPRAG_WORK_DIR}/operator_registry"
        "${program_import}" "${mode_flag}" "${mode} operator registry")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} config consumer")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        file(GLOB_RECURSE files_before RELATIVE "${CPRAG_WORK_DIR}" "${CPRAG_WORK_DIR}/*")
        set(state_before)
        foreach(work_file IN LISTS files_before)
            file(SHA256 "${CPRAG_WORK_DIR}/${work_file}" work_hash)
            list(APPEND state_before "${work_file}=${work_hash}")
        endforeach()
        execute_process(COMMAND "${CMAKE_COMMAND}" -E env
            "OPENAI_API_KEY=${secret_marker}"
            "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/program-${mode}"
            ragmodel ragconfig ragprofile ragregistry architecture_local_config
            generic_profile it_architecture_profile operator_registry
            library -a "${cell}" "${secret_marker}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result
            TIMEOUT 30)
        file(GLOB_RECURSE files_after RELATIVE "${CPRAG_WORK_DIR}" "${CPRAG_WORK_DIR}/*")
        set(state_after)
        foreach(work_file IN LISTS files_after)
            file(SHA256 "${CPRAG_WORK_DIR}/${work_file}" work_hash)
            list(APPEND state_after "${work_file}=${work_hash}")
        endforeach()
        if(NOT "${state_before}" STREQUAL "${state_after}")
            message(FATAL_ERROR
                "${cell} config loading changed the runtime worktree:\nbefore=${state_before}\nafter=${state_after}")
        endif()
        if(vm_out MATCHES "${secret_marker}" OR vm_err MATCHES "${secret_marker}")
            message(FATAL_ERROR "${cell} exposed the secret value in output")
        endif()
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P2_02_OK cell=${cell} levelg=1 configs=1 profiles=2 env_refs=1 arbitrary_paths=0 secret_values=0 provider_calls=0 source_reads=0 library_writes=0")
            message(FATAL_ERROR
                "${cell} failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

file(READ "${report}" retained_output)
if(retained_output MATCHES "${secret_marker}")
    message(FATAL_ERROR "P2-02 retained the secret value in its report")
endif()
message(STATUS
    "P2-02 passed registered Level-G config/profile contracts and side-effect denial on rxvme/rxbvm")
