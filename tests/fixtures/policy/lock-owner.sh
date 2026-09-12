#!/bin/sh
# Test-only crash fixture. All task paths arrive as quoted environment values.
set -u
policy_lock_pid=
cleanup() {
    if [ -n "$policy_lock_pid" ]; then kill -KILL "$policy_lock_pid" 2>/dev/null || :; wait "$policy_lock_pid" 2>/dev/null || :; fi
    rm -f "$TEST_FIFO" "$TEST_READY"
}
trap cleanup EXIT HUP INT TERM
mkfifo "$TEST_FIFO" || exit 1
"$TEST_SQLITE" "$TEST_LOCK" <"$TEST_FIFO" >"$TEST_BUSY.lock-log" 2>&1 &
policy_lock_pid=$!
exec 3>"$TEST_FIFO"
printf '%s\n' 'BEGIN EXCLUSIVE;' '.shell touch "$TEST_READY"' >&3
poll=0
while [ ! -f "$TEST_READY" ]; do
    poll=$((poll + 1))
    if [ "$poll" -ge 200 ]; then exit 2; fi
    sleep 0.02
done
"$TEST_NATIVE" --config-file "$TEST_POLICY" --access admin --format json config set --key worker.max_restarts --value 1 --expect-sha256 "$TEST_HASH" >"$TEST_BUSY"
result=$?
if [ "$result" -ne 6 ]; then cat "$TEST_BUSY"; exit 3; fi
kill -KILL "$policy_lock_pid" || exit 4
wait "$policy_lock_pid" 2>/dev/null || :
policy_lock_pid=
exec 3>&-
exit 0
