foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXLINK CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_PROVIDER_DIR CPRAG_APP_DIR CPRAG_PROVIDER_DIR
        CPRAG_OUTPUT_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

set(app_modules
    ragmodel ragevidence ragjob ragconfig ragprofile ragregistry ragschema
    ragfile ragconfigfile ragstore ragbackup ragrepository ragcanonical ragplanning
    ragtrace ragcommand ragingest ragfolder ragclaims ragimprove ragwork ragquery
    ragembedding ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics ragapplicationprovider ragqueryprovider ragquerypolicy ragproduct)
set(provider_modules
    provider_contract provider_catalog provider_http industrial_provider codex_provider)
set(config_modules
    architecture_local_config generic_profile it_architecture_profile
    operator_registry)

file(REMOVE_RECURSE "${CPRAG_OUTPUT_DIR}")
file(MAKE_DIRECTORY "${CPRAG_OUTPUT_DIR}")
set(imports
    "${CPRAG_OUTPUT_DIR};${CPRAG_PLUGIN_PROVIDER_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")

function(compile_module source name)
    execute_process(
        COMMAND "${CPRAG_RXC}" -i "${imports}"
            -o "${CPRAG_OUTPUT_DIR}/${name}" "${source}"
        WORKING_DIRECTORY "${CPRAG_OUTPUT_DIR}"
        RESULT_VARIABLE compile_result
        OUTPUT_VARIABLE compile_out
        ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR
            "cREXX application module ${name} compile failed:\n${compile_out}${compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" -o "${CPRAG_OUTPUT_DIR}/${name}"
            "${CPRAG_OUTPUT_DIR}/${name}"
        WORKING_DIRECTORY "${CPRAG_OUTPUT_DIR}"
        RESULT_VARIABLE assemble_result
        OUTPUT_VARIABLE assemble_out
        ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR
            "cREXX application module ${name} assemble failed:\n${assemble_out}${assemble_err}")
    endif()
endfunction()

foreach(module IN LISTS provider_modules)
    compile_module("${CPRAG_PROVIDER_DIR}/${module}.crexx" "${module}")
endforeach()
foreach(module IN LISTS app_modules)
    compile_module("${CPRAG_APP_DIR}/${module}.crexx" "${module}")
endforeach()
compile_module("${CPRAG_APP_DIR}/config/architecture_local_config.crexx"
    architecture_local_config)
compile_module("${CPRAG_APP_DIR}/config/profiles/generic_profile.crexx"
    generic_profile)
compile_module("${CPRAG_APP_DIR}/config/profiles/it_architecture_profile.crexx"
    it_architecture_profile)
compile_module("${CPRAG_APP_DIR}/config/operator_registry.crexx"
    operator_registry)
compile_module("${CPRAG_APP_DIR}/surfaces/ragmcp.crexx" ragmcp)
compile_module("${CPRAG_APP_DIR}/surfaces/crexx_rag_cli.crexx" crexx_rag_cli)

set(link_inputs
    "${CPRAG_OUTPUT_DIR}/crexx_rag_cli.rxbin"
    "${CPRAG_OUTPUT_DIR}/ragmcp.rxbin")
foreach(module IN LISTS provider_modules)
    list(APPEND link_inputs "${CPRAG_OUTPUT_DIR}/${module}.rxbin")
endforeach()
foreach(module IN LISTS app_modules config_modules)
    list(APPEND link_inputs "${CPRAG_OUTPUT_DIR}/${module}.rxbin")
endforeach()
list(APPEND link_inputs
    "${CPRAG_CREXX_BIN_DIR}/rxfnsg.rxbin"
    "${CPRAG_CREXX_BIN_DIR}/classlib.rxbin"
    "${CPRAG_CREXX_BIN_DIR}/library.rxbin")

execute_process(
    COMMAND "${CPRAG_RXLINK}" -s -r crexx_rag_cli
        -m "${CPRAG_OUTPUT_DIR}/crexx-rag.map"
        -p "${CPRAG_OUTPUT_DIR}/crexx-rag.rxproviders"
        -o "${CPRAG_OUTPUT_DIR}/crexx-rag"
        ${link_inputs}
    WORKING_DIRECTORY "${CPRAG_OUTPUT_DIR}"
    RESULT_VARIABLE link_result
    OUTPUT_VARIABLE link_out
    ERROR_VARIABLE link_err)
if(NOT link_result EQUAL 0)
    message(FATAL_ERROR
        "cREXX application link failed:\n${link_out}${link_err}")
endif()

file(READ "${CPRAG_OUTPUT_DIR}/crexx-rag.rxproviders" provider_requirements)
if(NOT provider_requirements MATCHES "required[\t ]+rx_sqlite_boundary[\t ]")
    message(FATAL_ERROR
        "linked application did not declare the static SQLite provider")
endif()
if(provider_requirements MATCHES "[\t ]system\\.")
    message(FATAL_ERROR
        "linked application retained an unpackaged legacy system dependency")
endif()

# VM provider autoload resolves an application-local `providers` directory
# beside the linked image. Keep the generic SQLite mechanism with the image;
# installed CREXX providers remain discoverable from the runtime prefix.
file(MAKE_DIRECTORY "${CPRAG_OUTPUT_DIR}/providers")
file(COPY
    "${CPRAG_PLUGIN_PROVIDER_DIR}/rx_sqlite_boundary.rxplugin"
    DESTINATION "${CPRAG_OUTPUT_DIR}/providers")

file(SHA256 "${CPRAG_OUTPUT_DIR}/crexx-rag.rxbin" application_sha256)
file(WRITE "${CPRAG_OUTPUT_DIR}/artifact.txt"
    "artifact=crexx-rag.rxbin\n"
    "sha256=${application_sha256}\n"
    "root=crexx_rag_cli\n"
    "level=G\n"
    "hosted_calls=0\n")
message(STATUS
    "Built linked cREXX application ${CPRAG_OUTPUT_DIR}/crexx-rag.rxbin (${application_sha256})")
