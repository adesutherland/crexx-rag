foreach(required_var CPRAG_CREXX_PACKAGE_PREFIX CPRAG_SQLITE_PROVIDER_ARCHIVE
        CPRAG_SQLITE_PROVIDER_NAME CPRAG_OUTPUT_DIR CPRAG_STAMP)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_OUTPUT_DIR}")
file(MAKE_DIRECTORY "${CPRAG_OUTPUT_DIR}")
file(COPY "${CPRAG_CREXX_PACKAGE_PREFIX}/" DESTINATION "${CPRAG_OUTPUT_DIR}")
file(MAKE_DIRECTORY "${CPRAG_OUTPUT_DIR}/bin/providers")
file(COPY_FILE "${CPRAG_SQLITE_PROVIDER_ARCHIVE}"
    "${CPRAG_OUTPUT_DIR}/bin/providers/${CPRAG_SQLITE_PROVIDER_NAME}"
    ONLY_IF_DIFFERENT)

# SQLite remains a generic external dependency of the application-local RXPA
# provider.  Extend only the build-owned SDK copy used for native packaging.
file(APPEND "${CPRAG_OUTPUT_DIR}/bin/crexx_native_libs_argv" "-lsqlite3\n")
file(WRITE "${CPRAG_STAMP}"
    "crexx_prefix=${CPRAG_CREXX_PACKAGE_PREFIX}\n"
    "sqlite_provider=${CPRAG_SQLITE_PROVIDER_NAME}\n")
