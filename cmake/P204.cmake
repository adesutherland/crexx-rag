foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_SCHEMA CPRAG_STORE
        CPRAG_COMPAT CPRAG_SOURCE CPRAG_WORK_DIR)
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
    "item=P2-04\nlevel=G\nsource_format=1\ntarget_format=2\n"
    "source_access=readonly\ndual_write=0\nprovider_calls=0\n"
    "legacy_work_resumed=0\nunverified_claims_accepted=0\n")

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR
            "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR
            "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}"
        "${label} compile:\n${compile_out}${compile_err}"
        "${label} assemble:\n${assemble_out}${assemble_err}\n")
endfunction()

function(bundle_state path output_variable)
    file(GLOB_RECURSE bundle_files RELATIVE "${path}" "${path}/*")
    list(SORT bundle_files)
    set(state)
    foreach(bundle_file IN LISTS bundle_files)
        if(NOT IS_DIRECTORY "${path}/${bundle_file}")
            file(SHA256 "${path}/${bundle_file}" checksum)
            file(SIZE "${path}/${bundle_file}" size)
            file(TIMESTAMP "${path}/${bundle_file}" modified "%s" UTC)
            list(APPEND state "${bundle_file}=${size}:${modified}:${checksum}")
        endif()
    endforeach()
    set(${output_variable} "${state}" PARENT_SCOPE)
endfunction()

function(run_scenario runtime program cell mode source_path expected_pattern)
    execute_process(COMMAND "${runtime}" -l "${program_import}"
        "${program}" ragschema ragstore ragcompat rx_sqlite_boundary rx_system library
        -a "${cell}" "${mode}" "${source_path}" ${ARGN}
        OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
        RESULT_VARIABLE vm_result TIMEOUT 60)
    if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "${expected_pattern}")
        message(FATAL_ERROR
            "${cell} ${mode} failed (${vm_result}):\n${vm_out}\n${vm_err}")
    endif()
    file(APPEND "${report}" "${cell} ${mode}:\n${vm_out}${vm_err}\n")
endfunction()

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_SCHEMA}" "${CPRAG_WORK_DIR}/ragschema"
        "${base_import}" "${mode_flag}" "${mode} ragschema")
    compile_crexx("${CPRAG_STORE}" "${CPRAG_WORK_DIR}/ragstore"
        "${program_import}" "${mode_flag}" "${mode} ragstore")
    compile_crexx("${CPRAG_COMPAT}" "${CPRAG_WORK_DIR}/ragcompat"
        "${program_import}" "${mode_flag}" "${mode} ragcompat")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} version-1 compatibility scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(program "${CPRAG_WORK_DIR}/program-${mode}")
        set(source_path "${CPRAG_WORK_DIR}/source-${cell}")
        set(target_path "${CPRAG_WORK_DIR}/target-${cell}")
        run_scenario("${runtime}" "${program}" "${cell}" create
            "${source_path}"
            "P2_04_FIXTURE_OK documents=2 chunks=3 entities=2 edges=1 embeddings=2 candidates=2 work=1 attempts=1")
        bundle_state("${source_path}" source_before)
        run_scenario("${runtime}" "${program}" "${cell}" dry-run
            "${source_path}"
            "P2_04_DRY_RUN_OK cell=${cell} source_writes=0 target_created=0 documents=2 chunks=3 imported_embeddings=1 quarantined=10"
            "${target_path}")
        bundle_state("${source_path}" source_after_dry_run)
        if(NOT "${source_before}" STREQUAL "${source_after_dry_run}")
            message(FATAL_ERROR
                "${cell} dry-run changed the version-1 source bundle:\nbefore=${source_before}\nafter=${source_after_dry_run}")
        endif()
        if(EXISTS "${target_path}")
            message(FATAL_ERROR "${cell} dry-run created the target path")
        endif()
        run_scenario("${runtime}" "${program}" "${cell}" import
            "${source_path}"
            "P2_04_IMPORT_OK cell=${cell} source_writes=0 schema=2 generation=2 sources=2 chunks=3 concepts=2 claims=0 embeddings=1 reviews=10 verified=1"
            "${target_path}")
        bundle_state("${source_path}" source_after_import)
        if(NOT "${source_before}" STREQUAL "${source_after_import}")
            message(FATAL_ERROR
                "${cell} import changed the version-1 source bundle:\nbefore=${source_before}\nafter=${source_after_import}")
        endif()
        if(NOT EXISTS "${target_path}/library.sqlite" OR NOT EXISTS "${target_path}/manifest.json")
            message(FATAL_ERROR "${cell} import did not publish a complete target bundle")
        endif()

        set(invalid_source "${CPRAG_WORK_DIR}/invalid-source-${cell}")
        set(invalid_target "${CPRAG_WORK_DIR}/invalid-target-${cell}")
        run_scenario("${runtime}" "${program}" "${cell}" create-invalid
            "${invalid_source}" "P2_04_INVALID_FIXTURE_OK")
        bundle_state("${invalid_source}" invalid_before)
        run_scenario("${runtime}" "${program}" "${cell}" invalid
            "${invalid_source}"
            "P2_04_INVALID_OK cell=${cell} unsupported_version=rejected target_created=0"
            "${invalid_target}")
        bundle_state("${invalid_source}" invalid_after)
        if(NOT "${invalid_before}" STREQUAL "${invalid_after}" OR EXISTS "${invalid_target}")
            message(FATAL_ERROR "${cell} rejected conversion was not a zero-write operation")
        endif()
    endforeach()
endforeach()

message(STATUS
    "P2-04 passed: version-1 dry-run/import, schema-v2 side-by-side publication, quarantine policy, invalid-version rejection, and source zero-write proof across noopt/opt x rxvme/rxbvm")
