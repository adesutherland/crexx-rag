import subprocess,json,time,pathlib,select,sys
root=pathlib.Path(__file__).parent
lanes={
 "repaired_copy":("/Users/adrian/.local/bin/crexxrag","/private/tmp/crexxrag-test3-repeat-tadMRjFu/library","/private/tmp/crexxrag-smk006-V6YatF/test2.conf"),
 "configured_qa":("/Users/adrian/Documents/ScottishHistory/tools/bin/crexxrag","/Users/adrian/Documents/ScottishHistory/library","/Users/adrian/Documents/ScottishHistory/crexxrag.conf"),
 "current_same_qa":("/Users/adrian/.local/bin/crexxrag","/Users/adrian/Documents/ScottishHistory/library","/Users/adrian/Documents/ScottishHistory/crexxrag.conf")}
name=sys.argv[1];exe,library,conf=lanes[name];out=root/name;out.mkdir(exist_ok=True)
proc=subprocess.Popen([exe,"--library",library,"--config-file",conf,"--access","read","serve","mcp"],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=open(out/"server.err","w"),text=True,bufsize=1)
metrics=[];sequence=0

def rpc(label,method,params):
 global sequence
 sequence+=1;request={"jsonrpc":"2.0","id":sequence,"method":method,"params":params};start=time.perf_counter();proc.stdin.write(json.dumps(request)+"\n");proc.stdin.flush()
 if not select.select([proc.stdout],[],[],120)[0]:raise TimeoutError(label)
 raw=proc.stdout.readline();elapsed=time.perf_counter()-start;response=json.loads(raw);(out/(label+".json")).write_text(raw)
 row={"label":label,"seconds":elapsed,"wire_bytes":len(raw.encode())};result=response.get("result",{});data=result.get("structuredContent")
 if not data:
  texts=[x.get("text","") for x in result.get("content",[]) if x.get("type")=="text"]
  if texts:
   try:data=json.loads(texts[0])
   except ValueError:pass
 if data:
  row["exit_code"]=data.get("exit_code");row["message"]=data.get("message")
  for r in data.get("records",[]):
   fields=r.get("fields",{})
   if "evidence_json" in fields:
    ev=json.loads(fields["evidence_json"]);row["generation"]=ev.get("active_generation");row["evidence_bytes"]=len(fields["evidence_json"].encode());row["counts"]={k:len(ev.get(k,[])) for k in ["passages","claims","leads","analysis_notes"]};row["trace"]=ev.get("trace",{}).get("notes",[])
   if "published_generation" in fields:row["generation"]=fields["published_generation"]
 if "error" in response:row["error"]=response["error"]
 metrics.append(row);(out/"metrics.json").write_text(json.dumps(metrics,indent=2)+"\n");print(json.dumps({"lane":name,**row}),flush=True);return data
try:
 rpc("initialize","initialize",{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"crexxrag-performance-probe","version":"1"}})
 proc.stdin.write(json.dumps({"jsonrpc":"2.0","method":"notifications/initialized"})+"\n");proc.stdin.flush()
 rpc("tools","tools/list",{})
 status=rpc("status","tools/call",{"name":"rag_library_status","arguments":{}})
 if status and status.get("exit_code")!=0:raise RuntimeError(status.get("message"))
 rpc("overview","tools/call",{"name":"rag_library_overview","arguments":{}})
 for qid,question in [("bannockburn","Who defeated Edward II at Bannockburn?"),("mackay","How were Mackay and Dundee connected?")]:
  for hops in [0,1,3,4]:
   rpc(qid+"-h"+str(hops),"tools/call",{"name":"rag_query_inspect","arguments":{"question":question,"mode":"lexical","hops":hops,"limit":3}})
  data=rpc(qid+"-h3-repeat","tools/call",{"name":"rag_query_inspect","arguments":{"question":question,"mode":"lexical","hops":3,"limit":3}})
  if data and data.get("exit_code")==0:
   ev=json.loads(data["records"][0]["fields"]["evidence_json"])
   if ev.get("passages"):rpc(qid+"-citation","tools/call",{"name":"rag_citation_show","arguments":{"citation":ev["passages"][0]["citation"]["id"]}})
finally:
 proc.stdin.close()
 try:proc.wait(timeout=5)
 except subprocess.TimeoutExpired:proc.terminate();proc.wait(timeout=5)
