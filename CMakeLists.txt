cmake_minimum_required(VERSION 3.21)

project(crexxrag
    VERSION 0.1.0
    DESCRIPTION "cREXX local RAG and typed-graph knowledge store"
    LANGUAGES C CXX)

include(GNUInstallDirs)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(CREXXRAG_BUILD_TESTS "Build crexxrag regression and provider tests" ON)

find_package(CREXX CONFIG REQUIRED)
find_package(SQLite3 REQUIRED)

set(CREXX_EXECUTABLE "${CREXX_crexx_EXECUTABLE}")
set(CREXX_RXC_EXECUTABLE "${CREXX_rxc_EXECUTABLE}")
set(CREXX_RXAS_EXECUTABLE "${CREXX_rxas_EXECUTABLE}")
set(CREXX_RXLINK_EXECUTABLE "${CREXX_rxlink_EXECUTABLE}")
set(CREXX_RXVME_EXECUTABLE "${CREXX_rxvme_EXECUTABLE}")
set(CREXX_RXBVM_EXECUTABLE "${CREXX_rxbvm_EXECUTABLE}")
set(CREXX_INSTALL_BIN_DIR "${CREXX_BIN_DIR}")

message(STATUS
    "Using installed CREXX package ${CREXX_VERSION_DISPLAY} from ${CREXX_PACKAGE_PREFIX}")

# Keep imported targets first and legacy variables last. CREXX native packaging
# force-loads the static provider, so link selection must remain deterministic.
if(TARGET SQLite3::SQLite3)
    set(CREXXRAG_SQLITE_LINK SQLite3::SQLite3)
elseif(TARGET SQLite::SQLite3)
    set(CREXXRAG_SQLITE_LINK SQLite::SQLite3)
else()
    set(CREXXRAG_SQLITE_LINK ${SQLite3_LIBRARIES})
    set(CREXXRAG_SQLITE_INCLUDE_DIRS ${SQLite3_INCLUDE_DIRS})
endif()

if(NOT TARGET CREXX::RXPA)
    message(FATAL_ERROR "The installed CREXX package must provide CREXX::RXPA")
endif()

set(CREXX_RXPA_PLUGIN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
add_dynamic_plugin_target(_sqlite_boundary native/sqlite/sqlite_boundary.c)
target_link_libraries(_sqlite_boundary PRIVATE ${CREXXRAG_SQLITE_LINK})
if(CREXXRAG_SQLITE_INCLUDE_DIRS)
    target_include_directories(_sqlite_boundary PRIVATE ${CREXXRAG_SQLITE_INCLUDE_DIRS})
endif()

add_static_plugin_target(_sqlite_boundary native/sqlite/sqlite_boundary.c)
target_link_libraries(_sqlite_boundary_static PRIVATE ${CREXXRAG_SQLITE_LINK})
if(CREXXRAG_SQLITE_INCLUDE_DIRS)
    target_include_directories(_sqlite_boundary_static PRIVATE ${CREXXRAG_SQLITE_INCLUDE_DIRS})
endif()
add_rxpa_provider_package(_sqlite_boundary
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/providers")

set(CREXXRAG_APPLICATION_DIR "${CMAKE_BINARY_DIR}/crexx-application")
set(CREXXRAG_APPLICATION_RXBIN "${CREXXRAG_APPLICATION_DIR}/crexxrag.rxbin")
set(CREXXRAG_PROVIDER_DIR "${CMAKE_CURRENT_LIST_DIR}/crexx/providers")
set(CREXXRAG_APP_DIR "${CMAKE_CURRENT_LIST_DIR}/crexx/application")
set(CREXXRAG_APPLICATION_SOURCES
    "${CREXXRAG_PROVIDER_DIR}/provider_contract.crexx"
    "${CREXXRAG_PROVIDER_DIR}/provider_catalog.crexx"
    "${CREXXRAG_PROVIDER_DIR}/provider_http.crexx"
    "${CREXXRAG_PROVIDER_DIR}/industrial_provider.crexx"
    "${CREXXRAG_PROVIDER_DIR}/codex_provider.crexx"
    "${CREXXRAG_APP_DIR}/ragmodel.crexx"
    "${CREXXRAG_APP_DIR}/ragevidence.crexx"
    "${CREXXRAG_APP_DIR}/ragjob.crexx"
    "${CREXXRAG_APP_DIR}/ragconfig.crexx"
    "${CREXXRAG_APP_DIR}/ragconfigfile.crexx"
    "${CREXXRAG_APP_DIR}/ragprofile.crexx"
    "${CREXXRAG_APP_DIR}/ragregistry.crexx"
    "${CREXXRAG_APP_DIR}/ragschema.crexx"
    "${CREXXRAG_APP_DIR}/ragfile.crexx"
    "${CREXXRAG_APP_DIR}/ragstore.crexx"
    "${CREXXRAG_APP_DIR}/ragbackup.crexx"
    "${CREXXRAG_APP_DIR}/ragrepository.crexx"
    "${CREXXRAG_APP_DIR}/ragcanonical.crexx"
    "${CREXXRAG_APP_DIR}/ragplanning.crexx"
    "${CREXXRAG_APP_DIR}/ragtrace.crexx"
    "${CREXXRAG_APP_DIR}/ragcommand.crexx"
    "${CREXXRAG_APP_DIR}/ragingest.crexx"
    "${CREXXRAG_APP_DIR}/ragfolder.crexx"
    "${CREXXRAG_APP_DIR}/ragclaims.crexx"
    "${CREXXRAG_APP_DIR}/ragimprove.crexx"
    "${CREXXRAG_APP_DIR}/ragproposalio.crexx"
    "${CREXXRAG_APP_DIR}/ragwork.crexx"
    "${CREXXRAG_APP_DIR}/ragquery.crexx"
    "${CREXXRAG_APP_DIR}/ragembedding.crexx"
    "${CREXXRAG_APP_DIR}/ragretrieval.crexx"
    "${CREXXRAG_APP_DIR}/ragevidencejson.crexx"
    "${CREXXRAG_APP_DIR}/ragfoundation.crexx"
    "${CREXXRAG_APP_DIR}/ragprocess.crexx"
    "${CREXXRAG_APP_DIR}/ragproviderdiagnostics.crexx"
    "${CREXXRAG_APP_DIR}/ragapplicationprovider.crexx"
    "${CREXXRAG_APP_DIR}/ragqueryprovider.crexx"
    "${CREXXRAG_APP_DIR}/ragquerypolicy.crexx"
    "${CREXXRAG_APP_DIR}/ragproduct.crexx"
    "${CREXXRAG_APP_DIR}/config/architecture_local_config.crexx"
    "${CREXXRAG_APP_DIR}/config/profiles/generic_profile.crexx"
    "${CREXXRAG_APP_DIR}/config/profiles/it_architecture_profile.crexx"
    "${CREXXRAG_APP_DIR}/config/operator_registry.crexx"
    "${CREXXRAG_APP_DIR}/surfaces/ragmcp.crexx"
    "${CREXXRAG_APP_DIR}/surfaces/rag_address_environment.crexx"
    "${CREXXRAG_APP_DIR}/surfaces/crexxrag_cli.crexx")

add_custom_command(
    OUTPUT "${CREXXRAG_APPLICATION_RXBIN}"
    BYPRODUCTS
        "${CREXXRAG_APPLICATION_DIR}/crexxrag.map"
        "${CREXXRAG_APPLICATION_DIR}/crexxrag.rxproviders"
        "${CREXXRAG_APPLICATION_DIR}/artifact.txt"
        "${CREXXRAG_APPLICATION_DIR}/providers/rx_sqlite_boundary.rxplugin"
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
        "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
        "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
        "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
        "-DCPRAG_PLUGIN_PROVIDER_DIR=${CMAKE_BINARY_DIR}/bin/providers"
        "-DCPRAG_APP_DIR=${CREXXRAG_APP_DIR}"
        "-DCPRAG_PROVIDER_DIR=${CREXXRAG_PROVIDER_DIR}"
        "-DCPRAG_OUTPUT_DIR=${CREXXRAG_APPLICATION_DIR}"
        -P "${CMAKE_CURRENT_LIST_DIR}/cmake/BuildCrexxRagApplication.cmake"
    DEPENDS
        ${CREXXRAG_APPLICATION_SOURCES}
        _sqlite_boundary _sqlite_boundary_static
        "${CMAKE_CURRENT_LIST_DIR}/cmake/BuildCrexxRagApplication.cmake"
    COMMENT "Building the linked Level-G crexxrag application"
    VERBATIM)
add_custom_target(crexxrag_application ALL DEPENDS "${CREXXRAG_APPLICATION_RXBIN}")

file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/crexxrag-product")
configure_file("${CMAKE_CURRENT_LIST_DIR}/cmake/crexxrag-launcher.in"
    "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag" @ONLY)
file(CHMOD "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
add_custom_command(
    OUTPUT "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag.rxbin"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different
        "${CREXXRAG_APPLICATION_RXBIN}"
        "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag.rxbin"
    COMMAND "${CMAKE_COMMAND}" -E copy_directory
        "${CREXXRAG_APPLICATION_DIR}/providers"
        "${CMAKE_BINARY_DIR}/crexxrag-product/providers"
    DEPENDS "${CREXXRAG_APPLICATION_RXBIN}"
    COMMENT "Staging the runnable crexxrag product directory"
    VERBATIM)
add_custom_target(crexxrag_product ALL
    DEPENDS "${CMAKE_BINARY_DIR}/crexxrag-product/crexxrag.rxbin")

add_custom_target(crexxrag_native ALL
    COMMAND "${CMAKE_COMMAND}"
        "-DCPRAG_CREXX_PACKAGE_PREFIX=${CREXX_PACKAGE_PREFIX}"
        "-DCPRAG_APPLICATION_DIR=${CREXXRAG_APPLICATION_DIR}"
        "-DCPRAG_SQLITE_PROVIDER_ARCHIVE=${CMAKE_BINARY_DIR}/bin/providers/rx_sqlite_boundary${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "-DCPRAG_MAIN_SOURCE=${CREXXRAG_APP_DIR}/surfaces/crexxrag_cli.crexx"
        "-DCPRAG_OUTPUT_DIR=${CMAKE_BINARY_DIR}/crexxrag-native"
        "-DCMAKE_EXECUTABLE_SUFFIX=${CMAKE_EXECUTABLE_SUFFIX}"
        -P "${CMAKE_CURRENT_LIST_DIR}/cmake/AttemptNativeCrexxRag.cmake"
    DEPENDS crexxrag_application _sqlite_boundary_static
        "${CMAKE_CURRENT_LIST_DIR}/cmake/AttemptNativeCrexxRag.cmake"
    COMMENT "Packaging the native crexxrag executable"
    USES_TERMINAL VERBATIM)

install(FILES "${CREXXRAG_APPLICATION_RXBIN}"
    DESTINATION "${CMAKE_INSTALL_LIBEXECDIR}/crexxrag")
install(PROGRAMS
    "${CMAKE_BINARY_DIR}/crexxrag-native/package/crexxrag${CMAKE_EXECUTABLE_SUFFIX}"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(FILES "${CREXXRAG_APPLICATION_DIR}/providers/rx_sqlite_boundary.rxplugin"
    DESTINATION "${CMAKE_INSTALL_LIBEXECDIR}/crexxrag/providers")
install(DIRECTORY crexx/application/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexxrag/application"
    FILES_MATCHING PATTERN "*.crexx" PATTERN "*.conf"
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
    PATTERN "*.txt")
install(FILES README.md
    DESTINATION "${CMAKE_INSTALL_DOCDIR}"
    RENAME PRODUCT-README.md)
install(DIRECTORY docs/
    DESTINATION "${CMAKE_INSTALL_DOCDIR}"
    FILES_MATCHING PATTERN "*.md")

if(CREXXRAG_BUILD_TESTS)
    enable_testing()
    add_executable(crexxrag_provider_fixture tests/provider_fixture.cpp)
    find_package(Threads REQUIRED)
    add_executable(sqlite_provider_thread_test
        native/sqlite/tests/sqlite_boundary_thread_test.c)
    target_include_directories(sqlite_provider_thread_test PRIVATE
        "${CMAKE_CURRENT_LIST_DIR}/native/sqlite")
    target_link_libraries(sqlite_provider_thread_test PRIVATE
        CREXX::RXPA ${CREXXRAG_SQLITE_LINK} Threads::Threads)
    if(CREXXRAG_SQLITE_INCLUDE_DIRS)
        target_include_directories(sqlite_provider_thread_test PRIVATE
            ${CREXXRAG_SQLITE_INCLUDE_DIRS})
    endif()
    add_test(NAME sqlite_provider_thread_sessions
        COMMAND sqlite_provider_thread_test
            "${CMAKE_BINARY_DIR}/sqlite-provider-thread-sessions.sqlite")
    set_tests_properties(sqlite_provider_thread_sessions PROPERTIES
        LABELS "sqlite;rxpa;session-affine;thread-safe;fullmutex")

    include(cmake/CrexxRagTests.cmake)
endif()
