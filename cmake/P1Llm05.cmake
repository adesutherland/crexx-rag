foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_CONTRACT CPRAG_CATALOG CPRAG_HTTP CPRAG_ADAPTER
        CPRAG_LOCAL_ADAPTER CPRAG_SOURCE CPRAG_LOOPBACK CPRAG_SOURCE_ROOT
        CPRAG_HOSTED_OUTPUT CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(port 18995)
set(base_import "${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "fixture=zero-outbound\nhosted_calls=0\ncredential_values_retained=0\n")

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
    compile_crexx("${CPRAG_HTTP}" "${CPRAG_WORK_DIR}/provider_http"
        "${program_import}" "${mode_flag}" "${mode} HTTP")
    compile_crexx("${CPRAG_ADAPTER}" "${CPRAG_WORK_DIR}/industrial_provider"
        "${program_import}" "${mode_flag}" "${mode} adapter")
    compile_crexx("${CPRAG_LOCAL_ADAPTER}" "${CPRAG_WORK_DIR}/openai_compatible_provider"
        "${program_import}" "${mode_flag}" "${mode} local adapter")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} test")
endforeach()

set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 0 zero-outbound; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p1-llm-05 "${CPRAG_LOOPBACK}" "${port}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "Could not start zero-outbound observer")
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
    message(FATAL_ERROR "Zero-outbound observer did not become ready")
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
            provider_contract provider_catalog provider_http industrial_provider
            openai_compatible_provider library
            -a "127.0.0.1" "${port}" "${cell}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err RESULT_VARIABLE vm_result)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "P1_LLM_05_OK")
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
    message(FATAL_ERROR "Zero-outbound observer did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
file(APPEND "${report}"
    "observer:\n${final_server_out}${final_server_err}result=${server_result}\n")
if(NOT server_result STREQUAL "0"
        OR NOT final_server_out MATCHES "scenario=zero-outbound connections=0")
    message(FATAL_ERROR "Denied route made an outbound connection")
endif()

file(GLOB_RECURSE audit_files LIST_DIRECTORIES false
    "${CPRAG_SOURCE_ROOT}/cmake/*.cmake"
    "${CPRAG_SOURCE_ROOT}/docs/evidence/2026-08-03-phase1b/*"
    "${CPRAG_SOURCE_ROOT}/incubator/phase1b/provider/*"
    "${CPRAG_SOURCE_ROOT}/tests/*")
if(EXISTS "${CPRAG_HOSTED_OUTPUT}")
    list(APPEND audit_files "${CPRAG_HOSTED_OUTPUT}")
endif()
list(APPEND audit_files "${report}" "${server_out}" "${server_err}")
file(READ "${CPRAG_HTTP}" http_source)
if(http_source MATCHES "_headers:[ \t]+method"
        OR http_source MATCHES "buildRequest"
        OR http_source MATCHES "lastHttp")
    message(FATAL_ERROR "Provider transport exposes a raw request or authorization helper")
endif()
set(scanned_credentials 0)
foreach(key_name OPENAI_API_KEY ANTHROPIC_API_KEY GEMINI_API_KEY)
    set(secret "$ENV{${key_name}}")
    if(secret STREQUAL "")
        message(FATAL_ERROR "Credential required for secret-retention audit is unavailable")
    endif()
    math(EXPR scanned_credentials "${scanned_credentials} + 1")
    foreach(audit_file IN LISTS audit_files)
        file(READ "${audit_file}" audit_content)
        string(FIND "${audit_content}" "${secret}" leak_position)
        if(NOT leak_position EQUAL -1)
            message(FATAL_ERROR "Credential value found in retained source, fixture, or output")
        endif()
    endforeach()
endforeach()
file(APPEND "${report}"
    "credential_values_scanned=${scanned_credentials}\ncredential_value_matches=0\n"
    "raw_request_surface=not_exposed\nraw_authorization_surface=not_exposed\n")

message(STATUS
    "P1-LLM-05 passed zero-outbound and three-credential retention audit on rxvme/rxbvm")
