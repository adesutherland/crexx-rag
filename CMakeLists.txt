cmake_minimum_required(VERSION 3.21)

project(crexx-rag
    VERSION 0.1.0
    DESCRIPTION "Lightweight local GraphRAG core with CREXX and MCP frontends"
    LANGUAGES C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(CPRAG_BUILD_CLI "Build the crexx-rag command line tool" ON)
option(CPRAG_BUILD_MCP "Build the crexx-rag-mcp stdio server" ON)
option(CPRAG_BUILD_CREXX_PLUGIN "Build the CREXX rxpa plugin when CREXX_ROOT is available" ON)
option(CPRAG_BUILD_TESTS "Build unit tests" ON)
option(CPRAG_ENABLE_FAISS "Enable optional FAISS-backed vector index support" OFF)
option(CPRAG_ALLOW_VENDORED_CREXXPA "Allow temporary vendored crexxpa.h fallback until CREXX installs development headers" ON)
option(CPRAG_ALLOW_CREXX_SOURCE_FALLBACK "Allow building against a source checkout when installed CREXX headers are unavailable" OFF)

find_program(CREXX_EXECUTABLE crexx)
set(CREXX_RXPA_INCLUDE_DIR "" CACHE PATH "Installed CREXX rxpa include directory containing crexxpa.h")
set(CREXX_SOURCE_ROOT "${CMAKE_CURRENT_LIST_DIR}/../CREXX" CACHE PATH "Optional CREXX source checkout for development-only fallback builds")
set(CPRAG_VENDORED_CREXXPA_DIR "${CMAKE_CURRENT_LIST_DIR}/third_party/crexx-rxpa")

if(CREXX_EXECUTABLE)
    get_filename_component(CREXX_INSTALL_BIN_DIR "${CREXX_EXECUTABLE}" DIRECTORY)
    find_program(CREXX_RXC_EXECUTABLE rxc HINTS "${CREXX_INSTALL_BIN_DIR}")
    find_program(CREXX_RXAS_EXECUTABLE rxas HINTS "${CREXX_INSTALL_BIN_DIR}")
    find_program(CREXX_RXVME_EXECUTABLE rxvme HINTS "${CREXX_INSTALL_BIN_DIR}")
    if(NOT CREXX_RXPA_INCLUDE_DIR)
        foreach(candidate
                "${CREXX_INSTALL_BIN_DIR}"
                "${CREXX_INSTALL_BIN_DIR}/include"
                "${CREXX_INSTALL_BIN_DIR}/../include"
                "${CREXX_INSTALL_BIN_DIR}/../include/crexx"
                "${CREXX_INSTALL_BIN_DIR}/../rxpa")
            if(EXISTS "${candidate}/crexxpa.h")
                set(CREXX_RXPA_INCLUDE_DIR "${candidate}" CACHE PATH "Installed CREXX rxpa include directory containing crexxpa.h" FORCE)
                break()
            endif()
        endforeach()
    endif()
endif()

if(NOT CREXX_RXPA_INCLUDE_DIR
        AND CPRAG_ALLOW_VENDORED_CREXXPA
        AND EXISTS "${CPRAG_VENDORED_CREXXPA_DIR}/crexxpa.h")
    set(CREXX_RXPA_INCLUDE_DIR "${CPRAG_VENDORED_CREXXPA_DIR}" CACHE PATH "CREXX rxpa include directory containing crexxpa.h" FORCE)
    message(WARNING "Using vendored third_party/crexx-rxpa/crexxpa.h. TODO: remove this fallback once CREXX installs development headers.")
endif()

if(NOT CREXX_RXPA_INCLUDE_DIR
        AND CPRAG_ALLOW_CREXX_SOURCE_FALLBACK
        AND EXISTS "${CREXX_SOURCE_ROOT}/rxpa/crexxpa.h")
    set(CREXX_RXPA_INCLUDE_DIR "${CREXX_SOURCE_ROOT}/rxpa" CACHE PATH "CREXX rxpa include directory containing crexxpa.h" FORCE)
    message(WARNING "Using CREXX source checkout fallback for rxpa headers. Prefer an installed CREXX development header package.")
endif()

find_package(SQLite3 REQUIRED)

if(TARGET SQLite3::SQLite3)
    set(CPRAG_SQLITE_LINK SQLite3::SQLite3)
elseif(TARGET SQLite::SQLite3)
    set(CPRAG_SQLITE_LINK SQLite::SQLite3)
else()
    set(CPRAG_SQLITE_LINK ${SQLite3_LIBRARIES})
    set(CPRAG_SQLITE_INCLUDE_DIRS ${SQLite3_INCLUDE_DIRS})
endif()

set(CPRAG_FAISS_LINK "")
if(CPRAG_ENABLE_FAISS)
    find_package(faiss CONFIG QUIET)
    if(TARGET faiss)
        set(CPRAG_FAISS_LINK faiss)
    elseif(TARGET faiss::faiss)
        set(CPRAG_FAISS_LINK faiss::faiss)
    else()
        find_path(FAISS_INCLUDE_DIR faiss/IndexFlat.h)
        find_library(FAISS_LIBRARY faiss)
        if(FAISS_INCLUDE_DIR AND FAISS_LIBRARY)
            add_library(cprag_faiss UNKNOWN IMPORTED)
            set_target_properties(cprag_faiss PROPERTIES
                IMPORTED_LOCATION "${FAISS_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${FAISS_INCLUDE_DIR}")
            set(CPRAG_FAISS_LINK cprag_faiss)
        endif()
    endif()

    if(NOT CPRAG_FAISS_LINK)
        message(FATAL_ERROR "CPRAG_ENABLE_FAISS is ON, but FAISS was not found. Install FAISS or configure FAISS_INCLUDE_DIR/FAISS_LIBRARY.")
    endif()
endif()

add_library(cprag_core
    core/chunker.cpp
    core/ragcore.cpp)
add_library(crexx-rag::core ALIAS cprag_core)
target_include_directories(cprag_core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
        $<INSTALL_INTERFACE:include>)
if(CPRAG_SQLITE_INCLUDE_DIRS)
    target_include_directories(cprag_core PUBLIC ${CPRAG_SQLITE_INCLUDE_DIRS})
endif()
target_link_libraries(cprag_core PUBLIC ${CPRAG_SQLITE_LINK})
if(CPRAG_ENABLE_FAISS)
    target_compile_definitions(cprag_core PUBLIC CPRAG_HAVE_FAISS=1)
    target_link_libraries(cprag_core PUBLIC ${CPRAG_FAISS_LINK})
endif()

if(CPRAG_BUILD_CLI)
    add_executable(crexx-rag cli/main.cpp)
    target_link_libraries(crexx-rag PRIVATE cprag_core)
endif()

if(CPRAG_BUILD_MCP)
    add_executable(crexx-rag-mcp mcp/main.cpp)
    target_link_libraries(crexx-rag-mcp PRIVATE cprag_core)
endif()

if(CPRAG_BUILD_CREXX_PLUGIN)
    if(CREXX_RXPA_INCLUDE_DIR AND EXISTS "${CREXX_RXPA_INCLUDE_DIR}/crexxpa.h")
        add_library(_rag MODULE crexx/plugins/rag/rxrag.c)
        target_include_directories(_rag PRIVATE
            "${CREXX_RXPA_INCLUDE_DIR}"
            "${CMAKE_CURRENT_LIST_DIR}/include")
        target_compile_definitions(_rag PRIVATE BUILD_DLL "PLUGIN_ID=rx_rag")
        target_link_libraries(_rag PRIVATE cprag_core)
        set_target_properties(_rag PROPERTIES
            PREFIX "rx"
            SUFFIX ".rxplugin"
            LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
    else()
        message(WARNING "Installed CREXX rxpa header crexxpa.h was not found; skipping CREXX plugin. See docs/crexx-integration-issues.md.")
    endif()
endif()

if(CPRAG_BUILD_TESTS)
    enable_testing()
    add_executable(ragcore_smoke tests/ragcore_smoke.cpp)
    target_link_libraries(ragcore_smoke PRIVATE cprag_core)
    add_test(NAME ragcore_smoke COMMAND ragcore_smoke)

    if(CPRAG_BUILD_MCP AND TARGET crexx-rag-mcp)
        add_test(
            NAME mcp_smoke
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_MCP=$<TARGET_FILE:crexx-rag-mcp>"
                "-DCPRAG_CLI=$<TARGET_FILE:crexx-rag>"
                "-DCPRAG_FAISS_ENABLED=${CPRAG_ENABLE_FAISS}"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/mcp-smoke"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/McpSmoke.cmake")
    endif()

    if(CPRAG_BUILD_CREXX_PLUGIN
            AND TARGET _rag
            AND CREXX_EXECUTABLE
            AND CREXX_RXC_EXECUTABLE
            AND CREXX_RXAS_EXECUTABLE
            AND CREXX_RXVME_EXECUTABLE)
        add_test(
            NAME crexx_profile_smoke
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/profiles/balanced.crexx"
                "-DCPRAG_CREXX_SOURCE_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_rag>"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/crexx-profile-smoke"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/CrexxProfileSmoke.cmake")
    elseif(CPRAG_BUILD_CREXX_PLUGIN)
        message(STATUS "Skipping CREXX profile smoke test; installed rxc/rxas/rxvme was not found.")
    endif()
endif()
