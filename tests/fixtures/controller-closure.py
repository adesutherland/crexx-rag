#!/usr/bin/env python3
"""Observe real controller exits after isolated pipe closures or named signals.

Diagnostic fixture only: the observer survives to retain the actual OS wait
status and the scratch runtime rows. No Codex, model calls or corpus work.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import signal
import sqlite3
import subprocess
import sys

# Keep this diagnostic module import from creating files in the checkout.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("launcher", Path(__file__).with_name("launcher-exit.py"))
launcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launcher)


def exercise(application, root, mode):
    case = root / mode
    command, env = launcher.prepare(application, case)
    controller = None
    with (case / "controller.stdout").open("w") as out, (case / "controller.stderr").open("w") as err:
        controller = subprocess.Popen(command, cwd=case, env=env,
            stdin=subprocess.PIPE if mode == "stdin_eof" else subprocess.DEVNULL,
            stdout=subprocess.PIPE if mode == "stdout_closed" else out,
            stderr=subprocess.PIPE if mode == "stderr_closed" else err)
        try:
            launcher.until(lambda: len(launcher.rows(case)) == 2 and
                all(row["state"] == ("running" if row["kind"] == "controller" else "idle")
                    and (row["kind"] == "controller" or row["detail"] == "waiting for durable work")
                    for row in launcher.rows(case)))
            before = dict(process=launcher.process(controller.pid), runtime=launcher.rows(case))
            launcher.save(case / "before.json", before)
            if mode == "stdin_eof":
                controller.stdin.close()
            elif mode == "stdout_closed":
                controller.stdout.close()
            elif mode == "stderr_closed":
                controller.stderr.close()
            elif mode != "control":
                os.kill(controller.pid, getattr(signal, "SIG" + mode.upper()))
            code = controller.wait(timeout=30)
            # The real worker is bounded even if its controller dies. Retain its
            # result only after it exits, rather than assuming it was killed.
            launcher.until(lambda: all(launcher.exited(row["pid"]) for row in launcher.rows(case)))
            with sqlite3.connect(f"file:{case}/library/library.sqlite?mode=ro", uri=True) as db:
                counts = db.execute("SELECT (SELECT count(*) FROM jobs),(SELECT count(*) FROM provider_runs)").fetchone()
            assert counts == (0, 0)
            report = dict(mode=mode, controller_pid=controller.pid, os_exit_code=code,
                os_signal=signal.Signals(-code).name if code < 0 else None,
                before=before, final_runtime=launcher.rows(case), jobs=0, provider_runs=0)
            launcher.save(case / "result.json", report)
            print(json.dumps({k: report[k] for k in ("mode", "os_exit_code", "os_signal", "final_runtime")}), flush=True)
            if mode != "kill":
                assert code == 0, f"{mode}: expected ordinary exit, got {code}"
                assert all(row["state"] == "stopped" and row["exit_code"] == 0 for row in report["final_runtime"])
                if mode in ("term", "hup", "int"):
                    assert "shutdown requested" in report["final_runtime"][0]["detail"]
                    assert "SIG" + mode.upper() in report["final_runtime"][0]["detail"]
            else:
                assert code == -signal.SIGKILL
        finally:
            if controller.poll() is None:
                controller.kill()
                controller.wait(timeout=5)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--application", type=Path, required=True)
    parser.add_argument("--work-dir", type=Path, required=True)
    parser.add_argument("--cases", nargs="+", choices=("control", "stdin_eof", "stdout_closed", "stderr_closed", "term", "hup", "int", "kill"),
        default=("control", "stdin_eof", "stdout_closed", "stderr_closed", "term", "hup", "int", "kill"))
    args = parser.parse_args()
    root = args.work_dir.resolve()
    root.mkdir()
    failures = []
    for mode in args.cases:
        try:
            exercise(args.application.resolve(), root, mode)
        except AssertionError as error:
            failures.append(f"{mode}: {error}")
    if failures:
        raise AssertionError("; ".join(failures))
