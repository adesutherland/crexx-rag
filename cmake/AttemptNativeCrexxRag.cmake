foreach(required_var CPRAG_CREXX_PACKAGE_PREFIX CPRAG_APPLICATION_DIR
        CPRAG_SQLITE_PROVIDER_ARCHIVE CPRAG_MAIN_SOURCE CPRAG_OUTPUT_DIR)
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

set(sdk_prefix "${CPRAG_OUTPUT_DIR}/sdk")
set(package_dir "${CPRAG_OUTPUT_DIR}/package")
file(REMOVE_RECURSE "${CPRAG_OUTPUT_DIR}")
file(MAKE_DIRECTORY "${sdk_prefix}" "${package_dir}")
file(COPY "${CPRAG_CREXX_PACKAGE_PREFIX}/" DESTINATION "${sdk_prefix}")
file(MAKE_DIRECTORY "${sdk_prefix}/bin/providers")
file(COPY "${CPRAG_SQLITE_PROVIDER_ARCHIVE}"
    DESTINATION "${sdk_prefix}/bin/providers")

# The application-local static RXPA archive deliberately leaves SQLite as an
# external generic system dependency. Add it only to this copied SDK's native
# link configuration; the user's installed CREXX prefix remains untouched.
file(APPEND "${sdk_prefix}/bin/crexx_native_libs_argv" "-lsqlite3\n")

configure_file("${CPRAG_MAIN_SOURCE}" "${package_dir}/crexx-rag.crexx" COPYONLY)
configure_file("${CPRAG_APPLICATION_DIR}/crexx_rag_cli.rxbin"
    "${package_dir}/crexx-rag.rxbin" COPYONLY)

set(native_libraries)
foreach(module IN LISTS provider_modules app_modules config_modules)
    list(APPEND native_libraries
        -l "${CPRAG_APPLICATION_DIR}/${module}.rxbin")
endforeach()
list(APPEND native_libraries -l "${sdk_prefix}/bin/rxfnsg.rxbin")

execute_process(
    COMMAND "${sdk_prefix}/bin/crexx"
        -native -nocompile -noexec -nocolor -verbose2
        --linkmap "${package_dir}/crexx-rag-native.map"
        ${native_libraries}
        crexx-rag.crexx
    WORKING_DIRECTORY "${package_dir}"
    RESULT_VARIABLE native_result
    OUTPUT_VARIABLE native_out
    ERROR_VARIABLE native_err)
file(WRITE "${package_dir}/native-build.txt"
    "${native_out}${native_err}")
if(NOT native_result EQUAL 0)
    message(FATAL_ERROR
        "CREXX native application packaging failed; inspect ${package_dir}/native-build.txt")
endif()

if(NOT EXISTS "${package_dir}/crexx-rag${CMAKE_EXECUTABLE_SUFFIX}")
    message(FATAL_ERROR "CREXX native packager returned success without an executable")
endif()

# `crexxrag` is the enduring human product name.  Keep the historical
# `crexx-rag` spelling beside it while native-v1 remains the executable oracle.
file(COPY_FILE
    "${package_dir}/crexx-rag${CMAKE_EXECUTABLE_SUFFIX}"
    "${package_dir}/crexxrag${CMAKE_EXECUTABLE_SUFFIX}"
    ONLY_IF_DIFFERENT)

execute_process(
    COMMAND "${package_dir}/crexxrag${CMAKE_EXECUTABLE_SUFFIX}"
        --library "${package_dir}/library"
        --config architecture-local
        --profile generic-profile
        --access admin
        --format json
        library init
    WORKING_DIRECTORY "${package_dir}"
    RESULT_VARIABLE run_result
    OUTPUT_VARIABLE run_out
    ERROR_VARIABLE run_err)
file(APPEND "${package_dir}/native-build.txt"
    "native run:\n${run_out}${run_err}")
if(NOT run_result EQUAL 0 OR NOT run_out MATCHES
        "\"operation\":\"library.init\",\"status\":\"ok\"")
    message(FATAL_ERROR
        "CREXX native application did not initialize a library; inspect ${package_dir}/native-build.txt")
endif()

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env
        "CREXX_RAG_SELF=${package_dir}/crexxrag${CMAKE_EXECUTABLE_SUFFIX}"
        "${package_dir}/crexxrag${CMAKE_EXECUTABLE_SUFFIX}"
        --library "${package_dir}/library"
        --config architecture-local --profile generic-profile
        --access control --format json worker start
        --count 2 --poll-ms 50 --max-polls 4
    WORKING_DIRECTORY "${package_dir}"
    RESULT_VARIABLE worker_result
    OUTPUT_VARIABLE worker_out
    ERROR_VARIABLE worker_err)
execute_process(
    COMMAND "${package_dir}/crexxrag${CMAKE_EXECUTABLE_SUFFIX}"
        --library "${package_dir}/library"
        --access read --format json worker list --stale-seconds 15
    WORKING_DIRECTORY "${package_dir}"
    RESULT_VARIABLE list_result
    OUTPUT_VARIABLE list_out
    ERROR_VARIABLE list_err)
file(APPEND "${package_dir}/native-build.txt"
    "native workers:\n${worker_out}${worker_err}${list_out}${list_err}")
if(NOT worker_result EQUAL 0 OR NOT list_result EQUAL 0 OR
   NOT worker_out MATCHES "\"workers_requested\":2" OR
   NOT worker_out MATCHES "\"workers_completed\":2" OR
   NOT worker_out MATCHES "\"workers_failed\":0" OR
   NOT list_out MATCHES "\"kind\":\"controller\"" OR
   NOT list_out MATCHES "\"kind\":\"worker\"")
    message(FATAL_ERROR
        "CREXX native application did not supervise two worker processes; inspect ${package_dir}/native-build.txt")
endif()

file(SHA256 "${package_dir}/crexxrag${CMAKE_EXECUTABLE_SUFFIX}" native_sha256)
message(STATUS
    "CREXX native application passed library init and two-worker supervision (${native_sha256})")
