import subprocess,json,time,pathlib,select,sys
root=pathlib.Path(__file__).parent
lanes={
 "repaired_copy":("/Users/adrian/.local/bin/crexxrag","/private/tmp/crexxrag-test3-repeat-tadMRjFu/library","/private/tmp/crexxrag-smk006-V6YatF/test2.conf"),
 "configured_qa":("/Users/adrian/Documents/ScottishHistory/tools/bin/crexxrag","/Users/adrian/Documents/ScottishHistory/library","/Users/adrian/Documents/ScottishHistory/crexxrag.conf"),
 "current_same_qa":("/Users/adrian/.local/bin/crexxrag","/Users/adrian/Documents/ScottishHistory/library","/Users/adrian/Documents/ScottishHistory/crexxrag.conf")}
name=sys.argv[1];exe,library,conf=lanes[name];out=root/"answer-and-path";out.mkdir(exist_ok=True)
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
 rpc("initialize","initialize",{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"crexxrag-answer-performance","version":"1"}})
 proc.stdin.write(json.dumps({"jsonrpc":"2.0","method":"notifications/initialized"})+"\n");proc.stdin.flush()
 rpc("status","tools/call",{"name":"rag_library_status","arguments":{}})
 for direction in ["outbound","inbound","both"]:
  for hops in [1,3]:
   rpc("path-"+direction+"-h"+str(hops),"tools/call",{"name":"rag_query_path","arguments":{"question":"Dundee","mode":"lexical","hops":hops,"direction":direction,"limit":3}})
 question="What happened at Bannockburn in 1314?"
 for label,limit,hops in [("compact",3,1),("default",12,3)]:
  rpc("evidence-"+label,"tools/call",{"name":"rag_query_inspect","arguments":{"question":question,"mode":"lexical","hops":hops,"limit":limit}})
  rpc("answer-"+label,"tools/call",{"name":"rag_query_answer","arguments":{"question":question,"mode":"lexical","hops":hops,"limit":limit}})
finally:
 proc.stdin.close()
 try:proc.wait(timeout=5)
 except subprocess.TimeoutExpired:proc.terminate();proc.wait(timeout=5)
