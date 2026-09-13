"""Isolated review diagnostics, never a product workflow or user-library mutation."""
import hashlib, json, pathlib, re, sqlite3, subprocess, sys, time
root = pathlib.Path(__file__).resolve().parents[3]
source, target, result_path = map(pathlib.Path, sys.argv[1:])
assert source.resolve() != target.resolve()
target.parent.mkdir(parents=True, exist_ok=True)
assert not target.exists(), 'Choose a fresh diagnostic database'
reader = sqlite3.connect(source.as_uri()+'?mode=ro', uri=True)
db = sqlite3.connect(target)
reader.backup(db); reader.close()
def digest(rows):
    return hashlib.sha256(json.dumps(rows, ensure_ascii=False, separators=(',', ':'), default=lambda x:x.hex()).encode()).hexdigest()
def run(sql, params):
    start=time.perf_counter(); rows=[db.execute(sql,p).fetchall() for p in params]
    return dict(seconds=time.perf_counter()-start, rows=sum(map(len,rows)), digest=digest(rows), eqp=db.execute('EXPLAIN QUERY PLAN '+sql, params[0]).fetchall())
cases=json.loads((root/'docs/qa/sql-performance-review-20260913/query-experiments.json').read_text())['cases']
results={'sqlite_version':sqlite3.sqlite_version,'source':str(source),'target':str(target),'cases':[]}
for case in cases:
    # Two independent parameter sets are sufficient for retained before/after evidence.
    case=dict(case);case['parameters']=case['parameters'][:2]
    case['before']=run(case['sql'],case['parameters']);results['cases'].append(case)
text=(root/'crexx/application/ragschema.crexx').read_text();start=text.index('  if version = 18 then do');end=text.index('    return statements.0',start)
statements=re.findall(r'statements\[statements.0 \+ 1\] = "([^\n]+)"',text[start:end])
start=time.perf_counter()
for sql in statements: db.execute(sql)
db.commit();results['index_build_seconds']=time.perf_counter()-start;results['indexes']=statements
for case in results['cases']:
    sql=case['sql'].replace("json_extract(e.message,'$.task_id')","CASE WHEN json_valid(e.message) THEN json_extract(e.message,'$.task_id') END")
    sql=sql.replace("FROM concepts c LEFT JOIN aliases a ON a.target_concept_id=c.concept_id AND a.visible_to_generation IS NULL WHERE c.visible_to_generation IS NULL AND c.lifecycle_state<>'retired' AND (lower(c.canonical_label)=lower(i.proposed_label) OR a.normalized_alias=lower(i.proposed_label) OR a.normalized_alias IN(SELECT lower(value) FROM json_each(i.aliases_json)))", "FROM concepts c WHERE c.concept_id IN(SELECT concept_id FROM concepts WHERE lower(canonical_label)=lower(i.proposed_label) AND visible_to_generation IS NULL UNION SELECT target_concept_id FROM aliases WHERE visible_to_generation IS NULL AND normalized_alias IN(SELECT lower(i.proposed_label) UNION SELECT lower(value) FROM json_each(i.aliases_json))) AND c.visible_to_generation IS NULL AND c.lifecycle_state<>'retired'")
    case['after_sql']=sql;case['after']=run(sql,case['parameters']);case['equal']=case['before']['digest']==case['after']['digest']
# Actual new anchor SQL, compared with the original ordered catalogue algorithm.
text=(root/'crexx/application/ragretrieval.crexx').read_text();part=text[text.index('_anchors: procedure'):]
anchor_sql=re.search(r'  sql = "([^\n]+)"',part).group(1)
generation=db.execute('SELECT published_generation FROM library_meta').fetchone()[0]
concepts=db.execute('SELECT concept_id,lower(canonical_label) FROM concepts WHERE visible_from_generation<=? AND (visible_to_generation IS NULL OR visible_to_generation>?) ORDER BY concept_id',(generation,generation)).fetchall()
aliases=db.execute('SELECT DISTINCT target_concept_id,lower(normalized_alias) FROM aliases WHERE target_concept_id IS NOT NULL AND visible_from_generation<=? AND (visible_to_generation IS NULL OR visible_to_generation>?) ORDER BY target_concept_id,normalized_alias',(generation,generation)).fetchall()
questions=['the duke of argyll','william of orange','general stewart','king  william','  king william  ','no-matching-concept-fixture','église saint andrew','john macdonald']
results['anchors']=[]
for q in questions:
    expected=list(dict.fromkeys(i for i,label in concepts+aliases if label and ' '+label+' ' in ' '+q+' '))
    start=time.perf_counter(); actual=[r[0] for r in db.execute(anchor_sql,(generation,q+' '))]
    results['anchors'].append(dict(question=q,equal=expected==actual,rows=len(actual),seconds=time.perf_counter()-start,digest=digest(actual)))
results['anchor_eqp']=db.execute('EXPLAIN QUERY PLAN '+anchor_sql,(generation,questions[0]+' ')).fetchall()
# Late generation and composite cursors keep the same ordered identities.
results['pages']=[]
for name,table,columns,order,old,new,params in [
 ('generation','published_generations','generation','generation',"printf('%020d',generation)>?",'generation>CAST(? AS INTEGER)',(f'{generation-10:020d}',)),
 ('lineage','claim_support','lineage_group,support_id','lineage_group,support_id',"(lineage_group||char(31)||support_id)>?","(lineage_group,support_id)>(substr(?1,1,instr(?1,char(31))-1),substr(?1,instr(?1,char(31))+1))",(db.execute('SELECT lineage_group||char(31)||support_id FROM claim_support ORDER BY lineage_group,support_id LIMIT 1 OFFSET 5000').fetchone()[0],)),
 ('embeddings','revision_chunk_embeddings','revision_chunk_id,embedding_id','revision_chunk_id,embedding_id',"(revision_chunk_id||char(31)||embedding_id)>?","(revision_chunk_id,embedding_id)>(substr(?1,1,instr(?1,char(31))-1),substr(?1,instr(?1,char(31))+1))",(db.execute('SELECT revision_chunk_id||char(31)||embedding_id FROM revision_chunk_embeddings ORDER BY revision_chunk_id,embedding_id LIMIT 1 OFFSET 10000').fetchone()[0],))]:
    prefix=f'SELECT {columns} FROM {table} WHERE ';suffix=f' ORDER BY {order} LIMIT 100'
    before=run(prefix+old+suffix,[params]);after=run(prefix+new+suffix,[params]);results['pages'].append(dict(name=name,before=before,after=after,equal=before['digest']==after['digest']))
results['index_bytes']=db.execute("SELECT sum(pgsize) FROM dbstat WHERE name IN("+','.join('?' for _ in statements)+')',[s.split()[2] for s in statements]).fetchone()[0]
result_path.write_text(json.dumps(results,indent=2)+'\n')
assert all(c['equal'] for c in results['cases']+results['anchors']+results['pages'])
print(json.dumps({'cases':len(results['cases']),'anchor_questions':len(results['anchors']),'pages':len(results['pages']),'all_equal':True,'indexes':len(statements),'index_build_seconds':results['index_build_seconds'],'index_bytes':results['index_bytes']}))
