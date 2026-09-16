#!/usr/bin/env python3
"""Preview CTest selection and audit exact-input evidence; never execute tests."""
import argparse
import collections
import json
import os
from pathlib import Path
import re
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--build', default='cmake-build-debug')
parser.add_argument('--tier', default='fast|component|integration')
parser.add_argument('--match', default='.*')
parser.add_argument('--json', type=Path)
parser.add_argument('--require-complete', action='store_true')
args = parser.parse_args()
inventory = json.loads(subprocess.check_output(['ctest', '--test-dir', args.build, '--show-only=json-v1'], text=True))
rows = []
for test in inventory['tests']:
    props = {p['name']: p['value'] for p in test['properties']}
    tier = next((s[5:] for s in props.get('LABELS', []) if s.startswith('tier-')), 'unclassified')
    if not re.fullmatch(args.tier, tier) or not re.search(args.match, test['name']):
        continue
    command = test.get('command', [])
    driver = next((Path(c).stem for c in reversed(command) if c.endswith('.cmake')), 'QA harness')
    row = {'case': test['name'], 'tier': tier, 'owner': driver, 'priority': props.get('COST', 0),
           'processors': props.get('PROCESSORS', 1), 'locks': props.get('RESOURCE_LOCK', []), 'state': 'not-run'}
    if props.get('DISABLED'):
        row['state'] = 'disabled'
    elif command:
        environment = os.environ.copy()
        for item in props.get('ENVIRONMENT', []):
            k, v = item.split('=', 1); environment[k] = v
        index = command.index('--')
        inspection = subprocess.run(command[:index]+['--inspect']+command[index:], env=environment, capture_output=True, text=True)
        if inspection.returncode:
            row.update(state='missing-input', detail=inspection.stderr[-1000:])
        else:
            inspected = json.loads(inspection.stdout)
            row['evidence_key'] = inspected['key']
            result = inspected['result']
            if result:
                row.update(state=result['outcome'], seconds=result['seconds'], directory=result['directory'],
                           reason=result.get('reason', 'prior execution'), identity=result['identity'])
                for field in ['setup_seconds', 'resource_wait_seconds', 'run_seconds', 'cleanup_seconds']:
                    row[field] = result.get(field)
    row['selection_reason'] = f'tier {tier}; name matches {args.match}'
    row['review_budget_seconds'] = 2 if tier == 'fast' else 10 if tier == 'component' else 30 if tier == 'integration' else None
    row['slow_review'] = row.get('seconds', 0) > row['review_budget_seconds'] if row['review_budget_seconds'] is not None else False
    rows.append(row)
rows.sort(key=lambda r: (-r['priority'], r['case']))
counts = dict(collections.Counter(r['state'] for r in rows))
for r in rows:
    estimate = f"{r['seconds']:.2f}s" if 'seconds' in r else 'unmeasured'
    print(f"{r['tier']:11} {r['state']:13} {estimate:12} slots={r['processors']} {r['case']} [{r['owner']}]")
print(json.dumps(counts, sort_keys=True))
if args.json:
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps({'counts': counts, 'cases': rows}, indent=2)+'\n')
# A disabled case is always an explicit incomplete gate, never a pass.
if args.require_complete and (not rows or any(r['state'] != 'passed' for r in rows)):
    sys.exit(1)
