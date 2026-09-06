foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_MODEL CPRAG_CONFIG
        CPRAG_FILE CPRAG_CONFIG_FILE_MODULE CPRAG_GLOSSARY_MODULE CPRAG_PROFILE_MODULE
        CPRAG_PROFILE_FILE_MODULE CPRAG_SCENARIO CPRAG_FIXTURE
        CPRAG_SUBSCRIPTION_FIXTURE CPRAG_APPLICATION CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/result.txt")
file(WRITE "${report}"
    "test=configuration-contract\nformat=crexx-rag.config/3\nformat_1_2_compatibility=verified\nprovider_calls=0\ncredential_reads=0\n")
file(WRITE "${CPRAG_WORK_DIR}/glossary-valid.tsv"
    "format\tcrexx-rag.glossary/1\nconcept\tBillingService\tapplication-component\tBilling Service\nconcept\tCustomerDatabase\tdata-store\tCustomer DB\nexclude\tDeprecatedSystem\n")
file(WRITE "${CPRAG_WORK_DIR}/glossary-duplicate.tsv"
    "format\tcrexx-rag.glossary/1\nconcept\tBillingService\tapplication-component\nconcept\tBillingService\tapplication-component\n")
file(WRITE "${CPRAG_WORK_DIR}/glossary-alias.tsv"
    "format\tcrexx-rag.glossary/1\nconcept\tBillingService\tapplication-component\tShared Alias\nconcept\tCustomerDatabase\tdata-store\tShared Alias\n")
file(WRITE "${CPRAG_WORK_DIR}/glossary-exclusion.tsv"
    "format\tcrexx-rag.glossary/1\nconcept\tBillingService\tapplication-component\tBilling Service\nexclude\tBilling Service\n")
file(WRITE "${CPRAG_WORK_DIR}/glossary-missing-format.tsv" "# no data records\n")
file(WRITE "${CPRAG_WORK_DIR}/profile-valid.tsv"
    "format\tcrexx-rag.profile/1\nprofile\tscottish-history-profile\t1\nconcept\tperson\nconcept\tplace\nrelationship\trelated-to\trelated-to\tfalse\nchunk\t1400\t180\tplain,markdown\nweight\tlexical\t1000000\nprompt\tadvisory\t1\tscottish-history-advisory\nprompt\textractor\t1\tscottish-history-extractor\nvalidator\tdirection-required\n")
file(WRITE "${CPRAG_WORK_DIR}/profile-mismatch.tsv"
    "format\tcrexx-rag.profile/1\nprofile\twrong-profile\t1\nconcept\tperson\nrelationship\trelated-to\trelated-to\tfalse\nchunk\t1400\t180\tplain\nweight\tlexical\t1000000\nprompt\tadvisory\t1\twrong-advisory\nprompt\textractor\t1\twrong-extractor\nvalidator\tdirection-required\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${compile_out}${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${assemble_out}${assemble_err}")
    endif()
endfunction()

set(secret_marker "CONFIG_SECRET_MUST_NOT_APPEAR_8A21")
foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_MODEL}" "${CPRAG_WORK_DIR}/ragmodel"
        "${base_import}" "${mode_flag}" "${mode} ragmodel")
    compile_crexx("${CPRAG_CONFIG}" "${CPRAG_WORK_DIR}/ragconfig"
        "${program_import}" "${mode_flag}" "${mode} ragconfig")
    compile_crexx("${CPRAG_FILE}" "${CPRAG_WORK_DIR}/ragfile"
        "${program_import}" "${mode_flag}" "${mode} ragfile")
    compile_crexx("${CPRAG_CONFIG_FILE_MODULE}" "${CPRAG_WORK_DIR}/ragconfigfile"
        "${program_import}" "${mode_flag}" "${mode} ragconfigfile")
    compile_crexx("${CPRAG_GLOSSARY_MODULE}" "${CPRAG_WORK_DIR}/ragglossary"
        "${program_import}" "${mode_flag}" "${mode} ragglossary")
    compile_crexx("${CPRAG_PROFILE_MODULE}" "${CPRAG_WORK_DIR}/ragprofile"
        "${program_import}" "${mode_flag}" "${mode} ragprofile")
    compile_crexx("${CPRAG_PROFILE_FILE_MODULE}" "${CPRAG_WORK_DIR}/ragprofilefile"
        "${program_import}" "${mode_flag}" "${mode} ragprofilefile")
    compile_crexx("${CPRAG_SCENARIO}" "${CPRAG_WORK_DIR}/scenario-${mode}"
        "${program_import}" "${mode_flag}" "${mode} config scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        execute_process(COMMAND "${CMAKE_COMMAND}" -E env
            "GEMINI_API_KEY=${secret_marker}"
            "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/scenario-${mode}"
            ragconfigfile ragconfig ragmodel ragfile ragglossary ragprofilefile ragprofile rx_hash rx_system library
            -a "${cell}" "${CPRAG_FIXTURE}"
                "${CPRAG_WORK_DIR}/glossary-valid.tsv"
                "${CPRAG_WORK_DIR}/glossary-duplicate.tsv"
                "${CPRAG_WORK_DIR}/glossary-alias.tsv"
                "${CPRAG_WORK_DIR}/glossary-exclusion.tsv"
                "${CPRAG_WORK_DIR}/glossary-missing-format.tsv"
                "${CPRAG_WORK_DIR}/profile-valid.tsv"
                "${CPRAG_WORK_DIR}/profile-mismatch.tsv"
            RESULT_VARIABLE vm_result OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            TIMEOUT 30)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "CONFIG_CONTRACT_OK cell=${cell} formats=1,2,3 identities=split settings=typed-and-bounded providers=2 gemini=2 env_refs=2 literal_secrets=0 executable_modules=0 glossary=validated profile=validated provider_calls=0")
            message(FATAL_ERROR "${cell} config scenario failed:\n${vm_out}${vm_err}")
        endif()
        if(vm_out MATCHES "${secret_marker}" OR vm_err MATCHES "${secret_marker}")
            message(FATAL_ERROR "${cell} exposed a resolved credential")
        endif()
        file(APPEND "${report}" "${cell}: ${vm_out}${vm_err}")
    endforeach()
endforeach()

execute_process(COMMAND "${CMAKE_COMMAND}" -E env
    "GEMINI_API_KEY=${secret_marker}"
    "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a
    --config-file "${CPRAG_FIXTURE}"
    --profile generic-profile --format json doctor
    RESULT_VARIABLE cli_result OUTPUT_VARIABLE cli_out ERROR_VARIABLE cli_err
    TIMEOUT 30)
if(NOT cli_result EQUAL 0 OR NOT cli_out MATCHES
        "\"operation\":\"doctor\",\"status\":\"ok\"" OR
   NOT cli_out MATCHES "\"config_count\":1" OR
   NOT cli_out MATCHES "\"provider_id\":\"gemini-generate\"")
    message(FATAL_ERROR "linked CLI config-file smoke failed:\n${cli_out}${cli_err}")
endif()
if(cli_out MATCHES "${secret_marker}" OR cli_err MATCHES "${secret_marker}")
    message(FATAL_ERROR "linked CLI exposed a resolved credential")
endif()

execute_process(COMMAND "${CMAKE_COMMAND}" -E env
    "GEMINI_API_KEY=${secret_marker}"
    "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a
    --config-file "${CPRAG_FIXTURE}"
    --profile generic-profile --format json config explain
    RESULT_VARIABLE explain_result OUTPUT_VARIABLE explain_out ERROR_VARIABLE explain_err
    TIMEOUT 30)
string(JSON explain_evidence_ceiling ERROR_VARIABLE explain_evidence_error GET
    "${explain_out}" records 4 fields maximum_evidence_bytes)
string(JSON explain_maintenance_length ERROR_VARIABLE explain_maintenance_error LENGTH
    "${explain_out}" records 5 fields)
string(JSON explain_maintenance_batch ERROR_VARIABLE explain_maintenance_batch_error GET
    "${explain_out}" records 5 fields batch_items)
if(NOT explain_result EQUAL 0 OR
   NOT explain_evidence_error STREQUAL "NOTFOUND" OR
   NOT explain_evidence_ceiling STREQUAL "262144" OR
   NOT explain_maintenance_error STREQUAL "NOTFOUND" OR
   NOT explain_maintenance_length EQUAL 11 OR
   NOT explain_maintenance_batch_error STREQUAL "NOTFOUND" OR
   NOT explain_maintenance_batch STREQUAL "1000" OR
   NOT explain_out MATCHES "\"narrative_output_tokens\":4096")
    message(FATAL_ERROR
        "linked configuration explanation was not bounded and isolated:\n${explain_out}${explain_err}")
endif()

# A data profile is selected by id in ordinary configuration and loaded only
# from the corresponding bounded data file.  No executable module name is
# accepted from operator configuration.
file(READ "${CPRAG_FIXTURE}" profile_config_text)
string(REPLACE "profiles = generic-profile,it-architecture-profile"
    "profiles = scottish-history-profile"
    profile_config_text "${profile_config_text}")
string(APPEND profile_config_text
    "\nprofile.scottish-history-profile.file = ${CPRAG_WORK_DIR}/profile-valid.tsv\n")
set(profile_config "${CPRAG_WORK_DIR}/profile-config.conf")
file(WRITE "${profile_config}" "${profile_config_text}")
execute_process(COMMAND "${CMAKE_COMMAND}" -E env
    "GEMINI_API_KEY=${secret_marker}"
    "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a
    --config-file "${profile_config}"
    --profile scottish-history-profile --format json profile show
    RESULT_VARIABLE profile_cli_result
    OUTPUT_VARIABLE profile_cli_out ERROR_VARIABLE profile_cli_err
    TIMEOUT 30)
string(JSON profile_maximum_chunk ERROR_VARIABLE profile_maximum_chunk_error
    GET "${profile_cli_out}" records 0 fields maximum_chunk_characters)
string(JSON profile_overlap ERROR_VARIABLE profile_overlap_error
    GET "${profile_cli_out}" records 0 fields overlap_characters)
if(NOT profile_cli_result EQUAL 0 OR
   NOT profile_cli_out MATCHES "\"profile_id\":\"scottish-history-profile\"" OR
   NOT profile_cli_out MATCHES "\"valid\":true" OR
   NOT profile_maximum_chunk_error STREQUAL "NOTFOUND" OR
   NOT profile_overlap_error STREQUAL "NOTFOUND" OR
   NOT profile_maximum_chunk STREQUAL "1400" OR
   NOT profile_overlap STREQUAL "180")
    message(FATAL_ERROR
        "linked data-defined profile smoke failed:\n${profile_cli_out}${profile_cli_err}")
endif()

# Configuration lifecycle is a public, zero-provider contract: operators can
# inspect split identities, review an operational-only plan, reject tampering,
# apply the exact plan, and retain the resulting state without editing cREXX.
set(lifecycle_library "${CPRAG_WORK_DIR}/lifecycle-library")
file(READ "${CPRAG_FIXTURE}" lifecycle_config_text)
string(REPLACE "worker.processes = 1" "worker.processes = 2"
    lifecycle_config_text "${lifecycle_config_text}")
set(lifecycle_config "${CPRAG_WORK_DIR}/operational-change.conf")
file(WRITE "${lifecycle_config}" "${lifecycle_config_text}")
set(lifecycle_cli "${CMAKE_COMMAND}" -E env
    "GEMINI_API_KEY=${secret_marker}"
    "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a)

execute_process(COMMAND ${lifecycle_cli}
    --config-file "${CPRAG_FIXTURE}" --profile generic-profile
    --library "${lifecycle_library}" --format json init
    RESULT_VARIABLE lifecycle_init_result
    OUTPUT_VARIABLE lifecycle_init_out ERROR_VARIABLE lifecycle_init_err
    TIMEOUT 30)
if(NOT lifecycle_init_result EQUAL 0 OR
   NOT lifecycle_init_out MATCHES "\"schema_version\":8")
    message(FATAL_ERROR
        "configuration lifecycle init failed:\n${lifecycle_init_out}${lifecycle_init_err}")
endif()

execute_process(COMMAND ${lifecycle_cli}
    --config-file "${CPRAG_FIXTURE}" --profile generic-profile
    --library "${lifecycle_library}" --format json config diff
    RESULT_VARIABLE identical_result
    OUTPUT_VARIABLE identical_out ERROR_VARIABLE identical_err
    TIMEOUT 30)
if(NOT identical_result EQUAL 0 OR
   NOT identical_out MATCHES "\"classification\":\"identical\"" OR
   NOT identical_out MATCHES "\"provider_calls\":0")
    message(FATAL_ERROR
        "identical configuration classification failed:\n${identical_out}${identical_err}")
endif()

execute_process(COMMAND ${lifecycle_cli}
    --config-file "${lifecycle_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json config diff
    RESULT_VARIABLE operational_result
    OUTPUT_VARIABLE operational_out ERROR_VARIABLE operational_err
    TIMEOUT 30)
if(NOT operational_result EQUAL 0 OR
   NOT operational_out MATCHES "\"classification\":\"operational\"" OR
   NOT operational_out MATCHES "\"active_jobs\":0")
    message(FATAL_ERROR
        "operational configuration classification failed:\n${operational_out}${operational_err}")
endif()

execute_process(COMMAND ${lifecycle_cli}
    --config-file "${lifecycle_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json --access plan
    config plan --reason "configuration lifecycle regression"
    RESULT_VARIABLE config_plan_result
    OUTPUT_VARIABLE config_plan_out ERROR_VARIABLE config_plan_err
    TIMEOUT 30)
string(JSON config_plan ERROR_VARIABLE config_plan_json_error GET
    "${config_plan_out}" records 0 fields canonical_plan)
string(JSON config_digest ERROR_VARIABLE config_digest_json_error GET
    "${config_plan_out}" records 0 fields digest)
if(NOT config_plan_result EQUAL 0 OR config_plan_json_error OR
   config_digest_json_error OR NOT config_plan_out MATCHES
    "\"schema_version\":\"crexx-rag.reconfigure-plan/1\"")
    message(FATAL_ERROR
        "configuration plan failed:\n${config_plan_out}${config_plan_err}")
endif()

set(tampered_config_plan "${config_plan} ")
execute_process(COMMAND ${lifecycle_cli}
    --config-file "${lifecycle_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json --access admin
    config apply --plan-json "${tampered_config_plan}"
    --expect-digest "${config_digest}"
    RESULT_VARIABLE tampered_result
    OUTPUT_VARIABLE tampered_out ERROR_VARIABLE tampered_err
    TIMEOUT 30)
if(NOT tampered_result EQUAL 6 OR NOT tampered_out MATCHES
    "reviewed configuration plan or digest is invalid")
    message(FATAL_ERROR
        "tampered configuration plan was not rejected:\n${tampered_out}${tampered_err}")
endif()

execute_process(COMMAND ${lifecycle_cli}
    --config-file "${lifecycle_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json --access admin
    config apply --plan-json "${config_plan}"
    --expect-digest "${config_digest}"
    RESULT_VARIABLE config_apply_result
    OUTPUT_VARIABLE config_apply_out ERROR_VARIABLE config_apply_err
    TIMEOUT 30)
if(NOT config_apply_result EQUAL 0 OR
   NOT config_apply_out MATCHES "\"operation\":\"config.apply\",\"status\":\"ok\"" OR
   NOT config_apply_out MATCHES "\"classification\":\"operational\"")
    message(FATAL_ERROR
        "reviewed configuration apply failed:\n${config_apply_out}${config_apply_err}")
endif()

execute_process(COMMAND ${lifecycle_cli}
    --config-file "${lifecycle_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json config diff
    RESULT_VARIABLE applied_diff_result
    OUTPUT_VARIABLE applied_diff_out ERROR_VARIABLE applied_diff_err
    TIMEOUT 30)
if(NOT applied_diff_result EQUAL 0 OR
   NOT applied_diff_out MATCHES "\"classification\":\"identical\"")
    message(FATAL_ERROR
        "applied configuration did not become current:\n${applied_diff_out}${applied_diff_err}")
endif()

string(REPLACE "gemini-3.5-flash-lite" "gemini-semantic-change"
    semantic_config_text "${lifecycle_config_text}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/semantic-source")
file(WRITE "${CPRAG_WORK_DIR}/semantic-source/evidence.txt"
    "BillingService depends on CustomerDatabase.\n")
string(REPLACE "source.architecture-docs.root = ./source-docs"
    "source.architecture-docs.root = ${CPRAG_WORK_DIR}/semantic-source"
    semantic_config_text "${semantic_config_text}")
set(semantic_config "${CPRAG_WORK_DIR}/semantic-change.conf")
file(WRITE "${semantic_config}" "${semantic_config_text}")
execute_process(COMMAND ${lifecycle_cli}
    --config-file "${semantic_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json config diff
    RESULT_VARIABLE semantic_diff_result
    OUTPUT_VARIABLE semantic_diff_out ERROR_VARIABLE semantic_diff_err
    TIMEOUT 30)
if(NOT semantic_diff_result EQUAL 0 OR
   NOT semantic_diff_out MATCHES "\"classification\":\"semantic\"")
    message(FATAL_ERROR
        "semantic configuration classification failed:\n${semantic_diff_out}${semantic_diff_err}")
endif()
execute_process(COMMAND ${lifecycle_cli}
    --config-file "${semantic_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json --access plan
    config plan --reason "semantic change rejection regression"
    RESULT_VARIABLE semantic_plan_result
    OUTPUT_VARIABLE semantic_plan_out ERROR_VARIABLE semantic_plan_err
    TIMEOUT 30)
string(JSON semantic_plan ERROR_VARIABLE semantic_plan_json_error GET
    "${semantic_plan_out}" records 0 fields canonical_plan)
string(JSON semantic_digest ERROR_VARIABLE semantic_digest_json_error GET
    "${semantic_plan_out}" records 0 fields digest)
if(NOT semantic_plan_result EQUAL 0 OR semantic_plan_json_error OR
   semantic_digest_json_error)
    message(FATAL_ERROR
        "semantic configuration plan failed:\n${semantic_plan_out}${semantic_plan_err}")
endif()
execute_process(COMMAND ${lifecycle_cli}
    --config-file "${semantic_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json --access admin
    config apply --plan-json "${semantic_plan}"
    --expect-digest "${semantic_digest}"
    RESULT_VARIABLE semantic_apply_result
    OUTPUT_VARIABLE semantic_apply_out ERROR_VARIABLE semantic_apply_err
    TIMEOUT 30)
if(NOT semantic_apply_result EQUAL 6 OR NOT semantic_apply_out MATCHES
    "semantic configuration changes require a new ingestion generation")
    message(FATAL_ERROR
        "semantic configuration apply was not rejected:\n${semantic_apply_out}${semantic_apply_err}")
endif()
execute_process(COMMAND ${lifecycle_cli}
    --config-file "${semantic_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json --access plan
    ingest plan --source-set architecture-docs
    RESULT_VARIABLE semantic_ingest_plan_result
    OUTPUT_VARIABLE semantic_ingest_plan_out ERROR_VARIABLE semantic_ingest_plan_err
    TIMEOUT 30)
string(JSON semantic_ingest_plan ERROR_VARIABLE semantic_ingest_plan_json_error
    GET "${semantic_ingest_plan_out}" records 0 fields canonical_plan)
string(JSON semantic_ingest_digest ERROR_VARIABLE semantic_ingest_digest_json_error
    GET "${semantic_ingest_plan_out}" records 0 fields digest)
if(NOT semantic_ingest_plan_result EQUAL 0 OR
   semantic_ingest_plan_json_error OR semantic_ingest_digest_json_error OR
   NOT semantic_ingest_plan_out MATCHES "\"observations\":1")
    message(FATAL_ERROR
        "semantic ingestion planning failed:\n${semantic_ingest_plan_out}${semantic_ingest_plan_err}")
endif()
execute_process(COMMAND ${lifecycle_cli}
    --config-file "${semantic_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json --access ingest
    ingest apply --plan-json "${semantic_ingest_plan}"
    --expect-digest "${semantic_ingest_digest}"
    RESULT_VARIABLE semantic_ingest_apply_result
    OUTPUT_VARIABLE semantic_ingest_apply_out ERROR_VARIABLE semantic_ingest_apply_err
    TIMEOUT 30)
if(NOT semantic_ingest_apply_result EQUAL 0 OR
   NOT semantic_ingest_apply_out MATCHES "\"disposition\":\"published\"" OR
   NOT semantic_ingest_apply_out MATCHES "\"generation\":2" OR
   NOT semantic_ingest_apply_out MATCHES "\"items_queued\":2")
    message(FATAL_ERROR
        "semantic ingestion apply failed:\n${semantic_ingest_apply_out}${semantic_ingest_apply_err}")
endif()
execute_process(COMMAND ${lifecycle_cli}
    --config-file "${semantic_config}" --profile generic-profile
    --library "${lifecycle_library}" --format json config diff
    RESULT_VARIABLE semantic_current_result
    OUTPUT_VARIABLE semantic_current_out ERROR_VARIABLE semantic_current_err
    TIMEOUT 30)
if(NOT semantic_current_result EQUAL 0 OR
   NOT semantic_current_out MATCHES "\"classification\":\"identical\"" OR
   NOT semantic_current_out MATCHES "\"active_jobs\":1")
    message(FATAL_ERROR
        "semantic ingestion did not publish the target configuration:\n${semantic_current_out}${semantic_current_err}")
endif()
if(lifecycle_init_out MATCHES "${secret_marker}" OR
   identical_out MATCHES "${secret_marker}" OR
   operational_out MATCHES "${secret_marker}" OR
   config_plan_out MATCHES "${secret_marker}" OR
   config_apply_out MATCHES "${secret_marker}" OR
   applied_diff_out MATCHES "${secret_marker}" OR
   semantic_diff_out MATCHES "${secret_marker}" OR
   semantic_plan_out MATCHES "${secret_marker}" OR
   semantic_apply_out MATCHES "${secret_marker}" OR
   semantic_ingest_plan_out MATCHES "${secret_marker}" OR
   semantic_ingest_apply_out MATCHES "${secret_marker}" OR
   semantic_current_out MATCHES "${secret_marker}")
    message(FATAL_ERROR "configuration lifecycle output exposed a resolved credential")
endif()

execute_process(COMMAND "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a
    --config-file "${CPRAG_SUBSCRIPTION_FIXTURE}"
    --format json provider list
    RESULT_VARIABLE subscription_result
    OUTPUT_VARIABLE subscription_out ERROR_VARIABLE subscription_err
    TIMEOUT 30)
if(NOT subscription_result EQUAL 0 OR NOT subscription_out MATCHES
        "\"provider_id\":\"codex-extract\"" OR
   NOT subscription_out MATCHES "\"kind\":\"codex\"" OR
   NOT subscription_out MATCHES "\"charging_basis\":\"subscription-allowance\"" OR
   NOT subscription_out MATCHES "\"provider_id\":\"local-embed\"" OR
   NOT subscription_out MATCHES "\"kind\":\"openai-compatible\"" OR
   NOT subscription_out MATCHES "\"charging_basis\":\"local-compute\"")
    message(FATAL_ERROR
        "Codex/local tutorial configuration failed zero-call provider discovery:\n${subscription_out}${subscription_err}")
endif()

execute_process(COMMAND "${CPRAG_RXVME}" "${CPRAG_APPLICATION}" -a
    --config-file "${CPRAG_FIXTURE}" --config architecture-local
    --profile generic-profile --format json doctor
    RESULT_VARIABLE mismatch_result OUTPUT_VARIABLE mismatch_out ERROR_VARIABLE mismatch_err
    TIMEOUT 30)
if(NOT mismatch_result EQUAL 3 OR NOT mismatch_out MATCHES
        "--config does not match --config-file")
    message(FATAL_ERROR
        "linked CLI did not reject a mismatched config id:\n${mismatch_out}${mismatch_err}")
endif()

file(APPEND "${report}"
    "linked-cli:\n${cli_out}${cli_err}${subscription_out}${subscription_err}"
    "configuration-lifecycle:\n${lifecycle_init_out}${identical_out}${operational_out}${config_plan_out}${tampered_out}${config_apply_out}${applied_diff_out}${semantic_diff_out}${semantic_plan_out}${semantic_apply_out}${semantic_ingest_plan_out}${semantic_ingest_apply_out}${semantic_current_out}")
file(READ "${report}" retained)
if(retained MATCHES "${secret_marker}")
    message(FATAL_ERROR "retained config evidence contains a resolved credential")
endif()
message(STATUS
    "Configuration contract passed four compiler/VM cells, linked CLI discovery, and reviewed split-identity lifecycle")
