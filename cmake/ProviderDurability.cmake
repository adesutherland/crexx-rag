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
set(modules ragsupervision ragenrich ragproposalio ragperiod ragprovenance ragassessment ragschema ragfile
    ragstore ragmodel ragjob ragquotationcontract ragextractioncontract ragresolutioncontract raganswercontract ragreportcontract ragpromptdefaults ragpromptinspection ragcommandutil ragsqlsupport ragdirectcalls ragreportservice ragobservationservice ragqueryservice ragoperationsquery ragclaimrules ragclaims ragadmission raglifecycle ragworktypes ragenvironment ragusage ragreceipts ragallowance ragwork ragcommandcatalog ragcommand ragworkerdefaults ragpolicypublication ragpolicyfile ragtrace ragbacklog
    ragmaintain ragimprove ragconfiguration ragconfig ragprofile ragcanonical raggrounding rxfnsg rxsqlite
    rx_hash rx_system rxfs rxplatform library)

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/provider-durability-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
            -o "${program}" "${CPRAG_SCENARIO}"
        RESULT_VARIABLE compile_result
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${mode} provider durability compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        RESULT_VARIABLE assemble_result
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${mode} provider durability assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(library "${CPRAG_WORK_DIR}/library-${mode}-${runtime_name}")
        execute_process(
            COMMAND "${runtime}" -l "${imports}" "${program}" ${modules}
                -a "${library}"
            RESULT_VARIABLE run_result
            OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err
            TIMEOUT 30)
        if(NOT run_result EQUAL 0 OR NOT run_out MATCHES
            "PROVIDER_DURABILITY_OK completed_turn_reused=1 codex_turns=1 stale_reservations=0 fence=2 admissions=durable uncalled_provider_runs=0 paused_completion=sticky batch_retry=2 replay=immutable reconciliation=in-progress indexes=11 migration=1to6-validated-to11 provider_history=costed prospective_config=audited large_plan=renderable")
            message(FATAL_ERROR
                "${mode}-${runtime_name} provider durability failed (${run_result}):\n${run_out}\n${run_err}")
        endif()
    endforeach()
endforeach()

file(WRITE "${CPRAG_WORK_DIR}/summary.txt"
    "Provider durability passed in noopt/opt on rxvme/rxbvm: completed Codex output reused, one subscription turn charged, stale reservations released, fencing advanced, provider concurrency admission was durable, an uncalled preflight created no provider run, paused jobs remained paused, legacy retry remained compatible, immutable replay retained source dead letters and lineage, reconciliation classified the active replay, worker indexes were present, and schema version one upgraded to six, validated as an older supported schema, then upgraded to version nine with costed provider history and prospective configuration auditing.\n")
