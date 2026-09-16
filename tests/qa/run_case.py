#!/usr/bin/env python3
"""CTest execution boundary: private files, owned children, and exact-input pass reuse.
CTest alone selects/orders/schedules cases. This module never invokes another test.
"""
import argparse
import contextlib
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import uuid


def digest(path):
    h = hashlib.sha256()
    with open(path, 'rb') as source:
        for block in iter(lambda: source.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


@contextlib.contextmanager
def lock(path):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('a') as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        yield


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--name', required=True)
    parser.add_argument('--input', action='append', default=[])
    parser.add_argument('--artifact', action='append', default=[])
    parser.add_argument('--port', action='append', default=[])
    parser.add_argument('--inspect', action='store_true', help='report current evidence without executing')
    parser.add_argument('--force', action='store_true', help='explicit repeatability experiment')
    parser.add_argument('--timeout', type=float, default=float(os.environ.get('CREXXRAG_TEST_TIMEOUT', '300')))
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ['--'] else args.command
    prepared = time.monotonic()
    root = args.root.resolve()
    inputs = set(str(Path(p).resolve()) for p in args.input)
    cohorts = {str(Path(p).parent) for p in inputs if p.endswith(('.conf', '.in'))}
    for directory in cohorts:
        inputs.update(str(p.resolve()) for p in Path(directory).rglob('*') if p.is_file())
    inputs = sorted(inputs)
    artifacts = set()
    for artifact in args.artifact:
        path = Path(artifact).resolve()
        if path.is_dir():
            artifacts.update(str(p) for p in path.rglob('*') if p.is_file() and p.suffix in ('.rxbin', '.rxproviders', '.rxplugin'))
        else:
            artifacts.add(str(path))
    artifacts = sorted(artifacts)
    identity = {'command': command, 'inputs': {p: digest(p) for p in inputs},
                'artifacts': {p: digest(p) for p in artifacts},
                'runner': digest(__file__), 'python': sys.version, 'timeout': args.timeout, 'ports': sorted(args.port), 'environment': {
                    k: os.environ.get(k, '') for k in ['PATH', 'TZ', 'LANG', 'LC_ALL', 'CREXXRAG_TEST_TIMEOUT', 'CPRAG_CONFIG_FIXTURE']}}
    key = hashlib.sha256(json.dumps(identity, sort_keys=True).encode()).hexdigest()
    receipt = root / 'results' / args.name / (key + '.json')
    if args.inspect:
        prior = json.loads(receipt.read_text()) if receipt.exists() else None
        print(json.dumps({'case': args.name, 'key': key, 'result': prior}))
        return 0
    with lock(root/'locks'/('case-'+args.name)):
        if not args.force and receipt.exists():
            prior = json.loads(receipt.read_text())
            if prior['outcome'] == 'passed':
                print(f"REUSED PASS {args.name}: unchanged inputs; {prior['directory']}")
                return 125
        previous = list((root/'results'/args.name).glob('*.json'))
        reason = 'explicit repeatability' if args.force else 'prior failure or interruption' if receipt.exists() else 'changed inputs' if previous else 'first execution'
        execution = root/'runs'/args.name/(time.strftime('%Y%m%dT%H%M%S')+'-'+uuid.uuid4().hex[:8])
        execution.mkdir(parents=True)
        copies = {}
        for number, source in enumerate(inputs):
            # Test drivers use sibling includes; preserve their read-only location.
            # Mutable data/config fixtures get private copies, including directory trees.
            if source.endswith(('.cmake', '.py', '.crexx', '.sh')):
                continue
            dest = execution/'inputs'/str(number)/Path(source).name
            dest.parent.mkdir(parents=True, exist_ok=True)
            if str(Path(source).parent) in cohorts and source.endswith(('.conf', '.in')):
                # Relative profiles/prompts/glossaries are part of the fixture,
                # not shared inputs silently read back from the source tree.
                shutil.copytree(Path(source).parent, dest.parent, dirs_exist_ok=True)
            else:
                shutil.copy2(source, dest)
            copies[source] = str(dest)
        work = execution/'work'
        rewritten = []
        for arg in command:
            if arg.startswith('-DCPRAG_WORK_DIR='):
                arg = '-DCPRAG_WORK_DIR='+str(work)
            else:
                value = arg.split('=', 1)[1] if arg.startswith('-D') and '=' in arg else arg
                if Path(value).is_absolute():
                    dest = copies.get(str(Path(value).resolve()))
                    if dest:
                        arg = arg[:-len(value)] + dest
            rewritten.append(arg)
        (execution/'command.json').write_text(json.dumps(rewritten, indent=2)+'\n')
        tmp = execution/'tmp'; tmp.mkdir()
        environment = os.environ.copy()
        environment.update(TMPDIR=str(tmp), TMP=str(tmp), TEMP=str(tmp))
        # Port locks are process-wide, not merely CTest-invocation-wide. Fixed
        # endpoint protocol fixtures retain their endpoint while isolated cases
        # using other ports run concurrently. Never probe/release a free port.
        setup_seconds = time.monotonic()-prepared
        started = time.monotonic()
        proc = None
        interrupted = False
        def stop(signum, frame):
            nonlocal interrupted
            interrupted = True
            if proc is None:
                raise SystemExit(130)
            if proc is not None:
                with contextlib.suppress(ProcessLookupError):
                    os.killpg(proc.pid, signal.SIGTERM)
        signal.signal(signal.SIGTERM, stop)
        signal.signal(signal.SIGINT, stop)
        with contextlib.ExitStack() as stack:
            for port in sorted(set(args.port), key=int):
                stack.enter_context(lock(Path(tempfile.gettempdir())/'crexxrag-qa-port-locks'/str(port)))
            waited = time.monotonic()-started
            launched = time.monotonic()
            with (execution/'output.log').open('w') as output:
                proc = subprocess.Popen(rewritten, cwd=execution, env=environment,
                                        stdout=output, stderr=subprocess.STDOUT,
                                        start_new_session=True)
                try:
                    while True:
                        try:
                            code = proc.wait(timeout=0.2)
                            break
                        except subprocess.TimeoutExpired:
                            if interrupted or time.monotonic()-launched > args.timeout:
                                was_interrupted = interrupted
                                stop(signal.SIGTERM, None)
                                interrupted = was_interrupted
                                try:
                                    code = proc.wait(timeout=2)
                                except subprocess.TimeoutExpired:
                                    os.killpg(proc.pid, signal.SIGKILL)
                                    code = proc.wait()
                                code = 130 if interrupted else 124
                                break
                finally:
                    run_seconds = time.monotonic()-launched
                    cleanup_started = time.monotonic()
                    # Ordinary descendants inherit the case process group.
                    with contextlib.suppress(ProcessLookupError):
                        os.killpg(proc.pid, signal.SIGTERM)
                    with contextlib.suppress(ProcessLookupError):
                        os.killpg(proc.pid, signal.SIGKILL)
            elapsed = time.monotonic()-started
        outcome = 'interrupted' if interrupted else 'passed' if code == 0 else 'failed'
        result = {'case': args.name, 'identity': identity, 'outcome': outcome,
                  'exit_code': code, 'seconds': round(elapsed, 3),
                  'resource_wait_seconds': round(waited, 3), 'setup_seconds': round(setup_seconds, 3),
                  'run_seconds': round(run_seconds, 3), 'cleanup_seconds': round(time.monotonic()-cleanup_started, 3),
                  'reason': reason, 'directory': str(execution)}
        receipt.parent.mkdir(parents=True, exist_ok=True)
        (execution/'result.json').write_text(json.dumps(result, indent=2)+'\n')
        temporary = receipt.with_suffix('.tmp')
        temporary.write_text(json.dumps(result, indent=2)+'\n'); temporary.replace(receipt)
        print(f"{outcome.upper()} {args.name}: {elapsed:.2f}s; logs: {execution}")
        if code:
            print((execution/'output.log').read_text(errors='replace')[-24000:])
        return 0 if code == 0 else 1

if __name__ == '__main__':
    sys.exit(main())
