set(CPRAG_RXC /Users/adrian/.local/bin/rxc)
set(CPRAG_RXAS /Users/adrian/.local/bin/rxas)
set(CPRAG_RXVME /Users/adrian/.local/bin/rxvme)
set(CPRAG_RXBVM /Users/adrian/.local/bin/rxbvm)
set(CPRAG_CREXX_BIN_DIR /Users/adrian/.local/bin)
set(CPRAG_PLUGIN_DIR /Users/adrian/.local/bin/providers)
set(CPRAG_APPLICATION_DIR /Users/adrian/CLionProjects/crexx-rag-review/cmake-build-debug/crexx-application)
set(CPRAG_SCENARIO /private/tmp/supervision-race-diagnostic.crexx)
set(CPRAG_WORK_DIR /private/tmp/crexx-openclose-race)
include(/Users/adrian/CLionProjects/crexx-rag-review/cmake/SupervisionRegression.cmake)
set(program /private/tmp/crexx-openclose-race/openclose)
execute_process(COMMAND "${CPRAG_RXC}" -i "${imports}" -o "${program}" /private/tmp/openclose-race.crexx COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CPRAG_RXAS}" -o "${program}" "${program}" COMMAND_ERROR_IS_FATAL ANY)
file(WRITE /private/tmp/crexx-openclose-race/compete.sh [=[
set -u
folder=$1
shift
pids=""
for n in 1 2 3 4 5 6 7 8; do
  "$@" >"$folder/peer-$n.log" 2>&1 &
  pids="$pids $!"
done
failed=0
for child in $pids; do
  wait "$child" || failed=1
done
cat "$folder"/peer-*.log
exit "$failed"
]=])
foreach(runtime IN ITEMS RXVME RXBVM)
    file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/results-${runtime}")
    execute_process(COMMAND /bin/sh /private/tmp/crexx-openclose-race/compete.sh
      "${CPRAG_WORK_DIR}/results-${runtime}" "${CPRAG_${runtime}}" -l "${imports}" "${program}" ${modules}
      -a "${CPRAG_WORK_DIR}/library-${runtime}"
      RESULT_VARIABLE competed OUTPUT_VARIABLE competition ERROR_VARIABLE competition_error TIMEOUT 90)
    message(STATUS "${runtime} result=${competed} ${competition}${competition_error}")
endforeach()
