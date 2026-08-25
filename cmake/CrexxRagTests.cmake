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
        "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
        "-DCPRAG_MODEL=${CREXXRAG_APP_DIR}/ragmodel.crexx"
        "-DCPRAG_CONFIG=${CREXXRAG_APP_DIR}/ragconfig.crexx"
        "-DCPRAG_FILE=${CREXXRAG_APP_DIR}/ragfile.crexx"
        "-DCPRAG_CONFIG_FILE_MODULE=${CREXXRAG_APP_DIR}/ragconfigfile.crexx"
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

add_test(NAME provider_durability
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
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
        "-DCPRAG_PROBE=${CREXXRAG_PROVIDER_DIR}/tests/codex_protocol_scenario.crexx"
        "-DCPRAG_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-codex-protocol"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CodexProtocol.cmake")
set_tests_properties(codex_protocol PROPERTIES
    LABELS "provider;codex;jsonl;schema;zero-outbound")

add_test(NAME gemini_improvement
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_PROPOSAL_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/proposals/external-architecture.ndjson.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-improvement"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiImprovement.cmake")
set_tests_properties(gemini_improvement PROPERTIES
    TIMEOUT 180 LABELS "gemini;improvement;claim;worker;reviewed-plan")

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
