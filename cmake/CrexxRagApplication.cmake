set(CREXXRAG_APPLICATION_DIR "${CMAKE_BINARY_DIR}/crexx-application")
set(CREXXRAG_APPLICATION_PROJECT_RXBIN
    "${CREXXRAG_APPLICATION_DIR}/project/crexxrag-project.rxbin")
set(CREXXRAG_APPLICATION_RXBIN "${CREXXRAG_APPLICATION_DIR}/crexxrag.rxbin")
set(CREXXRAG_PROVIDER_DIR "${CMAKE_CURRENT_LIST_DIR}/../crexx/providers")
set(CREXXRAG_APP_DIR "${CMAKE_CURRENT_LIST_DIR}/../crexx/application")

# These sources are one CREXX project.  The project driver supplies all of
# their directories as source roots, compiles the members in one parallel wave,
# and publishes only after the link barrier succeeds.  crexxrag_cli owns the
# project's sole MAIN.
set(CREXXRAG_APPLICATION_SOURCES
    "${CREXXRAG_APP_DIR}/surfaces/crexxrag_cli.crexx"
    "${CREXXRAG_PROVIDER_DIR}/provider_contract.crexx"
    "${CREXXRAG_PROVIDER_DIR}/provider_catalog.crexx"
    "${CREXXRAG_PROVIDER_DIR}/provider_http.crexx"
    "${CREXXRAG_PROVIDER_DIR}/industrial_provider.crexx"
    "${CREXXRAG_PROVIDER_DIR}/llama_provider.crexx"
    "${CREXXRAG_APP_DIR}/ragembeddinginput.crexx"
    "${CREXXRAG_PROVIDER_DIR}/codex_provider.crexx"
    "${CREXXRAG_APP_DIR}/ragmodel.crexx"
    "${CREXXRAG_APP_DIR}/ragevidence.crexx"
    "${CREXXRAG_APP_DIR}/ragjob.crexx"
    "${CREXXRAG_APP_DIR}/ragconfig.crexx"
    "${CREXXRAG_APP_DIR}/ragconfigfile.crexx"
    "${CREXXRAG_APP_DIR}/ragglossary.crexx"
    "${CREXXRAG_APP_DIR}/ragprofile.crexx"
    "${CREXXRAG_APP_DIR}/ragprofilefile.crexx"
    "${CREXXRAG_APP_DIR}/ragregistry.crexx"
    "${CREXXRAG_APP_DIR}/ragschema.crexx"
    "${CREXXRAG_APP_DIR}/ragfile.crexx"
    "${CREXXRAG_APP_DIR}/ragstore.crexx"
    "${CREXXRAG_APP_DIR}/ragbackup.crexx"
    "${CREXXRAG_APP_DIR}/ragrepository.crexx"
    "${CREXXRAG_APP_DIR}/ragcanonical.crexx"
    "${CREXXRAG_APP_DIR}/raggrounding.crexx"
    "${CREXXRAG_APP_DIR}/ragperiod.crexx"
    "${CREXXRAG_APP_DIR}/ragassessment.crexx"
    "${CREXXRAG_APP_DIR}/ragenrich.crexx"
    "${CREXXRAG_APP_DIR}/ragprovenance.crexx"
    "${CREXXRAG_APP_DIR}/ragconfiguration.crexx"
    "${CREXXRAG_APP_DIR}/ragplanning.crexx"
    "${CREXXRAG_APP_DIR}/ragtrace.crexx"
    "${CREXXRAG_APP_DIR}/surfaces/ragcommandcatalog.crexx"
    "${CREXXRAG_APP_DIR}/ragcommand.crexx"
    "${CREXXRAG_APP_DIR}/ragworkerdefaults.crexx"
    "${CREXXRAG_APP_DIR}/ragpolicypublication.crexx"
    "${CREXXRAG_APP_DIR}/ragpolicyfile.crexx"
    "${CREXXRAG_APP_DIR}/ragresultpages.crexx"
    "${CREXXRAG_APP_DIR}/ragingest.crexx"
    "${CREXXRAG_APP_DIR}/ragfolder.crexx"
    "${CREXXRAG_APP_DIR}/ragclaims.crexx"
    "${CREXXRAG_APP_DIR}/ragcommandutil.crexx"
    "${CREXXRAG_APP_DIR}/ragsqlsupport.crexx"
    "${CREXXRAG_APP_DIR}/ragdirectcalls.crexx"
    "${CREXXRAG_APP_DIR}/ragreportservice.crexx"
    "${CREXXRAG_APP_DIR}/ragobservationservice.crexx"
    "${CREXXRAG_APP_DIR}/ragqueryservice.crexx"
    "${CREXXRAG_APP_DIR}/ragoperationsquery.crexx"
    "${CREXXRAG_APP_DIR}/ragclaimrules.crexx"
    "${CREXXRAG_APP_DIR}/ragquotationcontract.crexx"
    "${CREXXRAG_APP_DIR}/ragextractioncontract.crexx"
    "${CREXXRAG_APP_DIR}/ragresolutioncontract.crexx"
    "${CREXXRAG_APP_DIR}/ragresolutionreferences.crexx"
    "${CREXXRAG_APP_DIR}/raganswercontract.crexx"
    "${CREXXRAG_APP_DIR}/raganswerreferences.crexx"
    "${CREXXRAG_APP_DIR}/ragreportcontract.crexx"
    "${CREXXRAG_APP_DIR}/ragpromptdefaults.crexx"
    "${CREXXRAG_APP_DIR}/ragpromptinspection.crexx"
    "${CREXXRAG_APP_DIR}/ragimprove.crexx"
    "${CREXXRAG_APP_DIR}/ragmaintain.crexx"
    "${CREXXRAG_APP_DIR}/ragbacklog.crexx"
    "${CREXXRAG_APP_DIR}/ragproposalio.crexx"
    "${CREXXRAG_APP_DIR}/raglifecycle.crexx"
    "${CREXXRAG_APP_DIR}/ragadmission.crexx"
    "${CREXXRAG_APP_DIR}/ragworktypes.crexx"
    "${CREXXRAG_APP_DIR}/ragreceipts.crexx"
    "${CREXXRAG_APP_DIR}/ragusage.crexx"
    "${CREXXRAG_APP_DIR}/ragallowance.crexx"
    "${CREXXRAG_APP_DIR}/ragwork.crexx"
    "${CREXXRAG_APP_DIR}/ragquery.crexx"
    "${CREXXRAG_APP_DIR}/ragembedding.crexx"
    "${CREXXRAG_APP_DIR}/ragretrieval.crexx"
    "${CREXXRAG_APP_DIR}/ragevidencejson.crexx"
    "${CREXXRAG_APP_DIR}/ragfoundation.crexx"
    "${CREXXRAG_APP_DIR}/ragprocess.crexx"
    "${CREXXRAG_APP_DIR}/ragsupervision.crexx"
    "${CREXXRAG_APP_DIR}/ragenvironment.crexx"
    "${CREXXRAG_APP_DIR}/ragproviderdiagnostics.crexx"
    "${CREXXRAG_APP_DIR}/ragapplicationprovider.crexx"
    "${CREXXRAG_APP_DIR}/ragqueryprovider.crexx"
    "${CREXXRAG_APP_DIR}/ragquerypolicy.crexx"
    "${CREXXRAG_APP_DIR}/ragcontinuation.crexx"
    "${CREXXRAG_APP_DIR}/ragproduct.crexx"
    "${CREXXRAG_APP_DIR}/config/architecture_local_config.crexx"
    "${CREXXRAG_APP_DIR}/config/profiles/generic_profile.crexx"
    "${CREXXRAG_APP_DIR}/config/profiles/it_architecture_profile.crexx"
    "${CREXXRAG_APP_DIR}/config/operator_registry.crexx"
    "${CREXXRAG_APP_DIR}/surfaces/ragmcp.crexx")
set(CREXXRAG_ADDRESS_SOURCE
    "${CREXXRAG_APP_DIR}/surfaces/rag_address_environment.crexx")

set(CREXXRAG_REXX_BUILD_JOBS "auto" CACHE STRING
    "Parallel jobs used by the CREXX project driver")
if(NOT CREXXRAG_REXX_BUILD_JOBS STREQUAL "auto" AND
   NOT CREXXRAG_REXX_BUILD_JOBS MATCHES "^[1-9][0-9]*$")
    message(FATAL_ERROR
        "CREXXRAG_REXX_BUILD_JOBS must be auto or a positive integer")
endif()

set(crexxrag_binary_imports
    "${CREXXRAG_SQLITE_PROVIDER_DIR};${CREXX_INSTALL_BIN_DIR}")
add_custom_command(
    OUTPUT "${CREXXRAG_APPLICATION_PROJECT_RXBIN}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory
        "${CREXXRAG_APPLICATION_DIR}/project"
    COMMAND "${CREXX_EXECUTABLE}"
        --program "${CREXXRAG_APPLICATION_DIR}/project/crexxrag-project"
        ${CREXXRAG_APPLICATION_SOURCES}
        --jobs "${CREXXRAG_REXX_BUILD_JOBS}"
        --noexec --nocolor --verbose1
        -i "${crexxrag_binary_imports}"
    DEPENDS
        ${CREXXRAG_APPLICATION_SOURCES}
        "${CREXXRAG_SQLITE_DYNAMIC_PROVIDER}"
        "${CREXXRAG_VECTOR_DYNAMIC_PROVIDER}"
        "${CREXX_EXECUTABLE}"
        "${CREXX_BUILDINFO_FILE}"
        "${CMAKE_CURRENT_LIST_FILE}"
    COMMENT "Building the cREXX application project"
    USES_TERMINAL
    VERBATIM)

set(crexxrag_link_inputs
    "${CREXXRAG_APPLICATION_PROJECT_RXBIN}"
    "${CREXX_INSTALL_BIN_DIR}/rxfnsg.rxbin"
    "${CREXX_INSTALL_BIN_DIR}/classlib.rxbin"
    "${CREXX_INSTALL_BIN_DIR}/library.rxbin")
add_custom_command(
    OUTPUT "${CREXXRAG_APPLICATION_RXBIN}"
    BYPRODUCTS
        "${CREXXRAG_APPLICATION_DIR}/crexxrag.map"
        "${CREXXRAG_APPLICATION_DIR}/crexxrag.rxproviders"
        "${CREXXRAG_APPLICATION_DIR}/artifact.txt"
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_LINK_INPUTS=${crexxrag_link_inputs}"
        "-DCPRAG_OUTPUT_DIR=${CREXXRAG_APPLICATION_DIR}"
        -P "${CMAKE_CURRENT_LIST_DIR}/LinkCrexxRagApplication.cmake"
    DEPENDS
        "${CREXXRAG_APPLICATION_PROJECT_RXBIN}"
        "${CREXXRAG_SQLITE_DYNAMIC_PROVIDER}"
        "${CREXXRAG_VECTOR_DYNAMIC_PROVIDER}"
        "${CREXX_RXLINK_EXECUTABLE}"
        "${CMAKE_CURRENT_LIST_DIR}/LinkCrexxRagApplication.cmake"
    COMMENT "Publishing the linked Level-G crexxrag application"
    VERBATIM)
add_custom_target(crexxrag_application ALL
    DEPENDS "${CREXXRAG_APPLICATION_RXBIN}")

# ADDRESS RAG is a loadable cREXX environment module, not another application
# entry point.  Build and publish it independently from the CLI program.
set(CREXXRAG_ADDRESS_DIR "${CREXXRAG_APPLICATION_DIR}/address")
set(CREXXRAG_ADDRESS_RXBIN
    "${CREXXRAG_ADDRESS_DIR}/rag_address_environment.rxbin")
set(crexxrag_address_source_roots
    "${CREXXRAG_PROVIDER_DIR};${CREXXRAG_APP_DIR};${CREXXRAG_APP_DIR}/config;${CREXXRAG_APP_DIR}/config/profiles")
add_custom_command(
    OUTPUT "${CREXXRAG_ADDRESS_RXBIN}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CREXXRAG_ADDRESS_DIR}"
    COMMAND "${CREXX_EXECUTABLE}"
        --library "${CREXXRAG_ADDRESS_DIR}/rag_address_environment"
        "${CREXXRAG_ADDRESS_SOURCE}"
        --jobs 1 --noexec --nocolor --verbose1
        -s "${crexxrag_address_source_roots}"
        -i "${crexxrag_binary_imports}"
    DEPENDS
        "${CREXXRAG_ADDRESS_SOURCE}"
        ${CREXXRAG_APPLICATION_SOURCES}
        "${CREXXRAG_SQLITE_DYNAMIC_PROVIDER}"
        "${CREXXRAG_VECTOR_DYNAMIC_PROVIDER}"
        "${CREXX_EXECUTABLE}"
        "${CREXX_BUILDINFO_FILE}"
        "${CMAKE_CURRENT_LIST_FILE}"
    COMMENT "Building the ADDRESS RAG environment module"
    USES_TERMINAL
    VERBATIM)
add_custom_target(crexxrag_address ALL
    DEPENDS "${CREXXRAG_ADDRESS_RXBIN}")
