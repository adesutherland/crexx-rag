"""Provider-free Test 5 boundary/breadth probe against an identified scratch copy."""
import json
import os
from pathlib import Path
import sqlite3
import subprocess
import sys
import time

root = Path(__file__).parent
identity = json.loads((root / 'identity.json').read_text())
out = root / 'wide-mcp'; out.mkdir(exist_ok=False)
db = sqlite3.connect('file:' + identity['library'] + '/library.sqlite?mode=ro', uri=True)
before = db.execute('PRAGMA data_version').fetchone()[0]
env = os.environ.copy()
for name in ['GEMINI_API_KEY', 'GOOGLE_API_KEY', 'OPENAI_API_KEY']:
    env.pop(name, None)
env['CREXXRAG_CODEX'] = '/usr/bin/false'
err = (out / 'server.err').open('w')
proc = subprocess.Popen([identity['executable'], '--library', identity['library'],
    '--config-file', identity['config'], '--access', 'read', 'serve', 'mcp'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=err, text=True)
metrics = []
queries = [('default', {'question': 'Scotland', 'hops': 0}),
    ('thirteen', {'question': 'Scotland', 'hops': 0, 'limit': 13}),
    ('two-hundred', {'question': 'Scotland', 'hops': 0, 'limit': 200}),
    ('nairn-two-hundred', {'question': '"Fitz-James’s horse"', 'hops': 0, 'limit': 200}),
    ('rejected-201', {'question': 'Scotland', 'limit': 201})]
requests = [('initialize', 'initialize', {'protocolVersion':'2025-06-18','capabilities':{},
             'clientInfo':{'name':'test5-wide-net','version':'1'}})]
requests += [(label, 'tools/call', {'name':'rag_query_inspect','arguments':args}) for label,args in queries]
try:
    for n,(label,method,params) in enumerate(requests, 1):
        request = {'jsonrpc':'2.0','id':n,'method':method,'params':params}
        (out/(label+'-request.json')).write_text(json.dumps(request)+'\n')
        start = time.perf_counter(); proc.stdin.write(json.dumps(request)+'\n'); proc.stdin.flush()
        raw = proc.stdout.readline(); elapsed = time.perf_counter()-start
        (out/(label+'.json')).write_text(raw)
        response = json.loads(raw); assert response['id'] == n
        row = {'label':label,'observed_elapsed_seconds':elapsed,'wire_bytes':len(raw.encode())}
        data = response.get('result',{}).get('structuredContent',{})
        row['error'] = response.get('error'); row['exit_code'] = data.get('exit_code')
        if data.get('records'):
            f = data['records'][0]['fields']; e = json.loads(f['evidence_json'])
            row.update(limit=f['effective_passage_limit'],passages=len(e['passages']),
                lexical_candidates=f['lexical_candidates'],evidence_bytes=len(f['evidence_json'].encode()),
                provider_calls=f['provider_calls'])
            assert f['provider_calls']==0 and f['generated_answer'] is None
        metrics.append(row)
        if label=='initialize':
            proc.stdin.write('{"jsonrpc":"2.0","method":"notifications/initialized"}\n');proc.stdin.flush()
finally:
    proc.stdin.close();proc.wait(timeout=10);err.close()
after = db.execute('PRAGMA data_version').fetchone()[0]; db.close()
(out/'metrics.json').write_text(json.dumps(metrics,indent=2)+'\n')
result={'server_exit':proc.returncode,'unchanged_database':before==after,'requests':len(requests)}
(out/'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'result':result,'metrics':metrics},indent=2))
assert proc.returncode==0 and before==after
assert metrics[1]['limit']==12 and metrics[1]['passages']==12
assert metrics[2]['limit']==13 and metrics[2]['passages']==13
assert metrics[3]['limit']==200 and metrics[3]['passages']>12
assert metrics[4]['limit']==200 and metrics[4]['passages']>0
assert metrics[5]['error']['code']==-32602
