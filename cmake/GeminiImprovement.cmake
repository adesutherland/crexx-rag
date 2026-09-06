foreach(required_var CPRAG_NATIVE_APPLICATION CPRAG_LOOPBACK
        CPRAG_CONFIG_TEMPLATE CPRAG_PROPOSAL_FIXTURE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/source")
file(WRITE "${CPRAG_WORK_DIR}/source/architecture.txt"
    "BillingService depends on CustomerDatabase.\n"
    "Again, BillingService depends on CustomerDatabase.\n")
set(CPRAG_FIXTURE_GLOSSARY "${CPRAG_WORK_DIR}/architecture.glossary.tsv")
set(glossary_text
    "format\tcrexx-rag.glossary/1\nconcept\tBillingService\tapplication-component\tBilling Service\nconcept\tCustomerDatabase\tdata-store\tCustomer DB\nexclude\tDeprecatedSystem\n")
file(WRITE "${CPRAG_FIXTURE_GLOSSARY}" "${glossary_text}")
set(CPRAG_FIXTURE_PORT 18998)
set(CPRAG_FIXTURE_SOURCE "${CPRAG_WORK_DIR}/source")
configure_file("${CPRAG_CONFIG_TEMPLATE}"
    "${CPRAG_WORK_DIR}/crexxrag.conf" @ONLY)
file(READ "${CPRAG_WORK_DIR}/crexxrag.conf" large_budget_config)
string(REPLACE "budget.input_tokens = 8192" "budget.input_tokens = 31000000"
    large_budget_config "${large_budget_config}")
string(REPLACE "budget.output_tokens = 1024" "budget.output_tokens = 3600000"
    large_budget_config "${large_budget_config}")
string(REPLACE "budget.cost_microunits = 1000000" "budget.cost_microunits = 18000000"
    large_budget_config "${large_budget_config}")
file(WRITE "${CPRAG_WORK_DIR}/crexxrag.conf" "${large_budget_config}")

set(server_out "${CPRAG_WORK_DIR}/loopback.out")
set(server_err "${CPRAG_WORK_DIR}/loopback.err")
set(server_status "${CPRAG_WORK_DIR}/loopback.status")
execute_process(COMMAND /bin/sh -c
    "( \"$1\" \"$2\" 4 product-ingestion; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
    p4r-01 "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${server_out}"
    "${server_err}" "${server_status}"
    RESULT_VARIABLE launch_result)
if(NOT launch_result EQUAL 0)
    message(FATAL_ERROR "could not start Gemini improvement loopback")
endif()
set(ready FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${server_out}")
        file(READ "${server_out}" current_server_out)
        if(current_server_out MATCHES "READY ${CPRAG_FIXTURE_PORT}")
            set(ready TRUE)
            break()
        endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT ready)
    message(FATAL_ERROR "Gemini improvement loopback did not become ready")
endif()

if(NOT EXISTS "${CPRAG_NATIVE_APPLICATION}")
    message(FATAL_ERROR "native crexxrag application is required")
endif()
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
    "${CPRAG_NATIVE_APPLICATION}")

execute_process(COMMAND ${cli} init
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err
    RESULT_VARIABLE init_result TIMEOUT 30)
if(NOT init_result EQUAL 0 OR NOT init_out MATCHES "schema version: 10")
    message(FATAL_ERROR "Improvement test human init failed:\n${init_out}${init_err}")
endif()

execute_process(COMMAND ${cli} ingest --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE ingest_out ERROR_VARIABLE ingest_err
    RESULT_VARIABLE ingest_result TIMEOUT 60)
if(NOT ingest_result EQUAL 0 OR
   NOT ingest_out MATCHES "items queued: 2" OR
   NOT ingest_out MATCHES "state: completed" OR
   NOT ingest_out MATCHES "planned total: 2")
    message(FATAL_ERROR "Improvement prerequisite ingestion failed:\n${ingest_out}${ingest_err}")
endif()

execute_process(COMMAND ${cli} --format json --access plan maintain plan
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE plan_out ERROR_VARIABLE plan_err
    RESULT_VARIABLE plan_result TIMEOUT 30)
if(NOT plan_result EQUAL 0 OR
   NOT plan_out MATCHES "\"maintenance_digest\":\"[0-9a-f]+\"" OR
   NOT plan_out MATCHES "\"work_provider_calls\":1" OR
   NOT plan_out MATCHES "\"maximum_work_provider_calls\":2" OR
   NOT plan_out MATCHES "\"provider_id\":\"gemini-generate\"" OR
   NOT plan_out MATCHES "\"charging_basis\":\"local-compute\"" OR
   NOT plan_out MATCHES "\"worker_processes\":2")
    message(FATAL_ERROR "Machine improvement preview failed:\n${plan_out}${plan_err}")
endif()
string(JSON reviewed_plan ERROR_VARIABLE reviewed_plan_error GET
    "${plan_out}" records 0 fields canonical_plan)
string(JSON reviewed_digest ERROR_VARIABLE reviewed_digest_error GET
    "${plan_out}" records 0 fields digest)
if(reviewed_plan_error OR reviewed_digest_error)
    message(FATAL_ERROR "Machine maintenance preview did not expose its reviewed plan: ${plan_out}")
endif()

# Maintenance review binds the complete discovery context and the exact
# glossary bytes just as ingestion does. Drift is rejected before a run, job,
# provider call, or any other library mutation is created.
find_program(CREXXRAG_SQLITE3 sqlite3 REQUIRED)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
        "SELECT published_generation || ':' || (SELECT count(*) FROM maintenance_runs) || ':' || (SELECT count(*) FROM jobs) FROM library_meta WHERE singleton=1"
    OUTPUT_VARIABLE drift_state_before OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE drift_state_before_err RESULT_VARIABLE drift_state_before_result)
file(APPEND "${CPRAG_FIXTURE_GLOSSARY}" "concept\tUnreviewedConcept\tapplication-component\n")
execute_process(COMMAND ${cli} --format json --access curate maintain apply
        --plan-json "${reviewed_plan}" --expect-digest "${reviewed_digest}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE drift_out ERROR_VARIABLE drift_err
    RESULT_VARIABLE drift_result TIMEOUT 30)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
        "SELECT published_generation || ':' || (SELECT count(*) FROM maintenance_runs) || ':' || (SELECT count(*) FROM jobs) FROM library_meta WHERE singleton=1"
    OUTPUT_VARIABLE drift_state_after OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE drift_state_after_err RESULT_VARIABLE drift_state_after_result)
if(drift_result EQUAL 0 OR
   NOT drift_out MATCHES "reviewed maintenance digest does not match" OR
   drift_err MATCHES "crexxrag provider" OR
   NOT drift_state_before_result EQUAL 0 OR NOT drift_state_after_result EQUAL 0 OR
   NOT drift_state_before STREQUAL drift_state_after)
    message(FATAL_ERROR "Glossary drift was not a zero-mutation, zero-provider maintenance rejection:\n${drift_out}${drift_err}\nbefore=${drift_state_before} ${drift_state_before_err}\nafter=${drift_state_after} ${drift_state_after_err}")
endif()
file(WRITE "${CPRAG_FIXTURE_GLOSSARY}" "${glossary_text}")

execute_process(COMMAND ${cli} maintain --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE improve_out ERROR_VARIABLE improve_err
    RESULT_VARIABLE improve_result TIMEOUT 60)
if(NOT improve_result EQUAL 0 OR
   NOT improve_out MATCHES "Maintenance plan" OR
   NOT improve_out MATCHES "Extraction:       gemini / gemini-3.5-flash-lite" OR
   NOT improve_out MATCHES "Monetary API cost: Not applicable" OR
   NOT improve_out MATCHES "disposition: applied" OR
   NOT improve_out MATCHES "work items: 1" OR
   NOT improve_out MATCHES "state: complete" OR
   NOT improve_out MATCHES "item type: concept-review" OR
   NOT improve_out MATCHES "vector state: identical-no-op" OR
   improve_out MATCHES "canonical_plan|\{\"schema\"" OR
   NOT improve_err MATCHES "crexxrag controller complete")
    message(FATAL_ERROR "Guided improvement failed:\n${improve_out}${improve_err}")
endif()
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
        "SELECT count(*) FROM analysis_notes n JOIN analysis_note_links l ON l.note_id=n.note_id WHERE n.state='active' AND n.note_kind='insight' AND n.text='The repeated dependency deserves explicit validation.' AND n.importance=820000 AND n.uncertainty=280000 AND n.provider_run_id IS NOT NULL AND l.object_type='chunk' AND l.span_start=0 AND l.span_end=43"
    OUTPUT_VARIABLE durable_note_count OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE durable_note_err RESULT_VARIABLE durable_note_result)
if(NOT durable_note_result EQUAL 0 OR NOT durable_note_count STREQUAL "1")
    message(FATAL_ERROR "Gemini maintenance note was not durably stored with provider provenance and its exact citation: ${durable_note_count} ${durable_note_err}")
endif()

execute_process(COMMAND ${cli} query "What does BillingService depend on?"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE query_out ERROR_VARIABLE query_err
    RESULT_VARIABLE query_result TIMEOUT 30)
if(NOT query_result EQUAL 0 OR
   NOT query_out MATCHES "vector state: active-ann-ivf-rxvector" OR
   NOT query_out MATCHES "retrieval mode: hybrid" OR
   NOT query_out MATCHES "BillingService --depends-on--> CustomerDatabase" OR
   NOT query_out MATCHES "citation: .*utf8-(0-43|44-94)" OR
   NOT query_err MATCHES "crexxrag query-embedding complete")
    message(FATAL_ERROR "Maintained installed-style library query failed:\n${query_out}${query_err}")
endif()

execute_process(COMMAND ${cli} maintain --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE settle_out ERROR_VARIABLE settle_err
    RESULT_VARIABLE settle_result TIMEOUT 30)
if(NOT settle_result EQUAL 0 OR
   NOT settle_out MATCHES "disposition: applied" OR
   NOT settle_out MATCHES "work items: 0" OR
   NOT settle_out MATCHES "item type: analysis-lead" OR
   settle_out MATCHES "item type: concept-review" OR
   settle_err MATCHES "crexxrag (controller|worker|provider)")
    message(FATAL_ERROR "New provider diagnosis did not settle into a zero-call durable analysis worklist:\n${settle_out}${settle_err}")
endif()

execute_process(COMMAND ${cli} maintain --yes --workers 2
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE replay_out ERROR_VARIABLE replay_err
    RESULT_VARIABLE replay_result TIMEOUT 30)
if(NOT replay_result EQUAL 0 OR
   NOT replay_out MATCHES "disposition: identical-no-op" OR
   NOT replay_out MATCHES "items: 0" OR
   replay_err MATCHES "crexxrag (controller|worker|provider)")
    message(FATAL_ERROR "Settled maintenance replay was not a zero-call no-op:\n${replay_out}${replay_err}")
endif()

# Exercise lifecycle finalisation through the public review surface, rather
# than treating the lifecycle repository test as sufficient orchestration
# proof. The reviewed synonym publishes a new semantic generation and the
# dispatcher must immediately publish its compatible ANN generation.
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
        "SELECT concept_id FROM concepts WHERE canonical_label='BillingService' AND visible_to_generation IS NULL LIMIT 1"
    OUTPUT_VARIABLE lifecycle_concept OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE lifecycle_concept_err RESULT_VARIABLE lifecycle_concept_result)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
        "SELECT published_generation FROM library_meta WHERE singleton=1"
    OUTPUT_VARIABLE lifecycle_generation OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE lifecycle_generation_err RESULT_VARIABLE lifecycle_generation_result)
if(NOT lifecycle_concept_result EQUAL 0 OR lifecycle_concept STREQUAL "" OR
   NOT lifecycle_generation_result EQUAL 0 OR lifecycle_generation STREQUAL "")
    message(FATAL_ERROR "could not bind the public lifecycle review fixture: ${lifecycle_concept_err}${lifecycle_generation_err}")
endif()
set(lifecycle_action "{\"schema\":\"crexx-rag.lifecycle-action/1\",\"operation\":\"synonym\",\"concept_id\":\"${lifecycle_concept}\",\"target_concept_id\":\"\",\"alias\":\"Billing Platform\",\"concept_type\":\"\",\"successors\":[],\"dispositions\":[],\"reason\":\"reviewed public lifecycle finalisation test\"}")
set(lifecycle_proposal "{\"schema\":\"crexx-rag.maintenance-review/1\",\"maintenance_item_id\":\"item-public-lifecycle\",\"expected_generation\":${lifecycle_generation},\"action\":${lifecycle_action}}")
set(lifecycle_sql_file "${CPRAG_WORK_DIR}/public-lifecycle-review.sql")
file(WRITE "${lifecycle_sql_file}"
    "INSERT INTO maintenance_runs(run_id,expected_generation,config_snapshot_id,mode,state,plan_digest,canonical_plan,created_at) SELECT 'run-public-lifecycle',${lifecycle_generation},config_snapshot_id,'reviewed','running','digest-public-lifecycle','{}',strftime('%Y-%m-%dT%H:%M:%fZ','now') FROM published_generations WHERE generation=${lifecycle_generation};\n"
    "INSERT INTO maintenance_items(item_id,run_id,item_type,subject_type,subject_id,score,trigger_json,diagnosis_json,action_json,state,expected_generation,created_at,updated_at) VALUES('item-public-lifecycle','run-public-lifecycle','synonym','concept','${lifecycle_concept}',900000,'{}','{}','${lifecycle_action}','review-required',${lifecycle_generation},strftime('%Y-%m-%dT%H:%M:%fZ','now'),strftime('%Y-%m-%dT%H:%M:%fZ','now'));\n"
    "INSERT INTO reviews(review_id,review_type,subject_id,state,proposal_json,created_at) VALUES('review-public-lifecycle','maintenance-synonym','item-public-lifecycle','pending','${lifecycle_proposal}',strftime('%Y-%m-%dT%H:%M:%fZ','now'));\n")
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    INPUT_FILE "${lifecycle_sql_file}"
    OUTPUT_VARIABLE lifecycle_seed_out ERROR_VARIABLE lifecycle_seed_err
    RESULT_VARIABLE lifecycle_seed_result)
if(NOT lifecycle_seed_result EQUAL 0)
    message(FATAL_ERROR "could not seed the public lifecycle review fixture: ${lifecycle_seed_out}${lifecycle_seed_err}")
endif()
execute_process(COMMAND ${cli} --profile it-architecture-profile --access curate
        --format json review decide review-public-lifecycle
        --decision accept --apply
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE lifecycle_decide_out ERROR_VARIABLE lifecycle_decide_err
    RESULT_VARIABLE lifecycle_decide_result TIMEOUT 30)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
        "SELECT (SELECT count(*) FROM aliases WHERE normalized_alias='billing platform' AND target_concept_id='${lifecycle_concept}' AND visible_to_generation IS NULL) || ':' || (SELECT count(*) FROM vector_generations WHERE semantic_generation=(SELECT published_generation FROM library_meta WHERE singleton=1) AND algorithm='ivf-flat-v1' AND state='published')"
    OUTPUT_VARIABLE lifecycle_state OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE lifecycle_state_err RESULT_VARIABLE lifecycle_state_result)
if(NOT lifecycle_decide_result EQUAL 0 OR
   NOT lifecycle_decide_out MATCHES "\"promotion_disposition\":\"synonym-applied\"" OR
   NOT lifecycle_decide_out MATCHES "\"vector_state\":\"published\"" OR
   NOT lifecycle_decide_out MATCHES "\"vector_generations\":1" OR
   NOT lifecycle_state_result EQUAL 0 OR NOT lifecycle_state STREQUAL "1:1")
    message(FATAL_ERROR "public lifecycle review did not atomically publish its synonym and ANN generation:\n${lifecycle_decide_out}${lifecycle_decide_err}\nstate=${lifecycle_state} ${lifecycle_state_err}")
endif()

# Exercise the enduring discovery and external-proposal surfaces against the
# same real, Gemini-ingested library. These operations make no provider calls.
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
        "SELECT revision_chunk_id FROM revision_chunks WHERE visible_to_generation IS NULL ORDER BY revision_chunk_id LIMIT 1"
    OUTPUT_VARIABLE CREXXRAG_PROPOSAL_CHUNK
    ERROR_VARIABLE proposal_chunk_err RESULT_VARIABLE proposal_chunk_result
    OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT proposal_chunk_result EQUAL 0 OR CREXXRAG_PROPOSAL_CHUNK STREQUAL "")
    message(FATAL_ERROR "could not select the active evidence chunk: ${proposal_chunk_err}")
endif()
configure_file("${CPRAG_PROPOSAL_FIXTURE}"
    "${CPRAG_WORK_DIR}/external-proposal.ndjson" @ONLY)
execute_process(COMMAND ${cli} --format json provider list
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE provider_list_out ERROR_VARIABLE provider_list_err
    RESULT_VARIABLE provider_list_result TIMEOUT 30)
execute_process(COMMAND ${cli} --format json profile list
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE profile_list_out ERROR_VARIABLE profile_list_err
    RESULT_VARIABLE profile_list_result TIMEOUT 30)
execute_process(COMMAND ${cli} --format json profile show it-architecture-profile
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE profile_show_out ERROR_VARIABLE profile_show_err
    RESULT_VARIABLE profile_show_result TIMEOUT 30)
if(NOT provider_list_result EQUAL 0 OR
   NOT provider_list_out MATCHES "\"provider_id\":\"gemini-generate\"" OR
   NOT provider_list_out MATCHES "\"provider_id\":\"gemini-embed\"" OR
   NOT profile_list_result EQUAL 0 OR
   NOT profile_list_out MATCHES "\"profile_id\":\"it-architecture-profile\"" OR
   NOT profile_show_result EQUAL 0 OR
   NOT profile_show_out MATCHES "\"relationship_type\":\"depends-on\"")
    message(FATAL_ERROR "provider/profile discovery failed:\n${provider_list_out}${provider_list_err}${profile_list_out}${profile_list_err}${profile_show_out}${profile_show_err}")
endif()

execute_process(COMMAND ${cli} --profile it-architecture-profile --access plan
        --format json proposal plan --input "${CPRAG_WORK_DIR}/external-proposal.ndjson"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE proposal_plan_out ERROR_VARIABLE proposal_plan_err
    RESULT_VARIABLE proposal_plan_result TIMEOUT 30)
string(JSON proposal_plan ERROR_VARIABLE proposal_plan_json_error GET
    "${proposal_plan_out}" records 0 fields canonical_plan)
string(JSON proposal_digest ERROR_VARIABLE proposal_digest_json_error GET
    "${proposal_plan_out}" records 0 fields digest)
if(NOT proposal_plan_result EQUAL 0 OR proposal_plan_json_error OR
   proposal_digest_json_error OR
   NOT proposal_plan_out MATCHES "\"library_writes\":0")
    message(FATAL_ERROR "external proposal planning failed:\n${proposal_plan_out}${proposal_plan_err}")
endif()
execute_process(COMMAND ${cli} --profile it-architecture-profile --access curate
        --format json proposal apply --plan-json "${proposal_plan}"
        --expect-digest "${proposal_digest}"
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE proposal_apply_out ERROR_VARIABLE proposal_apply_err
    RESULT_VARIABLE proposal_apply_result TIMEOUT 30)
if(NOT proposal_apply_result EQUAL 0 OR
   NOT proposal_apply_out MATCHES "\"reviews_created\":1")
    message(FATAL_ERROR "external proposal apply failed:\n${proposal_apply_out}${proposal_apply_err}")
endif()
execute_process(COMMAND ${cli} --format json review list
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE review_list_out ERROR_VARIABLE review_list_err
    RESULT_VARIABLE review_list_result TIMEOUT 30)
string(JSON review_count ERROR_VARIABLE review_count_error LENGTH
    "${review_list_out}" records)
set(external_review_id "")
if(NOT review_count_error)
    math(EXPR review_last "${review_count} - 1")
    foreach(index RANGE 0 ${review_last})
        string(JSON review_name ERROR_VARIABLE review_name_error GET
            "${review_list_out}" records ${index} fields name)
        if(NOT review_name_error AND review_name STREQUAL "external-proposal")
            string(JSON external_review_id GET
                "${review_list_out}" records ${index} fields identity)
        endif()
    endforeach()
endif()
if(NOT review_list_result EQUAL 0 OR external_review_id STREQUAL "")
    message(FATAL_ERROR "external proposal review was not visible:\n${review_list_out}${review_list_err}")
endif()
execute_process(COMMAND ${cli} --profile it-architecture-profile --access curate
        --format json review decide "${external_review_id}"
        --decision accept --apply
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE review_decide_out ERROR_VARIABLE review_decide_err
    RESULT_VARIABLE review_decide_result TIMEOUT 30)
if(NOT review_decide_result EQUAL 0 OR
   NOT review_decide_out MATCHES "\"state\":\"accepted\"" OR
   NOT review_decide_out MATCHES "\"promotion_disposition\":\"accepted\"" OR
   NOT review_decide_out MATCHES "\"vector_state\":\"published\"" OR
   NOT review_decide_out MATCHES "\"vector_generations\":1")
    message(FATAL_ERROR "external proposal review promotion failed:\n${review_decide_out}${review_decide_err}")
endif()

execute_process(COMMAND ${cli} --access diagnose library verify
    WORKING_DIRECTORY "${CPRAG_WORK_DIR}"
    OUTPUT_VARIABLE verify_out ERROR_VARIABLE verify_err
    RESULT_VARIABLE verify_result TIMEOUT 30)
if(NOT verify_result EQUAL 0 OR NOT verify_out MATCHES "state: verified" OR
   NOT verify_out MATCHES "issue count: 0")
    message(FATAL_ERROR "Improved library verification failed:\n${verify_out}${verify_err}")
endif()

set(exited FALSE)
foreach(poll RANGE 1 200)
    if(EXISTS "${server_status}")
        set(exited TRUE)
        break()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
endforeach()
if(NOT exited)
    message(FATAL_ERROR "Gemini improvement loopback did not exit")
endif()
file(READ "${server_status}" server_result)
file(READ "${server_out}" final_server_out)
file(READ "${server_err}" final_server_err)
if(NOT server_result STREQUAL "0" OR
   NOT final_server_out MATCHES "SUMMARY scenario=product-ingestion connections=4")
    message(FATAL_ERROR "Gemini improvement loopback failed:\n${final_server_out}${final_server_err}")
endif()

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "test=gemini-maintenance\nprovider=gemini\nrequests=4\n"
    "ingest_calls=2\nimprovement_calls=1\nreplay_calls=0\n"
    "surface=crexxrag-maintain\nprovider_input=durable\nglossary_drift=zero-mutation-rejected\nvector_output=ann-published\n"
    "${init_out}${ingest_out}${ingest_err}${plan_out}${plan_err}${drift_out}${drift_err}${improve_out}${improve_err}${query_out}${query_err}${settle_out}${settle_err}${replay_out}${replay_err}${lifecycle_decide_out}${lifecycle_decide_err}${provider_list_out}${profile_list_out}${profile_show_out}${proposal_plan_out}${proposal_apply_out}${review_list_out}${review_decide_out}${verify_out}${verify_err}")
message(STATUS "Gemini maintenance and the public provider, profile, lifecycle, proposal, and review surfaces passed with glossary-drift rejection, durable-note output, ANN finalisation, integrity verification, and zero-call replay")

# Maintenance worklists must be completely inspectable beyond the old silent
# 99/100-item rendering limit. A cursor follows stable score/ID ordering.
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT run_id FROM maintenance_runs ORDER BY created_at DESC,run_id DESC LIMIT 1"
    OUTPUT_VARIABLE page_run OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "WITH RECURSIVE seq(n) AS (VALUES(1) UNION ALL SELECT n+1 FROM seq WHERE n<105) INSERT INTO maintenance_items(item_id,run_id,item_type,subject_type,subject_id,score,trigger_json,diagnosis_json,action_json,state,expected_generation,created_at,updated_at) SELECT 'pagination-'||printf('%03d',seq.n),m.run_id,m.item_type,m.subject_type,'pagination-subject-'||seq.n,m.score,m.trigger_json,m.diagnosis_json,m.action_json,'review-required',m.expected_generation,m.created_at,m.updated_at FROM seq CROSS JOIN (SELECT * FROM maintenance_items WHERE run_id='${page_run}' ORDER BY item_id LIMIT 1) m"
    COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${CPRAG_WORK_DIR}/library/library.sqlite"
    "SELECT count(*) FROM maintenance_items WHERE run_id='${page_run}'"
    OUTPUT_VARIABLE page_expected OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
foreach(operation IN ITEMS status inspect)
    set(page_cursor "")
    set(page_ids)
    foreach(page RANGE 1 20)
        set(cursor_argument)
        if(NOT page_cursor STREQUAL "")
            set(cursor_argument --cursor "${page_cursor}")
        endif()
        execute_process(COMMAND ${cli} --format json maintain ${operation} --id "${page_run}" --limit 17 ${cursor_argument}
            WORKING_DIRECTORY "${CPRAG_WORK_DIR}" OUTPUT_VARIABLE page_out ERROR_VARIABLE page_err RESULT_VARIABLE page_result TIMEOUT 30)
        if(NOT page_result EQUAL 0)
            message(FATAL_ERROR "maintenance ${operation} pagination failed: ${page_out}${page_err}")
        endif()
        string(JSON page_length LENGTH "${page_out}" records)
        math(EXPR last_record "${page_length}-1")
        string(JSON page_kind GET "${page_out}" records ${last_record} kind)
        string(JSON page_cursor GET "${page_out}" records ${last_record} fields next_cursor)
        if(NOT page_kind STREQUAL "maintenance-page" OR page_length GREATER 19)
            message(FATAL_ERROR "maintenance pagination metadata is absent or oversized: ${page_out}")
        endif()
        foreach(row RANGE 0 ${last_record})
            string(JSON row_kind GET "${page_out}" records ${row} kind)
            if(row_kind STREQUAL "maintenance-item")
                string(JSON row_id GET "${page_out}" records ${row} fields item_id)
                if(row_id IN_LIST page_ids)
                    message(FATAL_ERROR "maintenance pagination repeated ${row_id}")
                endif()
                list(APPEND page_ids "${row_id}")
            endif()
        endforeach()
        if(page_cursor STREQUAL "")
            break()
        endif()
    endforeach()
    list(LENGTH page_ids page_received)
    if(NOT page_received EQUAL page_expected OR page_received LESS 105)
        message(FATAL_ERROR "maintenance ${operation} pagination lost rows: ${page_received}/${page_expected}")
    endif()
endforeach()
file(APPEND "${CPRAG_WORK_DIR}/result.txt" "maintenance_pagination=complete-status+inspect\n")
