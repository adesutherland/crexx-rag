foreach(required_var CPRAG_RXVME CPRAG_RXBVM CPRAG_CREXX_BIN_DIR
        CPRAG_APPLICATION CPRAG_LAUNCHER CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

get_filename_component(application_dir "${CPRAG_APPLICATION}" DIRECTORY)
set(load_path
    "${application_dir}/providers;${CPRAG_CREXX_BIN_DIR}/providers;${CPRAG_CREXX_BIN_DIR}")
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source-docs")
set(CPRAG_FIXTURE_GLOSSARY "")
set(CPRAG_FIXTURE_PORT 1)
file(MAKE_DIRECTORY "${CPRAG_FIXTURE_SOURCE}")
file(READ "${CMAKE_CURRENT_LIST_DIR}/../tests/fixtures/providers/gemini-ingestion.conf.in" worker_config)
string(REPLACE "config.id = gemini-loopback" "config.id = architecture-local" worker_config "${worker_config}")
string(REPLACE "profiles = it-architecture-profile" "profiles = generic-profile" worker_config "${worker_config}")
string(REPLACE "worker.processes = 2" "worker.processes = 8" worker_config "${worker_config}")
string(CONFIGURE "${worker_config}" worker_config @ONLY)
string(REPLACE "discovery.glossary_file = \n" "" worker_config "${worker_config}")
file(WRITE "${CPRAG_WORK_DIR}/workers.conf" "${worker_config}")
set(driver "${CPRAG_WORK_DIR}/process-framework.sh")
file(WRITE "${driver}" [=[
set -eu
runtime=$1
load_path=$2
application=$3
library=$4
output_dir=$5
launcher=$6
configuration=$7

export CREXXRAG_RUNTIME="$runtime"
export CREXXRAG_IMAGE="$application"
export CREXXRAG_LOAD_PATH="$load_path"
export CREXXRAG_SELF="$launcher"

run_app() {
  "$runtime" -l "$load_path" "$application" -a --config-file "$configuration" "$@"
}

run_app --library "$library" --config architecture-local \
  --profile generic-profile --access admin --format json library init \
  >"$output_dir/init.out" 2>"$output_dir/init.err"

set +e
run_app --library "$library" --config architecture-local --profile generic-profile --access control --format json worker start \
  --count 33 >"$output_dir/bounds.out" 2>"$output_dir/bounds.err"
bounds_status=$?
set -e
if [ "$bounds_status" -ne 2 ]; then
  exit 20
fi

for command in start run; do
  if [ "$command" = run ]; then set -- --follow; else set --; fi
  for limit in invalid -1 1000001; do
    set +e
    run_app --library "$library" --config architecture-local --profile generic-profile --access control --format json worker "$command" \
      "$@" --max-items "$limit" >"$output_dir/item-bounds-$command-$limit.out" 2>&1
    bounds_status=$?
    set -e
    if [ "$bounds_status" -ne 2 ]; then exit 25; fi
  done
done

run_app --library "$library" --config architecture-local --profile generic-profile --access control --format json worker start \
  --count 8 --poll-ms 50 --max-polls 40 --max-items 1 \
  >"$output_dir/controller.out" 2>"$output_dir/controller.err" &
controller=$!
tries=0
observed=0
while [ "$tries" -lt 80 ]; do
  if run_app --library "$library" --access read --format json worker list \
       --stale-seconds 2 >"$output_dir/observer.out" 2>"$output_dir/observer.err"; then
    idle_count=$(grep -o '"classification":"idle"' "$output_dir/observer.out" | wc -l | tr -d ' ')
    if [ "$idle_count" -ge 8 ]; then
      observed=1
      break
    fi
  fi
  sleep 0.05
  tries=$((tries + 1))
done
if [ "$observed" -ne 1 ]; then
  kill -KILL "$controller" 2>/dev/null || true
  wait "$controller" 2>/dev/null || true
  exit 21
fi
wait "$controller"

# A failed child launch must return with a diagnostic, not wait indefinitely
# for a reserved worker that never registered.
export CREXXRAG_RUNTIME="$output_dir/missing-runtime"
set +e
run_app --library "$library" --config architecture-local --profile generic-profile --access control --format json worker start \
  --count 2 --poll-ms 50 --max-polls 1 \
  >"$output_dir/startup-failure.out" 2>"$output_dir/startup-failure.err"
startup_status=$?
set -e
export CREXXRAG_RUNTIME="$runtime"
if [ "$startup_status" -eq 0 ] || [ ! -s "$output_dir/startup-failure.err" ]; then exit 26; fi

worker_id=worker-drain-qa
run_app --library "$library" --config architecture-local --profile generic-profile --access control --format json worker run \
  --id "$worker_id" --follow --poll-ms 50 --max-polls 200 \
  >"$output_dir/drain-worker.out" 2>"$output_dir/drain-worker.err" &
worker=$!
tries=0
while [ "$tries" -lt 80 ]; do
  if run_app --library "$library" --access read --format json worker status \
       "$worker_id" --stale-seconds 2 >"$output_dir/drain-status.out" \
       2>"$output_dir/drain-status.err"; then
    break
  fi
  sleep 0.05
  tries=$((tries + 1))
done
run_app --library "$library" --access control --format json worker drain \
  "$worker_id" >"$output_dir/drain.out" 2>"$output_dir/drain.err"
wait "$worker"

stale_id=worker-stale-qa
"$runtime" -l "$load_path" "$application" -a \
  --config-file "$configuration" --library "$library" --config architecture-local --profile generic-profile --access control --format json worker run \
  --id "$stale_id" --follow --poll-ms 50 \
  >"$output_dir/stale-worker.out" 2>"$output_dir/stale-worker.err" &
stale_worker=$!
tries=0
while [ "$tries" -lt 80 ]; do
  if run_app --library "$library" --access read --format json worker status \
       "$stale_id" --stale-seconds 1 >/dev/null 2>&1; then
    break
  fi
  sleep 0.05
  tries=$((tries + 1))
done
kill -KILL "$stale_worker"
wait "$stale_worker" 2>/dev/null || true
sleep 2
run_app --library "$library" --access read --format json worker status \
  "$stale_id" --stale-seconds 1 >"$output_dir/stale-status.out" \
  2>"$output_dir/stale-status.err"
run_app --library "$library" --access control --format json worker prune \
  --stale-seconds 1 >"$output_dir/prune.out" 2>"$output_dir/prune.err"
run_app --library "$library" --access read --format json worker list \
  --stale-seconds 1 >"$output_dir/final-list.out" 2>"$output_dir/final-list.err"
]=])

foreach(runtime IN ITEMS "${CPRAG_RXVME}" "${CPRAG_RXBVM}")
    get_filename_component(runtime_name "${runtime}" NAME)
    set(cell_dir "${CPRAG_WORK_DIR}/${runtime_name}")
    set(library "${cell_dir}/library")
    file(MAKE_DIRECTORY "${cell_dir}")
    execute_process(
        COMMAND /bin/sh "${driver}" "${runtime}" "${load_path}"
            "${CPRAG_APPLICATION}" "${library}" "${cell_dir}" "${CPRAG_LAUNCHER}" "${CPRAG_WORK_DIR}/workers.conf"
        WORKING_DIRECTORY "${cell_dir}"
        RESULT_VARIABLE result
        OUTPUT_VARIABLE shell_out
        ERROR_VARIABLE shell_err
        # The complete sequence launches many independent CLIs (29.3 seconds
        # in the traced local run); keep margin around the existing poll bounds.
        TIMEOUT 60)
    if(NOT result EQUAL 0)
        message(FATAL_ERROR
            "${runtime_name} process framework failed (${result}):\n${shell_out}${shell_err}")
    endif()
    file(READ "${cell_dir}/init.out" init_out)
    file(READ "${cell_dir}/init.err" init_err)
    file(READ "${cell_dir}/controller.out" controller_out)
    file(READ "${cell_dir}/controller.err" controller_err)
    file(READ "${cell_dir}/observer.out" observer_out)
    file(READ "${cell_dir}/observer.err" observer_err)
    file(READ "${cell_dir}/bounds.out" bounds_out)
    file(READ "${cell_dir}/bounds.err" bounds_err)
    file(READ "${cell_dir}/drain-status.out" drain_status_out)
    file(READ "${cell_dir}/drain-status.err" drain_status_err)
    file(READ "${cell_dir}/drain.out" drain_out)
    file(READ "${cell_dir}/drain.err" drain_err)
    file(READ "${cell_dir}/drain-worker.out" drain_worker_out)
    file(READ "${cell_dir}/drain-worker.err" drain_worker_err)
    file(READ "${cell_dir}/stale-status.out" stale_status_out)
    file(READ "${cell_dir}/stale-status.err" stale_status_err)
    file(READ "${cell_dir}/prune.out" prune_out)
    file(READ "${cell_dir}/prune.err" prune_err)
    file(READ "${cell_dir}/final-list.out" final_list_out)
    file(READ "${cell_dir}/final-list.err" final_list_err)
    string(FIND "${final_list_out}" "\"records\":[]" empty_records_position)
    if(NOT init_out MATCHES "\"schema_version\":14" OR
       NOT controller_out MATCHES "\"workers_requested\":8" OR
       NOT controller_out MATCHES "\"workers_completed\":8" OR
       NOT controller_out MATCHES "\"workers_failed\":0" OR
       NOT bounds_out MATCHES "\"operation\":\"worker.start\",\"status\":\"error\",\"exit_code\":2" OR
       NOT observer_out MATCHES "\"kind\":\"controller\"" OR
       NOT observer_out MATCHES "\"kind\":\"worker\"" OR
       NOT observer_out MATCHES "\"pid_check\":\"alive\"" OR
       NOT drain_status_out MATCHES "\"classification\":\"idle\"" OR
       NOT drain_out MATCHES "\"requested_state\":\"drain\"" OR
       NOT drain_worker_out MATCHES "\"operation\":\"worker.run\",\"status\":\"ok\"" OR
       NOT stale_status_out MATCHES "\"classification\":\"stale\"" OR
       NOT stale_status_out MATCHES "\"pid_check\":\"missing\"" OR
       NOT prune_out MATCHES "\"rows_deleted\":[1-9][0-9]*" OR
       empty_records_position LESS 0)
        message(FATAL_ERROR
            "${runtime_name} process framework assertions failed:\n"
            "${init_out}${init_err}${bounds_out}${bounds_err}${controller_out}${controller_err}"
            "${observer_out}${observer_err}${drain_status_out}${drain_status_err}"
            "${drain_out}${drain_err}${drain_worker_out}${drain_worker_err}"
            "${stale_status_out}${stale_status_err}${prune_out}${prune_err}"
            "${final_list_out}${final_list_err}")
    endif()
endforeach()

execute_process(
    COMMAND "${CPRAG_LAUNCHER}"
        --library "${CPRAG_WORK_DIR}/rxvme/library"
        --access read --format json worker list --stale-seconds 1
    RESULT_VARIABLE launcher_result
    OUTPUT_VARIABLE launcher_out
    ERROR_VARIABLE launcher_err
    TIMEOUT 10)
if(NOT launcher_result EQUAL 0 OR
   NOT launcher_out MATCHES "\"operation\":\"worker.list\",\"status\":\"ok\"")
    message(FATAL_ERROR
        "staged launcher did not execute the linked application:\n${launcher_out}${launcher_err}")
endif()

message(STATUS
    "Process framework passed eight-worker registration, startup diagnostics, drain, stale detection and explicit pruning on both VMs")
