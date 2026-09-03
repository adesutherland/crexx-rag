foreach(required_var CPRAG_CREXX_EXECUTABLE CPRAG_APPLICATION_PROJECT_RXBIN
        CPRAG_OUTPUT_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

set(package_dir "${CPRAG_OUTPUT_DIR}/package")
file(REMOVE_RECURSE "${CPRAG_OUTPUT_DIR}")
file(MAKE_DIRECTORY "${package_dir}")
configure_file("${CPRAG_APPLICATION_PROJECT_RXBIN}"
    "${package_dir}/crexxrag.rxbin" COPYONLY)

execute_process(
    COMMAND "${CPRAG_CREXX_EXECUTABLE}"
        -native -nocompile -noexec -nocolor -verbose2
        --linkmap "${package_dir}/crexxrag-native.map"
        crexxrag.crexx
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

if(NOT EXISTS "${package_dir}/crexxrag${CMAKE_EXECUTABLE_SUFFIX}")
    message(FATAL_ERROR "CREXX native packager returned success without an executable")
endif()

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
        "CREXXRAG_SELF=${package_dir}/crexxrag${CMAKE_EXECUTABLE_SUFFIX}"
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
