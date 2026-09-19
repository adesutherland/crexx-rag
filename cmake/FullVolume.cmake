foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION_DIR CPRAG_PLUGIN_DIR CPRAG_SCENARIO CPRAG_WORK_DIR
        CPRAG_SCALE_LIBRARY CPRAG_SCALE_PROFILE)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REAL_PATH "${CPRAG_SCALE_LIBRARY}" scale_library)
get_filename_component(work_directory "${CPRAG_WORK_DIR}" ABSOLUTE)
string(FIND "${scale_library}/" "${work_directory}/" work_contains_library)
string(FIND "${work_directory}/" "${scale_library}/" library_contains_work)
if(work_contains_library EQUAL 0 OR library_contains_work EQUAL 0)
    message(FATAL_ERROR "The probe work directory must be separate from the supplied library")
endif()
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(GLOB project_member_dirs LIST_DIRECTORIES true
    "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.crexx-build/members/*")
list(JOIN project_member_dirs ";" project_imports)
set(imports "${CPRAG_WORK_DIR};${project_imports};${CPRAG_APPLICATION_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules ragsupervision ragenrich ragproposalio ragperiod ragprovenance ragassessment ragmodel ragevidence
    ragjob ragconfig ragprofile ragprofilefile ragregistry ragschema ragfile ragconfigfile
    ragglossary ragstore ragbackup ragrepository ragcanonical ragplanning ragtrace ragcommandcatalog ragcommand ragworkerdefaults ragpolicypublication ragpolicyfile
    ragingest ragfolder ragquotationcontract ragextractioncontract ragresolutioncontract raganswercontract ragreportcontract ragpromptdefaults ragpromptinspection ragcommandutil ragsqlsupport ragdirectcalls ragreportservice ragobservationservice ragqueryservice ragoperationsquery ragclaimrules ragclaims ragimprove ragmaintain ragbacklog ragadmission raglifecycle ragworktypes ragenvironment ragusage ragreceipts ragallowance ragwork ragquery
    ragembedding ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics raggrounding ragapplicationprovider
    ragqueryprovider ragquerypolicy ragcontinuation ragproduct provider_contract provider_catalog provider_http industrial_provider llama_provider ragembeddinginput codex_provider
    architecture_local_config generic_profile it_architecture_profile operator_registry rxsqlite rx_hash rx_system rxfs
    rxplatform rxvector rxfnsg library)

execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}"
    -o "${CPRAG_WORK_DIR}/full_volume_scenario" "${CPRAG_SCENARIO}"
    RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
if(NOT compile_result EQUAL 0)
    message(FATAL_ERROR "Full-volume scenario compile failed:\n${compile_out}${compile_err}")
endif()
execute_process(COMMAND "${CPRAG_RXAS}" -o "${CPRAG_WORK_DIR}/full_volume_scenario"
    "${CPRAG_WORK_DIR}/full_volume_scenario"
    RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
if(NOT assemble_result EQUAL 0)
    message(FATAL_ERROR "Full-volume scenario assembly failed:\n${assemble_out}${assemble_err}")
endif()

foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    execute_process(COMMAND "${runtime}"
        --provider-path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}"
        -l "${imports}" "${CPRAG_WORK_DIR}/full_volume_scenario" ${modules}
        -a "${CPRAG_SCALE_LIBRARY}" "${CPRAG_SCALE_PROFILE}"
        RESULT_VARIABLE run_result OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err TIMEOUT 120)
    file(WRITE "${CPRAG_WORK_DIR}/${runtime_name}.log" "${run_out}${run_err}")
    if(NOT run_result EQUAL 0 OR NOT run_out MATCHES "FULL_VOLUME_OK")
        message(FATAL_ERROR "${runtime_name} full-volume retrieval failed:\n${run_out}${run_err}")
    endif()
endforeach()
