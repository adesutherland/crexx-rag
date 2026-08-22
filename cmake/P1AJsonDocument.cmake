foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_TEST_SOURCE CPRAG_BENCHMARK_SOURCE CPRAG_PROBE_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

include("${CMAKE_CURRENT_LIST_DIR}/CpragProcessMetrics.cmake")

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(all_output "")

foreach(mode IN ITEMS noopt opt)
    set(mode_dir "${CPRAG_WORK_DIR}/${mode}")
    file(MAKE_DIRECTORY "${mode_dir}")
    set(test_base "${mode_dir}/rxjson_projection_test")
    set(benchmark_base "${mode_dir}/rxjson_projection_benchmark")
    set(probe_base "${mode_dir}/binary_argument_optimizer_probe")
    set(mode_flags)
    if(mode STREQUAL "noopt")
        list(APPEND mode_flags -n)
    endif()

    foreach(program_kind IN ITEMS test benchmark probe)
        if(program_kind STREQUAL "test")
            set(program_source "${CPRAG_TEST_SOURCE}")
            set(program_base "${test_base}")
        elseif(program_kind STREQUAL "benchmark")
            set(program_source "${CPRAG_BENCHMARK_SOURCE}")
            set(program_base "${benchmark_base}")
        else()
            set(program_source "${CPRAG_PROBE_SOURCE}")
            set(program_base "${probe_base}")
        endif()
        execute_process(
            COMMAND "${CPRAG_RXC}" ${mode_flags} -i "${CPRAG_CREXX_BIN_DIR}"
                --import-rxas -o "${program_base}" "${program_source}"
            OUTPUT_VARIABLE rxc_out ERROR_VARIABLE rxc_err RESULT_VARIABLE rxc_result)
        if(NOT rxc_result EQUAL 0)
            message(FATAL_ERROR "${mode}/${program_kind} compile failed:\n${rxc_out}\n${rxc_err}")
        endif()
        execute_process(
            COMMAND "${CPRAG_RXAS}" ${mode_flags} -o "${program_base}" "${program_base}"
            OUTPUT_VARIABLE rxas_out ERROR_VARIABLE rxas_err RESULT_VARIABLE rxas_result)
        if(NOT rxas_result EQUAL 0)
            message(FATAL_ERROR "${mode}/${program_kind} assembly failed:\n${rxas_out}\n${rxas_err}")
        endif()
        string(APPEND all_output
            "mode=${mode} kind=${program_kind} rxc=${CPRAG_RXC} ${mode_flags} -i ${CPRAG_CREXX_BIN_DIR} --import-rxas -o ${program_base} ${program_source}\n${rxc_out}${rxc_err}\n"
            "mode=${mode} kind=${program_kind} rxas=${CPRAG_RXAS} ${mode_flags} -o ${program_base} ${program_base}\n${rxas_out}${rxas_err}\n")
    endforeach()

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()

        execute_process(
            COMMAND "${CPRAG_TIME_EXECUTABLE}" ${CPRAG_TIME_RESOURCE_ARGS}
                "${runtime}" -l "${CPRAG_CREXX_BIN_DIR}"
                "${test_base}" library -a "${runtime_name}"
            OUTPUT_VARIABLE test_out ERROR_VARIABLE test_err RESULT_VARIABLE test_result)
        if(NOT test_result EQUAL 0 OR NOT test_out MATCHES "P1A_RXJSON_PROJECTION_OK")
            message(FATAL_ERROR "${mode}/${runtime_name} projection test failed (${test_result}):\n${test_out}\n${test_err}")
        endif()
        execute_process(
            COMMAND "${CPRAG_TIME_EXECUTABLE}" ${CPRAG_TIME_RESOURCE_ARGS}
                "${runtime}" -l "${CPRAG_CREXX_BIN_DIR}"
                "${benchmark_base}" library -a "${runtime_name}"
            OUTPUT_VARIABLE benchmark_out ERROR_VARIABLE benchmark_err RESULT_VARIABLE benchmark_result)
        if(NOT benchmark_result EQUAL 0 OR NOT benchmark_out MATCHES "P1A_RXJSON_PROJECTION_BENCH_OK")
            message(FATAL_ERROR "${mode}/${runtime_name} projection benchmark failed (${benchmark_result}):\n${benchmark_out}\n${benchmark_err}")
        endif()
        execute_process(
            COMMAND "${CPRAG_TIME_EXECUTABLE}" ${CPRAG_TIME_RESOURCE_ARGS}
                "${runtime}" -l "${CPRAG_CREXX_BIN_DIR}"
                "${probe_base}" library -a 3072 10
            OUTPUT_VARIABLE probe_out ERROR_VARIABLE probe_err RESULT_VARIABLE probe_result)
        if(NOT probe_result EQUAL 0 OR NOT probe_out MATCHES "P1A_BINARY_ARGUMENT_PROBE_OK")
            message(FATAL_ERROR "${mode}/${runtime_name} binary probe failed (${probe_result}):\n${probe_out}\n${probe_err}")
        endif()
        string(REGEX MATCH "variant=by_value elapsed_us=([0-9]+)" by_value_match "${probe_out}")
        if(by_value_match STREQUAL "")
            message(FATAL_ERROR "${mode}/${runtime_name} binary probe omitted by-value timing")
        endif()
        set(${runtime_name}_${mode}_by_value "${CMAKE_MATCH_1}")
        file(WRITE "${CPRAG_WORK_DIR}/${mode}-${runtime_name}.txt"
            "projection test:\n${test_out}${test_err}\nprojection benchmark:\n${benchmark_out}${benchmark_err}\nbinary probe:\n${probe_out}${probe_err}\n")
        string(APPEND all_output
            "mode=${mode} runtime=${runtime_name} projection-test:\n${test_out}${test_err}\n"
            "mode=${mode} runtime=${runtime_name} projection-benchmark:\n${benchmark_out}${benchmark_err}\n"
            "mode=${mode} runtime=${runtime_name} binary-probe:\n${probe_out}${probe_err}\n")
    endforeach()
endforeach()

foreach(runtime_name IN ITEMS rxvme rxbvm)
    math(EXPR optimized_scaled "${${runtime_name}_opt_by_value} * 100")
    math(EXPR noopt_limit "${${runtime_name}_noopt_by_value} * 90")
    set(performance_status "pass")
    if(optimized_scaled GREATER noopt_limit)
        set(performance_status "observation-below-historical-threshold")
        if(DEFINED CPRAG_ENFORCE_PERFORMANCE AND CPRAG_ENFORCE_PERFORMANCE)
            message(FATAL_ERROR
                "${runtime_name} optimized by-value ${${runtime_name}_opt_by_value} us does not meet the requested <=0.90x non-optimized performance gate ${${runtime_name}_noopt_by_value} us")
        endif()
    endif()
    string(APPEND all_output
        "${runtime_name} by-value observation: opt=${${runtime_name}_opt_by_value}us noopt=${${runtime_name}_noopt_by_value}us historical_threshold=0.90 status=${performance_status}\n")
endforeach()

file(WRITE "${CPRAG_WORK_DIR}/commands-and-results.txt" "${all_output}")
message(STATUS
    "Production rxjson projection correctness passed noopt/opt on rxvme/rxbvm; timing is recorded as non-gating evidence")
