foreach(required_var
        CPRAG_CREXX_PREFIX CPRAG_CREXX_DIR CPRAG_CREXX_VERSION
        CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_CONSUMER_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REAL_PATH "${CPRAG_CREXX_PREFIX}" selected_prefix)
foreach(selected_path IN ITEMS
        "${CPRAG_CREXX_DIR}" "${CPRAG_RXC}" "${CPRAG_RXAS}"
        "${CPRAG_RXVME}" "${CPRAG_RXBVM}" "${CPRAG_CREXX_BIN_DIR}")
    file(REAL_PATH "${selected_path}" resolved_path)
    string(FIND "${resolved_path}" "${selected_prefix}/" prefix_position)
    if(NOT prefix_position EQUAL 0)
        message(FATAL_ERROR
            "Selected CREXX path escaped the installed prefix: ${resolved_path}")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(consumer_build "${CPRAG_WORK_DIR}/external-build")
execute_process(
    COMMAND "${CMAKE_COMMAND}"
        -S "${CPRAG_CONSUMER_SOURCE}"
        -B "${consumer_build}"
        -G Ninja
        "-DCMAKE_PREFIX_PATH=${selected_prefix}"
        "-DCREXX_DIR=${CPRAG_CREXX_DIR}"
        -DCPRAG_ALLOW_VENDORED_CREXXPA=OFF
        -DCPRAG_ALLOW_CREXX_SOURCE_FALLBACK=OFF
        -DCMAKE_C_FLAGS=-Werror
    OUTPUT_VARIABLE configure_out
    ERROR_VARIABLE configure_err
    RESULT_VARIABLE configure_result)
if(NOT configure_result EQUAL 0)
    message(FATAL_ERROR
        "Installed-package external configure failed:\n${configure_out}\n${configure_err}")
endif()

execute_process(
    COMMAND "${CMAKE_COMMAND}" --build "${consumer_build}"
        --target _external_consumer --verbose
    OUTPUT_VARIABLE build_out
    ERROR_VARIABLE build_err
    RESULT_VARIABLE build_result)
if(NOT build_result EQUAL 0)
    message(FATAL_ERROR
        "Installed-package external build failed:\n${build_out}\n${build_err}")
endif()

file(READ "${consumer_build}/CMakeCache.txt" consumer_cache)
foreach(fallback IN ITEMS
        CPRAG_ALLOW_VENDORED_CREXXPA CPRAG_ALLOW_CREXX_SOURCE_FALLBACK)
    if(NOT consumer_cache MATCHES "${fallback}:BOOL=OFF")
        message(FATAL_ERROR "${fallback} was not retained as OFF")
    endif()
endforeach()

file(READ "${consumer_build}/build.ninja" build_graph)
string(FIND "${build_graph}" "${selected_prefix}/include" installed_include_position)
if(installed_include_position EQUAL -1)
    message(FATAL_ERROR "External build graph did not select installed headers")
endif()
if(DEFINED CPRAG_FORBIDDEN_CREXX_SOURCE_DIR
        AND NOT "${CPRAG_FORBIDDEN_CREXX_SOURCE_DIR}" STREQUAL "")
    file(REAL_PATH "${CPRAG_FORBIDDEN_CREXX_SOURCE_DIR}" forbidden_source)
    string(FIND "${build_graph}" "${forbidden_source}" forbidden_position)
    if(NOT forbidden_position EQUAL -1)
        message(FATAL_ERROR
            "External build graph selected the CREXX source checkout: ${forbidden_source}")
    endif()
endif()

set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "configure:\n${configure_out}${configure_err}\nbuild:\n${build_out}${build_err}\n")
set(import_path "${consumer_build}/bin;${CPRAG_CREXX_BIN_DIR}")
foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    set(program "${CPRAG_WORK_DIR}/external-consumer-${mode}")
    execute_process(
        COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${import_path}"
            -o "${program}" "${CPRAG_CONSUMER_SOURCE}/external_consumer.crexx"
        OUTPUT_VARIABLE rxc_out
        ERROR_VARIABLE rxc_err
        RESULT_VARIABLE rxc_result)
    if(NOT rxc_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} external consumer compile failed:\n${rxc_out}\n${rxc_err}")
    endif()
    execute_process(
        COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${program}" "${program}"
        OUTPUT_VARIABLE rxas_out
        ERROR_VARIABLE rxas_err
        RESULT_VARIABLE rxas_result)
    if(NOT rxas_result EQUAL 0)
        message(FATAL_ERROR
            "${mode} external consumer assembly failed:\n${rxas_out}\n${rxas_err}")
    endif()
    file(APPEND "${report}"
        "${mode} rxc:\n${rxc_out}${rxc_err}\n${mode} rxas:\n${rxas_out}${rxas_err}\n")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        execute_process(
            COMMAND "${runtime}" -l "${import_path}" "${program}"
                rx_external_consumer library -a "${CPRAG_CREXX_VERSION}"
            OUTPUT_VARIABLE vm_out
            ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result)
        string(FIND "${vm_out}"
            "P1_RXPA_01_OK version=${CPRAG_CREXX_VERSION} result=42"
            success_position)
        if(NOT vm_result EQUAL 0 OR success_position EQUAL -1)
            message(FATAL_ERROR
                "${mode}/${runtime_name} external consumer failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        file(APPEND "${report}"
            "${mode}/${runtime_name}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

foreach(fingerprint IN ITEMS
        "${selected_prefix}/BUILDINFO"
        "${selected_prefix}/include/rxpa/crexxpa.h"
        "${selected_prefix}/include/crexx_version.h"
        "${selected_prefix}/include/platform/rxinteger.h"
        "${CPRAG_CREXX_DIR}/CREXXConfig.cmake"
        "${CPRAG_CREXX_DIR}/CREXXConfigVersion.cmake"
        "${CPRAG_CREXX_DIR}/CREXXTargets.cmake"
        "${CPRAG_CREXX_DIR}/RXPluginFunction.cmake"
        "${CPRAG_RXC}" "${CPRAG_RXAS}" "${CPRAG_RXVME}" "${CPRAG_RXBVM}"
        "${consumer_build}/bin/rx_external_consumer.rxplugin")
    file(SHA256 "${fingerprint}" fingerprint_hash)
    file(APPEND "${CPRAG_WORK_DIR}/selected-prefix-manifest.txt"
        "${fingerprint_hash}  ${fingerprint}\n")
endforeach()

message(STATUS
    "P1-RXPA-01 passed installed-only external build and noopt/opt rxvme/rxbvm runtime checks")
