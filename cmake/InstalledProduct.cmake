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
execute_process(COMMAND "${CMAKE_COMMAND}" --install "${CPRAG_BUILD_DIR}"
        --prefix "${prefix}"
    RESULT_VARIABLE install_result OUTPUT_VARIABLE install_out
    ERROR_VARIABLE install_err TIMEOUT 120)
if(NOT install_result EQUAL 0)
    message(FATAL_ERROR "scratch-prefix install failed:\n${install_out}${install_err}")
endif()

set(application "${prefix}/bin/crexxrag")
set(tutorial "${prefix}/share/crexxrag/tutorial")
set(skills "${prefix}/share/crexxrag/skills")
foreach(required_path
        "${application}"
        "${tutorial}/crexxrag.conf"
        "${tutorial}/crexxrag-codex-local.conf"
        "${tutorial}/architecture.glossary.tsv"
        "${tutorial}/source-docs/architecture.txt"
        "${skills}/crexxrag-maintain/SKILL.md"
        "${skills}/crexxrag-maintain/manifest.json")
    if(NOT EXISTS "${required_path}")
        message(FATAL_ERROR "installed product is missing ${required_path}")
    endif()
endforeach()
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

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "test=installed-product\nprefix=${prefix}\n"
    "doctor=passed\nprovider_smoke=passed\ningest=passed\nmaintenance=passed\nquery=passed\n"
    "skill=crexxrag-maintain\nobsolete_skill=absent\n"
    "${doctor_out}${doctor_err}${smoke_out}${smoke_err}${maintenance_out}${maintenance_err}")
message(STATUS "Scratch-prefix installed crexxrag passed doctor, Gemini provider smoke, init, ingest, maintain, hybrid query, tutorial and skill audit")
