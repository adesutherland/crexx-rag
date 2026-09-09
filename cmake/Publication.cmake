foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_APPLICATION_DIR CPRAG_PLUGIN_DIR CPRAG_SCENARIO CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
find_program(sqlite_cli sqlite3 REQUIRED)
set(heartbeat_driver "${CPRAG_WORK_DIR}/heartbeat-contention.sh")
file(WRITE "${heartbeat_driver}" [=[
set -eu
sqlite=$1; runtime=$2; providers=$3; imports=$4; scenario=$5; library=$6
shift 6
locker=; contender=
cleanup() {
  if [ -n "$contender" ]; then kill "$contender" 2>/dev/null || true; fi
  if [ -n "$locker" ]; then kill "$locker" 2>/dev/null || true; fi
}
trap cleanup EXIT HUP INT TERM
mkfifo "$library/heartbeat-control"
"$sqlite" "$library/library.sqlite" <"$library/heartbeat-control" >"$library/locker.out" 2>"$library/locker.err" &
locker=$!
exec 3>"$library/heartbeat-control"
printf 'BEGIN IMMEDIATE;\n.shell touch "%s/heartbeat-locked"\n' "$library" >&3
tries=0
until [ -f "$library/heartbeat-locked" ]; do
  tries=$((tries+1)); [ "$tries" -lt 1000 ] || exit 20
  kill -0 "$locker" 2>/dev/null || exit 21
  sleep 0.01
done
"$runtime" --provider-path "$providers" -l "$imports" "$scenario" "$@" -a "$library" heartbeat >"$library/heartbeat.out" 2>"$library/heartbeat.err" &
contender=$!
tries=0
# Release only after the product has observed SQLITE_BUSY and announced its
# retry. This handshake, not a timed sleep, proves recovery on a later attempt.
until grep -q 'retry=1/2:.*sqlite=5,extended=5,operation=step' "$library/heartbeat.err"; do
  tries=$((tries+1)); [ "$tries" -lt 1500 ] || exit 22
  kill -0 "$contender" 2>/dev/null || exit 23
  sleep 0.01
done
printf 'COMMIT;\n.quit\n' >&3
exec 3>&-
wait "$locker"; locker=
wait "$contender"; contender=
grep -q 'HEARTBEAT_RESUMED' "$library/heartbeat.out"
]=])
file(GLOB project_member_dirs LIST_DIRECTORIES true
    "${CPRAG_APPLICATION_DIR}/project/crexxrag-project.crexx-build/members/*")
list(JOIN project_member_dirs ";" project_imports)
set(imports "${CPRAG_WORK_DIR};${project_imports};${CPRAG_APPLICATION_DIR};${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
set(modules ragenrich ragproposalio ragperiod ragprovenance ragassessment ragmodel ragevidence
    ragjob ragconfig ragprofile ragregistry ragschema ragfile ragconfigfile ragglossary
    ragstore ragbackup ragrepository ragcanonical ragplanning ragtrace ragcommand ragingest
    ragfolder ragclaims ragimprove ragmaintain ragbacklog ragwork ragquery ragembedding
    ragretrieval ragevidencejson ragfoundation ragprocess ragproviderdiagnostics raggrounding ragapplicationprovider ragqueryprovider
    ragquerypolicy ragproduct provider_contract provider_catalog provider_http industrial_provider codex_provider architecture_local_config
    generic_profile it_architecture_profile operator_registry rxsqlite rx_hash rx_system rxfs rxplatform
    rxvector rxfnsg library)

execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}"
    -o "${CPRAG_WORK_DIR}/publication_scenario" "${CPRAG_SCENARIO}"
    RESULT_VARIABLE compile_result OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err)
if(NOT compile_result EQUAL 0)
    message(FATAL_ERROR "Publication scenario compile failed:\n${compile_out}${compile_err}")
endif()
execute_process(COMMAND "${CPRAG_RXAS}" -o "${CPRAG_WORK_DIR}/publication_scenario"
    "${CPRAG_WORK_DIR}/publication_scenario"
    RESULT_VARIABLE assemble_result OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err)
if(NOT assemble_result EQUAL 0)
    message(FATAL_ERROR "Publication scenario assembly failed:\n${assemble_out}${assemble_err}")
endif()

foreach(runtime_name IN ITEMS rxvme rxbvm)
    if(runtime_name STREQUAL "rxvme")
        set(runtime "${CPRAG_RXVME}")
    else()
        set(runtime "${CPRAG_RXBVM}")
    endif()
    set(library "${CPRAG_WORK_DIR}/library-${runtime_name}")
    execute_process(COMMAND "${runtime}"
        --provider-path "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers"
        -l "${imports}" "${CPRAG_WORK_DIR}/publication_scenario" ${modules}
        -a "${library}"
        RESULT_VARIABLE run_result OUTPUT_VARIABLE run_out ERROR_VARIABLE run_err TIMEOUT 120)
    if(NOT run_result EQUAL 0 OR NOT run_out MATCHES "PUBLICATION_OK")
        message(FATAL_ERROR "${runtime_name} publication failed:\n${run_out}${run_err}")
    endif()
    execute_process(COMMAND /bin/sh "${heartbeat_driver}" "${sqlite_cli}" "${runtime}"
        "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}/providers" "${imports}"
        "${CPRAG_WORK_DIR}/publication_scenario" "${library}" ${modules}
        RESULT_VARIABLE heartbeat_result OUTPUT_VARIABLE heartbeat_out ERROR_VARIABLE heartbeat_err TIMEOUT 30)
    if(NOT heartbeat_result EQUAL 0)
        file(READ "${library}/heartbeat.err" heartbeat_diagnostic)
        message(FATAL_ERROR "${runtime_name} heartbeat contention failed (${heartbeat_result}):\n${heartbeat_out}${heartbeat_err}${heartbeat_diagnostic}")
    endif()
endforeach()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "Publication passed independent-connection ownership, late batch rejection with zero partial graph publication, retained provider accounting and released reservations, failed/successful generation rollback with aligned manifest and preserved FTS, and cancellation during an admitted call with accounted usage, released reservations, terminal cancellation and zero graph publication on both VMs.\n")
message(STATUS "Publication assertions passed on both VMs")
