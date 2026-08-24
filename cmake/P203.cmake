foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_SCHEMA CPRAG_FILE CPRAG_STORE
        CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(STRINGS "${CPRAG_SCHEMA}" schema_lines)
set(active_migration 0)
set(migration_1_payload "")
set(migration_2_payload "")
set(migration_3_payload "")
set(migration_1_expected "")
set(migration_2_expected "")
set(migration_3_expected "")
foreach(schema_line IN LISTS schema_lines)
    if(schema_line MATCHES "if version = ([123]) then do")
        set(active_migration "${CMAKE_MATCH_1}")
    elseif(schema_line MATCHES "if version = ([123]) then return \"([0-9a-f]+)\"")
        string(LENGTH "${CMAKE_MATCH_2}" checksum_length)
        if(checksum_length EQUAL 64)
            set("migration_${CMAKE_MATCH_1}_expected" "${CMAKE_MATCH_2}")
        endif()
    elseif(schema_line MATCHES "statements\\[statements\\.0 \\+ 1\\] = \"(.*)\"")
        string(APPEND "migration_${active_migration}_payload" "${CMAKE_MATCH_1}\n")
    endif()
endforeach()
foreach(version RANGE 1 3)
    string(SHA256 actual_checksum "${migration_${version}_payload}")
    if(NOT actual_checksum STREQUAL migration_${version}_expected)
        message(FATAL_ERROR
            "migration ${version} checksum does not match its ordered DDL: expected=${migration_${version}_expected} actual=${actual_checksum}")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "item=P2-03-maintained\nlevel=G\nschema_version=3\nmigrations=3\n"
    "sqlite_authority=1\nmanifest_projection=recoverable\n"
    "provider_calls=0\nsource_reads=0\n")

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

function(durable_bundle_state path output_variable)
    file(GLOB_RECURSE bundle_files RELATIVE "${path}" "${path}/*")
    list(SORT bundle_files)
    set(state)
    foreach(bundle_file IN LISTS bundle_files)
        if(NOT IS_DIRECTORY "${path}/${bundle_file}" AND NOT bundle_file MATCHES "-shm$")
            file(SHA256 "${path}/${bundle_file}" checksum)
            file(SIZE "${path}/${bundle_file}" size)
            file(TIMESTAMP "${path}/${bundle_file}" modified "%s" UTC)
            list(APPEND state "${bundle_file}=${size}:${modified}:${checksum}")
        endif()
    endforeach()
    set(${output_variable} "${state}" PARENT_SCOPE)
endfunction()

function(run_scenario runtime program cell mode path expected_result expected_pattern)
    execute_process(COMMAND "${runtime}" -l "${program_import}"
        "${program}" ragschema ragfile ragstore rx_sqlite_boundary rx_hash rx_system library
        -a "${cell}" "${mode}" "${path}" ${ARGN}
        OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
        RESULT_VARIABLE vm_result TIMEOUT 60)
    if(NOT vm_result EQUAL expected_result OR NOT vm_out MATCHES "${expected_pattern}")
        message(FATAL_ERROR
            "${cell} ${mode} failed (${vm_result}, expected ${expected_result}):\n${vm_out}\n${vm_err}")
    endif()
    file(APPEND "${report}" "${cell} ${mode}:\n${vm_out}${vm_err}\n")
endfunction()

function(run_crash runtime program cell mode path expected_pattern)
    set(marker "${CPRAG_WORK_DIR}/${cell}-${mode}.marker")
    set(stdout_file "${marker}.stdout")
    set(stderr_file "${marker}.stderr")
    file(REMOVE "${marker}" "${stdout_file}" "${stderr_file}")
    execute_process(COMMAND /bin/sh -c [=[
"$1" -l "$2" "$3" ragschema ragfile ragstore rx_sqlite_boundary rx_hash rx_system library -a "$4" "$5" "$6" "$7" >"$8" 2>"$9" &
child=$!
tries=0
while [ "$tries" -lt 200 ]; do
    if [ -f "$7" ]; then
        kill -KILL "$child"
        wait "$child" 2>/dev/null
        exit 0
    fi
    sleep 0.05
    tries=$((tries + 1))
done
kill -KILL "$child" 2>/dev/null
wait "$child" 2>/dev/null
exit 1
]=] p203-crash "${runtime}" "${program_import}" "${program}" "${cell}" "${mode}" "${path}" "${marker}" "${stdout_file}" "${stderr_file}"
        OUTPUT_VARIABLE shell_out ERROR_VARIABLE shell_err
        RESULT_VARIABLE crash_result TIMEOUT 20)
    if(EXISTS "${marker}")
        file(READ "${marker}" marker_out)
    else()
        set(marker_out "")
    endif()
    if(EXISTS "${stdout_file}")
        file(READ "${stdout_file}" vm_out)
    else()
        set(vm_out "")
    endif()
    if(EXISTS "${stderr_file}")
        file(READ "${stderr_file}" vm_err)
    else()
        set(vm_err "")
    endif()
    if(NOT crash_result EQUAL 0 OR NOT marker_out MATCHES "${expected_pattern}")
        message(FATAL_ERROR
            "${cell} ${mode} was not terminated at the expected boundary (${crash_result}):\nmarker=${marker_out}\n${vm_out}\n${vm_err}\n${shell_out}\n${shell_err}")
    endif()
    file(APPEND "${report}" "${cell} ${mode} SIGKILL:\n${marker_out}${vm_out}${vm_err}${shell_out}${shell_err}\n")
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
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} storage scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(program "${CPRAG_WORK_DIR}/program-${mode}")
        set(library_path "${CPRAG_WORK_DIR}/library-${cell}")
        run_scenario("${runtime}" "${program}" "${cell}" full
            "${library_path}" 0
            "P2_03_FULL_OK cell=${cell} levelg=1 schema=3 migrations=3 tables=33 generations=2 snapshots=2 manifest_recovery=1 rollback=1")
        run_scenario("${runtime}" "${program}" "${cell}" migration
            "${CPRAG_WORK_DIR}/migration-${cell}" 0
            "P2_03_MIGRATION_OK cell=${cell} ordered=2 checksums=verified upgrade=1 idempotent=1 downgrade=denied failed_upgrade=rolled_back")

        bundle_state("${library_path}" state_before)
        run_scenario("${runtime}" "${program}" "${cell}" readonly
            "${library_path}" 0
            "P2_03_READONLY_OK cell=${cell} generation=1 manifest=aligned writes=0 repairs=0 migrations=0"
            1 aligned)
        bundle_state("${library_path}" state_after)
        if(NOT "${state_before}" STREQUAL "${state_after}")
            message(FATAL_ERROR
                "${cell} readonly open changed the library bundle:\nbefore=${state_before}\nafter=${state_after}")
        endif()

        set(missing_path "${CPRAG_WORK_DIR}/missing-${cell}")
        run_scenario("${runtime}" "${program}" "${cell}" readonly-missing
            "${missing_path}" 0
            "P2_03_MISSING_READONLY_OK cell=${cell} created=0 migrated=0")
        if(EXISTS "${missing_path}")
            message(FATAL_ERROR "${cell} readonly open created a missing library path")
        endif()
    endforeach()
endforeach()

# Crash ordering uses uncatchable process termination on both optimized VMs.
foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    set(cell "crash-${runtime_name}")
    set(program "${CPRAG_WORK_DIR}/program-opt")
    set(library_path "${CPRAG_WORK_DIR}/library-${cell}")
    run_scenario("${runtime}" "${program}" "${cell}" crash-setup
        "${library_path}" 0 "P2_03_CRASH_SETUP_OK generation=1 manifest=aligned")
    run_crash("${runtime}" "${program}" "${cell}" crash-before-commit
        "${library_path}" "P2_03_CRASH_POINT=before-db-commit generation=2")

    durable_bundle_state("${library_path}" before_precommit_read)
    run_scenario("${runtime}" "${program}" "${cell}" readonly
        "${library_path}" 0
        "P2_03_READONLY_OK cell=${cell} generation=1 manifest=aligned writes=0 repairs=0 migrations=0"
        1 aligned)
    durable_bundle_state("${library_path}" after_precommit_read)
    if(NOT "${before_precommit_read}" STREQUAL "${after_precommit_read}")
        message(FATAL_ERROR "${cell} pre-commit crash inspection changed authoritative bundle state")
    endif()

    run_crash("${runtime}" "${program}" "${cell}" crash-after-database
        "${library_path}" "P2_03_CRASH_POINT=after-db-commit generation=2")
    durable_bundle_state("${library_path}" before_stale_read)
    run_scenario("${runtime}" "${program}" "${cell}" readonly
        "${library_path}" 0
        "P2_03_READONLY_OK cell=${cell} generation=2 manifest=stale writes=0 repairs=0 migrations=0"
        2 stale)
    durable_bundle_state("${library_path}" after_stale_read)
    if(NOT "${before_stale_read}" STREQUAL "${after_stale_read}")
        message(FATAL_ERROR "${cell} stale-manifest inspection changed authoritative bundle state")
    endif()
    run_scenario("${runtime}" "${program}" "${cell}" recover
        "${library_path}" 0
        "P2_03_RECOVERY_OK cell=${cell} generation=2 manifest=aligned authorized=1"
        2)

    run_crash("${runtime}" "${program}" "${cell}" crash-after-temporary
        "${library_path}" "P2_03_CRASH_POINT=after-manifest-temp generation=3")
    durable_bundle_state("${library_path}" before_temp_read)
    run_scenario("${runtime}" "${program}" "${cell}" readonly
        "${library_path}" 0
        "P2_03_READONLY_OK cell=${cell} generation=3 manifest=stale-temp writes=0 repairs=0 migrations=0"
        3 stale-temp)
    durable_bundle_state("${library_path}" after_temp_read)
    if(NOT "${before_temp_read}" STREQUAL "${after_temp_read}")
        message(FATAL_ERROR "${cell} temporary-manifest inspection changed authoritative bundle state")
    endif()
    run_scenario("${runtime}" "${program}" "${cell}" recover
        "${library_path}" 0
        "P2_03_RECOVERY_OK cell=${cell} generation=3 manifest=aligned authorized=1"
        3)
endforeach()

message(STATUS
    "P2-03 passed schema-v2 lifecycle, migration, generation, snapshot, manifest, read-only, crash, verification, and rollback contracts")
