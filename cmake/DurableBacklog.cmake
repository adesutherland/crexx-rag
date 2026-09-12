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
    ragfolder ragquotationcontract ragextractioncontract ragresolutioncontract raganswercontract ragreportcontract ragpromptdefaults ragpromptinspection ragclaimrules ragclaims ragimprove ragmaintain ragbacklog ragadmission raglifecycle ragworktypes ragenvironment ragusage ragreceipts ragwork ragquery ragembedding
    ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics raggrounding ragapplicationprovider ragqueryprovider
    ragquerypolicy ragproduct provider_contract provider_catalog provider_http industrial_provider codex_provider architecture_local_config
    generic_profile it_architecture_profile operator_registry rxsqlite rx_hash rx_system rxfs rxplatform
    rxvector rxfnsg library)

execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}"
    -o "${CPRAG_WORK_DIR}/backlog_scenario" "${CPRAG_SCENARIO}"
    RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
if(NOT compile_result EQUAL 0)
    message(FATAL_ERROR "Durable backlog scenario compile failed:\n${compile_out}${compile_err}")
endif()
execute_process(COMMAND "${CPRAG_RXAS}" -o "${CPRAG_WORK_DIR}/backlog_scenario"
    "${CPRAG_WORK_DIR}/backlog_scenario"
    RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
if(NOT assemble_result EQUAL 0)
    message(FATAL_ERROR "Durable backlog scenario assembly failed:\n${assemble_out}${assemble_err}")
endif()

foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    set(library "${CPRAG_WORK_DIR}/library-${runtime_name}")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E env "TZ=Europe/London" "${runtime}"
        --provider-path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers"
        -l "${imports}" "${CPRAG_WORK_DIR}/backlog_scenario" ${modules}
        -a "${library}"
        RESULT_VARIABLE run_result OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err TIMEOUT 120)
    if(NOT run_result EQUAL 0 OR NOT run_out MATCHES "DURABLE_BACKLOG_OK")
        message(FATAL_ERROR "${runtime_name} durable backlog failed:\n${run_out}${run_err}")
    endif()
endforeach()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "Durable backlog passed task deduplication, fenced split fan-out, window resume, mention migration, stale-answer rejection, uncertainty and source preservation on both VMs.\n")
message(STATUS "Durable backlog assertions passed on both VMs")
