"""Read-only before/after SQL experiment on the disposable review copy."""
from pathlib import Path
import sqlite3,json,time,hashlib,statistics
P=Path('/private/tmp/crexxrag-sql-review-20260913')
inventory=json.loads((P/'inventory.json').read_text())
db=sqlite3.connect(str(P/'library.sqlite'))
def sql(module,line):
    r=next(r for r in inventory['statements'] if r['file'].endswith('/'+module+'.crexx') and r['line']==line)
    if '⟦' in r['template']: raise ValueError(r['template'])
    return r['template']
def ids(table,col,where='1',n=20):
    return [r[0] for r in db.execute(f'SELECT {col} FROM {table} WHERE {where} ORDER BY {col} LIMIT {n}')]
generation=db.execute('SELECT published_generation FROM library_meta').fetchone()[0]
concepts=ids('concepts','concept_id',"visible_to_generation IS NULL AND lifecycle_state='active'")
chunks=ids('revision_chunks','revision_chunk_id','visible_to_generation IS NULL')
tasks=db.execute("SELECT kind,subject_type,subject_id,evidence_fingerprint FROM maintenance_tasks WHERE required_capability='advanced-reasoning' AND state IN('unresolved','review') AND kind IN('concept-review','identity-review') ORDER BY kind,task_id LIMIT 2").fetchall()
alias_ids=ids('maintenance_alias_issues','issue_id',"state='open'",10)
items=ids('maintenance_task_items','item_id')
terms=ids('candidate_mentions','normalized_candidate','1',20)
cases=[
 ('task_review_hold',sql('ragbacklog',418),tasks),
 ('concept_subject',sql('ragbacklog',479),[(v,) for v in concepts]),
 ('competing_concepts',sql('ragbacklog',493),[(v,) for v in concepts]),
 ('alias_issue_subject',sql('ragbacklog',488),[(v,) for v in alias_ids]),
 ('identity_census_100','SELECT concept_id FROM ('+sql('ragbacklog',619)+") WHERE concept_id>'' ORDER BY concept_id LIMIT 100",[()]),
 ('concept_passage_selection',sql('ragbacklog',507),[(v,v,v,v) for v in concepts]),
 ('glossary_candidates',sql('ragingest',616).replace('DELETE FROM candidate_mentions','SELECT candidate_id FROM candidate_mentions')+' ORDER BY candidate_id',[(generation,v) for v in terms]),
 ('retrieval_alias',sql('ragquery',234),[(v,generation) for v in ['stewart','scotland','william','absent-review-control']]),
 ('retrieval_notes',sql('ragretrieval',689),[(v,generation,8) for v in chunks]),
 ('cached_resolution',sql('ragwork',671),[(v,) for v in items]),
 ('admission_expiry_candidates',"SELECT admission_id FROM provider_admissions WHERE outcome='active' AND lease_until_epoch<=unixepoch()",[()]),
]
# Indexes are independent proposals, not a migration or changes to application data.
indexes=[
 "CREATE INDEX review_extraction_event_task ON job_events(json_extract(message,'$.task_id')) WHERE event_type='extraction-review-required'",
 "CREATE INDEX review_alias_target ON aliases(target_concept_id,visible_to_generation,normalized_alias)",
 "CREATE INDEX review_mentions_concept ON mentions(concept_id,visible_to_generation,revision_chunk_id)",
 "CREATE INDEX review_active_concept_label ON concepts(lower(canonical_label),concept_id) WHERE visible_to_generation IS NULL AND lifecycle_state='active'",
 "CREATE INDEX review_open_issue_label ON maintenance_alias_issues(lower(proposed_label),proposed_type) WHERE state='open'",
 "CREATE INDEX review_candidate_generation ON candidate_mentions(visible_from_generation,normalized_candidate)",
 "CREATE INDEX review_alias_lower ON aliases(lower(normalized_alias),visible_from_generation,visible_to_generation,alias_id)",
 "CREATE INDEX review_note_chunk ON analysis_note_links(revision_chunk_id,note_id)",
 "CREATE INDEX review_output_task ON maintenance_provider_outputs(task_id,created_epoch DESC,item_id)",
 "CREATE INDEX review_admission_expiry ON provider_admissions(lease_until_epoch,admission_id) WHERE outcome='active'",
]
def run(label):
    result=[]
    for name,query,parameters in cases:
        t=time.perf_counter();out=[];dur=[]
        for args in parameters:
            started=time.perf_counter()
            out.append(db.execute(query,args).fetchall());dur.append(time.perf_counter()-started)
        digest=hashlib.sha256(json.dumps(out,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
        r=dict(name=name,calls=len(parameters),seconds=time.perf_counter()-t,max_seconds=max(dur),rows=sum(len(v) for v in out),digest=digest,eqp=[list(v) for v in db.execute('EXPLAIN QUERY PLAN '+query,parameters[0])])
        result.append(r);print(label,name,round(r['seconds'],6),r['rows'],flush=True)
    return result
db.close()
db=sqlite3.connect('file:'+inventory['database']+'?mode=ro',uri=True)
before=run('before')
db.close()
db=sqlite3.connect(str(P/'library.sqlite'))
index_results=[]
for query in indexes:
    started=time.perf_counter();db.execute(query.replace("CREATE INDEX ","CREATE INDEX IF NOT EXISTS "));db.commit()
    name=query.split()[2]
    size=db.execute('SELECT sum(pgsize) FROM dbstat WHERE name=?',(name,)).fetchone()[0]
    index_results.append(dict(sql=query,seconds=time.perf_counter()-started,bytes=size))
after=run('after')
for a,b in zip(before,after):
    assert a['digest']==b['digest'],a['name']
result=dict(sqlite_version=sqlite3.sqlite_version,generation=generation,before=before,after=after,indexes=index_results,cases=[dict(name=n,sql=q,parameters=p) for n,q,p in cases])
(P/'query-experiments.json').write_text(json.dumps(result,indent=2)+'\n')
print('All result arrays are identical',flush=True)
