foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION_DIR CPRAG_PLUGIN_DIR CPRAG_SCENARIO CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(GLOB project_member_dirs LIST_DIRECTORIES true
    "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.crexx-build/members/*")
list(JOIN project_member_dirs ";" project_imports)
set(imports "${CPRAG_WORK_DIR};${project_imports};${CPRAG_APPLICATION_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules ragenrich ragproposalio ragperiod ragprovenance ragassessment ragmodel ragevidence
    ragjob ragconfig ragprofile ragregistry ragschema ragfile ragconfigfile ragglossary
    ragstore ragbackup ragrepository ragcanonical ragplanning ragtrace ragcommand ragingest
    ragfolder ragclaims ragimprove ragmaintain ragbacklog ragadmission raglifecycle ragworktypes ragenvironment ragusage ragreceipts ragwork ragquery ragembedding
    ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics raggrounding ragapplicationprovider ragqueryprovider
    ragquerypolicy ragproduct provider_contract provider_catalog provider_http industrial_provider codex_provider architecture_local_config
    generic_profile it_architecture_profile operator_registry rxsqlite rx_hash rx_system rxfs rxplatform
    rxvector rxfnsg library)

execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}"
    -o "${CPRAG_WORK_DIR}/lifecycle_methodology" "${CPRAG_SCENARIO}"
    RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
if(NOT compile_result EQUAL 0)
    message(FATAL_ERROR "Lifecycle methodology scenario compile failed:\n${compile_out}${compile_err}")
endif()
execute_process(COMMAND "${CPRAG_RXAS}" -o "${CPRAG_WORK_DIR}/lifecycle_methodology"
    "${CPRAG_WORK_DIR}/lifecycle_methodology"
    RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
if(NOT assemble_result EQUAL 0)
    message(FATAL_ERROR "Lifecycle methodology scenario assembly failed:\n${assemble_out}${assemble_err}")
endif()

foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    set(library "${CPRAG_WORK_DIR}/library-${runtime_name}")
    execute_process(COMMAND "${runtime}"
        --provider-path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers"
        -l "${imports}" "${CPRAG_WORK_DIR}/lifecycle_methodology" ${modules}
        -a "${library}"
        RESULT_VARIABLE run_result OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err TIMEOUT 120)
    if(NOT run_result EQUAL 0 OR NOT run_out MATCHES
            "LIFECYCLE_METHODOLOGY_OK generations=7 synonym=1 split=1 merge=1 type_correction=1 retirement_gate=atomic exact_impact=required ambiguities=resolved conflicts=closed supports=atomic retire=1 restore=1 migration_parent=retained dispositions=complete malformed=rejected repositories=verified")
        message(FATAL_ERROR "${runtime_name} lifecycle methodology scenario failed:\n${run_out}${run_err}")
    endif()
endforeach()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "Versioned concept lifecycle passed on rxvme and rxbvm: synonym, split, merge, type correction, exact-set/ambiguity/conflict retirement gates, atomic claim-support closure, retirement, restoration, complete dispositions, malformed rejection, migration-parent retention, and repository verification.\n")
message(STATUS "Lifecycle methodology passed all reviewed operations and negative gates on both VMs")
