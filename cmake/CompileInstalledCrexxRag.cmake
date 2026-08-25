foreach(required_var CPRAG_INSTALL_PREFIX CPRAG_RXC CPRAG_RXAS
        CPRAG_CREXX_BIN_DIR CPRAG_OUTPUT_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

set(application "${CPRAG_INSTALL_PREFIX}/share/crexx-rag/application")
set(provider "${CPRAG_INSTALL_PREFIX}/share/crexx-rag/provider")
set(plugin "${CPRAG_INSTALL_PREFIX}/lib/crexx-rag/providers")
foreach(required IN ITEMS
        "${application}/ragproduct.crexx"
        "${application}/surfaces/crexx_rag_cli.crexx"
        "${application}/surfaces/rag_address_environment.crexx"
        "${application}/surfaces/ragmcp.crexx"
        "${provider}/provider_contract.crexx"
        "${provider}/provider_catalog.crexx"
        "${provider}/provider_http.crexx"
        "${provider}/industrial_provider.crexx"
        "${provider}/codex_provider.crexx")
    if(NOT EXISTS "${required}")
        message(FATAL_ERROR "installed cREXX-RAG source is incomplete: ${required}")
    endif()
endforeach()
file(REMOVE_RECURSE "${CPRAG_OUTPUT_DIR}")
file(MAKE_DIRECTORY "${CPRAG_OUTPUT_DIR}")
set(imports "${CPRAG_OUTPUT_DIR};${plugin};${CPRAG_CREXX_BIN_DIR}")
set(mode_flag)
set(mode_name optimized)
if(CPRAG_NOOPT)
    set(mode_flag -n)
    set(mode_name non-optimized)
endif()

function(compile_module source name)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${CPRAG_OUTPUT_DIR}/${name}" "${source}"
        WORKING_DIRECTORY "${CPRAG_OUTPUT_DIR}"
        RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "installed ${name} compile failed:\n${compile_out}${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${CPRAG_OUTPUT_DIR}/${name}"
        "${CPRAG_OUTPUT_DIR}/${name}" WORKING_DIRECTORY "${CPRAG_OUTPUT_DIR}"
        RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "installed ${name} assembly failed:\n${assemble_out}${assemble_err}")
    endif()
endfunction()

foreach(module IN ITEMS provider_contract provider_catalog provider_http industrial_provider codex_provider)
    compile_module("${provider}/${module}.crexx" "${module}")
endforeach()
foreach(module IN ITEMS ragmodel ragevidence ragjob ragconfig ragprofile ragregistry
        ragschema ragfile ragconfigfile ragstore ragbackup ragrepository ragcanonical ragplanning
        ragtrace ragcommand ragingest ragfolder ragclaims ragimprove ragwork ragquery
        ragembedding ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics ragapplicationprovider ragqueryprovider ragquerypolicy ragproduct)
    compile_module("${application}/${module}.crexx" "${module}")
endforeach()
compile_module("${application}/config/architecture_local_config.crexx" architecture_local_config)
compile_module("${application}/config/profiles/generic_profile.crexx" generic_profile)
compile_module("${application}/config/profiles/it_architecture_profile.crexx" it_architecture_profile)
compile_module("${application}/config/operator_registry.crexx" operator_registry)
compile_module("${application}/surfaces/crexx_rag_cli.crexx" crexx_rag_cli)
compile_module("${application}/surfaces/rag_address_environment.crexx" rag_address_environment)
compile_module("${application}/surfaces/ragmcp.crexx" ragmcp)
file(WRITE "${CPRAG_OUTPUT_DIR}/runtime-modules.txt"
    "provider_contract provider_catalog provider_http industrial_provider codex_provider ragmodel ragevidence ragjob ragconfig ragprofile ragregistry ragschema ragfile ragconfigfile ragstore ragbackup ragrepository ragcanonical ragplanning ragtrace ragcommand ragingest ragfolder ragclaims ragimprove ragwork ragquery ragembedding ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics ragapplicationprovider ragqueryprovider ragquerypolicy ragproduct architecture_local_config generic_profile it_architecture_profile operator_registry rx_sqlite_boundary rx_hash rx_system rxfs rxvector rxfnsg classlib library\n")
message(STATUS "Installed cREXX-RAG application compiled ${mode_name} without source-tree fallback: ${CPRAG_OUTPUT_DIR}")
