foreach(required_var
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_DIR CPRAG_MODULE CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(module_base "${CPRAG_WORK_DIR}/data_boundary")
set(program "${CPRAG_WORK_DIR}/data-boundary-test")
set(native_import_path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import_path "${CPRAG_WORK_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${native_import_path}" -o "${module_base}" "${CPRAG_MODULE}"
    OUTPUT_VARIABLE module_compile_output
    ERROR_VARIABLE module_compile_error
    RESULT_VARIABLE module_compile_result)
if(NOT module_compile_result EQUAL 0)
    message(FATAL_ERROR "Data boundary module compile failed:\n${module_compile_output}\n${module_compile_error}")
endif()
execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${module_base}" "${module_base}"
    OUTPUT_VARIABLE module_assemble_output
    ERROR_VARIABLE module_assemble_error
    RESULT_VARIABLE module_assemble_result)
if(NOT module_assemble_result EQUAL 0)
    message(FATAL_ERROR "Data boundary module assembly failed:\n${module_assemble_output}\n${module_assemble_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXC}" -i "${program_import_path}" -o "${program}" "${CPRAG_SOURCE}"
    OUTPUT_VARIABLE compile_output
    ERROR_VARIABLE compile_error
    RESULT_VARIABLE compile_result)
if(NOT compile_result EQUAL 0)
    message(FATAL_ERROR "Data boundary test compile failed:\n${compile_output}\n${compile_error}")
endif()
execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${program}" "${program}"
    OUTPUT_VARIABLE assemble_output
    ERROR_VARIABLE assemble_error
    RESULT_VARIABLE assemble_result)
if(NOT assemble_result EQUAL 0)
    message(FATAL_ERROR "Data boundary test assembly failed:\n${assemble_output}\n${assemble_error}")
endif()

execute_process(
    COMMAND "${CPRAG_RXVME}" -l "${program_import_path}" "${program}" data_boundary rx_sqlite_boundary library
    OUTPUT_VARIABLE vm_output
    ERROR_VARIABLE vm_error
    RESULT_VARIABLE vm_result)
file(WRITE "${CPRAG_WORK_DIR}/commands-and-output.txt"
    "module rxc:\n${module_compile_output}${module_compile_error}\n"
    "module rxas:\n${module_assemble_output}${module_assemble_error}\n"
    "test rxc:\n${compile_output}${compile_error}\n"
    "test rxas:\n${assemble_output}${assemble_error}\n"
    "rxvme:\n${vm_output}${vm_error}\nrxvme_result=${vm_result}\n")
if(NOT vm_result EQUAL 0 OR NOT vm_output MATCHES "P1A_DATA_OK")
    message(FATAL_ERROR "Data boundary runtime failed (${vm_result}):\n${vm_output}\n${vm_error}")
endif()
message(STATUS "${vm_output}")
