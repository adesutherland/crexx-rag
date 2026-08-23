foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_SCHEMA CPRAG_FILE CPRAG_STORE
        CPRAG_BACKUP CPRAG_SOURCE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
set(sidecar_source "${CPRAG_WORK_DIR}/vector-source.faiss")
file(WRITE "${sidecar_source}" "P2-05 immutable opaque-sidecar fixture with deterministic bytes\n")
file(SIZE "${sidecar_source}" sidecar_size)
file(SHA256 "${sidecar_source}" sidecar_checksum)
string(SUBSTRING "${sidecar_checksum}" 0 16 checksum_prefix)
set(sidecar_name "vectors.2.vg-fixture.${checksum_prefix}.faiss")
file(WRITE "${report}"
    "item=P2-05\nlevel=G\nbackup=online-pinned\n"
    "sidecar_source_sha256=${sidecar_checksum}\nsidecar_source_bytes=${sidecar_size}\n"
    "folder_publication=atomic-rename\nprovider_calls=0\n")

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

function(bundle_state path output_variable)
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

function(run_scenario runtime program cell mode path expected_pattern)
    execute_process(COMMAND "${runtime}" -l "${program_import}"
        "${program}" ragschema ragfile ragstore ragbackup rx_sqlite_boundary rx_hash rx_system rxfs library
        -a "${cell}" "${mode}" "${path}" ${ARGN}
        OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
        RESULT_VARIABLE vm_result TIMEOUT 60)
    if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "${expected_pattern}")
        message(FATAL_ERROR "${cell} ${mode} failed (${vm_result}):\n${vm_out}\n${vm_err}")
    endif()
    file(APPEND "${report}" "${cell} ${mode}:\n${vm_out}${vm_err}\n")
endfunction()

function(run_sidecar_crash runtime program cell library_path boundary)
    set(marker "${CPRAG_WORK_DIR}/${cell}-sidecar-${boundary}.marker")
    set(stdout_file "${marker}.stdout")
    set(stderr_file "${marker}.stderr")
    file(REMOVE "${marker}" "${stdout_file}" "${stderr_file}")
    execute_process(COMMAND /bin/sh -c [=[
"$1" -l "$2" "$3" ragschema ragfile ragstore ragbackup rx_sqlite_boundary rx_hash rx_system rxfs library -a "$4" crash-sidecar "$5" "$6" "$7" "$8" "$9" "${10}" >"${11}" 2>"${12}" &
child=$!
tries=0
while [ "$tries" -lt 200 ]; do
    if [ -f "${10}" ]; then
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
]=] p205-sidecar "${runtime}" "${program_import}" "${program}" "${cell}" "${library_path}" "${sidecar_source}" "${sidecar_size}" "${sidecar_checksum}" "${boundary}" "${marker}" "${stdout_file}" "${stderr_file}"
        OUTPUT_VARIABLE shell_out ERROR_VARIABLE shell_err
        RESULT_VARIABLE crash_result TIMEOUT 20)
    if(EXISTS "${marker}")
        file(READ "${marker}" marker_out)
    else()
        set(marker_out "")
    endif()
    if(NOT crash_result EQUAL 0 OR NOT marker_out MATCHES "P2_05_CRASH_POINT=sidecar-")
        message(FATAL_ERROR "${cell} sidecar ${boundary} crash failed (${crash_result}):\n${marker_out}\n${shell_out}\n${shell_err}")
    endif()
    file(APPEND "${report}" "${cell} sidecar ${boundary} SIGKILL:\n${marker_out}${shell_out}${shell_err}\n")
endfunction()

function(run_folder_crash runtime program cell kind source_path target_path boundary)
    set(marker "${CPRAG_WORK_DIR}/${cell}-${kind}-${boundary}.marker")
    set(stdout_file "${marker}.stdout")
    set(stderr_file "${marker}.stderr")
    file(REMOVE "${marker}" "${stdout_file}" "${stderr_file}")
    execute_process(COMMAND /bin/sh -c [=[
"$1" -l "$2" "$3" ragschema ragfile ragstore ragbackup rx_sqlite_boundary rx_hash rx_system rxfs library -a "$4" "$5" "$6" "$7" "$8" "$9" >"${10}" 2>"${11}" &
child=$!
tries=0
while [ "$tries" -lt 200 ]; do
    if [ -f "$9" ]; then
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
]=] p205-folder "${runtime}" "${program_import}" "${program}" "${cell}" "crash-${kind}" "${source_path}" "${target_path}" "${boundary}" "${marker}" "${stdout_file}" "${stderr_file}"
        OUTPUT_VARIABLE shell_out ERROR_VARIABLE shell_err
        RESULT_VARIABLE crash_result TIMEOUT 20)
    if(EXISTS "${marker}")
        file(READ "${marker}" marker_out)
    else()
        set(marker_out "")
    endif()
    if(NOT crash_result EQUAL 0 OR NOT marker_out MATCHES "P2_05_CRASH_POINT=${kind}-${boundary}")
        message(FATAL_ERROR "${cell} ${kind} ${boundary} crash failed (${crash_result}):\n${marker_out}\n${shell_out}\n${shell_err}")
    endif()
    file(APPEND "${report}" "${cell} ${kind} ${boundary} SIGKILL:\n${marker_out}${shell_out}${shell_err}\n")
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
    compile_crexx("${CPRAG_BACKUP}" "${CPRAG_WORK_DIR}/ragbackup"
        "${program_import}" "${mode_flag}" "${mode} ragbackup")
    compile_crexx("${CPRAG_SOURCE}" "${CPRAG_WORK_DIR}/program-${mode}"
        "${program_import}" "${mode_flag}" "${mode} backup scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(program "${CPRAG_WORK_DIR}/program-${mode}")
        set(source_library "${CPRAG_WORK_DIR}/source-${cell}")
        set(snapshot_library "${CPRAG_WORK_DIR}/snapshot-${cell}")
        set(restored_library "${CPRAG_WORK_DIR}/restored-${cell}")
        run_scenario("${runtime}" "${program}" "${cell}" binary-file
            "${CPRAG_WORK_DIR}/binary-${cell}.dat"
            "P2_05_BINARY_FILE_OK cell=${cell} bytes=10 embedded_nul=2 invalid_utf8=1 bounded_incremental=1 public_file=1 sha256=")
        run_scenario("${runtime}" "${program}" "${cell}" setup "${source_library}"
            "P2_05_SETUP_OK cell=${cell} generation=2 sidecars=1"
            "${sidecar_source}" "${sidecar_size}" "${sidecar_checksum}")
        run_scenario("${runtime}" "${program}" "${cell}" negative "${source_library}"
            "P2_05_SIDECAR_NEGATIVE_OK cell=${cell} unsafe=rejected checksum=rejected overwrite=rejected immutable=1"
            "${sidecar_source}" "${sidecar_size}" "${sidecar_checksum}")
        run_scenario("${runtime}" "${program}" "${cell}" backup "${source_library}"
            "P2_05_BACKUP_OK cell=${cell} pinned_generation=2 live_generation=3 sidecars=1 atomic_folder=1 verified=1"
            "${snapshot_library}")
        if(NOT EXISTS "${snapshot_library}/${sidecar_name}")
            message(FATAL_ERROR "${cell} snapshot is missing its pinned sidecar")
        endif()
        file(SHA256 "${snapshot_library}/${sidecar_name}" snapshot_sidecar_checksum)
        if(NOT snapshot_sidecar_checksum STREQUAL sidecar_checksum)
            message(FATAL_ERROR "${cell} snapshot sidecar checksum changed")
        endif()
        file(READ "${snapshot_library}/manifest.json" snapshot_manifest)
        if(NOT snapshot_manifest MATCHES "${sidecar_checksum}")
            message(FATAL_ERROR "${cell} snapshot manifest omits the active sidecar checksum")
        endif()
        bundle_state("${snapshot_library}" snapshot_before_restore)
        run_scenario("${runtime}" "${program}" "${cell}" restore "${snapshot_library}"
            "P2_05_RESTORE_OK cell=${cell} fresh_target=1 generation=2 sidecars=1 overwrite=rejected verified=1"
            "${restored_library}")
        bundle_state("${snapshot_library}" snapshot_after_restore)
        if(NOT "${snapshot_before_restore}" STREQUAL "${snapshot_after_restore}")
            message(FATAL_ERROR "${cell} restore changed the source snapshot bundle")
        endif()
        file(SHA256 "${restored_library}/${sidecar_name}" restored_sidecar_checksum)
        if(NOT restored_sidecar_checksum STREQUAL sidecar_checksum)
            message(FATAL_ERROR "${cell} restored sidecar checksum changed")
        endif()
        run_scenario("${runtime}" "${program}" "${cell}" tamper "${restored_library}"
            "P2_05_TAMPER_OK cell=${cell} checksum_mismatch=detected missing_sidecar=detected"
            "${sidecar_checksum}")
    endforeach()
endforeach()

# Real process termination covers every sidecar and folder publication boundary
# on both optimized VMs. Each source is an isolated scratch fixture.
foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    set(program "${CPRAG_WORK_DIR}/program-opt")
    foreach(boundary IN ITEMS prepared installed committed manifest-temp)
        set(cell "crash-${runtime_name}-${boundary}")
        set(library_path "${CPRAG_WORK_DIR}/sidecar-${cell}")
        run_scenario("${runtime}" "${program}" "${cell}" setup-library "${library_path}"
            "P2_05_SETUP_OK cell=${cell} generation=2 sidecars=0"
            "${sidecar_source}" "${sidecar_size}" "${sidecar_checksum}")
        run_sidecar_crash("${runtime}" "${program}" "${cell}" "${library_path}" "${boundary}")
        run_scenario("${runtime}" "${program}" "${cell}" inspect-sidecar-crash "${library_path}"
            "P2_05_SIDECAR_CRASH_OK cell=${cell} boundary=${boundary}"
            "${sidecar_checksum}" "${boundary}")
        if(boundary STREQUAL "committed" OR boundary STREQUAL "manifest-temp")
            run_scenario("${runtime}" "${program}" "${cell}" recover-sidecar "${library_path}"
                "P2_05_SIDECAR_RECOVERY_OK cell=${cell} manifest=aligned verified=1")
        endif()
    endforeach()

    foreach(kind IN ITEMS backup restore)
        set(source_cell "crash-${kind}-${runtime_name}-source")
        set(folder_source "${CPRAG_WORK_DIR}/${kind}-${runtime_name}-source")
        run_scenario("${runtime}" "${program}" "${source_cell}" setup "${folder_source}"
            "P2_05_SETUP_OK cell=${source_cell} generation=2 sidecars=1"
            "${sidecar_source}" "${sidecar_size}" "${sidecar_checksum}")
        bundle_state("${folder_source}" folder_source_before)
        foreach(boundary IN ITEMS database sidecars manifest)
            set(cell "crash-${kind}-${runtime_name}-${boundary}")
            set(folder_target "${CPRAG_WORK_DIR}/${kind}-${runtime_name}-${boundary}-target")
            run_folder_crash("${runtime}" "${program}" "${cell}" "${kind}" "${folder_source}" "${folder_target}" "${boundary}")
            if(EXISTS "${folder_target}" OR NOT EXISTS "${folder_target}.new/library.sqlite")
                message(FATAL_ERROR "${cell} exposed a partial final folder or lost the staged database")
            endif()
            if(boundary STREQUAL "database")
                if(EXISTS "${folder_target}.new/${sidecar_name}" OR EXISTS "${folder_target}.new/manifest.json")
                    message(FATAL_ERROR "${cell} crossed the database-only crash boundary")
                endif()
            elseif(boundary STREQUAL "sidecars")
                if(NOT EXISTS "${folder_target}.new/${sidecar_name}" OR EXISTS "${folder_target}.new/manifest.json")
                    message(FATAL_ERROR "${cell} did not retain exactly database plus sidecars")
                endif()
            else()
                if(NOT EXISTS "${folder_target}.new/${sidecar_name}" OR NOT EXISTS "${folder_target}.new/manifest.json")
                    message(FATAL_ERROR "${cell} did not retain the complete unpublished staging folder")
                endif()
            endif()
        endforeach()
        bundle_state("${folder_source}" folder_source_after)
        if(NOT "${folder_source_before}" STREQUAL "${folder_source_after}")
            message(FATAL_ERROR "${kind}-${runtime_name} crash sequence changed its source bundle")
        endif()
    endforeach()
endforeach()

message(STATUS
    "P2-05 passed: immutable sidecar/SQLite/manifest ordering, pinned online backup, fresh restore, exact copied SHA-256, and real SIGKILL boundaries across noopt/opt x rxvme/rxbvm")
