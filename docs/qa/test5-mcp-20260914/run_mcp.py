"""Test 5 diagnostic MCP client; no product logic or provider calls.

Usage: python3 run_mcp.py IDENTITY_JSON OUTPUT_DIRECTORY
IDENTITY_JSON names the executable, disposable library and configuration.
The selected copy must already be ready for queries. See ../../test5-mcp-qa.md.
"""
import hashlib
import json
import os
from pathlib import Path
import select
import sqlite3
import subprocess
import sys
import time

identity = json.loads(Path(sys.argv[1]).read_text())
out = Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=False)
db = sqlite3.connect('file:' + identity['library'] + '/library.sqlite?mode=ro', uri=True)
db.row_factory = sqlite3.Row
metrics, checks = [], []


def save(name, value):
    (out / (name + '.json')).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n')


def check(name, condition, detail=None):
    checks.append({'check': name, 'pass': bool(condition), 'detail': detail})
    save('checks', checks)
    if not condition:
        print('FAIL ' + name, flush=True)


def snapshot():
    counts = {t: db.execute('SELECT COUNT(*) FROM ' + t).fetchone()[0]
              for t in ['sources', 'source_revisions', 'revision_chunks', 'mentions',
                        'claims', 'provider_runs', 'attempts', 'query_gaps']}
    hashes = {}
    for t in ['sources', 'source_revisions', 'revision_chunks', 'mentions', 'claims']:
        h = hashlib.sha256()
        for row in db.execute('SELECT * FROM ' + t + ' ORDER BY 1'):
            h.update(json.dumps(list(row), ensure_ascii=False, separators=(',', ':')).encode())
            h.update(b'\n')
        hashes[t] = h.hexdigest()
    return {'meta': dict(db.execute('SELECT * FROM library_meta').fetchone()),
            'counts': counts, 'corpus_hashes': hashes,
            'data_version': db.execute('PRAGMA data_version').fetchone()[0]}


before = snapshot(); save('before', before)
env = os.environ.copy()
for key in ['GEMINI_API_KEY', 'GOOGLE_API_KEY', 'OPENAI_API_KEY']:
    env.pop(key, None)
env['CREXXRAG_CODEX'] = '/usr/bin/false'
server_err = (out / 'server.err').open('w')
command = [identity['executable'], '--library', identity['library'], '--config-file',
           identity['config'], '--access', 'read', 'serve', 'mcp']
proc = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                        stderr=server_err, text=True, bufsize=1, env=env)
sequence = 0


def cpu():
    text = subprocess.check_output(['ps', '-p', str(proc.pid), '-o', 'time='], text=True).strip()
    parts = text.split(':')
    return sum(float(p) * 60 ** i for i, p in enumerate(reversed(parts)))


def rpc(label, method, params, expected_error=False):
    global sequence
    sequence += 1
    req = {'jsonrpc': '2.0', 'id': sequence, 'method': method, 'params': params}
    save(label + '-request', req)
    c0 = cpu(); start = time.perf_counter()
    proc.stdin.write(json.dumps(req) + '\n'); proc.stdin.flush()
    if not select.select([proc.stdout], [], [], 120)[0]:
        raise TimeoutError(label + ': transport did not respond; not a speed verdict')
    raw = proc.stdout.readline(); elapsed = time.perf_counter() - start; c1 = cpu()
    (out / (label + '.json')).write_text(raw)
    response = json.loads(raw)
    check(label + ': matching JSON-RPC ID', response.get('id') == sequence)
    result = response.get('result', {})
    data = result.get('structuredContent', {})
    failed = 'error' in response or result.get('isError', False) or data.get('exit_code', 0) != 0
    check(label + ': expected outcome', failed == expected_error,
          response.get('error') or data.get('message'))
    row = {'label': label, 'method': method, 'tool': params.get('name'),
           'elapsed_seconds_observed': round(elapsed, 6),
           'server_cpu_seconds_approx': round(c1-c0, 2), 'wire_bytes': len(raw.encode()),
           'exit_code': data.get('exit_code'), 'expected_error': expected_error}
    if data.get('records'):
        fields = data['records'][0]['fields']
        if 'evidence_json' in fields:
            ev = json.loads(fields['evidence_json'])
            row['evidence_bytes'] = len(fields['evidence_json'].encode())
            row['counts'] = {k: len(ev[k]) for k in ['passages', 'claims', 'leads', 'analysis_notes']}
            row['retrieval'] = {k: v for k, v in fields.items() if k.startswith('effective_') or k in
                ['candidate_count', 'lexical_candidates', 'vector_candidates', 'graph_candidates',
                 'provider_calls', 'query_gaps_recorded', 'query_embedding_state', 'retrieval_mode']}
            row['trace'] = ev['trace']['notes']
            check(label + ': zero provider route', fields['provider_calls'] == 0 and
                  fields['query_embedding_state'] == 'not-requested' and fields['generated_answer'] is None)
            check(label + ': current evidence generation', ev['schema'] == 'crexx-rag.evidence/2' and
                  ev['active_generation'] == before['meta']['published_generation'])
            check(label + ': configured bounds', len(ev['passages']) <= fields['effective_passage_limit'] and
                  len(ev['claims']) <= fields['effective_claim_limit'] and
                  len(ev['leads']) <= fields['effective_lead_limit'] and row['evidence_bytes'] <= 262144 and
                  fields['lexical_candidates'] <= fields['effective_lexical_limit'] and fields['vector_candidates'] == 0)
            check(label + ': directional claims have support', all(c['direction'] == 'outbound' and
                  c['supports'] and all(s['citation']['id'] for s in c['supports']) for c in ev['claims']))
            if params.get('name') == 'rag_query_inspect':
                check(label + ': no gap writes', fields['query_gaps_recorded'] == 0)
    metrics.append(row); save('metrics', metrics)
    print(json.dumps({k:v for k,v in row.items() if k not in ['trace','retrieval']}), flush=True)
    return result if not data else data


def call(label, tool, args=None, **options):
    return rpc(label, 'tools/call', {'name': tool, 'arguments': args or {}}, **options)


def inspect(label, question, **args):
    data = call(label, 'rag_query_inspect', {'question': question, 'mode': 'lexical', **args})
    return json.loads(data['records'][0]['fields']['evidence_json'])


def citation(label, citation_id, paged=False):
    full = call(label, 'rag_citation_show', {'citation': citation_id})['records'][0]['fields']
    check(label + ': complete citation', not full.get('next_cursor') and full['citation'] == citation_id and
          len(full['text'].encode()) == full['span_end'] - full['span_start'])
    if paged:
        chunks, cursor, seen = [], '', set()
        while True:
            f = call(label + '-page-' + str(len(chunks)+1), 'rag_citation_show',
                     {'citation': citation_id, 'limit': 127, 'cursor': cursor})['records'][0]['fields']
            chunks.append(f['text']); cursor = f.get('next_cursor', '')
            if not cursor:
                break
            if cursor in seen:
                raise RuntimeError('Repeated citation cursor')
            seen.add(cursor)
        check(label + ': paged text exactly matches full span', ''.join(chunks) == full['text'],
              {'pages': len(chunks), 'characters': len(full['text']), 'utf8_bytes': len(full['text'].encode())})
    return full


try:
    initialized = rpc('initialize', 'initialize', {'protocolVersion': '2025-06-18', 'capabilities': {},
                      'clientInfo': {'name': 'crexxrag-test5', 'version': '1'}})
    proc.stdin.write(json.dumps({'jsonrpc':'2.0','method':'notifications/initialized'})+'\n'); proc.stdin.flush()
    tools = {t['name']: t for t in rpc('tools', 'tools/list', {})['tools']}
    check('MCP instructions route ordinary Q&A to current assistant',
          all(x in initialized['instructions'] for x in ['rag_query_inspect', 'compose the answer yourself', 'latency']))
    check('inspect schema and annotations', tools['rag_query_inspect']['inputSchema']['properties']['mode']['enum'] == ['lexical'] and
          tools['rag_query_inspect']['annotations']['readOnlyHint'])
    check('answerer is explicit and has generation cost', all(x in tools['rag_query_answer']['description']
          for x in ['explicitly requests', 'latency', 'provider usage']))
    call('denied-control', 'rag_vector_rebuild', expected_error=True)
    call('bad-limit', 'rag_query_inspect', {'question': 'Dundee', 'limit': 0}, expected_error=True)
    status = call('status', 'rag_library_status')['records'][0]['fields']
    check('status matches independent library identity', status['published_generation'] == before['meta']['published_generation'] and
          status['library_id'] == before['meta']['library_id'] and status['issue_count'] == 0)
    source_ids, cursor, seen = [], '', set()
    while True:
        data = call('sources-page-' + str(len(seen)+1), 'rag_source_list', {'limit': 3, 'cursor': cursor})
        source_ids += [r['fields']['identity'] for r in data['records'] if r['kind'] == 'sources']
        cursor = next((r['fields']['next_cursor'] for r in data['records'] if 'next_cursor' in r['fields']), '')
        if not cursor:
            break
        if cursor in seen:
            raise RuntimeError('Repeated source cursor')
        seen.add(cursor)
    check('all sources paged exactly once', len(source_ids) == len(set(source_ids)) == before['counts']['sources'])
    call('profile', 'rag_profile_show')
    call('overview', 'rag_library_overview')
    packets = {}
    for name, question in [('bannockburn', 'Who defeated Edward II at Bannockburn?'),
                           ('mackay', 'How were Mackay and Dundee connected?')]:
        for hops in [0, 1, 3, 4]:
            packets[name + '-h' + str(hops)] = inspect(name + '-h' + str(hops), question, hops=hops, limit=3)
        for repeat in [1, 2]:
            ev = inspect(name + '-repeat-' + str(repeat), question, hops=3, limit=3)
            check(name + ': repeated evidence stable ' + str(repeat), ev == packets[name+'-h3'])
    dense = inspect('scotland-dense', 'Scotland', hops=4, limit=12)
    empty = inspect('absent-term', 'zzqtestfiveunfindablewordzzq', hops=0, limit=12)
    check('absent-term returns no invented evidence', not empty['passages'] and not empty['claims'])
    follow = packets['mackay-h3']['leads'][0]['path'][:2]
    follow_question = 'What is the relationship between ' + follow[0] + ' and ' + follow[1] + '?'
    lead = inspect('follow-returned-lead', follow_question, hops=3, direction='both', limit=12)
    check('returned lead can be followed', bool(lead['passages']))
    battle_question = 'What happened at Bannockburn in 1314?'
    compact = inspect('battle-compact', battle_question, hops=3, limit=3)
    normal = inspect('battle-normal', battle_question, hops=3, limit=12)
    answer_hits = [(i+1,p) for i,p in enumerate(normal['passages'])
                   if p['title']=='bannockburn-1911-excerpt.txt' and 'defeated Edward' in p['text']]
    check('normal evidence retains direct battle answer', bool(answer_hits))
    if answer_hits:
        citation('battle-citation', answer_hits[0][1]['citation']['id'], paged=True)
    save('ranking-observation', {'answer_ranks': [i for i,p in answer_hits],
         'answer_present_in_compact': any('defeated Edward' in p['text'] for p in compact['passages']),
         'compact_passages': len(compact['passages']), 'normal_passages': len(normal['passages'])})
    nairn = inspect('nairn-quoted-unicode', '"Fitz-James’s horse"', hops=0, limit=12)
    nairn_hits = [p for p in nairn['passages'] if 'Argyleshire' in p['text'] and 'advanced' in p['text']]
    check('quoted Unicode retrieves repaired Nairn passage', bool(nairn_hits))
    if nairn_hits:
        citation('nairn-citation', nairn_hits[0]['citation']['id'], paged=True)
    if lead['claims']:
        citation('lead-claim-citation', lead['claims'][0]['supports'][0]['citation']['id'])
    if lead['passages']:
        citation('lead-passage-citation', lead['passages'][0]['citation']['id'])
    after_readonly = snapshot(); save('after-readonly', after_readonly)
    check('ordinary MCP Q&A makes no database writes', before == after_readonly)
    paths = {}
    for direction in ['outbound', 'inbound', 'both']:
        for hops in [1, 3]:
            label = 'path-' + direction + '-h' + str(hops)
            data = call(label, 'rag_query_path', {'question': 'Dundee', 'mode': 'lexical',
                         'direction': direction, 'hops': hops, 'limit': 3})
            f = data['records'][0]['fields']; e = json.loads(f['evidence_json']); p = json.loads(f['paths_json'])
            claims = {c['claim_id']: c for c in e['claims']}
            check(label + ': projection preserves stored endpoints', all(x['claim_id'] in claims and
                  x['nodes'] == [claims[x['claim_id']]['subject'], claims[x['claim_id']]['object']] and
                  x['relationship'] == claims[x['claim_id']]['relationship_type'] and x['citations']
                  for x in p['paths'] if x['kind'] == 'accepted-claim'))
            paths[label] = p
    save('paths-summary', {k: {'accepted': [p['nodes'] for p in v['paths'] if p['kind']=='accepted-claim'],
                              'leads': sum(p['kind']=='exploratory-lead' for p in v['paths'])} for k,v in paths.items()})
    call('final-status', 'rag_library_status')
    after = snapshot(); save('after', after)
    check('path calls preserve corpus and generation', before['meta'] == after['meta'] and before['corpus_hashes'] == after['corpus_hashes'])
    check('all MCP requests make zero new provider runs or attempts', all(before['counts'][k] == after['counts'][k]
          for k in ['provider_runs','attempts']))
finally:
    proc.stdin.close()
    try:
        proc.wait(timeout=10)
    except subprocess.TimeoutExpired:
        proc.terminate(); proc.wait(timeout=10)
    server_err.close(); db.close()
    check('MCP server exits cleanly', proc.returncode == 0)
    save('result', {'checks': len(checks), 'failures': [c for c in checks if not c['pass']],
                   'requests': sequence, 'server_pid': proc.pid, 'server_exit': proc.returncode,
                   'shared_machine': True, 'timing_thresholds': None})
sys.exit(1 if any(not c['pass'] for c in checks) else 0)
