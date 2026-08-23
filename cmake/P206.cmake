foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_SCHEMA CPRAG_FILE CPRAG_STORE
        CPRAG_REPOSITORY CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "item=P2-06\nlevel=G\nrepositories=16\npaging=keyset\n"
    "snapshot=pinned\nbinary_payloads=typed\nprovider_calls=0\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}"
        "${label} compile:\n${compile_out}${compile_err}"
        "${label} assemble:\n${assemble_out}${assemble_err}\n")
endfunction()

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_SCHEMA}" "${CPRAG_WORK_DIR}/ragschema"
        "${base_import}" "${mode_flag}" "${mode} ragschema")
    compile_crexx("${CPRAG_FILE}" "${CPRAG_WORK_DIR}/ragfile"
        "${base_import}" "${mode_flag}" "${mode} ragfile")
    compile_crexx("${CPRAG_STORE}" "${CPRAG_WORK_DIR}/ragstore"
        "${program_import}" "${mode_flag}" "${mode} ragstore")
    compile_crexx("${CPRAG_REPOSITORY}" "${CPRAG_WORK_DIR}/ragrepository"
        "${program_import}" "${mode_flag}" "${mode} ragrepository")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} repository scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(library_path "${CPRAG_WORK_DIR}/library-${cell}")
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/program-${mode}"
            ragschema ragfile ragstore ragrepository rx_sqlite_boundary
            rx_hash rx_system library
            -a "${cell}" "${library_path}"
            OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
            RESULT_VARIABLE vm_result TIMEOUT 60)
        if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES
                "P2_06_REPOSITORIES_OK cell=${cell} repositories=16 page_limit=1 pinned_generation=2 fresh_generation=3 semantic_rows=2 operational_rows=3 binary_payloads=exact invariant_faults=2 provider_calls=0")
            message(FATAL_ERROR "${cell} repository scenario failed (${vm_result}):\n${vm_out}\n${vm_err}")
        endif()
        if(NOT EXISTS "${library_path}/library.sqlite" OR
           NOT EXISTS "${library_path}/manifest.json")
            message(FATAL_ERROR "${cell} did not retain a complete schema-v2 library")
        endif()
        file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
    endforeach()
endforeach()

message(STATUS
    "P2-06 passed: 16 keyset-paged repositories, typed binary projections, pinned old/new generation visibility, operational snapshot isolation, cursor bounds, and lifecycle/orphan verification across noopt/opt x rxvme/rxbvm")
