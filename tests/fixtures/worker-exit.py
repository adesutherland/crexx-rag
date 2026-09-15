#!/usr/bin/env python3
"""Kill one actual worker while eight local provider fixtures rendezvous.

Only the scratch library supplied by NativeSupervision.cmake is used. Observe
replacement while healthy peers continue; verify receipts and unknown holds
independently of the command's success flag.
"""
import json
import os
from pathlib import Path
import signal
import sqlite3
import subprocess
import sys
import time

cell, job, mode = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
cli = sys.argv[4:]
db_path = cell / "library/library.sqlite"


def query(sql, parameters=()):
    with sqlite3.connect(db_path, timeout=10) as db:
        return db.execute(sql, parameters).fetchall()


def until(predicate, seconds=25):
    end = time.monotonic() + seconds
    while time.monotonic() < end:
        if predicate():
            return
        time.sleep(0.05)
    raise AssertionError("worker exit observation did not reach its expected state")


with (cell / "controller.out").open("w") as out, (cell / "controller.err").open("w") as err:
    controller = subprocess.Popen(cli + ["--access", "control", "job", "run", job,
        "--count", "8", "--max-polls", "2000", "--poll-ms", "20"], stdout=out, stderr=err)
    controller_pid = None
    try:
        until(lambda: len(list((cell / "sync").glob("*.ready"))) == 8)
        workers = query("SELECT instance_id,pid FROM runtime_instances WHERE kind='worker' AND state IN('idle','running')")
        assert len(workers) == 8
        controller_pid = query("SELECT pid FROM runtime_instances WHERE kind='controller'")[0][0]
        (cell / "registered-workers.json").write_text(json.dumps(workers))
        # Retain descriptor evidence when diagnosing delayed child completion.
        # This reads only the scratch workers, and is not a product probe.
        if Path("/usr/sbin/lsof").exists():
            observed = subprocess.run(["/usr/sbin/lsof", "-nP", "-a", "-p",
                ",".join(str(pid) for _, pid in workers), "-F", "pftn"],
                capture_output=True, text=True)
            (cell / "worker-descriptors.txt").write_text(observed.stdout)
        victim, pid = workers[0]
        item = query("SELECT item_id FROM attempts WHERE worker_id=? AND outcome='running'", (victim,))[0][0]
        before = query("SELECT model_call_budget,codex_turn_budget,input_token_budget,output_token_budget FROM jobs")
        if mode == "worker-write-error":
            query("CREATE TRIGGER reject_exit BEFORE UPDATE ON runtime_instances WHEN NEW.instance_id='" + victim + "' AND NEW.state='failed' BEGIN SELECT RAISE(ABORT,'fixture exit persistence failure'); END")
        os.kill(pid, signal.SIGKILL)
        (cell / "sync/released").touch()
        if mode == "worker-write-error":
            until(lambda: "fixture exit persistence failure" in (cell / "controller.err").read_text())
        else:
            until(lambda: query("SELECT count(*) FROM job_events WHERE event_type='worker-replacement'")[0][0] == 1)
            until(lambda: query("SELECT count(*) FROM runtime_instances WHERE kind='worker' AND state IN('idle','running') AND pid>0")[0][0] == 8)
            # All seven original peers remain alive and are not drained.
            for peer, peer_pid in workers[1:]:
                os.kill(peer_pid, 0)
                assert query("SELECT requested_state FROM runtime_instances WHERE instance_id=?", (peer,)) == [("none",)]
            assert query("SELECT state,exit_code FROM runtime_instances WHERE instance_id=?", (victim,))[0][0] == "failed"
        if mode == "worker-write-error":
            assert controller.wait(timeout=30) == 8
            assert query("SELECT count(*) FROM job_events WHERE event_type='worker-replacement'") == [(0,)]
        else:
            expected = 8 if mode == "worker-unknown" else 9
            until(lambda: query("SELECT count(*) FROM job_items WHERE item_type='claim-extraction' AND state='processed'")[0][0] == expected)
            assert query("SELECT count(*) FROM provider_runs") == [(9,)]
            assert query("SELECT count(*) FROM provider_runs WHERE outcome='succeeded'") == [(expected,)]
            assert query("SELECT count(*) FROM job_events WHERE event_type='provider-intent'") == [(9,)]
            assert query("SELECT count(*) FROM job_events WHERE item_id=? AND event_type='provider-intent'", (item,)) == [(1,)]
            assert query("SELECT count(*) FROM attempts WHERE worker_id=?", (victim,)) == [(1,)]
            assert query("SELECT count(*) FROM job_events WHERE event_type='worker-replacement'") == [(1,)]
            assert query("SELECT count(*) FROM provider_cooldowns WHERE failure_count>0") == [(0,)]
            if mode == "worker-unknown":
                assert query("SELECT state FROM job_items WHERE item_id=?", (item,)) == [("dead_letter",)]
                assert query("SELECT count(*) FROM job_events WHERE item_id=? AND event_type='provider-outcome-uncertain'", (item,)) == [(1,)]
            else:
                assert query("SELECT state FROM job_items WHERE item_id=?", (item,)) == [("processed",)]
            assert query("SELECT model_call_budget,codex_turn_budget,input_token_budget,output_token_budget FROM jobs") == before
            # End this bounded fixture through the ordinary drain signal.
            os.kill(controller_pid, signal.SIGTERM)
            assert controller.wait(timeout=30) == 0
            assert query("SELECT count(*) FROM attempts WHERE outcome='running'") == [(0,)]
            assert query("SELECT reserved_calls+reserved_tokens+reserved_cost+reserved_codex_turns FROM jobs") == [(0,)]
            assert query("PRAGMA integrity_check") == [("ok",)]
        print(json.dumps({"case": mode, "victim": victim, "runtime": query("SELECT instance_id,state,exit_code,detail FROM runtime_instances"),
            "attempts": query("SELECT item_id,worker_id,outcome FROM attempts")}))
    finally:
        (cell / "sync/released").touch()
        if controller.poll() is None:
            try:
                os.kill(controller_pid or controller.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                controller.wait(timeout=30)
            except subprocess.TimeoutExpired:
                controller.kill()
                controller.wait(timeout=5)
