foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXLINK CPRAG_RXVME
        CPRAG_RXBVM CPRAG_CREXX_BIN_DIR CPRAG_CONTRACT CPRAG_CATALOG
        CPRAG_HTTP CPRAG_ADAPTER CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()
if("$ENV{OPENAI_API_KEY}" STREQUAL "")
    message(FATAL_ERROR
        "Phase-7 hosted qualification requires env:OPENAI_API_KEY")
endif()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/hosted-output.txt")
file(WRITE "${report}"
    "phase=7\nprovider=openai\ncredential_reference=env:OPENAI_API_KEY\n"
    "credential_values_logged=0\npublic_fixture_only=1\nmax_attempts=1\n"
    "declared_call_ceiling=8\n")

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
endfunction()

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    foreach(module IN ITEMS provider_contract provider_catalog provider_http
            industrial_provider)
        if(module STREQUAL "provider_contract")
            set(source "${CPRAG_CONTRACT}")
            set(imports "${base_import}")
        elseif(module STREQUAL "provider_catalog")
            set(source "${CPRAG_CATALOG}")
            set(imports "${program_import}")
        elseif(module STREQUAL "provider_http")
            set(source "${CPRAG_HTTP}")
            set(imports "${program_import}")
        else()
            set(source "${CPRAG_ADAPTER}")
            set(imports "${program_import}")
        endif()
        compile_crexx("${source}" "${CPRAG_WORK_DIR}/${module}-${mode}"
            "${imports}" "${mode_flag}" "${mode} ${module}")
    endforeach()
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/probe-${mode}"
        "${program_import}" "${mode_flag}" "${mode} hosted probe")
    execute_process(COMMAND "${CPRAG_RXLINK}" -s
        -o "${CPRAG_WORK_DIR}/probe-${mode}-linked"
        "${CPRAG_WORK_DIR}/probe-${mode}.rxbin"
        "${CPRAG_WORK_DIR}/provider_contract-${mode}.rxbin"
        "${CPRAG_WORK_DIR}/provider_catalog-${mode}.rxbin"
        "${CPRAG_WORK_DIR}/provider_http-${mode}.rxbin"
        "${CPRAG_WORK_DIR}/industrial_provider-${mode}.rxbin"
        "${CPRAG_CREXX_BIN_DIR}/rxfnsg.rxbin"
        "${CPRAG_CREXX_BIN_DIR}/classlib.rxbin"
        "${CPRAG_CREXX_BIN_DIR}/library.rxbin"
        OUTPUT_VARIABLE link_out ERROR_VARIABLE link_err
        RESULT_VARIABLE link_result)
    if(NOT link_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} hosted probe link failed:\n${link_out}\n${link_err}")
    endif()
    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(COMMAND "${runtime}"
            "${CPRAG_WORK_DIR}/probe-${mode}-linked.rxbin"
            -a "${mode}-${runtime_name}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result TIMEOUT 300)
        file(APPEND "${report}" "${mode}-${runtime_name}:\n${vm_out}${vm_err}\n")
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P7_HOSTED_PROVIDER_SUMMARY status=ok.*calls=2 generation=1 embedding_batches=1 max_attempts=1")
            message(FATAL_ERROR
                "${mode}-${runtime_name} hosted qualification failed; inspect secret-free ${report}")
        endif()
    endforeach()
endforeach()

message(STATUS
    "Phase 7 cREXX hosted probe unexpectedly passed in all four compiler/VM cells; review the retained cutover blocker before changing its status")
