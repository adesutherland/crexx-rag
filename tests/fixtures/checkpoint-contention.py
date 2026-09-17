"""Eight isolated processes contend only on this case's deliberate shared fixture."""
import concurrent.futures
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sqlite3
import subprocess
import sys
import time

folder = Path(sys.argv[1])
command = sys.argv[2:]
# The failed-lock path cannot write an event but must still emit correct UTC.
clock_log = folder.parent / ("checkpoint-" + folder.name.removeprefix("library-") + ".log")
for line in clock_log.read_text().splitlines():
    if not line.startswith('{"event":"transaction-lock-failed"'):
        continue
    event = json.loads(line)
    assert event["utc_offset_seconds"] == 0
    stamp = datetime.fromisoformat(event["timestamp"].replace("Z", "+00:00"))
    assert abs((datetime.now(timezone.utc) - stamp).total_seconds()) < 120, "failed lock clock disagrees with UTC"

processes = [subprocess.Popen(command + ["checkpoint-poll"], stdin=subprocess.PIPE,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True) for _ in range(8)]
try:
    for process in processes:
        assert process.stdout.readline().strip() == "CHECKPOINT_READY", "worker did not open before contention"
    with sqlite3.connect(folder / "library.sqlite") as lock:
        before = list(lock.iterdump())
        lock.execute("BEGIN IMMEDIATE")
        def poll(entry):
            index, process = entry
            started = time.monotonic()
            output, errors = process.communicate("release\n", timeout=15)
            elapsed = time.monotonic() - started
            (folder / f"poll-{index}.log").write_text(output + errors)
            waits = [int(value) for value in re.findall(r'"lock_wait_ms":(\d+)', errors)]
            return {"worker": index, "exit": process.returncode, "seconds": elapsed,
                    "failed_begins": len(waits), "lock_wait_ms": sum(waits), "result": output.strip()}
        started = time.monotonic()
        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
            results = list(pool.map(poll, enumerate(processes)))
        duration = time.monotonic() - started
        lock.rollback()
        after = list(lock.iterdump())
    report = {"pollers": 8, "polls_per_worker": 20, "seconds": duration,
              "unchanged": before == after, "workers": results}
    (folder / "checkpoint-contention.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report))
    assert before == after, "polling changed state while another writer owned the transaction"
    assert all(row["exit"] == 0 for row in results), "avoidable checkpoint writer acquisition lost workers"
finally:
    for process in processes:
        if process.poll() is None:
            process.kill()
        process.wait()
