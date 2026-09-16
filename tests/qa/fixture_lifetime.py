"""The former 11-second native-surfaces wait, isolated from surface acceptance."""
import http.client
import subprocess
import sys
import time

child = subprocess.Popen([sys.argv[1], '0', '1', 'default'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
try:
    ready = child.stdout.readline().strip()
    assert ready.startswith('READY '), ready
    port = int(ready.split()[1])
    time.sleep(11)  # Explicit fixture idle-lifetime regression, exercised once.
    assert child.poll() is None, 'fixture exited during preparation'
    connection = http.client.HTTPConnection('127.0.0.1', port, timeout=3)
    connection.request('POST', '/loopback-embed', '{}', {'Connection': 'close'})
    response = connection.getresponse(); response.read(); connection.close()
    assert response.status == 200, response.status
    out, err = child.communicate(timeout=3)
    assert child.returncode == 0, out+err
finally:
    if child.poll() is None:
        child.kill(); child.wait()
