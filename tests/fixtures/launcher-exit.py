#!/usr/bin/env python3
"""Test an ordinary launching parent's exit, without Codex or provider work.

The observer starts a Python parent, which starts the real cREXX-RAG controller.
No setsid, shell backgrounding, terminal, signal or daemon is involved. An empty
scratch library exercises the controller/worker lifetime with bounded idle polls.
"""
import argparse
import json
import os
from pathlib import Path
import sqlite3
import subprocess
import sys
import time


def save(path, value):
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, indent=2) + "\n")
    temporary.replace(path)


def until(predicate, seconds=30):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        result = predicate()
        if result:
            return result
        time.sleep(0.05)
    raise AssertionError("fixture rendezvous timed out")


def rows(case):
    with sqlite3.connect(f"file:{case}/library/library.sqlite?mode=ro", uri=True) as db:
        db.row_factory = sqlite3.Row
        return [dict(row) for row in db.execute(
            "SELECT kind,pid,state,heartbeat_at,exit_code,detail "
            "FROM runtime_instances ORDER BY kind,pid")]


def process(pid):
    result = subprocess.run(["ps", "-p", str(pid), "-o", "pid=,ppid=,pgid=,stat="],
                            text=True, capture_output=True, check=False)
    fields = result.stdout.split()
    if not fields:
        return None
    return dict(pid=int(fields[0]), ppid=int(fields[1]), pgid=int(fields[2]), state=fields[3])


def exited(pid):
    observation = process(pid)
    return not observation or observation["state"].startswith("Z")


def parent(case):
    spec = json.loads((case / "launch.json").read_text())
    with (case / "controller.stdout").open("w") as out, (case / "controller.stderr").open("w") as err:
        child = subprocess.Popen(spec["argv"], cwd=case, stdin=subprocess.DEVNULL,
                                 stdout=out, stderr=err)
    save(case / "parent.json", dict(parent_pid=os.getpid(), controller_pid=child.pid))
    until(lambda: (case / "release-parent").exists())
    if spec["mode"] == "wait":
        save(case / "waited-exit.json", dict(os_exit_code=child.wait(timeout=30)))
    # In exit mode, returning normally leaves the child alone. No signal is sent.


def prepare(application, case):
    case.mkdir()
    (case / "source").mkdir()
    (case / "glossary.tsv").write_text("format\tcrexx-rag.glossary/1\n")
    template = Path(__file__).parent / "providers/codex-application.conf.in"
    config = template.read_text().replace("@CPRAG_FIXTURE_SOURCE@", str(case / "source"))
    config = config.replace("@CPRAG_FIXTURE_GLOSSARY@", str(case / "glossary.tsv"))
    config = config.replace("@CPRAG_FIXTURE_PORT@", "1")
    (case / "crexxrag.conf").write_text(config)
    env = os.environ.copy()
    env["CREXXRAG_SELF"] = str(application)
    # Fail locally if a future change unexpectedly tries to invoke a provider.
    env["CREXXRAG_CODEX"] = str(case / "no-provider-executable")
    cli = [str(application), "--library", str(case / "library"), "--config-file",
           str(case / "crexxrag.conf"), "--profile", "it-architecture-profile",
           "--format", "json", "--progress", "plain"]
    init = subprocess.run(cli + ["--access", "admin", "library", "init"], env=env,
                          cwd=case, text=True, capture_output=True, timeout=30)
    save(case / "init.json", dict(exit_code=init.returncode, stdout=init.stdout, stderr=init.stderr))
    assert init.returncode == 0, init.stderr + init.stdout
    command = cli + ["--access", "control", "worker", "start", "--poll-ms", "100", "--max-polls", "80"]
    return command, env


def exercise(application, root, mode):
    case = root / mode
    command, env = prepare(application, case)
    save(case / "launch.json", dict(mode=mode, argv=command))
    launching_parent = subprocess.Popen([sys.executable, str(Path(__file__).resolve()),
                                        "--parent", str(case)], env=env)
    try:
        identity = until(lambda: json.loads((case / "parent.json").read_text())
                         if (case / "parent.json").exists() else None)
        until(lambda: len(rows(case)) == 2 and
              all(row["state"] == "running" if row["kind"] == "controller"
                  else row["state"] == "idle" for row in rows(case)))
        before = dict(parent=process(launching_parent.pid),
                      controller=process(identity["controller_pid"]), runtime=rows(case))
        assert before["controller"]["ppid"] == launching_parent.pid
        (case / "release-parent").touch()
        if mode == "exit":
            assert launching_parent.wait(timeout=5) == 0
        # Observe a later heartbeat; elapsed time here is not a performance gate.
        initial_heartbeat = before["runtime"][0]["heartbeat_at"]
        until(lambda: rows(case)[0]["heartbeat_at"] > initial_heartbeat)
        after = dict(parent=process(launching_parent.pid),
                     controller=process(identity["controller_pid"]), runtime=rows(case))
        assert after["controller"] and after["runtime"][0]["state"] == "running"
        assert all(process(row["pid"]) for row in after["runtime"])
        if mode == "exit":
            assert after["parent"] is None
            assert after["controller"]["ppid"] != launching_parent.pid
        else:
            assert after["parent"] and after["controller"]["ppid"] == launching_parent.pid
        until(lambda: all(row["state"] == "stopped" and row["exit_code"] == 0 for row in rows(case)))
        until(lambda: exited(identity["controller_pid"]))
        assert launching_parent.wait(timeout=5) == 0
        os_exit_code = None
        if mode == "wait":
            os_exit_code = json.loads((case / "waited-exit.json").read_text())["os_exit_code"]
            assert os_exit_code == 0
        result = json.loads((case / "controller.stdout").read_text())
        assert result["exit_code"] == 0
        with sqlite3.connect(f"file:{case}/library/library.sqlite?mode=ro", uri=True) as db:
            counts = db.execute("SELECT (SELECT count(*) FROM jobs),(SELECT count(*) FROM provider_runs)").fetchone()
        assert counts == (0, 0)
        report = dict(mode=mode, before=before, after=after, final_runtime=rows(case),
                      product_exit_code=result["exit_code"], jobs=0, provider_runs=0,
                      parent_exit_code=launching_parent.returncode,
                      controller_os_exit_code=os_exit_code,
                      outcome="controller and worker survived; bounded run completed")
        save(case / "result.json", report)
        print(json.dumps(dict(mode=mode, outcome=report["outcome"],
                              controller_parent_after=after["controller"]["ppid"], provider_runs=0)), flush=True)
    finally:
        if launching_parent.poll() is None:
            launching_parent.terminate()
            launching_parent.wait(timeout=5)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--application", type=Path)
    parser.add_argument("--work-dir", type=Path)
    parser.add_argument("--parent", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.parent:
        parent(args.parent)
    else:
        if not args.application or not args.work_dir:
            parser.error("--application and a new --work-dir are required")
        args.work_dir = args.work_dir.resolve()
        args.work_dir.mkdir()  # Never remove or reuse an existing library.
        for case_mode in ("wait", "exit"):
            exercise(args.application.resolve(), args.work_dir, case_mode)
