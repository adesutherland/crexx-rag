foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION_DIR CPRAG_PROBE CPRAG_LOOPBACK
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" 19020 4 local-embedding; printf '%s' $? >\"$4\" ) >\"$2\" 2>\"$3\" &"
    local-embedding-protocol "${CPRAG_LOOPBACK}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start local embedding loopback")
endif()
set(ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${server_out}")
        file(READ "${server_out}" current_server_out)
        if(current_server_out MATCHES "READY 19020")
            set(ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT ready)
    message(FATAL_ERROR "local embedding loopback did not become ready")
endif()

set(imports "${CPRAG_WORK_DIR};${CPRAG_APPLICATION_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules provider_contract provider_catalog provider_http industrial_provider
    rx_hash rx_system rxfs rxplatform rxvector rxfnsg library)
foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/local-embedding-${mode}")
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
            -o "${program}" "${CPRAG_PROBE}"
        RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out
        ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${mode} local embedding protocol compile failed:\n${compile_out}${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out
        ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${mode} local embedding protocol assembly failed:\n${assemble_out}${assemble_err}")
    endif()

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        execute_process(COMMAND "${runtime}" -l "${imports}" "${program}" ${modules}
                -a "${cell}"
            RESULT_VARIABLE run_result OUTPUT_VARIABLE run_out
            ERROR_VARIABLE run_err TIMEOUT 30)
        if(NOT run_result EQUAL 0 OR NOT run_out MATCHES
                "LOCAL_EMBEDDING_PROTOCOL_OK cell=${cell} protocol=openai-compatible endpoint=/v1/embeddings dimensions=3 charging=local-compute privacy=restricted")
            message(FATAL_ERROR "${cell} local embedding protocol failed:\n${run_out}${run_err}")
        endif()
        file(APPEND "${CPRAG_WORK_DIR}/result.txt" "${run_out}${run_err}")
    endforeach()
endforeach()

set(exited FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${server_status}")
        set(exited TRUE)
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT exited)
    message(FATAL_ERROR "local embedding loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=local-embedding connections=4 request_connection_close=4")
    message(FATAL_ERROR "local embedding loopback failed:\n${final_server_out}${final_server_err}")
endif()
message(STATUS "Local OpenAI-compatible embedding protocol passed request mapping, restricted local privacy, vector decoding and zero monetary cost on both VMs and compiler modes")
