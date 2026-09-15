#!/usr/bin/env python3
"""Exercise legacy task reset through public CLI/MCP on an isolated library."""
import json
from pathlib import Path
import sqlite3
import subprocess
import sys

binary, template, directory = sys.argv[1:]
work = Path(directory).resolve()
(work / "source").mkdir()
(work / "source/history.txt").write_text("Platform depends on Peer.\n")
(work / "glossary.tsv").write_text("format\tcrexx-rag.glossary/1\nconcept\tPlatform\tapplication-component\nconcept\tPeer\tdata-store\n")
config = Path(template).read_text().replace("@CPRAG_FIXTURE_SOURCE@", str(work / "source"))
config = config.replace("@CPRAG_FIXTURE_GLOSSARY@", str(work / "glossary.tsv")).replace("@CPRAG_FIXTURE_PORT@", "1")
(work / "crexxrag.conf").write_text(config + "\nmaintenance.mode = manual\n")
base = [binary, "--library", str(work / "library"), "--config-file", str(work / "crexxrag.conf"), "--format", "json"]


def cli(*args, success=True):
    result = subprocess.run(base + list(args), cwd=work, capture_output=True, text=True, timeout=20)
    with (work / "commands.log").open("a") as log:
        log.write(json.dumps(args) + "\n" + result.stdout + result.stderr + "\n")
    assert result.stdout.startswith("{"), (args, result.returncode, result.stdout, result.stderr)
    body = json.loads(result.stdout)
    if success:
        assert result.returncode == 0, (args, body, result.stderr)
    else:
        assert result.returncode != 0, (args, body)
    return body


def fields(body):
    return body["records"][0]["fields"]


def db():
    return sqlite3.connect(work / "library/library.sqlite")


def rows(sql, args=()):
    with db() as connection:
        return connection.execute(sql, args).fetchall()


def task_state(task):
    return rows("SELECT state FROM maintenance_tasks WHERE task_id=?", (task,))[0][0]


def facts():
    tables = ["sources", "source_revisions", "source_revision_texts", "revision_chunks", "chunk_contents", "concepts", "mentions", "claims", "claim_support", "provider_runs", "attempts"]
    return {table: rows("SELECT * FROM " + table + " ORDER BY 1") for table in tables}


def response(task):
    packet = json.loads(rows("SELECT evidence_json FROM maintenance_tasks WHERE task_id=?", (task,))[0][0])
    passage = packet["passages"][0]
    return json.dumps(dict(action="retain", object_id="", target_concept_id="", canonical_label="", concept_type="", successors=[], reason="Reviewed source; no graph change required.", evidence=[dict(evidence_id=passage["evidence_id"], quote=passage["text"])], effective_from="", effective_to="", qualifiers_json="{}", question=""))


def close_task(task):
    plan = fields(cli("--access", "plan", "maintain", "resolve-plan", task, "--response-json", response(task), "--actor", "reset-fixture"))
    applied = fields(cli("--access", "curate", "maintain", "resolve-apply", "--plan-json", plan["canonical_plan"], "--expect-digest", plan["digest"]))
    cli("--access", "curate", "review", "decide", applied["review_id"], "--decision", "accept", "--apply")
    assert task_state(task) == "resolved"


cli("--access", "admin", "library", "init")
plan = fields(cli("--access", "plan", "ingest", "plan", "--source-set", "architecture-docs"))
cli("--access", "ingest", "ingest", "apply", "--plan-json", plan["canonical_plan"], "--expect-digest", plan["digest"])
chunk = rows("SELECT revision_chunk_id FROM revision_chunks")[0][0]
with db() as connection:
    connection.executescript("""
      UPDATE job_items SET state='cancelled'; UPDATE jobs SET state='cancelled';
      INSERT INTO concepts(concept_id,canonical_label,concept_type,lifecycle_state,visible_from_generation)
        VALUES('reset-concept','Platform','application-component','active',2);
      INSERT INTO analysis_notes(note_id,note_kind,text,importance,uncertainty,next_action,state,grounding_json,author,created_generation,created_at,updated_at)
        VALUES('reset-note','lead','Review Platform',100,0,'','active','{}','fixture',2,'fixture','fixture');
    """)
    connection.execute("INSERT INTO mentions(mention_id,concept_id,revision_chunk_id,span_start,span_end,visible_from_generation) VALUES('reset-mention','reset-concept',?,0,8,2)", (chunk,))
    connection.execute("INSERT INTO analysis_note_links(link_id,note_id,object_type,object_id,revision_chunk_id,span_start,span_end) VALUES('reset-link','reset-note','concept','reset-concept',?,0,8)", (chunk,))
    for name, kind, subject, subject_id, state in [
        ("legacy", "concept-review", "chunk", chunk, "unresolved"),
        ("concept", "identity-review", "concept", "reset-concept", "failed"),
        ("note", "analysis-lead", "note", "reset-note", "review"),
        ("closed", "closed-question", "chunk", chunk, "resolved"),
    ]:
        connection.execute("INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,attempt_count,not_before_epoch,created_epoch,updated_epoch,required_capability,semantic_failures) VALUES(?,?,?,?, 'old-packet','legacy-policy','{}','Old instructions',?,900000,7,9999999999,1,1,'advanced-reasoning',3)", ("task:" + name, kind, subject, subject_id, state))

# Exactly the Scottish failure shape: old extraction review, no maintenance window.
# The pre-change run records the old no-window failure in reset-before.log.
for args in [("--access", "read", "maintain", "reset", "task:legacy"), ("--access", "control", "maintain", "reset"), ("--access", "control", "maintain", "reset", "task:legacy", "--all"), ("--access", "control", "maintain", "reset", "missing")]:
    cli(*args, success=False)
before = facts()
reset = fields(cli("--access", "control", "maintain", "reset", "task:legacy"))
fresh = reset["task_id"]
assert reset["tasks_reset"] == 1 and fresh != "task:legacy"
assert task_state("task:legacy") == "superseded"
assert rows("SELECT attempt_count,semantic_failures,not_before_epoch FROM maintenance_tasks WHERE task_id=?", (fresh,)) == [(0, 0, 0)]
assert facts() == before, "reset changed source, graph or provider history"
assert rows("SELECT count(*) FROM maintenance_windows") == [(0,)], "reset fabricated a run/window"
close_task(fresh)
again = fields(cli("--access", "control", "maintain", "reset", "task:legacy"))
assert again["tasks_reset"] == 0 and again["task_id"] == fresh
assert task_state(fresh) == "resolved"

# Actual retained provider calls and attempts, not only the task's cached counter.
# A historical window exists but deliberately has a different policy fingerprint.
with db() as connection:
    job, snapshot = connection.execute("SELECT job_id,config_snapshot_id FROM jobs LIMIT 1").fetchone()
    connection.execute("INSERT INTO maintenance_runs(run_id,expected_generation,config_snapshot_id,mode,state,plan_digest,canonical_plan,created_at) SELECT 'old-run',published_generation,?,'manual','complete','old-plan','{}','fixture' FROM library_meta", (snapshot,))
    connection.execute("INSERT INTO maintenance_windows(window_id,run_id,job_id,state,deadline_epoch,policy_json,policy_fingerprint,created_epoch) VALUES('old-window','old-run',?,'complete',1,'{}','unrelated-policy',1)", (job,))
    connection.execute("INSERT INTO job_items(item_id,job_id,item_type,state,priority,fence,idempotency_key,input_hash,input_json,created_at,updated_at) VALUES('old-item',?,'maintenance','failed',1,3,'old-item','hash','{}','fixture','fixture')", (job,))
    connection.execute("INSERT INTO maintenance_task_items(item_id,task_id,window_id,attempt_number) VALUES('old-item','task:concept','old-window',7)")
    for n in range(3):
        connection.execute("INSERT INTO provider_runs(provider_run_id,config_snapshot_id,provider_id,model,request_hash,outcome,input_tokens,output_tokens,duration_ms,started_at,completed_at) VALUES(?,?,'fixture','fixture','hash','failed',11,2,17,'fixture','fixture')", (f"run-{n}", snapshot))
        connection.execute("INSERT INTO attempts(attempt_id,item_id,worker_id,fence,input_hash,provider_run_id,validation_state,outcome,started_at,completed_at) VALUES(?,'old-item','historic',?,'hash',?,'transport timeout','failed','fixture','fixture')", (f"attempt-{n}", n, f"run-{n}"))
    connection.execute("INSERT INTO retry_requests(request_id,task_id,source_version,reason,state,disposition,created_epoch,updated_epoch) VALUES('old-retry','task:concept','old','fixture','pending','attempt-limit',1,1)")
# Real in-flight ownership is the only scheduling exclusion; other tasks reset.
with db() as connection:
    connection.execute("INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch) VALUES('task:running','running-review','chunk',?,'old','old','{}','old','dispatched',1,1,1)", (chunk,))
    connection.execute("INSERT INTO job_items(item_id,job_id,item_type,state,priority,idempotency_key,input_hash,input_json,created_at,updated_at) VALUES('running-item',?,'maintenance','running',1,'running-item','hash','{}','fixture','fixture')", (job,))
    connection.execute("INSERT INTO maintenance_task_items(item_id,task_id,window_id,attempt_number) VALUES('running-item','task:running','old-window',1)")
blocked = cli("--access", "control", "maintain", "reset", "task:running", success=False)
assert "drain" in blocked["message"] and task_state("task:running") == "dispatched"
# Pending reviews/waivers are old task bookkeeping; fresh task must be actionable.
with db() as connection:
    connection.execute("INSERT INTO reviews(review_id,review_type,subject_id,state,proposal_json,created_at) VALUES('old-review','maintenance-external','task:note','pending','{}','fixture')")
    connection.execute("INSERT INTO maintenance_task_waivers(waiver_id,task_id,reason,state,created_epoch) VALUES('old-waiver','task:concept','old policy','active',1)")
before = facts()
request = json.dumps(dict(jsonrpc="2.0", id=1, method="initialize", params={})) + "\n"
request += json.dumps(dict(jsonrpc="2.0", id=2, method="tools/call", params=dict(name="rag_task_reset", arguments=dict(all=True)))) + "\n"
rpc = subprocess.run(base + ["--access", "control", "serve", "mcp"], cwd=work, input=request, capture_output=True, text=True, timeout=20)
(work / "mcp-reset.jsonl").write_text(rpc.stdout + rpc.stderr)
assert rpc.returncode == 0 and '"isError":true' not in rpc.stdout.replace(" ", ""), rpc.stdout + rpc.stderr
assert task_state("task:concept") == task_state("task:note") == "superseded", rpc.stdout
assert rows("SELECT state FROM reviews WHERE review_id='old-review'") == [("dismissed",)]
assert task_state("task:closed") == task_state(fresh) == "resolved"
assert task_state("task:running") == "dispatched"
assert '"running_tasks_skipped":1' in rpc.stdout.replace(" ", "")
assert facts() == before
baseline = json.loads(rows("SELECT message FROM job_events WHERE item_id='old-item' AND event_type='retry-reset'")[0][0])
assert baseline["attempts"] == baseline["paid_calls"] == baseline["task_calls"] == 3, baseline
assert rows("SELECT state,disposition FROM retry_requests WHERE request_id='old-retry'") == [("completed", "task-reset")]
assert rows("SELECT state FROM job_items WHERE item_id='old-item'") == [("cancelled",)]
for old in ["task:concept", "task:note"]:
    successor = rows("SELECT task_id FROM maintenance_tasks WHERE parent_task_id=? AND state='pending'", (old,))[0][0]
    assert rows("SELECT attempt_count,semantic_failures,not_before_epoch,required_capability FROM maintenance_tasks WHERE task_id=?", (successor,)) == [(0,0,0,"standard")]
    assert rows("SELECT count(*) FROM maintenance_task_items WHERE task_id=?", (successor,)) == [(0,)]
    close_task(successor)
with db() as connection:
    connection.execute("UPDATE job_items SET state='failed' WHERE item_id='running-item'")
fresh_running = fields(cli("--access", "control", "maintain", "reset", "task:running"))["task_id"]
close_task(fresh_running)
# A deleted subject can close, rather than becoming an unresolvable empty packet.
with db() as connection:
    connection.execute("INSERT INTO maintenance_tasks(task_id,kind,subject_type,subject_id,evidence_fingerprint,policy_fingerprint,evidence_json,question,state,priority,created_epoch,updated_epoch) VALUES('task:gone','concept-review','concept','missing','old','old','{}','old','failed',1,1,1)")
assert fields(cli("--access", "control", "maintain", "reset", "task:gone"))["tasks_reset"] == 1
assert task_state("task:gone") == "resolved"
# Current-policy census must find retained resolved questions, not reopen them.
plan = fields(cli("--access", "plan", "maintain", "plan", "--minutes", "1"))
cli("--access", "curate", "maintain", "apply", "--plan-json", plan["canonical_plan"], "--expect-digest", plan["digest"])
assert rows("SELECT task_id,state FROM maintenance_tasks WHERE kind='concept-review' AND subject_type='chunk' AND state<>'superseded'") == [(fresh,"resolved")], "census reopened the closed chunk review"
assert rows("SELECT count(*),sum(input_tokens),sum(output_tokens) FROM provider_runs") == [(3,33,6)]
assert rows("PRAGMA integrity_check") == [("ok",)]
assert rows("PRAGMA foreign_key_check") == []
print("TASK_RESET_OK: legacy chunk, stale concept, review/waiver, single/all CLI/MCP, zero counters, retained source/graph, normal closure.")
