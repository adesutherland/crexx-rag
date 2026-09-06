set(CREXXRAG_NATIVE_APPLICATION
    "${CMAKE_BINARY_DIR}/crexxrag-native/package/crexxrag${CMAKE_EXECUTABLE_SUFFIX}")
set(CREXXRAG_PROVIDER_FIXTURE "$<TARGET_FILE:crexxrag_provider_fixture>")

add_test(NAME linked_application
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_APPLICATION=${CREXXRAG_APPLICATION_RXBIN}"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-linked-application"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CrexxRagApplicationSmoke.cmake")
set_tests_properties(linked_application PROPERTIES
    LABELS "application;linked;sqlite;provider;zero-outbound")

add_test(NAME configuration_contract
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_MODEL=${CREXXRAG_APP_DIR}/ragmodel.crexx"
        "-DCPRAG_CONFIG=${CREXXRAG_APP_DIR}/ragconfig.crexx"
        "-DCPRAG_FILE=${CREXXRAG_APP_DIR}/ragfile.crexx"
        "-DCPRAG_CONFIG_FILE_MODULE=${CREXXRAG_APP_DIR}/ragconfigfile.crexx"
        "-DCPRAG_GLOSSARY_MODULE=${CREXXRAG_APP_DIR}/ragglossary.crexx"
        "-DCPRAG_PROFILE_MODULE=${CREXXRAG_APP_DIR}/ragprofile.crexx"
        "-DCPRAG_PROFILE_FILE_MODULE=${CREXXRAG_APP_DIR}/ragprofilefile.crexx"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/config_scenario.crexx"
        "-DCPRAG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SUBSCRIPTION_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/docs/tutorial/crexxrag-codex-local.conf"
        "-DCPRAG_APPLICATION=${CREXXRAG_APPLICATION_RXBIN}"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-configuration"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ConfigContract.cmake")
set_tests_properties(configuration_contract PROPERTIES
    LABELS "configuration;gemini;privacy;zero-outbound")

add_test(NAME process_workers
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION=${CREXXRAG_APPLICATION_RXBIN}"
        "-DCPRAG_LAUNCHER=${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-process-workers"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ProcessWorkers.cmake")
set_tests_properties(process_workers PROPERTIES
    TIMEOUT 60 LABELS "process;sqlite;multi-process;worker;zero-outbound")

add_test(NAME gemini_ingestion
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION=${CREXXRAG_APPLICATION_RXBIN}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-ingestion"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiIngestion.cmake")
set_tests_properties(gemini_ingestion PROPERTIES
    TIMEOUT 180 LABELS "gemini;ingestion;embedding;claim;trace;loopback")

add_test(NAME gemini_extraction_validation
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-extraction-validation"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiExtractionValidation.cmake")
set_tests_properties(gemini_extraction_validation PROPERTIES
    TIMEOUT 300 LABELS "gemini;extraction;validation;span;registry;dead-letter;secret-free")

add_test(NAME provider_durability
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/provider_durability_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-provider-durability"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ProviderDurability.cmake")
set_tests_properties(provider_durability PROPERTIES
    LABELS "provider;codex;subscription-budget;durability;zero-outbound")

add_test(NAME codex_protocol
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_PROBE=${CREXXRAG_PROVIDER_DIR}/tests/codex_protocol_scenario.crexx"
        "-DCPRAG_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-codex-protocol"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CodexProtocol.cmake")
set_tests_properties(codex_protocol PROPERTIES
    LABELS "provider;codex;jsonl;schema;zero-outbound")

add_test(NAME codex_application
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-codex-application"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CodexApplication.cmake")
set_tests_properties(codex_application PROPERTIES
    TIMEOUT 180 LABELS "provider;codex;application;worker;durability;recovery;zero-outbound")

add_test(NAME gemini_maintenance
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_PROPOSAL_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/proposals/external-architecture.ndjson.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-improvement"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiImprovement.cmake")
set_tests_properties(gemini_maintenance PROPERTIES
    TIMEOUT 180 LABELS "gemini;maintenance;claim;worker;reviewed-plan;ann")

add_test(NAME gemini_query
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-query"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiQuery.cmake")
set_tests_properties(gemini_query PROPERTIES
    TIMEOUT 300 LABELS "gemini;query;embedding;hybrid;answer;citation;privacy;budget")

add_test(NAME query_policy
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APP_DIR}"
        "-DCPRAG_PROVIDER_DIR=${CREXXRAG_PROVIDER_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/query_policy_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-query-policy"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/QueryPolicy.cmake")
set_tests_properties(query_policy PROPERTIES
    LABELS "query;privacy;budget;codex;zero-outbound")

add_test(NAME ann_methodology
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/ann_methodology_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-ann-methodology"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AnnMethodology.cmake")
set_tests_properties(ann_methodology PROPERTIES
    TIMEOUT 240 LABELS "ann;retrieval;recall;tamper;rxvector;sqlite")

add_test(NAME lifecycle_methodology
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/lifecycle_methodology_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-lifecycle-methodology"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/LifecycleMethodology.cmake")
set_tests_properties(lifecycle_methodology PROPERTIES
    TIMEOUT 300 LABELS "maintenance;lifecycle;split;merge;retirement;atomic;sqlite")

add_test(NAME evidence_methodology
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/evidence_methodology_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-evidence-methodology"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/EvidenceMethodology.cmake")
set_tests_properties(evidence_methodology PROPERTIES
    TIMEOUT 300 LABELS "retrieval;graph;direction;lead;note;gap;sqlite")

add_test(NAME maintenance_methodology
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/maintenance_methodology_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-maintenance-methodology"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/MaintenanceMethodology.cmake")
set_tests_properties(maintenance_methodology PROPERTIES
    TIMEOUT 300 LABELS "maintenance;census;worklist;ranking;replay;sqlite")

add_test(NAME native_surfaces
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-surfaces"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeSurfaces.cmake")
set_tests_properties(native_surfaces PROPERTIES
    TIMEOUT 300 LABELS "native;human;mcp;gemini;answer;strict-json;configuration")

add_test(NAME address_surface
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_ADDRESS_RXBIN=${CREXXRAG_ADDRESS_RXBIN}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/address_surface_scenario.crexx"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-address-surface"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AddressSurface.cmake")
set_tests_properties(address_surface PROPERTIES
    TIMEOUT 180 LABELS "address;surface;configuration;access;zero-outbound")

add_test(NAME gemini_provider_smoke
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-provider-smoke"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiProviderSmoke.cmake")
set_tests_properties(gemini_provider_smoke PROPERTIES
    TIMEOUT 300 LABELS "provider;gemini;generation;embedding;citation;budget;secret-free")

add_test(NAME installed_product
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_BUILD_DIR=${CMAKE_BINARY_DIR}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_PROVIDER_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_MAINTENANCE_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_PROPOSAL_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/proposals/external-architecture.ndjson.in"
        "-DCPRAG_PROVIDER_SMOKE_SCRIPT=${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiProviderSmoke.cmake"
        "-DCPRAG_MAINTENANCE_SCRIPT=${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiImprovement.cmake"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-installed-product"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/InstalledProduct.cmake")
set_tests_properties(installed_product PROPERTIES
    TIMEOUT 720 LABELS "installed;native;gemini;ingestion;maintenance;query;skills")

add_test(NAME documentation_contract
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-documentation-contract"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DocumentationContract.cmake")
set_tests_properties(documentation_contract PROPERTIES
    LABELS "documentation;methodology;skills;zero-outbound")

add_test(NAME local_embedding_protocol
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PROBE=${CREXXRAG_PROVIDER_DIR}/tests/local_embedding_protocol_scenario.crexx"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-local-embedding-protocol"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/LocalEmbeddingProtocol.cmake")
set_tests_properties(local_embedding_protocol PROPERTIES
    TIMEOUT 180 LABELS "provider;local;openai-compatible;llama.cpp;embedding;privacy")


add_test(NAME quotation_grounding
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/grounding_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-quotation-grounding"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/QuotationGrounding.cmake")
set_tests_properties(quotation_grounding PROPERTIES
    LABELS "extraction;quotation;unicode;provenance;zero-outbound")

add_test(NAME durable_backlog
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/backlog_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklog.cmake")
set_tests_properties(durable_backlog PROPERTIES
    TIMEOUT 300 LABELS "maintenance;lifecycle;split;merge;retirement;atomic;sqlite")

add_test(NAME durable_backlog_provider
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog-provider"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklogProvider.cmake")
set_tests_properties(durable_backlog_provider PROPERTIES
    TIMEOUT 240 LABELS "maintenance;gemini;resolution;redaction;sqlite;zero-outbound")
