foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_CONTRACT CPRAG_CATALOG CPRAG_ADAPTER CPRAG_SOURCE
        CPRAG_LOOPBACK CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(port 18993)
set(base_import "${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "contract=${CPRAG_CONTRACT}\nadapter=${CPRAG_ADAPTER}\nsource=${CPRAG_SOURCE}\n"
    "hosted_calls=0\ntransport=installed-rxhttp\nconnection_reuse=unsupported\n"
    "streaming=unsupported\ncancellation=unsupported\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
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
    compile_crexx("${CPRAG_CONTRACT}" "${CPRAG_WORK_DIR}/provider_contract"
        "${base_import}" "${mode_flag}" "${mode} contract")
    compile_crexx("${CPRAG_CATALOG}" "${CPRAG_WORK_DIR}/provider_catalog"
        "${program_import}" "${mode_flag}" "${mode} catalog")
    compile_crexx("${CPRAG_ADAPTER}"
        "${CPRAG_WORK_DIR}/openai_compatible_provider" "${program_import}"
        "${mode_flag}" "${mode} adapter")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} test")
endforeach()

set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 128 hardening; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p1-llm-03 "${CPRAG_LOOPBACK}" "${port}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "Could not start provider hardening loopback")
endif()
set(ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${server_out}")
        file(READ "${server_out}" current_server_out)
        if(current_server_out MATCHES "READY ${port}")
            set(ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT ready)
    message(FATAL_ERROR "Provider hardening loopback did not become ready")
endif()

foreach(mode IN ITEMS noopt opt)
    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/program-${mode}"
            provider_contract provider_catalog openai_compatible_provider library
            -a "127.0.0.1" "${port}" "${cell}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err RESULT_VARIABLE vm_result)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "P1_LLM_03_OK")
            message(FATAL_ERROR
                "${cell} failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
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
    message(FATAL_ERROR "Provider hardening loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
file(APPEND "${report}"
    "loopback:\n${final_server_out}${final_server_err}result=${server_result}\n")
if(NOT server_result STREQUAL "0")
    message(FATAL_ERROR "Provider hardening loopback failed: ${server_result}")
endif()
if(NOT final_server_out MATCHES "connections=128 request_connection_close=128")
    message(FATAL_ERROR "Provider transport connection accounting mismatch")
endif()

message(STATUS
    "P1-LLM-03 passed hardening contract on rxvme/rxbvm; rxhttp connection reuse remains unsupported")
