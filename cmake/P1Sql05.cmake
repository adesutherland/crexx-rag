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

foreach(mode IN ITEMS noopt opt)
    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(program "${CPRAG_WORK_DIR}/program-${mode}")
        set(database "${CPRAG_WORK_DIR}/${cell}.sqlite")
        set(ready "${CPRAG_WORK_DIR}/${cell}.ready")
        set(done "${CPRAG_WORK_DIR}/${cell}.done")
        set(writer_out "${CPRAG_WORK_DIR}/${cell}-writer.out")
        set(writer_err "${CPRAG_WORK_DIR}/${cell}-writer.err")
        set(writer_status "${CPRAG_WORK_DIR}/${cell}-writer.status")

        execute_process(
            COMMAND "${runtime}" -l "${import_path}" "${program}"
                rx_sqlite_boundary rx_system library -a setup "${database}"
            OUTPUT_VARIABLE setup_out ERROR_VARIABLE setup_err
            RESULT_VARIABLE setup_result)
        if(NOT setup_result EQUAL 0 OR NOT setup_out MATCHES "P1_SQL_05_SETUP_OK")
            message(FATAL_ERROR "${cell} setup failed:\n${setup_out}\n${setup_err}")
        endif()

        execute_process(
            COMMAND /bin/sh -c
                "( \"$1\" -l \"$2\" \"$3\" rx_sqlite_boundary rx_system library -a writer \"$4\" \"$5\" \"$6\"; printf '%s' $? >\"$9\" ) >\"$7\" 2>\"$8\" &"
                p1-sql-05 "${runtime}" "${import_path}" "${program}"
                "${database}" "${ready}" "${done}" "${writer_out}"
                "${writer_err}" "${writer_status}"
            RESULT_VARIABLE launch_result)
        if(NOT launch_result EQUAL 0)
            message(FATAL_ERROR "${cell} writer launch failed")
        endif()

        set(ready_seen FALSE)
        foreach(poll RANGE 1 200)
            if(EXISTS "${ready}")
                set(ready_seen TRUE)
                break()
            endif()
            execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
        endforeach()
        if(NOT ready_seen)
            message(FATAL_ERROR "${cell} writer did not reach its transaction boundary")
        endif()

        execute_process(
            COMMAND "${runtime}" -l "${import_path}" "${program}"
                rx_sqlite_boundary rx_system library -a reader "${database}"
            OUTPUT_VARIABLE reader_out ERROR_VARIABLE reader_err
            RESULT_VARIABLE reader_result)
        if(NOT reader_result EQUAL 0
                OR NOT reader_out MATCHES "P1_SQL_05_READER_OK before=1 during=1 after=2")
            message(FATAL_ERROR
                "${cell} reader failed (${reader_result}):\n${reader_out}\n${reader_err}")
        endif()

        set(status_seen FALSE)
        foreach(poll RANGE 1 200)
            if(EXISTS "${writer_status}")
                set(status_seen TRUE)
                break()
            endif()
            execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
        endforeach()
        if(NOT status_seen)
            message(FATAL_ERROR "${cell} writer did not exit")
        endif()
        file(READ "${writer_status}" writer_result)
        file(READ "${writer_out}" writer_output)
        file(READ "${writer_err}" writer_error)
        if(NOT writer_result STREQUAL "0"
                OR NOT writer_output MATCHES "P1_SQL_05_WRITER_OK"
                OR NOT EXISTS "${done}")
            message(FATAL_ERROR
                "${cell} writer failed (${writer_result}):\n${writer_output}\n${writer_error}")
        endif()

        execute_process(
            COMMAND "${runtime}" -l "${import_path}" "${program}"
                rx_sqlite_boundary rx_system library -a verify "${database}"
            OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
            RESULT_VARIABLE verify_result)
        if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "P1_SQL_05_OK")
            message(FATAL_ERROR "${cell} verify failed:\n${verify_out}\n${verify_err}")
        endif()
        file(APPEND "${report}"
            "${cell} setup:\n${setup_out}${setup_err}"
            "${cell} writer:\n${writer_output}${writer_error}"
            "${cell} reader:\n${reader_out}${reader_err}"
            "${cell} verify:\n${verify_out}${verify_err}\n")
    endforeach()
endforeach()

message(STATUS
    "P1-SQL-05 passed separate-process WAL reader/writer snapshots on rxvme/rxbvm")
