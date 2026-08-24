foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_APP_DIR CPRAG_CLAIMS_SCENARIO
        CPRAG_WORK_SCENARIO CPRAG_TUTORIAL CPRAG_TUTORIAL_FIXTURE
        CPRAG_TUTORIAL_EXPECTED CPRAG_NATIVE_WORK_ORACLE CPRAG_WORK_DIR)
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
    "phase=4\nlevel=G\nschema=2\n"
    "proposal=crexx-rag.extraction-proposal/1\n"
    "plan=crexx-rag.improve-plan/1\n"
    "secret_values_logged=0\n")

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

set(application_modules
    ragschema ragfile ragstore ragrepository ragingest ragclaims ragimprove
    ragjob ragwork rx_sqlite_boundary rx_hash rx_system rxplatform library)
set(tutorial_modules
    ragschema ragfile ragstore ragingest ragfolder ragclaims ragimprove
    ragjob ragwork rx_sqlite_boundary rx_hash rx_system rxfs rxplatform library)

function(run_checked runtime program modules cell library_path pattern)
    execute_process(COMMAND "${runtime}" -l "${program_import}"
        "${program}" ${modules} -a "${cell}" "${library_path}"
        OUTPUT_VARIABLE vm_out ERROR_VARIABLE vm_err
        RESULT_VARIABLE vm_result TIMEOUT 120)
    if(NOT vm_result EQUAL 0 OR NOT vm_out MATCHES "${pattern}")
        message(FATAL_ERROR "${cell} failed (${vm_result}):\n${vm_out}\n${vm_err}")
    endif()
    file(APPEND "${report}" "${cell}:\n${vm_out}${vm_err}\n")
endfunction()

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    foreach(module IN ITEMS ragschema ragfile ragstore ragrepository ragingest
            ragfolder ragclaims ragimprove ragjob ragwork)
        compile_crexx("${CPRAG_APP_DIR}/${module}.crexx"
            "${CPRAG_WORK_DIR}/${module}" "${program_import}" "${mode_flag}"
            "${mode} ${module}")
    endforeach()
    compile_crexx("${CPRAG_CLAIMS_SCENARIO}"
        "${CPRAG_WORK_DIR}/claims-${mode}" "${program_import}" "${mode_flag}"
        "${mode} Phase-4 claim scenario")
    compile_crexx("${CPRAG_WORK_SCENARIO}"
        "${CPRAG_WORK_DIR}/work-${mode}" "${program_import}" "${mode_flag}"
        "${mode} Phase-4 worker scenario")
    compile_crexx("${CPRAG_TUTORIAL}"
        "${CPRAG_WORK_DIR}/tutorial-${mode}" "${program_import}" "${mode_flag}"
        "${mode} Phase-4 tutorial")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        run_checked("${runtime}" "${CPRAG_WORK_DIR}/claims-${mode}"
            "${application_modules}" "${cell}"
            "${CPRAG_WORK_DIR}/claims-library-${cell}"
            "P4_CLAIMS_OK cell=${cell}.*replay_writes=0.*provider_calls=0")
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/tutorial-${mode}" ${tutorial_modules}
            -a "${CPRAG_WORK_DIR}/tutorial-library-${cell}" "${CPRAG_TUTORIAL_FIXTURE}"
            OUTPUT_VARIABLE tutorial_out ERROR_VARIABLE tutorial_err
            RESULT_VARIABLE tutorial_result TIMEOUT 120)
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

function(run_worker_recovery runtime runtime_name)
    set(program "${CPRAG_WORK_DIR}/work-opt")
    set(library_path "${CPRAG_WORK_DIR}/worker-library-${runtime_name}")
    execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
        ${application_modules} -a setup "${library_path}" "${runtime_name}"
        RESULT_VARIABLE setup_result OUTPUT_VARIABLE setup_out ERROR_VARIABLE setup_err
        TIMEOUT 120)
    if(NOT setup_result EQUAL 0 OR NOT setup_out MATCHES "P4_WORK_SETUP_OK cell=${runtime_name}.*items=4")
        message(FATAL_ERROR "${runtime_name} worker setup failed:\n${setup_out}\n${setup_err}")
    endif()
    set(crash_out "${CPRAG_WORK_DIR}/worker-${runtime_name}-crash.txt")
    execute_process(COMMAND /bin/sh -c [=[
"$1" -l "$2" "$3" ragschema ragfile ragstore ragrepository ragingest ragclaims ragimprove ragjob ragwork rx_sqlite_boundary rx_hash rx_system rxplatform library -a crash "$4" >"$5" 2>&1 &
child=$!
tries=0
while [ "$tries" -lt 200 ]; do
    if grep -q P4_CRASH_CLAIMED "$5" 2>/dev/null; then
        kill -KILL "$child" || exit 1
        wait "$child" 2>/dev/null
        exit 0
    fi
    sleep 0.05
    tries=$((tries + 1))
done
kill -KILL "$child" 2>/dev/null
wait "$child" 2>/dev/null
exit 1
]=] p4-crash "${runtime}" "${program_import}" "${program}" "${library_path}" "${crash_out}"
        RESULT_VARIABLE crash_result TIMEOUT 20)
    if(EXISTS "${crash_out}")
        file(READ "${crash_out}" crash_text)
    else()
        set(crash_text "")
    endif()
    if(NOT crash_result EQUAL 0 OR NOT crash_text MATCHES "P4_CRASH_CLAIMED.*fence=1")
        message(FATAL_ERROR "${runtime_name} crash injection failed:\n${crash_text}")
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 2)

    set(worker_a "${CPRAG_WORK_DIR}/worker-${runtime_name}-a.txt")
    set(worker_b "${CPRAG_WORK_DIR}/worker-${runtime_name}-b.txt")
    execute_process(COMMAND /bin/sh -c [=[
"$1" -l "$2" "$3" ragschema ragfile ragstore ragrepository ragingest ragclaims ragimprove ragjob ragwork rx_sqlite_boundary rx_hash rx_system rxplatform library -a worker "$4" worker-a >"$5" 2>&1 &
a=$!
"$1" -l "$2" "$3" ragschema ragfile ragstore ragrepository ragingest ragclaims ragimprove ragjob ragwork rx_sqlite_boundary rx_hash rx_system rxplatform library -a worker "$4" worker-b >"$6" 2>&1 &
b=$!
wait "$a"; ar=$?
wait "$b"; br=$?
test "$ar" -eq 0 -a "$br" -eq 0
]=] p4-workers "${runtime}" "${program_import}" "${program}" "${library_path}" "${worker_a}" "${worker_b}"
        RESULT_VARIABLE workers_result TIMEOUT 120)
    file(READ "${worker_a}" worker_a_text)
    file(READ "${worker_b}" worker_b_text)
    if(NOT workers_result EQUAL 0 OR NOT worker_a_text MATCHES "P4_WORKER_OK worker=worker-a"
            OR NOT worker_b_text MATCHES "P4_WORKER_OK worker=worker-b")
        message(FATAL_ERROR "${runtime_name} two-process workers failed:\n${worker_a_text}\n${worker_b_text}")
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 2)
    execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
        ${application_modules} -a worker "${library_path}" recovery-worker
        RESULT_VARIABLE recovery_result OUTPUT_VARIABLE recovery_out ERROR_VARIABLE recovery_err
        TIMEOUT 120)
    execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
        ${application_modules} -a stale "${library_path}" "${runtime_name}"
        RESULT_VARIABLE stale_result OUTPUT_VARIABLE stale_out ERROR_VARIABLE stale_err
        TIMEOUT 60)
    execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
        ${application_modules} -a verify "${library_path}" "${runtime_name}"
        RESULT_VARIABLE verify_result OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
        TIMEOUT 60)
    execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
        ${application_modules} -a soak "${library_path}" "soak-smoke-${runtime_name}" 2
        RESULT_VARIABLE soak_result OUTPUT_VARIABLE soak_out ERROR_VARIABLE soak_err
        TIMEOUT 15)
    if(NOT recovery_result EQUAL 0 OR NOT recovery_out MATCHES "P4_WORKER_OK worker=recovery-worker"
            OR NOT stale_result EQUAL 0 OR NOT stale_out MATCHES "P4_STALE_FENCE_OK"
            OR NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "P4_WORK_VERIFY_OK cell=${runtime_name}.*workers=two_process.*effect=exactly_once"
            OR NOT soak_result EQUAL 0 OR NOT soak_out MATCHES "P4_SOAK_OK worker=soak-smoke-${runtime_name}.*idle_polls=2")
        message(FATAL_ERROR "${runtime_name} recovery/fence/soak-smoke verification failed:\n${recovery_out}${recovery_err}\n${stale_out}${stale_err}\n${verify_out}${verify_err}\n${soak_out}${soak_err}")
    endif()
    set(control_path "${CPRAG_WORK_DIR}/control-library-${runtime_name}")
    execute_process(COMMAND "${runtime}" -l "${program_import}" "${program}"
        ${application_modules} -a control "${control_path}" "${runtime_name}"
        RESULT_VARIABLE control_result OUTPUT_VARIABLE control_out ERROR_VARIABLE control_err
        TIMEOUT 120)
    if(NOT control_result EQUAL 0 OR NOT control_out MATCHES "P4_CONTROL_OK cell=${runtime_name}.*cancellation=cooperative.*dead_letter=1")
        message(FATAL_ERROR "${runtime_name} worker controls failed:\n${control_out}\n${control_err}")
    endif()
    file(APPEND "${report}"
        "${runtime_name} crash/two-process/recovery/soak-smoke:\n${crash_text}${worker_a_text}${worker_b_text}${recovery_out}${stale_out}${verify_out}${soak_out}\n"
        "${runtime_name} controls:\n${control_out}${control_err}\n")
endfunction()

run_worker_recovery("${CPRAG_RXVME}" "rxvme")
run_worker_recovery("${CPRAG_RXBVM}" "rxbvm")

execute_process(COMMAND "${CPRAG_NATIVE_WORK_ORACLE}"
    RESULT_VARIABLE native_result OUTPUT_VARIABLE native_out ERROR_VARIABLE native_err
    TIMEOUT 60)
if(NOT native_result EQUAL 0)
    message(FATAL_ERROR "native-v1 work-queue oracle failed:\n${native_out}\n${native_err}")
endif()
file(APPEND "${report}" "native-v1 work-queue oracle: exit=${native_result}\n${native_out}${native_err}\n")

message(STATUS "Phase 4 passed: four optimized/non-optimized dual-VM claim/tutorial cells, dual-VM crash recovery and worker controls, two OS-process workers, and native-v1 work-queue oracle")
