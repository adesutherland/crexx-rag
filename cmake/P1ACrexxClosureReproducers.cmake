foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_RECORD_CONTRACT CPRAG_RECORD_FACADE CPRAG_PARSE_REPRO
        CPRAG_LOOP_REPRO CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(WRITE "${CPRAG_WORK_DIR}/record-runtime.crexx"
"options levelg\nimport repro_record\nimport repro_facade\nfacade=.reprofacade()\nrecord=facade.record()\nif record.value() \\= \"typed\" then return 1\nsay \"CRI01_RECORD_OK\"\nreturn 0\n")

function(compile_and_assemble label source output imports mode_flag)
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}" -o "${output}" "${source}"
        OUTPUT_VARIABLE rxc_out ERROR_VARIABLE rxc_err RESULT_VARIABLE rxc_result)
    if(NOT rxc_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${rxc_out}\n${rxc_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        OUTPUT_VARIABLE rxas_out ERROR_VARIABLE rxas_err RESULT_VARIABLE rxas_result)
    if(NOT rxas_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${rxas_out}\n${rxas_err}")
    endif()
    file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt"
        "${label} rxc:\n${rxc_out}${rxc_err}\n${label} rxas:\n${rxas_out}${rxas_err}\n")
endfunction()

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(mode_dir "${CPRAG_WORK_DIR}/${mode}")
    file(MAKE_DIRECTORY "${mode_dir}")
    set(record_contract "${mode_dir}/repro_record")
    set(record_facade "${mode_dir}/repro_facade")
    set(record_runtime "${mode_dir}/record-runtime")
    set(parse_runtime "${mode_dir}/levelg-parseplan-repro")
    set(loop_runtime "${mode_dir}/levelb-do-forever-return-repro")
    set(imports "${mode_dir};${CPRAG_CREXX_BIN_DIR}")

    compile_and_assemble("${mode}/record-contract" "${CPRAG_RECORD_CONTRACT}" "${record_contract}" "${CPRAG_CREXX_BIN_DIR}" "${mode_flag}")
    compile_and_assemble("${mode}/record-facade" "${CPRAG_RECORD_FACADE}" "${record_facade}" "${imports}" "${mode_flag}")
    compile_and_assemble("${mode}/record-runtime" "${CPRAG_WORK_DIR}/record-runtime.crexx" "${record_runtime}" "${imports}" "${mode_flag}")
    compile_and_assemble("${mode}/parse" "${CPRAG_PARSE_REPRO}" "${parse_runtime}" "${CPRAG_CREXX_BIN_DIR}" "${mode_flag}")
    compile_and_assemble("${mode}/loop" "${CPRAG_LOOP_REPRO}" "${loop_runtime}" "${CPRAG_CREXX_BIN_DIR}" "${mode_flag}")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(COMMAND "${runtime}" -l "${imports}" "${record_runtime}" repro_facade repro_record library
            OUTPUT_VARIABLE record_out ERROR_VARIABLE record_err RESULT_VARIABLE record_result)
        if(NOT record_result EQUAL 0 OR NOT record_out MATCHES "CRI01_RECORD_OK")
            message(FATAL_ERROR "${mode}/${runtime_name} record runtime failed:\n${record_out}\n${record_err}")
        endif()
        execute_process(COMMAND "${runtime}" -l "${CPRAG_CREXX_BIN_DIR}" "${parse_runtime}" library -a "alpha|beta|gamma"
            OUTPUT_VARIABLE parse_out ERROR_VARIABLE parse_err RESULT_VARIABLE parse_result)
        if(NOT parse_result EQUAL 0 OR NOT parse_out MATCHES "alpha[\r\n]+beta[\r\n]+gamma")
            message(FATAL_ERROR "${mode}/${runtime_name} Level G PARSE runtime failed:\n${parse_out}\n${parse_err}")
        endif()
        file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt"
            "${mode}/${runtime_name} record:\n${record_out}${record_err}\n"
            "${mode}/${runtime_name} parse:\n${parse_out}${parse_err}\n")
    endforeach()
endforeach()
message(STATUS "CRI-01/04/05 concrete reproducers passed noopt/opt on rxvme/rxbvm")
