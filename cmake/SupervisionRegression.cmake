foreach(required CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_PLUGIN_DIR CPRAG_APPLICATION_DIR CPRAG_SCENARIO CPRAG_WORK_DIR)
    if(NOT DEFINED ${required} OR "${${required}}" STREQUAL "")
        message(FATAL_ERROR "${required} is required")
    endif()
endforeach()
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(GLOB members LIST_DIRECTORIES true
    "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.crexx-build/members/*")
list(JOIN members ";" member_imports)
set(imports "${member_imports};${CPRAG_APPLICATION_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules ragsupervision ragenrich ragproposalio ragperiod ragprovenance ragassessment ragschema ragfile
    ragstore ragmodel ragjob ragquotationcontract ragextractioncontract ragresolutioncontract raganswercontract ragreportcontract ragpromptdefaults ragpromptinspection ragcommandutil ragsqlsupport ragdirectcalls ragreportservice ragobservationservice ragqueryservice ragoperationsquery ragclaimrules ragclaims ragadmission raglifecycle ragworktypes ragenvironment ragusage ragreceipts ragallowance ragwork ragcommandcatalog ragcommand ragworkerdefaults ragpolicypublication ragpolicyfile ragtrace ragbacklog
    ragmaintain ragimprove ragconfig ragprofile ragcanonical raggrounding generic_profile
    rxfnsg rxsqlite rx_hash rx_system rxfs rxplatform library)
set(program "${CPRAG_WORK_DIR}/supervision-regression")
execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}" -o "${program}" "${CPRAG_SCENARIO}"
    RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE errors)
file(WRITE "${CPRAG_WORK_DIR}/compile.log" "${output}${errors}")
if(NOT status EQUAL 0)
    message(FATAL_ERROR "Supervision regression compile failed:\n${output}${errors}")
endif()
execute_process(COMMAND "${CPRAG_RXAS}" -o "${program}" "${program}"
    RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE errors)
if(NOT status EQUAL 0)
    message(FATAL_ERROR "Supervision regression assembly failed:\n${output}${errors}")
endif()
find_program(sqlite_cli sqlite3 REQUIRED)
set(wal_driver "${CPRAG_WORK_DIR}/wal-contention.sh")
file(WRITE "${wal_driver}" [=[
set -eu
sqlite=$1; library=$2
shift 2
locker=; contender=
cleanup() {
  if [ -n "$contender" ]; then kill "$contender" 2>/dev/null || true; fi
  if [ -n "$locker" ]; then kill "$locker" 2>/dev/null || true; fi
}
trap cleanup EXIT HUP INT TERM
mkfifo "$library/wal-control"
"$sqlite" -bail "$library/library.sqlite" <"$library/wal-control" >"$library/wal-locker.out" 2>"$library/wal-locker.err" &
locker=$!
exec 3>"$library/wal-control"
printf 'PRAGMA journal_mode=DELETE;\nBEGIN EXCLUSIVE;\n.shell touch "%s/wal-locked"\n' "$library" >&3
tries=0
until [ -f "$library/wal-locked" ]; do
  tries=$((tries+1)); [ "$tries" -lt 1000 ] || exit 20
  kill -0 "$locker" 2>/dev/null || exit 21
  sleep 0.01
done
"$@" -a "$library" open-only >"$library/wal-open.out" 2>"$library/wal-open.err" &
contender=$!
tries=0
# This rendezvous requires the actual first SQLITE_BUSY result, then releases
# the lock. No reduced product timeout, replayed transaction body or paid call.
until grep -q 'retry=1/5: enable WAL:.*sqlite=5,extended=5,operation=exec' "$library/wal-open.err"; do
  tries=$((tries+1)); [ "$tries" -lt 1500 ] || exit 22
  kill -0 "$contender" 2>/dev/null || exit 23
  sleep 0.01
done
printf 'COMMIT;\n.quit\n' >&3
exec 3>&-
wait "$locker"; locker=
wait "$contender"; contender=
grep -q 'WAL_OPEN_OK' "$library/wal-open.out"
]=])
set(failures)
foreach(runtime IN ITEMS RXVME RXBVM)
    execute_process(COMMAND "${CPRAG_${runtime}}" -l "${imports}" "${program}" ${modules}
        -a "${CPRAG_WORK_DIR}/library-${runtime}"
        RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE errors TIMEOUT 60)
    file(WRITE "${CPRAG_WORK_DIR}/${runtime}.log" "exit=${status}\n${output}${errors}")
    if(status EQUAL 0 AND output MATCHES "SUPERVISION_REGRESSION_OK")
        # Two fresh processes reserve against the same rolling limit. They
        # race independent SQLite connections; exactly one reservation wins.
        file(WRITE "${CPRAG_WORK_DIR}/race-${runtime}.sh"
            "#!/bin/sh\nset -u\n\"$@\" worker-5 > '${CPRAG_WORK_DIR}/race-${runtime}-1.log' 2>&1 &\na=$!\n\"$@\" worker-6 > '${CPRAG_WORK_DIR}/race-${runtime}-2.log' 2>&1 &\nb=$!\nwait $a; left=$?\nwait $b; right=$?\nprintf 'left=%s right=%s\\n' \"$left\" \"$right\" > '${CPRAG_WORK_DIR}/race-${runtime}-status.log'\n[ \"$left\" -eq 0 ] && [ \"$right\" -eq 0 ]\n")
        execute_process(COMMAND /bin/sh "${CPRAG_WORK_DIR}/race-${runtime}.sh"
            "${CPRAG_${runtime}}" -l "${imports}" "${program}" ${modules}
            -a "${CPRAG_WORK_DIR}/library-${runtime}"
            RESULT_VARIABLE raced TIMEOUT 30)
        file(READ "${CPRAG_WORK_DIR}/race-${runtime}-1.log" first)
        file(READ "${CPRAG_WORK_DIR}/race-${runtime}-2.log" second)
        if(NOT raced EQUAL 0 OR NOT "${first}${second}" MATCHES "RACE=0" OR NOT "${first}${second}" MATCHES "RACE=2")
            file(READ "${CPRAG_WORK_DIR}/race-${runtime}-status.log" child_status)
            list(APPEND failures "${runtime} concurrent reservation exit=${raced} ${child_status}: ${first}${second}")
        endif()
    endif()
    if(status EQUAL 0 AND output MATCHES "SUPERVISION_REGRESSION_OK")
        execute_process(COMMAND "${sqlite_cli}" -readonly "${CPRAG_WORK_DIR}/library-${runtime}/library.sqlite" .dump
            RESULT_VARIABLE before_status OUTPUT_VARIABLE before_wal)
        execute_process(COMMAND /bin/sh "${wal_driver}" "${sqlite_cli}" "${CPRAG_WORK_DIR}/library-${runtime}"
            "${CPRAG_${runtime}}" -l "${imports}" "${program}" ${modules}
            RESULT_VARIABLE wal_status OUTPUT_VARIABLE wal_output ERROR_VARIABLE wal_errors TIMEOUT 30)
        execute_process(COMMAND "${sqlite_cli}" -readonly "${CPRAG_WORK_DIR}/library-${runtime}/library.sqlite" .dump
            RESULT_VARIABLE after_status OUTPUT_VARIABLE after_wal)
        if(NOT before_status EQUAL 0 OR NOT after_status EQUAL 0 OR NOT before_wal STREQUAL after_wal)
            list(APPEND failures "${runtime} WAL startup changed retained database state")
        endif()
        if(NOT wal_status EQUAL 0)
            file(READ "${CPRAG_WORK_DIR}/library-${runtime}/wal-open.out" wal_observed)
            file(READ "${CPRAG_WORK_DIR}/library-${runtime}/wal-open.err" wal_diagnostic)
            list(APPEND failures "${runtime} WAL lock recovery failed (${wal_status}): ${wal_observed}${wal_diagnostic}${wal_errors}")
        endif()
    endif()
    if(NOT status EQUAL 0 OR NOT output MATCHES "SUPERVISION_REGRESSION_OK")
        list(APPEND failures "${runtime}: ${output}${errors}")
    endif()
endforeach()
if(failures)
    list(JOIN failures "\n" detail)
    message(FATAL_ERROR "RAG-OPS-004 acceptance failed:\n${detail}")
endif()
message(STATUS "Supervision regression passed on both VMs with optimized code")
