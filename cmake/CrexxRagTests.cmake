include("${CMAKE_CURRENT_LIST_DIR}/CrexxRagTestExecution.cmake")
set(CREXXRAG_NATIVE_APPLICATION
    "${CMAKE_BINARY_DIR}/crexxrag-native/package/crexxrag${CMAKE_EXECUTABLE_SUFFIX}")
set(CREXXRAG_PROVIDER_FIXTURE "$<TARGET_FILE:crexxrag_provider_fixture>")

crexxrag_add_test(NAME regression_folder_include
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-folder-include"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/FolderInclude.cmake")
set_tests_properties(regression_folder_include PROPERTIES
    TIMEOUT 120 LABELS "regression;ingestion;configuration;zero-outbound")

crexxrag_add_test(NAME regression_source_backlog
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-source-backlog"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/SourceBacklog.cmake")
set_tests_properties(regression_source_backlog PROPERTIES
    TIMEOUT 90 LABELS "regression;operator;pagination;zero-outbound")

crexxrag_add_test(NAME regression_source_maintenance
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-source-maintenance"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/SourceMaintenance.cmake")
set_tests_properties(regression_source_maintenance PROPERTIES
    TIMEOUT 180 LABELS "regression;maintenance;source;zero-outbound")

crexxrag_add_test(NAME advanced_first_pass
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-advanced-first-pass"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AdvancedFirstPass.cmake")
set_tests_properties(advanced_first_pass PROPERTIES
    TIMEOUT 240 LABELS "regression;maintenance;source;provider;worker;recovery;zero-outbound")

crexxrag_add_test(NAME regression_job_deadline
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-job-deadline"
        -DCPRAG_DEADLINE_TEST=ON -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/SourceMaintenance.cmake")
set_tests_properties(regression_job_deadline PROPERTIES
    TIMEOUT 180 LABELS "regression;maintenance;source;zero-outbound")

crexxrag_add_test(NAME regression_policy_file
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_LOCK_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/policy/lock-owner.sh"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-policy-file"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PolicyFile.cmake")
set_tests_properties(regression_policy_file PROPERTIES
    TIMEOUT 240 LABELS "regression;configuration;policy;recovery;zero-outbound")

crexxrag_add_test(NAME regression_command_metadata
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_EXPECTED_CONTRACTS=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/contracts/command-metadata.sha256"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-command-metadata"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CommandMetadata.cmake")
set_tests_properties(regression_command_metadata PROPERTIES TIMEOUT 60 LABELS "regression;command;contract;zero-outbound")

crexxrag_add_test(NAME regression_command_arguments
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-command-arguments"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CommandArguments.cmake")
set_tests_properties(regression_command_arguments PROPERTIES TIMEOUT 120 LABELS "regression;command;strict-json;zero-outbound")

crexxrag_add_test(NAME regression_operator_diagnostics
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-operator-diagnostics"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/OperatorDiagnostics.cmake")
set_tests_properties(regression_operator_diagnostics PROPERTIES
    TIMEOUT 120 LABELS "regression;operator;pagination;zero-outbound")

# Smoke regressions retain ordinary assertions after their product repairs.
# Labels describe the cause; they never invert or suppress failures.
foreach(case IN ITEMS stale_workers terminal_state)
    crexxrag_add_test(NAME regression_smoke_${case}
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
            "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
            "-DCPRAG_CASE=${case}"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-smoke-${case}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/SmokeStatus.cmake")
    set_tests_properties(regression_smoke_${case} PROPERTIES
        TIMEOUT 90 LABELS "regression;operator;recovery;zero-outbound")
endforeach()

crexxrag_add_test(NAME regression_rule_simplification
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-rule-simplification"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/RuleSimplification.cmake")
set_tests_properties(regression_rule_simplification PROPERTIES
    TIMEOUT 90 LABELS "regression;configuration;lifecycle;zero-outbound")

crexxrag_add_test(NAME regression_prompt_inspection
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/prompt_inspection_scenario.crexx"
        "-DCPRAG_MARKER=PROMPT_INSPECTION_OK"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-prompt-inspection"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PromptInspection.cmake")
set_tests_properties(regression_prompt_inspection PROPERTIES
    TIMEOUT 150 LABELS "regression;prompt;configuration;zero-outbound")

crexxrag_add_test(NAME regression_prompt_contract
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION=${CREXXRAG_APPLICATION_RXBIN}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_INGESTION_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_QUERY_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_EXPECTED_CONTRACTS=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/contracts/provider-contracts.sha256"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-prompt-contract"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PromptContract.cmake")
set_tests_properties(regression_prompt_contract PROPERTIES
    TIMEOUT 180 LABELS "regression;prompt;schema;loopback;zero-outbound")

crexxrag_add_test(NAME regression_policy_file_vm
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/policy_file_scenario.crexx"
        "-DCPRAG_MARKER=POLICY_FILE_OK"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-policy-file-vm"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ProjectContract.cmake")
set_tests_properties(regression_policy_file_vm PROPERTIES
    TIMEOUT 150 LABELS "regression;configuration;policy;sqlite;zero-outbound")
set_tests_properties(regression_policy_file_vm PROPERTIES
    ENVIRONMENT "CPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf")

crexxrag_add_test(NAME regression_command_catalogue
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/command_catalogue_scenario.crexx"
        "-DCPRAG_MARKER=COMMAND_CATALOGUE_OK"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-command-catalogue"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ProjectContract.cmake")
set_tests_properties(regression_command_catalogue PROPERTIES
    TIMEOUT 150 LABELS "regression;command;contract;zero-outbound")

crexxrag_add_test(NAME regression_claim_policy
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/claim_policy_scenario.crexx"
        "-DCPRAG_MARKER=CLAIM_POLICY_OK"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-claim-policy"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ProjectContract.cmake")
set_tests_properties(regression_claim_policy PROPERTIES
    TIMEOUT 150 LABELS "regression;claim;policy;zero-outbound")

crexxrag_add_test(NAME native_lifecycle
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-lifecycle"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeLifecycle.cmake")
set_tests_properties(native_lifecycle PROPERTIES
    TIMEOUT 180 LABELS "native;recovery;lifecycle;regression;loopback")

crexxrag_add_test(NAME linked_application
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_APPLICATION=${CREXXRAG_APPLICATION_RXBIN}"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-linked-application"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CrexxRagApplicationSmoke.cmake")
set_tests_properties(linked_application PROPERTIES
    LABELS "application;linked;sqlite;provider;zero-outbound")

crexxrag_add_test(NAME configuration_contract
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

crexxrag_add_test(NAME regression_supervision
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/supervision_regression.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-supervision-regression"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/SupervisionRegression.cmake")
set_tests_properties(regression_supervision PROPERTIES
    TIMEOUT 150 LABELS "regression;worker;recovery;zero-outbound")

foreach(case IN ITEMS positive aged replenish cancel outage outage24 bad-task)
crexxrag_add_test(NAME native_supervision_${case}
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-supervision-${case}"
        "-DCPRAG_CASES=${case}"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeSupervision.cmake")
set_tests_properties(native_supervision_${case} PROPERTIES
    TIMEOUT 240 LABELS "regression;worker;recovery;native;zero-outbound")
endforeach()

crexxrag_add_test(NAME worker_unexpected_exit
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_CASES=worker-kill;worker-unknown;worker-write-error"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-worker-unexpected-exit"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeSupervision.cmake")
# Re-enabled for installed CREXX 17e844441ed8 qualification of
# https://github.com/adesutherland/CREXX/issues/701. Keep all original fault cases.
set_tests_properties(worker_unexpected_exit PROPERTIES
    TIMEOUT 300 PROCESSORS 8
    LABELS "regression;worker;recovery;native;zero-outbound;crexx-701")

crexxrag_add_test(NAME process_workers
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION=${CREXXRAG_APPLICATION_RXBIN}"
        "-DCPRAG_LAUNCHER=${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-process-workers"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ProcessWorkers.cmake")
set_tests_properties(process_workers PROPERTIES
    TIMEOUT 150 LABELS "process;sqlite;multi-process;worker;zero-outbound")

crexxrag_add_test(NAME gemini_ingestion
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

crexxrag_add_test(NAME gemini_extraction_validation
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-extraction-validation"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiExtractionValidation.cmake")
set_tests_properties(gemini_extraction_validation PROPERTIES
    TIMEOUT 300 LABELS "gemini;extraction;validation;span;registry;dead-letter;secret-free")

crexxrag_add_test(NAME provider_durability
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

foreach(mode IN ITEMS noopt opt)
foreach(runtime IN ITEMS rxvme rxbvm)
crexxrag_add_test(NAME codex_protocol_${mode}_${runtime}
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_MODE=${mode}" "-DCPRAG_RUNTIME=${runtime}"
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
set_tests_properties(codex_protocol_${mode}_${runtime} PROPERTIES
    LABELS "provider;codex;jsonl;schema;zero-outbound")

endforeach()
endforeach()

crexxrag_add_test(NAME codex_protocol_turnover
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
        -DCPRAG_TURNOVER=ON
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CodexProtocol.cmake")
set_tests_properties(codex_protocol_turnover PROPERTIES
    LABELS "provider;codex;jsonl;schema;zero-outbound")

crexxrag_add_test(NAME codex_application
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-codex-application"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CodexApplication.cmake")
set_tests_properties(codex_application PROPERTIES
    TIMEOUT 180 LABELS "provider;codex;application;worker;durability;recovery;zero-outbound")

foreach(case IN ITEMS invalid-schema invalid-schema-start)
crexxrag_add_test(NAME codex_application_${case}
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-codex-application-${case}"
        "-DCPRAG_TERMINAL_FAILURE=${case}"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CodexApplication.cmake")
set_tests_properties(codex_application_${case} PROPERTIES
    TIMEOUT 180 LABELS "provider;codex;application;worker;durability;recovery;zero-outbound")
endforeach()

foreach(case IN ITEMS receipt-write preflight-once preflight-always preflight-disabled turn-disconnect admission-release citation-feedback citation-exhausted)
crexxrag_add_test(NAME worker_recovery_${case}
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-worker-recovery-${case}"
        "-DCPRAG_CASE=${case}"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/WorkerRecovery.cmake")
set_tests_properties(worker_recovery_${case} PROPERTIES
    TIMEOUT 180 LABELS "provider;worker;durability;recovery;zero-outbound")
endforeach()

foreach(case IN ITEMS interrupted completed cleanup unavailable exhausted unavailable-only)
crexxrag_add_test(NAME controller_recovery_${case}
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-controller-recovery-${case}"
        "-DCPRAG_CASES=${case}"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ControllerRecovery.cmake")
set_tests_properties(controller_recovery_${case} PROPERTIES
    TIMEOUT 180 LABELS "provider;worker;concurrency;recovery;zero-outbound")
endforeach()

crexxrag_add_test(NAME gemini_maintenance
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_PROPOSAL_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/proposals/external-architecture.ndjson.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-improvement"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiImprovement.cmake")
set_tests_properties(gemini_maintenance PROPERTIES
    TIMEOUT 180 LABELS "gemini;maintenance;claim;worker;reviewed-plan;ann")

crexxrag_add_test(NAME gemini_query
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-query"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiQuery.cmake")
set_tests_properties(gemini_query PROPERTIES
    TIMEOUT 300 LABELS "gemini;query;embedding;hybrid;answer;citation;privacy;budget")

crexxrag_add_test(NAME query_policy
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

crexxrag_add_test(NAME ann_methodology
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

# Trained weights are provisioned separately. When selected, this is a required
# local integration case; absence is reported at configure time, never a pass.
set(CREXXRAG_BGE_MODEL "" CACHE FILEPATH "Pinned BGE-small GGUF for native embedding acceptance")
if(NOT CREXXRAG_BGE_MODEL AND EXISTS "$ENV{HOME}/Library/Caches/crexx/native-inference/bge-small-en-v1.5-f16.gguf")
    set(CREXXRAG_BGE_MODEL "$ENV{HOME}/Library/Caches/crexx/native-inference/bge-small-en-v1.5-f16.gguf" CACHE FILEPATH "Pinned BGE-small GGUF for native embedding acceptance" FORCE)
endif()
if(CREXXRAG_BGE_MODEL)
    set(window_sources
        "${CREXXRAG_APP_DIR}/tests/embedding_windows_scenario.crexx"
        "${CREXXRAG_APP_DIR}/ragembeddinginput.crexx"
        "${CREXXRAG_PROVIDER_DIR}/llama_provider.crexx"
        "${CREXXRAG_APP_DIR}/ragconfig.crexx"
        "${CREXXRAG_APP_DIR}/ragmodel.crexx"
        "${CREXXRAG_APP_DIR}/ragworkerdefaults.crexx"
        "${CREXXRAG_PROVIDER_DIR}/provider_contract.crexx")
    set(window_probe "${CMAKE_BINARY_DIR}/qa-programs/embedding-windows/window-probe")
    add_custom_command(OUTPUT "${window_probe}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/qa-programs/embedding-windows"
        COMMAND "${CREXX_EXECUTABLE}" --program "${window_probe}" ${window_sources}
            --jobs 4 --native --noexec --nocolor
        DEPENDS ${window_sources} "${CREXX_EXECUTABLE}" "${CREXX_BUILDINFO_FILE}"
        COMMENT "Building native embedding window acceptance" VERBATIM)
    add_custom_target(crexxrag_window_probe ALL DEPENDS "${window_probe}")
    crexxrag_add_test(NAME native_embedding_windows
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
            "-DCPRAG_PROBE=${window_probe}"
            "-DCPRAG_MODEL=${CREXXRAG_BGE_MODEL}"
            "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-embedding-windows"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeEmbeddingWindows.cmake")
    set_tests_properties(native_embedding_windows PROPERTIES TIMEOUT 120 LABELS "native;embedding;local-model;zero-outbound")
else()
    message(STATUS "Native trained-model acceptance not selected: set CREXXRAG_BGE_MODEL to qualify it")
endif()

crexxrag_add_test(NAME lifecycle_methodology
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

crexxrag_add_test(NAME evidence_methodology
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

crexxrag_add_test(NAME maintenance_methodology
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

crexxrag_add_test(NAME native_surfaces
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-surfaces"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeSurfaces.cmake")
set_tests_properties(native_surfaces PROPERTIES
    TIMEOUT 300 LABELS "native;human;mcp;gemini;answer;strict-json;configuration")

crexxrag_add_test(NAME address_surface
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

crexxrag_add_test(NAME regression_result_contract
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_ADDRESS_RXBIN=${CREXXRAG_ADDRESS_RXBIN}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/result_contract_scenario.crexx"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-result-contract"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AddressSurface.cmake")
set_tests_properties(regression_result_contract PROPERTIES
    TIMEOUT 180 LABELS "regression;address;public-contract;query;zero-outbound")

crexxrag_add_test(NAME gemini_provider_smoke
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-gemini-provider-smoke"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiProviderSmoke.cmake")
set_tests_properties(gemini_provider_smoke PROPERTIES
    TIMEOUT 300 LABELS "provider;gemini;generation;embedding;citation;budget;secret-free")

crexxrag_add_test(NAME installed_product
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

crexxrag_add_test(NAME documentation_contract
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-documentation-contract"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DocumentationContract.cmake")
set_tests_properties(documentation_contract PROPERTIES
    LABELS "documentation;methodology;skills;zero-outbound")

crexxrag_add_test(NAME local_embedding_protocol
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


crexxrag_add_test(NAME quotation_grounding
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

crexxrag_add_test(NAME temporal_provenance
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/provenance_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-temporal-provenance"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/TemporalProvenance.cmake")
set_tests_properties(temporal_provenance PROPERTIES
    LABELS "extraction;quotation;unicode;provenance;zero-outbound")

crexxrag_add_test(NAME durable_backlog
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/backlog_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklog.cmake")
set_tests_properties(durable_backlog PROPERTIES
    TIMEOUT 300 LABELS "maintenance;lifecycle;split;merge;retirement;atomic;sqlite")

crexxrag_add_test(NAME durable_backlog_escalation
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/backlog_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog"
        -DCPRAG_CASE=escalation
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklog.cmake")
set_tests_properties(durable_backlog_escalation PROPERTIES
    TIMEOUT 300 LABELS "maintenance;lifecycle;split;merge;retirement;atomic;sqlite")

crexxrag_add_test(NAME durable_backlog_budget
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/backlog_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog"
        -DCPRAG_CASE=budget
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklog.cmake")
set_tests_properties(durable_backlog_budget PROPERTIES
    TIMEOUT 300 LABELS "maintenance;lifecycle;split;merge;retirement;atomic;sqlite")

crexxrag_add_test(NAME durable_backlog_recording
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/backlog_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog"
        -DCPRAG_CASE=recording
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklog.cmake")
set_tests_properties(durable_backlog_recording PROPERTIES
    TIMEOUT 300 LABELS "maintenance;lifecycle;split;merge;retirement;atomic;sqlite")

crexxrag_add_test(NAME durable_backlog_reconsideration
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/backlog_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog"
        -DCPRAG_CASE=reconsideration
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklog.cmake")
set_tests_properties(durable_backlog_reconsideration PROPERTIES
    TIMEOUT 300 LABELS "maintenance;lifecycle;split;merge;retirement;atomic;sqlite")

crexxrag_add_test(NAME durable_backlog_sparse_edge
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/backlog_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog"
        -DCPRAG_CASE=sparse-edge
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklog.cmake")
set_tests_properties(durable_backlog_sparse_edge PROPERTIES
    TIMEOUT 300 LABELS "maintenance;claim;review;atomic;sqlite;zero-outbound")

crexxrag_add_test(NAME durable_backlog_actionability
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_FIXTURE=${CREXXRAG_APP_DIR}/config/google-gemini.conf"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/backlog_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog"
        -DCPRAG_CASE=actionability
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklog.cmake")
set_tests_properties(durable_backlog_actionability PROPERTIES
    TIMEOUT 300 LABELS "maintenance;review;sqlite;zero-outbound")

crexxrag_add_test(NAME task_reset
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-task-reset"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/TaskReset.cmake")
set_tests_properties(task_reset PROPERTIES
    TIMEOUT 150 LABELS "regression;maintenance;recovery;surface;zero-outbound")

foreach(case IN ITEMS valid receipt-recovery advanced malformed rejected manual concurrent budget continuation item-limit correction correction-failed correction-budget correction-advanced)
crexxrag_add_test(NAME durable_backlog_provider_${case}
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog-provider-${case}"
        "-DCPRAG_CASES=${case}"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklogProvider.cmake")
set_tests_properties(durable_backlog_provider_${case} PROPERTIES
    TIMEOUT 240 LABELS "maintenance;gemini;resolution;redaction;sqlite;zero-outbound")
endforeach()

crexxrag_add_test(NAME durable_backlog_provider_configured_route
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-durable-backlog-provider-configured-route"
        -DCPRAG_CASES=valid -DCPRAG_CONFIGURED_ROUTE=ON
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DurableBacklogProvider.cmake")
set_tests_properties(durable_backlog_provider_configured_route PROPERTIES
    TIMEOUT 240 LABELS "maintenance;gemini;resolution;privacy;sqlite;zero-outbound")

crexxrag_add_test(NAME publication
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/publication_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-publication"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Publication.cmake")
set_tests_properties(publication PROPERTIES
    TIMEOUT 240 LABELS "publication;concurrency;atomic;sqlite;zero-outbound")

crexxrag_add_test(NAME native_publication
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-publication"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativePublication.cmake")
set_tests_properties(native_publication PROPERTIES
    TIMEOUT 240 LABELS "publication;concurrency;atomic;gemini;sqlite;zero-outbound")

crexxrag_add_test(NAME embedding_recovery
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-embedding-recovery"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/EmbeddingRecovery.cmake")
set_tests_properties(embedding_recovery PROPERTIES
    TIMEOUT 240 LABELS "recovery;concurrency;accounting;gemini;sqlite;zero-outbound")

crexxrag_add_test(NAME test2_completion
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-test2-completion"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Test2Completion.cmake")
set_tests_properties(test2_completion PROPERTIES TIMEOUT 240 LABELS "provider;worker;publication;recovery;zero-outbound")

crexxrag_add_test(NAME embedding_publication
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-embedding-publication"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/EmbeddingPublication.cmake")
set_tests_properties(embedding_publication PROPERTIES
    TIMEOUT 120 LABELS "recovery;publication;accounting;gemini;sqlite;zero-outbound")

crexxrag_add_test(NAME embedding_exhaustion
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-embedding-exhaustion"
        "-DCPRAG_EXHAUSTION=ON"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/EmbeddingRecovery.cmake")
set_tests_properties(embedding_exhaustion PROPERTIES
    TIMEOUT 240 LABELS "recovery;concurrency;accounting;gemini;sqlite;zero-outbound")

crexxrag_add_test(NAME native_receipt_failure
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-receipt-failure"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeReceiptFailure.cmake")
set_tests_properties(native_receipt_failure PROPERTIES
    TIMEOUT 240 LABELS "recovery;concurrency;accounting;gemini;sqlite;zero-outbound")

crexxrag_add_test(NAME native_receipts
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-receipts"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeReceipts.cmake")
set_tests_properties(native_receipts PROPERTIES
    TIMEOUT 240 LABELS "recovery;concurrency;accounting;gemini;sqlite;zero-outbound")

crexxrag_add_test(NAME native_interruption
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-interruption"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeInterruption.cmake")
set_tests_properties(native_interruption PROPERTIES
    TIMEOUT 180 LABELS "native;recovery;cancellation;accounting;publication;sqlite;zero-outbound")

# Agreed simple restart behavior, tested before its implementation.
foreach(case IN ITEMS control stdin_eof stdout_closed stderr_closed term hup int kill)
crexxrag_add_test(NAME regression_controller_closure_${case}
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_CASE=${case}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/controller-closure.py"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-controller-closure"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ControllerClosure.cmake")
set_tests_properties(regression_controller_closure_${case} PROPERTIES
    TIMEOUT 120 LABELS "regression;native;recovery;zero-outbound")

endforeach()

foreach(case IN ITEMS controller_loss restart_live controller_term)
    crexxrag_add_test(NAME regression_${case}
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
            "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
            "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-${case}"
            "-DCPRAG_CASES=${case}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeInterruption.cmake")
    set_tests_properties(regression_${case} PROPERTIES
        TIMEOUT 120 LABELS "regression;native;recovery;zero-outbound")
endforeach()

# Keep repaired defects as ordinary regressions in the full workflow; no
# WILL_FAIL property can turn a setup error or crash into a passing result.
foreach(case IN ITEMS pages page_max large_job plan_detail retry closed_retry reset_retries retrieval retrieval_unicode)
    crexxrag_add_test(NAME regression_${case}
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
            "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-regression-${case}"
            "-DCPRAG_CASE=${case}"
            "-DCPRAG_CORPUS=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/retrieval/regression.json"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PublicRegression.cmake")
    set_tests_properties(regression_${case} PROPERTIES
        TIMEOUT 180 LABELS "regression;native;public-contract;zero-outbound")
endforeach()
set_property(TEST regression_page_max regression_large_job APPEND PROPERTY LABELS "RAG-UX-02")
set_property(TEST regression_closed_retry APPEND PROPERTY LABELS "RAG-OPS-002")
set_property(TEST regression_retrieval_unicode APPEND PROPERTY LABELS "RAG-QE-06")

crexxrag_add_test(NAME regression_ingest_capacity
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/admission_regression.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-regression-ingest-capacity"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/AdmissionRegression.cmake")
set_tests_properties(regression_ingest_capacity PROPERTIES
    TIMEOUT 180 LABELS "regression;RAG-OPS-004;worker;accounting;zero-outbound")

crexxrag_add_test(NAME native_admission
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-admission"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeAdmission.cmake")
set_tests_properties(native_admission PROPERTIES
    TIMEOUT 180 LABELS "regression;native;worker;accounting;zero-outbound")

crexxrag_add_test(NAME regression_lifecycle
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/lifecycle_regression.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-regression-lifecycle"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/LifecycleRegression.cmake")
set_tests_properties(regression_lifecycle PROPERTIES
    TIMEOUT 180 LABELS "regression;RAG-OPS-002;worker;accounting;zero-outbound")

crexxrag_add_test(NAME native_lifecycle_holds
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-lifecycle-holds"
        "-DCPRAG_HOLDS=1"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeLifecycle.cmake")
set_tests_properties(native_lifecycle_holds PROPERTIES
    TIMEOUT 180 LABELS "native;recovery;lifecycle;regression;loopback")

crexxrag_add_test(NAME native_continuation
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-continuation"
        -DCPRAG_CONTINUATION=ON
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeLifecycle.cmake")
set_tests_properties(native_continuation PROPERTIES TIMEOUT 180 LABELS "native;recovery;continuation;regression;loopback")

crexxrag_add_test(NAME native_legacy_retry_ceiling
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-legacy-retry"
        -DCPRAG_LEGACY_CEILING=ON
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeLifecycle.cmake")
set_tests_properties(native_legacy_retry_ceiling PROPERTIES TIMEOUT 180 LABELS "native;recovery;lifecycle;regression;loopback")

crexxrag_add_test(NAME native_continuation_holds
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-continuation-holds"
        -DCPRAG_CONTINUATION=ON -DCPRAG_HOLDS=ON
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeLifecycle.cmake")
set_tests_properties(native_continuation_holds PROPERTIES TIMEOUT 180 LABELS "native;recovery;continuation;regression;loopback")

crexxrag_add_test(NAME native_embedding_retry_policy
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-embedding-retry-policy"
        -DCPRAG_LEGACY_CEILING=ON -DCPRAG_EMBEDDING_POLICY=ON
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeLifecycle.cmake")
set_tests_properties(native_embedding_retry_policy PROPERTIES TIMEOUT 180 LABELS "native;recovery;lifecycle;regression;loopback")

crexxrag_add_test(NAME native_retry_reset
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-ingestion.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-retry-reset"
        -DCPRAG_LEGACY_CEILING=ON -DCPRAG_RESET_RETRIES=ON
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeLifecycle.cmake")
set_tests_properties(native_retry_reset PROPERTIES TIMEOUT 180 LABELS "native;recovery;lifecycle;regression;loopback")

crexxrag_add_test(NAME regression_sql_performance
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/sql_performance_scenario.crexx"
        "-DCPRAG_MARKER=SQL_PERFORMANCE_OK"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-sql-performance"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ProjectContract.cmake")
set_tests_properties(regression_sql_performance PROPERTIES TIMEOUT 150 LABELS "regression;sqlite;zero-outbound")

crexxrag_add_test(NAME release_packaging COMMAND "${Python3_EXECUTABLE}"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/release/test_packaging.py")
set_tests_properties(release_packaging PROPERTIES TIMEOUT 30 LABELS "release;packaging;zero-outbound")

crexxrag_add_test(NAME qa_execution COMMAND "${Python3_EXECUTABLE}"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/qa/test_execution.py")
set_tests_properties(qa_execution PROPERTIES TIMEOUT 30 LABELS "harness;isolation;zero-outbound")
crexxrag_add_test(NAME qa_fixture_lifetime COMMAND "${Python3_EXECUTABLE}"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/qa/fixture_lifetime.py" "$<TARGET_FILE:crexxrag_provider_fixture>")
set_tests_properties(qa_fixture_lifetime PROPERTIES TIMEOUT 30 LABELS "harness;timing;loopback;zero-outbound")
crexxrag_add_test(NAME observability_providers
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_CODEX_FIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-app-server-fixture.sh"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/codex-application.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-observability-providers"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ObservabilityProviders.cmake")
set_tests_properties(observability_providers PROPERTIES TIMEOUT 90 LABELS "provider;codex;inspection;zero-outbound")
crexxrag_add_test(NAME native_vector
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
        "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_PLUGIN_DIR=${CREXXRAG_SQLITE_PROVIDER_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/native_vector_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-ann-methodology"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/NativeVector.cmake")
set_tests_properties(native_vector PROPERTIES
    TIMEOUT 240 LABELS "ann;retrieval;recall;tamper;rxvector;sqlite")

crexxrag_add_test(NAME vector_provider
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_CREXX=${CREXX_EXECUTABLE}"
        "-DCPRAG_BIN=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_SCENARIO=${CREXXRAG_APP_DIR}/tests/vector_provider_scenario.crexx"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-vector-provider"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/VectorProvider.cmake")
set_tests_properties(vector_provider PROPERTIES TIMEOUT 60 LABELS "vector;rxpa;zero-outbound")
crexxrag_add_test(NAME native_vector_public
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${CREXXRAG_NATIVE_APPLICATION}"
        "-DCPRAG_LOOPBACK=${CREXXRAG_PROVIDER_FIXTURE}"
        "-DCPRAG_CONFIG_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/providers/gemini-query.conf.in"
        "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/test-native-vector-public"
        -DCPRAG_NATIVE_VECTOR_ONLY=ON
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeminiQuery.cmake")
set_tests_properties(native_vector_public PROPERTIES
    TIMEOUT 300 LABELS "gemini;query;embedding;hybrid;answer;citation;privacy;budget")

include("${CMAKE_CURRENT_LIST_DIR}/CrexxRagTestSuites.cmake")
