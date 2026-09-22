#!/usr/bin/env python3
"""Zero-outbound relocated release check; all mutable state is private."""
import argparse
import json
import os
from pathlib import Path
import tempfile

from package import run, unpack, verify_inventory


def smoke(prefix, scratch):
    identity = verify_inventory(prefix, installed=True)
    binary = prefix / "bin" / ("crexxrag.exe" if os.name == "nt" else "crexxrag")
    env = dict(os.environ, CREXXRAG_SELF=str(binary.resolve()))
    # Exercise the delivered native application, without an SDK/provider search path.
    for key in ("CREXX_HOME", "REXX_HOME", "CREXXRAG_CONFIG", "RX_PLUGIN_PATH"):
        env.pop(key, None)
    import subprocess
    def command(access, *args):
        result = run(binary, "--library", scratch / "library", "--config", "architecture-local",
                     "--profile", "generic-profile", "--access", access, "--format", "json", *args,
                     cwd=scratch, env=env, stdout=subprocess.PIPE, text=True, timeout=60)
        document = json.loads(result.stdout)
        if document["status"] != "ok" or document["exit_code"] != 0:
            raise ValueError(document["message"])
        return document
    command("admin", "library", "init")
    result = command("control", "worker", "start", "--count", "2", "--poll-ms", "50", "--max-polls", "4")
    fields = result["records"][0]["fields"]
    if fields.get("workers_completed") != 2 or fields.get("workers_failed") != 0:
        raise ValueError("Packaged application did not supervise both workers")
    command("diagnose", "library", "verify")
    print(json.dumps(dict(source_commit=identity["source_commit"], platform=identity["platform"],
                         signing=identity["signing"], status="passed", provider_calls=0)))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--prefix", type=Path)
    source.add_argument("--archive", type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="rag installed smoke ") as directory:
        work = Path(directory)
        prefix = args.prefix.resolve() if args.prefix else work / "extracted payload"
        if args.archive:
            unpack(args.archive, prefix)
        smoke(prefix, work)
