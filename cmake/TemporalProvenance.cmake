foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_APPLICATION_DIR
        CPRAG_SCENARIO CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(GLOB project_member_dirs LIST_DIRECTORIES true
    "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.crexx-build/members/*")
list(JOIN project_member_dirs ";" project_imports)
set(imports "${project_imports};${CPRAG_APPLICATION_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules ragenrich ragproposalio ragperiod ragprovenance ragassessment ragmodel ragevidence
    ragjob ragconfig ragconfiguration ragprofile ragregistry ragschema ragfile ragconfigfile ragglossary
    ragstore ragbackup ragrepository ragcanonical ragplanning ragtrace ragcommandcatalog ragcommand ragingest
    ragfolder ragquotationcontract ragextractioncontract ragresolutioncontract raganswercontract ragreportcontract ragpromptdefaults ragpromptinspection ragcommandutil ragsqlsupport ragdirectcalls ragreportservice ragobservationservice ragqueryservice ragoperationsquery ragclaimrules ragclaims ragimprove ragmaintain ragbacklog ragadmission raglifecycle ragworktypes ragenvironment ragusage ragreceipts ragwork ragquery ragembedding
    ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics raggrounding ragapplicationprovider ragqueryprovider
    ragquerypolicy ragproduct provider_contract provider_catalog provider_http industrial_provider codex_provider architecture_local_config
    generic_profile it_architecture_profile operator_registry rxsqlite rx_hash rx_system rxfs rxplatform
    rxvector rxfnsg library)

foreach(scenario IN ITEMS provenance period enrichment)
if(NOT scenario STREQUAL "provenance")
    get_filename_component(scenario_dir "${CPRAG_SCENARIO}" DIRECTORY)
    set(CPRAG_SCENARIO "${scenario_dir}/${scenario}_scenario.crexx")
endif()
foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/${scenario}-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
            -o "${program}" "${CPRAG_SCENARIO}"
        RESULT_VARIABLE compile_result
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${mode} temporal provenance compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        RESULT_VARIABLE assemble_result
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${mode} temporal provenance assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(library "${CPRAG_WORK_DIR}/library-${scenario}-${mode}-${runtime_name}")
        execute_process(
            COMMAND "${runtime}" -l "${imports}" "${program}" ${modules}
                -a "${library}"
            RESULT_VARIABLE run_result
            OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err
            TIMEOUT 30)
        if(NOT run_result EQUAL 0 OR NOT run_out MATCHES
            "(PROVENANCE_OK|PERIOD_OK|ENRICHMENT_OK)")
            message(FATAL_ERROR
                "${mode}-${runtime_name} temporal provenance failed (${run_result}):\n${run_out}\n${run_err}")
        endif()
    endforeach()
endforeach()

endforeach()
file(WRITE "${CPRAG_WORK_DIR}/summary.txt" "Temporal and provenance validation passed both VMs with and without optimization.\n")
