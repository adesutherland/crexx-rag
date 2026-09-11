foreach(required CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_DIR CPRAG_APPLICATION_DIR CPRAG_SCENARIO CPRAG_WORK_DIR)
    if(NOT DEFINED ${required} OR "${${required}}" STREQUAL "")
        message(FATAL_ERROR "${required} is required")
    endif()
endforeach()
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(GLOB members LIST_DIRECTORIES true
    "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.crexx-build/members/*")
list(JOIN members ";" member_imports)
set(imports "${member_imports};${CPRAG_APPLICATION_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules ragenrich ragproposalio ragperiod ragprovenance ragassessment ragschema ragfile
    ragstore ragmodel ragjob ragclaims ragadmission raglifecycle ragworktypes ragusage ragreceipts ragwork ragcommand ragtrace ragbacklog
    ragmaintain ragimprove ragconfig ragprofile ragcanonical raggrounding generic_profile
    rxfnsg rxsqlite rx_hash rx_system rxfs rxplatform library)
set(program "${CPRAG_WORK_DIR}/lifecycle-regression")
execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}" -o "${program}" "${CPRAG_SCENARIO}"
    RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE errors)
file(WRITE "${CPRAG_WORK_DIR}/compile.log" "${output}${errors}")
if(NOT status EQUAL 0)
    message(FATAL_ERROR "Lifecycle regression compile failed:\n${output}${errors}")
endif()
execute_process(COMMAND "${CPRAG_RXAS}" -o "${program}" "${program}"
    RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE errors)
if(NOT status EQUAL 0)
    message(FATAL_ERROR "Lifecycle regression assembly failed:\n${output}${errors}")
endif()
set(failures)
foreach(runtime IN ITEMS RXVME RXBVM)
    execute_process(COMMAND "${CPRAG_${runtime}}" -l "${imports}" "${program}" ${modules}
        -a "${CPRAG_WORK_DIR}/library-${runtime}"
        RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE errors TIMEOUT 60)
    file(WRITE "${CPRAG_WORK_DIR}/${runtime}.log" "exit=${status}\n${output}${errors}")
    if(NOT status EQUAL 0 OR NOT output MATCHES "LIFECYCLE_REGRESSION_OK")
        list(APPEND failures "${runtime}: ${output}${errors}")
    endif()
endforeach()
if(failures)
    list(JOIN failures "\n" detail)
    message(FATAL_ERROR "RAG-OPS-002 acceptance failed:\n${detail}")
endif()
message(STATUS "Lifecycle regression passed on both VMs with optimized code")
