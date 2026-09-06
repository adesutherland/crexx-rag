cmake_minimum_required(VERSION 3.21)

project(crexxrag
    VERSION 0.1.0
    DESCRIPTION "cREXX local RAG and typed-graph knowledge store"
    LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(CREXXRAG_BUILD_TESTS "Build crexxrag regression and provider tests" ON)

find_package(CREXX CONFIG REQUIRED)

set(CREXX_EXECUTABLE "${CREXX_crexx_EXECUTABLE}")
set(CREXX_RXC_EXECUTABLE "${CREXX_rxc_EXECUTABLE}")
set(CREXX_RXAS_EXECUTABLE "${CREXX_rxas_EXECUTABLE}")
set(CREXX_RXLINK_EXECUTABLE "${CREXX_rxlink_EXECUTABLE}")
set(CREXX_RXVME_EXECUTABLE "${CREXX_rxvme_EXECUTABLE}")
set(CREXX_RXBVM_EXECUTABLE "${CREXX_rxbvm_EXECUTABLE}")
set(CREXX_INSTALL_BIN_DIR "${CREXX_BIN_DIR}")

message(STATUS
    "Using installed CREXX package ${CREXX_VERSION_DISPLAY} from ${CREXX_PACKAGE_PREFIX}")

# SQLite is a supported CREXX component.  Downstream code imports the installed
# rxsqlite declarations, runtimes discover its dynamic provider here, and the
# CREXX native packager selects the canonical static archive from the same
# package.  The application does not build or link a second SQLite copy.
set(CREXXRAG_SQLITE_PROVIDER_DIR "${CREXX_INSTALL_BIN_DIR}/providers")
set(CREXXRAG_SQLITE_DYNAMIC_PROVIDER
    "${CREXXRAG_SQLITE_PROVIDER_DIR}/rxsqlite.rxplugin")
set(CREXXRAG_SQLITE_STATIC_PROVIDER
    "${CREXXRAG_SQLITE_PROVIDER_DIR}/rxsqlite${CMAKE_STATIC_LIBRARY_SUFFIX}")
foreach(crexxrag_sqlite_artifact IN ITEMS
        "${CREXXRAG_SQLITE_DYNAMIC_PROVIDER}"
        "${CREXXRAG_SQLITE_STATIC_PROVIDER}")
    if(NOT EXISTS "${crexxrag_sqlite_artifact}")
        message(FATAL_ERROR
            "The installed CREXX package does not provide ${crexxrag_sqlite_artifact}; install a CREXX build with the rxsqlite component")
    endif()
endforeach()

include(cmake/CrexxRagApplication.cmake)

file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/crexxrag-product")
configure_file("${CMAKE_CURRENT_LIST_DIR}/cmake/crexxrag-launcher.in"
    "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag" @ONLY)
file(CHMOD "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
add_custom_command(
    OUTPUT "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag.rxbin"
    COMMAND "${CMAKE_COMMAND}" -E rm -rf
        "${CMAKE_BINARY_DIR}/crexxrag-product/providers"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different
        "${CREXXRAG_APPLICATION_RXBIN}"
        "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag.rxbin"
    DEPENDS "${CREXXRAG_APPLICATION_RXBIN}"
    COMMENT "Staging the runnable crexxrag product directory"
    VERBATIM)
add_custom_target(crexxrag_product ALL
    DEPENDS "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag.rxbin")

set(CREXXRAG_NATIVE_APPLICATION
    "${CMAKE_BINARY_DIR}/crexxrag-native/package/crexxrag${CMAKE_EXECUTABLE_SUFFIX}")
add_custom_command(
    OUTPUT "${CREXXRAG_NATIVE_APPLICATION}"
    BYPRODUCTS
        "${CMAKE_BINARY_DIR}/crexxrag-native/package/crexxrag.rxbin"
        "${CMAKE_BINARY_DIR}/crexxrag-native/package/crexxrag-native.map"
        "${CMAKE_BINARY_DIR}/crexxrag-native/package/native-build.txt"
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_CREXX_EXECUTABLE=${CREXX_EXECUTABLE}"
        "-DCPRAG_APPLICATION_PROJECT_RXBIN=${CREXXRAG_APPLICATION_PROJECT_RXBIN}"
        "-DCPRAG_OUTPUT_DIR=${CMAKE_BINARY_DIR}/crexxrag-native"
        "-DCMAKE_EXECUTABLE_SUFFIX=${CMAKE_EXECUTABLE_SUFFIX}"
        -P "${CMAKE_CURRENT_LIST_DIR}/cmake/AttemptNativeCrexxRag.cmake"
    DEPENDS
        "${CREXXRAG_APPLICATION_RXBIN}"
        "${CREXXRAG_APPLICATION_PROJECT_RXBIN}"
        "${CREXXRAG_SQLITE_STATIC_PROVIDER}"
        "${CREXX_EXECUTABLE}"
        "${CREXX_BUILDINFO_FILE}"
        "${CMAKE_CURRENT_LIST_DIR}/cmake/AttemptNativeCrexxRag.cmake"
    COMMENT "Packaging the native crexxrag executable"
    USES_TERMINAL
    VERBATIM)
add_custom_target(crexxrag_native ALL
    DEPENDS "${CREXXRAG_NATIVE_APPLICATION}")

install(FILES "${CREXXRAG_APPLICATION_RXBIN}"
    DESTINATION "${CMAKE_INSTALL_LIBEXECDIR}/crexxrag")
install(FILES "${CREXXRAG_ADDRESS_RXBIN}"
    DESTINATION "${CMAKE_INSTALL_LIBEXECDIR}/crexxrag")
install(PROGRAMS
    "${CMAKE_BINARY_DIR}/crexxrag-native/package/crexxrag${CMAKE_EXECUTABLE_SUFFIX}"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")
# Upgrades from the incubating provider must not leave its private dynamic
# module beside the supported CREXX-owned rxsqlite component.  Remove only the
# exact path formerly installed by this project; leave the directory and any
# unrelated operator-managed files untouched.
set(crexxrag_legacy_sqlite_provider
    "${CMAKE_INSTALL_LIBEXECDIR}/crexxrag/providers/rx_sqlite_boundary.rxplugin")
install(CODE "
set(crexxrag_legacy_sqlite_provider_path
    \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${crexxrag_legacy_sqlite_provider}\")
if(EXISTS \"\${crexxrag_legacy_sqlite_provider_path}\")
    file(REMOVE \"\${crexxrag_legacy_sqlite_provider_path}\")
    message(STATUS
        \"Removed obsolete cREXX-RAG SQLite provider \${crexxrag_legacy_sqlite_provider_path}\")
endif()
")
install(DIRECTORY crexx/application/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexxrag/application"
    FILES_MATCHING PATTERN "*.crexx" PATTERN "*.conf" PATTERN "*.tsv" PATTERN "*.txt"
    PATTERN "tests" EXCLUDE)
install(DIRECTORY crexx/providers/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexxrag/providers"
    FILES_MATCHING PATTERN "*.crexx"
    PATTERN "tests" EXCLUDE)
install(DIRECTORY skills/ DESTINATION "${CMAKE_INSTALL_DATADIR}/crexxrag/skills")
install(DIRECTORY docs/tutorial/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexxrag/tutorial"
    FILES_MATCHING
    PATTERN "README.md"
    PATTERN "*.conf"
    PATTERN "*.tsv"
    PATTERN "*.txt")
install(FILES README.md
    DESTINATION "${CMAKE_INSTALL_DOCDIR}"
    RENAME PRODUCT-README.md)
install(DIRECTORY docs/
    DESTINATION "${CMAKE_INSTALL_DOCDIR}"
    FILES_MATCHING PATTERN "*.md")

if(DEFINED ENV{HOME} AND NOT "$ENV{HOME}" STREQUAL "")
    set(crexxrag_default_local_prefix "$ENV{HOME}/.local")
else()
    set(crexxrag_default_local_prefix "${CMAKE_INSTALL_PREFIX}")
endif()
set(CREXXRAG_LOCAL_INSTALL_PREFIX "${crexxrag_default_local_prefix}"
    CACHE PATH "Prefix used by the install-local target")
add_custom_target(install-local
    COMMAND "${CMAKE_COMMAND}" --install "${CMAKE_BINARY_DIR}"
        --prefix "${CREXXRAG_LOCAL_INSTALL_PREFIX}"
    DEPENDS crexxrag_native crexxrag_address
    COMMENT "Installing crexxrag to ${CREXXRAG_LOCAL_INSTALL_PREFIX}"
    USES_TERMINAL
    VERBATIM)

if(CREXXRAG_BUILD_TESTS)
    enable_testing()
    add_executable(crexxrag_provider_fixture tests/provider_fixture.cpp)
    include(cmake/CrexxRagTests.cmake)
endif()
