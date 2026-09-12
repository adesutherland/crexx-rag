foreach(required_var CPRAG_BUILD_DIR CPRAG_LOOPBACK CPRAG_PROVIDER_CONFIG_TEMPLATE
        CPRAG_MAINTENANCE_CONFIG_TEMPLATE
        CPRAG_PROPOSAL_FIXTURE CPRAG_PROVIDER_SMOKE_SCRIPT
        CPRAG_MAINTENANCE_SCRIPT CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(prefix "${CPRAG_WORK_DIR}/prefix")
set(legacy_sqlite_provider
    "${prefix}/libexec/crexxrag/providers/rx_sqlite_boundary.rxplugin")
file(MAKE_DIRECTORY "${prefix}/libexec/crexxrag/providers")
file(WRITE "${legacy_sqlite_provider}" "obsolete downstream provider fixture\n")
execute_process(COMMAND "${CMAKE_COMMAND}" --install "${CPRAG_BUILD_DIR}"
        --prefix "${prefix}"
    RESULT_VARIABLE install_result OUTPUT_VARIABLE install_out
    ERROR_VARIABLE install_err TIMEOUT 120)
if(NOT install_result EQUAL 0)
    message(FATAL_ERROR "scratch-prefix install failed:\n${install_out}${install_err}")
endif()
if(EXISTS "${legacy_sqlite_provider}")
    message(FATAL_ERROR
        "scratch-prefix upgrade retained the obsolete downstream SQLite provider")
endif()

set(application "${prefix}/bin/crexxrag")
set(tutorial "${prefix}/share/crexxrag/tutorial")
set(skills "${prefix}/share/crexxrag/skills")
set(operator_config "${prefix}/share/crexxrag/application/config")
foreach(required_path
        "${application}"
        "${operator_config}/editable-gemini.conf"
        "${operator_config}/profiles/generic.profile.tsv"
        "${operator_config}/profiles/it-architecture.profile.tsv"
        "${operator_config}/prompts/advisory.txt"
        "${operator_config}/prompts/extractor.txt"
        "${operator_config}/prompts/answerer.txt"
        "${tutorial}/crexxrag.conf"
        "${tutorial}/crexxrag-codex-local.conf"
        "${tutorial}/architecture.glossary.tsv"
        "${tutorial}/source-docs/architecture.txt"
        "${skills}/crexxrag-maintain/SKILL.md"
        "${skills}/crexxrag-maintain/manifest.json"
        "${skills}/crexxrag-resolve/SKILL.md"
        "${skills}/crexxrag-resolve/manifest.json")
    if(NOT EXISTS "${required_path}")
        message(FATAL_ERROR "installed product is missing ${required_path}")
    endif()
endforeach()
execute_process(COMMAND "${application}" --config-file "${operator_config}/editable-gemini.conf"
    --profile it-architecture-profile --format json config explain
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    RESULT_VARIABLE operator_result OUTPUT_VARIABLE operator_out ERROR_VARIABLE operator_err TIMEOUT 30)
if(NOT operator_result EQUAL 0 OR NOT operator_out MATCHES "\"origin\":\"data-file\"")
    message(FATAL_ERROR "installed editable configuration failed: ${operator_out}${operator_err}")
endif()
# Edit a copy of the installed policy/profile/prompt cohort, never the template.
file(COPY "${operator_config}/" DESTINATION "${CPRAG_WORK_DIR}/policy-work")
set(edit_policy "${CPRAG_WORK_DIR}/policy-work/editable-gemini.conf")
file(SHA256 "${operator_config}/editable-gemini.conf" template_hash)
execute_process(COMMAND "${application}" --config-file "${edit_policy}" --format json config show
    RESULT_VARIABLE show_result OUTPUT_VARIABLE show_out ERROR_VARIABLE show_err TIMEOUT 30)
string(JSON edit_hash GET "${show_out}" records 0 fields sha256)
string(JSON edit_valid GET "${show_out}" records 0 fields valid)
if(NOT show_result EQUAL 0 OR NOT edit_valid)
    message(FATAL_ERROR "Installed policy inspection failed: ${show_out}${show_err}")
endif()
execute_process(COMMAND "${application}" --config-file "${edit_policy}" --format json --access admin
    config set --key role.answerer.system_prompt --value "Installed policy objective." --expect-sha256 "${edit_hash}"
    RESULT_VARIABLE edit_result OUTPUT_VARIABLE edit_out ERROR_VARIABLE edit_err TIMEOUT 30)
if(NOT edit_result EQUAL 0)
    message(FATAL_ERROR "Installed policy edit failed: ${edit_out}${edit_err}")
endif()
execute_process(COMMAND "${application}" --config-file "${edit_policy}" --profile it-architecture-profile --format json
    config prompt --role answerer RESULT_VARIABLE prompt_result OUTPUT_VARIABLE prompt_out ERROR_VARIABLE prompt_err TIMEOUT 30)
string(JSON edit_objective GET "${prompt_out}" records 0 fields configured_objective)
file(SHA256 "${operator_config}/editable-gemini.conf" template_after)
if(NOT prompt_result EQUAL 0 OR NOT edit_objective STREQUAL "Installed policy objective." OR
   NOT template_hash STREQUAL template_after OR EXISTS "${CPRAG_WORK_DIR}/policy-work/library")
    message(FATAL_ERROR "Installed policy round trip failed: ${prompt_out}${prompt_err}")
endif()
if(EXISTS "${skills}/crexxrag-improve")
    message(FATAL_ERROR "obsolete crexxrag-improve skill was installed")
endif()
file(READ "${skills}/crexxrag-maintain/manifest.json" maintain_manifest)
if(NOT maintain_manifest MATCHES "\"rag_maintain_plan\"" OR
   NOT maintain_manifest MATCHES "\"rag_maintain_apply\"" OR
   maintain_manifest MATCHES "rag_improve")
    message(FATAL_ERROR "installed maintenance skill does not use the enduring tool vocabulary")
endif()

file(COPY "${tutorial}/" DESTINATION "${CPRAG_WORK_DIR}/tutorial-work")
execute_process(COMMAND "${CMAKE_COMMAND}" -E env
        "GEMINI_API_KEY=installed-doctor-symbolic-secret"
        "${application}" doctor
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}/tutorial-work"
    RESULT_VARIABLE doctor_result OUTPUT_VARIABLE doctor_out
    ERROR_VARIABLE doctor_err TIMEOUT 30)
if(NOT doctor_result EQUAL 0 OR
   NOT doctor_out MATCHES "OK: required installed capabilities" OR
   NOT doctor_out MATCHES "providers were not contacted" OR
   doctor_out MATCHES "installed-doctor-symbolic-secret" OR
   doctor_err MATCHES "installed-doctor-symbolic-secret")
    message(FATAL_ERROR "installed tutorial doctor failed or exposed a secret:\n${doctor_out}${doctor_err}")
endif()

execute_process(COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${application}"
        "-DCPRAG_LOOPBACK=${CPRAG_LOOPBACK}"
        "-DCPRAG_CONFIG_TEMPLATE=${CPRAG_PROVIDER_CONFIG_TEMPLATE}"
        "-DCPRAG_WORK_DIR=${CPRAG_WORK_DIR}/provider-smoke"
        -P "${CPRAG_PROVIDER_SMOKE_SCRIPT}"
    RESULT_VARIABLE smoke_result OUTPUT_VARIABLE smoke_out
    ERROR_VARIABLE smoke_err TIMEOUT 420)
if(NOT smoke_result EQUAL 0)
    message(FATAL_ERROR "installed provider smoke failed:\n${smoke_out}${smoke_err}")
endif()

execute_process(COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${application}"
        "-DCPRAG_LOOPBACK=${CPRAG_LOOPBACK}"
        "-DCPRAG_CONFIG_TEMPLATE=${CPRAG_MAINTENANCE_CONFIG_TEMPLATE}"
        "-DCPRAG_PROPOSAL_FIXTURE=${CPRAG_PROPOSAL_FIXTURE}"
        "-DCPRAG_WORK_DIR=${CPRAG_WORK_DIR}/maintenance"
        -P "${CPRAG_MAINTENANCE_SCRIPT}"
    RESULT_VARIABLE maintenance_result OUTPUT_VARIABLE maintenance_out
    ERROR_VARIABLE maintenance_err TIMEOUT 300)
if(NOT maintenance_result EQUAL 0)
    message(FATAL_ERROR "installed init/ingest/maintain/query workflow failed:\n${maintenance_out}${maintenance_err}")
endif()

# The same public boundaries must work from a scratch installation.
foreach(case IN ITEMS page_max plan_detail retrieval_unicode)
    execute_process(COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_NATIVE_APPLICATION=${application}"
        "-DCPRAG_CONFIG_TEMPLATE=${CPRAG_PROVIDER_CONFIG_TEMPLATE}"
        "-DCPRAG_CORPUS=${CMAKE_CURRENT_LIST_DIR}/../tests/fixtures/retrieval/regression.json"
        "-DCPRAG_CASE=${case}"
        "-DCPRAG_WORK_DIR=${CPRAG_WORK_DIR}/public-${case}"
        -P "${CMAKE_CURRENT_LIST_DIR}/PublicRegression.cmake"
        RESULT_VARIABLE public_result OUTPUT_VARIABLE public_out ERROR_VARIABLE public_err TIMEOUT 180)
    if(NOT public_result EQUAL 0)
        message(FATAL_ERROR "Installed ${case} failed: ${public_out}${public_err}")
    endif()
endforeach()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "test=installed-product\nprefix=${prefix}\n"
    "doctor=passed\npolicy_edit=passed\nprovider_smoke=passed\ningest=passed\nmaintenance=passed\nquery=passed\n"
    "skill=crexxrag-maintain\nobsolete_skill=absent\n"
    "obsolete_sqlite_provider=removed\n"
    "${doctor_out}${doctor_err}${smoke_out}${smoke_err}${maintenance_out}${maintenance_err}")
message(STATUS "Scratch-prefix installed crexxrag passed doctor, Gemini provider smoke, init, ingest, maintain, hybrid query, tutorial and skill audit")
