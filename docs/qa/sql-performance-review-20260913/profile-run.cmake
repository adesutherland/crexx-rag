set(CPRAG_WORK_DIR /private/tmp/crexxrag-sql-review-20260913)
set(CPRAG_APPLICATION_DIR /Users/adrian/CLionProjects/crexx-rag/cmake-build-debug/crexx-application)
set(CPRAG_CREXX_BIN_DIR /Users/adrian/.local/bin)
set(CPRAG_PLUGIN_DIR /Users/adrian/.local/bin/providers)
set(CPRAG_RXC /Users/adrian/.local/bin/rxc)
set(CPRAG_RXAS /Users/adrian/.local/bin/rxas)
set(CPRAG_SCENARIO /private/tmp/crexxrag-sql-review-20260913/profile-scan.crexx)
file(GLOB project_member_dirs LIST_DIRECTORIES true
    "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.crexx-build/members/*")
list(JOIN project_member_dirs ";" project_imports)
set(imports "${CPRAG_WORK_DIR};${project_imports};${CPRAG_APPLICATION_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules ragenrich ragproposalio ragperiod ragprovenance ragassessment ragmodel ragevidence
    ragjob ragconfig ragprofile ragregistry ragschema ragfile ragconfigfile ragglossary
    ragstore ragbackup ragrepository ragcanonical ragplanning ragtrace ragcommandcatalog ragcommand ragmcp ragworkerdefaults ragpolicypublication ragpolicyfile ragingest
    ragfolder ragquotationcontract ragextractioncontract ragresolutioncontract raganswercontract ragreportcontract ragpromptdefaults ragpromptinspection ragcommandutil ragsqlsupport ragdirectcalls ragreportservice ragobservationservice ragqueryservice ragoperationsquery ragclaimrules ragclaims ragimprove ragmaintain ragbacklog ragadmission raglifecycle ragworktypes ragenvironment ragusage ragreceipts ragallowance ragwork ragquery ragembedding
    ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics raggrounding ragapplicationprovider ragqueryprovider
    ragquerypolicy ragcontinuation ragproduct provider_contract provider_catalog provider_http industrial_provider codex_provider architecture_local_config
    generic_profile it_architecture_profile operator_registry rxsqlite rx_hash rx_system rxfs rxplatform
    rxvector rxfnsg library)

execute_process(COMMAND /Users/adrian/.local/bin/rxvme --provider-path "${CPRAG_PLUGIN_DIR}" -l "${imports}" /private/tmp/crexxrag-sql-review-20260913/profile-scan diagnosticbacklog ${modules} -a /private/tmp/crexxrag-sql-review-20260913/library.sqlite RESULT_VARIABLE result)
message("profile result=${result}")
