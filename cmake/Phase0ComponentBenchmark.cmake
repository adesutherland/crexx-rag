foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_BENCHMARK_SOURCE CPRAG_NATIVE_BENCHMARK CPRAG_LOOPBACK_PROVIDER
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

include("${CMAKE_CURRENT_LIST_DIR}/CpragProcessMetrics.cmake")

function(assert_output output runtime)
    foreach(component crexx_algorithm json_parse record_materialize json_encode provider_wait)
        if(NOT output MATCHES "${runtime},${component},[0-9]+")
            message(FATAL_ERROR "${runtime} benchmark omitted ${component}:\n${output}")
        endif()
    endforeach()
    if(NOT output MATCHES "${runtime},provider_wait,[0-9]+,1,[0-9]+,[0-9]+,ok")
        message(FATAL_ERROR "${runtime} provider wait did not succeed:\n${output}")
    endif()
endfunction()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(output_base "${CPRAG_WORK_DIR}/phase0-components")
set(port 18765)

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${CPRAG_CREXX_BIN_DIR}" --import-rxas -o "${output_base}" "${CPRAG_BENCHMARK_SOURCE}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE rxc_output
    ERROR_VARIABLE rxc_error
    RESULT_VARIABLE rxc_result)
if(NOT rxc_result EQUAL 0)
    message(FATAL_ERROR "rxc Phase-0 benchmark failed (${rxc_result}):\n${rxc_output}\n${rxc_error}")
endif()
execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${output_base}" "${output_base}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE rxas_output
    ERROR_VARIABLE rxas_error
    RESULT_VARIABLE rxas_result)
if(NOT rxas_result EQUAL 0)
    message(FATAL_ERROR "rxas Phase-0 benchmark failed (${rxas_result}):\n${rxas_output}\n${rxas_error}")
endif()

execute_process(
    COMMAND "${CPRAG_NATIVE_BENCHMARK}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE native_output
    ERROR_VARIABLE native_error
    RESULT_VARIABLE native_result)
if(NOT native_result EQUAL 0)
    message(FATAL_ERROR "Native component benchmark failed (${native_result}):\n${native_output}\n${native_error}")
endif()
foreach(component sqlite_write vector_db_transfer vector_decode vector_compute vector_selection vector_peak_memory vector_total)
    if(NOT native_output MATCHES "native,${component},[0-9]+")
        message(FATAL_ERROR "Native benchmark omitted ${component}:\n${native_output}")
    endif()
endforeach()

set(provider_out "${CPRAG_WORK_DIR}/loopback-provider.out")
set(provider_err "${CPRAG_WORK_DIR}/loopback-provider.err")
execute_process(
    COMMAND /bin/sh -c "\"$1\" \"$2\" \"$3\" >\"$4\" 2>\"$5\" &"
        phase0-provider "${CPRAG_LOOPBACK_PROVIDER}" "${port}" 2 "${provider_out}" "${provider_err}"
    RESULT_VARIABLE provider_start_result)
if(NOT provider_start_result EQUAL 0)
    message(FATAL_ERROR "Failed to start deterministic loopback provider")
endif()
execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.2)

execute_process(
    COMMAND "${CPRAG_TIME_EXECUTABLE}" ${CPRAG_TIME_RESOURCE_ARGS}
        "${CPRAG_RXVME}" -l "${CPRAG_CREXX_BIN_DIR}"
        "${output_base}" rxfnsg rxfnsc library -a rxvme "${port}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE rxvme_output
    ERROR_VARIABLE rxvme_error
    RESULT_VARIABLE rxvme_result)
if(NOT rxvme_result EQUAL 0)
    message(FATAL_ERROR "rxvme Phase-0 benchmark failed (${rxvme_result}):\n${rxvme_output}\n${rxvme_error}")
endif()
assert_output("${rxvme_output}" rxvme)

execute_process(
    COMMAND "${CPRAG_TIME_EXECUTABLE}" ${CPRAG_TIME_RESOURCE_ARGS}
        "${CPRAG_RXBVM}" -l "${CPRAG_CREXX_BIN_DIR}"
        "${output_base}" rxfnsg rxfnsc library -a rxbvm "${port}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE rxbvm_output
    ERROR_VARIABLE rxbvm_error
    RESULT_VARIABLE rxbvm_result)
if(NOT rxbvm_result EQUAL 0)
    message(FATAL_ERROR "rxbvm Phase-0 benchmark failed (${rxbvm_result}):\n${rxbvm_output}\n${rxbvm_error}")
endif()
assert_output("${rxbvm_output}" rxbvm)

foreach(runtime rxvme rxbvm)
    set(timing_error "${${runtime}_error}")
    cprag_extract_peak_rss("${timing_error}" ${runtime}_rss)
endforeach()

file(READ "${provider_out}" provider_log)
if(NOT provider_log MATCHES "READY ${port}")
    file(READ "${provider_err}" provider_error_log)
    message(FATAL_ERROR "Loopback provider readiness was not recorded:\n${provider_log}\n${provider_error_log}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/native.csv"
    "runtime,component,elapsed_us,operations,bytes,checksum,status\n${native_output}")
file(WRITE "${CPRAG_WORK_DIR}/rxvme.csv" "${rxvme_output}rxvme,process_peak_memory,0,1,${rxvme_rss},${rxvme_rss},ok\n")
file(WRITE "${CPRAG_WORK_DIR}/rxbvm.csv" "${rxbvm_output}rxbvm,process_peak_memory,0,1,${rxbvm_rss},${rxbvm_rss},ok\n")
file(WRITE "${CPRAG_WORK_DIR}/diagnostics.txt"
    "rxc:\n${rxc_output}${rxc_error}\nrxas:\n${rxas_output}${rxas_error}\nrxvme time:\n${rxvme_error}\nrxbvm time:\n${rxbvm_error}\nprovider:\n${provider_log}")
message(STATUS "Phase-0 same-session component benchmark passed for native, rxvme, and rxbvm")
