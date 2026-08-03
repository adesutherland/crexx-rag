cmake_minimum_required(VERSION 3.24)
project(crexx_external_rxpa_consumer C)

option(CPRAG_ALLOW_VENDORED_CREXXPA "Disallowed external-consumer fallback" OFF)
option(CPRAG_ALLOW_CREXX_SOURCE_FALLBACK "Disallowed external-consumer fallback" OFF)

if(CPRAG_ALLOW_VENDORED_CREXXPA OR CPRAG_ALLOW_CREXX_SOURCE_FALLBACK)
    message(FATAL_ERROR
        "The external consumer must use the installed CREXX development package")
endif()

set(CREXX_REQUIRED_VERSION "" CACHE STRING
    "Optional exact CREXX package base version for compatibility checks")
if(CREXX_REQUIRED_VERSION STREQUAL "")
    find_package(CREXX CONFIG REQUIRED)
else()
    find_package(CREXX ${CREXX_REQUIRED_VERSION} EXACT CONFIG REQUIRED)
endif()
if(NOT TARGET CREXX::RXPA)
    message(FATAL_ERROR "The installed CREXX package does not export CREXX::RXPA")
endif()
if(NOT COMMAND add_dynamic_plugin_target)
    message(FATAL_ERROR
        "The installed CREXX package does not provide add_dynamic_plugin_target")
endif()

set(CREXX_RXPA_PLUGIN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
add_dynamic_plugin_target(_external_consumer external_consumer.c)

get_target_property(CREXX_RXPA_INCLUDES CREXX::RXPA INTERFACE_INCLUDE_DIRECTORIES)
file(WRITE "${CMAKE_BINARY_DIR}/package-report.txt"
    "version=${CREXX_VERSION}\n"
    "display=${CREXX_VERSION_DISPLAY}\n"
    "prefix=${CREXX_PACKAGE_PREFIX}\n"
    "rxpa_includes=${CREXX_RXPA_INCLUDES}\n")
