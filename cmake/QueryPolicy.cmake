foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION_DIR CPRAG_PROVIDER_DIR
        CPRAG_SCENARIO CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(GLOB project_member_dirs LIST_DIRECTORIES true
    "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.crexx-build/members/*")
list(JOIN project_member_dirs ";" project_imports)
set(imports "${CPRAG_WORK_DIR};${project_imports};${CPRAG_APPLICATION_DIR};${CPRAG_PROVIDER_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    foreach(module IN ITEMS ragmodel ragworkerdefaults ragconfig provider_contract provider_catalog ragadmission ragquerypolicy)
        set(source "${CPRAG_APPLICATION_DIR}/${module}.crexx")
        if(module STREQUAL "provider_contract" OR module STREQUAL "provider_catalog")
            set(source "${CPRAG_PROVIDER_DIR}/${module}.crexx")
        endif()
        execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
            -o "${CPRAG_WORK_DIR}/${module}" "${source}"
            RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
        if(NOT compile_result EQUAL 0)
            message(FATAL_ERROR "${mode} ${module} compile failed:\n${compile_out}${compile_err}")
        endif()
        execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag}
            -o "${CPRAG_WORK_DIR}/${module}" "${CPRAG_WORK_DIR}/${module}"
            RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
        if(NOT assemble_result EQUAL 0)
            message(FATAL_ERROR "${mode} ${module} assembly failed:\n${assemble_out}${assemble_err}")
        endif()
    endforeach()
    set(program "${CPRAG_WORK_DIR}/query-policy-${mode}")
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${program}" "${CPRAG_SCENARIO}"
        RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${mode} query policy compile failed:\n${compile_out}${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${mode} query policy assembly failed:\n${assemble_out}${assemble_err}")
    endif()
    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(COMMAND "${runtime}" -l "${imports}" "${program}"
            ragquerypolicy ragadmission ragconfig ragworkerdefaults ragmodel provider_contract provider_catalog rx_hash rx_system library
            -a "${mode}-${runtime_name}"
            RESULT_VARIABLE run_result OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err TIMEOUT 30)
        if(NOT run_result EQUAL 0 OR NOT run_out MATCHES "QUERY_POLICY_OK")
            message(FATAL_ERROR "${mode}-${runtime_name} query policy failed:\n${run_out}${run_err}")
        endif()
    endforeach()
endforeach()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "Query privacy and every call, Codex-turn, input-token, output-token and cost ceiling passed in noopt/opt on rxvme/rxbvm.\n")
message(STATUS "Query privacy and budget policy passed in four compiler/VM cells")
