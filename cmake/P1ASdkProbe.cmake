foreach(required_var
        CPRAG_CREXX_PREFIX CPRAG_CREXX_DIR CPRAG_CREXX_VERSION
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_GENERATOR CPRAG_MAKE_PROGRAM CPRAG_PROBE_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

set(generator_args -G "${CPRAG_GENERATOR}")
if(NOT CPRAG_MAKE_PROGRAM STREQUAL "")
    list(APPEND generator_args "-DCMAKE_MAKE_PROGRAM=${CPRAG_MAKE_PROGRAM}")
endif()

file(REAL_PATH "${CPRAG_CREXX_PREFIX}" selected_prefix)
foreach(selected_path IN ITEMS
        "${CPRAG_CREXX_DIR}" "${CPRAG_RXC}" "${CPRAG_RXAS}"
        "${CPRAG_RXVME}" "${CPRAG_RXBVM}" "${CPRAG_CREXX_BIN_DIR}")
    file(REAL_PATH "${selected_path}" resolved_path)
    string(FIND "${resolved_path}" "${selected_prefix}/" prefix_position)
    if(NOT prefix_position EQUAL 0)
        message(FATAL_ERROR "Selected CREXX path escaped scratch prefix: ${resolved_path}")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(probe_build "${CPRAG_WORK_DIR}/external-build")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -S "${CPRAG_PROBE_SOURCE}" -B "${probe_build}"
        ${generator_args}
        "-DCMAKE_PREFIX_PATH=${selected_prefix}"
        "-DCREXX_DIR=${CPRAG_CREXX_DIR}"
        "-DCMAKE_C_FLAGS=-Werror"
    OUTPUT_VARIABLE configure_out ERROR_VARIABLE configure_err RESULT_VARIABLE configure_result)
if(NOT configure_result EQUAL 0)
    message(FATAL_ERROR "Installed-package external configure failed:\n${configure_out}\n${configure_err}")
endif()
execute_process(
    COMMAND "${CMAKE_COMMAND}" --build "${probe_build}"
        --target _sdk_probe _sdk_probe_bad --verbose
    OUTPUT_VARIABLE build_out ERROR_VARIABLE build_err RESULT_VARIABLE build_result)
if(NOT build_result EQUAL 0)
    message(FATAL_ERROR "Installed-package external build failed:\n${build_out}\n${build_err}")
endif()
string(FIND "${build_out}" "${CPRAG_CREXX_PREFIX}/include" selected_include_position)
if(selected_include_position EQUAL -1)
    string(FIND "${build_out}" "${selected_prefix}/include" selected_include_position)
endif()
if(selected_include_position EQUAL -1)
    message(FATAL_ERROR "External verbose build did not prove selected-prefix headers")
endif()

set(import_path "${probe_build}/bin;${CPRAG_CREXX_BIN_DIR}")
file(WRITE "${CPRAG_WORK_DIR}/commands-and-output.txt"
    "configure:\n${configure_out}${configure_err}\nbuild:\n${build_out}${build_err}\n")
foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/sdk-probe-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${import_path}"
            -o "${program}" "${CPRAG_PROBE_SOURCE}/sdk_probe.crexx"
        OUTPUT_VARIABLE rxc_out ERROR_VARIABLE rxc_err RESULT_VARIABLE rxc_result)
    if(NOT rxc_result EQUAL 0)
        message(FATAL_ERROR "${mode} external consumer compile failed:\n${rxc_out}\n${rxc_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        OUTPUT_VARIABLE rxas_out ERROR_VARIABLE rxas_err RESULT_VARIABLE rxas_result)
    if(NOT rxas_result EQUAL 0)
        message(FATAL_ERROR "${mode} external consumer assembly failed:\n${rxas_out}\n${rxas_err}")
    endif()
    file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt"
        "${mode} rxc:\n${rxc_out}${rxc_err}\n${mode} rxas:\n${rxas_out}${rxas_err}\n")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(
            COMMAND "${runtime}" -l "${import_path}" "${program}"
                rx_sdk_probe library -a "${CPRAG_CREXX_VERSION}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err RESULT_VARIABLE vm_result)
        string(FIND "${vm_out}" "SDK_VERSION=${CPRAG_CREXX_VERSION}" version_position)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "SDK_ADD_RESULT=42"
                OR version_position EQUAL -1)
            message(FATAL_ERROR "${mode}/${runtime_name} external consumer failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt"
            "${mode}/${runtime_name}:\n${vm_out}${vm_err}\n")
    endforeach()

    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} --no-localisation -i "${import_path}"
            -o "${CPRAG_WORK_DIR}/sdk-probe-bad-${mode}"
            "${CPRAG_PROBE_SOURCE}/sdk_probe_bad.crexx"
        OUTPUT_VARIABLE bad_out ERROR_VARIABLE bad_err RESULT_VARIABLE bad_result)
    if(bad_result EQUAL 0)
        message(FATAL_ERROR "${mode} malformed RXPA signature unexpectedly compiled")
    endif()
    set(diagnostic "${bad_out}${bad_err}")
    if(diagnostic MATCHES "INTERNAL_ERROR"
            OR NOT diagnostic MATCHES "RXPA_IMPORT_SIGNATURE_INVALID"
            OR NOT diagnostic MATCHES "field=\"arguments\""
            OR NOT diagnostic MATCHES "import_file=\"rx_sdk_probe_bad.rxplugin\"")
        message(FATAL_ERROR "${mode} malformed RXPA diagnostic mismatch:\n${diagnostic}")
    endif()
    file(APPEND "${CPRAG_WORK_DIR}/commands-and-output.txt"
        "${mode} structured malformed-signature diagnostic:\n${diagnostic}\n")
endforeach()

foreach(fingerprint IN ITEMS
        "${selected_prefix}/include/rxpa/crexxpa.h"
        "${selected_prefix}/include/crexx_version.h"
        "${selected_prefix}/include/platform/rxinteger.h"
        "${CPRAG_CREXX_DIR}/CREXXConfig.cmake"
        "${CPRAG_CREXX_DIR}/RXPluginFunction.cmake"
        "${CPRAG_RXC}" "${CPRAG_RXAS}" "${CPRAG_RXVME}" "${CPRAG_RXBVM}"
        "${probe_build}/bin/rx_sdk_probe.rxplugin"
        "${probe_build}/bin/rx_sdk_probe_bad.rxplugin")
    file(SHA256 "${fingerprint}" fingerprint_hash)
    file(APPEND "${CPRAG_WORK_DIR}/selected-prefix-manifest.txt"
        "${fingerprint_hash}  ${fingerprint}\n")
endforeach()
message(STATUS
    "P1A SDK passed installed-package provenance, named signatures, structured negatives, noopt/opt, rxvme/rxbvm")
