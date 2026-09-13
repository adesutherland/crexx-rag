"""One-off source/EQP inventory for the 13 September SQL review. No execution of SQL."""
from pathlib import Path
import collections, hashlib, json, re, sqlite3

ROOT = Path('/Users/adrian/CLionProjects/crexx-rag')
OUT = Path('/private/tmp/crexxrag-sql-review-20260913')
DB = '/private/tmp/crexxrag-smk006-V6YatF/smoke-library/library.sqlite'
# Keep offsets/newlines while removing comments. Quoted comments remain strings.
LEX = re.compile(r'/\*[\s\S]*?\*/|--[^\n]*|"(?:""|[^"\n])*"|\x27(?:\x27\x27|[^\x27\n])*\x27')
START = re.compile(r'^\s*(SELECT|WITH|INSERT|UPDATE|DELETE|REPLACE|CREATE|DROP|ALTER|PRAGMA|BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE)\b', re.I)
TOKEN = re.compile(r'"(?:""|[^"\n])*"|\x27(?:\x27\x27|[^\x27\n])*\x27|\|\||[A-Za-z_][\w.]*|\d+|[^\s]')

def unquote(s):
    return s[1:-1].replace(s[0]*2,s[0])

def chain(s, start):
    """Read one concatenation expression; only value interpolation is parameterized.
    Identifier, subquery and predicate builders remain explicit unresolved placeholders.
    """
    ts=list(TOKEN.finditer(s,start)); parts=[]; i=0
    while i<len(ts):
        t=ts[i].group(); begin=ts[i].start()
        if t.startswith(('"',"'")):
            parts.append(('literal',unquote(t))); end=ts[i].end(); i+=1
        else:
            depth=0; j=i
            while j<len(ts):
                v=ts[j].group()
                if depth==0 and v in ('||',',',')',';'): break
                if depth==0 and j>i and '\n' in s[ts[j-1].end():ts[j].start()]: break
                if v=='(': depth+=1
                if v==')': depth-=1
                j+=1
            if j==i: break
            end=ts[j-1].end(); parts.append(('expression',s[begin:end])); i=j
        if i>=len(ts) or ts[i].group()!='||': break
        i+=1
    return parts,end

def explain(db, sql):
    # EXPLAIN only compiles; no writes, DDL or transaction commands are run.
    try:
        try: cur=db.execute('EXPLAIN QUERY PLAN '+sql)
        except sqlite3.ProgrammingError as e:
            m=re.search(r'uses (\d+)',str(e))
            if not m: raise
            cur=db.execute('EXPLAIN QUERY PLAN '+sql,[None]*int(m[1]))
        return [r[3] for r in cur.fetchall()], ''
    except sqlite3.Error as e: return [], str(e)

db=sqlite3.connect('file:'+DB+'?mode=ro',uri=True)
rows=[]; calls=[]; modules=[]
for p in sorted((ROOT/'crexx').rglob('*.crexx')):
    if 'tests' in p.parts: continue
    original=p.read_text(); s=LEX.sub(lambda m: re.sub(r'[^\n]',' ',m.group()) if m.group().startswith(('/*','--')) else m.group(),original)
    procs=list(re.finditer(r'^\s*([\w.*]+):\s*(?:procedure|method|factory)\b',s,re.M|re.I))
    def context(pos):
        before=[x for x in procs if x.start()<=pos]
        proc=before[-1] if before else None
        end=next((x.start() for x in procs if x.start()>pos),len(s))
        body=s[proc.start() if proc else 0:end]
        loops=[original.count('\n',0,(proc.start() if proc else 0)+m.start())+1 for m in re.finditer(r'\bdo\s+(?:forever|while\b|until\b|[\w.]+\s*=)',body,re.I)]
        transactions=sorted(set(re.findall(r'"(BEGIN(?: IMMEDIATE| EXCLUSIVE)?|COMMIT|ROLLBACK|SAVEPOINT[^"\n]*|RELEASE[^"\n]*)"',body,re.I)))
        return proc.group(1) if proc else '(module)',loops,transactions
    n0=len(rows)
    for m in LEX.finditer(s):
        if not m.group().startswith(('"',"'")): continue
        lit=unquote(m.group()); root=START.match(lit)
        if not root or root.group(1)!=root.group(1).upper(): continue
        line=s.count('\n',0,m.start())+1
        parts,end=chain(s,m.start())
        sql=''; dynamic=[]
        for kind,v in parts:
            if kind=='literal': sql+=v
            elif re.match(r'^(?:_q|sqlquote|_sqlquote)\(',v) or re.match(r'^(?:_n|_number|sqlreadint|max|min|length)\(',v) or re.fullmatch(r'\d+|key|generation|current|expected_generation|staged|limit|maximum|maximum_items|maximum_rows|offset|deadline|now_epoch|minutes|version|fence|retry_at|priority|after|begin|finish|dimension|sequence|count|ordinal|remaining|input_bound',v):
                sql+='?';dynamic.append(v)
            else:
                sql+='⟦'+v+'⟧';dynamic.append(v)
        proc,loops,tx=context(m.start())
        if proc=='_closevisible':
            sql=sql.replace('WHERE ?=?', 'WHERE ⟦key⟧=?')
        category='transaction' if root.group(1).upper() in ('BEGIN','COMMIT','ROLLBACK','SAVEPOINT','RELEASE') else 'ddl' if root.group(1).upper() in ('CREATE','DROP','ALTER','PRAGMA') else 'query'
        plan,error=([], 'dynamic SQL shape') if '⟦' in sql else explain(db,sql) if category=='query' else ([], '')
        rows.append(dict(id=f'SQL-{len(rows)+1:04}',file=str(p.relative_to(ROOT)),line=line,procedure=proc,kind=root.group(1).upper(),category=category,source=original[m.start():end],template=sql,interpolations=dynamic,procedure_loop_lines=loops,procedure_transaction_statements=tx,eqp=plan,eqp_error=error))
    for m in re.finditer(r'\b(sqliteprepare|sqliteexec|sqlreadint|sqlreadtext)\b',s,re.I):
        # API/helper declarations and expose/import lists are not call sites.
        tail=s[m.end():]
        if tail.lstrip().startswith(':'): continue
        prefix=s[s.rfind('\n',0,m.start())+1:m.start()]
        if re.match(r'\s*(namespace|import)\b',prefix): continue
        proc,loops,tx=context(m.start())
        calls.append(dict(file=str(p.relative_to(ROOT)),line=s.count('\n',0,m.start())+1,api=m.group(),procedure=proc,procedure_loop_lines=loops,procedure_transaction_statements=tx))
    modules.append(dict(file=str(p.relative_to(ROOT)),sql_roots=len(rows)-n0))
schema=[dict(zip(['type','name','table','sql'],r)) for r in db.execute('SELECT type,name,tbl_name,sql FROM sqlite_schema ORDER BY type,name')]
indexes={r[0]:[dict(zip(['seq','name','unique','origin','partial'],i)) for i in db.execute('PRAGMA index_list("'+r[0]+'")')] for r in db.execute("SELECT name FROM sqlite_schema WHERE type='table'")}
groups=collections.defaultdict(list)
for r in rows:
    normalized=re.sub(r'\s+',' ',r['template']).strip()
    if len(normalized)>30: groups[normalized].append(r['id'])
dupes=[dict(template=k,sites=v) for k,v in groups.items() if len(v)>1]
result=dict(source_sha='bfbbdfd95d95a080262d47711c759bc2a9df18a0',python_sqlite=sqlite3.sqlite_version,database=DB,modules=modules,statements=rows,execution_sites=calls,duplicate_templates=dupes,schema=schema,indexes=indexes)
(OUT/'inventory.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(roots=len(rows),sites=len(calls),modules_with_sql=sum(x['sql_roots']>0 for x in modules),kinds=collections.Counter(r['category'] for r in rows),query_plans=sum(bool(r['eqp']) for r in rows),errors=collections.Counter(r['eqp_error'] for r in rows if r['eqp_error']),duplicate_templates=len(dupes)),indent=2))
# All exact literal/template constructions, grouped by owning procedure for human inspection.
with (OUT/'review-input.txt').open('w') as f:
    last=None
    for r in rows:
        key=r['file']+'::'+r['procedure']
        if key!=last:
            f.write('\n'+key+' loops='+str(r['procedure_loop_lines'])+' transactions='+str(r['procedure_transaction_statements'])+'\n');last=key
        f.write(r['id']+' L'+str(r['line'])+' '+r['template']+'\n')
        if r['eqp']: f.write('  EQP '+' | '.join(r['eqp'])+'\n')
        elif r['eqp_error']!='dynamic SQL shape': f.write('  '+r['eqp_error']+'\n')
