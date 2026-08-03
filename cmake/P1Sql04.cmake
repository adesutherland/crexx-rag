foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_DIR CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(import_path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}" "source=${CPRAG_SOURCE}\n")

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/program-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${import_path}"
            -o "${program}" "${CPRAG_SOURCE}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${mode} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${mode} assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}"
        "${mode} compile:\n${compile_out}${compile_err}"
        "${mode} assemble:\n${assemble_out}${assemble_err}\n")
endforeach()

set(database "${CPRAG_WORK_DIR}/readonly.sqlite")
execute_process(
    COMMAND "${CPRAG_RXVME}" -l "${import_path}"
        "${CPRAG_WORK_DIR}/program-opt" rx_sqlite_boundary library
        -a setup "${database}"
    OUTPUT_VARIABLE setup_out ERROR_VARIABLE setup_err RESULT_VARIABLE setup_result)
if(NOT setup_result EQUAL 0 OR NOT setup_out MATCHES "P1_SQL_04_SETUP_OK")
    message(FATAL_ERROR "Read-only seed failed:\n${setup_out}\n${setup_err}")
endif()
file(SHA256 "${database}" baseline_hash)
file(SIZE "${database}" baseline_size)
file(TIMESTAMP "${database}" baseline_mtime UTC)
file(GLOB baseline_files "${database}*")
list(SORT baseline_files)
file(APPEND "${report}"
    "setup:\n${setup_out}${setup_err}"
    "baseline hash=${baseline_hash} size=${baseline_size} mtime=${baseline_mtime} files=${baseline_files}\n")

foreach(mode IN ITEMS noopt opt)
    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(
            COMMAND "${runtime}" -l "${import_path}"
                "${CPRAG_WORK_DIR}/program-${mode}" rx_sqlite_boundary library
                -a readonly "${database}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err RESULT_VARIABLE vm_result)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "P1_SQL_04_OK")
            message(FATAL_ERROR
                "${mode}/${runtime_name} read-only case failed:\n${vm_out}\n${vm_err}")
        endif()
        file(SHA256 "${database}" current_hash)
        file(SIZE "${database}" current_size)
        file(TIMESTAMP "${database}" current_mtime UTC)
        file(GLOB current_files "${database}*")
        list(SORT current_files)
        if(NOT current_hash STREQUAL baseline_hash
                OR NOT current_size EQUAL baseline_size
                OR NOT current_mtime STREQUAL baseline_mtime
                OR NOT current_files STREQUAL baseline_files)
            message(FATAL_ERROR
                "${mode}/${runtime_name} read-only open changed the database or sidecars")
        endif()
        file(APPEND "${report}"
            "${mode}/${runtime_name}:\n${vm_out}${vm_err}"
            "hash=${current_hash} size=${current_size} mtime=${current_mtime} files=${current_files}\n")
    endforeach()
endforeach()

set(missing "${CPRAG_WORK_DIR}/must-not-exist.sqlite")
foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    execute_process(
        COMMAND "${runtime}" -l "${import_path}"
            "${CPRAG_WORK_DIR}/program-opt" rx_sqlite_boundary library
            -a missing "${missing}"
        OUTPUT_VARIABLE missing_out ERROR_VARIABLE missing_err
        RESULT_VARIABLE missing_result)
    if(NOT missing_result EQUAL 0
            OR NOT missing_out MATCHES "P1_SQL_04_MISSING_OK"
            OR EXISTS "${missing}")
        message(FATAL_ERROR
            "${runtime_name} missing read-only case failed:\n${missing_out}\n${missing_err}")
    endif()
    file(APPEND "${report}"
        "${runtime_name} missing:\n${missing_out}${missing_err}\n")
endforeach()

message(STATUS
    "P1-SQL-04 passed four-cell read-only zero-write and missing-path checks")
