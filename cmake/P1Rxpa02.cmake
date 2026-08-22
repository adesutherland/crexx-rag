foreach(required_var
        CPRAG_CREXX_PREFIX CPRAG_CREXX_DIR CPRAG_CREXX_VERSION
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_GENERATOR CPRAG_MAKE_PROGRAM CPRAG_CONSUMER_SOURCE
        CPRAG_PACKAGE_PROBE_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

set(generator_args -G "${CPRAG_GENERATOR}")
if(NOT CPRAG_MAKE_PROGRAM STREQUAL "")
    list(APPEND generator_args "-DCMAKE_MAKE_PROGRAM=${CPRAG_MAKE_PROGRAM}")
endif()

file(REAL_PATH "${CPRAG_CREXX_PREFIX}" selected_prefix)
set(required_files
    "${selected_prefix}/BUILDINFO"
    "${selected_prefix}/include/crexx_version.h"
    "${selected_prefix}/include/crexxsaa.h"
    "${selected_prefix}/include/platform/rxinteger.h"
    "${selected_prefix}/include/rxpa/crexxpa.h"
    "${CPRAG_CREXX_DIR}/CREXXConfig.cmake"
    "${CPRAG_CREXX_DIR}/CREXXConfigVersion.cmake"
    "${CPRAG_CREXX_DIR}/CREXXTargets.cmake"
    "${CPRAG_CREXX_DIR}/RXPluginFunction.cmake"
    "${CPRAG_RXC}"
    "${CPRAG_RXAS}"
    "${CPRAG_RXVME}"
    "${CPRAG_RXBVM}")
foreach(required_file IN LISTS required_files)
    if(NOT EXISTS "${required_file}")
        message(FATAL_ERROR "Required development-package file is missing: ${required_file}")
    endif()
endforeach()

file(READ "${selected_prefix}/BUILDINFO" buildinfo)
string(REGEX MATCH "display=[^\r\n]*" buildinfo_display "${buildinfo}")
if(NOT buildinfo_display STREQUAL "display=${CPRAG_CREXX_VERSION}")
    message(FATAL_ERROR
        "BUILDINFO display does not match the selected package: ${CPRAG_CREXX_VERSION}")
endif()
if(NOT buildinfo MATCHES "base_version=([0-9]+\\.[0-9]+\\.[0-9]+)")
    message(FATAL_ERROR "BUILDINFO does not contain a semantic base_version")
endif()
set(base_version "${CMAKE_MATCH_1}")

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "selected_prefix=${selected_prefix}\n"
    "display=${CPRAG_CREXX_VERSION}\n"
    "base_version=${base_version}\n")

set(compatible_build "${CPRAG_WORK_DIR}/compatible-package")
execute_process(
    COMMAND "${CMAKE_COMMAND}"
        -S "${CPRAG_PACKAGE_PROBE_SOURCE}"
        -B "${compatible_build}"
        ${generator_args}
        "-DCREXX_DIR=${CPRAG_CREXX_DIR}"
        "-DCREXX_REQUIRED_VERSION=${base_version}"
    OUTPUT_VARIABLE compatible_out
    ERROR_VARIABLE compatible_err
    RESULT_VARIABLE compatible_result)
if(NOT compatible_result EQUAL 0)
    message(FATAL_ERROR
        "Exact compatible package was rejected:\n${compatible_out}\n${compatible_err}")
endif()
file(READ "${compatible_build}/package-probe.txt" compatible_report)
string(REGEX MATCH "display=[^\r\n]*" compatible_display "${compatible_report}")
if(NOT compatible_display STREQUAL "display=${CPRAG_CREXX_VERSION}")
    message(FATAL_ERROR "Compatible package report did not match BUILDINFO")
endif()
file(APPEND "${report}"
    "compatible package configure:\n${compatible_out}${compatible_err}${compatible_report}\n")

set(missing_root "${CPRAG_WORK_DIR}/missing-prefix")
set(missing_build "${CPRAG_WORK_DIR}/missing-package")
execute_process(
    COMMAND "${CMAKE_COMMAND}"
        -S "${CPRAG_PACKAGE_PROBE_SOURCE}"
        -B "${missing_build}"
        ${generator_args}
        "-DCREXX_DIR=${missing_root}/lib/cmake/CREXX"
        "-DCMAKE_PREFIX_PATH=${missing_root}"
        -DCMAKE_FIND_USE_PACKAGE_REGISTRY=FALSE
        -DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=FALSE
        -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=FALSE
        -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=FALSE
        -DCMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH=FALSE
        -DCMAKE_FIND_USE_CMAKE_PATH=FALSE
    OUTPUT_VARIABLE missing_out
    ERROR_VARIABLE missing_err
    RESULT_VARIABLE missing_result)
set(missing_diagnostic "${missing_out}${missing_err}")
if(missing_result EQUAL 0
        OR NOT missing_diagnostic MATCHES "CREXXConfig.cmake"
        OR NOT missing_diagnostic MATCHES "CMAKE_PREFIX_PATH|CREXX_DIR")
    message(FATAL_ERROR
        "Missing-package diagnostic was not actionable:\n${missing_diagnostic}")
endif()
file(APPEND "${report}"
    "missing package diagnostic:\n${missing_diagnostic}\n")

set(incompatible_build "${CPRAG_WORK_DIR}/incompatible-package")
execute_process(
    COMMAND "${CMAKE_COMMAND}"
        -S "${CPRAG_PACKAGE_PROBE_SOURCE}"
        -B "${incompatible_build}"
        ${generator_args}
        "-DCREXX_DIR=${CPRAG_CREXX_DIR}"
        -DCREXX_REQUIRED_VERSION=2.0.0
    OUTPUT_VARIABLE incompatible_out
    ERROR_VARIABLE incompatible_err
    RESULT_VARIABLE incompatible_result)
set(incompatible_diagnostic "${incompatible_out}${incompatible_err}")
if(incompatible_result EQUAL 0
        OR NOT incompatible_diagnostic MATCHES "2.0.0"
        OR NOT incompatible_diagnostic MATCHES "version: ${base_version}|version \"${base_version}\"")
    message(FATAL_ERROR
        "Incompatible-package diagnostic was not actionable:\n${incompatible_diagnostic}")
endif()
file(APPEND "${report}"
    "incompatible package diagnostic:\n${incompatible_diagnostic}\n")

set(consumer_build "${CPRAG_WORK_DIR}/external-build")
execute_process(
    COMMAND "${CMAKE_COMMAND}"
        -S "${CPRAG_CONSUMER_SOURCE}"
        -B "${consumer_build}"
        ${generator_args}
        "-DCREXX_DIR=${CPRAG_CREXX_DIR}"
        "-DCREXX_REQUIRED_VERSION=${base_version}"
        -DCPRAG_ALLOW_VENDORED_CREXXPA=OFF
        -DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF
        -DCMAKE_C_FLAGS=-Werror
    OUTPUT_VARIABLE consumer_configure_out
    ERROR_VARIABLE consumer_configure_err
    RESULT_VARIABLE consumer_configure_result)
if(NOT consumer_configure_result EQUAL 0)
    message(FATAL_ERROR
        "Consumer configure failed:\n${consumer_configure_out}\n${consumer_configure_err}")
endif()
execute_process(
    COMMAND "${CMAKE_COMMAND}" --build "${consumer_build}"
        --target _external_consumer --verbose
    OUTPUT_VARIABLE consumer_build_out
    ERROR_VARIABLE consumer_build_err
    RESULT_VARIABLE consumer_build_result)
if(NOT consumer_build_result EQUAL 0)
    message(FATAL_ERROR
        "Consumer build failed:\n${consumer_build_out}\n${consumer_build_err}")
endif()
file(APPEND "${report}"
    "consumer configure:\n${consumer_configure_out}${consumer_configure_err}"
    "consumer build:\n${consumer_build_out}${consumer_build_err}\n")

set(import_path "${consumer_build}/bin;${CPRAG_CREXX_BIN_DIR}")
set(program "${CPRAG_WORK_DIR}/external-consumer")
execute_process(
    COMMAND "${CPRAG_RXC}" -i "${import_path}" -o "${program}"
        "${CPRAG_CONSUMER_SOURCE}/external_consumer.crexx"
    OUTPUT_VARIABLE rxc_out ERROR_VARIABLE rxc_err RESULT_VARIABLE rxc_result)
if(NOT rxc_result EQUAL 0)
    message(FATAL_ERROR "Consumer compile failed:\n${rxc_out}\n${rxc_err}")
endif()
execute_process(
    COMMAND "${CPRAG_RXAS}" -o "${program}" "${program}"
    OUTPUT_VARIABLE rxas_out ERROR_VARIABLE rxas_err RESULT_VARIABLE rxas_result)
if(NOT rxas_result EQUAL 0)
    message(FATAL_ERROR "Consumer assembly failed:\n${rxas_out}\n${rxas_err}")
endif()

foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    execute_process(
        COMMAND "${runtime}" -l "${import_path}" "${program}"
            rx_external_consumer library -a "${CPRAG_CREXX_VERSION}"
        OUTPUT_VARIABLE found_out ERROR_VARIABLE found_err RESULT_VARIABLE found_result)
    if(NOT found_result EQUAL 0
            OR NOT found_out MATCHES "P1_RXPA_01_OK.*result=42")
        message(FATAL_ERROR
            "${runtime_name} module discovery failed:\n${found_out}\n${found_err}")
    endif()
    execute_process(
        COMMAND "${runtime}" -l "${CPRAG_CREXX_BIN_DIR}" "${program}"
            rx_external_consumer library -a "${CPRAG_CREXX_VERSION}"
        OUTPUT_VARIABLE absent_out ERROR_VARIABLE absent_err RESULT_VARIABLE absent_result)
    set(absent_diagnostic "${absent_out}${absent_err}")
    if(absent_result EQUAL 0
            OR NOT absent_diagnostic MATCHES "ERROR reading module file rx_external_consumer")
        message(FATAL_ERROR
            "${runtime_name} missing-module diagnostic mismatch:\n${absent_diagnostic}")
    endif()
    file(APPEND "${report}"
        "${runtime_name} module found:\n${found_out}${found_err}"
        "${runtime_name} module absent:\n${absent_diagnostic}\n")
endforeach()

foreach(fingerprint IN LISTS required_files)
    file(SHA256 "${fingerprint}" fingerprint_hash)
    file(APPEND "${CPRAG_WORK_DIR}/development-package-manifest.txt"
        "${fingerprint_hash}  ${fingerprint}\n")
endforeach()
file(SHA256 "${consumer_build}/bin/rx_external_consumer.rxplugin" plugin_hash)
file(APPEND "${CPRAG_WORK_DIR}/development-package-manifest.txt"
    "${plugin_hash}  ${consumer_build}/bin/rx_external_consumer.rxplugin\n")

message(STATUS
    "P1-RXPA-02 passed development-package, compatibility, and dual-VM module-discovery checks")
