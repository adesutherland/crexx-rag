cmake_minimum_required(VERSION 3.24)
project(crexx_package_probe NONE)

set(CREXX_REQUIRED_VERSION "1.0.0" CACHE STRING
    "Exact CREXX package base version")
find_package(CREXX ${CREXX_REQUIRED_VERSION} EXACT CONFIG REQUIRED)

if(NOT TARGET CREXX::RXPA)
    message(FATAL_ERROR "Compatible CREXX package did not export CREXX::RXPA")
endif()
if(NOT COMMAND add_dynamic_plugin_target)
    message(FATAL_ERROR
        "Compatible CREXX package did not provide RXPluginFunction.cmake")
endif()

file(WRITE "${CMAKE_BINARY_DIR}/package-probe.txt"
    "version=${CREXX_VERSION}\n"
    "display=${CREXX_VERSION_DISPLAY}\n"
    "prefix=${CREXX_PACKAGE_PREFIX}\n")
