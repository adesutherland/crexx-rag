foreach(required_var CPRAG_RXVME CPRAG_RXBVM CPRAG_APPLICATION
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

get_filename_component(application_dir "${CPRAG_APPLICATION}" DIRECTORY)
set(requirements "${application_dir}/crexxrag.rxproviders")
if(NOT EXISTS "${requirements}")
    message(FATAL_ERROR "linked application provider requirements are missing")
endif()
file(READ "${requirements}" provider_requirements)
foreach(operation IN ITEMS sqliteopenmode sqliteprepare sqlitebindtext
        sqlitestep sqlitecolumntext sqlitefinalize sqliteclose)
    if(NOT provider_requirements MATCHES
            "required[\t ]+rx_sqlite_boundary[\t ]+sqlite_boundary\\.${operation}[\t ]")
        message(FATAL_ERROR
            "SQLite cREXX operation ${operation} is not mapped to rx_sqlite_boundary")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
foreach(runtime IN ITEMS "${CPRAG_RXVME}" "${CPRAG_RXBVM}")
    get_filename_component(runtime_name "${runtime}" NAME)
    set(library "${CPRAG_WORK_DIR}/library-${runtime_name}")
    execute_process(
        COMMAND "${runtime}" "${CPRAG_APPLICATION}" -a
            --library "${library}"
            --config architecture-local
            --profile generic-profile
            --access admin
            --format json
            library init
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
        RESULT_VARIABLE init_result
        OUTPUT_VARIABLE init_out
        ERROR_VARIABLE init_err)
    if(NOT init_result EQUAL 0 OR NOT init_out MATCHES
            "\"operation\":\"library.init\",\"status\":\"ok\"")
        message(FATAL_ERROR
            "${runtime_name} linked application init failed:\n${init_out}${init_err}")
    endif()
    execute_process(
        COMMAND "${runtime}" "${CPRAG_APPLICATION}" -a
            --library "${library}"
            --config architecture-local
            --profile generic-profile
            --access read
            --format json
            library status
        WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
        RESULT_VARIABLE status_result
        OUTPUT_VARIABLE status_out
        ERROR_VARIABLE status_err)
    if(NOT status_result EQUAL 0 OR NOT status_out MATCHES
            "\"operation\":\"library.status\",\"status\":\"ok\"")
        message(FATAL_ERROR
            "${runtime_name} linked application status failed:\n${status_out}${status_err}")
    endif()
endforeach()

message(STATUS
    "Linked cREXX application passed VM autoload and SQLite API mapping smoke")
