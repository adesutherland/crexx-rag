foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_APP_DIR CPRAG_CONFIG_DIR
        CPRAG_PROFILE_DIR CPRAG_SURFACE_DIR CPRAG_CLI CPRAG_ADDRESS
        CPRAG_MCP CPRAG_PROVIDER_CONTRACT CPRAG_PROVIDER_DIR CPRAG_ADDRESS_SCENARIO CPRAG_MCP_SCENARIO
        CPRAG_CONFIG_FIXTURE CPRAG_TUTORIAL_FIXTURE CPRAG_SKILLS_DIR CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}" "${CPRAG_WORK_DIR}/source-docs")
file(COPY "${CPRAG_TUTORIAL_FIXTURE}" DESTINATION "${CPRAG_WORK_DIR}/source-docs")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
string(REPLACE ";" "\\;" program_import_arg "${program_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}" "phase=6\nlevel=G\ntransports=CLI,ADDRESS-RAG,MCP\nsecret_values_logged=0\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}" "${label} compile:\n${compile_out}${compile_err}${assemble_out}${assemble_err}\n")
endfunction()

set(app_modules ragmodel ragevidence ragjob ragconfig ragprofile ragregistry
    ragschema ragfile ragconfigfile ragstore ragbackup ragrepository ragcanonical ragplanning
    ragtrace ragcommand ragingest ragfolder ragclaims ragimprove ragwork ragquery
    ragembedding ragretrieval ragevidencejson ragfoundation ragprocess ragapplicationprovider ragproduct)
set(provider_modules provider_contract provider_catalog provider_http industrial_provider)
set(config_modules architecture_local_config generic_profile it_architecture_profile
    operator_registry)
set(runtime_modules ragmcp rag_address_environment ${provider_modules} ${app_modules} ${config_modules}
    rx_sqlite_boundary rx_hash rx_system rxfs rxvector rxfnsg classlib library)

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    else()
        foreach(generated IN LISTS app_modules config_modules)
            file(REMOVE "${CPRAG_WORK_DIR}/${generated}.rxas" "${CPRAG_WORK_DIR}/${generated}.rxbin")
        endforeach()
        foreach(generated IN ITEMS ${provider_modules} crexx_rag_cli rag_address_environment ragmcp address-noopt mcp-noopt)
            file(REMOVE "${CPRAG_WORK_DIR}/${generated}.rxas" "${CPRAG_WORK_DIR}/${generated}.rxbin")
        endforeach()
    endif()
    foreach(module IN LISTS provider_modules)
        compile_crexx("${CPRAG_PROVIDER_DIR}/${module}.crexx"
            "${CPRAG_WORK_DIR}/${module}" "${program_import}" "${mode_flag}"
            "${mode} ${module}")
    endforeach()
    foreach(module IN LISTS app_modules)
        compile_crexx("${CPRAG_APP_DIR}/${module}.crexx"
            "${CPRAG_WORK_DIR}/${module}" "${program_import}" "${mode_flag}"
            "${mode} ${module}")
    endforeach()
    compile_crexx("${CPRAG_CONFIG_DIR}/architecture_local_config.crexx"
        "${CPRAG_WORK_DIR}/architecture_local_config" "${program_import}" "${mode_flag}" "${mode} architecture config")
    compile_crexx("${CPRAG_PROFILE_DIR}/generic_profile.crexx"
        "${CPRAG_WORK_DIR}/generic_profile" "${program_import}" "${mode_flag}" "${mode} generic profile")
    compile_crexx("${CPRAG_PROFILE_DIR}/it_architecture_profile.crexx"
        "${CPRAG_WORK_DIR}/it_architecture_profile" "${program_import}" "${mode_flag}" "${mode} IT profile")
    compile_crexx("${CPRAG_CONFIG_DIR}/operator_registry.crexx"
        "${CPRAG_WORK_DIR}/operator_registry" "${program_import}" "${mode_flag}" "${mode} operator registry")
    compile_crexx("${CPRAG_CLI}" "${CPRAG_WORK_DIR}/crexx_rag_cli"
        "${program_import}" "${mode_flag}" "${mode} CLI")
    compile_crexx("${CPRAG_ADDRESS}" "${CPRAG_WORK_DIR}/rag_address_environment"
        "${program_import}" "${mode_flag}" "${mode} ADDRESS RAG")
    compile_crexx("${CPRAG_MCP}" "${CPRAG_WORK_DIR}/ragmcp"
        "${program_import}" "${mode_flag}" "${mode} MCP")
    compile_crexx("${CPRAG_ADDRESS_SCENARIO}" "${CPRAG_WORK_DIR}/address-${mode}"
        "${program_import}" "${mode_flag}" "${mode} ADDRESS scenario")
    compile_crexx("${CPRAG_MCP_SCENARIO}" "${CPRAG_WORK_DIR}/mcp-${mode}"
        "${program_import}" "${mode_flag}" "${mode} MCP scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(library "${CPRAG_WORK_DIR}/library-${cell}")
        set(cli_base "${runtime}" -l "${program_import_arg}"
            "${CPRAG_WORK_DIR}/crexx_rag_cli" ${provider_modules} ${app_modules} ${config_modules}
            rx_sqlite_boundary rx_hash rx_system rxfs rxvector rxfnsg library)
        execute_process(COMMAND ${cli_base} -a --library "${library}"
            --config architecture-local --profile generic-profile --access admin
            --format json library init WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
            OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err RESULT_VARIABLE init_result)
        if(NOT init_result EQUAL 0)
            message(FATAL_ERROR "${cell} CLI init failed:\n${init_out}${init_err}")
        endif()
        string(JSON library_id ERROR_VARIABLE json_error GET "${init_out}" records 0 fields library_id)
        if(json_error OR library_id STREQUAL "")
            message(FATAL_ERROR "${cell} CLI init did not return library id: ${init_out}")
        endif()
        file(SHA256 "${library}/library.sqlite" db_before)
        file(SHA256 "${library}/manifest.json" manifest_before)

        execute_process(COMMAND ${cli_base} -a --library "${library}"
            --config architecture-local --profile generic-profile --access plan
            --format json ingest plan --source-set architecture-docs
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE ingest_plan_out
            ERROR_VARIABLE plan_err RESULT_VARIABLE plan_result)
        execute_process(COMMAND ${cli_base} -a --library "${library}"
            --config architecture-local --profile generic-profile --access plan
            --format json improve plan WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
            OUTPUT_VARIABLE improve_plan_out ERROR_VARIABLE improve_err RESULT_VARIABLE improve_result)
        execute_process(COMMAND ${cli_base} -a --library "${library}"
            --config architecture-local --profile generic-profile --access plan
            --format json proposal plan --input-digest aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE proposal_plan_out
            ERROR_VARIABLE proposal_err RESULT_VARIABLE proposal_result)
        if(NOT plan_result EQUAL 0 OR NOT improve_result EQUAL 0 OR NOT proposal_result EQUAL 0)
            message(FATAL_ERROR "${cell} zero-write plan failed:\n${ingest_plan_out}${plan_err}${improve_plan_out}${improve_err}${proposal_plan_out}${proposal_err}")
        endif()
        file(SHA256 "${library}/library.sqlite" db_after_plan)
        file(SHA256 "${library}/manifest.json" manifest_after_plan)
        if(NOT db_before STREQUAL db_after_plan OR NOT manifest_before STREQUAL manifest_after_plan)
            message(FATAL_ERROR "${cell} read/plan changed the library")
        endif()
        string(JSON plan_json ERROR_VARIABLE plan_json_error GET "${ingest_plan_out}" records 0 fields canonical_plan)
        string(JSON plan_digest ERROR_VARIABLE plan_digest_error GET "${ingest_plan_out}" records 0 fields digest)
        if(plan_json_error OR plan_digest_error)
            message(FATAL_ERROR "${cell} plan result cannot be reviewed/applied: ${ingest_plan_out}")
        endif()
        execute_process(COMMAND ${cli_base} -a --library "${library}"
            --config architecture-local --profile generic-profile --access ingest
            --format json ingest apply --plan-json "${plan_json}" --expect-digest "${plan_digest}"
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE apply_out
            ERROR_VARIABLE apply_err RESULT_VARIABLE apply_result)
        if(NOT apply_result EQUAL 0 OR NOT apply_out MATCHES "\"operation\":\"ingest.apply\",\"status\":\"ok\"")
            message(FATAL_ERROR "${cell} reviewed ingest apply failed:\n${apply_out}${apply_err}")
        endif()

        execute_process(COMMAND ${cli_base} -a --library "${library}"
            --config architecture-local --profile generic-profile --access read
            --format json query evidence "Which component reads ADX?"
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE query_out
            ERROR_VARIABLE query_err RESULT_VARIABLE query_result)
        execute_process(COMMAND ${cli_base} -a --library "${library}"
            --config architecture-local --profile generic-profile --access read
            --format json queue-status WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
            OUTPUT_VARIABLE alias_out ERROR_VARIABLE alias_err RESULT_VARIABLE alias_result)
        if(NOT query_result EQUAL 0 OR NOT query_out MATCHES "\"evidence_schema\":\"crexx-rag.evidence/1\"" OR
           NOT alias_result EQUAL 0 OR NOT alias_out MATCHES "\"kind\":\"deprecation\"")
            message(FATAL_ERROR "${cell} query/deprecation failed:\n${query_out}${query_err}${alias_out}${alias_err}")
        endif()

        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/address-${mode}" ${runtime_modules}
            -a "${library}" OUTPUT_VARIABLE address_out ERROR_VARIABLE address_err
            RESULT_VARIABLE address_result TIMEOUT 60)
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/mcp-${mode}" ${runtime_modules}
            -a "${library}" OUTPUT_VARIABLE mcp_out ERROR_VARIABLE mcp_err
            RESULT_VARIABLE mcp_result TIMEOUT 60)
        if(NOT address_result EQUAL 0 OR NOT address_out MATCHES "P6_ADDRESS_OK library_id=${library_id}" OR
           NOT mcp_result EQUAL 0 OR NOT mcp_out MATCHES "P6_MCP_OK library_id=${library_id}")
            message(FATAL_ERROR "${cell} surface equality failed:\n${address_out}${address_err}${mcp_out}${mcp_err}")
        endif()

        set(mcp_config_input "${CPRAG_WORK_DIR}/mcp-config-${cell}.jsonl")
        file(WRITE "${mcp_config_input}"
            "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n"
            "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_provider_diagnostics\",\"arguments\":{}}}\n")
        execute_process(COMMAND "${CMAKE_COMMAND}" -E env
            "GEMINI_API_KEY=P6_SECRET_MUST_NOT_APPEAR_70B3"
            "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/ragmcp" ${runtime_modules}
            -a --library "${library}" --config-file "${CPRAG_CONFIG_FIXTURE}"
            --profile generic-profile --access diagnose
            INPUT_FILE "${mcp_config_input}"
            OUTPUT_VARIABLE mcp_config_out ERROR_VARIABLE mcp_config_err
            RESULT_VARIABLE mcp_config_result TIMEOUT 60)
        if(NOT mcp_config_result EQUAL 0 OR
           NOT mcp_config_out MATCHES "\"provider_id\":\"gemini-generate\"" OR
           NOT mcp_config_out MATCHES "\"credential_resolved\":false" OR
           mcp_config_out MATCHES "P6_SECRET_MUST_NOT_APPEAR_70B3" OR
           mcp_config_err MATCHES "P6_SECRET_MUST_NOT_APPEAR_70B3")
            message(FATAL_ERROR
                "${cell} fixed MCP config-file startup failed:\n${mcp_config_out}${mcp_config_err}")
        endif()

        set(backup "${CPRAG_WORK_DIR}/backup-${cell}")
        set(restored "${CPRAG_WORK_DIR}/restored-${cell}")
        execute_process(COMMAND ${cli_base} -a --library "${library}"
            --config architecture-local --profile generic-profile --access admin
            --format json library backup --output "${backup}"
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE backup_out
            ERROR_VARIABLE backup_err RESULT_VARIABLE backup_result)
        execute_process(COMMAND ${cli_base} -a --library "${restored}"
            --config architecture-local --profile generic-profile --access admin
            --format json library restore --input "${backup}" --output "${restored}"
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE restore_out
            ERROR_VARIABLE restore_err RESULT_VARIABLE restore_result)
        if(NOT backup_result EQUAL 0 OR NOT restore_result EQUAL 0)
            message(FATAL_ERROR "${cell} documented backup/restore failed:\n${backup_out}${backup_err}${restore_out}${restore_err}")
        endif()
        file(APPEND "${report}" "${cell}:\n${init_out}${ingest_plan_out}${apply_out}${query_out}${alias_out}${address_out}${mcp_out}${mcp_config_out}${backup_out}${restore_out}\n")
    endforeach()
endforeach()

foreach(skill IN ITEMS crexx-rag-qa crexx-rag-ingest crexx-rag-improve crexx-rag-diagnose)
    if(NOT EXISTS "${CPRAG_SKILLS_DIR}/${skill}/SKILL.md" OR NOT EXISTS "${CPRAG_SKILLS_DIR}/${skill}/manifest.json")
        message(FATAL_ERROR "installable skill package ${skill} is incomplete")
    endif()
    file(READ "${CPRAG_SKILLS_DIR}/${skill}/manifest.json" manifest)
    string(JSON schema ERROR_VARIABLE manifest_error GET "${manifest}" schema)
    if(manifest_error OR NOT schema STREQUAL "crexx-rag.skill-manifest/1")
        message(FATAL_ERROR "skill ${skill} manifest is invalid")
    endif()
endforeach()

message(STATUS "Phase 6 passed: four optimized/non-optimized dual-VM fresh-product cells, exact reviewed ingest, zero-write plans, CLI/ADDRESS/MCP semantic equality, capability denial, deprecation, backup/restore, and installable skill manifests")
