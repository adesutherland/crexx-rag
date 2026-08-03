foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_CODEC CPRAG_SEARCH
        CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

include("${CMAKE_CURRENT_LIST_DIR}/CpragProcessMetrics.cmake")

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "codec=${CPRAG_CODEC}\nsearch=${CPRAG_SEARCH}\nsource=${CPRAG_SOURCE}\n"
    "fixture=deterministic-11684-by-768\nproduction_schema=0\n"
    "metric_scope=fixture-build-separated-from-search-total\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR
            "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR
            "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}"
        "${label} compile:\n${compile_out}${compile_err}"
        "${label} assemble:\n${assemble_out}${assemble_err}\n")
endfunction()

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_CODEC}" "${CPRAG_WORK_DIR}/vector_codec"
        "${base_import}" "${mode_flag}" "${mode} codec")
    compile_crexx("${CPRAG_SEARCH}" "${CPRAG_WORK_DIR}/vector_search"
        "${base_import}" "${mode_flag}" "${mode} search")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} benchmark")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(database "${CPRAG_WORK_DIR}/${cell}.sqlite")
        execute_process(COMMAND "${CPRAG_TIME_EXECUTABLE}" ${CPRAG_TIME_RESOURCE_ARGS}
            "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/program-${mode}"
            vector_codec vector_search rx_sqlite_boundary library
            -a "${database}" "${cell}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE timing
            RESULT_VARIABLE vm_result TIMEOUT 300)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P1_VEC_03_OK cell=${cell} rows=11684 dimension=768 pages=92 top_checksum=1031")
            message(FATAL_ERROR
                "${cell} failed (${vm_result}):\n${vm_out}\n${timing}")
        endif()
        foreach(component sqlite_transfer decode arithmetic selection
                estimated_working_memory total)
            if(NOT vm_out MATCHES "${cell},${component},[0-9]+")
                message(FATAL_ERROR "${cell} omitted ${component}:\n${vm_out}")
            endif()
        endforeach()
        cprag_extract_peak_rss("${timing}" peak_rss)
        file(WRITE "${CPRAG_WORK_DIR}/${cell}-metrics.txt"
            "cell,component,elapsed_us,operations,bytes,checksum,status\n"
            "${vm_out}${cell},process_peak_memory,0,1,${peak_rss},${peak_rss},ok\n")
        file(APPEND "${report}"
            "${cell}:\n${vm_out}${cell},process_peak_memory,0,1,${peak_rss},${peak_rss},ok\n"
            "${cell} process timing:\n${timing}\n")
    endforeach()
endforeach()

message(STATUS
    "P1-VEC-03 measured full vector components and process RSS on rxvme/rxbvm")
