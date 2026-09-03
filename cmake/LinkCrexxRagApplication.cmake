foreach(required_var CPRAG_RXLINK CPRAG_LINK_INPUTS CPRAG_DYNAMIC_PROVIDER
        CPRAG_OUTPUT_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(MAKE_DIRECTORY "${CPRAG_OUTPUT_DIR}")
execute_process(
    COMMAND "${CPRAG_RXLINK}" -s -r crexxrag_cli
        -m "${CPRAG_OUTPUT_DIR}/crexxrag.map"
        -p "${CPRAG_OUTPUT_DIR}/crexxrag.rxproviders"
        -o "${CPRAG_OUTPUT_DIR}/crexxrag"
        ${CPRAG_LINK_INPUTS}
    WORKING_DIRECTORY "${CPRAG_OUTPUT_DIR}"
    RESULT_VARIABLE link_result
    OUTPUT_VARIABLE link_out
    ERROR_VARIABLE link_err)
if(NOT link_result EQUAL 0)
    message(FATAL_ERROR
        "cREXX application link failed:\n${link_out}${link_err}")
endif()

file(READ "${CPRAG_OUTPUT_DIR}/crexxrag.rxproviders" provider_requirements)
if(NOT provider_requirements MATCHES "required[\t ]+rx_sqlite_boundary[\t ]")
    message(FATAL_ERROR
        "linked application did not declare the static SQLite provider")
endif()
if(provider_requirements MATCHES "[\t ]system\\.")
    message(FATAL_ERROR
        "linked application retained an unpackaged legacy system dependency")
endif()

file(MAKE_DIRECTORY "${CPRAG_OUTPUT_DIR}/providers")
file(COPY_FILE "${CPRAG_DYNAMIC_PROVIDER}"
    "${CPRAG_OUTPUT_DIR}/providers/rx_sqlite_boundary.rxplugin"
    ONLY_IF_DIFFERENT)

file(SHA256 "${CPRAG_OUTPUT_DIR}/crexxrag.rxbin" application_sha256)
file(WRITE "${CPRAG_OUTPUT_DIR}/artifact.txt"
    "artifact=crexxrag.rxbin\n"
    "sha256=${application_sha256}\n"
    "root=crexxrag_cli\n"
    "level=G\n"
    "hosted_calls=0\n")
message(STATUS
    "Built linked cREXX application ${CPRAG_OUTPUT_DIR}/crexxrag.rxbin (${application_sha256})")
