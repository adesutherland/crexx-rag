"""Acceptance for the per-test execution boundary, not product behavior."""
import os
import signal
import time
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest

RUNNER = pathlib.Path(__file__).with_name('run_case.py')

class ExecutionTests(unittest.TestCase):
    def test_same_case_parallel_roots_ports_and_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            script = root/'listen.py'
            script.write_text("import socket,pathlib,time\ns=socket.socket(); s.bind(('127.0.0.1',0)); s.listen(); pathlib.Path('port').write_text(str(s.getsockname()[1])); time.sleep(.3)\n")
            commands = [[sys.executable, str(RUNNER), '--root', str(root/str(n)), '--name', 'same', '--input', str(script), '--', sys.executable, str(script)] for n in range(2)]
            children = [subprocess.Popen(c, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) for c in commands]
            for child in children:
                out = child.communicate(timeout=10)[0]
                self.assertEqual(child.returncode, 0, out)
            ports = [p.read_text() for p in root.glob('*/runs/same/*/port')]
            self.assertEqual(len(set(ports)), 2)
            script.write_text('raise SystemExit(1)\n')
            for _ in range(2):
                result = subprocess.run(commands[0], capture_output=True, timeout=10)
                self.assertEqual(result.returncode, 1, result.stdout+result.stderr)
            self.assertEqual(len(list((root/'0').glob('runs/same/*'))), 3)

    def test_configuration_cohort_and_invalidation(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            config = root/'fixtures'/'test.conf'
            profile = config.parent/'profiles'/'generic.tsv'
            profile.parent.mkdir(parents=True)
            config.write_text('profiles/generic.tsv')
            profile.write_text('original')
            script = root/'check.py'
            script.write_text("import pathlib,sys\np=pathlib.Path(sys.argv[1]); q=p.parent/p.read_text(); assert q.exists(); q.write_text('private')\n")
            command = [sys.executable, str(RUNNER), '--root', str(root/'qa'), '--name', 'config', '--input', str(config), '--input', str(script), '--', sys.executable, str(script), str(config)]
            for expected in [0, 125, 0]:
                if expected == 0 and list((root/'qa').glob('results/config/*')):
                    profile.write_text('changed')
                result = subprocess.run(command, capture_output=True, timeout=10)
                self.assertEqual(result.returncode, expected, result.stdout+result.stderr)
                self.assertNotEqual(profile.read_text(), 'private')

    def test_independent_runs_and_reuse(self):
        with tempfile.TemporaryDirectory() as root:
            root = pathlib.Path(root)
            fixture = root / 'fixture.txt'
            fixture.write_text('original')
            script = root / 'case.py'
            script.write_text("import pathlib,sys\np=pathlib.Path(sys.argv[1]); assert p.read_text()=='original'; p.write_text('private')\npathlib.Path('output').write_text(str(pathlib.Path.cwd()))\n")
            base = [sys.executable, str(RUNNER), '--root', str(root/'qa'), '--input', str(script), '--input', str(fixture)]
            commands = [base + ['--name', name, '--', sys.executable, str(script), str(fixture)] for name in ['a','b']]
            children = [subprocess.Popen(c, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) for c in commands]
            for child in children:
                out = child.communicate(timeout=10)[0]
                self.assertEqual(child.returncode, 0, out)
            self.assertEqual(fixture.read_text(), 'original')
            self.assertEqual(len(list((root/'qa').glob('runs/*/*/output'))), 2)
            again = subprocess.run(commands[0], capture_output=True, timeout=10)
            self.assertEqual(again.returncode, 125, again.stdout+again.stderr)
            script.write_text(script.read_text()+'\n# changed fixture\n')
            changed = subprocess.run(commands[0], capture_output=True, timeout=10)
            self.assertEqual(changed.returncode, 0, changed.stdout+changed.stderr)

    def test_cancel_owns_children_and_does_not_reuse_failure(self):
        with tempfile.TemporaryDirectory() as root:
            root = pathlib.Path(root)
            script = root/'wait.py'
            script.write_text("import os,subprocess,time,pathlib\np=subprocess.Popen(['sleep','60'])\npathlib.Path('child.pid').write_text(str(p.pid))\ntime.sleep(60)\n")
            command = [sys.executable,str(RUNNER),'--root',str(root/'qa'),'--name','cancel','--input',str(script),'--',sys.executable,str(script)]
            child=subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            pid_file=None
            for _ in range(100):
                files=list((root/'qa').glob('runs/cancel/*/child.pid'))
                if files:
                    pid_file=files[0]; break
                time.sleep(.02)
            self.assertIsNotNone(pid_file)
            descendant=int(pid_file.read_text())
            child.terminate(); out=child.communicate(timeout=5)[0]
            self.assertNotEqual(child.returncode,0,out)
            for _ in range(100):
                state=subprocess.run(['ps','-o','stat=','-p',str(descendant)],capture_output=True,text=True).stdout.strip()
                if not state or state.startswith('Z'): break
                time.sleep(.02)
            self.assertTrue(not state or state.startswith('Z'),state)
            result=json.loads(next((root/'qa').glob('results/cancel/*.json')).read_text())
            self.assertEqual(result['outcome'],'interrupted')

if __name__ == '__main__':
    unittest.main()
