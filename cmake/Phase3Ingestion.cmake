foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_APP_DIR CPRAG_SCENARIO
        CPRAG_DELTA_SCENARIO CPRAG_RESUME_SCENARIO CPRAG_TUTORIAL
        CPRAG_TUTORIAL_FIXTURE CPRAG_TUTORIAL_EXPECTED CPRAG_PHASE0_FIXTURE
        CPRAG_NATIVE_CLI CPRAG_ORACLE_CAPTURE CPRAG_WORK_DIR)
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
    "phase=3\nlevel=G\nschema=2\nprovider_calls=0\n"
    "plan=crexx-rag.ingest-plan/1\n")

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

function(run_program runtime program modules cell library_path expected_pattern)
    execute_process(COMMAND "${runtime}" -l "${program_import}"
        "${program}" ${modules} -a "${cell}" "${library_path}" ${ARGN}
        OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
        RESULT_VARIABLE vm_result TIMEOUT 90)
    if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "${expected_pattern}")
        message(FATAL_ERROR "${cell} failed (${vm_result}):\n${vm_out}\n${vm_err}")
    endif()
    file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
endfunction()

set(application_modules
    ragschema ragfile ragstore ragrepository ragingest
    rx_sqlite_boundary rx_hash rx_system library)
set(tutorial_modules
    ragschema ragfile ragstore ragingest ragfolder
    rx_sqlite_boundary rx_hash rx_system rxfs library)
set(delta_modules
    ragschema ragfile ragstore ragingest
    rx_sqlite_boundary rx_hash rx_system library)

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_APP_DIR}/ragschema.crexx" "${CPRAG_WORK_DIR}/ragschema"
        "${base_import}" "${mode_flag}" "${mode} ragschema")
    compile_crexx("${CPRAG_APP_DIR}/ragfile.crexx" "${CPRAG_WORK_DIR}/ragfile"
        "${base_import}" "${mode_flag}" "${mode} ragfile")
    compile_crexx("${CPRAG_APP_DIR}/ragstore.crexx" "${CPRAG_WORK_DIR}/ragstore"
        "${program_import}" "${mode_flag}" "${mode} ragstore")
    compile_crexx("${CPRAG_APP_DIR}/ragrepository.crexx" "${CPRAG_WORK_DIR}/ragrepository"
        "${program_import}" "${mode_flag}" "${mode} ragrepository")
    compile_crexx("${CPRAG_APP_DIR}/ragingest.crexx" "${CPRAG_WORK_DIR}/ragingest"
        "${program_import}" "${mode_flag}" "${mode} ragingest")
    compile_crexx("${CPRAG_APP_DIR}/ragfolder.crexx" "${CPRAG_WORK_DIR}/ragfolder"
        "${program_import}" "${mode_flag}" "${mode} ragfolder")
    compile_crexx("${CPRAG_SCENARIO}" "${CPRAG_WORK_DIR}/scenario-${mode}"
        "${program_import}" "${mode_flag}" "${mode} Phase-3 scenario")
    compile_crexx("${CPRAG_TUTORIAL}" "${CPRAG_WORK_DIR}/tutorial-${mode}"
        "${program_import}" "${mode_flag}" "${mode} Phase-3 tutorial")
    compile_crexx("${CPRAG_RESUME_SCENARIO}" "${CPRAG_WORK_DIR}/resume-${mode}"
        "${program_import}" "${mode_flag}" "${mode} Phase-3 resume scenario")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        run_program("${runtime}" "${CPRAG_WORK_DIR}/scenario-${mode}"
            "${application_modules}" "${cell}"
            "${CPRAG_WORK_DIR}/library-${cell}"
            "P3_INGEST_OK cell=${cell} schema=2 initial_incremental=shared no_op_writes=0 provider_calls=0")
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/tutorial-${mode}" ${tutorial_modules}
            -a "${CPRAG_WORK_DIR}/tutorial-library-${cell}" "${CPRAG_TUTORIAL_FIXTURE}"
            OUTPUT_VARIABLE tutorial_out ERROR_VARIABLE tutorial_err
            RESULT_VARIABLE tutorial_result TIMEOUT 90)
        file(READ "${CPRAG_TUTORIAL_EXPECTED}" tutorial_expected)
        string(REPLACE "\r\n" "\n" tutorial_out "${tutorial_out}")
        string(STRIP "${tutorial_out}" tutorial_out)
        string(STRIP "${tutorial_expected}" tutorial_expected)
        if(NOT tutorial_result EQUAL 0 OR NOT tutorial_out STREQUAL tutorial_expected)
            message(FATAL_ERROR "${cell} tutorial mismatch (${tutorial_result}):\nactual:\n${tutorial_out}\nexpected:\n${tutorial_expected}\n${tutorial_err}")
        endif()
        file(APPEND "${report}" "${cell} tutorial:\n${tutorial_out}\n${tutorial_err}\n")
    endforeach()
endforeach()

compile_crexx("${CPRAG_DELTA_SCENARIO}" "${CPRAG_WORK_DIR}/delta-opt"
    "${program_import}" "" "optimized Phase-3 oracle delta")
foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    run_program("${runtime}" "${CPRAG_WORK_DIR}/delta-opt"
        "${delta_modules}" "delta-${runtime_name}"
        "${CPRAG_WORK_DIR}/delta-library-${runtime_name}"
        "\\{\"implementation\":\"crexx\",\"corpus\":\"scotland-shaped-v1\",\"sources\":2,\"chunks\":5,\"candidates\":[0-9]+,\"accepted_candidates\":[0-9]+,\"provider_calls\":0\\}"
        "${CPRAG_PHASE0_FIXTURE}/scotland-shaped-chronicle.md"
        "${CPRAG_PHASE0_FIXTURE}/scotland-shaped-ledger.md")
endforeach()

set(native_library "${CPRAG_WORK_DIR}/native-scotland.cprag")
execute_process(COMMAND "${CPRAG_NATIVE_CLI}" init "${native_library}"
    RESULT_VARIABLE native_init OUTPUT_VARIABLE native_init_out ERROR_VARIABLE native_init_err)
execute_process(COMMAND "${CPRAG_NATIVE_CLI}" ingest-file "${native_library}"
    "${CPRAG_PHASE0_FIXTURE}/scotland-shaped-chronicle.md" markdown 512 0 Chronicle
    RESULT_VARIABLE native_first OUTPUT_VARIABLE native_first_out ERROR_VARIABLE native_first_err)
execute_process(COMMAND "${CPRAG_NATIVE_CLI}" ingest-file "${native_library}"
    "${CPRAG_PHASE0_FIXTURE}/scotland-shaped-ledger.md" markdown 512 0 Ledger
    RESULT_VARIABLE native_second OUTPUT_VARIABLE native_second_out ERROR_VARIABLE native_second_err)
execute_process(COMMAND "${CPRAG_NATIVE_CLI}" stats "${native_library}"
    RESULT_VARIABLE native_stats_result OUTPUT_VARIABLE native_stats ERROR_VARIABLE native_stats_err)
if(NOT native_init EQUAL 0 OR NOT native_first EQUAL 0 OR NOT native_second EQUAL 0 OR
   NOT native_stats_result EQUAL 0 OR NOT native_stats MATCHES "\"documents\":2,\"chunks\":5")
    message(FATAL_ERROR "native Scotland oracle failed or departed from the bounded 2-source/5-chunk semantic baseline:\n${native_init_out}${native_init_err}${native_first_out}${native_first_err}${native_second_out}${native_second_err}${native_stats}${native_stats_err}")
endif()
execute_process(COMMAND "${CPRAG_ORACLE_CAPTURE}" "${CPRAG_PHASE0_FIXTURE}"
    RESULT_VARIABLE oracle_result OUTPUT_VARIABLE oracle_out ERROR_VARIABLE oracle_err)
if(NOT oracle_result EQUAL 0 OR NOT oracle_out MATCHES "\"record\":\"chunking\"" OR
   NOT oracle_out MATCHES "\"record\":\"candidate-census-adjudication\".*\"mention_count\":2")
    message(FATAL_ERROR "generic native oracle capture failed:\n${oracle_out}\n${oracle_err}")
endif()
file(APPEND "${report}" "native Scotland oracle:\n${native_stats}\ngeneric oracle:\n${oracle_out}\n")

function(run_resume_crash runtime runtime_name)
    set(program "${CPRAG_WORK_DIR}/resume-opt")
    set(library_path "${CPRAG_WORK_DIR}/resume-library-${runtime_name}")
    execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
        ${delta_modules} -a setup "${library_path}"
        RESULT_VARIABLE setup_result OUTPUT_VARIABLE setup_out ERROR_VARIABLE setup_err TIMEOUT 60)
    if(NOT setup_result EQUAL 0 OR NOT setup_out MATCHES "P3_RESUME_SETUP_OK generation=1")
        message(FATAL_ERROR "${runtime_name} resume setup failed:\n${setup_out}\n${setup_err}")
    endif()
    set(marker "${CPRAG_WORK_DIR}/resume-${runtime_name}.marker")
    set(stdout_file "${marker}.stdout")
    set(stderr_file "${marker}.stderr")
    file(REMOVE "${marker}" "${stdout_file}" "${stderr_file}")
    execute_process(COMMAND /bin/sh -c [=[
"$1" -l "$2" "$3" ragschema ragfile ragstore ragingest rx_sqlite_boundary rx_hash rx_system library -a crash "$4" "$5" >"$6" 2>"$7" &
child=$!
tries=0
while [ "$tries" -lt 200 ]; do
    if [ -f "$5" ]; then
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
]=] phase3-resume "${runtime}" "${program_import}" "${program}" "${library_path}" "${marker}" "${stdout_file}" "${stderr_file}"
        RESULT_VARIABLE crash_result OUTPUT_VARIABLE crash_out ERROR_VARIABLE crash_err TIMEOUT 20)
    if(EXISTS "${marker}")
        file(READ "${marker}" marker_out)
    else()
        set(marker_out "")
    endif()
    if(NOT crash_result EQUAL 0 OR NOT marker_out MATCHES "P3_RESUME_CRASH_POINT=staging generation=2")
        message(FATAL_ERROR "${runtime_name} was not killed at the ingest staging boundary:\n${marker_out}\n${crash_out}\n${crash_err}")
    endif()
    execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
        ${delta_modules} -a resume "${library_path}" "${runtime_name}"
        RESULT_VARIABLE resume_result OUTPUT_VARIABLE resume_out ERROR_VARIABLE resume_err TIMEOUT 60)
    if(NOT resume_result EQUAL 0 OR NOT resume_out MATCHES "P3_RESUME_OK cell=${runtime_name} killed_staging=rolled_back resumed_generation=2 sources=1 revisions=1 jobs=1 duplicate_rows=0 repeat_writes=0 provider_calls=0")
        message(FATAL_ERROR "${runtime_name} resume failed:\n${resume_out}\n${resume_err}")
    endif()
    file(APPEND "${report}" "${runtime_name} crash/resume:\n${marker_out}${resume_out}${resume_err}\n")
endfunction()

run_resume_crash("${CPRAG_RXVME}" "rxvme")
run_resume_crash("${CPRAG_RXBVM}" "rxbvm")

message(STATUS "Phase 3 passed: four optimized/non-optimized dual-VM ingestion cells, executable folder tutorial, dual-run generic/Scotland oracle evidence, and dual-VM SIGKILL resume")
