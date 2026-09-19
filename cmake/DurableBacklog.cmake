foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION_DIR CPRAG_PLUGIN_DIR CPRAG_SCENARIO CPRAG_WORK_DIR CPRAG_NATIVE_APPLICATION CPRAG_CONFIG_FIXTURE)
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
set(modules ragsupervision ragenrich ragproposalio ragperiod ragprovenance ragassessment ragmodel ragevidence
    ragjob ragconfig ragprofile ragregistry ragschema ragfile ragconfigfile ragglossary
    ragstore ragbackup ragrepository ragcanonical ragplanning ragtrace ragcommandcatalog ragcommand ragmcp ragworkerdefaults ragpolicypublication ragpolicyfile ragingest
    ragfolder ragquotationcontract ragextractioncontract ragresolutioncontract raganswercontract ragreportcontract ragpromptdefaults ragpromptinspection ragcommandutil ragsqlsupport ragdirectcalls ragreportservice ragobservationservice ragqueryservice ragoperationsquery ragclaimrules ragclaims ragimprove ragmaintain ragbacklog ragadmission raglifecycle ragworktypes ragenvironment ragusage ragreceipts ragallowance ragwork ragquery ragembedding
    ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics raggrounding ragapplicationprovider ragqueryprovider
    ragquerypolicy ragcontinuation ragproduct provider_contract provider_catalog provider_http industrial_provider llama_provider ragembeddinginput codex_provider architecture_local_config
    generic_profile it_architecture_profile operator_registry rxsqlite rx_hash rx_system rxfs rxplatform
    rxvector rxfnsg library)

if(CPRAG_PREBUILT)
    file(COPY "${CPRAG_PREBUILT}/backlog_scenario.rxbin" DESTINATION "${CPRAG_WORK_DIR}")
else()
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

endif()
if(CPRAG_COMPILE_ONLY)
    return()
endif()
if(NOT CPRAG_CASE)
    set(CPRAG_CASE core)
endif()
foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    set(library "${CPRAG_WORK_DIR}/library-${runtime_name}")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E env "TZ=Europe/London" "${runtime}"
        --provider-path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}"
        -l "${imports}" "${CPRAG_WORK_DIR}/backlog_scenario" ${modules}
        -a "${library}" "${CPRAG_CASE}"
        RESULT_VARIABLE run_result OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err TIMEOUT 120)
    if(NOT run_result EQUAL 0 OR NOT run_out MATCHES "DURABLE_BACKLOG_OK")
        message(FATAL_ERROR "${runtime_name} durable backlog failed:\n${run_out}${run_err}")
    endif()
endforeach()

if(NOT CPRAG_CASE STREQUAL "core")
    return()
endif()

# Replay the old unfinished marker through the shipped native command path.
# SQL only represents historical state and checks retained facts.
find_program(sqlite_cli sqlite3 REQUIRED)
set(database "${CPRAG_WORK_DIR}/library-rxbvm/library.sqlite")
set(native "${CPRAG_NATIVE_APPLICATION}" --library "${CPRAG_WORK_DIR}/library-rxbvm"
    --config-file "${CPRAG_CONFIG_FIXTURE}" --profile it-architecture-profile --format json)
set(facts "SELECT (SELECT published_generation FROM library_meta)||':'||(SELECT count(*) FROM maintenance_tasks)||':'||(SELECT count(*) FROM provider_runs)||':'||(SELECT count(*) FROM source_revisions)||':'||(SELECT count(*) FROM attempts)||':'||(SELECT count(*) FROM reviews);")
execute_process(COMMAND "${sqlite_cli}" "${database}" "${facts}"
    OUTPUT_VARIABLE before OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${sqlite_cli}" "${database}"
    "UPDATE maintenance_workflows SET state='migrating',completed_generation=NULL WHERE workflow_id='closure-workflow';"
    COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND ${native} --access read maintain workflows --concept "Platform closure"
    RESULT_VARIABLE result OUTPUT_VARIABLE inventory ERROR_VARIABLE errors TIMEOUT 30)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "Native workflow discovery failed: ${inventory}${errors}")
endif()
string(JSON count LENGTH "${inventory}" records)
math(EXPR last "${count}-1")
set(workflow "")
foreach(i RANGE 0 ${last})
    string(JSON kind GET "${inventory}" records ${i} kind)
    if(kind STREQUAL "maintenance-workflow")
        string(JSON detail GET "${inventory}" records ${i} fields detail)
        string(JSON workflow GET "${detail}" workflow_id)
    endif()
endforeach()
if(NOT workflow STREQUAL "closure-workflow")
    message(FATAL_ERROR "Native discovery omitted the named workflow: ${inventory}")
endif()
execute_process(COMMAND ${native} --access plan maintain reconcile "${workflow}"
    RESULT_VARIABLE result OUTPUT_VARIABLE preview ERROR_VARIABLE errors TIMEOUT 30)
if(NOT result EQUAL 0 OR NOT preview MATCHES "complete-retired-workflow")
    message(FATAL_ERROR "Native old workflow preview failed: ${preview}${errors}")
endif()
string(JSON generation GET "${preview}" records 0 fields generation)
foreach(repetition RANGE 1 2)
    execute_process(COMMAND ${native} --access curate maintain reconcile "${workflow}" --apply --expect-generation "${generation}"
        RESULT_VARIABLE result OUTPUT_VARIABLE applied ERROR_VARIABLE errors TIMEOUT 30)
    if(NOT result EQUAL 0 OR NOT applied MATCHES "complete")
        message(FATAL_ERROR "Native old workflow completion failed: ${applied}${errors}")
    endif()
endforeach()
execute_process(COMMAND "${sqlite_cli}" "${database}" "${facts}"
    OUTPUT_VARIABLE after OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${sqlite_cli}" "${database}"
    "SELECT state||':'||(completed_generation=(SELECT max(generation) FROM concept_versions WHERE concept_id='closure-parent' AND lifecycle_state='retired')) FROM maintenance_workflows WHERE workflow_id='closure-workflow';"
    OUTPUT_VARIABLE state OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
if(NOT before STREQUAL after OR NOT state STREQUAL "complete:1")
    message(FATAL_ERROR "Native workflow recovery changed history or published again: ${before}, ${after}, ${state}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "Durable backlog passed task deduplication, fenced split fan-out, window resume, mention migration, stale-answer rejection, uncertainty and source preservation on both VMs.\n")
message(STATUS "Durable backlog assertions passed on both VMs")
