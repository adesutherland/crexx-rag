foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_DIR CPRAG_MODULE CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

include("${CMAKE_CURRENT_LIST_DIR}/CpragProcessMetrics.cmake")

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(native_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${native_import}")

function(compile_module name source import_path)
    execute_process(COMMAND "${CPRAG_RXC}" -i "${import_path}" -o "${CPRAG_WORK_DIR}/${name}" "${source}"
        OUTPUT_VARIABLE out ERROR_VARIABLE err RESULT_VARIABLE result)
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "${name} compile failed:\n${out}\n${err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" -o "${CPRAG_WORK_DIR}/${name}" "${CPRAG_WORK_DIR}/${name}"
        OUTPUT_VARIABLE asm_out ERROR_VARIABLE asm_err RESULT_VARIABLE asm_result)
    if(NOT asm_result EQUAL 0)
        message(FATAL_ERROR "${name} assembly failed:\n${asm_out}\n${asm_err}")
    endif()
    file(APPEND "${CPRAG_WORK_DIR}/compile.txt" "${name} rxc:\n${out}${err}\n${name} rxas:\n${asm_out}${asm_err}\n")
endfunction()

compile_module(vector_boundary "${CPRAG_MODULE}" "${native_import}")
compile_module(vector-boundary-test "${CPRAG_SOURCE}" "${program_import}")

foreach(runtime IN ITEMS rxvme rxbvm)
    if(runtime STREQUAL "rxvme")
        set(vm "${CPRAG_RXVME}")
    else()
        set(vm "${CPRAG_RXBVM}")
    endif()
    execute_process(
        COMMAND "${CPRAG_TIME_EXECUTABLE}" ${CPRAG_TIME_RESOURCE_ARGS}
            "${vm}" -l "${program_import}" "${CPRAG_WORK_DIR}/vector-boundary-test"
            vector_boundary rx_sqlite_boundary library -a "${runtime}"
        OUTPUT_VARIABLE output ERROR_VARIABLE timing RESULT_VARIABLE result)
    if(NOT result EQUAL 0 OR NOT output MATCHES "P1A_VEC_OK runtime=${runtime}")
        message(FATAL_ERROR "${runtime} vector boundary failed (${result}):\n${output}\n${timing}")
    endif()
    foreach(component db_transfer decode arithmetic selection estimated_working_memory total)
        if(NOT output MATCHES "${runtime},${component},[0-9]+")
            message(FATAL_ERROR "${runtime} omitted ${component}:\n${output}")
        endif()
    endforeach()
    cprag_extract_peak_rss("${timing}" rss)
    file(WRITE "${CPRAG_WORK_DIR}/${runtime}.csv"
        "runtime,component,elapsed_us,operations,bytes,checksum,status\n${output}${runtime},process_peak_memory,0,1,${rss},${rss},ok\n")
    file(APPEND "${CPRAG_WORK_DIR}/diagnostics.txt" "${runtime} time:\n${timing}\n")
endforeach()

message(STATUS "P1A vector boundary passed ordering/ties and component measurements on rxvme/rxbvm")
