cmake_minimum_required(VERSION 3.24)
project(crexx_external_sdk_probe C)

find_package(CREXX CONFIG REQUIRED)

set(CREXX_RXPA_PLUGIN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
add_dynamic_plugin_target(_sdk_probe sdk_probe.c)
add_dynamic_plugin_target(_sdk_probe_bad sdk_probe_bad.c)
