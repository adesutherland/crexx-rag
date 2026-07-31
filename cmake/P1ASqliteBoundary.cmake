foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_DIR CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(program "${CPRAG_WORK_DIR}/sqlite-boundary-test")
set(import_path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${import_path}" -o "${program}" "${CPRAG_SOURCE}"
    OUTPUT_VARIABLE compile_output
    ERROR_VARIABLE compile_error
    RESULT_VARIABLE compile_result)
if(NOT compile_result EQUAL 0)
    message(FATAL_ERROR "SQLite boundary cREXX compile failed:\n${compile_output}\n${compile_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${program}" "${program}"
    OUTPUT_VARIABLE assemble_output
    ERROR_VARIABLE assemble_error
    RESULT_VARIABLE assemble_result)
if(NOT assemble_result EQUAL 0)
    message(FATAL_ERROR "SQLite boundary assembly failed:\n${assemble_output}\n${assemble_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXVME}" -l "${import_path}" "${program}" rx_sqlite_boundary library
    OUTPUT_VARIABLE vm_output
    ERROR_VARIABLE vm_error
    RESULT_VARIABLE vm_result)
file(WRITE "${CPRAG_WORK_DIR}/commands-and-output.txt"
    "rxc output:\n${compile_output}${compile_error}\n"
    "rxas output:\n${assemble_output}${assemble_error}\n"
    "rxvme output:\n${vm_output}${vm_error}\n"
    "rxvme_result=${vm_result}\n")
if(NOT vm_result EQUAL 0 OR NOT vm_output MATCHES "P1A_SQLITE_OK")
    message(FATAL_ERROR "SQLite boundary runtime failed (${vm_result}):\n${vm_output}\n${vm_error}")
endif()

message(STATUS "${vm_output}")
